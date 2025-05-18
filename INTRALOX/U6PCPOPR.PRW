#include "protheus.ch"
#include "tbiconn.ch"
#include "colors.ch"
#include "rptdef.ch"
#include "FWPrintSetup.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ PDFPICK   ¦ Autor ¦  Fabrica ERPBR    ¦ Data ¦ 02/11/2024  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Pick List ordem de produção modelo Pdf.					  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo INTRALOX										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function PDFPICK() // aOrdemP, zPathPDF, lExibe

//Local oFont08  := TFont():New("Arial",08,08,,.F.,,,,.T.,.F.)
//Local oFont09N := TFont():New("Arial",09,09,,.T.,,,,.T.,.F.)
Local oFont10  := TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
Local oFont10N := TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)
//Local oFont12  := TFont():New("Arial",12,12,,.F.,,,,.T.,.F.)
Local cPath    := "c:\report"
Local aOrdemP  := {}
Local lExibe   := .T.
Local zPathPDF := ""
Local zPdf     := ""
Local zTotFol  := 1
Local pdc, _pdc
Private opdc

If !ExistDir(cPath)
	MakeDir(cPath)
EndIf

zPathPDF := AllTrim(cPath)+"\"

If !(FWCodEmp() $("99,U6"))
	MsgAlert("Empresa não autorizada: "+FWCodEmp())
	Return
Endif

// Estrutura:
// [1]  - Cliente
// [2]  - Ordem Produção
// [3]  - Quantidade
// [4]  - Código Produto
// [5]  - Descrição Produto
// [6]  - Previsão Início
// [7]  - Data Entrega
// [8]  - Seiban
// [9]  - Código Componente
// [10] - Descrição Componente
// [11] - Quantidade requirida
// [12] - Quantidade disponível
// [13] - Descrição complementar
// [14] - Fornecedor
// [15] - Endereço

AAdd(aOrdemP,{"INGENIERIA PLANA ALTA SA",;
			  "2202130",;
			  1,;
			  "DPP-3308480-001",;
			  "DARB SORTER S4500",;
			  "28/06/2024",;
			  "02/08/2024",;
			  "3202130-1",;
			  "DPP-1015807",;
			  "MECHANICAL BEARING TWO-BOLT FLANGE 1",;
			  4,;
			  8,;
			  "F2B-SCEZ-50MM-PCR 1",;
			  "DODGE 1",;
			  "A01A" })

AAdd(aOrdemP,{"INGENIERIA PLANA ALTA SA",;
			  "2202130",;
			  1,;
			  "DPP-3308480-001",;
			  "DARB SORTER S4500",;
			  "28/06/2024",;
			  "02/08/2024",;
			  "3202130-1",;
			  "DPP-1015808",;
			  "MECHANICAL BEARING TWO-BOLT FLANGE 2",;
			  5,;
			  9,;
			  "F2B-SCEZ-50MM-PCR 2",;
			  "DODGE 2",;
			  "A02A" })

AAdd(aOrdemP,{"INGENIERIA PLANA ALTA SA",;
			  "2202130",;
			  1,;
			  "DPP-3308480-001",;
			  "DARB SORTER S4500",;
			  "28/06/2024",;
			  "02/08/2024",;
			  "3202130-1",;
			  "DPP-1015809",;
			  "MECHANICAL BEARING TWO-BOLT FLANGE 3",;
			  3,;
			  7,;
			  "F2B-SCEZ-50MM-PCR 3",;
			  "DODGE 3",;
			  "A03A" })

If Len(aOrdemP) == 0
	MsgAlert("Sem dados para geração do Pdf.")
	Return
Endif

zPdf := "2202130 - INGENIERIA PLANA ALTA SA"

zPdf := StrTran(zPdf,".","")
zPdf := StrTran(zPdf,",","")
zPdf := StrTran(zPdf,"-","")
zPdf := StrTran(zPdf,"_","")
zPdf := StrTran(zPdf,";","")
zPdf := StrTran(zPdf,"&","")
zPdf := StrTran(zPdf,"/","")
zPdf := StrTran(zPdf,"\","")
zPdf := StrTran(zPdf,"(","")
zPdf := StrTran(zPdf,")","")
zPdf := StrTran(zPdf,"{","")
zPdf := StrTran(zPdf,"}","")
zPdf := StrTran(zPdf,"[","")
zPdf := StrTran(zPdf,"]","")
zPdf := StrTran(zPdf,"º","")
zPdf := StrTran(zPdf,"@","")
zPdf := StrTran(zPdf,"%","")
zPdf := StrTran(zPdf,"$","")
zPdf := StrTran(zPdf,"#","")
zPdf := StrTran(zPdf,"!","")
zPdf := StrTran(zPdf,"?","")
zPdf := StrTran(zPdf,CHR(13),"")
zPdf := StrTran(zPdf,CHR(10),"")

// Paginas
xLin := 210
For _pdc := 1 to Len(aOrdemP)

	If xLin > 530
		xLin := 210
		zTotFol += 1
	Endif
	xLin += 15

	lImpLn2 := .F.
//	zDescr2 := AllTrim(Substr(SC7->C7_DESCRI,36))
//	If !Empty(zDescr2)
//		lImpLn2 := .T.
//		xLin += 15
//	Endif
//	If !lImpLn2
//		xLin += 15
//	Endif

Next _pdc
xLin += 15
xLin += 10
xLin += 15
If xLin > 500
	zTotFol += 1
Endif
zTotFol += 3

opdc:=FWMSPrinter():New(zPdf,IMP_PDF,.F.,zPathPDF,.T.,,@opdc,,,,,lExibe)
opdc:SetResolution(72)
opdc:SetPortrait()
//opdc:SetLandscape()
opdc:SetPaperSize(DMPAPER_A4)
opdc:SetMargin(60,60,60,60)
opdc:cPathPDF := zPathPDF

opdc:StartPage()
pdcCab(1,zTotFol,.T.)

zFolha  := 1
zLin    := 210
For pdc := 1 to Len(aOrdemP)
	If zLin > 790
		opdc:Line(zLin, 0000, zLin, 0800)
		opdc:EndPage()
		opdc:StartPage()
		zFolha += 1
		pdcCab(zFolha,zTotFol,.T.)
		zLin := 210
	Endif

	opdc:Say(zLin, 0000, "0001",oFont10,,IIf(GetMv("MV_IMPXML"),CLR_HRED,CLR_BLACK))
	opdc:Say(zLin, 0030, "PRODUTO",oFont10)
	opdc:Say(zLin, 0580, Transform(18, PesqPict("SC7","C7_PICM")),oFont10)
	zLin += 15
	opdc:Say(zLin, 0030, "123456",oFont10)
	
//	lImpLn2 := .F.
//	zDescr2 := AllTrim(Substr(SC7->C7_DESCRI,36))
//	If !Empty(zDescr2)
//		lImpLn2 := .T.
//		opdc:Say(zLin, 0240, zDescr2,oFont10)
//		zLin += 15
//	Endif
//	If !lImpLn2
//		zLin += 15
//	Endif

Next pdc
opdc:Line(zLin, 0000, zLin, 0800)
zLin += 15
opdc:Say(zLin, 0000, "ICMS: "+AllTrim(Transform(18, PesqPict("SC7","C7_VALICM"))),oFont10N)
opdc:Say(zLin, 0120, "IPI: "+AllTrim(Transform(10, PesqPict("SC7","C7_VALIPI"))),oFont10N)
zLin += 10
opdc:Line(zLin, 0000, zLin, 0800)
zLin += 15

opdc:EndPage()

cFilePrint := zPathPDF+zPdf+".pdf"
If lExibe
	opdc:Preview()
Else
	File2Printer( cFilePrint, "PDF" )
	opdc:Preview()
	CpyT2S( cFilePrint, "\U6", .F. )
Endif	

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ pdcCab  ¦ Autor ¦  Fabrica ERPBR    ¦ Data ¦ 02/11/2024	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Impressão do cabeçalho.									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo INTRALOX										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function pdcCab(zFolha,zTotFol,lCabDet)

Local cStartPath := GetSrvProfString("Startpath","")
Local cLogoTp    := cStartPath + "logo_intraloxU6.bmp"

//Local oFont08N := TFont():New("Arial",08,08,,.T.,,,,.T.,.F.)
//Local oFont10  := TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
Local oFont10N := TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)
//Local oFont12  := TFont():New("Arial",12,12,,.F.,,,,.T.,.F.)
Local oFont16N := TFont():New("Arial",16,16,,.T.,,,,.T.,.F.)

opdc:SayBitmap(0025, 0000, cLogoTp, 0130, 0070)

opdc:Say(0060, 0325, "PEDIDO DE COMPRA:",oFont16N)
//opdc:Say(0060, 0465, "AD5004",oFont16N,,IIf(GetMv("MV_IMPXML"),CLR_HRED,CLR_BLACK))
opdc:Say(0060, 0465, "AD5004",oFont16N,,CLR_HRED)

opdc:Box(0090, 0000, 0170, 0800)
//opdc:Line(0090, 0400, 0170, 0400)

If lCabDet
	opdc:Say(0185, 0000, "Item",oFont10N)
//	opdc:Say(0180, 0030, "Código",oFont10N)
//	opdc:Say(0192, 0030, "N.C.M.",oFont10N)
//	opdc:Line(0195, 0000, 0195, 0800)
Endif

Return
