#include "protheus.ch"
#include "restful.ch"

WSRESTFUL CONSULTA_NFENTRADA DESCRIPTION "Webservice Documento de Entrada" FORMAT APPLICATION_JSON
 
	WSMETHOD GET V6 DESCRIPTION "Consulta Documento de Entrada" PATH "/V6/{Filial}/{Documento}/{Serie}/{CgcFor}" WSSYNTAX "/V6/{Filial}/{Documento}/{Serie}/{CgcFor}" TTALK "V6"

END WSRESTFUL

WSMETHOD GET V6 WSSERVICE CONSULTA_NFENTRADA

Local lRet     := .T.
Local uFilial  := self:aUrlParms[2]
Local uNFiscal := self:aUrlParms[3]
Local uSerie   := self:aUrlParms[4]
Local uCgcFor  := self:aUrlParms[5]
Local oJsonRet := JsonObject():New()
Local oJsonIte := Nil
Local oJsonPag := Nil
Local aItens   := {}
Local aItPag   := {}

DbSelectArea("SA2")
DbSetOrder(3)
If !DbSeek( xFilial("SA2") + PadR(uCgcFor,TamSx3("A2_CGC")[1]) )

	lRet := .F.
	SetRestFault(1,;
				 "Fornecedor não encontrado.",;
				 .T.,;
				 400,;
				 "Falha na busca do Titulo.")

Else

	DbSelectArea("SF1")
	DbSetOrder(1)
	If DbSeek( uFilial + PadR(uNFiscal,TamSx3("F1_DOC")[1]) + PadR(uSerie,TamSx3("F1_SERIE")[1]) + SA2->A2_COD + SA2->A2_LOJA )

		oJsonRet["empres"] := cEmpAnt
		oJsonRet["filial"] := SF1->F1_FILIAL
		oJsonRet["cgcfor"] := AllTrim(SA2->A2_CGC)
		oJsonRet["codfor"] := AllTrim(SF1->F1_FORNECE)
		oJsonRet["nomfor"] := AllTrim(SA2->A2_NOME)
		oJsonRet["emissa"] := DtoS(SF1->F1_EMISSAO)
		oJsonRet["numero"] := AllTrim(SF1->F1_DOC)
		oJsonRet["serie"]  := AllTrim(SF1->F1_SERIE)
		oJsonRet["especi"] := AllTrim(SF1->F1_ESPECIE)
		oJsonRet["chvnfe"] := AllTrim(SF1->F1_CHVNFE)
		oJsonRet["condPg"] := AllTrim(SF1->F1_COND)
		oJsonRet["predoc"] := IIf(Empty(SF1->F1_STATUS),.T.,.F.)
		oJsonRet["linkbl"] := AllTrim(SF1->F1_XLINKBL)
		oJsonRet["blueEz"] := AllTrim(SF1->F1_XNRBLEZ)

		DbSelectArea("SD1")
		DbSetOrder(1)
		DbSeek( SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) )
		While !Eof() .And. SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)

			oJsonIte := JsonObject():New()
			oJsonIte["item"]    := AllTrim(SD1->D1_ITEM)
			oJsonIte["produt"]  := AllTrim(SD1->D1_COD)
			oJsonIte["descri"]  := AllTrim(SB1->B1_DESC)
			oJsonIte["quant"]   := SD1->D1_QUANT
			oJsonIte["vunit"]   := SD1->D1_VUNIT
			oJsonIte["vTotal"]  := SD1->D1_TOTAL
			oJsonIte["armazem"] := AllTrim(SD1->D1_LOCAL)
			oJsonIte["numpc"]   := AllTrim(SD1->D1_PEDIDO)
			oJsonIte["itempc"]  := AllTrim(SD1->D1_ITEMPC)
			oJsonIte["codserv"] := AllTrim(SD1->D1_CODISS)
			oJsonIte["ccusto"]  := AllTrim(SD1->D1_CC)
			oJsonIte["tes"]     := AllTrim(SD1->D1_TES)
			oJsonIte["cfop"]    := AllTrim(SD1->D1_CF)
			AAdd(aItens,oJsonIte)
			FreeObj(oJsonIte)

			DbSelectArea("SD1")
			SD1->(DbSkip())
		Enddo
		oJsonRet["itens"] := aItens

		// Contas a Pagar
		DbSelectArea("SE2")
		DbSetOrder(6)
		DbSeek( SF1->(F1_FILIAL+F1_FORNECE+F1_LOJA+F1_PREFIXO+F1_DUPL) )
		While !Eof() .And. SE2->(E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM) == SF1->(F1_FILIAL+F1_FORNECE+F1_LOJA+F1_PREFIXO+F1_DUPL)

			oJsonPag := JsonObject():New()
			oJsonPag["parcela"] := AllTrim(SE2->E2_PARCELA)
			oJsonPag["tipo"]    := AllTrim(SE2->E2_TIPO)
			oJsonPag["emissao"] := DtoS(SE2->E2_EMISSAO)
			oJsonPag["vencto"]  := DtoS(SE2->E2_VENCREA)
			oJsonPag["valor"]   := SE2->E2_VALOR
			oJsonPag["saldo"]   := SE2->E2_SALDO
			oJsonPag["naturez"] := AllTrim(SE2->E2_NATUREZ)
			oJsonPag["histor"]  := AllTrim(SE2->E2_HIST)
			oJsonPag["blueez"]  := AllTrim(SE2->E2_XNRBLEZ)
			AAdd(aItPag,oJsonPag)
			FreeObj(oJsonPag)

			DbSelectArea("SE2")
			SE2->(DbSkip())
		Enddo
		oJsonRet["cpag"] := aItPag

		lRet := .T.
		self:SetResponse( oJsonRet:toJson() )

	Else

		lRet := .F.
		SetRestFault(1,;
					"Documento nao encontrado.",;
					.T.,;
					400,;
					"Falha na busca do Documento.")

	Endif

Endif

Return(lRet)
