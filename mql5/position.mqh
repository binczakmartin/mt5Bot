#include "file.mqh"
#include "server.mqh"
#include "order.mqh"
#include "utils.mqh"
#include "variables.mqh"
#include <Trade\Trade.mqh>

double getPrice(string symbol) {
  double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
  double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);

  return round((bid + ask*9) / 10, symbol); // Round to the symbol's precision
}

void openPosition(Prediction &prediction) {
  double price = getPrice(prediction.pair);
  double capitalUnrounded = AccountInfoDouble(ACCOUNT_BALANCE) * POSITION_WEIGHT;
  double capital = MathRound(capitalUnrounded);
  double volumeUnrounded = capital / price;
  double volume = GetNormalizedVolume(prediction.pair, volumeUnrounded);
  double priceDifference = (prediction.predictedPrice - prediction.currentPrice) / prediction.currentPrice;

  if (priceDifference >= 0.006) {
    double tp = round(price  * 1.005, prediction.pair);
    double sl = round(price  * 0.985, prediction.pair);
    Print("placeLong pair:", prediction.pair, " price:", price, " tp:", tp, " sl:", sl, " volume:", volume);
    placeLong(prediction.pair, price, tp, sl, volume);
  } else if (priceDifference <= -0.006) {
    double tp = round(price  * 0.995, prediction.pair);
    double sl = round(price  * 1.015, prediction.pair);
    Print("placeShort pair:", prediction.pair, " price:", price, " tp:", tp, " sl:", sl, " volume:", volume);
    placeShort(prediction.pair, price, tp, sl, volume);
  } else {
    return;
  }
}

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