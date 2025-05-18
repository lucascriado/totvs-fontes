#include "totvs.ch"
#include "protheus.ch"
#include "tbiconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ BLEZSB1 ¦ Autor ¦ Fábrica ERP.BR   ¦ Data  ¦   Jul-2023    ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Integração BlueEz - Produtos.							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo BLUEEZ											  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function BLEZSB1(bzProduto)

Local lSchedule := .F.
Local nMaxCount := IIf(bzProduto == Nil, 1, 1)
Local cBlzToken := ""

cBlzToken := U_BLEZAUT(.F.) // Atualiza o token de autenticação

MsgRun("Aguarde, integração BlueEz produtos","Processando",{|| u_ProcBzSb1(lSchedule,nMaxCount,bzProduto,cBlzToken) })

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ ProcBzSb1  ¦ Autor ¦ Fábrica ERP.BR ¦ Data  ¦  Jul-2023    ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Executa integração BlueEz.               				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo BLUEEZ											  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function ProcBzSb1(lSchedule,nMaxCount,bzProduto,cBlzToken)

Local cBlezUrl    := AllTrim(GetMv("CO_BLEZURL")) // https://apiqa.blueez.com.br
Local cResource   := "/api/v1/erp/item/newItem"
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

If bzProduto <> Nil
    If !MsgYesNo("Confirma integração BlueEz para o produto "+AllTrim(SB1->B1_DESC)+" ?")
        Return
    Endif
Endif

If ValType(oRest) == "O"

    AAdd(aHeader, "Content-Type: application/json; charset=UTF-8")
    AAdd(aHeader, "Accept: application/json")
    AAdd(aHeader, "User-Agent: Chrome/65.0 (compatible; Protheus "+GetBuild()+")")
    AAdd(aHeader, "Authorization: Bearer "+cBlzToken)

    cQuery := " SELECT R_E_C_N_O_ AS RECSB1 "
    cQuery += " FROM "+RetSqlName("SB1")
    cQuery += " WHERE D_E_L_E_T_ <> '*' "
    If lCargaIni
        cQuery += " AND B1_MSBLQL <> '1' "
    Endif    
    If bzProduto != Nil
        cQuery += " AND B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = '"+AllTrim(bzProduto)+"' "
    ElseIf lSchedule
        cQuery += " AND B1_XBLUEEZ IN('S','X') "
    Else
        cQuery += " AND B1_XBLUEEZ IN('S','X') "
    Endif
    cQuery += " AND B1_DESC <> ' ' "
    cQuery += " ORDER BY B1_COD "
    DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TRBLEZ", .F., .T.)

    DbSelectArea("TRBLEZ")
    TRBLEZ->(DbGotop())
    If !Eof()
        While !Eof()

            DbSelectArea("SB1")
            SB1->(DbGoto(TRBLEZ->RECSB1))
            nRecAtu := SB1->(Recno())

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
                    SB1->(DbGoto(nRecAnt))
                    If oObjJson:SUCCESS
                        lRetorno := .T.
                        If !lSchedule
                            If !lCargaIni
                                MsgInfo(AllTrim(SB1->B1_COD)+": sucesso !!")
                            Endif    
                        Endif    
                        If nMaxCount == 1
                            RecLock("SB1",.F.)
                            SB1->B1_XBLUEEZ := "E"
                            MsUnLock()
                        Endif
                    Else
                        cMsgErro := Upper(AllTrim(oObjJson:MESSAGE))
                    Endif
                    SB1->(DbGoto(nRecAtu))
                Endif
                If !lRetorno
                    SB1->(DbGoto(nRecAnt))
                    If !lSchedule
                        If !lCargaIni
                            MsgInfo(AllTrim(SB1->B1_COD)+": "+cMsgErro)
                        Endif    
                    Endif    
                    If nMaxCount == 1
                        RecLock("SB1",.F.)
                        SB1->B1_XBLUEEZ := "X"
                        MsUnLock()
                    Endif
                    SB1->(DbGoto(nRecAtu))
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

            pDescricao := u_zLimpaEsp(SB1->B1_DESC)
            cPostParms += '{'
            cPostParms += '"empresa":null,'
            cPostParms += '"codigo":"'+AllTrim(SB1->B1_COD)+'",'
            cPostParms += '"descricao":"'+AllTrim(pDescricao)+'",'
            cPostParms += '"codigo_unidade":"'+AllTrim(SB1->B1_UM)+'",'
            cPostParms += '"codigo_natureza":"1",'
            cPostParms += '"codigos_categorias":"1",'
            cPostParms += '"narrativa_tecnica":"",'
            cPostParms += '"ativo":'+IIf(SB1->B1_MSBLQL=="1","0","1")+','// 0=inativo | 1=ativo
            cPostParms += '"tipo":"produto"'
            cPostParms += '}'

            nRecAnt := SB1->(Recno())
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
            SB1->(DbGoto(nRecAnt))
            If oObjJson:SUCCESS
                lRetorno := .T.
                If !lSchedule
                    If !lCargaIni
                        MsgInfo(AllTrim(SB1->B1_COD)+": sucesso !!")
                    Endif    
                Endif    
                If nMaxCount == 1
                    RecLock("SB1",.F.)
                    SB1->B1_XBLUEEZ := "E"
                    MsUnLock()
                Endif
            Else
                cMsgErro := Upper(AllTrim(oObjJson:MESSAGE))
            Endif
            SB1->(DbGoto(nRecAtu))
        Endif
        If !lRetorno
            SB1->(DbGoto(nRecAnt))
            If !lSchedule
                If !lCargaIni
                    MsgInfo(AllTrim(SB1->B1_COD)+": "+cMsgErro)
                Endif    
            Endif    
            If nMaxCount == 1
                RecLock("SB1",.F.)
                SB1->B1_XBLUEEZ := "X"
                MsUnLock()
            Endif
            SB1->(DbGoto(nRecAtu))
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
