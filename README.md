# flutter_ffi_test

lutter_rust_bridge_codegen --rust-input ./src/api.rs --dart-output ../lib/bridge_generated.dart --dart-decl-output ../lib/bridge_definitions.dart --c-output test.h

der inhalt von test.h muss in den native ios ordner unter Runner mit dem Namen bridge_generated.h diese wird durch Runner-Bridging-Header.h mit aufgenommen.

zuvor muss libnative für das universal target gebuildet werden und in der runner build config als dependeny hinzugefügt werden
