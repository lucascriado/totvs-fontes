#Include "Protheus.Ch"

User Function XAXCAD()
    
    Private aCores  := {}
    Private aRotina := {}
    Private cCadastro := "AULA ADVPL I"

    //Montando o Array aRotina, com funções que serão mostradas no menu
    aAdd(aRotina,{"Pesquisar"   , "AxPesqui", 0, 1})
    aAdd(aRotina,{"Visualizar"  , "AxVisual", 0, 2})
    aAdd(aRotina,{"Incluir"     , "U_XINCLUI", 0, 3})
    aAdd(aRotina,{"Alterar"     , "AxAltera", 0, 4})
    aAdd(aRotina,{"Excluir"     , "AxDeleta", 0, 5})
    aAdd(aRotina,{"Legenda"    , "u_BOTAO01", 0, 8})

    //Montando as cores da legenda
    aAdd(aCores,{"Z2_LOGI"  , "BR_VERDE" })
    aAdd(aCores,{"!Z2_LOGI" , "BR_VERMELHO" })

    mBrowse(,,,, "SZ2", , , , , , aCores )

Return

User Function XINCLUI()

    If MsgYesNo("Deseja Incluir um registro?","Inclusao")
        AxInclui("SZ2",,3)
    ENdif

Return

User Function BOTAO01()
    Local aLegenda := {}

	aAdd( aLegenda,{"BR_VERDE"   ,"Marcado"	   })
	aAdd( aLegenda,{"BR_VERMELHO", "Desmarcado"})

	BrwLegenda("Legenda","Legenda",aLegenda)
Return

User Function XSIMBRW()
    AXCADASTRO("SZ2","Tabela Aula")
Return
