#include "file.mqh"
#include "server.mqh"
#include "order.mqh"
#include "utils.mqh"
#include "variables.mqh"
#include <Trade\Trade.mqh>

void HandleAPIResponse(string response) {
  LogToFile("Réponse de l'API : " + response);
  Prediction predictions[10];
  int currentPosition = 0;
  for (int i = 0; i < ArraySize(MARKETS); i++) {
    string pair = MARKETS[i];
    int pairPosition = StringFind(response, pair);
    if (pairPosition != -1) {
      string jsonValue = GetJSONValueByIndex(response, "nextData", 0, pairPosition);
      predictions[currentPosition].pair = pair;
      predictions[currentPosition].predictedPrice = StringToDouble(jsonValue);
      predictions[currentPosition].currentPrice = (SymbolInfoDouble(pair, SYMBOL_BID) + SymbolInfoDouble(pair, SYMBOL_ASK)) / 2;
      currentPosition++;
    }
  }

  CheckAndOpenPosition(predictions);
}

void CheckAndOpenPosition(Prediction &predictions[]) {
  int openPositions = 0;

  for (int i = 0; i < ArraySize(predictions); i++) {
    if (HasOpenPosition(predictions[i].pair) || HasOpenOrder(predictions[i].pair) || !CheckTotalOrdersAndPositions(NB_POSITION)) {
        LogToFile("Position or order already open for " + predictions[i].pair);
        continue;
    }

    CloseUnfilledOrders(predictions[i].pair, NB_HOUR_EXPIRATION);
    
    double capitalUnrounded = AccountInfoDouble(ACCOUNT_BALANCE) * POSITION_WEIGHT;
    double capital = MathRound(capitalUnrounded);
    double volumeUnrounded = capital / predictions[i].currentPrice;
    double volume = GetNormalizedVolume(predictions[i].pair, volumeUnrounded); // Use the function to get normalized volume
    double priceDifference = (predictions[i].predictedPrice - predictions[i].currentPrice) / predictions[i].currentPrice;

    LogToFile("Capital pour " + predictions[i].pair + ": " + DoubleToString(capital));
    LogToFile("Volume pour " + predictions[i].pair + ": " + DoubleToString(volume));
    LogToFile("Prix actuel pour " + predictions[i].pair + ": " + DoubleToString(predictions[i].currentPrice));
    LogToFile("predictions[i].predictedPrice pour " + predictions[i].pair + ": " + predictions[i].predictedPrice);
    LogToFile("priceDifference pour " + predictions[i].pair + ": " + priceDifference);

    // TODO ADD VARIABLES IN VARIABLES.mqh MAKE A FUNCTION
    if (priceDifference >= 0.006) {
      double tp = predictions[i].currentPrice * 1.005;
      double sl = predictions[i].currentPrice * 0.985;
      LogToFile("placeLong pair:"+predictions[i].pair+" price:"+ predictions[i].currentPrice+" tp:"+tp+" sl:"+sl+" volume:"+volume);
      placeLong(predictions[i].pair, predictions[i].currentPrice, tp, sl, volume);
      openPositions++;
    } else if (priceDifference <= -0.006) {
      double tp = predictions[i].currentPrice * 0.995;
      double sl = predictions[i].currentPrice * 1.015;
      LogToFile("placeShort pair:"+predictions[i].pair+" price:"+ predictions[i].currentPrice+" tp:"+tp+" sl:"+sl+" volume:"+volume);
      placeShort(predictions[i].pair, predictions[i].currentPrice, tp, sl, volume);
      openPositions++;
    } else {
      LogToFile("Pas de position à ouvrir pour " + predictions[i].pair);
    }

    Sleep(3000);
  }
}

/* Manage position */
void managePosition() {
   LogToFile("Gestion des positions\n\n");
   MqlTradeResult result = {};
   
   for (int i = 0; i < ArraySize(MARKETS); i += 1) {
      string ohlvc = readFile(MARKETS[i]);
      writeFile(MARKETS[i]);    
      sendOHLCV(MARKETS[i], ohlvc);
   }
}
