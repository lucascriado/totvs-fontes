#Include "Protheus.ch"
//Link de funções para manipulação de matriz
//https://tdn.totvs.com/pages/viewpage.action?pageId=6063768

//Dicas de funções
//aSize(ARRAY,5)
//AFill( ARRAY, CONTEUDO, ELEMENTO INCIAL, QUANTOS ELEMENTOS )
//Array(5,3)

/* 
1-Criando um vetor com nomes:
    Declare um array unidimensional chamado aAlunos contendo os nomes de três colegas de classe.

2-Expandindo o vetor:
    Aumente o tamanho do array aAlunos adicionando mais dois espaços vazios.

3-Preenchendo os novos espaços:
    Insira o nome de dois colegas nos espaços adicionados no exercício anterior.

4-Criando uma matriz para representar a turma:
    Crie um array bidimensional de 5 linhas por 3 colunas e nomeie-o como aTurma.

5-Preenchendo a matriz com os nomes dos alunos:
    Insira os nomes armazenados no vetor aAlunos na primeira coluna do array aTurma, preenchendo todas as linhas.
*/

User function ALEXE03()
    Local aAlunos   := {"Bruno","Lucas","Juliano"}
    Local aTurma    := Array(5,3)   

    aSize(aAlunos,Len(aAlunos)+2)

    aFill(aAlunos,"Elaine",Len(aAlunos)-1,1)
    aFill(aAlunos,"Gustavo",5)

    aTurma[1][1] := aAlunos[1]
    aTurma[2][1] := aAlunos[2]
    aTurma[3][1] := aAlunos[3]
    aTurma[4][1] := aAlunos[4]
    aFill(aTurma[5],aAlunos[5],1,1)

Return

