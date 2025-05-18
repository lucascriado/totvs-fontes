#include "protheus.ch"
#include "restful.ch"

WSRESTFUL FORNECEDOR_TODOS DESCRIPTION "Webservice Fornecedor JSON" FORMAT APPLICATION_JSON

    WSMETHOD POST V1 DESCRIPTION "Operações de Fornecedor" PATH "/V1/fornecedortodos" WSSYNTAX "/V1/fornecedortodos" TTALK "V1"

END WSRESTFUL

WSMETHOD POST V1 WSSERVICE FORNECEDOR_TODOS

Local lTudoOk := .T.
Local cJson    := Self:GetContent()
Local oJson    := JsonObject():New()
Local oJsonRet := JsonObject():New()
Local lRet     := .T.
Local lErrJson := .F.
Local log

self:SetContentType("application/json")
oJson:FromJson(cJson)

cCodigo := ''
cLoja := oJson["loja"]
cNome := oJson["nome"]
cEndereco := oJson["endereco"]
cNomeFantasia := oJson["nome_fantasia"]
cTipo := oJson["tipo"]
cEstado := oJson["estado"]
cMunicipio := oJson["municipio"]
cCgC := oJson["cgc"]
lDeletar := oJson["deletar"]
nOpcAuto := IIf(lDeletar, 5, 3)
AcharDb := ""
lMsErroAuto := .T.

aArray := { { "A2_COD"      , cCodigo           , NIL },;
            { "A2_LOJA"     , cLoja             , NIL },;
            { "A2_NOME"     , cNome             , NIL },;
            { "A2_END"      , cEndereco         , NIL },;
            { "A2_NREDUZ"   , cNomeFantasia     , NIL },;
            { "A2_TIPO"     , cTipo             , NIL },;
            { "A2_EST"      , cEstado           , NIL },;
            { "A2_MUN"      , cMunicipio        , NIL },;
            { "A2_CGC"      , cCgC              , NIL } }

If Empty(cCgC)
    lTudoOk := .F.
    oJsonRet:Add("Erro", "Json não informado")
    lErrJson := .T.
Else
    DbSelectArea("SA2")
    DbSetOrder(3)
    AcharDb := xFilial("SA2") + PadR(cCgC, TamSx3("A2_CGC")[1])

    If DbSeek(AcharDb)
        cCodigo := SA2->A2_COD
        aArray[1][2] := cCodigo
        If nOpcAuto <> 5
            nOpcAuto := 4
        EndIf
    Else
        If lDeletar
            lTudoOk := .F.
            oJsonRet["decisao"] := "Erro"
            oJsonRet["mensagem"] := "Fornecedor não encontrado para exclusão!"
            self:SetResponse(oJsonRet:ToJson())
            lErrJson := .T.

            Return(lRet)
        Else
            DbSelectArea("SA2")
            DbSetOrder(1)

            cCodigo := GetSxeNum("SA2", "A2_COD")

            While .T.
                If DbSeek(xFilial("SA2") + cCodigo)
                    cCodigo := GetSxeNum("SA2", "A2_COD")
                    ConfirmSx8()
                Else
                    Exit
                Endif
            Enddo

            aArray[1][2] := cCodigo
        EndIf
    EndIf

    If lTudoOk
        lMsErroAuto := .F.
        MsExecAuto({ |x,y,z| MATA020(x,y,z)}, aArray, nOpcAuto)  // 3 - Inclusão | 4 - Alteração | 5 - Exclusão
    EndIf

    If lMsErroAuto
        aLog := GetAutoGrLog()
        bMsg := "Falha na execução do ExecAuto."
        For log := 1 to Len(aLog)
            If AT("Erro -->",aLog[log])
                bMsg := AllTrim(Substr(aLog[log],9))
            Endif
        Next log
    Else
        If nOpcAuto == 5
            oJsonRet["decisao"] := "Sucesso"
            oJsonRet["mensagem"] := "Fornecedor excluído com sucesso"
            self:SetResponse(oJsonRet:ToJson())
        ElseIf nOpcAuto == 4
            oJsonRet["decisao"] := "Sucesso"
            oJsonRet["mensagem"] := "Fornecedor alterado com sucesso"
            self:SetResponse(oJsonRet:ToJson())
        Else
            oJsonRet["decisao"] := "Sucesso"
            oJsonRet["mensagem"] := "Fornecedor incluído com sucesso"
            self:SetResponse(oJsonRet:ToJson())
        EndIf
    EndIf
    
    Return(lRet)
EndIf
