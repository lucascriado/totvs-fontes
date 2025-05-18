#Include "Protheus.Ch"

User Function XSERVCLI()
    Local cArqO := "\system\DTC\sa19901.dtc"
    Local cArqD := "C:\TESTE"
    Local cArq1 := "C:\TESTE\ARQUIVOENV.dtc"
    local cArq2 := "\system\DTC"

    CpyS2T(cArqO,cArqD,)

    CpyT2S(cArq1,cArq2)

Return
