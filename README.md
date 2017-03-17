Demo project for using Protobuf with BuckleScript
-------------------------------------------------

> This repo contains a demo project to illustrate how to use Protobuf messages in 
> BuckleScript.

The project consists in a JavaScript web server (Express) which provides a POST entry point **to convert
temperature between Celcius and Fahrenheit**. The request and response body are JSON values which format
is defined by a **Protobuf** schema file. 

This project demonstrates that using Protobuf along with the OCaml code generator [ocaml-protoc](https://github.com/mransan/ocaml-protoc), **one can easily, safely and efficiently serialize OCaml values to JSON.**

While this code is server side, it works equaly well on the client.

TL;TR
------

```
git clone https://github.com/mransan/bs-protobuf-demo.git
cd bs-protobuf-demo
npm install
npm run-script start & 
curl -H "Content-Type: text/plain" -X POST -d '{"desiredUnit":"C", "temperature" : {"u":"F", "v":120}}' \
  http://localhost:8000
```

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
opam install --yes "ocaml-protoc>=1.0.3"
```

**[npm](https://nodejs.org/en/download/current/)**

> We assume you have node installed!

Temperature conversion server
-----------------------------

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
  C = 0; // Celcius
  F = 1; // Fahrenheit
}

message Temperature {
  TemperatureUnit u = 1; 
  float v =  2;
}

message Request {
  TemperatureUnit desired = 1;
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
```

Let'a also add a quick test to run the function in `src/conversion_test.ml`:
```OCaml
open Messages_pb 

let make_celcius v = {u = C; v} 

let make_fahrenheit v = { u = F; v }

let log {v; _} = Js.log v

let () = 
  Conversion.convert C (make_celcius 100.) |> log; 
  Conversion.convert C (make_celcius 0.) |> log; 
  Conversion.convert F (make_celcius 0.) |> log
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
    "bs-ocaml-protoc-json": "^0.0.x",
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
```

Let's add a quick test as well in `src/conversion_test.ml`:
```OCaml
let () = 
  Js.log @@ Conversion.convert_json {|{
    "desired": "F", 
    "temperature": { "u" : "C", "v": 0 }
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
{"temperature":{"u":"F","v":-32}}
```

**Setting up web server**

First is of course to add all the JS tooling for ES6/Babel. Check [package.json](package.json), it contains all the dependencies and scripts to run the webserver, make sure to add [.babelrc](.babelrc) file as well and run `npm install` after.

The fun part is of course the main code of the web server which you can find [here](src/index.js):
```Javascript
import express from 'express';
import bodyParser from 'body-parser';
import {convert_json} from '../lib/js/src/conversion' 

const app = express(); 
app.use(bodyParser.text())

app.post('/', (function (req, res) {
  res.send(convert_json(req.body)); 
}));

app.listen(8000, () => { console.log("Web server started"); });
```

🏁 Now run the following, you should see the JSON response! Voila

```bash
curl -H "Content-Type: text/plain" -X POST -d '{"desiredUnit":"C", "temperature" : {"u":"F", "v":120}}' http://localhost:8000
```
