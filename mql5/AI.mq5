#include "file.mqh"
#include "server.mqh"

/* target markets 
string   MARKETS[10] = {
   "BTCUSD", "ADAUSD", "ETHUSD",
   "XMRUSD", "DOTUSD", "XRPUSD",
   "NEOUSD", "LTCUSD", "DOGEUSD",
   "DASHUSD"
};*/

string   MARKETS[3] = {
   "BTCUSD", "LTCUSD", "ETHUSD",
};

/* constants */
string   ENDPOINT    =  "http://127.0.0.1:3005";
int      TIMEOUT     =  5000;
int      NBCANDLE    =  15000;

/* when the script start */
void OnStart() {
   int   i = 0;
   
   printf("Start EA");
   while (true) {
      i++;
      if (i % 60 == 0) { // dont call the API too much
         printf("Manage positions");
         for (int i = 0; i < ArraySize(MARKETS); i += 1) {
            string ohlvc = readFile(MARKETS[i]);
            writeFile(MARKETS[i]);    
            sendOHLCV(MARKETS[i], ohlvc);
         }
         i = 0;
      }
      Sleep(2000);
   }
}

/* after each update */
void OnTick() {
}
