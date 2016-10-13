//+------------------------------------------------------------------+
//|                                                     Ea_2MAdx.mq5 |
//|                               Copyright 2016,  Abimael B. Silva. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Abimael B. Silva."
#property link      "abimael.bs@gmail.com"
#property version   "1.09"
#property description "Utilizando 2 M�dias M�veis e o indicador ADX, optimizado para WIN e WDO M2" // Description (line 1)
#property description "Compra: M�dia M�vel de curto per�odo deve estar acima da m�dia de Longo per�odo." 
#property description "Pre�o acima da M�dia de curto per�odo, entrada no rompimento e 2 candle" 
#property description "Venda: M�dia M�vel de curto per�odo deve estar abaixo da m�dia de Longo per�odo."
#property description "Pre�o abaixo da M�dia de curto per�odo, entrada no rompimento e 2 candle"
#property description "ADX(14) deve estar acima de 22."
#property description "ADX(+DI) subindo para compra." 
#property description "ADX(-DI) subindo para venda." 
#property icon        "\\Images\\Ea_2MAdx.ico"; // A file with the product icon

#include <Mine/Ea_2MAdxClass.mqh>
#include <Trade/PositionInfo.mqh>
#include <Mine/Utils.mqh>

//+------------------------------------------------------------------+ 
//| Enumerador dos m�todos de cria��o do manipulador                 | 
//+------------------------------------------------------------------+ 

// Parametros de entrada
input string   Sessao_01="===== Config. do volume (MINI-INDICE)"; // Volume 
input double   Lote      =1.0;            // Lotes para o Trade
input double   TakeProfit=250;      // Ganho TP(Pontos)
input double   StopLoss  =100;         // Perda SL(Pontos)

input string   Sessao_02 ="===== Config. Quant. Op. Gain e Loss"; //Total Opera��es
input int      MaximoStopGain=5; // M�ximo trade com Stop Gain
input int      MaximoStopLoss=2; // M�ximo trade com Stop Loss 

input string   Sessao_03 ="===== Configura��o Realiza��o Parcial"; //Saida Parcial
input eConfirmar UsarSaidaParcial = true; // Usar Saida Parcial ?
input double   LoteSaidaParcial_1 = 1.0; // Lotes para saida parcial (Primeira)
input double   ValorSaidaParcial_1= 150; // Ganho TP Saida Parcial(Pontos)
input double   LoteSaidaParcial_2 = 1.0; // Lotes para saida parcial (Segunda)
input double   ValorSaidaParcial_2= 250; // Ganho TP Saida Parcial(Pontos)

input string   Sessao_04="===== Configura��es Break-Even"; //BreakEven
input eConfirmar UsarBreakEven=true; // Usar BreakEven ?
input double   BreakEven=70;         // Valor para in�cio Break Even
input double   PontosAcimaEntrada=20;// Pontos acima do pre�o de entrada

input string   Sessao_05="===== Configura��es Trailing Stop"; //Trailing Stop
input eConfirmar UsarTralingStop =true; // Usar Trailing Stop ?
input double   InicioTrailingStop=100;  // In�cio Trailing Stop
input double   MudancaTrailing   =10;   // Valor mudan�a Trailing Stop

input string   Sessao_06="===== Configura��o Pre�o de Ajuste"; //Pre�o de Ajuste
input eConfirmar UsarPrecoAjuste = false; // Comprar/Vender no Pre�o de ajuste ? 
input double   PrecoAjuste    = 0.0;         // Pre�o de Ajuste Preg�o Anterior
input color    CorLinhaAjuste = clrRoyalBlue; // Pre�o de ajuste(Cor)
//input ENUM_OBJECT Objeto = OBJ_HLINE;
input string   Sessao_07="===== Configura��o Meta Di�ria"; //Meta di�ria
input eConfirmar UsarMetaDiaria=true;  // Usar Meta Di�ria ?
input double   ValorCorretagem = 2.00; // Valor corretagem (R$)
//input double   ValorTaxas = 9.00;    // Valor taxa IBOV (R$)
input double   PorcentagemMeta = 0.00; // Valor da Meta em porcentagem (%)
input double   TotalMeta = 40.00;     // Total meta Gain (R$)
input eTipoMeta TipoMeta = Liquido;    // Total do valor (Liquido/Bruto)
//input double   TotalPrejuizo = 100.00;// Limite de Perca (R$)

input string   Sessao_08="===== Configura��es Indicadores"; //Indicadores
input int      MA_Periodo=17;          // Per�odo M�dia M�vel Curta
input int      MALong_Periodo=72;      // Per�odo M�dia M�vel Longa
input ENUM_MA_METHOD MetodoMM=MODE_EMA;// M�todo M�dia M�vel
input double   Adx_Min=20.0;           // Valor m�nimo ADX
//input eConfirmar UsarStopATR = false;// Usar Stop ATR

input string   Sessao_09="===== Configura��o Hor�rio Trade"; //Hor�rio
input string   HoraInicio = "09:15"; // Hora In�cio do Trader
input string   HoraFim    = "17:55"; // Hora Fim do Trader

input string   Sessao_10="===== Config. Hor�rio De N�o Operar"; // Hor�rio De N�o Operar
input string   WaitHoraInicio = "15:35"; // Hora In�cio de Aguardar
input string   WaitHoraFim    = "16:10"; // Hora Fim de Aguardar

input string   Sessao_11="===== Configura��o Identificador EA"; //ID
input eConfirmar UsarSom = true; // Tocar som ao realizar opera��o ?
input int      EA_Magico=12345;  // Identificador EA

// Criando objeto da classe
CPositionInfo cPos;
Ea_2MAdxClass CExpert;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   CExpert.SetSimbolo(_Symbol);
   CExpert.SetPeriodo(_Period);
   CExpert.SetNumeroMagico(EA_Magico);
   CExpert.SetLote(Lote);
   CExpert.SetADX_Minimo(Adx_Min);
   CExpert.SetTakeProfit(TakeProfit);
   CExpert.SetStopLoss(StopLoss);
   CExpert.SetMaxGain(MaximoStopGain);
   CExpert.SetMaxLoss(MaximoStopLoss);
   CExpert.SetUsarBreakEven(UsarBreakEven);
   CExpert.SetBreakEven(BreakEven);
   CExpert.SetMetodoMA(MetodoMM);
   CExpert.SetWaitHoraInico(WaitHoraInicio);
   CExpert.SetWaitHoraFim(WaitHoraFim);
   CExpert.SetTicksBreakEven(PontosAcimaEntrada);
   CExpert.SetHoraInico(HoraInicio);
   CExpert.SetHoraFim(HoraFim);
   CExpert.SetUsarTralingStop(UsarTralingStop);
   CExpert.SetInicioTrailingStop(InicioTrailingStop);
   CExpert.SetMudancaTrailingStop(MudancaTrailing);
   CExpert.SetUsarPrecoAjuste(UsarPrecoAjuste);
   CExpert.SetPrecoDeAjuste(PrecoAjuste);
   CExpert.SetValorCorretagem(ValorCorretagem);
   //CExpert.SetValorTaxaIBOV(ValorTaxas);
   CExpert.SetUsarMetaDiaria(UsarMetaDiaria);
   CExpert.SetValorTotalMeta(TotalMeta);
   CExpert.SetTipoMeta(TipoMeta);
   //CExpert.SetUsarStopATR(UsarStopATR);
   CExpert.SetTamanhoMaxCadle((_Digits==3 || _Digits==5) ? 10:180); // Tamanho m�ximo do candle anterior
   CExpert.SetUsarSom(UsarSom);   
   CExpert.SetUsarSaidaParcial(UsarSaidaParcial);
   CExpert.SetLoteSaidaParcial_1(LoteSaidaParcial_1);
   CExpert.SetValorSaidaParcial_1(ValorSaidaParcial_1);
   CExpert.SetLoteSaidaParcial_2(LoteSaidaParcial_2);
   CExpert.SetValorSaidaParcial_2(ValorSaidaParcial_2);
   
   CExpert.DoInit(MA_Periodo,MALong_Periodo);
   
   if(WaitHoraInicio != "" && WaitHoraFim =="")
    return CExpert.ShowErro("Informe a hora final de n�o abrir Opera��o",NULL);
      
   if((UsarSaidaParcial && LoteSaidaParcial_1 > Lote) || (UsarSaidaParcial && LoteSaidaParcial_2 > Lote) )   
      return CExpert.ShowErro("Lote saida parcial n�o deve ser maior que Lote do Trade",NULL);   
   
   if(CExpert.GetSimbolo() != EnumToString(WIN) && CExpert.GetSimbolo() != EnumToString(WDO) && CExpert.GetSimbolo() != EnumToString(EUR))        
      return CExpert.ShowErro("Ativo diferente de WIN/WDO/EUR futuro!",NULL);    
      
   if(CExpert.GetPeriodo() < 2 ) Print("Estrat�gia melhor em per�odo acima de 1 minuto");
   
   //if(UsarTralingStop && UsarBreakEven && BreakEven>0 && MudancaTrailing<PontosAcimaEntrada && MudancaTrailing > 0)
      //return CExpert.ShowErro("Valor mudan�a Trailing Stop n�o pode ser menor que Pontos acima do pre�o de entrada do BreakEven.\nEA ser� fechado",NULL);
      
   if(UsarTralingStop && UsarBreakEven && BreakEven>0 && InicioTrailingStop>0 && InicioTrailingStop<BreakEven )
      return CExpert.ShowErro("Valor Trailing Stop n�o pode ser menor que BreakEven.\nEA ser� fechado",NULL);     
         
   CExpert.GetInformation();
   CExpert.DesenharOBJ(PrecoAjuste,CorLinhaAjuste);
   Print(MQL5InfoString(MQL5_PROGRAM_NAME)," est� executando");
   
   //Print("Initial margin requirements for 1 lot=",Mar MarketInfo(Symbol(),MODE_MARGININIT)); 
   
   //int symbol_order_mode=(int)SymbolInfoInteger(symbol,SYMBOL_ORDER_MODE); 
   
   //if ((SYMBOL_MARGIN_INITIAL&symbol_order_mode)== SYMBOL_MARGIN_INITIAL)
   
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   CExpert.DoUnit();   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
 {      
   //--- Verifica se tem barras suficiente
   if(Bars(_Symbol,_Period)<30) 
   {
      CExpert.ShowErro("Menos de 30 barras, o EA ser� fechado:",GetLastError());
      return;
   }

   if(!cPos.Select(_Symbol) && !CExpert.GetMetaOk())
   {     
      ENUM_ORDER_TYPE _TipoOrder = CExpert.CheckOpenTrade();
      
      if(_TipoOrder==ORDER_TYPE_BUY || _TipoOrder==ORDER_TYPE_SELL) 
      {         
         CExpert.AbrirPosicao(_TipoOrder);
         primeiraSaida = segundaSaida = false;
      }
   }
   else
   {
      if(CExpert.CheckCloseTrade()) return;
      
      // Saida Parcial
      CExpert.SaidaParcial(cPos.PositionType());
                  
      // BreakEven
      CExpert.BreakEven(cPos.PositionType());      
      
      // Trailing Stop
      CExpert.TrainlingStop(cPos.PositionType());
   }
}
//+------------------------------------------------------------------+
//| Expert Checar Gains e Loss / Executado a cada opera��o           |
//+------------------------------------------------------------------+
void OnTrade()
{   
   CExpert.GetInformation();
}
//+------------------------------------------------------------------+
