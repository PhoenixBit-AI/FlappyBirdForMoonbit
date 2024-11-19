let plant_types : Int = 30

let plant_y : Int = @lib.screen_height - 22

let player_start_y : Int = 40

let player_x : Int = 60

let gravity : Float = 0.11

let jump_speed : Float = -2.0

type! GameError String

struct Plant {
  x : Int
  type_ : Int
} derive(Default)

struct GameStartState {
  frameCount : UInt
  plants : Array[Plant]
  birdIdleAnim : Animation
}

pub fn GameStartState::default() -> GameStartState {
  GameStartState::{
    frameCount: 0,
    plants: [],
    birdIdleAnim: Animation::default(),
  }
}

struct GameOverState {
  frameCount : UInt
  score : UInt
  player : Player
  birdFallAnim : Animation
  pipes : Array[Pipe]
  plants : Array[Plant]
  groundX : Int
}

enum Model {
  GameStart(GameStartState)
  GameIn(GameInState)
  GameOver(GameOverState)
}

pub struct Game {
  mut model : Model
}

pub struct Pipe {
  x : Int
  gapStart : Int
}

pub struct Player {
  y : Float
  yVel : Float
}

pub fn Player::default() -> Player {
  Player::{ y: 0, yVel: 0 }
}

pub struct GameInState {
  frameCount : UInt
  score : UInt
  player : Player
  lastFlap : Bool
  birdAnim : Animation
  pipes : Array[Pipe]
  lastPipeGenerated : UInt
  plants : Array[Plant]
  lastPlantGenerated : UInt
  groundX : Int
}

pub fn Game::new() -> Game {
  { model: Model::GameStart(GameStartState::default()) }
}

pub fn Game::init(self : Game) -> Unit {
  init_palette()
  let plants = starting_plants()
  self.init_game_start(0, plants)
  @lib.save_score_data(0U)
}

pub fn Game::update(self : Game) -> Unit {
  match self.model {
    Model::GameStart(prev_state) =>
      self.run_game_start(
        { ..prev_state, frameCount: prev_state.frameCount + 1 },
      )
    Model::GameIn(prev_state) =>
      self.run_game({ ..prev_state, frameCount: prev_state.frameCount + 1 })
    Model::GameOver(prev_state) =>
      self.run_game_over(
        { ..prev_state, frameCount: prev_state.frameCount + 1 },
      )
  }
}

pub fn Game::run_game_start(self : Game, prev_state : GameStartState) -> Unit {
  let state = {
    ..prev_state,
    birdIdleAnim: update_animation(
      prev_state.birdIdleAnim,
      prev_state.frameCount,
    ),
  }
  set_text_colors()
  @lib.text("Flappy Bird!!!", pos=@lib.Pos::{ x: 31, y: 12 })
  @lib.text("Click to start!", pos=@lib.Pos::{ x: 24, y: 72 })
  draw_ground(groundSprite, 0)
  draw_plants(plantSpriteSheet, state.plants)
  let shift = idle_shift(state.frameCount, state.birdIdleAnim)
  draw_animation(
    state.birdIdleAnim,
    pos={ x: player_x, y: player_start_y + shift },
  )
  let gamepad = @wasm4.get_gamepad()
  let mouse = @wasm4.get_mouse()
  let start = gamepad.button_1 || gamepad.button_up || mouse.left
  if start {
    self.model = self.init_game(state)
  } else {
    self.model = GameStart(state)
  }
}

pub fn Game::init_game_start(
  self : Game,
  frameCount : UInt,
  plants : Array[Plant]
) -> Unit {
  self.model = Model::GameStart(
    { frameCount, plants, birdIdleAnim: create_bird_idle_anim(frameCount) },
  )
}

pub fn Game::init_game(_self : Game, state : GameStartState) -> Model {
  Model::GameIn(
    {
      frameCount: state.frameCount,
      score: 0,
      player: { y: player_start_y.to_float(), yVel: jump_speed },
      lastPipeGenerated: state.frameCount,
      pipes: [],
      plants: state.plants,
      lastPlantGenerated: 4,
      lastFlap: false,
      birdAnim: create_bird_flap_anim(state.frameCount),
      groundX: 0,
    },
  )
}

pub fn Game::run_game(self : Game, pre_state : GameInState) -> Unit {
  let gamepad = @wasm4.get_gamepad()
  let mouse = @wasm4.get_mouse()
  let flap = gamepad.button_1 || gamepad.button_up || mouse.left
  let (yVel, nextAnim) = if pre_state.lastFlap.not() &&
    flap &&
    flap_allowed(pre_state.frameCount, pre_state.birdAnim) {
    let anim = pre_state.birdAnim
    flap_tone()
    (jump_speed, { ..anim, index: 0, state: RunOnce })
  } else {
    (
      pre_state.player.yVel + gravity,
      pre_state.birdAnim.update_animation(pre_state.frameCount),
    )
  }
  let pipe = generate_pipe(pre_state.frameCount, pre_state.lastPipeGenerated)
  let lastPipeGenerated = match pipe {
    Some(_) => pre_state.frameCount
    None => pre_state.lastPipeGenerated
  }
  let pipes = pre_state.pipes |> update_pipes
  match pipe {
    Some(v) => pipes.push(v)
    None => ()
  }
  let plant = generate_plant(pre_state.frameCount, pre_state.lastPlantGenerated)
  let lastPlantGenerated = match plant {
    Some(_) => pre_state.frameCount
    None => pre_state.lastPlantGenerated
  }
  let plants = pre_state.plants |> update_plants
  match plant {
    Some(v) => plants.push(v)
    None => ()
  }
  let gainPoint = pre_state.pipes.filter(fn(p) { p.x == player_x - 2 }).length()
  let y = pre_state.player.y + yVel
  let score = pre_state.score + gainPoint.reinterpret_as_uint()
  let state = {
    ..pre_state,
    birdAnim: nextAnim,
    player: { y, yVel },
    score,
    lastFlap: flap,
    lastPipeGenerated,
    pipes,
    lastPlantGenerated,
    plants,
    groundX: (pre_state.groundX - 1) % @lib.screen_width,
  }
  if gainPoint > 0 {
    point_tone()
  }
  draw_pipes(pipeSprite, state.pipes)
  draw_ground(groundSprite, state.groundX)
  draw_plants(plantSpriteSheet, state.plants)
  let yPixel = floor(state.player.y) |> min(134)
  let collided = player_collided(
    yPixel |> to_int(),
    state.birdAnim.index.reinterpret_as_int(),
  )
  state.birdAnim.draw_animation(pos={ x: player_x, y: yPixel |> to_int })
  draw_score(state.score, pos={ x: 68, y: 4 })
  if collided.not() && y < 134 {
    self.model = GameIn(state)
  } else {
    gameover_tone()
    self.model = self.init_game_over(state)
  }
}

pub fn Game::init_game_over(_self : Game, state : GameInState) -> Model {
  let { frameCount, score, player, pipes, plants, groundX, .. } = state
  Model::GameOver(
    {
      frameCount,
      score,
      player,
      pipes,
      plants,
      birdFallAnim: create_bird_fall_anim(frameCount),
      groundX,
    },
  )
}

pub fn Game::run_game_over(self : Game, pre_state : GameOverState) -> Unit {
  let yVel = pre_state.player.yVel + gravity
  let birdFallAnim = pre_state.birdFallAnim.update_animation(
    pre_state.frameCount,
  )
  let y : Float = {
    let next = pre_state.player.y + yVel
    if next > 134 {
      134
    } else {
      next
    }
  }
  let state = { ..pre_state, birdFallAnim, player: { y, yVel } }
  draw_pipes(pipeSprite, state.pipes)
  draw_ground(groundSprite, state.groundX)
  draw_plants(plantSpriteSheet, state.plants)
  let yPixel = state.player.y
  state.birdFallAnim.draw_animation(pos={ x: player_x, y: yPixel |> to_int })
  set_shape_colors(fill=color1, border=color4)
  @lib.rect(pos=@lib.Pos::{ x: 16, y: 52 }, size={ w: 136, h: 32 })
  set_text_colors()
  @lib.text("Game Over!", pos=@lib.Pos::{ x: 44, y: 56 })
  @lib.text("Right to restart", pos=@lib.Pos::{ x: 20, y: 72 })
  set_shape_colors(fill=color1, border=color4)
  @lib.rect(pos=@lib.Pos::{ x: 66, y: 2 }, size={ w: 28, h: 12 })
  draw_score(state.score, pos={ x: 68, y: 4 })
  let gamepad = @wasm4.get_gamepad()
  let mouse = @wasm4.get_mouse()
  let start_new_game = mouse.right || gamepad.button_2 || gamepad.button_right
  if start_new_game {
    let plants = starting_plants()
    self.init_game_start(state.frameCount, plants)
  } else {
    self.model = Model::GameOver(state)
  }
}

pub fn draw_ground(sprite : Sprite, x : Int) -> Unit {
  set_ground_colors()
  sprite.blit(pos={ x, y: @lib.screen_height - 13 })
  sprite.blit(pos={ x: x + @lib.screen_width, y: @lib.screen_height - 13 })
}

pub fn draw_plants(sprite : Sprite, plants : Array[Plant]) -> Unit {
  for plant in plants {
    draw_plant(sprite, plant)
  }
}

pub fn player_collided(playerY : Int, animIndex : Int) -> Bool {
  if playerY >= 1 {
    on_screen_collided(playerY, animIndex)
  } else {
    off_screen_collided()
  }
}

pub fn on_screen_collided(playerY : Int, animIndex : Int) -> Bool {
  let basePoints : Array[@lib.Pos] = [
    { x: 11, y: 2 },
    { x: 13, y: 3 },
    { x: 3, y: 5 },
    { x: 11, y: 6 },
    { x: 9, y: 8 },
    { x: 5, y: 9 },
    { x: 7, y: 10 },
    { x: 5, y: 12 },
  ]
  let collisionPoints = if animIndex == 2 {
    basePoints..push({ x: 2, y: 1 })..push({ x: 7, y: 1 })
  } else if animIndex == 1 {
    basePoints..push({ x: 2, y: 2 })
  } else {
    basePoints
  }
  let r = collisionPoints.fold(
    init=Some(false),
    walk_collision_points(player_x, playerY),
  )
  r.unwrap()
}

pub fn walk_collision_points(
  pX : Int,
  pY : Int
) -> (Bool?, @lib.Pos) -> Bool? {
  fn walk(acc : Bool?, point : @lib.Pos) -> Bool? {
    let r = acc.unwrap()
    if r {
      Some(true)
    } else {
      let p = @lib.Pos::{ x: pX + point.x, y: pY + point.y }
      let color = @lib.get_pixel(p)
      Some(color != color1)
    }
  }

  walk
}

pub fn off_screen_collided() -> Bool {
  let point : @lib.Pos = { x: player_x + 13, y: 0 }
  let color = @lib.get_pixel(point)
  color != color1
  // false
}

pub fn draw_plant(spriteSheet : Sprite, plant : Plant) -> Unit {
  let sprite = spriteSheet.sub(
    pos={ x: plant.type_ * 12, y: 0 },
    size={ w: 12, h: 12 },
  )
  set_sprite_colors()
  sprite.blit(pos={ x: plant.x, y: plant_y })
}

pub fn idle_shift(frameCount : UInt, anim : Animation) -> Int {
  let { index, lastUpdated, .. } = anim
  if index == 2 {
    0
  } else if index == 1 && frameCount - lastUpdated > 3 {
    0
  } else {
    1
  }
}

pub fn draw_score(score : UInt, ~pos : @lib.Pos) -> Unit {
  set_text_colors()
  let x = if score < 10 {
    pos.x + 8
  } else if score < 100 {
    pos.x + 4
  } else {
    pos.x
  }
  @lib.text("\{score}", pos={ x, y: pos.y })
}

pub fn draw_pipes(sprite : Sprite, pipes : Array[Pipe]) -> Unit {
  for pipe in pipes {
    draw_pipe(sprite, pipe)
  }
}

let gap_height = 40

pub fn draw_pipe(sprite : Sprite, pipe : Pipe) -> Unit {
  let { x, gapStart } = pipe
  set_sprite_colors()
  sprite.blit(
    pos={ x, y: gapStart - @lib.screen_height },
    flags={
      one_bit_per_pixel: false,
      flip_x: false,
      flip_y: true,
      rotate: false,
    },
  )
  sprite.blit(pos={ x, y: gapStart + gap_height })
}

pub fn starting_plants() -> Array[Plant] {
  range(0, 14).fold(
    init=[],
    fn {
      acc, i => {
        let p = random_plant(i * 12)
        acc..push(p)
      }
    },
  )
}

pub fn update_pipes(pipes : Array[Pipe]) -> Array[Pipe] {
  pipes.map(fn(pipe) { { ..pipe, x: pipe.x - 1 } })
  |> drop_if(fn(pipe) { pipe.x < -20 })
}

pub fn generate_pipe(frameCount : UInt, lastPipeGenerated : UInt) -> Pipe? {
  if frameCount - lastPipeGenerated > 90 {
    let gapStart = random_int(16)
    { x: @lib.screen_width, gapStart: gapStart * 5 + 10 } |> Some
  } else {
    None
  }
}

pub fn generate_plant(frameCount : UInt, lastPlantGenerated : UInt) -> Plant? {
  if frameCount - lastPlantGenerated > 12 {
    random_plant(@lib.screen_width) |> Some
  } else {
    None
  }
}

pub fn update_plants(plants : Array[Plant]) -> Array[Plant] {
  plants.map(fn(plant) { { ..plant, x: plant.x - 1 } })
  |> drop_if(fn(plant) { plant.x < -12 })
}

pub fn random_plant(i : Int) -> Plant {
  let t = random_int(1000) % plant_types
  { x: i, type_: t }
}

pub fn flap_allowed(frameCount : UInt, anim : Animation) -> Bool {
  let { index, lastUpdated, .. } = anim
  if index == 2 {
    true
  } else if index == 1 && frameCount - lastUpdated > 3 {
    true
  } else {
    false
  }
}
