#Include "Protheus.Ch"
#Include "Totvs.ch"
#Include "Colors.ch"

User Function XTELAIII()
	Local oDlg
	Local oOk       := LoadBitmap(GetResources(),'LBOK')
	Local oNo       := LoadBitmap(GetResources(),'LBNO')
	Local aColSizes := {5,30,10}
	Local bButton1  := {||aAdd(aLinha,{.F.,SPACE(30),18})}
	Local bButton2  := {|| CONTIN()}
	Local bButton3  := {|| DELETA()}

	Private aLinha    := {}
	Private oGrid
	Private cTGet1	  := SPACE(10)

	//Arrays contendo valores para calcular tamanho das dialogs//
	Private aSize	:= MsAdvSize(.F.,.F.,500)				   //	
	Private aInfo   := {}									   //
	Private aObj    := {}									   //	
	Private aPObj   := {}									   //					  
	Private aPGet1 	:= {}									   //
	//---------------------------------------------------------//

	//Divisões da tela
	// 1 - cabeçalho
	// 2 - grid
	aAdd( aObj , { 100 , 50 , .T. , .T. } )
	aAdd( aObj , { 100 , 50 , .T. , .T. } )

	// Calculo automtico da dimenses dos objetos (altura/largura) em pixel
	aInfo:= { aSize[1] , aSize[2] , aSize[3] , aSize[4] , 5 , 5 }
	aPObj := MsObjSize( aInfo , aObj )
	// Calculo automtico de dimenses dos objetos MSGET
	// 1 linha
	// 2 coluna
	aPGet1 	:= MsObjGetPos( (aSize[3] - aSize[1]), 315, { {5,10,65,95,125} } )
	aPGet2 	:= MsObjGetPos( (aSize[4] - aSize[2]), 315, { {5,45,105,165,225,285,345,405,465,525,585,645} } )


	aAdd(aLinha,{.T.,"Leandro Campos",30})
	aAdd(aLinha,{.F.,"Renato Augusto",50})

	oDlg := TDialog():New(0,0,aSize[6],aSize[5],"XTELAII",,,,,,,,,.T.)

	oGrid := TCBrowse():New(aPObj[2,1],aPObj[2,2],aPObj[2,4],aPObj[2,3]/2,,,aColSizes,oDlg,,,,,,,,,,,,,,.T.)
	oGrid:SetArray(aLinha)

	oGrid:addColumn(TCColumn():New(""       ,{|| IIF(aLinha[oGrid:nAt][1],oOK,oNo)},,,,,,.T.))
	oGrid:addColumn(TCColumn():New("Nome"   ,{|| aLinha[oGrid:nAt][2]}))
	oGrid:addColumn(TCColumn():New("Idade"  ,{|| aLinha[oGrid:nAt][3]}),,,,,,,,,{|| AGEVAL()})

	oGrid:bLDblClick := {|| LDBCLK()}

	oSay1   := TSay():New(aPGet1[1][1],aPGet2[1][1],{|| "Codigo:"},oDlg,,,,,,.T.,,,40,20)
    oGet1   := TGet():New(aPGet1[1][2],aPGet2[1][1],{|u| iif( Pcount()>0, cTGet1:= u,cTGet1 ) },oDlg,40,10,,,,,,,,.T.)

	oButton3 := TButton():New(aPGet1[1][1],aPGet2[1][10],"Deleta",oDlg,bButton3,50,20,,,,.T.)
	oButton1 := TButton():New(aPGet1[1][1],aPGet2[1][11],"Cria linha",oDlg,bButton1,50,20,,,,.T.)
	oButton2 := TButton():New(aPGet1[1][1],aPGet2[1][12],"Continua",oDlg,bButton2,50,20,,,,.T.)

	oDlg:Lcentered  := .T.
	oDlg:Activate()

Return

Static function AGEVAL()
	Local lRet := .T.

	If aLinha[oGrid:nAt][3] < 18 .Or. aLinha[oGrid:nAt][3] > 80
		lRet := .F.
		Alert("Faixa de idade nao permitida!","Corrija")
	Endif
Return lRet

Static Function LDBCLK()
	Local nOri

	If oGrid:nColPos == 1
		aLinha[oGrid:nAt][1]:= !aLinha[oGrid:nAt][1]
	Else
		lEditCell(aLinha,oGrid,"",oGrid:nColPos)
	Endif

Return

Static Function CONTIN()
	Local nI := 0
	Local cMsg := ""

	For nI := 1 To Len(aLinha)
		If aLinha[nI][1]
			cMsg += "Linha " + cValtochar(nI) + " marcada" + CRLF
		Endif
	Next

	If !Empty(cMsg)
		MsgInfo(cMsg)
	Else
		Alert("Nenhum registro marcado")
	Endif

Return

Static Function DELETA()

	aDel(aLinha,oGrid:nAt)
	aSize(aLinha,Len(aLinha) - 1)

Return
