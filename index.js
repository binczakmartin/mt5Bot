/* dirty expres API */

const express = require('express');
const bodyParser = require('body-parser');
const rawBody = require('raw-body');
const fs = require('fs');

const app = express();
const port = 3005;

app.use(bodyParser.json());

app.use((req, res, next) => {
  rawBody(req, {
    length: req.headers['content-length'],
    limit: '100mb',
    encoding: 'utf8',
  }, (err, body) => {
    if (err) return next(err);

    req.body = body;
    next();
  });
});

app.post('/:market', (req, res) => {
  const market = req.params.market;
  const content = JSON.parse(req.body.replace(/\0/g, ''));

  fs.writeFileSync(`data/${market}.json`, JSON.stringify(content), "utf8");

  res.send({status: 'OK'});
});

app.listen(port, () => {
  console.log(`Serveur en écoute sur le port ${port}`);
});
