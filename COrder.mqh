

//+------------------------------------------------------------------+
//|   Include                                                        |
//+------------------------------------------------------------------+
  #include <stdlib.mqh>
#include <stderror.mqh>
#include <Arrays\List.mqh>
#include <Arrays\ArrayString.mqh>
#include <DiscordTelegram/Common.mqh>
#include <DiscordTelegram/Jason.mqh>

#include <DoEasy\Engine.mqh>
#ifdef __MQL5__
#include <Trade\Trade.mqh>
#endif 
#include <DiscordTelegram/Comment.mqh>

#include  <Arrays/List.mqh>
#include <DiscordTelegram/Telegram.mqh>



#define TOTAL_BUTT   (20)
//--- structures
struct SDataButt
  {
   string      name;
   string      text;
  };
 
 
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



   
//+------------------------------------------------------------------+
//|   ChatActionToString                                             |
//+------------------------------------------------------------------+
string ChatActionToString(const ENUM_CHAT_ACTION _action)
{
   string result=EnumToString(_action);
   result=StringSubstr(result,7);
   StringToLower(result);
   return(result);
}
;
 enum MARKET_SELECTION{ FOREX, CRYPTO_MARKET,STOCKS,INDEX}
;

enum MODE
{ 
Alert_Only, Manual, AutoTrade, Mixed,
HEDGE,NORMAL,MARTINGALE,MARTINGALE_STEPPING};


 enum PLATFORM{ TELEGRAM,DISCORD,TWITTER, FACEBOOK,WHATSAPP};
enum MONEY_MANAGEMENT{

M1=1,//Risk per Trade
M2=2,//Position Size
M3=3,//Martingale/Antimartingale
M4=4//Martingale Stepping
};

enum Filteration
  {
   
   B1=1, //M5 < M30
   B2=2, //M5 < H1
   B3=3, //M5 < M30 + DOM by BULLVSBEAR®
   B4=4, //M5 < H1  + DOM by BULLVSBEAR®
  };
input             Filteration FILTER SELECTION=B4;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum TrendFilter
  {
   E1=1, //Relative Strength Index
   E2=2, //Stochastic_Old Technique
   E3=3,//CCI
   E4=4//OBV
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
input             Mode MODE SELECTION=C2;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum TradeMode
  {
   D1=1, //Normal Style
   
   D2=2, //Hedging Style
   D3=3, //Normal Martingale Style
  D4=4//Martingale Stepping Style
  };
enum STATUS {ON=1,OFF=0};
//SYMBOLS DYNAMIC  SCANNER






//|-----------------------------------------------------------------------------------------|
//|                                O R D E R S   S T A T U S                                |
//|-----------------------------------------------------------------------------------------|

string BotOrdersTotal(bool noPending=true)
{
   int count=0;
   int total=OrdersTotal();
//--- Assert optimize function by checking total > 0
   if( total<=0 ) return( strBotInt("Total", count) );   
//--- Assert optimize function by checking noPending = false
   if( noPending==false ) return( strBotInt("Total", total) );
   
//--- Assert determine count of all trades that are opened
   for(int i=0;i<total;i++) {
      int go=OrderSelect( i, SELECT_BY_POS, MODE_TRADES );
   //--- Assert OrderType is either BUY or SELL
      if( OrderType() <= 1 ) count++;
   }
   return( strBotInt( "Total", count ) );
}

string BotOrdersTrade(bool noPending=true)
{
   int count=0;
   string msg="";
   const string strPartial="from #";
   int total=OrdersTotal();
//--- Assert optimize function by checking total > 0
   if( total<=0 ) return( msg );   

//--- Assert determine count of all trades that are opened
   for(int i=0;i<total;i++) {
      int jy=OrderSelect( i, SELECT_BY_POS, MODE_TRADES );

   //--- Assert OrderType is either BUY or SELL if noPending=true
      if( noPending==true && OrderType() > 1 ) continue ;
      else count++;

      msg = StringConcatenate(msg, strBotInt( "Ticket",OrderTicket() ));
      msg = StringConcatenate(msg, strBotStr( "Symbol",OrderSymbol() ));
      msg = StringConcatenate(msg, strBotInt( "Type",OrderType() ));
      msg = StringConcatenate(msg, strBotDbl( "Lots",OrderLots(),2 ));
      msg = StringConcatenate(msg, strBotDbl( "OpenPrice",OrderOpenPrice(),5 ));
      msg = StringConcatenate(msg, strBotDbl( "CurPrice",OrderClosePrice(),5 ));
      msg = StringConcatenate(msg, strBotDbl( "StopLoss",OrderStopLoss(),5 ));
      msg = StringConcatenate(msg, strBotDbl( "TakeProfit",OrderTakeProfit(),5 ));
      msg = StringConcatenate(msg, strBotTme( "OpenTime",OrderOpenTime() ));
      msg = StringConcatenate(msg, strBotTme( "CloseTime",OrderCloseTime() ));
      
   //--- Assert Partial Trade has comment="from #<historyTicket>"
      if( StringFind( OrderComment(), strPartial )>=0 )
         msg = StringConcatenate(msg, strBotStr( "PrevTicket", StringSubstr(OrderComment(),StringLen(strPartial)) ));
      else
         msg = StringConcatenate(msg, strBotStr( "PrevTicket", "0" ));
   }
//--- Assert msg isnt empty
   if( msg=="" ) return( msg );   
   
//--- Assert append count of trades
   msg = StringConcatenate(strBotInt( "Count",count ), msg);
   return( msg );
}

string BotOrdersTicket(int ticket, bool noPending=true)
{string gh;

for(int a=0;a<OrdersHistoryTotal()-1;a++){

if(OrderSelect(a,SELECT_BY_POS,MODE_HISTORY)){
 gh=(string)"Ticket: "+(string)OrderTicket()+"  "+ "DATE"+(string) TimeCurrent();
}


};


   return( gh );
}

string BotHistoryTicket(int ticket, bool noPending=true)
{
   string msg=NL;
   const string strPartial="from #";
   int total=OrdersHistoryTotal();
//--- Assert optimize function by checking total > 0
   if( total<=0 ) return( msg );   
for(int j=total;j>0;j--){
//--- Assert determine history by ticket
   if( OrderSelect( ticket, SELECT_BY_TICKET, MODE_HISTORY )==false ) return( msg );
   if( OrderSelect( j, SELECT_BY_TICKET, MODE_HISTORY )==true ){
//--- Assert OrderType is either BUY or SELL if noPending=true
   if( noPending==true && OrderType() >=0 ) return( msg );
      
//--- Assert OrderTicket is found

   msg = StringConcatenate(msg, strBotStr( "Date",(string)TimeCurrent() ));
   msg = StringConcatenate(msg, strBotInt( "Ticket",OrderTicket() ));
   msg = StringConcatenate(msg, strBotStr( "Symbol",OrderSymbol() ));
   msg = StringConcatenate(msg, strBotInt( "Type",OrderType() ));
   msg = StringConcatenate(msg, strBotDbl( "Lots",OrderLots(),2 ));
   msg = StringConcatenate(msg, strBotDbl( "OpenPrice",OrderOpenPrice(),5 ));
   msg = StringConcatenate(msg, strBotDbl( "ClosePrice",OrderClosePrice(),5 ));
   msg = StringConcatenate(msg, strBotDbl( "StopLoss",OrderStopLoss(),5 ));
   msg = StringConcatenate(msg, strBotDbl( "TakeProfit",OrderTakeProfit(),5 ));
   msg = StringConcatenate(msg, strBotTme( "OpenTime",OrderOpenTime() ));
   msg = StringConcatenate(msg, strBotTme( "CloseTime",OrderCloseTime() ));
   
//--- Assert Partial Trade has comment="from #<historyTicket>"
   if( StringFind( OrderComment(), strPartial )>=0 )
      msg = StringConcatenate(msg, strBotStr( "PrevTicket", StringSubstr(OrderComment(),StringLen(strPartial)) ));
   else
      msg = StringConcatenate(msg, strBotStr( "PrevTicket", "0" ));
}};
   return( msg );
}

string BotOrdersHistoryTotal(bool noPending=true)
{
   return( strBotInt( "Total", OrdersHistoryTotal() ) );
}


string tradeReport(bool noPending=true){
string  report="None";
for(int j=OrdersHistoryTotal()-1;j>0;j--){
if(OrderSelect(j,SELECT_BY_TICKET,MODE_HISTORY )==false){
if(OrderProfit()>0){
report+="Total Profit : "+ (string)OrderProfit()+ "  "+(string)TimeCurrent() ;


};
if(OrderProfit()<0){
report+="Total Losses: "+ (string)OrderProfit()+"  "+(string)TimeCurrent();


};

};

}

return report;
}
//|-----------------------------------------------------------------------------------------|
//|                               A C C O U N T   S T A T U S                               |
//|-----------------------------------------------------------------------------------------|
string BotAccount(void)
{
   string msg=NL;

   msg = StringConcatenate(msg, strBotInt( "Number",AccountNumber() ));
   msg = StringConcatenate(msg, strBotStr( "Currency",AccountCurrency() ));
   msg = StringConcatenate(msg, strBotDbl( "Balance",AccountBalance(),2 ));
   msg = StringConcatenate(msg, strBotDbl( "Equity",AccountEquity(),2 ));
   msg = StringConcatenate(msg, strBotDbl( "Margin",AccountMargin(),2 ));
   msg = StringConcatenate(msg, strBotDbl( "FreeMargin",AccountFreeMargin(),2 ));
   msg = StringConcatenate(msg, strBotDbl( "Profit",AccountProfit(),2 ));
   
   return( msg );
}


//|-----------------------------------------------------------------------------------------|
//|                           I N T E R N A L   F U N C T I O N S                           |
//|-----------------------------------------------------------------------------------------|
string strBotInt(string key, int val)
{
   return( StringConcatenate(NL,key,"=",val) );
}
string strBotDbl(string key, double val, int dgt=5)
{
   return( StringConcatenate(NL,key,"=",NormalizeDouble(val,dgt)) );
}
string strBotTme(string key, datetime val)
{
   return( StringConcatenate(NL,key,"=",TimeToString(val)) );
}
string strBotStr(string key, string val)
{
   return( StringConcatenate(NL,key,"=",val) );
}
string strBotBln(string key, bool val)
{
   string valType;
   if( val )   valType="true";
   else        valType="false";
   return( StringConcatenate(NL,key,"=",valType) );
}  




//+------------------------------------------------------------------+
//|   CMyBot                                                         |
//+------------------------------------------------------------------+
class CMyBot: public CCustomBot
{
private:
   ENUM_LANGUAGES    m_lang;
   string            m_symbol;
   ENUM_TIMEFRAMES   m_period;
   string            m_template;
   CArrayString      m_templates;

public:
   //+------------------------------------------------------------------+
   void              Language(const ENUM_LANGUAGES _lang)
   {
      m_lang=_lang;
   }

   //+------------------------------------------------------------------+
   int               Templates(const string _list)
   {
      m_templates.Clear();
      //--- parsing
      string text=StringTrim(_list);
      if(text=="")
         return(0);

      //---
      while(StringReplace(text,"  "," ")>0);
      StringReplace(text,";"," ");
      StringReplace(text,","," ");

      //---
      string array[];
      int amount=StringSplit(text,' ',array);
      amount=fmin(amount,5);

      for(int i=0; i<amount; i++)
      {
         array[i]=StringTrim(array[i]);
         if(array[i]!="")
            m_templates.Add(array[i]);
      }

      return(amount);
   }

   //+------------------------------------------------------------------+
   int               SendScreenShot(const long _chat_id,
                                    const string _symbol,
                                    const ENUM_TIMEFRAMES _period,
                                    const string _template=NULL)
   {
      int result=0;

      long chart_id=ChartOpen(_symbol,_period);
      if(chart_id==0)
         return(ERR_CHART_NOT_FOUND);

      ChartSetInteger(ChartID(),CHART_BRING_TO_TOP,true);

      //--- updates chart
      int wait=60;
      while(--wait>0)
      {
         if(SeriesInfoInteger(_symbol,_period,SERIES_SYNCHRONIZED))
            break;
         Sleep(500);
      }

      if(_template!=NULL)
         if(!ChartApplyTemplate(chart_id,_template))
            PrintError(_LastError,InpLanguage);

      ChartRedraw(chart_id);
      Sleep(500);

      ChartSetInteger(chart_id,CHART_SHOW_GRID,false);

      ChartSetInteger(chart_id,CHART_SHOW_PERIOD_SEP,false);

      string filename=StringFormat("%s%d.gif",_symbol,_period);

      if(FileIsExist(filename))
         FileDelete(filename);
      ChartRedraw(chart_id);

      Sleep(100);

      if(ChartScreenShot(chart_id,filename,800,600,ALIGN_RIGHT))
      {
         
         Sleep(100);
         
         //--- Need for MT4 on weekends !!!
         ChartRedraw(chart_id);
         
         bot.SendChatAction(_chat_id,ACTION_UPLOAD_PHOTO);

         //--- waitng 30 sec for save screenshot
         wait=60;
         while(!FileIsExist(filename) && --wait>0)
            Sleep(500);

         //---
         if(FileIsExist(filename))
         {
            string screen_id;
            result=bot.SendPhoto(screen_id,_chat_id,filename,_symbol+"_"+StringSubstr(EnumToString(_period),7));
         }
         else
         {
            string mask=m_lang==LANGUAGE_EN?"Screenshot file '%s' not created.":"Файл скриншота '%s' не создан.";
            PrintFormat(mask,filename);
         }
      }

      ChartClose(chart_id);
      return(result);
   }
   //+------------------------------------------------------------------+
   int               SendScreenShotToChat(const long _chat_id,
                                    const string _symbol,
                                    const ENUM_TIMEFRAMES _period,
             
                                    const string _template=NULL ,
                                    bool SendScreenShots=True)
   {int result=0;
      if(SendScreenShots==true){
      
      


        
      long chart_id=ChartOpen(_symbol,_period);
      
      Set Chart Colors=BackGround;
      if(chart_id==0)
         return(ERR_CHART_NOT_FOUND);

      ChartSetInteger(ChartID(),CHART_BRING_TO_TOP,true);

      //--- updates chart
      int wait=60;
      while(--wait>0)
      {
         if(SeriesInfoInteger(_symbol,_period,SERIES_SYNCHRONIZED))
          break;
         Sleep(100);
      }

      if(_template!=NULL)
         if(!ChartApplyTemplate(chart_id,_template))
            PrintError(_LastError);

      ChartRedraw(chart_id);
      Sleep(60);

      ChartSetInteger(chart_id,CHART_SHOW_GRID,false);

      ChartSetInteger(chart_id,CHART_SHOW_PERIOD_SEP,false);

      string filename=StringFormat("%s%d.gif",_symbol,_period);

      if(FileIsExist(filename))
         FileDelete(filename);
      ChartRedraw(chart_id);

      Sleep(30);
 Set Chart Colors=BackGround;
      if(ChartScreenShot(chart_id,filename,800,600,ALIGN_RIGHT))
      {
         
         Sleep(30);
         
         //--- Need for MT4 on weekends !!!
         ChartRedraw(chart_id);
         
       SendChatAction(msgs.chat_id,ACTION_UPLOAD_PHOTO);

         //--- waitng 30 sec for save screenshot
         wait=60;
         while(!FileIsExist(filename) && --wait>0)
            Sleep(60);

         //---
         if(FileIsExist(filename))
         {
            string screen_id;
            result=SendPhoto(screen_id,_chat_id,filename,_symbol+"_"+StringSubstr(EnumToString(_period),7));
         }
         else
         {
            string mask=m_lang==LANGUAGE_EN?"Screenshot file '%s' not created.":"Файл скриншота '%s' не создан.";
            PrintFormat(mask,filename);
         }
         
      ChartClose(chart_id);
      }
}
      return(result);
   }

   //+------------------------------------------------------------------+
   int               SendScreenShotToChannel(const string  channel_id,
                                    const string _symbol,
                                    const ENUM_TIMEFRAMES _period,
      
                                    const string _template,bool SendScreenShotss=false)
   {
   
     int result=0;


   if(SendScreenShotss==true){
    
      long chart_id=ChartOpen(_symbol,_period);
      
   
      if(chart_id==0)
         return(ERR_CHART_NOT_FOUND);

      ChartSetInteger(chart_id,CHART_BRING_TO_TOP,true);

      //--- updates chart 
         SendChatAction(chart_id,ACTION_TYPING);
      int wait=60;
      while(--wait>0)
      {
    
         if(SeriesInfoInteger(_symbol,_period,SERIES_SYNCHRONIZED))
           
         Sleep(500);
         break;
      }
                       
      if(_template!=NULL)
         if(!ChartApplyTemplate(chart_id,_template))
            Comment(_LastError);

      ChartRedraw(chart_id);
      Sleep(30);

      ChartSetInteger(chart_id,CHART_SHOW_GRID,false);

      ChartSetInteger(chart_id,CHART_SHOW_PERIOD_SEP,false);

    string filename=StringFormat("%s%d.gif",_symbol,_period);

      if(FileIsExist(filename))
         FileDelete(filename);
      ChartRedraw(chart_id);

      Sleep(30);
     
ChartColorSet();
      if(ChartScreenShot(chart_id,filename,chartWidth,ChartHight,ALIGN_RIGHT))
      {
         
         Sleep(500);
         
         //--- Need for MT4 on weekends !!!
         ChartRedraw(chart_id);
            //--- waitng 30 sec for save screenshot
         wait=30;
         while(!FileIsExist(filename) && --wait>0)
            Sleep(30);

         //---
         if(FileIsExist(filename))
         {
            string screen_id;
              SendChatAction(msgs.chat_id,ACTION_UPLOAD_PHOTO);

            result=SendPhoto(screen_id,channel_id,filename,_symbol+"_"+StringSubstr(EnumToString(_period),7));
         
         }
         else
         {
            string mask=m_lang==LANGUAGE_EN?"Screenshot file '%s' not created.":"Файл скриншота '%s' не создан.";
            PrintFormat(mask,filename);
            SendChatAction(chart_id,ACTION_TYPING);

           SendMessage(channel_id,mask +filename,false,false);
            
         }
      }

      ChartClose(chart_id);
      
      }
      return(result);
   }
   
 
   



   //+------------------------------------------------------------------+
   void              ProcessMessages(void)
   {

#define EMOJI_TOP    "\xF51D"
#define EMOJI_BACK   "\xF519"
#define KEYB_MAIN    (m_lang==LANGUAGE_EN)?"[[\"Account Info\"],[\"Quotes\"],[\"Charts\"],[\"/ordertrade\"],[\"/ordertotal\"],[\"/ticket\"],[\"/historytotal\"],[\"/ tradeReport\"]]":"[[\"Информация\"],[\"Котировки\"],[\"Графики\"]]"
#define KEYB_SYMBOLS "[[\""+EMOJI_TOP+"\",\"GBPUSD\",\"EURUSD\"],[\"AUDUSD\",\"USDJPY\",\"EURJPY\"],[\"USDCAD\",\"USDCHF\",\"EURCHF\"]]"
#define KEYB_PERIODS "[[\""+EMOJI_TOP+"\",\"M1\",\"M5\",\"M15\"],[\""+EMOJI_BACK+"\",\"M30\",\"H1\",\"H4\"],[\" \",\"D1\",\"W1\",\"MN1\"]]"

      for(int i=0; i<m_chats.Total(); i++)
      {
      string msg=NL;
      const string strOrderTrade="/ordertrade";
      const string strHistoryTicket="/historyticket";
      int pos=0, ticket=0;
         CCustomChat *chat=m_chats.GetNodeAtIndex(i);
         if(!chat.m_new_one.done)
         {
            chat.m_new_one.done=true;
            string text=chat.m_new_one.message_text;

            //--- start
            if(text=="/start" || text=="/help")
            {
               chat.m_state=0;
               msg="The bot works with your trading account:\n";
               msg+="/info - get account information\n";
               msg+="/quotes - get quotes\n";
               msg+="/charts - get chart images\n";

               if(m_lang==LANGUAGE_RU)
               {
                  msg="Бот работает с вашим торговым счетом:\n";
                  msg+="/info - запросить информацию по счету\n";
                  msg+="/quotes - запросить котировки\n";
                  msg+="/charts - запросить график\n";
               }

               SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(KEYB_MAIN,false,false));
               continue;
            }

            //---
            if(text==EMOJI_TOP)
            {
               chat.m_state=0;
             msg=(m_lang==LANGUAGE_EN)?"Choose a menu item":"Выберите пункт меню";
               SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(KEYB_MAIN,false,false));
               continue;
            }

            //---
            if(text==EMOJI_BACK)
            {
               if(chat.m_state==31)
               {
                  chat.m_state=3;
                  msg=(m_lang==LANGUAGE_EN)?"Enter a symbol name like 'EURUSD'":"Введите название инструмента, например 'EURUSD'";
                  SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(KEYB_SYMBOLS,false,false));
               }
               else if(chat.m_state==32)
               {
                  chat.m_state=31;
                msg=(m_lang==LANGUAGE_EN)?"Select a timeframe like 'H1'":"Введите период графика, например 'H1'";
                  SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(KEYB_PERIODS,false,false));
               }
               else
               {
                  chat.m_state=0;
                  msg=(m_lang==LANGUAGE_EN)?"Choose a menu item":"Выберите пункт меню";
                  SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(KEYB_MAIN,false,false));
               }
               continue;
            }

            //---
            if(text=="/info" || text=="Account Info" || text=="Информация")
            {
               chat.m_state=1;
               string currency=AccountInfoString(ACCOUNT_CURRENCY);
                
               
              msg=StringFormat("%d: %s\n",AccountInfoInteger(ACCOUNT_LOGIN),AccountInfoString(ACCOUNT_SERVER));
               
               msg+=StringFormat("%s: %s\n",(m_lang==LANGUAGE_EN)?"Date :":"Прибыль",(string)TimeCurrent());
               
               msg+=StringFormat("%s: %.2f %s\n",(m_lang==LANGUAGE_EN)?"Balance":"Баланс",AccountInfoDouble(ACCOUNT_BALANCE),currency);
               
                 msg+=StringFormat("%s: %.2f %s\n",(m_lang==LANGUAGE_EN)?"Equity":"Прибыль",AccountInfoDouble(ACCOUNT_EQUITY),currency);
               msg+=StringFormat("%s: %.2f %s\n",(m_lang==LANGUAGE_EN)?"Profit":"Прибыль",AccountInfoDouble(ACCOUNT_PROFIT),currency);
                 msg+=StringFormat("%s: %.2f %s\n",(m_lang==LANGUAGE_EN)?"Margin":"Прибыль",AccountInfoDouble(ACCOUNT_MARGIN),currency);
               
                 msg+=StringFormat("%s: %.2f %s\n",(m_lang==LANGUAGE_EN)?"Margin Free":"Прибыль",AccountInfoDouble(ACCOUNT_MARGIN_FREE),currency);
               
                 msg+=StringFormat("%s: %.2f %s\n",(m_lang==LANGUAGE_EN)?"Marging Initial":"Прибыль",AccountInfoDouble(ACCOUNT_MARGIN_INITIAL),currency);
                 msg+=StringFormat("%s: %.2f %s\n",(m_lang==LANGUAGE_EN)?"Margin_Maintenance":"Прибыль",AccountInfoDouble(ACCOUNT_MARGIN_MAINTENANCE),currency);
               
               msg+=StringFormat("%s: %.2f %s\n",(m_lang==LANGUAGE_EN)?"Margin_So_So_Call":"Прибыль",AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL),currency);
               
                
               msg+=StringFormat("%s: %.2f %s\n",(m_lang==LANGUAGE_EN)?"Margin_So_So":"Прибыль",AccountInfoDouble(ACCOUNT_MARGIN_SO_SO),currency);
               
               
               
               
               
               SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(KEYB_MAIN,false,false));
            }

            //---
            if(text=="/quotes" || text=="Quotes" || text=="Котировки")
            {
               chat.m_state=2;
              msg=(m_lang==LANGUAGE_EN)?"Enter a symbol name like 'EURUSD'":"Введите название инструмента, например 'EURUSD'";
               SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(KEYB_SYMBOLS,false,false));
               continue;
            }

            //---
            if(text=="/charts" || text=="Charts" || text=="Графики")
            {
               chat.m_state=3;
               msg=(m_lang==LANGUAGE_EN)?"Enter a symbol name like 'EURUSD'":"Введите название инструмента, например 'EURUSD'";
               SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(KEYB_SYMBOLS,false,false));
               continue;
            }
             
            if( text=="/ordertotal" ) {
               SendMessage( chat.m_id, BotOrdersTotal() );
            }
            
            if( StringFind( text, strOrderTrade )>=0 ) {
               pos =(int) StringToInteger( StringSubstr( text, StringLen(strOrderTrade)+1 ) );
               SendMessage( chat.m_id, BotOrdersTrade(pos) );
            }

            if( text=="/historytotal" ) {
               SendMessage( chat.m_id, BotOrdersHistoryTotal() );
            }

            if( StringFind( text, strHistoryTicket )>=0 ) {
               ticket =(int) StringToInteger( StringSubstr( text, StringLen(strHistoryTicket)+1 ) );
               SendMessage( chat.m_id, BotHistoryTicket(ticket) );
            }
            
            if( text=="/account" ) {
               SendMessage( chat.m_id, BotAccount() );
            }
          
            msg = StringConcatenate(msg,"My commands list:",NL);
            msg = StringConcatenate(msg,"/ordertotal-return count of orders",NL);
            msg = StringConcatenate(msg,"/ordertrade-return ALL opened orders",NL);
            msg = StringConcatenate(msg,"/orderticket <ticket>-return an order or a chain of history by ticket",NL);
            msg = StringConcatenate(msg,"/historytotal-return count of history",NL);
            msg = StringConcatenate(msg,"/historyticket <ticket>-return a history or chain of history by ticket",NL);
            msg = StringConcatenate(msg,"/account-return account info",NL);
            msg = StringConcatenate(msg,"/help-get help");
            if( text=="/help" ) {
               SendMessage( chat.m_id, msg );
            }

          if(text=="/tradeReport"){
          
           SendMessage(chat.m_id,  tradeReport());
          }

            //--- Quotes
            if(chat.m_state==2)
            {
               string mask=(m_lang==LANGUAGE_EN)?"Invalid symbol name '%s'":"Инструмент '%s' не найден";
              msg=StringFormat(mask,text);
               StringToUpper(text);
               string symbol=text;
               if(SymbolSelect(symbol,true))
               {
                  double open[1]= {0};

                  m_symbol=symbol;
                  //--- upload history
                  for(int k=0; k<3; k++)
                  {
#ifdef __MQL4__
                     double array[][6];
                     ArrayCopyRates(array,symbol,PERIOD_D1);
#endif

                     Sleep(2000);
                     CopyOpen(symbol,PERIOD_D1,0,1,open);
                     if(open[0]>0.0)
                        break;
                  }

                  int digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);
                  double bid=SymbolInfoDouble(symbol,SYMBOL_BID);

                  CopyOpen(symbol,PERIOD_D1,0,1,open);
                  if(open[0]>0.0)
                  {
                     double percent=100*(bid-open[0])/open[0];
                     //--- sign
                     string sign=ShortToString(0x25B2);
                     if(percent<0.0)
                        sign=ShortToString(0x25BC);

                     msg=StringFormat("%s: %s %s (%s%%)",symbol,DoubleToString(bid,digits),sign,DoubleToString(percent,2));
                  }
                  else
                  {
                     msg=(m_lang==LANGUAGE_EN)?"No history for ":"Нет истории для "+symbol;
                  }
               }

               SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(KEYB_SYMBOLS,false,false));
               continue;
            }

            //--- Charts
            if(chat.m_state==3)
            {

               StringToUpper(text);
               string symbol=text;
               if(SymbolSelect(symbol,true))
               {
                  m_symbol=symbol;

                  chat.m_state=31;
                  msg=(m_lang==LANGUAGE_EN)?"Select a timeframe like 'H1'":"Введите период графика, например 'H1'";
                  SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(KEYB_PERIODS,false,false));
               }
               else
               {
                  string mask=(m_lang==LANGUAGE_EN)?"Invalid symbol name '%s'":"Инструмент '%s' не найден";
                  msg=StringFormat(mask,text);
                  SendMessage(chat.m_id,msg,ReplyKeyboardMarkup(KEYB_SYMBOLS,false,false));
               }
               continue;
            }

            //Charts->Periods
            if(chat.m_state==31)
            {
               bool found=false;
               int total=ArraySize(_periods);
               for(int k=0; k<total; k++)
               {
                  string str_tf=StringSubstr(EnumToString(_periods[k]),7);
                  if(StringCompare(str_tf,text,false)==0)
                  {
                     m_period=_periods[k];
                     found=true;
                     break;
                  }
               }

               if(found)
               {
                  //--- template
                  chat.m_state=32;
                  string str="[[\""+EMOJI_BACK+"\",\""+EMOJI_TOP+"\"]";
                  str+=",[\"None\"]";
                  for(int k=0; k<m_templates.Total(); k++)
                     str+=",[\""+m_templates.At(k)+"\"]";
                  str+="]";

                  SendMessage(chat.m_id,(m_lang==LANGUAGE_EN)?"Select a template":"Выберите шаблон",ReplyKeyboardMarkup(str,false,false));
               }
               else
               {
                  SendMessage(chat.m_id,(m_lang==LANGUAGE_EN)?"Invalid timeframe":"Неправильно задан период графика",ReplyKeyboardMarkup(KEYB_PERIODS,false,false));
               }
               continue;
            }
            //---
            if(chat.m_state==32)
            {
               m_template=text;
               if(m_template=="None")
                  m_template=NULL;
               int result=SendScreenShot(chat.m_id,m_symbol,m_period,m_template);
               if(result!=0)
                  Print(GetErrorDescription(result,InpLanguage));
            }
         }
      }
   }
};


const ENUM_TIMEFRAMES _periods[] = {PERIOD_M1,PERIOD_M5,PERIOD_M15,PERIOD_M30,PERIOD_H1,PERIOD_H4,PERIOD_D1,PERIOD_W1,PERIOD_MN1};


class Order
  {
private:

int LotDigits;
CList OrderList;

double price,sl,tp;

datetime expiration;

double Order_StopLoss, Order_TakeProfit;//set sl an d tp

double Order_Trailing_Stop_Loss;//set order trail stop loss

double Order_Trailing_Take_Profit;//set order trailing take profit
		
double Order_Lot;// set Order lot
		
datetime Order_Open_Time, Order_Close_Time;
	
double Order_Loss,Order_Profit;
	
string  Order_Symbol;
		
		 
int Order_Ticket;
double Order_ClosePrice;
double Order_CloseBy;
datetime Order_CloseTime;
int Order_MagicNumber;

color clr;


double Order_Commission;

datetime Order_Expiration_Time;

double Order_OpenPrice;

double Order_CurrentPrice,profit,losses;
string Order_Comment ;
int Order_Type; datetime Order_Close_Times;
int NextOpenTradeAfterHours ;//next open trade after time

public:

void Order(){









}



void setMM_Martingale_ProfitFactor(double ProfitFactor){MM_Martingale_ProfitFactor=ProfitFactor;};
double getMM_Martingale_ProfitFactor(){return MM_Martingale_ProfitFactor;};


void  setMM_Martingale_Start(double Lot){ MM_Martingale_Start=Lot;}
double getMartingale_Start(){return MM_Martingale_Start ;};


void setMM_Martingale_RestartLoss (double restartlot){MM_Martingale_RestartLoss=restartlot;};
double getMM_Martingale_RestartLoss(){return MM_Martingale_RestartLoss ;};


void setMM_Martingale_LossFactor (double LossFactor ){ MM_Martingale_LossFactor=LossFactor;};
double getMM_Martingale_LossFactor(){return  MM_Martingale_LossFactor ;} ;

void setMM_Martingale_RestartProfit(int RestartProfit){MM_Martingale_RestartProfit=RestartProfit;};
double getMM_Martingale_RestartProfit(){return MM_Martingale_RestartProfit;};

void setMM_Martingale_RestartLosses(int Restart_Losses){MM_Martingale_RestartLosses=Restart_Losses;};
double getMM_Martingale_RestartLosses(){return MM_Martingale_RestartLosses;};




double Martingale_Trade_Size() //martingale / anti-martingale
  {
  
double lots = getMartingale_Start();
   double MaxLot = MarketInfo(Symbol(), MODE_MAXLOT);
   double MinLot = MarketInfo(Symbol(), MODE_MINLOT);
   if(SelectLastHistoryTrade())
     {
      double orderprofit = OrderProfit();
      double orderlots = OrderLots();
      double boprofit = BOProfit(OrderTicket());
      if(orderprofit + boprofit > 0 && !MM_Martingale_RestartProfit)
         lots = orderlots * getMM_Martingale_ProfitFactor();
      else if(orderprofit + boprofit < 0 && !getMM_Martingale_RestartLoss())
         lots = orderlots * getMM_Martingale_LossFactor();
      else if(orderprofit + boprofit == 0)
         lots = orderlots;
     }
   if(ConsecutivePL(false, MM_Martingale_RestartLosses))
      lots = MM_Martingale_Start;
   if(ConsecutivePL(true, MM_Martingale_RestartProfits))
      lots =getMartingale_Start();
   if(lots > MaxLot) lots = MaxLot;
   if(lots < MinLot) lots = MinLot;

   
   for(int j=OrdersHistoryTotal()-1;j>0;j--){
   if(OrderSelect(j,SELECT_BY_TICKET)){
   
    
   if(OrderProfit()<0 &&OrderProfit()>-2){
   
  return lots=MarketInfo(Symbol(), MODE_MINLOT);
   }else if( OrderProfit()>0){
   
   
   return lots*2;
   
   }else if(OrderProfit()<10){
   
   return lots*lots;
   }
   
   
   
   }
   
   
   }


   return(lots);
  }



double BOProfit(int ticket) //Binary Options profit
  {
   int total = OrdersHistoryTotal();
   for(int i = total-1; i >= 0; i--)
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) continue;
      if(StringSubstr(OrderComment(), 0, 2) == "BO" && StringFind(OrderComment(), "#"+IntegerToString(ticket)+" ") >= 0)
         return OrderProfit();
     }
   return 0;
  }

bool ConsecutivePL(bool profits, int n)
  {
   int count = 0;
   int total = OrdersHistoryTotal();
   for(int i = total-1; i >= 0; i--)
     {  double p=0,L=0;
      if(!OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) continue;
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == getOrder_MagicNumber() &&OrderCloseTime()<TimeDay(TimeCurrent()))
        {
         double orderprofit = OrderProfit();
         double boprofit = BOProfit(OrderTicket());
         if((!profits && orderprofit + boprofit >= 0) || (profits && orderprofit + boprofit <= 0))
             p+=orderprofit;
             
              if(OrderProfit()<0){L+=OrderProfit();};
           
            break;
            
           
         count++;
        }
         PrintFormat("Profit :%2.4f, Losses:%2.4f",p,L);
     }
     
   return(count >= n);
  }




bool inTimeInterval(datetime t, int From_Hour, int From_Min, int To_Hour, int To_Min)
  {
   string TOD = TimeToString(t, TIME_MINUTES);
   string TOD_From = StringFormat("%02d", From_Hour)+":"+StringFormat("%02d", From_Min);
   string TOD_To = StringFormat("%02d", To_Hour)+":"+StringFormat("%02d", To_Min);
   return((StringCompare(TOD, TOD_From) >= 0 && StringCompare(TOD, TOD_To) <= 0)
     || (StringCompare(TOD_From, TOD_To) > 0
       && ((StringCompare(TOD, TOD_From) >= 0 && StringCompare(TOD, "23:59") <= 0)
         || (StringCompare(TOD, "00:00") >= 0 && StringCompare(TOD, TOD_To) <= 0))));
  }

void CloseByDuration(int sec) //close trades opened longer than sec seconds
  {
   if(!IsTradeAllowed()) return;
   bool success = false;
   int err = 0;
   int total = OrdersTotal();
   int orderList[][2];
   int orderCount = 0;
   int i;
   for(i = 0; i < total; i++)
     {
      while(IsTradeContextBusy()) Sleep(100);
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if(OrderMagicNumber() != Order_MagicNumber || OrderSymbol() != Symbol() || OrderType() > 1 || OrderOpenTime() + sec > TimeCurrent()) continue;
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
      while(IsTradeContextBusy()) Sleep(100);
      RefreshRates();
      price = Bid;
      if(OrderType() == OP_SELL)
         price = Ask;
      success = OrderClose(OrderTicket(), NormalizeDouble(OrderLots(), LotDigits), NormalizeDouble(price, Digits()), MaxSlippage, clrWhite);
      if(!success)
        {
         err = GetLastError();
         myAlert("error", "OrderClose failed; error #"+IntegerToString(err)+" ");
        }
     }
   if(success) myAlert("order", "Orders closed by duration: "+Symbol()+" Magic #"+IntegerToString(Order_MagicNumber));
  }

void DeleteByDuration(int sec) //delete pending order after time since placing the order
  {
   if(!IsTradeAllowed()) return;
   bool success = false;
   int err = 0;
   int total = OrdersTotal();
   int orderList[][2];
   int orderCount = 0;
   int i;
   for(i = 0; i < total; i++)
     {
      while(IsTradeContextBusy()) Sleep(100);
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if(OrderMagicNumber() != Order_MagicNumber || OrderSymbol() != Symbol() || OrderType() <= 1 || OrderOpenTime() + sec > TimeCurrent()) continue;
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
      while(IsTradeContextBusy()) Sleep(100);
      RefreshRates();
      success = OrderDelete(OrderTicket());
      if(!success)
        {
         err = GetLastError();
         myAlert("error", "OrderDelete failed; error #"+IntegerToString(err)+" ");
        }
     }
   if(success) myAlert("order", "Orders deleted by duration: "+Symbol()+" Magic #"+IntegerToString(Order_MagicNumber));
  }

void DeleteByDistance(double distance) //delete pending order if price went too far from it
  {
   if(!IsTradeAllowed()) return;
   bool success = false;
   int err = 0;
   int total = OrdersTotal();
   int orderList[][2];
   int orderCount = 0;
   int i;
   for(i = 0; i < total; i++)
     {
      while(IsTradeContextBusy()) Sleep(100);
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if(OrderMagicNumber() != Order_MagicNumber || OrderSymbol() != Symbol() || OrderType() <= 1) continue;
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
      while(IsTradeContextBusy()) Sleep(100);
      RefreshRates();
    price = (OrderType() % 2 == 1) ? Ask : Bid;
      if(MathAbs(OrderOpenPrice() - price) <= distance) continue;
      success = OrderDelete(OrderTicket());
      if(!success)
        {
         err = GetLastError();
         myAlert("error", "OrderDelete failed; error #"+IntegerToString(err)+" ");
        }
     }
   if(success) myAlert("order", "Orders deleted by distance: "+Symbol()+" Magic #"+IntegerToString(Order_MagicNumber));
  }

double MM_Size() //position sizing
  {
   double MaxLot=0;
   
   if( MaxLot==0){ MaxLot = MarketInfo(Symbol(), MODE_MAXLOT);}
   double MinLot = MarketInfo(Symbol(), MODE_MINLOT);
   double lots = AccountBalance()/10000;
   if(lots > MaxLot) lots = MaxLot;
   if(lots < MinLot) lots = MinLot;
   return(lots);
  }

bool TradeDayOfWeek()
  {
   int day = DayOfWeek();
   return((TradeMonday && day == 1)
   || (TradeTuesday && day == 2)
   || (TradeWednesday && day == 3)
   || (TradeThursday && day == 4)
   || (TradeFriday && day == 5)
   || (TradeSaturday && day == 6)
   || (TradeSunday && day == 0));
  }

void myAlert(string type, string message)
  {
   int handle;
   if(type == "print")
      Print(message);
   else if(type == "error")
     {
      Print(type+" |"+IndicatorName+Symbol()+","+IntegerToString(Period())+" | "+message);
     }
   else if(type == "order")
     {
      Print(type+"|" +IndicatorName+" "+Symbol()+","+IntegerToString(Period())+" | "+message);
      if(Audible_Alerts) Alert(type+" |  "+Symbol()+","+IntegerToString(Period())+" | "+message);
      if(Send_Email) SendMail(IndicatorName, type+" | "+IndicatorName+Symbol()+","+IntegerToString(Period())+" | "+message);
      handle = FileOpen(IndicatorName, FILE_TXT|FILE_READ|FILE_WRITE|FILE_SHARE_READ|FILE_SHARE_WRITE, ';');
      if(handle != INVALID_HANDLE)
        {
         FileSeek(handle, 0, SEEK_END);
         FileWrite(handle, type+" | "+IndicatorName+Symbol()+","+IntegerToString(Period())+" | "+message);
         FileClose(handle);
        }
      if(Push_Notifications) SendNotification(type+" |  "+IndicatorName+Symbol()+","+IntegerToString(Period())+" | "+message);
     }
   else if(type == "modify")
     {
      Print(type+" |  "+IndicatorName+Symbol()+","+IntegerToString(Period())+" | "+message);
      if(Audible_Alerts) Alert(type+" | "+IndicatorName+Symbol()+","+IntegerToString(Period())+" | "+message);
      if(Send_Email) SendMail(IndicatorName, type+" |"+IndicatorName+Symbol()+","+IntegerToString(Period())+" | "+message);
      handle = FileOpen(IndicatorName, FILE_TXT|FILE_READ|FILE_WRITE|FILE_SHARE_READ|FILE_SHARE_WRITE, ';');
      if(handle != INVALID_HANDLE)
        {
         FileSeek(handle, 0, SEEK_END);
         FileWrite(handle, type+" | "+IndicatorName+Symbol()+","+IntegerToString(Period())+" | "+message);
         FileClose(handle);
        }
      if(Push_Notifications) SendNotification(type+" |  "+IndicatorName+Symbol()+","+IntegerToString(Period())+" | "+message);
     }
  }





int getOrder_MagicNumber(){

  return Order_MagicNumber;
}

void setOrder_Expiration_Time(){

if(OrderSelect(Order_Ticket,SELECT_BY_POS,MODE_TRADES)==true){
Order_Expiration_Time=OrderExpiration();

}

}
datetime getOrder_Expiration_Time(){
return Order_Expiration_Time;
}

void setOrder_OpenPrice(){
if(OrderSelect(Order_Ticket,SELECT_BY_POS,MODE_TRADES)==true){
Order_OpenPrice=OrderOpenPrice();
}

}

double getOrder_OpenPrice(){
if(OrderSelect(Order_Ticket,SELECT_BY_POS,MODE_TRADES)==true){
Order_OpenPrice=OrderOpenPrice();
}
return Order_OpenPrice;
}

void setOrder_Type(int order_type){
Order_Type=order_type;

}
int getOrder_Type(){//return Order type;
Order_Type=OrderType();
return Order_Type;
}

color Order_Color;int Order_Command;

   void setOrder_Command(int Order_command){
   Order_Command=Order_command;
   
   }
   
   int getOrder_Command(){//return order comment
   
   return Order_Command;
   }
   
   
   
   
   
   
   void setOrder_Comment(string comments){
    Order_Comment=comments;
   }
   string getOrder_Comment(){
   
   return Order_Comment;
   }
   
     string actions;
     
string CheckMySignal(int i){

datetime date=TimeCurrent();
//Did it make an up arraow on candle 1}
double UpArrow=iCustom(_Symbol,PERIOD_CURRENT,IndicatorName,0,1);
//print (up arrow value, uparrow);
if(UpArrow!=EMPTY_VALUE){

 StringFormat(" Action:%s"," ______BUY NOW_____ SYMBOLS : "+SYMBOLS[i]+" "+(string)date );
action="BUY";
return action;
}

//Did it make a  down  arraow on candle 1}

double DownArrow=iCustom(_Symbol,PERIOD_CURRENT,IndicatorName,1,1);
//print (up arrow value, DownArrow);
if(DownArrow>=1){
action="SELL";
   string msg=StringFormat(" Action:%s"," ______SELL NOW_____SYMBOLS : ",(string)SYMBOLS[i]+" "+(string)date);

action="SELL";
return action;
}
 return StringFormat(" Action:%s"," ______D'ont Trade Now_____ SYMBOLS :",(string)date);
}
   
void setOrder_Color(color Color){//set order color

Order_Color=Color;
}

color getOrder_Color(){return Order_Color;};
//send order open a new order based on init inputs
void  SendOrder(   ){


if(getOrder_Command()==OP_BUY||getOrder_Command()==OP_BUYSTOP||getOrder_Command()==OP_BUYLIMIT){


 Order_Ticket=OrderSend(getOrder_Symbol(),getOrder_Command(),getOrder_Lot(),Ask,getOrder_Slippage(),getOrder_StopLoss(),getOrder_TakeProfit(),getOrder_Comment(),getOrder_MagicNumber(),getOrder_Expiration_Time(),getOrder_Color());

}
else if(getOrder_Command()==OP_SELL||getOrder_Command()==OP_SELLSTOP||getOrder_Command()==OP_SELLLIMIT){


Order_Ticket=OrderSend(getOrder_Symbol(),getOrder_Command(),getOrder_Lot(),Bid,getOrder_Slippage(),getOrder_StopLoss(),getOrder_TakeProfit(),getOrder_Comment(),getOrder_MagicNumber(),getOrder_Expiration_Time(),getOrder_Color());
}
}






void setOrder_Symbol(string symbol){

Order_Symbol=symbol;
}

int TradesCount(int type) //returns # of open trades for order type, current symbol and magic number
  {
   int result = 0;
   int total = OrdersTotal();
   for(int i = 0; i < total; i++)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == false) continue;
      if(OrderMagicNumber() != Order_MagicNumber || OrderSymbol() != Symbol() || OrderType() != type) continue;
      result++;
     }
   return(result);
  }

datetime LastOpenTradeTime()
  {
   datetime result = 0;
   for(int i = OrdersTotal()-1; i >= 0; i--)
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if(OrderType() > 1) continue;
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == Order_MagicNumber)
        {
         result = OrderOpenTime();
         break;
        }
     } 
   return(result);
  }

bool SelectLastHistoryTrade()
  {
   int lastOrder = -1;
   int total = OrdersHistoryTotal();
   for(int i = total-1; i >= 0; i--)
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) continue;
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == Order_MagicNumber)
        {
         lastOrder = i;
         if(OrderProfit()<0){Order_Loss=OrderProfit();};
         if(OrderProfit()>=0){Order_Profit=OrderProfit();}
          
         break;
        }
     } 
   return(lastOrder >= 0);
  }

datetime LastOpenTime()
  {
   datetime opentime1 = 0, opentime2 = 0;
   if(SelectLastHistoryTrade())
      opentime1 = OrderOpenTime();
   opentime2 = LastOpenTradeTime();
   if (opentime1 > opentime2)
      return opentime1;
   else
      return opentime2;
  }

double Margin_Risk_Percent;

void setOrder_Margin_Risk_Percent(double margin_Risk_Percent){
Margin_Risk_Percent=margin_Risk_Percent;

}
double getOrder_Margin_Risk_Percent(){return Margin_Risk_Percent;}


double MM_Lot(double stoploss) //Risk % per trade, SL = relative Stop Loss to calculate risk
  {
    double MaxLot = MarketInfo(Symbol(), MODE_MAXLOT);
   double MinLot ;
   
   if(getOrder_Lot()>0){MinLot=getOrder_Lot();} else {MinLot=MarketInfo(Symbol(), MODE_MINLOT);};
   double tickvalue = MarketInfo(Symbol(), MODE_TICKVALUE);
   double ticksize = MarketInfo(Symbol(), MODE_TICKSIZE);
   double lots =0.01;
   if(lots > MaxLot) lots = MaxLot;
   if(lots < MinLot) lots = MinLot;
   return(lots);
  }
void myOrderDelete(int type, string ordername) //delete pending orders of "type"
  {
   if(!IsTradeAllowed()) return;
   bool success = false;
   int err = 0;
   string ordername_ = ordername;
   if(ordername != "")
      ordername_ = "("+ordername+")";
   int total = OrdersTotal();
   int orderList[][2];
 
   int orderCount = 0;
   int i;
   for(i = 0; i < total; i++)
     {
      while(IsTradeContextBusy()) Sleep(100);
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if(OrderMagicNumber() != Order_MagicNumber || OrderSymbol() != Symbol() || OrderType() != type) continue;
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
      while(IsTradeContextBusy()) Sleep(100);
      RefreshRates();
      success = OrderDelete(OrderTicket());
      if(!success)
        {
         err = GetLastError();
        Alert("error", "OrderDelete"+ordername_+" failed; error #"+IntegerToString(err)+" ");
        }
     }}

string getOrder_Symbol(){
return Order_Symbol;
}

int Order_Slippage ;

void setOrder_Slippage(int slippages){
Order_Slippage =slippages;
}


int  getOrder_Slippage(){
return Order_Slippage ;
}

void setOrder_Ticket(int ticket) {
Order_Ticket=ticket;

	};//set order ticket number

int getOrder_Ticket() {
 return Order_Ticket;
	}
	
	
void setOrderLoss(){
for(int j=OrdersHistoryTotal()-1;j>0;j--){
  if( OrderSelect( j,SELECT_BY_TICKET,MODE_HISTORY)){
    if(OrderProfit()<0)losses=OrderProfit();
  }
}
}
double geOrderLoss(){
return losses;
}


void setOrder_StopLoss(double sls) {
  Order_StopLoss=sls;
 
 
	}

double getOrder_StopLoss() {
		return Order_StopLoss ;
		};

void setOrder_TakeProfit(double tps) {
	Order_TakeProfit=tps;
		
};//set sl an d tp


double  getOrder_TakeProfit() {
		return Order_TakeProfit;
	};
	
	
	


void setOrderProfit(){

  
  for(int j=OrdersHistoryTotal()-1;j>0;j--){
  if( OrderSelect( Order_Ticket,SELECT_BY_TICKET,MODE_HISTORY)){
           if(OrderProfit()>0)profit=OrderProfit();
  
  }
}

}


double getOrderProfit(){

return profit;


}


void setOrder_Trailing_Stop_Loss(int sls) {


Order_Trailing_Stop_Loss=sls;

};//set order trail stop loss




double getOrder_Trailing_Stop_Loss(){
return Order_Trailing_Stop_Loss;


}





void setOrder_Trailing_Take_Profit(double traillingPips) {
   Order_Trailing_Take_Profit=traillingPips;
};//set order trailing take profit
 
 double  getOrder_Trailing_Take_Profit() {
return tp;
};

void setOrder_Lot(double Lot) { Order_Lot=Lot;};// set Order lot
double  getOrder_Lot() {
	return Order_Lot;
};// Get Order lot


void setOrder_Open_Time(datetime date_time) {
	Order_Open_Time = date_time;
};

datetime getOrder_Open_Time() {
 
for(int j=OrdersHistoryTotal()-1;j>0;j--){
  if( OrderSelect(j,SELECT_BY_TICKET,MODE_HISTORY)){
   return Order_Open_Time= OrderOpenTime();
  
  }
}

return	Order_Open_Time=0;
};


datetime getOrder_Close_Time() {

 for(int j=OrdersHistoryTotal()-1;j>0;j--){
  if( OrderSelect(  Order_Ticket,SELECT_BY_TICKET,MODE_HISTORY)){
   return Order_Close_Times=OrderOpenTime();}
  };
 return Order_Close_Times;
}



};

  