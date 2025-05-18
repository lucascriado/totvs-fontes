#include "protheus.ch"
#include "topconn.ch"
#include "totvs.ch"

User Function DELEAPAGAR()

Private lMsErroAuto := .F.
Private cOk := .F.

If !MsgYesNo("Confirma excluir esse Título a Pagar ?", "Aviso")
    Return
Endif

cPrefix := "TSS"
cTitulo := "20240111"
cParcel := "02"
cTipoTt := "NF"
cNaturez := "1"
cFornecedor := "000001"
cLoja := "01"
cEmissao := StoD("20240921")
cVencimento := StoD("20240921")
cVenctoReal := StoD("20240921")
cVlrTitulo := 600

DbSelectArea("SE2")
DbSetOrder(1)

If DbSeek( xFilial("SE2") + cPrefix + PadR(cTitulo,TamSx3("E2_NUM")[1]) + cParcel + PadR(cTipoTt,TamSx3("E2_TIPO")[1]) + cFornecedor + cLoja )

    aArray := { { "E2_PREFIXO"  , cPrefix     , NIL },;
                { "E2_NUM"      , PadR(cTitulo,TamSx3("E2_NUM")[1]),      NIL },;
                { "E2_PARCELA"  , cParcel     , NIL },;
                { "E2_TIPO"     , PadR(cTipoTt,TamSx3("E2_TIPO")[1]),     NIL },;
                { "E2_NATUREZ"  , PadR(cNaturez,TamSx3("E2_NATUREZ")[1]), NIL },;
                { "E2_FORNECE"  , cFornecedor , NIL },;
                { "E2_LOJA"     , cLoja       , NIL },;
                { "E2_EMISSAO"  , cEmissao    , NIL },;
                { "E2_VENCTO"   , cVencimento , NIL },;
                { "E2_VENCREA"  , cVenctoReal , NIL },;
                { "E2_VALOR"    , cVlrTitulo  , NIL } }

    MsExecAuto( { |x,y| FINA050(x,y)} , aArray, 5)  // 5 - Exclusão
    cOk := .T.
Else
    cOk := .F.
Endif

If lMsErroAuto
    MostraErro()
Else
    If cOk
        MsgInfo("Título " + SE2->E2_NUM + " excluido com sucesso!", "Aviso")
    Else
        MsgStop("Título não encontrado!", "Erro")
    Endif
Endif            

Return
