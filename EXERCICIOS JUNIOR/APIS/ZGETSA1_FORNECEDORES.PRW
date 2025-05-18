#include "protheus.ch"
#include "restful.ch"

WSRESTFUL CONSULTA_FORNECEDORES DESCRIPTION "Webservice Consulta Fornecedores" FORMAT APPLICATION_JSON

    WSMETHOD GET V1 DESCRIPTION "Consulta Fornecedores" PATH "/V1/Fornecedores" WSSYNTAX "/V1/Fornecedores" TTALK "V1"

END WSRESTFUL    

WSMETHOD GET V1 WSSERVICE CONSULTA_FORNECEDORES

Local lRet     := .T.
Local oJsonRet := JsonObject():New()
Local oJsonCli := Nil
Local aFornecedor := {}
Local lTudOk   := .F.

cAliasCli := GetNextAlias()
If Select(cAliasCli) > 0
    (cAliasCli)->(DbCloseArea())
Endif

BeginSql Alias cAliasCli
    SELECT 
        SA2.R_E_C_N_O_ AS REC_SA2
    FROM
        %Table:SA2% SA2
    ORDER BY
        A2_FILIAL, A2_COD
EndSql

Begin Sequence
    DbSelectArea(cAliasCli)
    While !(cAliasCli)->(Eof())

        DbSelectArea("SA2")
        SA1->(DbGoto( (cAliasCli)->REC_SA2 ))

        lTudOk := .T.
        oJsonCli := JsonObject():New()
        oJsonCli["empresa"] := cEmpAnt
        oJsonCli["xfilial"] := cFilAnt
        oJsonCli["codfornecedor"] := AllTrim(SA2->A2_COD)
        oJsonCli["nome fornecedor"] := AllTrim(SA2->A2_NOME)
        oJsonCli["estado do fornecedor"] := Alltrim(SA2->A2_END)

        AAdd(aFornecedor, oJsonCli)
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
    oJsonRet["Fornecedores"] := aFornecedor
    lRet := .T.
    self:SetResponse(oJsonRet:toJson())
Endif

Return(lRet)
