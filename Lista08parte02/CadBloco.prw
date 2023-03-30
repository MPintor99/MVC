#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} User Function CadBloco
    Cadastros do Condomínio
    @type  Function
    @author Matheus Pintor
    @since 30/03/2023
    @version 1.0
    /*/
User Function CadBloco()
    local cAlias    := "ZS5"
    local cTitle    := "Blocos do Condomínio"
    local oBrowse   := FwMBrowse():New()

    oBrowse:SetAlias(cAlias)
    oBrowse:SetDescription(cTitle)

    oBrowse:DisableDetails()
    oBrowse:DisableReport()

    oBrowse:Activate()
Return 

Static Function MenuDef()
    local aRotina := {}

    ADD OPTION aRotina TITLE "Visualizar"   ACTION 'VIEWDEF.CadBloco' OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE "Incluir"      ACTION 'VIEWDEF.CadBloco' OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE "Alterar"      ACTION 'VIEWDEF.CadBloco' OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE "Excluir"      ACTION 'VIEWDEF.CadBloco' OPERATION 5 ACCESS 0

Return aRotina

Static Function ModelDef()
    local oModel    := MpFormModel():New("CadBL")
    local oStruZS5  := FwFormStruct(1, "ZS5")
    
    oModel:AddFields("ZS5MASTER",,oStruZS5)

    oModel:SetPrimaryKey({"ZS5_COD"})

    oStruZS5:SetProperty('ZS5_COD', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD,  'GetSXENum("ZS5", "ZS5_COD")'))

Return oModel

Static Function ViewDef()
    local oModel    := FwLoadModel('CadBloco')
    local oStruZS5  := FwFormStruct(2, "ZS5")
    local oView     := FwFormView():New()

    oView:SetModel(oModel)

    oView:AddField("VIEW_ZS5", oStruZS5, "ZS5MASTER")

    oView:CreateHorizontalBox("ZS5MASTER", 100)

    oView:SetOwnerView("VIEW_ZS5", "ZS5MASTER")
    oView:EnableTitleView("VIEW_ZS5", "Cadastro de Blocos do Condomínio")

Return oView

