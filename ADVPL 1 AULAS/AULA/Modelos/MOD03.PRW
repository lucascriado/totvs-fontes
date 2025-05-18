#include "protheus.ch"
User Function CadM3()
	Private cAlias1 := "SA1"
	Private cAlias2 := "SB1"
	Private aHeader := {}
	Private aCols := {}
	Private cCadastro := "Modelo 3"
	Private aRotina := {}

	AAdd(aRotina, {"Pesquisar"  , "axPesqui" , 0, 1})
	AAdd(aRotina, {"Visualizar" , "U_Incmod3" , 0, 2})
	AAdd(aRotina, {"Incluir"    , "u_Incmod3" , 0, 3})
	AAdd(aRotina, {"Altera"     , "u_Incmod3" , 0, 4})
	AAdd(aRotina, {"Excluir"    , "u_Incmod3" , 0, 5})

	mBrowse(,,,,cAlias1)
Return

User Function Incmod3(cAlias, nReg, nOpc)
	Local nAdi := 0
	Local i := 0
	Private j:=1

	//Criar as variaveis de memoria
	RegToMemory(cAlias1, (nOpc==3))
	RegToMemory(cAlias2, (nOpc==3))

	aHeader := {}
	aCols := {}

	//Monta aheader
	dbSelectArea("SX3")
	dbSetorder(1)
	dbSeek(cAlias2)
	While SX3->(!EOF()) .AND. SX3->X3_ARQUIVO == cAlias2
		If X3USO(SX3->X3_USADO) .AND. cNIVEL >= SX3->X3_NIVEL;
				.AND. ALLTRIM(SX3->X3_CAMPO) $ "B1_COD/B1_DESC/B1_TIPO/B1_UM/B1_LOCPAD"
			AAdd(aHeader, {Trim(SX3->X3_TITULO),;//01 - titulo
			SX3->X3_CAMPO ,; //02- nome do campo
			SX3->X3_PICTURE ,; //03 - mascara do campo
			SX3->X3_TAMANHO ,; //04 - tamanho
			SX3->X3_DECIMAL ,; //05 - decimais
			SX3->X3_VALID ,; //06 - validacao
			SX3->X3_USADO ,; //07 - USADO
			SX3->X3_TIPO ,; //08 - TIPO DO CAMPO
			SX3->X3_ARQUIVO ,; //09 - ALIAS
			SX3->X3_CONTEXT}) //10 - Virtual ou Real
		ENDIF
		SX3->(DBSKIP())
	ENDDO

	//Monta acols
	If nOpc == 3 //Inclusão
		AAdd(aCols, Array(Len(aHeader) + 1))

		For nAdi:= 1 to Len(aHeader)
			aCols[1][nADI] := Criavar(aHeader[nADI][2])
		Next

		ACols[1][len(aHeader)+1] := .F.
	Else //Visual/Altera/Exclui
		(cAlias2)->(dbSetOrder(14))
		(cAlias2)->(dbSeek(xFilial(cAlias2) + (cAlias1)->A1_COD))
		While (cAlias2)->(!EOF()).And.(cAlias2)->B1_CODCLI == (cAlias1)->A1_COD

			AAdd(aCols, Array(len(aHeader)+1))

			For i := 1 To Len(aHeader)
				If aHeader[i][10] <> "V"
					aCols[len(aCols)][i] := (cAlias2)->&(aHeader[i][2])
				Else
					aCols[len(aCols)][i] := CriaVar(aHeader[i][2])
				EndIf
			Next

			ACols[j][len(aHeader)+1] := .F.
			(cAlias2)->(dbSkip())
			j++
		Enddo
	Endif

	lRet := Modelo3(cCadastro, cAlias1, cAlias2,,"AllwaysTrue()","AllwaysTrue()" , nOpc, nOpc,"AllwaysTrue()" ,,,,,,,350)

	If lRet
		If nOpc == 3 // Inclusão
			RecLock(cAlias1,.T.)
			(cAlias1)->A1_COD 		:= M->A1_COD
			(cAlias1)->A1_LOJA		:= M->A1_LOJA
			(cAlias1)->A1_NOME 		:= M->A1_NOME
			(cAlias1)->A1_END 		:= M->A1_END
			(cAlias1)->A1_NREDUZ	:= M->A1_NREDUZ
			(cAlias1)->A1_TIPO 		:= M->A1_TIPO
			(cAlias1)->A1_EST 		:= M->A1_EST
			(cAlias1)->A1_MUN 		:= M->A1_MUN
			(cAlias1)->(MsUnlock())

			For i := 1 to Len(aCols)
				If !aCols[i][6]
					RecLock(cAlias2,.T.)
					(cAlias2)->B1_COD		:= aCols[i][1]
					(cAlias2)->B1_DESC		:= aCols[i][2]
					(cAlias2)->B1_TIPO		:= aCols[i][3]
					(cAlias2)->B1_UM		:= aCols[i][4]
					(cAlias2)->B1_LOCPAD	:= aCols[i][5]
					(cAlias2)->B1_CODCLI	:= M->A1_COD
					(cAlias2)->(MsUnlock())
				Endif
			Next

		ElseIf nOpc == 4 //Alteracao
			RecLock(cAlias1,.F.)
			(cAlias1)->A1_NOME 		:= M->A1_NOME
			(cAlias1)->A1_END 		:= M->A1_END
			(cAlias1)->A1_NREDUZ	:= M->A1_NREDUZ
			(cAlias1)->A1_TIPO 		:= M->A1_TIPO
			(cAlias1)->A1_EST 		:= M->A1_EST
			(cAlias1)->A1_MUN 		:= M->A1_MUN
			(cAlias1)->(MsUnlock())

			DbSelectArea(cAlias2)
			(cAlias2)->(DbSetOrder(1))
			(cAlias2)->(DbGoTop())
			For i := 1 to Len(aCols)
				(cAlias2)->(DbSeek(xFilial(cAlias2) + aCols[i][1]))

				If !aCols[i][6]
					RecLock(cAlias2,.F.)
					(cAlias2)->B1_DESC		:= aCols[i][2]
					(cAlias2)->B1_TIPO		:= aCols[i][3]
					(cAlias2)->B1_UM		:= aCols[i][4]
					(cAlias2)->B1_LOCPAD	:= aCols[i][5]
					(cAlias2)->(MsUnlock())
				Else
					RecLock(cAlias2,.F.)
					(cAlias2)->(DbDelete())
					(cAlias2)->(MsUnlock())
				Endif
			Next

		ElseIf nOpc == 5 //exclusao
			RecLock(cAlias1,.F.)
			(cAlias1)->(DbDelete())
			(cAlias1)->(MsUnlock())

			DbSelectArea(cAlias2)
			(cAlias2)->(DbSetOrder(1))
			(cAlias2)->(DbGoTop())
			For i := 1 to Len(aCols)
				(cAlias2)->(DbSeek(xFilial(cAlias2) + aCols[i][1]))

				RecLock(cAlias2,.F.)
				(cAlias2)->(DbDelete())
				(cAlias2)->(MsUnlock())
			Next
		Endif
	Endif
Return
