#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} User Function CadCond
    Cadastros do Condomínio
    @type  Function
    @author Matheus Pintor
    @since 30/03/2023
    @version 1.0
    /*/
User Function CadCond()
    Local cAlias := 'ZS5'
    Local cTitle := 'Cadastros do Condomínio'
    Local oBrowse := FwmBrowse():New()

    oBrowse:SetAlias(cAlias)
    oBrowse:SetDescription(cTitle)

    oBrowse:DisableDetails()
    oBrowse:DisableReport()

    oBrowse:Activate()
Return 

Static Function MenuDef()
    Local aRotina := {}

    ADD OPTION aRotina TITLE "Visualizar" ACTION 'VIEWDEF.CadCond' OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE "Incluir"     ACTION 'VIEWDEF.CadBloco' OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE "Alterar"  ACTION 'VIEWDEF.CadCond' OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE "Excluir"   ACTION 'VIEWDEF.CadCond' OPERATION 5 ACCESS 0
Return aRotina

Static Function ModelDef()
    Local oModel := MPFormModel():New('CadCond_M')
    Local oStruZS5 := FwFormStruct(1, 'ZS5')
    Local oStruZS6 := FwFormStruct(1, 'ZS6')

    oStruZS5:SetProperty('ZS5_COD',    MODEL_FIELD_INIT,    FwBuildFeature(STRUCT_FEATURE_INIPAD,  'GetSXENum("ZS5", "ZS5_COD")'))  

    oStruZS5:SetProperty('ZS5_BLOCO', MODEL_FIELD_WHEN, {|| .F.})

    oStruZS5:SetProperty('ZS5_DESC', MODEL_FIELD_WHEN, {|| .F.})

    oModel:AddFields('ZS5MASTER', /*OWNER*/, oStruZS5)
    oModel:SetDescription('Cadastro de Blocos')

    oModel:AddGrid('ZS6DETAIL', 'ZS5MASTER', oStruZS6)
    oModel:GetModel('ZS6DETAIL'):SetDescription('Apartamentos')

    oModel:SetRelation('ZS6DETAIL', {{'ZS6_FILIAL', 'xFilial("ZS6")'}, {'ZS6_BLOCO', 'ZS5_COD'}}, ZS6-> (IndexKey(1)))

    oModel:SetPrimaryKey({'ZS5_COD'})

    oModel:GetModel('ZS6DETAIL'):SetUniqueLine({'ZS6_COD'})

Return oModel

Static Function ViewDef()
    Local oModel := FwLoadModel('CadCond')
    Local oStruZS5  := FwFormStruct(2, "ZS5")
    Local oStruZS6  := FwFormStruct(2, "ZS6")
    Local oView     := FwFormView():New()

    oView:SetModel(oModel)
    oView:AddField('VIEW_ZS5', oStruZS5, 'ZS5MASTER')

    oView:AddGrid('VIEW_ZS6', oStruZS6, 'ZS6DETAIL')

    oView:CreateHorizontalBox('BLOCOS', 50)
    oView:CreateHorizontalBox('APARTAMENTOS', 50)

    oView:SetOwnerView('VIEW_ZS5', 'BLOCOS')
    oView:SetOwnerView('VIEW_ZS6', 'APARTAMENTOS')

    oView:EnableTitleView('VIEW_ZS5', 'Cadastro de Blocos')
    oView:EnableTitleView('VIEW_ZS6', 'Cadastro de Apartamentos')

    oView:AddIncrementField('VIEW_ZS6', 'ZS6_COD')

Return oView

