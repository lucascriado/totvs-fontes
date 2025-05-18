#include "protheus.ch"
#include "restful.ch"

WSRESTFUL CONSULTA_CLI DESCRIPTION "Webservice Consulta Clientes" FORMAT APPLICATION_JSON
 
	WSMETHOD GET V1 DESCRIPTION "Consulta Clientes" PATH "/V1/{Loja}" WSSYNTAX "/V1/{Loja}" TTALK "V1"

END WSRESTFUL	

WSMETHOD GET V1 WSSERVICE CONSULTA_CLI

Local lRet     := .T.
Local uLojaCli := self:aUrlParms[2]
Local oJsonRet := JsonObject():New()
Local oJsonCli := Nil
Local aCliente := {}
Local lTudOk   := .F.

cLojaClie := uLojaCli
cAliasCli := GetNextAlias()
If Select(cAliasCli) > 0; (cAliasCli)->(DbCloseArea()); Endif

BeginSql Alias cAliasCli
	SELECT 
		SA1.R_E_C_N_O_ AS REC_SA1
	FROM
		%Table:SA1% SA1
	WHERE
		SA1.%NotDel%
		AND A1_LOJA = %Exp:cLojaClie%
	ORDER BY
		A1_FILIAL, A1_COD
EndSql

Begin Sequence
	DbSelectArea(cAliasCli)
	While !(cAliasCli)->(Eof())

		DbSelectArea("SA1")
		SA1->(DbGoto( (cAliasCli)->REC_SA1 ))

		lTudOk := .T.
		oJsonCli := JsonObject():New()
		oJsonCli["empresa"] := cEmpAnt
		oJsonCli["xfilial"] := cFilAnt
		oJsonCli["codcli"] := AllTrim(SA1->A1_COD)
		oJsonCli["lojcli"] := AllTrim(SA1->A1_LOJA)
		oJsonCli["nomcli"] := AllTrim(SA1->A1_NOME)
		oJsonCli["cgccli"] := AllTrim(SA1->A1_CGC)
		AAdd(aCliente,oJsonCli)
		FreeObj(oJsonCli)

		DbSelectArea(cAliasCli)
		(cAliasCli)->(DbSkip())
	Enddo
	(cAliasCli)->(DbCloseArea())
End Sequence

If !lTudOk
	lRet := .F.
	SetRestFault(1,;
				 "Dados não encontrados.",;
				 .T.,;
				 400,;
				 "Falha na busca dos Clientes.")
Else
	oJsonRet["clientes"] := aCliente
	lRet := .T.
	self:SetResponse( oJsonRet:toJson() )
Endif

Return(lRet)


