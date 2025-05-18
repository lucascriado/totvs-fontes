#include "totvs.ch"
#include "protheus.ch"
#include "tbiconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ BLEZSA2 ¦ Autor ¦ Fábrica ERP.BR   ¦ Data  ¦ Jul-2023      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Integração BlueEz - Fornecedores.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo BLUEEZ											  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function BLEZSA2(bzFornec)

Local lSchedule := .F.
Local nMaxCount := IIf(bzFornec == Nil, 1, 1)
Local cBlzToken := ""

cBlzToken := U_BLEZAUT(.F.) // Atualiza o token de autenticação

MsgRun("Aguarde, integração BlueEz fornecedores","Processando",{|| u_ProcBzSa2(lSchedule,nMaxCount,bzFornec,cBlzToken) })

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ProcBzSa2 ¦ Autor ¦ Fábrica ERP.BR ¦ Data  ¦   Jul-2023    ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Executa integração BlueEz.               				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo BLUEEZ											  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function ProcBzSa2(lSchedule,nMaxCount,bzFornec,cBlzToken)

Local cBlezUrl    := AllTrim(GetMv("CO_BLEZURL")) // https://apiqa.blueez.com.br
Local cResource   := "/api/v1/erp/pessoas/PostPessoa"
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

If bzFornec <> Nil
    If !MsgYesNo("Confirma integração BlueEz para o fornecedor "+AllTrim(SA2->A2_NOME)+" ?")
        Return
    Endif
Endif

If ValType(oRest) == "O"

    AAdd(aHeader, "Content-Type: application/json; charset=UTF-8")
    AAdd(aHeader, "Accept: application/json")
    AAdd(aHeader, "User-Agent: Chrome/65.0 (compatible; Protheus "+GetBuild()+")")
    AAdd(aHeader, "Authorization: Bearer "+cBlzToken)

    cQuery := " SELECT R_E_C_N_O_ AS RECSA2 "
    cQuery += " FROM "+RetSqlName("SA2") "
    cQuery += " WHERE D_E_L_E_T_ <> '*' "
    If lCargaIni
        cQuery += " AND A2_MSBLQL <> '1' "
    Endif
    If bzFornec != Nil
        cQuery += " AND A2_FILIAL = '"+xFilial("SA2")+"' AND A2_COD = '"+AllTrim(bzFornec)+"' "
    ElseIf lSchedule
        cQuery += " AND A2_XBLUEEZ IN('S','X') "
    Else
        cQuery += " AND A2_XBLUEEZ IN('S','X') "
    Endif
    cQuery += " AND A2_CGC <> ' ' "
    cQuery += " ORDER BY A2_COD, A2_LOJA "
    DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TRBLEZ", .F., .T.)

    DbSelectArea("TRBLEZ")
    TRBLEZ->(DbGotop())
    If !Eof()
        While !Eof()

            DbSelectArea("SA2")
            SA2->(DbGoto(TRBLEZ->RECSA2))
            nRecAtu := SA2->(Recno())

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
                    SA2->(DbGoto(nRecAnt))
                    If oObjJson:SUCCESS
                        lRetorno := .T.
                        If !lSchedule
                            If !lCargaIni
                                MsgInfo(AllTrim(SA2->A2_COD)+": sucesso !!")
                            Endif
                        Endif    
                        If nMaxCount == 1
                            RecLock("SA2",.F.)
                            SA2->A2_XBLUEEZ := "E"
                            MsUnLock()
                        Endif
                    Else
                        cMsgErro := Upper(AllTrim(oObjJson:MESSAGE))
                    Endif
                    SA2->(DbGoto(nRecAtu))
                Endif
                If !lRetorno
                    SA2->(DbGoto(nRecAnt))
                    If !lSchedule
                        If !lCargaIni
                            MsgInfo(AllTrim(SA2->A2_COD)+": "+cMsgErro)
                        Endif    
                    Endif    
                    If nMaxCount == 1
                        RecLock("SA2",.F.)
                        SA2->A2_XBLUEEZ := "X"
                        MsUnLock()
                    Endif
                    SA2->(DbGoto(nRecAtu))
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
            
            fNomeForne := u_zLimpaEsp(SA2->A2_NOME)
            fNomeReduz := u_zLimpaEsp(SA2->A2_NREDUZ)
            cPostParms += '{'
            cPostParms += '"cnpj_cpf":"'+SA2->A2_CGC+'",'
            cPostParms += '"razao_social":"'+AllTrim(fNomeForne)+'",'
            cPostParms += '"nome_fantasia":"'+AllTrim(SA2->A2_NREDUZ)+'",'
            //
            cPostParms += '"cep":"'+SA2->A2_CEP+'",'
            cPostParms += '"endereco":"'+AllTrim(SA2->A2_END)+'",'
            cPostParms += '"bairro":"'+AllTrim(SA2->A2_BAIRRO)+'",'
            cPostParms += '"cidade":"'+AllTrim(SA2->A2_MUN)+'",'
            cPostParms += '"estado":"'+AllTrim(SA2->A2_EST)+'",'
            cPostParms += '"complemento":"'+AllTrim(SA2->A2_ENDCOMP)+'",'
            //
            cPostParms += '"cliente":0,'
            cPostParms += '"fornecedor":1,'
            cPostParms += '"email":"'+Lower(AllTrim(SA2->A2_EMAIL))+'",'
            cPostParms += '"telefone":"'+AllTrim(SA2->A2_TEL)+'",'
            cPostParms += '"site":"'+Lower(AllTrim(SA2->A2_HPAGE))+'",'
            cPostParms += '"porte":"G",'
            cPostParms += '"numero_funcionarios":500,'
            cPostParms += '"ativa":'+IIf(SA2->A2_MSBLQL=="1","0","1")+','// 0=inativo | 1=ativo
            cPostParms += '"homologado":false'
            cPostParms += '}'

            nRecAnt := SA2->(Recno())
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
            SA2->(DbGoto(nRecAnt))
            If oObjJson:SUCCESS
                lRetorno := .T.
                If !lSchedule
                    If !lCargaIni
                        MsgInfo(AllTrim(SA2->A2_COD)+": sucesso !!")
                    Endif    
                Endif    
                If nMaxCount == 1
                    RecLock("SA2",.F.)
                    SA2->A2_XBLUEEZ := "E"
                    MsUnLock()
                Endif    
            Else
                cMsgErro := Upper(AllTrim(oObjJson:MESSAGE))
            Endif
            SA2->(DbGoto(nRecAtu))
        Endif
        If !lRetorno
            SA2->(DbGoto(nRecAnt))
            If !lSchedule
                If !lCargaIni
                    MsgInfo(AllTrim(SA2->A2_COD)+": "+cMsgErro)
                Endif    
            Endif    
            If nMaxCount == 1
                RecLock("SA2",.F.)
                SA2->A2_XBLUEEZ := "X"
                MsUnLock()
            Endif
            SA2->(DbGoto(nRecAtu))
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

If lRet
    If Val(SA2->A2_CGC) == 0
        lRet := .F.
    Endif
Endif

Return(lRet)
