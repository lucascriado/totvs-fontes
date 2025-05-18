#include "protheus.ch"
#include "restful.ch"

WSRESTFUL CONSULTA_PEDIDO DESCRIPTION "Webservice Pedido de Compra" FORMAT APPLICATION_JSON
 
	WSMETHOD GET V2 DESCRIPTION "Consulta Pedido de Compra" PATH "/V2/{Filial}/{NumPed}" WSSYNTAX "/V2/{Filial}/{NumPed}" TTALK "V2"

END WSRESTFUL

WSMETHOD GET V2 WSSERVICE CONSULTA_PEDIDO

Local lRet     := .T.
Local uFilial  := self:aUrlParms[2]
Local uPedido  := self:aUrlParms[3]
Local oJsonRet := JsonObject():New()
Local oJsonIte := Nil
Local oJsonRat := Nil
Local aItens   := {}
Local aItRat   := {}

DbSelectArea("SC7")
DbSetOrder(1)
If DbSeek( uFilial + uPedido )

	lCabec := .F.
	While !Eof() .And. SC7->(C7_FILIAL+C7_NUM) == uFilial + uPedido

		If !lCabec

			lCabec := .T.

			DbSelectArea("SA2")
			DbSetOrder(1)
			DbSeek( xFilial("SA2") + SC7->(C7_FORNECE + C7_LOJA) )

			oJsonRet["empres"] := cEmpAnt
			oJsonRet["filial"] := SC7->C7_FILIAL
			oJsonRet["pedido"] := AllTrim(SC7->C7_NUM)
			oJsonRet["cgcfor"] := AllTrim(SA2->A2_CGC)
			oJsonRet["codfor"] := AllTrim(SC7->C7_FORNECE)
			oJsonRet["nomfor"] := AllTrim(SA2->A2_NOME)
			oJsonRet["emissa"] := DtoS(SC7->C7_EMISSAO)
			oJsonRet["condPg"] := AllTrim(SC7->C7_COND)
			oJsonRet["adiant"] := IIf(SC7->C7_XPADTO > 0, .T., .F.)
			oJsonRet["percad"] := SC7->C7_XPADTO
			oJsonRet["linkbl"] := AllTrim(SC7->C7_XLINKBL)
			oJsonRet["blueEz"] := AllTrim(SC7->C7_XNRBLEZ)

		Endif

		oJsonIte := JsonObject():New()
		oJsonIte["Item"]    := AllTrim(SC7->C7_ITEM)
		oJsonIte["produto"] := AllTrim(SC7->C7_PRODUTO)
		oJsonIte["descri"]  := AllTrim(SC7->C7_DESCRI)
		oJsonIte["quant"]   := SC7->C7_QUANT
		oJsonIte["prcUnit"] := SC7->C7_PRECO
		oJsonIte["vTotal"]  := SC7->C7_TOTAL
		oJsonIte["valipi"]  := SC7->C7_VALIPI
		oJsonIte["armazem"] := AllTrim(SC7->C7_LOCAL)
		oJsonIte["observ"]  := AllTrim(SC7->C7_OBS)
		oJsonIte["entrega"] := DtoS(SC7->C7_DATPRF)
		oJsonIte["pdescon"] := SC7->C7_DESC1
		oJsonIte["vdescon"] := SC7->C7_VLDESC
		oJsonIte["seguro"]  := SC7->C7_SEGURO
		oJsonIte["despesa"] := SC7->C7_DESPESA
		oJsonIte["frete"]   := SC7->C7_VALFRE
		oJsonIte["tpfrete"] := SC7->C7_TPFRETE
		oJsonIte["ccitem"]  := SC7->C7_CC
		// ************ //
		// ** Rateio ** //
		// ************ //
		aItRat   := {}
		oJsonRat := JsonObject():New()
		DbSelectArea("SCH")
		DbSetOrder(2)
		If DbSeek( SC7->(C7_FILIAL+C7_NUM+C7_ITEM) )
			While !Eof() .And. SCH->(CH_FILIAL+CH_PEDIDO+CH_ITEMPD) == SC7->(C7_FILIAL+C7_NUM+C7_ITEM)
				oJsonRat := JsonObject():New()
				oJsonRat["itemrt"] := SCH->CH_ITEM
				oJsonRat["percen"] := SCH->CH_PERC
				oJsonRat["ccusto"] := AllTrim(SCH->CH_CC)
				AAdd(aItRat,oJsonRat)
				FreeObj(oJsonRat)
				DbSelectArea("SCH")
				SCH->(DbSkip())
			Enddo
		Else
			AAdd(aItRat,oJsonRat)
			FreeObj(oJsonRat)
		Endif
		// ************ //
		// ** Rateio ** //
		// ************ //
		oJsonIte["rateio"] := aItRat
		AAdd(aItens,oJsonIte)
		FreeObj(oJsonIte)

		DbSelectArea("SC7")
		SC7->(DbSkip())
	Enddo
	oJsonRet["itens"] := aItens

	lRet := .T.
	self:SetResponse( oJsonRet:toJson() )

Else

	lRet := .F.
	SetRestFault(1,;
				 "Pedido nao encontrado.",;
				 .T.,;
				 400,;
				 "Falha na busca do Pedido.")

Endif

Return(lRet)

// https://www.youtube.com/watch?v=V3Cii74aqJY - GET
// https://www.youtube.com/watch?v=fqXEVpG9vB8 - POST
