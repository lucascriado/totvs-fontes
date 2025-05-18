#include "protheus.ch"
#include "restful.ch"

WSRESTFUL PEDIDO_COMPRA DESCRIPTION "Webservice Pedido de Compra" FORMAT APPLICATION_JSON
 
	WSMETHOD POST V1 DESCRIPTION "Inclusão de Pedido de Compra" PATH "/V1" WSSYNTAX "/V1" TTALK "V1"

END WSRESTFUL

WSMETHOD POST V1 WSSERVICE PEDIDO_COMPRA

Local lRet     := .T.
Local cJson    := Self:GetContent()
Local oJson    := JsonObject():New()
Local oJsonRet := JsonObject():New()
Local aCadEmp  := FwLoadSm0()
Local aLog 	   := {}
Local aCabec   := {}
Local aItem    := {}
Local aItens   := {}
Local aRatcc   := {}
Local i
Local r
Local x

Private lMsErroAuto    := .F.
Private lMsHelpAuto    := .T.
Private lAutoErrNoFile := .T.

self:SetContentType( "application/json" )

oJson:FromJson(cJson)

cBlzEmp := oJson["empresa"]
cBlzFil := oJson["filial"]
cCgcFor := oJson["cgcfor"]
dEmissa := StoD(oJson["emissao"])
cCondPg := oJson["condpg"]
lAdiant := oJson["adiant"]
nPercAd := oJson["percad"]
cLinkBl := oJson["linkbl"]
cTpFret := oJson["tpfrete"]
nVFrete := oJson["frete"]
nSeguro := oJson["seguro"]
nDespes := oJson["despesa"]
nDescon := oJson["descont"]
cNrBlez := oJson["nr_blueez"]

// 1. Empresa e Filial
lEmpFil := .F.
For i := 1 to Len(aCadEmp)
	If cBlzEmp == AllTrim(aCadEmp[i][1]) .And. cBlzFil == AllTrim(aCadEmp[i][2])
		lEmpFil := .T.
		cFilAnt := cBlzFil
	Endif
Next i
If !lEmpFil
	oJsonRet["success"] := .F.
	oJsonRet["coderr"]  := 1001
	oJsonRet["msgerr"]  := "Empresa/Filial nao localizada: "+cBlzEmp+"-"+cBlzFil
	self:SetResponse( oJsonRet:toJson() )
	Return(.F.)
Endif

// 2. Emissão
If dEmissa < (Date()-30)
	oJsonRet["success"] := .F.
	oJsonRet["coderr"]  := 1002
	oJsonRet["msgerr"]  := "Data de emissao invalida (menor que 30dd): "+DtoC(dEmissa)
	self:SetResponse( oJsonRet:toJson() )
	Return(.F.)
Endif

// 3. Fornecedor
DbSelectArea("SA2")
DbSetOrder(3)
If !DbSeek( xFilial("SA2") + cCgcFor )
	oJsonRet["success"] := .F.
	oJsonRet["coderr"]  := 1003
	oJsonRet["msgerr"]  := "Fornecedor nao cadastrado: "+cCgcFor
	self:SetResponse( oJsonRet:toJson() )
	Return(.F.)
Else
	If SA2->A2_MSBLQL == "1"
		oJsonRet["success"] := .F.
		oJsonRet["coderr"]  := 1003
		oJsonRet["msgerr"]  := "Fornecedor bloqueado: "+cCgcFor
		self:SetResponse( oJsonRet:toJson() )
		Return(.F.)
	Endif
Endif

// 4. Condição de Pagamento
DbSelectArea("SE4")
DbSetOrder(1)
If !DbSeek( xFilial("SE4") + cCondPg )
	oJsonRet["success"] := .F.
	oJsonRet["coderr"]  := 1004
	oJsonRet["msgerr"]  := "Condicao de pagamento nao cadastrada: "+cCondPg
	self:SetResponse( oJsonRet:toJson() )
	Return(.F.)
Else
	If SE4->E4_MSBLQL == "1"
		oJsonRet["success"] := .F.
		oJsonRet["coderr"]  := 1004
		oJsonRet["msgerr"]  := "Condicao de pagamento bloqueada: "+cCondPg
		self:SetResponse( oJsonRet:toJson() )
		Return(.F.)
	Endif
Endif

// 5. Itens
lItensOk := .T.
For i := 1 to Len(oJson["itens"])

	bProd := PadR(AllTrim(oJson["itens"][i]["prod"]),TamSx3("B1_COD")[1])
	bQtde := oJson["itens"][i]["quant"]
	bPrec := oJson["itens"][i]["preco"]
	bEntr := StoD(oJson["itens"][i]["dtentr"])
	bccIt := PadR(AllTrim(oJson["itens"][i]["ccitem"]),TamSx3("CTT_CUSTO")[1])

	// 5.1 - Produto
	DbSelectArea("SB1")
	DbSetOrder(1)
	If !DbSeek( xFilial("SB1") + bProd )
		oJsonRet["success"] := .F.
		oJsonRet["coderr"]  := 1005
		oJsonRet["msgerr"]  := "Produto nao cadastrado: "+AllTrim(bProd)
		self:SetResponse( oJsonRet:toJson() )
		lItensOk := .F.
		Exit
	Else
		If SB1->B1_MSBLQL == "1"
			oJsonRet["success"] := .F.
			oJsonRet["coderr"]  := 1005
			oJsonRet["msgerr"]  := "Produto bloqueado: "+AllTrim(bProd)
			self:SetResponse( oJsonRet:toJson() )
			lItensOk := .F.
			Exit
		ElseIf !Empty(SB1->B1_TE)
			DbSelectArea("SF4")
			DbSetOrder(1)
			DbSeek( xFilial("SF4") + SB1->B1_TE )
			If SF4->F4_MSBLQL == "1"
				oJsonRet["success"] := .F.
				oJsonRet["coderr"]  := 1005
				oJsonRet["msgerr"]  := "Produto com Tes de Entrada "+SB1->B1_TE+" bloqueado: "+AllTrim(bProd)
				self:SetResponse( oJsonRet:toJson() )
				lItensOk := .F.
				Exit
			Endif
		Endif
	Endif

	// 5.2 - Centro de custo (associado ao item)
	If !Empty(bccIt)
		DbSelectArea("CTT")
		DbSetOrder(1)
		If !DbSeek( xFilial("CTT") + bccIt )
			oJsonRet["success"] := .F.
			oJsonRet["coderr"]  := 1006
			oJsonRet["msgerr"]  := "Centro de custo nao cadastrado (associado ao item "+AllTrim(STR(i))+"): "+AllTrim(bccIt)
			self:SetResponse( oJsonRet:toJson() )
			lItensOk := .F.
			Exit
		Else
			If (!Empty(CTT->CTT_DTEXSF) .And. Date() > CTT->CTT_DTEXSF) .Or. CTT->CTT_BLOQ == "1"
				oJsonRet["success"] := .F.
				oJsonRet["coderr"]  := 1007
				oJsonRet["msgerr"]  := "Centro de custo bloqueado (associado ao item "+AllTrim(STR(i))+"): "+AllTrim(bccIt)
				self:SetResponse( oJsonRet:toJson() )
				lItensOk := .F.
				Exit
			Endif
		Endif
	Endif

	// 5.3 - Quantidade
	If bQtde <= 0
		oJsonRet["success"] := .F.
		oJsonRet["coderr"]  := 1008
		oJsonRet["msgerr"]  := "Quantidade invalida: "+AllTrim(STR(bQtde))
		self:SetResponse( oJsonRet:toJson() )
		lItensOk := .F.
		Exit
	Endif

	// 5.4 - Preço
	If bPrec <= 0
		oJsonRet["success"] := .F.
		oJsonRet["coderr"]  := 1009
		oJsonRet["msgerr"]  := "Preco unitario invalido: "+AllTrim(STR(bPrec))
		self:SetResponse( oJsonRet:toJson() )
		lItensOk := .F.
		Exit
	Endif

	// 5.5 - Entrega
	If bEntr < Date()
		oJsonRet["success"] := .F.
		oJsonRet["coderr"]  := 1010
		oJsonRet["msgerr"]  := "Data de entrega invalida: "+DtoC(bEntr)
		self:SetResponse( oJsonRet:toJson() )
		lItensOk := .F.
		Exit
	Endif

	// 5.6 - Rateio
	bTotRat := 0
	lOkRate := .T.
	For r := 1 to Len(oJson["itens"][i]["rateio"])
		bcCusto := oJson["itens"][i]["rateio"][r]["ccusto"]
		bPercen := oJson["itens"][i]["rateio"][r]["percen"]
		bTotRat += bPercen
		DbSelectArea("CTT")
		DbSetOrder(1)
		If !DbSeek( xFilial("CTT") + PadR(bcCusto,TamSx3("CTT_CUSTO")[1]) )
			oJsonRet["success"] := .F.
			oJsonRet["coderr"]  := 1011
			oJsonRet["msgerr"]  := "Centro de custo nao cadastrado: "+AllTrim(bcCusto)
			self:SetResponse( oJsonRet:toJson() )
			lOkRate := .F.
			Exit
		Else
			If (!Empty(CTT->CTT_DTEXSF) .And. Date() > CTT->CTT_DTEXSF) .Or. CTT->CTT_BLOQ == "1"
				oJsonRet["success"] := .F.
				oJsonRet["coderr"]  := 1012
				oJsonRet["msgerr"]  := "Centro de custo bloqueado: "+AllTrim(bcCusto)
				self:SetResponse( oJsonRet:toJson() )
				lOkRate := .F.
				Exit
			Endif
		Endif
	Next r
	If lOkRate
		If bTotRat > 0 .And. bTotRat <> 100
			oJsonRet["success"] := .F.
			oJsonRet["coderr"]  := 1013
			oJsonRet["msgerr"]  := "Rateio invalido no Item "+AllTrim(STR(i))+": "+AllTrim(STR(bTotRat))
			self:SetResponse( oJsonRet:toJson() )
			lItensOk := .F.
			Exit
		Endif
	Else
		lItensOk := .F.
		Exit
	Endif	

Next i
If !lItensOk
	Return(.F.)
Endif

// 7. Id BlueEz
cQuery := " SELECT C7_NUM NUMERO "
cQuery += " FROM "+RetSqlName("SC7")
cQuery += " WHERE C7_XNRBLEZ = '"+cNrBlez+"' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TRB7", .F., .T.)
TRB7->(DbGotop())
c7BlueEz := TRB7->NUMERO
TRB7->(DbCloseArea())
If !Empty(c7BlueEz)
	oJsonRet["success"] := .F.
	oJsonRet["coderr"]  := 1014
	oJsonRet["msgerr"]  := "No. BlueEz ja cadastrado: "+cNrBlez
	oJsonRet["numero"]  := c7BlueEz
	self:SetResponse( oJsonRet:toJson() )
	Return(.F.)
Endif

// 8. Tipo de Frete
If nVFrete > 0
	If !(cTpFret $("C,F,T,R,D,S"))
		oJsonRet["success"] := .F.
		oJsonRet["coderr"]  := 1036
		oJsonRet["msgerr"]  := "Tipo de frete invalido (C,F,T,R,D,S): "+cTpFret
		self:SetResponse( oJsonRet:toJson() )
		Return(.F.)
	Endif
Endif

// Inicia a gravação do pedido
cNumPed := GetNumSC7()
SC7->(DbSetOrder(1))
While SC7->(DbSeek(xFilial("SC7")+cNumPed))
	cNumPed := GetNumSC7()
Enddo

AAdd(aCabec,{ "C7_NUM"    , cNumPed        , Nil })
AAdd(aCabec,{ "C7_EMISSAO", dEmissa        , Nil })
AAdd(aCabec,{ "C7_FORNECE", SA2->A2_COD    , Nil })
AAdd(aCabec,{ "C7_LOJA"   , SA2->A2_LOJA   , Nil })
AAdd(aCabec,{ "C7_COND"   , SE4->E4_CODIGO , Nil })
AAdd(aCabec,{ "C7_CONTATO", SA2->A2_CONTATO, Nil })
AAdd(aCabec,{ "C7_FILENT" , cFilAnt        , Nil })			
AAdd(aCabec,{ "C7_USER"   , __cUserId      , Nil })			
AAdd(aCabec,{ "C7_XNRBLEZ", cNrBlez        , Nil })
AAdd(aCabec,{ "C7_XLINKBL", cLinkBl        , Nil })
If nVFrete > 0
	AAdd(aCabec,{ "C7_TPFRETE", cTpFret    , Nil })
Endif	
AAdd(aCabec,{ "C7_FRETE"  , nVFrete        , Nil })
AAdd(aCabec,{ "C7_DESPESA", nDespes        , Nil })
AAdd(aCabec,{ "C7_SEGURO" , nSeguro        , Nil })
AAdd(aCabec,{ "C7_DESC1"  , nDescon        , Nil })

If ( ExistBlock("BLZC7CAB") )
	aCabUsr := ExecBlock("BLZC7CAB",.F.,.F.,{aCabec})
	If ( ValType(aCabUsr) == "A" )
		For x := 1 to Len(aCabUsr)
			AAdd(aCabec,aCabUsr[x])
		Next x	
	Endif
Endif	

For i := 1 to Len(oJson["itens"])

	aItem := {}
	bProd := PadR(AllTrim(oJson["itens"][i]["prod"]),TamSx3("B1_COD")[1])
	bQtde := oJson["itens"][i]["quant"]
	bPrec := oJson["itens"][i]["preco"]
	nVTot := oJson["itens"][i]["quant"] * oJson["itens"][i]["preco"]
	bEntr := StoD(oJson["itens"][i]["dtentr"])
	bObse := oJson["itens"][i]["observ"]
	bVIpi := oJson["itens"][i]["valipi"]
	bAIpi := 0
	If bVIpi > 0
		bAIpi := Round(((bVIpi / nVTot) * 100),0)
	Endif

	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek( xFilial("SB1") + bProd )

	DbSelectArea("SB2")
	DbSetOrder(1)
	If !DbSeek( xFilial("SB2") + bProd + SB1->B1_LOCPAD )
		RecLock("SB2",.T.)
		SB2->B2_FILIAL  := xFilial("SB2")
		SB2->B2_COD     := bProd
		SB2->B2_LOCAL   := SB1->B1_LOCPAD
		SB2->B2_LOCALIZ := AllTrim(Posicione("SX5",1,xFilial("SX5")+"02"+PadR(SB1->B1_TIPO,6),"X5_DESCRI"))
		SB2->B2_DMOV    := Date()
		SB2->B2_HMOV    := Time()
		MsUnLock()
	Endif

	AAdd(aItem,{ "C7_PRODUTO", SB1->B1_COD    , Nil })
	AAdd(aItem,{ "C7_QUANT"  , bQtde          , Nil })
	AAdd(aItem,{ "C7_PRECO"  , bPrec          , Nil })
	AAdd(aItem,{ "C7_TOTAL"  , nVTot          , Nil })
	AAdd(aItem,{ "C7_LOCAL"  , SB1->B1_LOCPAD , Nil })
	AAdd(aItem,{ "C7_DATPRF" , bEntr          , Nil })
	AAdd(aItem,{ "C7_OBS"    , bObse          , Nil })
	AAdd(aItem,{ "C7_IPI"    , bAIpi          , Nil })
	AAdd(aItem,{ "C7_VALIPI" , bVIpi          , Nil })
	AAdd(aItem,{ "C7_DESCRI" , SB1->B1_DESC   , Nil })
	If Len(oJson["itens"][i]["rateio"]) == 0
		AAdd(aItem,{ "C7_CC" , bccIt , Nil })
	Else
		AAdd(aItem,{ "C7_CC" , Space(TamSx3("B1_CC")[1]) , Nil })
	Endif	

	If ( ExistBlock("BLZC7ITE") )
		aIteUsr := ExecBlock("BLZC7ITE",.F.,.F.,{aItem})
		If ( ValType(aIteUsr) == "A" )
			For x := 1 to Len(aIteUsr)
				AAdd(aItem,aIteUsr[x])
			Next x	
		Endif
	Endif	

	AAdd(aItens, aItem)

	// Rateio
	bItemPc := StrZero(i,4)
	If Len(oJson["itens"][i]["rateio"]) > 0
		AAdd(aRatcc,{bItemPc,{ }})
		For r := 1 to Len(oJson["itens"][i]["rateio"])
			aItemCC := {}
			bItemRt := StrZero(r,TamSx3("CH_ITEM")[1])
			bPercen := oJson["itens"][i]["rateio"][r]["percen"]
			bcCusto := oJson["itens"][i]["rateio"][r]["ccusto"]
			bCtaCtb := SB1->B1_CONTA
			//
			AAdd(aItemCC,{"CH_ITEM" , bItemRt, Nil})
			AAdd(aItemCC,{"CH_PERC" , bPercen, Nil})
			AAdd(aItemCC,{"CH_CC"   , bcCusto, Nil})
			AAdd(aItemCC,{"CH_CONTA", bCtaCtb, Nil})
			AAdd(aRatcc[i][2],aItemCC)
		Next r
	Endif	

Next i

If Len(aCabec) == 0 .Or. Len(aItens) == 0
	SetRestFault(2,;
				 "Falha na inclusao do pedido de compra.",;
				 .T.,;
				 400,;
				 "Houve uma falha na leitura dos dados no Json, efetue a correçao.")

	Return(.F.)
Endif

lMsErroAuto    := .F.
lMsHelpAuto    := .T.
lAutoErrNoFile := .T.

Begin Transaction

MSExecAuto({|k,v,w,x,y,z| MATA120(k,v,w,x,y,z)},1, aCabec, aItens, 3,,aRatcc)
If !lMsErroAuto			
	bTot := 0
	bRec := SC7->(Recno())
	bFil := SC7->C7_FILIAL
	bPed := SC7->C7_NUM
	DbSelectArea("SC7")
	DbSetOrder(1)
	DbSeek( bFil + bPed )
	While !Eof() .And. SC7->(C7_FILIAL+C7_NUM) == bFil + bPed
		RecLock("SC7",.F.)
		SC7->C7_XNRBLEZ := cNrBlez
		SC7->C7_XPADTO  := IIf(lAdiant .And. nPercAd > 0, nPercAd, 0)
		MsUnLock()
		bTot += SC7->C7_TOTAL
		SC7->(DbSkip())
	Enddo
	SC7->(DbGoto(bRec))
	// ********************************** //
	// ** Verifica se tem Adiantamento ** //
	// ********************************** //
	If lAdiant .And. nPercAd > 0
		cPrefix := AllTrim(SuperGetMv("CO_BLEZPRF",.F.,"ADT"))
		cNumero := "000"+SC7->C7_NUM
		cParcel := ""
		cTipTit := "PA"
		cNatTit := AllTrim(SuperGetMv("CO_BLEZNAT",.F.,"1209001"))
		cCodFor := SC7->C7_FORNECE
		cLojFor := SC7->C7_LOJA
		dEmissa := SC7->C7_EMISSAO
		dVencto := dEmissa
		dVencRe := DataValida(dVencto,.T.)
		nVlrTit := bTot * (nPercAd/100)
		cHistor := "ADTO PEDIDO "+SC7->C7_NUM
		cNrBlez := cNrBlez
		cBcoTit := AllTrim(SuperGetMv("CO_BLEZBCO",.F.,"001"))
		cAgeTit := AllTrim(SuperGetMv("CO_BLEZAGE",.F.,"3336"))
		cCtaTit := AllTrim(SuperGetMv("CO_BLEZCTA",.F.,"6392"))
		//
		aArray := { { "E2_PREFIXO" , cPrefix , Nil },;
					{ "E2_NUM"     , cNumero , Nil },;
					{ "E2_PARCELA" , cParcel , Nil },;
					{ "E2_TIPO"    , cTipTit , Nil },;
					{ "E2_NATUREZ" , cNatTit , Nil },;
					{ "E2_FORNECE" , cCodFor , Nil },;
					{ "E2_LOJA"    , cLojFor , Nil },;
					{ "E2_EMISSAO" , dEmissa , Nil },;
					{ "E2_VENCTO"  , dVencto , Nil },;
					{ "E2_VENCREA" , dVencRe , Nil },;
					{ "E2_VALOR"   , nVlrTit , Nil },;
					{ "E2_HIST"    , cHistor , Nil },;
					{ "E2_XNRBLEZ" , cNrBlez , Nil },;
					{ "AUTBANCO"   , cBcoTit , Nil },;
					{ "AUTAGENCIA" , cAgeTit , Nil },;
					{ "AUTCONTA"   , cCtaTit , Nil } }

		lMsErroAuto    := .F.
		lMsHelpAuto    := .T.
		lAutoErrNoFile := .T.

		MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aArray,,3)
		If !lMsErroAuto
			oJsonRet["success"] := .T.
			oJsonRet["filial"] := SC7->C7_FILIAL
			oJsonRet["numero"] := SC7->C7_NUM
			oJsonRet["adiant"] := .T.
			self:SetResponse( oJsonRet:toJson() )
		Else
			DisarmTransaction()
			lRet := .F.
			aLog := GetAutoGRLog()
			bMsg := "Falha na inclusao do adiantamento vinculado."
			For i := 1 to Len(aLog)
				If AT("Erro -->",aLog[i])
					bMsg := AllTrim(Substr(aLog[i],9))
				Endif
			Next i
			oJsonRet["success"] := .F.
			oJsonRet["coderr"]  := 1015
			oJsonRet["msgerr"]  := bMsg
			self:SetResponse( oJsonRet:toJson() )
		Endif
	Else
		lRet := .T.
		oJsonRet["success"] := .T.
		oJsonRet["filial"] := SC7->C7_FILIAL
		oJsonRet["numero"] := SC7->C7_NUM
		oJsonRet["adiant"] := .F.
		self:SetResponse( oJsonRet:toJson() )
	Endif
Else
	DisarmTransaction()
	lRet := .F.
	aLog := GetAutoGRLog()
	bMsg := "Falha na inclusao do pedido."
	For i := 1 to Len(aLog)
		If AT("A120COMP",aLog[i]) > 0
			bMsg := "Usuario comprador nao cadastrado nesta filial."
			Exit
		ElseIf AT("Numero ja gravado",aLog[i]) > 0
			bMsg := "Numero de pedido ja utilizado."
			Exit
		ElseIf AT("Erro -->",aLog[i]) > 0
			bMsg := AllTrim(Substr(aLog[i],9))
			Exit
		Endif
	Next i
	oJsonRet["success"] := .F.
	oJsonRet["coderr"]  := 1016
	oJsonRet["msgerr"]  := bMsg
	self:SetResponse( oJsonRet:toJson() )
Endif

End Transaction

Return(lRet)

// https://www.youtube.com/watch?v=V3Cii74aqJY - GET
// https://www.youtube.com/watch?v=fqXEVpG9vB8 - POST

/*
{
	"filial":"0105",
    "cgcfor":"23289201000156",
    "emissao":"20230926",
    "condpg":"001",
    "nr_blueez":"000099",
    "adiant":false,
    "percad":0,
    "itens":[
        {
            "prod":"0410015AC",
            "quant":1,
            "preco":1500.6,
            "dtentr":"20230930",
            "numsc":"",
            "itemsc":"",
            "observ":"CABO REFLAM FLEX 450/750V",
            "rateio":[
                {
                    "ccusto":"9902",
                    "percen":80
                },
                {
                    "ccusto":"9904",
                    "percen":20
                }
            ]
        },
        {
            "prod":"0410015BC",
            "quant":1,
            "preco":2641.5,
            "dtentr":"20230930",
            "numsc":"",
            "itemsc":"",
            "observ":"CABO REFLAM FLEX 450/750V",
            "rateio":[
                {
                    "ccusto":"9902",
                    "percen":50
                },
                {
                    "ccusto":"9904",
                    "percen":50
                }
            ]
        }
    ]
}
*/

/*
{
    "empresa":"01",
    "filial":"01010001",
    "cgcfor":"10249782000150",
    "emissao":"20231011",
    "condpg":"001",
    "nr_blueez":"000999",
    "adiant":false,
    "percad":0,
    "itens":[
        {
            "prod":"SH-01-110-0002",
            "quant":1,
            "preco":50,
            "dtentr":"20231230",
            "numsc":"",
            "itemsc":"",
            "observ":"REATOR ELETRONICO",
            "rateio":[
                {
                    "ccusto":"160001000001",
                    "percen":60
                },
                {
                    "ccusto":"020001000001",
                    "percen":40
                }
            ]
        },
        {
            "prod":"SH-01-110-0003",
            "quant":1,
            "preco":60.5,
            "dtentr":"20231230",
            "numsc":"",
            "itemsc":"",
            "observ":"REATOR PARA LAMPADA",
            "rateio":[
                {
                    "ccusto":"160001000001",
                    "percen":50
                },
                {
                    "ccusto":"020001000001",
                    "percen":50
                }
            ]
        }
    ]
}
*/

/*
{"C7_TPFRETE",CriaVar("C7_TPFRETE",.F.),NIL},;
{"C7_FRETE",CriaVar("C7_FRETE",.F.),NIL},;
{"C7_DESPESA",CriaVar("C7_DESPESA",.F.),NIL},;
{"C7_SEGURO",CriaVar("C7_SEGURO",.F.),NIL},;
{"C7_DESC1",CriaVar("C7_DESC1",.F.),NIL},;
*/
