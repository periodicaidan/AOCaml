open Core
open AOCaml

let get_text_for_day n = 
  In_channel.read_all @@ String.concat ["input/day"; Int.to_string n; ".txt"]
  |> String.strip

(* TODO: Write an actual runner *)
let () = 
  let text = get_text_for_day 3 in 
  Day3.Part2.run text
  |> Int.to_string
  |> print_endline
