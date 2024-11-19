pub fn set_text_colors(~fg : UInt, ~bg : UInt) -> Unit {
  @wasm4.set_draw_colors(fg, index=1)
  @wasm4.set_draw_colors(bg, index=2)
}

pub fn set_shape_colors(~fill : UInt, ~border : UInt) -> Unit {
  @wasm4.set_draw_colors(fill, index=1)
  @wasm4.set_draw_colors(border, index=2)
}

pub struct Pos {
  x : Int
  y : Int
} derive(Default, Show)

pub struct Size {
  w : Int
  h : Int
} derive(Default, Show)

pub fn text(s : String, ~pos : Pos) -> Unit {
  @wasm4.text(s, pos.x, pos.y)
}

pub fn rect(~pos : Pos, ~size : Size) -> Unit {
  @wasm4.rect(pos.x, pos.y, size.w, size.h)
}

pub fn oval(~pos : Pos, ~size : Size) -> Unit {
  @wasm4.oval(pos.x, pos.y, size.w, size.h)
}

pub let screen_width : Int = 160

pub let screen_height : Int = 160

pub fn get_pixel(pos : Pos) -> UInt {
  @wasm4.get_frame_buffer((pos.x + pos.y * screen_width).reinterpret_as_uint())
}

pub fn save_score_data(s : UInt) -> Unit {
  @wasm4.disk_write(Bytes::from_array([s.to_byte()]), 1U) |> ignore
}

pub fn load_score_data() -> UInt {
  let bytes = Bytes::make(1, (0).to_byte())
  if @wasm4.disk_read(bytes, 1U) > 0 {
    bytes[0].to_int().reinterpret_as_uint()
  } else {
    0U
  }
}
