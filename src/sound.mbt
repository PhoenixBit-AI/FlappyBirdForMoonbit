fn flap_tone() -> Unit {
  @wasm4.tone(
    (300, 600),
    @wasm4.ADSR::new(0, attack=5, decay=10, release=10),
    @wasm4.ADSRVolume::new(30, peak=60),
    @wasm4.ToneFlag::new(channel=Pulse1, mode=Duty_1_4),
  )
}

fn point_tone() -> Unit {
  @wasm4.tone(
    (800, 1200),
    @wasm4.ADSR::new(0, attack=0, decay=4, release=4),
    @wasm4.ADSRVolume::new(50, peak=100),
    @wasm4.ToneFlag::new(channel=Pulse2, mode=Duty_3_4),
  )
}

fn gameover_tone() -> Unit {
  @wasm4.tone(
    (400, 100),
    @wasm4.ADSR::new(0, decay=60, release=0),
    @wasm4.ADSRVolume::new(100, peak=100),
    @wasm4.ToneFlag::new(channel=Triangle),
  )
}