/*******************************************************************************
** Model architectrure
** BINCZAK Martin - 2023
*******************************************************************************/

import fs from "fs";
import * as tf from "@tensorflow/tfjs";

import { resolve, join } from "path";

const savedModelPath = "./models";

export const loadModel = async function (pair) {
  let model;

  const modelPath = join(savedModelPath, "model.json");
  if (fs.existsSync(`${savedModelPath}/${pair}/model.json`)) {
    model = await tf.loadLayersModel(`file://${resolve(savedModelPath)}/${pair}/model.json`);
  } else {
    const input = tf.input({ shape: [150, 5] });

    const rnn1 = tf.layers.simpleRNN({
      units: 256,
      activation: "selu",
      returnSequences: true,
    }).apply(input);

    const output = tf.layers.dense({
      units: 5,
      activation: "linear",
    }).apply(rnn1);

    model = tf.model({ inputs: input, outputs: output });
  }

  model.compile({
    optimizer: "adamax",
    loss: tf.metrics.meanAbsolutePercentageError,
  });

  return model;
};
