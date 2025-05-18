#include "protheus.ch"
#include "restful.ch"

WSRESTFUL TITULO_PAGAR DESCRIPTION "Webservice Titulo a Pagar" FORMAT APPLICATION_JSON
 
	WSMETHOD POST V3 DESCRIPTION "Inclusão de Titulo a Pagar" PATH "/V3" WSSYNTAX "/V3" TTALK "V3"

END WSRESTFUL

WSMETHOD POST V3 WSSERVICE TITULO_PAGAR

Local lRet     := .T.
Local cJson    := Self:GetContent()
Local oJson    := JsonObject():New()
Local oJsonRet := JsonObject():New()
Local aCadEmp  := FwLoadSm0()
Local aLog 	   := {}
Local aArray   := {}
Local aRateio  := {}
Local aRatAux  := {}
Local i, r

Private lMsErroAuto    := .F.
Private lMsHelpAuto    := .T.
Private lAutoErrNoFile := .T.

self:SetContentType( "application/json" )

oJson:FromJson(cJson)

cBlzEmp := oJson["empresa"]
cBlzFil := oJson["filial"]
cCgcFor := oJson["cgcfor"]
cPrefix := oJson["prefixo"]
cNumero := oJson["numero"]
cParcel := oJson["parcela"]
cTipTit := oJson["tipo"]
dEmissa := StoD(oJson["emissao"])
dVencto := StoD(oJson["vencto"])
nVlrTit := oJson["valor"]
cNatTit := oJson["natureza"]
cCCusto := oJson["ccusto"]
cBcoTit := oJson["banco"]
cAgeTit := oJson["agencia"]
cCtaTit := oJson["conta"]
cHistor := oJson["histor"]
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

// 2. Fornecedor
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

// 3. Prefixo + Número + Parcela
If Empty(cPrefix) .Or. Empty(cNumero) .Or. Empty(cParcel)
	oJsonRet["success"] := .F.
	oJsonRet["coderr"]  := 1017
	oJsonRet["msgerr"]  := "Prefixo|Numero|Parcela nao informado"
	self:SetResponse( oJsonRet:toJson() )
	Return(.F.)
Else
	If Len(cPrefix) > TamSx3("E2_PREFIXO")[1]
		oJsonRet["success"] := .F.
		oJsonRet["coderr"]  := 1018
		oJsonRet["msgerr"]  := "Prefixo invalido (tamanho maximo permitido = "+AllTrim(STR(TamSx3("E2_PREFIXO")[1]))+"): "+cPrefix
		self:SetResponse( oJsonRet:toJson() )
		Return(.F.)
	Endif
	If Len(cNumero) > TamSx3("E2_NUM")[1]
		oJsonRet["success"] := .F.
		oJsonRet["coderr"]  := 1019
		oJsonRet["msgerr"]  := "Numero invalido (tamanho maximo permitido = "+AllTrim(STR(TamSx3("E2_NUM")[1]))+"): "+cNumero
		self:SetResponse( oJsonRet:toJson() )
		Return(.F.)
	Endif
	If Len(cParcel) > TamSx3("E2_PARCELA")[1]
		oJsonRet["success"] := .F.
		oJsonRet["coderr"]  := 1020
		oJsonRet["msgerr"]  := "Parcela invalida (tamanho maximo permitido = "+AllTrim(STR(TamSx3("E2_PARCELA")[1]))+"): "+cParcel
		self:SetResponse( oJsonRet:toJson() )
		Return(.F.)
	Endif
Endif

// 4. Tipo
If !(cTipTit $("PA,NF"))
	oJsonRet["success"] := .F.
	oJsonRet["coderr"]  := 1021
	oJsonRet["msgerr"]  := "Tipo invalido (permitido = PA,NF): "+cTipTit
	self:SetResponse( oJsonRet:toJson() )
	Return(.F.)
Endif

// 5. Emissão
If dEmissa < (Date()-30)
	oJsonRet["success"] := .F.
	oJsonRet["coderr"]  := 1002
	oJsonRet["msgerr"]  := "Data de emissao invalida (menor que 30dd): "+DtoC(dEmissa)
	self:SetResponse( oJsonRet:toJson() )
	Return(.F.)
Endif

// 6. Vencimento
If dVencto < dEmissa
	oJsonRet["success"] := .F.
	oJsonRet["coderr"]  := 1022
	oJsonRet["msgerr"]  := "Data de vencimento invalida (menor que emissao): "+DtoC(dVencto)
	self:SetResponse( oJsonRet:toJson() )
	Return(.F.)
Endif

// 7. Valor
If nVlrTit <= 0
	oJsonRet["success"] := .F.
	oJsonRet["coderr"]  := 1023
	oJsonRet["msgerr"]  := "Valor invalido: "+AllTrim(STR(nVlrTit))
	self:SetResponse( oJsonRet:toJson() )
	Return(.F.)
Endif

// 8. Natureza
DbSelectArea("SED")
DbSetOrder(1)
If !DbSeek( xFilial("SED") + PadR(cNatTit,TamSx3("ED_CODIGO")[1]) )
	oJsonRet["success"] := .F.
	oJsonRet["coderr"]  := 1024
	oJsonRet["msgerr"]  := "Natureza nao cadastrada: "+AllTrim(cNatTit)
	self:SetResponse( oJsonRet:toJson() )
	Return(.F.)
Else
	If SED->ED_MSBLQL == "1"
		oJsonRet["success"] := .F.
		oJsonRet["coderr"]  := 1024
		oJsonRet["msgerr"]  := "Natureza bloqueada: "+AllTrim(cNatTit)
		self:SetResponse( oJsonRet:toJson() )
		Return(.F.)
	Endif
Endif

// 9. Centro de Custo
If !Empty(cCCusto)
	DbSelectArea("CTT")
	DbSetOrder(1)
	If !DbSeek( xFilial("CTT") + PadR(cCCusto,TamSx3("CTT_CUSTO")[1]) )
		oJsonRet["success"] := .F.
		oJsonRet["coderr"]  := 1011
		oJsonRet["msgerr"]  := "Centro de custo nao cadastrado: "+cCCusto
		self:SetResponse( oJsonRet:toJson() )
		Return(.F.)
	Else
		If (!Empty(CTT->CTT_DTEXSF) .And. Date() > CTT->CTT_DTEXSF) .Or. CTT->CTT_BLOQ == "1"
			oJsonRet["success"] := .F.
			oJsonRet["coderr"]  := 1012
			oJsonRet["msgerr"]  := "Centro de custo bloqueado: "+cCCusto
			self:SetResponse( oJsonRet:toJson() )
			Return(.F.)
		Endif
	Endif
Endif

// 10. Banco + Agencia + Conta
If cTipTit == "PA"
	If Empty(cBcoTit) .Or. Empty(cAgeTit) .Or. Empty(cCtaTit)
		oJsonRet["success"] := .F.
		oJsonRet["coderr"]  := 1025
		oJsonRet["msgerr"]  := "Titulo PA obrigatorio informar Banco/Agencia/Conta"
		self:SetResponse( oJsonRet:toJson() )
		Return(.F.)
	Else
		DbSelectArea("SA6")
		DbSetOrder(1)
		If !DbSeek( xFilial("SA6") + PadR(cBcoTit,TamSx3("A6_COD")[1]) + PadR(cAgeTit,TamSx3("A6_AGENCIA")[1]) + PadR(cCtaTit,TamSx3("A6_NUMCON")[1]) )
			oJsonRet["success"] := .F.
			oJsonRet["coderr"]  := 1026
			oJsonRet["msgerr"]  := "Banco/Agencia/Conta nao cadastrado: "+cBcoTit+"|"+cAgeTit+"|"+cCtaTit
			self:SetResponse( oJsonRet:toJson() )
			Return(.F.)
		Endif
	Endif	
Endif

cCodFor := SA2->A2_COD
cLojFor := SA2->A2_LOJA
dVencRe := DataValida(dVencto,.T.)

// 11. Duplicidade
DbSelectArea("SE2")
DbSetOrder(1)
If DbSeek( xFilial("SE2") + PadR(cPrefix,TamSx3("E2_PREFIXO")[1]) + PadR(cNumero,TamSx3("E2_NUM")[1]) +;
							 PadR(cParcel,TamSx3("E2_PARCELA")[1]) + PadR(cTipTit,TamSx3("E2_TIPO")[1]) +; 
							 PadR(cCodFor,TamSx3("E2_FORNECE")[1]) + PadR(cLojFor,TamSx3("E2_LOJA")[1]) )
	oJsonRet["success"] := .F.
	oJsonRet["coderr"]  := 1027
	oJsonRet["msgerr"]  := "Titulo ja cadastrado com essa numeracao"
	self:SetResponse( oJsonRet:toJson() )
	Return(.F.)
Endif

// 12. Rateio
bTotRat := 0
lOkRate := .T.
For r := 1 to Len(oJson["rateio"])
	bcCusto := oJson["rateio"][r]["ccusto"]
	bPercen := oJson["rateio"][r]["percen"]
	bTotRat += bPercen
	DbSelectArea("CTT")
	DbSetOrder(1)
	If !DbSeek( xFilial("CTT") + PadR(bcCusto,TamSx3("CTT_CUSTO")[1]) )
		oJsonRet["success"] := .F.
		oJsonRet["coderr"]  := 1011
		oJsonRet["msgerr"]  := "Centro de custo nao cadastrado: "+bcCusto
		self:SetResponse( oJsonRet:toJson() )
		lOkRate := .F.
	Else
		If (!Empty(CTT->CTT_DTEXSF) .And. Date() > CTT->CTT_DTEXSF) .Or. CTT->CTT_BLOQ == "1"
			oJsonRet["success"] := .F.
			oJsonRet["coderr"]  := 1012
			oJsonRet["msgerr"]  := "Centro de custo bloqueado: "+bcCusto
			self:SetResponse( oJsonRet:toJson() )
			lOkRate := .F.
		Endif
	Endif
Next r
If lOkRate
	If bTotRat > 0 .And. bTotRat <> 100
		oJsonRet["success"] := .F.
		oJsonRet["coderr"]  := 1013
		oJsonRet["msgerr"]  := "Rateio invalido no Item "+AllTrim(STR(i))+": "+AllTrim(STR(bTotRat))
		self:SetResponse( oJsonRet:toJson() )
		Return(.F.)
	Endif
Else
	Return(.F.)
Endif	

// 13. Id BlueEz
cQuery := " SELECT E2_NUM NUMERO "
cQuery += " FROM "+RetSqlName("SE2")
cQuery += " WHERE E2_XNRBLEZ = '"+cNrBlez+"' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TRB2", .F., .T.)
TRB2->(DbGotop())
e2BlueEz := TRB2->NUMERO
TRB2->(DbCloseArea())
If !Empty(e2BlueEz)
	oJsonRet["success"] := .F.
	oJsonRet["coderr"]  := 1014
	oJsonRet["msgerr"]  := "No.BlueEz já cadastrado: "+cNrBlez
	oJsonRet["numero"]  := e2BlueEz
	self:SetResponse( oJsonRet:toJson() )
	Return(.F.)
Endif

// Inicia a gravação do titulo
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
			{ "E2_CCUSTO"  , cCCusto , Nil },;
			{ "E2_XNRBLEZ" , cNrBlez , Nil } }

If Len(oJson["rateio"]) > 0
	AAdd(aArray, {"E2_RATEIO" , "S" , Nil})
Endif

If cTipTit == "PA"
	AAdd(aArray, {"AUTBANCO"   , cBcoTit , Nil})
	AAdd(aArray, {"AUTAGENCIA" , cAgeTit , Nil})
	AAdd(aArray, {"AUTCONTA"   , cCtaTit , Nil})
Endif

// Rateio
If Len(oJson["rateio"]) > 0
	For r := 1 to Len(oJson["rateio"])
		aRatAux := {}
		bCtaDeb := "3300140005"
		bCtaCrd := ""
		bPercen := oJson["rateio"][r]["percen"]
		bVlrRat := nVlrTit * (bPercen/100)
		bcCusDb := oJson["rateio"][r]["ccusto"]
		bcCusCr := ""
		//
		AAdd(aRatAux,{"CTJ_DEBITO" , bCtaDeb, Nil})
		AAdd(aRatAux,{"CTJ_CREDIT" , bCtaCrd, Nil})
		AAdd(aRatAux,{"CTJ_PERCEN" , bPercen, Nil})
		AAdd(aRatAux,{"CTJ_VALOR"  , bVlrRat, Nil})
		AAdd(aRatAux,{"CTJ_CCD"    , bcCusDb, Nil})
		AAdd(aRatAux,{"CTJ_CCC"    , bcCusCr, Nil})
		AAdd(aRateio,aRatAux)
	Next r
Endif	

If Len(aArray) == 0
	SetRestFault(2,;
				 "Falha na inclusão do titulo a pagar.",;
				 .T.,;
				 400,;
				 "Houve uma falha na leitura dos dados no Json, efetue a correção.")
	Return(.F.)
Endif

lMsErroAuto    := .F.
lMsHelpAuto    := .T.
lAutoErrNoFile := .T.

Begin Transaction

If Len(aRateio) > 0
	MsExecAuto( { |a,b,c,d,e,f,g,h| FINA050(a,b,c,d,e,f,g,h)}, aArray,, 3,,,,,aRateio,,)
Else
	MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aArray,,3)
Endif	

If !lMsErroAuto
	oJsonRet["success"] := .T.
	oJsonRet["filial"] := SE2->E2_FILIAL
	oJsonRet["numero"] := SE2->E2_NUM
	self:SetResponse( oJsonRet:toJson() )
Else
    DisarmTransaction()
	lRet := .F.
	aLog := GetAutoGRLog()
	bMsg := "Falha na inclusao do titulo a pagar"
	For i := 1 to Len(aLog)
		If AT("Erro -->",aLog[i])
			bMsg := AllTrim(Substr(aLog[i],9))
		Endif
	Next i
	oJsonRet["success"] := .F.
	oJsonRet["coderr"]  := 1028
	oJsonRet["msgerr"] := bMsg
	self:SetResponse( oJsonRet:toJson() )
Endif

End Transaction

Return(lRet)

/*
// Adiantamento
{
    "empresa":"01",
    "filial":"01010001",
    "cgcfor":"10249782000150",
    "prefixo":"MAN",
    "numero":"20231006",
    "parcela":"01",
    "tipo":"PA",
    "emissao":"20231003",
    "vencto":"20231103",
    "valor":1005.51,
    "natureza":"1205001",
    "ccusto":"160001000001",
    "banco":"001",
    "agencia":"3336",
    "conta":"6392",
    "histor":"TESTE PG ANTECIPADO",
    "nr_blueez":"0000000001",
    "rateio":[
            ]
}

// Título a Pagar
{
    "empresa":"01",
    "filial":"01010001",
    "cgcfor":"10249782000150",
    "prefixo":"MAN",
    "numero":"20231025",
    "parcela":"01",
    "tipo":"NF",
    "emissao":"20231025",
    "vencto":"20231125",
    "valor":1500.84,
    "natureza":"1205001",
    "ccusto":"160001000001",
    "banco":"001",
    "agencia":"3336",
    "conta":"6392",
    "histor":"TESTE CPAG COM RATEIO",
    "nr_blueez":"0000000002",
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
}

// Partage
{
    "empresa":"01",
    "filial":"01010001",
    "cgcfor":"10249782000150",
    "emissao":"20231124",
    "condpg":"001",
    "adiant":false,
    "percad":10,
    "linkbl":"http://192.168.9.11:8106/rest",
    "tpfrete":"C",
    "frete":100,
    "seguro":50,
    "despesa":60,
    "descont":5,
    "nr_blueez":"009096",
    "itens":[
        {
            "prod":"SH-01-110-0002",
            "quant":1,
            "preco":500,
            "dtentr":"20231230",
            "numsc":"",
            "itemsc":"",
            "ccitem":"",
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
            "preco":600.84,
            "dtentr":"20231230",
            "numsc":"",
            "itemsc":"",
            "ccitem":"",
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
