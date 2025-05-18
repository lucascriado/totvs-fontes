#include "protheus.ch"
#include "restful.ch"

WSRESTFUL CLIENTE_TODOS DESCRIPTION "Webservice Cliente JSON" FORMAT APPLICATION_JSON

    WSMETHOD POST V1 DESCRIPTION "Operações de Cliente" PATH "/V1/clientetodos" WSSYNTAX "/V1/clientetodos" TTALK "V1"

END WSRESTFUL

WSMETHOD POST V1 WSSERVICE CLIENTE_TODOS

Local lTudoOk := .T.
Local cJson    := Self:GetContent()
Local oJson    := JsonObject():New()
Local oJsonRet := JsonObject():New()
Local lRet     := .T.
Local lErrJson := .F.
Local aAI0Auto := {}
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
lMsHelpAuto    := .T.
lAutoErrNoFile := .T.

aArray := { { "A1_COD"      , cCodigo           , NIL },;
            { "A1_LOJA"     , cLoja             , NIL },;
            { "A1_NOME"     , cNome             , NIL },;
            { "A1_END"      , cEndereco         , NIL },;
            { "A1_NREDUZ"   , cNomeFantasia     , NIL },;
            { "A1_TIPO"     , cTipo             , NIL },;
            { "A1_EST"      , cEstado           , NIL },;
            { "A1_MUN"      , cMunicipio        , NIL },;
            { "A1_CGC"      , cCgC              , NIL } }

If Empty(cCgC)
    lTudoOk := .F.
    oJsonRet:Add("Erro", "Json não informado")
    lErrJson := .T.
Else    
    DbSelectArea("SA1")
    DbSetOrder(3)

    AcharDb := xFilial("SA1") + PadR(cCgC, TamSx3("A1_CGC")[1])
    
    If DbSeek(AcharDb)
        cCodigo := SA1->A1_COD
        aArray[1][2] := cCodigo
        If nOpcAuto <> 5
            nOpcAuto := 4
        EndIf
    Else
        If lDeletar
            lTudoOk := .F.
            oJsonRet["decisao"] := "Erro"
            oJsonRet["mensagem"] := "Cliente não encontrado para exclusão!"
            self:SetResponse(oJsonRet:ToJson())
            lErrJson := .T.

            Return(lRet)
        Else
            DbSelectArea("SA1")
            DbSetOrder(1)

            cCodigo := GetSxeNum("SA1", "A1_COD")

            While .T.
                If DbSeek( xFilial("SA1") + cCodigo )
                    cCodigo := GetSxeNum("SA1", "A1_COD")
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
        MsExecAuto( { |x,y,z| CRMA980(x,y,z)}, aArray, nOpcAuto, aAI0Auto)  // 3 - Inclusão | 4 - Alteração | 5 - Exclusão
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
            oJsonRet["mensagem"] := "Cliente excluido com sucesso"
            self:SetResponse(oJsonRet:ToJson())
        ElseIf nOpcAuto == 4
            oJsonRet["decisao"] := "Sucesso"
            oJsonRet["mensagem"] := "Cliente alterado com sucesso"
            self:SetResponse(oJsonRet:ToJson())
        Else
            oJsonRet["decisao"] := "Sucesso"
            oJsonRet["mensagem"] := "Cliente incluido com sucesso"
            self:SetResponse(oJsonRet:ToJson())
        EndIf
    EndIf
    
    Return(lRet)
EndIf

