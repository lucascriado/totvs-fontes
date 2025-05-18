#Include "Protheus.Ch"

User Function XPARAL()
    Local cMV1 := GetMV("AL_TREINA")
    Local cMV2 := SuperGetMv("AL_TREINAR", .F., "PADRAO")

    StrTokArr(cMV1,";")
       
Return
