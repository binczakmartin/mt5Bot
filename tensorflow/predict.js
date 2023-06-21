/*******************************************************************************
** Train the model
** BINCZAK Martin - 2023
*******************************************************************************/

import * as tf from '@tensorflow/tfjs-node';

import { getFeatures } from "./format.js";
import { loadModel } from './model.js';

export const predictNextClose = async function (pair) {
  const model = await loadModel(pair);

  let data = getFeatures(pair);

  const newTensor = tf.tensor2d(data);

  const nextClosingPrice = model.predict(newTensor).dataSync()[0];
  console.log(data[data.length - 1]);
  console.log(`\x1b[38;5;178m${pair}\x1b[0m `, nextClosingPrice);
};
