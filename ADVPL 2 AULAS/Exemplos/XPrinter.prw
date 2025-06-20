//Bibliotecas
#Include "Totvs.ch"
#Include "TopConn.ch"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"

//Alinhamentos
#Define PAD_LEFT    0
#Define PAD_RIGHT   1
#Define PAD_CENTER  2

//Cor(es)
Static nCorCinza := RGB(110, 110, 110)
Static nCorLinha := RGB(20, 204, 214)

User Function xPrinter()
	Local aArea := FWGetArea()
	Local aPergs   := {}
	Local xPar0 := Space(15)
	Local xPar1 := Space(15)

	//Adicionando os parametros do ParamBox
	aAdd(aPergs, {1, "Produto De", xPar0,  "", ".T.", "SB1", ".T.", 80,  .F.})
	aAdd(aPergs, {1, "Produto Até", xPar1,  "", ".T.", "SB1", ".T.", 80,  .T.})

	//Se a pergunta for confirma, cria o relatorio
	If ParamBox(aPergs, "Informe os parametros")
		Processa({|| fImprime()})
	EndIf

	FWRestArea(aArea)
Return

Static Function fImprime()
	Local aArea        := GetArea()
	Local nI           := 0
	Local nTotAux      := 0
	Local nAtuAux      := 0
	Local cQryAux      := ''
	Local cArquivo     := 'xPrint.pdf'
	Private oPrintPvt
	Private oBrushLin  := TBrush():New(,nCorLinha)
	Private cHoraEx    := Time()
	Private nPagAtu    := 1
	//Linhas e colunas
	Private nLinAtu    := 0
	Private nLinFin    := 800
	Private nColIni    := 010
	Private nColFin    := 580
	Private nColMeio   := (nColFin-nColIni)/2
	//Colunas dos relatorio
	Private nColDad1    := nColIni
	Private nColDad2    := nColIni + 150
	//Declarando as fontes
	Private cNomeFont  := 'Arial'
	Private oFontDet   := TFont():New(cNomeFont, 9, -11, .T., .F., 5, .T., 5, .T., .F.)
	Private oFontDetN  := TFont():New(cNomeFont, 9, -13, .T., .T., 5, .T., 5, .T., .F.)
	Private oFontRod   := TFont():New(cNomeFont, 9, -8,  .T., .F., 5, .T., 5, .T., .F.)
	Private oFontMin   := TFont():New(cNomeFont, 9, -7,  .T., .F., 5, .T., 5, .T., .F.)
	Private oFontTit   := TFont():New(cNomeFont, 9, -15, .T., .T., 5, .T., 5, .T., .F.)

	//Monta a consulta de dados
	cQryAux += "SELECT "        + CRLF
	cQryAux += " B1_COD, "        + CRLF
	cQryAux += " B1_DESC, "        + CRLF
	cQryAux += " B1_GRUPO "        + CRLF
	cQryAux += "FROM "        + CRLF
	cQryAux += " SB1990 SB1 "        + CRLF
	cQryAux += "WHERE "        + CRLF
	cQryAux += " B1_COD >= '" + MV_PAR01 + "' "        + CRLF
	cQryAux += " AND B1_COD <= '" + MV_PAR02 + "' "        + CRLF
	cQryAux += " AND SB1.D_E_L_E_T_ = ' '"        + CRLF
	PLSQuery(cQryAux, 'QRY_AUX')

	//Define o tamanho da régua
	DbSelectArea('QRY_AUX')
	QRY_AUX->(DbGoTop())
	Count to nTotAux
	ProcRegua(nTotAux)
	QRY_AUX->(DbGoTop())

	//Somente se tiver dados
	If ! QRY_AUX->(EoF())
		//Criando o objeto de impressao
		oPrintPvt := FWMSPrinter():New(cArquivo + cHoraEx, IMP_PDF, .F., ,   .T., ,    @oPrintPvt, ,   ,    , ,.T.)
		oPrintPvt:cPathPDF := GetTempPath()
		oPrintPvt:SetResolution(72)
		oPrintPvt:SetPortrait()
		oPrintPvt:SetPaperSize(DMPAPER_A4)
		oPrintPvt:SetMargin(0, 0, 0, 0)

		For nI := 1 To 2
            IMPREL(nAtuAux,nTotAux,nI)
        Next

	Else
		MsgStop('Não foi encontrado informações com os parâmetros informados!', 'Atenção')
	EndIf

	QRY_AUX->(DbCloseArea())

	RestArea(aArea)
Return

Static Function ImpRel(nAtuAux,nTotAux,nI)
    
    nLinAtu    := 0

    If nI > 1
        nAtuAux := 1
        nPagAtu    := 1

        oPrintPvt := FWMSPrinter():New("teste" + cValtochar(nI), IMP_PDF, .F., ,   .T., ,    @oPrintPvt, ,   ,    , ,.T.)
		oPrintPvt:cPathPDF := GetTempPath()
		oPrintPvt:SetResolution(72)
		oPrintPvt:SetPortrait()
		oPrintPvt:SetPaperSize(DMPAPER_A4)
		oPrintPvt:SetMargin(0, 0, 0, 0)

        QRY_AUX->(DbGoTop())
    Endif 

    //Imprime os dados
	fImpCab()
	While ! QRY_AUX->(EoF())
		nAtuAux++
		IncProc('Imprimindo registro ' + cValToChar(nAtuAux) + ' de ' + cValToChar(nTotAux) + '...')

		//Se atingiu o limite, quebra de pagina
		fQuebra()

		//Faz o zebrado ao fundo
		If nAtuAux % 2 == 0
			oPrintPvt:FillRect({nLinAtu - 2, nColIni, nLinAtu + 12, nColFin}, oBrushLin)
		EndIf

		//Imprime a linha atual
		oPrintPvt:SayAlign(nLinAtu, nColDad1, Alltrim(QRY_AUX->B1_COD), oFontDet, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
		oPrintPvt:SayAlign(nLinAtu, nColDad2, Alltrim(QRY_AUX->B1_DESC), oFontDetN, 100, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)

		nLinAtu += 15
		oPrintPvt:Line(nLinAtu-3, nColIni, nLinAtu-3, nColFin, nCorCinza)

		//Se atingiu o limite, quebra de pagina
		fQuebra()

		QRY_AUX->(DbSkip())
	EndDo
	fImpRod()

	oPrintPvt:Preview()

Return

Static Function fImpCab()
	Local cTexto   := ''
	Local nLinCab  := 015

	//Iniciando Pagina
	oPrintPvt:StartPage()

	//Cabecalho
	cTexto := 'Todos os Produtos'
	oPrintPvt:SayAlign(nLinCab, nColMeio-200 , cTexto, oFontTit, 400, 20, , PAD_CENTER, )

	//Linha Separatoria
	nLinCab += 020
	oPrintPvt:Line(nLinCab,   nColIni, nLinCab,   nColFin)

	//Atualizando a linha inicial do relatorio
	nLinAtu := nLinCab + 5

	If nPagAtu == 1
		//Imprimindo os parâmetros
		oPrintPvt:SayAlign(nLinAtu, nColIni, 'Produto De', oFontDetN, 200, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
		oPrintPvt:SayAlign(nLinAtu, nColIni+200, MV_PAR01, oFontDet, 200, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
		nLinAtu += 15
		oPrintPvt:SayAlign(nLinAtu, nColIni, 'Produto Até', oFontDetN, 200, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
		oPrintPvt:SayAlign(nLinAtu, nColIni+200, MV_PAR02, oFontDet, 200, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
		nLinAtu += 15
		oPrintPvt:Line(nLinAtu-3, nColIni, nLinAtu-3, nColFin, nCorCinza)
		nLinAtu += 5
	EndIf

	oPrintPvt:SayAlign(nLinAtu, nColDad1, 'Produto', oFontMin, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
	oPrintPvt:SayAlign(nLinAtu, nColDad2, 'Descrição', oFontMin, 100, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
	nLinAtu += 15
Return

Static Function fImpRod()
	Local nLinRod:= nLinFin
	Local cTexto := ''

	//Linha Separatoria
	oPrintPvt:Line(nLinRod,   nColIni, nLinRod,   nColFin)
	nLinRod += 3

	//Dados da Esquerda
	cTexto := dToC(dDataBase) + '     ' + cHoraEx + '     ' + FunName() + ' (xPrint)     ' + UsrRetName(RetCodUsr())
	oPrintPvt:SayAlign(nLinRod, nColIni, cTexto, oFontRod, 500, 10, , PAD_LEFT, )

	//Direita
	cTexto := 'Pagina '+cValToChar(nPagAtu)
	oPrintPvt:SayAlign(nLinRod, nColFin-40, cTexto, oFontRod, 040, 10, , PAD_RIGHT, )

	//Finalizando a pagina e somando mais um
	oPrintPvt:EndPage()
	nPagAtu++
Return

Static Function fQuebra()
	If nLinAtu >= nLinFin-10
		fImpRod()
		fImpCab()
	EndIf
Return
