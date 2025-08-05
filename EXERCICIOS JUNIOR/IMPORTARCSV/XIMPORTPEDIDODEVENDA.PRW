#include "protheus.ch"
#include "tbiconn.ch"

User Function XIMPORTPEDIDODEVENDA()
    Local cArquivo := "C:\report\import_pedidosdevenda.csv"
    Local oArquivo
	oArquivo := FWFileReader():New(cArquivo)
    Local aLinha, cLinha, nLinha := 0
    Local aCabec := {}, aItens := {}, aProd := {}
    Local cTipo, cA1Cod, cA1Loja, cClient, cLoja, cTipoCli, cPagamento
    Local lOk := .T., nOpcX := 3, nX
    Private lMsErroAuto := .F.

	If oArquivo:Open()
		While oArquivo:HasLine()
			nLinha++
			cLinha := oArquivo:GetLine()
			aLinha := StrTokArr(cLinha, ";")

			If nLinha == 1
				Loop // skip cabeçalho do (SC5)
			ElseIf nLinha == 2
				// itens do SC5
				cTipo      := aLinha[1]
				cA1Cod     := aLinha[2]
				cA1Loja    := aLinha[3]
				cClient    := aLinha[4]
				cLoja      := aLinha[5]
				cTipoCli   := aLinha[6]
				cPagamento := aLinha[7]
			ElseIf nLinha == 3
				Loop // skip cabeçalho do (SC6)
			Else
				// itens do SC6
				AAdd(aProd, { aLinha[1], Val(aLinha[2]), Val(aLinha[3]), aLinha[4] })
			EndIf
		EndDo
		oArquivo:Close()
	Else
		MsgInfo("Erro ao abrir o arquivo: " + cArquivo)
		Return
	EndIf

    Begin Transaction
        If lOk
            AAdd(aCabec, {"C5_NUM"    , GetSxeNum("SC5", "C5_NUM"), Nil})
            AAdd(aCabec, {"C5_TIPO"   , cTipo      , Nil})
            AAdd(aCabec, {"C5_CLIENTE", cA1Cod     , Nil})
            AAdd(aCabec, {"C5_LOJACLI", cA1Loja    , Nil})
            AAdd(aCabec, {"C5_CLIENT" , cClient    , Nil})
            AAdd(aCabec, {"C5_LOJAENT", cLoja      , Nil})
            AAdd(aCabec, {"C5_TIPOCLI", cTipoCli   , Nil})
            AAdd(aCabec, {"C5_CONDPAG", cPagamento , Nil})

            For nX := 1 To Len(aProd)
                aLinha := {}

                AAdd(aLinha, {"C6_ITEM"   , StrZero(nX, 2), Nil})
                AAdd(aLinha, {"C6_PRODUTO", aProd[nX][1] , Nil})
                AAdd(aLinha, {"C6_QTDVEN" , aProd[nX][2] , Nil})
                AAdd(aLinha, {"C6_PRCVEN" , aProd[nX][3] , Nil})
                AAdd(aLinha, {"C6_TES"    , aProd[nX][4] , Nil})
                AAdd(aItens, aLinha)
            Next

            If lOk
                MSExecAuto({|a, b, c, d| MATA410(a, b, c, d)}, aCabec, aItens, nOpcX, .F.)

                If !lMsErroAuto
                    MsgInfo("Incluído com sucesso!")
                    ConfirmSX8()
                Else
                    MsgInfo("Erro na inclusão!")
                    RollBackSX8()
                    MOSTRAERRO()
                    DisarmTransaction()
                EndIf
            EndIf
        EndIf
    End Transaction

Return
