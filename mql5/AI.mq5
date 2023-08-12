#include "position.mqh"

/* when the script start */
void OnStart() {
   int   i = 0;
   
   printf("Start EA");
   sendFiles();
   
   while (true) {
      i++;
      if (i % 30 == 0) { // dont call the API too much
         sendFiles();
         string data = getPredictions();
         OpenPositions(data);
         i = 0;
      }

      Sleep(1000);
   }
}

/* after each update */
void OnTick() {
}
