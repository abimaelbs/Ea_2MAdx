//+------------------------------------------------------------------+
//|                                                     Ea_2MAdx.mq5 |
//|                               Copyright 2016,  Abimael B. Silva. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Abimael B. Silva."
#property link      "abimael.bs@gmail.com"
#property version   "1.08"
#property description "Este EA � basedo em 2 M�dias M�veis e um ADX, optimizado para WIN e WDO M1" // Description (line 1)
#property description "Compra: M�dia M�vel de curto per�odo deve estar acima da m�dia de Longo per�odo." 
#property description "Pre�o acima da M�dia de curto per�odo, entrada no rompimento e 2 candle" 
#property description "Venda: M�dia M�vel de curto per�odo deve estar abaixo da m�dia de Longo per�odo."
#property description "Pre�o abaixo da M�dia de curto per�odo, entrada no rompimento e 2 candle"
#property description "ADX(14) deve estar acima de 22."
#property description "ADX(+DI) subindo em 2 candle para compra." 
#property description "ADX(-DI) subindo em 2 candle para venda." 
#property icon        "\\Images\\Ea_2MAdx.ico"; // A file with the product icon

#include <Mine/Ea_2MAdxClass.mqh>
#include <Trade/PositionInfo.mqh>
#include <Mine/Utils.mqh>

//+------------------------------------------------------------------+ 
//| Enumerador dos m�todos de cria��o do manipulador                 | 
//+------------------------------------------------------------------+ 

// Parametros de entrada
input string   Sessao_01="===== Configura��es do volume"; //Volume (MINI-INDICE)
input double   Lote=3.0;            // Lotes para o Trade
input double   TakeProfit=300;      // Ganho TP(Pontos)
input double   StopLoss=80;         // Perda SL(Pontos)

input string   Sessao_02="===== Configura��o Realiza��o Parcial"; //Saida Parcial
input eConfirmar UsarSaidaParcial= true; // Usar Saida Parcial
input double   LoteSaidaParcial_1 = 1.0; // Lotes para saida parcial (Primeira)
input double   ValorSaidaParcial_1= 120; // Ganho TP Saida Parcial(Pontos)
input double   LoteSaidaParcial_2 = 1.0; // Lotes para saida parcial (Segunda)
input double   ValorSaidaParcial_2= 180; // Ganho TP Saida Parcial(Pontos)

input string   Sessao_03="===== Configura��es Break-Even"; //BreakEven
input eConfirmar UsarBreakEven=true; // Usar BreakEven
input double   BreakEven=60;        // Valor para in�cio Break Even
input double   PontosAcimaEntrada=20;// Pontos acima do pre�o de entrada

input string   Sessao_04="===== Configura��es Trailing Stop"; //Trailing Stop
input eConfirmar UsarTralingStop=true; // Usar Trailing Stop
input double   InicioTrailingStop=100; // In�cio Trailing Stop
input double   MudancaTrailing=20;     // Valor mudan�a Trailing Stop

input string   Sessao_05="===== Configura��o Quant. Op. Gain e Loss"; //Total Opera��es
input int      MaximoStopGain=0; // M�ximo total trade com Stop Gain
input int      MaximoStopLoss=2; // M�ximo total trade com Stop Loss

input string   Sessao_06="===== Configura��o Pre�o de Ajuste"; //Pre�o de Ajuste
input eConfirmar UsarPrecoAjuste = false; // Comprar/Vender no Pre�o de ajuste 
input double   PrecoAjuste = 0.0;   // Pre�o de Ajuste Preg�o Anterior
input color    CorLinhaAjuste = clrRoyalBlue; // Pre�o de ajuste(Cor)
//input ENUM_OBJECT Objeto = OBJ_HLINE;
input string   Sessao_07="===== Configura��o Meta Di�ria"; //Meta di�ria
input eConfirmar UsarMetaDiaria=true;  //Usar Meta Di�ia
input double   ValorCorretagem = 2.00; // Valor corretagem (R$)
//input double   ValorTaxas = 9.00;    // Valor taxa IBOV (R$)
input double   TotalMeta = 150.00;      // Total meta (R$)
input eTipoMeta TipoMeta = Liquido;    // Total do valor (Liquido/Bruto)

input string   Sessao_08="===== Configura��es Indicadores"; //Indicadores
input int      MA_Periodo=17;       // Per�odo M�dia M�vel
input int      MALong_Periodo=72;   // Per�odo M�dia M�vel Longa
input ENUM_MA_METHOD MetodoMM=MODE_EMA;// M�todo M�dia M�vel
input double   Adx_Min=21.0;           // Valor m�nimo ADX
input eConfirmar UsarStopATR = false;  // Usar Stop ATR

input string   Sessao_09="===== Configura��o Hor�rio Trade"; //Hor�rio
input string   HoraInicio = "09:10"; // Hora In�cio do Trader
input string   HoraFim    = "17:55"; // Hora Fim do Trader

input string   Sessao_11="===== Config. Hor�rio De N�o Operar"; // Hor�rio De N�o Operar
input string   WaitHoraInicio = "12:10"; // Hora In�cio de Aguardar
input string   WaitHoraFim    = "13:10"; // Hora Fim de Aguardar

input string   Sessao_10="===== Configura��o Identificador EA"; //ID
input int      EA_Magico=12345; // Identificador EA

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
   CExpert.SetUsarStopATR(UsarStopATR);
   
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
   if(UsarTralingStop && UsarBreakEven && BreakEven>0 && MudancaTrailing<PontosAcimaEntrada && MudancaTrailing > 0)
      return CExpert.ShowErro("Valor mudan�a Trailing Stop n�o pode ser menor que Pontos acima do pre�o de entrada do BreakEven.\nEA ser� fechado",NULL);     
      
   CExpert.GetInformation();
   CExpert.DesenharOBJ(PrecoAjuste,CorLinhaAjuste);
   Print(MQL5InfoString(MQL5_PROGRAM_NAME)," est� executando");
   
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   CExpert.DoUnit();
   Print(MQL5InfoString(MQL5_PROGRAM_NAME)," foi removido");
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   //--- Verifica se tem barras suficiente
   if(Bars(_Symbol,_Period)<30) {
      CExpert.ShowErro("Menos de 30 barras, o EA ser� fechado:",GetLastError());
      return;
     }

   if(!cPos.Select(_Symbol)) {
      ENUM_ORDER_TYPE typeOrder=CExpert.CheckOpenTrade();

      if(typeOrder==ORDER_TYPE_BUY || typeOrder==ORDER_TYPE_SELL) 
      {         
         CExpert.AbrirPosicao(typeOrder);
         primeiraSaida = segundaSaida = false;
      }
     }
   else
     {
      if(CExpert.CheckCloseTrade()) return;
      
      // Saida Parcial
      CExpert.SaidaParcial(cPos.PositionType());
                  
      // Braek even
      CExpert.BreakEven(cPos.PositionType());      
      
      // Trailing Stop
      CExpert.TrainlingStop(cPos.PositionType());
     }
  }
//+------------------------------------------------------------------+
//| Expert Checar Gains e Loss                                       |
//+------------------------------------------------------------------+
void OnTrade()
  {
   CExpert.GetInformation();
  }
//+------------------------------------------------------------------+

