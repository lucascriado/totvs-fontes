#Include "Protheus.ch"
#Include "TopConn.ch"

User Function XEXCELREL()
	Local aPergs   := {}
    Local xPar0 := Space(15)
    Local xPar1 := Space(15)
	
	Private aDados := {}
     
    //Adicionando os parametros do ParamBox
    aAdd(aPergs, {1, "Produto De", xPar0,  "", ".T.", "SA1", ".T.", 80,  .F.})
    aAdd(aPergs, {1, "Produto Até", xPar1,  "", ".T.", "SA1", ".T.", 80,  .T.})
     
    //Se a pergunta for confirma, cria o relatorio
    If ParamBox(aPergs, "Informe os parametros")
		BUSCADADOS()

        If !Empty(aDados)
            CRIAXML()
        Endif

	Endif

Return

Static Function BUSCADADOS()
	Local cQuery := ""

	cQuery := "Select * " + CRLF
	cQuery += " From " + RetSqlName("SA1") + CRLF
	cQuery += " Where A1_COD between '" + MV_PAR01 + "' And '" + MV_PAR02 + "'" + CRLF
	cQuery += " And D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)

	If Select("EXR") > 0
		EXR->(dbCloseArea())
	EndIf

	TCQUERY cQuery NEW ALIAS "EXR"

	If EXR->(!Eof())
		While EXR->(!Eof())
			aAdd(aDados, {EXR->A1_COD,; //1
				EXR->A1_LOJA,;          //2
				EXR->A1_NOME,;          //3
				EXR->A1_EST})           //4
            
            EXR->(DbSkip())
		enddo
	Endif

Return

Static Function CRIAXML()
    Local oFWMsExcel
	Local oExcel	 := FWMsExcelEx():New()
    Local cArquivo    	:= 'AVENORTE'
	Local cTitulo 		:= "Clientes"
    Local nI := 0

    //Aba
    oExcel:AddworkSheet(cArquivo)
    //Criando a Tabela
	oExcel:AddTable(cArquivo,cTitulo)
    // Colunas
    oExcel:AddColumn(cArquivo,cTitulo,"Codigo",1,1)				//1
	oExcel:AddColumn(cArquivo,cTitulo,"Loja",1,1)				//2
	oExcel:AddColumn(cArquivo,cTitulo,"Nome",1,1)				//3
	oExcel:AddColumn(cArquivo,cTitulo,"Estado",1,1)				//4

    //Conteudo colunas
	For nI := 1 To Len(aDados)
		oExcel:AddRow(cArquivo, cTitulo, {aDados[nI][1],aDados[nI][2],aDados[nI][3],aDados[nI][4]})
	Next

    //Criando novas pastas
   /*  //Aba
    oExcel:AddworkSheet(cArquivo)
    //Criando a Tabela
	oExcel:AddTable(cArquivo,cTitulo) */

    cArquivo := GetTempPath()+cArquivo+RIGHT(STRZERO(INT(SECONDS()),8),5)+'.xml'
    oExcel:Activate()
    oExcel:GetXMLFile(cArquivo)

    //Abrindo o excel e abrindo o arquivo xml
	oFWMsExcel := MsExcel():New()               //Abre uma nova conexão com Excel
	oFWMsExcel:WorkBooks:Open(cArquivo)         //Abre uma planilha
	oFWMsExcel:SetVisible(.T.)                  //Visualiza a planilha
	oFWMsExcel:Destroy()                        //Encerra o processo do gerenciador de tarefas

Return
