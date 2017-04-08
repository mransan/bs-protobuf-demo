open Messages_types

let log {v; _} = Js.log v

let () = 
  Conversion.convert C (default_temperature ~v:100. ()) |> log; 
  Conversion.convert C (default_temperature ()) |> log; 
  Conversion.convert F (default_temperature ()) |> log;
  Conversion.convert C (default_temperature ~u:F ~v:32.0 ()) |> log

let () = 
  Js.log @@ Conversion.convert_json {|{
    "desired": "F", 
    "temperature": { "u" : "C", "v": 0 }
  }|}
