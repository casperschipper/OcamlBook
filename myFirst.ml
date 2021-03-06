let rec length l =
  match l with
    [] -> 0
  | _::t -> 1 + length t

let rec take x xs =
  if x = 0 then [] else
  match xs with
    [] -> []
  | h::ts -> h :: take (x-1) ts

let rec drop x xs =
  if x = 0 then
    xs
  else
    match xs with
      [] -> []
    | h::ts -> drop (x-1) ts

let rec append a b =
  match a with
    [] -> b
  | h::t -> h :: append t b

let flip f x y = f y x

let rec map f xs =
  match xs with
    [] -> []
  | h::t -> f h :: map f t

let rec foldr f z xs =
  match xs with
    [] -> z
  | h::ts -> f h (foldr f z ts)

let compose f g =
  (fun x -> f ( g x ))

let myTest =
  let halve x = x / 2
  in map halve [10;20;30;40]

let evens l =
  map (fun x -> x mod 2 = 0) l

let isEven x =
  x mod 2 = 0

let rec range a b =
  match a = b with
    true -> [b]
  | false -> a :: range (a+1) b 

       
let rec filter f xs =
  match xs with
          [] -> []
        | h::ts -> if f h then h::filter f ts else filter f ts

let rec mergeWith f xs ys =
  match xs, ys with
    [], l -> l
  | l, [] -> l
  | hx::tx , hy::ty -> if f hx hy then
                         hx :: mergeWith f tx (hy::ty)
                       else
                         hy :: mergeWith f (hx::tx) ty

let rec msortWith f ls =
  match ls with
    [] -> []
  | [x] -> [x]
  | _ -> let
     pivot = (length ls) / 2
    in
    let
      left = take pivot ls
      and
        right = drop pivot ls
    in
    mergeWith f (msortWith f left) (msortWith f right)

let calm chars =
  map (fun char -> match char with '!' -> '.' | _ -> char) chars
    
let rec apply f n x =
  match n with
    1 -> f x
  | n -> f (apply f (n-1) x)

let clip low high x =
  match x with
    x when x < low -> low
  | x when x > high -> high
  | _ -> x
      

let clips xs =
  map clip xs

let rec lookup x dict =
  match dict with
    [] -> raise Not_found
  | (k, v)::t -> if k = x then v else lookup x t

let census =
  [(1,4);(2,3);(42,7);(33,4);(7,2)]

let rec add k v dict =
  match dict with
    [] -> [(k,v)]
  | (k',v')::ts -> if k = k' then (k,v)::ts else (k', v') :: add k v ts

let rec remove k dict =
  match dict with
    [] -> []
  | (k',v) :: ts -> if k = k' then ts else (k',v) :: remove k ts

let (<<) f g x = f(g(x))

let mapl f ls =
  ((map << map) f) ls

type rect =
  Rect of int * int
| Square of int

let area rectangle =
  match rectangle with
    Rect (w, h) -> w * h
  | Square s -> s * s

let makeTall rectangle =
  match rectangle with
    Rect (w, h) when w >= h -> Rect (h, w)
  | _ -> rectangle

let getWidth r =
  match r with
    Rect (w, _) -> w
  | Square s -> s
  

let bookshelf rects =
  let turned =
    map makeTall rects

  in
  msortWith (fun a b -> getWidth a < getWidth b) turned

let totalWidth rects =
  foldr (fun r acc -> (getWidth r) + acc) 0 rects
     
let dummies =
  [Rect (1,10);Rect (2,3);Rect (5,2);Rect (3,10);Rect(9,9) ;Square 2]

type 'a tree =
  Br of 'a * 'a tree * 'a tree
| Lf

let rec size tr =
  match tr with
    Br (_, l, r) -> 1 + size l + size r
  | Lf -> 0

let rec total tr =
  match tr with
   Lf -> 0
  | Br (v, l, r) -> v + total l + total r

let rec lookup tr k =
  match tr with
    Lf -> None
  | Br ((k',v),l, r) ->
     if k == k' then
       Some v else if
       k < k' then lookup l k else lookup r k
    
let rec insert tr (k,v) =
  match tr with
    Lf -> Br ((k, v) , Lf, Lf)
  | Br ((k',v'), l, r) -> if k = k' then
                           Br ((k, v), l, r)
                         else if k < k' then
                           Br ((k',v'), insert l (k,v), r)
                         else
                           Br ((k',v'), l, insert r (k,v))

let testList = [(1,"casper");(10,"fish");(3,"laura");(22,"dirk");(31,"hans");(4,"kees")]
                             

let rec listFromTree tr =
  match tr with
    Lf -> []
  |  Br ( (k,v), l, r ) -> (k,v) :: ( listFromTree l @ listFromTree r )
   
             
let rec memberOfTree tr k =
  match tr with
    Lf -> false
  | Br ((k',_), l, r) -> if k = k' then true else
                           memberOfTree l k || memberOfTree r k

let rec treeFromList lst =
  foldr (flip insert) Lf lst
     
           
    

let print_dict_entry (k, v) =
  print_int k ; print_newline () ; print_string v ; print_newline ()

let rec iter f l =
  match l with
    [] -> ()
  | h::ts -> f h ; iter f ts
                                                      
let rec read_dict () =
  try
    let i = read_int () in
    if i =  0 then [] else
      let name = read_line () in
      (i, name) :: read_dict ()
  with
    Failure _ ->
    print_string "It ain't no int!" ;
    print_newline ();
    read_dict()
    
let entry_to_channel ch (k,v) =
  output_string ch (string_of_int k);
  output_char ch '\n';
  output_string ch v;
  output_char ch '\n'

let dictionary_to_channel ch d =
  iter (entry_to_channel ch) d

let dictionary_to_file filename dict =
  let ch = open_out filename in
  dictionary_to_channel ch dict;
  close_out ch

let entry_of_channel ch =
  let number = input_line ch in
  let name = input_line ch in
  (int_of_string number, name)

let rec dictionary_of_channel ch =
  try let e = entry_of_channel ch in
      e :: dictionary_of_channel ch
  with
    End_of_file -> []

let explode s =
  let rec exp i l =
    if i < 0 then l else exp (i - 1) (s.[i] :: l) in
  exp (String.length s - 1) []

  
let mapStr f str =
  let chars =
    explode str
  in
  Batteries.String.implode (map f chars)

let filterStr f str =
  let chars =
    explode str
  in
  Batteries.String.implode (filter f chars)

let hyphenize =
  mapStr (fun c -> match c with ' ' -> '-' | s -> s)

let removeHeader =
  filterStr (fun c -> c != '#')

let (|>) x f = f x

let is_digit = function '0' .. '9' -> true | _ -> false
             
let dropWhiteSpace str = 
  let chars = explode str in
  let rec filterWhites cs =
    match cs with
      [] -> []
    | c :: '.' :: ts when is_digit c -> filterWhites ts
    | ' '::ts -> filterWhites ts
    | rest -> rest
  in
  filterWhites chars |> Batteries.String.implode
  
let anchor headerTxt =
  let anchorId str =
     str |> removeHeader |>  dropWhiteSpace |> lowercase |> hyphenize
  in
  String.concat "" ["<a id=\"";anchorId headerTxt;"\">\n"]      

  
let process str =
  let isHeader s =
    try
      s.[0] = '#' || s.[1] = '#'
    with Invalid_argument _ -> false
  in
  if isHeader str then
    String.concat "\n" [anchor str;str]
  else str

         
let rec read_lines_of_channel ch =
  try let e = input_line ch in
      e :: read_lines_of_channel ch
  with
    End_of_file -> []

let lines_of_file filename =
  let ch = open_in filename in
    let lines = read_lines_of_channel ch in
    close_in ch;
    lines


let lines_to_channel ch lines =
  iter (fun str ->
      output_string ch str;
      output_char ch '\n';
      flush ch) lines
  
let lines_to_file filename lines =
  let ch = open_out filename in
  lines_to_channel ch lines
  
let dictionary_of_file filename =
  let ch = open_in filename in
  let dict = dictionary_of_channel ch in
    close_in ch;
    dict


let process_markdown_file filename =
  let lines = lines_of_file filename in
  let output = map process lines in
    lines_to_file "out.txt" output



    

  
  
            

    
    
