#include "variables.mqh"

bool checkMargin(string symbol, double volume) {
  double lotSize = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
  double marginHedged = SymbolInfoDouble(symbol, SYMBOL_MARGIN_HEDGED);
  double tickValue = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
  double tickSize = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
  double leverage = AccountInfoInteger(ACCOUNT_LEVERAGE);

  double requiredMargin = (volume / lotSize) * marginHedged * (tickValue / tickSize) / leverage;

  if (AccountInfoDouble(ACCOUNT_FREEMARGIN) < requiredMargin) {
    Print("Not enough money to trade ", volume, " lots. Required margin: ", requiredMargin, " Free margin: ", AccountInfoDouble(ACCOUNT_FREEMARGIN));
    return false;
  }

  return true;
}

double GetLotsFromUSD(string symbol, double desiredUSD) {
  double lotSize = SymbolInfoDouble(symbol, SYMBOL_TRADE_CONTRACT_SIZE);
  double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
  double minVolume = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
  double maxVolume = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
  double stepVolume = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);

  if (lotSize == 0 || bid == 0 || stepVolume == 0) {
    Print("Invalid parameters!");
    return 0.0;
  }

  // Calculate the preliminary lots without considering min, max, and step
  double lots = desiredUSD / (lotSize * bid);

  // Determine the number of decimal places for stepVolume
  int decimals = 0;
  while (stepVolume < 1) {
    stepVolume *= 10;
    decimals++;
  }

  // Round to the nearest step size
  lots = NormalizeDouble(MathRound(lots / stepVolume) * stepVolume, decimals);

  // Ensure the lots are within min and max volume
  if (lots < minVolume) lots = minVolume;
  if (lots > maxVolume) lots = maxVolume;

  return lots;
}

/* place a long order with takeprofit and stoploss */
MqlTradeResult placeLong(string symbol, double price, double tp, double sl, double volume ) {
  MqlTradeRequest   request={};
  MqlTradeResult    result={};

  //if (!checkMargin(symbol, volume)) return result;

  //request.action        = TRADE_ACTION_PENDING; //for limit trade     
  request.action        = TRADE_ACTION_DEAL;             
  request.symbol        = symbol;                                  
  request.volume        = volume;
  request.sl            = sl;
  request.tp            = tp;                  
  request.type          = ORDER_TYPE_BUY;
  request.type_filling  = ORDER_FILLING_IOC;
  request.price         = price; 
  request.deviation     = 10;                                    
  request.magic         = 4444;
  
  if (!OrderSend(request, result)) {
    Print("OrderSend failed with error code: ", GetLastError());
    result.retcode = GetLastError();
  }
   
  return result;
}

/* place a short order with takeprofit and stoploss */
MqlTradeResult placeShort(string symbol, double price, double tp, double sl, double volume ) {
  MqlTradeRequest   request={};
  MqlTradeResult    result={};

  //if (!checkMargin(symbol, volume)) return result;

  //request.action        = TRADE_ACTION_PENDING;
  request.action        = TRADE_ACTION_DEAL;                       
  request.symbol        = symbol;                                  
  request.volume        = volume;
  request.sl            = sl;
  request.tp            = tp;                  
  request.type          = ORDER_TYPE_SELL;
  request.type_filling  = ORDER_FILLING_IOC;
  request.price         = price; 
  request.deviation     = 10;                                    
  request.magic         = 4444;
  
  if (!OrderSend(request, result)) {
    Print("OrderSend failed with error code: ", GetLastError());
    result.retcode = GetLastError();
  }
   
  return result;
}

void openOrder(Prediction &prediction, bool isShort) {
  double capitalUnrounded = AccountInfoDouble(ACCOUNT_BALANCE) * POSITION_WEIGHT;
  double capital = MathRound(capitalUnrounded);
  double price = getPrice(prediction.pair, isShort);
  double volumeUnrounded = capital / price;
  double volume = GetNormalizedVolume(prediction.pair, volumeUnrounded);
  double tpLong = round(price * 1.04, prediction.pair);
  double slLong = round(price * 0.96, prediction.pair);
  double tpShort = round(price * 0.96, prediction.pair);
  double slShort = round(price * 1.04, prediction.pair);
  double lots = GetLotsFromUSD(prediction.pair, capital);
  
  Print("volume ", lots);

  if (isShort) {
    Print("placeShort pair:", prediction.pair, " price:", price, " tp:", tpShort, " sl:", slShort, " volume:", lots);
    placeShort(prediction.pair, price, tpShort, slShort, lots);
  } else {
    Print("placeLong pair:", prediction.pair, " price:", price, " tp:", tpLong, " sl:", slLong, " volume:", lots);
    placeLong(prediction.pair, price, tpLong, slLong, lots);
  }
}

void CloseUnfilledOrders(string symbol, int hours) {
  MqlTradeRequest request = {};
  MqlTradeResult result = {};
  datetime expirationTime = TimeCurrent() - PeriodSeconds(PERIOD_H1) * hours;

  for (int i = OrdersTotal() - 1; i >= 0; i--) {
    ulong order_ticket = OrderGetTicket(i);
    string orderSymbol;
    OrderGetString(ORDER_SYMBOL, orderSymbol);
    datetime orderTimeSetup;
    OrderGetInteger(ORDER_TIME_SETUP, orderTimeSetup);
    if (orderSymbol == symbol && orderTimeSetup < expirationTime) {
      request.action = TRADE_ACTION_REMOVE;
      request.order = order_ticket;

      if (!OrderSend(request, result)) {
        PrintFormat("OrderSend error %d", GetLastError());
      } else {
        Print(symbol, " expired order");
      }
    }
  }
}
