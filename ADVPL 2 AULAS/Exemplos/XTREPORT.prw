#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

User Function XTEREPORT()
	Local cPerg := "XSE5"
	Local oReport

	Pergunte(cPerg, .F.)

	oReport := ReportDef(cPerg)
	oReport:PrintDialog()

Return

Static Function ReportDef(cPerg)
	Local oReport
	Local oSectionA
	Local oSectionB    
	Local oBreak

	oReport := TReport():New("XTEREPORT","Pedidos de venda treinamento",cPerg,{|oReport| ReportPrint(oReport)})
	oReport:OnPageBreak(,.F.)
	oReport:lParamPage := .F.
	oReport:SetCustomText({|| CRIACAB(oReport:cTitle)})

	oSectionA := TRSection():New(oReport,"Pedidos","REP")

	TRCell():New(oSectionA,"C5_NUM"     ,"REP","Pedido" ,/*Picture*/,TamSx3("C5_NUM")[1]    ,,,"LEFT",,,,05,,,,.T.)
	TRCell():New(oSectionA,"C5_CLIENTE" ,"REP","Cod Cli",/*Picture*/,TamSx3("C5_CLIENTE")[1],,,"LEFT",,,,05,,,,.T.)
	TRCell():New(oSectionA,"DESCCLI"    ,""   ,"Nome"   ,/*Picture*/,TamSx3("A1_NOME")[1]   ,,,"LEFT",,,,05,,,,.T.)
	TRCell():New(oSectionA,"C5_LOJACLI" ,"REP","Loja"   ,/*Picture*/,TamSx3("C5_LOJACLI")[1],,,"LEFT",,,,05,,,,.T.)
	TRCell():New(oSectionA,"C5_EMISSAO" ,"REP","Emissao",/*Picture*/,TamSx3("C5_EMISSAO")[1],,,"LEFT",,,,05,,,,.T.)

	oSectionB := TRSection():New(oReport,"Itens","ITR")
    oSectionB:SetLeftMargin(6)

	TRCell():New(oSectionB,"C6_ITEM"    ,"ITR","Item"       ,/*Picture*/         ,TamSx3("C6_ITEM")[1]    ,,,"LEFT",,,,05,,,,.T.)
	TRCell():New(oSectionB,"C6_PRODUTO" ,"ITR","Cod Pro"    ,/*Picture*/         ,TamSx3("C6_PRODUTO")[1] ,,,"LEFT",,,,05,,,,.T.)
	TRCell():New(oSectionB,"DESCPRO"    ,""   ,"Desc"       ,/*Picture*/         ,TamSx3("B1_DESC")[1]    ,,,"LEFT",,,,05,,,,.T.)
	TRCell():New(oSectionB,"C6_UM"      ,"ITR","Unidade"    ,/*Picture*/         ,TamSx3("C6_UM")[1]      ,,,"LEFT",,,,05,,,,.T.)
	TRCell():New(oSectionB,"C6_QTDVEN"  ,"ITR","Quantidade" ,"@E 999999.99"      ,TamSx3("C6_QTDVEN")[1]  ,,,"RIGHT",,,,05,,,,.T.)
	TRCell():New(oSectionB,"C6_VALOR"   ,"ITR","Valor"		,"@E 999,999,999.99" ,TamSx3("C6_VALOR")[1]   ,,,"RIGHT",,,,05,,,,.T.)

    //Quebras do relatorio
    oBreak := TRBreak():New(oSectionB, oSectionB:Cell("C6_ITEM"), {||"total"},.T.)
 
    //Totalizadores
    TRFunction():New(oSectionB:Cell("C6_VALOR"), , "SUM", , , "@E 999,999,999.99", , .T.,.T.,.F.)

Return oReport

Static Function ReportPrint(oReport)
	Local oSectionA := oReport:Section(1)
	Local oSectionB := oReport:Section(2)
	Local cQuery    := ""

	cQuery := " Select *" + CRLF
	cQuery += " From " + RetSqlName("SC5") + CRLF
	cQuery += " Where D_E_L_E_T_ = ' '" + CRLF
	cQuery += " And C5_NUM Between '" + MV_PAR01 + "' and '" + MV_PAR02 + "'"
	cQuery := ChangeQuery(cQuery)

	If Select("REP") > 0
		REP->(DbCloseArea())
	ENdif

	TCQUERY cQuery NEW ALIAS "REP"

	While !REP->(EOF())
		oSectionA:Init()

		oSectionA:Cell("C5_EMISSAO"):SetValue(STOD(REP->C5_EMISSAO))
		oSectionA:Cell("DESCCLI"):SetValue(POSICIONE("SA1",1,xFilial("SA1") + REP->C5_CLIENTE + REP->C5_LOJACLI, "A1_NOME"))

		oSectionA:PrintLine()

		cQuery := " Select *" + CRLF
		cQuery += " From "+ RetSqlName("SC6") + CRLF
		cQuery += " WHere D_E_L_E_T_ = ' '" + CRLF
		cQuery += " And C6_NUM = '" + REP->C5_NUM + "'" + CRLF
		cQuery := ChangeQuery(cQuery)

		If Select("ITR") > 0
			ITR->(DbCloseArea())
		ENdif

		TCQUERY cQuery NEW ALIAS "ITR"

        While !ITR->(EOF())
            oSectionB:Init()

            oSectionB:Cell("DESCPRO"):SetValue(POSICIONE("SB1",1,xFilial("Sbq") + ITR->C6_PRODUTO, "B1_DESC"))

            oSectionB:PrintLine()

            ITR->(DbSkip())
        Enddo

        oSectionB:Finish()
		oSectionA:Finish()
        oReport:SkipLine(2)
		oReport:FatLine()

		REP->(DbSkip())
	Enddo

Return

Static Function CriaCab(_cTitulo)
	Local aArea		:= GetArea()
	Local aCabec	:= {}

	//Monta estrutura do cabecalho
	cLinha1 := "ADO TRANSPORTADORA" + SPACE(10) + _cTitulo + SPACE(10)
	cLinha1 += " Hora: " + Time() + " Emissao: " + DTOC(Date())

	/* cLinha2 := "Cnpj: " + cCnpj + SPACE(10) +"Ie: " + cIe + SPACE(10)
	cLinha2 += "Rota: " + cRota + " Hora: " + Time()

	cLinha3 := "Unidade: " + cUn + SPACE(10) +"Rntc: " + cRntc + SPACE(10)
	cLinha3 += "Peso total: " + cValToChar(nPeso) + " Qtd.Total: "  + cValToChar(nQuant)

	cLinha4 := "Motorista: " + cMoto + SPACE(10) + "Placa: " + cPlaca + SPACE(10)
	cLinha4 += "Volume: " + cValToChar(nVol) */

	//Cria cabecalho
	aAdd(aCabec, cLinha1)
	/* aAdd(aCabec, cLinha2)
	aAdd(aCabec, cLinha3)
	aAdd(aCabec, cLinha4) */

	RestArea(aArea)

Return aCabec
