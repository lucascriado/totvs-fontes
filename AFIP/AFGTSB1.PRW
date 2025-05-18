#include "totvs.ch"
#include "protheus.ch"
#include "tbiconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ AFGTSB1 ¦ Autor ¦ Fábrica ERP.BR   ¦ Data  ¦ 14/03/2022    ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Integração GtPlan - Produtos.							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AFIP											  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function AFGTSB1(gtProduto)

Local lSchedule := .F.
Local nMaxCount := IIf(gtProduto == Nil, 1000, 1)

MsgRun("Aguarde, integração gtplan produtos...","Processando",{|| u_ProcGtSb1(lSchedule,nMaxCount,gtProduto) })

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ ProcGtSb1  ¦ Autor ¦ Fábrica ERP.BR ¦ Data  ¦ 18/03/2022   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Executa integração GtPlan.               				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AFIP											  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function ProcGtSb1(lSchedule,nMaxCount,gtProduto)

Local cURI        := AllTrim(GetMv("MV_ZURLGTP")) // https://api-qa.gtplan.net
Local cResource   := "/Erp_sku"
Local oRest       := FwRest():New(cURI)
Local cUserId     := AllTrim(GetMv("MV_ZUSRGTP")) // BBD9E0D8800D07305101D4067FA8D4F5
Local cPassword   := AllTrim(GetMv("MV_ZPSWGTP")) // A4A8A31750A23DE2DA88EF6A491DFD5C
Local zFilialGtp  := AllTrim(GetMv("MV_ZFILGTP")) // 63,88,A2,I0
Local cGetParms   := "action=INSERT"
Local cPostParms  := ""
Local nTimeOut    := 120
Local aHeader     := {}
Local cHeaderPost := ""
Local cRetorno    := ""
Local oObjJson    := Nil
Local nCountRows  := 0
Local zIdCompany  := "5322"
Local _prod

If gtProduto <> Nil
    If !MsgYesNo("Confirma integração GtPlan para o produto "+AllTrim(SB1->B1_DESC)+" ?")
        Return
    Endif
Endif

If ValType(oRest) == "O"

    AAdd(aHeader, "Content-Type: application/json; charset=UTF-8")
    AAdd(aHeader, "Accept: application/json")
    AAdd(aHeader, "User-Agent: Chrome/65.0 (compatible; Protheus "+GetBuild()+")")
    AAdd(aHeader, "Authorization: Basic "+Encode64(cUserId+":"+cPassword))

    cQuery := " SELECT R_E_C_N_O_ AS RECSB1 "
    cQuery += " FROM "+RetSqlName("SB1")
    cQuery += " WHERE B1_FILIAL = '"+xFilial("SB1")+"' "
    cQuery += " AND B1_MSBLQL <> '1' "
    If gtProduto != Nil
        cQuery += " AND B1_COD = '"+AllTrim(gtProduto)+"' "
    ElseIf lSchedule
        cQuery += " AND B1_ZZGTP = 'S' "
    Else
        cQuery += " AND B1_ZZGTP = 'E' "
    Endif
    cQuery += " AND D_E_L_E_T_ <> '*' "
    cQuery += " ORDER BY B1_COD "
    DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TRBGTP", .F., .T.)

    DbSelectArea("TRBGTP")
    TRBGTP->(DbGotop())
    If !Eof()
        cPostParms := '{ "DATA":['
        While !Eof()

            DbSelectArea("SB1")
            SB1->(DbGoto(TRBGTP->RECSB1))
            nRecAtu := SB1->(Recno())

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
                                SB1->(DbGoto(nRecAnt))
                                RecLock("SB1",.F.)
                                SB1->B1_ZZGTP := "E"
                                MsUnLock()
                                SB1->(DbGoto(nRecAtu))
                            Endif
                        Endif
                    Endif
                Endif
                If !lRetorno
                    If !lSchedule
                        MsgInfo("Erro no retorno.")
                    Endif    
                    If nMaxCount == 1
                        SB1->(DbGoto(nRecAnt))
                        RecLock("SB1",.F.)
                        SB1->B1_ZZGTP := "X"
                        MsUnLock()
                        SB1->(DbGoto(nRecAtu))
                    Endif    
                Endif
                cPostParms := '{ "DATA":['
                nCountRows := 1
            Else
                If nCountRows > 1
                    cPostParms += ','
                Endif
            Endif

            DbSelectArea("SAH")
            DbSetOrder(1)
            DbSeek( xFilial("SAH") + SB1->B1_UM )

            DbSelectArea("SBM")
            DbSetOrder(1)
            DbSeek( xFilial("SBM") + SB1->B1_GRUPO )

            aFilSb1 := {}
            If Substr(SB1->B1_COD,1,4) == "CEAC"
                AAdd(aFilSb1,"I0")
            Else
                nPosic  := 0
                aFilSb1 := {}
                cTxtLin := zFilialGtp
                While (!Empty(cTxtLin))
                    If (((nPosic := AT(",",cTxtLin)) > 0))
                        If Substr(cTxtLin,1,nPosic-1) <> "I0"
                            AAdd(aFilSb1,Substr(cTxtLin,1,nPosic-1))
                        Endif
                        cTxtLin := Stuff(cTxtLin,1,nPosic,"")
                    Else
                        If Substr(cTxtLin,1,Len(AllTrim(cTxtLin))) <> "I0"
                            AAdd(aFilSb1,Substr(cTxtLin,1,Len(AllTrim(cTxtLin))))
                        Endif
                        cTxtLin := Stuff(cTxtLin,1,Len(cTxtLin),"")
                    Endif	
                Enddo
            Endif

            For _prod := 1 to Len(aFilSb1)
                gtFilSb1 := aFilSb1[_prod]
                If _prod > 1
                    nCountRows += 1
                    cPostParms += ','
                Endif
                cPostParms += '{'
                cPostParms += '"ID_COMPANY_FK":"'+zIdCompany+'",'
                cPostParms += '"COD_ESTAB_PK":"'+gtFilSb1+'",'
                cPostParms += '"COD_ITEM_PK":"'+AllTrim(SB1->B1_COD)+'",'
                cPostParms += '"DESC_ITEM":"'+AllTrim(SB1->B1_DESC)+'",'
                cPostParms += '"VAL_UNIT_SKU":"'+AllTrim(STR(SB1->B1_PRV1))+'",'
                cPostParms += '"COD_STD_UNIT":"'+AllTrim(SB1->B1_UM)+'",'
                cPostParms += '"DESC_STD_UNIT":"'+AllTrim(SAH->AH_DESCPO)+'",'
                cPostParms += '"YN_PARENT":"N",'
                cPostParms += '"COD_ITEM_PARENT":" ",'
                cPostParms += '"COD_GROUP2":"'+AllTrim(SB1->B1_GRUPO)+'",'
                cPostParms += '"COD_GROUP3":"#",'
                cPostParms += '"COD_GROUP4":"#",'
                cPostParms += '"COD_GROUP5":"#",'
                cPostParms += '"COD_GROUP6":"#",'
                cPostParms += '"COD_GROUP7":"#",'
                cPostParms += '"COD_GROUP8":"#",'
                cPostParms += '"COD_GROUP9":"#",'
                cPostParms += '"COD_GROUP10":"#",'
                cPostParms += '"COD_GROUP11":"#",'
                cPostParms += '"COD_GROUP12":"#",'
                cPostParms += '"DESC_GROUP2":"'+AllTrim(SBM->BM_DESC)+'",'
                cPostParms += '"DESC_GROUP3":"#",'
                cPostParms += '"DESC_GROUP4":"#",'
                cPostParms += '"DESC_GROUP5":"#",'
                cPostParms += '"DESC_GROUP6":"#",'
                cPostParms += '"DESC_GROUP7":"#",'
                cPostParms += '"DESC_GROUP8":"#",'
                cPostParms += '"DESC_GROUP9":"#",'
                cPostParms += '"DESC_GROUP10":"#",'
                cPostParms += '"DESC_GROUP11":"#",'
                cPostParms += '"DESC_GROUP12":"#",'
                cPostParms += '"COD_ORDER_UNIT":"'+AllTrim(SB1->B1_UM)+'",'
                cPostParms += '"DESC_ORDER_UNIT":"'+AllTrim(SAH->AH_DESCPO)+'",'
                cPostParms += '"QTY_MULT_ORDER":"1"'
                cPostParms += '}'
            Next _prod

            nRecAnt := SB1->(Recno())
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
                        SB1->(DbGoto(nRecAnt))
                        RecLock("SB1",.F.)
                        SB1->B1_ZZGTP := "E"
                        MsUnLock()
                        SB1->(DbGoto(nRecAtu))
                    Endif
                Endif
            Endif
        Endif
        If !lRetorno
            If !lSchedule
                MsgInfo("Erro no retorno.")
            Endif    
            If nMaxCount == 1
                SB1->(DbGoto(nRecAnt))
                RecLock("SB1",.F.)
                SB1->B1_ZZGTP := "X"
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

/*
º   LAPI0101
–   RESPFAC010103
<tab> PINCA0114
°   SOLU4121
"   CEAC010108
Å   HPLC010143
µ   IGEN010564
™   IGEN010451
®   IGEN010571
*/

Return(lRet)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ SCHGTSB1 ¦ Autor ¦ Fábrica ERP.BR  ¦ Data  ¦ 16/03/2022    ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Integração GtPlan - Produtos.    						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AFIP											  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function SCHGTSB1()

Local lSchedule := .T.
Local nMaxCount := 1

PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01"

//ConOut( "GtPlan - Integração Produtos - "+DtoC(Date())+" - "+Time()+" - Início" )
cMessage := "GtPlan - Integração Produtos - "+DtoC(Date())+" - "+Time()+" - Início"
FwLogMsg("INFO", /*cTransactionId*/, "AFIP", FunName(), "", "01", cMessage, 0, (Seconds()), {})

u_ProcGtSb1(lSchedule,nMaxCount,Nil)
//ConOut( "GtPlan - Integração Produtos - "+DtoC(Date())+" - "+Time()+" - Fim" )
cMessage := "GtPlan - Integração Produtos - "+DtoC(Date())+" - "+Time()+" - Fim"
FwLogMsg("INFO", /*cTransactionId*/, "AFIP", FunName(), "", "01", cMessage, 0, (Seconds()), {})

Return
