#include "protheus.ch"
#include "restful.ch"

WSRESTFUL CONSULTA_PRODUTOS DESCRIPTION "Webservice Consulta Produtos" FORMAT APPLICATION_JSON

    WSMETHOD GET V1 DESCRIPTION "Consulta Produtos" PATH "/V1/Produtos" WSSYNTAX "/V1/Produtos" TTALK "V1"

END WSRESTFUL    

WSMETHOD GET V1 WSSERVICE CONSULTA_PRODUTOS

Local lRet     := .T.
Local oJsonRet := JsonObject():New()
Local oJsonCli := Nil
Local aProduto := {}
Local lTudOk   := .F.

cAliasCli := GetNextAlias()
If Select(cAliasCli) > 0
    (cAliasCli)->(DbCloseArea())
Endif

BeginSql Alias cAliasCli
    SELECT 
        SB1.R_E_C_N_O_ AS REC_SB1
    FROM
        %Table:SB1% SB1
    ORDER BY
        B1_FILIAL, B1_COD
EndSql

Begin Sequence
    DbSelectArea(cAliasCli)
    While !(cAliasCli)->(Eof())

        DbSelectArea("SB1")
        SA1->(DbGoto( (cAliasCli)->REC_SB1 ))

        lTudOk := .T.
        oJsonCli := JsonObject():New()
        oJsonCli["empresa"] := cEmpAnt
        oJsonCli["xfilial"] := cFilAnt
        oJsonCli["codcli"] := AllTrim(SB1->B1_COD)
        oJsonCli["descrição do produto"] := AllTrim(SB1->B1_DESC)
        AAdd(aProduto, oJsonCli)
        FreeObj(oJsonCli)

        DbSelectArea(cAliasCli)
        (cAliasCli)->(DbSkip())
    Enddo
    (cAliasCli)->(DbCloseArea())
End Sequence

If !lTudOk
    lRet := .F.
    SetRestFault(1, ;
                 "Dados não encontrados.", ;
                 .T., ;
                 400, ;
                 "Falha na busca dos Produtos.")
Else
    oJsonRet["Produtos"] := aProduto
    lRet := .T.
    self:SetResponse(oJsonRet:toJson())
Endif

Return(lRet)
