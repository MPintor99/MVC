#iNCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} User Function CATCNH
    Categoria CNH
    @type  Function
    @author Matheus Pintor
    @since 27/03/2023
*/
User Function CATCNH()
    Local cAlias  := 'ZS1'
    Local cTitle   := 'Cursos'
    Local oBrowse  := FwMbrowse():New()

    oBrowse:SetAlias(cAlias) //Seleciona a tabela que será utilizada
    oBrowse:SetDescription(cTitle) //Seleciona o título
    oBrowse:DisableDetails() //Retira os detalhes embaixo no Browse
    oBrowse:DisableReport() //Retira o botão para imprimir o Browse
    oBrowse:Activate() //Ativa o Browse

Return

Static Function MenuDef()
    Local aRotina := {}

    ADD OPTION aRotina TITLE 'Incluir' ACTION 'VIEWDEF.CATCNH' OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE 'Alterar' ACTION 'VIEWDEF.CATCNH' OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE 'Excluir' ACTION 'VIEWDEF.CATCNH' OPERATION 5 ACCESS 0
Return aRotina

Static Function ModelDef()
    Local oModel    := MPFormModel():New('CATCNHM')
    Local oStruZS1  := FWFormStruct(1, 'ZS1')
    Local aGatilho  := FWStruTrigger('ZS1_CODVEI', 'ZS1_NOVEI', 'ZS2->ZS2_NOME', .T., 'ZS2', 1, 'xFilial("ZS2")+Alltrim(M->ZS1_CODVEI)')

    oStruZS1:AddTrigger(aGatilho[1] , aGatilho[2] , aGatilho[3] , aGatilho[4])

    oStruZS1:SetProperty('ZS1_COD',    MODEL_FIELD_INIT,    FwBuildFeature(STRUCT_FEATURE_INIPAD,  'GetSXENum("ZS1", "ZS1_COD")'))       //Ini Padrão

    oModel:AddFields('ZS1MASTER', /*COMPONENTE PAI*/, oStruZS1)

    oModel:SetDescription('Categoria CNH')
    oModel:GetModel('ZS1MASTER'):SetDescription('CNH')

    oModel:SetPrimaryKey({'ZS1_COD'}) //Demonstra como os campos serão organizados, tipo índice
Return oModel

Static Function ViewDef() //Função de visualização de tela
    Local oModel   := FwLoadModel('CATCNH') //Faz o Load do modelo do arquivo fonte
    Local oStruZS1 := FWFormStruct(2, 'ZS1') //Faz as estruturas, porém o 2 faz com que sirva apenas para visualização
    Local oView    := FwFormView():New() //Instanciando a Classe da Tela, criando objeto onde será a tela

    oView:SetModel(oModel) //Vincula o modelo carregado com o objeto criado
    oView:AddField('VIEW_ZS1', oStruZS1, 'ZS1MASTER') //Vincula o componente visual de formulário com o componente de formulário do componente de dados (ModelDef)
   
    oView:CreateHorizontalBox('CNH', 100) //Cria uma caixa horizontal onde o primeiro campo define o nome e o segundo a % de tela que será ocupada
    
    oView:SetOwnerView('VIEW_ZS1', 'CNH') //Demonstra a quem essa view pertencE

    oView:EnableTitleView('VIEW_ZS1', 'Categoria da CNH')
Return oView



