#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} User Function ExFinalL8
    Visualizações da Auto-Escola.
    @type  Function
    @author Matheus Pintors
    @since 29/03/2023
    /*/
User Function ExFinalL8()
    local cAlias    := 'ZS1'
    local cTitle    := 'Auto-Escola'
    local oBrowse   := FwMBrowse():New()
    oBrowse:SetAlias(cAlias)
    oBrowse:SetDescription(cTitle)
    
    oBrowse:DisableDetails()
    oBrowse:DisableReport()
    oBrowse:Activate()
Return 

Static Function MenuDef()
    local aRotina := {}
    ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.ExFinalL8" OPERATION 2 ACCESS 0
Return aRotina

Static Function ModelDef()
    local oModel    := MPFormModel():New("ExFinalL8_M")
    local oStruZS1  := FWFormStruct(1, "ZS1")
    local oStruZS3  := FWFormStruct(1, "ZS3")
    local oStruZS4  := FWFormStruct(1, "ZS4")
    /*
    ZS1 - CNH
    ZS3 - INSTRUTOR
    ZS4 - ALUNOS 
    */
    oModel:AddFields("ZS1MASTER", NIL, oStruZS1)
    oModel:AddGrid("ZS3DETAIL", "ZS1MASTER", oStruZS3)
    oModel:AddGrid("ZS4DETAIL", "ZS3DETAIL", oStruZS4)
    oModel:SetRelation('ZS3DETAIL', {{'ZS3_FILIAL', 'xFilial("ZS3")'}, {'ZS3_CATEGO', 'ZS1_SIGLA'}}, ZS3->(IndexKey(1)))
    oModel:SetRelation('ZS4DETAIL', {{'ZS4_FILIAL', 'xFilial("ZS4")'}, {'ZS4_CODINS', 'ZS3_COD'}}, ZS4->(IndexKey(1)))
    oModel:SetPrimaryKey({'ZS1_COD','ZS3_COD', 'ZS4_COD'})
Return oModel

Static Function ViewDef()
    local oModel    := FwLoadModel('ExFinalL8')
    local oStruZS1  := FwFormStruct(2, "ZS1")
    local oStruZS3  := FwFormStruct(2, "ZS3")
    local oStruZS4  := FwFormStruct(2, "ZS4")
    local oView     := FwFormView():New()

    oView:SetModel(oModel)

    oView:AddField("VIEW_ZS1", oStruZS1, "ZS1MASTER")
    oView:AddGrid("VIEW_ZS3", oStruZS3, "ZS3DETAIL")
    oView:AddGrid("VIEW_ZS4", oStruZS4, "ZS4DETAIL")

    oView:CreateHorizontalBox("CNH", 33)
    oView:CreateHorizontalBox("INSTRUTOR", 33)
    oView:CreateHorizontalBox("ALUNO", 34)

    oView:SetOwnerView("VIEW_ZS1", "CNH")
    oView:EnableTitleView("VIEW_ZS1", "Categorias de CNH")
    
    oView:SetOwnerView("VIEW_ZS3", "INSTRUTOR")
    oView:EnableTitleView("VIEW_ZS3", "Instrutores da Categoria")

    oView:SetOwnerView("VIEW_ZS4", "ALUNO")
    oView:EnableTitleView("VIEW_ZS4", "Alunos do Instrutor")

Return oView
