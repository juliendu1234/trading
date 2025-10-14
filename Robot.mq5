//+---------------------------------------------+
//|           TiAkTrade47Final                  |
//|     Auteur : Technic' informatique          |
//+---------------------------------------------+

#property copyright "© 2025, Technic informatique"
#property version   "4.0"
#property strict

#include <Trade\Trade.mqh>
CTrade trade;

//+---------------------+
//| Fonctions utilisées |
//+---------------------+
void ManagePendingOrders();
void ManageTrailingStopLoss();
void CheckCumulativeTP();
void PlaceBuyOrder();
void PlaceSellOrder();
void SetInitialStopLoss();
void SetInitialTakeProfit();
bool CanPlaceAnotherBuy();
bool CanPlaceAnotherSell();
void GetAllBuySidePrices(double &pricesBuySide[]);
void GetAllSellSidePrices(double &pricesSellSide[]);
int CountPositions(ENUM_POSITION_TYPE type);
int CountPendingOrders(ENUM_ORDER_TYPE type);
void DrawVirtualTP();
void CheckCloseOnCandleIfProfit();
double ComputeBuyTPPrice();
double ComputeSellTPPrice();
bool CanAffordNextTrade(double currentPrice, double lotSize);
int CountOpenTrades();

//+---------------------+
//| Paramétres externes |
//+---------------------+
input group "=== Paramètres Affichage ==="
input bool   EnableGraphics                    = true;           // Activer/Désactiver l'affichage graphique
input double Ratio                             = 1.0;            // 1.0 = base ; 0.8 = -20% ; 1.2 = +20%
input int    DisplayCount                      = 1;              // Nombre total de panneaux à afficher
input int    LongeurMagic                      = 3;              // Longeur du n° magique à afficher
input string DisplaySymbols                    = "GOOG111";      // Symbole+N°Magique à afficher (actif111,actif222)
input int    MagicNumber                       = 111;            // Numéro magique du robot
input string WebRequest_A_Rajouter             = "===== http://wyptekx.cluster029.hosting.ovh.net =====";
input color  PanelBackgroundColor              = clrLightBlue;   // Couleur de fond du panneau
input int    PanelWidth                        = 405;            // Largeur du panneau
input int    PanelHeight                       = 455;            // Hauteur du panneau
input int    OffsetX                           = 80;             // Décalage vers la droite du panneau
input int    OffsetY                           = 20;             // Décalage vers le bas du panneau
input color  Line1Color                        = clrOrangeRed;   // Couleur ligne 1
input int    Line1Size                         = 20;             // Taille ligne 1
input color  Line2Color                        = clrDarkViolet;  // Couleur ligne 2
input int    Line2Size                         = 14;             // Taille ligne 2
input color  Line7Color                        = clrDarkViolet;  // Couleur ligne 3
input int    Line7Size                         = 14;             // Taille ligne 3
input color  Line3Color                        = clrDeepSkyBlue; // Couleur ligne 4
input int    Line3Size                         = 14;             // Taille ligne 4
input color  Line3_1Color                      = clrDeepSkyBlue; // Couleur ligne 5
input int    Line3_1Size                       = 14;             // Taille ligne 5
input color  Line6Color                        = clrDeepSkyBlue; // Couleur ligne 6
input int    Line6Size                         = 14;             // Taille ligne 6
input color  Line4Color                        = clrLightSalmon; // Couleur ligne 7
input int    Line4Size                         = 14;             // Taille ligne 7
input color  Line4_1Color                      = clrLightSalmon; // Couleur ligne 8
input int    Line4_1Size                       = 14;             // Taille ligne 8
input color  Line5Color                        = clrLightSalmon; // Couleur ligne 9
input int    Line5Size                         = 14;             // Taille ligne 9

input group "=== Paramètres Achats ==="
input ENUM_TIMEFRAMES TimeframeBuy             = PERIOD_CURRENT; // Sélecteur de période
input int    StartHourBuy                      = 0;              // Heure de départ (0-23)
input int    StartMinuteBuy                    = 0;              // Minute de départ (0-59)
input double LotSizeBuy                        = 0.01;           // Lots de base
input double MaxLotSizeBuy                     = 0.01;           // Lots de base maximum (0 = aucune limite)
input double BaseVolumeBuy                     = 0.01;           // Lots pour la grille
input double MaxBaseVolumeBuy                  = 0.01;           // Lots pour la grille maximum (0 = aucune limite)
input double GridMultiplierBuy                 = 1.0;            // Multiplicateur de lots pour la grille
input int    MaxBuyTrades                      = 1;              // Nombre de trades maximum
input int    DistanceOrderBuy                  = 100;            // Distance entre le prix et les ordres
input int    TrailingDistanceOrderBuy          = 200;            // Distance de réajustement des ordres
input int    DistanceMinEntre2TradesBuy        = 300;            // Distance minimum entre 2 trades
input int    InitialStopLossBuy                = 0;              // SL (0 = aucun SL)
input int    InitialTakeProfitBuy              = 200;            // TP (0 = aucun TP)
input int    TrailingStartBuy                  = 1000000;        // Trailing Start
input int    TrailingStopLossBuy               = 1000000;        // Trailing Distance
enum         BuyTrailingMode { BUY_MODE_NONE   = 0, BUY_CUMUL_SINGLE = 1, BUY_CUMUL_MULTI = 2, BUY_CLOSE_CANDLE = 3 };
input        BuyTrailingMode BuyMode           = BUY_MODE_NONE;  // Mode de trailing
input bool InverserOrdresBuy                   = false;          // Inverser les ordres (BuyStop en BuyLimit)
input bool NouveauxOrdresAPrixPlusAvantageuxBuy = true;          // Nouveaux ordres à prix plus avantageux

input group "=== Paramètres Ventes ==="
input ENUM_TIMEFRAMES TimeframeSell            = PERIOD_CURRENT; // Sélecteur de période
input int    StartHourSell                     = 0;              // Heure de départ (0-23)
input int    StartMinuteSell                   = 0;              // Minute de départ (0-59)
input double LotSizeSell                       = 0.01;           // Lots de base
input double MaxLotSizeSell                    = 0.01;           // Lots de base maximum (0 = aucune limite)
input double BaseVolumeSell                    = 0.01;           // Lots pour la grille
input double MaxBaseVolumeSell                 = 0.01;           // Lots pour la grille maximum (0 = aucune limite)
input double GridMultiplierSell                = 1.0;            // Multiplicateur de lots pour la grille
input int    MaxSellTrades                     = 1;              // Nombre de trades maximum
input int    DistanceOrderSell                 = 100;            // Distance entre le prix et les ordres
input int    TrailingDistanceOrderSell         = 200;            // Distance de réajustement des ordres
input int    DistanceMinEntre2TradesSell       = 300;            // Distance minimum entre 2 trades
input int    InitialStopLossSell               = 0;              // SL (0 = aucun SL)
input int    InitialTakeProfitSell             = 200;            // TP (0 = aucun TP)
input int    TrailingStartSell                 = 1000000;        // Trailing Start
input int    TrailingStopLossSell              = 1000000;        // Trailing Distance
enum         SellTrailingMode { SELL_MODE_NONE   = 0, SELL_CUMUL_SINGLE = 1, SELL_CUMUL_MULTI = 2, SELL_CLOSE_CANDLE = 3 };
input        SellTrailingMode SellMode           = SELL_MODE_NONE;  // Mode de trailing
input bool InverserOrdresSell                    = false;        // Inverser les ordres (SellStop en SellLimit)
input bool NouveauxOrdresAPrixPlusAvantageuxSell = true;         // Nouveaux ordres à prix plus avantageux

input string Section_Tests                     = "===== Paramètres Backtests =====";
input bool   BackTestMode                      = true;          // Mode BackTest
input double MaxAccountBalance                 = 1000.0;          // Solde maximum du compte (€)
input double BackTestStopThreshold             = -1000.0;         // Arrêt du BackTest après perte en €
input int    BackTestSpread                    = 10;              // Spread personnalisé

input string Section_Security                  = "===== Paramètres Sécurité =====";
input double FixedCapital                      = 0.0;            // Capital fixe (0 = désactivé)
input double ZeroRiskPrice                     = 0.0;            // Prix point 0 (0 = auto)

//+--------------------+
//| Variables globales |
//+--------------------+

bool         PrematureStop                     = false;
double       g_initialBalance                  = 0.0;
bool         gridResetBuy                      = false;
bool         gridResetSell                     = false;
bool effectiveEnableGraphics;
string LicenseFileURL = "http://wyptekx.cluster029.hosting.ovh.net/Trading/Licences/TiAkTrade47Final.txt";
#ifndef CHART_WIDTH
#define CHART_WIDTH 0
#endif
#ifndef CHART_HEIGHT
#define CHART_HEIGHT 1
#endif

string Line1Text    = "Technic' informatique";
string Line1Font    = "Comic Sans MS";
int    Line1XOffset = 60;
int    Line1YOffset = 5;
string Line2Text    = "Panneau de contrôle";
string Line2Font    = "Comic Sans MS";
int    Line2XOffset = 10;
int    Line2YOffset = 45;
string Line7Text    = "Spread actuel :";
string Line7Font    = "Comic Sans MS";
int    Line7XOffset = 10;
int    Line7YOffset = 70;
string Line3Text    = "Nombre d'achats :";
string Line3Font    = "Comic Sans MS";
int    Line3XOffset = 10;
int    Line3YOffset = 105;
string Line3_1Text    = "Ajout/Modif. ordre d'achat dans : ";
string Line3_1Font    = "Comic Sans MS";
int    Line3_1XOffset = 10;
int    Line3_1YOffset = 130;
string Line6Text    = "Solde nul à la baisse :";
string Line6Font    = "Comic Sans MS";
int    Line6XOffset = 10;
int    Line6YOffset = 155;
string Line4Text    = "Nombre de ventes :";
string Line4Font    = "Comic Sans MS";
int    Line4XOffset = 10;
int    Line4YOffset = 190;
string Line4_1Text    = "Ajout/Modif. ordre de vente dans : ";
string Line4_1Font    = "Comic Sans MS";
int    Line4_1XOffset = 10;
int    Line4_1YOffset = 215;
string Line5Text    = "Solde nul à la hausse :";
string Line5Font    = "Comic Sans MS";
int    Line5XOffset = 10;
int    Line5YOffset = 240;
string Line8Text    = "Gains/Pertes (mois dernier) :";
string Line8Font    = "Comic Sans MS";
int    Line8Size    = 14;
color  Line8Color   = clrWhite;
int    Line8XOffset = 10;
int    Line8YOffset = 275;
string Line9Text    = "Gains/Pertes (mois en cours) :";
string Line9Font    = "Comic Sans MS";
int    Line9Size    = 14;
color  Line9Color   = clrWhite;
int    Line9XOffset = 10;
int    Line9YOffset = 300;
string Line10Text   = "Gains/Pertes (14j) :";
string Line10Font   = "Comic Sans MS";
int    Line10Size   = 14;
color  Line10Color  = clrWhite;
int    Line10XOffset = 10;
int    Line10YOffset = 325;
string Line11Text   = "Gains/Pertes (7j) :";
string Line11Font   = "Comic Sans MS";
int    Line11Size   = 14;
color  Line11Color  = clrWhite;
int    Line11XOffset = 10;
int    Line11YOffset = 350;
string Line12Text   = "Gains/Pertes (hier) :";
string Line12Font   = "Comic Sans MS";
int    Line12Size   = 14;
color  Line12Color  = clrWhite;
int    Line12XOffset = 10;
int    Line12YOffset = 375;
string Line13Text   = "Gains/Pertes (jour) :";
string Line13Font   = "Comic Sans MS";
int    Line13Size   = 14;
color  Line13Color  = clrWhite;
int    Line13XOffset = 10;
int    Line13YOffset = 400;
string Line14Text   = "Gains/Pertes actuel :";
string Line14Font   = "Comic Sans MS";
int    Line14Size   = 14;
color  Line14Color  = clrWhite;
int    Line14XOffset = 10;
int    Line14YOffset = 425;
string g_Symbols[];

//+-----------------------+
//| Extraction du symbole |
//+-----------------------+
string ExtractSymbol(string combined)
  {
   int len = StringLen(combined);
   if(len < LongeurMagic)
      return combined;
   bool isDigits = true;
   for(int i = len - LongeurMagic; i < len; i++)
     {
      string ch = StringSubstr(combined, i, 1);
      if(ch < "0" || ch > "9")
        {
         isDigits = false;
         break;
        }
     }
   if(isDigits)
      return StringSubstr(combined, 0, len - LongeurMagic);
   else
      return combined;
  }

//+------------------------------+
//| Extraction du numéro magique |
//+------------------------------+
long ExtractMagic(string combined)
  {
   int len = StringLen(combined);
   if(len < LongeurMagic)
      return 0;
   bool isDigits = true;
   for(int i = len - LongeurMagic; i < len; i++)
     {
      string ch = StringSubstr(combined, i, 1);
      if(ch < "0" || ch > "9")
        {
         isDigits = false;
         break;
        }
     }
   if(isDigits)
      return StringToInteger(StringSubstr(combined, len - LongeurMagic));
   else
      return 0;
  }

//+-------------------------+
//| Couleur selon le profit |
//+-------------------------+
color GetProfitColor(double profit)
  {
   if(profit > 0)
      return clrLimeGreen;
   else
      if(profit < 0)
         return clrCrimson;
   return clrWhite;
  }

//+-------------------------------------------------------+
//| Calcul du profit pour un symbole et un numéro magique |
//+-------------------------------------------------------+
double CalculateProfitSymbol(string symbol, long magicNumber, datetime startTime, datetime endTime)
  {
   double totalProfit = 0;
   if(!HistorySelect(startTime, endTime))
     {
      return 0;
     }
   int totalDeals = HistoryDealsTotal();
   for(int i = 0; i < totalDeals; i++)
     {
      ulong dealTicket = HistoryDealGetTicket(i);
      if(dealTicket <= 0)
         continue;
      if(HistoryDealGetInteger(dealTicket, DEAL_ENTRY) != DEAL_ENTRY_OUT)
         continue;
      string dealSymbol = HistoryDealGetString(dealTicket, DEAL_SYMBOL);
      datetime dealTime = (datetime)HistoryDealGetInteger(dealTicket, DEAL_TIME);
      double dealProfit = HistoryDealGetDouble(dealTicket, DEAL_PROFIT);
      long dealMagic = HistoryDealGetInteger(dealTicket, DEAL_MAGIC);
      ulong dealPositionId = HistoryDealGetInteger(dealTicket, DEAL_POSITION_ID);
      if(dealSymbol == symbol &&
         dealTime >= startTime &&
         dealTime < endTime &&
         (dealMagic == magicNumber || (magicNumber != 0 && dealMagic == 0)))
        {
         totalProfit += dealProfit;
         totalProfit += HistoryDealGetDouble(dealTicket, DEAL_SWAP);
         totalProfit += HistoryDealGetDouble(dealTicket, DEAL_COMMISSION);
        }
     }
   return totalProfit;
  }

//+---------------------------+
//| Calcul du profit flottant |
//+---------------------------+
double CalculateFloatingProfitSymbol(string symbol, long magic)
{
   double floatingProfit = 0.0;
   double totalCosts = 0.0;
   int totalPositions = PositionsTotal();
   for(int i = 0; i < totalPositions; i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
      {
         if(StringCompare(PositionGetString(POSITION_SYMBOL), symbol) == 0)
         {
            if(magic > 0)
            {
               if(PositionGetInteger(POSITION_MAGIC) != magic)
                  continue;
            }
            floatingProfit += PositionGetDouble(POSITION_PROFIT);
            totalCosts += PositionGetDouble(POSITION_SWAP);
            ulong positionId = PositionGetInteger(POSITION_IDENTIFIER);
            if(HistorySelectByPosition(positionId))
            {
               int deals = HistoryDealsTotal();
               for(int j = 0; j < deals; j++)
               {
                  ulong dealTicket = HistoryDealGetTicket(j);
                  if(dealTicket > 0)
                  {
                     totalCosts += HistoryDealGetDouble(dealTicket, DEAL_COMMISSION);
                  }
               }
            }
         }
      }
   }
   return floatingProfit + totalCosts;
}

//+-------------------------------------------+
//| Calcul du solde-out pour les positions BUY |
//+-------------------------------------------+
double CalculateBreakEvenLongSymbol(string symbol)
  {
   double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   double floatingProfitLoss = AccountInfoDouble(ACCOUNT_PROFIT);
   double currentPrice = SymbolInfoDouble(symbol, SYMBOL_ASK);
   double contractSize = SymbolInfoDouble(symbol, SYMBOL_TRADE_CONTRACT_SIZE);
   double totalVolumeBuy = 0;
   for(int i = 0; i < PositionsTotal(); i++)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
        {
         if(StringCompare(PositionGetString(POSITION_SYMBOL), symbol) == 0 &&
            (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
           {
            totalVolumeBuy += PositionGetDouble(POSITION_VOLUME);
           }
        }
     }
   double equity = accountBalance + floatingProfitLoss;
   double breakEvenPrice = 0.0;
   if(totalVolumeBuy > 0)
     {
      breakEvenPrice = currentPrice - (equity / (contractSize * totalVolumeBuy));
     }
   else
     {
      breakEvenPrice = currentPrice;
     }
   return breakEvenPrice;
  }

//+------------------------------------------=-+
//| Calcul du solde-out pour les positions SELL |
//+-----------------------------------------=--+
double CalculateBreakEvenShortSymbol(string symbol)
  {
   double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   double floatingProfitLoss = AccountInfoDouble(ACCOUNT_PROFIT);
   double currentPrice = SymbolInfoDouble(symbol, SYMBOL_BID);
   double contractSize = SymbolInfoDouble(symbol, SYMBOL_TRADE_CONTRACT_SIZE);
   double totalVolumeSell = 0;
   for(int i = 0; i < PositionsTotal(); i++)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
        {
         if(StringCompare(PositionGetString(POSITION_SYMBOL), symbol) == 0 &&
            (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
           {
            totalVolumeSell += PositionGetDouble(POSITION_VOLUME);
           }
        }
     }
   double equity = accountBalance + floatingProfitLoss;
   double breakEvenPrice = 0.0;
   if(totalVolumeSell > 0)
     {
      breakEvenPrice = currentPrice + (equity / (contractSize * totalVolumeSell));
     }
   else
     {
      breakEvenPrice = currentPrice;
     }
   return breakEvenPrice;
  }

//+-------------------------------------------+
//| Positionnement du panneau selon son index |
//+-------------------------------------------+
void GetDynamicPanelPositionForPanel(int index, int &posX, int &posY)
  {
   posX = OffsetX + index * (((int)(PanelWidth * Ratio)) + 5);
   posY = OffsetY;
  }

//+----------------------------------------------------+
//| Mise à jour d’un objet texte pour un panneau donné |
//+----------------------------------------------------+
void UpdateTextLineEx(const string name,
                      const string text,
                      const string font,
                      const int    size,
                      const color  col,
                      const int    baseX,
                      const int    baseY,
                      const int    offsetX,
                      const int    offsetY)
  {
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetString(0, name, OBJPROP_FONT, font);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, (int)(size * Ratio));
   ObjectSetInteger(0, name, OBJPROP_COLOR, col);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, baseX + (int)(offsetX * Ratio));
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, baseY + (int)(offsetY * Ratio));
  }

//+---------------------------------------------------------+
//| Mise à jour du panneau pour un symbole + numéro magique |
//+---------------------------------------------------------+
void UpdatePanelForSymbol(string symWithMagic, int index)
  {
   int posX, posY;
   GetDynamicPanelPositionForPanel(index, posX, posY);
   string actualSymbol = ExtractSymbol(symWithMagic);
   long magicNumber    = ExtractMagic(symWithMagic);
   string panelName = "ControlPanel_" + IntegerToString(index);
   ObjectSetInteger(0, panelName, OBJPROP_XDISTANCE, posX);
   ObjectSetInteger(0, panelName, OBJPROP_YDISTANCE, posY);
   ObjectSetInteger(0, panelName, OBJPROP_XSIZE, (int)(PanelWidth * Ratio));
   ObjectSetInteger(0, panelName, OBJPROP_YSIZE, (int)(PanelHeight * Ratio));
   datetime now = TimeCurrent();
   MqlDateTime dt;
   TimeToStruct(now, dt);
   dt.hour = 0;
   dt.min = 0;
   dt.sec = 0;
   datetime todayStart = StructToTime(dt);
   datetime monthStart = StringToTime(StringFormat("%04d.%02d.01 00:00:00", dt.year, dt.mon));
   datetime lastMonthStart = monthStart - 30 * 86400;
   double profit_last_month = CalculateProfitSymbol(actualSymbol, magicNumber, lastMonthStart, monthStart);
   double profit_this_month = CalculateProfitSymbol(actualSymbol, magicNumber, monthStart, now);
   double profit_14j = CalculateProfitSymbol(actualSymbol, magicNumber, now - 14 * 86400, now);
   double profit_7j = CalculateProfitSymbol(actualSymbol, magicNumber, now - 7 * 86400, now);
   double profit_hier = CalculateProfitSymbol(actualSymbol, magicNumber, todayStart - 86400, todayStart - 1);
   double profit_jour = CalculateProfitSymbol(actualSymbol, magicNumber, todayStart, now);
   double profit_float = CalculateFloatingProfitSymbol(actualSymbol, magicNumber);
   double ask = SymbolInfoDouble(actualSymbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(actualSymbol, SYMBOL_BID);
   double point = SymbolInfoDouble(actualSymbol, SYMBOL_POINT);
   double spreadPoints = (BackTestMode) ? BackTestSpread : ((ask != 0 && bid != 0) ? (ask - bid) / point : 0.0);
   double breakEvenShort = CalculateBreakEvenShortSymbol(actualSymbol);
   double breakEvenLong = CalculateBreakEvenLongSymbol(actualSymbol);
   bool hasShort = false, hasLong = false;
   int totalPositions = PositionsTotal();
   int openBuyCount = 0, openSellCount = 0;
   for(int iPos = 0; iPos < totalPositions; iPos++)
     {
      ulong ticket = PositionGetTicket(iPos);
      if(PositionSelectByTicket(ticket))
        {
         if(StringCompare(PositionGetString(POSITION_SYMBOL), actualSymbol) == 0 &&
            (magicNumber == 0 || PositionGetInteger(POSITION_MAGIC) == magicNumber))
           {
            if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
              {
               hasShort = true;
               openSellCount++;
              }
            if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
              {
               hasLong = true;
               openBuyCount++;
              }
           }
        }
     }
   string timeLeftBuy = FormatTimeLeft(0, TimeframeBuy, StartHourBuy, StartMinuteBuy);
   string timeLeftSell = FormatTimeLeft(0, TimeframeSell, StartHourSell, StartMinuteSell);
   MqlDateTime brokerTime;
   TimeToStruct(TimeCurrent(), brokerTime);
   string brokerTimeStr = StringFormat("%02d:%02d:%02d", brokerTime.hour, brokerTime.min, brokerTime.sec);
   string fixedLine2 = "Actif : " + actualSymbol + " - N° magique : " + IntegerToString(magicNumber);
   UpdateTextLineEx("TextLine1_" + IntegerToString(index), Line1Text, Line1Font, Line1Size, Line1Color, posX, posY, Line1XOffset, Line1YOffset);
   UpdateTextLineEx("TextLine2_" + IntegerToString(index), fixedLine2, Line2Font, Line2Size, Line2Color, posX, posY, Line2XOffset, Line2YOffset);
   UpdateTextLineEx("TextLine3_" + IntegerToString(index),
                    openBuyCount == 0 ? Line3Text : Line3Text + " " + IntegerToString(openBuyCount),
                    Line3Font, Line3Size, Line3Color, posX, posY, Line3XOffset, Line3YOffset);
   UpdateTextLineEx("TextLine3_1_" + IntegerToString(index),
                    Line3_1Text + timeLeftBuy,
                    Line3_1Font, Line3_1Size, Line3_1Color, posX, posY, Line3_1XOffset, Line3_1YOffset);
   UpdateTextLineEx("TextLine6_" + IntegerToString(index),
                    hasLong ? Line6Text + " " + DoubleToString(breakEvenLong, _Digits) : Line6Text,
                    Line6Font, Line6Size, Line6Color, posX, posY, Line6XOffset, Line6YOffset);
   UpdateTextLineEx("TextLine4_" + IntegerToString(index),
                    openSellCount == 0 ? Line4Text : Line4Text + " " + IntegerToString(openSellCount),
                    Line4Font, Line4Size, Line4Color, posX, posY, Line4XOffset, Line4YOffset);
   UpdateTextLineEx("TextLine4_1_" + IntegerToString(index),
                    Line4_1Text + timeLeftSell,
                    Line4_1Font, Line4_1Size, Line4_1Color, posX, posY, Line4_1XOffset, Line4_1YOffset);
   UpdateTextLineEx("TextLine5_" + IntegerToString(index),
                    hasShort ? Line5Text + " " + DoubleToString(breakEvenShort, _Digits) : Line5Text,
                    Line5Font, Line5Size, Line5Color, posX, posY, Line5XOffset, Line5YOffset);
   UpdateTextLineEx("TextLine7_" + IntegerToString(index),
                    "Heure : " + brokerTimeStr + " - Spread : " + DoubleToString(spreadPoints, 0),
                    Line7Font, Line7Size, Line7Color, posX, posY, Line7XOffset, Line7YOffset);
   UpdateTextLineEx("TextLine8_" + IntegerToString(index),
                    Line8Text + " " + DoubleToString(profit_last_month, 2) + " €",
                    Line8Font, Line8Size, profit_last_month > 0 ? clrForestGreen : (profit_last_month < 0 ? clrCrimson : clrWhite),
                    posX, posY, Line8XOffset, Line8YOffset);
   UpdateTextLineEx("TextLine9_" + IntegerToString(index),
                    Line9Text + " " + DoubleToString(profit_this_month, 2) + " €",
                    Line9Font, Line9Size, profit_this_month > 0 ? clrForestGreen : (profit_this_month < 0 ? clrCrimson : clrWhite),
                    posX, posY, Line9XOffset, Line9YOffset);
   UpdateTextLineEx("TextLine10_" + IntegerToString(index),
                    Line10Text + " " + DoubleToString(profit_14j, 2) + " €",
                    Line10Font, Line10Size, profit_14j > 0 ? clrForestGreen : (profit_14j < 0 ? clrCrimson : clrWhite),
                    posX, posY, Line10XOffset, Line10YOffset);
   UpdateTextLineEx("TextLine11_" + IntegerToString(index),
                    Line11Text + " " + DoubleToString(profit_7j, 2) + " €",
                    Line11Font, Line11Size, profit_7j > 0 ? clrForestGreen : (profit_7j < 0 ? clrCrimson : clrWhite),
                    posX, posY, Line11XOffset, Line11YOffset);
   UpdateTextLineEx("TextLine12_" + IntegerToString(index),
                    Line12Text + " " + DoubleToString(profit_hier, 2) + " €",
                    Line12Font, Line12Size, profit_hier > 0 ? clrForestGreen : (profit_hier < 0 ? clrCrimson : clrWhite),
                    posX, posY, Line12XOffset, Line12YOffset);
   UpdateTextLineEx("TextLine13_" + IntegerToString(index),
                    Line13Text + " " + DoubleToString(profit_jour, 2) + " €",
                    Line13Font, Line13Size, profit_jour > 0 ? clrForestGreen : (profit_jour < 0 ? clrCrimson : clrWhite),
                    posX, posY, Line13XOffset, Line13YOffset);
   UpdateTextLineEx("TextLine14_" + IntegerToString(index),
                    Line14Text + " " + DoubleToString(profit_float, 2) + " €",
                    Line14Font, Line14Size, profit_float > 0 ? clrForestGreen : (profit_float < 0 ? clrCrimson : clrWhite),
                    posX, posY, Line14XOffset, Line14YOffset);
   ObjectSetInteger(0, "TextLine1_" + IntegerToString(index), OBJPROP_ALIGN, ALIGN_CENTER);
   ObjectSetInteger(0, "TextLine2_" + IntegerToString(index), OBJPROP_ALIGN, ALIGN_CENTER);
   string upLineName = "ZeroBalanceUpLine_" + IntegerToString(index);
   string downLineName = "ZeroBalanceDownLine_" + IntegerToString(index);
   if(openSellCount > 0)
     {
      if(ObjectFind(0, upLineName) == -1)
        {
         ObjectCreate(0, upLineName, OBJ_HLINE, 0, 0, 0);
         ObjectSetInteger(0, upLineName, OBJPROP_COLOR, Line5Color);
         ObjectSetInteger(0, upLineName, OBJPROP_BACK, true);
        }
      ObjectSetDouble(0, upLineName, OBJPROP_PRICE, breakEvenShort);
     }
   else
     {
      if(ObjectFind(0, upLineName) != -1)
         ObjectDelete(0, upLineName);
     }
   if(openBuyCount > 0)
     {
      if(ObjectFind(0, downLineName) == -1)
        {
         ObjectCreate(0, downLineName, OBJ_HLINE, 0, 0, 0);
         ObjectSetInteger(0, downLineName, OBJPROP_COLOR, Line6Color);
         ObjectSetInteger(0, downLineName, OBJPROP_BACK, true);
        }
      ObjectSetDouble(0, downLineName, OBJPROP_PRICE, breakEvenLong);
     }
   else
     {
      if(ObjectFind(0, downLineName) != -1)
         ObjectDelete(0, downLineName);
     }
  }

//+----------------------------+
//| Vérification de la licence |
//+----------------------------+
bool CheckLicense()
  {
   if(MQLInfoInteger(MQL_TESTER))
      return true;
   long accountNumber = AccountInfoInteger(ACCOUNT_LOGIN);
   char result[];
   char postData[];
   string headers;
   int httpCode = WebRequest("GET", LicenseFileURL, "", 5000, postData, result, headers);
   if(httpCode == 200)
     {
      string content = CharArrayToString(result);
      StringReplace(content, "\r", "\n");
      while(StringLen(content) > 0)
        {
         int pos = StringFind(content, "\n", 0);
         string line;
         if(pos >= 0)
           {
            line    = StringSubstr(content, 0, pos);
            content = StringSubstr(content, pos + 1);
           }
         else
           {
            line    = content;
            content = "";
           }
         StringTrimLeft(line);
         StringTrimRight(line);
         if(StringLen(line) == 0)
            continue;
         int posComment = StringFind(line, "#", 0);
         if(posComment != -1)
           {
            line = StringSubstr(line, 0, posComment);
            StringTrimLeft(line);
            StringTrimRight(line);
           }
         if(line == IntegerToString(accountNumber))
           {
            Print("Licence OK pour le compte ", accountNumber);
            return true;
           }
        }
      Print("Licence refusée : compte ", accountNumber, " non listé");
      return false;
     }
   Print("Erreur WebRequest. Code HTTP=", httpCode);
   return false;
  }

//+----------------------------------------------------------------------+
//| ComputeOpenProfit : Calcule le profit ouvert total sur les positions |
//| (filtré par MagicNumber et symbole)                                  |
//+----------------------------------------------------------------------+
double ComputeOpenProfit()
  {
   double totalProfit = 0.0;
   for(int i = 0; i < PositionsTotal(); i++)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
        {
         if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
            PositionGetString(POSITION_SYMBOL) == _Symbol)
           {
            totalProfit += PositionGetDouble(POSITION_PROFIT);
           }
        }
     }
   return totalProfit;
  }

//+------------------------------------------------------------------+
//| ComputeBuyTPPrice : Calcule le TP cible pour les trades BUY      |
//+------------------------------------------------------------------+
double ComputeBuyTPPrice()
{
   double point = _Point;
   double totalVolume = 0.0;
   double sumWeighted = 0.0;
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
      {
         if(PositionGetInteger(POSITION_MAGIC)==MagicNumber &&
            PositionGetString(POSITION_SYMBOL)==_Symbol &&
            (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
         {
            double vol = PositionGetDouble(POSITION_VOLUME);
            totalVolume += vol;
            sumWeighted += vol * PositionGetDouble(POSITION_PRICE_OPEN);
         }
      }
   }
   if(totalVolume < 0.000001)
      return 0.0;
   double weightedAvg = sumWeighted / totalVolume;
   double TP_global = weightedAvg + (InitialTakeProfitBuy * _Point);
   return TP_global;
}

//+------------------------------------------------------------------+
//| ComputeSellTPPrice : Calcule le TP cible pour les trades SELL    |
//+------------------------------------------------------------------+
double ComputeSellTPPrice()
{
   double point = _Point;
   double totalVolume = 0.0;
   double sumWeighted = 0.0;
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
      {
         if(PositionGetInteger(POSITION_MAGIC)==MagicNumber &&
            PositionGetString(POSITION_SYMBOL)==_Symbol &&
            (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
         {
            double vol = PositionGetDouble(POSITION_VOLUME);
            totalVolume += vol;
            sumWeighted += vol * PositionGetDouble(POSITION_PRICE_OPEN);
         }
      }
   }
   if(totalVolume < 0.000001)
      return 0.0;
   double weightedAvg = sumWeighted / totalVolume;
   double TP_global = weightedAvg - (InitialTakeProfitSell * _Point);
   return TP_global;
}

//+--------+
//| OnInit |
//+--------+
int OnInit()
  {
   effectiveEnableGraphics = EnableGraphics;
   if(!CheckLicense())
     {
      return(INIT_FAILED);
     }
   int symbolCount = StringSplit(DisplaySymbols, ',', g_Symbols);
   for(int i = symbolCount; i < DisplayCount; i++)
     {
      ArrayResize(g_Symbols, i + 1);
      g_Symbols[i] = _Symbol + "0";
     }
   if(effectiveEnableGraphics)
     {
      for(int i = 0; i < DisplayCount; i++)
        {
         string panelName = "ControlPanel_" + IntegerToString(i);
         if(!ObjectCreate(0, panelName, OBJ_RECTANGLE_LABEL, 0, 0, 0))
           {
            return(INIT_FAILED);
           }
         ObjectSetInteger(0, panelName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
         ObjectSetInteger(0, panelName, OBJPROP_XSIZE, PanelWidth);
         ObjectSetInteger(0, panelName, OBJPROP_YSIZE, PanelHeight);
         ObjectSetInteger(0, panelName, OBJPROP_BGCOLOR, PanelBackgroundColor);
         ObjectSetInteger(0, panelName, OBJPROP_COLOR, PanelBackgroundColor);
         ObjectSetString(0, panelName, OBJPROP_TEXT, "");
         ObjectSetInteger(0, panelName, OBJPROP_ZORDER, 0);
         string lineNames[] =
           {
            "TextLine1_", "TextLine2_", "TextLine3_", "TextLine3_1_", "TextLine6_",
            "TextLine4_", "TextLine4_1_", "TextLine5_", "TextLine7_",
            "TextLine8_", "TextLine9_", "TextLine10_", "TextLine11_",
            "TextLine12_", "TextLine13_", "TextLine14_"
           };
         for(int j = 0; j < ArraySize(lineNames); j++)
           {
            string objName = lineNames[j] + IntegerToString(i);
            if(!ObjectCreate(0, objName, OBJ_LABEL, 0, 0, 0))
              {
              }
            ObjectSetInteger(0, objName, OBJPROP_ZORDER, 2);
           }
         string hLineUp = "ZeroBalanceUpLine_" + IntegerToString(i);
         string hLineDown = "ZeroBalanceDownLine_" + IntegerToString(i);
         if(!ObjectCreate(0, hLineUp, OBJ_HLINE, 0, 0, 0))
            if(!ObjectCreate(0, hLineDown, OBJ_HLINE, 0, 0, 0))
               ObjectSetInteger(0, hLineUp, OBJPROP_COLOR, Line5Color);
         ObjectSetInteger(0, hLineUp, OBJPROP_BACK, false);
         ObjectSetInteger(0, hLineUp, OBJPROP_ZORDER, 1);
         ObjectSetInteger(0, hLineDown, OBJPROP_COLOR, Line6Color);
         ObjectSetInteger(0, hLineDown, OBJPROP_BACK, false);
         ObjectSetInteger(0, hLineDown, OBJPROP_ZORDER, 1);
        }
      for(int i = 0; i < DisplayCount; i++)
        {
         string sym = (i < ArraySize(g_Symbols)) ? g_Symbols[i] : (_Symbol + "0");
         UpdatePanelForSymbol(sym, i);
        }
     }
   g_initialBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   PrematureStop = false;
   return(INIT_SUCCEEDED);
  }

//+----------+
//| OnDeinit |
//+----------+
void OnDeinit(const int reason)
  {
   if(effectiveEnableGraphics)
     {
      string lineNames[] =
        {
         "TextLine1_", "TextLine2_", "TextLine3_", "TextLine3_1_", "TextLine6_",
         "TextLine4_", "TextLine4_1_", "TextLine5_", "TextLine7_",
         "TextLine8_", "TextLine9_", "TextLine10_", "TextLine11_",
         "TextLine12_", "TextLine13_", "TextLine14_"
        };
      for(int i = 0; i < DisplayCount; i++)
        {
         ObjectDelete(0, "ControlPanel_" + IntegerToString(i));
         for(int j = 0; j < ArraySize(lineNames); j++)
           {
            ObjectDelete(0, lineNames[j] + IntegerToString(i));
           }
         ObjectDelete(0, "ZeroBalanceUpLine_" + IntegerToString(i));
         ObjectDelete(0, "ZeroBalanceDownLine_" + IntegerToString(i));
        }
      ChartRedraw();
     }
  }

//+-------------------------------------------+
//| OnTick : Exécution principale de l'expert |
//+-------------------------------------------+
void OnTick()
{
   if(BackTestMode)
   {
      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      double equity  = AccountInfoDouble(ACCOUNT_EQUITY);
      double currentDrawdown = balance - equity;
      if(currentDrawdown >= MathAbs(BackTestStopThreshold))
      {
         Print("⛔ Drawdown max atteint : ", currentDrawdown, "€ ≥ ", MathAbs(BackTestStopThreshold), "€");
         PrematureStop = true;
         TesterStop();
         return;
      }
   }
   static datetime lastValidTradeTime = 0;
   bool isValidTimeBuy  = (MaxBuyTrades  > 0) ? IsValidTradingTime(TimeframeBuy, true)  : false;
   bool isValidTimeSell = (MaxSellTrades > 0) ? IsValidTradingTime(TimeframeSell, false) : false;
   if ((MaxBuyTrades == 0 || !isValidTimeBuy) && (MaxSellTrades == 0 || !isValidTimeSell))
   {
      if(effectiveEnableGraphics)
      {
         for(int i = 0; i < DisplayCount; i++)
         {
            string sym = (i < ArraySize(g_Symbols)) ? g_Symbols[i] : (_Symbol + "0");
            UpdatePanelForSymbol(sym, i);
         }
         ChartRedraw();
      }
      ManagePendingOrders();
      SetInitialStopLoss();
      SetInitialTakeProfit();
      ManageTrailingStopLoss();
      CheckCumulativeTP();
      if(BuyMode != BUY_MODE_NONE || SellMode != SELL_MODE_NONE)
         DrawVirtualTP();
      return;
   }
   if(effectiveEnableGraphics)
   {
      for(int i = 0; i < DisplayCount; i++)
      {
         string sym = (i < ArraySize(g_Symbols)) ? g_Symbols[i] : (_Symbol + "0");
         UpdatePanelForSymbol(sym, i);
      }
      ChartRedraw();
   }
   ManagePendingOrders();
   SetInitialStopLoss();
   SetInitialTakeProfit();
   ManageTrailingStopLoss();
   CheckCumulativeTP();
   if(BuyMode != BUY_MODE_NONE || SellMode != SELL_MODE_NONE)
      DrawVirtualTP();
   static datetime lastCandleTimeBuy = 0;
   static datetime lastCandleTimeSell = 0;
   datetime currentCandleTimeBuy  = (MaxBuyTrades  > 0) ? iTime(_Symbol, TimeframeBuy, 0)  : 0;
   datetime currentCandleTimeSell = (MaxSellTrades > 0) ? iTime(_Symbol, TimeframeSell, 0) : 0;
   if(MaxBuyTrades > 0 && currentCandleTimeBuy > lastCandleTimeBuy && isValidTimeBuy)
   {
      lastCandleTimeBuy = currentCandleTimeBuy;
      if(CountPositions(POSITION_TYPE_BUY) == 0)
      {
         if(!gridResetBuy)
         {
            for(int i = OrdersTotal()-1; i >= 0; i--)
            {
               ulong ticket = OrderGetTicket(i);
               if(OrderSelect(ticket))
               {
                  if(OrderGetInteger(ORDER_MAGIC) == MagicNumber &&
                     OrderGetString(ORDER_SYMBOL) == _Symbol)
                  {
                     ENUM_ORDER_TYPE otype = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
                     if(otype == ORDER_TYPE_BUY_STOP || otype == ORDER_TYPE_BUY_LIMIT)
                        trade.OrderDelete(ticket);
                  }
               }
            }
            gridResetBuy = true;
         }
      }
      else
         gridResetBuy = false;
      ENUM_ORDER_TYPE pendingTypeBuy = (!InverserOrdresBuy) ? ORDER_TYPE_BUY_STOP : ORDER_TYPE_BUY_LIMIT;
      if(CanPlaceAnotherBuy() &&
         CountPendingOrders(pendingTypeBuy) == 0 &&
         CountPositions(POSITION_TYPE_BUY) < MaxBuyTrades)
      {
         PlaceBuyOrder();
      }
   }
   if(MaxSellTrades > 0 && currentCandleTimeSell > lastCandleTimeSell && isValidTimeSell)
   {
      lastCandleTimeSell = currentCandleTimeSell;

      if(CountPositions(POSITION_TYPE_SELL) == 0)
      {
         if(!gridResetSell)
         {
            for(int i = OrdersTotal()-1; i >= 0; i--)
            {
               ulong ticket = OrderGetTicket(i);
               if(OrderSelect(ticket))
               {
                  if(OrderGetInteger(ORDER_MAGIC) == MagicNumber &&
                     OrderGetString(ORDER_SYMBOL) == _Symbol)
                  {
                     ENUM_ORDER_TYPE otype = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
                     if(otype == ORDER_TYPE_SELL_STOP || otype == ORDER_TYPE_SELL_LIMIT)
                        trade.OrderDelete(ticket);
                  }
               }
            }
            gridResetSell = true;
         }
      }
      else
         gridResetSell = false;
      ENUM_ORDER_TYPE pendingTypeSell = (!InverserOrdresSell) ? ORDER_TYPE_SELL_STOP : ORDER_TYPE_SELL_LIMIT;
      if(CanPlaceAnotherSell() &&
         CountPendingOrders(pendingTypeSell) == 0 &&
         CountPositions(POSITION_TYPE_SELL) < MaxSellTrades)
      {
         PlaceSellOrder();
      }
   }
   if((MaxBuyTrades > 0 && currentCandleTimeBuy > lastCandleTimeBuy) ||
      (MaxSellTrades > 0 && currentCandleTimeSell > lastCandleTimeSell))
   {
      CheckCloseOnCandleIfProfit();
   }
}

//+---------------------------------------------------------------+
//| OnTester : Critère d'optimisation personnalisé                |
//| Si le test a été stoppé prématurément, OnTester renvoie 0,    |
//| sinon, il renvoie le profit net (solde final - solde initial) |
//+---------------------------------------------------------------+
double OnTester()
  {
   if(PrematureStop)
      return 0;
   else
      return AccountInfoDouble(ACCOUNT_BALANCE) - g_initialBalance;
  }

//+--------------------------------------------------------------+
//| CheckCumulativeTP : Ferme les trades si le TP global atteint |
//| (utilise ComputeBuyTPPrice et ComputeSellTPPrice)            |
//+--------------------------------------------------------------+
void CheckCumulativeTP()
{
   double TP_global_buy = ComputeBuyTPPrice();
   double TP_global_sell = ComputeSellTPPrice();
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   
   if(TP_global_buy > 0 && bid >= TP_global_buy)
   {
      for(int i = PositionsTotal()-1; i >= 0; i--)
      {
         ulong ticket = PositionGetTicket(i);
         if(PositionSelectByTicket(ticket))
         {
            if(PositionGetInteger(POSITION_MAGIC)==MagicNumber &&
               PositionGetString(POSITION_SYMBOL)==_Symbol &&
               (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
            {
               if(trade.PositionClose(ticket))
                  Print("Cumul TP BUY atteint (TP_global=", TP_global_buy, "), fermeture trade ", ticket);
               else
                  Print("Erreur fermeture BUY trade ", ticket, ": ", trade.ResultRetcode());
            }
         }
      }
   }
   
   if(TP_global_sell > 0 && ask <= TP_global_sell)
   {
      for(int i = PositionsTotal()-1; i >= 0; i--)
      {
         ulong ticket = PositionGetTicket(i);
         if(PositionSelectByTicket(ticket))
         {
            if(PositionGetInteger(POSITION_MAGIC)==MagicNumber &&
               PositionGetString(POSITION_SYMBOL)==_Symbol &&
               (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
            {
               if(trade.PositionClose(ticket))
                  Print("Cumul TP SELL atteint (TP_global=", TP_global_sell, "), fermeture trade ", ticket);
               else
                  Print("Erreur fermeture SELL trade ", ticket, ": ", trade.ResultRetcode());
            }
         }
      }
   }
}

//+-------------------------------------------------------------------+
//| DrawVirtualTP : Trace la ligne horizontale TP virtuelle           |
//| Actualisée à chaque tick via ComputeBuyTPPrice/ComputeSellTPPrice |
//+-------------------------------------------------------------------+
void DrawVirtualTP()
  {
   if(BuyMode != BUY_MODE_NONE)
     {
      double TP_virtual_buy = ComputeBuyTPPrice();
      if(TP_virtual_buy > 0)
        {
         if(ObjectFind(0, "VirtualTP_BUY") < 0)
           {
            ObjectCreate(0, "VirtualTP_BUY", OBJ_HLINE, 0, 0, TP_virtual_buy);
           }
         else
           {
            ObjectSetDouble(0, "VirtualTP_BUY", OBJPROP_PRICE, TP_virtual_buy);
           }
         ObjectSetInteger(0, "VirtualTP_BUY", OBJPROP_COLOR, clrPurple);
         ObjectSetInteger(0, "VirtualTP_BUY", OBJPROP_WIDTH, 2);
         ObjectSetInteger(0, "VirtualTP_BUY", OBJPROP_BACK, true);
        }
      else
        {
         if(ObjectFind(0, "VirtualTP_BUY") >= 0)
            ObjectDelete(0, "VirtualTP_BUY");
        }
     }
   else
     {
      if(ObjectFind(0, "VirtualTP_BUY") >= 0)
         ObjectDelete(0, "VirtualTP_BUY");
     }
   if(SellMode != SELL_MODE_NONE)
     {
      double TP_virtual_sell = ComputeSellTPPrice();
      if(TP_virtual_sell > 0)
        {
         if(ObjectFind(0, "VirtualTP_SELL") < 0)
           {
            ObjectCreate(0, "VirtualTP_SELL", OBJ_HLINE, 0, 0, TP_virtual_sell);
           }
         else
           {
            ObjectSetDouble(0, "VirtualTP_SELL", OBJPROP_PRICE, TP_virtual_sell);
           }
         ObjectSetInteger(0, "VirtualTP_SELL", OBJPROP_COLOR, clrPurple);
         ObjectSetInteger(0, "VirtualTP_SELL", OBJPROP_WIDTH, 2);
         ObjectSetInteger(0, "VirtualTP_SELL", OBJPROP_BACK, true);
        }
      else
        {
         if(ObjectFind(0, "VirtualTP_SELL") >= 0)
            ObjectDelete(0, "VirtualTP_SELL");
        }
     }
   else
     {
      if(ObjectFind(0, "VirtualTP_SELL") >= 0)
         ObjectDelete(0, "VirtualTP_SELL");
     }
  }

//+--------------------------------------------------------------------+
//| ManageTrailingStopLoss : Applique le trailing sur les trades réels |
//+--------------------------------------------------------------------+
void ManageTrailingStopLoss()
{
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double point = _Point;
   
   for(int i = PositionsTotal()-1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
      {
         if(PositionGetInteger(POSITION_MAGIC)==MagicNumber &&
            PositionGetString(POSITION_SYMBOL)==_Symbol)
         {
            ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
            double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
            double stopLoss  = PositionGetDouble(POSITION_SL);
            double currentPrice = (type == POSITION_TYPE_BUY ? bid : ask);
            double profitPips = (type == POSITION_TYPE_BUY) ? (currentPrice - openPrice)/point
                                                            : (openPrice - currentPrice)/point;
            if(type == POSITION_TYPE_BUY)
            {
               if(profitPips >= TrailingStartBuy)
               {
                  double trailingStopDistance = TrailingStopLossBuy * point;
                  double newSL = NormalizeDouble(currentPrice - trailingStopDistance, _Digits);
                  if(newSL > stopLoss || stopLoss <= 0.0000001)
                     if(!trade.PositionModify(ticket, newSL, PositionGetDouble(POSITION_TP)))
                        Print("Erreur modification SL BUY : ", trade.ResultRetcode());
               }
            }
            else // SELL
            {
               if(profitPips >= TrailingStartSell)
               {
                  double trailingStopDistance = TrailingStopLossSell * point;
                  double newSL = NormalizeDouble(currentPrice + trailingStopDistance, _Digits);
                  if(newSL < stopLoss || stopLoss <= 0.0000001)
                     if(!trade.PositionModify(ticket, newSL, PositionGetDouble(POSITION_TP)))
                        Print("Erreur modification SL SELL : ", trade.ResultRetcode());
               }
            }
         }
      }
   }
}

//+------------------------------------------------------------+
//| ManagePendingOrders : Gère les ordres pendants en fonction |
//| du mode normal/inversé, séparé pour BUY et SELL            |
//+------------------------------------------------------------+
void ManagePendingOrders()
{
   double point = _Point;
   for(int i = OrdersTotal()-1; i >= 0; i--)
   {
      ulong ticket = OrderGetTicket(i);
      if(!OrderSelect(ticket))
         continue;
      
      if(OrderGetInteger(ORDER_MAGIC) != MagicNumber)
         continue;
      if(OrderGetString(ORDER_SYMBOL) != _Symbol)
         continue;
      
      ENUM_ORDER_TYPE otype = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
      double openPrice = OrderGetDouble(ORDER_PRICE_OPEN);
      
      // Gestion des ordres pending BUY
      if(otype == ORDER_TYPE_BUY_STOP || otype == ORDER_TYPE_BUY_LIMIT)
      {
         if(!InverserOrdresBuy && otype == ORDER_TYPE_BUY_STOP)
         {
            double desiredPrice = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK) + DistanceOrderBuy * point, _Digits);
            double diff = MathAbs(openPrice - desiredPrice);
            if(diff > TrailingDistanceOrderBuy * point)
            {
               trade.SetExpertMagicNumber(MagicNumber);
               if(!trade.OrderModify(ticket, desiredPrice, 0.0, 0.0, ORDER_TIME_GTC, 0, 0))
                  Print("Erreur modif BUY_STOP : ", trade.ResultRetcode());
            }
            if(NouveauxOrdresAPrixPlusAvantageuxBuy)
            {
               double lowestActiveBuy = -1;
               for(int j = PositionsTotal()-1; j >= 0; j--)
               {
                  ulong tick = PositionGetTicket(j);
                  if(PositionSelectByTicket(tick))
                  {
                     if(PositionGetInteger(POSITION_MAGIC)==MagicNumber &&
                        PositionGetString(POSITION_SYMBOL)==_Symbol &&
                        (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
                     {
                        double posPrice = PositionGetDouble(POSITION_PRICE_OPEN);
                        if(lowestActiveBuy < 0 || posPrice < lowestActiveBuy)
                           lowestActiveBuy = posPrice;
                     }
                  }
               }
               if(lowestActiveBuy > 0)
               {
                  double threshold = lowestActiveBuy - (DistanceMinEntre2TradesBuy + DistanceOrderBuy) * point;
                  if(openPrice > threshold)
                  {
                     if(!trade.OrderDelete(ticket))
                        Print("Erreur suppression BUY_STOP : ", trade.ResultRetcode());
                  }
               }
            }
         }
         else if(InverserOrdresBuy && otype == ORDER_TYPE_BUY_LIMIT)
         {
            double desiredPrice = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK) - DistanceOrderBuy * point, _Digits);
            double diff = MathAbs(openPrice - desiredPrice);
            if(diff > TrailingDistanceOrderBuy * point)
            {
               trade.SetExpertMagicNumber(MagicNumber);
               if(!trade.OrderModify(ticket, desiredPrice, 0.0, 0.0, ORDER_TIME_GTC, 0, 0))
                  Print("Erreur modif BUY_LIMIT : ", trade.ResultRetcode());
            }
            if(NouveauxOrdresAPrixPlusAvantageuxBuy)
            {
               double lowestActiveBuy = -1;
               for(int j = PositionsTotal()-1; j >= 0; j--)
               {
                  ulong tick = PositionGetTicket(j);
                  if(PositionSelectByTicket(tick))
                  {
                     if(PositionGetInteger(POSITION_MAGIC)==MagicNumber &&
                        PositionGetString(POSITION_SYMBOL)==_Symbol &&
                        (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
                     {
                        double posPrice = PositionGetDouble(POSITION_PRICE_OPEN);
                        if(lowestActiveBuy < 0 || posPrice < lowestActiveBuy)
                           lowestActiveBuy = posPrice;
                     }
                  }
               }
               if(lowestActiveBuy > 0)
               {
                  double threshold = lowestActiveBuy - (DistanceMinEntre2TradesBuy + DistanceOrderBuy) * point;
                  if(openPrice > threshold)
                  {
                     if(!trade.OrderDelete(ticket))
                        Print("Erreur suppression BUY_LIMIT : ", trade.ResultRetcode());
                  }
               }
            }
         }
      }
      
      // Gestion des ordres pending SELL
      if(otype == ORDER_TYPE_SELL_STOP || otype == ORDER_TYPE_SELL_LIMIT)
      {
         if(!InverserOrdresSell && otype == ORDER_TYPE_SELL_STOP)
         {
            double desiredPrice = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID) - DistanceOrderSell * point, _Digits);
            double diff = MathAbs(openPrice - desiredPrice);
            if(diff > TrailingDistanceOrderSell * point)
            {
               trade.SetExpertMagicNumber(MagicNumber);
               if(!trade.OrderModify(ticket, desiredPrice, 0.0, 0.0, ORDER_TIME_GTC, 0, 0))
                  Print("Erreur modif SELL_STOP : ", trade.ResultRetcode());
            }
            if(NouveauxOrdresAPrixPlusAvantageuxSell)
            {
               double highestActiveSell = -1;
               for(int j = PositionsTotal()-1; j >= 0; j--)
               {
                  ulong tick = PositionGetTicket(j);
                  if(PositionSelectByTicket(tick))
                  {
                     if(PositionGetInteger(POSITION_MAGIC)==MagicNumber &&
                        PositionGetString(POSITION_SYMBOL)==_Symbol &&
                        (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
                     {
                        double posPrice = PositionGetDouble(POSITION_PRICE_OPEN);
                        if(highestActiveSell < 0 || posPrice > highestActiveSell)
                           highestActiveSell = posPrice;
                     }
                  }
               }
               if(highestActiveSell > 0)
               {
                  double threshold = highestActiveSell + (DistanceMinEntre2TradesSell + DistanceOrderSell) * point;
                  if(openPrice < threshold)
                  {
                     if(!trade.OrderDelete(ticket))
                        Print("Erreur suppression SELL_STOP : ", trade.ResultRetcode());
                  }
               }
            }
         }
         else if(InverserOrdresSell && otype == ORDER_TYPE_SELL_LIMIT)
         {
            double desiredPrice = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK) + DistanceOrderSell * point, _Digits);
            double diff = MathAbs(openPrice - desiredPrice);
            if(diff > TrailingDistanceOrderSell * point)
            {
               trade.SetExpertMagicNumber(MagicNumber);
               if(!trade.OrderModify(ticket, desiredPrice, 0.0, 0.0, ORDER_TIME_GTC, 0, 0))
                  Print("Erreur modif SELL_LIMIT : ", trade.ResultRetcode());
            }
            if(NouveauxOrdresAPrixPlusAvantageuxSell)
            {
               double highestActiveSell = -1;
               for(int j = PositionsTotal()-1; j >= 0; j--)
               {
                  ulong tick = PositionGetTicket(j);
                  if(PositionSelectByTicket(tick))
                  {
                     if(PositionGetInteger(POSITION_MAGIC)==MagicNumber &&
                        PositionGetString(POSITION_SYMBOL)==_Symbol &&
                        (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
                     {
                        double posPrice = PositionGetDouble(POSITION_PRICE_OPEN);
                        if(highestActiveSell < 0 || posPrice > highestActiveSell)
                           highestActiveSell = posPrice;
                     }
                  }
               }
               if(highestActiveSell > 0)
               {
                  double threshold = highestActiveSell + (DistanceMinEntre2TradesSell + DistanceOrderSell) * point;
                  if(openPrice < threshold)
                  {
                     if(!trade.OrderDelete(ticket))
                        Print("Erreur suppression SELL_LIMIT : ", trade.ResultRetcode());
                  }
               }
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| CountOpenTrades : Compte le nombre total de trades ouverts       |
//+------------------------------------------------------------------+
int CountOpenTrades()
{
   int count = 0;
   for(int i = PositionsTotal()-1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
      {
         if(PositionGetInteger(POSITION_MAGIC)==MagicNumber &&
            PositionGetString(POSITION_SYMBOL)==_Symbol)
         {
            count++;
         }
      }
   }
   return count;
}

//+------------------------------------------------------------------+
//| CanAffordNextTrade : Vérifie si le capital fixe permet un trade  |
//| Contrôle que tous les trades + le nouveau ne dépassent pas le    |
//| capital fixe au point 0                                          |
//+------------------------------------------------------------------+
bool CanAffordNextTrade(double currentPrice, double lotSize)
{
   // Si FixedCapital est <= 0, la sécurité est désactivée
   if(FixedCapital <= 0)
      return true;
   
   // Calcul du prix effectif du point 0
   double effectiveZeroPrice = (ZeroRiskPrice <= 0) ? 0.01 : ZeroRiskPrice;
   if(currentPrice <= effectiveZeroPrice)
      return false;
   
   // Récupération de la taille du contrat
   double contractSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_CONTRACT_SIZE);
   if(contractSize <= 0)
      contractSize = 1.0;
   
   // Calcul du coût total si le prix descend au point 0
   double totalCostIfZero = 0.0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0 && PositionSelectByTicket(ticket))
      {
         if(PositionGetString(POSITION_SYMBOL) == _Symbol && 
            PositionGetInteger(POSITION_MAGIC) == MagicNumber)
         {
            double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
            double volume = PositionGetDouble(POSITION_VOLUME);
            double cost = volume * contractSize * (openPrice - effectiveZeroPrice);
            totalCostIfZero += cost;
         }
      }
   }
   
   // Ajout du coût du nouveau trade
   double newTradeCost = lotSize * contractSize * (currentPrice - effectiveZeroPrice);
   totalCostIfZero += newTradeCost;
   
   // Vérification si le capital fixe peut couvrir le coût
   bool canAfford = (totalCostIfZero <= FixedCapital);
   
   if(!canAfford)
   {
      Print("⛔ Capital de risque atteint : Coût total si prix = ", effectiveZeroPrice, 
            " serait ", totalCostIfZero, " € > Capital fixe ", FixedCapital, " €");
   }
   
   return canAfford;
}

//+--------------------------------------------------+
//| PlaceBuyOrder : Place un ordre pour "signal BUY" |
//| - Mode normal : utilise BUY_STOP                 |
//| - Mode inversé : utilise BUY_LIMIT               |
//+--------------------------------------------------+
void PlaceBuyOrder()
{
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double point = _Point;
   trade.SetExpertMagicNumber(MagicNumber);
   int gridBuy = CountPositions(POSITION_TYPE_BUY) + CountPendingOrders((!InverserOrdresBuy) ? ORDER_TYPE_BUY_STOP : ORDER_TYPE_BUY_LIMIT);
   double lotBuy = LotSizeBuy * MathPow(GridMultiplierBuy, gridBuy);
   double volStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   lotBuy = MathRound(lotBuy / volStep) * volStep;
   lotBuy = NormalizeDouble(lotBuy, 2);
   if(MaxLotSizeBuy > 0 && lotBuy > MaxLotSizeBuy)
      lotBuy = MaxLotSizeBuy;
   
   // Calcul du prix d'ordre prévisionnel
   double orderPrice;
   if(!InverserOrdresBuy)
      orderPrice = NormalizeDouble(ask + DistanceOrderBuy * point, _Digits);
   else
      orderPrice = NormalizeDouble(ask - DistanceOrderBuy * point, _Digits);
   
   // Vérification de la sécurité du capital
   if(!CanAffordNextTrade(orderPrice, lotBuy))
   {
      Print("⛔ PlaceBuyOrder : Trade refusé par sécurité du capital");
      return;
   }
   
   if(!InverserOrdresBuy)
   {
      if(!trade.BuyStop(lotBuy, orderPrice, _Symbol))
         Print("Erreur BuyStop (mode normal) : ", trade.ResultRetcode());
   }
   else
   {
      if(!trade.BuyLimit(lotBuy, orderPrice, _Symbol))
         Print("Erreur BuyLimit (mode inversé) : ", trade.ResultRetcode());
   }
}

//+----------------------------------------------------+
//| PlaceSellOrder : Place un ordre pour "signal SELL" |
//| - Mode normal : utilise SELL_STOP                  |
//| - Mode inversé : utilise SELL_LIMIT                |
//+----------------------------------------------------+
void PlaceSellOrder()
{
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double point = _Point;
   trade.SetExpertMagicNumber(MagicNumber);
   int gridSell = CountPositions(POSITION_TYPE_SELL) + CountPendingOrders((!InverserOrdresSell) ? ORDER_TYPE_SELL_STOP : ORDER_TYPE_SELL_LIMIT);
   double lotSell = LotSizeSell * MathPow(GridMultiplierSell, gridSell);
   double volStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   lotSell = MathRound(lotSell / volStep) * volStep;
   lotSell = NormalizeDouble(lotSell, 2);
   if(MaxLotSizeSell > 0 && lotSell > MaxLotSizeSell)
      lotSell = MaxLotSizeSell;
   
   // Calcul du prix d'ordre prévisionnel
   double orderPrice;
   if(!InverserOrdresSell)
      orderPrice = NormalizeDouble(bid - DistanceOrderSell * point, _Digits);
   else
      orderPrice = NormalizeDouble(bid + DistanceOrderSell * point, _Digits);
   
   // Vérification de la sécurité du capital
   if(!CanAffordNextTrade(orderPrice, lotSell))
   {
      Print("⛔ PlaceSellOrder : Trade refusé par sécurité du capital");
      return;
   }
   
   if(!InverserOrdresSell)
   {
      if(!trade.SellStop(lotSell, orderPrice, _Symbol))
         Print("Erreur SellStop (mode normal) : ", trade.ResultRetcode());
   }
   else
   {
      if(!trade.SellLimit(lotSell, orderPrice, _Symbol))
         Print("Erreur SellLimit (mode inversé) : ", trade.ResultRetcode());
   }
}

//+------------------------------------------------------------------+
//| SetInitialTakeProfit : Définit le TP pour un trade actif         |
//| si TP = 0 et si la clôture en fin de bougie n'est pas activée       |
//+------------------------------------------------------------------+
void SetInitialTakeProfit()
{
   double point = _Point;
   for(int i = PositionsTotal()-1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
      {
         if(PositionGetInteger(POSITION_MAGIC)==MagicNumber &&
            PositionGetString(POSITION_SYMBOL)==_Symbol)
         {
            ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
            double tp = PositionGetDouble(POSITION_TP);
            if(tp == 0.0)
            {
               double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
               double newTP;
               if(type == POSITION_TYPE_BUY)
               {
                  if(InitialTakeProfitBuy != 0 && BuyMode == BUY_MODE_NONE)
                     newTP = NormalizeDouble(openPrice + (InitialTakeProfitBuy * point), _Digits);
                  else
                     continue;
               }
               else
               {
                  if(InitialTakeProfitSell != 0 && SellMode == SELL_MODE_NONE)
                     newTP = NormalizeDouble(openPrice - (InitialTakeProfitSell * point), _Digits);
                  else
                     continue;
               }
               trade.PositionModify(ticket, PositionGetDouble(POSITION_SL), newTP);
            }
         }
      }
   }
}


//+------------------------------------------------------------------+
//| SetInitialStopLoss : Définit le SL pour un trade actif si SL = 0   |
//+------------------------------------------------------------------+
void SetInitialStopLoss()
{
   double point = _Point;
   for(int i = PositionsTotal()-1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
      {
         if(PositionGetInteger(POSITION_MAGIC)==MagicNumber &&
            PositionGetString(POSITION_SYMBOL)==_Symbol)
         {
            double sl = PositionGetDouble(POSITION_SL);
            if(sl == 0.0)
            {
               ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
               double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
               double newSL;
               if(type == POSITION_TYPE_BUY)
               {
                  if(InitialStopLossBuy != 0)
                     newSL = NormalizeDouble(openPrice - (InitialStopLossBuy * point), _Digits);
                  else
                     continue;
               }
               else // SELL
               {
                  if(InitialStopLossSell != 0)
                     newSL = NormalizeDouble(openPrice + (InitialStopLossSell * point), _Digits);
                  else
                     continue;
               }
               trade.PositionModify(ticket, newSL, PositionGetDouble(POSITION_TP));
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Peut-on placer un nouvel ordre "signal BUY" ?                     |
//+------------------------------------------------------------------+
bool CanPlaceAnotherBuy()
{
   double prospectivePrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK) + DistanceOrderBuy * _Point;
   double allPrices[];
   GetAllBuySidePrices(allPrices);
   int count = ArraySize(allPrices);
   if(count == 0)
      return true;
   if(NouveauxOrdresAPrixPlusAvantageuxBuy)
   {
      double lowestBuy = allPrices[0];
      for(int i = 1; i < count; i++)
         lowestBuy = MathMin(lowestBuy, allPrices[i]);
      double minPriceAllowed = lowestBuy - DistanceMinEntre2TradesBuy * _Point;
      if(prospectivePrice > minPriceAllowed)
         return false;
   }
   return true;
}

//+------------------------------------------------------------------+
//| Peut-on placer un nouvel ordre "signal SELL" ?                    |
//+------------------------------------------------------------------+
bool CanPlaceAnotherSell()
{
   double prospectivePrice = SymbolInfoDouble(_Symbol, SYMBOL_BID) - DistanceOrderSell * _Point;
   double allPrices[];
   GetAllSellSidePrices(allPrices);
   int count = ArraySize(allPrices);
   if(count == 0)
      return true;
   if(NouveauxOrdresAPrixPlusAvantageuxSell)
   {
      double highestSell = allPrices[0];
      for(int i = 1; i < count; i++)
         highestSell = MathMax(highestSell, allPrices[i]);
      double minPriceAllowed = highestSell + DistanceMinEntre2TradesSell * _Point;
      if(prospectivePrice < minPriceAllowed)
         return false;
   }
   return true;
}

//+------------------------------------------------------------------+
//| GetAllBuySidePrices : Récupère tous les prix d'ouverture BUY      |
//+------------------------------------------------------------------+
void GetAllBuySidePrices(double &pricesBuySide[])
{
   ArrayResize(pricesBuySide, 0);
   for(int i = PositionsTotal()-1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
      {
         if(PositionGetInteger(POSITION_MAGIC)==MagicNumber &&
            PositionGetString(POSITION_SYMBOL)==_Symbol &&
            (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
         {
            double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
            int n = ArraySize(pricesBuySide);
            ArrayResize(pricesBuySide, n+1);
            pricesBuySide[n] = openPrice;
         }
      }
   }
   for(int i = OrdersTotal()-1; i >= 0; i--)
   {
      ulong ticket = OrderGetTicket(i);
      if(OrderSelect(ticket))
      {
         if(OrderGetInteger(ORDER_MAGIC)==MagicNumber &&
            OrderGetString(ORDER_SYMBOL)==_Symbol)
         {
            ENUM_ORDER_TYPE otype = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
            if(otype == ORDER_TYPE_BUY_STOP || otype == ORDER_TYPE_BUY_LIMIT)
            {
               double openPrice = OrderGetDouble(ORDER_PRICE_OPEN);
               int n = ArraySize(pricesBuySide);
               ArrayResize(pricesBuySide, n+1);
               pricesBuySide[n] = openPrice;
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| GetAllSellSidePrices : Récupère tous les prix d'ouverture SELL    |
//+------------------------------------------------------------------+
void GetAllSellSidePrices(double &pricesSellSide[])
{
   ArrayResize(pricesSellSide, 0);
   for(int i = PositionsTotal()-1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
      {
         if(PositionGetInteger(POSITION_MAGIC)==MagicNumber &&
            PositionGetString(POSITION_SYMBOL)==_Symbol &&
            (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
         {
            double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
            int n = ArraySize(pricesSellSide);
            ArrayResize(pricesSellSide, n+1);
            pricesSellSide[n] = openPrice;
         }
      }
   }
   for(int i = OrdersTotal()-1; i >= 0; i--)
   {
      ulong ticket = OrderGetTicket(i);
      if(OrderSelect(ticket))
      {
         if(OrderGetInteger(ORDER_MAGIC)==MagicNumber &&
            OrderGetString(ORDER_SYMBOL)==_Symbol)
         {
            ENUM_ORDER_TYPE otype = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
            if(otype == ORDER_TYPE_SELL_STOP || otype == ORDER_TYPE_SELL_LIMIT)
            {
               double openPrice = OrderGetDouble(ORDER_PRICE_OPEN);
               int n = ArraySize(pricesSellSide);
               ArrayResize(pricesSellSide, n+1);
               pricesSellSide[n] = openPrice;
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| CountPositions : Compte le nombre de positions pour un type donné  |
//+------------------------------------------------------------------+
int CountPositions(ENUM_POSITION_TYPE type)
{
   int count = 0;
   for(int i = PositionsTotal()-1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
      {
         if(PositionGetInteger(POSITION_MAGIC)==MagicNumber &&
            PositionGetString(POSITION_SYMBOL)==_Symbol &&
            (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)==type)
         {
            count++;
         }
      }
   }
   return count;
}

//+------------------------------------------------------------------+
//| CountPendingOrders : Compte le nombre d'ordres pendants pour un type |
//+------------------------------------------------------------------+
int CountPendingOrders(ENUM_ORDER_TYPE type)
{
   int count = 0;
   for(int i = OrdersTotal()-1; i >= 0; i--)
   {
      ulong ticket = OrderGetTicket(i);
      if(OrderSelect(ticket))
      {
         if(OrderGetInteger(ORDER_MAGIC)==MagicNumber &&
            OrderGetString(ORDER_SYMBOL)==_Symbol &&
            (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE)==type)
         {
            count++;
         }
      }
   }
   return count;
}

//+-----------------------------------------------------------------------+
//| CheckCloseOnCandleIfProfit : Ferme les trades d'un côté si            |
//| le profit net est positif en fin de bougie, selon le réglage BUY/SELL |
//+-----------------------------------------------------------------------+
void CheckCloseOnCandleIfProfit()
{
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double point = _Point;
   double buyPips = 0.0;
   double sellPips = 0.0;
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
      {
         if(PositionGetInteger(POSITION_MAGIC)==MagicNumber &&
            PositionGetString(POSITION_SYMBOL)==_Symbol)
         {
            ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
            double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
            double volume    = PositionGetDouble(POSITION_VOLUME);
            double currentPrice = (type == POSITION_TYPE_BUY) ? bid : ask;
            double pips = (type == POSITION_TYPE_BUY)
                           ? (currentPrice - openPrice) / point
                           : (openPrice - currentPrice) / point;
            pips *= volume;
            if(type == POSITION_TYPE_BUY)
               buyPips += pips;
            else
               sellPips += pips;
         }
      }
   }
   if(BUY_CLOSE_CANDLE && buyPips > 0.0)
   {
      Print("CloseOnCandleIfProfit: BUY side in profit (", buyPips, " pips), closing all BUY trades.");
      for(int i = PositionsTotal()-1; i >= 0; i--)
      {
         ulong ticket = PositionGetTicket(i);
         if(PositionSelectByTicket(ticket))
         {
            if(PositionGetInteger(POSITION_MAGIC)==MagicNumber &&
               PositionGetString(POSITION_SYMBOL)==_Symbol &&
               (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
            {
               trade.PositionClose(ticket);
            }
         }
      }
      if(CountPositions(POSITION_TYPE_BUY) == 0)
         DeleteAllPendingOrdersAfterClose();
   }
   if(SELL_CLOSE_CANDLE && sellPips > 0.0)
   {
      Print("CloseOnCandleIfProfit: SELL side in profit (", sellPips, " pips), closing all SELL trades.");
      for(int i = PositionsTotal()-1; i >= 0; i--)
      {
         ulong ticket = PositionGetTicket(i);
         if(PositionSelectByTicket(ticket))
         {
            if(PositionGetInteger(POSITION_MAGIC)==MagicNumber &&
               PositionGetString(POSITION_SYMBOL)==_Symbol &&
               (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
            {
               trade.PositionClose(ticket);
            }
         }
      }
      if(CountPositions(POSITION_TYPE_SELL) == 0)
         DeleteAllPendingOrdersAfterClose();
   }
}

//+-------------------------------------------------------------+
//| GetAdjustedSpread : Retourne le spread ajusté selon le mode |
//+-------------------------------------------------------------+
double GetAdjustedSpread()
  {
   if(BackTestMode)
      return BackTestSpread * _Point;
   return SymbolInfoDouble(_Symbol, SYMBOL_ASK) - SymbolInfoDouble(_Symbol, SYMBOL_BID);
  }

//+------------------------------------------+
//| Fonction pour obtenir le prix Ask ajusté |
//+------------------------------------------+
double GetAdjustedAsk()
  {
   double basePrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   if(BackTestMode)
      return basePrice + (BackTestSpread * _Point);
   return SymbolInfoDouble(_Symbol, SYMBOL_ASK);
  }

//+------------------------------------------+
//| Fonction pour obtenir le prix Bid ajusté |
//+------------------------------------------+
double GetAdjustedBid()
  {
   if(BackTestMode)
      return SymbolInfoDouble(_Symbol, SYMBOL_BID);
   return SymbolInfoDouble(_Symbol, SYMBOL_BID);
  }

//+-------------------------------------+
//| Fonction pour gérer le portefeuille |
//+-------------------------------------+
bool CheckMarginForNewPosition(double lotSize, ENUM_POSITION_TYPE type)
  {
   if(!BackTestMode)
      return true;
   double margin = 0.0;
   ENUM_ORDER_TYPE orderType;
   if(type == POSITION_TYPE_BUY)
      orderType = ORDER_TYPE_BUY;
   else
      orderType = ORDER_TYPE_SELL;
   if(!OrderCalcMargin(orderType, _Symbol, lotSize,
                       (type == POSITION_TYPE_BUY) ? GetAdjustedAsk() : GetAdjustedBid(),
                       margin))
     {
      return false;
     }
   double currentMargin = AccountInfoDouble(ACCOUNT_MARGIN);
   double adjustedEquity = MathMin(AccountInfoDouble(ACCOUNT_EQUITY), MaxAccountBalance);
   double adjustedFreeMargin = adjustedEquity - currentMargin;
   bool canTrade = (margin <= adjustedFreeMargin);
   return canTrade;
  }

//+-------------------------------------------+
//| Fonction pour gérer les heures de Trading |
//+-------------------------------------------+
bool IsValidTradingTime(ENUM_TIMEFRAMES timeframe, bool isBuy)
  {
   datetime serverTime = TimeCurrent();
   MqlDateTime serverTimeStruct;
   TimeToStruct(serverTime, serverTimeStruct);
   int periodMinutes;
   switch(timeframe)
     {
      case PERIOD_M1:  periodMinutes = 1;     break;
      case PERIOD_M2:  periodMinutes = 2;     break;
      case PERIOD_M3:  periodMinutes = 3;     break;
      case PERIOD_M4:  periodMinutes = 4;     break;
      case PERIOD_M5:  periodMinutes = 5;     break;
      case PERIOD_M6:  periodMinutes = 6;     break;
      case PERIOD_M10: periodMinutes = 10;    break;
      case PERIOD_M12: periodMinutes = 12;    break;
      case PERIOD_M15: periodMinutes = 15;    break;
      case PERIOD_M20: periodMinutes = 20;    break;
      case PERIOD_M30: periodMinutes = 30;    break;
      case PERIOD_H1:  periodMinutes = 60;    break;
      case PERIOD_H2:  periodMinutes = 120;   break;
      case PERIOD_H3:  periodMinutes = 180;   break;
      case PERIOD_H4:  periodMinutes = 240;   break;
      case PERIOD_H6:  periodMinutes = 360;   break;
      case PERIOD_H8:  periodMinutes = 480;   break;
      case PERIOD_H12: periodMinutes = 720;   break;
      case PERIOD_D1:  periodMinutes = 1440;  break;
      case PERIOD_W1:  periodMinutes = 10080; break;
      case PERIOD_MN1: periodMinutes = 43200; break;
      default:
         return false;
     }
   int currentTimeInMinutes = serverTimeStruct.hour * 60 + serverTimeStruct.min;
   int startTimeInMinutes;
   if(isBuy)
      startTimeInMinutes = StartHourBuy * 60 + StartMinuteBuy;
   else
      startTimeInMinutes = StartHourSell * 60 + StartMinuteSell;
   int elapsedMinutes = currentTimeInMinutes - startTimeInMinutes;
   if(elapsedMinutes < 0)
      elapsedMinutes += 1440;
   bool isValidTime = (elapsedMinutes % periodMinutes == 0);
   return isValidTime;
  }

//+----------------------------------------+
//| Formatage du temps restant en HH:MM:SS |
//+----------------------------------------+
string FormatTimeLeft(int seconds, ENUM_TIMEFRAMES timeframe, int startHour, int startMinute)
{
   datetime currentTime = TimeCurrent();
   MqlDateTime dt;
   TimeToStruct(currentTime, dt);
   int periodMinutes;
   switch(timeframe)
   {
      case PERIOD_M1:  periodMinutes = 1;     break;
      case PERIOD_M2:  periodMinutes = 2;     break;
      case PERIOD_M3:  periodMinutes = 3;     break;
      case PERIOD_M4:  periodMinutes = 4;     break;
      case PERIOD_M5:  periodMinutes = 5;     break;
      case PERIOD_M6:  periodMinutes = 6;     break;
      case PERIOD_M10: periodMinutes = 10;    break;
      case PERIOD_M12: periodMinutes = 12;    break;
      case PERIOD_M15: periodMinutes = 15;    break;
      case PERIOD_M20: periodMinutes = 20;    break;
      case PERIOD_M30: periodMinutes = 30;    break;
      case PERIOD_H1:  periodMinutes = 60;    break;
      case PERIOD_H2:  periodMinutes = 120;   break;
      case PERIOD_H3:  periodMinutes = 180;   break;
      case PERIOD_H4:  periodMinutes = 240;   break;
      case PERIOD_H6:  periodMinutes = 360;   break;
      case PERIOD_H8:  periodMinutes = 480;   break;
      case PERIOD_H12: periodMinutes = 720;   break;
      case PERIOD_D1:  periodMinutes = 1440;  break;
      case PERIOD_W1:  periodMinutes = 10080; break;
      case PERIOD_MN1: periodMinutes = 43200; break;
      default:         periodMinutes = PeriodSeconds(timeframe)/60; break;
   }
   int currentMinutes = (dt.hour * 60) + dt.min;
   int startMinutes = (startHour * 60) + startMinute;
   int minutesSinceSync;
   if(currentMinutes >= startMinutes)
   {
      minutesSinceSync = (currentMinutes - startMinutes) % periodMinutes;
   }
   else
   {
      int minutesToMidnight = 1440 - startMinutes;
      minutesSinceSync = (minutesToMidnight + currentMinutes) % periodMinutes;
   }
   int secondsLeft = ((periodMinutes - minutesSinceSync) * 60) - dt.sec;
   if(secondsLeft <= 0)
   {
      secondsLeft = periodMinutes * 60;
   }
   int hours = (secondsLeft / 3600) % 24;
   int mins = (secondsLeft % 3600) / 60;
   int secs = secondsLeft % 60;
   return StringFormat("%02d:%02d:%02d", hours, mins, secs);
}

//+-----------------------------------------+
//| Calcul du prochain temps de mise à jour |
//+-----------------------------------------+
datetime CalculateNextUpdateTime(ENUM_TIMEFRAMES timeframe, int startHour, int startMinute)
  {
   datetime currentTime = TimeCurrent();
   MqlDateTime dt;
   TimeToStruct(currentTime, dt);
   int periodMinutes;
   switch(timeframe)
     {
      case PERIOD_M1:  periodMinutes = 1;     break;
      case PERIOD_M2:  periodMinutes = 2;     break;
      case PERIOD_M3:  periodMinutes = 3;     break;
      case PERIOD_M4:  periodMinutes = 4;     break;
      case PERIOD_M5:  periodMinutes = 5;     break;
      case PERIOD_M6:  periodMinutes = 6;     break;
      case PERIOD_M10: periodMinutes = 10;    break;
      case PERIOD_M12: periodMinutes = 12;    break;
      case PERIOD_M15: periodMinutes = 15;    break;
      case PERIOD_M20: periodMinutes = 20;    break;
      case PERIOD_M30: periodMinutes = 30;    break;
      case PERIOD_H1:  periodMinutes = 60;    break;
      case PERIOD_H2:  periodMinutes = 120;   break;
      case PERIOD_H3:  periodMinutes = 180;   break;
      case PERIOD_H4:  periodMinutes = 240;   break;
      case PERIOD_H6:  periodMinutes = 360;   break;
      case PERIOD_H8:  periodMinutes = 480;   break;
      case PERIOD_H12: periodMinutes = 720;   break;
      case PERIOD_D1:  periodMinutes = 1440;  break;
      case PERIOD_W1:  periodMinutes = 10080; break;
      case PERIOD_MN1: periodMinutes = 43200; break;
      default:
         periodMinutes = PeriodSeconds(timeframe)/60;
         break;
     }
   int currentMinutes = (dt.hour * 60) + dt.min;
   int startMinutes = (startHour * 60) + startMinute;
   int elapsedPeriods;
   if(currentMinutes >= startMinutes)
     {
      elapsedPeriods = (currentMinutes - startMinutes) / periodMinutes;
     }
   else
     {
      elapsedPeriods = -1;
     }
   int nextExecutionMinutes = startMinutes + ((elapsedPeriods + 1) * periodMinutes);
   if(nextExecutionMinutes >= 1440)
     {
      nextExecutionMinutes = startMinutes;
     }
   datetime nextTime = currentTime - (dt.hour * 3600 + dt.min * 60 + dt.sec);
   nextTime += nextExecutionMinutes * 60;
   if(nextTime <= currentTime)
     {
      nextTime += periodMinutes * 60;
     }
   return nextTime;
  }

//+---------------------------------------------------+
//| Calcule les frais de swap accumulés pour un trade |
//+---------------------------------------------------+
double GetAccumulatedSwapCost(ulong ticket)
{
   if(!PositionSelectByTicket(ticket))
      return 0.0;
   double totalCosts = PositionGetDouble(POSITION_SWAP);
   ulong positionId = PositionGetInteger(POSITION_IDENTIFIER);
   if(HistorySelectByPosition(positionId))
   {
      int deals = HistoryDealsTotal();
      for(int i = 0; i < deals; i++)
      {
         ulong dealTicket = HistoryDealGetTicket(i);
         if(dealTicket > 0)
         {
            totalCosts += HistoryDealGetDouble(dealTicket, DEAL_COMMISSION);
         }
      }
   }
   return totalCosts;
}

//+-----------------------------------+
//| Suppression des ordres en attente |
//+-----------------------------------+
void DeleteAllPendingOrdersAfterClose()
  {
   for(int i = OrdersTotal()-1; i >= 0; i--)
     {
      ulong ticket = OrderGetTicket(i);
      if(OrderSelect(ticket))
        {
         if(OrderGetInteger(ORDER_MAGIC) == MagicNumber &&
            OrderGetString(ORDER_SYMBOL) == _Symbol)
           {
            ENUM_ORDER_TYPE orderType = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
            if(orderType == ORDER_TYPE_BUY_STOP || orderType == ORDER_TYPE_BUY_LIMIT ||
               orderType == ORDER_TYPE_SELL_STOP || orderType == ORDER_TYPE_SELL_LIMIT)
              {
               trade.OrderDelete(ticket);
              }
           }
        }
     }
  }