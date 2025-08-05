#Include "TOTVS.ch"
#Include "TopConn.ch"

User Function XIMPORTRECEBER()
    Local aVetSE1    := {}
    Local xFilial   := "01"
    Local cPrefixo  := "777"
    Local cNumero   := "88888"
    Local cParcela  := "01"
    Local cTipo     := "NF"
    Local cNatureza := "001"
    Local cCliente  := "000003"
    Local cLoja     := "01"
    Local cNomCli   := "MARCOS DA SILVA"
    Local dEmissao  := CToD("08/05/2025")
    Local dVencto   := CToD("08/05/2025")
    Local dVencReal := CToD("08/05/2025")
    Local nValor    := 5500

    Private lMsErroAuto := .F.

    Begin Transaction

        aAdd(aVetSE1, {"E1_FILIAL",  xFilial,    Nil})
        aAdd(aVetSE1, {"E1_NUM",     cNumero,    Nil})
        aAdd(aVetSE1, {"E1_PREFIXO", cPrefixo,   Nil})
        aAdd(aVetSE1, {"E1_PARCELA", cParcela,   Nil})
        aAdd(aVetSE1, {"E1_TIPO",    cTipo,      Nil})
        aAdd(aVetSE1, {"E1_NATUREZ", cNatureza,  Nil})
        aAdd(aVetSE1, {"E1_CLIENTE", cCliente,   Nil})
        aAdd(aVetSE1, {"E1_LOJA",    cLoja,      Nil})
        aAdd(aVetSE1, {"E1_NOMCLI",  cNomCli,    Nil})
        aAdd(aVetSE1, {"E1_EMISSAO", dEmissao,   Nil})
        aAdd(aVetSE1, {"E1_VENCTO",  dVencto,    Nil})
        aAdd(aVetSE1, {"E1_VENCREA", dVencReal,  Nil})
        aAdd(aVetSE1, {"E1_VALOR",   nValor,     Nil})
        
        MSExecAuto({|x,y| FINA040(x,y)}, aVetSE1, 3)

        If lMsErroAuto
            MostraErro()
            DisarmTransaction()
        Else
            MsgInfo("Conta a Receber incluída com sucesso!")
        EndIf
    End Transaction

Return
