/*******************************************************************************
** Express server and AI training loop
** BINCZAK Martin - 2023
*******************************************************************************/

import express from 'express';
import bodyParser from 'body-parser';
import rawBody from 'raw-body';
import fs from 'fs';

import { trainModel } from './tensorflow/train.js';
import { predictNextClose } from './tensorflow/predict.js';
import { getFileNamesWithoutExtension } from './tensorflow/format.js';

const app = express();
const port = 3005;

app.use(bodyParser.json());

process.stdout.write('\x1Bc'); 

// MT5 body format
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

// get data from MT5
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

// predict next closes
app.get('/predict', async (req, res) => {
  try {
    let promiseTab = [];
    let markets = getFileNamesWithoutExtension();

    markets.forEach((market) => {
      promiseTab.push(predictNextClose(market));
    });

    const results = await Promise.all(promiseTab);
    console.log(results);
    res.send({ status: 'OK', results });
  }
  catch (error) {
    console.error(error);
    res.send({ status: 'KO', error: error.message });
  }
});

// AI training loop
(async () => {
  while (true) {
    let promiseTab = []; 
    let markets = getFileNamesWithoutExtension();

    markets.forEach((market) => promiseTab.push(trainModel(market)));
    
    const results = await Promise.all(promiseTab);
    process.stdout.write('\x1Bc');
    // results.forEach((result) => console.log(`pair: ${result.pair}, loss: ${result.loss} %`));

    await new Promise(resolve => setTimeout(resolve, 2000));
  }
})();

// launch API
app.listen(port, async () => console.log(`listening on port ${port}`));