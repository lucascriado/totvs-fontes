#include "protheus.ch"
#include "topconn.ch"
#include "totvs.ch"

User Function ALLPAGAR()

Private lMsErroAuto := .F.

If !MsgYesNo("Confirma a opera��o no T�tulo a Pagar?", "Aviso")
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
cVlrTitulo := 999
lDeletar := .F.
nOpcAuto := IIf(lDeletar, 5, 3)

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

DbSelectArea("SE2")
DbSetOrder(1)

If DbSeek( xFilial("SE2") + cPrefix + PadR(cTitulo,TamSx3("E2_NUM")[1]) + cParcel + PadR(cTipoTt,TamSx3("E2_TIPO")[1]) + cFornecedor + cLoja )
    If nOpcAuto <> 5
        nOpcAuto := 4
    Endif
Else
    If lDeletar
        MsgAlert("T�tulo de Contas a Pagar n�o encontrado para exclus�o!", "Aviso")
        Return
    Else
        MsgAlert("T�tulo de Contas a Pagar n�o encontrado para altera��o!", "Aviso")
        Return
    Endif
Endif

MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aArray, nOpcAuto)  // 3 - Inclus�o | 4 - Altera��o | 5 - Exclus�o

If lMsErroAuto
    MostraErro()
Else
    If nOpcAuto == 5
        MsgInfo("T�tulo " + SE2->E2_NUM + " exclu�do com sucesso!", "Aviso")
    ElseIf nOpcAuto == 4
        MsgInfo("T�tulo " + SE2->E2_NUM + " alterado com sucesso!", "Aviso")
    Else
        MsgInfo("T�tulo " + SE2->E2_NUM + " inclu�do com sucesso!", "Aviso")
    EndIf
Endif            

Return
