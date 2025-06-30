#Include "protheus.ch"
#Include "topconn.ch"

User Function XPCOMPRA()

    Local cQuery   := ""
    Local aDados   := {}
    Local dDataIni := Ctod("")
    Local dDataFim := Ctod("")
    Local cDir     := ""
    Local cArq     := ""
    Local nHandle  := 0
    Local cLinha   := ""
    Local i        := 0

    Pergunte("XCOMPRAS")
    
    dDataIni := MV_PAR01
    dDataFim := MV_PAR02
    cDir     := AllTrim(MV_PAR03)

    cQuery := "SELECT "
    cQuery += "SD1.D1_EMISSAO, "
    cQuery += "SA2.A2_COD, SA2.A2_NOME, "
    cQuery += "SC1.C1_NUM, SC1.C1_ITEM, "
    cQuery += "SB1.B1_COD, SB1.B1_DESC, SC1.C1_QUANT, "
    cQuery += "SC7.C7_NUM, SC7.C7_ITEM, SC7.C7_QUANT, SC7.C7_PRECO, SC7.C7_TOTAL, "
    cQuery += "SF1.F1_DOC, SF1.F1_SERIE, "
    cQuery += "SD1.D1_QUANT, SD1.D1_VUNIT, SD1.D1_TOTAL "
    cQuery += "FROM " + RetSqlName("SD1") + " SD1 "
    cQuery += "INNER JOIN " + RetSqlName("SF1") + " SF1 ON SF1.F1_FILIAL = SD1.D1_FILIAL AND SF1.F1_DOC = SD1.D1_DOC AND SF1.F1_SERIE = SD1.D1_SERIE AND SF1.F1_FORNECE = SD1.D1_FORNECE AND SF1.F1_LOJA = SD1.D1_LOJA "
    cQuery += "LEFT JOIN " + RetSqlName("SC7") + " SC7 ON SC7.C7_FILIAL = SD1.D1_FILIAL AND SC7.C7_NUM = SD1.D1_PEDIDO AND SC7.C7_ITEM = SD1.D1_ITEMPC " // SC7.D_E_L_E_T_ <> '*'
    cQuery += "LEFT JOIN " + RetSqlName("SC1") + " SC1 ON SC1.C1_FILIAL = SC7.C7_FILIAL AND SC1.C1_NUM = SC7.C7_NUMSC AND SC1.C1_ITEM = SC7.C7_ITEMSC "
    cQuery += "INNER JOIN " + RetSqlName("SA2") + " SA2 ON SA2.A2_FILIAL = '"+xFilial("SA2")+"' AND SA2.A2_COD = SD1.D1_FORNECE AND SA2.A2_LOJA = SD1.D1_LOJA "
    cQuery += "INNER JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND SB1.B1_COD = SD1.D1_COD "
    cQuery += "WHERE "
    cQuery += "SB1.D_E_L_E_T_ <> '*' AND "
    cQuery += "SD1.D_E_L_E_T_ <> '*' AND "
    cQuery += "(SC7.D_E_L_E_T_ <> '*' OR SC7.C7_NUM IS NULL) AND "
    cQuery += "(SC1.D_E_L_E_T_ <> '*' OR SC1.C1_NUM IS NULL) AND "
    cQuery += "SD1.D1_FILIAL = '01' AND "
    cQuery += "SD1.D1_EMISSAO BETWEEN '" + DtoS(dDataIni) + "' AND '" + DtoS(dDataFim) + "' "

    If Select("EXDADOS") > 0
        EXDADOS->(DbCloseArea())
    EndIf

    TCQUERY cQuery NEW ALIAS "EXDADOS"

    If !EXDADOS->(Eof())
        While !EXDADOS->(Eof())
            aAdd(aDados, { ;
                EXDADOS->D1_EMISSAO, ;
                EXDADOS->A2_COD, ;
                EXDADOS->A2_NOME, ;
                EXDADOS->C1_NUM, ;
                EXDADOS->C1_ITEM, ;
                EXDADOS->B1_COD, ;
                EXDADOS->B1_DESC, ;
                EXDADOS->C1_QUANT, ;
                EXDADOS->C7_NUM, ;
                EXDADOS->C7_ITEM, ;
                EXDADOS->C7_QUANT, ;
                EXDADOS->C7_PRECO, ;
                EXDADOS->C7_TOTAL, ;
                EXDADOS->F1_DOC, ;
                EXDADOS->F1_SERIE, ;
                EXDADOS->D1_QUANT, ;
                EXDADOS->D1_VUNIT, ;
                EXDADOS->D1_TOTAL ;
            })
            EXDADOS->(DbSkip())
        EndDo
    Else
        MsgInfo("Nenhum registro encontrado no período informado.")
        Return
    EndIf

    cArq := cDir + "\compras_" + FWTimeStamp(1) + ".csv"

    nHandle := FCreate(cArq, 0)

    FWrite(nHandle, "Emissao;Cod Forn;Nome Forn;Num SC;Item SC;Cod Produto;Desc Produto;Qtd SC;Num C7;Item C7;Qtd C7;Preco;Total;Doc;Serie;Qtd NF;Vlr Unit;Vlr Total" + CRLF)

    For i := 1 To Len(aDados)
        cLinha := ""
        cLinha += aDados[i][1] + ";"
        cLinha += AllTrim(aDados[i][2]) + ";"
        cLinha += AllTrim(aDados[i][3]) + ";"
        cLinha += AllTrim(aDados[i][4]) + ";"
        cLinha += AllTrim(aDados[i][5]) + ";"
        cLinha += AllTrim(aDados[i][6]) + ";"
        cLinha += AllTrim(aDados[i][7]) + ";"
        cLinha += cValToChar(aDados[i][8]) + ";"
        cLinha += AllTrim(aDados[i][9]) + ";"
        cLinha += AllTrim(aDados[i][10]) + ";"
        cLinha += cValToChar(aDados[i][11]) + ";"
        cLinha += cValToChar(aDados[i][12]) + ";"
        cLinha += cValToChar(aDados[i][13]) + ";"
        cLinha += AllTrim(aDados[i][14]) + ";"
        cLinha += AllTrim(aDados[i][15]) + ";"
        cLinha += cValToChar(aDados[i][16]) + ";"
        cLinha += cValToChar(aDados[i][17]) + ";"
        cLinha += cValToChar(aDados[i][18])
        FWrite(nHandle, cLinha + CRLF)
    Next

    FClose(nHandle)

    MsgInfo("Arquivo CSV gerado com sucesso em:" + CRLF + cArq)

Return


// cQuery := "SELECT "
//     cQuery += "SD1.D1_EMISSAO, "
//     cQuery += "SA2.A2_COD, SA2.A2_NOME, "
//     cQuery += "SC1.C1_NUM, SC1.C1_ITEM, "
//     cQuery += "SB1.B1_COD, SB1.B1_DESC, SC1.C1_QUANT, "
//     cQuery += "SC7.C7_NUM, SC7.C7_ITEM, SC7.C7_QUANT, SC7.C7_PRECO, SC7.C7_TOTAL, "
//     cQuery += "SF1.F1_DOC, SF1.F1_SERIE, "
//     cQuery += "SD1.D1_QUANT, SD1.D1_VUNIT, SD1.D1_TOTAL "
//     cQuery += "FROM " + RetSqlName("SD1") + " SD1 "
//     cQuery += "INNER JOIN " + RetSqlName("SF1") + " SF1 ON SF1.F1_FILIAL = SD1.D1_FILIAL AND SF1.F1_DOC = SD1.D1_DOC AND SF1.F1_SERIE = SD1.D1_SERIE AND SF1.F1_FORNECE = SD1.D1_FORNECE AND SF1.F1_LOJA = SD1.D1_LOJA "
//     cQuery += "INNER JOIN " + RetSqlName("SC7") + " SC7 ON SC7.C7_FILIAL = SD1.D1_FILIAL AND SC7.C7_NUM = SD1.D1_PEDIDO AND SC7.C7_ITEM = SD1.D1_ITEMPC "
//     cQuery += "INNER JOIN " + RetSqlName("SC1") + " SC1 ON SC1.C1_FILIAL = SC7.C7_FILIAL AND SC1.C1_NUM = SC7.C7_NUMSC AND SC1.C1_ITEM = SC7.C7_ITEMSC "
//     cQuery += "INNER JOIN " + RetSqlName("SA2") + " SA2 ON SA2.A2_FILIAL = '"+xFilial("SA2")+"' AND SA2.A2_COD = SD1.D1_FORNECE AND SA2.A2_LOJA = SD1.D1_LOJA "
//     cQuery += "INNER JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND SB1.B1_COD = SD1.D1_COD "
//     cQuery += "WHERE "
//     cQuery += "SB1.D_E_L_E_T_ <> '*' AND "
//     cQuery += "SD1.D_E_L_E_T_ <> '*' AND "
//     cQuery += "SC7.D_E_L_E_T_ <> '*' AND "
//     cQuery += "SC1.D_E_L_E_T_ <> '*' AND "
//     cQuery += "SC1.C1_FILIAL = SD1.D1_FILIAL AND "
//     cQuery += "SC1.C1_FILIAL = SC7.C7_FILIAL AND "
//     cQuery += "SD1.D1_FILIAL = '01' AND "
//     cQuery += "SD1.D1_EMISSAO BETWEEN '" + DtoS(dDataIni) + "' AND '" + DtoS(dDataFim) + "' "
