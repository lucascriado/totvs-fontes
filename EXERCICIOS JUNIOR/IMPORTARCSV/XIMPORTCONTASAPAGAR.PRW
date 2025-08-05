#Include "TOTVS.ch"
#Include "TopConn.ch"

User Function XIMPORTCONTASAPAGAR()
    Local aVetSE2    := {}
    Local xFilial   := "01"
    Local cPrefixo  := "777"
    Local cNumero   := "000000007"
    Local cParcela  := "01"
    Local cTipo     := "NF"
    Local cNatureza := "001"
    Local cFornece  := "000123"
    Local cLoja     := "01"
    Local cNomFor   := "Fornecedor 1"
    Local dEmissao  := CToD("08/05/2025")
    Local dVencto   := CToD("08/05/2025")
    Local dVencReal := CToD("08/05/2025")
    Local nValor    := 5500

    Private lMsErroAuto := .F.

    Begin Transaction
        lMsErroAuto := .F.

        aAdd(aVetSE2, {"E2_FILIAL",  xFilial,    Nil})
        aAdd(aVetSE2, {"E2_NUM",     cNumero,    Nil})
        aAdd(aVetSE2, {"E2_PREFIXO", cPrefixo,   Nil})
        aAdd(aVetSE2, {"E2_PARCELA", cParcela,   Nil})
        aAdd(aVetSE2, {"E2_TIPO",    cTipo,      Nil})
        aAdd(aVetSE2, {"E2_NATUREZ", cNatureza,  Nil})
        aAdd(aVetSE2, {"E2_FORNECE", cFornece,   Nil})
        aAdd(aVetSE2, {"E2_LOJA",    cLoja,      Nil})
        aAdd(aVetSE2, {"E2_NOMFOR",  cNomFor,    Nil})
        aAdd(aVetSE2, {"E2_EMISSAO", dEmissao,   Nil})
        aAdd(aVetSE2, {"E2_VENCTO",  dVencto,    Nil})
        aAdd(aVetSE2, {"E2_VENCREA", dVencReal,  Nil})
        aAdd(aVetSE2, {"E2_VALOR",   nValor,     Nil})

        // Aqui agora está certo
        MSExecAuto({|a, b, c, d| FINA050(a, b, c, d)}, aVetSE2, {}, 3, .F.)

        If lMsErroAuto
            MostraErro()
            DisarmTransaction()
        Else
            MsgInfo("Conta a Pagar incluída com sucesso!")
        EndIf
    End Transaction

Return
