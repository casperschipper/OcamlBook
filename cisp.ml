

(*

a stream has a state,
it should know its previous 2 values (or maybe more??)
Should this be customizable?

Each stream needs a function that will return a float and the new state.

The program is a stream.
it can be asked for it's next value.
It will return a value and update the stream.
Thus, running the program means itterating the state getting values along the way.

There may be streams in the stream
These will follow the same process.

The stream will have a state. And it should store some of its history.


https://ocaml.org/learn/tutorials/comparison_of_standard_containers.html



 *)

type countable = {
    count : int ;
    name : string ;
    hairs : int ;
  }

type bar = {
    count : int ;
  }

type stream =
  Seq of stream list * stream list (* left holds upcoming streams, right side holds values that have already been used up, so they can be reused  *)
| V of float (* static value *)
| Rv of stream * stream (* random value defined by lower and higher boundaries, also streams *)
| Count of stream * int * bool (* control stream, current state, holdmode *)

let updateCount { count } =
  { count = count + 1 }

  
let rv a b =
  let range =
      abs_float a -. b
  and offset = min a b
  in
  (Random.float range) +. offset


let cartesian f a b =
  List.concat (List.map (fun x -> List.map (fun y -> f x y) a) b)

let rec range a b =
  if (a < b) then
    a :: range (a+1) b
  else if (a > b)
  then range b a else
    [a]
    
 
  
let rec next st =
  match st with
    Seq (h::ts,consumed) -> let (value,state) = next h in
                            (match value with
                              [] -> ( [], Seq ( ts, state::consumed ))
                              | value -> ( value, Seq ( ts, state::consumed )))                         
  | Seq ([], h::ts ) -> ([], Seq (ts @ [h],[]))
  | Seq ([], [] ) -> ([], Seq([], [])) (* meaningless *)
  | V v -> ([v], V v)
  | Rv (a, b) -> let (va, statea) = next a
                   and
                     (vb, stateb) = next b
                 in
                 (cartesian rv va vb, Rv(statea,stateb))
  | Count (max, curr, holdmode) -> if holdmode then
                                     let (value,maxState) = next max in
                                     (range 0 (floor value), Count maxState 0 holdmode)
                                   else
                                     if curr != max then
                                       ([curr], Count maxState (curr + 1) holdMode)
                                   
                                   

let mkSeq lst =
  Seq (lst, [])
          
                 
let test1 = mkSeq [V 0.99;Rv (V 0.1,V 0.2);mkSeq [V 33.0;V 34.0;V 35.0]]

let rec collect str n =
  if n = 0 then [] else 
    let (value, state) = next str in
    value :: collect state (n - 1)

let flat xs =
  List.concat xs
