#Include "Protheus.ch"

//Exemplo de estrutura de decisão
User Function XIF()
    Local aNotas    := {"Leandro",6,10,9,10}
    Local lProjet   := .T.
    Local nRecupe   := 10
    Local nMedia    := 7
    Local nNota     := 0   

    nNota += aNotas[2]
    nNota += aNotas[3]
    nNota += aNotas[4]
    nNota += aNotas[5]

    nNota := nNota/4

    If nNota >= nMedia .And. lProjet
        MSgInfo("Leandro passou","Resultado")
    ElseIf nRecupe >= nMedia
        MSgInfo("Leandro passou","Resultado")
    Else
        MSgInfo("Leandro reprovou","Resultado")
    Endif

    Do Case
    Case nNota >= nMedia .And. lProjet
        MSgInfo("Leandro passou","Resultado")
    Case nRecupe >= nMedia
        MSgInfo("Leandro passou","Resultado")
    OTHERWISE
        MSgInfo("Leandro reprovou","Resultado")
    End Case

Return
