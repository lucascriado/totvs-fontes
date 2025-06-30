#include "protheus.ch"
#include "restful.ch"
#include "topconn.ch"
#include "totvs.ch"

WSRESTFUL WEBEA DESCRIPTION "Webservice para inclusão de cliente" FORMAT APPLICATION_JSON

    WSMETHOD POST V1 DESCRIPTION "Inclusão de cliente JSON" PATH "/V1/EA" WSSYNTAX "/V1/EA" TTALK "V1"

END WSRESTFUL

WSMETHOD POST V1 WSSERVICE WEBEA

Local cJson := Self:GetContent()
Local oJson      := JsonObject():New()
Local oJsonRet   := JsonObject():New()
Local lDeuCerto  := .F.
Local aErro      := {}

Local cCodigo, cLoja, cNome, cEndereco, cNomeFantasia, cTipo, cEstado, cMunicipio, cCgC

Self:SetContentType("application/json")

oJson:FromJson(cJson)

cCodigo        := oJson["codigo"]
cLoja          := oJson["loja"]
cNome          := oJson["nome"]
cEndereco      := oJson["endereco"]
cNomeFantasia  := oJson["nome_fantasia"]
cTipo          := oJson["tipo"]
cEstado        := oJson["estado"]
cMunicipio     := oJson["municipio"]
cCgC           := oJson["cgc"]

DbSelectArea("SA1")
DbSetOrder(3)
If DbSeek(xFilial("SA1") + PadR(cCgC, TamSx3("A1_CGC")[1]))
    oJsonRet["status"] := "erro"
    oJsonRet["mensagem"] := "Cliente já cadastrado."
    Self:SendResponse(oJsonRet:ToJson())
    Return
EndIf

oModel := FWLoadModel("CRMA980")
oModel:SetOperation(3)           // 3 = Inclusão
oModel:Activate()

oSA1 := oModel:getModel("SA1MASTER")
oSA1:setValue("A1_COD",     cCodigo)
oSA1:setValue("A1_LOJA",    cLoja)
oSA1:setValue("A1_NOME",    cNome)
oSA1:setValue("A1_END",     cEndereco)
oSA1:setValue("A1_NREDUZ",  cNomeFantasia)
oSA1:setValue("A1_TIPO",    cTipo)
oSA1:setValue("A1_EST",     cEstado)
oSA1:setValue("A1_MUN",     cMunicipio)

If oModel:VldData()

    If oModel:CommitData()
        lDeuCerto := .T.
    EndIf

EndIf

If lDeuCerto
    oJsonRet["status"] := "sucesso"
    oJsonRet["mensagem"] := "Cliente incluído com sucesso."
    oModel:DeActivate()
Else
    aErro := oModel:GetErrorMessage()
    oJsonRet["status"] := "erro"
    oJsonRet["mensagem"] := aErro[6]
    oJsonRet["solucao"] := aErro[7]
EndIf
Return
