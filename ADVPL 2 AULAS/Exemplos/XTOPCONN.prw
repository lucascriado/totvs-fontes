#Include "Protheus.ch"
#Include "TopConn.Ch"

User Function XTCLINK()

	nConexao := TcLink("MSSQL/PROTHEUS","LocalHost",7890)
	If nConexao < 0
		UserException("Erro "+CVALTOCHAR(nConexao)+" ao conectar com MSSQL/BaseTeste")
	Else
		MsgInfo("Conexão com MSSQL/BaseTeste efetuada com sucesso "+CVALTOCHAR(nConexao))
	Endif

	If TCUnlink(nConexao)
		MsgInfo("Conexão encerrada com sucesso")
	Endif

Return

User function XSETCON()

	nAtual := AdvConnection()
	nConexao := TcLink("MSSQL/PROTHEUS","LocalHost",7890)
	If nConexao < 0
		UserException("Erro "+CVALTOCHAR(nConexao)+" ao conectar com MSSQL/BaseTeste")
	Else
		MsgInfo("Conexão com MSSQL/BaseTeste efetuada com sucesso "+CVALTOCHAR(nConexao))
	Endif

	// Volta para conexao salva na variavel nAtual
	lRet:=TCSETCONN(nAtual)
	If lRet
		MsgInfo("Conexão trocada com sucesso")
	Endif

Return

User Function XDUMMY()

	TCSetDummy(.t.)
	SX2->(DBGOTOP())
	WHILE SX2->(!EOF())
		DBSELECTAREA( SX2->X2_CHAVE )
		DBCLOSEAREA()
		SX2->(DBSKIP())
	ENDDO
	TCSetDummy(.F.)

Return

User Function XGETDB()

	cDB := TcGetDB()
	If Empty(cDB)
		MsgStop("Não há conexão ativa.")
	Else
		MsgInfo("Conectado com "+cDB)
	Endif

Return

User Function XDELFILE()

	If TcDelFile("SA1990")
		MSGINFO("Tabela excluída com sucesso")
	Else
		MSGINFO("Não foi possível excluir a tabela")
	Endif

Return

User function XGENQRY()

	DbSelectArea("SB1")

	cQuery := "SELECT *"
	cQuery += " FROM " + RetSqlName("SB1")
	cQuery += " Order By " + SqlOrder(SB1->(IndexKey()))
	cQuery := ChangeQuery(cQuery)

	cResultado := MSPARSE(cQuery,"MSSQL")
	MsgInfo(cResultado,"Formatado")

	If Select("TRB") > 0
        TRB->(DbCloseArea())
    ENdif

	//dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery), 'TRB', .F., .T.)
	TCQUERY cQuery NEW ALIAS "TRB"
	DbSelectArea("TRB")

	TCSetField( "TRB", "B1_UREV", "D", 8, 0 )
	TCSetField( "TRB", "B1_PRV1", "N", 14, 2 )

Return

User Function XMSERRO()

	cQry := "SELECT * FROM SA1990 WHERE A1_EST='SP' AND" // Propositalmente errado
	cNovo := MSPARSE(cQry,"INFORMIX")
	cERRO:= MSPARSEERROR()
	IF !EMPTY( cERRO )
		ALERT("Erro na query "+CRLF+cERRO )
	ENDIF

Return

User Function XMSFULL()
	Local cRet1
	Local cRet2

	Private cErro1 	:= ""
	Private cCon1	:= ""
	Private cErro2	:= ""
	Private cCon2	:= ""

	cQry := "SELECT * FROM SA1990 WHERE A1_EST='SP' AND"

	cRet1 := MsParseFull(cQry,"MSSQL",@cErro1,@cCon1)

	cQuery := "SELECT *"
	cQuery += " FROM " + RetSqlName("SB1")
	cQuery += " Order By " + SqlOrder(SB1->(IndexKey()))

	cRet2 := MsParseFull(cQuery,"MSSQL",@cErro2,@cCon2)

Return

User Function XLEX()
	nRET:=TCSQLEXEC("insert into not_exist (field_name, field_type) values ('name', 'type')")
	IF nRET < 0
		ALERT("Erro na execucao da query"+CRLF+TcSqlError())
	ENDIF
Return
