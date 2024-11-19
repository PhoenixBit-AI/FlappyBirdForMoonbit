pub fn range(start : Int, end : Int, ~step : Int = 1) -> Iter[Int] {
  Iter::new(
    fn(yield) {
      for i = start; i < end; i = i + step {
        if yield(i) == IterEnd {
          break IterEnd
        }
      } else {
        IterContinue
      }
    },
  )
}

let random : @random.Rand = @random.new()

pub fn random_bool() -> Bool {
  random.int(limit=2) == 0
}

pub fn random_int(max_val : Int, ~start : Int = 0) -> Int {
  start + random.int(limit=max_val)
}

pub fn log(s : String) -> Unit {
  @wasm4.trace(s)
}

pub fn max[T: Compare](a : T, b : T) -> T {
  if a > b {
    a
  } else {
    b
  }
}

pub fn min[T: Compare](a : T, b : T) -> T {
  if a < b {
    a
  } else {
    b
  }
}


extern "wasm" fn to_int(f : Float) -> Int =
  #|(func (param f32) (result i32) local.get 0 i32.trunc_f32_s)

extern "wasm" fn floor(f : Float) -> Float =
  #|(func (param f32) (result f32) local.get 0 f32.floor)

extern "wasm" fn ceil(f : Float) -> Float =
  #|(func (param f32) (result f32) local.get 0 f32.ceil)


pub fn drop_if[T](arr : Array[T], f : (T) -> Bool) -> Array[T] {
  let r = []
  for v in arr {
    if f(v).not() {
      r.push(v)
    }
  }
  r
}

pub fn keep_if[T](arr : Array[T], f : (T) -> Bool) -> Array[T] {
  let r = []
  for v in arr {
    if f(v) {
      r.push(v)
    }
  }
  r
}

pub fn count_if[T](arr : Array[T], f : (T) -> Bool) -> UInt {
  let mut r = 0U
  for v in arr {
    if f(v) {
      r = r + 1U
    }
  }
  r
}


pub fn append_if_ok[T](arr : Array[T], v : T?) -> Array[T] {
  match v {
    Some(v) => arr..push(v)
    None => arr
  }
}

pub fn prepend_if_ok[T](arr : Array[T], v: T?) -> Array[T] {
  insert_if_ok(arr, 0, v)
}

pub fn insert_if_ok[T](arr : Array[T], i : Int, v : T?) -> Array[T] {
  match v {
    Some(v) => arr..insert(i, v)
    None => arr
  }
}