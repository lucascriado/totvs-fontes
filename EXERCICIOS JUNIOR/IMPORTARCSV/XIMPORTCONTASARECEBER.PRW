#Include "TOTVS.ch"
#Include "TopConn.ch"

User Function XIMPORTRECEBER()
    Local cArquivo := "C:\report\import_contasreceber.csv"
    Local oArquivo := FWFileReader():New(cArquivo)
    Local aLinha, cLinha, nLinha := 0
    Local aVetSE1
    Private lMsErroAuto := .F.

    If oArquivo:Open()
        While oArquivo:HasLine()
            nLinha++
            cLinha := oArquivo:GetLine()

            If nLinha == 1
                Loop
            EndIf

            aLinha := StrTokArr(cLinha, ";")
            aVetSE1 := {}


            Begin Transaction
                lMsErroAuto := .F.

                aAdd(aVetSE1, {"E1_FILIAL",  aLinha[1], Nil})
                aAdd(aVetSE1, {"E1_NUM",     aLinha[2], Nil})
                aAdd(aVetSE1, {"E1_PREFIXO", aLinha[3], Nil})
                aAdd(aVetSE1, {"E1_PARCELA", aLinha[4], Nil})
                aAdd(aVetSE1, {"E1_TIPO",    aLinha[5], Nil})
                aAdd(aVetSE1, {"E1_NATUREZ", aLinha[6], Nil})
                aAdd(aVetSE1, {"E1_CLIENTE", aLinha[7], Nil})
                aAdd(aVetSE1, {"E1_LOJA",    aLinha[8], Nil})
                aAdd(aVetSE1, {"E1_NOMCLI",  aLinha[9], Nil})
                aAdd(aVetSE1, {"E1_EMISSAO", CToD(aLinha[10]), Nil})
                aAdd(aVetSE1, {"E1_VENCTO",  CToD(aLinha[11]), Nil})
                aAdd(aVetSE1, {"E1_VENCREA", CToD(aLinha[12]), Nil})
                aAdd(aVetSE1, {"E1_VALOR",   Val(aLinha[13]), Nil})

                MSExecAuto({|a, b| FINA040(a, b)}, aVetSE1, 3)

                If lMsErroAuto
                    MostraErro()
                    DisarmTransaction()
                Else
                    MsgInfo("Conta a Receber incluída com sucesso! Num: " + aLinha[2])
                EndIf
            End Transaction
        EndDo
        oArquivo:Close()
    Else
        MsgInfo("Erro ao abrir o arquivo: " + cArquivo)
    EndIf

Return
