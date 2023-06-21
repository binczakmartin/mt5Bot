/*******************************************************************************
** Express server and AI training loop
** BINCZAK Martin - 2023
*******************************************************************************/

import express from 'express';
import bodyParser from 'body-parser';
import rawBody from 'raw-body';
import fs from 'fs';

import { trainModel } from './tensorflow/train.js';
import { getFileNamesWithoutExtension } from './tensorflow/format.js';

const app = express();
const port = 3005;

app.use(bodyParser.json());

// format du body de la requete envoyé par MT5
app.use((req, res, next) => {
  rawBody(req, {
    length: req.headers['content-length'],
    limit: '10000mb',
    encoding: 'utf8',
  }, (err, body) => {
    if (err) return next(err);

    req.body = body;
    next();
  });
});

// reception des données depuis MT5
app.post('/:market', async (req, res) => {
  try {
    const market = req.params.market;
    const content = JSON.parse(req.body.replace(/\0/g, ''));
    console.log(`POST ${market} ${content.length}`);
    fs.writeFileSync(`data/${market}.json`, JSON.stringify(content), "utf8");
    res.send({ status: 'OK' });
  }
  catch (e) {
    console.error(e);
    res.send({ status: 'KO' });
  }
});

// lancement du serveur
app.listen(port, async () => {
  console.log(`Serveur en écoute sur le port ${port}`);
});

// entrainement en boucle de l'IA
(async () => {
  while (true) {
    let promiseTab = []; 
    let markets = getFileNamesWithoutExtension();

    for (let market of markets) {
      promiseTab.push(trainModel(market));
    }

    await Promise.all(promiseTab);
    await new Promise(resolve => setTimeout(resolve, 2000));
  }
})();