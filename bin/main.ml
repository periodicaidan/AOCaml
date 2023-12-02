open Core

let get_text_for_day n = 
  In_channel.read_all @@ String.concat ["input/day"; Int.to_string n; ".txt"]
  |> String.strip

let _day_1_part_1 input = 
  let lines = String.split_lines input in 
  let process_next_char acc next = 
    if not @@ Char.is_digit next then 
      acc 
    else 
      match acc with 
      | (None, _) -> (Some next, None)
      | (Some _ as hi, _) -> (hi, Some next)
  in
  let process_line line = 
    String.fold line ~init:(None, None) ~f:process_next_char 
  in 
  let join_digits digits = 
    String.of_char_list (
      match digits with 
      | (Some hi, None) -> [hi; hi]
      | (Some hi, Some lo) -> [hi; lo]
      | (None, _) -> ['0'; '0'] (* Shouldn't happen... *)
    )
  in 
  List.map lines ~f:process_line 
  |> List.map ~f:join_digits
  |> List.map ~f:Int.of_string
  |> List.fold ~init:0 ~f:(+)

let explode_string s = List.init (String.length s) ~f:(String.get s)

module Day1 = struct    
  let tokens = ["1"; "2"; "3"; "4"; "5"; "6"; "7"; "8"; "9"; "0"; "one"; "two"; "three"; "four"; "five"; "six"; "seven"; "eight"; "nine"]

  let token_chars = List.(tokens >>| explode_string)

  let token_chars_reversed = List.(token_chars >>| rev) 

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
    | _ -> raise Exit 

  type parse_result = {
    input: char list;
    output: int option;
  }

  let init_parser input = { input = explode_string input; output = None }

  type parse_direction = 
  | Forward
  | Backward 

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
      | Forward -> { input = rest; output = Some(int_of_token tkn)}
      | Backward -> { input = rest; output = Some(int_of_token @@ String.rev tkn)}
  
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
    
  let part2 text =
    let lines = String.split_lines text in 
    let calibration_values = List.(lines >>| parse_line_both_ways >>| Option.value ~default:0) in
    List.fold calibration_values ~init:0 ~f:(+)
end

let () = 
  let text = get_text_for_day 1 in 
  Day1.part2 text
  |> Int.to_string
  |> print_endline
