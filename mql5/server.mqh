/* send OHLCV data to the API */
void sendOHLCV(string market, const string& jsonData) {
    string cookie = "";
    string headers;
    uchar payload[];
    uchar result[];
    int res;
    
    ResetLastError();
    StringToCharArray(jsonData, payload, CP_UTF8);
    headers = "Content-Type: application/json";
    res = WebRequest("POST", ENDPOINT + "/" + market, cookie, headers, TIMEOUT, payload, ArraySize(payload), result, headers);
    
    if(res == -1) Print("Error in WebRequest. Error code =", GetLastError());
}

string getPredictions() {
   string cookie=NULL,headers;
   char   post[],result[];
    
    PrintFormat("GET %s", "http://localhost:3005/predict");
    
    int res = WebRequest(
        "GET", 
        ENDPOINT + "/predict", 
        cookie, 
        NULL, 
        TIMEOUT,
        post,
        0,
        result,
        headers
    );
    
    if (res == -1) {
        Print("Error in WebRequest. Error code =", GetLastError());
        return "";
    }
    
    return CharArrayToString(result);
}
