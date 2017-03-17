(** This module implement the temperature conversion API *)

open Messages_pb 

(* Actual conversion logic *)
let convert desired ({u; v}  as t)  = 
  if desired = u
  then t 
  else 
   let v =  
     match desired with
     | C -> (v -. 32.) *. 5. /. 9.  
     | F -> (v *. 9. /. 5.) -. 32.
   in 
   {v; u = desired}

module MessageEncoder = Messages_pb.Make_encoder(Pbrt_bsjson.Encoder)
module MessageDecoder = Messages_pb.Make_decoder(Pbrt_bsjson.Decoder) 

(* Decoding request *)
let request_of_json_string json_str = 
  match Pbrt_bsjson.Decoder.of_string json_str with
  | None -> None 
  | Some decoder -> 
    try Some (MessageDecoder.decode_request decoder)
    with _ -> None 

(* Encoding response *)
let json_str_of_response response = 
  let encoder = Pbrt_bsjson.Encoder.empty () in 
  MessageEncoder.encode_response response encoder; 
  Pbrt_bsjson.Encoder.to_string encoder 

(* JSON entry point *)
let convert_json request_str = 
  match request_of_json_string request_str with
  | Some {desired; temperature = Some t} -> 
    let response = Temperature (convert desired t) in 
    json_str_of_response response 
  | _ -> 
    json_str_of_response (Error "error decoding request")
