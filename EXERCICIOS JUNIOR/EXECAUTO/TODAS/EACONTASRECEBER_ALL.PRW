#include "protheus.ch"
#include "topconn.ch"
#include "totvs.ch"

User Function ALLRECEBER()

Private lMsErroAuto := .F.

If !MsgYesNo("Confirma a opera��o no T�tulo a Receber?", "Aviso")
    Return
Endif

cPrefix := "TST"
cTitulo := "20240921"
cParcel := "02"
cTipoTt := "NF"
cNatureza := "1"
cCliente := "000001"
cLoja := "01"
dEmissao := StoD("20240921")
dVencto := CtoD("30/09/2024")
dVenctoRea := CtoD("30/09/2024")
nValor := 888
lDeletar := .F.
nOpcAuto := IIf(lDeletar, 5, 3)

aArray := { { "E1_PREFIXO"  , cPrefix        , NIL },;
            { "E1_NUM"      , PadR(cTitulo,TamSx3("E1_NUM")[1]), NIL },;
            { "E1_PARCELA"  , cParcel        , NIL },;
            { "E1_TIPO"     , PadR(cTipoTt,TamSx3("E1_TIPO")[1]), NIL },;
            { "E1_NATUREZ"  , PadR(cNatureza,TamSx3("E1_NATUREZ")[1]), NIL },;
            { "E1_CLIENTE"  , cCliente       , NIL },;
            { "E1_LOJA"     , cLoja          , NIL },;
            { "E1_EMISSAO"  , dEmissao       , NIL },;
            { "E1_VENCTO"   , dVencto        , NIL },;
            { "E1_VENCREA"  , dVenctoRea     , NIL },;
            { "E1_VALOR"    , nValor         , NIL } }

DbSelectArea("SE1")
DbSetOrder(1)

If DbSeek( xFilial("SE1") + cPrefix + PadR(cTitulo,TamSx3("E1_NUM")[1]) + cParcel + PadR(cTipoTt,TamSx3("E1_TIPO")[1]) )
    If nOpcAuto <> 5
        nOpcAuto := 4
    Endif
Else
    If lDeletar
        MsgAlert("T�tulo de Contas a Receber n�o encontrado para exclus�o!", "Aviso")
        Return
    Else
        MsgAlert("T�tulo de Contas a Receber n�o encontrado para altera��o!", "Aviso")
        Return
    Endif
Endif

MsExecAuto( { |x,y,z| FINA040(x,y,z)}, aArray, nOpcAuto)  // 3 - Inclus�o | 4 - Altera��o | 5 - Exclus�o

If lMsErroAuto
    MostraErro()
Else
    If nOpcAuto == 5
        MsgInfo("T�tulo " + SE1->E1_NUM + " exclu�do com sucesso!", "Aviso")
    ElseIf nOpcAuto == 4
        MsgInfo("T�tulo " + SE1->E1_NUM + " alterado com sucesso!", "Aviso")
    Else
        MsgInfo("T�tulo " + SE1->E1_NUM + " inclu�do com sucesso!", "Aviso")
    EndIf
Endif            

Return
