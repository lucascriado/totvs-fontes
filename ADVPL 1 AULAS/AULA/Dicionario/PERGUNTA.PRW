#Include "Protheus.ch"

User Function XPERGUN()

	If PERGUNTE("ADVPLI",.T.)
		MsgInfo("CONFIRMOU")
	Else
		MsgInfo("CANCELOU")
	Endif

Return

User Function xCLIVAL(nPar)
	Local lRet      := .T.
    Local cCodCli   := ""

    If nPar == 1
        cCodCli := MV_PAR01
    Else
        cCodCli := MV_PAR02
    Endif

	If !Empty(cCodCli)
		DbSelectArea("SA1")
		SA1->(DbSetOrder(1))
		SA1->(DbGoTop())

		If !SA1->(DbSeek(xFilial("SA1") + cCodCli))
			lRet := .F.
			Alert("Cliente nao encontrado")
		Endif
	ENdif

Return lRet
