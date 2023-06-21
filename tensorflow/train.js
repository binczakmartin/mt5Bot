/*******************************************************************************
** Train the model
** BINCZAK Martin - 2023
*******************************************************************************/

import * as tf from '@tensorflow/tfjs-node';

import { resolve } from 'path';
import { loadModel } from './model.js';
import { getFeatures } from './format.js';

const savedModelPath = './models';

export const trainModel = async (pair) => {
  console.log("training pair ", pair)
  const dataset = getFeatures(pair);
  const trainSize = Math.floor(dataset.length * 0.75);

  const X_train = tf.tensor2d(dataset.slice(0, trainSize));
  const Y_train = tf.tensor1d(dataset.slice(0, trainSize).map(row => row[4]));
  const X_test = tf.tensor2d(dataset.slice(trainSize));
  const Y_test = tf.tensor1d(dataset.slice(trainSize).map(row => row[4]));
  
  const model = await loadModel(pair);

  // early stopping to avoid overfitting
  const earlyStop = tf.callbacks.earlyStopping({
    monitor: 'val_loss',
    patience: 5,
    restoreBestModel: true,
  });

  // Train model with early stopping
  const history = await model.fit(X_train, Y_train, {
    epochs: 50,
    batchSize: 1500, // Increase batch size for parallelism
    validationData: [X_test, Y_test],
    callbacks: [earlyStop, tf.node.tensorBoard('./logs')],
    verbose: 2,
  });

  await X_train.dispose();
  await Y_train.dispose();
  
  // Evaluate the model
  const loss = model.evaluate(X_test, Y_test);
  console.log(`Test loss: ${loss}`);

  await X_test.dispose();
  await Y_test.dispose();

  await model.save(`file://${resolve(savedModelPath)}/${pair}`);
  await model.dispose();
};
