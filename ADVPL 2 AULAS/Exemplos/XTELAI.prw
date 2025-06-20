#Include "Protheus.Ch"
#Include "Totvs.ch"
#Include "Colors.ch"

User Function XTELAI()
    Local oDlg
    Local oSay1, oSay2, oSay3, oSay4, oSay5
    Local oFont
    Local oGet1,oGet2, oGet3, oGet4, oGet5
    Local oButton1, oButton2
    Local bVal1     := {||IIF(Empty(cTget1),.F.,ExistCpo("SA1",cTget1))}
    Local bCha1     := {|| cTGet3 := POSICIONE("SA1",1,xFilial("SA1") + cTGet1 + cTGet2,"A1_NOME")}
    Local bButton1  := {|| CONFIRMA(),oDlg:End()}
    Local bButton2  := {|| oDlg:End()}
    Local aCombo    := {"1=Sim","2=Nao","3=Limitado","4=Com autorizacao"}
    Local aRadio    := {"Pessoa Juridica","Pessoa Fisica"}
    Local aPastas   := {"Cliente","Financeiro"}
    
    Private cTGet1    := Space(TamSx3("A1_COD")[1])
    Private cTGet2    := Space(TamSx3("A1_LOJA")[1])
    Private cTGet3    := Space(TamSx3("A1_NOME")[1])
    Private nTGet4    := 0
    Private dTGet5    := Date()
    Private lCheck    := .F.
    Private lCheck1   := .F.
    Private cCombo    := "3"
    Private nRadio    := 0
    
   //--------------------------------------Principais objetos-------------------------------------------------//
    oDlg    := TDialog():New(0,0,500,500,"XTELAI",,,,,,,,,.T.)
    oFont   := TFont():New("Calibri",,15)
    oFont:Bold := .T.
    oTFolder := TFolder():New(0,0,aPastas,,oDlg,,,,.T.,,250,250)
    oPanel1 := tPanel():New(5,5,,oTFolder:aDialogs[1],oFont,,,,,200,100)
    oPanel2 := tPanel():New(5,5,,oTFolder:aDialogs[2],oFont,,,,,200,100)
    //--------------------------------------------------------------------------------------------------------//

    //--------------------------------------Cliente-----------------------------------------------------------//
    oSay1   := TSay():New(10,10,{|| "Codigo:"},oPanel1,,oFont,,,,.T.,,,40,20)
    oGet1   := TGet():New(20,10,{|u| iif( Pcount()>0, cTGet1:= u,cTGet1 ) },oPanel1,40,10,,bVal1,,,,,,.T.)
    oGet1:cF3 := "SA1"

    oSay2   := TSay():New(35,10,{|| "Loja:"},oPanel1,,oFont,,,,.T.,,,40,20)
    oGet2   := TGet():New(45,10,{|u| iif( Pcount()>0, cTGet2:= u,cTGet2 ) },oPanel1,20,10,,,,,,,,.T.)
    oGet2:bChange := bCha1
    
    oSay3   := TSay():New(60,10,{|| "Nome:"},oPanel1,,oFont,,,,.T.,,,40,20)
    oGet3   := TGet():New(70,10,{|u| iif( Pcount()>0, cTGet3:= u,cTGet3 ) },oPanel1,100,10,,,,,,,,.T.)
    oGet3:lReadOnly := .T.

    oRadio := TRadMenu():New(10,150,aRadio,{|u|Iif(PCount()==0,nRadio,nRadio:=u)},oPanel1,,,,,,,,100,12,,,,.T.)
    //--------------------------------------------------------------------------------------------------------//

    //-----------------------------------------Financeiro-----------------------------------------------------//
    oSay4   := TSay():New(10,10,{|| "Saldo:"},oPanel2,,oFont,,,,.T.,,,40,20)
    oGet4   := TGet():New(20,10,{|u| iif( Pcount()>0, nTGet4:= u,nTGet4 ) },oPanel2,40,10,"@E 999,99",,,,,,,.T.)

    oSay5   := TSay():New(35,10,{|| "Validade do saldo:"},oPanel2,,oFont,,,,.T.,,,80,20)
    oGet5   := TGet():New(45,10,{|u| iif( Pcount()>0, dTGet5:= u,dTGet5 ) },oPanel2,40,10,,,,,,,,.T.)

    oCheck := TCheckBox():New(60,10,"Libera saldo",{|| lCheck },oPanel2,100,210,,,oFont,,,,,.T.)
    oCheck:bLClicked := {|| IIF(lCheck,lCheck := .F.,(lCheck := .T.,IIF(lCheck1,lCheck1 := .F.,nil)))}

    oCheck1 := TCheckBox():New(60,60,"Bloqueia saldo",{|| lCheck1 },oPanel2,100,210,,,oFont,,,,,.T.)
    oCheck1:bLClicked := {|| IIF(lCheck1,lCheck1 := .F.,(lCheck1 := .T.,IIF(lCheck,lCheck := .F.,nil)))}

    oSay6  := TSay():New(70,10,{|| "Compra a prazo?"},oPanel2,,oFont,,,,.T.,,,80,20)
    oCombo := TComboBox():New(80,10,{|u| iif( Pcount()>0, cCombo:= u,cCombo ) },aCombo,50,20,oPanel2,,,,,,.T.)
    oCombo:Select(2)
    //--------------------------------------------------------------------------------------------------------//

    oButton1 := TButton():New(220,135,"Confirma",oDlg,bButton1,50,20,,,,.T.)
    oButton2 := TButton():New(220,195,"Cancelar",oDlg,bButton2,50,20,,,,.T.)

    oDlg:Lcentered  := .T.
    oDlg:Activate()

Return

Static Function CONFIRMA()
    Local cMsg := ""

    cMsg += "Cliente " + Alltrim(cTGet3) + " possui um saldo no valor de "
    cMsg += TRANSFORM(nTGet4,"@E 999,99") + "R$" + " com validade a expirar no dia  " + DTOC(dTGet5)

    MsgInfo(cMsg,"CONFIRMA")
Return
