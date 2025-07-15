#Include "Protheus.Ch"
#Include "Totvs.ch"
#Include "Colors.ch"

User Function XTELA_JUST()
    Local oDlg
    Local oSay
    Local oGet
    Local oButton1, oButton2
    Local cJustificativa := Space(100) 
    
    DEFINE DIALOG oDlg FROM 0,0 TO 400,600 TITLE "Justificativa" PIXEL

    @ 1,1 SAY oSay VAR "Justificativa:" OF oDlg PIXEL

    @ 10,1 GET oGet VAR cJustificativa SIZE 300,100 MULTILINE OF oDlg PIXEL

    @ 120,1 BUTTON oButton1 PROMPT "Confirmar" ACTION (oDlg:End()) SIZE 50,20 OF oDlg PIXEL
    @ 120,60 BUTTON oButton2 PROMPT "Cancelar" ACTION (oDlg:End()) SIZE 50,20 OF oDlg PIXEL

    ACTIVATE DIALOG oDlg CENTERED

Return
