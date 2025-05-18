#include "protheus.ch"
#include "restful.ch"
WSRESTFUL CONSULTA_ARQUIVOS DESCRIPTION "Webservice Consulta Arquivos" FORMAT APPLICATION_JSON

    WSMETHOD GET V1 DESCRIPTION "Consulta Arquivos" PATH "/V1/Arquivos/{CGC}" WSSYNTAX "/V1/Arquivos/{CGC}" TTALK "V1"

END WSRESTFUL    

WSMETHOD GET V1 WSSERVICE CONSULTA_ARQUIVOS

Local lRet     := .T.
Local oJsonRet := JsonObject():New()
//Local oJsonCli := Nil
Local oJsonArquivo := Nil
Local oJsonArquivoFinal := Nil
Local aDocumentos   := {}
Local aArquivoFinal := {}
Local lTudOk := .F.
Local cCgc := self:aUrlParms[3]
Local cCodEnt := ""
//Local cCodObj := Array(0)
//Local cFormattedList := ""
//Local cFormatted := ""
//Local cArquivo := ""

DbSelectArea("SA1")
DbSetOrder(3)
If DbSeek( xFilial("SA1") + cCgc )

    cCodEnt := AllTrim(SA1->(A1_COD+A1_LOJA))

    DbSelectArea("AC9")
    DbSetOrder(2)
    If DbSeek( xFilial("AC9") + "SA1" + xFilial("SA1") + PadR(cCodEnt,70) )
        While !Eof() .And. AC9->(AC9_FILIAL+AC9_ENTIDA+AC9_FILENT+AC9_CODENT) == xFilial("AC9") + "SA1" + xFilial("SA1") + PadR(cCodEnt,70)
            
            DbSelectArea("ACB")
            DbSetOrder(1)
            If DbSeek( xFilial("ACB") + AC9->AC9_CODOBJ )

                lTudOk := .T.

                oJsonArquivo := JsonObject():New()
                oJsonArquivo["codobj"]  := AllTrim(AC9->AC9_CODOBJ)
                oJsonArquivo["objeto"]  := AllTrim(ACB->ACB_OBJETO)
                oJsonArquivo["descobj"] := AllTrim(ACB->ACB_DESCRI)
                
                cArquivo := AllTrim(ACB->ACB_OBJETO)
                cArqDir := "\dirdoc\co99\shared\" + cArquivo
                cArquivoBase64 := u_zFile64(cArqDir)
                oJsonArquivo["base64"] := cArquivoBase64 

                AAdd(aDocumentos, oJsonArquivo)
                FreeObj(oJsonArquivo)

            Endif
            
            DbSelectArea("AC9")
            AC9->(DbSkip())
        Enddo

        If lTudOk

            oJsonArquivoFinal := JsonObject():New()
            oJsonArquivoFinal["codigo"] := AllTrim(SA1->A1_COD)
            oJsonArquivoFinal["loja"]   := AllTrim(SA1->A1_LOJA)
            oJsonArquivoFinal["nome"]   := AllTrim(SA1->A1_NOME)
            oJsonArquivoFinal["docs"]   := aDocumentos

            AAdd(aArquivoFinal, oJsonArquivoFinal)
            FreeObj(oJsonArquivoFinal)

        Endif

    Endif

Endif

/*
cAliasCli := GetNextAlias()
If Select(cAliasCli) > 0
    (cAliasCli)->(DbCloseArea())
Endif

BeginSql Alias cAliasCli
    SELECT 
        SA1.R_E_C_N_O_ AS REC_SA1
    FROM
        %Table:SA1% SA1
    WHERE
        A1_CGC = %Exp:cCgc%
    ORDER BY
		A1_FILIAL
EndSql

Begin Sequence
    DbSelectArea(cAliasCli)
    While !(cAliasCli)->(Eof())

        DbSelectArea("SA1")
        DbGoto((cAliasCli)->REC_SA1)

        lTudOk := .T.
        oJsonCli := JsonObject():New()
        oJsonCli["nome do cliente"] := AllTrim(SA1->A1_NOME)
        oJsonCli["código do cliente"] := AllTrim(SA1->A1_COD)
        oJsonCli["código da loja"] := AllTrim(SA1->A1_LOJA)
        cCodEnt := AllTrim(SA1->(A1_COD+A1_LOJA))
        AAdd(aArquivoFinal, oJsonCli)
        FreeObj(oJsonCli)

        DbSelectArea(cAliasCli)
        (cAliasCli)->(DbSkip())
    Enddo
    (cAliasCli)->(DbCloseArea())
End Sequence

cAliasArquivo := GetNextAlias()
If Select(cAliasArquivo) > 0
    (cAliasArquivo)->(DbCloseArea())
Endif
        
BeginSql Alias cAliasArquivo
    SELECT 
        AC9.R_E_C_N_O_ AS REC_AC9
    FROM
        %Table:AC9% AC9
    WHERE
        AC9_CODENT = %Exp:cCodEnt%
    ORDER BY
        AC9_FILIAL
EndSql

Begin Sequence
    DbSelectArea(cAliasArquivo)
    While !(cAliasArquivo)->(Eof())

        DbSelectArea("AC9")
        DbGoto((cAliasArquivo)->REC_AC9)

        lTudOk := .T.
        oJsonArquivo := JsonObject():New()
        oJsonArquivo["código de entidade"] := AllTrim(AC9->AC9_CODENT)
        oJsonArquivo["código do objeto"] := AllTrim(AC9->AC9_CODOBJ)
        
        AAdd(cCodObj, AllTrim(AC9->AC9_CODOBJ))
        
        AAdd(aArquivoFinal, oJsonArquivo)
        FreeObj(oJsonArquivo)

        DbSelectArea(cAliasArquivo)
        (cAliasArquivo)->(DbSkip())
    Enddo
    (cAliasArquivo)->(DbCloseArea())
End Sequence

cAliasArquivoFinal := GetNextAlias()
If Select(cAliasArquivoFinal) > 0
    (cAliasArquivoFinal)->(DbCloseArea())
Endif
        
cFormattedList := ArrayToStr(cCodObj, ",")

//cFormatted := StrTran(cFormattedList, ";", "', '")
cFormatted := '%' + FormatIn(cFormattedList,",") + '%' // resultado = '01','02','03'


BeginSql Alias cAliasArquivoFinal
    SELECT 
        ACB.R_E_C_N_O_ AS REC_ACB
    FROM
        %Table:ACB% ACB
    WHERE
        ACB_CODOBJ IN (%Exp:cFormatted%)
EndSql

Begin Sequence
    DbSelectArea(cAliasArquivoFinal)
    While !(cAliasArquivoFinal)->(Eof())

        DbSelectArea("ACB")
        DbGoto((cAliasArquivoFinal)->REC_ACB)

        lTudOk := .T.
        oJsonArquivoFinal := JsonObject():New()
        oJsonArquivoFinal["nome da descri"] := AllTrim(ACB->ACB_DESCRI)
        
        cArquivo := AllTrim(ACB->ACB_OBJETO)
        cArqDir := "dirdoc\co99\shared\" + cArquivo
        cArquivoBase64 := u_zFile64(cArqDir)
        oJsonArquivoFinal["base64"] := cArquivoBase64 

        AAdd(aArquivoFinal, oJsonArquivoFinal)
        FreeObj(oJsonArquivoFinal)

        DbSelectArea(cAliasArquivoFinal)
        (cAliasArquivoFinal)->(DbSkip())
    Enddo
    (cAliasArquivoFinal)->(DbCloseArea())
End Sequence
*/

If !lTudOk
    lRet := .F.
    SetRestFault(1, ;
                 "Dados não encontrados.", ;
                 .T., ;
                 400, ;
                 "Falha na busca dos Arquivos.")
Else
    oJsonRet["Dados encontrados: "] := aArquivoFinal
    lRet := .T.
    self:SetResponse(oJsonRet:toJson())
Endif

Return(lRet)
 
User Function zFile64(cArquivo)
    Local cConteudo := ""
    Local cString64 := ""
    Local oFile
 
    If File(cArquivo)
        oFile := FwFileReader():New(cArquivo)
        If oFile:Open()
 
            cConteudo  := oFile:FullRead()
            cString64  := Encode64(cConteudo, , .F., .F.)
        EndIf
        oFile:Close()
    EndIf
Return (cString64)
