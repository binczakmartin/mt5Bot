#include "file.mqh"
#include "server.mqh"
#include "order.mqh"
#include "utils.mqh"
#include "variables.mqh"
#include <Trade\Trade.mqh>

void OpenPositions(string data) {
  int predictionsCount;
  
  Prediction predictions[ArraySize(MARKETS)];
  parsePredictions(data, predictions, predictionsCount);

  for (int i = 0; i < ArraySize(predictions); i++) {
    if (!checkOpenPosition(predictions[i].pair)
      || !checkOpenOrder(predictions[i].pair)
      || !CheckTotalOrdersAndPositions(NB_POSITION)) {
        continue;
    }

    CloseUnfilledOrders(predictions[i].pair, NB_HOUR_EXPIRATION);
    openPosition(predictions[i]);

    Sleep(3000);
  }
}

void openPosition(Prediction &prediction) {
  if (!prediction.currentPrice) {
    return;
  }
  
  double priceDifference = (prediction.predictedPrice - prediction.currentPrice) / prediction.currentPrice;

  if (priceDifference >= 0.01) {
    openOrder(prediction, false);
  } else if (priceDifference < -0.01) {
    openOrder(prediction, true);
  }
}

double GetNormalizedVolume(string symbol, double desiredVolume) {
    double minVolume = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
    double maxVolume = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
    double stepVolume = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);

    if (desiredVolume < minVolume) return minVolume;
    if (desiredVolume > maxVolume) return maxVolume;

    return MathRound((desiredVolume - minVolume) / stepVolume) * stepVolume + minVolume;
}