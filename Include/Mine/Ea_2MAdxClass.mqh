//+------------------------------------------------------------------+
//|                                                Ea_2MAdxClass.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "abimael.bs@gmail.com"
#property version   "1.07"

#include <Trade/Trade.mqh>
#include <Mine/Utils.mqh>
#include <Mine/Enums.mqh>
#include <Charts\Chart.mqh>

CChart cchart;
CTrade cTrade;

int   totalGains,
      totalLoss;
double totalCorretagem,
       totalProfit,
       valarTotalLoss;
bool   primeiraSaida,
       segundaSaida;

//+------------------------------------------------------------------+
//|   Declara��o                                                     |
//+------------------------------------------------------------------+
class Ea_2MAdxClass
  {
private:
   double            _Lote;           // Parametro do Volume de lotes para o Trade.
   double            _TakeProfit;     // Ganho
   double            _StopLoss;       // Perda 
   double            _Adx_Minimo;     // Valor m�nimo ADX
   bool              _UsarBreakEven;  // Usar breakeven
   bool              _UsarStopATR;    // Usar Stop ATR, configura��a autom�otica de stop
   
   bool              _UsarSaidaParcial; //  Saida Parcial
   double            _LoteSaidaParcial_1;// Quantidade de lote na saida parcial
   double            _ValorSaidaParcial_1;// Valor em pontos para saida parcial
   double            _LoteSaidaParcial_2;// Quantidade de lote na saida parcial
   double            _ValorSaidaParcial_2;// Valor em pontos para saida parcial
   
   double            _BreakEvenVal;   // Trazer valor para o 0x0   
   double            _TicksAcimaBreakEven; // Quantidade acima do pre�o
   bool              _UsarTralingStop; //Usar Trailing Stop
   double            _InicioTrailingStop;  //In�cio Trainling Stop
   double            _MudancaTrailingStop; // Mudan�a Trainling Stop 
   double            _PrecoDeAjuste;       //Pre�o de Ajuste anterior
   //color             _CorLinhaAjuste;  // Pre�o de ajuste(Cor)
   double            _ValorCorretagem; // Valor da corretagem por opera��o
   double            _ValorTaxaIBOV;   // Taxa da cobrado por dia IBOV
   bool              _UsarMetaDiaria;  // Usar meta di�ria
   double            _ValorTotalMeta;  // Total meta di�ria
   eTipoMeta         _TipoMeta;        // Tipo meta (liquido/bruto)
   int               _MA_Manusear;     // Moving avarege para manusear da M�dia M�vel Simples
   int               _MALong_Manusear; // Moving avarege para manusear da M�dia M�vel Simples
   double            _MAShort_Valor[];  // Array para os valores da M�dia M�vel Simples.    
   double            _MALong_Valor[]; // Array para os valores da M�dia M�vel Simples.    
   int               _ADX_Manusear;   // ADX para manusear.
   double            _ADX_Valor[];    // ADX valor       
   double            _MaiorDI[];      // Array para +BB do Banda de Boliger (Superior=1)
   double            _MenorDI[];      // Array para -BB do Banda de Boliger (Inferior=2)   
   int               _ATR_Manusear;   // Stop ATR
   double            _ATR_Valor[];    // Valor ATR
   string            _HoraInicio;     // Usar controle de horas para entrada na opera��o
   string            _HoraFim;        // Usar controle de horas para sa�da na opera��o      
   int               _NumeroMagico;   // C�digo do Expert Advisor.      
   MqlTick           latest_price;    // To be used for gettinf recent/latest price quotes
   MqlTradeRequest   _Request;        // Estrutura usada para enviar do Trade.
   MqlTradeResult    _Result;         // Estrutura usada para recebimento do resultado do Trade.
   MqlRates          mrate[];         // To be used to store the prices, volumes and spread of each bar   
   string            _Simbolo;        // Simbolo corrente.
   ENUM_TIMEFRAMES   _Periodo;        // P�riodo atual.
   ENUM_MA_METHOD    _MetodoMA;       //        
   int               _TotalGain;      // Guarda o total de gain no dia
   int               _TotalLoss;      // Guarda o total de loss no dia
   Utils             _clUtils;        // Instancia a classe Util.     
public:   
   /* M�todos B�sicos para todos os EA's*/
                     Ea_2MAdxClass(); //Construtor
                    //~Ea_2MAdxClass(); //Destrutor
   void              DoInit(int ma,int maLong); //Inicializar indicadores
   void              DoUnit();   
   int               ShowErro(string msg,int erroCode);
   void              ShowAlert(string msg);
   ENUM_ORDER_TYPE   CheckOpenTrade(void);// Verifica por condi��o de compra ou venda.      

   /* M�todos Get */
   string GetSimbolo() { return(StringSubstr(_Simbolo,0,3)); }
   ENUM_TIMEFRAMES GetPeriodo() { return(_Periodo); }
   
   /* M�todos Set*/
   void SetLote(double lote){ _Lote=lote; }
   void SetTakeProfit(double tp) { _TakeProfit=tp; }
   void SetADX_Minimo(double adx) { _Adx_Minimo=adx; }
   void SetStopLoss(double sl) {  _StopLoss=sl; }
   void SetUsarBreakEven(bool bk) { _UsarBreakEven = bk; }
   void SetUsarStopATR(bool atr) { _UsarStopATR = atr; }
   
   void SetUsarSaidaParcial(bool sa) { _UsarSaidaParcial = sa; }
   void SetLoteSaidaParcial_1(double sp) { _LoteSaidaParcial_1 = sp; }
   void SetValorSaidaParcial_1(double vs) { _ValorSaidaParcial_1= vs; }
   void SetLoteSaidaParcial_2(double sp2) { _LoteSaidaParcial_2 = sp2; }
   void SetValorSaidaParcial_2(double vs2) { _ValorSaidaParcial_2= vs2; }
   
   void SetBreakEven(double bv) {_BreakEvenVal=bv; }
   void SetTicksBreakEven(double tbv) {_TicksAcimaBreakEven=tbv; }
   void SetPrecoDeAjuste(double aj) { _PrecoDeAjuste=aj; }
   void SetValorCorretagem(double corretagem) {_ValorCorretagem = corretagem; }
   void SetValorTaxaIBOV(double txIbov) { _ValorTaxaIBOV = txIbov; }
   void SetUsarMetaDiaria(bool md) { _UsarMetaDiaria= md; }
   void SetValorTotalMeta(double tm) { _ValorTotalMeta = tm; }
   void SetTipoMeta(eTipoMeta t) {_TipoMeta= t; }
   void SetUsarTralingStop(bool tl) {_UsarTralingStop = tl; }
   void SetInicioTrailingStop(double train) { _InicioTrailingStop = train; }
   void SetMudancaTrailingStop(double mTrain) { _MudancaTrailingStop = mTrain; }
   void SetSimbolo(string simbolo) { _Simbolo=simbolo; }
   void SetPeriodo(ENUM_TIMEFRAMES periodo) { _Periodo=periodo; }
   void SetHoraInico(string hora) { _HoraInicio=hora; }
   void SetHoraFim(string hora) { _HoraFim=hora; }
   void SetNumeroMagico(int numero){ _NumeroMagico=numero; }
   void SetMetodoMA(ENUM_MA_METHOD mt) { _MetodoMA=mt; }
   void SetMaxGain(int gain){ _TotalGain=gain; }
   void SetMaxLoss(int loss) { _TotalLoss=loss; }

   /* M�todos P�blicos */
   bool              CheckCloseTrade();
   void              AbrirPosicao(ENUM_ORDER_TYPE typeOrder); //Abre uma posicao, compra ou venda.
   void              BreakEven(ENUM_POSITION_TYPE typeOrder);
   void              TrainlingStop(ENUM_POSITION_TYPE TypeOrder);
   void              GetInformation();
   void              DesenharOBJ(double preco,long cor);  
   void              SaidaParcial(int tipoOrder); 
protected:
   void              GetBuffers();      
   void              ClosePosition();   
  };
 
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Ea_2MAdxClass::Ea_2MAdxClass()
  {
   ZeroMemory(_MAShort_Valor);
   ZeroMemory(_MALong_Valor);
   ZeroMemory(_ADX_Valor);
   ZeroMemory(_MaiorDI);
   ZeroMemory(_MenorDI);
   ZeroMemory(_Request);
   ZeroMemory(_Result);   
  }

//+------------------------------------------------------------------+ 
//| Inicializar objetos                                              |
//+------------------------------------------------------------------+
void Ea_2MAdxClass::DoInit(int ma,int maLong)
  {    
   //--- resetting error code to zero
   ResetLastError(); 
       
   _MALong_Manusear= iCustom(_Simbolo,_Periodo,"Custom_iMALong", maLong, _MetodoMA, PRICE_CLOSE);
   _MA_Manusear    = iCustom(_Simbolo,_Periodo,"Custom_iMAShort", ma, _MetodoMA, PRICE_CLOSE);    
   _ADX_Manusear   = iCustom(_Simbolo,_Periodo,"CustomADX",14); 
   _ATR_Manusear   = iATR(_Simbolo,_Periodo,14);

   //_MA_Manusear     = iMA(_Simbolo,_Periodo,ma,0,_MetodoMA,PRICE_CLOSE);         
   //_MALong_Manusear = iMA(_Simbolo,_Periodo,maLong,0,_MetodoMA,PRICE_CLOSE);
   // _MACD_Manusear   = iMACD(_Simbolo,_Periodo,12,26,9,PRICE_CLOSE);   
   // _ADX_Manusear    = iADX(_Simbolo,_Periodo,14);
   
   cTrade.SetExpertMagicNumber(_NumeroMagico);
   totalGains=0;totalLoss=0;totalCorretagem=0;totalProfit=0;valarTotalLoss=0;     
   primeiraSaida = segundaSaida = false;
   //cchart.Attach(0);
   
   int subwindow=(int)ChartGetInteger(0,CHART_WINDOWS_TOTAL);
   PrintFormat("Adicionado indicador Moveg Average na janela do gr�fico %d",subwindow);
   //if(!ChartIndicatorAdd(0,subwindow,_MALong_Manusear)) 
   if(!ChartIndicatorAdd(0,0,_MALong_Manusear)) 
     { 
      PrintFormat("Falha para adicionar indicador Moving Average na janela do gr�fico %d. C�digo de erro %d", subwindow,GetLastError()); 
     }
   if(!ChartIndicatorAdd(0,0,_MA_Manusear)) 
     { 
      PrintFormat("Falha para adicionar indicador Moving Average na janela do gr�fico %d. C�digo de erro %d", subwindow,GetLastError()); 
     }
    if(!ChartIndicatorAdd(0,1,_ADX_Manusear)) 
     { 
      PrintFormat("Falha para adicionar indicador ADX na janela do gr�fico %d. C�digo de erro %d", subwindow,GetLastError()); 
     }    
   //if(!cchart.IndicatorAdd(0,_MACD_Manusear)) Print(" Falha ao adicionar Media m�vel no chart");       
   
   //if(!cchart.IndicatorAdd(0,_MALong_Manusear)) Print(" Falha ao adicionar Media m�vel no chart"); 
   //if(!cchart.IndicatorAdd(0,_MA_Manusear)) Print("Falha ao adicionar Media m�vel no chart"); 
   //if(!cchart.IndicatorAdd(1,_ADX_Manusear)) Print(" Falha ao adicionar ADX no chart");       
  }
//+------------------------------------------------------------------+
//| Destrutor                                                        | 
//+------------------------------------------------------------------+
void Ea_2MAdxClass::DoUnit(void)
{   

   int window=ChartWindowFind(); 
      
   //ChartIndicatorDelete(0,0,"EMA(17)");
   //ChartIndicatorDelete(0,0,"EMA(72)");
   //ChartIndicatorDelete(0,window,"ADX(14)");
   
   //cchart.IndicatorDelete(0,cchart.IndicatorName(0,1));   
   //cchart.IndicatorDelete(0,"EMA(17)");  
   //cchart.IndicatorDelete(0,"EMA(72)");
   //cchart.IndicatorDelete(1,"ADX(14)");   
          
   //Print("Nome Indicador: "+ cchart.IndicatorName(0,1)); 
   //Print("Nome Indicador: "+ cchart.IndicatorName(0,2)); 
   //Print("Nome Indicador: "+ cchart.IndicatorName(0,3));
            
   IndicatorRelease(_MA_Manusear);   
   IndicatorRelease(_MALong_Manusear);
   IndicatorRelease(_ADX_Manusear);
   IndicatorRelease(_ATR_Manusear);
   //cchart.Detach(); 
   Comment("");
   //_clUtils.WriteFile("Teste");
}

//+------------------------------------------------------------------+ 
//| Retorna o tipo de entrada no Trade (Buy or Sell)                 | 
//+------------------------------------------------------------------+
ENUM_ORDER_TYPE Ea_2MAdxClass::CheckOpenTrade(void)
  {      
   if(_clUtils.IsNewDay()) GetInformation();
   
   GetBuffers();   
   
   bool IsCondition_1=false;
   bool IsCondition_2=false;
   bool IsCondition_3=false;
   bool IsCondition_4=false;
   bool IsCondition_5=false;
   
   // Se debugando
   /*
   if ( MQL5InfoInteger(MQL5_DEBUGGING) )
   {
      if(_MAShort_Valor[0] > _MALong_Valor[0] )
         return(ORDER_TYPE_BUY);
     if(_MAShort_Valor[0] < _MALong_Valor[0] ) 
      return(ORDER_TYPE_SELL);                        
   } */
   
   /* Se condi��o de compra.
      Se pre�o negociado acima da m�dia m�vel e barra anterior acima da m�dia m�vel.
   */
   // M�dias
   IsCondition_1 = ( _MAShort_Valor[0] > _MALong_Valor[0] );
   // �ltimo e pen�ltimo neg�cios acima da m�dia de curto per�odo
   IsCondition_2 = ( latest_price.last > _MAShort_Valor[0] && mrate[1].high > _MAShort_Valor[1] && 
                     latest_price.last > mrate[1].high && mrate[1].high > mrate[2].high );   
   // ADX maior que valor m�nimo e +DI acima de -DI
   IsCondition_3 = ( _ADX_Valor[0] > _Adx_Minimo && _ADX_Valor[0] > _ADX_Valor[1] &&  _MaiorDI[0] > _MenorDI[0] && _MaiorDI[0] > _MaiorDI[1]);
   
   //IsCondition_1 = ( _MAShort_Valor[0] > _MALong_Valor[0] && latest_price.last > _MAShort_Valor[0] && mrate[1].high >_MAShort_Valor[1]);
   //IsCondition_2 = ( _ADX_Valor[0] > _Adx_Minimo && _ADX_Valor[0] > _ADX_Valor[1] && _MaiorDI[0] > _MaiorDI[1] &&  _MaiorDI[1] > _MaiorDI[2]);
   
   // Se neg�cio abaixo do pre�o de ajuste, n�o comprar
   IsCondition_4 = ((_PrecoDeAjuste <= 0) || ( _PrecoDeAjuste > 0 && latest_price.last > _PrecoDeAjuste)) ; 
   
   // Se n�o houve engolfo
   IsCondition_5 = (mrate[0].low > mrate[1].low);
                    
   if( IsCondition_1 && IsCondition_2 && IsCondition_3 && IsCondition_4 && IsCondition_5)
   {
      if(GetPeriodo()==1)                 
         if(!(mrate[2].high > mrate[3].high)) return(-1); // Se �ltima barra fechada maior que pen�ltima barra              
       
      if(_clUtils.IsNewBar(_Simbolo))                     
            return(ORDER_TYPE_BUY);                        
   }

   /* Se condi��o de venda.
      Se pre�o abaixo da m�dia m�vel e barra anterior menor que a m�dia m�vel.
   */
   // M�dias
   IsCondition_1 = ( _MAShort_Valor[0] < _MALong_Valor[0]);
   // �ltimo e pen�ltimo neg�cios abaixo da m�dia de curto per�odo
   IsCondition_2 = ( latest_price.last < _MAShort_Valor[0] && mrate[1].low < _MAShort_Valor[1] && 
                     latest_price.last < mrate[1].low && mrate[1].low < mrate[2].low);   
   // ADX maior que valor m�nimo e +DI acima de -DI
   IsCondition_3 = ( _ADX_Valor[0] > _Adx_Minimo && _ADX_Valor[0] > _ADX_Valor[1] && _MaiorDI[0] < _MenorDI[0] && _MenorDI[0] > _MenorDI[1]);
                  
   //IsCondition_1 = (_MAShort_Valor[0] < _MALong_Valor[0] && latest_price.last < _MAShort_Valor[0] && mrate[1].low < _MAShort_Valor[1]);
   //IsCondition_2 = (_ADX_Valor[0] > _Adx_Minimo && _ADX_Valor[0] > _ADX_Valor[1] && _MenorDI[0] > _MenorDI[1] && _MenorDI[1] > _MenorDI[2] && latest_price.last<mrate[1].low);
  
   // Se neg�cio acima do pre�o de ajuste, n�o vender                     
   IsCondition_4 = ((_PrecoDeAjuste <= 0) || (_PrecoDeAjuste > 0 && latest_price.last < _PrecoDeAjuste));
   
   // Se n�o houve engolfo
   IsCondition_5 = (mrate[0].high < mrate[1].high);
   
   if(IsCondition_1 && IsCondition_2 && IsCondition_3 && IsCondition_4 && IsCondition_5)
   {
      if(GetPeriodo()==1)                 
         if(!(mrate[2].low < mrate[3].low)) return(-1); // Se �ltima barra fechada maior que pen�ltima      
      
      if(_clUtils.IsNewBar(_Simbolo))                   
            return(ORDER_TYPE_SELL);                        
   }

   return(-1);
  }
//+------------------------------------------------------------------+ 
//| Pegar valores Indicadores                                        | 
//+------------------------------------------------------------------+
void Ea_2MAdxClass::GetBuffers(void)
  {
   ZeroMemory(_MAShort_Valor);
   ZeroMemory(_ADX_Valor);
   ZeroMemory(_MaiorDI);
   ZeroMemory(_MenorDI);
   ZeroMemory(_Request);
   ZeroMemory(_Result);
   ZeroMemory(mrate);   

   ArraySetAsSeries(_MAShort_Valor,true);
   ArraySetAsSeries(_ADX_Valor,true);
   ArraySetAsSeries(_MaiorDI,true);
   ArraySetAsSeries(_MenorDI,true);
   ArraySetAsSeries(mrate,true);
   ArraySetAsSeries(_ADX_Valor,true);   

   if(CopyBuffer(_MA_Manusear,0,0,3,_MAShort_Valor)<0 || 
      CopyBuffer(_ADX_Manusear,0,0,3,_ADX_Valor)<0 || 
      CopyBuffer(_ADX_Manusear,1,0,3,_MaiorDI)<0 || 
      CopyBuffer(_ADX_Manusear,2,0,3,_MenorDI)<0 || 
      CopyBuffer(_ADX_Manusear,2,0,3,_MenorDI)<0 || 
      CopyBuffer(_MALong_Manusear,0,0,3,_MALong_Valor) < 0 ||
      CopyBuffer(_ATR_Manusear,0,0,3,_ATR_Valor)<0     
      )
      ShowErro("Erro ao copiar Buffers dos indicadores",GetLastError());

   if(CopyRates(_Simbolo,_Periodo,0,4,mrate)<0)
      ShowErro("Error ao copiar dados da cota��o do hist�rico",GetLastError());

   if(!SymbolInfoTick(_Simbolo,latest_price))
      ShowErro("Erro ao obter a �ltima cota��o de pre�o",GetLastError());
  }
//+------------------------------------------------------------------+ 
//| Exibir mensagens com c�digo do erro.                             | 
//+------------------------------------------------------------------+
int Ea_2MAdxClass::ShowErro(string msg,int erroCode)
  {
   ResetLastError();
   if(erroCode != NULL)
      Alert(msg,"-erro: ",erroCode,"!!");
   else Alert(msg+"!!");  
   return -1;   
  }
//+------------------------------------------------------------------+ 
//| Exibir apenas mensagem.                                          | 
//+------------------------------------------------------------------+
void Ea_2MAdxClass::ShowAlert(string msg)
  {
   ResetLastError();
   Alert(msg+"!!");   
  }
//+------------------------------------------------------------------+ 
//| Abrir posi��o Trade.                                             | 
//+------------------------------------------------------------------+
void Ea_2MAdxClass::AbrirPosicao(ENUM_ORDER_TYPE typeOrder)
  {      
   //if(_clUtils.IsNewDay()) GetInformation();
   
   if(!_clUtils.ValidarHoraEntrada(_HoraInicio,_HoraFim)) return;
      
   // Se j� alcan�ou meta di�ria, n�o opera mais   
   if(_clUtils.IsMetaDiaria(_ValorTotalMeta,_TipoMeta,totalProfit,valarTotalLoss,_ValorCorretagem,totalCorretagem,_Lote)) return;
     
   if((_TotalGain > 0 && totalGains >= _TotalGain) || (_TotalLoss > 0 && totalLoss >= _TotalLoss)) return;
   
   primeiraSaida = segundaSaida = false;   
      
   GetBuffers();
      
   double sl = 0.00;
   double tp = 0.00;

   if(typeOrder==ORDER_TYPE_BUY)
     {
      if((_Digits==5) && _StopLoss>0)
         sl= NormalizeDouble(latest_price.bid - (_StopLoss *_Point)*10,_Digits);
      else if(_StopLoss>0) sl=latest_price.bid-NormalizeDouble(_StopLoss,_Digits);

      if((_Digits==5) && _TakeProfit>0)
         tp= NormalizeDouble(latest_price.bid + (_TakeProfit*_Point)*10,_Digits);
      else if(_TakeProfit>0) tp=latest_price.bid+NormalizeDouble(_TakeProfit,_Digits);
      
      if(_UsarStopATR)               
         sl = latest_price.bid-NormalizeDouble((_ATR_Valor[0] * 2.5),_Digits);      
      
      cTrade.SetExpertMagicNumber(_NumeroMagico);
      cTrade.Buy(_Lote,_Simbolo,latest_price.bid,sl,tp,MQL5InfoString(MQL5_PROGRAM_NAME)+" (Compra)");
     }
   else if(typeOrder==ORDER_TYPE_SELL)
     {
      if((_Digits==5) && _StopLoss>0)
         sl= NormalizeDouble(latest_price.ask + (_StopLoss *_Point)*10,_Digits);
      else if(_StopLoss>0) sl=latest_price.ask+NormalizeDouble(_StopLoss,_Digits);

      if((_Digits==5) && _TakeProfit>0)
         tp= NormalizeDouble(latest_price.ask - (_TakeProfit*_Point)*10,_Digits);
      else if(_TakeProfit>0) tp=latest_price.ask-NormalizeDouble(_TakeProfit,_Digits);
      
      if(_UsarStopATR)               
         sl = latest_price.ask+NormalizeDouble((_ATR_Valor[0] * 2.5),_Digits);
      
      cTrade.SetExpertMagicNumber(_NumeroMagico);
      cTrade.Sell(_Lote,_Simbolo,latest_price.ask,sl,tp,MQL5InfoString(MQL5_PROGRAM_NAME)+" (Venda)");
     }
  }
//+------------------------------------------------------------------+ 
//| Verifica condi��o de sa�da do Trade.                             | 
//+------------------------------------------------------------------+
bool Ea_2MAdxClass::CheckCloseTrade()
  {
   // Se hora de saida return true ou verifica setup de saida    
    if(_clUtils.ValidarHoraSaida(_HoraFim))
     {
         ClosePosition();
         return(true);
     }
   else
     {
      GetBuffers();
      
      if(_clUtils.IsMetaDiaria(_ValorTotalMeta,_TipoMeta,totalProfit,valarTotalLoss,_ValorCorretagem,totalCorretagem,_Lote))
      {
         ClosePosition();
         return(true);
      }     
     }
   _clUtils.IsNewBar(_Simbolo);
   return(false);
  }
//+------------------------------------------------------------------+ 
//| Fechar todas as posi��es do trade                                | 
//+------------------------------------------------------------------+
void Ea_2MAdxClass::ClosePosition(void)
  {
   cTrade.PositionClose(_Simbolo,0);
  }
//+------------------------------------------------------------------+ 
//| Fechar todas as posi��es do trade                                | 
//+------------------------------------------------------------------+
void Ea_2MAdxClass::BreakEven(ENUM_POSITION_TYPE typeOrder)
  {   
	if(_UsarBreakEven) 
	{ 
	   _clUtils.SetNumeroMagico(_NumeroMagico);
      _clUtils.BreakEven(_Simbolo,typeOrder,_BreakEvenVal,_TicksAcimaBreakEven);   
   }
  }
  
//+------------------------------------------------------------------+ 
//| Executa Trailing Stop                                            | 
//+------------------------------------------------------------------+
void Ea_2MAdxClass::TrainlingStop(ENUM_POSITION_TYPE typeOrder)
{
   if(_UsarTralingStop)
   {
      _clUtils.SetNumeroMagico(_NumeroMagico);
      _clUtils.TrailingStop(_Simbolo,typeOrder,_InicioTrailingStop,_MudancaTrailingStop);
   }
} 

//+------------------------------------------------------------------+ 
//| Retorna informa��es na tela sobre os trades                      | 
//+------------------------------------------------------------------+
void Ea_2MAdxClass::GetInformation(void)
  {
   string CurrDate=TimeToString(TimeCurrent(),TIME_DATE);
   HistorySelect(StringToTime(CurrDate),TimeCurrent());
   
   int deals=HistoryDealsTotal();
   int returns=0;
   double profit=0;
   double loss=0;
   totalProfit=0;
   //totalTaxas=0;
   totalCorretagem=0;
   totalGains=0;
   totalLoss=0;
   valarTotalLoss=0;
      
   //--- scan through all of the deals in the history
   for(int i=0;i<deals;i++)
     {
      //--- obtain the ticket of the deals by its index in the list
      ulong deal_ticket=HistoryDealGetTicket(i);
      if(deal_ticket>0) // obtain into the cache the deal, and work with it
        {
         string symbol             =HistoryDealGetString(deal_ticket,DEAL_SYMBOL);
         datetime time             =(datetime)HistoryDealGetInteger(deal_ticket,DEAL_TIME);
         ulong order               =HistoryDealGetInteger(deal_ticket,DEAL_ORDER);
         long order_magic          =HistoryDealGetInteger(deal_ticket,DEAL_MAGIC);
         double order_volume       =HistoryDealGetDouble(deal_ticket,DEAL_VOLUME);
         long pos_ID               =HistoryDealGetInteger(deal_ticket,DEAL_POSITION_ID);
         ENUM_DEAL_ENTRY entry_type=(ENUM_DEAL_ENTRY)HistoryDealGetInteger(deal_ticket,DEAL_ENTRY);
                  
         //--- process the deals with the indicated DEAL_MAGIC
         if(order_magic==_NumeroMagico)
           {
            //... necessary actions
           }        
         //--- calculate the losses and profits with a fixed results
         if(entry_type==DEAL_ENTRY_OUT)         
           {
            //--- increase the number of deals 
            returns++;
            //--- result of fixation
            double result=HistoryDealGetDouble(deal_ticket,DEAL_PROFIT);

            //--- input the positive results into the summarized profit
            if(result>0) 
              {
               profit+=result;
               totalProfit+=result;
               totalGains++;
              }
            //--- input the negative results into the summarized losses
            if(result<0) 
              {
               loss+=result;
               valarTotalLoss+=result;
               totalLoss++;              
              }
                             
             totalCorretagem += (_ValorCorretagem * order_volume);            
           }
        }
      else // unsuccessful attempt to obtain a deal
        {
         PrintFormat("We couldn't select a deal, with the index %d. Error %d",i,GetLastError());
        }
     }
               
   Comment("TOTAL DE ORDENS: "+ (string)returns +
           "\nGAIN=R$"+StringFormat("%.2f",profit) +
           "\nLOSS=R$"+StringFormat("%.2f",loss) +
           "\nCORRETAGEM=R$"+StringFormat("%.2f",totalCorretagem) +
           "\nTOTAL GAIN="+StringFormat("%d",totalGains) +
           "\nTOTAL LOSS="+StringFormat("%d",totalLoss)                                     
           );
}

void Ea_2MAdxClass::DesenharOBJ(double preco,long cor)
{
   ObjectDelete(0,"LnAjuste");
   if(preco <=0) return;   
   
   datetime date[];
   int bars=(int)ChartGetInteger(0,CHART_VISIBLE_BARS); 
   
   ArrayResize(date,bars);
   ZeroMemory(date);
   
   if(!date[0])
      date[0]=TimeCurrent();

   if(!preco)
      preco=SymbolInfoDouble(_Simbolo,SYMBOL_BID);
                      
   ObjectCreate(0,"LnAjuste",OBJ_HLINE,0,date[0],preco,0);           
   ObjectSetInteger(0,"LnAjuste",OBJPROP_COLOR,cor);
   ObjectSetInteger(0,"LnAjuste",OBJPROP_STYLE,STYLE_DASH);
   ObjectSetInteger(0,"LnAjuste",OBJPROP_WIDTH,3);
   ObjectSetInteger(0,"LnAjuste",OBJPROP_RAY_RIGHT,1);
   ObjectSetInteger(0,"LnAjuste",OBJPROP_RAY_LEFT,1);
}

//+------------------------------------------------------------------+ 
//| Saida Parcial                                                    | 
//+------------------------------------------------------------------+
void Ea_2MAdxClass::SaidaParcial(int tipoOrder)
{     
   // Executar a 1� Saida parcial
   if(primeiraSaida == false && _ValorSaidaParcial_1 > 0 && _LoteSaidaParcial_1 > 0 && _UsarSaidaParcial)
   {
     _clUtils.SetNumeroMagico(_NumeroMagico);
     primeiraSaida = _clUtils.SaidaParcial(_Simbolo,tipoOrder,_LoteSaidaParcial_1,_ValorSaidaParcial_1);
   } // Executar a 2� Saida parcial
   else if(segundaSaida == false && _ValorSaidaParcial_2 > 0 && _LoteSaidaParcial_2 > 0 && _UsarSaidaParcial)
   {
      _clUtils.SetNumeroMagico(_NumeroMagico);
      segundaSaida = _clUtils.SaidaParcial(_Simbolo,tipoOrder,_LoteSaidaParcial_2,_ValorSaidaParcial_2);
   }
}