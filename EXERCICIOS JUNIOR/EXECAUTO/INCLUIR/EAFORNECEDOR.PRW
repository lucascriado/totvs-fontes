#include "protheus.ch"
#include "topconn.ch"
#include "totvs.ch"

User Function EAFORNECEDOR()

// RpcSetEnv("99", "01")

Private lMsErroAuto := .F.

If !MsgYesNo("Confirma a inclusão de um novo fornecedor ?","Aviso")
    Return
Endif

cCodigo := "000004"
cLoja := "01"
cRazao := "Fornecedor Teste"
cNomeFantasia := "Forn Teste"
cEndereco := "Rua Teste"
cEstado := "SC"
cMunicipio := "Joinville"
cTipo := "J"
cCgC := "12345678000195"

DbSelectArea("SA2")
DbSetOrder(3)
If DbSeek( xFilial("SA2") + PadR(cCgC ,TamSx3("A2_CGC")[1]) )
    MsgAlert("Fornecedor já cadastrado !","Aviso")
    Return
Endif

aArray := { { "A2_COD"      , cCodigo           , NIL },;
            { "A2_LOJA"     , cLoja             , NIL },;
            { "A2_NOME"     , cRazao            , NIL },;
            { "A2_NREDUZ"   , cNomeFantasia     , NIL },;
            { "A2_END"      , cEndereco         , NIL },;
            { "A2_EST"      , cEstado           , NIL },;
            { "A2_MUN"      , cMunicipio        , NIL },;
            { "A2_TIPO"     , cTipo             , NIL },;
            { "A2_CGC"      , PadR(cCgC ,TamSx3("A2_CGC")[1]), NIL } }

MsExecAuto( { |x,y| MATA020(x,y)} , aArray, 3)  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão

If lMsErroAuto

    MostraErro()

Else

    MsgInfo("Fornecedor "+SA2->A2_NREDUZ+" incluído com sucesso!","Aviso")

Endif            

Return
