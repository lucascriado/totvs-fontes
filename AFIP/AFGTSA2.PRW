#include "totvs.ch"
#include "protheus.ch"
#include "tbiconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ AFGTSA2 ¦ Autor ¦ Fábrica ERP.BR   ¦ Data  ¦ 16/03/2022    ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Integração GtPlan - Fornecedores.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AFIP											  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function AFGTSA2(gtFornec)

Local lSchedule := .F.
Local nMaxCount := IIf(gtFornec == Nil, 1000, 1)

MsgRun("Aguarde, integração gtplan fornecedores...","Processando",{|| u_ProcGtSa2(lSchedule,nMaxCount,gtFornec) })

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ProcGtSa2 ¦ Autor ¦ Fábrica ERP.BR ¦ Data  ¦ 18/03/2022    ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Executa integração GtPlan.               				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AFIP											  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function ProcGtSa2(lSchedule,nMaxCount,gtFornec)

Local cURI        := AllTrim(GetMv("MV_ZURLGTP")) // https://api-qa.gtplan.net
Local cResource   := "/Erp_supplier"
Local oRest       := FwRest():New(cURI)
Local cUserId     := AllTrim(GetMv("MV_ZUSRGTP")) // BBD9E0D8800D07305101D4067FA8D4F5
Local cPassword   := AllTrim(GetMv("MV_ZPSWGTP")) // A4A8A31750A23DE2DA88EF6A491DFD5C
Local cGetParms   := "action=INSERT"
Local cPostParms  := ""
Local nTimeOut    := 120
Local aHeader     := {}
Local cHeaderPost := ""
Local cRetorno    := ""
Local oObjJson    := Nil
Local nCountRows  := 0
Local zIdCompany  := "5322"

If gtFornec <> Nil
    If !MsgYesNo("Confirma integração GtPlan para o fornecedor "+AllTrim(SA2->A2_NOME)+" ?")
        Return
    Endif
Endif

If ValType(oRest) == "O"

    AAdd(aHeader, "Content-Type: application/json; charset=UTF-8")
    AAdd(aHeader, "Accept: application/json")
    AAdd(aHeader, "User-Agent: Chrome/65.0 (compatible; Protheus "+GetBuild()+")")
    AAdd(aHeader, "Authorization: Basic "+Encode64(cUserId+":"+cPassword))

    cQuery := " SELECT R_E_C_N_O_ AS RECSA2 "
    cQuery += " FROM "+RetSqlName("SA2") "
    cQuery += " WHERE A2_FILIAL = '"+xFilial("SA2")+"' "
    cQuery += " AND A2_MSBLQL <> '1' "
    If gtFornec != Nil
        cQuery += " AND A2_COD = '"+AllTrim(gtFornec)+"' "
    ElseIf lSchedule
        cQuery += " AND A2_ZZGTP = 'S' "
    Else
        cQuery += " AND A2_ZZGTP = 'E' "
    Endif
    cQuery += " AND D_E_L_E_T_ <> '*' "
    cQuery += " ORDER BY A2_COD, A2_LOJA "
    DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TRBGTP", .F., .T.)

    DbSelectArea("TRBGTP")
    TRBGTP->(DbGotop())
    If !Eof()
        cPostParms := '{ "DATA":['
        While !Eof()

            DbSelectArea("SA2")
            SA2->(DbGoto(TRBGTP->RECSA2))
            nRecAtu := SA2->(Recno())

            If !DadosValidos()
                DbSelectArea("TRBGTP")
                TRBGTP->(DbSkip())
                Loop
            Endif

            nCountRows += 1

            If nCountRows > nMaxCount
                cPostParms += ']}'
                lRetorno := .F.
                cRetorno := HttpPost(cURI+cResource, cGetParms, cPostParms, nTimeOut, aHeader, @cHeaderPost)
                If FWJsonDeserialize(cRetorno, @oObjJson)
                    If ValType(oObjJson:RESULT:SUCCESS) == "O"
                        If oObjJson:RESULT:SUCCESS:AFFECTEDROWS > 0
                            lRetorno := .T.
                            If !lSchedule
                                MsgInfo("Sucesso: "+AllTrim(STR(oObjJson:RESULT:SUCCESS:AFFECTEDROWS))+" registros.")
                            Endif    
                            If nMaxCount == 1
                                SA2->(DbGoto(nRecAnt))
                                RecLock("SA2",.F.)
                                SA2->A2_ZZGTP := "E"
                                MsUnLock()
                                SA2->(DbGoto(nRecAtu))
                            Endif
                        Endif
                    Endif
                Endif
                If !lRetorno
                    If !lSchedule
                        MsgInfo("Erro no retorno.")
                    Endif    
                    If nMaxCount == 1
                        SA2->(DbGoto(nRecAnt))
                        RecLock("SA2",.F.)
                        SA2->A2_ZZGTP := "X"
                        MsUnLock()
                        SA2->(DbGoto(nRecAtu))
                    Endif    
                Endif
                cPostParms := '{ "DATA":['
                nCountRows := 1
            Else
                If nCountRows > 1
                    cPostParms += ','
                Endif
            Endif
            
            cPostParms += '{'
            cPostParms += '"ID_COMPANY_FK":"'+zIdCompany+'",'
            cPostParms += '"ID_SUPPLIER_PK":"'+AllTrim(SA2->(A2_COD+A2_LOJA))+'",'
            cPostParms += '"COD_SUPPLIER":"'+AllTrim(SA2->A2_CGC)+'",'
            cPostParms += '"DESC_SUPPLIER":"'+AllTrim(SA2->A2_NOME)+'",'
            cPostParms += '"SUPPLIER_CONTACT_NAME":"'+AllTrim(SA2->A2_CONTATO)+'",'
            cPostParms += '"EMAIL_SUPPLIER":"'+AllTrim(SA2->A2_EMAIL)+'"'
            cPostParms += '}'

            nRecAnt := SA2->(Recno())
            DbSelectArea("TRBGTP")
            TRBGTP->(DbSkip())
        
        Enddo
        cPostParms += ']}'
    Endif
    TRBGTP->(DbCloseArea())

    If nCountRows > 0 
        lRetorno := .F.
        cRetorno := HttpPost(cURI+cResource, cGetParms, cPostParms, nTimeOut, aHeader, @cHeaderPost)
        If FWJsonDeserialize(cRetorno, @oObjJson)
            If ValType(oObjJson:RESULT:SUCCESS) == "O"
                If oObjJson:RESULT:SUCCESS:AFFECTEDROWS > 0
                    lRetorno := .T.
                    If !lSchedule
                        MsgInfo("Sucesso: "+AllTrim(STR(oObjJson:RESULT:SUCCESS:AFFECTEDROWS))+" registros.")
                    Endif    
                    If nMaxCount == 1
                        SA2->(DbGoto(nRecAnt))
                        RecLock("SA2",.F.)
                        SA2->A2_ZZGTP := "E"
                        MsUnLock()
                        SA2->(DbGoto(nRecAtu))
                    Endif    
                Endif
            Endif
        Endif
        If !lRetorno
            If !lSchedule
                MsgInfo("Erro no retorno.")
            Endif    
            If nMaxCount == 1
                SA2->(DbGoto(nRecAnt))
                RecLock("SA2",.F.)
                SA2->A2_ZZGTP := "X"
                MsUnLock()
            Endif    
        Endif
    Endif

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ DadosValidos ¦ Autor ¦ Fábrica ERP.BR ¦ Data ¦ 18/03/2022  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Valida os dados.                                           ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AFIP											  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function DadosValidos()

Local lRet := .T.

If lRet
    If Val(SA2->A2_CGC) == 0
        lRet := .F.
    Endif
Endif

Return(lRet)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ SCHGTSA2 ¦ Autor ¦ Fábrica ERP.BR  ¦ Data  ¦ 16/03/2022    ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Integração GtPlan - Fornecedores.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AFIP											  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function SCHGTSA2()

Local lSchedule := .T.
Local nMaxCount := 1

PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01"

//ConOut( "GtPlan - Integração Fornecedores - "+DtoC(Date())+" - "+Time()+" - Início" )
cMessage := "GtPlan - Integração Fornecedores - "+DtoC(Date())+" - "+Time()+" - Início"
FwLogMsg("INFO", /*cTransactionId*/, "AFIP", FunName(), "", "01", cMessage, 0, (Seconds()), {})

u_ProcGtSa2(lSchedule,nMaxCount,Nil)

//ConOut( "GtPlan - Integração Fornecedores - "+DtoC(Date())+" - "+Time()+" - Fim" )
cMessage := "GtPlan - Integração Fornecedores - "+DtoC(Date())+" - "+Time()+" - Fim"
FwLogMsg("INFO", /*cTransactionId*/, "AFIP", FunName(), "", "01", cMessage, 0, (Seconds()), {})

Return
