#Include "Protheus.Ch"

User Function XFOR()
	Local aNotas    := {{"Leandro",6,10,9,10},{"Marcos",6,8,7,6}}
	Local nL, nC
	Local nMedia    := 7
	Local nNota     := 0

	For nL := 1 to Len(aNotas)
        nNota := 0

		For nC := 1 To Len(aNotas[nL])
			If nC <> 1 .And. Valtype(aNotas[nL][nC]) == "N"
				nNota += aNotas[nL][nC]
			Endif
		Next

		nNota := nNota/4

		If nNota >= nMedia
			MSgInfo(aNotas[nL][1] + " passou","Resultado")
		Else
			MSgAlert(aNotas[nL][1] + " reprovou","Resultado")
		Endif
	Next

Return

User Function XWhile()
    Local lLe   := .T.
    Local nCont := 0

	DbSelectArea("SX5")
    SX5->(DbSetOrder(1))
	SX5->(DbGoTop())

    While X5_TABELA=="00"
        aAdd(abloco,{X5_CHAVE,X5_DESCRI})

		SX5->(DbSkip())
    Enddo

Return
