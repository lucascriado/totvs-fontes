#Include "Protheus.Ch"
#Include "Totvs.ch"
#Include "Colors.ch"

User Function XTELAI()
    Local oDlg
    Local oSay
    Local oGet
    Local oButton1, oButton2
    Local cJustificativa := Space(100) 
    Local bButton1  := {|| oDlg:End()}
    Local bButton2  := {|| oDlg:End()}
    
    oDlg := TDialog():New(0,0,200,300,"Justificativa",,,,,,,,,.T.)

    oSay := TSay():New(10,10,{|| "Justificativa:"},oDlg)

    oGet := TGet():New(30,10,{|u| iif( Pcount()>0, cJustificativa:= u, cJustificativa ) },oDlg,180,100)

    oButton1 := TButton():New(170,50,"Confirma",oDlg,bButton1,50,20)
    oButton2 := TButton():New(170,110,"Cancelar",oDlg,bButton2,50,20)

    oDlg:Lcentered  := .T.
    oDlg:Activate()

Return
