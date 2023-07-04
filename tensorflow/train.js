/*******************************************************************************
** Train the model
** BINCZAK Martin - 2023
*******************************************************************************/

import * as tf from '@tensorflow/tfjs-node';

import { resolve } from 'path';
import { loadModel } from './model.js';
import { getFeatures, getSequences } from './format.js';

const savedModelPath = './models';

export const trainModel = async (pair) => {
  const dataset = getFeatures(pair);
  const trainSize = Math.floor(dataset.length * 0.5);
  const trainData = tf.tensor3d(getSequences(150, dataset.slice(0, trainSize)), [150, 150, 5]);
  const trainLabels = tf.tensor3d(getSequences(150, dataset.slice(1, trainSize)), [150, 150, 5]);

  const model = await loadModel(pair);

  // Early stopping to avoid overfitting
  const earlyStop = tf.callbacks.earlyStopping({
    monitor: 'loss',
    patience: 200,
    restoreBestModel: true,
  });

  // Train model without early stopping
  const history = await model.fit(trainData, trainLabels, {
    epochs: 150,
    batchSize: 2000, // Increase batch size for parallelism
    callbacks: [tf.node.tensorBoard(`./logs/${pair}`)],
    verbose: 1,
  });

  await model.save(`file://${resolve(savedModelPath)}/${pair}`);
  await trainData.dispose();
  await trainLabels.dispose();
  await model.dispose();
};
