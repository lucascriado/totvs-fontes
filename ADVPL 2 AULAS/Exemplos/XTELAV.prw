#Include "Protheus.Ch"

User Function XTELAV()
	Private cAlias1 := "SA1"
	Private aHeader := {}
	Private aCols := {}
	Private cCadastro := "Modelo 3"
	Private aRotina := {}

	AAdd(aRotina, {"Pesquisar"  , "axPesqui"     , 0, 1})
	AAdd(aRotina, {"Visualizar" , "U_Incmod3"    , 0, 2})
	AAdd(aRotina, {"Incluir"    , "u_TMPINCLUI"  , 0, 3})
	AAdd(aRotina, {"Altera"     , "u_Incmod3"    , 0, 4})
	AAdd(aRotina, {"Excluir"    , "u_Incmod3"    , 0, 5})

	mBrowse(,,,,cAlias1)

Return

User Function TMPINCLUI(cAlias, nReg, nOpc)
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

    aHeadCpo := CRIATMP()
    CRIAHEADER()

    oDlg := TDialog():New(0,0,580,900,"XTELAII",,,,,,,,,.T.)
    RegToMemory(cAlias1,.T.)

    Enchoice(cAlias1,,nOpc,,,,aCpoEnch,{30,0,150,455},,,,,,oDlg)

    oGrid := MsGetDB():New(153,0,290,455,nOpc,,,,.T.,{'MP_COD','MP_DESC'},,,,"TMP",,,.T.,oDlg)

    oDlg:Lcentered  := .T.
    oDlg:Activate(,,,,,,{|| EnchoiceBar(oDlg,bConfirm,bCancel,,aOutraAc)})
Return

Static Function CRIATMP()
	Local aCampos := {}
    Local cFile
    
    aAdd(aCampos,{'MP_COD'  ,'C' ,6,0})
    aAdd(aCampos,{'MP_DESC' ,'C' ,50,0})

    cFile := CRIATRAB(aCampos,.T.)

    If Select("TMP") > 0
        TMP->(DbCloseArea())
    ENdif


    dbUseArea(.T.,"TOPCCON",cFile,"TMP",.F.,.F.)

Return aCampos

Static Function CRIAHEADER()
    Local nI := 0

    For nI := 1 To Len(aHeadCpo)
        aAdd(aHeader,{aHeadCpo[nI][1],;
        aHeadCpo[nI][1],;
        "",;
        aHeadCpo[nI][3],;
        aHeadCpo[nI][4],;
        "",;
        "",;
        aHeadCpo[nI][2],;
        "",;
        ""})
    Next

Return
