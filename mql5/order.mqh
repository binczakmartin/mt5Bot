/* place a take profit order with a stoploss */
bool placeOrder(symbol, price, tp, sl, volume ) {
   MqlTradeRequest   request={0};
   MqlTradeResult    result={0};
   
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