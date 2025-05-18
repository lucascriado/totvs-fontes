#Include "Protheus.Ch"
//Exemplo de funções de posicionamento em tabela
User Function XPOSTAB()
    Local aArea     := GetArea()
    Local cCodCli   := "CLI01"

    If Len(cCodCli) <> TamSx3("A1_COD")[1]
        cCodCli := PadR(cCodCli,TamSx3("A1_COD")[1])
    Endif
    
    DbSelectArea("SA1")
    SA1->(DbSetOrder(1))

    SA1->(DbGoTop())
    If DbSeek(xFilial("SA1") + cCodCli + "01")
        MsgInfo("Encontrou")
    Else
        Alert("Nao encontrou")
    Endif

    RestArea(aArea)
Return

//Exemplo de estrutura de leitura de tabela
User Function XLETAB()
    Local cMsg := ""

    DbSelectArea("SA1")
    SA1->(DbSetOrder(1))
    SA1->(DbGoTop())

    While !SA1->(EOF())
        cMsg += "Codigo: " + SA1->A1_COD + CRLF
        cMsg += "Nome: " + SA1->A1_NOME + CRLF
        cMsg += "--------------------------------------------------------"
        cMsg += CRLF

        SA1->(DbSkip())
    Enddo

    MsgInfo(cMsg)

    SA1->(DbCloseArea())
Return

//Funcoes que retornam dados de uma tabela ou se o registro existe
User Function XPOSI()

    cPos:= Posicione("SA1",1,xFilial("SA1") + "CLI01 " + "01","A1_NOME")

    MsgInfo(cPos)

    ExistCpo("SA1", "000002" + "06")

Return
