#include "protheus.ch"
#include "tbiconn.ch"

User function IncProd()
	Local cDesc 	:= "TESTE EXECAUTO1"
	Local cTipo 	:= "GN"
	Local cUm   	:= "UN"
	Local cArmazem 	:= "01"
	Local nPrv1		:= 50

	XEXEC(cDesc,cTipo,cUm,cArmazem,nPrv1)
Return

Static Function XEXEC(_cDesc,_cTipo,_cUm,_cArmazem,_nPrv1)
	Local aRotAuto := {}
	Local nOpc := 3 // inclusao
	Local lOk := .T.

	Private lMsErroAuto := .f. //necessario a criacao, pois sera atualizado quando houver

	PREPARE ENVIRONMENT EMPRESA '99' FILIAL '01' MODULO 'FAT'

    DbSelectArea("NNR")
	NNR->(DbSetOrder(1))
	NNR->(DbGotop())
	If !NNR->(DbSeek(xFilial("NNR") + _cArmazem))
		lOk := .F.
		MsgAlert("Armazem informado nao existe!")
	Endif

	If lOK
		aRotAuto:= {{'B1_COD' ,GETSXENUM('SB1', 'B1_COD') ,Nil},;
			{'B1_DESC' 	,_cDesc		,Nil},;
			{'B1_TIPO' 	,_cTipo 	,Nil},;
			{'B1_UM' 	,_cUm 		,Nil},;
			{'B1_LOCPAD',_cArmazem	,Nil},;
			{'B1_PRV1' 	,_nPrv1 	,Nil}}

		MSExecAuto({|x,y| mata010(x,y)},aRotAuto,nOpc)

		If lMsErroAuto
			//mostrar na tela o log informando qual a inconsistência ocorreu durante a rotina
			Mostraerro()
			RollBackSX8()
		Else
			ConfirmSX8()
		EndIf
	Endif

    NNR->(DbCloseArea()) 
	RESET ENVIRONMENT
Return
