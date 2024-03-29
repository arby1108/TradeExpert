
//+------------------------------------------------------------------+
//|                                                  TradeExpert.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright      "© Noel Martial Nguemechieu "
#property strict

#property  description "This bot trade generate signal and manage your positions"
#include <DiscordTelegram/Telegram.mqh>

  #include <stdlib.mqh>
#include <stderror.mqh>
string SYMBOLS[200]={"EURUSD","USDCAD","USDCHF","GBPUSD","USDJPY","AUDUSD","EURDKK","CADCHF","CHFJPY","EURAUD","USDDKK","AUDCAD","USDCNH","NZDSGD","NZDJPY","GBPNZD","EURCHF","EURJPY","CADJPY","AUDJPY","USDCHF","EURNZD","NZDUSD"} ;
   
CCOrder mytrade;
//--- enums
enum ENUM_BUTTONS
  {
   BUTT_BUY,
   BUTT_BUY_LIMIT,
   BUTT_BUY_STOP,
   BUTT_BUY_STOP_LIMIT,
   BUTT_CLOSE_BUY,
   BUTT_CLOSE_BUY2,
   BUTT_CLOSE_BUY_BY_SELL,
   BUTT_SELL,
   BUTT_SELL_LIMIT,
   BUTT_SELL_STOP,
   BUTT_SELL_STOP_LIMIT,
   BUTT_CLOSE_SELL,
   BUTT_CLOSE_SELL2,
   BUTT_CLOSE_SELL_BY_BUY,
   BUTT_DELETE_PENDING,
   BUTT_CLOSE_ALL,
   BUTT_PROFIT_WITHDRAWAL,
   BUTT_SET_STOP_LOSS,
   BUTT_SET_TAKE_PROFIT,
   BUTT_TRAILING_ALL
  };
#define TOTAL_BUTT   (20)
//--- structures
struct SDataButt
  {
   string      name;
   string      text;
  };

input const string  C ="";//;=======================    MARKET SELECTION  =========================";

input MARKET_SELECTION  MARKET=FOREX_MARKET;//Set Trading Market


input const string  E="";//;========================   TRADE  MODE  SETTING  =======================";
input TRADE_MODE TRADE_MODE_=ALERT_ONLY;//Trade Mode
input  ENUM_TIMEFRAMES TimeFrame= PERIOD_H1;//Timeframe 

enum Filteration
  {
   
   B1=1, //M5 < M30
   B2=2, //M5 < H1
   B3=3, //M5 < M30 + DOM by BULLVSBEAR®
   B4=4, //M5 < H1  + DOM by BULLVSBEAR®
  };
input             Filteration FILTER SELECTION=B1;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum TrendFilter
  {
   E1=1, //Relative Strength Index
   E2=2, //Stochastic_Old Technique
  };
  
 
input             TrendFilter TECHNIQUE=E1;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum Mode
  {
   C1=1, //Alert Only - Notis Sahaja
   C2=2, //Auto Trade - Perdagangan Automatis
  };
input             Mode MODE SELECTION=C1;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum MONEYMANGEMENT
  {
   D1=1, //Normal Style
   D2=2, //Martingale Style
   D3=3, //Hedging Style
   D4=4// Martingale Stepping
  };


input const string  D="";//______________TRADING  PARAMETERS____________";



input uint     InpDistance          =  50;   // Pending orders distance (points)
input uint     InpDistanceSL        =  50;   // StopLimit orders distance (points)
input uint     InpSlippage          =  0;    // Slippage in points
input double   InpWithdrawal        =  10;   // Withdrawal funds (in tester)
input uint     InpButtShiftX        =  60;   // Buttons X shift 
input uint     InpButtShiftY        =  30;   // Buttons Y shift 
input uint     InpTrailingStop      =  100;   // Trailing Stop (points)
input uint     InpTrailingStep      =  1;   // Trailing Step (points)
input uint     InpTrailingStart     =  0;    // Trailing Start (points)
input uint     InpStopLossModify    =  60;   // StopLoss for modification (points)
input uint     InpTakeProfitModify  =  60;   // TakeProfit for modification (points)

input int         InpTakeProfit                                         = 200;//Take profit
input int         InpStopLoss                                           = 200;//StopLoss
input int         High Spread Preventation                           = 50;//Set High Spread Preventation 
input int         Slippage Preventation                              = 30;//Set High Slippage Preventation 

input int         Maximum Per TradePool                              = 5;

int               Check Previous Bars                                = 1;
input int         Sell MaxOrder For This Pair                        = 1;
input int         Buy MaxOrder For This Pair                         = 1;
uint LotDigits=2; //initialized in OnInit
extern uint MagicNumber = 112403;//Set MagicNumber 
extern uint NextOpenTradeAfterHours = 2; //Next open trade after time
extern uint NextOpenTradeAfterTOD_Hour = 00; //Next open trade after time of the day
extern uint NextOpenTradeAfterTOD_Min = 23; //Next open trade after time of the day
datetime NextTradeTime = 0;
extern uint TOD_From_Hour = 04; //Time of the day (from hour)
extern uint TOD_From_Min = 00; //Time of the day (from min)
extern uint TOD_To_Hour = 03; //Time of the day (to hour)
extern uint TOD_To_Min = 15; //Time of the day (to min)
extern uint MaxTradeDurationDays = 3; //Maximum trade duration
extern uint PendingOrderExpirationHours = 0; //Pending order expiration
extern double DeleteOrderAtDistance = 0; //Delete order when too far from current price
extern uint MinTradeDurationDays = 1; //Minimum trade duration
extern double MM_PositionSizing = 10000;
extern double MaxSpread = 0;
extern uint MaxSlippage = 3; //Adjusted in OnInit
extern bool TradeMonday = true;
extern bool TradeTuesday = true;
extern bool TradeWednesday = true;
extern bool TradeThursday = true;
extern bool TradeFriday = true;
extern bool TradeSaturday = true;
extern bool TradeSunday = true;
extern double MaxSL = 0;
extern double MinSL = 0;
extern double MaxTP = 0;
extern double MinTP = 0;
extern double CloseAtPL = 0;
extern double PriceTooClose = 0;
 
string mytype;

//--- global variables

datetime timess[];
string actions;
double times[];


string macd,signal;
  double priceAsk,priceBid;


input bool        Debug                                              = true;

extern string                                                        ="";//ALERT OBJECTS SETTING
input bool        DrawFibo                                           = true;
input int         Arrow Code Buy                                     = 236;
input int         Arrow Code Sell                                    = 238;
input color       Colour Buy                                         = Blue;
input color       Colour Sell                                        = Red;
input bool        Hide Arrow BUY in ObjectList                       = false;
input bool        Hide Arrow SELL in ObjectList                      = false;
input ENUM_ALIGN_MODE Location                                       = ALIGN_RIGHT;
input int         Width                                              = 1080;
input int         Height                                             = 860;
//AutoTradeFeature


extern string                                                        ="";//BREAKEVEN-Set to false to disable;
input bool        BreakEven                                          = false;
input int         When Pip Was                                       = 15;
extern string     Then                                               = "?";
input int         Pip To Secure                                      = 5;

extern string                                                        ="";//PARTIAL CLOSE-THE FixedLotSize MUST BE LOGIC FOR DIVIDING BY 2-Set to false to disable;
input bool        Partial Close                                      = false;
input double      Pip To Partial                                     = 10;

extern string                                                        ="";//TRADE OBJECTS SETTING;
input int         Arrow Code Buy Trade                               = 108;
input int         Arrow Code Sell Trade                              = 108;
input color       Colour Buy Trade                                   = Blue;
input color       Colour Sell Trade                                  = Red;
input bool        Hide Arrow BUY Trade in ObjectList                 = false;
input bool        Hide Arrow SELL Trade in ObjectList                = false;

input const string F="";//____________________MONEY MANAGEMENT________________________";


input            MONEYMANGEMENT TRADE SELECTION=D1;


CCustomChat chats;
input double      FixedLotSize                                       = 0.01;//FixedLotSize 

input const string FF="";//_________________MARTINGALE FEATURE   _______________";

extern double MM_Martingale_Start_Lot =0.01;
extern double MM_Martingale_ProfitFactor = 2;
extern double MM_Martingale_LossFactor = 3;
extern int  MM_Martingale_RestartLosses =2;
extern int MM_Martingale_RestartProfits =5;
extern bool MM_Martingale_RestartProfit = true;
extern bool MM_Martingale_RestartLoss = true;



extern const string  FFF ="";//_______ MARTINGALE_STEPPING_SETTING_________";

extern double multiplier      = 2.0;  //Multiplier
extern double note    = 10; // Distance (pips) 
extern double pairglobalprofit= 8; //Take Profit (pips)
extern int    tradesperday    = 99; //Max Level Martingale
extern double Risk      = 2; //Level Risk
extern double Target    = 10000000.0; // Target Equity for Withdraw (USD) 
extern bool   UseVirtual        = True;// Use Virtual Take Profit
extern bool   timefilter        = false;// Time Filter
extern int    Start_Hour      = 23;// Start Hour (Broker Time)
extern int     Finish_Hour     = 8;// End Hour (Broker Time)



int ii=1;
extern string                                                        ="";//___________CHARTS SETTINGS___________";
bool              Set Chart Colors                                   = true;
input color       BackGround                                         = White;
input color       ForeGround                                         = Black;
input color       Bull Candle                                        = clrGold;
input color       Bear Candle                                        = Red;
input color       Bull Outline                                       = Black;
input color       Bear Outline                                       = Black;
//--- input variables
//--- global variables
CEngine        engine;
#ifdef __MQL5__
CTrade         trade;
#endif 
SDataButt      butt_data[TOTAL_BUTT];
string         prefix;
 double priceTarget=0; 

double   InpLots              = FixedLotSize;

 double  securetrade1=priceAsk*priceTarget/100;
  double  securetrade2=priceBid*priceTarget/100;

double         withdrawal=(InpWithdrawal<InpLots ? InpLots : InpWithdrawal);

uint           distance_pending;
uint           distance_stoplimit;
uint           slippage;
bool           trailing_on;
double         trailing_stop;
double         trailing_step;
uint           trailing_start;
uint           stoploss_to_modify;
uint           takeprofit_to_modify;

double lot=InpLots;
int time_signal;


bool TelegramPushNotification,TelegramPushNotificationWithPhoto;
double myPoint;


bool   MM        = false;                       

double _profit          = 8;
double globalprofit    = 8;
double maximaloss      = 0;
bool   openonnewcandle = false;
 double spacePips       = 100;
 int    spaceOrders     = 5;
 double spaceLots       = 0.03;
 double space1Pips      = 100;
 int    space1Orders    = 1;
 double space1Lots      = 0.05;
 double space2Pips      = 100;
 int    space2Orders    = 1;
 double space2Lots      = 0.07;
 double space3Pips      = 100;
 int    space3Orders    = 99;
 double space3Lots      = 0.09;
 int     magicbuy        = 1;
 string  buycomment      = "";
 int     magicsell       = 2;
 string  sellcomment     = "";
 int     Start_Minute    = 00;
 int     Finish_Minute   = 59;
 bool    smaParabolicEntry = false;
 int     cciperiod =     0;
 double  ccimax    =   100;
 double  ccimin    =  -100;
 bool    suspendtrades     = false;
 bool    closeallsellsnow  = false;
 bool    closeallbuysnow   = false;
 bool    closeallnow       = false;
int     DisplayX          = 0;
int     DisplayY          = 0;
int     fontSise          = 0;
string  fontName          = "";
color   Colour           = Yellow;
 
double totalprofit; 
bool   sellallowed=true;
bool   buyallowed=true;
bool   firebuy=true;
bool   firesell=true;
string stoptrading="0"; 
bool   validSetup=true;
string error;
int    DisplayCount      = 0;
bool    KeepTextOnTop     = False;
string    txts,txt1;
string    txt2="";
string    txt3="";
color col = ForestGreen;
int               Entry Arrow Offset                                 = 30;
bool              Set Copyright                                      = true;



//Internal EA parameters
double            SendLots;

bool              ShortTrading          = false;
bool              LongTrading           = false;
bool              ShortTradingPP        = false;
bool              LongTradingPP         = false;
bool              ShortTrading1st       = false;
bool              LongTrading1st        = false;
bool              LongTradingts261M5    = false;
bool              LongTradingts261M15   = false;
bool              LongTradingts261M30   = false;
bool              LongTradingts261H1    = false;
bool              ShortTradingts261M5   = false;
bool              ShortTradingts261M15  = false;
bool              ShortTradingts261M30  = false;
bool              ShortTradingts261H1   = false;
bool              AlertOnlyFactor       = false;
bool              AutoTradeFactor       = false;
bool              M5tillM30Factor       = false;
bool              M5tillH1Factor        = false;
bool              M5tillH1DOMFactor     = false;
bool              M5tillM30DOMFactor    = false;
bool              MartingaleFactor      = false;
bool              NormalFactor          = false;
bool              HedgeFactor           = false;
double            PIP                  = 0;

double            TP                   = 0;
double            SL                   = 0;
double            TS                   = 0;
int               Ticket               = 0;
int               BarsCnt              = 0;
datetime          TimeCnt              = 0;
int               EntryBars            = 0;
double            ASK                  = 0;
double            BID                  = 0;
int              DIGITS               = 0;
double            POINT                = 0;
string            SYMBOL               = _Symbol;
int               LOTDIGITS            = 2;
bool              BreakEvenOnce        = false;
datetime               TimeStamp            = PeriodSeconds();
datetime              NextSave             = PeriodSeconds();
bool              AlertCount           = false;
int bar;
datetime time_alert;

//Indicator parameters
// none
//Debugging parameters
static bool       EABlocked=true;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
CComment comment;
int OnInit(){


//--- Calling the function displays the list of enumeration constants in the journal 
//--- (the list is set in the strings 22 and 25 of the DELib.mqh file) for checking the constants validity
 
 
//##############################################TELEGRAM#####BOT CONTROL
//---
   run_mode=GetRunMode();

//--- stop working in tester
   if(run_mode!=RUN_LIVE)
   {
      PrintError(ERR_RUN_LIMITATION,InpLanguage);
      return(INIT_FAILED);
   }

   int y=40;
   if(ChartGetInteger(0,CHART_SHOW_ONE_CLICK))
      y=120;
   comment.Create("BotPanel",20,y);
   comment.SetColor(clrDimGray,clrGreen,220);

//--- set token
   init_error=bot.Token(TOKEN);
///--- set language
   bot.Language(InpLanguage);

//--- set filter
   bot.UserNameFilter(USERNAME);

//--- set templates
   bot.Templates(IndicatorList);

//--- set timer
   int timer_ms=3000;
   switch(InpUpdateMode)
   {
   case UPDATE_FAST:
      timer_ms=1000;
      break;
   case UPDATE_NORMAL:
      timer_ms=2000;
      break;
   case UPDATE_SLOW:
      timer_ms=3000;
      break;
   default:
      timer_ms=3000;
      break;
   };
   EventSetMillisecondTimer(timer_ms);
   
//--- done

 
 
 
   //EnumNumbersTest();

//--- Set EA global variables
   prefix=MQLInfoString(MQL_PROGRAM_NAME)+"_";
   for(int i=0;i<TOTAL_BUTT;i++)
     {
      butt_data[i].name=prefix+EnumToString((ENUM_BUTTONS)i);
      butt_data[i].text=EnumToButtText((ENUM_BUTTONS)i);
     }
   lot=NormalizeLot(Symbol(),fmax(InpLots,MinimumLots(Symbol())*2.0));

  

//--- Check and remove remaining EA graphical objects
   if(IsPresentObects(prefix))
      ObjectsDeleteAll(0,prefix);

//--- Create the button panel
   if(!CreateButtons(InpButtShiftX,InpButtShiftY))
      return INIT_FAILED;
//--- Set trailing activation button status
   ButtonState(butt_data[TOTAL_BUTT-1].name,trailing_on);

//--- Set CTrade trading class parameters
#ifdef __MQL5__
   trade.SetDeviationInPoints(slippage);
   trade.SetExpertMagicNumber(magic_number);
   trade.SetTypeFillingBySymbol(Symbol());
   trade.SetMarginMode();
   trade.LogLevel(LOG_LEVEL_NO);
#endif 
//--- Fast check of the account object
   CAccount*acc=new CAccount();
   if(acc!=NULL)
     {
      acc.PrintShort();
      acc.Print();
      delete acc;
     }


OnTimer();

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- Remove EA graphical objects by an object name prefix
   ObjectsDeleteAll(0,prefix);
   Comment("");
     //---TELEGRAM BOTCONTROL
   if(reason==REASON_CLOSE ||
         reason==REASON_PROGRAM ||
         reason==REASON_PARAMETERS ||
         reason==REASON_REMOVE ||
         reason==REASON_RECOMPILE ||
         reason==REASON_ACCOUNT ||
         reason==REASON_INITFAILED)
   {
      time_check=0;
      comment.Destroy();
   }

   EventKillTimer();
    
  
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
     Comment("BOT_NAME:"+bot.Name());

  bot.ForceReply();
    
   bot.ProcessMessages();
 bot.GetUpdates();
  if(STATUS){

  
       
  }else{
  Comment("YOUR CHANNEL IS NOT ACTIVATED");
  };
  
   
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
  OnTimer();
   if(MQLInfoInteger(MQL_TESTER))
      return;
   if(id==CHARTEVENT_OBJECT_CLICK && StringFind(sparam,"BUTT_")>0)
     {
      PressButtonEvents(sparam);
     }
//--- DoEasy library event
   if(id>=CHARTEVENT_CUSTOM)
     {
      OnDoEasyEvent(id,lparam,dparam,sparam);
     } 
  }
//+------------------------------------------------------------------+
//| Handling DoEasy library events                              	 |
//+------------------------------------------------------------------+
void OnDoEasyEvent(const int id,
                   const long &lparam,
                   const double &dparam,
                   const string &sparam)
  {
   int idx=id-CHARTEVENT_CUSTOM;
   string event="::"+string(idx);
   int digits=Digits();
//--- Handling trading events
   if(idx<TRADE_EVENTS_NEXT_CODE)
     {
      event=EnumToString((ENUM_TRADE_EVENT)ushort(idx));
      digits=(int)SymbolInfoInteger(sparam,SYMBOL_DIGITS);
     }
//--- Handling account events
   else if(idx<ACCOUNT_EVENTS_NEXT_CODE)
     {
      event=EnumToString((ENUM_ACCOUNT_EVENT)ushort(idx));
      digits=0;
      
      //--- if this is an equity increase
      if((ENUM_ACCOUNT_EVENT)idx==ACCOUNT_EVENT_EQUITY_INC)
        {
         Print(DFUN,sparam);
         //--- Close a position with the highest profit when the equity exceeds the value
         //--- specified in the CAccountsCollection::InitControlsParams() method for
         //--- the m_control_equity_inc variable tracking the equity growth by 15 units (by default)
         //--- AccountCollection file, InitControlsParams() method, string 1199
         
         //--- Get the list of all open positions
         CArrayObj* list_positions=engine.GetListMarketPosition();
         //--- Sort the list by profit considering commission and swap
         list_positions.Sort(SORT_BY_ORDER_PROFIT_FULL);
         //--- Get the position index with the highest profit
         int index=CSelect::FindOrderMax(list_positions,ORDER_PROP_PROFIT_FULL);
         if(index>WRONG_VALUE)
           {
            COrder* position=list_positions.At(index);
            if(position!=NULL)
              {
               //--- Get a ticket of a position with the highest profit and close the position by a ticket
               #ifdef __MQL5__
                  trade.PositionClose(position.Ticket());
               #else 
                  PositionClose(position.Ticket(),position.Volume());
               #endif 
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Return the flag of a prefixed object presence                    |
//+------------------------------------------------------------------+
bool IsPresentObects(const string object_prefix)
  {
   for(int i=ObjectsTotal(0,0)-1;i>=0;i--)
      if(StringFind(ObjectName(0,i,0),object_prefix)>WRONG_VALUE)
         return true;
   return false;
  }
//+------------------------------------------------------------------+
//| Tracking the buttons' status                                     |
//+------------------------------------------------------------------+
void PressButtonsControl(void)
  {
   int total=ObjectsTotal(0,0);
   for(int i=0;i<total;i++)
     {
      string obj_name=ObjectName(0,i);
      if(StringFind(obj_name,prefix+"BUTT_")<0)
         continue;
      PressButtonEvents(obj_name);
     }
  }
//+------------------------------------------------------------------+
//| Create the buttons panel                                         |
//+------------------------------------------------------------------+
bool CreateButtons(const int shift_x=30,const int shift_y=0)
  {
   int h=20,w=70,offset=2;
   int cx=offset+shift_x,cy=offset+shift_y+(h+1)*(TOTAL_BUTT/2)+3*h+1;
   int x=cx,y=cy;
   int shift=0;
   for(int i=0;i<TOTAL_BUTT;i++)
     {
      x=x+(i==7 ? w+2 : 0);
      if(i==TOTAL_BUTT-6) x=cx;
      y=(cy-(i-(i>6 ? 7 : 0))*(h+1));
      if(!ButtonCreate(butt_data[i].name,x,y,(i<TOTAL_BUTT-6 ? w : w*2+2),h,butt_data[i].text,(i<4 ? clrGreen : i>6 && i<11 ? clrRed : clrBlue)))
        {
         Alert(TextByLanguage("Не удалось создать кнопку \"","Could not create button \""),butt_data[i].text);
         return false;
        }
     }
   ChartRedraw(0);
   return true;
  }
//+------------------------------------------------------------------+
//| Create the button                                                |
//+------------------------------------------------------------------+
bool ButtonCreate(const string name,const int x,const int y,const int w,const int h,const string text,const color clr,const string font="Calibri",const int font_size=8)
  {
   if(ObjectFind(0,name)<0)
     {
      if(!ObjectCreate(0,name,OBJ_BUTTON,0,0,0)) 
        { 
         Print(DFUN,TextByLanguage("не удалось создать кнопку! Код ошибки=","Could not create button! Error code="),GetLastError()); 
         return false; 
        } 
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
      ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
      ObjectSetInteger(0,name,OBJPROP_XSIZE,w);
      ObjectSetInteger(0,name,OBJPROP_YSIZE,h);
      ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_LOWER);
      ObjectSetInteger(0,name,OBJPROP_ANCHOR,ANCHOR_LEFT_LOWER);
      ObjectSetInteger(0,name,OBJPROP_FONTSIZE,font_size);
      ObjectSetString(0,name,OBJPROP_FONT,font);
      ObjectSetString(0,name,OBJPROP_TEXT,text);
      ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
      ObjectSetString(0,name,OBJPROP_TOOLTIP,"\n");
      ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,clrGray);
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//| Return the button status                                         |
//+------------------------------------------------------------------+
bool ButtonState(const string name)
  {
   return (bool)ObjectGetInteger(0,name,OBJPROP_STATE);
  }
//+------------------------------------------------------------------+
//| Set the button status                                   		 |
//+------------------------------------------------------------------+
void ButtonState(const string name,const bool state)
  {
   ObjectSetInteger(0,name,OBJPROP_STATE,state);
   if(name==butt_data[TOTAL_BUTT-1].name)
     {
      if(state)
         ObjectSetInteger(0,name,OBJPROP_BGCOLOR,C'220,255,240');
      else
         ObjectSetInteger(0,name,OBJPROP_BGCOLOR,C'240,240,240');
     }
  }
     
     
string CheckMySignal(int i){


//Did it make an up arraow on candle 1}
double UpArrow=iCustom(SYMBOLS[i],TimeFrame,IndicatorName,0,1);
//print (up arrow value, uparrow);
if(UpArrow!=EMPTY_VALUE){
return "BUY";

}

//Did it make a  down  arraow on candle 1}

double DownArrow=iCustom(SYMBOLS[i],TimeFrame,IndicatorName,1,1);
//print (up arrow value, DownArrow);
if(DownArrow!=EMPTY_VALUE){
 return "SELL";

}

 return "NO TRADING Now";
}
//+------------------------------------------------------------------+
//| Transform enumeration into the button text                       |
//+------------------------------------------------------------------+
string EnumToButtText(const ENUM_BUTTONS member)
  {
   string txt=StringSubstr(EnumToString(member),5);
   StringToLower(txt);
   StringReplace(txt,"set_take_profit","Set TakeProfit");
   StringReplace(txt,"set_stop_loss","Set StopLoss");
   StringReplace(txt,"trailing_all","Trailing All");
   StringReplace(txt,"buy","Buy");
   StringReplace(txt,"sell","Sell");
   StringReplace(txt,"_limit"," Limit");
   StringReplace(txt,"_stop"," Stop");
   StringReplace(txt,"close_","Close ");
   StringReplace(txt,"2"," 1/2");
   StringReplace(txt,"_by_"," by ");
   StringReplace(txt,"profit_","Profit ");
   StringReplace(txt,"delete_","Delete ");
   return txt;
  }
//+------------------------------------------------------------------+
//| Handle pressing the buttons                                      |
//+------------------------------------------------------------------+
void PressButtonEvents(const string button_name)
  {
   //--- Convert button name into its string ID
   string button=StringSubstr(button_name,StringLen(prefix));
   //--- If the button is pressed
   if(ButtonState(button_name))
     {
      //--- If the BUTT_BUY button is pressed: Open Buy position
      if(button==EnumToString(BUTT_BUY))
        {
         //--- Get the correct StopLoss and TakeProfit prices relative to StopLevel
        SL=CorrectStopLoss(Symbol(),ORDER_TYPE_BUY,0,InpStopLoss);
         TP=CorrectTakeProfit(Symbol(),ORDER_TYPE_BUY,0,InpTakeProfit);
         //--- Open Buy position
         #ifdef __MQL5__
            trade.Buy(mytrade.Martingale_Trade_Size(lot),Symbol(),0,SL,TP);
         #else 
            Buy(lot,Symbol(),MagicNumber,SL,TP);
         #endif 
        }
      //--- If the BUTT_BUY_LIMIT button is pressed: Place BuyLimit
      else if(button==EnumToString(BUTT_BUY_LIMIT))
        {
         //--- Get correct order placement relative to StopLevel
         double price_set=CorrectPricePending(Symbol(),ORDER_TYPE_BUY_LIMIT,distance_pending);
         priceAsk=price_set;
         //--- Get correct StopLoss and TakeProfit prices relative to the order placement level considering StopLevel
        SL=CorrectStopLoss(Symbol(),ORDER_TYPE_BUY_LIMIT,price_set,InpStopLoss);
         TP=CorrectTakeProfit(Symbol(),ORDER_TYPE_BUY_LIMIT,price_set,InpTakeProfit);
         //--- Set BuyLimit order
         #ifdef __MQL5__
            trade.BuyLimit(lot,price_set,Symbol(),SL,TP);
         #else 
            BuyLimit(mytrade.Martingale_Trade_Size(lot),price_set,Symbol(),MagicNumber,SL,TP);
         #endif 
        }
      //--- If the BUTT_BUY_STOP button is pressed: Set BuyStop
      else if(button==EnumToString(BUTT_BUY_STOP) ||CheckMySignal(ii)=="BUY")
        {
         //--- Get correct order placement relative to StopLevel
         double price_set=CorrectPricePending(Symbol(),ORDER_TYPE_BUY_STOP,distance_pending);
         //--- Get correct StopLoss and TakeProfit prices relative to the order placement level considering StopLevel
          SL=CorrectStopLoss(Symbol(),ORDER_TYPE_BUY_STOP,price_set,InpStopLoss);
         TP=CorrectTakeProfit(Symbol(),ORDER_TYPE_BUY_STOP,price_set,InpTakeProfit);
         //--- Set BuyStop order
         #ifdef __MQL5__
            trade.BuyStop(lot,price_set,Symbol(),SL,TP);
         #else 
            BuyStop(lot,price_set,Symbol(),MagicNumber,SL,TP);
         #endif 
        }
      //--- If the BUTT_BUY_STOP_LIMIT button is pressed: Set BuyStopLimit
      else if(button==EnumToString(BUTT_BUY_STOP_LIMIT))
        {
         //--- Get the correct BuyStop order placement price relative to StopLevel
         double price_set_stop=CorrectPricePending(Symbol(),ORDER_TYPE_BUY_STOP,distance_pending);
         //--- Calculate BuyLimit order price relative to BuyStop level considering StopLevel
         double price_set_limit=CorrectPricePending(Symbol(),ORDER_TYPE_BUY_LIMIT,distance_stoplimit,price_set_stop);
         //--- Get correct StopLoss and TakeProfit prices relative to the order placement level considering StopLevel
        SL=CorrectStopLoss(Symbol(),ORDER_TYPE_BUY_STOP,price_set_limit,InpStopLoss);
         TP=CorrectTakeProfit(Symbol(),ORDER_TYPE_BUY_STOP,price_set_limit,InpTakeProfit);
         //--- Set BuyStopLimit order
         #ifdef __MQL5__
            trade.OrderOpen(Symbol(),ORDER_TYPE_BUY_STOP_LIMIT,lot,price_set_limit,price_set_stop,sl,tp);
         #else 
            
         #endif 
        }
      //--- If the BUTT_SELL button is pressed: Open Sell position
      else if(button==EnumToString(BUTT_SELL))
        {
         //--- Get the correct StopLoss and TakeProfit prices relative to StopLevel
         SL=CorrectStopLoss(Symbol(),ORDER_TYPE_SELL,0,InpStopLoss);
         TP=CorrectTakeProfit(Symbol(),ORDER_TYPE_SELL,0,InpTakeProfit);
         //--- Open Sell position
         #ifdef __MQL5__
            trade.Sell(lot,Symbol(),0,SL,TP);
         #else 
            Sell(lot,Symbol(),MagicNumber,SL,TP);
         #endif 
        }
      //--- If the BUTT_SELL_LIMIT button is pressed: Set SellLimit
      else if(button==EnumToString(BUTT_SELL_LIMIT))
        {
         //--- Get correct order placement relative to StopLevel
         double price_set=CorrectPricePending(Symbol(),ORDER_TYPE_SELL_LIMIT,distance_pending);
         priceBid=price_set;
         //--- Get correct StopLoss and TakeProfit prices relative to the order placement level considering StopLevel
         SL=CorrectStopLoss(Symbol(),ORDER_TYPE_SELL_LIMIT,price_set,InpStopLoss);
        TP=CorrectTakeProfit(Symbol(),ORDER_TYPE_SELL_LIMIT,price_set,InpTakeProfit);
         //--- Set SellLimit order
         #ifdef __MQL5__
            trade.SellLimit(lot,price_set,Symbol(),SL,TP);
         #else 
            SellLimit(lot,price_set,Symbol(),MagicNumber,SL,TP);
         #endif 
        }
      //--- If the BUTT_SELL_STOP button is pressed: Set SellStop
      else if(button==EnumToString(BUTT_SELL_STOP)||CheckMySignal(ii)=="SELL")
        {
         //--- Get correct order placement relative to StopLevel
         double price_set=CorrectPricePending(Symbol(),ORDER_TYPE_SELL_STOP,distance_pending);
         //--- Get correct StopLoss and TakeProfit prices relative to the order placement level considering StopLevel
         SL=CorrectStopLoss(Symbol(),ORDER_TYPE_SELL_STOP,price_set,InpStopLoss);
         TP=CorrectTakeProfit(Symbol(),ORDER_TYPE_SELL_STOP,price_set,InpTakeProfit);
         //--- Set SellStop order
         #ifdef __MQL5__
            trade.SellStop(lot,price_set,Symbol(),SL,TP);
         #else 
            SellStop(lot,price_set,Symbol(),MagicNumber,SL,TP);
         #endif 
        }
      //--- If the BUTT_SELL_STOP_LIMIT button is pressed: Set SellStopLimit
      else if(button==EnumToString(BUTT_SELL_STOP_LIMIT))
        {
         //--- Get the correct SellStop order price relative to StopLevel
         double price_set_stop=CorrectPricePending(Symbol(),ORDER_TYPE_SELL_STOP,distance_pending);
         //--- Calculate SellLimit order price relative to SellStop level considering StopLevel
         double price_set_limit=CorrectPricePending(Symbol(),ORDER_TYPE_SELL_LIMIT,distance_stoplimit,price_set_stop);
         //--- Get correct StopLoss and TakeProfit prices relative to the order placement level considering StopLevel
         SL=CorrectStopLoss(Symbol(),ORDER_TYPE_SELL_STOP,price_set_limit,InpStopLoss);
        TP=CorrectTakeProfit(Symbol(),ORDER_TYPE_SELL_STOP,price_set_limit,InpTakeProfit);
         //--- Set SellStopLimit order
         #ifdef __MQL5__
            trade.OrderOpen(Symbol(),ORDER_TYPE_SELL_STOP_LIMIT,lot,price_set_limit,price_set_stop,SL,TP);
         #else 
            
         #endif 
        }
      //--- If the BUTT_CLOSE_BUY button is pressed: Close Buy with the maximum profit
      else if(button==EnumToString(BUTT_CLOSE_BUY))
        {
         //-- Get the list of all open positions
         CArrayObj* list=engine.GetListMarketPosition();
         //--- Select only Buy positions from the list
         list=CSelect::ByOrderProperty(list,ORDER_PROP_TYPE,POSITION_TYPE_BUY,EQUAL);
         //--- Sort the list by profit considering commission and swap
         list.Sort(SORT_BY_ORDER_PROFIT_FULL);
         //--- Get the index of the Buy position with the maximum profit
         int index=CSelect::FindOrderMax(list,ORDER_PROP_PROFIT_FULL);
         if(index>WRONG_VALUE)
           {
            COrder* position=list.At(index);
            if(position!=NULL)
              {
               //--- Get the Buy position ticket and close the position by the ticket
               #ifdef __MQL5__
                  trade.PositionClose(position.Ticket());
               #else 
                  PositionClose(position.Ticket(),position.Volume());
               #endif 
              }
           }
        }
      //--- If the BUTT_CLOSE_BUY2 button is pressed: Close the half of the Buy with the maximum profit
      else if(button==EnumToString(BUTT_CLOSE_BUY2))
        {
         //--- Get the list of all open positions
         CArrayObj* list=engine.GetListMarketPosition();
         //--- Select only Buy positions from the list
         list=CSelect::ByOrderProperty(list,ORDER_PROP_TYPE,POSITION_TYPE_BUY,EQUAL);
         //--- Sort the list by profit considering commission and swap
         list.Sort(SORT_BY_ORDER_PROFIT_FULL);
         //--- Get the index of the Buy position with the maximum profit
         int index=CSelect::FindOrderMax(list,ORDER_PROP_PROFIT_FULL);
         if(index>WRONG_VALUE)
           {
            COrder* position=list.At(index);
            if(position!=NULL)
              {
               //--- Calculate the closed volume and close the half of the Buy position by the ticket
               if(engine.IsHedge())
                 {
                  #ifdef __MQL5__
                     trade.PositionClosePartial(position.Ticket(),NormalizeLot(position.Symbol(),position.Volume()/2.0));
                  #else 
                     PositionClose(position.Ticket(),NormalizeLot(position.Symbol(),position.Volume()/2.0));
                  #endif 
                 }
               else
                 {
                  #ifdef __MQL5__
                     trade.Sell(NormalizeLot(position.Symbol(),position.Volume()/2.0));
                  #endif 
                 }
              }
           }
        }
      //--- If the BUTT_CLOSE_BUY_BY_SELL button is pressed: Close Buy with the maximum profit by the opposite Sell with the maximum profit
      else if(button==EnumToString(BUTT_CLOSE_BUY_BY_SELL))
        {
         //--- Get the list of all open positions
         CArrayObj* list_buy=engine.GetListMarketPosition();
         //--- Select only Buy positions from the list
         list_buy=CSelect::ByOrderProperty(list_buy,ORDER_PROP_TYPE,POSITION_TYPE_BUY,EQUAL);
         //--- Sort the list by profit considering commission and swap
         list_buy.Sort(SORT_BY_ORDER_PROFIT_FULL);
         //--- Get the index of the Buy position with the maximum profit
         int index_buy=CSelect::FindOrderMax(list_buy,ORDER_PROP_PROFIT_FULL);
         //--- Get the list of all open positions
         CArrayObj* list_sell=engine.GetListMarketPosition();
         //--- Select only Sell positions from the list
         list_sell=CSelect::ByOrderProperty(list_sell,ORDER_PROP_TYPE,POSITION_TYPE_SELL,EQUAL);
         //--- Sort the list by profit considering commission and swap
         list_sell.Sort(SORT_BY_ORDER_PROFIT_FULL);
         //--- Get the index of the Sell position with the maximum profit
         int index_sell=CSelect::FindOrderMax(list_sell,ORDER_PROP_PROFIT_FULL);
         if(index_buy>WRONG_VALUE && index_sell>WRONG_VALUE)
           {
            //--- Select the Buy position with the maximum profit
            COrder* position_buy=list_buy.At(index_buy);
            //--- Select the Sell position with the maximum profit
            COrder* position_sell=list_sell.At(index_sell);
            if(position_buy!=NULL && position_sell!=NULL)
              {
               //--- Close the Buy position by the opposite Sell one
               #ifdef __MQL5__
                  trade.PositionCloseBy(position_buy.Ticket(),position_sell.Ticket());
               #else 
                  PositionCloseBy(position_buy.Ticket(),position_sell.Ticket());
               #endif 
              }
           }
        }
      //--- If the BUTT_CLOSE_SELL button is pressed: Close Sell with the maximum profit
      else if(button==EnumToString(BUTT_CLOSE_SELL))
        {
         //--- Get the list of all open positions
         CArrayObj* list=engine.GetListMarketPosition();
         //--- Select only Sell positions from the list
         list=CSelect::ByOrderProperty(list,ORDER_PROP_TYPE,POSITION_TYPE_SELL,EQUAL);
         //--- Sort the list by profit considering commission and swap
         list.Sort(SORT_BY_ORDER_PROFIT_FULL);
         //--- Get the index of the Sell position with the maximum profit
         int index=CSelect::FindOrderMax(list,ORDER_PROP_PROFIT_FULL);
         if(index>WRONG_VALUE)
           {
            COrder* position=list.At(index);
            if(position!=NULL)
              {
               //--- Get the Sell position ticket and close the position by the ticket
               #ifdef __MQL5__
                  trade.PositionClose(position.Ticket());
               #else 
                  PositionClose(position.Ticket());
               #endif 
              }
           }
        }
      //--- If the BUTT_CLOSE_SELL2 button is pressed: Close the half of the Sell with the maximum profit
      else if(button==EnumToString(BUTT_CLOSE_SELL2))
        {
         //--- Get the list of all open positions
         CArrayObj* list=engine.GetListMarketPosition();
         //--- Select only Sell positions from the list
         list=CSelect::ByOrderProperty(list,ORDER_PROP_TYPE,POSITION_TYPE_SELL,EQUAL);
         //--- Sort the list by profit considering commission and swap
         list.Sort(SORT_BY_ORDER_PROFIT_FULL);
         //--- Get the index of the Sell position with the maximum profit
         int index=CSelect::FindOrderMax(list,ORDER_PROP_PROFIT_FULL);
         if(index>WRONG_VALUE)
           {
            COrder* position=list.At(index);
            if(position!=NULL)
              {
               //--- Calculate the closed volume and close the half of the Sell position by the ticket
               if(engine.IsHedge())
                 {
                  #ifdef __MQL5__
                     trade.PositionClosePartial(position.Ticket(),NormalizeLot(position.Symbol(),position.Volume()/2.0));
                  #else 
                     PositionClose(position.Ticket(),NormalizeLot(position.Symbol(),position.Volume()/2.0));
                  #endif 
                 }
               else
                 {
                  #ifdef __MQL5__
                     trade.Buy(NormalizeLot(position.Symbol(),position.Volume()/2.0));
                  #endif 
                 }
              }
           }
        }
      //--- If the BUTT_CLOSE_SELL_BY_BUY button is pressed: Close Sell with the maximum profit by the opposite Buy with the maximum profit
      else if(button==EnumToString(BUTT_CLOSE_SELL_BY_BUY))
        {
         //--- Get the list of all open positions
         CArrayObj* list_sell=engine.GetListMarketPosition();
         //--- Select only Sell positions from the list
         list_sell=CSelect::ByOrderProperty(list_sell,ORDER_PROP_TYPE,POSITION_TYPE_SELL,EQUAL);
         //--- Sort the list by profit considering commission and swap
         list_sell.Sort(SORT_BY_ORDER_PROFIT_FULL);
         //--- Get the index of the Sell position with the maximum profit
         int index_sell=CSelect::FindOrderMax(list_sell,ORDER_PROP_PROFIT_FULL);
         //--- Get the list of all open positions
         CArrayObj* list_buy=engine.GetListMarketPosition();
         //--- Select only Buy positions from the list
         list_buy=CSelect::ByOrderProperty(list_buy,ORDER_PROP_TYPE,POSITION_TYPE_BUY,EQUAL);
         //--- Sort the list by profit considering commission and swap
         list_buy.Sort(SORT_BY_ORDER_PROFIT_FULL);
         //--- Get the index of the Buy position with the maximum profit
         int index_buy=CSelect::FindOrderMax(list_buy,ORDER_PROP_PROFIT_FULL);
         if(index_sell>WRONG_VALUE && index_buy>WRONG_VALUE)
           {
            //--- Select the Sell position with the maximum profit
            COrder* position_sell=list_sell.At(index_sell);
            //--- Select the Buy position with the maximum profit
            COrder* position_buy=list_buy.At(index_buy);
            if(position_sell!=NULL && position_buy!=NULL)
              {
               //--- Close the Sell position by the opposite Buy one
               #ifdef __MQL5__
                  trade.PositionCloseBy(position_sell.Ticket(),position_buy.Ticket());
               #else 
                  PositionCloseBy(position_sell.Ticket(),position_buy.Ticket());
               #endif 
              }
           }
        }
      //--- If the BUTT_CLOSE_ALL is pressed: Close all positions starting with the one with the least profit
      else if(button==EnumToString(BUTT_CLOSE_ALL))
        {
         //--- Get the list of all open positions
         CArrayObj* list=engine.GetListMarketPosition();
         if(list!=NULL)
           {
            //--- Sort the list by profit considering commission and swap
            list.Sort(SORT_BY_ORDER_PROFIT_FULL);
            int total=list.Total();
            //--- In the loop from the position with the least profit
            for(int i=0;i<total;i++)
              {
               COrder* position=list.At(i);
               if(position==NULL)
                  continue;
               //--- close each position by its ticket
               #ifdef __MQL5__
                  trade.PositionClose(position.Ticket());
               #else 
                  PositionClose(position.Ticket(),position.Volume());
               #endif 
              }
           }
        }
      //--- If the BUTT_DELETE_PENDING button is pressed: Remove the first pending order
      else if(button==EnumToString(BUTT_DELETE_PENDING))
        {
         //--- Get the list of all orders
         CArrayObj* list=engine.GetListMarketPendings();
         if(list!=NULL)
           {
            //--- Sort the list by placement time
            list.Sort(SORT_BY_ORDER_TIME_OPEN);
            int total=list.Total();
            //--- In the loop from the position with the most amount of time
            for(int i=total-1;i>=0;i--)
              {
               COrder* order=list.At(i);
               if(order==NULL)
                  continue;
               //--- delete the order by its ticket
               #ifdef __MQL5__
                  trade.OrderDelete(order.Ticket());
               #else 
                  PendingOrderDelete(order.Ticket());
               #endif 
              }
           }
        }
      //--- If the BUTT_PROFIT_WITHDRAWAL button is pressed: Withdraw funds from the account
      if(button==EnumToString(BUTT_PROFIT_WITHDRAWAL))
        {
         //--- If the program is launched in the tester
         if(MQLInfoInteger(MQL_TESTER))
           {
            //--- Emulate funds withdrawal
            TesterWithdrawal(withdrawal);
           }
        }
      //--- If the BUTT_SET_STOP_LOSS button is pressed: Place StopLoss to all orders and positions where it is not present
      if(button==EnumToString(BUTT_SET_STOP_LOSS))
        {
         SetStopLoss();
        }
      //--- If the BUTT_SET_TAKE_PROFIT button is pressed: Place TakeProfit to all orders and positions where it is not present
      if(button==EnumToString(BUTT_SET_TAKE_PROFIT))
        {
         SetTakeProfit();
        }
      //--- Wait for 1/10 of a second
      Sleep(100);
      //--- "Unpress" the button (if this is not a trailing button)
      if(button!=EnumToString(BUTT_TRAILING_ALL))
         ButtonState(button_name,false);
      //--- If the BUTT_TRAILING_ALL button is pressed
      else
        {
         //--- Set the color of the active button
         ButtonState(button_name,true);
         trailing_on=true;
        }
      //--- re-draw the chart
      ChartRedraw();
     }
   //--- Return the inactive button color (if this is a trailing button)
   else if(button==EnumToString(BUTT_TRAILING_ALL))
     {
      ButtonState(button_name,false);
      trailing_on=false;
      //--- re-draw the chart
      ChartRedraw();
     }
  }
//+------------------------------------------------------------------+
//| Set StopLoss to all orders and positions                         |
//+------------------------------------------------------------------+
void SetStopLoss(void)
  {
   if(stoploss_to_modify==0)
      return;
//--- Set StopLoss to all positions where it is absent
   CArrayObj* list=engine.GetListMarketPosition();
   list=CSelect::ByOrderProperty(list,ORDER_PROP_SL,0,EQUAL);
   if(list==NULL)
      return;
   int total=list.Total();
   for(int i=total-1;i>=0;i--)
     {
      COrder* position=list.At(i);
      if(position==NULL)
         continue;
      double sl=CorrectStopLoss(position.Symbol(),position.TypeByDirection(),0,stoploss_to_modify);
      #ifdef __MQL5__
         trade.PositionModify(position.Ticket(),sl,position.TakeProfit());
      #else 
         PositionModify(position.Ticket(),sl,position.TakeProfit());
      #endif 
     }
//--- Set StopLoss to all pending orders where it is absent
   list=engine.GetListMarketPendings();
   list=CSelect::ByOrderProperty(list,ORDER_PROP_SL,0,EQUAL);
   if(list==NULL)
      return;
   total=list.Total();
   for(int i=total-1;i>=0;i--)
     {
      COrder* order=list.At(i);
      if(order==NULL)
         continue;
      double sl=CorrectStopLoss(order.Symbol(),(ENUM_ORDER_TYPE)order.TypeOrder(),order.PriceOpen(),stoploss_to_modify);
      #ifdef __MQL5__
         trade.OrderModify(order.Ticket(),order.PriceOpen(),sl,order.TakeProfit(),trade.RequestTypeTime(),trade.RequestExpiration(),order.PriceStopLimit());
      #else 
         PendingOrderModify(order.Ticket(),order.PriceOpen(),sl,order.TakeProfit());
      #endif 
     }
  }
//+------------------------------------------------------------------+
//| Set TakeProfit to all orders and positions                       |
//+------------------------------------------------------------------+
void SetTakeProfit(void)
  {
   if(takeprofit_to_modify==0)
      return;
//--- Set TakeProfit to all positions where it is absent
   CArrayObj* list=engine.GetListMarketPosition();
   list=CSelect::ByOrderProperty(list,ORDER_PROP_TP,0,EQUAL);
   if(list==NULL)
      return;
   int total=list.Total();
   for(int i=total-1;i>=0;i--)
     {
      COrder* position=list.At(i);
      if(position==NULL)
         continue;
      double tp=CorrectTakeProfit(position.Symbol(),position.TypeByDirection(),0,takeprofit_to_modify);
      #ifdef __MQL5__
         trade.PositionModify(position.Ticket(),position.StopLoss(),tp);
      #else 
         PositionModify(position.Ticket(),position.StopLoss(),tp);
      #endif 
     }
//--- Set TakeProfit to all pending orders where it is absent
   list=engine.GetListMarketPendings();
   list=CSelect::ByOrderProperty(list,ORDER_PROP_TP,0,EQUAL);
   if(list==NULL)
      return;
   total=list.Total();
   for(int i=total-1;i>=0;i--)
     {
      COrder* order=list.At(i);
      if(order==NULL)
         continue;
      double tp=CorrectTakeProfit(order.Symbol(),(ENUM_ORDER_TYPE)order.TypeOrder(),order.PriceOpen(),takeprofit_to_modify);
      #ifdef __MQL5__
         trade.OrderModify(order.Ticket(),order.PriceOpen(),order.StopLoss(),tp,trade.RequestTypeTime(),trade.RequestExpiration(),order.PriceStopLimit());
      #else 
         PendingOrderModify(order.Ticket(),order.PriceOpen(),order.StopLoss(),tp);
      #endif 
     }
  }
//+------------------------------------------------------------------+
//| Trailing stop of a position with the maximum profit              |
//+------------------------------------------------------------------+
void TrailingPositions(void)
  {
   MqlTick tick;
   if(!SymbolInfoTick(Symbol(),tick))
      return;
   double stop_level=StopLevel(Symbol(),2)*Point();
   //--- Get the list of all open positions
   CArrayObj* list=engine.GetListMarketPosition();
   //--- Select only Buy positions from the list
   CArrayObj* list_buy=CSelect::ByOrderProperty(list,ORDER_PROP_TYPE,POSITION_TYPE_BUY,EQUAL);
   //--- Sort the list by profit considering commission and swap
   list_buy.Sort(SORT_BY_ORDER_PROFIT_FULL);
   //--- Get the index of the Buy position with the maximum profit
   int index_buy=CSelect::FindOrderMax(list_buy,ORDER_PROP_PROFIT_FULL);
   if(index_buy>WRONG_VALUE)
     {
      COrder* buy=list_buy.At(index_buy);
      if(buy!=NULL)
        {
         //--- Calculate the new StopLoss
         double sl=NormalizeDouble(tick.bid-trailing_stop,Digits());
         //--- If the price and the StopLevel based on it are higher than the new StopLoss (the distance by StopLevel is maintained)
         if(tick.bid-stop_level>sl) 
           {
            //--- If the new StopLoss level exceeds the trailing step based on the current StopLoss
            if(buy.StopLoss()+trailing_step<sl)
              {
               //--- If we trail at any profit or position profit in points exceeds the trailing start, modify StopLoss
               if(trailing_start==0 || buy.ProfitInPoints()>(int)trailing_start)
                 {
                  #ifdef __MQL5__
                     trade.PositionModify(buy.Ticket(),sl,buy.TakeProfit());
                  #else 
                     PositionModify(buy.Ticket(),sl,buy.TakeProfit());
                  #endif 
                 }
              }
           }
        }
     }
   //--- Select only Sell positions from the list
   CArrayObj* list_sell=CSelect::ByOrderProperty(list,ORDER_PROP_TYPE,POSITION_TYPE_SELL,EQUAL);
   //--- Sort the list by profit considering commission and swap
   list_sell.Sort(SORT_BY_ORDER_PROFIT_FULL);
   //--- Get the index of the Sell position with the maximum profit
   int index_sell=CSelect::FindOrderMax(list_sell,ORDER_PROP_PROFIT_FULL);
   if(index_sell>WRONG_VALUE)
     {
      COrder* sell=list_sell.At(index_sell);
      if(sell!=NULL)
        {
         //--- Calculate the new StopLoss
         double sl=NormalizeDouble(tick.ask+trailing_stop,Digits());
         //--- If the price and StopLevel based on it are below the new StopLoss (the distance by StopLevel is maintained)
         if(tick.ask+stop_level<sl) 
           {
            //--- If the new StopLoss level is below the trailing step based on the current StopLoss or a position has no StopLoss
            if(sell.StopLoss()-trailing_step>sl || sell.StopLoss()==0)
              {
               //--- If we trail at any profit or position profit in points exceeds the trailing start, modify StopLoss
               if(trailing_start==0 || sell.ProfitInPoints()>(int)trailing_start)
                 {
                  #ifdef __MQL5__
                     trade.PositionModify(sell.Ticket(),sl,sell.TakeProfit());
                  #else 
                     PositionModify(sell.Ticket(),sl,sell.TakeProfit());
                  #endif 
                 }
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Trailing the farthest pending orders                             |
//+------------------------------------------------------------------+
void TrailingOrders(void)
  {
   MqlTick tick;
   if(!SymbolInfoTick(Symbol(),tick))
      return;
   double stop_level=StopLevel(Symbol(),2)*Point();
//--- Get the list of all placed orders
   CArrayObj* list=engine.GetListMarketPendings();
//--- Select only Buy orders from the list
   CArrayObj* list_buy=CSelect::ByOrderProperty(list,ORDER_PROP_DIRECTION,ORDER_TYPE_BUY,EQUAL);
   //--- Sort the list by distance from the price in points (by profit in points)
   list_buy.Sort(SORT_BY_ORDER_PROFIT_PT);
   //--- Get the index of the Buy order with the greatest distance
   int index_buy=CSelect::FindOrderMax(list_buy,ORDER_PROP_PROFIT_PT);
   if(index_buy>WRONG_VALUE)
     {
      COrder* buy=list_buy.At(index_buy);
      if(buy!=NULL)
        {
         //--- If the order is below the price (BuyLimit) and it should be "elevated" following the price
         if(buy.TypeOrder()==ORDER_TYPE_BUY_LIMIT)
           {
            //--- Calculate the new order price and stop levels based on it
            double price=NormalizeDouble(tick.ask-trailing_stop,Digits());
            double sl=(buy.StopLoss()>0 ? NormalizeDouble(price-(buy.PriceOpen()-buy.StopLoss()),Digits()) : 0);
            double tp=(buy.TakeProfit()>0 ? NormalizeDouble(price+(buy.TakeProfit()-buy.PriceOpen()),Digits()) : 0);
            //--- If the calculated price is below the StopLevel distance based on Ask order price (the distance by StopLevel is maintained)
            if(price<tick.ask-stop_level) 
              {
               //--- If the calculated price exceeds the trailing step based on the order placement price, modify the order price
               if(price>buy.PriceOpen()+trailing_step)
                 {
                  #ifdef __MQL5__
                     trade.OrderModify(buy.Ticket(),price,sl,tp,trade.RequestTypeTime(),trade.RequestExpiration(),buy.PriceStopLimit());
                  #else 
                     PendingOrderModify(buy.Ticket(),price,sl,tp);
                  #endif 
                 }
              }
           }
         //--- If the order exceeds the price (BuyStop and BuyStopLimit), and it should be "decreased" following the price
         else
           {
            //--- Calculate the new order price and stop levels based on it
            double price=NormalizeDouble(tick.ask+trailing_stop,Digits());
            double sl=(buy.StopLoss()>0 ? NormalizeDouble(price-(buy.PriceOpen()-buy.StopLoss()),Digits()) : 0);
            double tp=(buy.TakeProfit()>0 ? NormalizeDouble(price+(buy.TakeProfit()-buy.PriceOpen()),Digits()) : 0);
            //--- If the calculated price exceeds the StopLevel based on Ask order price (the distance by StopLevel is maintained)
            if(price>tick.ask+stop_level) 
              {
               //--- If the calculated price is lower than the trailing step based on order price, modify the order price
               if(price<buy.PriceOpen()-trailing_step)
                 {
                  #ifdef __MQL5__
                     trade.OrderModify(buy.Ticket(),price,sl,tp,trade.RequestTypeTime(),trade.RequestExpiration(),(buy.PriceStopLimit()>0 ? price-distance_stoplimit*Point() : 0));
                  #else 
                     PendingOrderModify(buy.Ticket(),price,sl,tp);
                  #endif 
                 }
              }
           }
        }
     }
//--- Select only Sell order from the list
   CArrayObj* list_sell=CSelect::ByOrderProperty(list,ORDER_PROP_DIRECTION,ORDER_TYPE_SELL,EQUAL);
   //--- Sort the list by distance from the price in points (by profit in points)
   list_sell.Sort(SORT_BY_ORDER_PROFIT_PT);
   //--- Get the index of the Sell order having the greatest distance
   int index_sell=CSelect::FindOrderMax(list_sell,ORDER_PROP_PROFIT_PT);
   if(index_sell>WRONG_VALUE)
     {
      COrder* sell=list_sell.At(index_sell);
      if(sell!=NULL)
        {
         //--- If the order exceeds the price (SellLimit), and it needs to be "decreased" following the price
         if(sell.TypeOrder()==ORDER_TYPE_SELL_LIMIT)
           {
            //--- Calculate the new order price and stop levels based on it
            double price=NormalizeDouble(tick.bid+trailing_stop,Digits());
            double sl=(sell.StopLoss()>0 ? NormalizeDouble(price+(sell.StopLoss()-sell.PriceOpen()),Digits()) : 0);
            double tp=(sell.TakeProfit()>0 ? NormalizeDouble(price-(sell.PriceOpen()-sell.TakeProfit()),Digits()) : 0);
            //--- If the calculated price exceeds the StopLevel distance based on the Bid order price (the distance by StopLevel is maintained)
            if(price>tick.bid+stop_level) 
              {
               //--- If the calculated price is lower than the trailing step based on order price, modify the order price
               if(price<sell.PriceOpen()-trailing_step)
                 {
                  #ifdef __MQL5__
                     trade.OrderModify(sell.Ticket(),price,sl,tp,trade.RequestTypeTime(),trade.RequestExpiration(),sell.PriceStopLimit());
                  #else 
                     PendingOrderModify(sell.Ticket(),price,sl,tp);
                  #endif 
                 }
              }
           }
         //--- If the order is below the price (SellStop and SellStopLimit), and it should be "elevated" following the price
         else
           {
            //--- Calculate the new order price and stop levels based on it
            double price=NormalizeDouble(tick.bid-trailing_stop,Digits());
            double sl=(sell.StopLoss()>0 ? NormalizeDouble(price+(sell.StopLoss()-sell.PriceOpen()),Digits()) : 0);
            double tp=(sell.TakeProfit()>0 ? NormalizeDouble(price-(sell.PriceOpen()-sell.TakeProfit()),Digits()) : 0);
            //--- If the calculated price is below the StopLevel distance based on the Bid order price (the distance by StopLevel is maintained)
            if(price<tick.bid-stop_level) 
              {
               //--- If the calculated price exceeds the trailing step based on the order placement price, modify the order price
               if(price>sell.PriceOpen()+trailing_step)
                 {
                  #ifdef __MQL5__
                     trade.OrderModify(sell.Ticket(),price,sl,tp,trade.RequestTypeTime(),trade.RequestExpiration(),(sell.PriceStopLimit()>0 ? price+distance_stoplimit*Point() : 0));
                  #else 
                     PendingOrderModify(sell.Ticket(),price,sl,tp);
                  #endif 
                 }
              }
           }
        }
     }
  }
//---------------------------------------------------
bool EqualInt(double variable,const int value)
  {
   return bool(int(variable)==value);
  }
//---------------------------------------------------


//----------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
  
 OnTimer();
 if(ii<100){ii++;}else if(ii==99){ii--;};
 
 
 
 
 DrawRegressionBuy(" regression",Time[0],0 ,Time[100],Ask);
  

 if(ii<=10){

     
  if(  CheckMySignal(ii)=="BUY"){
              bot. SendChatAction(msgs.chat_id,ACTION_OPEN_BUY);
        
    SL=CorrectStopLoss(SYMBOLS[ii],ORDER_TYPE_BUY,0,InpStopLoss);
          TP=CorrectTakeProfit(SYMBOLS[ii],ORDER_TYPE_BUY,0,InpTakeProfit);
      priceTarget=(2*TP-SL)/100;
         actions="BUY";
         string msg=StringFormat("SIGNAL:%s\xF4E3\nSYMBOL: %s\nTIMEFRAME: %s\nTYPE:%s\nPRICE :%2.4f\nTIME:%s\nEntry price:%2.4f\nTARGET:%2.4f\nTP :%2.4f\nSL:%2.4f\n",
                                 IndicatorName,SYMBOLS[ii],(string)TimeFrame,(string)actions,Bid,(string)TimeCurrent(),Ask, priceTarget,TP,SL);
        
      bot.SendMessageToChannel(CHANNEL_NAME,msg);
     bot.SendScreenShotToChannel(CHANNEL_NAME,SYMBOLS[ii],TimeFrame,IndicatorName);
     
   
    Comment("Size"+(string)mytrade.MM_Size());
    
    
    
  }else if(CheckMySignal(ii)=="SELL"){ 
  
   SL=CorrectStopLoss(SYMBOLS[ii],ORDER_TYPE_SELL,0,InpStopLoss);
          TP=CorrectTakeProfit(SYMBOLS[ii],ORDER_TYPE_SELL,0,InpTakeProfit);
      
   priceTarget=(2*TP-SL)/100;
    
        
  actions="SELL";
                       string    msg=StringFormat("SIGNAL:%s\xF4E3\nSYMBOL: %s\nTIMEFRAME: %s\nTYPE:%s \nPRICE :%2.4f\nTIME:%s\nEntry price:%2.4f\nTARGET:%2.4f\nTP :%2.4f\nSL:%2.4f\n",
                                 IndicatorName,SYMBOLS[ii],(string)TimeFrame,(string)actions,Ask,(string)TimeCurrent(),Bid, priceTarget,TP,SL);   
      bot. SendChatAction(msgs.chat_id,ACTION_OPEN_SELL);
      
     
       bot.SendMessageToChannel(CHANNEL_NAME,actions);
     bot.SendScreenShotToChannel(CHANNEL_NAME,SYMBOLS[ii],TimeFrame,IndicatorName);
  
            SellStop(mytrade.MM_Size(),Bid,SYMBOLS[ii],MagicNumber,SL,TP,"SELL NOW",2);     
        Sell( mytrade.MM_Size(),SYMBOLS[ii],MagicNumber,SL,TP,"SELL NOW",2);     

  }else{
  //trade signal send
             bot. SendChatAction(msgs.chat_id,ACTION_NO_TRADE_NOW);
                      
    actions="No trade Signal now!";
  
      bot.SendMessageToChannel(CHANNEL_NAME,actions);
    
    }
   mytrade.setOrder_MagicNumber(MagicNumber); 
   mytrade.setOrder_Slippage(Slippage Preventation);
   mytrade.setOrder_StopLoss(SL);
   mytrade.setOrder_TakeProfit(TP);
   
   mytrade.setOrder_Trailing_Stop_Loss(trailing_on);
    mytrade.setOrder_Command(OP_BUYSTOP);
mytrade.setMM_Martingale_LossFactor(MM_Martingale_LossFactor); //set loss factor value

mytrade.setMM_Martingale_ProfitFactor(MM_Martingale_ProfitFactor);//set profitfactot value
mytrade.setMM_Martingale_Start(MM_Martingale_Start_Lot);//set //starting lot value

mytrade.setMM_Martingale_RestartLoss(MM_Martingale_RestartLoss);//set staaarting stop loss value
mytrade.setMM_Martingale_RestartLosses(MM_Martingale_RestartLosses);//set restart losses 

mytrade.setMM_Martingale_RestartProfit(MM_Martingale_RestartProfit); //set restart profit



   
mytrade.setOrder_Lot(InpLots);
mytrade.setOrder_MagicNumber(MagicNumber);
mytrade.setOrder_Comment("@TradeExpert Market BUY Order executed at "+(string)BID +"Time :"+(string)TimeDay(TimeCurrent()));
mytrade.setOrder_Command(OP_SELL);
mytrade.setOrder_Symbol(SYMBOLS[ii]);
mytrade.setOrder_Color(clrRed);
mytrade.setOrder_Slippage(slippage);

mytrade.setOrder_StopLoss(SL);
mytrade.setOrder_TakeProfit(TP);



if(mytrade.geOrderLoss()==0 ) {
         SendLots=MM_Martingale_Start_Lot*MM_Martingale_Start_Lot;
        }else{ //return martingale trade size according to settings
if(OrderLots()==mytrade.Martingale_Trade_Size(MM_Martingale_Start_Lot) ){
SendLots=mytrade.Martingale_Trade_Size(2*MM_Martingale_Start_Lot);
}else{
 
SendLots=mytrade.Martingale_Trade_Size(MM_Martingale_Start_Lot*3);
}
 }

    if( CheckMySignal( ii)=="BUY"){
       mytrade.DeleteByDuration(700);
    bot.SendChatAction(msgs.chat_id,ACTION_OPEN_BUY);
  
     
    mytrade.setOrder_Command(OP_BUYSTOP);
      bot.SendChatAction(msgs.chat_id,ACTION_OPEN_BUY);

    mytrade.SendOrder(OP_BUYSTOP);
    }else if(CheckMySignal(ii)=="SELL"){
;mytrade.setOrder_Comment("@TradeExpert Market SELL Order executed at "+(string)BID +"Time :"+(string)TimeDay(TimeCurrent()));

        mytrade.DeleteByDuration(700);
    mytrade.setOrder_Command(OP_SELLSTOP);
      bot.SendChatAction(msgs.chat_id,ACTION_OPEN_SELL);

     mytrade.SendOrder(OP_SELLSTOP);
  
    }else{
    
    bot.SendMessageToChannel(CHANNEL_NAME, "NO TRADING"+ SYMBOLS[ii]);
    };
 }
 



//Refresh Rates
   GetRates(SYMBOLS[ii]);
  
//Martigale feature
if(TRADE SELECTION== D2)

{
mytrade.setMM_Martingale_LossFactor(MM_Martingale_LossFactor); //set loss factor value

mytrade.setMM_Martingale_ProfitFactor(MM_Martingale_ProfitFactor);//set profitfactot value
mytrade.setMM_Martingale_Start(MM_Martingale_Start_Lot);//set //starting lot value

mytrade.setMM_Martingale_RestartLoss(MM_Martingale_RestartLoss);//set staaarting stop loss value
mytrade.setMM_Martingale_RestartLosses(MM_Martingale_RestartLosses);//set restart losses 

mytrade.setMM_Martingale_RestartProfit(MM_Martingale_RestartProfit); //set restart profit

if(mytrade.geOrderLoss()==0 ) {
         SendLots=MM_Martingale_Start_Lot*MM_Martingale_Start_Lot;
        }else{ //return martingale trade size according to settings
if(OrderLots()==mytrade.Martingale_Trade_Size(MM_Martingale_Start_Lot) ){
SendLots=mytrade.Martingale_Trade_Size(2*MM_Martingale_Start_Lot);
}else{
 
SendLots=mytrade.Martingale_Trade_Size(MM_Martingale_Start_Lot*3);
}
 }


}else if (TRADE SELECTION==D4){

if (!validSetup) 
   {
      DisplayErrors();
      return;
   }
   
   int  ticketBuyOrder       =  GetTicketOfLargestBuyOrder();
   int  ticketSellOrder      =  GetTicketOfLargestSellOrder();
   bool isNewBar             =  IsNewBar();
   int  totalTradesDoneToday =  TradesToday();
   int  index;
   
   ShowStatus();
   
   if (GlobalVariableGet(stoptrading) == 1 && OrdersTotal() == 0 && CheckTradingTime() == true)
   {
      GlobalVariableSet(stoptrading,0);  
   }
   
   if (!smaParabolicEntry)
   {
      if (cciperiod == 0)
      {
         firesell = true;
         firebuy  = true;  
      } 
   }
   
   // determine entry based on SMA/parabolic
   if (smaParabolicEntry)
   {
      if (isNewBar==true)
      {
         firebuy  = true;
         firesell = true; 
         double ima  = iMA(NULL, 0, 0, 0, MODE_LWMA, PRICE_WEIGHTED, 0);
         double isar = iMA(NULL, 0, 0, 0, MODE_LWMA, PRICE_WEIGHTED, 0);
         if(isar < ima)
         {
            firesell = true;
            firebuy = true;
         }
         
         if( isar > ima) 
         {
            firesell = true;
            firebuy = true;
         }
      }
   }
   
   // determine entry based on CCI
   if (cciperiod > 0 && isNewBar == true)
   {
      firebuy  = true;
      firesell = true;
      double cci = iCCI(SYMBOLS[ii], 0, cciperiod, PRICE_TYPICAL, 0);
      
      if(sellallowed && cci < ccimin) 
      {
         firesell = true;
         sellallowed = true; 

      }
      if(buyallowed  && cci > ccimax) 
      {
         firebuy = true;
         buyallowed = true; 
      }
      
      if (cci < ccimax && cci > ccimin)
      {
         buyallowed  = true;
         sellallowed = true;
      }
   }
   
   if (tradesperday > totalTradesDoneToday && CheckTradingTime() && ticketBuyOrder==0 && suspendtrades==false && firebuy && closeallnow==false && GlobalVariableGet(stoptrading)==0)
   {
     index = OrderSend (SYMBOLS[ii],OP_BUY, GetLotSize() , Ask , 3, 0, 0, buycomment, magicbuy, 0, Blue); 
     if (index >= 0)
     {
         firebuy = true; 
     }
   }         

   if ((openonnewcandle == 1 && isNewBar == true && ticketBuyOrder != 0)|| (openonnewcandle == 0 && ticketBuyOrder != 0))
   {
      if ( OrderSelect(ticketBuyOrder, SELECT_BY_TICKET))
      {
         double orderLots  = OrderLots();
         double orderPrice = OrderOpenPrice(); 
         if( Ask <= orderPrice - spacePips * Point() && GetBuyOrderCount() < spaceOrders)
         {
            if (multiplier  > 0) 
            {
               index = OrderSend (SYMBOLS[ii], OP_BUY, NormalizeDouble(orderLots * multiplier, 2), Ask, 3, 0, 0, buycomment, magicbuy, 0, Blue); 
            }
            else if (multiplier == 0) 
            {
              index = OrderSend (SYMBOLS[ii], OP_BUY, lot, Ask, 3, 0, 0, buycomment, magicbuy, 0, Blue);
            }
         }  
         
         else if( Ask <= orderPrice - space1Pips * Point() && GetBuyOrderCount() <= (spaceOrders + space1Orders-1) && GetBuyOrderCount() >= spaceOrders)
         {
           if (multiplier  > 0) 
            {
               index = OrderSend (SYMBOLS[ii], OP_BUY, NormalizeDouble(OrderLots() * multiplier, 2), Ask, 3, 0, 0, buycomment, magicbuy, 0, Blue); 
            }
            else if (multiplier == 0) 
            {
               index = OrderSend (SYMBOLS[ii], OP_BUY, lot, Ask, 3, 0, 0, buycomment, magicbuy, 0, Blue);
            }
         }  
         
         else if( Ask <= orderPrice - space2Pips * Point()&& GetBuyOrderCount() <= (space2Orders + space1Orders + spaceOrders-1) && GetBuyOrderCount() > (spaceOrders + space1Orders-1))
         {
           if (multiplier  > 0) 
            {
               index = OrderSend (SYMBOLS[ii], OP_BUY, NormalizeDouble(OrderLots() * multiplier, 2), Ask, 3, 0, 0, buycomment, magicbuy, 0, Blue); 
            }
            else if (multiplier == 0) 
            {
               index = OrderSend (SYMBOLS[ii], OP_BUY,space2Lots, Ask, 3, 0, 0, buycomment, magicbuy, 0, Blue);
             }
         }  
         
         else if( Ask <= orderPrice - space3Pips * Point() && GetBuyOrderCount() <= (space3Orders + space2Orders + space1Orders + spaceOrders) && GetBuyOrderCount() > (spaceOrders + space1Orders + space2Orders-1))
         {
           if (multiplier  > 0) 
            {
               index = OrderSend (SYMBOLS[ii], OP_BUY, NormalizeDouble(OrderLots() * multiplier, 2), Ask, 3, 0, 0, buycomment, magicbuy, 0, Blue); 
            }
            else if (multiplier == 0) 
            {
               index = OrderSend (SYMBOLS[ii], OP_BUY, space3Lots, Ask, 3, 0, 0, buycomment, magicbuy, 0, Blue);
            }
         }  
      }
   }
    
   // --------------------------------------------
   // sell orders
   // --------------------------------------------
   totalTradesDoneToday = TradesToday();
   if (tradesperday > totalTradesDoneToday && CheckTradingTime() == true && ticketSellOrder == 0 && suspendtrades == false && firesell == true && closeallnow == false && GlobalVariableGet(stoptrading) == 0)
   {
     index = OrderSend (SYMBOLS[ii], OP_SELL, mytrade.Martingale_Trade_Size(lot), Bid, 3, 0, 0, sellcomment, magicsell, 0, Red);  
     if (index >= 0)
     {
         firesell = false;
     }
   }

   // manage sell order
   if ((openonnewcandle == 1 && isNewBar==true && ticketSellOrder !=0 )|| (openonnewcandle == 0 && ticketSellOrder != 0))
   {
      if ( OrderSelect(ticketSellOrder, SELECT_BY_TICKET))
      {
         double orderLots  = OrderLots();
         double orderPrice = OrderOpenPrice(); 
         if( Bid >= orderPrice + spacePips * Point() && GetSellOrderCount() < spaceOrders)
         {
           if (multiplier  > 0) 
            {
               index = OrderSend(SYMBOLS[ii], OP_SELL, NormalizeDouble(orderLots * multiplier, 2), Bid, 3, 0, 0, sellcomment, magicsell, 0, Red); 
            }
            else if (multiplier == 0)
            {
                index = OrderSend(SYMBOLS[ii], OP_SELL, spaceLots, Bid, 3, 0, 0, sellcomment, magicsell, 0, Red);
            }
         } 
         else if( Bid >= orderPrice + space1Pips * Point() && GetSellOrderCount() <= (spaceOrders + space1Orders - 1) && GetSellOrderCount() >= spaceOrders)      
         { 
            if (multiplier > 0) 
            {
               index = OrderSend(SYMBOLS[ii], OP_SELL, NormalizeDouble(OrderLots() * multiplier, 2), Bid, 3, 0, 0, sellcomment, magicsell, 0, Red); 
            }
            else if (multiplier == 0) 
            {
               index = OrderSend(SYMBOLS[ii], OP_SELL, lot,Bid, 3, 0, 0, sellcomment, magicsell ,0, Red);
            }
         } 
         else if( Bid >= orderPrice + lot * Point() && GetSellOrderCount() <= (space2Orders + space1Orders + spaceOrders - 1) && GetSellOrderCount() > (spaceOrders + space1Orders-1))     
         {
           if (multiplier > 0) 
            {
               index = OrderSend(SYMBOLS[ii],OP_SELL, NormalizeDouble(orderLots * multiplier, 2), Bid, 3, 0, 0, sellcomment, magicsell, 0, Red);  
            }
            else if (multiplier == 0) 
            {
               index = OrderSend(SYMBOLS[ii],OP_SELL, lot, Bid, 3, 0, 0, sellcomment, magicsell, 0, Red);
            }
         } 
         else if( Bid >= orderPrice + lot * Point() && GetSellOrderCount() <= (space3Orders + space2Orders + space1Orders + spaceOrders) && GetSellOrderCount() > (spaceOrders + space1Orders + space2Orders-1))     
         {
           if (multiplier  > 0) 
            {
               index = OrderSend(SYMBOLS[ii],OP_SELL, NormalizeDouble(OrderLots() * multiplier, 2), Bid, 3, 0, 0, sellcomment, magicsell, 0, Red); 
            }
            else if (multiplier == 0) 
            {
               index = OrderSend(SYMBOLS[ii],OP_SELL, lot, Bid, 3, 0, 0, sellcomment, magicsell, 0, Red);
            }
         } 
      }
   } 
   
   double profitBuyOrders=0;
   for(int k=OrdersTotal()-1; k >=0; k--)
   {
      if ( OrderSelect(k,SELECT_BY_POS))
      {
         if (Symbol()==OrderSymbol() && OrderType()==OP_BUY && OrderMagicNumber() == magicbuy)
         {
            profitBuyOrders = profitBuyOrders + OrderProfit() + OrderSwap() + OrderCommission();
         }
      }
   }

   if ((_profit > 0 && profitBuyOrders >= _profit) || closeallbuysnow == true)
   {
      CloseAllBuyOrders();
      firebuy = false;
   }  
   
   
   double profitSellOrders=0;
   for(int j=OrdersTotal()-1; j>=0; j--)
   {
      if (OrderSelect(j,SELECT_BY_POS))
      { 
         if (Symbol() == OrderSymbol() && OrderType()==OP_SELL && OrderMagicNumber() == magicsell)
         {
            profitSellOrders = profitSellOrders + OrderProfit() + OrderSwap() + OrderCommission();
         }
      }
   }
   
   if ((_profit > 0 && profitSellOrders >= _profit) || closeallsellsnow == true)
   {
      CloseAllSellOrders();
      firesell = true;

   }  
    
   if (pairglobalprofit> 0  && profitBuyOrders + profitSellOrders >= pairglobalprofit)
   {
      CloseAllSellOrders();
      CloseAllBuyOrders();
      firebuy=true;
      firesell=true;    
   }

   double totalglobalprofit = TotalProfit();
   if((globalprofit > 0 && totalglobalprofit >= globalprofit) || (maximaloss < 0 && totalglobalprofit <= maximaloss))
   {
      GlobalVariableSet(stoptrading, 1);
      CloseAllOrders();
      firebuy  = true;
      firesell = true;
   }


}else{

 SendLots=FixedLotSize;//return fixed lot for hedging style or normal style
 
 if(OrderLots()==SendLots){SendLots=OrderLots()+0.001;};
}


   
      
      if(SendLots>MarketInfo(SYMBOLS[ii],MODE_MAXLOT)){
      
         SendLots--;
     }
   CheckOpenOrdersSell();
   CheckOpenOrdersBuy();
   CheckForEntry();
   if(TECHNIQUE==E2)
     {
      CheckStochts261m5();
      CheckStochts261m15();
      CheckStochts261m30();
      CheckStochts261h1();
     }
   if(TECHNIQUE==E1)
     {
      CheckRSIts261m5();
      CheckRSIts261m15();
      CheckRSIts261m30();
      CheckRSIts261h1();
     }
     
     
     
     
     
   AlertOnly();
   M5tillM30();
   M5tillM30DOM();
   AutoTrade();
   M5tillH1();
   M5tillH1DOM();
   Martingale();
   NormalTrade();
   HedgeTrade();
   if(Partial Close)
      Partialclose();
//Check and correct trailing SL
   if(InpTrailingStop!=0)
      CheckOrdersTrailing();
//Check new bars
   if(iBars(SYMBOLS[ii],Period())!=BarsCnt || iTime(SYMBOLS[ii],Period(),1)!=TimeCnt)
      OnBar();
//Check Breakeven
   if(BreakEven)
      CheckBreakEven();
   if(Set Chart Colors)
      ChartColorSet();
   if(Set Copyright)
      CopyRightlogo();    
     
  
  
  
  //autotrade end
  
  
  
  
     
  }//end ontick function



//+------------------------------------------------------------------+
int GetBuyOrderCount()
{
   int count=0;

   // find all open orders of today
   for (int k = OrdersTotal();k >=0 ;k--)
   {  
      if (OrderSelect(k, SELECT_BY_POS))
      {
         if (OrderType()==OP_BUY && OrderSymbol() == SYMBOLS[ii] && OrderMagicNumber() == magicbuy) 
         {
             count=count+1;
         }
      }
   }
   return count;
}

//+------------------------------------------------------------------+
int GetSellOrderCount()
{
   int count=0;

   // find all open orders of today
   for (int k = OrdersTotal(); k >=0 ;k--)
   {  
      if (OrderSelect(k, SELECT_BY_POS))
      {
         if (OrderType() == OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == magicsell) 
         {
            count=count+1;
         }
      }
   }
   return count;
}
 

//+------------------------------------------------------------------+
// GetTicketOfLargestBuyOrder()
// returns the ticket of the largest open buy order 
//+------------------------------------------------------------------+

int GetTicketOfLargestBuyOrder()
{
   double maxLots=0;
   int    orderTicketNr=0;

   for (int i=0;i < OrdersTotal();i++)
   {
      if ( OrderSelect(i,SELECT_BY_POS)) 
      {
         if( OrderType()==OP_BUY && OrderSymbol() == SYMBOLS[ii] && OrderMagicNumber()==magicbuy)
         {
            
            double orderLots = OrderLots()*2;  
            if (orderLots >= maxLots) 
            {
               maxLots-= OrderLots(); 
               orderTicketNr = OrderTicket();
            }   
         } 
      } 
   }
   return orderTicketNr;
}


//+------------------------------------------------------------------+
// GetTicketOfLargestSellOrder()
// returns the ticket of the largest open sell order 
//+------------------------------------------------------------------+
int GetTicketOfLargestSellOrder()
{
   double maxLots=0;
   int orderTicketNr=0;

   for (int l=0;l<=OrdersTotal();l++)
   {
      if ( OrderSelect(l,SELECT_BY_POS) )
      {
         if(OrderType() == OP_SELL && OrderSymbol() ==SYMBOLS[ii] && OrderMagicNumber() == magicsell)
         {
            double orderLots = OrderLots();  
            if (orderLots >= maxLots) 
            {
               maxLots = orderLots; 
               orderTicketNr = OrderTicket();
            }   
         }
      }  
   }
   return orderTicketNr;
}


//+------------------------------------------------------------------+
// CloseAllBuyOrders()
// closes all open buy orders
//+------------------------------------------------------------------+
void CloseAllBuyOrders()
{
   for (int m=OrdersTotal(); m>=0; m--)
   {
      if ( OrderSelect(m, SELECT_BY_POS))
      {
         if(OrderType() == OP_BUY && OrderSymbol() == SYMBOLS[ii] && OrderMagicNumber() == magicbuy)
         {
            RefreshRates();
            bool success = OrderClose(OrderTicket(), OrderLots(), Bid, 0, Blue);
         }
      }
    }
}


//+------------------------------------------------------------------+
// CloseAllSellOrders()
// closes all open sell orders
//+------------------------------------------------------------------+
void CloseAllSellOrders()
{
   for (int h=OrdersTotal();h>=0;h--)
   {
      if ( OrderSelect(h,SELECT_BY_POS) )
      {
         if(OrderType() == OP_SELL && OrderSymbol() == SYMBOLS[ii] && OrderMagicNumber() == magicsell)
         {
            RefreshRates();
            bool success =OrderClose(OrderTicket(), OrderLots(), Ask, 0, Red);
         }
      }
   }
}


//+------------------------------------------------------------------+
// CloseAllOrders()
// closes all orders
//+------------------------------------------------------------------+
void CloseAllOrders()
{
   CloseAllBuyOrders();
   CloseAllSellOrders();
}


//+------------------------------------------------------------------+
// TotalProfit()
// returns the total profit for all open orders
//+------------------------------------------------------------------+
double TotalProfit()
{
   double totalProfit = 0;
   for (int j=OrdersTotal();j >= 0; j--)
   {
      if( OrderSelect(j,SELECT_BY_POS))
      {
         if(OrderSymbol() == SYMBOLS[ii])
         {
            if (OrderMagicNumber() == magicsell || OrderMagicNumber() == magicbuy)
            {
               RefreshRates();
         
               totalProfit = totalProfit + OrderProfit() + OrderSwap() + OrderCommission();
            }
         }
      }      
   }
   return totalProfit;
}


//+------------------------------------------------------------------+
// IsNewBar()
// returns if new bar has started
//+------------------------------------------------------------------+
bool IsNewBar()
{
   static datetime time = Time[0];
   if(Time[0] > time)
   {
      time = Time[0]; //newbar, update time
      return (true);
   } 
   return(false);
}

//+------------------------------------------------------------------+
// CheckTradingTime()
// returns true if we are allowed to trade
//+------------------------------------------------------------------+
bool CheckTradingTime()
{
   int min  = TimeMinute( TimeCurrent() );
   int hour = TimeHour( TimeCurrent() );
   
   // check if we can trade from 00:00 - 24:00
   if (Start_Hour == 0 && Finish_Hour == 24)
   {
      if (Start_Minute==0 && Finish_Minute==0)
      {
         // yes then return true
         return true; 
      } 
   } 
   
   if (Start_Hour > Finish_Hour) 
   {
      return(true);
   } 
    
   // suppose we're allowed to trade from 14:15 - 19:30
   
   // 1) check if hour is < 14 or hour > 19
   if ( hour < Start_Hour || hour > Finish_Hour ) 
   {   
      // if so then we are not allowed to trade
      return false;
   }
   
   // if hour is 14, then check if minute < 15
   if ( hour == Start_Hour && min < Start_Minute )
   {
      // if so then we are not allowed to trade
      return false;
   } 
   
   // if hour is 19, then check  minute > 30
   if ( hour == Finish_Hour && min > Finish_Minute )
   {
      // if so then we are not allowed to trade
      return false;
   }
   return true;
 }
   
   
//--------------------------------------------------------------------------------

// TradesToday()
// return total number of trades done today (closed and still open)
//--------------------------------------------------------------------------------
int TradesToday()
{
   int count=0;

   // find all open orders of today
   for (int k = OrdersTotal();k >=0 ;k--)
   {  
      if (OrderSelect(k,SELECT_BY_POS))
      {
         if (OrderSymbol() ==SYMBOLS[ii] )
         {
             if(OrderLots() == lot)
             {
                  if (OrderMagicNumber() == magicbuy || OrderMagicNumber() == magicsell) 
                  {
                     if( TimeDay(OrderOpenTime()) == TimeDay(TimeCurrent()))
                     { 
                        count=count+1;
                     }
                  }
             }
         }
      }
   }
   
   // find all closed orders of today
   for (int l=OrdersHistoryTotal();l >= 0;l--)
   {
      if(OrderSelect(l, SELECT_BY_POS,MODE_HISTORY))
      {
         if (OrderSymbol() == SYMBOLS[ii] )
         {
             if(OrderLots() == InpLots)
             {
               if (OrderMagicNumber() != magicbuy && OrderMagicNumber() !=magicsell) 
               {
                  if(OrdersHistoryTotal() != 0 && TimeDay(OrderOpenTime()) == TimeDay(TimeCurrent()))
                  {
                     count = count + 1;
                  }
               }
             }
         }
      }
   }
   return(count);
}
  

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void RemoveAllObjects()
{
   for(int i = ObjectsTotal() - 1; i >= 0; i--)
   {
      if (StringFind(ObjectName(i),"EA-",0) > -1)  ObjectDelete(ObjectName(i));
   }
}

//+------------------------------------------------------------------+
//| Display                               |
//+------------------------------------------------------------------+
void Display(string text)
{
  string lab_str = "EA-" + IntegerToString(DisplayCount);  
  double ofset = 0;  
  
  ObjectCreate("EA-BG",OBJ_RECTANGLE_LABEL,0,0,0);
  ObjectSet("EA-BG", OBJPROP_XDISTANCE, DisplayX-20);
  ObjectSet("EA-BG", OBJPROP_YDISTANCE, DisplayY-20);
  ObjectSet("EA-BG", OBJPROP_XSIZE,1);
  ObjectSet("EA-BG", OBJPROP_YSIZE,1);
  ObjectSet("EA-BG", OBJPROP_BGCOLOR,C'0,0,0');
  ObjectSet("EA-BG", OBJPROP_BORDER_TYPE,BORDER_SUNKEN);
  ObjectSet("EA-BG", OBJPROP_CORNER,CORNER_LEFT_UPPER);
  ObjectSet("EA-BG", OBJPROP_STYLE,STYLE_SOLID);
  ObjectSet("EA-BG", OBJPROP_COLOR,clrWhite);
  ObjectSet("EA-BG", OBJPROP_WIDTH,1);
  ObjectSet("EA-BG", OBJPROP_BACK,false);

  ObjectCreate(lab_str, OBJ_LABEL, 0, 0, 0);
  ObjectSet(lab_str, OBJPROP_CORNER, 0);
  ObjectSet(lab_str, OBJPROP_XDISTANCE, DisplayX + ofset);
  ObjectSet(lab_str, OBJPROP_YDISTANCE, DisplayY+DisplayCount*(fontSise+9));
  ObjectSet(lab_str, OBJPROP_BACK, false);
  ObjectSetText(lab_str, text, fontSise, fontName, Colour);
  
 
//-------------------------  
  
    
}

//------------------------------------------------------------------+
//------------------------------------------------------------------+
void SM(string message)
{
   DisplayCount++;
   Display(message);
      
}//End void SM()


//------------------------------------------------------------------+
// Draw error screen
//------------------------------------------------------------------+
void DisplayErrors()
{
   DisplayCount=0;
   Colour=Red;
   SM("Trading turned OFF");
   SM("");
   SM("Invalid settings:");
   SM(error);
}
//------------------------------------------------------------------+
// Draw info screen
//------------------------------------------------------------------+
void ShowStatus()
{
   if(IsOptimization()) return;
  // if(IsTesting()) return;
   
   DisplayCount=0;
   
 
   double lotsTrading=0;
   int openTrades=0;
   double profitLoss=0; 
   for (int k = OrdersTotal();k >=0 ;k--)
   {  
      if (OrderSelect(k, SELECT_BY_POS))
      {
          if ( OrderSymbol() == SYMBOLS[ii])
          {
               if (OrderMagicNumber() == magicbuy || OrderMagicNumber() == magicsell) 
               {
                  lotsTrading+=OrderLots();
                  openTrades=openTrades+1;
                  profitLoss += (OrderProfit() + OrderSwap() + OrderCommission());
               }
          }
      }
   }
   
   
   int wonTrades=0;
   int lostTrades=0;
   double profitToday=0;
   double profitYesterday=0;   
   double profitTotal=0;  
   double totalLotsTraded=0;
   double maxLotsizeUsed=0;
   double profitFactor=-1;
   double totalAmountWon=0;
   double totalAmountLost=0;
   datetime today     = TimeCurrent() ;
   datetime yesterday = TimeCurrent() - (60 * 60 * 24);
   for (int l=OrdersHistoryTotal();l >= 0;l--)
   {
      if(OrderSelect(l, SELECT_BY_POS,MODE_HISTORY))
      {
        if ( OrderSymbol() == SYMBOLS[ii])
        {
           if ( OrderMagicNumber() == magicbuy || OrderMagicNumber() == magicsell )
           {
               totalLotsTraded += OrderLots();
               maxLotsizeUsed   = MathMax(maxLotsizeUsed, OrderLots());
               if (OrderProfit() > 0) wonTrades++;
               else lostTrades++;
               
               double orderProfit = (OrderProfit() + OrderSwap() + OrderCommission());
               if (orderProfit<0) totalAmountLost += orderProfit;
               else totalAmountWon += orderProfit;
               
               profitTotal += orderProfit;
               
               if( TimeDay   (OrderCloseTime()) == TimeDay(today) &&
                   TimeMonth (OrderCloseTime()) == TimeMonth(today) &&
                   TimeYear  (OrderCloseTime()) == TimeYear(today) )
               {
                  profitToday += orderProfit;
               }
               
               if( TimeDay  (OrderCloseTime()) == TimeDay(yesterday) &&
                   TimeMonth(OrderCloseTime()) == TimeMonth(yesterday) &&
                   TimeYear (OrderCloseTime()) == TimeYear(yesterday) )
               {
                  profitYesterday += orderProfit;
               }
            }
        }
      }
   }
   if (totalAmountWon!=0 && totalAmountLost!=0)
   {
      profitFactor=MathAbs(totalAmountWon / totalAmountLost);
   }
   
   double totalTradeCount=(wonTrades+lostTrades);
   
  
}



//------------------------------------------------------------------+
// Generic Money management code
//------------------------------------------------------------------+
double GetLotSize()
{
   double minlot    = MarketInfo(SYMBOLS[ii], MODE_MINLOT);
   double maxlot    = MarketInfo(SYMBOLS[ii], MODE_MAXLOT);
   double leverage  = AccountLeverage();
   double lotsize   = MarketInfo(SYMBOLS[ii], MODE_LOTSIZE);
   double stoplevel = MarketInfo(SYMBOLS[ii], MODE_STOPLEVEL);
   double MinLots = 0.01;
   double MaximalLots = 50;
   double lots = SendLots;

   if(MM)
   {
      lots = NormalizeDouble(AccountFreeMargin() * Risk/100 / 1000.0,   LotDigits);
      if(lots < minlot) lots = minlot;
      if (lots > MaximalLots) lots = MaximalLots;
      if (AccountFreeMargin() < Ask * lots * lotsize / leverage) 
      {
         Print("We have no money. Lots = ", lots, " , Free Margin = ", AccountFreeMargin());
         Comment("We have no money. Lots = ", lots, " , Free Margin = ", AccountFreeMargin());
      }
   }
   else lots=NormalizeDouble(SendLots, Digits);
   return(lots);
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


  
  enum SELECT_DAYS_OR_MONTHS{Today,Yesterday,LastMonths,LastWeeks,
   ThisWeek,LastYear,ThisYear, ThisMonth};
  input SELECT_DAYS_OR_MONTHS  PERIOD_LOSS ;


  //+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckForEntry()
  {
   double ma5;
   double ma12;
   double ma5previous;
   double ma12previous;
   double PeakGreen;
   double PeakRed;
   for(int i=0; i<=Check Previous Bars; i++)
     {
      ma5=iMA(SYMBOLS[ii],Period(),5,0,MODE_EMA,PRICE_CLOSE,i);
      ma12=iMA(SYMBOLS[ii],Period(),12,0,MODE_EMA,PRICE_CLOSE,i);
      ma5previous=iMA(SYMBOLS[ii],Period(),5,0,MODE_EMA,PRICE_CLOSE,1+i);
      ma12previous=iMA(SYMBOLS[ii],Period(),12,0,MODE_EMA,PRICE_CLOSE,1+i);
      PeakGreen=iCustom(SYMBOLS[ii],PERIOD_M5,"BULLVSBEAR",2,i);
      PeakRed=iCustom(SYMBOLS[ii],PERIOD_M5,"BULLVSBEAR",3,i);

      if(SymbolInfoInteger(SYMBOLS[ii],SYMBOL_SPREAD)<High Spread Preventation)//grandmaster
        {
         if(AlertOnlyFactor==true)
           {
            if(M5tillH1Factor==true)//m5-h1 STO
              {
               if(Bars!=EntryBars)
                  if((ma5>ma12) && (ma5previous<ma12previous) && iClose(NULL,0,i+1)>iOpen(NULL,0,i+1) && iClose(NULL,0,i+1)>ma5 && iClose(NULL,0,i+1)>ma12)
     
                        if(LongTradingts261M5==true && LongTradingts261M15==true && LongTradingts261M30==true && LongTradingts261H1==true)
                          {
                           UpArrow("Buy_"+DoubleToStr(Low[10]),TimeCurrent(),Low[10]-Entry Arrow Offset*PIP,Green);
                           if(DrawFibo==true)
                              DrawFiboSimpleBuy("TradeExpert_FiboBuy",Time[0],High[0],Time[100],Low[0]);
                           

                           LongTradingts261M5=false;
                          }
               if(Bars!=EntryBars)
                  if((ma5<ma12) && (ma5previous>ma12previous) && iClose(NULL,0,i+1)<iOpen(NULL,0,i+1) && iClose(NULL,0,i+1)<ma5 && iClose(NULL,0,i+1)<ma12)

                        if(ShortTradingts261M5==true && ShortTradingts261M15==true && ShortTradingts261M30==true && ShortTradingts261H1==true)
                          {
                           DownArrow("Sell_"+DoubleToStr(High[10]),TimeCurrent(),High[10]-Entry Arrow Offset*PIP,Red);
                           if(DrawFibo==true)
                              DrawFiboSimpleSell("TradeExpert_FiboSell",Time[100],Low[0],Time[0],High[0]);
                           
                           ShortTradingts261M5=false;
                          }
              }
            if(M5tillH1DOMFactor==true)//M5-H1 STO DOM
              {

               if((ma5>ma12) && (ma5previous<ma12previous) && iClose(NULL,0,i+1)>iOpen(NULL,0,i+1) && iClose(NULL,0,i+1)>ma5 && iClose(NULL,0,i+1)>ma12)

                     if(LongTradingts261M5==true && LongTradingts261M15==true && LongTradingts261M30==true && LongTradingts261H1==true)
                        if(PeakGreen>PeakRed)
                          {
                           UpArrow("Buy_"+DoubleToStr(Low[10]),TimeCurrent(),Low[10]-Entry Arrow Offset*PIP,Green);
                           if(DrawFibo==true)
                              DrawFiboSimpleBuy("TradeExpert_FiboBuy",Time[0],High[0],Time[100],Low[0]);
                          
                          
                           LongTradingts261M5=false;
                          }

               if((ma5<ma12) && (ma5previous>ma12previous) && iClose(NULL,0,i+1)<iOpen(NULL,0,i+1) && iClose(NULL,0,i+1)<ma5 && iClose(NULL,0,i+1)<ma12)

                     if(ShortTradingts261M5==true && ShortTradingts261M15==true && ShortTradingts261M30==true && ShortTradingts261H1==true)
                        if(PeakGreen<PeakRed)
                          {
                           DownArrow("Sell_"+DoubleToStr(High[10]),TimeCurrent(),High[10]-Entry Arrow Offset*PIP,Red);
                           if(DrawFibo==true)
                              DrawFiboSimpleSell("TradeExpert_FiboSell",Time[100],Low[0],Time[0],High[0]);
                          
                           ShortTradingts261M5=false;
                          }
              }
            if(M5tillM30Factor==true)//M5-M30 STO
              {
               if(Bars!=EntryBars)
                  if((ma5>ma12) && (ma5previous<ma12previous) && iClose(NULL,0,i+1)>iOpen(NULL,0,i+1) && iClose(NULL,0,i+1)>ma5 && iClose(NULL,0,i+1)>ma12)
   
                        if(LongTradingts261M5==true && LongTradingts261M15==true && LongTradingts261M30==true)

                          {
                           UpArrow("Buy_"+DoubleToStr(Low[10]),TimeCurrent(),Low[10]-Entry Arrow Offset*PIP,Green);
                           if(DrawFibo==true)
                              DrawFiboSimpleBuy("TradeExpert_FiboBuy",Time[0],High[0],Time[100],Low[0]);
                          
                           
                           LongTradingts261M5=false;
                          }
               if(Bars!=EntryBars)
                  if((ma5<ma12) && (ma5previous>ma12previous) && iClose(NULL,0,i+1)<iOpen(NULL,0,i+1) && iClose(NULL,0,i+1)<ma5 && iClose(NULL,0,i+1)<ma12)
            
                        if(ShortTradingts261M5==true && ShortTradingts261M15==true && ShortTradingts261M30==true)

                          {
                           DownArrow("Sell_"+DoubleToStr(High[10]),TimeCurrent(),High[10]-Entry Arrow Offset*PIP,Red);
                           if(DrawFibo==true)
                              DrawFiboSimpleSell("TradeExpert_FiboSell",Time[100],Low[0],Time[0],High[0]);
                         
                           
                          }
              }
            if(M5tillM30DOMFactor==true)//M5-M30-DOM
              {

               if((ma5>ma12) && (ma5previous<ma12previous) && iClose(NULL,0,i+1)>iOpen(NULL,0,i+1) && iClose(NULL,0,i+1)>ma5 && iClose(NULL,0,i+1)>ma12)
          
                     if(LongTradingts261M5==true && LongTradingts261M15==true && LongTradingts261M30==true)
                        if(PeakGreen>PeakRed)

                          {
                           UpArrow("Buy_"+DoubleToStr(Low[10]),TimeCurrent(),Low[10]-Entry Arrow Offset*PIP,Green);
                           if(DrawFibo==true)
                              DrawFiboSimpleBuy("TradeExpert_FiboBuy",Time[0],High[0],Time[100],Low[0]);
                         
                           LongTradingts261M5=false;
                          }

               if((ma5<ma12) && (ma5previous>ma12previous) && iClose(NULL,0,i+1)<iOpen(NULL,0,i+1) && iClose(NULL,0,i+1)<ma5 && iClose(NULL,0,i+1)<ma12)

                     if(ShortTradingts261M5==true && ShortTradingts261M15==true && ShortTradingts261M30==true)
                        if(PeakGreen<PeakRed)

                          {
                           DownArrow("Sell_"+DoubleToStr(High[10]),TimeCurrent(),High[10]-Entry Arrow Offset*PIP,Red);
                           if(DrawFibo==true)
                              DrawFiboSimpleSell("TradeExpert_FiboSell",Time[100],Low[0],Time[0],High[0]);
                           
                           ShortTradingts261M5=false;
                          }
              }
           }
         if(AutoTradeFactor==true)
            if(OrdersTotal()<Maximum Per TradePool)
              {
               if(NormalFactor==true||TRADE SELECTION==D2)
                 {
                  if(M5tillH1Factor==true)//M5-H1
                    {
                       {
                        if(Bars!=EntryBars)
                           if(!LongTradingPP)
                              if((ma5>ma12) && (ma5previous<ma12previous) && iClose(NULL,0,i+1)>iOpen(NULL,0,i+1) && iClose(NULL,0,i+1)>ma5 && iClose(NULL,0,i+1)>ma12)
                           
                                    if(LongTradingts261M5==true && LongTradingts261M15==true && LongTradingts261M30==true && LongTradingts261H1==true)

                                      {
                                       OpenBuy("TradeExpert BUY M5H1"+TimeToStr(TimeCurrent()));
                                       UpArrowTrade("Buy_"+DoubleToStr(Low[10]),TimeCurrent(),Low[10]-Entry Arrow Offset*PIP,Green);
                                       if(TelegramPushNotification==true)
                                        //  Print(TelegramSendText(TelegramAPI, TelegramTOKEN,StringFormat("Order Sent by EA TS261: FILTERED BY M5<H1\n\nOrderType : BUY\nPair : %s\n\n===========================\nCurrentAskPrice : %s\n===========================",
                                                               //  Symbol(),DoubleToStr(Ask,Digits))));


                                       LongTradingts261M5=false;
                                      }
                        if(Bars!=EntryBars)
                           if(!ShortTradingPP)
                              if((ma5<ma12) && (ma5previous>ma12previous) && iClose(NULL,0,i+1)<iOpen(NULL,0,i+1) && iClose(NULL,0,i+1)<ma5 && iClose(NULL,0,i+1)<ma12)
               
                                    if(ShortTradingts261M5==true && ShortTradingts261M15==true && ShortTradingts261M30==true && ShortTradingts261H1==true)

                                      {
                                       OpenSell("TradeExpert SELL M5H1"+TimeToStr(TimeCurrent()));
                                       DownArrowTrade("Sell_"+DoubleToStr(High[10]),TimeCurrent(),High[10]-Entry Arrow Offset*PIP,Red);
                                       if(TelegramPushNotification==true)
                                         // Print(TelegramSendText(TelegramAPI, TelegramTOKEN,StringFormat("Order Sent by EA TS261: FILTERED BY M5<H1\n\nOrderType : SELL\nPair : %s\n\n===========================\nCurrentBidPrice : %s\n===========================",
                                                              //   Symbol(),DoubleToStr(Bid,Digits))));



                                       ShortTradingts261M5=false;
                                      }
                       }
                    }
                  if(M5tillM30Factor==true)//M5-M30
                    {
                     if(Bars!=EntryBars)
                        if(!LongTradingPP)
                           if((ma5>ma12) && (ma5previous<ma12previous) && iClose(NULL,0,i+1)>iOpen(NULL,0,i+1) && iClose(NULL,0,i+1)>ma5 && iClose(NULL,0,i+1)>ma12)
         
                                 if(LongTradingts261M5==true && LongTradingts261M15==true && LongTradingts261M30==true)

                                   {
                                    OpenBuy("TradeExpert BUY M5M30"+TimeToStr(TimeCurrent()));
                                    UpArrowTrade("Buy_"+DoubleToStr(Low[10]),TimeCurrent(),Low[10]-Entry Arrow Offset*PIP,Green);
                                    if(TelegramPushNotification==true)
                                      // Print(TelegramSendText(TelegramAPI, TelegramTOKEN,StringFormat("Order Sent by EA TS261: FILTERED BY M5<M30\n\nOrderType : BUY\nPair : %s\n\n===========================\nCurrentAskPrice : %s\n===========================",
//Symbol(),DoubleToStr(Ask,Digits))));

                                    LongTradingts261M5=false;
                                   }
                     if(Bars!=EntryBars)
                        if(!ShortTradingPP)
                           if((ma5<ma12) && (ma5previous>ma12previous) && iClose(NULL,0,i+1)<iOpen(NULL,0,i+1) && iClose(NULL,0,i+1)<ma5 && iClose(NULL,0,i+1)<ma12)
                      
                                 if(ShortTradingts261M5==true && ShortTradingts261M15==true && ShortTradingts261M30==true)

                                   {
                                    OpenSell("TradeExpert SELL M5M30"+TimeToStr(TimeCurrent()));
                                    DownArrowTrade("Sell_"+DoubleToStr(High[10]),TimeCurrent(),High[10]-Entry Arrow Offset*PIP,Red);
                                    if(TelegramPushNotification==true)
                                      // Print(TelegramSendText(TelegramAPI, TelegramTOKEN,StringFormat("Order Sent by EA TS261: FILTERED BY M5<M30\n\nOrderType : SELL\nPair : %s\n\n===========================\nCurrentBidPrice : %s\n===========================",
                                                            //  Symbol(),DoubleToStr(Bid,Digits))));

                                    ShortTradingts261M5=false;
                                   }
                    }
                  if(M5tillH1DOMFactor==true)//M5-H1+DOM
                    {
                     if(Bars!=EntryBars)
                        if(!LongTradingPP)
                           if((ma5>ma12) && (ma5previous<ma12previous) && iClose(NULL,0,i+1)>iOpen(NULL,0,i+1) && iClose(NULL,0,i+1)>ma5 && iClose(NULL,0,i+1)>ma12)
              
                                 if(LongTradingts261M5==true && LongTradingts261M15==true && LongTradingts261M30==true && LongTradingts261H1==true)
                                    if(PeakGreen>PeakRed)

                                      {
                                       OpenBuy("TradeExpert BUY M5H1DOM"+TimeToStr(TimeCurrent()));
                                       UpArrowTrade("Buy_"+DoubleToStr(Low[10]),TimeCurrent(),Low[10]-Entry Arrow Offset*PIP,Green);
                                       if(TelegramPushNotification==true)
                                          //Print(TelegramSendText(TelegramAPI, TelegramTOKEN,StringFormat("Order Sent by EA TS261: FILTERED BY M5<H1+DOM\n\nOrderType : BUY\nPair : %s\n\n===========================\nCurrentAskPrice : %s\n===========================",
                                               //                  Symbol(),DoubleToStr(Ask,Digits))));

                                       LongTradingts261M5=false;
                                      }
                     if(Bars!=EntryBars)
                        if(!ShortTradingPP)
                           if((ma5<ma12) && (ma5previous>ma12previous) && iClose(NULL,0,i+1)<iOpen(NULL,0,i+1) && iClose(NULL,0,i+1)<ma5 && iClose(NULL,0,i+1)<ma12)
           
                                 if(ShortTradingts261M5==true && ShortTradingts261M15==true && ShortTradingts261M30==true && ShortTradingts261H1==true)
                                    if(PeakGreen<PeakRed)

                                      {
                                       OpenSell("TradeExpert SELL M5H1DOM"+TimeToStr(TimeCurrent()));
                                       DownArrowTrade("Sell_"+DoubleToStr(High[10]),TimeCurrent(),High[10]-Entry Arrow Offset*PIP,Red);
                                       if(TelegramPushNotification==true)
                                         // Print(TelegramSendText(TelegramAPI, TelegramTOKEN,StringFormat("Order Sent by EA TS261: FILTERED BY M5<H1+DOM\n\nOrderType : SELL\nPair : %s\n\n===========================\nCurrentBidPrice : %s\n===========================",
                                             //                    Symbol(),DoubleToStr(Bid,Digits))));
//
                                       ShortTradingts261M5=false;
                                      }

                    }
                  if(M5tillM30DOMFactor==true)//M5-M30+DOM
                    {
                     if(Bars!=EntryBars)
                        if(!LongTradingPP)
                           if((ma5>ma12) && (ma5previous<ma12previous) && iClose(NULL,0,i+1)>iOpen(NULL,0,i+1) && iClose(NULL,0,i+1)>ma5 && iClose(NULL,0,i+1)>ma12)
                    
                                 if(LongTradingts261M5==true && LongTradingts261M15==true && LongTradingts261M30==true)
                                    if(PeakGreen>PeakRed)

                                      {
                                       OpenBuy("TradeExpert BUY M5M30DOM"+TimeToStr(TimeCurrent()));
                                       UpArrowTrade("Buy_"+DoubleToStr(Low[10]),TimeCurrent(),Low[10]-Entry Arrow Offset*PIP,Green);
                                       if(TelegramPushNotification==true)
                                         // Print(TelegramSendText(TelegramAPI, TelegramTOKEN,StringFormat("Order Sent by EA TS261: FILTERED BY M5<M30+DOM\n\nOrderType : BUY\nPair : %s\n\n===========================\nCurrentAskPrice : %s\n===========================",
       //                                                          Symbol(),DoubleToStr(Ask,Digits))));

                                       LongTradingts261M5=false;
                                      }
                     if(Bars!=EntryBars)
                        if(!ShortTradingPP)
                           if((ma5<ma12) && (ma5previous>ma12previous) && iClose(NULL,0,i+1)<iOpen(NULL,0,i+1) && iClose(NULL,0,i+1)<ma5 && iClose(NULL,0,i+1)<ma12)
                
                                 if(ShortTradingts261M5==true && ShortTradingts261M15==true && ShortTradingts261M30==true)
                                    if(PeakGreen<PeakRed)

                                      {
                                       OpenSell("TradeExpert SELL M5M30DOM"+TimeToStr(TimeCurrent()));
                                       DownArrowTrade("Sell_"+DoubleToStr(High[10]),TimeCurrent(),High[10]-Entry Arrow Offset*PIP,Red);
                                       if(TelegramPushNotification==true)
                                         // Print(TelegramSendText(TelegramAPI, TelegramTOKEN,StringFormat("Order Sent by EA TS261: FILTERED BY M5<M30+DOM\n\nOrderType : SELL\nPair : %s\n\n===========================\nCurrentBidPrice : %s\n===========================",
                                                        //         Symbol(),DoubleToStr(Bid,Digits))));
                                                  //
                                       ShortTradingts261M5=false;
                                      }

                    }
                 }
               if(HedgeFactor==true)
                 {
                  if(M5tillH1Factor==true)//M5-H1
                    {
                       {
                        if(Bars!=EntryBars)
                           if(!LongTradingPP)
                              if((ma5>ma12) && (ma5previous<ma12previous) && iClose(NULL,0,i+1)>iOpen(NULL,0,i+1) && iClose(NULL,0,i+1)>ma5 && iClose(NULL,0,i+1)>ma12)
                 
                                    if(LongTradingts261M5==true && LongTradingts261M15==true && LongTradingts261M30==true && LongTradingts261H1==true)

                                      {
                                       OpenSell("TradeExpert Hedge M5H1"+TimeToStr(TimeCurrent()));
                                       OpenBuy("TradeExpert Hedge M5H1"+TimeToStr(TimeCurrent()));
                                       UpArrowTrade("Buy_"+DoubleToStr(Low[10]),TimeCurrent(),Low[10]-Entry Arrow Offset*PIP,Green);
                                       if(TelegramPushNotification==true)
                                          //Print(TelegramSendText(TelegramAPI, TelegramTOKEN,StringFormat("Order Sent by EA TS261: FILTERED BY M5<H1\n\nOrderType : BUY\nPair : %s\n\n===========================\nCurrentAskPrice : %s\n===========================",
                                           //                      Symbol(),DoubleToStr(Ask,Digits))));


                                       LongTradingts261M5=false;
                                      }
                        if(Bars!=EntryBars)
                           if(!ShortTradingPP)
                              if((ma5<ma12) && (ma5previous>ma12previous) && iClose(NULL,0,i+1)<iOpen(NULL,0,i+1) && iClose(NULL,0,i+1)<ma5 && iClose(NULL,0,i+1)<ma12)
                             
                                    if(ShortTradingts261M5==true && ShortTradingts261M15==true && ShortTradingts261M30==true && ShortTradingts261H1==true)

                                      {
                                       OpenSell("TS261 Hedge M5H1"+TimeToStr(TimeCurrent()));
                                       OpenBuy("TS261 Hedge M5H1"+TimeToStr(TimeCurrent()));
                                       DownArrowTrade("Sell_"+DoubleToStr(High[10]),TimeCurrent(),High[10]-Entry Arrow Offset*PIP,Red);
                                       if(TelegramPushNotification==true)
                                     //     Print(TelegramSendText(TelegramAPI, TelegramTOKEN,StringFormat("Order Sent by EA TS261: FILTERED BY M5<H1\n\nOrderType : SELL\nPair : %s\n\n===========================\nCurrentBidPrice : %s\n===========================",
                                            //                     Symbol(),DoubleToStr(Bid,Digits))));
//

                                       ShortTradingts261M5=false;
                                      }
                       }
                    }
                  if(M5tillM30Factor==true)//M5-M30
                    {
                     if(Bars!=EntryBars)
                        if(!LongTradingPP)
                           if((ma5>ma12) && (ma5previous<ma12previous) && iClose(NULL,0,i+1)>iOpen(NULL,0,i+1) && iClose(NULL,0,i+1)>ma5 && iClose(NULL,0,i+1)>ma12)
                     
                                 if(LongTradingts261M5==true && LongTradingts261M15==true && LongTradingts261M30==true)

                                   {
                                    OpenBuy("TS261 Hedge M5M30"+TimeToStr(TimeCurrent()));
                                    OpenSell("TS261 Hedge M5M30"+TimeToStr(TimeCurrent()));
                                    UpArrowTrade("Buy_"+DoubleToStr(Low[10]),TimeCurrent(),Low[10]-Entry Arrow Offset*PIP,Green);
                                    if(TelegramPushNotification==true)
                                       //Print(TelegramSendText(TelegramAPI, TelegramTOKEN,StringFormat("Order Sent by EA TS261: FILTERED BY M5<M30\n\nOrderType : BUY\nPair : %s\n\n===========================\nCurrentAskPrice : %s\n===========================",
                                                      //        Symbol(),DoubleToStr(Ask,Digits))));

                                    LongTradingts261M5=false;
                                   }
                     if(Bars!=EntryBars)
                        if(!ShortTradingPP)
                           if((ma5<ma12) && (ma5previous>ma12previous) && iClose(NULL,0,i+1)<iOpen(NULL,0,i+1) && iClose(NULL,0,i+1)<ma5 && iClose(NULL,0,i+1)<ma12)
       
                                 if(ShortTradingts261M5==true && ShortTradingts261M15==true && ShortTradingts261M30==true)

                                   {
                                    OpenBuy("TS261 Hedge M5M30"+TimeToStr(TimeCurrent()));
                                    OpenSell("TS261 Hedge M5M30"+TimeToStr(TimeCurrent()));
                                    DownArrowTrade("Sell_"+DoubleToStr(High[10]),TimeCurrent(),High[10]-Entry Arrow Offset*PIP,Red);
                                    if(TelegramPushNotification==true)
                                      // Print(TelegramSendText(TelegramAPI, TelegramTOKEN,StringFormat("Order Sent by EA TS261: FILTERED BY M5<M30\n\nOrderType : SELL\nPair : %s\n\n===========================\nCurrentBidPrice : %s\n===========================",
                                                         //     Symbol(),DoubleToStr(Bid,Digits))));


                                    ShortTradingts261M5=false;
                                   }
                    }
                  if(M5tillH1DOMFactor==true)//M5-H1+DOM
                    {
                     if(Bars!=EntryBars)
                        if(!LongTradingPP)
                           if((ma5>ma12) && (ma5previous<ma12previous) && iClose(NULL,0,i+1)>iOpen(NULL,0,i+1) && iClose(NULL,0,i+1)>ma5 && iClose(NULL,0,i+1)>ma12)
            
                                 if(LongTradingts261M5==true && LongTradingts261M15==true && LongTradingts261M30==true && LongTradingts261H1==true)
                                    if(PeakGreen>PeakRed)

                                      {
                                       OpenBuy("TS261 Hedge M5H1DOM"+TimeToStr(TimeCurrent()));
                                       OpenSell("TS261 Hedge M5H1DOM"+TimeToStr(TimeCurrent()));
                                       UpArrowTrade("Buy_"+DoubleToStr(Low[10]),TimeCurrent(),Low[10]-Entry Arrow Offset*PIP,Green);
                                       if(TelegramPushNotification==true)
                                      //    Print(TelegramSendText(TelegramAPI, TelegramTOKEN,StringFormat("Order Sent by EA TS261: FILTERED BY M5H1DOM\n\nOrderType : BUY\nPair : %s\n\n===========================\nCurrentAskPrice : %s\n===========================",
                                                           //      Symbol(),DoubleToStr(Ask,Digits))));

                                       LongTradingts261M5=false;
                                      }
                     if(Bars!=EntryBars)
                        if(!ShortTradingPP)
                           if((ma5<ma12) && (ma5previous>ma12previous) && iClose(NULL,0,i+1)<iOpen(NULL,0,i+1) && iClose(NULL,0,i+1)<ma5 && iClose(NULL,0,i+1)<ma12)
        
                                 if(ShortTradingts261M5==true && ShortTradingts261M15==true && ShortTradingts261M30==true && ShortTradingts261H1==true)
                                    if(PeakGreen<PeakRed)

                                      {
                                       OpenBuy("TS261 Hedge M5H1DOM"+TimeToStr(TimeCurrent()));
                                       OpenSell("TS261 Hedge M5H1DOM"+TimeToStr(TimeCurrent()));
                                       DownArrowTrade("Sell_"+DoubleToStr(High[10]),TimeCurrent(),High[10]-Entry Arrow Offset*PIP,Red);
                                       if(TelegramPushNotification==true)
                                         // Print(TelegramSendText(TelegramAPI, TelegramTOKEN,StringFormat("Order Sent by EA TS261: FILTERED BY M5H1DOM\n\nOrderType : SELL\nPair : %s\n\n===========================\nCurrentBidPrice : %s\n===========================",
                                                            //     Symbol(),DoubleToStr(Bid,Digits))));

                                       ShortTradingts261M5=false;
                                      }

                    }
                  if(M5tillM30DOMFactor==true)//M5-M30+DOM
                    {
                     if(Bars!=EntryBars)
                        if(!LongTradingPP)
                           if((ma5>ma12) && (ma5previous<ma12previous) && iClose(NULL,0,i+1)>iOpen(NULL,0,i+1) && iClose(NULL,0,i+1)>ma5 && iClose(NULL,0,i+1)>ma12)
         
                                 if(LongTradingts261M5==true && LongTradingts261M15==true && LongTradingts261M30==true)
                                    if(PeakGreen>PeakRed)

                                      {
                                       OpenSell("TS261 Hedge M5M30DOM"+TimeToStr(TimeCurrent()));
                                       OpenBuy("TS261 Hedge M5M30DOM"+TimeToStr(TimeCurrent()));
                                       UpArrowTrade("Buy_"+DoubleToStr(Low[10]),TimeCurrent(),Low[10]-Entry Arrow Offset*PIP,Green);
                                       if(TelegramPushNotification==true)
                                        //  Print(TelegramSendText(TelegramAPI, TelegramTOKEN,StringFormat("Order Sent by EA TS261: FILTERED BY M5M30DOM\n\nOrderType : BUY\nPair : %s\n\n===========================\nCurrentAskPrice : %s\n===========================",
                                                               //  Symbol(),DoubleToStr(Ask,Digits))));

                                       LongTradingts261M5=false;
                                      }
                     if(Bars!=EntryBars)
                        if(!ShortTradingPP)
                           if((ma5<ma12) && (ma5previous>ma12previous) && iClose(NULL,0,i+1)<iOpen(NULL,0,i+1) && iClose(NULL,0,i+1)<ma5 && iClose(NULL,0,i+1)<ma12)
                 
                                 if(ShortTradingts261M5==true && ShortTradingts261M15==true && ShortTradingts261M30==true)
                                    if(PeakGreen<PeakRed)

                                      {
                                       OpenSell("TS261 Hedge M5M30DOM"+TimeToStr(TimeCurrent()));
                                       OpenBuy("TS261 Hedge M5M30DOM"+TimeToStr(TimeCurrent()));
                                       DownArrowTrade("Sell_"+DoubleToStr(High[10]),TimeCurrent(),High[10]-Entry Arrow Offset*PIP,Red);
                                       if(TelegramPushNotification==true)
                                         // Print(TelegramSendText(TelegramAPI, TelegramTOKEN,StringFormat("Order Sent by EA TS261: FILTERED BY M5M30DOM\n\nOrderType : SELL\nPair : %s\n\n===========================\nCurrentBidPrice : %s\n===========================",
                                                          //       Symbol(),DoubleToStr(Bid,Digits))));

                                       ShortTradingts261M5=false;
                                      }

                    }
                 }
              }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnBar()
  {
//Note: DO NOT USE zero bar logic e.g.: Open[0]/Close[0] or Low[0]/High[0] in OnBar() function!
   CheckForEntry();
   BarsCnt=Bars;
   TimeCnt=iTime(Symbol(),Period(),1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void Previour_Order_Select(int type){//set new trade size
int total = OrdersTotal();
   int orderList[][2];
   int orderCount = 0;
   int i;
   for(i = 0; i < total; i++)
     {
   int sec=0;
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if(OrderMagicNumber() != mytrade.getOrder_MagicNumber() || OrderSymbol() != Symbol() || OrderType() > 1 || OrderOpenTime() + sec > TimeCurrent()) continue;
      orderCount++;
      ArrayResize(orderList, orderCount);
      orderList[orderCount - 1][0] = (int)OrderOpenTime();
      orderList[orderCount - 1][1] = OrderTicket();
     }
   if(orderCount > 0)
      ArraySort(orderList, WHOLE_ARRAY, 0, MODE_ASCEND);
   for(i = 0; i < orderCount; i++)
     {
      if(!OrderSelect(orderList[i][1], SELECT_BY_TICKET, MODE_TRADES)) continue;
      
      RefreshRates();
      
      if(OrderType() == type && InpLots==OrderLots()){
      
      
      mytrade.setOrder_Lot(2*InpLots);//B  set new lot size if match previour order lot
      
      }else{
       lot++;
      mytrade.setOrder_Lot(InpLots/100);
    
      
      }
        }
   








}
bool OpenBuy(string Signal



)
  {
   int ErrorCode=-1;
   GetRates(SYMBOL);
//Get new lot size
   lot=NormalizeDouble(SendLots,LOTDIGITS);
//Define TP and SL levels
   TP = NormalizeDouble(Bid+InpTakeProfit*PIP,Digits);
   SL = NormalizeDouble(Bid-InpStopLoss*PIP,Digits);
   
   

mytrade.setOrder_MagicNumber(MagicNumber);
mytrade.setOrder_Color(clrGreen);
mytrade.setOrder_Comment("TradeExpert Market BUY Order executed at "+(string)ASK +"Time :"+(string)TimeDay(TimeCurrent()));

mytrade.setOrder_Command(OP_BUYSTOP);
mytrade.setOrder_Symbol(SYMBOL);
mytrade.setOrder_Slippage(slippage);
mytrade.setOrder_StopLoss(SL);
mytrade.setOrder_TakeProfit(TP);

Previour_Order_Select(OP_BUYSTOP);
mytrade.SendOrder(OP_BUYSTOP);//send BUY Market order



    
   if(Ticket==-1)
     {
      ErrorCode=GetLastError();
      Alert("@TTradeExpert1 #Buy Error: ",ErrorCode," ",Symbol()," Slippage: ",slippage);
      if(Debug)
         Print("@TradeExpert #Buy Error: ",ErrorCode," ",Symbol()," Slippage: ",slippage);
      LongTrading=false;
      return(false);
     }
   if(Ticket>=0)
     {
      LongTrading=true;
      EntryBars=Bars;
      return(true);
     }

   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

  

bool OpenSell(string SignalComment)//Autotrade if signal
  {
   int ErrorCode=-1;
   GetRates(SYMBOL);
//Get new lot size
   lot=NormalizeDouble(SendLots,LotDigits);
//Define TP and SL levels
   TP = NormalizeDouble(Ask-InpTakeProfit*PIP,Digits);
   SL = NormalizeDouble(Ask+InpStopLoss*PIP,Digits);



   
mytrade.setOrder_Lot(InpLots);
mytrade.setOrder_MagicNumber(MagicNumber);
mytrade.setOrder_Comment("@TradeExpert Market SELL Order executed at "+(string)BID +"Time :"+(string)TimeDay(TimeCurrent()));
mytrade.setOrder_Command(OP_SELLSTOP);
mytrade.setOrder_Symbol(SYMBOLS[ii]);
mytrade.setOrder_Color(clrRed);
mytrade.setOrder_Slippage(slippage);

mytrade.setOrder_StopLoss(SL);
mytrade.setOrder_TakeProfit(TP);


  Previour_Order_Select(OP_SELLSTOP);
  
mytrade.SendOrder(OP_SELLSTOP);



RefreshRates();
   if(Ticket==-1)
     {
      ErrorCode=GetLastError();
      Alert("@TradeExpert #Sell Error: ",ErrorCode," ",SYMBOL," Slippage: ",slippage);
      if(Debug)
         Print("@TradeExpert #Sell Error: ",ErrorCode," ",SYMBOL," Slippage: ",slippage);
      ShortTrading=false;
      return(false);
     }
   if(Ticket>=0)
     {
      ShortTrading=true;
      EntryBars=Bars;
      return(true);
     }
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool AlertOnly()
  {
   if(MODE SELECTION==C1)
      AlertOnlyFactor=true;
   return AlertOnlyFactor;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool M5tillM30()
  {
   if(FILTER SELECTION==B1)
      M5tillM30Factor=true;
   return M5tillM30Factor;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool M5tillM30DOM()
  {
   if(FILTER SELECTION==B3)
      M5tillM30DOMFactor=true;
   return M5tillM30DOMFactor;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool AutoTrade()
  {
   if(MODE SELECTION==C2)
      AutoTradeFactor=true;
   return AutoTradeFactor;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool M5tillH1()
  {
   if(FILTER SELECTION==B2)
      M5tillH1Factor=true;
   return M5tillH1Factor;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool M5tillH1DOM()
  {
   if(FILTER SELECTION==B4)
      M5tillH1DOMFactor=true;
   return M5tillH1DOMFactor;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Martingale()
  {
   if(TRADE SELECTION==D2)
      MartingaleFactor=true;
   if(TRADE SELECTION==D1||D3)
      MartingaleFactor=false;
   return MartingaleFactor;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool NormalTrade()
  {
   if(TRADE SELECTION==D2||D3)
      NormalFactor=false;
   if(TRADE SELECTION==D1)
      NormalFactor=true;
   return NormalFactor;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool HedgeTrade()
  {
   if(TRADE SELECTION==D2||D1)
      HedgeFactor=false;
   if(TRADE SELECTION==D3)
      HedgeFactor=true;
   return HedgeFactor;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckStochts261m5()
  {
   double ts261m5;
   double OverSold;
   double OverBought;

   for(int i=0; i<=0; i++)
     {
      ts261m5=iCustom(SYMBOLS[ii],Period(),"1mfsto",5,5,5,3,i);
      OverSold=-45;
      OverBought=45;

      if(bar!=Bars)

        {

         if(ts261m5<OverSold)
           {
            LongTradingts261M5=true;
            ShortTradingts261M5=false;
           }
         if(ts261m5>OverBought)

           {
            LongTradingts261M5=false;
            ShortTradingts261M5=true;
           }
        }
     }
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckStochts261m15()
  {
   double ts261m15;
   double OverSold;
   double OverBought;
   for(int i=0; i<=0; i++)
     {
      ts261m15=iCustom(SYMBOLS[ii],Period(),"1mfsto",15,15,15,3,i);
      OverSold=-45;
      OverBought=45;

      if(bar!=Bars)
        {
         if(ts261m15<OverSold)
           {
            LongTradingts261M15=true;
            ShortTradingts261M15=false;
           }
         if(ts261m15>OverBought)

           {
            LongTradingts261M15=false;
            ShortTradingts261M15=true;
           }
        }
     }
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckStochts261m30()
  {
   double ts261m30;
   double OverSold;
   double OverBought;
   for(int i=0; i<=0; i++)
     {
      ts261m30=iCustom(SYMBOLS[ii],Period(),"1mfsto",30,30,30,3,i);
      OverSold=-45;
      OverBought=45;

      if(bar!=Bars)
        {
         if(ts261m30<OverSold)
           {
            LongTradingts261M30=true;
            ShortTradingts261M30=false;
           }
         if(ts261m30>OverBought)

           {
            LongTradingts261M30=false;
            ShortTradingts261M30=true;
           }
        }
     }
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckStochts261h1()
  {
   double ts261h1;
   double OverSold;
   double OverBought;

   for(int i=0; i<=0; i++)
     {

      ts261h1=iCustom(SYMBOLS[ii],Period(),"1mfsto",60,60,60,3,i);
      OverSold=-45;
      OverBought=45;

      if(bar!=Bars)
        {
         if(ts261h1<OverSold)
           {
            LongTradingts261H1=true;
            ShortTradingts261H1=false;
           }
         if(ts261h1>OverBought)

           {
            LongTradingts261H1=false;
            ShortTradingts261H1=true;
           }
        }
     }
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckRSIts261m5()
  {
   double ts261m5high;
   double ts261m5low;
   double OverSold;
   double OverBought;

   for(int i=0; i<=0; i++)
     {
      ts261m5high=iCustom(SYMBOLS[ii],Period(),"MTF_RSI",9,2,1,i);
      ts261m5low=iCustom(SYMBOLS[ii],Period(),"MTF_RSI",9,3,1,i);
      OverSold=20;
      OverBought=80;

      if(bar!=Bars)

        {

         if(ts261m5low<OverSold)
           {
            LongTradingts261M5=true;
            ShortTradingts261M5=false;
           }
         if(ts261m5high>OverBought)

           {
            LongTradingts261M5=false;
            ShortTradingts261M5=true;
           }
        }
     }
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckRSIts261m15()
  {
   double ts261m15high;
   double ts261m15low;
   double OverSold;
   double OverBought;
   for(int i=0; i<=0; i++)
     {
      ts261m15high=iCustom(SYMBOLS[ii],Period(),"MTF_RSI",9,2,2,i);
      ts261m15low=iCustom(SYMBOLS[ii],Period(),"MTF_RSI",9,3,2,i);
      OverSold=20;
      OverBought=80;

      if(bar!=Bars)
        {
         if(ts261m15low<OverSold)
           {
            LongTradingts261M15=true;
            ShortTradingts261M15=false;
           }
         if(ts261m15high>OverBought)

           {
            LongTradingts261M15=false;
            ShortTradingts261M15=true;
           }
        }
     }
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckRSIts261m30()
  {
   double ts261m30high;
   double ts261m30low;
   double OverSold;
   double OverBought;
   for(int i=0; i<=0; i++)
     {
      ts261m30high=iCustom(SYMBOLS[ii],Period(),"MTF_RSI",9,2,3,i);
      ts261m30low=iCustom(SYMBOLS[ii],Period(),"MTF_RSI",9,3,3,i);
      OverSold=20;
      OverBought=80;

      if(bar!=Bars)
        {
         if(ts261m30low<OverSold)
           {
            LongTradingts261M30=true;
            ShortTradingts261M30=false;
           }
         if(ts261m30high>OverBought)

           {
            LongTradingts261M30=false;
            ShortTradingts261M30=true;
           }
        }
     }
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckRSIts261h1()
  {
   double ts261h1high;
   double ts261h1low;
   double OverSold;
   double OverBought;

   for(int i=0; i<=0; i++)
     {

      ts261h1high=iCustom(SYMBOLS[ii],Period(),"MTF_RSI",9,2,4,i);
      ts261h1low=iCustom(SYMBOLS[ii],Period(),"MTF_RSI",9,3,4,i);
      OverSold=20;
      OverBought=80;

      if(bar!=Bars)
        {
         if(ts261h1low<OverSold)
           {
            LongTradingts261H1=true;
            ShortTradingts261H1=false;
           }
         if(ts261h1high>OverBought)

           {
            LongTradingts261H1=false;
            ShortTradingts261H1=true;
           }
        }
     }
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CloseAll()
  {
   bool CloseCheck=false;
   if(Debug)
      Print("@TradeExpert: Time to close EA trades");
   while(CountOpenTrades()>0)
     {
      GetRates(SYMBOL);
      if(Debug)
         Print("@TradeExpert: Trying to close all EA trades");
      for(int i=OrdersTotal()-1; i>=0; i--)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
            if(OrderMagicNumber()==MagicNumber && OrderSymbol()==SYMBOL)
              {
               switch(OrderType())
                 {
                  case OP_BUY       :
                    {
                     CloseCheck=OrderClose(OrderTicket(),OrderLots(),Bid,slippage,Violet); //break;
                     if(!CloseCheck)
                       {
                        Alert("@TradeExpert #Close Error: ",GetLastError()," ",Symbol(),"Slippage: ",slippage);
                        if(Debug)
                           Print("@TradeExpert #Close Error: ",GetLastError()," ",Symbol(),"Slippage: ",slippage);
                        return(false);
                       }
                     if(CloseCheck)
                       {
                        LongTrading=false;
                       }
                    }
                  break;
                  case OP_SELL      :
                    {
                     CloseCheck=OrderClose(OrderTicket(),OrderLots(),Ask,slippage,Violet); //break;
                     if(!CloseCheck)
                       {
                        Alert("@TradeExpert #Close Error: ",GetLastError()," ",SYMBOLS[ii],"Slippage: ",slippage);
                        if(Debug)
                           Print("@TradeExpert #Close Error: ",GetLastError()," ",SYMBOLS[ii],"Slippage: ",slippage);
                        return(false);
                       }
                     if(CloseCheck)
                       {
                        ShortTrading=false;
                       }
                    }
                  break;
                  default :
                     Print("@TradeExpert No open trades");
                 }
              }
        }
     }

   LongTrading=false;
   ShortTrading=false;
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CloseAllSell()
  {
   bool CloseCheck=false;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(CountOpenTrades()>0)
     {
      GetRates(SYMBOL);
      //if(Debug) Print("@TS261: Trying to close Sell EA trades");
      for(int i=OrdersTotal()-1; i>=0; i--)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
            if(OrderMagicNumber()==MagicNumber && OrderSymbol()==SYMBOL)
               if(OrderType()==OP_SELL)
                 {
                  CloseCheck=OrderClose(OrderTicket(),OrderLots(),BID,slippage,Violet);
                  if(Debug)
                     Print("@TradeExpert: Close Sell EA trades done");
                 }
        }

     }

   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CloseAllBuy()
  {
   bool CloseCheck=false;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(CountOpenTrades()>0)
     {
      GetRates(SYMBOLS[ii]);
      //if(Debug) Print("@TS261: Trying to close BUY EA trades");
      for(int i=OrdersTotal()-1; i>=0; i--)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
            if(OrderMagicNumber()==MagicNumber && OrderSymbol()==SYMBOLS[ii])
               if(OrderType()==OP_BUY)
                 {
                  CloseCheck=OrderClose(OrderTicket(),OrderLots(),BID,slippage,Violet);
                  if(Debug)
                     Print("@TS261: Close Buy EA trades done");
                 }
        }

     }

   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CountOpenTrades()
  {
   int OrderCnt=0;
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(OrderMagicNumber()==MagicNumber && OrderSymbol()==SYMBOLS[ii])
            OrderCnt++;
     }
//if(Debug) Print("@TS261 Number of open trades:",IntegerToString(OrderCnt));
   return(OrderCnt);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GetRates(string symbol)
  {
//Refresh rates
   ASK=MarketInfo(symbol,MODE_ASK);
   BID=MarketInfo(symbol,MODE_BID);
   DIGITS=(int)MarketInfo(symbol,MODE_DIGITS);
   POINT=Point;
   LOTDIGITS=(int)-MathLog10(SymbolInfoDouble(symbol,SYMBOL_VOLUME_STEP));
//Print("Rates: Ask:",ASK," BID:",BID," DIGITS:",DIGITS," POINT:",DoubleToStr(POINT,DIGITS));
  }
////////////////////////////////////////////////////////////////////////
bool CheckOpenOrdersSell()
  {
   ShortTradingPP=false;
   int OrderCountSell=1;
//Search for open trades
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(OrderMagicNumber()==MagicNumber && OrderSymbol()==SYMBOLS[ii])
            if(OrderType()==OP_SELL)
               OrderCountSell++;
        {
         if(OrderCountSell>Sell MaxOrder For This Pair)
           {
            ShortTradingPP=true;

           }

        }
     }

   if(ShortTradingPP)
      return(false);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
     {
      BreakEvenOnce=false;
      return(false);
     }
  }
//////////////////////////////////////////////////////////////////////////
bool CheckOpenOrdersBuy()
  {
   LongTradingPP=false;
   int OrderCountBuy=1;
//Search for open trades
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(OrderMagicNumber()==MagicNumber && OrderSymbol()==SYMBOLS[ii])
            if(OrderType()==OP_BUY)
               OrderCountBuy++;
        {
         if(OrderCountBuy>Buy MaxOrder For This Pair)
           {
            LongTradingPP=true;
            //if(Debug) Print("@TS261 Number of open trades:",IntegerToString(OrderCount));

           }

        }
     }

   if(LongTradingPP)
      return(false);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
     {
      BreakEvenOnce=false;
      return(false);
     }
  }
////////////////////////////////////////////////////////////////////////////
bool CheckOpenOrders()
  {
//Reset trading flags
   LongTrading=false;
   ShortTrading=false;

//Search for open trades
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(OrderMagicNumber()==MagicNumber && OrderSymbol()==SYMBOLS[ii])
           {
            if(OrderType()==OP_BUY)
              {
               LongTrading=true;
              }
            if(OrderType()==OP_SELL)
              {
               ShortTrading=true;
              }
           }
     }
   if(LongTrading || ShortTrading)
      return(false);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else
     {
      BreakEvenOnce=false;
      return(false);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckOrdersTrailing()
  {
   bool ModifyCheck=false;

//RefreshRates
   GetRates(SYMBOLS[ii]);
//Print("PIP:", PIP);
   if(CountOpenTrades()>0)
     {
      for(int i=OrdersTotal()-1; i>=0; i--)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
           {
            if(OrderSymbol()==SYMBOLS[ii] && OrderType()==OP_BUY && OrderMagicNumber()==MagicNumber)
              {
               if((BID-OrderStopLoss())/PIP>InpTrailingStop+InpStopLoss)
                 {
                  SL=NormalizeDouble(OrderStopLoss()+(InpTrailingStop*PIP),Digits);
                  if(SL!=OrderStopLoss())
                     if(SL<NormalizeDouble((Bid-((MarketInfo(SYMBOLS[ii],MODE_STOPLEVEL)+MarketInfo(Symbol(),MODE_SPREAD))*Point())),Digits))
                       {
                        ModifyCheck=OrderModify(OrderTicket(),OrderOpenPrice(),SL,OrderTakeProfit(),0,Green);
                        DrawText("SLModify",DoubleToString(SL,Digits),Time[0],clrBlue);
                        if(!ModifyCheck)
                           ErrorCheck("BUY");

                       }

                 }

              }
            if(OrderSymbol()==SYMBOLS[ii] && OrderType()==OP_SELL && OrderMagicNumber()==MagicNumber)
              {
               if((OrderStopLoss()-Ask)/PIP>InpTrailingStop+InpStopLoss)
                 {
                  SL=NormalizeDouble(OrderStopLoss()-(InpTrailingStop*PIP),Digits);
                  if(SL!=OrderStopLoss())
                     if(SL>NormalizeDouble((Ask+((MarketInfo(SYMBOLS[ii],MODE_STOPLEVEL)+MarketInfo(Symbol(),MODE_SPREAD))*Point())),Digits))

                       {
                        ModifyCheck=OrderModify(OrderTicket(),OrderOpenPrice(),SL,OrderTakeProfit(),0,Red);
                        DrawText("SLModify",NULL,TimeCurrent(),0,clrRed);
                        if(!ModifyCheck)
                           ErrorCheck("SELL");
                       }
                 }
              }
           }
        }

     }
   return(true);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ErrorCheck(string Direction)
  {
   int ModifyErrorCheck=0;
   double AllowedSL;

   ModifyErrorCheck=GetLastError();
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(ModifyErrorCheck!=ERR_NO_ERROR) //0 means No error returned!
     {
      if(ModifyErrorCheck==130)
        {
         if(Direction=="SELL")
           {
            AllowedSL=NormalizeDouble((Ask+((MarketInfo(Symbol(),MODE_STOPLEVEL)+MarketInfo(Symbol(),MODE_SPREAD))*Point())),Digits);
            if(Debug)
               Print("@TradeExpert SL for ",Direction,": ",SL,">",AllowedSL);
           }
         else
           {
            AllowedSL=NormalizeDouble((Bid-((MarketInfo(Symbol(),MODE_STOPLEVEL)+MarketInfo(Symbol(),MODE_SPREAD))*Point())),Digits);
            if(Debug)
               Print("@TradeExpert SL for ",Direction,": ",SL,"<",AllowedSL);
           }
         if(Debug)
            Print("@TradeExpert Current SL ",Direction,": ",NormalizeDouble(SL,Digits)," Error: ",ModifyErrorCheck," ",Symbol()," Slippage: ",slippage," Spread: ",MarketInfo(Symbol(),MODE_SPREAD));
        }
      return(false);
     }
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CopyRightlogo()
  {
   ObjectCreate(0,"logo",OBJ_BITMAP_LABEL,0,0,0);
   ObjectSetString(0,"logo",OBJPROP_BMPFILE,"\\Images\\ts261.bmp");
   ObjectSetInteger(0,"logo",OBJPROP_CORNER,CORNER_LEFT_LOWER);
   ObjectSetInteger(0,"logo",OBJPROP_ANCHOR,CORNER_LEFT_LOWER);
   ObjectSetInteger(0,"logo",OBJPROP_BACK,true);
   ObjectSetInteger(0,"logo",OBJPROP_XDISTANCE,40);
   ObjectSetInteger(0,"logo",OBJPROP_YDISTANCE,1);

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ChartColorSet()
  {
   ChartSetInteger(0,CHART_COLOR_CANDLE_BEAR,Bear Candle);
   ChartSetInteger(0,CHART_COLOR_CANDLE_BULL,Bull Candle);
   ChartSetInteger(0,CHART_COLOR_CHART_DOWN,Bear Outline);
   ChartSetInteger(0,CHART_COLOR_CHART_UP,Bull Outline);
   ChartSetInteger(0,CHART_SHOW_GRID,0);
   ChartSetInteger(0,CHART_SHOW_PERIOD_SEP,false);
   ChartSetInteger(0,CHART_MODE,1);
   ChartSetInteger(0,CHART_SHIFT,1);
   ChartSetInteger(0,CHART_SHOW_ASK_LINE,1);
   ChartSetInteger(0,CHART_COLOR_BACKGROUND,BackGround);
   ChartSetInteger(0,CHART_COLOR_FOREGROUND,ForeGround);
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UpArrow(string Name,datetime TIME,double Level,color Color)
  {
   ObjectCreate(Name,OBJ_ARROW,0,TIME,Low[2],0);
   ObjectSet(Name,OBJPROP_STYLE,STYLE_SOLID);
   ObjectSet(Name,OBJPROP_ARROWCODE,Arrow Code Buy);
   ObjectSet(Name,OBJPROP_WIDTH,2);
   ObjectSet(Name,OBJPROP_COLOR,Colour Buy);
   ObjectSet(Name,OBJPROP_HIDDEN,Hide Arrow BUY in ObjectList);

   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UpArrowTrade(string Name,datetime TIME,double Level,color Color)
  {
   ObjectCreate(Name,OBJ_ARROW,0,TIME,Low[2],0);
   ObjectSet(Name,OBJPROP_STYLE,STYLE_SOLID);
   ObjectSet(Name,OBJPROP_ARROWCODE,Arrow Code Buy Trade);
   ObjectSet(Name,OBJPROP_WIDTH,2);
   ObjectSet(Name,OBJPROP_COLOR,Colour Buy Trade);
   ObjectSet(Name,OBJPROP_HIDDEN,Hide Arrow BUY Trade in ObjectList);

   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DownArrow(string Name,datetime TIME,double Level,color Color)
  {
   ObjectCreate(Name,OBJ_ARROW,0,TIME,High[2],0);
   ObjectSet(Name,OBJPROP_STYLE,STYLE_SOLID);
   ObjectSet(Name,OBJPROP_ARROWCODE,Arrow Code Sell);
   ObjectSet(Name,OBJPROP_WIDTH,2);
   ObjectSet(Name,OBJPROP_COLOR,Colour Sell);
   ObjectSet(Name,OBJPROP_HIDDEN,Hide Arrow SELL in ObjectList);

   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DownArrowTrade(string Name,datetime TIME,double Level,color Color)
  {
   ObjectCreate(Name,OBJ_ARROW,0,TIME,High[2],0);
   ObjectSet(Name,OBJPROP_STYLE,STYLE_SOLID);
   ObjectSet(Name,OBJPROP_ARROWCODE,Arrow Code Sell Trade);
   ObjectSet(Name,OBJPROP_WIDTH,2);
   ObjectSet(Name,OBJPROP_COLOR,Colour Sell Trade);
   ObjectSet(Name,OBJPROP_HIDDEN,Hide Arrow SELL Trade in ObjectList);

   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawDot(string Name,datetime TIME,double Level,color Color)
  {
   ObjectCreate(Name,OBJ_ARROW,0,TIME,Level,0);
   ObjectSet(Name,OBJPROP_ARROWCODE,158);
   ObjectSet(Name,OBJPROP_WIDTH,2);
   ObjectSet(Name,OBJPROP_COLOR,Color);
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawTrendLine(string str="",double PRICE1=0,datetime TIME1=0,double PRICE2=0,datetime TIME2=0,color COLOR=Orange,int WIDTH=1)
  {
   if(ObjectFind(str)==-1)
     {
      ObjectCreate(str,OBJ_TREND,0,TIME1,PRICE1,TIME2,PRICE2);
      ObjectSet(str,OBJPROP_WIDTH,WIDTH);
      ObjectSet(str,OBJPROP_COLOR,COLOR);
      ObjectSet(str,OBJPROP_RAY,false);
      ObjectSet(str,OBJPROP_BACK,false);
      ObjectSet(str,OBJPROP_STYLE,STYLE_DOT);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawText(string Name,string Text="",datetime TIME=0,double Level=0,color COLOR=Yellow)
  {
   ObjectDelete(Name);
   if(ObjectFind(Name)==-1)
      ObjectCreate(Name,OBJ_TEXT,0,TIME,Level);
   ObjectSetText(Name,Text,12,"",COLOR);
    return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Partialclose()

  {

   if(OrdersTotal())
     {
      if(!OrderSelect(0,SELECT_BY_POS,MODE_TRADES))
         Print("Unable to select an order");
      double OP=OrderOpenPrice();
      int type=OrderType();
      double lots=OrderLots();
      int ticket=OrderTicket();
      if(lots==FixedLotSize)
        {
         if(type==OP_BUY && Bid-OP>(Pip To Partial*PIP))
           {
            if(!OrderClose(ticket,lots/2,Ask,slippage,clrGreen))
               Print("Fail to close order");

           }

         if(type==OP_SELL && OP-Ask>(Pip To Partial*PIP))
           {
            if(!OrderClose(ticket,lots/2,Bid,slippage,clrRed))
               Print("Fail to close order");

           }
        }

     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckBreakEven()
  {
   bool ModifyCheck=false;
//int ErrorCode;

   for(int j=OrdersTotal()-1; j>=0; j--)
     {
      if(OrderSelect(j,SELECT_BY_POS,MODE_TRADES))
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)

           {
            if(OrderType()==OP_BUY)
              {
               if((Bid-OrderOpenPrice())/PIP>When Pip Was)
                  if(OrderOpenPrice()>OrderStopLoss())
                    {
                     ModifyCheck=OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+(Pip To Secure*PIP),OrderTakeProfit(),0,Blue);
                     if(!ModifyCheck)
                       {
                        BreakEvenOnce=false;
                        //ErrorCode=GetLastError();
                        //Print("OrderModify error : ", ErrorCode);

                       }
                     else
                        BreakEvenOnce=true;
                    }
              }
            if(OrderType()==OP_SELL)
              {
               if((OrderOpenPrice()-Ask)/PIP>When Pip Was)
                  if(OrderOpenPrice()<OrderStopLoss())
                    {
                     ModifyCheck=OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-(Pip To Secure*PIP),OrderTakeProfit(),0,Blue);
                     if(!ModifyCheck)
                       {
                        BreakEvenOnce=false;
                        //ErrorCode=GetLastError();
                        //Print("OrderModify error : ", ErrorCode);

                       }
                     else
                        BreakEvenOnce=true;
                    }
              }
           }
     }
   return(false);
  }
  

  
  
  

void DrawFiboSimpleBuy(string fiboName,datetime firstTime,double firstPrice,datetime secondTime,double secondPrice)
  {
   int HighestCandle=iHighest(SYMBOLS[ii],Period(),MODE_CLOSE,1,0);
   int LowestCandle=iLowest(SYMBOLS[ii],Period(),MODE_OPEN,30,0);

   ObjectDelete("TradeExpert_FiboBuy");
   ObjectDelete("TradeExpert_FiboSell");

   ObjectCreate(fiboName,OBJ_FIBO,0,Time[0],High[HighestCandle],Time[30],Low[LowestCandle]);
   ObjectSet(fiboName,OBJPROP_COLOR,Blue);
   ObjectSet(fiboName,OBJPROP_BACK,true);
   ObjectSet(fiboName,OBJPROP_WIDTH,3);
   ObjectSet(fiboName,OBJPROP_FIBOLEVELS,25);
   ObjectSet(fiboName,OBJPROP_LEVELCOLOR,Blue);
   ObjectSet(fiboName,OBJPROP_LEVELWIDTH,3);
//---

   ObjectSet(fiboName,OBJPROP_FIRSTLEVEL+0,-3.236);
   ObjectSetFiboDescription(fiboName,0,"SL 3= %$");
   ObjectSet(fiboName,OBJPROP_FIRSTLEVEL+1,-1.618);
   ObjectSetFiboDescription(fiboName,1,"SL 2= %$");
   ObjectSet(fiboName,OBJPROP_FIRSTLEVEL+2,-0.618);
   ObjectSetFiboDescription(fiboName,2,"SL 1= %$");
   ObjectSet(fiboName,OBJPROP_FIRSTLEVEL+3,0.000);
   ObjectSetFiboDescription(fiboName,3,"Lowest Shadow= %$");
   ObjectSet(fiboName,OBJPROP_FIRSTLEVEL+4,1.000);
   ObjectSetFiboDescription(fiboName,4,"Entry= %$");
   ObjectSet(fiboName,OBJPROP_FIRSTLEVEL+5,1.618);
   ObjectSetFiboDescription(fiboName,5,"TP 1= %$");
   ObjectSet(fiboName,OBJPROP_FIRSTLEVEL+6,2.618);
   ObjectSetFiboDescription(fiboName,6,"TP 2= %$");
   ObjectSet(fiboName,OBJPROP_FIRSTLEVEL+7,4.236);
   ObjectSetFiboDescription(fiboName,7,"TP 3= %$");
//----
   
   ObjectSet(fiboName,OBJPROP_RAY,false);
   ObjectSet(fiboName,OBJPROP_RAY_RIGHT,false);

  }
  
  

void DrawRegressionBuy(string regression,datetime firstTime,double firstPrice,datetime secondTime,double secondPrice)
  {
   int HighestCandle=iHighest(SYMBOLS[ii],Period(),MODE_CLOSE,1,0);
   int LowestCandle=iLowest(SYMBOLS[ii],Period(),MODE_OPEN,30,0);
string fiboName=regression;
   ObjectDelete("TradeExpert_FiboBuy");
   ObjectDelete("TradeExpert_FiboSell");

   ObjectCreate(fiboName,OBJ_REGRESSION,0,Time[0],High[HighestCandle],Time[30],Low[LowestCandle]);
   ObjectSet(fiboName,OBJPROP_COLOR,Blue);
   ObjectSet(fiboName,OBJPROP_BACK,true);
   ObjectSet(fiboName,OBJPROP_WIDTH,3);
   ObjectSet(fiboName,OBJPROP_FIBOLEVELS,25);
   ObjectSet(fiboName,OBJPROP_LEVELCOLOR,Blue);
   ObjectSet(fiboName,OBJPROP_LEVELWIDTH,3);
//---

   ObjectSet(fiboName,OBJPROP_FIRSTLEVEL+0,-3.236);
   ObjectSetFiboDescription(regression,0,"SL 3= %$");
   ObjectSet(fiboName,OBJPROP_FIRSTLEVEL+1,-1.618);
   ObjectSetFiboDescription(regression,1,"SL 2= %$");
   ObjectSet(fiboName,OBJPROP_FIRSTLEVEL+2,-0.618);
   ObjectSetFiboDescription(regression,2,"SL 1= %$");
   ObjectSet(fiboName,OBJPROP_FIRSTLEVEL+3,0.000);
   ObjectSetFiboDescription(fiboName,3,"Lowest Shadow= %$");
   ObjectSet(fiboName,OBJPROP_FIRSTLEVEL+4,1.000);
   ObjectSetFiboDescription(fiboName,4,"Entry= %$");
   ObjectSet(fiboName,OBJPROP_FIRSTLEVEL+5,1.618);
   ObjectSetFiboDescription(fiboName,5,"TP 1= %$");
   ObjectSet(fiboName,OBJPROP_FIRSTLEVEL+6,2.618);
   ObjectSetFiboDescription(fiboName,6,"TP 2= %$");
   ObjectSet(fiboName,OBJPROP_FIRSTLEVEL+7,4.236);
   ObjectSetFiboDescription(fiboName,7,"TP 3= %$");
//----
   
   ObjectSet(fiboName,OBJPROP_RAY,false);
   ObjectSet(fiboName,OBJPROP_RAY_RIGHT,false);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawFiboSimpleSell(string fiboName,datetime firstTime,double firstPrice,datetime secondTime,double secondPrice)
  {
   int HighestCandle=iHighest(Symbol(),Period(),MODE_OPEN,30,0);
   int LowestCandle=iLowest(Symbol(),Period(),MODE_CLOSE,1,0);

   ObjectDelete("TradeExpert_FiboBuy");
   ObjectDelete("TradeExpert_FiboSell");


   ObjectCreate(fiboName,OBJ_FIBO,0,Time[0],Low[LowestCandle],Time[30],High[HighestCandle]);
   ObjectSet(fiboName,OBJPROP_COLOR,Red);
   ObjectSet(fiboName,OBJPROP_BACK,true);
   ObjectSet(fiboName,OBJPROP_WIDTH,3);
   ObjectSet(fiboName,OBJPROP_FIBOLEVELS,25);
   ObjectSet(fiboName,OBJPROP_LEVELCOLOR,Red);
   ObjectSet(fiboName,OBJPROP_LEVELWIDTH,3);
//---

   ObjectSet(fiboName,OBJPROP_FIRSTLEVEL+0,-3.236);
   ObjectSetFiboDescription(fiboName,0,"SL 3= %$");
   ObjectSet(fiboName,OBJPROP_FIRSTLEVEL+1,-1.618);
   ObjectSetFiboDescription(fiboName,1,"SL 2= %$");
   ObjectSet(fiboName,OBJPROP_FIRSTLEVEL+2,-0.618);
   ObjectSetFiboDescription(fiboName,2,"SL 1= %$");
   ObjectSet(fiboName,OBJPROP_FIRSTLEVEL+3,0.000);
   ObjectSetFiboDescription(fiboName,3,"Highest Shadow= %$");
   ObjectSet(fiboName,OBJPROP_FIRSTLEVEL+4,1.000);
   ObjectSetFiboDescription(fiboName,4,"Entry= %$");
   ObjectSet(fiboName,OBJPROP_FIRSTLEVEL+5,1.618);
   ObjectSetFiboDescription(fiboName,5,"TP 1= %$");
   ObjectSet(fiboName,OBJPROP_FIRSTLEVEL+6,2.618);
   ObjectSetFiboDescription(fiboName,6,"TP 2= %$");
   ObjectSet(fiboName,OBJPROP_FIRSTLEVEL+7,4.236);
   ObjectSetFiboDescription(fiboName,7,"TP 3= %$");
//----
   ObjectSet(fiboName,OBJPROP_RAY,false);
   ObjectSet(fiboName,OBJPROP_RAY_RIGHT,false);



  }

 