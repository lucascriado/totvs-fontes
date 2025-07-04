#include "protheus.ch"
#include "topconn.ch"
#include "totvs.ch"

User Function ALLCLIENTE()

Private lMsErroAuto := .F.

If !MsgYesNo("Confirma a opera��o de Cliente?", "Aviso")
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
        MsgAlert("Cliente n�o encontrado para exclus�o!", "Aviso")
        Return
    Else
        MsgAlert("Cliente n�o encontrado para altera��o, ser� feita uma inclus�o!", "Aviso")
    Endif
Endif

MsExecAuto( { |x,y,z| MATA030(x,y,z)}, aArray, nOpcAuto)  // 3 - Inclus�o | 4 - Altera��o | 5 - Exclus�o

If lMsErroAuto
    MostraErro()
Else
    If nOpcAuto == 5
        MsgInfo("Cliente " + SE2->E2_NUM + " exclu�do com sucesso!", "Aviso")
    ElseIf nOpcAuto == 4
        MsgInfo("Cliente " + SE2->E2_NUM + " alterado com sucesso!", "Aviso")
    Else
        MsgInfo("Cliente " + SE2->E2_NUM + " inclu�do com sucesso!", "Aviso")
    EndIf
Endif            

Return
