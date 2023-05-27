/* global vars */
string   ENDPOINT    =  "http://127.0.0.1:3005";
int      TIMEOUT     =  5000;
int      NBCANDLE    =  200;
string   MARKETS[10] = 
{
                        "BTCUSD", "ADAUSD", "ETHUSD",
                        "XMRUSD", "DOTUSD", "XRPUSD",
                        "NEOUSD", "LTCUSD", "DOGEUSD",
                        "DASHUSD"
};

/* encode OHLCV data to JSON string */
string jsonEncode(MqlRates& rates[]) {
   string str = "[";
   
   for (int i = 0; i < ArraySize(rates); i += 1) {
      str += "{\"date\":\""   +  (double)    rates[i].time          + "\",";
      str += "\"open\":\""    +  (double)    rates[i].open          + "\",";
      str += "\"high\":\""    +  (double)    rates[i].high          + "\",";
      str += "\"low\":\""     +  (double)    rates[i].low           + "\",";
      str += "\"close\":\""   +  (double)    rates[i].close         + "\",";
      str += "\"volume\":\""  +  (double)    rates[i].tick_volume   + "\"}";
      if  (i != ArraySize(rates) - 1) str += ",";
   }
   
   return str += "]\0";
}

void sendJson(string market, const string& jsonData)
{
    string cookie = "";
    string headers;
    uchar payload[];
    uchar result[];
    int res;
    
    ResetLastError();

    StringToCharArray(jsonData, payload, CP_UTF8);  // Convert the JSON data to a character array using UTF-8 encoding

    headers = "Content-Type: application/json";  // Set JSON headers
    
    PrintFormat("POST %s", ENDPOINT + "/" + market);
    res = WebRequest("POST", ENDPOINT + "/" + market, cookie, headers, TIMEOUT, payload, ArraySize(payload) - 1, result, headers);
    
    if(res == -1)
    {
        Print("Error in WebRequest. Error code =", GetLastError());
    }
}

/* get market OHLCV data and save it to a file */
void writeFile(string market) {
   MqlRates rates[];
   string filename = market + ".json";
   
   if (!CopyRates(market, PERIOD_H1, 0, NBCANDLE + 1, rates)) {
      Print("Erreur lors de la récupération des données OHLCV!");
   }
   
   int filehandle = FileOpen(filename, FILE_WRITE | FILE_TXT);
   FileWriteString(filehandle, jsonEncode(rates));
   PrintFormat("write %s ", filename);
   
   FileClose(filehandle);
}

/* read OHLCV file */
string readFile(string market) {
   ResetLastError();
   int      filehandle = FileOpen(market + ".json", FILE_READ );
   string     str;
   
   if(filehandle != INVALID_HANDLE) {
      str = FileReadString(filehandle, int(FileSize(filehandle)));
      while(!FileIsEnding(filehandle)) {
      }
      FileClose(filehandle);
   } else {
      PrintFormat("Failed to open %s file, Error code = %d", market, GetLastError());
   }
   
   return str;
}

/* when the script start */
void OnStart() {
   for (int i = 0; i < ArraySize(MARKETS); i += 1) {
      writeFile(MARKETS[i]);
      string json = readFile(MARKETS[i]);
      
      sendJson(MARKETS[i], json);
   }
   Print("fin");
}

/* after each update */
void OnTick() {

}
