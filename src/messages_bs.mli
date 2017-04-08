(** messages.proto BuckleScript Encoding *)


(** {2 Protobuf JSON Encoding} *)

val encode_temperature_unit : Messages_types.temperature_unit -> string
(** [encode_temperature_unit v] returns JSON string*)

val encode_temperature : Messages_types.temperature -> Js_json.t Js_dict.t -> unit
(** [encode_temperature v dict] encodes [v] int the given JSON [dict] *)

val encode_request : Messages_types.request -> Js_json.t Js_dict.t -> unit
(** [encode_request v dict] encodes [v] int the given JSON [dict] *)

val encode_response : Messages_types.response -> Js_json.t Js_dict.t -> unit
(** [encode_response v dict] encodes [v] int the given JSON [dict] *)


(** {2 BS Decoding} *)

val decode_temperature_unit : Js_json.t -> Messages_types.temperature_unit
(** [decode_temperature_unit value] decodes a [temperature_unit] from a Json value*)

val decode_temperature : Js_json.t Js_dict.t -> Messages_types.temperature
(** [decode_temperature decoder] decodes a [temperature] value from [decoder] *)

val decode_request : Js_json.t Js_dict.t -> Messages_types.request
(** [decode_request decoder] decodes a [request] value from [decoder] *)

val decode_response : Js_json.t Js_dict.t -> Messages_types.response
(** [decode_response decoder] decodes a [response] value from [decoder] *)
