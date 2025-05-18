#include "totvs.ch"
#include "protheus.ch"
#include "tbiconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ AFGTSC7 ¦ Autor ¦ Fábrica ERP.BR   ¦ Data  ¦ 09/05/2022    ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Integração GtPlan - Pedidos de Compra (Retorno).			  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AFIP											  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function AFGTSC7()

Local lSchedule := .F.

MsgRun("Aguarde, integração gtplan pedidos de compra...","Processando",{|| u_ProcGtPed(lSchedule) })

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ ProcGtPed  ¦ Autor ¦ Fábrica ERP.BR ¦ Data  ¦ 09/05/2022   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Executa integração GtPlan.               				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AFIP											  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function ProcGtPed(lSchedule)

Local cURI        := AllTrim(GetMv("MV_ZURLRET")) // https://api-qa.gtplan.net
Local cResource   := "/Mrp_po_get_id"
Local oRest       := FwRest():New(cURI)
Local cUserId     := AllTrim(GetMv("MV_ZUSRGTP")) // BBD9E0D8800D07305101D4067FA8D4F5
Local cPassword   := AllTrim(GetMv("MV_ZPSWGTP")) // A4A8A31750A23DE2DA88EF6A491DFD5C
Local cGetParms   := "status=2"
Local nTimeOut    := 120
Local aHeader     := {}
Local cHeaderGet  := ""
Local cHeaderPost := ""
Local cRetorno    := ""
Local oObjJson    := Nil
Local oObjJret    := Nil
Local _p
Local _id
Local i

If ValType(oRest) == "O"

    AAdd(aHeader, "Content-Type: application/json; charset=UTF-8")
    AAdd(aHeader, "Accept: application/json")
    AAdd(aHeader, "User-Agent: Chrome/65.0 (compatible; Protheus "+GetBuild()+")")
    AAdd(aHeader, "Authorization: Basic "+Encode64(cUserId+":"+cPassword))

    cRetorno := HttpGet(cURI+cResource, cGetParms, nTimeOut, aHeader, @cHeaderGet)
    
    lOkJson  := .F.
    oObjJson := JsonObject():New()
    RetJson  := oObjJson:FromJson(cRetorno)
    jNames   := oObjJson:RESULT:GetNames()
    If ValType(jNames) == "A"
        For i := 1 to Len(jNames)
            If jNames[i] == "DATA"
                lOkJson := .T.
                Exit
            Endif
        Next i
    Endif
    If !lOkJson
        Return
    Endif

    If FWJsonDeserialize(cRetorno, @oObjJson)
        If ValType(oObjJson:RESULT:DATA) == "O"
            If ValType(oObjJson:RESULT:DATA:ORDEM) == "A"
                aPedCom := oObjJson:RESULT:DATA:ORDEM
                For _p := 1 to Len(aPedCom)

                    cNumGtPla   := ""
                    cNumProth   := ""
                    aIdPoParc   := {}
                    cMensErro   := ""
                    cHeaderPost := ""

                    lPedComOk := GravaPedido( aPedCom[_p], @cNumGtPla, @aIdPoParc, @cNumProth, @cMensErro )
                    If lPedComOk
                        cCodRet := "3"
                    Else
                        cCodRet := "4"
                    Endif

                    cPostParms := ""
                    cPostParms += '{ "Ordem": 
                    cPostParms += '[{'
                    cPostParms += '"nrDocumentoExterno": "'+cNumGtPla+'",'
                    cPostParms += '"cdStatus": "'+cCodRet+'",'
                    cPostParms += '"cdOrdem": "'+cNumProth+'",'
                    cPostParms += '"dsLogError": "'+cMensErro+'",'
                    cPostParms += '"Itens": ['
                    For _id := 1 to Len(aIdPoParc)
                        cPostParms += '{'
                        cPostParms += '"IdPoParc": "'+aIdPoParc[_id]+'",'
                        cPostParms += '"cdStatus": "'+cCodRet+'",'
                        cPostParms += '"dsLogError": "'+cMensErro+'"'
                        cPostParms += '}'
                        If Len(aIdPoParc) > _id
                            cPostParms += ','
                        Endif
                    Next _id
                    cPostParms += ']'
                    cPostParms += '}]'
                    cPostParms += '}'

                    cRetUpd := HttpPost(cURI+"/Mrp_po_upd_id", "model=1", cPostParms, nTimeOut, aHeader, @cHeaderPost)
                    If FWJsonDeserialize(cRetUpd, @oObjJret)
                        nTotReg := oObjJret:RESULT:SUCCESS
                    Endif

                Next _p
            Endif
        Endif
    Endif

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ GravaPedido ¦ Autor ¦ Fábrica ERP.BR  ¦ Data ¦ 12/05/2022  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Integração GtPlan - Gravação do Pedido de Compra.		  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AFIP											  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function GravaPedido(aPedCom, cNumGtPla, aIdPoParc, cNumProth, cMensErro)

Local lRetOk  := .T.
Local aCabec  := {}
Local aItens  := {}
Local cFilBk  := cFilAnt
Local cNumPed := ""
Local _it
Local _en

Private lMsErroAuto    := .F.
Private lMsHelpAuto    := .T.
Private lAutoErrNoFile := .T.

zAprovad := aPedCom:CDAPROVADOR
zComprad := aPedCom:CDCOMPRADOR
zCondPag := StrZero(Val(aPedCom:CDCONDPAGAMENTO),3)
zEstabel := aPedCom:CDESTABELECIMENTO
zLocalEn := aPedCom:CDLOCALENTRADA
zSolicit := IIf(!Empty(aPedCom:CDSOLICITACAO), StrZero(Val(aPedCom:CDSOLICITACAO),6), "")
zUsuario := aPedCom:CDUSUARIO
zObserva := aPedCom:DSOBSERVACAOORD
zDtEsper := aPedCom:DTESPERADA
zFornece := aPedCom:IDFORNECEDOR
zUrgente := aPedCom:IEURGENTE
zNrDocEx := aPedCom:NRDOCUMENTOEXTERNO
zVlPedid := Val(aPedCom:VLPEDIDO)
aItensPc := aPedCom:ITENS

If !FWFilExist("01",zEstabel)
    cMensErro := "Filial nao cadastrada: "+zEstabel
    lRetOk := .F.
Else
    cFilAnt := zEstabel
Endif

If lRetOk
    If Empty(zSolicit)
        cMensErro := "Solicitacao de compra nao informada"
        lRetOk := .F.
    Endif
Endif

If lRetOk
    DbSelectArea("SA2")
    DbSetOrder(1)
    If !DbSeek( xFilial("SA2") + Substr(zFornece,1,6) + Substr(zFornece,7,2) )
        cMensErro := "Fornecedor nao cadastrado: "+zFornece
        lRetOk := .F.
    Endif
Endif

If lRetOk
    DbSelectArea("SE4")
    DbSetOrder(1)
    If !DbSeek( xFilial("SE4") + zCondPag )
        cMensErro := "Condicao de pagamento nao cadastrada: "+zCondPag
        lRetOk := .F.
    Endif
Endif

If lRetOk
    DbSelectArea("NNR")
    DbSetOrder(1)
    If !DbSeek( xFilial("NNR") + zLocalEn )
        cMensErro := "Armazem nao cadastrado: "+zLocalEn
        lRetOk := .F.
    Endif
Endif

If lRetOk
    cNumPed := GetNumSC7(.T.)
    SC7->(DbSetOrder(1))
    While SC7->(DbSeek(xFilial("SC7")+cNumPed))
        cNumPed := GetNumSC7(.T.)
    Enddo
    AAdd(aCabec,{ "C7_NUM"    , cNumPed,         Nil })
    AAdd(aCabec,{ "C7_EMISSAO", Date(),          Nil })
    AAdd(aCabec,{ "C7_FORNECE", SA2->A2_COD,     Nil })
    AAdd(aCabec,{ "C7_LOJA"   , SA2->A2_LOJA,    Nil })
    AAdd(aCabec,{ "C7_COND"   , SE4->E4_CODIGO,  Nil })
    AAdd(aCabec,{ "C7_CONTATO", SA2->A2_CONTATO, Nil })
    AAdd(aCabec,{ "C7_FILENT" , cFilAnt,         Nil })			
    AAdd(aCabec,{ "C7_USER"   , "000000",        Nil }) // Validar com Afip
Endif

For _it := 1 to Len(aItensPc)

    zProduto := PadR(aItensPc[_it]:CDMATERIAL,15)
    zUnidMed := aItensPc[_it]:CDUNIDADEMEDIDACOMPRA
    zObsItem := zObserva +"|"+aItensPc[_it]:DSOBSERVACAOITEM
    zIdPoIte := aItensPc[_it]:IDPOITEM
    zQuantid := Val(aItensPc[_it]:QTMATERIAL)
    zVlrIpi  := Val(aItensPc[_it]:VLIPI)
    zVlUnit  := Val(aItensPc[_it]:VLUNITARIO)
    zNumSol  := ""
    zIteSol  := ""
    scSaldo  := 0
    zQtdSol  := 0
    aEntrega := aItensPc[_it]:ENTREGAS

    If lRetOk
        DbSelectArea("SB1")
        DbSetOrder(1)
        If !DbSeek( xFilial("SB1") + zProduto )
            cMensErro := "Produto nao cadastrado: "+zProduto
            lRetOk := .F.
            Exit
        Endif
    Endif    

    If lRetOk .And. !Empty(zSolicit)
        DbSelectArea("SC1")
        DbSetOrder(2)
        If !DbSeek( cFilAnt + zProduto + zSolicit )
            cMensErro := "SC "+zSolicit+" nao cadastrada para o produto "+zProduto
            lRetOk := .F.
        Else
            zNumSol := SC1->C1_NUM
            zIteSol := SC1->C1_ITEM
            scSaldo := SC1->C1_QUANT - SC1->C1_QUJE
        Endif
    Endif

    For _en := 1 to Len(aEntrega)

        zDatEntr := aEntrega[_en]:DTENTREGASOLICITADA
        zDatEntr := StoD((Substr(zDatEntr,5,4)+Substr(zDatEntr,3,2)+Substr(zDatEntr,1,2)))
        zIdPoPar := aEntrega[_en]:IDPOPARC
        zNmParce := aEntrega[_en]:NMPARCELA
        zQtdeEnt := Val(aEntrega[_en]:QTENTREGASOLICITADA)
        zTotPed  := Round((zQtdeEnt * zVlUnit),2)
        zQtdSol  := IIf(zQtdeEnt <= scSaldo, zQtdeEnt, scSaldo)  
        zAlqIpi  := 0
        If zVlrIpi > 0
            zAlqIpi := Round(((zVlrIpi / zTotal) * 100),0)
        Endif

        AAdd(aIdPoParc,zIdPoPar)

        If lRetOk
            aLinha := {}			
            AAdd(aLinha,{ "C7_PRODUTO", SB1->B1_COD,     Nil })
            AAdd(aLinha,{ "C7_QUANT"  , zQtdeEnt,        Nil })
            AAdd(aLinha,{ "C7_PRECO"  , zVlUnit,         Nil })
            AAdd(aLinha,{ "C7_TOTAL"  , zTotPed,         Nil })
            AAdd(aLinha,{ "C7_DATPRF" , zDatEntr,        Nil })
            AAdd(aLinha,{ "C7_CC"     , SB1->B1_CC,      Nil })
            AAdd(aLinha,{ "C7_OBS"    , zObsItem,        Nil })
            AAdd(aLinha,{ "C7_LOCAL"  , NNR->NNR_CODIGO, Nil })
            AAdd(aLinha,{ "C7_DESCRI" , SB1->B1_DESC,    Nil })
            AAdd(aLinha,{ "C7_IPI"    , zAlqIpi,         Nil })
            AAdd(aLinha,{ "C7_VALIPI" , zVlrIpi,         Nil })
            AAdd(aLinha,{ "C7_NUMSC"  , zNumSol,         Nil })
            AAdd(aLinha,{ "C7_ITEMSC" , zIteSol,         Nil })
            AAdd(aLinha,{ "C7_QTDSOL" , zQtdSol,         Nil })
            AAdd(aLinha,{ "C7_ZZGTP"  , "S",             Nil })
            AAdd(aLinha,{ "C7_ZZNRO"  , zNrDocEx,        Nil })
            AAdd(aLinha,{ "C7_ZZIDI"  , zIdPoIte,        Nil })
            AAdd(aLinha,{ "C7_ZZIDP"  , zIdPoPar,        Nil })
            AAdd(aLinha,{ "C7_XMODAL" , "4",             Nil }) // Adicionado em 16/09/2022
            AAdd(aLinha,{ "C7_XOPELOG", "S",             Nil }) // Adicionado em 16/09/2022
            AAdd(aItens,aLinha)		
        Endif

    Next _en

Next _it

If lRetOk

    Begin Transaction

    lMsErroAuto := .F.
    MSExecAuto({|x,y,z,w| MATA120(x,y,z,w)},1, aCabec, aItens, 3)
    If lMsErroAuto
        lRetOk := .F.			
        DisarmTransaction()
        aErroAuto := GetAutoGrLog()
        cMensErro := u_ExtractErr(aErroAuto)
        If Empty(cMensErro)
            cMensErro := "Falha na gravacao do pedido: "+zNrDocEx
        Endif
    Else	
        DbSelectArea("SC7")
        DbSetOrder(1)
        DbSeek( cFilAnt + cNumPed )
        zRec := SC7->(Recno())
        While !Eof() .And. SC7->(C7_FILIAL + C7_NUM) == cFilAnt + cNumPed

            DbSelectArea("SC7")
            SC7->(DbSkip())
        Enddo
        SC7->(DbGoto(zRec))
    Endif

    End Transaction
    MsUnLockAll()

Endif

cFilAnt := cFilBk

cNumGtPla := zNrDocEx
cNumProth := cNumPed

Return(lRetOk)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ ExtractErr ¦ Autor ¦ Luis Brandini   ¦  Data ¦ 12/05/2022  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Tratamento para extrair a mensagem de erro.				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AFIP   										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function ExtractErr(aErro)

Local cMensagem := ""
Local _x

For _x := 1 to Len(aErro)
	If _x == 1
		cMensagem += AllTrim(aErro[_x])
	Endif
	nPos := AT("< --",aErro[_x])
	If nPos > 0
		cMensagem += AllTrim(aErro[_x])
		Exit
	Endif
Next _x

Return(cMensagem)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ SCHGTSC7 ¦ Autor ¦ Fábrica ERP.BR  ¦ Data  ¦ 22/03/2022    ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Integração GtPlan - Pedido de Compra.					  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AFIP											  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function SCHGTSC7()

Local lSchedule := .T.

//ConOut( "GtPlan - Integração Pedido de Compra - "+DtoC(Date())+" - "+Time()+" - Início" )
cMessage := "GtPlan - Integração Pedido de Compra - "+DtoC(Date())+" - "+Time()+" - Início"
FwLogMsg("INFO", /*cTransactionId*/, "AFIP", FunName(), "", "01", cMessage, 0, (Seconds()), {})

PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01"

//ConOut( "GtPlan - Integração Pedido de Compra - "+DtoC(Date())+" - "+Time()+" - Fim" )
cMessage := "GtPlan - Integração Pedido de Compra - "+DtoC(Date())+" - "+Time()+" - Fim"
FwLogMsg("INFO", /*cTransactionId*/, "AFIP", FunName(), "", "01", cMessage, 0, (Seconds()), {})

u_ProcGtPed(lSchedule)

Return
