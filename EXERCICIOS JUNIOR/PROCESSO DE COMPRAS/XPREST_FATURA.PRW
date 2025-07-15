// Local cJson := ::GetContent()
// ::SetContentType("application/json")
// ::SetResponse(cJson)

#include "protheus.ch"
#include "topconn.ch"
#include "restful.ch"
#include "totvs.ch"
#include "tbiconn.ch"

WSRESTFUL PVM410REST DESCRIPTION "Webservice para inclusão de pedidos de venda MATA410" FORMAT APPLICATION_JSON

    WSMETHOD POST V1 DESCRIPTION "Webservice para inclusão de pedidos de venda MATA410" PATH "/V1/PVREST" WSSYNTAX "/V1/PVREST" TTALK "V1"

END WSRESTFUL

WSMETHOD POST V1 WSSERVICE PVM410REST

// variaveis de controle
Local nOpcX      := 3            //(3-Inclusao / 4-Alteracao / 5-Exclusao)
Local nX         := 0
Local aCabec     := {}
Local aItens     := {}
Local aLinha     := {}
Local lOk        := .T.
Local lRet     := .T.

// variaveis de controle json
Local cJson    := Self:GetContent()
Local oJson    := JsonObject():New()
Local oJsonRet := JsonObject():New()
Local aProdutos := {}
Local oProduto   := JsonObject():New()
Local log

// pega o conteudo do json
self:SetContentType("application/json")
oJson:FromJson(cJson)

// variaveis json
Local cTipo, cA1Cod, cA1Loja, cClient, cLojaEnt, cTipoCli, cPagamento
aProdutos := oJson["produtos"]

// lugar das variaveis que vamos pegar no json
cTipo := oJson["tipo"]
cA1Cod := oJson["codigo_do_cliente"]
cA1Loja := oJson["loja_do_cliente"]
cClient := oJson["cliente"]
cLojaEnt := oJson["loja_entrega"]
cTipoCli := oJson["tipo_cliente"]
cPagamento := oJson["condicao_pagamento"]

	Local lMsErroAuto := .F.

		DbSelectArea("SA1")
		DbSetOrder(1)
		If SA1->(! MsSeek(xFilial("SA1") + cA1Cod + cA1Loja))
			lOk     := .F.
			MsgInfo("Cadastrar Cliente: " + cA1Cod + " - " + cA1Loja)
		EndIf

		DbSelectArea("SE4")
		DbSetOrder(1)
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
				aadd(aCabec, {"C5_CLIENT", cClient  	, Nil})
				aadd(aCabec, {"C5_LOJAENT", cLojaEnt 	, Nil})
				aadd(aCabec, {"C5_TIPOCLI", cTipoCli  	, Nil})
				aadd(aCabec, {"C5_CONDPAG", cPagamento	, Nil})

			For nX := 1 To Len(aProdutos)
					aLinha := {}
					oProduto := aProdutos[nX]

					DbSelectArea("SB1")
					DbSetOrder(1)
					If SB1->(! MsSeek(xFilial("SB1")+ oProduto["codigo_produto"]))
						lOk     := .F.
						MsgInfo("Cadastrar Produto: " + oProduto["codigo_produto"])
						EXIT
					EndIf

					DbSelectArea("SF4")
					DbSetOrder(1)
					If SF4->(! MsSeek(xFilial("SF4") + oProduto["tes"]))
						lOk     := .F.
						MsgInfo("Cadastrar TES: " + oProduto["tes"])
						EXIT
					EndIf

					aadd(aLinha,{"C6_ITEM"   , StrZero(nX,2)	, Nil})
					aadd(aLinha,{"C6_PRODUTO", oProduto["codigo_produto"]    , Nil})
					aadd(aLinha,{"C6_QTDVEN" , oProduto["quantidade"]    , Nil})
					aadd(aLinha,{"C6_PRCVEN" , oProduto["preco"]    , Nil})
					aadd(aLinha,{"C6_TES"    , oProduto["tes"]    , Nil})
					aadd(aItens, aLinha)
				Next nX

			If lOk
                MSExecAuto({|a, b, c, d| MATA410(a, b, c, d)}, aCabec, aItens, nOpcX, .F.)

                If lMsErroAuto
                    aLog := GetAutoGrLog()
                    bMsg := "Falha na execucao do ExecAuto."
                    For log := 1 to Len(aLog)
                        If AT("Erro -->",aLog[log]) > 0
                            bMsg := AllTrim(Substr(aLog[log],9))
                        Endif
                    Next log

                    RollbackSx8()
                    DisarmTransaction()
                    oJsonRet["decisao"] := "Falha"
                    oJsonRet["mensagem"] := "Falha na inclusao do Pedido: " + bMsg
                Else
                    ConfirmSX8()
                    oJsonRet["decisao"] := "Sucesso"
                    oJsonRet["mensagem"] := "Pedido incluido com sucesso"
                EndIf
            Else
                RollbackSx8()
                DisarmTransaction()
                oJsonRet["decisao"] := "Falha"
                oJsonRet["mensagem"] := "Falha na validacao dos dados de entrada."
            Endif
    Endif
	End Transaction
    self:SetResponse(oJsonRet:ToJson())
    Return(lRet)
Return
