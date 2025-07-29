#include "protheus.ch"
#include "topconn.ch"
#include "restful.ch"
#include "totvs.ch"
#include "tbiconn.ch"

WSRESTFUL PVCONSULTAREST DESCRIPTION "Webservice para consulta de pedidos de venda" FORMAT APPLICATION_JSON
    WSMETHOD GET V1 DESCRIPTION "Consulta de Pedido de Venda via GET" PATH "/V1/PEDIDODEVENDA" WSSYNTAX "/V1/PEDIDODEVENDA" TTALK "V1"
END WSRESTFUL

WSMETHOD GET V1 WSSERVICE PVCONSULTAREST
    // headers via GET PARAMS
    Local jHeader := ""
    jHeader := oRest:getHeaderRequest()

    Local lRet      := .T.
    Local oJsonRet  := JsonObject():New()
    Local oJsonProd := Nil
    Local aProdutos := {}
    Local cNumPed   := AllTrim(jHeader["pedido"])
    Local cCnpjCpf  := AllTrim(jHeader["cnpj"])
    Local cDataEmi  := AllTrim(jHeader["dataemissao"])
    Local dDataEmi  := StoD(cDataEmi)
    Local cAliasPed := GetNextAlias()
    Local lAchou    := .F.

    If Empty(cNumPed) .Or. Empty(cCnpjCpf) .Or. Empty(cDataEmi)
        SetRestFault(400, "Parâmetros obrigatórios: Número do Pedido, CNPJ e Data de Emissão.")
        Return .F.
    EndIf

    If Select(cAliasPed) > 0
        (cAliasPed)->(DbCloseArea())
    EndIf

    BeginSql Alias cAliasPed
        SELECT
            SC5.C5_NUM,
            SC5.C5_CLIENTE,
            SC5.C5_LOJACLI,
            SA1.A1_NOME,
            SA1.A1_CGC,
            SC5.C5_EMISSAO,
            SC6.C6_PRODUTO,
            SC6.C6_QTDVEN, 
            SC6.C6_VALOR,
            SC6.C6_TES
        FROM
            %Table:SC5% SC5
        LEFT JOIN
            %Table:SC6% SC6 ON SC6.C6_FILIAL = SC5.C5_FILIAL AND SC6.C6_NUM = SC5.C5_NUM AND SC6.D_E_L_E_T_ = ''
        LEFT JOIN
            %Table:SA1% SA1 ON SA1.A1_LOJA = SC5.C5_LOJACLI AND SA1.A1_COD = SC5.C5_CLIENTE AND SA1.D_E_L_E_T_ = ''
        WHERE SC5.C5_NUM = %Exp:cNumPed%
            AND SA1.A1_CGC = %Exp:cCnpjCpf%
            AND SC5.C5_EMISSAO = %Exp:dDataEmi%
    EndSql

    Begin Sequence
        DbSelectArea(cAliasPed)

        If !(cAliasPed)->(Eof())
            lAchou := .T.
            oJsonRet["numero"]    := AllTrim((cAliasPed)->C5_NUM)
            oJsonRet["emissao"]   := AllTrim((cAliasPed)->C5_EMISSAO)
            oJsonRet["cliente"]   := AllTrim((cAliasPed)->C5_CLIENTE)
            oJsonRet["loja"]      := AllTrim((cAliasPed)->C5_LOJACLI)
            oJsonRet["nome"]      := AllTrim((cAliasPed)->A1_NOME)
            oJsonRet["cnpj"]      := AllTrim((cAliasPed)->A1_CGC)

            While !(cAliasPed)->(Eof())
                If !Empty((cAliasPed)->C6_PRODUTO)
                    oJsonProd := JsonObject():New()
                    oJsonProd["produto"]    := AllTrim((cAliasPed)->C6_PRODUTO)
                    oJsonProd["qtd"]        := (cAliasPed)->C6_QTDVEN
                    oJsonProd["valor"]      := (cAliasPed)->C6_VALOR
                    oJsonProd["tes"]        := AllTrim((cAliasPed)->C6_TES)
                    AAdd(aProdutos, oJsonProd)
                    FreeObj(oJsonProd)
                EndIf
                (cAliasPed)->(DbSkip())
            EndDo
            oJsonRet["produtos"] := aProdutos
        EndIf
        (cAliasPed)->(DbCloseArea())
    End Sequence

    If !lAchou
        SetRestFault(404, "Pedido não encontrado ou dados inválidos.")
        Return .F.
    EndIf

    self:SetResponse(oJsonRet:ToJson())
    Return lRet
