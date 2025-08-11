#Include "TOTVS.ch"
#Include "TopConn.ch"

User Function XIMPORTCONTASAPAGAR()
    Local cArquivo := "C:\report\import_contasapagar.csv"
    Local oArquivo := FWFileReader():New(cArquivo)
    Local aLinha, cLinha, nLinha := 0
    Local aVetSE2
    Private lMsErroAuto := .F.

    If oArquivo:Open()
        While oArquivo:HasLine()
            nLinha++
            cLinha := oArquivo:GetLine()

            If nLinha == 1
                Loop
            EndIf

            aLinha := StrTokArr(cLinha, ";")
            aVetSE2 := {}


            Begin Transaction
                lMsErroAuto := .F.

                aAdd(aVetSE2, {"E2_FILIAL",  xFilial("SE2"), Nil})
                aAdd(aVetSE2, {"E2_NUM",     aLinha[2], Nil})
                aAdd(aVetSE2, {"E2_PREFIXO", aLinha[3], Nil})
                aAdd(aVetSE2, {"E2_PARCELA", aLinha[4], Nil})
                aAdd(aVetSE2, {"E2_TIPO",    aLinha[5], Nil})
                aAdd(aVetSE2, {"E2_NATUREZ", aLinha[6], Nil})
                aAdd(aVetSE2, {"E2_FORNECE", aLinha[7], Nil})
                aAdd(aVetSE2, {"E2_LOJA",    aLinha[8], Nil})
                aAdd(aVetSE2, {"E2_NOMFOR",  aLinha[9], Nil})
                aAdd(aVetSE2, {"E2_EMISSAO", CToD(aLinha[10]), Nil})
                aAdd(aVetSE2, {"E2_VENCTO",  CToD(aLinha[11]), Nil})
                aAdd(aVetSE2, {"E2_VENCREA", CToD(aLinha[12]), Nil})
                aAdd(aVetSE2, {"E2_VALOR",   Val(aLinha[13]), Nil})

                MSExecAuto({|a, b, c, d| FINA050(a, b, c, d)}, aVetSE2, {}, 3, .F.)

                If lMsErroAuto
                    MostraErro()
                    DisarmTransaction()
                Else
                    MsgInfo("Conta a Pagar incluída com sucesso! Num: " + aLinha[2])
                EndIf
            End Transaction
        EndDo
        oArquivo:Close()
    Else
        MsgInfo("Erro ao abrir o arquivo: " + cArquivo)
    EndIf

Return
