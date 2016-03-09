//+------------------------------------------------------------------+
//|                                                        Enums.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.01"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Enums
  {
     enum eSimbolo
     {
      WIN,   // Mini-Indice
      WDO,   // Mini-Dolar
      EUR    // Euro
     };
     
     enum eTipoMeta
     {
      Liquido,  // Líquido
      Bruto     // Bruto
     };
     
     enum eConfirmar
     {
         No=0,  // Não
         Yes=1, // Sim
     };
     
     enum eSom
     {
         SOUND_ERROR             = 0,  // Error
         SOUND_OPEN_POSITION     = 1,  // Position opening/position volume increase/pending order triggering
         SOUND_ADJUST_ORDER      = 2,  // Stop Loss/Take Profit/pending order setting
         SOUND_CLOSE_WITH_PROFIT = 3,  // Position closing at profit
         SOUND_CLOSE_WITH_LOSS   = 4   // Position closing at loss
     };
  };