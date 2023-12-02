open Base

module type Trebuchet_calibration = sig 
  val tokens: string list
  val int_of_token: string -> int
end 

module Calibration_parser (M: Trebuchet_calibration) = struct 
  let token_chars = List.(M.tokens >>| Utils.explode_string)

  let token_chars_reversed = List.(token_chars >>| rev) 

  type parse_result = {
    input: char list;
    output: int option;
  }

  type parse_direction = 
  | Forward
  | Backward 

  let init_parser input = { input = Utils.explode_string input; output = None }
  
  let try_input_with input test =
    let (maybe_token, rest) = List.split_n input (List.length test) in 
    match List.for_all2 maybe_token ~f:Char.equal test with 
    | Unequal_lengths | Ok false -> None 
    | Ok true -> Some(rest, String.of_char_list maybe_token)

  let parse_next { input; output } direction = 
    let directional_tokens = 
      match direction with 
      | Forward -> token_chars 
      | Backward -> token_chars_reversed
    in
    let parse_attempts = List.map directional_tokens ~f:(try_input_with input) in
    match List.fold parse_attempts ~init:None ~f:Option.first_some with 
    | None -> { input = List.tl input |> Option.value ~default:[]; output }
    | Some (rest, tkn) -> 
      match direction with 
      | Forward -> { input = rest; output = Some(M.int_of_token tkn)}
      | Backward -> { input = rest; output = Some(M.int_of_token @@ String.rev tkn)}
  
  let parse_line line direction = 
    let line = 
      match direction with 
      | Forward -> line 
      | Backward -> String.rev line 
    in 
    let parse_result = init_parser line in 
    let rec parse res =
      match res with 
      | { input = _; output = (Some _) as output } -> output
      | { input = []; output = _ } -> None 
      | { input = _; output = None } -> parse @@ parse_next res direction  
    in 
    parse parse_result

  let parse_line_both_ways line = 
    let forward_digit = parse_line line Forward in
    let backward_digit = parse_line line Backward in
    Option.map2 forward_digit backward_digit ~f:(fun f b -> f * 10 + b)

  let run text =
    let lines = String.split_lines text in 
    let calibration_values = List.(lines >>| parse_line_both_ways >>| Option.value ~default:0) in
    List.fold calibration_values ~init:0 ~f:(+)
 end

module Part1 = Calibration_parser(struct 
  let tokens = ["1"; "2"; "3"; "4"; "5"; "6"; "7"; "8"; "9"; "0"]

  let int_of_token = Int.of_string
end)

module Part2 = Calibration_parser(struct 
  let tokens = ["1"; "2"; "3"; "4"; "5"; "6"; "7"; "8"; "9"; "0"; "one"; "two"; "three"; "four"; "five"; "six"; "seven"; "eight"; "nine"]
  
  let int_of_token tkn = 
    match tkn with 
    | "1" | "one" -> 1
    | "2" | "two" -> 2
    | "3" | "three" -> 3
    | "4" | "four" -> 4
    | "5" | "five" -> 5
    | "6" | "six" -> 6
    | "7" | "seven" -> 7
    | "8" | "eight" -> 8
    | "9" | "nine" -> 9
    | _ -> failwith "Unreachable"
end)
