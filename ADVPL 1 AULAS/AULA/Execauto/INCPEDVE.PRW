#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

User Function INCPEDVE()
	Local cTipo 	:= "N"
	Local cA1Cod	:= "000001"     //Codigo do Cliente
	Local cA1Loja   := "01"         //Loja do Cliente
	Local cTipoCli	:= "F"
	Local cE4Codigo	:= "001"        //Codigo da Condicao de Pagamento
	Local aProd		:= {{'000001',1,10,"501"},;
						{'000002',3,50,"501"}}

	XEXEC(cTipo,cA1Cod,cA1Loja,cTipoCli,cE4Codigo, aProd)
Return

Static Function XEXEC(_cTipo,_cA1Cod,_cA1Loja,_cTipoCli,_cE4Codigo,_aProd)
	Local nOpcX      := 3            //Seleciona o tipo da operacao (3-Inclusao / 4-Alteracao / 5-Exclusao)
	Local nX         := 0
	Local aCabec     := {}
	Local aItens     := {}
	Local aLinha     := {}
	Local lOk        := .T.

	Private lMsErroAuto    := .F.

	//VERIFICAR CLIENTE
	If SA1->(! MsSeek(xFilial("SA1") + _cA1Cod + _cA1Loja))
		lOk     := .F.
		MsgInfo("Cadastrar Cliente: " + _cA1Cod + " - " + _cA1Loja)
	EndIf

	//VERIFICAR CONDICAO DE PAGAMENTO
	If SE4->(! MsSeek(xFilial("SE4") + _cE4Codigo))
		lOk     := .F.
		MsgInfo("Cadastrar Condicao de Pagamento: " + _cE4Codigo)
	EndIf

	Begin Transaction

		If lOk

			aadd(aCabec, {"C5_NUM"    , GetSxeNum("SC5", "C5_NUM"), Nil})
			aadd(aCabec, {"C5_TIPO"   , _cTipo     	, Nil})
			aadd(aCabec, {"C5_CLIENTE", _cA1Cod   	, Nil})
			aadd(aCabec, {"C5_LOJACLI", _cA1Loja  	, Nil})
			aadd(aCabec, {"C5_TIPOCLI", _cTipoCli  	, Nil})
			aadd(aCabec, {"C5_CONDPAG", _cE4Codigo	, Nil})

			For nX := 1 To Len(_aProd)  //Quantidade de Itens
				aLinha := {}

				//VERIFICAR PRODUTO
				If SB1->(! MsSeek(xFilial("SB1")+ _aProd[nX][1]))
					lOk     := .F.
					MsgInfo("Cadastrar Produto: " + _aProd[nX][1])
					EXIT
				EndIf

				//VERIFICAR TES
				If SF4->(! MsSeek(xFilial("SF4") + _aProd[nX][4]))
					lOk     := .F.
					MsgInfo("Cadastrar TES: " + _aProd[nX][4])
					EXIT
				EndIf

				aadd(aLinha,{"C6_ITEM"   , StrZero(nX,2)	, Nil})
				aadd(aLinha,{"C6_PRODUTO", _aProd[nX][1]    , Nil})	
				aadd(aLinha,{"C6_QTDVEN" , _aProd[nX][2]    , Nil})
				aadd(aLinha,{"C6_PRCVEN" , _aProd[nX][3]    , Nil})
				aadd(aLinha,{"C6_TES"    , _aProd[nX][4]    , Nil})
				aadd(aItens, aLinha)
			Next nX

			If lOk
				MSExecAuto({|a, b, c, d| MATA410(a, b, c, d)}, aCabec, aItens, nOpcX, .F.)


				If !lMsErroAuto
					MsgInfo("Incluido com sucesso! Pedido")
					ConfirmSX8()
				Else
					MsgInfo("Erro na inclusao!")
					RollBAckSx8()
					MOSTRAERRO()
					DisarmTransaction()
					Break
				EndIf
			Endif
		Endif

	End Transaction

Return
