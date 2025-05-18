#include "protheus.ch"
#include "restful.ch"

WSRESTFUL RECEBE_ARQUIVO DESCRIPTION "RECEBE_ARQUIVO" FORMAT APPLICATION_JSON
 
    WSMETHOD POST V1 DESCRIPTION "RECEBE_ARQUIVO" PATH "/V1/Envio" WSSYNTAX "/V1/Envio" TTALK "V1"

END WSRESTFUL

WSMETHOD POST V1 WSSERVICE RECEBE_ARQUIVO

Local lTudoOk := .T.
Local lRet     := .T.
Local cJson    := Self:GetContent()
Local oJson    := JsonObject():New()
Local oJsonRet := JsonObject():New()
Local lErrJson := .F.

self:SetContentType("application/json")
oJson:FromJson(cJson)

cCgc := oJson["cgc"]
cNomeDocumento := oJson["nome_documento"]
cBase64 := oJson["base64"]

If Empty(cBase64)
    lTudoOk := .F.
    oJsonRet:Add("Erro", "Base64 não informado")
    lErrJson := .T.
Else
    DbSelectArea("SA1")
    DbSetOrder(3)
    If !DbSeek( xFilial("SA1") + Padr(cCgc, TamSx3("A1_CGC")[1]))
        lTudoOk := .F.
        oJsonRet:Add("Erro", "Falha ao encontrar CPF/CPNJ")
        lErrJson := .T.
    Else
        DbSelectArea("ACB")
        DbSetOrder(2)
        If !DbSeek( xFilial("ACB") + PadR(cNomeDocumento, TamSx3("ACB_OBJETO")[1]) )
            cArqDir := "dirdoc\co99\shared\" + cNomeDocumento
            nHandle := fcreate(cArqDir)
            If nHandle < 0
                lTudoOk := .F.
                oJsonRet:Add("Erro", "Falha ao criar arquivo")
                lErrJson := .T.
            Else
                FWrite(nHandle, Decode64(cBase64))
                fClose(nHandle)
            EndIf
            
            cNumeroDocumento := GetSxeNum("ACB", "ACB_CODOBJ")
            ConfirmSx8()
            Reclock("ACB", .T.)
            ACB->ACB_FILIAL := xFilial("ACB")
            ACB->ACB_CODOBJ := cNumeroDocumento
            ACB->ACB_OBJETO := cNomeDocumento
            ACB->ACB_DESCRI := cNomeDocumento
            MsUnlock()
        Else
            cNumeroDocumento := ACB->ACB_CODOBJ
        Endif

        DbSelectArea("AC9")
        DbSetOrder(1)
        If !DbSeek( xFilial("AC9") + PadR(cNumeroDocumento, TamSx3("AC9_CODOBJ")[1]) + "SA1")
            Reclock("AC9", .T.)
            AC9->AC9_FILIAL := xFilial("AC9")
            AC9->AC9_ENTIDA := "SA1"
            AC9->AC9_CODENT := SA1->(A1_COD+A1_LOJA)
            AC9->AC9_CODOBJ := cNumeroDocumento
            MsUnlock()
        Endif
    EndIf    
EndIf

If lErrJson
    SetRestFault(2, ;
                 oJsonRet:ToJson(), ;
                 .T., ;
                 400, ;
                 "Erro ao receber arquivo.")
    Return (.F.)
Else
    If lTudoOk
        oJsonRet["upload"] := .T.
        oJsonRet["decisao"] := "Sucesso"
        oJsonRet["mensagem"] := "Arquivo recebido com sucesso"
        self:SetResponse(oJsonRet:ToJson())
    Else
        oJsonRet["upload"] := .F.
        oJsonRet["decisao"] := "Falha"
        oJsonRet["mensagem"] := "Falha ao receber arquivo"
        self:SetResponse(oJsonRet:ToJson())
    Endif
Endif

Return(lRet)
