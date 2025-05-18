#include "protheus.ch"
#include "topconn.ch"
#include "totvs.ch"

User Function ALLCLIENTE()

Private lMsErroAuto := .F.

If !MsgYesNo("Confirma a operação de Cliente?", "Aviso")
    Return
Endif

cCodigo := "000004"
cLoja := "01"
cNome := "Cliente Teste do Lucas"
cEndereco := "Rua Teste"
cNomeFantasia := "Cliente Teste"
cTipo := "F"
cEstado := "SC"
cMunicipio := "Joinville"
cCgC := "42046013832"
lDeletar := .F.
nOpcAuto := IIf(lDeletar, 5, 3)

aArray := { { "A1_COD"      , cCodigo           , NIL },;
            { "A1_LOJA"     , cLoja             , NIL },;
            { "A1_NOME"     , cNome             , NIL },;
            { "A1_END"      , cEndereco         , NIL },;
            { "A1_NREDUZ"   , cNomeFantasia     , NIL },;
            { "A1_TIPO"     , cTipo             , NIL },;
            { "A1_EST"      , cEstado           , NIL },;
            { "A1_MUN"      , cMunicipio        , NIL },;
            { "A1_CGC"      , PadR(cCgC,TamSx3("A1_CGC")[1]) , NIL } }

DbSelectArea("SA1")
DbSetOrder(3)

If DbSeek( xFilial("SA1") + PadR(cCgC,TamSx3("A1_CGC")[1]) )
    If nOpcAuto <> 5  
        nOpcAuto := 4  
    Endif
Else
    If lDeletar
        MsgAlert("Cliente não encontrado para exclusão!", "Aviso")
        Return
    Else
        MsgAlert("Cliente não encontrado para alteração, será feita uma inclusão!", "Aviso")
    Endif
Endif

MsExecAuto( { |x,y,z| MATA030(x,y,z)}, aArray, nOpcAuto)  // 3 - Inclusão | 4 - Alteração | 5 - Exclusão

If lMsErroAuto
    MostraErro()
Else
    If nOpcAuto == 5
        MsgInfo("Cliente " + SE2->E2_NUM + " excluído com sucesso!", "Aviso")
    ElseIf nOpcAuto == 4
        MsgInfo("Cliente " + SE2->E2_NUM + " alterado com sucesso!", "Aviso")
    Else
        MsgInfo("Cliente " + SE2->E2_NUM + " incluído com sucesso!", "Aviso")
    EndIf
Endif            

Return
