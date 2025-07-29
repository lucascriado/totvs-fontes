#Include "TOTVS.ch"
#Include "TopConn.ch"

Static nPosCodigo   := 1
Static nPosLoja     := 2
Static nPosNome     := 3
Static nPosPessoa   := 4
Static nPosEnd      := 5
Static nPosNFant    := 6
Static nPosTipo     := 7
Static nPosEstado   := 8
Static nPosMunicip  := 9
Static nPosCGC      := 10

User Function XIMPORTCLIENTE()
    Local aArea      := GetArea()
    Local cArquivo   := "C:\report\import_clientes.csv"
    Local oArquivo
    Local cLinha     := ""
    Local aLinha     := {}
    Local nLinha     := 0

    Local cCodCli   := ""
    Local cLojCli   := ""
    Local cNome      := ""
    Local cPessoa    := ""
    Local cEndereco  := ""
    Local cFantasia  := ""
    Local cTipo      := ""
    Local cEstado    := ""
    Local cMunicipio := ""
    Local cCGC       := ""

    oArquivo := FWFileReader():New(cArquivo)

    If oArquivo:Open()
        While oArquivo:HasLine()
            nLinha++
            cLinha := oArquivo:GetLine()
            aLinha := StrTokArr(cLinha, ";")

            If nLinha == 1
                Loop
            EndIf

            cCodCli   := AllTrim(aLinha[nPosCodigo])
            cLojCli   := AllTrim(aLinha[nPosLoja])
            cNome      := AllTrim(aLinha[nPosNome])
            cPessoa    := AllTrim(aLinha[nPosPessoa])
            cEndereco  := AllTrim(aLinha[nPosEnd])
            cFantasia  := AllTrim(aLinha[nPosNFant])
            cTipo      := AllTrim(aLinha[nPosTipo])
            cEstado    := AllTrim(aLinha[nPosEstado])
            cMunicipio := AllTrim(aLinha[nPosMunicip])
            cCGC       := AllTrim(aLinha[nPosCGC])

            DbSelectArea("SA1")
            DbSetOrder(3)
            If DbSeek(xFilial("SA1") + PadR(cCGC, TamSx3("A1_CGC")[1]))
                MsgInfo("Linha " + cValToChar(nLinha) + ": Cliente já existe com CGC " + cCGC, "Aviso")
                Loop
            EndIf

            aArray := { ;
                { "A1_COD"    , cCodCli                                , NIL }, ;
                { "A1_LOJA"   , cLojCli                                , NIL }, ;
                { "A1_NOME"   , cNome                                   , NIL }, ;
                { "A1_END"    , cEndereco                               , NIL }, ;
                { "A1_NREDUZ" , cFantasia                               , NIL }, ;
                { "A1_TIPO"   , cTipo                                   , NIL }, ;
                { "A1_EST"    , cEstado                                 , NIL }, ;
                { "A1_MUN"    , cMunicipio                              , NIL }, ;
                { "A1_PESSOA" , cPessoa                                 , NIL }, ;
                { "A1_CGC"    , PadR(cCGC, TamSx3("A1_CGC")[1])         , NIL } ;
            }

            If MsExecAuto({|x,y| MATA030(x,y)}, aArray, 3)
                MsgInfo("Linha " + cValToChar(nLinha) + ": Cliente " + cFantasia + " incluído com sucesso!", "Sucesso")
            Else
                MostraErro()
                MsgInfo("Linha " + cValToChar(nLinha) + ": ERRO ao incluir cliente " + cCodForn, "Erro")
            EndIf
        EndDo

        oArquivo:Close()
    Else
        MsgStop("Erro ao abrir o arquivo CSV!", "Erro")
    EndIf

    RestArea(aArea)
Return
