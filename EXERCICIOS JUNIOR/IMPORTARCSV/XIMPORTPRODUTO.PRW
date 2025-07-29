#Include "TOTVS.ch"
#Include "TopConn.ch"

Static nPosCodigo  := 1
Static nPosDesc    := 2
Static nPosTipo    := 3
Static nPosUnidade := 4
Static nPosArmazem := 5

User Function XIMPORTPRODUTO()
    Local aArea      := GetArea()
    Local cArquivo   := "C:\report\import_produtos.csv"
    Local oArquivo
    Local cLinha     := ""
    Local aLinha     := {}
    Local nLinha     := 0

    Local cCod       := ""
    Local cDesc      := ""
    Local cTipo      := ""
    Local cUM        := ""
    Local cLocPad    := ""

    oArquivo := FWFileReader():New(cArquivo)

    If oArquivo:Open()
        While oArquivo:HasLine()
            nLinha++
            cLinha := oArquivo:GetLine()
            aLinha := StrTokArr(cLinha, ";")

            If nLinha == 1
                Loop
            EndIf

            cCod := AllTrim(aLinha[nPosCodigo])
            cDesc := AllTrim(aLinha[nPosDesc])
            cTipo := AllTrim(aLinha[nPosTipo])
            cUM := AllTrim(aLinha[nPosUnidade])
            cLocPad := AllTrim(aLinha[nPosArmazem])

            DbSelectArea("SB1")
            DbSetOrder(1)
            If DbSeek(xFilial("SB1") + PadR(cCod, TamSx3("B1_COD")[1]))
                MsgInfo("Linha " + cValToChar(nLinha) + ": Produto já existe com código " + cCod, "Aviso")
                Loop
            EndIf

            If __IncluiProduto(cCod, cDesc, cTipo, cUM, cLocPad, nLinha)
                MsgInfo("Linha " + cValToChar(nLinha) + ": Produto " + cDesc + " incluído com sucesso!", "Sucesso")
            Else
                MsgInfo("Linha " + cValToChar(nLinha) + ": ERRO ao incluir Produto " + cDesc, "Erro")
            EndIf

        EndDo
        oArquivo:Close()
    Else
        MsgStop("Erro ao abrir o arquivo CSV!", "Erro")
    EndIf

    RestArea(aArea)
Return

Static Function __IncluiProduto(cCod, cDesc, cTipo, cUM, cLocPad, nLinha)
    Local lDeuCerto := .F.
    Local oModel := FWLoadModel("MATA010")
    Local oSB1Mod   := Nil
    Local aErro     := {}

    oModel:SetOperation(3)
    oModel:Activate()

    oSB1Mod := oModel:GetModel("SB1MASTER")
    oSB1Mod:SetValue("B1_FILIAL" , xFilial("SB1"))
    oSB1Mod:SetValue("B1_COD"    , cCod      ) 
    oSB1Mod:SetValue("B1_DESC"   , cDesc     ) 
    oSB1Mod:SetValue("B1_TIPO"   , cTipo     ) 
    oSB1Mod:SetValue("B1_UM"     , cUM       ) 
    oSB1Mod:SetValue("B1_LOCPAD" , cLocPad   )

    If oModel:VldData()
        If oModel:CommitData()
            lDeuCerto := .T.
        EndIf
    EndIf

    If !lDeuCerto
        aErro := oModel:GetErrorMessage()
        MsgInfo( ;
            "Erro na linha " + cValToChar(nLinha) + CRLF + ;
            "Id do formulário de origem: " + cValToChar(aErro[1]) + CRLF + ;
            "Id do campo de origem: " + cValToChar(aErro[2]) + CRLF + ;
            "Id do formulário de erro: " + cValToChar(aErro[3]) + CRLF + ;
            "Id do campo de erro: " + cValToChar(aErro[4]) + CRLF + ;
            "Id do erro: " + cValToChar(aErro[5]) + CRLF + ;
            "Mensagem do erro: " + cValToChar(aErro[6]) + CRLF + ;
            "Mensagem da solução: " + cValToChar(aErro[7]) + CRLF + ;
            "Valor atribuído: " + cValToChar(aErro[8]) + CRLF + ;
            "Valor anterior: " + cValToChar(aErro[9]) ;
        )
        MostraErro()
    EndIf

    oModel:DeActivate()
Return lDeuCerto

