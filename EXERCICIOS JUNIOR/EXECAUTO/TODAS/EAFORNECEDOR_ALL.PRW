#include "protheus.ch"
#include "topconn.ch"
#include "totvs.ch"

User Function ALLFORNECEDOR()

Private lMsErroAuto := .F.

If !MsgYesNo("Confirma a operação de Fornecedor?", "Aviso")
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
lDeletar := .F.
nOpcAuto := IIf(lDeletar, 5, 3)

aArray := { { "A2_COD"      , cCodigo           , NIL },;
            { "A2_LOJA"     , cLoja             , NIL },;
            { "A2_NOME"     , cRazao            , NIL },;
            { "A2_NREDUZ"   , cNomeFantasia     , NIL },;
            { "A2_END"      , cEndereco         , NIL },;
            { "A2_EST"      , cEstado           , NIL },;
            { "A2_MUN"      , cMunicipio        , NIL },;
            { "A2_TIPO"     , cTipo             , NIL },;
            { "A2_CGC"      , cCgC              , NIL } }

DbSelectArea("SA2")
DbSetOrder(3)

If DbSeek( xFilial("SA2") + PadR(cCgC ,TamSx3("A2_CGC")[1]) )
    If nOpcAuto <> 5
        nOpcAuto := 4
    Endif
Else
    If lDeletar
        MsgAlert("Fornecedor não encontrado para exclusão!", "Aviso")
        Return
    Else
        MsgAlert("Fornecedor não encontrado para alteração!", "Aviso")
        Return
    Endif
Endif

MsExecAuto( { |x,y,z| MATA020(x,y,z)}, aArray, nOpcAuto)  // 3 - Inclusão | 4 - Alteração | 5 - Exclusão

If lMsErroAuto
    MostraErro()
Else
    If nOpcAuto == 5
        MsgInfo("Fornecedor " + SE2->E2_NUM + " excluído com sucesso!", "Aviso")
    ElseIf nOpcAuto == 4
        MsgInfo("Fornecedor " + SE2->E2_NUM + " alterado com sucesso!", "Aviso")
    Else
        MsgInfo("Fornecedor " + SE2->E2_NUM + " incluído com sucesso!", "Aviso")
    EndIf
Endif            

Return
