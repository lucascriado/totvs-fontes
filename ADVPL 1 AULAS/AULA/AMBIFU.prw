#Include "Protheus.Ch"
//Fun��es que retornam informa��es do ambiente
User Function XAMBIFU(PARAM1,PARAM2)
    
    //Retorna o nome do arquivo de cofiguracao remote.
    cRet    := GetRemoteIniName()
    //Retorna o ambiente atual
    cRet2   := GetEnvServer()
    //Retorna o tema escolhido.
    cRet3   := GetTheme()
    //Retorna a extens�o da Base (DBF, DTC, etc)
    cRet4   := GetDBExtension()
    //Retorna a extens�o do Indice(CDX, IDX, NTX, etc)
    cRet5   := OrdBagExt()
    //Retorna o nome do fonte
    cRet6   := Funname()
    //Retorna o conteudo do parametro da se��o
    cRet7   := GetSrvProfString("Sourcepath", "\undefined")
    //Retorna um array com as fun��es do reposit�rio do ambiente corrente
    cRet8   := GetFuncArr("U_XAMBIFU")
    //Retorna um array com dados do programa informado dentro do reposit�rio
    cRet9   := GetApoInfo("AMBIFU.prw")

    //Mesagem no concolo do appserver
    Conout("MENSAGEM NO CONSOLE")

Return
