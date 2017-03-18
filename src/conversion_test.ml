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


(** This is an example how to create a Tree in OCaml 
    and serialize it in JSON *)

let make_node ?(left = Empty) ?(right = Empty) value= Node {
  value; 
  left = Some left; 
  right = Some right;
}

let () = 
  let tree = 
    make_node 
      ~left:(make_node 
        ~left:(make_node "2") 
        ~right:(make_node "3") 
        "4"
      )
      ~right:(make_node 
        ~left:(make_node "5")
        ~right:(make_node "6") 
        "7"
      )
      "8"
  in 
  let encoder = Pbrt_bsjson.Encoder.empty() in
  Conversion.MessageEncoder.encode_binary_tree tree encoder;
  Pbrt_bsjson.Encoder.to_string encoder |> print_endline 

let make_node_compact ?left  ?right value = ({
  value; 
  left;
  right;
}:binary_tree_compact)

let () = 
  let tree = 
    make_node_compact 
      ~left:(make_node_compact 
        ~left:(make_node_compact "2") 
        ~right:(make_node_compact "3") 
        "4"
      )
      ~right:(make_node_compact 
        ~left:(make_node_compact "5")
        ~right:(make_node_compact "6") 
        "7"
      )
      "8"
  in 
  let encoder = Pbrt_bsjson.Encoder.empty() in
  Conversion.MessageEncoder.encode_binary_tree_compact tree encoder;
  Pbrt_bsjson.Encoder.to_string encoder |> print_endline 
