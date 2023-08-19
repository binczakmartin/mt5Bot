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

void parsePredictions(string response, Prediction &predictions[], int &predictionsCount) {
  LogToFile("Réponse de l'API : " + response);
  predictionsCount = 0; // Initialize predictions count
  for (int i = 0; i < ArraySize(MARKETS); i++) {
    int pairPosition = StringFind(response, MARKETS[i]);
    if (pairPosition != -1) {
      string jsonValue = GetJSONValueByIndex(response, "nextData", 0, pairPosition);
      predictions[predictionsCount].pair = MARKETS[i];
      predictions[predictionsCount].predictedPrice = StringToDouble(jsonValue);
      predictions[predictionsCount].currentPrice = (SymbolInfoDouble(MARKETS[i], SYMBOL_BID));
      predictionsCount++;
    }
  }
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

bool checkOpenPosition(string symbol) {
    for(int i = PositionsTotal() - 1; i >= 0; i--) {
        string positionSymbol = PositionGetSymbol(i);
        if (positionSymbol == symbol) {
            return false;
        }
    }
    return true;
}

bool checkOpenOrder(string symbol) {
  for(int i = 0; i < OrdersTotal(); i++) {
    ulong ticket = OrderGetTicket(i);
    string orderSymbol;
    if (OrderGetString(ORDER_SYMBOL, orderSymbol) && orderSymbol == symbol) {
      return false;
    }
  }
  return true;
}

bool CheckTotalOrdersAndPositions(int maxOrders) {
  int totalOrders = 0;

  for (int i = 0; i < OrdersTotal(); i++) {
    totalOrders++;
  }

  totalOrders += PositionsTotal();
  return totalOrders <= maxOrders;
}

double round(double price, string symbol) {
  int precision = SymbolInfoInteger(symbol, SYMBOL_DIGITS);
  return NormalizeDouble(price, precision);
}

double getPrice(string symbol, bool isShort) {
  double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
  double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);

  if (isShort) {
      return SymbolInfoDouble(symbol, SYMBOL_BID);
  }
  return SymbolInfoDouble(symbol, SYMBOL_ASK); 
}
