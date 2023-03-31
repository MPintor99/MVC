#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} User Function CADVEIC
    Cadastro de veículo
    @type  Function
    @author Matheus Pintor
    @since 27/03/2023
    /*/
User Function CADVEIC()
    Local cAlias := 'ZS2'
    Local cTitle := 'Cadastro de Veículos'
    Local oBrowse := NIL

    oBrowse := FWMBrowse():New() //Criação da tela.
    oBrowse:SetAlias(cAlias) //Tabela a ser utilizada
    oBrowse:SetDescription(cTitle) //Título
    oBrowse:DisableDetails() //Desabilita os detalhes que ficam embaixo na tela.
    oBrowse:DisableReport()

    oBrowse:Activate() //Ativação da tela, deve ficar por último.
Return 

Static Function MenuDef()
    Local aRotina := {}

    ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.CADVEIC' OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.CADVEIC' OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.CADVEIC' OPERATION 5 ACCESS 0

Return aRotina

Static Function ModelDef()
    Local oModel        := NIL
    Local oStructureZS2 := NIL

    oModel        := MPFormModel():New('CADVEICM')
    oStructureZS2 := FWFormStruct(1, 'ZS2') //Pega a estrutura dos campos da tabela com suas propriedades

    oModel:AddFields('ZS2MASTER', /*OWNER*/, oStructureZS2)

    oModel:SetDescription('Modelo de Dados de Cursos')

    oModel:GetModel('ZS2MASTER'):SetDescription('Formulario do Curso')

    oModel:SetPrimaryKey({'ZS2_COD'})

Return oModel

Static Function ViewDef()
    Local oModel        := NIL
    Local oStructureZS2 := NIL
    Local oView         := NIL

    oModel := FWLoadModel('CADVEIC') 
    oStructureZS2 := FWFormStruct(2, 'ZS2')//Recebe a visualização dos campos da tabela selecionada
    oView := FWFormView():NEW()

    oView:SetModel(oModel)

    oView:AddField('VIEW_ZS2', oStructureZS2 , 'ZS2MASTER') //Form
    
    oView:CreateHorizontalBox('TELA', 100) //Div

    oView:SetOwnerView('VIEW_ZS2', 'TELA') //Adiciona os campos na tela
Return oView

User Function zOpCadVei()
    Local aArea     := GetArea() 
    Local cOpcao    := ""
    
    cOpcao += "MAN=MANUAL;"
    cOpcao += "AUT=AUTOMÁTICO;"

    RestArea(aArea)
Return cOpcao
