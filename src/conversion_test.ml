open Messages_pb 

let make_celcius v = {u = C; v} 

let make_fahrenheit v = { u = F; v }

let log {v; _} = Js.log v

let () = 
  Conversion.convert C (make_celcius 100.) |> log; 
  Conversion.convert C (make_celcius 0.) |> log; 
  Conversion.convert F (make_celcius 0.) |> log

let () = 
  Js.log @@ Conversion.convert_json {|{
    "desired": "F", 
    "temperature": { "u" : "C", "v": 0 }
  }|}
