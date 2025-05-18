#include "Protheus.ch"

User Function A010TOK()
	Local lRet := .T.

	If !IsBlind()
		If INCLUI
			If !MsgYesNo("Confirma a inclusao do produto " + AllTrim(M->B1_DESC) + "?")
				lRet := .F.
			Endif
		Endif
	Endif

Return lRet
