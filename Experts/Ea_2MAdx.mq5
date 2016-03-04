//+------------------------------------------------------------------+
//|                                                     Ea_2MAdx.mq5 |
//|                               Copyright 2015,  Abimael B. Silva. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Abimael B. Silva."
#property link      "https://www.mql5.com"
#property version   "1.06"
#property description "Este EA é basedo em 2 Médias Móveis e um ADX, optimizado para WIN e WDO M1" // Description (line 1)
#property description "Compra: Média Móvel de curto período deve estar acima da média de Longo período." 
#property description "Preço acima da Média de curto período, entrada no rompimento e 2 candle" 
#property description "Venda: Média Móvel de curto período deve estar abaixo da média de Longo período."
#property description "Preço abaixo da Média de curto período, entrada no rompimento e 2 candle"
#property description "ADX(14) deve estar acima de 22."
#property description "ADX(+DI) subindo em 2 candle para compra." 
#property description "ADX(-DI) subindo em 2 candle para venda." 
#property icon        "\\Images\\EA_MMADX.ico"; // A file with the product icon

#include <Mine/Ea_2MAdxClass.mqh>
#include <Trade/PositionInfo.mqh>
#include <Mine/Utils.mqh>
//+------------------------------------------------------------------+ 
//| Enumerador dos métodos de criação do manipulador                 | 
//+------------------------------------------------------------------+ 

// Parametros de entrada
input string   Sessao_01="===== Configurações do volume"; //Volume (MINI-INDICE)
input double   Lote=3.0;            // Lotes para o Trade
input double   TakeProfit=300;      // Ganho TP(Pontos)
input double   StopLoss=80;         // Perda SL(Pontos)

input string   Sessao_02="===== Configuração Realização Parcial"; //Saida Parcial
input eConfirmar IsSaidaParcial= true; // Usar Saida Parcial
input double   LoteSaidaParcial_1 = 1.0; // Lotes para saida parcial (Primeira)
input double   ValorSaidaParcial_1= 100; // Ganho TP Saida Parcial(Pontos)
input double   LoteSaidaParcial_2 = 1.0; // Lotes para saida parcial (Segunda)
input double   ValorSaidaParcial_2= 150; // Ganho TP Saida Parcial(Pontos)

input string   Sessao_04="===== Configurações Break-Even"; //BreakEven
input eConfirmar UsarBreakEven=true; // Usar Breakeven
input double   BreakEven=60;        // Valor para início Break Even
input double   PontosAcimaEntrada=20;// Pontos acima do preço de entrada

input string   Sessao_05="===== Configurações Trailing Stop"; //Trailing Stop
input eConfirmar UsarTralingStop=true; // Usar Trailing Stop
input double   InicioTrailingStop=100;// Início Trailing Stop
input double   MudancaTrailing=20;   // Valor mudança Trailing Stop

input string   Sessao_06="===== Configuração Quant. Op. Gain e Loss"; //Total Operações
input int      MaximoStopGain=0; // Máximo total trade com Stop Gain
input int      MaximoStopLoss=4; // Máximo total trade com Stop Loss

input string   Sessao_07="===== Configuração Preço de Ajuste"; //Preço de Ajuste
input double   PrecoAjuste = 0.0;   // Comprar/Vender no Preço de ajuste
input color    CorLinhaAjuste = RoyalBlue; // Preço de ajuste(Cor)
//input ENUM_OBJECT Objeto = OBJ_HLINE;
input string   Sessao_08="===== Configuração Meta Diária"; //Meta diária
input eConfirmar UsarMetaDiaria=true; //Usar Meta Diáia
input double   ValorCorretagem = 2.00; // Valor corretagem (R$)
//input double   ValorTaxas = 9.00; // Valor taxa IBOV (R$)
input double   TotalMeta = 60.00; // Total meta (R$)
input eTipoMeta TipoMeta = Liquido; // Total do valor (Liquido/Bruto)

input string   Sessao_03="===== Configurações Indicadores"; //Indicadores
input int      MA_Periodo=17;       // Período Média Móvel
input int      MALong_Periodo=72;   // Período Média Móvel Longa
input ENUM_MA_METHOD MetodoMM=MODE_EMA;// Método Média Móvel
//input int      ADX_Period=14;      // ADX Período
input double   Adx_Min=20.0;       // Valor mínimo ADX

input string   Sessao_09="===== Configuração Horário Trade"; //Horário
input string   HoraInicio = "09:10"; // Hora Início do Trader
input string   HoraFim    = "17:55"; // Hora Fim do Trader
input string   Sessao_10="===== Configuração Identificador EA"; //ID
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
   CExpert.SetTicksBreakEven(PontosAcimaEntrada);
   CExpert.SetHoraInico(HoraInicio);
   CExpert.SetHoraFim(HoraFim);
   CExpert.SetUsarTralingStop(UsarTralingStop);
   CExpert.SetInicioTrailingStop(InicioTrailingStop);
   CExpert.SetMudancaTrailingStop(MudancaTrailing);
   CExpert.SetPrecoDeAjuste(PrecoAjuste);
   CExpert.SetValorCorretagem(ValorCorretagem);
   //CExpert.SetValorTaxaIBOV(ValorTaxas);
   CExpert.SetUsarMetaDiaria(UsarMetaDiaria);
   CExpert.SetValorTotalMeta(TotalMeta);
   CExpert.SetTipoMeta(TipoMeta);
   
   CExpert.SetUsarSaidaParcial(IsSaidaParcial);
   CExpert.SetLoteSaidaParcial_1(LoteSaidaParcial_1);
   CExpert.SetValorSaidaParcial_1(ValorSaidaParcial_1);
   CExpert.SetLoteSaidaParcial_2(LoteSaidaParcial_2);
   CExpert.SetValorSaidaParcial_2(ValorSaidaParcial_2);
   
   CExpert.DoInit(MA_Periodo,MALong_Periodo);
   
   if(IsSaidaParcial && LoteSaidaParcial_1 >= Lote)
   {
      CExpert.ShowAlert("Lote saida parcial não deve ser maior ou igual a Lote do Trade");
      return(-1);
   }
   
   if(CExpert.GetSimbolo() != EnumToString(WIN) && 
      CExpert.GetSimbolo() != EnumToString(WDO) && 
      CExpert.GetSimbolo() != EnumToString(EUR)
      )
   {
      CExpert.ShowAlert("Ativo diferente de Indice/Dolar futuro!");
      return(-1);
   }
   
   if(CExpert.GetPeriodo() < 2 )
      Print("Estratégia melhor em período acima de 2 minutos");
   if(UsarTralingStop && UsarBreakEven && BreakEven>0 && MudancaTrailing<PontosAcimaEntrada && MudancaTrailing > 0)
   {
      CExpert.ShowAlert("Valor mudança Trailing Stop não pode ser menor que Pontos acima do preço de entrada do BreakEven."+
      "\nEA será fechado");
      return(-1);
   }
      
   CExpert.GetInformation();
   CExpert.DesenharOBJ(PrecoAjuste,CorLinhaAjuste);
   Print(MQL5InfoString(MQL5_PROGRAM_NAME)," está executando");
   
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   //CExpert.~EA_MMADXClass();
   Print(MQL5InfoString(MQL5_PROGRAM_NAME)," foi removido");
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   //--- Verifica se tem barras suficiente
   if(Bars(_Symbol,_Period)<30) {
      CExpert.ShowErro("Menos de 30 barras, o EA será fechado:",GetLastError());
      return;
     }

   if(!cPos.Select(_Symbol)) {
      ENUM_ORDER_TYPE typeOrder=CExpert.CheckOpenTrade();

      if(typeOrder==ORDER_TYPE_BUY || typeOrder==ORDER_TYPE_SELL) 
      {
         CExpert.AbrirPosicao(typeOrder);
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

