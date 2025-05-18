#include "protheus.ch"
#include "restful.ch"

WSRESTFUL TITULO_PAGAR DESCRIPTION "Webservice CTA Pagar" FORMAT APPLICATION_JSON

    WSMETHOD POST V1 DESCRIPTION "Operações de CTA Pagar" PATH "/V1/ctapagar" WSSYNTAX "/V1/ctapagar" TTALK "V1"

END WSRESTFUL

WSMETHOD POST V1 WSSERVICE TITULO_PAGAR

Local lTudoOk := .T.
Local cJson    := Self:GetContent()
Local oJson    := JsonObject():New()
Local oJsonRet := JsonObject():New()
Local lRet     := .T.
Local lErrJson := .F.

self:SetContentType("application/json")
oJson:FromJson(cJson)

cPrefix := oJson["prefixo"]
cTitulo := oJson["titulo"]
cParcel := oJson["parcela"]
cTipoTt := oJson["tipo_titulo"]
cNaturez := oJson["natureza"]
cFornecedor := oJson["fornecedor"]
cLoja := oJson["loja"]
cEmissao := StoD(oJson["emissao"])
cVencimento := StoD(oJson["vencimento"])
cVenctoReal := StoD(oJson["vencimento_real"])
cVlrTitulo := oJson["valor_titulo"]
lDeletar := oJson["deletar"]
nOpcAuto := IIf(lDeletar, 5, 3)
AcharDb = ""
lMsErroAuto := .T.

aArray := { { "E2_PREFIXO"  , cPrefix     , NIL },;
            { "E2_NUM"      , cTitulo     , NIL },;
            { "E2_PARCELA"  , cParcel     , NIL },;
            { "E2_TIPO"     , cTipoTt     , NIL },;
            { "E2_NATUREZ"  , cNaturez    , NIL },;
            { "E2_FORNECE"  , cFornecedor , NIL },;
            { "E2_LOJA"     , cLoja       , NIL },;
            { "E2_EMISSAO"  , cEmissao    , NIL },;
            { "E2_VENCTO"   , cVencimento , NIL },;
            { "E2_VENCREA"  , cVenctoReal , NIL },;
            { "E2_VALOR"    , cVlrTitulo  , NIL } }
            
If Empty(cPrefix)
    lTudoOk := .F.
    oJsonRet:Add("Erro", "Json não informado")
    lErrJson := .T.
Else    
    DbSelectArea("SE2")
    DbSetOrder(1)
    AcharDb := xFilial("SE2") + cPrefix + PadR(cTitulo,TamSx3("E2_NUM")[1]) + cParcel + PadR(cTipoTt,TamSx3("E2_TIPO")[1]) + cFornecedor + cLoja
    
    If DbSeek(AcharDb)
        If nOpcAuto <> 5
            nOpcAuto := 4
        EndIf
    Else
        If lDeletar
            lTudoOk := .F.
            oJsonRet["decisao"] := "Erro"
            oJsonRet["mensagem"] := "Cta pagar encontrado para exclusão!"
            self:SetResponse(oJsonRet:ToJson())
            lErrJson := .T.

            Return(lRet)
        Else
            oJsonRet["decisao"] := "Erro"
            oJsonRet["mensagem"] := "Cta pagar n�o encontrado para alteração, será feita uma inclusão!"
            self:SetResponse(oJsonRet:ToJson())
        EndIf
    EndIf

    If lTudoOk
        lMsErroAuto := .F.
        MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aArray,,nOpcAuto)  // 3 - Inclusão | 4 - Alteração | 5 - Exclusão
    EndIf


    If nOpcAuto == 5
        oJsonRet["decisao"] := "Sucesso"
        oJsonRet["mensagem"] := "Cta pagar excluido com sucesso"
        self:SetResponse(oJsonRet:ToJson())
    ElseIf nOpcAuto == 4
        oJsonRet["decisao"] := "Sucesso"
        oJsonRet["mensagem"] := "Cta pagar alterado com sucesso"
        self:SetResponse(oJsonRet:ToJson())
    Else
        oJsonRet["decisao"] := "Sucesso"
        oJsonRet["mensagem"] := "Cta pagar incluido com sucesso"
        self:SetResponse(oJsonRet:ToJson())
    EndIf
    
    Return(lRet)
EndIf

