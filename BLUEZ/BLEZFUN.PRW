#include "totvs.ch"
#include "protheus.ch"
#include "tbiconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ BLEZAUT ¦ Autor ¦  Fábrica ERP.BR   ¦  Data  ¦ Jul-2023	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Integração BlueEz - Autenticação p/Token.				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo BLUEEZ 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function BLEZAUT(lJob)

Local cBlezUrl    := AllTrim(GetMv("CO_BLEZURL")) // https://apiqa.blueez.com.br
Local cBlezUsr    := AllTrim(GetMv("CO_BLEZUSR")) // integrador_erp_cobreflex
Local cBlezPws    := AllTrim(GetMv("CO_BLEZPSW")) // 3rp_1nt3gr4d0r_t3st3
Local cGetParms   := ""
Local cPostParms  := ' { "user": "'+cBlezUsr+'", "pass": "'+cBlezPws+'" } '
Local nTimeOut    := 200
Local aHeadStr    := {"Content-Type: application/json"}
Local cHeaderPost := ""
Local cRetorno    := ""
Local cBlezToken  := ""
Local oObjJson    := Nil

cBlezUrl += "/login"
cRetorno := HttpPost(cBlezUrl, cGetParms, cPostParms, nTimeOut, aHeadStr, @cHeaderPost)

If !FWJsonDeserialize(cRetorno, @oObjJson)
	If !lJob
		MsgStop("Erro no retorno HttpPost de autenticação para Token: falha no retorno.")
	Endif	
Else
	If oObjJson:SUCCESS
		cBlezToken := oObjJson:ACCESSTOKEN
		If __cUserId == "000000"
			If !lJob
				MsgInfo("Autenticação Ok !!"+CHR(13)+CHR(10)+"Novo token: "+cBlezToken)
			Endif	
		Endif
	Else
		If !lJob
			MsgStop("Erro no retorno HttpPost de autenticação para Token: não autenticado.")
		Endif	
	Endif
Endif

Return(cBlezToken)
// HttpPost(  < cUrl >, [ cGetParms ] , [ cPostParms ], [ nTimeOut ], [ aHeadStr ], [ @cHeaderGet ] )

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ zLimpaEsp ¦ Autor ¦ Fábrica ERP.BR  ¦ Data  ¦  Out-2023    ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Integração BlueEz - Tratamento caracteres especiais. 	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo BLUEEZ											  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function zLimpaEsp(xConteudo)

Local cConteudo := xConteudo

cConteudo := StrTran(cConteudo, "'", "")
cConteudo := StrTran(cConteudo, "#", "")
cConteudo := StrTran(cConteudo, "%", "")
cConteudo := StrTran(cConteudo, "*", "")
cConteudo := StrTran(cConteudo, "&", "E")
cConteudo := StrTran(cConteudo, ">", "")
cConteudo := StrTran(cConteudo, "<", "")
cConteudo := StrTran(cConteudo, "!", "")
cConteudo := StrTran(cConteudo, "@", "")
cConteudo := StrTran(cConteudo, "$", "")
cConteudo := StrTran(cConteudo, "(", "")
cConteudo := StrTran(cConteudo, ")", "")
cConteudo := StrTran(cConteudo, "_", "")
cConteudo := StrTran(cConteudo, "=", "")
cConteudo := StrTran(cConteudo, "+", "")
cConteudo := StrTran(cConteudo, "{", "")
cConteudo := StrTran(cConteudo, "}", "")
cConteudo := StrTran(cConteudo, "[", "")
cConteudo := StrTran(cConteudo, "]", "")
//cConteudo := StrTran(cConteudo, "/", "")
cConteudo := StrTran(cConteudo, "?", "")
cConteudo := StrTran(cConteudo, ".", "")
cConteudo := StrTran(cConteudo, "\", "")
cConteudo := StrTran(cConteudo, "|", "")
cConteudo := StrTran(cConteudo, ":", "")
cConteudo := StrTran(cConteudo, ";", "")
//cConteudo := StrTran(cConteudo, '"', '')
//cConteudo := StrTran(cConteudo, '°', '')
cConteudo := StrTran(cConteudo, 'ª', '')

Return(cConteudo)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ BLZOPLK  ¦  Autor ¦ Fábrica ERP.BR  ¦ Data  ¦  Out-2023    ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Abertura do Link no navegador com documento público. 	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo BLUEEZ											  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function BLZOPLK(cLinkBl)

If Empty(cLinkBl)
	MsgAlert("Link não associado.")
Else	
	ShellExecute( "open", cLinkBl , "", "", 1 )
Endif	

Return
