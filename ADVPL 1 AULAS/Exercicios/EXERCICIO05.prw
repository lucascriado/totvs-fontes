#Include "Protheus.Ch"
/*
1 - Realize um cadastro de cliente

2 - Crie uma função, que deve:
    Receber como parâmetro um código de cliente.
    Buscar o cliente na tabela SA1 com o código informado.
    Exibir uma mensagem informando se o cliente foi encontrado ou não.

    Dicas:

    Use DbSelectArea("SA1") para selecionar a tabela.

    Use DbSeek() para buscar o cliente.

3- Adicione a função criada no exercicio 2:
    Se o cliente existir, utilize Reclock() para realizar uma alteração no registro.
    Atualizar os seguintes campos do cliente:
    A1_NOME ? "CLIENTE ALTERADO"
    A1_END ? "ENDEREÇO ALTERADO"
    Liberar o registro após a atualização.

    Dicas:

    Use Reclock("SA1",.F.) para bloquear o registro antes da alteração.

    Utilize MsUnlock() para liberar o registro após a atualização.

4- utilizando o ponto de entrada A010TOK
    Verificar se o usuário estiver incluindo um novo produto (INCLUI), exibir uma mensagem perguntando:
    "Confirma a inclusão do produto [NOME_DO_PRODUTO]?"
    Se o usuário confirmar, a função deve continuar e incluir o registro.
    Se o usuário recusar, a função deve retornar Falso, impedindo a inclusão.

    Dicas:

    Use AllTrim(M->B1_DESC) para exibir o nome do produto corretamente.

    Estruture a lógica com If...EndIf.

    Retorne .T. ou .F. para indicar se a inclusão foi permitida

    Utilize MsgYesNo() para perguntar ao usuario.
*/

User Function xEXE05()
    Local cCodCli := "000001"

    BUSCACLI(cCodCli)
Return

Static Function BUSCACLI(_cCodCli)
    Local cAlias := "SA1"

    DbSelectArea(cAlias)
    (cAlias)->(DbSetOrder(1))
    (cAlias)->(DbGoTop())

    If (cAlias)->(DbSeek(xFilial(cAlias) + _cCodCli))
        MsgInfo("Cliente Encontrado")

        RecLock(cAlias,.F.)
        SA1->A1_NOME    := "CLIENTE ALTERADO"
        SA1->A1_END     := "ENDEREÇO ALTERADO"
        (cAlias)->(MsUnlock())        
    Else
        Alert("Cliente nao Encontrado")
    Endif
Return
