[@@@ocaml.warning "-27-30-39"]

type temperature_unit =
  | C 
  | F 

type temperature = {
  u : temperature_unit;
  v : float;
}

and temperature_mutable = {
  mutable u : temperature_unit;
  mutable v : float;
}

type request = {
  desired : temperature_unit;
  temperature : temperature option;
}

and request_mutable = {
  mutable desired : temperature_unit;
  mutable temperature : temperature option;
}

type response =
  | Error of string
  | Temperature of temperature

let rec default_temperature_unit () = (C:temperature_unit)

let rec default_temperature 
  ?u:((u:temperature_unit) = default_temperature_unit ())
  ?v:((v:float) = 0.)
  () : temperature  = {
  u;
  v;
}

and default_temperature_mutable () : temperature_mutable = {
  u = default_temperature_unit ();
  v = 0.;
}

let rec default_request 
  ?desired:((desired:temperature_unit) = default_temperature_unit ())
  ?temperature:((temperature:temperature option) = None)
  () : request  = {
  desired;
  temperature;
}

and default_request_mutable () : request_mutable = {
  desired = default_temperature_unit ();
  temperature = None;
}

let rec default_response () : response = Error ("")

module Make_decoder(Decoder:Pbrt_json.Decoder_sig) = struct
  
  module Helper = Pbrt_json.Make_decoder_helper(Decoder)
  
  let rec decode_temperature_unit (value:Decoder.value) =
    match value with
    | Decoder.String "C" -> C
    | Decoder.String "F" -> F
    | _ -> Pbrt_json.E.malformed_variant "temperature_unit"
  
  let rec decode_temperature d =
    let v = default_temperature_mutable () in
    let continue = ref true in
    while !continue do
      match Decoder.key d with
      | None -> continue := false 
      | Some ("u", json_value) -> 
        v.u <- (decode_temperature_unit json_value)
      | Some ("v", json_value) -> 
        v.v <- Helper.float json_value "temperature" "v"
      
      | Some (_, _) -> () (*Unknown fields are ignored*)
    done;
    ({
      u = v.u;
      v = v.v;
    } : temperature)
  
  let rec decode_request d =
    let v = default_request_mutable () in
    let continue = ref true in
    while !continue do
      match Decoder.key d with
      | None -> continue := false 
      | Some ("desired", json_value) -> 
        v.desired <- (decode_temperature_unit json_value)
      | Some ("temperature", Decoder.Object o) -> 
        v.temperature <- Some ((decode_temperature o))
      | Some ("temperature", _) -> 
        v.temperature <- Some ((Pbrt_json.E.unexpected_json_type "request" "temperature"))
      
      | Some (_, _) -> () (*Unknown fields are ignored*)
    done;
    ({
      desired = v.desired;
      temperature = v.temperature;
    } : request)
  
  let rec decode_response d =
    let rec loop () =
      match Decoder.key d with
      | None -> Pbrt_json.E.malformed_variant "response"
      | Some ("error", json_value) -> 
        Error (Helper.string json_value "response" "Error")
      | Some ("temperature", Decoder.Object o) -> 
        Temperature ((decode_temperature o))
      | Some ("temperature", _) -> 
        Temperature ((Pbrt_json.E.unexpected_json_type "response" "Temperature"))
      
      | Some (_, _) -> loop ()
    in
    loop ()
  
end

module Make_encoder(Encoder:Pbrt_json.Encoder_sig) = struct
  
  let rec encode_temperature_unit (v:temperature_unit) : string = 
    match v with
    | C -> "C"
    | F -> "F"
  
  let rec encode_temperature (v:temperature) encoder = 
    Encoder.set_string encoder "u" (encode_temperature_unit v.u);
    Encoder.set_float encoder "v" v.v;
    ()
  
  let rec encode_request (v:request) encoder = 
    Encoder.set_string encoder "desired" (encode_temperature_unit v.desired);
    begin match v.temperature with
      | None -> ()
      | Some v ->
      begin (* temperature field *)
        let encoder' = Encoder.empty () in
        encode_temperature v encoder';
        Encoder.set_object encoder "temperature" encoder';
      end;
    end;
    ()
  
  let rec encode_response (v:response) encoder = 
    begin match v with
      | Error v ->
      Encoder.set_string encoder "error" v;
      | Temperature v ->
      begin (* temperature field *)
        let encoder' = Encoder.empty () in
        encode_temperature v encoder';
        Encoder.set_object encoder "temperature" encoder';
      end;
    end
  
end