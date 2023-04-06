use crate::{
  in_process_frontend::FlutterIntifaceEngineFrontend,
  mobile_init::{self, RUNTIME},
};
use anyhow::Result;
use flutter_rust_bridge::{frb, StreamSink};
use futures::{pin_mut, StreamExt};
use lazy_static::lazy_static;
use once_cell::sync::OnceCell;
use std::sync::{
  atomic::{AtomicBool, Ordering},
  Arc,
};
use tokio::{
  select,
  sync::{broadcast, Notify},
};
use tracing_futures::Instrument;

pub use crate::{EngineOptions, EngineOptionsExternal, IntifaceMessage};
pub use crate::engine::{IntifaceEngine};

static ENGINE_NOTIFIER: OnceCell<Arc<Notify>> = OnceCell::new();
lazy_static! {
  static ref RUN_STATUS: Arc<AtomicBool> = Arc::new(AtomicBool::new(false));
  static ref ENGINE_BROADCASTER: Arc<broadcast::Sender<IntifaceMessage>> =
    Arc::new(broadcast::channel(255).0);
  static ref BACKDOOR_INCOMING_BROADCASTER: Arc<broadcast::Sender<String>> =
    Arc::new(broadcast::channel(255).0);
}

#[frb(mirror(EngineOptionsExternal))]
pub struct _EngineOptionsExternal {
  pub sentry_api_key: Option<String>,
  pub device_config_json: Option<String>,
  pub user_device_config_json: Option<String>,
  pub server_name: String,
  pub crash_reporting: bool,
  pub websocket_use_all_interfaces: bool,
  pub websocket_port: Option<u16>,
  pub frontend_websocket_port: Option<u16>,
  pub frontend_in_process_channel: bool,
  pub max_ping_time: u32,
  pub log_level: Option<String>,
  pub allow_raw_messages: bool,
  pub use_bluetooth_le: bool,
  pub use_serial_port: bool,
  pub use_hid: bool,
  pub use_lovense_dongle_serial: bool,
  pub use_lovense_dongle_hid: bool,
  pub use_xinput: bool,
  pub use_lovense_connect: bool,
  pub use_device_websocket_server: bool,
  pub device_websocket_server_port: Option<u16>,
  pub crash_main_thread: bool,
  pub crash_task_thread: bool,
  pub websocket_client_address: Option<String>
}

pub fn run_engine(sink: StreamSink<String>, args: EngineOptionsExternal) -> Result<()> {
  if RUN_STATUS.load(Ordering::SeqCst) {
    return Err(anyhow::Error::msg("Server already running!"));
  }
  RUN_STATUS.store(true, Ordering::SeqCst);
  if RUNTIME.get().is_none() {
    mobile_init::create_runtime(sink.clone())
      .expect("Runtime should work, otherwise we can't function.");
  }
  if ENGINE_NOTIFIER.get().is_none() {
    ENGINE_NOTIFIER
      .set(Arc::new(Notify::new()))
      .expect("We already checked creation so this shouldn't fail");
  }
  let runtime = RUNTIME.get().expect("Runtime not initialized");
  let frontend = FlutterIntifaceEngineFrontend::new(sink.clone(), ENGINE_BROADCASTER.clone());
  let frontend_waiter = frontend.notify_on_creation();
  let engine = Arc::new(IntifaceEngine::default());
  let engine_clone = engine.clone();
  let notify = ENGINE_NOTIFIER.get().expect("Should be set").clone();
  let notify_clone = notify.clone();
  let options = args.into();

  let mut backdoor_incoming = BACKDOOR_INCOMING_BROADCASTER.subscribe();
  let outgoing_sink = sink.clone();
  // Start our backdoor task first
  runtime.spawn(
    async move {
      // Once we finish our waiter, continue. If we cancel the server run before then, just kill the
      // task.
      info!("Entering backdoor waiter task");
      select! {
        _ = frontend_waiter => {
          // This firing means the frontend is set up, and we just want to continue to creating our backdoor server.
        }
        _ = notify_clone.notified() => {
          return;
        }
      };
      // At this point we know we'll have a server.
      let backdoor_server = if let Some(backdoor_server) = engine_clone.backdoor_server() {
        backdoor_server
      } else {
        // If we somehow *don't* have a server here, something has gone very wrong. Just die.
        return;
      };
      let backdoor_server_stream = backdoor_server.event_stream();
      pin_mut!(backdoor_server_stream);
      loop {
        select! {
          msg = backdoor_incoming.recv() => {
            match msg {
              Ok(msg) => {
                let runtime = RUNTIME.get().expect("Runtime not initialized");
                let sink = outgoing_sink.clone();
                let backdoor_server_clone = backdoor_server.clone();
                runtime.spawn(async move {
                  sink.add(backdoor_server_clone.parse_message(&msg).await);
                });
              }
              Err(_) => break
            }
          },
          outgoing = backdoor_server_stream.next() => {
            match outgoing {
              Some(msg) => { sink.add(msg); }
              None => break
            }
          },
          _ = notify_clone.notified() => break
        }
      }
      info!("Exiting backdoor waiter task");
    }
    .instrument(info_span!("IC Backdoor server task")),
  );

  // Our notifier needs to run in a task by itself, because we don't want our engine future to get
  // cancelled, so we can't select between it and the notifier. It needs to shutdown gracefully.
  let engine_clone = engine.clone();

  runtime.spawn(
    async move {
      info!("Entering main engine waiter task");
      // These futures need to run in parallel, but the frontend will always notify before the engine
      // comes down, and we want the engine to run to completion after stop is called, so we can't
      // call this in a select, as the engine future will be truncated. So, join it is.
      //
      // If the engine somehow exits first, make sure we still leave by triggering our notifier
      // anyways.
      let notify_clone = notify.clone();
      futures::join!(
        async move {
          if let Err(e) = engine.run(&options, Some(Arc::new(frontend))).await {
            error!("Error running engine: {:?}", e);
          }
          notify_clone.notify_waiters();
        },
        async move {
          notify.notified().await;
          engine_clone.stop();
        }
      );
      RUN_STATUS.store(false, Ordering::SeqCst);
      info!("Exiting main engine waiter task");
    }
    .instrument(info_span!("IC main engine task")),
  );
  Ok(())
}

pub fn send(msg_json: String) {
  let msg: IntifaceMessage = serde_json::from_str(&msg_json).unwrap();
  if ENGINE_BROADCASTER.receiver_count() > 0 {
    ENGINE_BROADCASTER
      .send(msg)
      .expect("This should be infallible since we already checked for receivers");
  }
}

pub fn stop_engine() {
  if let Some(notifier) = ENGINE_NOTIFIER.get() {
    notifier.notify_waiters();
  }
}

pub fn send_backend_server_message(msg: String) {
  if BACKDOOR_INCOMING_BROADCASTER.receiver_count() > 0 {
    BACKDOOR_INCOMING_BROADCASTER
      .send(msg)
      .expect("This should be infallible since we already checked for receivers");
  }
}
