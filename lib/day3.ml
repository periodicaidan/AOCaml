open Base

module NumberToken = struct 
  type t = {
    value: int;
    x: int;
    y: int;
    span: int;
  }
  [@@deriving show, fields]

  let create value x y span = { value; x; y; span }
end

module SymbolToken = struct 
  type t = {
    value: char;
    x: int;
    y: int;
  }
  [@@deriving show]

  let create value x y = { value; x; y }
end

module Parser = struct 
  type t = {
    numbers: NumberToken.t list;
    symbols: SymbolToken.t list;
    input: char list;
    current_pos: int * int;  
  }
  [@@deriving show, fields]

  let init s = { numbers = []; symbols = []; input = Utils.explode_string s; current_pos = (0, 0) }

  let parse_symbol ({ symbols; input; current_pos = (x, y); _} as p) = 
    match input with
    | c :: rest -> 
      if not (Char.is_digit c || Char.equal c '.') then 
        Some { p with symbols = (SymbolToken.create c x y) :: symbols; input = rest; current_pos = (x + 1, y)}
      else 
        None
    | _ -> None

  let parse_number ({ numbers; input; current_pos = (x, y); _ } as p) = 
    let rec take_digits (digits, input) = 
      match input with 
      | c :: rest -> 
        if Char.is_digit c then 
          take_digits (c :: digits, rest)
        else 
          (digits, input)
      | _ -> (digits, input)
    in 
    let (digits, rest) = take_digits ([], input) in 
    let digits = List.rev digits in
    match digits with 
    | [] -> None 
    | digits -> 
      Some { p with 
        numbers = (NumberToken.create (digits |> String.of_char_list |> Int.of_string) x y (List.length digits)) :: numbers;
        input = rest; 
        current_pos = (x + List.length digits, y) }

  let parse_nl ({ input; current_pos = (_, y); _ } as p) = 
    match input with 
    | '\n' :: rest -> Some { p with input = rest; current_pos = (0, y + 1)}
    | _ -> None 

  let parse_dot ({ input; current_pos = (x, y); _ } as p) = 
    match input with 
    | '.' :: rest -> Some { p with input = rest; current_pos = (x + 1, y)} 
    | _ -> None

  let parse_fns = [parse_nl; parse_number; parse_dot; parse_symbol ]

  let rec parse parser = 
    let parse_result = List.fold parse_fns ~init:None ~f:(fun acc next_fn -> Option.first_some acc (next_fn parser)) in
    match parse_result with 
    | None -> parser 
    | Some parser' -> parse parser'
end

module Part1 = struct 
  let number_near_symbol number symbol = 
    let { NumberToken.x = nx; y = ny; span; _ } = number in 
    let { SymbolToken.x = sx; y = sy; _ } = symbol in 
    sy <= ny + 1 && sy >= ny - 1 && sx >= nx - 1 && sx <= nx + span

  let number_near_any_symbol symbols number = 
    List.exists symbols ~f:(number_near_symbol number)
  
  let run text = 
    let parser = Parser.init text |> Parser.parse in  
    let { Parser.numbers; symbols; _ } = parser in 
    List.filter numbers ~f:(number_near_any_symbol symbols) 
    |> List.map ~f:NumberToken.value 
    |> List.fold ~init:0 ~f:(+)
end

module Part2 = struct 
  let symbol_near_number = Fn.flip Part1.number_near_symbol

  let get_gear_ratio numbers symbol = 
    let adjacent_numbers = List.filter numbers ~f:(symbol_near_number symbol) in 
    let adjacent_numbers = List.map adjacent_numbers ~f:NumberToken.value in
    if (Char.equal symbol.value '*') && (List.length adjacent_numbers = 2) then 
      Some (List.fold adjacent_numbers ~init:1 ~f:( * ))
    else 
      None

  let run text = 
    let parser = Parser.init text |> Parser.parse in  
    let { Parser.numbers; symbols; _ } = parser in 
    List.filter_map symbols ~f:(get_gear_ratio numbers)
    |> List.fold ~init:0 ~f:(+)

end
