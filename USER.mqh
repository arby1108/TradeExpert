//+------------------------------------------------------------------+
//|                                                     Telegram.mqh |
//|                        Copyright 2021, Noel Martial Nguemechieu. |
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
#define EXPERT_NAME     "TRADE_EXPERT"
#define EXPERT_VERSION  "1.50"
#property version       EXPERT_VERSION
#define CAPTION_COLOR   clrWhite
#define LOSS_COLOR      clrOrangeRed
#define  NL "\n";

#include <DiscordTelegram/COrder.mqh>

ENUM_RUN_MODE  run_mode;
datetime       time_check;
int            web_error;
int            init_error;
string         photo_id=NULL;
//+------------------------------------------------------------------+
//|   Defines                                                        |
//+------------------------------------------------------------------+
#define TELEGRAM_BASE_URL  "https://api.telegram.org"
#define WEB_TIMEOUT        5000
//+------------------------------------------------------------------+
//|   ENUM_CHAT_ACTION                                               |
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
class CCustomMessage : public CObject
{
public:
   bool              done;
   long              update_id;
   long              message_id;
   //---
   long              from_id;
   string            from_first_name;
   string            from_last_name;
   string            from_username;
   //---
   long              chat_id;
   string            chat_first_name;
   string            chat_last_name;
   string            chat_username;
   string            chat_type;
   //---
   datetime          message_date;
   string            message_text;

                     CCustomMessage()
   {
      done=false;
      update_id=0;
      message_id=0;
      from_id=0;
      from_first_name=NULL;
      from_last_name=NULL;
      from_username=NULL;
      chat_id=0;
      chat_first_name=NULL;
      chat_last_name=NULL;
      chat_username=NULL;
      chat_type=NULL;
      message_date=0;
      message_text=NULL;
      from_id=0;
      from_first_name=NULL;
      from_last_name=NULL;
      from_username=NULL;
      chat_id=0;
      chat_first_name=NULL;
      chat_last_name=NULL;
      chat_username=NULL;
      chat_type=NULL;
      message_date=0;
      message_text=NULL;
   }

};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CCustomChat : public CObject
{
public:
   long              m_id;
   CCustomMessage    m_last;
   CCustomMessage    m_new_one;
   int               m_state;
   datetime          m_time;
};


//+------------------------------------------------------------------+
//|   CCustomBot                                                     |
//+------------------------------------------------------------------+
class CCustomBot 
{
private:
 ENUM_LANGUAGES    m_lang;
   string            m_symbol;
   ENUM_TIMEFRAMES   m_period;
   string            m_template;
   CArrayString      m_templates;
   //+------------------------------------------------------------------+
   void              ArrayAdd(uchar &dest[],const uchar &src[])
   {
      int src_size=ArraySize(src);
      if(src_size==0)
         return;

      int dest_size=ArraySize(dest);
      ArrayResize(dest,dest_size+src_size,500);
      ArrayCopy(dest,src,dest_size,0,src_size);
   }

   //+------------------------------------------------------------------+
   void              ArrayAdd(char &dest[],const string text)
   {
      int len=StringLen(text);
      if(len>0)
      {
         uchar src[];
         for(int i=0; i<len; i++)
         {
            ushort ch=StringGetCharacter(text,i);

            uchar array[];
            int total=ShortToUtf8(ch,array);

            int size=ArraySize(src);
            ArrayResize(src,size+total);
            ArrayCopy(src,array,size,0,total);
         }
         ArrayAdd(dest,src);
      }
   }

   //+------------------------------------------------------------------+
   int               SaveToFile(const string filename,
                                const char &text[])
   {
      ResetLastError();

      int handle=FileOpen(filename,FILE_BIN|FILE_ANSI|FILE_WRITE);
      if(handle==INVALID_HANDLE)
      {
         return(GetLastError());
      }

      FileWriteArray(handle,text);
      FileClose(handle);

      return(0);
   }

   //+------------------------------------------------------------------+
   string            UrlEncode(const string text)
   {
      string result=NULL;
      int length=StringLen(text);
      for(int i=0; i<length; i++)
      {
         ushort ch=StringGetCharacter(text,i);

         if((ch>=48 && ch<=57) || // 0-9
               (ch>=65 && ch<=90) || // A-Z
               (ch>=97 && ch<=122) || // a-z
               (ch=='!') || (ch=='\'') || (ch=='(') ||
               (ch==')') || (ch=='*') || (ch=='-') ||
               (ch=='.') || (ch=='_') || (ch=='~')
           )
         {
            result+=ShortToString(ch);
         }
         else
         {
            if(ch==' ')
               result+=ShortToString('+');
            else
            {
               uchar array[];
               int total=ShortToUtf8(ch,array);
               for(int k=0; k<total; k++)
                  result+=StringFormat("%%%02X",array[k]);
            }
         }
      }
      return result;
   }

protected:
   CList             m_chats;

private:
   string            m_token;
   string            m_name;
   long              m_update_id;
   CArrayString      m_users_filter;
   bool              m_first_remove;

   //+------------------------------------------------------------------+
   int               PostRequest(string &out,
                                 const string url,
                                 const string params,
                                 const int timeout=5000)
   {
      char data[];
      int data_size=StringLen(params);
      StringToCharArray(params,data,0,data_size);

      uchar result[];
      string result_headers;

      //--- application/x-www-form-urlencoded
      int res=WebRequest("POST",url,NULL,NULL,timeout,data,data_size,result,result_headers);
      if(res==200)//OK
      {
         //--- delete BOM
         int start_index=0;
         int size=ArraySize(result);
         for(int i=0; i<fmin(size,8); i++)
         {
            if(result[i]==0xef || result[i]==0xbb || result[i]==0xbf)
               start_index=i+1;
            else
               break;
         }
         //---
         out=CharArrayToString(result,start_index,WHOLE_ARRAY,CP_UTF8);
         return(0);
      }
      else
      {
         if(res==-1)
         {
            return(_LastError);
         }
         else
         {
            //--- HTTP errors
            if(res>=100 && res<=511)
            {
               out=CharArrayToString(result,0,WHOLE_ARRAY,CP_UTF8);
               Print(out);
               return(ERR_HTTP_ERROR_FIRST+res);
            }
            return(res);
         }
      }

      return(0);
   }

   //+------------------------------------------------------------------+
   int               ShortToUtf8(const ushort _ch,uchar &out[])
   {
      //---
      if(_ch<0x80)
      {
         ArrayResize(out,1);
         out[0]=(uchar)_ch;
         return(1);
      }
      //---
      if(_ch<0x800)
      {
         ArrayResize(out,2);
         out[0] = (uchar)((_ch >> 6)|0xC0);
         out[1] = (uchar)((_ch & 0x3F)|0x80);
         return(2);
      }
      //---
      if(_ch<0xFFFF)
      {
         if(_ch>=0xD800 && _ch<=0xDFFF)//Ill-formed
         {
            ArrayResize(out,1);
            out[0]=' ';
            return(1);
         }
         else if(_ch>=0xE000 && _ch<=0xF8FF)//Emoji
         {
            int ch=0x10000|_ch;
            ArrayResize(out,4);
            out[0] = (uchar)(0xF0 | (ch >> 18));
            out[1] = (uchar)(0x80 | ((ch >> 12) & 0x3F));
            out[2] = (uchar)(0x80 | ((ch >> 6) & 0x3F));
            out[3] = (uchar)(0x80 | ((ch & 0x3F)));
            return(4);
         }
         else
         {
            ArrayResize(out,3);
            out[0] = (uchar)((_ch>>12)|0xE0);
            out[1] = (uchar)(((_ch>>6)&0x3F)|0x80);
            out[2] = (uchar)((_ch&0x3F)|0x80);
            return(3);
         }
      }
      ArrayResize(out,3);
      out[0] = 0xEF;
      out[1] = 0xBF;
      out[2] = 0xBD;
      return(3);
   }

   //+------------------------------------------------------------------+
   string            StringDecode(string text)
   {
      //--- replace \n
      StringReplace(text,"\n",ShortToString(0x0A));

      //--- replace \u0000
      int haut=0;
      int pos=StringFind(text,"\\u");
      while(pos!=-1)
      {
         string strcode=StringSubstr(text,pos,6);
         string strhex=StringSubstr(text,pos+2,4);

         StringToUpper(strhex);

         int total=StringLen(strhex);
         int result=0;
         for(int i=0,k=total-1; i<total; i++,k--)
         {
            int coef=(int)pow(2,4*k);
            ushort ch=StringGetCharacter(strhex,i);
            if(ch>='0' && ch<='9')
               result+=(ch-'0')*coef;
            if(ch>='A' && ch<='F')
               result+=(ch-'A'+10)*coef;
         }

         if(haut!=0)
         {
            if(result>=0xDC00 && result<=0xDFFF)
            {
               int dec=((haut-0xD800)<<10)+(result-0xDC00);//+0x10000;
               StringReplaceEx(text,pos,6,ShortToString((ushort)dec));
               haut=0;
            }
            else
            {
               //--- error: Second byte out of range
               haut=0;
            }
         }
         else
         {
            if(result>=0xD800 && result<=0xDBFF)
            {
               haut=result;
               StringReplaceEx(text,pos,6,"");
            }
            else
            {
               StringReplaceEx(text,pos,6,ShortToString((ushort)result));
            }
         }

         pos=StringFind(text,"\\u",pos);
      }
      return(text);
   }

   //+------------------------------------------------------------------+
   int               StringReplaceEx(string &string_var,
                                     const int start_pos,
                                     const int length,
                                     const string replacement)
   {
      string temp=(start_pos==0)?"":StringSubstr(string_var,0,start_pos);
      temp+=replacement;
      temp+=StringSubstr(string_var,start_pos+length);
      string_var=temp;
      return(StringLen(replacement));
   }

   //+------------------------------------------------------------------+
   string            BoolToString(const bool _value)
   {
      if(_value)return("true");
      return("false");
   }

protected:
   //+------------------------------------------------------------------+
   string            StringTrim(string text)
   {
#ifdef __MQL4__
      text = StringTrimLeft(text);
      text = StringTrimRight(text);
#endif
#ifdef __MQL5__
      StringTrimLeft(text);
      StringTrimRight(text);
#endif
      return(text);
   }

public:
   //+------------------------------------------------------------------+
   void              CCustomBot()
   {
      m_token=NULL;
      m_name=NULL;
      m_update_id=0;
      m_first_remove=true;
      m_chats.Clear();
      m_users_filter.Clear();
   }

   //+------------------------------------------------------------------+
   int               ChatsTotal()
   {
      return(m_chats.Total());
   }

   //+------------------------------------------------------------------+
   int               Token(const string _token)
   {
      string token=StringTrim(_token);
      if(token=="")
         return(ERR_TOKEN_ISEMPTY);
      //---
      m_token=token;
      return(0);
   }

   //+------------------------------------------------------------------+
   void              UserNameFilter(const string username_list)
   {
      m_users_filter.Clear();

      //--- parsing
      string text=StringTrim(username_list);
      if(text=="")
         return;

      //---
      while(StringReplace(text,"  "," ")>0);
      StringReplace(text,";"," ");
      StringReplace(text,","," ");

      //---
      string array[];
      int amount=StringSplit(text,' ',array);
      for(int i=0; i<amount; i++)
      {
         string username=StringTrim(array[i]);
         if(username!="")
         {
            //--- remove first @
            if(StringGetCharacter(username,0)=='@')
               username=StringSubstr(username,1);

            m_users_filter.Add(username);
         }
      }

   }
   //+------------------------------------------------------------------+
   string            Name()
   {
      return(m_name);
   }

   //+------------------------------------------------------------------+
   int               GetMe()
   {
      if(m_token==NULL)
         return(ERR_TOKEN_ISEMPTY);
      //---
      string out;
      string url=StringFormat("%s/bot%s/getMe",TELEGRAM_BASE_URL,m_token);
      string params="";
      int res=PostRequest(out,url,params,WEB_TIMEOUT);
      if(res==0)
      {
         CJAVal js(NULL,jtUNDEF);
         //---
         bool done=js.Deserialize(out);
         if(!done)
            return(ERR_JSON_PARSING);

         //---
         bool ok=js["ok"].ToBool();
         if(!ok)
            return(ERR_JSON_NOT_OK);

         //---
         if(m_name==NULL)
            m_name=js["result"]["username"].ToStr();
      }
      //---
      return(res);
   }
   //+------------------------------------------------------------------+
   int               GetUpdates()
   {
      if(m_token==NULL)
         return(ERR_TOKEN_ISEMPTY);

      string out;
      string url=StringFormat("%s/bot%s/getUpdates",TELEGRAM_BASE_URL,m_token);
      string params=StringFormat("offset=%d",m_update_id);
      //---
      int res=PostRequest(out,url,params,WEB_TIMEOUT);
      if(res==0)
      {
         //Print(out);
         //--- parse result
         CJAVal js(NULL,jtUNDEF);
         bool done=js.Deserialize(out);
         if(!done)
            return(ERR_JSON_PARSING);

         bool ok=js["ok"].ToBool();
         if(!ok)
            return(ERR_JSON_NOT_OK);

         CCustomMessage msg;

         int total=ArraySize(js["result"].m_e);
         for(int i=0; i<total; i++)
         {
            CJAVal item=js["result"].m_e[i];
            //---
            msg.update_id=item["update_id"].ToInt();
            //---
            msg.message_id=item["message"]["message_id"].ToInt();
            msg.message_date=(datetime)item["message"]["date"].ToInt();
            //---
            msg.message_text=item["message"]["text"].ToStr();
            msg.message_text=StringDecode(msg.message_text);
            //---
            msg.from_id=item["message"]["from"]["id"].ToInt();

            msg.from_first_name=item["message"]["from"]["first_name"].ToStr();
            msg.from_first_name=StringDecode(msg.from_first_name);

            msg.from_last_name=item["message"]["from"]["last_name"].ToStr();
            msg.from_last_name=StringDecode(msg.from_last_name);

            msg.from_username=item["message"]["from"]["username"].ToStr();
            msg.from_username=StringDecode(msg.from_username);
            //---
            msg.chat_id=item["message"]["chat"]["id"].ToInt();

            msg.chat_first_name=item["message"]["chat"]["first_name"].ToStr();
            msg.chat_first_name=StringDecode(msg.chat_first_name);

            msg.chat_last_name=item["message"]["chat"]["last_name"].ToStr();
            msg.chat_last_name=StringDecode(msg.chat_last_name);

            msg.chat_username=item["message"]["chat"]["username"].ToStr();
            msg.chat_username=StringDecode(msg.chat_username);

            msg.chat_type=item["message"]["chat"]["type"].ToStr();

            m_update_id=msg.update_id+1;

            if(m_first_remove)
               continue;

            //--- filter
            if(m_users_filter.Total()==0 || (m_users_filter.Total()>0 && m_users_filter.SearchLinear(msg.from_username)>=0))
            {

               //--- find the chat
               int index=-1;
               for(int j=0; j<m_chats.Total(); j++)
               {
                  CCustomChat *chat=m_chats.GetNodeAtIndex(j);
                  if(chat.m_id==msg.chat_id)
                  {
                     index=j;
                     break;
                  }
               }

               //--- add new one to the chat list
               if(index==-1)
               {
                  m_chats.Add(new CCustomChat);
                  CCustomChat *chat=m_chats.GetLastNode();
                  chat.m_id=msg.chat_id;
                  chat.m_time=TimeLocal();
                  chat.m_state=0;
                  chat.m_new_one.message_text=msg.message_text;
                  chat.m_new_one.done=false;
               }
               //--- update chat message
               else
               {
                  CCustomChat *chat=m_chats.GetNodeAtIndex(index);
                  chat.m_time=TimeLocal();
                  chat.m_new_one.message_text=msg.message_text;
                  chat.m_new_one.done=false;
               }
            }
         }
         m_first_remove=false;
      }
      //---
      return(res);
   }

   //+------------------------------------------------------------------+
   int               SendChatAction(const long _chat_id,
                                    const ENUM_CHAT_ACTION _action)
   {
      if(m_token==NULL)
         return(ERR_TOKEN_ISEMPTY);
      string out;
      string url=StringFormat("%s/bot%s/sendChatAction",TELEGRAM_BASE_URL,m_token);
      string params=StringFormat("chat_id=%lld&action=%s",_chat_id,ChatActionToString(_action));
      int res=PostRequest(out,url,params,WEB_TIMEOUT);
      return(res);
   }

   //+------------------------------------------------------------------+
   int               SendPhotoToChat(const long   _chat_id,
                               const string _photo_id,
                               const string _caption=NULL)
   {
      if(m_token==NULL)
         return(ERR_TOKEN_ISEMPTY);

      string out;
      string url=StringFormat("%s/bot%s/sendPhoto",TELEGRAM_BASE_URL,m_token);
      string params=StringFormat("chat_id=%lld&photo=%s",_chat_id,_photo_id);
      if(_caption!=NULL)
         params+="&caption="+UrlEncode(_caption);

      int res=PostRequest(out,url,params,WEB_TIMEOUT);
      if(res!=0)
      {
         //--- parse result
         CJAVal js(NULL,jtUNDEF);
         bool done=js.Deserialize(out);
         if(!done)
            return(ERR_JSON_PARSING);

         //--- get error description
         bool ok=js["ok"].ToBool();
         long err_code=js["error_code"].ToInt();
         string err_desc=js["description"].ToStr();
      }
      //--- done
      return(res);
   }

   //+------------------------------------------------------------------+
   int               SendPhotoToChannel(string &_photo_id,
                               const string _channel_name,
                               const string _local_path,
                               const string _caption=NULL,
                               const bool _common_flag=false,
                               const int _timeout=10000)
   {
      if(m_token==NULL)
         return(ERR_TOKEN_ISEMPTY);

      string name=StringTrim(_channel_name);
      if(StringGetCharacter(name,0)!='@')
         name="@"+name;

      if(m_token==NULL)
         return(ERR_TOKEN_ISEMPTY);

      ResetLastError();
      //--- copy file to memory buffer
      if(!FileIsExist(_local_path,_common_flag))
         return(ERR_FILE_NOT_EXIST);

      //---
      int flags=FILE_READ|FILE_BIN|FILE_SHARE_WRITE|FILE_SHARE_READ;
      if(_common_flag)
         flags|=FILE_COMMON;

      //---
      int file=FileOpen(_local_path,flags);
      if(file<0)
         return(_LastError);

      //---
      int file_size=(int)FileSize(file);
      uchar photo[];
      ArrayResize(photo,file_size);
      FileReadArray(file,photo,0,file_size);
      FileClose(file);

      //--- create boundary: (data -> base64 -> 1024 bytes -> md5)
      uchar base64[];
      uchar key[];
      CryptEncode(CRYPT_BASE64,photo,key,base64);
      //---
      uchar temp[1024]= {0};
      ArrayCopy(temp,base64,0,0,1024);
      //---
      uchar md5[];
      CryptEncode(CRYPT_HASH_MD5,temp,key,md5);
      //---
      string hash=NULL;
      int total=ArraySize(md5);
      for(int i=0; i<total; i++)
         hash+=StringFormat("%02X",md5[i]);
      hash=StringSubstr(hash,0,16);

      //--- WebRequest
      uchar result[];
      string result_headers;

      string url=StringFormat("%s/bot%s/sendPhoto",TELEGRAM_BASE_URL,m_token);

      //--- 1
      uchar data[];

      //--- add chart_id
      ArrayAdd(data,"\r\n");
      ArrayAdd(data,"--"+hash+"\r\n");
      ArrayAdd(data,"Content-Disposition: form-data; name=\"chat_id\"\r\n");
      ArrayAdd(data,"\r\n");
      ArrayAdd(data,name);
      ArrayAdd(data,"\r\n");

      if(StringLen(_caption)>0)
      {
         ArrayAdd(data,"--"+hash+"\r\n");
         ArrayAdd(data,"Content-Disposition: form-data; name=\"caption\"\r\n");
         ArrayAdd(data,"\r\n");
         ArrayAdd(data,_caption);
         ArrayAdd(data,"\r\n");
      }

      ArrayAdd(data,"--"+hash+"\r\n");
      ArrayAdd(data,"Content-Disposition: form-data; name=\"photo\"; filename=\"lampash.gif\"\r\n");
      ArrayAdd(data,"\r\n");
      ArrayAdd(data,photo);
      ArrayAdd(data,"\r\n");
      ArrayAdd(data,"--"+hash+"--\r\n");

      // SaveToFile("debug.txt",data);

      //---
      string headers="Content-Type: multipart/form-data; boundary="+hash+"\r\n";
      int res=WebRequest("POST",url,headers,_timeout,data,result,result_headers);
      if(res==200)//OK
      {
         //--- delete BOM
         int start_index=0;
         int size=ArraySize(result);
         for(int i=0; i<fmin(size,8); i++)
         {
            if(result[i]==0xef || result[i]==0xbb || result[i]==0xbf)
               start_index=i+1;
            else
               break;
         }

         //---
         string out=CharArrayToString(result,start_index,WHOLE_ARRAY,CP_UTF8);

         //--- parse result
         CJAVal js(NULL,jtUNDEF);
         bool done=js.Deserialize(out);
         if(!done)
            return(ERR_JSON_PARSING);

         //--- get error description
         bool ok=js["ok"].ToBool();
         if(!ok)
            return(ERR_JSON_NOT_OK);

         total=ArraySize(js["result"]["photo"].m_e);
         for(int i=0; i<total; i++)
         {
            CJAVal image=js["result"]["photo"].m_e[i];

            long image_size=image["file_size"].ToInt();
            if(image_size<=file_size)
               _photo_id=image["file_id"].ToStr();
         }

         return(0);
      }
      else
      {
         if(res==-1)
         {
            string out=CharArrayToString(result,0,WHOLE_ARRAY,CP_UTF8);
            //Print(out);
            return(_LastError);
         }
         else
         {
            if(res>=100 && res<=511)
            {
               string out=CharArrayToString(result,0,WHOLE_ARRAY,CP_UTF8);
               //Print(out);
               return(ERR_HTTP_ERROR_FIRST+res);
            }
            return(res);
         }
      }
      //---
      return(0);
   }

   //+------------------------------------------------------------------+
   int               SendPhoto(string &_photo_id,
                               const long _chat_id,
                               const string _local_path,
                               const string _caption=NULL,
                               const bool _common_flag=false,
                               const int _timeout=10000)
   {
      if(m_token==NULL)
         return(ERR_TOKEN_ISEMPTY);

      ResetLastError();
      //--- copy file to memory buffer
      if(!FileIsExist(_local_path,_common_flag))
         return(ERR_FILE_NOT_EXIST);

      //---
      int flags=FILE_READ|FILE_BIN|FILE_SHARE_WRITE|FILE_SHARE_READ;
      if(_common_flag)
         flags|=FILE_COMMON;

      //---
      int file=FileOpen(_local_path,flags);
      if(file<0)
         return(_LastError);

      //---
      int file_size=(int)FileSize(file);
      uchar photo[];
      ArrayResize(photo,file_size);
      FileReadArray(file,photo,0,file_size);
      FileClose(file);

      //--- create boundary: (data -> base64 -> 1024 bytes -> md5)
      uchar base64[];
      uchar key[];
      CryptEncode(CRYPT_BASE64,photo,key,base64);
      //---
      uchar temp[1024]= {0};
      ArrayCopy(temp,base64,0,0,1024);
      //---
      uchar md5[];
      CryptEncode(CRYPT_HASH_MD5,temp,key,md5);
      //---
      string hash=NULL;
      int total=ArraySize(md5);
      for(int i=0; i<total; i++)
         hash+=StringFormat("%02X",md5[i]);
      hash=StringSubstr(hash,0,16);

      //--- WebRequest
      uchar result[];
      string result_headers;

      string url=StringFormat("%s/bot%s/sendPhoto",TELEGRAM_BASE_URL,m_token);

      //--- 1
      uchar data[];

      //--- add chart_id
      ArrayAdd(data,"\r\n");
      ArrayAdd(data,"--"+hash+"\r\n");
      ArrayAdd(data,"Content-Disposition: form-data; name=\"chat_id\"\r\n");
      ArrayAdd(data,"\r\n");
      ArrayAdd(data,IntegerToString(_chat_id));
      ArrayAdd(data,"\r\n");

      if(StringLen(_caption)>0)
      {
         ArrayAdd(data,"--"+hash+"\r\n");
         ArrayAdd(data,"Content-Disposition: form-data; name=\"caption\"\r\n");
         ArrayAdd(data,"\r\n");
         ArrayAdd(data,_caption);
         ArrayAdd(data,"\r\n");
      }

      ArrayAdd(data,"--"+hash+"\r\n");
      ArrayAdd(data,"Content-Disposition: form-data; name=\"photo\"; filename=\"lampash.gif\"\r\n");
      ArrayAdd(data,"\r\n");
      ArrayAdd(data,photo);
      ArrayAdd(data,"\r\n");
      ArrayAdd(data,"--"+hash+"--\r\n");

      // SaveToFile("debug.txt",data);

      //---
      string headers="Content-Type: multipart/form-data; boundary="+hash+"\r\n";
      int res=WebRequest("POST",url,headers,_timeout,data,result,result_headers);
      if(res==200)//OK
      {
         //--- delete BOM
         int start_index=0;
         int size=ArraySize(result);
         for(int i=0; i<fmin(size,8); i++)
         {
            if(result[i]==0xef || result[i]==0xbb || result[i]==0xbf)
               start_index=i+1;
            else
               break;
         }

         //---
         string out=CharArrayToString(result,start_index,WHOLE_ARRAY,CP_UTF8);

         //--- parse result
         CJAVal js(NULL,jtUNDEF);
         bool done=js.Deserialize(out);
         if(!done)
            return(ERR_JSON_PARSING);

         //--- get error description
         bool ok=js["ok"].ToBool();
         if(!ok)
            return(ERR_JSON_NOT_OK);

         total=ArraySize(js["result"]["photo"].m_e);
         for(int i=0; i<total; i++)
         {
            CJAVal image=js["result"]["photo"].m_e[i];

            long image_size=image["file_size"].ToInt();
            if(image_size<=file_size)
               _photo_id=image["file_id"].ToStr();
         }

         return(0);
      }
      else
      {
         if(res==-1)
         {
            string out=CharArrayToString(result,0,WHOLE_ARRAY,CP_UTF8);
            //Print(out);
            return(_LastError);
         }
         else
         {
            if(res>=100 && res<=511)
            {
               string out=CharArrayToString(result,0,WHOLE_ARRAY,CP_UTF8);
               //Print(out);
               return(ERR_HTTP_ERROR_FIRST+res);
            }
            return(res);
         }
      }
      //---
      return(0);
   }
   //+------------------------------------------------------------------+
     long chat_id;
  
   //+------------------------------------------------------------------+
   int               SendScreenShotToChat(const long _chat_id,
                                    const string _symbol,
                                    const ENUM_TIMEFRAMES _period,
             
                                    const string _template=NULL ,
                                    bool SendScreenShots=false)
   {int result=0;
      if(SendScreenShots==true){
      
      
chat_id=_chat_id;

        
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
         Sleep(60);
      }

      if(_template!=NULL)
         if(!ChartApplyTemplate(chart_id,_template))
            PrintError(_LastError,InpLanguage);

      ChartRedraw(chart_id);
      Sleep(60);

      ChartSetInteger(chart_id,CHART_SHOW_GRID,false);

      ChartSetInteger(chart_id,CHART_SHOW_PERIOD_SEP,false);

      string filename=StringFormat("%s%d.gif",_symbol,_period);

      if(FileIsExist(filename))
         FileDelete(filename);
      ChartRedraw(chart_id);

      Sleep(30);
 ChartColorSet();
      if(ChartScreenShot(chart_id,filename,800,600,ALIGN_RIGHT))
      {
         
         Sleep(30);
         
         //--- Need for MT4 on weekends !!!
         ChartRedraw(chart_id);
         
        bot.SendChatAction(_chat_id,ACTION_UPLOAD_PHOTO);

         //--- waitng 30 sec for save screenshot
         wait=60;
         while(!FileIsExist(filename) && --wait>0)
            Sleep(60);

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
SendScreenShotss=false;
   if(SendScreenShotss){
    
      long chart_id=ChartOpen(_symbol,_period);
      
     Set Chart Colors=BackGround;
      if(chart_id==0)
         return(ERR_CHART_NOT_FOUND);

      ChartSetInteger(chart_id,CHART_BRING_TO_TOP,true);

      //--- updates chart 
         SendChatAction(chat_id,ACTION_UPDATE_CHART);
      int wait=30;
      while(--wait>0)
      {
    
         if(SeriesInfoInteger(_symbol,_period,SERIES_SYNCHRONIZED))
           
         Sleep(70);
         break;
      }
                       
      if(_template!=NULL)
         if(!ChartApplyTemplate(chart_id,_template))
            Comment(_LastError,InpLanguage);

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
      if(ChartScreenShot(chart_id,filename,800,600,ALIGN_RIGHT))
      {
         
         Sleep(30);
         
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
              SendChatAction(chart_id,ACTION_UPLOAD_PHOTO);

            result=SendPhotoToChannel(screen_id,channel_id,filename,_symbol+"_"+StringSubstr(EnumToString(_period),7));
         
         }
         else
         {
            string mask=m_lang==LANGUAGE_EN?"Screenshot file '%s' not created.":"Файл скриншота '%s' не создан.";
            PrintFormat(mask,filename);
            SendChatAction(chart_id,ACTION_TYPING);

           SendMessageToChannel(channel_id,mask +filename,false,false);
            
         }
      }

      ChartClose(chart_id);
      
      }
      return(result);
   }
   
 

   //+------------------------------------------------------------------+
   void              ProcessMessages()
   {

#define EMOJI_TOP    "\xF51D"
#define EMOJI_BACK   "\xF519"
#define KEYB_MAIN    (m_lang==LANGUAGE_EN)?"[[\"Account Info\"],[\"Quotes\"],[\"Charts\"]]":"[[\"Информация\"],[\"Котировки\"],[\"Графики\"]]"
#define KEYB_SYMBOLS "[[\""+EMOJI_TOP+"\",\"GBPUSD\",\"EURUSD\"],[\"AUDUSD\",\"USDJPY\",\"EURJPY\"],[\"USDCAD\",\"USDCHF\",\"EURCHF\"]]"
#define KEYB_PERIODS "[[\""+EMOJI_TOP+"\",\"M1\",\"M5\",\"M15\"],[\""+EMOJI_BACK+"\",\"M30\",\"H1\",\"H4\"],[\" \",\"D1\",\"W1\",\"MN1\"]]"

      for(int i=0; i<m_chats.Total(); i++)
      {
         CCustomChat *chat=m_chats.GetNodeAtIndex(i);
         if(!chat.m_new_one.done)
         {
            chat.m_new_one.done=true;
            string text=chat.m_new_one.message_text;

            //--- start
            if(text=="/start" || text=="/help")
            {
               chat.m_state=0;
               string msg="The bot works with your trading account:\n";
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

               bot.SendMessageToChat(chat_id,msg,ReplyKeyboardMarkup(KEYB_MAIN,false,false));
               continue;
            }

            //---
            if(text==EMOJI_TOP)
            {
               chat.m_state=0;
               string msg=(m_lang==LANGUAGE_EN)?"Choose a menu item":"Выберите пункт меню";
               bot.SendMessageToChat(chat_id,msg,ReplyKeyboardMarkup(KEYB_MAIN,false,false));
               continue;
            }

            //---
            if(text==EMOJI_BACK)
            {
               if(chat.m_state==31)
               {
                  chat.m_state=3;
                  string msg=(m_lang==LANGUAGE_EN)?"Enter a symbol name like 'EURUSD'":"Введите название инструмента, например 'EURUSD'";
                 bot. SendMessageToChat(chat_id,msg,ReplyKeyboardMarkup(KEYB_SYMBOLS,false,false));
               }
               else if(chat.m_state==32)
               {
                  chat.m_state=31;
                  string msg=(m_lang==LANGUAGE_EN)?"Select a timeframe like 'H1'":"Введите период графика, например 'H1'";
                 bot. SendMessageToChat(chat_id,msg,ReplyKeyboardMarkup(KEYB_PERIODS,false,false));
               }
               else
               {
                  chat.m_state=0;
                  string msg=(m_lang==LANGUAGE_EN)?"Choose a menu item":"Выберите пункт меню";
                 bot.SendMessageToChat(chat_id,msg,ReplyKeyboardMarkup(KEYB_MAIN,false,false));
               }
               continue;
            }

            //---
            if(text=="/info" || text=="Account Info" || text=="Информация")
            {
               chat.m_state=1;
               string currency=AccountInfoString(ACCOUNT_CURRENCY);
               string msg=StringFormat("%d: %s\n",AccountInfoInteger(ACCOUNT_LOGIN),AccountInfoString(ACCOUNT_SERVER));
               msg+=StringFormat("%s: %.2f %s\n",(m_lang==LANGUAGE_EN)?"Balance":"Баланс",AccountInfoDouble(ACCOUNT_BALANCE),currency);
               msg+=StringFormat("%s: %.2f %s\n",(m_lang==LANGUAGE_EN)?"Profit":"Прибыль",AccountInfoDouble(ACCOUNT_PROFIT),currency);
               SendMessageToChat(chat_id,msg,ReplyKeyboardMarkup(KEYB_MAIN,false,false));
            }

            //---
            if(text=="/quotes" || text=="Quotes" || text=="Котировки")
            {
               chat.m_state=2;
               string msg=(m_lang==LANGUAGE_EN)?"Enter a symbol name like 'EURUSD'":"Введите название инструмента, например 'EURUSD'";
               bot.SendMessageToChat(chat_id,msg,ReplyKeyboardMarkup(KEYB_SYMBOLS,false,false));
               continue;
            }

            //---
            if(text=="/charts" || text=="Charts" || text=="Графики")
            {
               chat.m_state=3;
               string msg=(m_lang==LANGUAGE_EN)?"Enter a symbol name like 'EURUSD'":"Введите название инструмента, например 'EURUSD'";
               SendMessageToChat(chat_id,msg,ReplyKeyboardMarkup(KEYB_SYMBOLS,false,false));
               continue;
            }

            //--- Quotes
            if(chat.m_state==2)
            {
               string mask=(m_lang==LANGUAGE_EN)?"Invalid symbol name '%s'":"Инструмент '%s' не найден";
               string msg=StringFormat(mask,text);
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

               SendMessageToChat(chat.m_id,msg,ReplyKeyboardMarkup(KEYB_SYMBOLS,false,false));
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
                  string msg=(m_lang==LANGUAGE_EN)?"Select a timeframe like 'H1'":"Введите период графика, например 'H1'";
                  SendMessageToChat(chat.m_id,msg,ReplyKeyboardMarkup(KEYB_PERIODS,false,false));
               }
               else
               {
                  string mask=(m_lang==LANGUAGE_EN)?"Invalid symbol name '%s'":"Инструмент '%s' не найден";
                  string msg=StringFormat(mask,text);
                  SendMessageToChat(chat.m_id,msg,ReplyKeyboardMarkup(KEYB_SYMBOLS,false,false));
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

                  SendMessageToChat(chat.m_id,(m_lang==LANGUAGE_EN)?"Select a template":"Выберите шаблон",ReplyKeyboardMarkup(str,false,false));
               }
               else
               {
                  SendMessageToChat(chat.m_id,(m_lang==LANGUAGE_EN)?"Invalid timeframe":"Неправильно задан период графика",ReplyKeyboardMarkup(KEYB_PERIODS,false,false));
               }
               continue;
            }
            //---
            if(chat.m_state==32)
            {
               m_template=text;
               if(m_template=="None")
                  m_template=NULL;
               int result=SendScreenShotToChannel(CHANNEL_NAME,m_symbol,m_period,m_template, sendscreenshot);
               if(result!=0)
                  Print(GetErrorDescription(result,InpLanguage));
            }
         }
      }
   }
   
   
   
   
   
   
   
   
   
   
   

   //+------------------------------------------------------------------+
   int               SendMessageToChat(const long    _chat_id,
                                 const string  _text,
                                 const string  _reply_markup=NULL,
                                 const bool    _as_HTML=false,
                                 const bool    _silently=false)
   {
      //--- check token
      if(m_token==NULL)
         return(ERR_TOKEN_ISEMPTY);

      string out;
      string url=StringFormat("%s/bot%s/sendMessage",TELEGRAM_BASE_URL,m_token);

      string params=StringFormat("chat_id=%lld&text=%s",_chat_id,UrlEncode(_text));
      if(_reply_markup!=NULL)
         params+="&reply_markup="+_reply_markup;
      if(_as_HTML)
         params+="&parse_mode=HTML";
      if(_silently)
         params+="&disable_notification=true";

      int res=PostRequest(out,url,params,WEB_TIMEOUT);
      return(res);
   }

   //+------------------------------------------------------------------+
   int               SendMessageToChannel(const string _channel_name,
                                 const string _text,
                                 const bool   _as_HTML=false,
                                 const bool   _silently=false)
   {
      //--- check token
      if(m_token==NULL)
         return(ERR_TOKEN_ISEMPTY);

      string name=StringTrim(_channel_name);
      if(StringGetCharacter(name,0)!='@')
         name="@"+name;

      string out;
      string url=StringFormat("%s/bot%s/sendMessage",TELEGRAM_BASE_URL,m_token);
      string params=StringFormat("chat_id=%s&text=%s",name,UrlEncode(_text));
      if(_as_HTML)
         params+="&parse_mode=HTML";
      if(_silently)
         params+="&disable_notification=true";
      //      Print(params);
      int res=PostRequest(out,url,params,WEB_TIMEOUT);
      return(res);
   }
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
   string            ReplyKeyboardMarkup(const string keyboard,
                                         const bool resize,
                                         const bool one_time)
   {
      string result=StringFormat("{\"keyboard\": %s, \"one_time_keyboard\": %s, \"resize_keyboard\": %s, \"selective\": false}",UrlEncode(keyboard),BoolToString(resize),BoolToString(one_time));
      return(result);
   }

   //+------------------------------------------------------------------+
   string            ReplyKeyboardHide()
   {
      return("{\"hide_keyboard\": true}");
   }

   //+------------------------------------------------------------------+
   string            ForceReply()
   {
      return("{\"force_reply\": true}");
   }
};
//+------------------------------------------------------------------+
CCustomBot bot;