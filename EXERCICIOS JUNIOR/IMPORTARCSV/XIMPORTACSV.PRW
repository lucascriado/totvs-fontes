//Bibliotecas
#Include "TOTVS.ch"
#Include "TopConn.ch"

// Posições do Array
Static nPosCodigo := 1 // Coluna A no CSV
Static nPosLojFor := 2 // Coluna B no CSV
Static nPosRazSoc := 3 // Coluna C no CSV
Static nPosObserv := 4 // Coluna D no CSV

User Function ImportaCSV()
    Local aArea     := GetArea()
    Local cArquivo  := "C:\report\compras_20250624194340.csv"
    Local oArquivo
    Local cLinha    := ""
    Local aLinha    := {}
    Local nLinha    := 0
    Local cCodForn  := ""
    Local cLojForn  := ""
    Local cRazaoSoc := ""
    Local cObserv   := ""

    oArquivo := FWFileReader():New(cArquivo)

    If oArquivo:Open()

        While oArquivo:HasLine()
            nLinha++
            cLinha := oArquivo:GetLine()
            aLinha := StrTokArr(cLinha, ";")

            If "código" $ Lower(cLinha)
                Loop
            EndIf

            cCodForn  := aLinha[nPosCodigo]
            cLojForn  := aLinha[nPosLojFor]
            cRazaoSoc := aLinha[nPosRazSoc]
            cObserv   := aLinha[nPosObserv]

            ConOut("Linha " + cValToChar(nLinha) + ": " + ;
                "CodForn: " + cCodForn + ", " + ;
                "Loja: " + cLojForn + ", " + ;
                "Razão: " + cRazaoSoc + ", " + ;
                "Obs: " + cObserv)
        EndDo

        oArquivo:Close()

    Else
        MsgStop("Erro ao abrir o arquivo CSV!", "Erro")
    EndIf

    RestArea(aArea)
Return
