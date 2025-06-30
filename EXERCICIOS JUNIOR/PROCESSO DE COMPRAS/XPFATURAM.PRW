// #include "protheus.ch"
// #include "restful.ch"
// #include "topconn.ch"
// #include "totvs.ch"

// WSRESTFUL PVM410 DESCRIPTION "Webservice para inclusão de pedidos de venda MATA410" FORMAT APPLICATION_JSON

//     WSMETHOD POST V1 DESCRIPTION "Webservice para inclusão de pedidos de venda MATA410" PATH "/V1/PV" WSSYNTAX "/V1/PV" TTALK "V1"

// END WSRESTFUL

// WSMETHOD POST V1 WSSERVICE PVM410
//     Local cJson := ::GetContent()
//     ::SetContentType("application/json")
//     ::SetResponse(cJson)
//     Return .T.

#include "protheus.ch"
#include "tbiconn.ch"

User Function XMATA410()
   Local cTipo 	:= "N"
	Local cA1Cod	:= "000002"     //Codigo do Cliente
	Local cA1Loja   := "01"         //Loja do Cliente
	Local cTipoCli	:= "F"
	Local cPagamento	:= "001"        //Codigo da Condicao de Pagamento
	Local aProd		:= { {'000000000000001',1,10,"501"} }

	Local nOpcX      := 3            //(3-Inclusao / 4-Alteracao / 5-Exclusao)
	Local nX         := 0
	Local aCabec     := {}
	Local aItens     := {}
	Local aLinha     := {}
	Local lOk        := .T.

	Private lMsErroAuto    := .F.

		If SA1->(! MsSeek(xFilial("SA1") + cA1Cod + cA1Loja))
			lOk     := .F.
			MsgInfo("Cadastrar Cliente: " + cA1Cod + " - " + cA1Loja)
		EndIf

		If SE4->(! MsSeek(xFilial("SE4") + cPagamento))
			lOk     := .F.
			MsgInfo("Cadastrar Condicao de Pagamento: " + cPagamento)
		EndIf

	Begin Transaction
		If lOk

			aadd(aCabec, {"C5_NUM"    , GetSxeNum("SC5", "C5_NUM"), Nil})
				aadd(aCabec, {"C5_TIPO"   , cTipo     	, Nil})
				aadd(aCabec, {"C5_CLIENTE", cA1Cod   	, Nil})
				aadd(aCabec, {"C5_LOJACLI", cA1Loja  	, Nil})
				aadd(aCabec, {"C5_CLIENT", "000001"  	, Nil})
				aadd(aCabec, {"C5_LOJAENT", "01"  	, Nil})
				aadd(aCabec, {"C5_TIPOCLI", cTipoCli  	, Nil})
				aadd(aCabec, {"C5_CONDPAG", cPagamento	, Nil})

			For nX := 1 To Len(aProd)
					aLinha := {}

					If SB1->(! MsSeek(xFilial("SB1")+ aProd[nX][1]))
						lOk     := .F.
						MsgInfo("Cadastrar Produto: " + aProd[nX][1])
						EXIT
					EndIf

					If SF4->(! MsSeek(xFilial("SF4") + aProd[nX][4]))
						lOk     := .F.
						MsgInfo("Cadastrar TES: " + aProd[nX][4])
						EXIT
					EndIf

					aadd(aLinha,{"C6_ITEM"   , StrZero(nX,2)	, Nil})
					aadd(aLinha,{"C6_PRODUTO", aProd[nX][1]    , Nil})	
					aadd(aLinha,{"C6_QTDVEN" , aProd[nX][2]    , Nil})
					aadd(aLinha,{"C6_PRCVEN" , aProd[nX][3]    , Nil})
					aadd(aLinha,{"C6_TES"    , aProd[nX][4]    , Nil})
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
Return
