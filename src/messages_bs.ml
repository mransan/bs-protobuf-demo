[@@@ocaml.warning "-27-30-39"]

type temperature_mutable = {
  mutable u : Messages_types.temperature_unit;
  mutable v : float;
}

let default_temperature_mutable () : temperature_mutable = {
  u = Messages_types.default_temperature_unit ();
  v = 0.;
}

type request_mutable = {
  mutable desired : Messages_types.temperature_unit;
  mutable temperature : Messages_types.temperature option;
}

let default_request_mutable () : request_mutable = {
  desired = Messages_types.default_temperature_unit ();
  temperature = None;
}


let rec decode_temperature_unit (json:Js_json.t) =
  match Pbrt_bs.string json "temperature_unit" "value" with
  | "C" -> Messages_types.C
  | "F" -> Messages_types.F
  | "" -> Messages_types.C
  | _ -> Pbrt_bs.E.malformed_variant "temperature_unit"

let rec decode_temperature json =
  let v = default_temperature_mutable () in
  let keys = Js_dict.keys json in
  let last_key_index = Array.length keys - 1 in
  for i = 0 to last_key_index do
    match Array.unsafe_get keys i with
    | "u" -> 
      let json = Js_dict.unsafeGet json "u" in
      v.u <- (decode_temperature_unit json)
    | "v" -> 
      let json = Js_dict.unsafeGet json "v" in
      v.v <- Pbrt_bs.float json "temperature" "v"
    
    | _ -> () (*Unknown fields are ignored*)
  done;
  ({
    Messages_types.u = v.u;
    Messages_types.v = v.v;
  } : Messages_types.temperature)

let rec decode_request json =
  let v = default_request_mutable () in
  let keys = Js_dict.keys json in
  let last_key_index = Array.length keys - 1 in
  for i = 0 to last_key_index do
    match Array.unsafe_get keys i with
    | "desired" -> 
      let json = Js_dict.unsafeGet json "desired" in
      v.desired <- (decode_temperature_unit json)
    | "temperature" -> 
      let json = Js_dict.unsafeGet json "temperature" in
      v.temperature <- Some ((decode_temperature (Pbrt_bs.object_ json "request" "temperature")))
    
    | _ -> () (*Unknown fields are ignored*)
  done;
  ({
    Messages_types.desired = v.desired;
    Messages_types.temperature = v.temperature;
  } : Messages_types.request)

let rec decode_response json =
  let keys = Js_dict.keys json in
  let rec loop = function 
    | -1 -> Pbrt_bs.E.malformed_variant "response"
    | i -> 
      begin match Array.unsafe_get keys i with
      | "error" -> 
        let json = Js_dict.unsafeGet json "error" in
        Messages_types.Error (Pbrt_bs.string json "response" "Error")
      | "temperature" -> 
        let json = Js_dict.unsafeGet json "temperature" in
        Messages_types.Temperature ((decode_temperature (Pbrt_bs.object_ json "response" "Temperature")))
      
      | _ -> loop (i - 1)
      end
  in
  loop (Array.length keys - 1)

let rec encode_temperature_unit (v:Messages_types.temperature_unit) : string = 
  match v with
  | Messages_types.C -> "C"
  | Messages_types.F -> "F"

let rec encode_temperature (v:Messages_types.temperature) json = 
  Js_dict.set json "u" (Js_json.string (encode_temperature_unit v.Messages_types.u));
  Js_dict.set json "v" (Js_json.number v.Messages_types.v);
  ()

let rec encode_request (v:Messages_types.request) json = 
  Js_dict.set json "desired" (Js_json.string (encode_temperature_unit v.Messages_types.desired));
  begin match v.Messages_types.temperature with
  | None -> ()
  | Some v ->
    begin (* temperature field *)
      let json' = Js_dict.empty () in
      encode_temperature v json';
      Js_dict.set json "temperature" (Js_json.object_ json');
    end;
  end;
  ()

let rec encode_response (v:Messages_types.response) json = 
  begin match v with
  | Messages_types.Error v ->
    Js_dict.set json "error" (Js_json.string v);
  | Messages_types.Temperature v ->
    begin (* temperature field *)
      let json' = Js_dict.empty () in
      encode_temperature v json';
      Js_dict.set json "temperature" (Js_json.object_ json');
    end;
  end
