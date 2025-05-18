#include "totvs.ch"
#include "protheus.ch"
#include "tbiconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ AFGTSD1 ¦ Autor ¦ Fábrica ERP.BR   ¦ Data  ¦ 22/03/2022    ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Integração GtPlan - Notas Fiscais.       				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AFIP											  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function AFGTSD1()

Local lSchedule := .F.
Local nMaxCount := 1000

MsgRun("Aguarde, integração gtplan notas fiscais...","Processando",{|| u_ProcGtSd1(lSchedule,nMaxCount) })

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ ProcGtSd1  ¦ Autor ¦ Fábrica ERP.BR ¦ Data  ¦ 22/03/2022   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Executa integração GtPlan.               				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AFIP											  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function ProcGtSd1(lSchedule,nMaxCount)

Local cURI        := AllTrim(GetMv("MV_ZURLGTP")) // https://restbus.gtplanqa.net   
Local cResource   := "/Erp_invoice"
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

    cQuery := " SELECT SD1.R_E_C_N_O_ AS RECSD1 "
    cQuery += " FROM "+RetSqlName("SD1")+" SD1, "
    cQuery += RetSqlName("SB1")+" SB1, "
    cQuery += RetSqlName("SA2")+" SA2, "
    cQuery += RetSqlName("SF4")+" SF4 "
    cQuery += " WHERE D1_FILIAL IN "+FormatIn(zFilialGtp,",")
    cQuery += " AND D1_TES = F4_CODIGO "
    cQuery += " AND D1_COD = B1_COD "
    cQuery += " AND D1_FORNECE = A2_COD "
    cQuery += " AND D1_LOJA = A2_LOJA "
    cQuery += " AND D1_DTDIGIT >= '"+DtoS( Date() - IIf(lSchedule,30,365) )+"' "
    cQuery += " AND D1_TIPO = 'N' "
    cQuery += " AND F4_DUPLIC = 'S' "
    cQuery += " AND B1_ZZGTP = 'E' "
    cQuery += " AND A2_ZZGTP = 'E' "
    cQuery += " AND SD1.D_E_L_E_T_ <> '*' "
    cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
    cQuery += " AND SA2.D_E_L_E_T_ <> '*' "
    cQuery += " AND SF4.D_E_L_E_T_ <> '*' "
    cQuery += " ORDER BY D1_FILIAL, D1_DOC, D1_SERIE, D1_ITEM "
    DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TRBGTP", .F., .T.)

    DbSelectArea("TRBGTP")
    TRBGTP->(DbGotop())
    If !Eof()
        cPostParms := '{ "DATA":['
        While !Eof()

            DbSelectArea("SD1")
            SD1->(DbGoto(TRBGTP->RECSD1))
            nRecAtu := SD1->(Recno())

            If !DadosValidos()
                DbSelectArea("TRBGTP")
                TRBGTP->(DbSkip())
                Loop
            Endif

            If SD1->D1_FILIAL == "I0"
                If Substr(SD1->D1_COD,1,4) <> "CEAC"
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
                                MsgInfo("Sucesso: "+AllTrim(STR(oObjJson:RESULT:SUCCESS:AFFECTEDROWS))+" registros.")
                            Endif    
                            If nMaxCount == 1
                                SD1->(DbGoto(nRecAnt))
                                RecLock("SD1",.F.)
                                SD1->D1_ZZGTP := "E"
                                MsUnLock()
                                SD1->(DbGoto(nRecAtu))
                            Endif
                        Endif
                    Endif
                Endif
                If !lRetorno
                    If !lSchedule
                        MsgInfo("Erro no retorno.")
                    Endif    
                    If nMaxCount == 1
                        SD1->(DbGoto(nRecAnt))
                        RecLock("SD1",.F.)
                        SD1->D1_ZZGTP := "X"
                        MsUnLock()
                        SD1->(DbGoto(nRecAtu))
                    Endif
                Endif
                cPostParms := '{ "DATA":['
                nCountRows := 1
            Else
                If nCountRows > 1
                    cPostParms += ','
                Endif
            Endif

            DbSelectArea("SA2")
            DbSetOrder(1)
            DbSeek( xFilial("SA2") + SD1->(D1_FORNECE+D1_LOJA) )

            zInvoice := SD1->(D1_FILIAL+AllTrim(D1_DOC)+AllTrim(D1_SERIE)+AllTrim(D1_FORNECE)+AllTrim(D1_LOJA)+AllTrim(D1_COD)+D1_ITEM)
            zEmissao := DtoS(SD1->D1_EMISSAO)
            zEmissao := Substr(zEmissao,7,2)+Substr(zEmissao,5,2)+Substr(zEmissao,1,4)
            zEntrega := DtoS(SD1->D1_DTDIGIT)
            zEntrega := Substr(zEntrega,7,2)+Substr(zEntrega,5,2)+Substr(zEntrega,1,4)
            zPedido  := ""
            zEmiPed  := ""
            zEntPed  := ""
            zQtdPed  := 0
            zPrcPed  := 0

            If !Empty(SD1->D1_PEDIDO)
                DbSelectArea("SC7")
                DbSetOrder(1)
                If DbSeek( SD1->(D1_FILIAL+D1_PEDIDO+D1_ITEM) )
                    zPedido := SC7->C7_NUM
                    zEmiPed := DtoS(SC7->C7_EMISSAO)
                    zEmiPed := Substr(zEmiPed,7,2)+Substr(zEmiPed,5,2)+Substr(zEmiPed,1,4)
                    zEntPed := DtoS(SC7->C7_DATPRF)
                    zEntPed := Substr(zEntPed,7,2)+Substr(zEntPed,5,2)+Substr(zEntPed,1,4)
                    zQtdPed := SC7->C7_QUANT
                    zPrcPed := SC7->C7_PRECO
                Endif
            Endif    

            cPostParms += '{'
            cPostParms += '"ID_COMPANY_FK":"'+zIdCompany+'",'
            cPostParms += '"COD_ESTAB":"'+SD1->D1_FILIAL+'",'
            cPostParms += '"ID_INVOICE_PK":"'+zInvoice+'",'
            cPostParms += '"ID_SUPPLIER":"'+AllTrim(SA2->(A2_COD+A2_LOJA))+'",'
            cPostParms += '"COD_ITEM":"'+AllTrim(SD1->D1_COD)+'",'
            cPostParms += '"NUM_INVOICE":"'+AllTrim(SD1->D1_DOC)+'",'
            cPostParms += '"DATE_INVOICE":"'+zEmissao+'",'
            cPostParms += '"DATE_INVOICE_RECEIVED":"'+zEntrega+'",'
            cPostParms += '"QTY_INVOICE":"'+AllTrim(STR(SD1->D1_QUANT))+'",'
            cPostParms += '"VAL_UNIT_INVOICE":"'+AllTrim(STR(SD1->D1_VUNIT))+'",'
            cPostParms += '"NUM_ORDER":"'+AllTrim(zPedido)+'",'
            cPostParms += '"DATE_ORDER":"'+zEmiPed+'",'
            cPostParms += '"DATE_ORDER_EXP":"'+zEntPed+'",'
            cPostParms += '"QTY_ORDER":"'+AllTrim(STR(zQtdPed))+'",'
            cPostParms += '"VAL_UNIT_ORDER":"'+AllTrim(STR(zPrcPed))+'"'
            cPostParms += '}'

            nRecAnt := SD1->(Recno())
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
                        SD1->(DbGoto(nRecAnt))
                        RecLock("SD1",.F.)
                        SD1->D1_ZZGTP := "E"
                        MsUnLock()
                        SD1->(DbGoto(nRecAtu))
                    Endif
                Endif
            Endif
        Endif
        If !lRetorno
            If !lSchedule
                MsgInfo("Erro no retorno.")
            Endif    
            If nMaxCount == 1
                SD1->(DbGoto(nRecAnt))
                RecLock("SD1",.F.)
                SD1->D1_ZZGTP := "X"
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
¦¦¦Programa  ¦ SCHGTSD1 ¦ Autor ¦ Fábrica ERP.BR  ¦ Data  ¦ 22/03/2022    ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Integração GtPlan - Notas Fiscais.  						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AFIP											  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function SCHGTSD1()

Local lSchedule := .T.
Local nMaxCount := 1000

//ConOut( "GtPlan - Integração Documento de Entrada - "+DtoC(Date())+" - "+Time()+" - Início" )
cMessage := "GtPlan - Integração Documento de Entrada - "+DtoC(Date())+" - "+Time()+" - Início"
FwLogMsg("INFO", /*cTransactionId*/, "AFIP", FunName(), "", "01", cMessage, 0, (Seconds()), {})

PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01"

//ConOut( "GtPlan - Integração Documento de Entrada - "+DtoC(Date())+" - "+Time()+" - Fim" )
cMessage := "GtPlan - Integração Documento de Entrada - "+DtoC(Date())+" - "+Time()+" - Fim"
FwLogMsg("INFO", /*cTransactionId*/, "AFIP", FunName(), "", "01", cMessage, 0, (Seconds()), {})

u_ProcGtSd1(lSchedule,nMaxCount)

Return

