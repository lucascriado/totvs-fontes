#include "protheus.ch"
#include "topconn.ch"
#include "totvs.ch"

User Function DELEARECEBER()

// RpcSetEnv("99", "01")

Private lMsErroAuto := .F.
Private cOk := .F.

If !MsgYesNo("Confirma excluir esse Título a Receber ?","Aviso")
    Return
Endif


cPrefix := "TST"
cTitulo := "20240921 "
cParcel := "02"
cTipoTt := "NF "
cNatureza := "1     "
cCliente := "000001"
cLoja := "01"
dEmissao := StoD("20240921")
dVencto := CtoD("30/09/2024")
dVenctoRea := CtoD("30/09/2024")
nValor := 888

DbSelectArea("SE1")
DbSetOrder(1)

If DbSeek( xFilial("SE1") + cPrefix + PadR(cTitulo,TamSx3("E1_NUM")[1]) + cParcel + PadR(cTipoTt,TamSx3("E1_TIPO")[1]) )
    
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

    MsExecAuto( { |x,y| FINA040(x,y)} , aArray, 5)  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão
    cOk := .T.
Else
    cOk := .F.    
Endif


If lMsErroAuto

    MostraErro()

Else
    If cOk
        MsgInfo("Título "+SE1->E1_NUM+" excluido com sucesso!","Aviso")
    Else
        MsgStop("Título não encontrado!","Erro")
    Endif
Endif            

Return
