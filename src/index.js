import express from 'express';
import bodyParser from 'body-parser';
import {convert_json} from '../lib/js/src/conversion' 

const app = express(); 
app.use(bodyParser.text())

app.post('/', (function (req, res) {
  res.send(convert_json(req.body)); 
}));

app.listen(8000, () => { console.log("Web server started"); });
