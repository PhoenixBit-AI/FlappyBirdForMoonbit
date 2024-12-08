struct Sprite {
  sprite : @wasm4.Sprite
  pos : @lib.Pos
  size : @lib.Size
  flags : @wasm4.BlitFlag
  stride : Int
}

pub fn Sprite::from_array(
  ~data : Array[UInt],
  ~size : @lib.Size,
  ~flags : @wasm4.BlitFlag
) -> Sprite {
  {
    sprite: @wasm4.sprite(data.map(fn(v) { v.to_byte() }) |> Bytes::from_array),
    size,
    flags,
    pos: @lib.Pos::default(),
    stride: size.w,
  }
}

pub fn Sprite::sub(
  self : Sprite,
  ~pos : @lib.Pos,
  ~size : @lib.Size
) -> Sprite {
  try {
    if pos.x + size.w > self.size.w || pos.y + size.h > self.size.h {
      raise GameError("out of bounds")
    }
    { ..self, pos: { x: self.pos.x + pos.x, y: self.pos.y + pos.y }, size }
  } catch {
    GameError(s) => {
      log(s)
      panic()
    }
  }
}

fn blit(self : Sprite, ~pos : @lib.Pos, ~flags? : @wasm4.BlitFlag) -> Unit {
  self.sprite.blit_sub(
    pos.x,
    pos.y,
    self.size.w,
    self.size.h,
    self.pos.x,
    self.pos.y,
    self.stride,
    flags.or(self.flags),
  )
}

let groundSprite : Sprite = Sprite::from_array(
  data=[
    0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
    0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
    0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
    0xff, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa,
    0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa,
    0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa,
    0xaa, 0xaa, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55,
    0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55,
    0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55,
    0x55, 0x55, 0x55, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x44, 0x44, 0x44, 0x44, 0x44, 0x44, 0x44, 0x44,
    0x44, 0x44, 0x44, 0x44, 0x44, 0x44, 0x44, 0x44, 0x44, 0x44, 0x44, 0x44, 0x44,
    0x44, 0x44, 0x44, 0x44, 0x44, 0x44, 0x44, 0x44, 0x44, 0x44, 0x44, 0x44, 0x44,
    0x44, 0x44, 0x44, 0x44, 0x44, 0x44, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11,
    0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11,
    0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11,
    0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55,
    0x55, 0x55, 0x65, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x59, 0x55, 0x55, 0x55,
    0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x95, 0x55, 0x55, 0x55, 0x55,
    0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x45, 0x14, 0x51, 0x85, 0x14,
    0x51, 0x49, 0x14, 0x91, 0x45, 0x18, 0x51, 0x54, 0x51, 0x49, 0x24, 0x51, 0x46,
    0x14, 0x51, 0x46, 0x15, 0x14, 0x61, 0x45, 0x14, 0x92, 0x45, 0x14, 0x61, 0x46,
    0x14, 0x55, 0x14, 0x51, 0x45, 0x14, 0x61, 0x51, 0x45, 0x65, 0x66, 0x56, 0x56,
    0x59, 0x56, 0x59, 0x56, 0x55, 0x65, 0x65, 0x56, 0x59, 0x56, 0x59, 0x95, 0x59,
    0x59, 0x55, 0x99, 0x59, 0x59, 0x55, 0x95, 0x96, 0x55, 0x99, 0x55, 0x95, 0x95,
    0x59, 0x55, 0x96, 0x55, 0x59, 0x59, 0x95, 0x95, 0x96, 0x55, 0x95, 0x95, 0x99,
    0x66, 0x65, 0x99, 0x65, 0x96, 0x95, 0x96, 0x59, 0x59, 0x65, 0x99, 0x65, 0xa5,
    0x65, 0x96, 0x56, 0x56, 0x65, 0x99, 0x96, 0x59, 0x99, 0x66, 0x5a, 0x56, 0x59,
    0x65, 0x96, 0x56, 0x59, 0x66, 0x65, 0x65, 0x66, 0x59, 0x99, 0x59, 0xa6, 0x9a,
    0x5a, 0x69, 0x6a, 0x5a, 0x66, 0xa5, 0xa6, 0x9a, 0x9a, 0x6a, 0x6a, 0x5a, 0x65,
    0x69, 0xa6, 0xa6, 0x9a, 0x69, 0x69, 0xa5, 0xa6, 0x9a, 0x5a, 0x96, 0x56, 0x9a,
    0x6a, 0x6a, 0xa6, 0x9a, 0x9a, 0x96, 0xa9, 0xa6, 0x96, 0x9a, 0x5a, 0x69, 0xaa,
    0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa,
    0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa,
    0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa,
  ],
  flags={
    one_bit_per_pixel: false,
    flip_x: false,
    flip_y: false,
    rotate: false,
  },
  size={ w: 160, h: 13 },
)

let birdSpriteSheet : Sprite = Sprite::from_array(
  data=[
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x15, 0x56, 0x00, 0x00, 0x10, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x81, 0x00, 0x00, 0x00, 0x80,
    0x40, 0x05, 0x56, 0x81, 0x80, 0x14, 0x00, 0x01, 0x80, 0x00, 0x00, 0x01, 0x80,
    0x00, 0x02, 0x85, 0x00, 0x00, 0x02, 0x81, 0x40, 0x01, 0x56, 0xa5, 0xa0, 0x15,
    0x00, 0x05, 0xa0, 0x00, 0x00, 0x05, 0xa0, 0x00, 0x0a, 0x95, 0x00, 0x00, 0x0a,
    0x85, 0x40, 0x00, 0x56, 0xa9, 0x00, 0x15, 0x56, 0xa5, 0x00, 0x00, 0x00, 0x15,
    0x00, 0x00, 0x06, 0x55, 0x00, 0x00, 0x06, 0x55, 0x40, 0x00, 0x06, 0xaa, 0x00,
    0x15, 0x5a, 0xaa, 0x00, 0x15, 0x56, 0xaa, 0x00, 0x00, 0x16, 0x95, 0x00, 0x00,
    0x06, 0x95, 0x00, 0x00, 0x09, 0x55, 0x00, 0x15, 0x6a, 0xa9, 0x00, 0x05, 0x56,
    0xa9, 0x00, 0x00, 0x16, 0x94, 0x00, 0x00, 0x16, 0x95, 0x00, 0x00, 0x09, 0x54,
    0x00, 0x05, 0x6a, 0x94, 0x00, 0x01, 0x56, 0xa4, 0x00, 0x00, 0x1a, 0x94, 0x00,
    0x00, 0x16, 0x94, 0x00, 0x00, 0x09, 0x50, 0x00, 0x00, 0x69, 0x50, 0x00, 0x00,
    0x56, 0x90, 0x00, 0x00, 0x1a, 0xa0, 0x00, 0x00, 0x1a, 0xa0, 0x00, 0x00, 0x29,
    0x40, 0x00, 0x00, 0x29, 0x40, 0x00, 0x00, 0x26, 0x40, 0x00, 0x00, 0x0a, 0xa0,
    0x00, 0x00, 0x0a, 0xa0, 0x00, 0x00, 0x29, 0x00, 0x00, 0x00, 0x29, 0x00, 0x00,
    0x00, 0x29, 0x00, 0x00, 0x00, 0x0a, 0x80, 0x00, 0x00, 0x0a, 0x80, 0x00, 0x00,
    0x2a, 0x00, 0x00, 0x00, 0x2a, 0x00, 0x00, 0x00, 0x2a, 0x00, 0x00, 0x00, 0x05,
    0x40, 0x00, 0x00, 0x05, 0x40, 0x00, 0x00, 0x28, 0x00, 0x00, 0x00, 0x28, 0x00,
    0x00, 0x00, 0x28, 0x00, 0x00, 0x00, 0xa5, 0x00, 0x00, 0x00, 0xa5, 0x00, 0x00,
    0x00, 0x20, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0x00,
    0x24, 0x00, 0x00, 0x00, 0x24, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
  ],
  flags={
    one_bit_per_pixel: false,
    flip_x: false,
    flip_y: false,
    rotate: false,
  },
  size={ w: 80, h: 16 },
)

let pipeSprite : Sprite = Sprite::from_array(
  data=[
    0x0a, 0xaa, 0xaa, 0xab, 0xf0, 0x25, 0x55, 0x55, 0x55, 0x5c, 0x26, 0x96, 0x6a,
    0x9a, 0xac, 0x36, 0x96, 0x6a, 0x66, 0xac, 0x36, 0x96, 0x6a, 0x9a, 0xac, 0x0f,
    0xff, 0xff, 0xff, 0xf0, 0x03, 0x65, 0x9a, 0x66, 0xc0, 0x03, 0x65, 0x9a, 0x9a,
    0xc0, 0x03, 0x65, 0x9a, 0x66, 0xc0, 0x03, 0x65, 0x9a, 0x9a, 0xc0, 0x03, 0x65,
    0x9a, 0x66, 0xc0, 0x03, 0x65, 0x9a, 0x9a, 0xc0, 0x03, 0x65, 0x9a, 0x66, 0xc0,
    0x03, 0x65, 0x9a, 0x9a, 0xc0, 0x03, 0x65, 0x9a, 0x66, 0xc0, 0x03, 0x65, 0x9a,
    0x9a, 0xc0, 0x03, 0x65, 0x9a, 0x66, 0xc0, 0x03, 0x65, 0x9a, 0x9a, 0xc0, 0x03,
    0x65, 0x9a, 0x66, 0xc0, 0x03, 0x65, 0x9a, 0x9a, 0xc0, 0x03, 0x65, 0x9a, 0x66,
    0xc0, 0x03, 0x65, 0x9a, 0x9a, 0xc0, 0x03, 0x65, 0x9a, 0x66, 0xc0, 0x03, 0x65,
    0x9a, 0x9a, 0xc0, 0x03, 0x65, 0x9a, 0x66, 0xc0, 0x03, 0x65, 0x9a, 0x9a, 0xc0,
    0x03, 0x65, 0x9a, 0x66, 0xc0, 0x03, 0x65, 0x9a, 0x9a, 0xc0, 0x03, 0x65, 0x9a,
    0x66, 0xc0, 0x03, 0x65, 0x9a, 0x9a, 0xc0, 0x03, 0x65, 0x9a, 0x66, 0xc0, 0x03,
    0x65, 0x9a, 0x9a, 0xc0, 0x03, 0x65, 0x9a, 0x66, 0xc0, 0x03, 0x65, 0x9a, 0x9a,
    0xc0, 0x03, 0x65, 0x9a, 0x66, 0xc0, 0x03, 0x65, 0x9a, 0x9a, 0xc0, 0x03, 0x65,
    0x9a, 0x66, 0xc0, 0x03, 0x65, 0x9a, 0x9a, 0xc0, 0x03, 0x65, 0x9a, 0x66, 0xc0,
    0x03, 0x65, 0x9a, 0x9a, 0xc0, 0x03, 0x65, 0x9a, 0x66, 0xc0, 0x03, 0x65, 0x9a,
    0x9a, 0xc0, 0x03, 0x65, 0x9a, 0x66, 0xc0, 0x03, 0x65, 0x9a, 0x9a, 0xc0, 0x03,
    0x65, 0x9a, 0x66, 0xc0, 0x03, 0x65, 0x9a, 0x9a, 0xc0, 0x03, 0x65, 0x9a, 0x66,
    0xc0, 0x03, 0x65, 0x9a, 0x9a, 0xc0, 0x03, 0x65, 0x9a, 0x66, 0xc0, 0x03, 0x65,
    0x9a, 0x9a, 0xc0, 0x03, 0x65, 0x9a, 0x66, 0xc0, 0x03, 0x65, 0x9a, 0x9a, 0xc0,
    0x03, 0x65, 0x9a, 0x66, 0xc0, 0x03, 0x65, 0x9a, 0x9a, 0xc0, 0x03, 0x65, 0x9a,
    0x66, 0xc0, 0x03, 0x65, 0x9a, 0x9a, 0xc0, 0x03, 0x65, 0x9a, 0x66, 0xc0, 0x03,
    0x65, 0x9a, 0x9a, 0xc0, 0x03, 0x65, 0x9a, 0x66, 0xc0, 0x03, 0x65, 0x9a, 0x9a,
    0xc0, 0x03, 0x65, 0x9a, 0x66, 0xc0, 0x03, 0x65, 0x9a, 0x9a, 0xc0, 0x03, 0x65,
    0x9a, 0x66, 0xc0, 0x03, 0x65, 0x9a, 0x9a, 0xc0, 0x03, 0x65, 0x9a, 0x66, 0xc0,
    0x03, 0x65, 0x9a, 0x9a, 0xc0, 0x03, 0x65, 0x9a, 0x66, 0xc0, 0x03, 0x65, 0x9a,
    0x9a, 0xc0, 0x03, 0x65, 0x9a, 0x66, 0xc0, 0x03, 0x65, 0x9a, 0x9a, 0xc0, 0x03,
    0x65, 0x9a, 0x66, 0xc0, 0x03, 0x65, 0x9a, 0x9a, 0xc0, 0x03, 0x65, 0x9a, 0x66,
    0xc0, 0x03, 0x65, 0x9a, 0x9a, 0xc0, 0x03, 0x65, 0x9a, 0x66, 0xc0, 0x03, 0x65,
    0x9a, 0x9a, 0xc0, 0x03, 0x65, 0x9a, 0x66, 0xc0, 0x03, 0x65, 0x9a, 0x9a, 0xc0,
    0x03, 0x65, 0x9a, 0x66, 0xc0, 0x03, 0x65, 0x9a, 0x9a, 0xc0, 0x03, 0x65, 0x9a,
    0x66, 0xc0, 0x03, 0x65, 0x9a, 0x9a, 0xc0, 0x03, 0x65, 0x9a, 0x66, 0xc0, 0x03,
    0x65, 0x9a, 0x9a, 0xc0, 0x03, 0x65, 0x9a, 0x66, 0xc0, 0x03, 0x65, 0x9a, 0x9a,
    0xc0, 0x03, 0x65, 0x9a, 0x66, 0xc0, 0x03, 0x65, 0x9a, 0x9a, 0xc0, 0x03, 0x65,
    0x9a, 0x66, 0xc0, 0x03, 0x65, 0x9a, 0x9a, 0xc0, 0x03, 0x65, 0x9a, 0x66, 0xc0,
    0x03, 0x65, 0x9a, 0x9a, 0xc0, 0x03, 0x65, 0x9a, 0x66, 0xc0, 0x03, 0x65, 0x9a,
    0x9a, 0xc0, 0x03, 0x65, 0x9a, 0x66, 0xc0, 0x03, 0x65, 0x9a, 0x9a, 0xc0, 0x03,
    0x65, 0x9a, 0x66, 0xc0, 0x03, 0x65, 0x9a, 0x9a, 0xc0, 0x03, 0x65, 0x9a, 0x66,
    0xc0, 0x03, 0x65, 0x9a, 0x9a, 0xc0, 0x03, 0x65, 0x9a, 0x66, 0xc0, 0x03, 0x65,
    0x9a, 0x9a, 0xc0, 0x03, 0x65, 0x9a, 0x66, 0xc0, 0x03, 0x65, 0x9a, 0x9a, 0xc0,
    0x03, 0x65, 0x9a, 0x66, 0xc0, 0x03, 0x65, 0x9a, 0x9a, 0xc0, 0x03, 0x65, 0x9a,
    0x66, 0xc0, 0x03, 0x65, 0x9a, 0x9a, 0xc0, 0x03, 0x65, 0x9a, 0x66, 0xc0, 0x03,
    0x65, 0x9a, 0x9a, 0xc0, 0x03, 0x65, 0x9a, 0x66, 0xc0, 0x03, 0x65, 0x9a, 0x9a,
    0xc0, 0x03, 0x65, 0x9a, 0x66, 0xc0, 0x03, 0x65, 0x9a, 0x9a, 0xc0, 0x03, 0x65,
    0x9a, 0x66, 0xc0, 0x03, 0x65, 0x9a, 0x9a, 0xc0, 0x03, 0x65, 0x9a, 0x66, 0xc0,
    0x03, 0x65, 0x9a, 0x9a, 0xc0, 0x03, 0x65, 0x9a, 0x66, 0xc0, 0x03, 0x65, 0x9a,
    0x9a, 0xc0, 0x03, 0x65, 0x9a, 0x66, 0xc0, 0x03, 0x65, 0x9a, 0x9a, 0xc0, 0x03,
    0x65, 0x9a, 0x66, 0xc0, 0x03, 0x65, 0x9a, 0x9a, 0xc0, 0x03, 0x65, 0x9a, 0x66,
    0xc0, 0x03, 0x65, 0x9a, 0x9a, 0xc0, 0x03, 0x65, 0x9a, 0x66, 0xc0, 0x03, 0x65,
    0x9a, 0x9a, 0xc0, 0x03, 0x65, 0x9a, 0x66, 0xc0, 0x03, 0x65, 0x9a, 0x9a, 0xc0,
    0x03, 0x65, 0x9a, 0x66, 0xc0, 0x03, 0x65, 0x9a, 0x9a, 0xc0, 0x03, 0x65, 0x9a,
    0x66, 0xc0, 0x03, 0x65, 0x9a, 0x9a, 0xc0, 0x03, 0x65, 0x9a, 0x66, 0xc0, 0x03,
    0x65, 0x9a, 0x9a, 0xc0, 0x03, 0x65, 0x9a, 0x66, 0xc0, 0x03, 0x65, 0x9a, 0x9a,
    0xc0, 0x03, 0x65, 0x9a, 0x66, 0xc0, 0x03, 0x65, 0x9a, 0x9a, 0xc0, 0x03, 0x65,
    0x9a, 0x66, 0xc0, 0x03, 0x65, 0x9a, 0x9a, 0xc0, 0x03, 0x65, 0x9a, 0x66, 0xc0,
    0x03, 0x65, 0x9a, 0x9a, 0xc0, 0x03, 0x65, 0x9a, 0x66, 0xc0, 0x03, 0x65, 0x9a,
    0x9a, 0xc0, 0x03, 0x65, 0x9a, 0x66, 0xc0, 0x03, 0x65, 0x9a, 0x9a, 0xc0, 0x03,
    0x65, 0x9a, 0x66, 0xc0, 0x03, 0x65, 0x9a, 0x9a, 0xc0, 0x03, 0x65, 0x9a, 0x66,
    0xc0, 0x03, 0x65, 0x9a, 0x9a, 0xc0, 0x03, 0x65, 0x9a, 0x66, 0xc0, 0x03, 0x65,
    0x9a, 0x9a, 0xc0, 0x03, 0x65, 0x9a, 0x66, 0xc0, 0x03, 0x65, 0x9a, 0x9a, 0xc0,
    0x03, 0x65, 0x9a, 0x66, 0xc0, 0x03, 0x65, 0x9a, 0x9a, 0xc0, 0x03, 0x65, 0x9a,
    0x66, 0xc0, 0x03, 0x65, 0x9a, 0x9a, 0xc0,
  ],
  flags={
    one_bit_per_pixel: false,
    flip_x: false,
    flip_y: false,
    rotate: false,
  },
  size={ w: 20, h: 160 },
)

let plantSpriteSheet : Sprite = Sprite::from_array(
  data=[
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x50, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xaa, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x41,
    0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40,
    0x00, 0x00, 0x00, 0x00, 0x01, 0x40, 0x02, 0xaa, 0x00, 0x02, 0xaa, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x02, 0xa0, 0x00, 0x00, 0x00, 0x0a, 0x00, 0xa0, 0x00, 0x08,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x28, 0x00, 0x00, 0x00, 0x00, 0x00, 0x50, 0x40,
    0x00, 0x00, 0x11, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x01, 0x50, 0x00,
    0x00, 0x00, 0x10, 0x05, 0x00, 0x08, 0x00, 0x80, 0x08, 0x08, 0x80, 0x00, 0x2a,
    0x00, 0x00, 0x08, 0x08, 0x00, 0x00, 0x00, 0x20, 0x00, 0x08, 0x00, 0x20, 0x80,
    0x00, 0x00, 0x00, 0x00, 0x20, 0x80, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x08, 0x00, 0x00, 0xa0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80,
    0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x82, 0x00, 0x00, 0x00, 0x00, 0x00, 0x41, 0x40, 0x11,
    0x00, 0x15, 0x00, 0x00, 0x00, 0x00, 0x0a, 0x00, 0x15, 0x05, 0x14, 0x00, 0x28,
    0x00, 0x51, 0x45, 0x00, 0x20, 0x01, 0x60, 0x20, 0x81, 0x60, 0x00, 0x80, 0x80,
    0x0a, 0xa0, 0x16, 0x00, 0xa8, 0x00, 0x82, 0x15, 0x96, 0x02, 0x22, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x82, 0x00, 0x00, 0x00, 0x00, 0x02, 0x08, 0x20, 0x02, 0xa0,
    0x00, 0x00, 0x28, 0x00, 0x02, 0x20, 0x00, 0x02, 0x82, 0x00, 0x06, 0x11, 0x11,
    0x02, 0xb2, 0xb0, 0x02, 0x80, 0x08, 0x00, 0xa0, 0x00, 0x00, 0x00, 0x00, 0x00,
    0xa8, 0x00, 0x02, 0x06, 0x00, 0x00, 0x00, 0x00, 0x00, 0x51, 0x40, 0x15, 0x11,
    0x15, 0x00, 0x00, 0x00, 0x24, 0x20, 0x80, 0x51, 0x41, 0x50, 0x00, 0x22, 0x00,
    0x14, 0x41, 0x44, 0x20, 0x55, 0x60, 0x28, 0x59, 0xa0, 0x02, 0x01, 0x60, 0x20,
    0x21, 0x56, 0x02, 0x02, 0x00, 0x83, 0x55, 0xd6, 0x02, 0xaa, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x8a, 0x00, 0x00, 0x10, 0x40, 0x02, 0xa8, 0x80, 0x09, 0x5c, 0x00,
    0x08, 0x20, 0x08, 0x02, 0x00, 0x00, 0x0a, 0x0a, 0x28, 0x91, 0x44, 0x66, 0x09,
    0x6d, 0x5c, 0x0a, 0x08, 0x20, 0x02, 0x0b, 0x00, 0x00, 0x20, 0x00, 0x02, 0x06,
    0x00, 0x0a, 0x15, 0xa0, 0x00, 0x00, 0x00, 0x02, 0x15, 0xa0, 0x15, 0x15, 0x08,
    0x00, 0x00, 0x00, 0x04, 0x86, 0x60, 0x15, 0x80, 0x48, 0x20, 0x02, 0x08, 0x50,
    0x52, 0x94, 0x21, 0x55, 0x60, 0x21, 0x95, 0x60, 0x02, 0x15, 0x60, 0x80, 0x5a,
    0xa8, 0x08, 0x05, 0x80, 0x81, 0x69, 0x56, 0x0a, 0xea, 0x00, 0x00, 0x28, 0x00,
    0x02, 0xab, 0x80, 0x04, 0x45, 0x10, 0x0a, 0xea, 0x80, 0x03, 0x9a, 0x00, 0x28,
    0xa8, 0x20, 0x02, 0x00, 0x00, 0x28, 0x08, 0xa0, 0x45, 0x19, 0x18, 0x03, 0xef,
    0xeb, 0x28, 0x28, 0xa8, 0x08, 0x20, 0xc0, 0x00, 0x88, 0x00, 0x02, 0x05, 0x80,
    0x26, 0x16, 0x18, 0x02, 0x00, 0x00, 0x02, 0x8a, 0x80, 0x0a, 0x15, 0x28, 0x00,
    0x00, 0x08, 0x05, 0x99, 0xb0, 0x26, 0x08, 0xa0, 0x88, 0x02, 0x22, 0xa1, 0x42,
    0x05, 0x0a, 0xaa, 0x80, 0x0a, 0xaa, 0x80, 0x00, 0xaa, 0x80, 0x85, 0x5a, 0x70,
    0x08, 0x55, 0x80, 0x95, 0x55, 0x56, 0x2b, 0xae, 0x80, 0x00, 0x88, 0x00, 0x0a,
    0xee, 0xa0, 0x11, 0x11, 0x40, 0x0b, 0xab, 0xa0, 0x0b, 0xed, 0xe0, 0xba, 0xba,
    0xa0, 0x02, 0xa8, 0x00, 0x2a, 0x2a, 0xb8, 0x1a, 0x6a, 0x78, 0x29, 0xbe, 0x68,
    0xae, 0xaa, 0xb8, 0x31, 0x81, 0xc0, 0x00, 0x80, 0x00, 0x02, 0x55, 0x80, 0x87,
    0x18, 0x18, 0x09, 0x82, 0x80, 0x00, 0xaa, 0x00, 0x28, 0x08, 0x0a, 0x08, 0x20,
    0x20, 0x05, 0x65, 0xd0, 0x08, 0x02, 0x00, 0x08, 0xaa, 0x20, 0x28, 0x8a, 0x14,
    0x02, 0x17, 0x00, 0x02, 0x17, 0x00, 0x00, 0x27, 0x00, 0x2a, 0xa2, 0x70, 0x02,
    0xaa, 0x00, 0x2a, 0xaa, 0xa8, 0x2b, 0xba, 0xa0, 0x00, 0x87, 0x00, 0x2b, 0xae,
    0xa8, 0x06, 0x66, 0x80, 0x0b, 0xae, 0xb8, 0x25, 0xb9, 0x5c, 0xba, 0xea, 0xe8,
    0x02, 0xe0, 0x00, 0xae, 0xae, 0xea, 0x0b, 0xaa, 0xe0, 0x96, 0x97, 0x96, 0xba,
    0xba, 0xea, 0x31, 0x85, 0x70, 0x00, 0xa0, 0x00, 0x02, 0x67, 0x00, 0x87, 0x1c,
    0x57, 0x21, 0xc8, 0x70, 0x00, 0x2c, 0x00, 0x08, 0x0a, 0x08, 0x28, 0xa8, 0xa8,
    0x01, 0x5f, 0x54, 0x20, 0x00, 0x80, 0x28, 0x2e, 0x28, 0x22, 0x82, 0x0a, 0x02,
    0x17, 0x00, 0x02, 0x17, 0x00, 0x00, 0x27, 0x00, 0x09, 0xc2, 0x70, 0x00, 0x9c,
    0x00, 0x08, 0x55, 0x70, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x2a, 0xce, 0xac, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xab, 0x5b, 0xea, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x3f, 0x03, 0xf0, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x3e, 0xac, 0x3c, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xf0, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00,
  ],
  flags={
    one_bit_per_pixel: false,
    flip_x: false,
    flip_y: false,
    rotate: false,
  },
  size={ w: 360, h: 12 },
)

