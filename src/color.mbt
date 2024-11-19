let color1 = 1U

let color2 = 2U

let color3 = 3U

let color4 = 4U

let color0 = 0U

pub fn init_palette() -> Unit {
  @wasm4.set_palette(1, @wasm4.rgb(0xf1f2da))
  @wasm4.set_palette(2, @wasm4.rgb(0xffce96))
  @wasm4.set_palette(3, @wasm4.rgb(0xff7777))
  @wasm4.set_palette(4, @wasm4.rgb(0x00303b))
}

pub fn set_sprite_colors() -> Unit {
  @wasm4.set_draw_colors(color0, index=1)
  @wasm4.set_draw_colors(color2, index=2)
  @wasm4.set_draw_colors(color3, index=3)
  @wasm4.set_draw_colors(color4, index=4)
}

pub fn set_text_colors() -> Unit {
  @lib.set_text_colors(fg=color4, bg=color0)
}

pub fn set_shape_colors(~fill : UInt, ~border : UInt) -> Unit {
  @lib.set_shape_colors(~fill, ~border)
}

pub fn set_ground_colors() -> Unit {
  @wasm4.set_draw_colors(color1, index=1)
  @wasm4.set_draw_colors(color2, index=2)
  @wasm4.set_draw_colors(color3, index=3)
  @wasm4.set_draw_colors(color4, index=4)
}
