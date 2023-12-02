open Base

let explode_string s = List.init (String.length s) ~f:(String.get s)
