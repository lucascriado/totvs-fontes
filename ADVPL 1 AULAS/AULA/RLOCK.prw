#Include "Protheus.Ch"
//inclusao
User Function XILOCK()
	Local lOk   := .F.
    Local cCod  := GetSxeNum("SA1","A1_COD")

    DbSelectArea("SA1")
    SA1->(DbSetOrder(1))
    SA1->(DbGoTop())
    If DbSeek(xFilial("SA1") + cCod)
        ConfirmSX8()
        cCod := GetSxeNum("SA1","A1_COD")
    Endif

	lOk := Reclock("SA1",.T.)
	SA1->A1_COD     := cCod
	SA1->A1_LOJA    := "01"
	SA1->A1_NOME    := "TESTE RECLOCK"
	SA1->A1_END     := "PROTHEUS"
	SA1->A1_NREDUZ  := "RECLOCK"
	SA1->A1_TIPO    := "F"
	SA1->A1_EST     := "SP"
	SA1->A1_MUN     := "Sao paulo"
	SA1->(MsUnlock())

	If lOk
        ConfirmSX8()
	Else
        RollBackSX8()
	Endif
Return
//alteracao ou delecao
User Function XALOCK()

    DbSelectArea("SA1")
    SA1->(DbSetOrder(1))
    SA1->(DbGoTop())
    If DbSeek(xFilial("SA1") + "CLINSU")
        Reclock("SA1",.F.)
        SA1->(DbDelete())
	    //SA1->A1_MUN     := "Rio de janeiro"h
	    SA1->(MsUnlock())
    Endif

Return
