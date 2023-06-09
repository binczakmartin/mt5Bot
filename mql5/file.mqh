/* encode OHLCV data to JSON string */
string jsonEncode(MqlRates& rates[]) {
   string str = "[";
   
   for (int i = 0; i < ArraySize(rates); i += 1) {
      str += "{\"date\":\""   +  (string)(double)    rates[i].time          + "\",";
      str += "\"open\":\""    +  (string)(double)    rates[i].open          + "\",";
      str += "\"high\":\""    +  (string)(double)    rates[i].high          + "\",";
      str += "\"low\":\""     +  (string)(double)    rates[i].low           + "\",";
      str += "\"close\":\""   +  (string)(double)    rates[i].close         + "\",";
      str += "\"volume\":\""  +  (string)(double)    rates[i].tick_volume   + "\"}";
      str += ",";
   }
   
   str = StringSubstr(str, 0, StringLen(str)-1);
   return str += "]";
}

/* get market OHLCV data and save it to a file */
void writeFile(string market) {
   MqlRates rates[];
   string filename = market + ".json";
   
   if (!CopyRates(market, PERIOD_M30, 0, NBCANDLE + 1, rates)) {
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
   string    str;
   
   if(filehandle != INVALID_HANDLE) {
      str = FileReadString(filehandle, int(FileSize(filehandle)));
      FileClose(filehandle);
   } else {
      PrintFormat("Failed to open %s file, Error code = %d", market, GetLastError());
   }
   
   return str;
}
