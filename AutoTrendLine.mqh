//+------------------------------------------------------------------+
//|                                                AutoTrendLine.mqh |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

enum ENUM_TREND_BREAK{

TREND_BREAK_NONE,
TREND_BREAK_ABOVE,
TREND_BREAK_BELOW


 };
 
 class CTrendLevel{
 
 
 private : string mlevelName;
 
 public :CTrendLevel(string levelName){SetLevelName(levelName);};
 ~CTrendLevel(){};//Destructor
 
 void SetLevelName(string levelName){mlevelName=levelName;};
 string GetLevelName(){return(mlevelName);}
  
ENUM_TREND_BREAK GetBreak(int index);


};


ENUM_TREND_BREAK CTrendLevel::GetBreak(int index){
if(ObjectFind(0,mlevelName)<0)return  TREND_BREAK_NONE;//no trend line has been found on the chart
double prevOpen=iOpen(Symbol(),Period(),index+1);


double prevClose=iClose(Symbol(),Period(),index+1);

double close=iClose(Symbol(),Period(),index);



datetime prevTime=iTime(Symbol(),Period(),index+1);

datetime time=iTime(Symbol(),Period(),index);


double prevValue=ObjectGetValueByTime(0,mlevelName,prevTime);

double value=ObjectGetValueByTime(0,mlevelName,time);
if(prevValue==0||value==0){return TREND_BREAK_NONE;}



if(prevOpen<prevValue&& prevClose<prevValue&&close>value){return TREND_BREAK_NONE;}
if(prevOpen<prevValue&&prevClose<prevValue&&close>value){return TREND_BREAK_ABOVE;}

if(prevOpen>prevValue&&prevClose>prevValue&&close>value){return TREND_BREAK_BELOW;}


return( TREND_BREAK_NONE);
}

input string InputTrendLevelName="noelTrendLine";//Name of trend line

//For running the test
input int InputStartBar=99;//Starting bar
input int InputBar =0;//End bar

