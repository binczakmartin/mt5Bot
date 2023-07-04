/* place a long order with takeprofit and stoploss */
MqlTradeResult placeLong(string symbol, double price, double tp, double sl, float volume ) {
   MqlTradeRequest   request={};
   MqlTradeResult    result={};
   
   request.action    = TRADE_ACTION_DEAL;                     
   request.symbol    = symbol;                                  
   request.volume    = volume;
   request.sl        = sl;
   request.tp        = tp;                  
   request.type      = ORDER_TYPE_BUY;                        
   request.price     = price; 
   request.deviation = 10;                                    
   request.magic     = 4444;
   //result.order      = orderCCIticket;
   
   OrderSend(request, result);
   
   return result;
}

/* place a short order with takeprofit and stoploss */
MqlTradeResult placeShort(string symbol, double price, double tp, double sl, float volume ) {
   MqlTradeRequest   request={};
   MqlTradeResult    result={};
   
   request.action    = TRADE_ACTION_DEAL;                     
   request.symbol    = symbol;                                  
   request.volume    = volume;
   request.sl        = sl;
   request.tp        = tp;                  
   request.type      = ORDER_TYPE_SELL;                        
   request.price     = price; 
   request.deviation = 10;                                    
   request.magic     = 4444;
   //result.order      = orderCCIticket;
   
   OrderSend(request, result);
   
   return result;
}