[@@@ocaml.warning "-27-30-39"]


type temperature_unit =
  | C 
  | F 

type temperature = {
  u : temperature_unit;
  v : float;
}

type request = {
  desired : temperature_unit;
  temperature : temperature option;
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

let rec default_request 
  ?desired:((desired:temperature_unit) = default_temperature_unit ())
  ?temperature:((temperature:temperature option) = None)
  () : request  = {
  desired;
  temperature;
}

let rec default_response () : response = Error ("")
