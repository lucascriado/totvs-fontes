#include "protheus.ch"
#include "restful.ch"

WSRESTFUL CTE_JSON DESCRIPTION "Webservice Ct-e JSON" FORMAT APPLICATION_JSON
 
	WSMETHOD POST V1 DESCRIPTION "Inclusão de Ct-e JSON" PATH "/V1" WSSYNTAX "/V1" TTALK "V1"

END WSRESTFUL

WSMETHOD POST V1 WSSERVICE CTE_JSON

Local lRet     := .T.
Local cJson    := Lower(Self:GetContent())
Local oJson    := JsonObject():New()
Local oJsonRet := JsonObject():New()
Local lErrJson := .F.
Local cte, nf

self:SetContentType( "application/json" )
oJson:FromJson(cJson)


For cte := 1 to Len(oJson["cte"])

	cRcIdentCte := oJson["cte"][cte]["identificador"]
	
	cIdentCte := padr(cRcIdentCte, 30)

	DbSelectArea("ZAM")
	DbSetOrder(1)
	If !DbSeek( xFilial("ZAM") + cIdentCte )
		RecLock("ZAM",.T.)
		ZAM->ZAM_FILIAL := xFilial("ZAM")
		ZAM->ZAM_IDCTE  := cIdentCte
	Else
		RecLock("ZAM",.F.)
	Endif	

	ZAM->ZAM_TCGC := oJson["cte"][cte]["transportador"]["cnpjcpf"]
	ZAM->ZAM_TCGC := oJson["cte"][cte]["transportador"]["cnpjcpf"]
	ZAM->ZAM_TRAZ := oJson["cte"][cte]["transportador"]["razaosocial"]
	ZAM->ZAM_TFAN := oJson["cte"][cte]["transportador"]["fantasia"]
	ZAM->ZAM_TIE := oJson["cte"][cte]["transportador"]["ie"]
	ZAM->ZAM_TCON := oJson["cte"][cte]["transportador"]["contato"]
	ZAM->ZAM_TFON := oJson["cte"][cte]["transportador"]["fone"]
	ZAM->ZAM_TCEP := oJson["cte"][cte]["transportador"]["cep"]
	ZAM->ZAM_TEND := oJson["cte"][cte]["transportador"]["endereco"]
	ZAM->ZAM_TNUM := oJson["cte"][cte]["transportador"]["numero"]
	ZAM->ZAM_TBAI := oJson["cte"][cte]["transportador"]["bairro"]
	ZAM->ZAM_TCOM := oJson["cte"][cte]["transportador"]["complemento"]
	ZAM->ZAM_TIBG := oJson["cte"][cte]["transportador"]["ibge"]
	ZAM->ZAM_TREG := oJson["cte"][cte]["transportador"]["regiao"]
	ZAM->ZAM_TUF := oJson["cte"][cte]["transportador"]["uf"]
	ZAM->ZAM_TCID := oJson["cte"][cte]["transportador"]["cidade"]

	ZAM->ZAM_RCGC := oJson["cte"][cte]["remetente"]["cnpjcpf"]
	ZAM->ZAM_RRAZ := oJson["cte"][cte]["remetente"]["razaosocial"]
	ZAM->ZAM_RFAN := oJson["cte"][cte]["remetente"]["fantasia"]
	ZAM->ZAM_RIE := oJson["cte"][cte]["remetente"]["ie"]
	ZAM->ZAM_RCON := oJson["cte"][cte]["remetente"]["contato"]
	ZAM->ZAM_RCEP := oJson["cte"][cte]["remetente"]["cep"]
	ZAM->ZAM_REND := oJson["cte"][cte]["remetente"]["endereco"]
	ZAM->ZAM_RNUM := oJson["cte"][cte]["remetente"]["numero"]
	ZAM->ZAM_RCOM := oJson["cte"][cte]["remetente"]["complemento"]
	ZAM->ZAM_RBAI := oJson["cte"][cte]["remetente"]["bairro"]
	ZAM->ZAM_RIBG := oJson["cte"][cte]["remetente"]["ibge"]
	ZAM->ZAM_RREG := oJson["cte"][cte]["remetente"]["regiao"]
	ZAM->ZAM_RUF := oJson["cte"][cte]["remetente"]["uf"]
	ZAM->ZAM_RCID := oJson["cte"][cte]["remetente"]["cidade"]

	ZAM->ZAM_DECGC := oJson["cte"][cte]["destinatario"]["cnpjcpf"]
	ZAM->ZAM_DERAZ := oJson["cte"][cte]["destinatario"]["razaosocial"]
	ZAM->ZAM_DEFAN := oJson["cte"][cte]["destinatario"]["fantasia"]
	ZAM->ZAM_DEIE := oJson["cte"][cte]["destinatario"]["ie"]
	ZAM->ZAM_DECON := oJson["cte"][cte]["destinatario"]["contato"]
	ZAM->ZAM_DEFON := oJson["cte"][cte]["destinatario"]["fone"]
	ZAM->ZAM_DECEP := oJson["cte"][cte]["destinatario"]["cep"]
	ZAM->ZAM_DEEND := oJson["cte"][cte]["destinatario"]["endereco"]
	ZAM->ZAM_DENUM := oJson["cte"][cte]["destinatario"]["numero"]
	ZAM->ZAM_DECOM := oJson["cte"][cte]["destinatario"]["complemento"]
	ZAM->ZAM_DEBAI := oJson["cte"][cte]["destinatario"]["bairro"]
	ZAM->ZAM_DEIBG := oJson["cte"][cte]["destinatario"]["ibge"]
	ZAM->ZAM_DEREG := oJson["cte"][cte]["destinatario"]["regiao"]
	ZAM->ZAM_DEUF := oJson["cte"][cte]["destinatario"]["uf"]
	ZAM->ZAM_DECID := oJson["cte"][cte]["destinatario"]["cidade"]

	ZAM->ZAM_PACGC := oJson["cte"][cte]["pagador"]["cnpjcpf"]
	ZAM->ZAM_PAREG := oJson["cte"][cte]["pagador"]["razaosocial"]
	ZAM->ZAM_PAUF := oJson["cte"][cte]["pagador"]["uf"]

	ZAM->ZAM_DONUM := oJson["cte"][cte]["documento"]["numero"]
	ZAM->ZAM_DOSER := oJson["cte"][cte]["documento"]["serie"]
	ZAM->ZAM_DOMOD := oJson["cte"][cte]["documento"]["modelo"]
	ZAM->ZAM_DOTIP := oJson["cte"][cte]["documento"]["tipo"]
	ZAM->ZAM_DOEMI := oJson["cte"][cte]["documento"]["emissao"]
	ZAM->ZAM_DOCHA := oJson["cte"][cte]["documento"]["chave"]
	ZAM->ZAM_DOAUT := oJson["cte"][cte]["documento"]["autorizado"]
	ZAM->ZAM_DOPRO := oJson["cte"][cte]["documento"]["protocolo"]
	ZAM->ZAM_DOCAN := oJson["cte"][cte]["documento"]["cancelamento"]
	ZAM->ZAM_DOCIE := oJson["cte"][cte]["documento"]["ciencia_cancelamento"]
	ZAM->ZAM_DOAPR := oJson["cte"][cte]["documento"]["aprovacao"]
	ZAM->ZAM_DOOBS := oJson["cte"][cte]["documento"]["observacao"]

	ZAM->ZAM_OIBGE := oJson["cte"][cte]["origem"]["ibge"]
	ZAM->ZAM_OREGI := oJson["cte"][cte]["origem"]["regiao"]
	ZAM->ZAM_OUF := oJson["cte"][cte]["origem"]["uf"]
	ZAM->ZAM_OCIDA := oJson["cte"][cte]["origem"]["cidade"]

	ZAM->ZAM_DTIBG := oJson["cte"][cte]["destino"]["ibge"]
	ZAM->ZAM_DTREG := oJson["cte"][cte]["destino"]["regiao"]
	ZAM->ZAM_DTUF := oJson["cte"][cte]["destino"]["uf"]
	ZAM->ZAM_DTCID := oJson["cte"][cte]["destino"]["cidade"]

	ZAM->ZAM_CQUNT := oJson["cte"][cte]["carga"]["quantidade_notas"]
	ZAM->ZAM_CPESO := oJson["cte"][cte]["carga"]["peso"]
	ZAM->ZAM_CPSCA := oJson["cte"][cte]["carga"]["pesocalculado"]
	ZAM->ZAM_CM3 := oJson["cte"][cte]["carga"]["m3"]
	ZAM->ZAM_CVOLU := oJson["cte"][cte]["carga"]["volumes"]
	ZAM->ZAM_CKM := oJson["cte"][cte]["carga"]["km"]
	ZAM->ZAM_CVALO := oJson["cte"][cte]["carga"]["valor"]

	ZAM->ZAM_PRMDF := oJson["cte"][cte]["prestacao"]["modelo_fiscal"]
	ZAM->ZAM_PRCFO := oJson["cte"][cte]["prestacao"]["cfop"]
	ZAM->ZAM_PRVAP := oJson["cte"][cte]["prestacao"]["valor_prestacao"]
	ZAM->ZAM_PRTFET := oJson["cte"][cte]["prestacao"]["total_frete"]
	ZAM->ZAM_PRCVA := oJson["cte"][cte]["prestacao"]["conciliacao_valor"]
	
	ZAM->ZAM_PRITP := oJson["cte"][cte]["prestacao"]["imposto"]["tipo"]
	ZAM->ZAM_PRIBA := oJson["cte"][cte]["prestacao"]["imposto"]["base"]
	ZAM->ZAM_PRIAL := oJson["cte"][cte]["prestacao"]["imposto"]["aliquota"]
	ZAM->ZAM_PRIVA := oJson["cte"][cte]["prestacao"]["imposto"]["valor"]
	ZAM->ZAM_PRIDE := oJson["cte"][cte]["prestacao"]["imposto"]["desconto"]

	MsUnLock()

	For nf := 1 to Len(oJson["cte"][cte]["notafiscal"])
		
		cNumero := oJson["cte"][cte]["notafiscal"][nf]["numero"]

		DbSelectArea("ZAN")
		DbSetOrder(1)
		If !DbSeek( xFilial("ZAN") + cIdentCte + cNumero )
			RecLock("ZAN",.T.)
			ZAN->ZAN_FILIAL := xFilial("ZAN")
			ZAN->ZAN_IDCTE  := cIdentCte
		Else
			RecLock("ZAN",.F.)
		Endif

		ZAN->ZAN_NEMIS := oJson["cte"][cte]["notafiscal"][nf]["emissor"]
		ZAN->ZAN_NNUME := oJson["cte"][cte]["notafiscal"][nf]["numero"]
		ZAN->ZAN_NSERI := oJson["cte"][cte]["notafiscal"][nf]["serie"]
		ZAN->ZAN_NCHAV := oJson["cte"][cte]["notafiscal"][nf]["chave"]
		ZAN->ZAN_NEMIA := oJson["cte"][cte]["notafiscal"][nf]["emissao"]
		ZAN->ZAN_NFPES := oJson["cte"][cte]["notafiscal"][nf]["peso"]
		ZAN->ZAN_NPEC := oJson["cte"][cte]["notafiscal"][nf]["pesocalculado"]
		ZAN->ZAN_NM3 := oJson["cte"][cte]["notafiscal"][nf]["m3"]
		ZAN->ZAN_NVOLU := oJson["cte"][cte]["notafiscal"][nf]["volumes"]
		ZAN->ZAN_NVALO := oJson["cte"][cte]["notafiscal"][nf]["valor"]
		ZAN->ZAN_NPROD := oJson["cte"][cte]["notafiscal"][nf]["produto_dominante"]
		

		MsUnLock()

	Next nf

Next cte

If lErrJson
	SetRestFault(2,;
				 "Falha na inclusao do cte.",;
				 .T.,;
				 400,;
				 "Houve uma falha na leitura dos dados no Json, efetue a correcao.")
	Return(.F.)
Else
	oJsonRet["success"] := .T.
	self:SetResponse( oJsonRet:toJson() )
Endif

Return(lRet)
