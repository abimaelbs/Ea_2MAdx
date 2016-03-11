//+------------------------------------------------------------------+
//|                                                        Utils.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.2"
#include <Trade/Trade.mqh>
#include <Mine/Enums.mqh>

//--- Sound files
#resource "\\Files\\Sounds\\AHOOGA.WAV"   // Error
#resource "\\Files\\Sounds\\CASHREG.WAV"  // Position opening/position volume increase/pending order triggering
#resource "\\Files\\Sounds\\WHOOSH.WAV"   // Pending order/Stop Loss/Take Profit setting/modification
#resource "\\Files\\Sounds\\VERYGOOD.WAV" // Position closing at profit
#resource "\\Files\\Sounds\\DRIVEBY.WAV"  // Position closing at loss
//--- Sound file location
string SoundError          = "::Files\\Sounds\\AHOOGA.WAV";
string SoundOpenPosition   = "::Files\\Sounds\\CASHREG.WAV";
string SoundAdjustOrder    = "::Files\\Sounds\\WHOOSH.WAV";
string SoundCloseWithProfit= "::Files\\Sounds\\VERYGOOD.WAV";
string SoundCloseWithLoss  = "::Files\\Sounds\\DRIVEBY.WAV";

sinput bool       UseSound = true; // Sound notifications

class Utils
  {
private:
   MqlTick           precoRecente;    // To be used for gettinf recent/latest price quotes
   CTrade            clTrade;
   int               _NumeroMagico;   // Código do Expert Advisor.
public: 
   /*Propriedades*/  
   void SetNumeroMagico(int numero){ _NumeroMagico=numero; }
   bool IsMetaDiaria(double valorMeta /*Valor estipulado da meta diária*/,
                     int tipoCalculo /*Liquido:Calcular com as taxas e as percas(loss)*/,
                     double ganhoAtual /*Valor total já ganho no dia*/,
                     double lossAtual /*Valor total das percas no dia(loss)*/,
                     double precoCorretagem /*Preço da corretagem por operação Ex.: (entrada e saída) uma operação*/,
                     double totalCorretagemAtual /*Valor total corretagem do já excutado no dia*/,
                     double qtdLote /*Quantidade de lotes na operação*/);
   bool ValidarHoraEntrada(string horaInicio, string horaFim);
   bool ValidarHoraWait(string horaInicio, string horaFim);
   bool ValidarHoraSaida(string horaFinal);
   bool IsNewBar(string simbolo);
   bool IsNewDay();
   void BreakEven(string simbolo /*Simbolo */,
                  int tpOrdem /*Tipo de ordem*/,
                  double inicioBreakEven /*Quantidade de pontos para ativar*/,
                  double valorAcimaEntrada /*Valor acima da entrada*/);
   void TrailingStop(string simbolo /*Ativo em questão*/,
                     int tpOrdem/*Tipo de Ordem*/,
                     double valorInicio /*Valor do inicio do trailing-stop*/,
                     double valorMudarTrailing /*Valor de mudança do trailing após a entrada*/);
                     
   bool SaidaParcial(string simbolo /*Simbolo */,
                     int tpOrdem /*Tipo de ordem*/,                     
                     double loteSaida /*Valor acima da entrada*/,
                     double valorSaida);
                     
   void PlaySoundByID(int id,bool IsTocar=true);
   void WriteFile(string texto="");                     
  };

//+------------------------------------------------------------------+ 
//| Executa Trailing Stop                                            | 
//+------------------------------------------------------------------+  

bool Utils::SaidaParcial(string simbolo,int tpOrdem, double loteSaida,double valorSaida)
{
   //if(_Symbol != simbolo && clTrade.RequestMagic() != _NumeroMagico) return(false);
   if(_Symbol != simbolo) return(false);
   
   if(!SymbolInfoTick(simbolo,precoRecente))
      Print("Erro ao obter a última cotação de preço",GetLastError());
      
   if(PositionSelect(simbolo))
   {
      double posisao_tp    = PositionGetDouble(POSITION_TP);
      double posisao_sl    = PositionGetDouble(POSITION_SL); 
      double precoEntrada  = NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN),_Digits);
      double qtdLoteAberto = PositionGetDouble(POSITION_VOLUME); // Tamanho da posição atual
      
      if(tpOrdem == POSITION_TYPE_BUY)
      {                  
         if ((precoRecente.last >=  precoEntrada + valorSaida) && (loteSaida < qtdLoteAberto))
         {                                 
            clTrade.Sell(loteSaida,simbolo,precoRecente.bid,0,0,MQL5InfoString(MQL5_PROGRAM_NAME)+" (Saida Parcial:"+(string)loteSaida+"Lot)");
            clTrade.PositionModify(simbolo,posisao_sl,posisao_tp);
            return(true);     
         }               
      }
      else if(tpOrdem == POSITION_TYPE_SELL)
      {
       if ((precoRecente.last <=  precoEntrada - valorSaida) && (loteSaida < qtdLoteAberto))
         {                                 
            clTrade.Buy(loteSaida,simbolo,precoRecente.ask,0,0,MQL5InfoString(MQL5_PROGRAM_NAME)+" (Saida Parcial:"+(string)loteSaida+"Lot)");
            clTrade.PositionModify(simbolo,posisao_sl,posisao_tp); 
            return(true);  
         }
      }
   }
   return(false);
}

//+------------------------------------------------------------------+ 
//| Executa Trailing Stop                                            | 
//+------------------------------------------------------------------+  
void Utils::TrailingStop(string simbolo, int tpOrdem,double valorInicio,double valorMudarTrailing)
{
   //if(_Symbol != simbolo && clTrade.RequestMagic() != _NumeroMagico) return;
   if(_Symbol != simbolo) return;
   
   if(!SymbolInfoTick(simbolo,precoRecente))
      Print("Erro ao obter a última cotação de preço",GetLastError());
     
   if(PositionSelect(simbolo))
   {              
     if(valorInicio > 0)
     {            
         double posisao_tp = PositionGetDouble(POSITION_TP);
         double posisao_sl = PositionGetDouble(POSITION_SL); 
         double precoEntrada =  NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN),_Digits);
               
         if (posisao_sl <= 0) return;
         
         if(tpOrdem == POSITION_TYPE_BUY)
         {                  
            // Traz loss para o preço de entrada
            if (precoRecente.last >=  precoEntrada + valorInicio && posisao_sl < precoEntrada)
            {
               posisao_sl = precoEntrada;                        
               clTrade.PositionModify(simbolo,posisao_sl,posisao_tp);
               Print(MQL5InfoString(MQL5_PROGRAM_NAME)," TrailingStop acionado:"+(string)posisao_sl);
            }
            else if (precoRecente.last >= (posisao_sl + valorInicio) + valorMudarTrailing  && posisao_sl >= precoEntrada)
            {
               if(valorMudarTrailing > 0)
                  posisao_sl = posisao_sl + valorMudarTrailing;
               else 
                  posisao_sl = precoRecente.last - valorInicio;
                  
               clTrade.PositionModify(simbolo,posisao_sl,posisao_tp);
               Print(MQL5InfoString(MQL5_PROGRAM_NAME)," TrailingStop acionado:"+(string)posisao_sl);
            }      
         }
         else if(tpOrdem == POSITION_TYPE_SELL)
         {         
            // Traz loss para o preço de entrada
            if (precoRecente.last <=  precoEntrada - valorInicio && posisao_sl > precoEntrada)
            {   
               posisao_sl = precoEntrada;                           
               clTrade.PositionModify(simbolo,posisao_sl,posisao_tp); 
               Print(MQL5InfoString(MQL5_PROGRAM_NAME)," TrailingStop acionado:"+(string)posisao_sl);
            }
            else if (precoRecente.last <= ( posisao_sl - valorInicio) - valorMudarTrailing && posisao_sl <= precoEntrada)
            {
               if(valorMudarTrailing > 0)
                  posisao_sl = posisao_sl - valorMudarTrailing;
               else 
                  posisao_sl = precoRecente.last + valorInicio;
                  
               clTrade.PositionModify(simbolo,posisao_sl,posisao_tp);
               Print(MQL5InfoString(MQL5_PROGRAM_NAME)," TrailingStop acionado:"+(string)posisao_sl);
            }       
         }
      } 
  }    
}  

//+------------------------------------------------------------------+ 
//| Verifica total méta diário retorna true/false                    | 
//+------------------------------------------------------------------+
void Utils::BreakEven(string simbolo,int tpOrdem,double inicioBreakEven,double valorAcimaEntrada)
{
   //if(_Symbol != simbolo && clTrade.RequestMagic() != _NumeroMagico) return;
   if(_Symbol != simbolo) return;
   
   if(PositionSelect(simbolo))
   {
      if(inicioBreakEven > 0)
      {              
         if(!SymbolInfoTick(simbolo,precoRecente))
            Print("Erro ao obter a última cotação de preço",GetLastError());
            
         double new_sl = 0.0;
         double pos_tp = PositionGetDouble(POSITION_TP);
         
         double posisao_sl = PositionGetDouble(POSITION_SL);
         
         // Se loss maior ou igual ao preço de entrada 
         //if(PositionGetDouble(POSITION_SL) >= PositionGetDouble(POSITION_PRICE_OPEN )) return;
         
         if(tpOrdem==POSITION_TYPE_BUY) 
         {
            if(posisao_sl >= PositionGetDouble(POSITION_PRICE_OPEN )) return;
            
            if(precoRecente.last >= NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN)+inicioBreakEven,_Digits))
              {
                  new_sl=NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN)+valorAcimaEntrada,_Digits);               
                  clTrade.PositionModify(simbolo,new_sl,pos_tp);
                  Print(MQL5InfoString(MQL5_PROGRAM_NAME)," BreakEven acionado!");
              }
           }
         else if(tpOrdem==POSITION_TYPE_SELL)
         {
            if(posisao_sl<= PositionGetDouble(POSITION_PRICE_OPEN )) return;
            
            if(precoRecente.last <= NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN)-inicioBreakEven,_Digits))
              {
                  new_sl=NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN)-valorAcimaEntrada,_Digits);               
                  clTrade.PositionModify(simbolo,new_sl,pos_tp);
                  Print(MQL5InfoString(MQL5_PROGRAM_NAME)," BreakEven acionado!");
              }
         }      
      }
   }
}

//+------------------------------------------------------------------+ 
//| Verifica total méta diário retorna true/false                    | 
//+------------------------------------------------------------------+
bool Utils::IsMetaDiaria(double valorMeta,int tipoCalculo,double ganhoAtual,double lossAtual,
double precoCorretagem, double totalCorretagemAtual,double qtdLote)
{      
   if(valorMeta <=0) return false;
   
   // Total de valores operações   
   double ganhoAtualOperacao=0;
   double metaAux = 0;
   
   if(PositionSelect(_Symbol))   
      ganhoAtualOperacao = PositionGetDouble(POSITION_PROFIT);   
   
   if(tipoCalculo == Liquido)  // Valor Liquido
   {    
      metaAux = valorMeta + totalCorretagemAtual + (lossAtual * -1);// + _ValorTaxaIBOV;
      
      if(ganhoAtual >= metaAux) return true;
   
       metaAux += (precoCorretagem * qtdLote);
            
      return (ganhoAtualOperacao + ganhoAtual > metaAux);   
   }
   
   if(tipoCalculo == Bruto) // Valor Bruto 
   {     
      if(ganhoAtual >= (valorMeta + (lossAtual * -1))) return true;
      
      return (ganhoAtualOperacao + ganhoAtual > valorMeta + (lossAtual *-1));
   }    
   
   return false;    
}

//+------------------------------------------------------------------+
//|  Validar Horário de entrada, retorna true se hora válida         |
//+------------------------------------------------------------------+
bool Utils::ValidarHoraEntrada(string horaInicio,string horaFim)
{
   //MqlDateTime dt_struct;
   //TimeToStruct(TimeCurrent(),dt_struct);   
 if(horaInicio!="")
  {
   // Validar hora digitada   
   string aDelimiter=":";
   int tDelimiterLength=StringLen(aDelimiter);
   int tPos1 = 0;
   int tPos2 = StringFind(horaInicio,aDelimiter,0);

   string vHoraInicio  ="";
   string vMinutoInicio="";

   string vHoraFim    = "";
   string vMinutoFim  = "";

   if(tPos2>-1)
     {
      vHoraInicio=StringSubstr(horaInicio,tPos1,tPos2-tPos1);
      tPos1=tPos2+tDelimiterLength;
      vMinutoInicio=StringSubstr(horaInicio,tPos1,tPos2-tPos1);

      tPos1 = 0;
      tPos2 = StringFind(horaFim,aDelimiter,tPos1);
      vHoraFim=StringSubstr(horaFim,tPos1,tPos2-tPos1);
      tPos1=tPos2+tDelimiterLength;
      vMinutoFim=StringSubstr(horaFim,tPos1,tPos2-tPos1);
     }
   else
      return(false);

   datetime tm= TimeCurrent();
   datetime vtmIni=StringToTime(vHoraInicio+":"+vMinutoInicio);
   datetime vtmFim=StringToTime(vHoraFim+":"+vMinutoFim);
         
   if(tm >= vtmIni && tm < vtmFim)
      return true;   
   } 

   return(false);
}

//+------------------------------------------------------------------+
//|  Validar Horário de não operar                                   |
//+------------------------------------------------------------------+
bool Utils::ValidarHoraWait(string horaInicio,string horaFim)
{      
 if(horaInicio!="" && horaFim != "")
  {
   // Validar hora digitada   
   string aDelimiter=":";
   int tDelimiterLength=StringLen(aDelimiter);
   int tPos1 = 0;
   int tPos2 = StringFind(horaInicio,aDelimiter,0);

   string vHoraInicio="";
   string vMinutoInicio="";

   string vHoraFim    = "";
   string vMinutoFim  = "";

   if(tPos2>-1)
     {
      vHoraInicio=StringSubstr(horaInicio,tPos1,tPos2-tPos1);
      tPos1=tPos2+tDelimiterLength;
      vMinutoInicio=StringSubstr(horaInicio,tPos1,tPos2-tPos1);

      tPos1 = 0;
      tPos2 = StringFind(horaFim,aDelimiter,tPos1);
      vHoraFim=StringSubstr(horaFim,tPos1,tPos2-tPos1);
      tPos1=tPos2+tDelimiterLength;
      vMinutoFim=StringSubstr(horaFim,tPos1,tPos2-tPos1);
     }
   else
      return(false);
      
   datetime tm= TimeCurrent();
   datetime vtmIni=StringToTime(vHoraInicio+":"+vMinutoInicio);
   datetime vtmFim=StringToTime(vHoraFim+":"+vMinutoFim);
         
   if(tm >= vtmIni && tm < vtmFim)
      return true;      
  }
  
  return false;
}
//+------------------------------------------------------------------+
//|  Validar Horário de saida, retorna true se hora válida           |
//+------------------------------------------------------------------+
bool Utils::ValidarHoraSaida(string horaFinal)
{
   if(horaFinal!="")
   {
      // Validar hora digitada   
      string aDelimiter=":";
      int tDelimiterLength=StringLen(aDelimiter);
      int tPos1 = 0;
      int tPos2 = StringFind(horaFinal,aDelimiter,0);
      
      string vHoraFim    = "";
      string vMinutoFim  = "";
      
      if(tPos2>-1)
        {
         tPos2=StringFind(horaFinal,aDelimiter,tPos1);
         vHoraFim=StringSubstr(horaFinal,tPos1,tPos2-tPos1);
         tPos1=tPos2+tDelimiterLength;
         vMinutoFim=StringSubstr(horaFinal,tPos1,tPos2-tPos1);
        }
      else
         return(false);
      
      MqlDateTime dt_struct;
      TimeToStruct(TimeCurrent(),dt_struct);
      
      if(vHoraFim != "" && vMinutoFim != "")
         if(dt_struct.hour >= StringToInteger(vHoraFim) && dt_struct.min >= StringToInteger(vMinutoFim))
            return(true);        
   }

   return(false);
}

//+------------------------------------------------------------------+ 
//| Retorna true de há uma nova barra                                | 
//+------------------------------------------------------------------+
bool Utils::IsNewBar(string simbolo)
{
   //if(clTrade.RequestMagic() != _NumeroMagico) return(false);
   if(_Symbol != simbolo) return(false);
   
   MqlRates _Mrate[];
   ZeroMemory(_Mrate);
   ArraySetAsSeries(_Mrate,true); 
   
   if(CopyRates(_Symbol,_Period,0,3,_Mrate)<0)
      Print("Error ao copiar dados da cotação do histórico",GetLastError());
    
   datetime static Prev_time;
   datetime Bar_time[1];
   Bar_time[0]=_Mrate[0].time;   

   if(Prev_time==Bar_time[0])
      return(false);

   Prev_time=Bar_time[0];

   return(true);
}

//+------------------------------------------------------------------+
//|  Validar se é no dia                                             |
//+------------------------------------------------------------------+
bool Utils::IsNewDay(void)
{
   MqlDateTime dt_struct;
   TimeToStruct(TimeCurrent(),dt_struct);
   
   int static hoje;
   if(hoje!=dt_struct.day_of_week)
     {
      hoje=dt_struct.day_of_week;
      return(true);
     }
     
   return(false);
}

//+------------------------------------------------------------------+
//| Tocar sons                                                       |
//+------------------------------------------------------------------+
void Utils::PlaySoundByID(int id,bool IsTocar=true)
{
  if(IsTocar)
  {
   //--- Play the sound based on the identifier passed
   switch(id)
     {
      case SOUND_ERROR              : PlaySound(SoundError);            break;
      case SOUND_OPEN_POSITION      : PlaySound(SoundOpenPosition);     break;
      case SOUND_ADJUST_ORDER       : PlaySound(SoundAdjustOrder);      break;
      case SOUND_CLOSE_WITH_PROFIT  : PlaySound(SoundCloseWithProfit);  break;
      case SOUND_CLOSE_WITH_LOSS    : PlaySound(SoundCloseWithLoss);    break;
     }
  }
}

//+------------------------------------------------------------------+
//| Save data to file                                                |
//+------------------------------------------------------------------+
void Utils::WriteFile(string texto="")
  {
   //--- open the file
   ResetLastError();      
   int han=FileOpen(MQL5InfoString(MQL5_PROGRAM_NAME)+".txt",FILE_WRITE|FILE_TXT|FILE_ANSI," ");
   
   //--- check if the file has been opened
   if(han!=INVALID_HANDLE)
     {
      FileWrite(han,texto); 
      FileClose(han);
     }
   else
      Print("Falha ao abrir arquivo "+MQL5InfoString(MQL5_PROGRAM_NAME)+".txt, error",GetLastError());
  }
