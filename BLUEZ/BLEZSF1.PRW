#include "protheus.ch"
#include "restful.ch"

WSRESTFUL DOCUMENTO_ENTRADA DESCRIPTION "Webservice Documento de Entrada" FORMAT APPLICATION_JSON
 
	WSMETHOD POST V4 DESCRIPTION "Inclusão de Documento de Entrada" PATH "/V4" WSSYNTAX "/V4" TTALK "V4"

END WSRESTFUL

WSMETHOD POST V4 WSSERVICE DOCUMENTO_ENTRADA

Local lRet     := .T.
Local cJson    := Self:GetContent()
Local oJson    := JsonObject():New()
Local oJsonRet := JsonObject():New()
Local aCadEmp  := FwLoadSm0()
Local aLog 	   := {}
Local aCabec   := {}
Local aItem    := {}
Local aItens   := {}
Local i

Private lMsErroAuto    := .F.
Private lMsHelpAuto    := .T.
Private lAutoErrNoFile := .T.

self:SetContentType( "application/json" )

oJson:FromJson(cJson)

cBlzEmp := oJson["empresa"]
cBlzFil := oJson["filial"]
cCgcFor := oJson["cgcfor"]
dEmissa := StoD(oJson["emissao"])
cNumNfe := oJson["numero"]
cSerNfe := oJson["serie"]
cEspeci := oJson["especie"]
cChvNfe := oJson["chavenfe"]
cCondPg := oJson["condpg"]
lPreDoc := oJson["predoc"]
cLinkBl := oJson["linkbl"]
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
ElseIf dEmissa > Date()
	oJsonRet["success"] := .F.
	oJsonRet["coderr"]  := 1002
	oJsonRet["msgerr"]  := "Data de emissao invalida (maior que atual): "+DtoC(dEmissa)
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

// 5. Numero + Serie
If Empty(cNumNfe) .Or. Empty(cSerNfe)
	oJsonRet["success"] := .F.
	oJsonRet["coderr"]  := 1029
	oJsonRet["msgerr"] := "Numero|Serie nao informado"
	self:SetResponse( oJsonRet:toJson() )
	Return(.F.)
Else
	If Len(cNumNfe) > TamSx3("F1_DOC")[1]
		oJsonRet["success"] := .F.
		oJsonRet["coderr"]  := 1030
		oJsonRet["msgerr"]  := "Documento invalido (tamanho maximo permitido = "+AllTrim(STR(TamSx3("F1_DOC")[1]))+"): "+cNumNfe
		self:SetResponse( oJsonRet:toJson() )
		Return(.F.)
	Endif
	If Len(cSerNfe) > TamSx3("F1_SERIE")[1]
		oJsonRet["success"] := .F.
		oJsonRet["coderr"]  := 1031
		oJsonRet["msgerr"]  := "Serie invalida (tamanho maximo permitido = "+AllTrim(STR(TamSx3("F1_SERIE")[1]))+"): "+cSerNfe
		self:SetResponse( oJsonRet:toJson() )
		Return(.F.)
	Endif
Endif

// 6. Itens
lItensOk := .T.
For i := 1 to Len(oJson["itens"])

	bProd := PadR(AllTrim(oJson["itens"][i]["prod"]),TamSx3("B1_COD")[1])
	bQtde := oJson["itens"][i]["quant"]
	bPrec := oJson["itens"][i]["vunit"]
	bArmz := oJson["itens"][i]["armazem"]
	bPedi := oJson["itens"][i]["numpc"]
	bItPc := oJson["itens"][i]["itempc"]
	bServ := oJson["itens"][i]["codserv"]
	bCcus := oJson["itens"][i]["ccusto"]
	bOper := oJson["itens"][i]["operac"]

	// 5.1 - Produto
	DbSelectArea("SB1")
	DbSetOrder(1)
	If !DbSeek( xFilial("SB1") + bProd )
		oJsonRet["success"] := .F.
		oJsonRet["coderr"]  := 1005
		oJsonRet["msgerr"]  := "Produto nao cadastrado: "+bProd
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

	// 5.2 - Quantidade
	If bQtde <= 0
		oJsonRet["success"] := .F.
		oJsonRet["coderr"]  := 1008
		oJsonRet["msgerr"]  := "Quantidade invalida: "+AllTrim(STR(bQtde))
		self:SetResponse( oJsonRet:toJson() )
		lItensOk := .F.
		Exit
	Endif

	// 5.3 - Preço
	If bPrec <= 0
		oJsonRet["success"] := .F.
		oJsonRet["coderr"]  := 1009
		oJsonRet["msgerr"]  := "Preco unitario invalido: "+AllTrim(STR(bPrec))
		self:SetResponse( oJsonRet:toJson() )
		lItensOk := .F.
		Exit
	Endif

	// 5.4 - Armazém
	DbSelectArea("NNR")
	DbSetOrder(1)
	If !DbSeek( xFilial("NNR") + bArmz )
		oJsonRet["success"] := .F.
		oJsonRet["coderr"]  := 1032
		oJsonRet["msgerr"]  := "Armazem nao cadastrado: "+bArmz
		self:SetResponse( oJsonRet:toJson() )
		lItensOk := .F.
		Exit
	Endif

	// 5.5 - Cód.Serviço
	If !Empty(bServ)
		DbSelectArea("SX5")
		DbSetOrder(1)
		If !DbSeek( xFilial("SX5") + "60" + PadR(bServ,6) )
			oJsonRet["success"] := .F.
			oJsonRet["coderr"]  := 1033
			oJsonRet["msgerr"]  := "Codigo de servico nao cadastrado: "+bServ
			self:SetResponse( oJsonRet:toJson() )
			lItensOk := .F.
			Exit
		Endif
	Endif

	// 5.6 - Centro de Custo
	If !Empty(bCcus)
		DbSelectArea("CTT")
		DbSetOrder(1)
		If !DbSeek( xFilial("CTT") + PadR(bCcus,TamSx3("CTT_CUSTO")[1]) )
			oJsonRet["success"] := .F.
			oJsonRet["coderr"]  := 1011
			oJsonRet["msgerr"] := "Centro de custo nao cadastrado: "+bCcus
			self:SetResponse( oJsonRet:toJson() )
			lItensOk := .F.
			Exit
		Else
			If (!Empty(CTT->CTT_DTEXSF) .And. Date() > CTT->CTT_DTEXSF) .Or. CTT->CTT_BLOQ == "1"
				oJsonRet["success"] := .F.
				oJsonRet["coderr"]  := 1012
				oJsonRet["msgerr"]  := "Centro de custo bloqueado: "+bCcus
				self:SetResponse( oJsonRet:toJson() )
				lItensOk := .F.
				Exit
			Endif
		Endif	
	Endif

	// 5.7 - Tipo de Operação
	If !lPreDoc
		If Empty(bOper)
			oJsonRet["success"] := .F.
			oJsonRet["coderr"]  := 1037
			oJsonRet["msgerr"]  := "Tipo de Operacao nao informado: (predoc=false)"
			self:SetResponse( oJsonRet:toJson() )
			lItensOk := .F.
			Exit
		Endif
	Endif

Next i
If !lItensOk
	Return(.F.)
Endif

cCodFor := SA2->A2_COD
cLojFor := SA2->A2_LOJA
cCondPg := SE4->E4_CODIGO

// 6. Duplicidade
DbSelectArea("SF1")
DbSetOrder(1)
If DbSeek( xFilial("SF1") + PadR(cNumNfe,TamSx3("F1_DOC")[1]) + PadR(cSerNfe,TamSx3("F1_SERIE")[1]) +;
							 PadR(cCodFor,TamSx3("F1_FORNECE")[1]) + PadR(cLojFor,TamSx3("F1_LOJA")[1]) )
	oJsonRet["success"] := .F.
	oJsonRet["coderr"]  := 1034
	oJsonRet["msgerr"]  := "Documento ja cadastrado com essa numeracao"
	self:SetResponse( oJsonRet:toJson() )
	Return(.F.)
Endif

// 7. Id BlueEz
cQuery := " SELECT F1_DOC DOC "
cQuery += " FROM "+RetSqlName("SF1")
cQuery += " WHERE F1_XNRBLEZ = '"+cNrBlez+"' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TRB1", .F., .T.)
TRB1->(DbGotop())
f1BlueEz := TRB1->DOC
TRB1->(DbCloseArea())
If !Empty(f1BlueEz)
	oJsonRet["success"] := .F.
	oJsonRet["coderr"]  := 1014
	oJsonRet["msgerr"]  := "No. BlueEz já cadastrado: "+cNrBlez
	oJsonRet["numero"]  := f1BlueEz
	self:SetResponse( oJsonRet:toJson() )
	Return(.F.)
Endif

// Inicia a gravação do documento
AAdd(aCabec,{ "F1_TIPO"   , "N"     , Nil })
AAdd(aCabec,{ "F1_FORMUL" , "N"     , Nil })
AAdd(aCabec,{ "F1_DOC"    , cNumNfe , Nil })
AAdd(aCabec,{ "F1_SERIE"  , cSerNfe , Nil })
AAdd(aCabec,{ "F1_DTDIGIT", Date()  , Nil })
AAdd(aCabec,{ "F1_EMISSAO", dEmissa , Nil })
AAdd(aCabec,{ "F1_FORNECE", cCodFor , Nil })
AAdd(aCabec,{ "F1_LOJA"   , cLojFor , Nil })
AAdd(aCabec,{ "F1_ESPECIE", cEspeci , Nil })
AAdd(aCabec,{ "F1_CHVNFE" , cChvNfe , Nil })
AAdd(aCabec,{ "F1_COND"   , cCondPg , Nil })
AAdd(aCabec,{ "F1_XNRBLEZ", cNrBlez , Nil })
AAdd(aCabec,{ "F1_XLINKBL", cLinkBl , Nil })

For i := 1 to Len(oJson["itens"])

	aItem := {}
	bItem := StrZero(i,TamSx3("D1_ITEM")[1])
	bProd := PadR(AllTrim(oJson["itens"][i]["prod"]),TamSx3("B1_COD")[1])
	bQtde := oJson["itens"][i]["quant"]
	bPrec := oJson["itens"][i]["vunit"]
	nVTot := oJson["itens"][i]["quant"] * oJson["itens"][i]["vunit"]
	bArmz := oJson["itens"][i]["armazem"]
	bPedi := oJson["itens"][i]["numpc"]
	bItPc := oJson["itens"][i]["itempc"]
	bServ := oJson["itens"][i]["codserv"]
	bCcus := oJson["itens"][i]["ccusto"]
	bOper := oJson["itens"][i]["operac"]

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

	AAdd(aItem,{ "D1_ITEM"  , bItem , Nil })
	AAdd(aItem,{ "D1_COD"   , bProd , Nil })
	AAdd(aItem,{ "D1_QUANT" , bQtde , Nil })
	AAdd(aItem,{ "D1_VUNIT" , bPrec , Nil })
	AAdd(aItem,{ "D1_TOTAL" , nVTot , Nil })
	AAdd(aItem,{ "D1_LOCAL" , bArmz , Nil })
	If !lPreDoc
		AAdd(aItem,{ "D1_OPER" , bOper , Nil })
	Endif	
	If !Empty(bPedi)
		AAdd(aItem,{ "D1_PEDIDO" , bArmz , Nil })
	Endif
	If !Empty(bItPc)
		AAdd(aItem,{ "D1_ITEMPC" , bArmz , Nil })
	Endif
	If !Empty(bServ)
		AAdd(aItem,{ "D1_CODISS" , bServ , Nil })
	Endif
	If !Empty(bCcus)
		AAdd(aItem,{ "D1_CC" , bCcus , Nil })
	Endif
	AAdd(aItens, aItem)

Next i

If Len(aCabec) == 0 .Or. Len(aItens) == 0
	SetRestFault(2,;
				"Falha na inclusão do documento.",;
				.T.,;
				400,;
				"Houve uma falha na leitura dos dados no Json, efetue a correção.")

	Return(.F.)
Endif

lMsErroAuto    := .F.
lMsHelpAuto    := .T.
lAutoErrNoFile := .T.

If lPreDoc
	MsExecAuto({|x,y,z| MATA140(x,y,z)}, aCabec, aItens, 3)
Else
	MsExecAuto({|x,y,z| MATA103(x,y,z)}, aCabec, aItens, 3)
Endif	

If !lMsErroAuto			
	lRet := .T.
	oJsonRet["success"] := .T.
	oJsonRet["filial"] := SF1->F1_FILIAL
	oJsonRet["numero"] := SF1->F1_DOC
	self:SetResponse( oJsonRet:toJson() )
Else
	lRet := .F.
	aLog := GetAutoGRLog()
	bMsg := "Falha na inclusao do documento"
	For i := 1 to Len(aLog)
		If AT("Erro -->",aLog[i])
			bMsg := AllTrim(Substr(aLog[i],9))
		Endif
	Next i
	oJsonRet["success"] := .F.
	oJsonRet["coderr"]  := 1035
	oJsonRet["msgerr"]  := bMsg
	self:SetResponse( oJsonRet:toJson() )
Endif

Return(lRet)

/* pré documento
{
    "empresa":"01",
    "filial":"01010001",
    "cgcfor":"44658262000113",
    "emissao":"20231006",
    "numero":"000000022",
    "serie":"111",
    "especie":"NFS",
    "chavenfe":"",
    "condpg":"729",
    "predoc":true,
    "nr_blueez":"100000001",
    "itens":[
        {
            "prod":"DSP_213",
            "quant":1,
            "vunit":22211.7,
            "armazem":"01",
            "numpc":"",
            "itempc":"",
            "codserv":"01015",
            "ccusto":"010001000001",
            "operac":""
        },
        {
            "prod":"SH-001321",
            "quant":3,
            "vunit":2724.47,
            "armazem":"01",
            "numpc":"",
            "itempc":"",
            "codserv":"01015",
            "ccusto":"010001000001",
            "operac":""
        }
    ]
}
*/

/* documento
{
    "empresa":"01",
    "filial":"01010001",
    "cgcfor":"44658262000113",
    "emissao":"20231006",
    "numero":"000000022",
    "serie":"111",
    "especie":"NFS",
    "chavenfe":"",
    "condpg":"729",
    "predoc":false,
    "nr_blueez":"100000001",
    "itens":[
        {
            "prod":"DSP_213",
            "quant":1,
            "vunit":22211.7,
            "armazem":"01",
            "numpc":"",
            "itempc":"",
            "codserv":"01015",
            "ccusto":"010001000001",
            "operac":"51"
        },
        {
            "prod":"SH-001321",
            "quant":3,
            "vunit":2724.47,
            "armazem":"01",
            "numpc":"",
            "itempc":"",
            "codserv":"01015",
            "ccusto":"010001000001",
            "operac":"51"
        }
    ]
}
*/

