#include "protheus.ch"
#include "restful.ch"

WSRESTFUL TITULO_RECEBER_TODOS DESCRIPTION "Webservice CTA Receber" FORMAT APPLICATION_JSON

    WSMETHOD POST V1 DESCRIPTION "Operações de CTA Receber" PATH "/V1/ctareceber" WSSYNTAX "/V1/ctareceber" TTALK "V1"

END WSRESTFUL

WSMETHOD POST V1 WSSERVICE TITULO_RECEBER_TODOS

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
cNatureza := oJson["natureza"]
cCliente := oJson["cliente"]
cLoja := oJson["loja"]
dEmissao := StoD(oJson["emissao"])
dVencto := StoD(oJson["vencimento"])
dVenctoRea := StoD(oJson["vencimento_real"])
nValor := oJson["valor_titulo"]
lDeletar := oJson["deletar"]
nOpcAuto := IIf(lDeletar, 5, 3)
AcharDb = ""
lMsErroAuto := .T.

aArray := { { "E1_PREFIXO"  , cPrefix        , NIL },;
            { "E1_NUM"      , cTitulo        , NIL },;
            { "E1_PARCELA"  , cParcel        , NIL },;
            { "E1_TIPO"     , cTipoTt        , NIL },;
            { "E1_NATUREZ"  , cNatureza      , NIL },;
            { "E1_CLIENTE"  , cCliente       , NIL },;
            { "E1_LOJA"     , cLoja          , NIL },;
            { "E1_EMISSAO"  , dEmissao       , NIL },;
            { "E1_VENCTO"   , dVencto        , NIL },;
            { "E1_VENCREA"  , dVenctoRea     , NIL },;
            { "E1_VALOR"    , nValor         , NIL } }

If Empty(cPrefix)
    lTudoOk := .F.
    oJsonRet:Add("Erro", "Json não informado")
    lErrJson := .T.
Else    
    DbSelectArea("SE1")
    DbSetOrder(1)
    AcharDb := xFilial("SE1") + cPrefix + PadR(cTitulo,TamSx3("E1_NUM")[1]) + cParcel + PadR(cTipoTt,TamSx3("E1_TIPO")[1])
    
    If DbSeek(AcharDb)
        If nOpcAuto <> 5
            nOpcAuto := 4
        EndIf
    Else
        If lDeletar
            lTudoOk := .F.
            oJsonRet["decisao"] := "Erro"
            oJsonRet["mensagem"] := "Cta receber encontrado para exclusão!"
            self:SetResponse(oJsonRet:ToJson())
            lErrJson := .T.

            Return(lRet)
        Else
            oJsonRet["decisao"] := "Erro"
            oJsonRet["mensagem"] := "Cta receber não encontrado para alteração, será feita uma inclusão!"
            self:SetResponse(oJsonRet:ToJson())
        EndIf
    EndIf

    If lTudoOk
        lMsErroAuto := .F.
        MsExecAuto({|x,y| FINA040(x,y)},aArray,nOpcAuto)  // 3 - Inclusão | 4 - Alteração | 5 - Exclusão
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
