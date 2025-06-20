#Include "Protheus.Ch"
#Include "Totvs.ch"
#Include "Colors.ch"

User Function XTELAII()
    Local oDlg
    Local oOk       := LoadBitmap(GetResources(),'LBOK')
    Local oNo       := LoadBitmap(GetResources(),'LBNO')
    Local aHeader   := {"","Nome","Idade"}
    Local aColSizes := {5,30,10}
    Local bButton1  := {||aAdd(aLinha,{.F.,SPACE(30),18})}
    Local bButton2  := {|| CONTIN()}
    Local bButton3  := {|| DELETA()}
    
    Private aLinha    := {}
    Private oGrid

    aAdd(aLinha,{.T.,"Leandro Campos",30})
    aAdd(aLinha,{.F.,"Renato Augusto",50})

    oDlg := TDialog():New(0,0,500,500,"XTELAII",,,,,,,,,.T.)

    oGrid := TCBrowse():New(0,0,250,210,,aHeader,aColSizes,oDlg,,,,,,,,,,,,,,.T.)
    oGrid:SetArray(aLinha)
    oGrid:bLine := {|| {IIF(aLinha[oGrid:nAt][1],oOK,oNo),;
                        aLinha[oGrid:nAt][2],;
                        aLinha[oGrid:nAt][3]}}
    
    oGrid:bLDblClick := {|| LDBCLK()}

    oButton3 := TButton():New(220,75 ,"Deleta",oDlg,bButton3,50,20,,,,.T.)
    oButton1 := TButton():New(220,135,"Cria linha",oDlg,bButton1,50,20,,,,.T.)
    oButton2 := TButton():New(220,195,"Continua",oDlg,bButton2,50,20,,,,.T.)

    oDlg:Lcentered  := .T.
    oDlg:Activate()

Return

Static Function LDBCLK()
    Local nOri

    If oGrid:nColPos == 1
        aLinha[oGrid:nAt][1]:= !aLinha[oGrid:nAt][1]
    Else
        nOri :=  aLinha[oGrid:nAt][3]
        If lEditCell(aLinha,oGrid,"",oGrid:nColPos)
            If aLinha[oGrid:nAt][3] < 18 .Or. aLinha[oGrid:nAt][3] > 80
                aLinha[oGrid:nAt][3] := nOri
                Alert("Faixa de idade nao permitida!","Corrija")
            Endif
        Endif
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
