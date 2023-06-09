#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} User Function DOList
    Cadastros do Condom�nio
    @type  Function
    @author Matheus Pintor
    @since 30/03/2023
    @version 1.0
    /*/
User Function DOList()
    Local cAlias := 'ZS7'
    Local cTitle := 'Cadastros do Condom�nio'
    Local oBrowse := FwmBrowse():New()

    oBrowse:SetAlias(cAlias)
    oBrowse:SetDescription(cTitle)

    oBrowse:DisableDetails()
    oBrowse:DisableReport()

    oBrowse:AddLegend('ZS7_TAREFA == "1"', "GREEN", "Tarefa Conclu�da",  "2")
    oBrowse:AddLegend('ZS7_TAREFA == "2"', "RED",   "Tarefa n�o conclu�da", "2")

    oBrowse:Activate()
Return 

Static Function MenuDef()
    Local aRotina := {}

    ADD OPTION aRotina TITLE "Visualizar" ACTION 'VIEWDEF.DOList' OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE "Incluir"     ACTION 'VIEWDEF.DOList' OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE "Alterar"  ACTION 'VIEWDEF.DOList' OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE "Excluir"   ACTION 'VIEWDEF.DOList' OPERATION 5 ACCESS 0
Return aRotina

Static Function ModelDef()
    Local bGridPos    := {|oGrid| GridPos(oGrid)} 
    Local oModel   := MPFormModel():New('MList')

    Local oStruZS7 := FwFormStruct(1, 'ZS7')
    Local oStruZS8 := FwFormStruct(1, 'ZS8')

    oStruZS7:SetProperty('ZS7_COD',    MODEL_FIELD_INIT,    FwBuildFeature(STRUCT_FEATURE_INIPAD,  'GetSXENum("ZS7", "ZS7_COD")'))  


    oModel:AddFields('ZS7MASTER', /*OWNER*/, oStruZS7)
    oModel:SetDescription('Cadastro de Blocos')

    oModel:AddGrid('ZS8DETAIL', 'ZS7MASTER', oStruZS8, NIL, NIL, NIL, bGridPos)
    oModel:GetModel('ZS8DETAIL'):SetDescription('Apartamentos')

    oModel:SetRelation('ZS8DETAIL', {{'ZS8_FILIAL', 'xFilial("ZS8")'}, {'ZS8_LISTA', 'ZS7_COD'}}, ZS8-> (IndexKey(1)))

    oModel:SetPrimaryKey({'ZS7_COD'})

    oModel:GetModel('ZS8DETAIL'):SetUniqueLine({'ZS8_COD'})

Return oModel

Static Function ViewDef()
    Local oModel := FwLoadModel('DOList')
    Local oStruZS7  := FwFormStruct(2, "ZS7")
    Local oStruZS8  := FwFormStruct(2, "ZS8")
    Local oView     := FwFormView():New()

    oView:SetModel(oModel)
    oView:AddField('VIEW_ZS7', oStruZS7, 'ZS7MASTER')

    oView:AddGrid('VIEW_ZS8', oStruZS8, 'ZS8DETAIL')

    oView:CreateHorizontalBox('BLOCOS', 50)
    oView:CreateHorizontalBox('APARTAMENTOS', 50)

    oView:SetOwnerView('VIEW_ZS7', 'BLOCOS')
    oView:SetOwnerView('VIEW_ZS8', 'APARTAMENTOS')

    oView:EnableTitleView('VIEW_ZS7', 'Cadastro de Blocos')
    oView:EnableTitleView('VIEW_ZS8', 'Cadastro de Apartamentos')

    oView:AddIncrementField('VIEW_ZS8', 'ZS8_COD')

Return oView

Static Function GridPos(oGrid)
    Local cCodTarefa := FWFldGet('ZS7_COD')
    Local nLinhas    := oGrid:Length()
    Local nCont      := 0
    Local nMarc      := 0
    Local lOk        := NIL
    
    For nCont := 1 to nLinhas
        oGrid:GoLine(nCont)
        lOk := oGrid:GetValue('ZS8_MARC')
        
        If !oGrid:IsDeleted() .AND. lOk
            nMarc++
        Endif
    Next

    If nMarc == nLinhas
        If ZS7->(DbSeek(xFilial('ZS7') + cCodTarefa) )
            If ZS7->(Reclock('ZS7', .F.))
                ZS7->ZS7_TAREFA := '1'
                ZS7->(MSUnlock())
            Endif
        Endif
    Else
                If ZS7->(DbSeek(xFilial('ZS7') + cCodTarefa) )
            If ZS7->(Reclock('ZS7', .F.))
                ZS7->ZS7_TAREFA := '2'
                ZS7->(MSUnlock())
            Endif
        Endif
    Endif
Return

User Function zOpTarefa()
    Local aArea     := GetArea() 
    Local cOpcao    := ""
    
    cOpcao += "1=SIM;"
    cOpcao += "2=N�O;"

    RestArea(aArea)
Return cOpcao
