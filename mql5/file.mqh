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
      FileClose(filehandle);
   } else {
      PrintFormat("Failed to open %s file, Error code = %d", market, GetLastError());
   }
   
   return str;
}
