/*******************************************************************************
** Model structure
** BINCZAK Martin - 2023
*******************************************************************************/

import fs from "fs";
import * as tf from "@tensorflow/tfjs-node";

import { resolve } from "path";

const savedModelPath = './models';

export const loadModel = async function (pair) {
  let model;

  if (fs.existsSync(`${savedModelPath}/${pair}/model.json`)) {
    model = await tf.loadLayersModel(
      `file://${resolve(savedModelPath)}/${pair}/model.json`
    );
  } else {
    // Define a new model architecture
    const input = tf.input({ shape: [5] });
    const normalizeLayer = tf.layers.batchNormalization({});
    const normalizedInput = normalizeLayer.apply(input);

    // first layer
    const dense1 = tf.layers.dense({
      units: 128,
      activation: "relu",
    }).apply(normalizedInput);
    const bn1 = tf.layers.batchNormalization({}).apply(dense1);

    // second layer
    const dense2 = tf.layers.dense({
      units: 64,
      activation: "relu",
    }).apply(bn1);
    const bn2 = tf.layers.batchNormalization({}).apply(dense2);

    // third layer
    const dense3 = tf.layers.dense({
      units: 16,
      activation: "linear",
    }).apply(bn2);
    const bn3 = tf.layers.batchNormalization({}).apply(dense3);

    // output
    const output = tf.layers.dense({
      units: 1,
      activation: "relu",
    }).apply(bn3);
    model = tf.model({ inputs: input, outputs: output });
  }

  // compile model
  model.compile({
    optimizer: tf.train.adamax(),
    loss: "meanSquaredLogarithmicError",
  });

  return model;
};
