/* Constants */
string   ENDPOINT               =   "http://127.0.0.1:3005";
int      TIMEOUT                =   5000;
int      NBCANDLE               =   9000;
string   DEBUG_FILE             =   "debug_logs.txt";
int      NB_POSITION            =   3;
double   POSITION_WEIGHT        =   0.25;
int      NB_HOUR_EXPIRATION     =   1;

/* Predictions structures */
struct Prediction {
  string pair;
  double predictedPrice;
  double currentPrice;
};

/* target markets */
string   MARKETS[10] = {
   "BTCUSD", "LTCUSD", "ETHUSD", "DOGEUSD", "DOTUSD",
   "ADAUSD", "XRPUSD", "NEOUSD", "XMRUSD", "DASHUSD"
};