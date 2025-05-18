#include "totvs.ch"
#include "protheus.ch"
#include "tbiconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ BLEZCTT ¦ Autor ¦ Fábrica ERP.BR   ¦ Data  ¦   Jul-2023    ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Integração BlueEz - Centros de Custo.					  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo BLUEEZ											  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function BLEZCTT(bzCcusto)

Local lSchedule := .F.
Local nMaxCount := IIf(bzCcusto == Nil, 1, 1)
Local cBlzToken := ""

cBlzToken := U_BLEZAUT(.F.) // Atualiza o token de autenticação

MsgRun("Aguarde, integração BlueEz centros de custo","Processando",{|| u_ProcBzCtt(lSchedule,nMaxCount,bzCcusto,cBlzToken) })

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ ProcBzCtt  ¦ Autor ¦ Fábrica ERP.BR ¦ Data  ¦  Jul-2023    ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Executa integração BlueEz.               				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo BLUEEZ											  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function ProcBzCtt(lSchedule,nMaxCount,bzCcusto,cBlzToken)

Local cBlezUrl    := AllTrim(GetMv("CO_BLEZURL")) // https://apiqa.blueez.com.br
Local cResource   := "/api/v1/erp/centrosCusto"
Local oRest       := FwRest():New(cBlezUrl)
Local cGetParms   := ""
Local nTimeOut    := 200
Local cPostParms  := ""
Local aHeader     := {}
Local cHeaderPost := ""
Local cRetorno    := ""
Local oObjJson    := Nil
Local nCountRows  := 0
Local lCargaIni := .T.

If bzCcusto <> Nil
    If !MsgYesNo("Confirma integração BlueEz para o centro de custo "+AllTrim(CTT->CTT_CUSTO)+" ?")
        Return
    Endif
Endif

If ValType(oRest) == "O"

    AAdd(aHeader, "Content-Type: application/json; charset=UTF-8")
    AAdd(aHeader, "Accept: application/json")
    AAdd(aHeader, "User-Agent: Chrome/65.0 (compatible; Protheus "+GetBuild()+")")
    AAdd(aHeader, "Authorization: Bearer "+cBlzToken)

    cQuery := " SELECT R_E_C_N_O_ AS RECCTT "
    cQuery += " FROM "+RetSqlName("CTT")
    cQuery += " WHERE D_E_L_E_T_ <> '*' "
    cQuery += " AND CTT_CLASSE = '2' "
    If lCargaIni
        cQuery += " AND CTT_BLOQ <> '1' "
    Endif    
    If bzCcusto != Nil
        cQuery += " CTT_FILIAL = '"+xFilial("CTT")+"' AND CTT_CUSTO = '"+AllTrim(bzCcusto)+"'  "
    ElseIf lSchedule
        cQuery += " AND CTT_XBLUEZ IN('S','X') "
    Else
        cQuery += " AND CTT_XBLUEZ IN('S','X') "
    Endif
    cQuery += " ORDER BY CTT_CUSTO "
    DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TRBLEZ", .F., .T.)

    DbSelectArea("TRBLEZ")
    TRBLEZ->(DbGotop())
    If !Eof()
        While !Eof()

            DbSelectArea("CTT")
            CTT->(DbGoto(TRBLEZ->RECCTT))
            nRecAtu := CTT->(Recno())

            If !DadosValidos()
                DbSelectArea("TRBLEZ")
                TRBLEZ->(DbSkip())
                Loop
            Endif

            nCountRows += 1

            If nCountRows > nMaxCount
                lRetorno := .F.
                cMsgErro := "Erro no retorno."
                cRetorno := HttpPost(cBlezUrl+cResource, cGetParms, cPostParms, nTimeOut, aHeader, @cHeaderPost)
                If FWJsonDeserialize(cRetorno, @oObjJson)
                    CTT->(DbGoto(nRecAnt))
                    If oObjJson:SUCCESS
                        lRetorno := .T.
                        If !lSchedule
                            If !lCargaIni
                                MsgInfo(AllTrim(CTT->CTT_CUSTO)+": sucesso !!")
                            Endif    
                        Endif    
                        If nMaxCount == 1
                            RecLock("CTT",.F.)
                            CTT->CTT_XBLUEZ := "E"
                            MsUnLock()
                        Endif
                    Else
                        cMsgErro := Upper(AllTrim(oObjJson:MESSAGE))
                    Endif
                    CTT->(DbGoto(nRecAtu))
                Endif
                If !lRetorno
                    CTT->(DbGoto(nRecAnt))
                    If !lSchedule
                        If !lCargaIni
                            MsgInfo(AllTrim(CTT->CTT_CUSTO)+": "+cMsgErro)
                        Endif    
                    Endif    
                    If nMaxCount == 1
                        RecLock("CTT",.F.)
                        CTT->CTT_XBLUEZ := "X"
                        MsUnLock()
                    Endif
                    CTT->(DbGoto(nRecAtu))
                Endif
                cPostParms := ""
                nCountRows := 1
            Else
                /*
                If nCountRows > 1
                    cPostParms += ','
                Endif
                */
            Endif

            pDescricao := u_zLimpaEsp(CTT->CTT_DESC01)
            lBloqueado := ( (!Empty(CTT->CTT_DTEXSF) .And. Date() > CTT->CTT_DTEXSF) .Or. CTT->CTT_BLOQ == "1" )
            cPostParms += '{'
            cPostParms += '"empresa":null,'
            cPostParms += '"codigo":"'+AllTrim(CTT->CTT_CUSTO)+'",'
            cPostParms += '"descricao":"'+AllTrim(pDescricao)+'",'
            cPostParms += '"ativo":'+IIf(lBloqueado,"0","1") // 0=inativo | 1=ativo
            cPostParms += '}'

            nRecAnt := CTT->(Recno())
            DbSelectArea("TRBLEZ")
            TRBLEZ->(DbSkip())
        
        Enddo
    Endif
    TRBLEZ->(DbCloseArea())

    If nCountRows > 0 
        lRetorno := .F.
        cMsgErro := "Erro no retorno."
        cRetorno := HttpPost(cBlezUrl+cResource, cGetParms, cPostParms, nTimeOut, aHeader, @cHeaderPost)
        If FWJsonDeserialize(cRetorno, @oObjJson)
            CTT->(DbGoto(nRecAnt))
            If oObjJson:SUCCESS
                lRetorno := .T.
                If !lSchedule
                    If !lCargaIni
                        MsgInfo(AllTrim(CTT->CTT_CUSTO)+": sucesso !!")
                    Endif    
                Endif    
                If nMaxCount == 1
                    RecLock("CTT",.F.)
                    CTT->CTT_XBLUEZ := "E"
                    MsUnLock()
                Endif
            Else
                cMsgErro := Upper(AllTrim(oObjJson:MESSAGE))
            Endif
            CTT->(DbGoto(nRecAtu))
        Endif
        If !lRetorno
            CTT->(DbGoto(nRecAnt))
            If !lSchedule
                If !lCargaIni
                    MsgInfo(AllTrim(CTT->CTT_COD)+": "+cMsgErro)
                Endif    
            Endif    
            If nMaxCount == 1
                RecLock("CTT",.F.)
                CTT->CTT_XBLUEZ := "X"
                MsUnLock()
            Endif
            CTT->(DbGoto(nRecAtu))
        Endif
    Endif

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ DadosValidos ¦ Autor ¦ Fábrica ERP.BR ¦ Data ¦  Jul-2023   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Valida os dados.                                           ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo BLUEEZ											  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function DadosValidos()

Local lRet := .T.

Return(lRet)
