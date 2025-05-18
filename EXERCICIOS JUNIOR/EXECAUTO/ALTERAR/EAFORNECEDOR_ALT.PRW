#include "protheus.ch"
#include "topconn.ch"
#include "totvs.ch"

User Function ALTFORNECEDOR()

// RpcSetEnv("99", "01")

Private lMsErroAuto := .F.
Private cOk := .F.

If !MsgYesNo("Confirma a alteração de um novo fornecedor ?","Aviso")
    Return
Endif

cCodigo := "000004"
cLoja := "01"
cRazao := "Fornecedor Alterado"
cNomeFantasia := "Forn Teste"
cEndereco := "Rua Teste"
cEstado := "SC"
cMunicipio := "Joinville"
cTipo := "J"
cCgC := "12345678000195"

DbSelectArea("SA2")
DbSetOrder(3)
If DbSeek( xFilial("SA2") + PadR(cCgC ,TamSx3("A2_CGC")[1]) )
    aArray := { { "A2_COD"      , cCodigo           , NIL },;
                { "A2_LOJA"     , cLoja             , NIL },;
                { "A2_NOME"     , cRazao            , NIL },;
                { "A2_NREDUZ"   , cNomeFantasia     , NIL },;
                { "A2_END"      , cEndereco         , NIL },;
                { "A2_EST"      , cEstado           , NIL },;
                { "A2_MUN"      , cMunicipio        , NIL },;
                { "A2_TIPO"     , cTipo             , NIL },;
                { "A2_CGC"      , PadR(cCgC ,TamSx3("A2_CGC")[1]), NIL } }

    MsExecAuto( { |x,y| MATA020(x,y)} , aArray, 4)  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão
    cOk := .T.
Else
    cOk := .F.    
Endif


If lMsErroAuto

    MostraErro()

Else
    If cOk
        MsgInfo("Fornecedor "+SA2->A2_NREDUZ+" alterado com sucesso!","Aviso")
    Else
        MsgStop("Fornecedor não encontrado!","Erro")
    Endif
Endif        

Return
