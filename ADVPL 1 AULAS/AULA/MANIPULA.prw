#Include "Protheus.ch"
User Function XMANI()
    Local cVar01 := "50 LEANDRO CAMPOS"
    Local cVar02 := "TEXTO"
    Local nVar01 := 574

    //Tranforma carctere em numerico
    cResult := VAL(cVar01) + 100
    //Retorna parte de um texto
    cSub    := SUBSTR(cVar01,4,7)
    //Retorna conteudo apartir de esquerda ou direita
    cLeft   := LEFT(cVar01,2)
    cRight  := RIGHT(cVar01,6)
    
    //adiciona espaco ou dado em um string a esquerda ou direita
    cPadc := PADC(cVar02,10,"-")
    cPadl := PADR(cVar02,10)
    cPadr := PADL(cVar02,10,"-")

    //funcoes que limpam espacos
    cAllT := Alltrim("      ESPACO             ")
    cLTri := LTRIM("      ESPACO             ")
    cRTri := RTRIM("      ESPACO             ")

    //aplica uma mascara
    cTrans := TRANSFORM(nVar01,"@E 99,999.99")

Return
