/*
Exercício: Cálculo da Média e Status dos Alunos
Objetivo:
Com base em um array bidimensional contendo os nomes dos alunos e suas notas, 
exibir na tela o nome de cada aluno seguido de sua média e situação acadêmica, conforme a regra abaixo:

    "Aprovado" se a média for maior que 25

    "Exame" se a média estiver entre 10 e 25

    "Reprovado" se a média for menor que 10

Exemplo de entrada (array bidimensional):
    aArray := { { “Maria”, 10, 7, 15, 31} ,;
    { “Jose ”, 15, 16, 21, 33} , ;
    { “Petruncio”, 8, 8, 8, 6} , ;
    { “Firmino”, 15, 16, 21, 33} , ;
    { “Felizberto”, 10, 17, 31, 25} }

Saída esperada:
    Carlos - Média: 30 - Aprovado  

Tarefas:
    1-Criar um array bidimensional (aTurma) onde cada linha representa um aluno e suas notas.

    2-Calcular a média das notas de cada aluno.

    3-Determinar o status do aluno com base na média.

    4-Exibir na tela o nome do aluno, sua média e sua situação acadêmica.

Estruturade repeticao recomendado:
    FOR nI := 1 To Len(aTurma)
        FOR nX := 1 To Len(aTurma[nI])
        Next
    NEXT
*/
