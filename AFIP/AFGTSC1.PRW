#include "totvs.ch"
#include "protheus.ch"
#include "tbiconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ AFGTSC1 ¦ Autor ¦ Fábrica ERP.BR   ¦ Data  ¦ 16/03/2022    ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Integração GtPlan - Solicitação de Compras.				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AFIP											  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function AFGTSC1()

Local lSchedule := .F.
Local nMaxCount := 1

MsgRun("Aguarde, integração gtplan solic.compras...","Processando",{|| u_ProcGtSc1(lSchedule,nMaxCount) })

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ ProcGtSc1  ¦ Autor ¦ Fábrica ERP.BR ¦ Data  ¦ 18/03/2022   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Executa integração GtPlan.               				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AFIP											  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function ProcGtSc1(lSchedule,nMaxCount)

Local cURI        := AllTrim(GetMv("MV_ZURLGTP")) // https://api-qa.gtplan.net
Local cResource   := "/Erp_purchase_req"
Local oRest       := FwRest():New(cURI)
Local cUserId     := AllTrim(GetMv("MV_ZUSRGTP")) // BBD9E0D8800D07305101D4067FA8D4F5
Local cPassword   := AllTrim(GetMv("MV_ZPSWGTP")) // A4A8A31750A23DE2DA88EF6A491DFD5C
Local zFilialGtp  := AllTrim(GetMv("MV_ZFILGTP")) // 05,88,A2,I0
Local cGetParms   := "action=INSERT"
Local cPostParms  := ""
Local nTimeOut    := 120
Local aHeader     := {}
Local cHeaderPost := ""
Local cRetorno    := ""
Local oObjJson    := Nil
Local nCountRows  := 0
Local zIdCompany  := "5322"

If ValType(oRest) == "O"

    AAdd(aHeader, "Content-Type: application/json; charset=UTF-8")
    AAdd(aHeader, "Accept: application/json")
    AAdd(aHeader, "User-Agent: Chrome/65.0 (compatible; Protheus "+GetBuild()+")")
    AAdd(aHeader, "Authorization: Basic "+Encode64(cUserId+":"+cPassword))

    cQuery := " SELECT SC1.R_E_C_N_O_ AS RECSC1 "
    cQuery += " FROM "+RetSqlName("SC1")+" SC1, "
    cQuery += RetSqlName("SB1")+" SB1 "
    cQuery += " WHERE C1_FILIAL IN "+FormatIn(zFilialGtp,",")
    cQuery += " AND C1_PRODUTO = B1_COD "
    cQuery += " AND B1_ZZGTP = 'E' "
    cQuery += " AND C1_QUJE < C1_QUANT "
    cQuery += " AND C1_RESIDUO <> 'S' "
    cQuery += " AND C1_ZZLIBGT = 'S' "
    cQuery += " AND SC1.D_E_L_E_T_ <> '*' "
    cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
    cQuery += " ORDER BY C1_FILIAL, C1_NUM, C1_ITEM "
    DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TRBGTP", .F., .T.)

    DbSelectArea("TRBGTP")
    TRBGTP->(DbGotop())
    If !Eof()
        cPostParms := '{ "DATA":['
        While !Eof()

            DbSelectArea("SC1")
            SC1->(DbGoto(TRBGTP->RECSC1))
            nRecAtu := SC1->(Recno())

            If !DadosValidos()
                DbSelectArea("TRBGTP")
                TRBGTP->(DbSkip())
                Loop
            Endif

            If SC1->C1_FILIAL == "I0"
                If Substr(SC1->C1_PRODUTO,1,4) <> "CEAC"
                    DbSelectArea("TRBGTP")
                    TRBGTP->(DbSkip())
                    Loop
                Endif
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
                                //MsgInfo("Sucesso: "+AllTrim(STR(oObjJson:RESULT:SUCCESS:AFFECTEDROWS))+" registros.")
                            Endif    
                            If nMaxCount == 1
                                SC1->(DbGoto(nRecAnt))
                                RecLock("SC1",.F.)
                                SC1->C1_ZZGTP := "E"
                                MsUnLock()
                                SC1->(DbGoto(nRecAtu))
                            Endif
                        Endif
                    Endif
                Endif
                If !lRetorno
                    If !lSchedule
                        //MsgInfo("Erro no retorno.")
                    Endif    
                    If nMaxCount == 1
                        SC1->(DbGoto(nRecAnt))
                        RecLock("SC1",.F.)
                        SC1->C1_ZZGTP := "X"
                        MsUnLock()
                        SC1->(DbGoto(nRecAtu))
                    Endif
                Endif
                cPostParms := '{ "DATA":['
                nCountRows := 1
            Else
                If nCountRows > 1
                    cPostParms += ','
                Endif
            Endif
            
            zEmissao := DtoS(SC1->C1_EMISSAO)
            zEmissao := Substr(zEmissao,7,2)+Substr(zEmissao,5,2)+Substr(zEmissao,1,4)
            zEntrega := DtoS(SC1->C1_DATPRF)
            zEntrega := Substr(zEntrega,7,2)+Substr(zEntrega,5,2)+Substr(zEntrega,1,4)
            
            cPostParms += '{'
            cPostParms += '"ID_COMPANY_FK":"'+zIdCompany+'",'
            cPostParms += '"ID_REQ_PK":"'+SC1->(C1_FILIAL+AllTrim(C1_NUM)+C1_ITEM)+'",'
            cPostParms += '"NUM_REQ":"'+AllTrim(SC1->C1_NUM)+'",'            
            cPostParms += '"NUM_ITEM_REQ":"'+SC1->C1_ITEM+'",'
            cPostParms += '"NUM_PARC_REQ":"1",'
            cPostParms += '"COD_ITEM":"'+AllTrim(SC1->C1_PRODUTO)+'",'
            cPostParms += '"COD_ESTAB":"'+SC1->C1_FILIAL+'",'
            cPostParms += '"COD_LOCAL":"'+SC1->C1_LOCAL+'",'
            cPostParms += '"QTY_PARC":"'+AllTrim(STR(SC1->(C1_QUANT-C1_QUJE)))+'",'
            cPostParms += '"DATE_EXP":"'+zEntrega+'",'
            cPostParms += '"OBS_REQ":"'+AllTrim(SC1->C1_OBS)+'",'
            cPostParms += '"COD_BUYER":"'+AllTrim(SC1->C1_USER)+'"'
            cPostParms += '}'

            nRecAnt := SC1->(Recno())
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
                        //MsgInfo("Sucesso: "+AllTrim(STR(oObjJson:RESULT:SUCCESS:AFFECTEDROWS))+" registros.")
                    Endif    
                    If nMaxCount == 1
                        SC1->(DbGoto(nRecAnt))
                        RecLock("SC1",.F.)
                        SC1->C1_ZZGTP := "E"
                        MsUnLock()
                        SC1->(DbGoto(nRecAtu))
                    Endif
                Endif
            Endif
        Endif
        If !lRetorno
            If !lSchedule
                //MsgInfo("Erro no retorno.")
            Endif    
            If nMaxCount == 1
                SC1->(DbGoto(nRecAnt))
                RecLock("SC1",.F.)
                SC1->C1_ZZGTP := "X"
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


Return(lRet)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ SCHGTSC1 ¦ Autor ¦ Fábrica ERP.BR  ¦ Data  ¦ 22/03/2022    ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Integração GtPlan - Solic.Compras.           			  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AFIP											  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function SCHGTSC1()

Local lSchedule := .T.
Local nMaxCount := 1

//ConOut( "GtPlan - Integração Solicitação de Compras - "+DtoC(Date())+" - "+Time()+" - Início" )
cMessage := "GtPlan - Integração Solicitação de Compras - "+DtoC(Date())+" - "+Time()+" - Início"
FwLogMsg("INFO", /*cTransactionId*/, "AFIP", FunName(), "", "01", cMessage, 0, (Seconds()), {})

PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01"
//ConOut( "GtPlan - Integração Solicitação de Compras - "+DtoC(Date())+" - "+Time()+" - Fim" )
cMessage := "GtPlan - Integração Solicitação de Compras - "+DtoC(Date())+" - "+Time()+" - Fim"
FwLogMsg("INFO", /*cTransactionId*/, "AFIP", FunName(), "", "01", cMessage, 0, (Seconds()), {})

u_ProcGtSc1(lSchedule,nMaxCount)

Return
