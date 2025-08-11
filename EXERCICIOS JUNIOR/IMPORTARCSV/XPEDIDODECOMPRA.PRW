#Include "Protheus.ch"
#Include "RwMake.ch"
#Include "TbiConn.ch"
 
User Function XPCOMPRA()

Local aCabec := {}
Local aItens := {}
Local aLinha := {}
Local nX := 0
Local cDoc := ""
Local nOpc := 3
Local xFilial := "01"

PRIVATE lMsErroAuto := .F.

// PREPARE ENVIRONMENT EMPRESA "01" FILIAL "1001" MODULO "COM"
dbSelectArea("SC7")

// Obter número do pedido
cDoc := GetSXENum("SC7","C7_NUM")
SC7->(dbSetOrder(1))

// Aqui você deveria passar a filial correta (exemplo "01")

// Monta o cabeçalho básico
aadd(aCabec,{"C7_FILIAL" ,xFilial})
aadd(aCabec,{"C7_NUM" ,cDoc})
aadd(aCabec,{"C7_EMISSAO" ,dDataBase})
aadd(aCabec,{"C7_FORNECE" ,"000001"})   // Fornecedor válido com 6 dígitos
aadd(aCabec,{"C7_LOJA" ,"01"})
aadd(aCabec,{"C7_COND" ,"001"})
aadd(aCabec,{"C7_CONTATO" ,"AUTO"})
aadd(aCabec,{"C7_FILENT" ,"01"})       // Filial entrada, ex: "01"
aadd(aCabec,{"C7_TPFRETE" ,"C"})
aadd(aCabec,{"C7_FRETE" ,15})

// Monta o item básico
For nX := 1 To 1
    aLinha := {}
    aadd(aLinha,{"C7_PRODUTO" ,"000000000000004",Nil})
    aadd(aLinha,{"C7_QUANT" ,1 ,Nil})
    aadd(aLinha,{"C7_PRECO" ,100 ,Nil})
    aadd(aLinha,{"C7_TOTAL" ,100 ,Nil})
    aadd(aItens,aLinha)
Next nX

// Chamada do MSExecAuto sem rateio e adiantamento
MSExecAuto({|a,b,c,d,e,f,g,h| MATA120(a,b,c,d,e,f,g,h)},1,aCabec,aItens,nOpc,.F.)

If !lMsErroAuto
    ConOut("Incluido PC: "+cDoc)
Else
    
    ConOut("Erro na inclusao: "+ MostraErro())
EndIf

Return
