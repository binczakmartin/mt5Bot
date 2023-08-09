#include "variables.mqh"

string GetJSONValueByIndex(string json, string key, int index, int startPos = 0) {
    int keyPos = StringFind(json, key, startPos);
    if (keyPos == -1) return "";

    int arrayStartPos = StringFind(json, "[", keyPos);
    int arrayEndPos = StringFind(json, "]", keyPos);

    if (arrayStartPos == -1 || arrayEndPos == -1) return "";

    string arrayContent = StringSubstr(json, arrayStartPos + 1, arrayEndPos - arrayStartPos - 1);
    StringReplace(arrayContent, " ", ""); // remove spaces for easier parsing

    string values[];
    int numValues = StringSplit(arrayContent, ',', values);

    if (index >= 0 && index < numValues) {
        return values[index];
    }
    return "";
}

void PrintPredictions(Prediction &predictions[]) {
    Print("----- Affichage des Prédictions -----");
    for (int i = 0; i < ArraySize(predictions); i++) {
        Print("Pair : ", predictions[i].pair);
        Print("Prix Prédit : ", DoubleToString(predictions[i].predictedPrice, 6));
        Print("Prix Actuel : ", DoubleToString(predictions[i].currentPrice, 6));
        Print("---------------------------");
    }
}

void LogToFile(string message) {
    int fileHandle = FileOpen(DEBUG_FILE, FILE_TXT | FILE_WRITE | FILE_READ | FILE_SHARE_READ);
    if(fileHandle != INVALID_HANDLE) {
        FileSeek(fileHandle, 0, SEEK_END); // Move to the end of the file
        FileWriteString(fileHandle, message + "\n");
        FileClose(fileHandle);
    } else {
        Print("Error opening file, error code: ", GetLastError());
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

bool HasOpenPosition(string symbol) {
    for(int i = PositionsTotal() - 1; i >= 0; i--) {
        string positionSymbol = PositionGetSymbol(i);
        if (positionSymbol == symbol) {
            return true;
            Print("have open position %s ", symbol);
        }
    }
    return false;
}

bool HasOpenOrder(string symbol) {
  for(int i = 0; i < OrdersTotal(); i++) {
    ulong ticket = OrderGetTicket(i);
    string orderSymbol;
    if (OrderGetString(ORDER_SYMBOL, orderSymbol) && orderSymbol == symbol) {
      Print("has open order %s ", symbol);
      return true;
    }
  }
  return false;
}

bool CheckTotalOrdersAndPositions(int maxOrders) {
  int totalOrders = 0;

  for (int i = 0; i < OrdersTotal(); i++) {
    totalOrders++;
  }

  totalOrders += PositionsTotal();
  Print("totalOrders %d ", totalOrders <= maxOrders);
  return totalOrders <= maxOrders;
}






