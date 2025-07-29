#Include "TOTVS.ch"
#Include "TopConn.ch"

Static nPosCodigo      := 1
Static nPosLoja        := 2
Static nPosRSocial     := 3
Static nPosNFantasia   := 4
Static nPosEnd         := 5
Static nPosNEst        := 6
Static nPosMunicipio   := 7
Static nPosCodMunicipio := 8
Static nPosTipo        := 9
Static nPosCgc         := 10

User Function XIMPORTFORNECEDOR()
    Local aArea      := GetArea()
    Local cArquivo   := "C:\report\import_fornecedores.csv"
    Local oArquivo
    Local cLinha     := ""
    Local aLinha     := {}
    Local nLinha     := 0

    Local cCodForn   := "" 
    Local cLojForn   := "" 
    Local cRazaoSocial := "" 
    Local cNomeFantasia := "" 
    Local cEndereco  := "" 
    Local cEstado  := "" 
    Local cMunicipio := ""
    Local cTipo  := "" 
    Local cCgc  := "" 

    oArquivo := FWFileReader():New(cArquivo)

    If oArquivo:Open()
        While oArquivo:HasLine()
            nLinha++
            cLinha := oArquivo:GetLine()
            aLinha := StrTokArr(cLinha, ";")

            If nLinha == 1
                Loop
            EndIf

            cCodForn     := AllTrim(aLinha[nPosCodigo])
            cLojForn     := AllTrim(aLinha[nPosLoja])
            cRazaoSocial := AllTrim(aLinha[nPosRSocial])
            cNomeFantasia:= AllTrim(aLinha[nPosNFantasia])
            cEndereco    := AllTrim(aLinha[nPosEnd])
            cMunicipio   := AllTrim(aLinha[nPosMunicipio])
            cCodigoMunicipio := AllTrim(aLinha[nPosCodMunicipio])
            cEstado      := AllTrim(aLinha[nPosNEst])
            cTipo        := AllTrim(aLinha[nPosTipo])
            cCgc         := AllTrim(aLinha[nPosCgc])

            DbSelectArea("SA2")
            DbSetOrder(3)
            If DbSeek(xFilial("SA2") + PadR(cCgc, TamSx3("A2_CGC")[1]))
                MsgInfo("Linha " + cValToChar(nLinha) + ": Fornecedor já existe com CGC " + cCgc, "Aviso")
                Loop
            EndIf

            If __IncluiFornecedor(cCodForn, cLojForn, cRazaoSocial, cNomeFantasia, cEndereco, cMunicipio, cEstado, cTipo, cCgc, nLinha)
                MsgInfo("Linha " + cValToChar(nLinha) + ": Fornecedor " + cNomeFantasia + " incluído com sucesso!", "Sucesso")
            Else
                MsgInfo("Linha " + cValToChar(nLinha) + ": ERRO ao incluir fornecedor " + cNomeFantasia, "Erro")
            EndIf

        EndDo
        oArquivo:Close()
    Else
        MsgStop("Erro ao abrir o arquivo CSV!", "Erro")
    EndIf

    RestArea(aArea)
Return

Static Function __IncluiFornecedor(cCod, cLoja, cNome, cNomeFant, cEndereco, cMunicipio, cCodigoMunicipio, cEstado, cTipo, cCgc, nLinha)
    Local lDeuCerto := .F.
    Local oModel    := FWLoadModel("MATA020M")
    Local oSA2Mod   := Nil
    Local aErro     := {}

    oModel:SetOperation(3)
    oModel:Activate()

    oSA2Mod := oModel:getModel("SA2MASTER")
    oSA2Mod:setValue("A2_FILIAL" , xFilial("SA2"))
    oSA2Mod:setValue("A2_COD"    , cCod       )
    oSA2Mod:setValue("A2_LOJA"   , cLoja      )
    oSA2Mod:setValue("A2_NOME"   , cNome      )
    oSA2Mod:setValue("A2_NREDUZ" , cNomeFant  )
    oSA2Mod:setValue("A2_END"    , cEndereco  )
    oSA2Mod:setValue("A2_EST"    , cEstado    )
    oSA2Mod:setValue("A2_COD_MUN", cCodigoMunicipio  )
    oSA2Mod:setValue("A2_MUN"    , cMunicipio  ) 
    oSA2Mod:setValue("A2_TIPO"   , cTipo      )
    oSA2Mod:setValue("A2_CGC"    , cCgc       )

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

