#Include "Protheus.ch"
//Dicas de funções
//TRANSFORM(nVar01,"@E 99,999.99")
//cValToChar(VARIAVEL)
//DTOC(VARIAVEL)
//DOTS(VARIAVEL)

/*Utilizando as variáveis Declaradas abaixo, crie uma rotina que
apresente na tela a frase: “Total de vendas do dia 26/03/2025 foi de 1.786,00”,
para essa apresentação use a função MsgInfo().*/
User Function EXE02A()
    Local nTotVenda := 1786
    Local dDataVen  := Date()

    cMsg := "Total de vendas do dia "
    cMsg += DTOC(dDataVen)
    cMsg += " foi de "
    cMsg += TRANSFORM(nTotVenda,"@E 99,999.99")

    MsgInfo(cMsg,"Vendas")

Return

/* 2. Utilizando as variáveis declaradas abaixo, crie uma função de usuário que calcule o
valor do imposto e apresente na tela a frase: “Valor sem imposto: 5.000,00 'Quebra de linha'
                                               Valor com imposto: 8.000,00”. 
para essa apresentação use a função MsgInfo().*/
User Function EXE02B()
    Local nValortot := 5000
    Local nImp1     := 1000
    Local nImp2     := 1500
    Local nImp3     := 500

    cMsg := "Valor sem imposto: "
    cMsg += TRANSFORM(nValortot,"@E 99,999.99")
    cMsg += CRLF
    nValortot += nImp1 + nImp2 + nImp3
    cMsg += "Valor com imposto: "
    cMsg += TRANSFORM(nValortot,"@E 99,999.99")

    MsgInfo(cMsg,"Valor")

Return
