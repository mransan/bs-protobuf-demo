(** This module implement the temperature conversion API *)

open Messages_types

(* Actual conversion logic *)
let convert desired ({u; v}  as t)  = 
  if desired = u
  then t 
  else 
   let v =  
     match desired with
     | C -> (v -. 32.) *. 5. /. 9.  
     | F -> (v *. 9. /. 5.) +. 32.
   in 
   {v; u = desired}

(* Decoding request *)
let request_of_json_string json_str = 
  match Js_json.decodeObject @@ Js_json.parse json_str with
  | None -> None 
  | Some o -> Some (Messages_bs.decode_request o)

(* Encoding response *)
let json_str_of_response response = 
  Messages_bs.encode_response response
  |> Js_json.object_ |> Js_json.stringify

(* JSON entry point *)
let convert_json request_str = 
  match request_of_json_string request_str with
  | Some {desired; temperature = Some t} -> 
    let response = Temperature (convert desired t) in 
    json_str_of_response response 
  | _ -> 
    json_str_of_response (Error "error decoding request")
