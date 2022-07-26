//+------------------------------------------------------------------+
//|                                                       HFT V1.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#define   VERSION   "1.01"
#property version   VERSION
#property strict

#include "HFT_Math.mqh"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

int magicNumber=1111; // Magic Number
//string symbol="EURUSD";
int minCalTrade = 16; // Min trade for calculate
double lotSize;

double oldMin;
double oldMax;
double tradesHistory[];

double firstStopLoss = 300;
double firstTakeProfit= 400;

double countor_A, countor_B, countor_C, countor_D;

double midLine, midLineState, downLine, upLine;
double distance;

double newMin, newMax;

double breathLevel_1, breathLevel_2, breathLevel_3;

char lastTradeType;
double sl, tp;

double profit=0;
double loss=0;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   lotSize=MarketInfo(_Symbol,MODE_MINLOT);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {


   if(OrdersHistoryTotal()>= minCalTrade)
     {
      GetHistoryTrades();

      Comment(
         "---------------------------------------------","\n",
         "Closed Trade : ",OrdersHistoryTotal(),"\n",  
         "Old Min : ",oldMin,"\n",
         "Old Max : ",oldMax,"\n",
         "Countor A : ",countor_A,"\n",
         "Mid Line : ",midLine,"\n",
         "Countor B : ",countor_B,"\n",
         "Down Line : ",downLine,"\n",
         "Countor C : ",countor_C,"\n",
         "Up Line : ",upLine,"\n",
         "Distance : ",distance,"\n",
         "New Min : ",newMin,"\n",
         "New Max : ",newMax,"\n",
         "---------------------------------------------","\n",
         "Breath Level 1 : ",breathLevel_1,"\n",
         "Breath Level 2 : ",breathLevel_2,"\n",
         "Breath Level 3 : ",breathLevel_3,"\n",
         "---------------------------------------------","\n",
         "TakeProfit : ",profit,"\n",
         "StopLoss : ",loss,"\n",
         "---------------------------------------------","\n",
         "Account Profit / Loss : ",NormalizeDouble(AccountProfit(),Digits),"\n",
         "---------------------------------------------"

      );


     }
   else
      Comment("Closed Trade : ",OrdersHistoryTotal());

   Signal();
   CloseTrades();

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Signal()
  {
   if(OrdersTotal()==0 && OrdersHistoryTotal()==0)
     {
      sl = (Ask - (firstStopLoss * Point));
      tp = (Ask + (firstTakeProfit * Point));

      Buy(sl,tp);

     }


   if(OrdersTotal()==0 && OrdersHistoryTotal()> 0)
     {
      LastTradeInfo();

      if(lastTradeType==OP_SELL)//"Sell")
        {
         if(OrdersHistoryTotal()>= minCalTrade)
           {
            sl = 0;
            tp = 0;

            Buy(sl,tp);
           }
         else
           {
            sl = (Ask - (firstStopLoss * Point));
            tp = (Ask + (firstTakeProfit * Point));

            Buy(sl,tp);
           }
        }

      if(lastTradeType==OP_BUY)//"Buy")
        {
         if(OrdersHistoryTotal()>= minCalTrade)
           {
            sl = 0;
            tp = 0;

            Sell(sl,tp);
           }
         else
           {
            sl = (Bid + (firstStopLoss * Point));
            tp = (Bid - (firstTakeProfit * Point));

            Sell(sl,tp);
           }


        }
     }


  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GetHistoryTrades()
  {

   ArrayFree(tradesHistory);
   ArrayResize(tradesHistory,OrdersHistoryTotal());


   for(int i = OrdersHistoryTotal()-1; i > 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS,MODE_HISTORY))
        {
         tradesHistory[i]=OrderProfit();
        }
     }
     
     

   oldMin=tradesHistory[ArrayMinimum(tradesHistory,WHOLE_ARRAY,0)];
   oldMax=tradesHistory[ArrayMaximum(tradesHistory,WHOLE_ARRAY,0)];
   
  
   

   ArraySort(tradesHistory);
   countor_A = OrdersHistoryTotal();
   countor_B = (0.25*(countor_A+1));
   countor_C = (0.5*(countor_A+1));
   countor_D = (0.75*(countor_A+1));




   if(checkInteger(countor_B))
      downLine=tradesHistory[((int)countor_B)-1];

   if(checkInteger(countor_B == false))
      downLine = (tradesHistory[((int)MathFloor(countor_B))-1] + tradesHistory[((int)MathCeil(countor_B))-1])/2;




   if(checkInteger(countor_C))
      midLine=tradesHistory[((int)countor_C)-1];

   if(checkInteger(countor_C == false))
      midLine = (tradesHistory[((int)MathFloor(countor_C))-1] + tradesHistory[((int)MathCeil(countor_C))-1])/2;




   if(checkInteger(countor_D))
      upLine=tradesHistory[((int)countor_D)-1];

   if(checkInteger(countor_D == false))
      upLine = (tradesHistory[((int)MathFloor(countor_D))-1] + tradesHistory[((int)MathCeil(countor_D))-1])/2;




   distance = (upLine - downLine);
   newMin = (downLine-(1.5*distance));
   newMax = (upLine + (1.5*distance));





   if(MathAbs(newMax) > MathAbs(newMin))
      breathLevel_1 = 1;
   else
      breathLevel_1 = 0;


   if(MathAbs(newMin) < MathAbs(oldMin))
      breathLevel_2 = 1;
   else
      breathLevel_2 = 0;


   if(MathAbs(newMax) < MathAbs(oldMax))
      breathLevel_3 = 1;
   else
      breathLevel_3 = 0;



   if(newMax > oldMax)
      profit = newMax;
   else
      profit = oldMax;


   if(newMin < oldMin)
      loss=newMin;
   else
      loss=oldMin;





  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Sell(double _sl,double _tp)
  {
   bool sell = OrderSend(Symbol(),OP_SELL,lotSize,Bid,0,_sl,_tp,"sell",magicNumber,0,clrRed);  // slippage >=3 ???
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Buy(double _sl,double _tp)
  {
   bool buy = OrderSend(Symbol(),OP_BUY,lotSize,Ask,0,_sl,_tp,"buy",magicNumber,0,clrGreen);  // slippage >=3 ???
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void LastTradeInfo()
  {


   if(OrderSelect(OrdersHistoryTotal()-1, SELECT_BY_POS,MODE_HISTORY))
     {
      if(OrderType()==OP_BUY)
        {
         lastTradeType=OP_BUY;//"Buy";
        }

      if(OrderType()==OP_SELL)
        {
         lastTradeType=OP_SELL;//"Sell";
        }

     }

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseTrades()
  {

   if(profit != 0 && AccountProfit() >= profit)
      CloseAllTrades();

   if(loss != 0 && AccountProfit() <= loss)
      CloseAllTrades();

  }
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseAllTrades()
  {
   
   
   for(int i = OrdersTotal() - 1; i >= 0 ; i--)
     {
      if ( OrderSelect(i,SELECT_BY_POS)==false)
      {
         Print("OrderSelect returned the error of ",GetLastError());// Send notification
         continue;
      }
      if(OrderSymbol() != Symbol())
         continue;
      //double price = MarketInfo(OrderSymbol(),MODE_ASK);
      //if(OrderType() == OP_BUY)
         //price = MarketInfo(OrderSymbol(),MODE_BID);
      if(OrderType() == OP_BUY || OrderType() == OP_SELL)
      {
         if( OrderClose(OrderTicket(), OrderLots(),OrderClosePrice(),5)==false )
         {
            Print("OrderClose failed");// Send notification or start a loop
         }
      }
      else
     {
         if ( OrderDelete(OrderTicket())==false )
         {
               Print("OrderDelete failed");// Send notification or start a loop
         }
     }
      Sleep(100);
      int error = GetLastError();
      if(error > 0)
         Print("Unanticipated error: ");
      //RefreshRates();
     }

  }
//+------------------------------------------------------------------+
