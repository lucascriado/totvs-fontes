#include "Protheus.ch"
#INCLUDE "FWBROWSE.CH"

User Function xEnchoice()
	Local aArea       := GetArea()
	Local cTabela     := "SZ3"

	Private cCadastro   := "Treinamento Avenorte"
	Private cFiltro     := ""
	Private aRotina     := {}
	Private aCores      := {}
	Private aSize       := {}//-----------------------------------------------------------//
	Private aInfo       := {}															  //
	Private aObj        := {}// Arrays contendo valores para calcular tamanho das dialogs //
	Private aPObj       := {}															  //
	Private aPGet 	    := {}//-----------------------------------------------------------//
	Private bCampo      := {|nField| FieldName(nField)}

	// Retorna a area util das janelas Protheus garantindo um minimo para resolucao 800x600
	aSize := MsAdvSize(,.F.,370 )

	// 1 - Enchoice, sendo 80 pontos pixel
	// 2 - MsGetDados, o que sobrar em pontos pixel  para este objeto
	aAdd( aObj , { 100 , 150 , .T. , .F. } )
	aAdd( aObj , { 100 , 100 , .T. , .T. } )

	// Clculo automtico da dimenses dos objetos (altura/largura) em pixel
	aInfo:= { aSize[1] , aSize[2] , aSize[3] , aSize[4] , 5 , 5 }
	aPObj := MsObjSize( aInfo , aObj )
	// Clculo automtico de dimenses dos objetos MSGET
	aPGet 	:= MsObjGetPos( (aSize[3] - aSize[1]), 315, { {025,105,170,244} } )

	//Botes
	AADD(aRotina,{"Pesquisar"  		    ,"AxPesqui"   	, 0, 1})
	aAdd(aRotina,{"Visualizar" 			, "U_XALTV"    	, 0, 2})
	aAdd(aRotina,{"Incluir"    			, "U_XINC"      , 0, 3})
	aAdd(aRotina,{"Alterar"    			, "U_XALTV"     , 0, 4})
	aAdd(aRotina,{"Excluir"    			, "U_XALTV"     , 0, 4})

	DbSelectArea(cTabela)
	(cTabela)->(DbSetOrder(1))

	mBrowse(6,1,22,75,cTabela,,,,,6)

	(cTabela)->(DbCloseArea())
	RestArea(aArea)
Return

User Function XINC(cAlias, nReg, nOpc)
	Local oDlg
	Local oGrid
	Local nX := 0
	Local lOpc := .F.
	Local aOutrasAc := {}
	Local bBlocoOk  := {|| IIF(Obrigatorio( aGets, aTela,,.T. ),(lOpc := .T.,oDlg:end()),NIL)}
	Local bBlocoCan := {|| oDlg:end()}
	Local bBlocoIni := {|| EnchoiceBar(oDlg,bBlocoOk,bBlocoCan,,aOutrasAc)}

	Private aGets 	  := {}
	Private aTela 	  := {}
	Private aHeader   := {}
	Private aCols     := {}
	Private aCabec	  := {"NOUSER"}

	// Outras acoes da enchoicebar
	aAdd(aOutrasAc, {"BMP",{||MsgInfo("Botao 1","")},"Botao 1"})

	For nX := 1 To FCount()
		// Campos que farao parte do cabeçalho
		If FieldName( nX ) == "Z3_COD" .Or. FieldName( nX ) == "Z3_DESC" .Or. FieldName( nX ) == "Z3_VALOR";
				.Or. FieldName( nX ) == "Z3_DATA" .Or. FieldName( nX ) == "Z3_CODPRO"

			M->&( Eval( bCampo, nX ) ) := CriaVar( FieldName( nX ), .T. )
			aAdd(aCabec, FieldName( nX ))

		Endif
	Next nX

	XHEADER()
	XCOLS(nOpc)

	oDlg := MSDialog():New(aSize[7],aSize[1],aSize[6],aSize[5],"Treinamento Avenorte",,,,,,,,,.T.)
	EnChoice( cAlias, nReg, nOpc, , , , aCabec, aPObj[1],,,,,,oDlg)

	oGrid := MSGetDados():New(aPObj[2,1],aPObj[2,2],aPObj[2,3],aPObj[2,4],nOpc,,".T.",,.T.,,,.F.,,,,,,oDlg,.F.,)

	oDlg:Activate(,,,.T.,,,bBlocoIni)

	If lOpc
		If GRAVAREG(nOpc)
			ConfirmSX8()
			MsgInfo("Registro incluido com sucesso!","Inclusao")
		Endif
	Else
		RollBackSX8()
	Endif

Return

User Function XALTV(cAlias, nReg, nOpc)
	Local oDlg
	Local oGrid
	Local nX := 0
	Local lOpc := .F.
	Local lDelG := .T.
	Local aOutrasAc := {}
	Local bBlocoOk  := {|| lOpc := .T.,oDlg:end()}
	Local bBlocoCan := {|| oDlg:end()}
	Local bBlocoIni := {|| EnchoiceBar(oDlg,bBlocoOk,bBlocoCan,,aOutrasAc)}

	Private aGets 	  := {}
	Private aTela 	  := {}
	Private aHeader   := {}
	Private aCols     := {}
	Private aCabec	  := {"NOUSER"}
	Private aREG 	  := {}

	// se nao for alteracao
	If nOpc <> 2
		lDelG := .F.
	Endif

	// Outras acoes da enchoicebar
	aAdd(aOutrasAc, {"BMP",{||MsgInfo("Botao 1","")},"Botao 1"})

	For nX := 1 To FCount()
		// Campos que farao parte do cabeçalho
		If FieldName( nX ) == "Z3_COD" .Or. FieldName( nX ) == "Z3_DESC" .Or. FieldName( nX ) == "Z3_VALOR";
				.Or. FieldName( nX ) == "Z3_DATA" .Or. FieldName( nX ) == "Z3_CODPRO"

			M->&( Eval( bCampo, nX ) ) := FieldGet( nX )
			aAdd(aCabec, FieldName( nX ))

		Endif
	Next nX

	XHEADER()
	XCOLS(nOpc)

	oDlg := MSDialog():New(aSize[7],aSize[1],aSize[6],aSize[5],"Treinamento Avenorte",,,,,,,,,.T.)
	EnChoice( cAlias, nReg, nOpc, , , , aCabec, aPObj[1],,,,,,oDlg)

	oGrid := MSGetDados():New(aPObj[2,1],aPObj[2,2],aPObj[2,3],aPObj[2,4],nOpc,,".T.",,lDelG,,,.F.,,,,,,oDlg,.F.,)

	oDlg:Activate(,,,.T.,,,bBlocoIni)

	If lOpc .And. (nOpc == 4 .Or. nOpc == 5)
		If GRAVAREG(nOpc)
			MsgInfo("Registro Alterado com sucesso!","Inclusao")
		Endif
	Endif
Return
Static Function XHEADER()
	Local aArea := GetArea()

	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("SZ3")

	While !EOF() .And. X3_ARQUIVO == "SZ3"
		If X3Uso(X3_USADO) .And. !aScan(aCabec, AllTrim(X3_CAMPO) ) > 0
			AADD( aHeader, { Trim( X3Titulo() ),;
				X3_CAMPO,;
				X3_PICTURE,;
				X3_TAMANHO,;
				X3_DECIMAL,;
				X3_VALID,;
				X3_USADO,;
				X3_TIPO,;
				X3_ARQUIVO,;
				X3_CONTEXT})
		Endif
		dbSkip()
	Enddo

	RestArea(aArea)
Return

Static Function XCOLS(nOpc)
	Local aArea     := GetArea()
	Local nI        := 0
	Local nJ        := 0

	// Se for inclusao
	If nOpc == 3
		aAdd( aCols, Array( Len( aHeader ) + 1))

		For nJ := 1 To Len(aCols)
			For nI := 1 To Len(aHeader)
				aCOLS[nJ, nI] := CriaVar( aHeader[nI, 2], .T. )
			Next
			aCOLS[nJ, Len( aHeader ) + 1] := .F.
		Next
	Else
		cChave := SZ3->Z3_COD

		SZ3->(dbSetOrder(1))
		SZ3->(dbSeek( cChave ))

		While !EOF() .And. SZ3->Z3_COD  == cChave
			AADD( aREG, SZ3->( RecNo() ) )
			AADD( aCOLS, Array( Len( aHeader ) + 1 ) )

			For nI := 1 To Len( aHeader )
				If aHeader[nI,10] == "V"
					aCOLS[Len(aCOLS),nI] := CriaVar(aHeader[nI,2],.T.)
				Else
					aCOLS[Len(aCOLS),nI] := FieldGet(FieldPos(aHeader[nI,2]))
				Endif
			Next nI

			aCOLS[Len(aCOLS),Len(aHeader)+1] := .F.

			SZ3->(dbSkip())
		EndDo
	Endif

	Restarea( aArea )
Return

Static Function GRAVAREG(nOpc)
	Local nX := 0
	Local nI := 0
	Local lRet := .F.

	// se for inclusao
	If nOpc == 3
		//Grava itens
		For nX := 1 To Len( aCOLS )
			If !aCOLS[ nX, Len( aCOLS[nX] )]
				RecLock( "SZ3", .T. )
				For nI := 1 To Len( aHeader )
					FieldPut( FieldPos( Trim( aHeader[nI, 2] ) ),aCOLS[nX,nI] )
				Next nI
				SZ3->Z3_COD 	:= M->Z3_COD
				SZ3->Z3_DESC	:= M->Z3_DESC
				SZ3->Z3_VALOR	:= M->Z3_VALOR
				SZ3->Z3_DATA	:= M->Z3_DATA
				SZ3->Z3_CODPRO	:= M->Z3_CODPRO
				MsUnLock()
			Endif
		Next nX

	// se for alteracao	
	ElseIf nOpc == 4
		// Grava os itens conforme as alteraes
		For nX := 1 To Len( aCOLS )
			If nX <= Len( aREG )
				dbGoto( aREG[nX] )
				RecLock("SZ3",.F.)
				If aCOLS[ nX, Len( aHeader ) + 1 ]
					dbDelete()
				Endif
			Else
				If !aCOLS[ nX, Len( aHeader ) + 1 ]
					RecLock( "SZ3", .T. )
				Endif
			Endif

			If !aCOLS[ nX, Len(aHeader)+1 ]
				For nI := 1 To Len( aHeader )
					FieldPut( FieldPos( Trim( aHeader[ nI, 2] ) ),aCOLS[ nX, nI ] )
				Next nI
				SZ3->Z3_COD 	:= M->Z3_COD
				SZ3->Z3_DESC	:= M->Z3_DESC
				SZ3->Z3_VALOR	:= M->Z3_VALOR
				SZ3->Z3_DATA	:= M->Z3_DATA
				SZ3->Z3_CODPRO	:= M->Z3_CODPRO
			Endif
			MsUnLock()
		Next nX
		
	//se for exclusao
	Else
		For nX := 1 To Len(aCOLS)
				dbGoto( aREG[nX] )
				RecLock("SZ3",.F.)
					dbDelete()
				MsUnLock()
		Next nX
	Endif

Return lRet
