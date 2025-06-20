#Include "Protheus.ch"

/*   Função EnchoiceBar
    Parâmetros
        + Nome da Dialog que a EnchoiceBar será vinculada
        + Ação ao clicar no botão Confirmar
        + Ação ao clicar no botão Cancelar
        + Se for .T. mostra uma mensagem de deseja realmente excluir
        + Botões do Outras Ações
        + Número do Recno que será posicionado da tabela
        + Tabela de onde esta sendo feito as operações
        + Ativa a função Mashups no Outras Ações
    Retorno
        Função não tem retorno
 
    **** Apoie nosso projeto, se inscreva em https://www.youtube.com/TerminalDeInformacao ****
/*/
User Function XTELAIV()
	Private cAlias1 := ""
	Private cAlias2 := ""
	Private aHeader := {}
	Private aCols := {}
	Private cCadastro := "Modelo 3"
	Private aRotina := {}

	AAdd(aRotina, {"Pesquisar"  , "axPesqui"     , 0, 1})
	AAdd(aRotina, {"Visualizar" , "U_Incmod3"    , 0, 2})
	AAdd(aRotina, {"Incluir"    , "u_MOD3INCLUI" , 0, 3})
	AAdd(aRotina, {"Altera"     , "u_Incmod3"    , 0, 4})
	AAdd(aRotina, {"Excluir"    , "u_Incmod3"    , 0, 5})

	mBrowse(,,,,cAlias1)

Return

User Function MOD3INCLUI(cAlias, nReg, nOpc)
    Local oDlg
    Local bConfirm  := {|| Msginfo("Confirmou","Enchoicebar")}
    Local bCancel   := {|| oDlg:End()}
    Local aOutraAc  := {}
    Local aCpoEnch  := {} 
    
    aAdd(aOutraAc,{"BOTAO1", {|| Alert("Cliquei no 1")}, "Botão 1"}) 
    aAdd(aOutraAc,{"BOTAO2", {|| Alert("Cliquei no 2")}, "Botão 2"})

    DbSelectArea("SX3")
    SX3->(DbSetOrder(1))
    SX3->(DbGoTop())
    SX3->(DbSeek(cAlias1))
    While !Eof() .And. SX3->X3_ARQUIVO == cAlias1
        If !(SX3->X3_CAMPO $ "A1_FILIAL") .And. cNivel >= SX3->X3_NIVEL .And. X3Uso(SX3->X3_USADO)
            AADD(aCpoEnch,SX3->X3_CAMPO)
        EndIf
        DbSkip()
    Enddo

    Mod3Head() 		// Propriedades dos campos que compoem o cabealho do Grid dos itens(ZIF)
	Mod3Cols(nOpc)

    oDlg := TDialog():New(0,0,580,900,"XTELAII",,,,,,,,,.T.)
    

    Enchoice()

    oGrid := MsNewGetDados():New()

    oDlg:Lcentered  := .T.
    oDlg:Activate(,,,,,,{|| EnchoiceBar(oDlg,bConfirm,bCancel,,aOutraAc)})
Return 

//+--------------------------------------------------------------------+
//| Rotina | Mod3aHeader | Autor | Robson Luiz (rleg) |Data|01.01.2007 |
//+--------------------------------------------------------------------+
//| Descr. | Rotina para montar o vetor aHeader. |
//+--------------------------------------------------------------------+
//| Uso | Para treinamento e capacitao. |
//+---------------------------------------------------------------------
Static Function Mod3Head()
	Local aArea := GetArea()

	dbSelectArea("SX3")
	SX3->(dbSetOrder(1))
	SX3->(dbSeek(cAlias2))

	While !EOF() .And. X3_ARQUIVO == cAlias2
		If X3Uso(X3_USADO) .And. !(SX3->X3_CAMPO $ "B1_FILIAL") 
			AADD( aHeader, { Trim( X3Titulo() ),;   //1
				X3_CAMPO,;                          //2
				X3_PICTURE,;                        //3
				X3_TAMANHO,;                        //4
				X3_DECIMAL,;                        //5
				X3_VALID,;                          //6
				X3_USADO,;                          //7
				X3_TIPO,;                           //8
				X3_F3,;                             //9
				X3_CONTEXT})                        //10
		Endif
		dbSkip()
	End

	RestArea(aArea)

Return

//+--------------------------------------------------------------------+
//| Rotina | Mod3aCOLS | Autor | Robson Luiz (rleg) |Data | 01.01.2007 |
//+--------------------------------------------------------------------+
//| Descr. | Rotina para montar o vetor aCOLS. |
//+--------------------------------------------------------------------+
//| Uso | Para treinamento e capacitao. |
//+--------------------------------------------------------------------+

Static Function Mod3Cols( nOpc)
	Local cChave := ""
	Local aArea := GetArea()
	Local nI      := 0
	Local nJ      := 0

	// Se nao for inclusao
	If nOpc <> 3
		cChave := xFilial(cAlias) + SZ1->Z1_COD

		dbSelectArea( cAlias )
		ZIU->(dbSetOrder(2))
		ZIU->(dbSeek( cChave ))

		While !EOF() .And. ZIU->( ZIU_FILIAL + ZIU_COD ) == cChave
			AADD( aREG, ZIU->( RecNo() ) )
			AADD( aCOLS, Array( Len( aHeader ) + 1 ) )

			For nI := 1 To Len( aHeader )
				If aHeader[nI,10] == "V"
					aCOLS[Len(aCOLS),nI] := CriaVar(aHeader[nI,2],.T.)
				Else
					aCOLS[Len(aCOLS),nI] := FieldGet(FieldPos(aHeader[nI,2]))
				Endif
			Next nI

			aCOLS[Len(aCOLS),Len(aHeader)+1] := .F.
			ZIU->(dbSkip())
		EndDo
		DbCloseArea()
	Else
		aAdd( aCols, Array( Len( aHeader ) + 1))

		For nJ := 1 To Len(aCols)
			For nI := 1 To Len(aHeader)
				aCOLS[nJ, nI] := CriaVar( aHeader[nI, 2], .T. )
			Next
            aCOLS[nJ,Len(aHeader)+1] := .F.
		Next
	Endif

	Restarea( aArea )

Return
