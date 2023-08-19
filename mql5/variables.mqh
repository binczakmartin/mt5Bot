/* Constants */
string   ENDPOINT               =   "http://ftmo-trader.ovh:3005";
int      TIMEOUT                =   5000;
int      NBCANDLE               =   9999;
string   DEBUG_FILE             =   "debug_logs.txt";
int      NB_POSITION            =   2;
double   POSITION_WEIGHT        =   0.235;
int      NB_HOUR_EXPIRATION     =   1;

/* Predictions structures */
struct Prediction {
  string pair;
  double predictedPrice;
  double currentPrice;
};

/* targeted markets */
string   MARKETS[10] = {
   "BTCUSD", "LTCUSD", "ETHUSD", "ADAUSD",
   "DOGEUSD", "XRPUSD", "DOTUSD", "DASHUSD"
};