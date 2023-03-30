#iNCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} User Function CADINST
    Cadastro de Instrutor
    @type  Function
    @author Matheus Pintor
    @since 28/03/2023
*/
User Function CADINST()
    Local cAlias  := 'ZS3'
    Local cTitle   := 'Cadastro de Instrutores'
    Local oMark  := FwMarkBrowse():New()

    oMark:AddButton('Marcar Todos',    'U_MarcaInst',   , 1)
    oMark:AddButton('Desmarcar Todos', 'U_DesmInst',, 1)
    oMark:AddButton('Inverter Marc.',  'U_InverInt', , 1)
    oMark:AddButton('Excluir Marc.',   'U_DelInt', 5, 1)

    oMark:SetAlias(cAlias) //Seleciona a tabela que ser� utilizada
    oMark:SetDescription(cTitle) //Seleciona o t�tulo
    oMark:SetFieldMark('ZS3_MARC')
    oMark:DisableDetails() //Retira os detalhes embaixo no Browse
    oMark:DisableReport() //Retira o bot�o para imprimir o Browse
    oMark:Activate() //Ativa o Browse

Return

Static Function MenuDef()
    Local aRotina := {}

    ADD OPTION aRotina TITLE 'Incluir'      ACTION 'VIEWDEF.CADINST' OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE 'Alterar'      ACTION 'VIEWDEF.CADINST' OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE 'Excluir'      ACTION 'VIEWDEF.CADINST' OPERATION 5 ACCESS 0
Return aRotina

Static Function ModelDef()
    Local bModelPos    := {|oModel| ValidPos(oModel)} 
    Local oModel   := MPFormModel():New('CADINSTM', NIL, bModelPos)
    Local oStruZS3 := FWFormStruct(1, 'ZS3')

    oStruZS3:SetProperty('ZS3_COD',    MODEL_FIELD_INIT,    FwBuildFeature(STRUCT_FEATURE_INIPAD,  'GetSXENum("ZS3", "ZS3_COD")'))       //Ini Padr�o

    oModel:AddFields('ZS3MASTER', /*COMPONENTE PAI*/, oStruZS3)

    oModel:SetDescription('Cadastro de Instrutores')
    oModel:GetModel('ZS3MASTER'):SetDescription('Instrutores')

    oModel:SetPrimaryKey({'ZS3_COD'}) //Demonstra como os campos ser�o organizados, tipo �ndice
Return oModel

Static Function ViewDef() //Fun��o de visualiza��o de tela
    Local oModel   := FwLoadModel('CADINST') //Faz o Load do modelo do arquivo fonte
    Local oStruZS3 := FWFormStruct(2, 'ZS3') //Faz as estruturas, por�m o 2 faz com que sirva apenas para visualiza��o
    Local oView    := FwFormView():New() //Instanciando a Classe da Tela, criando objeto onde ser� a tela

    oView:SetModel(oModel) //Vincula o modelo carregado com o objeto criado
    oView:AddField('VIEW_ZS3', oStruZS3, 'ZS3MASTER') //Vincula o componente visual de formul�rio com o componente de formul�rio do componente de dados (ModelDef)
   
    oView:CreateHorizontalBox('INSTRUTOR', 100) //Cria uma caixa horizontal onde o primeiro campo define o nome e o segundo a % de tela que ser� ocupada

    oView:SetOwnerView('VIEW_ZS3', 'INSTRUTOR') //Demonstra a quem essa view pertence

    oView:EnableTitleView('VIEW_ZS3', 'Dados do Instrutor')

Return oView

Static Function ValidPos(oModel)
    Local nOperation := oModel:GetOperation()
    Local dDataNas   := oModel:GetValue('ZS3MASTER', 'ZS3_DATNAS')
    Local dDataHab   := oModel:GetValue('ZS3MASTER', 'ZS3_DATHAB')
    Local cEscolar   := oModel:GetValue('ZS3MASTER', 'ZS3_ESCOLA')
    Local nQuantAlun := oModel:GetValue('ZS3MASTER', 'ZS3_QTDALU')
    Local lOk        := .T.

    If nOperation == 5
        If Val(nQuantAlun) > 0
        lOk := .F.
            FwAlertError('N�o � poss�vel realizar a exclus�o de instrutores com alunos', 'N�o permitido')
        Endif
    Elseif nOperation == 3 .OR. nOperation == 4
        If dDataNas > Date() - 7665
            lOk := .F.
            FwAlertError('O instrutor precisa ter no m�nimo 21 anos de idade.')
        Elseif dDataHab > Date() - 730
            lOk := .F.
            FwAlertError('O Instrutor precisa estar habilidade a no m�nimo 2 anos.')
        Elseif Upper(cEscolar) == '1'
            lOk := .F.
            FwAlertError('O instrutor precisa ter no m�nimo o ensino m�dio completo')
        Endif
    Endif

Return lOk

User Function zOpGrauEsc()
    Local aArea     := GetArea() 
    Local cOpcao    := ""
    
    cOpcao += "1=Ensino Fundamental;"
    cOpcao += "2=Ensino M�dio;"
    cOpcao += "3=Ensino Superior;"

    RestArea(aArea)
Return cOpcao

User Function MarcaInst()
  DbSelectArea('ZS3')
  
  ZS3->(DbGotop())
  
  while ZS3->(!EOF())
    if !oMark:IsMark()
      oMark:MarkRec()  
    endif
    ZS3->(DbSkip())
  enddo

  oMark:Refresh(.T.) 
Return

User Function DesmInst()
  DbSelectArea('ZS3')
  
  ZS3->(DbGotop())
  
  while ZS3->(!EOF())
    if oMark:IsMark() 
      oMark:MarkRec() 
    endif
    ZS3->(DbSkip())
  enddo

  oMark:Refresh(.T.) 
Return

User Function InverInt()
  DbSelectArea('ZS3')
  
  ZS3->(DbGotop())
  
  while ZS3->(!EOF())
    oMark:MarkRec()
    
    ZS3->(DbSkip())
  enddo
  
  oMark:Refresh(.T.) 
Return


User Function DelInt()
  if MsgYesNo('Confirma a exclus�o dos cursos selecionados?')
    DbSelectArea('ZS3')
    
    ZS3->(DbGotop())
    
    while ZS3->(!EOF())
        if oMark:IsMark() .And. (ZS3->ZS3_QTDALU) == 0
          RecLock('ZS3', .F.)
            ZS3->(DbDelete()) 
          ZS3->(MSUnlock())
        Else 
            FwAlertError('N�o � poss�vel excluir o instrutor pois ele tem alunos em aula.')
        endif
      ZS3->(DbSkip())
    enddo
  Endif
  
  oMark:Refresh(.T.) 
Return

