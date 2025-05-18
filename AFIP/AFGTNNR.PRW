#include "totvs.ch"
#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ AFGTNNR ¦ Autor ¦ Fábrica ERP.BR   ¦ Data  ¦ 22/03/2022    ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Integração GtPlan - Locais de estoque.					  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AFIP											  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function AFGTNNR()

Local lSchedule := .F.
Local nMaxCount := 200

MsgRun("Aguarde, integração gtplan locais de estoque...","Processando",{|| u_ProcGtNNR(lSchedule,nMaxCount) })

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ProcGtNNR ¦ Autor ¦ Fábrica ERP.BR ¦ Data  ¦ 22/03/2022    ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Executa integração GtPlan.               				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AFIP											  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function ProcGtNNR(lSchedule,nMaxCount)

Local cURI        := AllTrim(GetMv("MV_ZURLGTP")) // https://restbus.gtplanqa.net
Local cResource   := "/Erp_local"
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
Local _loc

If ValType(oRest) == "O"

    AAdd(aHeader, "Content-Type: application/json; charset=UTF-8")
    AAdd(aHeader, "Accept: application/json")
    AAdd(aHeader, "User-Agent: Chrome/65.0 (compatible; Protheus "+GetBuild()+")")
    AAdd(aHeader, "Authorization: Basic "+Encode64(cUserId+":"+cPassword))

    cQuery := " SELECT R_E_C_N_O_ AS RECNNR "
    cQuery += " FROM "+RetSqlName("NNR") "
    cQuery += " WHERE NNR_FILIAL = '"+xFilial("NNR")+"' "
    cQuery += " AND D_E_L_E_T_ <> '*' "
    cQuery += " ORDER BY NNR_FILIAL, NNR_CODIGO "
    DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TRBGTP", .F., .T.)

    DbSelectArea("TRBGTP")
    TRBGTP->(DbGotop())
    If !Eof()
        cPostParms := '{ "DATA":['
        While !Eof()

            DbSelectArea("NNR")
            NNR->(DbGoto(TRBGTP->RECNNR))
            nRecAtu := NNR->(Recno())

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
                                NNR->(DbGoto(nRecAnt))
                                RecLock("NNR",.F.)
                                //NNR->NNR_ZZGTP := "C"
                                MsUnLock()
                                NNR->(DbGoto(nRecAtu))
                            Endif
                        Endif
                    Endif
                Endif
                If !lRetorno
                    If !lSchedule
                        MsgInfo("Erro no retorno.")
                    Endif    
                    If nMaxCount == 1
                        NNR->(DbGoto(nRecAnt))
                        RecLock("NNR",.F.)
                        //NNR->NNR_ZZGTP := "X"
                        MsUnLock()
                        NNR->(DbGoto(nRecAtu))
                    Endif    
                Endif
                cPostParms := '{ "DATA":['
                nCountRows := 1
            Else
                If nCountRows > 1
                    cPostParms += ','
                Endif
            Endif

            nPosic  := 0
            aFilNNR := {}
            cTxtLin := zFilialGtp
            While (!Empty(cTxtLin))
                If (((nPosic := AT(",",cTxtLin)) > 0))
                    AAdd(aFilNNR,Substr(cTxtLin,1,nPosic-1))
                    cTxtLin := Stuff(cTxtLin,1,nPosic,"")
                Else
                    AAdd(aFilNNR,Substr(cTxtLin,1,Len(AllTrim(cTxtLin))))
                    cTxtLin := Stuff(cTxtLin,1,Len(cTxtLin),"")
                Endif	
            Enddo

            For _loc := 1 to Len(aFilNNR)
                gtFilNNR := aFilNNR[_loc]
                If _loc > 1
                    nCountRows += 1
                    cPostParms += ','
                Endif
                cPostParms += '{'
                cPostParms += '"ID_COMPANY_FK":"'+zIdCompany+'",'
                cPostParms += '"COD_ESTAB_PK":"'+gtFilNNR+'",'
                cPostParms += '"COD_LOCAL_PK":"'+AllTrim(NNR->NNR_CODIGO)+'",'
                cPostParms += '"DESC_LOCAL":"'+AllTrim(NNR->NNR_DESCRI)+'"'
                cPostParms += '}'
            Next _loc

            nRecAnt := NNR->(Recno())
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
                        NNR->(DbGoto(nRecAnt))
                        RecLock("NNR",.F.)
                        //NNR->NNR_ZZGTP := "C"
                        MsUnLock()
                        NNR->(DbGoto(nRecAtu))
                    Endif    
                Endif
            Endif
        Endif
        If !lRetorno
            If !lSchedule
                MsgInfo("Erro no retorno.")
            Endif    
            If nMaxCount == 1
                NNR->(DbGoto(nRecAnt))
                RecLock("NNR",.F.)
                //NNR->NNR_ZZGTP := "X"
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
¦¦¦Função    ¦ DadosValidos ¦ Autor ¦ Fábrica ERP.BR ¦ Data ¦ 22/03/2022  ¦¦¦
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
¦¦¦Programa  ¦ SCHGTNNR ¦ Autor ¦ Fábrica ERP.BR  ¦ Data  ¦ 22/03/2022    ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Integração GtPlan - Locais de estoque.					  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AFIP											  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function SCHGTNNR()

Local lSchedule := .T.
Local nMaxCount := 1

u_ProcGtNNR(lSchedule,nMaxCount)

Return
