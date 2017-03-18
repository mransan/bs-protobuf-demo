(** messages.proto Generated Types and Encoding *)


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

type binary_tree_node = {
  value : string;
  left : binary_tree option;
  right : binary_tree option;
}

and binary_tree =
  | Node of binary_tree_node
  | Empty

type binary_tree_compact = {
  value : string;
  left : binary_tree_compact option;
  right : binary_tree_compact option;
}


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

val default_binary_tree_node : 
  ?value:string ->
  ?left:binary_tree option ->
  ?right:binary_tree option ->
  unit ->
  binary_tree_node
(** [default_binary_tree_node ()] is the default value for type [binary_tree_node] *)

val default_binary_tree : unit -> binary_tree
(** [default_binary_tree ()] is the default value for type [binary_tree] *)

val default_binary_tree_compact : 
  ?value:string ->
  ?left:binary_tree_compact option ->
  ?right:binary_tree_compact option ->
  unit ->
  binary_tree_compact
(** [default_binary_tree_compact ()] is the default value for type [binary_tree_compact] *)

module Make_decoder(Decoder:Pbrt_json.Decoder_sig) : sig
  
  (** {2 JSON Decoding} *)
  
  val decode_temperature_unit : Decoder.value -> temperature_unit
  (** [decode_temperature_unit value] decodes a [temperature_unit] from a Json value*)
  
  val decode_temperature : Decoder.t -> temperature
  (** [decode_temperature decoder] decodes a [temperature] value from [decoder] *)
  
  val decode_request : Decoder.t -> request
  (** [decode_request decoder] decodes a [request] value from [decoder] *)
  
  val decode_response : Decoder.t -> response
  (** [decode_response decoder] decodes a [response] value from [decoder] *)
  
  val decode_binary_tree_node : Decoder.t -> binary_tree_node
  (** [decode_binary_tree_node decoder] decodes a [binary_tree_node] value from [decoder] *)
  
  val decode_binary_tree : Decoder.t -> binary_tree
  (** [decode_binary_tree decoder] decodes a [binary_tree] value from [decoder] *)
  
  val decode_binary_tree_compact : Decoder.t -> binary_tree_compact
  (** [decode_binary_tree_compact decoder] decodes a [binary_tree_compact] value from [decoder] *)
  
end
module Make_encoder(Encoder:Pbrt_json.Encoder_sig) : sig
  
  (** {2 Protobuf JSON Encoding} *)
  
  val encode_temperature_unit : temperature_unit -> string
  (** [encode_temperature_unit v] returns JSON string*)
  
  val encode_temperature : temperature -> Encoder.t -> unit
  (** [encode_temperature v encoder] encodes [v] with the given [encoder] *)
  
  val encode_request : request -> Encoder.t -> unit
  (** [encode_request v encoder] encodes [v] with the given [encoder] *)
  
  val encode_response : response -> Encoder.t -> unit
  (** [encode_response v encoder] encodes [v] with the given [encoder] *)
  
  val encode_binary_tree_node : binary_tree_node -> Encoder.t -> unit
  (** [encode_binary_tree_node v encoder] encodes [v] with the given [encoder] *)
  
  val encode_binary_tree : binary_tree -> Encoder.t -> unit
  (** [encode_binary_tree v encoder] encodes [v] with the given [encoder] *)
  
  val encode_binary_tree_compact : binary_tree_compact -> Encoder.t -> unit
  (** [encode_binary_tree_compact v encoder] encodes [v] with the given [encoder] *)
  
end