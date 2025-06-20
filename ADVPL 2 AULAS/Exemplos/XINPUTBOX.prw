#Include "protheus.ch"

User Function  Exiptbox()
	Local cDescr as character
	Local cText  as character
	Local cResp  as character

	cDescr := 'Nome completo: '
	cText  := 'Digite seu nome: '
	cResp   := FWInputBox(cDescr, cText )
    cResp1  := FWInputBox(cDescr, cText )

	MsgInfo(cResp + CRLF +cResp1, 'Retorno da função FWInputBox')

Return
