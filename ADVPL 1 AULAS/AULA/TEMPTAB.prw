#Include "Protheus.Ch"

User Function XTMPTAB()
	Local aCampos := {}
	Local aDados  := {{"000001","REGISTRO 01"},;
		              {"000002","REGISTRO 02"}}
    Local cFile
    Local nI
    Local cMsg := ""
    
    aAdd(aCampos,{'MP_COD'  ,'C' ,6,0})
    aAdd(aCampos,{'MP_DESC' ,'C' ,50,0})

    cFile := CRIATRAB(aCampos,.T.)

    If Select("TMP") > 0
        TMP->(DbCloseArea())
    ENdif

    dbUseArea(.T.,"TOPCCON",cFile,"TMP",.F.,.F.)

    DbSelectArea("TMP")
    INDREGUA("TMP","INDMP","MP_COD",,,"Criando indice...")

    For nI := 1 To Len(aDados)
        RecLock("TMP",.T.)
        TMP->MP_COD     := aDados[nI][1]
        TMP->MP_DESC    := aDados[nI][2]
        TMP->(MsUnlock())
    Next

    TMP->(DbGoTop())
    While !TMP->(EOF())
        cMsg +="Codigo: "    +  TMP->MP_COD  + CRLF
        cMsg +="Descricao: " +  TMP->MP_DESC + CRLF
        cMsg +="------------------------------------------------------" + CRLF

        TMP->(DbSkip())
    Enddo

    TMP->(DbCloseArea())

    MsgInfo(cMsg)

Return
