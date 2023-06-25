/*******************************************************************************
** Train the model
** BINCZAK Martin - 2023
*******************************************************************************/

import * as tf from '@tensorflow/tfjs-node';

import { getFeatures, getSequences } from "./format.js";
import { loadModel } from './model.js';

export const predictNextClose = async function (pair) {
  const model = await loadModel(pair);
  const data = getFeatures(pair);
  const seq = getSequences(150, data)

  const newTensor = tf.tensor3d(seq);
  const prevData = seq[seq.length-1][seq[seq.length-1].length - 1];
  let nextData = [...model.predict(newTensor).dataSync().slice(-5)];
  nextData = nextData.map((elem) => elem = + Number(elem).toFixed(2));

  return {pair, nextData, prevData};
};
