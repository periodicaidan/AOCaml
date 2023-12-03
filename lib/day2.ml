(** Advent of Code Day 2: https://adventofcode.com/2023/day/2 *)

open Base

module Cubes = struct 
  type t = [
  | `Red
  | `Green
  | `Blue
  ]
  [@@deriving show]

  let of_string s = 
    match s with 
    | "red" -> Some `Red 
    | "green" -> Some `Green
    | "blue" -> Some `Blue 
    | _ -> None 

  let parse_count s = 
    match String.lsplit2 s ~on:' ' with 
    | Some (count, color) -> (
      of_string color |> Option.value_exn ~message:"Invalid cube color",
      Int.of_string count
      )
    | None -> failwith "Invalid cube count"
end

module Game = struct 
  type t = {
    id: int;
    draws: (Cubes.t * int) list list 
  }
  [@@deriving show, fields]

  let parse_game_id game_id_string = 
    match String.lsplit2 game_id_string ~on:' ' with 
    | Some ("Game", n) -> Int.of_string n 
    | Some _ | None -> failwith "Invalid game ID string"

  let parse_draw draw_string = 
    String.split draw_string ~on:',' 
    |> List.map ~f:String.strip
    |> List.map ~f:Cubes.parse_count 
    
  let parse_game draws = 
    String.split draws ~on:';'
    |> List.map ~f:String.strip 
    |> List.map ~f:parse_draw 
    
  let parse game_string = 
    match String.lsplit2 game_string ~on:':' with 
    | Some (game_id, draws) -> { id = parse_game_id game_id; draws = parse_game @@ String.strip draws }
    | None -> failwith "Invalid game string"

  let valid_draw bag drawn = 
    let valid_count (cube_color, num_drawn) = 
      match List.Assoc.find bag cube_color ~equal:Poly.(=) with 
      | Some num_in_bag -> num_in_bag >= num_drawn 
      | None -> num_drawn = 0
    in
    List.for_all drawn ~f:valid_count   

  let valid_game bag { draws; _ } =
    List.for_all draws ~f:(valid_draw bag)

  let fewest_cubes { draws; _ } = 
    let merge_bags a b = 
      List.map a ~f:(fun (color, count) -> 
        match List.Assoc.find b color ~equal:Poly.(=) with 
        | Some other_count -> (color, Int.max count other_count) 
        | None -> (color, count))
    in
    List.fold 
      draws
      ~init:[(`Red, 0); (`Green, 0); (`Blue, 0)]
      ~f:merge_bags
end

module Part1 = struct 
  let cubes_in_bag = [(`Red, 12); (`Green, 13); (`Blue, 14)]
  
  let run text =
    let lines = String.split_lines text in 
    List.map lines ~f:Game.parse
    |> List.filter ~f:(Game.valid_game cubes_in_bag)
    |> List.map ~f:Game.id 
    |> List.fold ~init:0 ~f:(+) 
end

module Part2 = struct 
  let cube_power cubes = 
    List.fold cubes ~init:1 ~f:(fun acc (_, count) -> acc * count)
  
  let run text = 
    let lines = String.split_lines text in 
    List.map lines ~f:Game.parse 
    |> List.map ~f:Game.fewest_cubes   
    |> List.map ~f:cube_power
    |> List.fold ~init:0 ~f:(+)
end
