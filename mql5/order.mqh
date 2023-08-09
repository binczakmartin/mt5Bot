/* place a long order with takeprofit and stoploss */
MqlTradeResult placeLong(string symbol, double price, double tp, double sl, double volume ) {
   MqlTradeRequest   request={};
   MqlTradeResult    result={};
   
   Print("volume: %f", volume);
   request.action    = TRADE_ACTION_PENDING;                     
   request.symbol    = symbol;                                  
   request.volume    = volume;
   request.sl        = sl;
   request.tp        = tp;                  
   request.type      = ORDER_TYPE_BUY_LIMIT;                        
   request.price     = price; 
   request.deviation = 10;                                    
   request.magic     = 4444;
   //result.order      = orderCCIticket;
   
   OrderSend(request, result);
   
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
   //result.order      = orderCCIticket;
   
   OrderSend(request, result);
   
   return result;
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
      // Setting the operation parameters
      request.action = TRADE_ACTION_REMOVE; // Type of trade operation
      request.order = order_ticket;         // Order ticket
      // Send the request
      if (!OrderSend(request, result)) {
        PrintFormat("OrderSend error %d", GetLastError()); // If unable to send the request, output the error code
      } else {
        // Information about the operation
        PrintFormat("retcode=%u  deal=%I64u  order=%I64u", result.retcode, result.deal, result.order);
      }
    }
  }
}
