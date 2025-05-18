#Include "Protheus.ch"
#Include "Totvs.ch"

/*
Programa : XESTRU
Autor: Leandro Campos - Conti
Data: 24/03/2025
Descrição: Aula advpl I
Objetivo: Explicacao da estrutura de codigo ADVPL  
*/
User Function XESTRU()
    Local cVar      := "Texto da variavel"
    Local nVar      := 1
    Local dData     := Date()
    Local aArray    := {}
    Local bBloco    := {||}
    Local lLogica   := .T.
    Local oObjeto   

    Private cVar1

    cFuncao := XPARAM(@cVar,cVar1)

Return

Static function XPARAM(_cVar,_cVar1)

    Default _cVar := ""

    _cVar := "Texto trocado"
    _cVar1 := "Texto da Private"

Return
