/*******************************************************************************
** Format the data to be processed by the model
** BINCZAK Martin - 2023
*******************************************************************************/

import fs from "fs";

export const getFeatures = function (pair) {
  const features = [];
  const filePath = `./data/${pair}.json`;

  if (fs.existsSync(filePath)) {
    const data = JSON.parse(fs.readFileSync(filePath));
    data.map((elem) => {
      const values = Object.values(elem).map((x) => parseFloat(x));
      values.shift(); // Remove the first element
      features.push(values);
    });
    return features;
  }

  return features;
};

export const getFileNamesWithoutExtension = function () {
  const fileNames = fs.readdirSync('./data');
  const namesWithoutExtension = fileNames.map((fileName) => {
    const name = fileName.replace(".json", "");
    return name;
  });

  return namesWithoutExtension;
}