(** messages.proto Types *)



(** {2 Types} *)

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


(** {2 Default values} *)

val default_temperature_unit : unit -> temperature_unit
(** [default_temperature_unit ()] is the default value for type [temperature_unit] *)

val default_temperature : 
  ?u:temperature_unit ->
  ?v:float ->
  unit ->
  temperature
(** [default_temperature ()] is the default value for type [temperature] *)

val default_request : 
  ?desired:temperature_unit ->
  ?temperature:temperature option ->
  unit ->
  request
(** [default_request ()] is the default value for type [request] *)

val default_response : unit -> response
(** [default_response ()] is the default value for type [response] *)
