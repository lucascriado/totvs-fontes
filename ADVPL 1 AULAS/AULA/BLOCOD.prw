#Include "Protheus.Ch"
//exemplo de utilização de DbEval
User Function XBLOCOD()
    Local bBloco

    Private abloco := {}
    Private nX     := 0 


    DbSelectArea("SX5")
    SX5->(DbSetOrder(1))   
    bBLoco      := {|| nX ++,aAdd(abloco,{X5_CHAVE,X5_DESCRI})}
    bCondicao   := {|| X5_TABELA=="00"}
    
    DBeval(bBloco,,bCondicao)

Return
