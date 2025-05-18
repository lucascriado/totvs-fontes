#Include "Protheus.ch"
//Exemplo de manipulação de array uni e bi-dimensional
User Function ALARRAY()
    Local aArray    := {"Bruno","Lucas","Juliano","Marcos","Elaine"}
    Local aIdade    := {25,22,27,35,23}
    Local aArray2   := {{"Bruno"    ,25},;
                        {"Lucas"    ,22},;
                        {"Juliano"  ,27},;
                        {"Marcos"   ,35},;
                        {"Elaine"   ,23}}
    Local aNArray   :={,}

    aNArray[1]  := "Gustavo"
    aNArray[2]  := 30

    MsgInfo(Valtype(aNArray[1]))
    //MsgInfo(aArray[5] + " " + Cvaltochar(aIdade[5]))

    MsgInfo(aArray2[1,1] + " " +Cvaltochar(aArray2[1][2]))
Return

//Funcoes de manipulacao de array
User Function ALFAR()
    Local aArray    := Array(10) //Cria array com numero de elementos espicificados
    Local aAdd      := {}
    Local aClone
    Local aArray2   := {{"Bruno"    ,25},;
                        {"Lucas"    ,22},;
                        {"Juliano"  ,27},;
                        {"Marcos"   ,35},;
                        {"Elaine"   ,23}} 

    //Adiciona dado a um array
    aAdd(aAdd,"Elton")
    aAdd(aAdd,"Camilo")
    aAdd(aAdd,{"Camilo",35,})

    //Clona um array
    aClone := aClone(aAdd)
    aDel   := aClone(aAdd)
    
    //Deleta elemento espicificado em um array
    aDel(aDel,1)
    //Muda o tamanho do array para o especificado
    aSize(aDel,2)

    //Copia um array para outro
    aCopy(aAdd,aArray,1,2,3)

    //adiciona dado em um array em outro
    aFill(aArray,"Laryssa",1,2)
    aFill(aArray,"Marcus",10)

    //Inclui 1 elemento nulo na posicao especificada
    aIns(aArray,2)

    //verifica se um dado existe no array
    nEleme := aScan(aArray,"Camilo")

    //ordena o array
    ASort(aArray2, , , {|x,y| x[2] < y[2]})
    //retorna ultimo elemento do array
    ATail(aArray)
Return
