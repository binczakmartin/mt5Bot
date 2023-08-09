#include "logic.mqh"

/* when the script start */
void OnStart() {
   int   i = 0;
   
   printf("Start EA");
   managePosition();
   
   while (true) {
      i++;
      if (i % 30 == 0) { // dont call the API too much
         managePosition();
         string data = GetPredictions();
         HandleAPIResponse(data);
         i = 0;
      }

      Sleep(1000);
   }
}

/* after each update */
void OnTick() {
}
