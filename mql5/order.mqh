#include "variables.mqh"

/* place a long order with takeprofit and stoploss */
MqlTradeResult placeLong(string symbol, double price, double tp, double sl, double volume ) {
  MqlTradeRequest   request={};
  MqlTradeResult    result={};
   
  request.action    = TRADE_ACTION_PENDING;                     
  request.symbol    = symbol;                                  
  request.volume    = volume;
  request.sl        = sl;
  request.tp        = tp;                  
  request.type      = ORDER_TYPE_BUY_LIMIT;
  request.price     = price; 
  request.deviation = 10;                                    
  request.magic     = 4444;
   
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

  request.action    = TRADE_ACTION_PENDING;                     
  request.symbol    = symbol;                                  
  request.volume    = volume;
  request.sl        = sl;
  request.tp        = tp;                  
  request.type      = ORDER_TYPE_SELL_LIMIT;
  request.price     = price; 
  request.deviation = 10;                                    
  request.magic     = 4444;
   
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
  double tpLong = round(price * 1.005, prediction.pair);
  double slLong = round(price * 0.985, prediction.pair);
  double tpShort = round(price * 0.995, prediction.pair);
  double slShort = round(price * 1.015, prediction.pair);

  if (isShort) {
    Print("placeShort pair:", prediction.pair, " price:", price, " tp:", tpShort, " sl:", slShort, " volume:", volume);
    placeShort(prediction.pair, price, tpShort, slShort, volume);
  } else {
    Print("placeLong pair:", prediction.pair, " price:", price, " tp:", tpLong, " sl:", slLong, " volume:", volume);
    placeLong(prediction.pair, price, tpLong, slLong, volume);
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
