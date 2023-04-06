#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
typedef struct _Dart_Handle* Dart_Handle;

typedef struct DartCObject DartCObject;

typedef int64_t DartPort;

typedef bool (*DartPostCObjectFnType)(DartPort port_id, void *message);

typedef struct wire_uint_8_list {
  uint8_t *ptr;
  int32_t len;
} wire_uint_8_list;

typedef struct wire_EngineOptionsExternal {
  struct wire_uint_8_list *sentry_api_key;
  struct wire_uint_8_list *device_config_json;
  struct wire_uint_8_list *user_device_config_json;
  struct wire_uint_8_list *server_name;
  bool crash_reporting;
  bool websocket_use_all_interfaces;
  uint16_t *websocket_port;
  struct wire_uint_8_list *websocket_client_address;
  uint16_t *frontend_websocket_port;
  bool frontend_in_process_channel;
  uint32_t max_ping_time;
  struct wire_uint_8_list *log_level;
  bool allow_raw_messages;
  bool use_bluetooth_le;
  bool use_serial_port;
  bool use_hid;
  bool use_lovense_dongle_serial;
  bool use_lovense_dongle_hid;
  bool use_xinput;
  bool use_lovense_connect;
  bool use_device_websocket_server;
  uint16_t *device_websocket_server_port;
  bool crash_main_thread;
  bool crash_task_thread;
} wire_EngineOptionsExternal;

typedef struct DartCObject *WireSyncReturn;

void store_dart_post_cobject(DartPostCObjectFnType ptr);

Dart_Handle get_dart_object(uintptr_t ptr);

void drop_dart_object(uintptr_t ptr);

uintptr_t new_dart_opaque(Dart_Handle handle);

intptr_t init_frb_dart_api_dl(void *obj);

void wire_run_engine(int64_t port_, struct wire_EngineOptionsExternal *args);

void wire_send(int64_t port_, struct wire_uint_8_list *msg_json);

void wire_stop_engine(int64_t port_);

void wire_send_backend_server_message(int64_t port_, struct wire_uint_8_list *msg);

struct wire_EngineOptionsExternal *new_box_autoadd_engine_options_external_0(void);

uint16_t *new_box_autoadd_u16_0(uint16_t value);

struct wire_uint_8_list *new_uint_8_list_0(int32_t len);

void free_WireSyncReturn(WireSyncReturn ptr);

jint JNI_OnLoad(JavaVM vm, const void *_res);

static int64_t dummy_method_to_enforce_bundling(void) {
    int64_t dummy_var = 0;
    dummy_var ^= ((int64_t) (void*) wire_run_engine);
    dummy_var ^= ((int64_t) (void*) wire_send);
    dummy_var ^= ((int64_t) (void*) wire_stop_engine);
    dummy_var ^= ((int64_t) (void*) wire_send_backend_server_message);
    dummy_var ^= ((int64_t) (void*) new_box_autoadd_engine_options_external_0);
    dummy_var ^= ((int64_t) (void*) new_box_autoadd_u16_0);
    dummy_var ^= ((int64_t) (void*) new_uint_8_list_0);
    dummy_var ^= ((int64_t) (void*) free_WireSyncReturn);
    dummy_var ^= ((int64_t) (void*) store_dart_post_cobject);
    dummy_var ^= ((int64_t) (void*) get_dart_object);
    dummy_var ^= ((int64_t) (void*) drop_dart_object);
    dummy_var ^= ((int64_t) (void*) new_dart_opaque);
    return dummy_var;
}
