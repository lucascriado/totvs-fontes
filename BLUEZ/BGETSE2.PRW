#include "protheus.ch"
#include "restful.ch"

WSRESTFUL CONSULTA_CPAGAR DESCRIPTION "Webservice Titulo a Pagar" FORMAT APPLICATION_JSON
 
	WSMETHOD GET V5 DESCRIPTION "Consulta Titulo a Pagar" PATH "/V5/{Filial}/{Prefixo}/{Numero}/{Parcela}/{Tipo}/{CgcFor}" WSSYNTAX "/V5/{Filial}/{Prefixo}/{Numero}/{Parcela}/{Tipo}/{CgcFor}" TTALK "V5"

END WSRESTFUL

WSMETHOD GET V5 WSSERVICE CONSULTA_CPAGAR

Local lRet     := .T.
Local uFilial  := self:aUrlParms[2]
Local uPrefixo := self:aUrlParms[3]
Local uNumero  := self:aUrlParms[4]
Local uParcela := self:aUrlParms[5]
Local uTipo    := self:aUrlParms[6]
Local uCgcFor  := self:aUrlParms[7]
Local oJsonRet := JsonObject():New()

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

	DbSelectArea("SE2")
	DbSetOrder(1)
	If DbSeek( uFilial + PadR(uPrefixo,TamSx3("E2_PREFIXO")[1]) + PadR(uNumero,TamSx3("E2_NUM")[1]) +;
						PadR(uParcela,TamSx3("E2_PARCELA")[1]) + PadR(uTipo,TamSx3("E2_TIPO")[1]) +; 
						SA2->A2_COD + SA2->A2_LOJA )

		e5Banco := ""
		e5Agenc := ""
		e5Conta := ""
		If AllTrim(SE2->E2_TIPO) == "PA"
			DbSelectArea("SE5")
			DbSetOrder(7)
			If DbSeek( SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA) )
				While !Eof() .And. SE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA) == SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)
					If SE5->E5_TIPODOC == "PA"
						e5Banco := SE5->E5_BANCO
						e5Agenc := SE5->E5_AGENCIA
						e5Conta := SE5->E5_CONTA
						Exit
					Endif
					SE5->(DbSkip())
				Enddo
			Endif
		Endif

		oJsonRet["empresa"] := cEmpAnt
		oJsonRet["filial"]  := SE2->E2_FILIAL
		oJsonRet["cgcfor"]  := AllTrim(SA2->A2_CGC)
		oJsonRet["nomfor"]  := AllTrim(SA2->A2_NOME)
		oJsonRet["codfor"]  := AllTrim(SE2->E2_FORNECE)
		oJsonRet["prefixo"] := AllTrim(SE2->E2_PREFIXO)
		oJsonRet["numero"]  := AllTrim(SE2->E2_NUM)
		oJsonRet["parcela"] := AllTrim(SE2->E2_PARCELA)
		oJsonRet["tipo"]    := AllTrim(SE2->E2_TIPO)
		oJsonRet["emissao"] := DtoS(SE2->E2_EMISSAO)
		oJsonRet["vencto"]  := DtoS(SE2->E2_VENCREA)
		oJsonRet["valor"]   := SE2->E2_VALOR
		oJsonRet["naturez"] := AllTrim(SE2->E2_NATUREZ)
		oJsonRet["ccusto"]  := AllTrim(SE2->E2_CCUSTO)
		oJsonRet["bancor"]  := e5Banco
		oJsonRet["agencia"] := e5Agenc
		oJsonRet["conta"]   := e5Conta
		oJsonRet["histor"]  := AllTrim(SE2->E2_HIST)
		oJsonRet["blueEz"]  := AllTrim(SE2->E2_XNRBLEZ)
		oJsonRet["saldo"]   := SE2->E2_SALDO

		// ************ //
		// ** Rateio ** //
		// ************ //
		aRateio  := {}
		oJsonRat := JsonObject():New()
		If SE2->E2_RATEIO == "S"
			cArqRat := AllTrim(SE2->E2_ARQRAT)
			DbSelectArea("CV4")
			DbSetOrder(1)
			If DbSeek( cArqRat )
				While !Eof() .And. CV4->(CV4_FILIAL+DtoS(CV4_DTSEQ)+CV4_SEQUEN) == cArqRat
					oJsonRat := JsonObject():New()
					oJsonRat["ccusto"] := AllTrim(CV4->CV4_CCD)
					oJsonRat["percen"] := CV4->CV4_PERCEN
					AAdd(aRateio,oJsonRat)
					FreeObj(oJsonRat)
					DbSelectArea("CV4")
					CV4->(DbSkip())
				Enddo
			Else
				AAdd(aRateio,oJsonRat)
				FreeObj(oJsonRat)
			Endif
		Else
			AAdd(aRateio,oJsonRat)
			FreeObj(oJsonRat)
		Endif	
		// ************ //
		// ** Rateio ** //
		// ************ //
		oJsonRet["rateio"] := aRateio

		lRet := .T.
		self:SetResponse( oJsonRet:toJson() )

	Else

		lRet := .F.
		SetRestFault(1,;
					"Titulo nao encontrado.",;
					.T.,;
					400,;
					"Falha na busca do Titulo.")

	Endif

Endif

Return(lRet)
