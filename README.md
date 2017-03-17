Protobuf JSON Runtime for BuckleScript
--------------------------------------

> This package provide the runtime library in BuckleScript to be used with 
> generated code from [ocaml-protoc](https://github.com/mransan/ocaml-protoc/). 

Installation - Prerequesites
----------------------------

**[opam](http://opam.ocaml.org/)** 

> opam is the package manager for OCaml 

If not installed you can install it running the following:
```bash 
wget https://raw.github.com/ocaml/opam/master/shell/opam_installer.sh -O - | \
  sh -s /usr/local/bin 4.02.3+buckle-master
eval `opam config env` 
``` 

**[ocaml-protoc](https://github.com/mransan/ocaml-protoc)**

> `ocaml-protoc` is the compiler for protobuf messages to OCaml

```bash
opam install --yes ocaml-protoc
```

**[npm](https://nodejs.org/en/download/current/)**

> We assume you have node installed!

Simple example 
--------------

> In this simple example we'll demonstrate how to implement a library in OCaml
> to do temperature conversion. 
>
> The library API interface will be in JSON and will directly be used by 
> the web server

> We assume you start in an empty directory 

Start by creating the src directory:
```bash
mkdir src
```
**Setup npm install**

Start with this simple `package.json` file:
```json
{
  "name" : "test", 
  "dependencies": {
    "bs-ocaml-protoc-json": "^1.0.x",
    "bs-platform": "^1.5.x"
  }
}
```

🏁 Then run:
```bash
npm install
```

**Define a protobuf message** 

Create a `src/messages.proto` file with the following content:

```Protobuf
syntax = "proto3";

enum TemperatureUnit  {
  CELCIUS = 0; 
  FAHRENHEIT = 1;
}

message Temperature {
  TemperatureUnit temperature_unit = 1; 
  float temperature_value =  2;
}

message Request {
  TemperatureUnit desired_unit = 1;
  Temperature temperature = 2; 
}

message Response {
  oneof t {
    string error = 1; 
    Temperature temperature = 2;
  }
}
```

Now generate the OCaml code with JSON encoding:

```bash
ocaml-protoc -json -ml_out src src/messages.proto
```

🏁 If all goes well you should now have 2 new files in the `src` directory:
```
src/
├── messages_pb.ml
├── messages_pb.mli
└── messages.proto
```

**Writing the conversion API**

Let's first write the core API logic using the generated OCaml type. Add `src/conversion.ml` with the following code:

```OCaml
open Messages_pb 

let convert desired_unit ({temperature_unit; temperature_value}  as t)  = 
  if desired_unit = temperature_unit
  then t 
  else 
   let temperature_value = 
     match desired_unit with
     | Celcius -> (temperature_value -. 32.) *. 5. /. 9.  
     | Fahrenheit -> (temperature_value *. 9. /. 5.) -. 32.
   in 
   {temperature_value; temperature_unit = desired_unit}
```

Let'a also add a quick test to run the function in `src/conversion_test.ml`:
```OCaml
open Messages_pb 

let make_celcius temperature_value = {
  temperature_unit = Celcius; 
  temperature_value;
} 

let make_fahrenheit temperature_value = {
  temperature_unit = Fahrenheit; 
  temperature_value;
}

let log {temperature_value; _} = Js.log temperature_value

let () = 
  Conversion.convert Celcius (make_celcius 100.) |> log; 
  Conversion.convert Celcius (make_celcius 0.) |> log; 
  Conversion.convert Fahrenheit (make_celcius 0.) |> log
```

**Setup the build**

`BuckleScript` comes with its own build tool which requires config file. Create the following `bsconfig.json` at the 
top of your project:

```Json
{
  "name": "test",
  "sources": [ "src" ], 
  "bs-dependencies": [ "bs-ocaml-protoc"]
}
```

Edit the `package.json` to include 2 scripts for building and running the test":
```Json
{
  "name" : "test", 
  "dependencies": {
    "bs-ocaml-protoc-json": "file:../bs-ocaml-protoc-json.git",
    "bs-platform": "^1.5.x"
  },
  "scripts" : {
    "build" : "bsb -make-world",
    "test" : "npm run-script build && node lib/js/src/conversion_test.js"
  }
}
```

🏁 Now run `npm run-script test` and you should see the ouptut:
```bash
100
0
-32
```

**Add JSON API**

Next step is to provide a `convert_json` function which will take a JSON value of a type `request` and return a JSON value of 
type `response`. 

Let's append the following to `conversion.ml`:

```OCaml
module MessageEncoder = Messages_pb.Make_encoder(Pbrt_bsjson.Encoder)
module MessageDecoder = Messages_pb.Make_decoder(Pbrt_bsjson.Decoder) 

let request_of_json_string json_str = 
  match Pbrt_bsjson.Decoder.of_string json_str with
  | None -> None 
  | Some decoder -> 
    try
      Some (MessageDecoder.decode_request decoder)
    with _ -> None

let json_str_of_response response = 
  let encoder = Pbrt_bsjson.Encoder.empty () in 
  MessageEncoder.encode_response response encoder; 
  Pbrt_bsjson.Encoder.to_string encoder 

let convert_json request_str = 
  match request_of_json_string request_str with
  | Some {desired_unit; temperature = Some temperature} -> 
    let response = Temperature (convert desired_unit temperature) in 
    json_str_of_response response 
  | _ -> 
    json_str_of_response (Error "error decoding request")
```

Let's add a quick test as well in `src/conversion_test.ml`:
```OCaml
let () = 
  Js.log @@ Conversion.convert_json {|{
    "desiredUnit": "FAHRENHEIT", 
    "temperature": {
      "temperatureUnit" : "CELCIUS", 
      "temperatureValue": 0
    }
  }|}
```

We also need to update our `bsconfig.json` to include the new dependency for the JSON runtime:

```JSON
{
  "name": "test",
  "sources": [ "src" ], 
  "bs-dependencies": [ "bs-ocaml-protoc", "bs-ocaml-protoc-json"]
}
```

🏁 Now run `npm run-script test` and you should see the ouptut:

```
{"temperature":{"temperatureUnit":"FAHRENHEIT","temperatureValue":-32}}
```
