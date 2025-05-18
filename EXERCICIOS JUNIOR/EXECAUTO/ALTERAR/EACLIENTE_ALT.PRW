#include "protheus.ch"
#include "topconn.ch"
#include "totvs.ch"

User Function ALTEACLIENTE()
// RpcSetEnv("99", "01")

Private lMsErroAuto := .F.
Private cOk := .F.

If !MsgYesNo("Confirma a alteração de um cliente ?","Aviso")
    Return
Endif

cCodigo := "000004"
cLoja := "01"
cNome := "Cliente Alterado Teste"
cEndereco := "Rua Teste"
cNomeFantasia := "Cliente Teste"
cTipo := "F"
cEstado := "SC"
cMunicipio := "Joinville"
cCgC := "42046013832"

DbSelectArea("SA1")
DbSetOrder(3)
If DbSeek( xFilial("SA1") + PadR(cCgC,TamSx3("A1_CGC")[1]) )
    
    aArray := { { "A1_COD"      , cCodigo           , NIL },;
                { "A1_LOJA"     , cLoja             , NIL },;
                { "A1_NOME"     , cNome             , NIL },;
                { "A1_LOJA"     , cLoja             , NIL },;
                { "A1_END"      , cEndereco         , NIL },;
                { "A1_NREDUZ"   , cNomeFantasia     , NIL },;
                { "A1_TIPO"     , cTipo             , NIL },;
                { "A1_EST"      , cEstado           , NIL },;
                { "A1_MUN"      , cMunicipio        , NIL },;
                { "A1_CGC"      , PadR(cCgC,TamSx3("A1_CGC")[1]), NIL } }

    MsExecAuto( { |x,y| MATA030(x,y)} , aArray, 4)  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão
    cOk := .T.
Else
    cOk := .F.    
Endif

If lMsErroAuto

    MostraErro()

Else
    If cOk
        MsgInfo("Cliente "+SA1->A1_NREDUZ+" alterado com sucesso!","Aviso")
    Else
        MsgStop("Cliente não encontrado!","Erro")
    Endif 
Endif            

Return
