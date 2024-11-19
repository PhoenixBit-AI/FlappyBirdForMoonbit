enum AnimationState {
  Completed
  RunOnce
  Loop
}

struct AnimationCell {
  frames : UInt
  sprite : Sprite
}

struct Animation {
  lastUpdated : UInt
  index : UInt
  cells : Array[AnimationCell]
  state : AnimationState
}

pub fn Animation::default() -> Animation {
  Animation::{ lastUpdated: 0, index: 0, cells: [], state: Loop }
}

fn inc(index : UInt, count : UInt) -> UInt {
  let next = index + 1
  if next == count {
    0
  } else {
    next
  }
}

fn update_animation(self : Animation, frameCount : UInt) -> Animation {
  let framesPerUpdate = match self.cells.get(self.index.reinterpret_as_int()) {
    Some({ frames, .. }) => frames
    None =>
      abort("animation cell out of bounds at index: $(self.index |> Num.toStr)")
  }
  if frameCount - self.lastUpdated < framesPerUpdate {
    { ..self }
  } else {
    let nextIndex = inc(
      self.index,
      self.cells.length().reinterpret_as_uint(),
    )
    match self.state {
      Completed => { ..self, lastUpdated: frameCount }
      Loop => { ..self, index: nextIndex, lastUpdated: frameCount }
      RunOnce =>
        if nextIndex == 0 {
          { ..self, state: Completed, lastUpdated: frameCount }
        } else {
          { ..self, index: nextIndex, lastUpdated: frameCount }
        }
    }
  }
}

fn draw_animation(
  self : Animation,
  ~pos : @lib.Pos,
  ~flags? : @wasm4.BlitFlag
) -> Unit {
  match self.cells.get(self.index.reinterpret_as_int()) {
    Some({ sprite, .. }) => {
      set_sprite_colors()
      sprite.blit(~pos, flags=flags.or(sprite.flags))
    }
    None => {
      log("animation cell out of bounds at index")
      panic()
    }
  }
}

fn create_bird_idle_anim(frameCount : UInt) -> Animation {
  {
    lastUpdated: frameCount,
    index: 0,
    state: Loop,
    cells: [
      {
        frames: 17,
        sprite: birdSpriteSheet.sub(
          pos={ x: 0, y: 0 },
          size={ w: 16, h: 16 },
        ),
      },
      {
        frames: 6,
        sprite: birdSpriteSheet.sub(
          pos={ x: 16, y: 0 },
          size={ w: 16, h: 16 },
        ),
      },
      {
        frames: 17,
        sprite: birdSpriteSheet.sub(
          pos={ x: 32, y: 0 },
          size={ w: 16, h: 16 },
        ),
      },
    ],
  }
}

pub fn create_bird_flap_anim(frameCount : UInt) -> Animation {
  {
    lastUpdated: frameCount,
    index: 2,
    state: Completed,
    cells: [
      {
        frames: 6,
        sprite: birdSpriteSheet.sub(
          pos={ x: 16, y: 0 },
          size={ w: 16, h: 16 },
        ),
      },
      {
        frames: 12,
        sprite: birdSpriteSheet.sub(
          pos={ x: 32, y: 0 },
          size={ w: 16, h: 16 },
        ),
      },
      {
        frames: 1,
        sprite: birdSpriteSheet.sub(
          pos={ x: 0, y: 0 },
          size={ w: 16, h: 16 },
        ),
      },
    ],
  }
}

pub fn create_bird_fall_anim(frameCount : UInt) -> Animation {
  {
    lastUpdated: frameCount,
    index: 0,
    state: Loop,
    cells: [
      {
        frames: 10,
        sprite: birdSpriteSheet.sub(
          pos={ x: 48, y: 0 },
          size={ w: 16, h: 16 },
        ),
      },
      {
        frames: 10,
        sprite: birdSpriteSheet.sub(
          pos={ x: 64, y: 0 },
          size={ w: 16, h: 16 },
        ),
      },
    ],
  }
}
