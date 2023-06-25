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
      units: 256, // Increase number of units
      activation: "selu", // Experiment with different activation functions
      returnSequences: true,
    }).apply(input);

    // const dense1 = tf.layers.dense({
    //   units: 64, // Increase number of units
    //   activation: "relu",
    // }).apply(rnn1);

    // const dropout1 = tf.layers.dropout({ rate: 0.2 }).apply(dense1); // Add dropout layer

    // const dense2 = tf.layers.dense({
    //   units: 16, // Increase number of units
    //   activation: "linear",
    // }).apply(dropout1);

    // const dropout2 = tf.layers.dropout({ rate: 0.2 }).apply(dense2); // Add dropout layer

    const output = tf.layers.dense({
      units: 5,
      activation: "linear", // Use linear activation for regression task
    }).apply(rnn1);

    model = tf.model({ inputs: input, outputs: output });
  }

  model.compile({
    optimizer: "adamax",
    loss: tf.metrics.meanAbsolutePercentageError,
  });

  return model;
};
