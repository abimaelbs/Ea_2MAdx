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
  };