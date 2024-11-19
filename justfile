build:
  moon build --debug --target wasm

dev:
  npx wasm4 run target/wasm/debug/build/main.wasm