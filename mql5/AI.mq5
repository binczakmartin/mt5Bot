#include "file.mqh"
#include "server.mqh"

/* target markets */
string   MARKETS[10] = {
   "BTCUSD", "ADAUSD", "ETHUSD",
   "XMRUSD", "DOTUSD", "XRPUSD",
   "NEOUSD", "LTCUSD", "DOGEUSD",
   "DASHUSD"
};

/* constants */
string   ENDPOINT    =  "http://127.0.0.1:3005";
int      TIMEOUT     =  5000;
int      NBCANDLE    =  200;

/* when the script start */
void OnStart() {
   for (int i = 0; i < ArraySize(MARKETS); i += 1) {
      string ohlvc = readFile(MARKETS[i]);
   
      writeFile(MARKETS[i]);    
      sendOHLCV(MARKETS[i], ohlvc);
   }
}

/* after each update */
void OnTick() {

}
