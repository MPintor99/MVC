#iNCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} User Function CADALUN
    Cadastro de Alunos
    @type  Function
    @author Matheus Pintor
    @since 28/03/2023
*/
User Function CADALUN()
    Local cAlias  := 'ZS4'
    Local cTitle   := 'Alunos'
    Local oMark   := FWMarkBrowse():New()
    Private cCodInstAnterior := ''

    oMark:AddButton('Marcar Todos',    'U_MarcAlun',   , 1)
    oMark:AddButton('Desmarcar Todos', 'U_DesmAlun',, 1)
    oMark:AddButton('Inverter Marc.',  'U_InverAlun', , 1)
    oMark:AddButton('Excluir Marc.',   'U_DelAlun', 5, 1)

    oMark:SetAlias(cAlias) //Seleciona a tabela que será utilizada
    oMark:SetDescription(cTitle) //Seleciona o título
    oMark:SetFieldMark('ZS4_MARC')
    oMark:DisableDetails() //Retira os detalhes embaixo no Browse
    oMark:DisableReport() //Retira o botão para imprimir o Browse
    oMark:Activate() //Ativa o Browse

Return

Static Function MenuDef()
    Local aRotina := {}

    ADD OPTION aRotina TITLE 'Incluir'      ACTION 'VIEWDEF.CADALUN' OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE 'Alterar'      ACTION 'VIEWDEF.CADALUN' OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE 'Excluir'      ACTION 'VIEWDEF.CADALUN' OPERATION 5 ACCESS 0
Return aRotina

Static Function ModelDef()
    Local bModelPos    := {|oModel| ValidPos(oModel)} 
    Local oModel    := MPFormModel():New('CADALUNM', NIL, bModelPos)
    Local oStruZS4  := FWFormStruct(1, 'ZS4')
    Local aGatilho := FWStruTrigger('ZS4_CODINS', 'ZS4_NOMINS', 'ZS3->ZS3_NOME', .T., 'ZS3', 1, 'xFilial("ZS3")+Alltrim(M->ZS4_CODINS)')

    oStruZS4:AddTrigger(aGatilho[1], aGatilho[2], aGatilho[3], aGatilho[4])

    oStruZS4:SetProperty('ZS4_AULAS', MODEL_FIELD_VALID, { |oModel| ValidCampo(oModel)})

    oStruZS4:SetProperty('ZS4_COD',    MODEL_FIELD_INIT,    FwBuildFeature(STRUCT_FEATURE_INIPAD,  'GetSXENum("ZS4", "ZS4_COD")'))       //Ini Padrão

    oModel:AddFields('ZS4MASTER', /*COMPONENTE PAI*/, oStruZS4)

    oModel:SetDescription('Alunos')

    oModel:SetPrimaryKey({'ZS4_COD'}) //Demonstra como os campos serão organizados, tipo índice
Return oModel

Static Function ViewDef() //Função de visualização de tela
    Local oModel   := FwLoadModel('CADALUN') //Faz o Load do modelo do arquivo fonte
    Local oStruZS4 := FWFormStruct(2, 'ZS4') //Faz as estruturas, porém o 2 faz com que sirva apenas para visualização
    Local oView    := FwFormView():New() //Instanciando a Classe da Tela, criando objeto onde será a tela

    oView:SetModel(oModel) //Vincula o modelo carregado com o objeto criado
    oView:AddField('VIEW_ZS4', oStruZS4, 'ZS4MASTER') //Vincula o componente visual de formulário com o componente de formulário do componente de dados (ModelDef)
   
    oView:CreateHorizontalBox('ALUNOS', 100)
    
    oView:SetOwnerView('VIEW_ZS4', 'ALUNOS') //Demonstra a quem essa view pertence

    oView:EnableTitleView('VIEW_ZS4', 'Dados dos Alunos')

    oView:setAfterViewActivate({|oView| InstAual(oView)})
Return oView

User Function zOpFazAula()
    Local aArea     := GetArea() 
    Local cOpcao    := ""
    
    cOpcao += "SIM;"
    cOpcao += "NÃO;"

    RestArea(aArea)
Return cOpcao

Static Function ValidCampo(oModel)
    Local lOk        := .T.
    Local cEstuda    := oModel:GetValue('ZS4_AULAS')
    Local cInstrutor := oModel:GetValue('ZS4_CODINS')

    If !Empty(cEstuda)
        If Empty(cInstrutor)
            Help(NIL, NIL, 'Campo "Instrutor" vazio.', NIL, 'Você não preencheu o campo instrutor.', 1, 0, NIL, NIL, NIL, NIL, NIL, {'Preencha o campo "Instrutor".'})
            lOk := .F.
            oModel:LoadValue('ZS4_AULAS', Space(TamSX3('ZS4_AULAS')[1]))
        Endif
    Endif


Return lOk

Static Function ValidPos(oModel)
    Local nOperation := oModel:GetOperation()
    Local cCodInst := oModel:GetValue('ZS4MASTER','ZS4_CODINS') //Pega o código do instrutor atual da tabela.
    Local cAula    := oModel:GetValue('ZS4MASTER', 'ZS4_AULAS')
    Local nQuantAlun := 0
    Local lOk := .T.
    
    ZS3->(DbSelectArea('ZS3'))
    ZS3->(DbGoTop())
    ZS3->(DbSetOrder(1))

    If nOperation == 3
        If ZS3->(DbSeek(xFilial('ZS3')+cCodInst)) 
            nQuantAlun := ZS3->ZS3_QTDALU
          
          If nQuantAlun < 5
              nQuantAlun++
              If ZS3->(Reclock('ZS3', .F.))
                  ZS3->ZS3_QTDALU := nQuantAlun
                  ZS3->(MSUnlock())
              Endif
          Else
            Help(NIL, NIL, 'Não é possível adicionar alunos neste instrutor', NIL, 'O instrutor já tem 5 anos registrados', 1, 0, NIL, NIL, NIL, NIL, NIL, {'Escolha outro instrutor.'})
          Endif
        Endif

    Elseif nOperation == 4
        ZS3->(DbSeek(xFilial('ZS3')+cCodInstAnterior))
        nQuantAlun := ZS3->ZS3_QTDALU

      If nQuantAlun > 0
          nQuantAlun--

          If ZS3->(Reclock('ZS3', .F.))
              ZS3->ZS3_QTDALU := nQuantAlun
              ZS3->(MSUnlock())
          Endif
      Endif
        ZS3->(DbSeek(xFilial('ZS3')+cCodInst)) 

            nQuantAlun := ZS3->ZS3_QTDALU
        If nQuantAlun < 5
            nQuantAlun++
            If ZS3->(Reclock('ZS3', .F.))
                ZS3->ZS3_QTDALU := nQuantAlun
                ZS3->(MSUnlock())
            Endif
        Else
          lOk := .F.
          Help(NIL, NIL, 'Não é possível adicionar alunos neste instrutor', NIL, 'O instrutor já tem 5 anos registrados', 1, 0, NIL, NIL, NIL, NIL, NIL, {'Escolha outro instrutor.'})
        Endif

    Elseif nOperation == 5
        If cAula != "SIM"
            If ZS3->(DbSeek(xFilial('ZS3')+cCodInst)) 
                
                nQuantAlun := ZS3->ZS3_QTDALU

                If nQuantAlun > 0
                    nQuantAlun--
                    If ZS3->(Reclock('ZS3', .F.))
                        ZS3->ZS3_QTDALU := nQuantAlun
                        ZS3->(MSUnlock())
                    Endif
                Endif
            Endif
        Else
            lOk := .F.
            Help(NIL, NIL, 'Aluno não pode ser excluído', NIL, 'Alunos em aula não podem ser excluídos', 1, 0, NIL, NIL, NIL, NIL, NIL, {'Altere o campo de aula para "NÃO".'})
        Endif
    Endif
Return lOk

Static Function InstAual(oView) //Pega o código do instrutor anterior na hora da alteração.
    cCodInstAnterior := ZS4->ZS4_CODINS
Return

User Function MarcAlun()
  DbSelectArea('ZS4')
  
  ZS4->(DbGotop())
  
  while ZS4->(!EOF())
    if !oMark:IsMark()
      oMark:MarkRec()  
    endif
    ZS4->(DbSkip())
  enddo

  oMark:Refresh(.T.) 
Return

User Function DesmAlun()
  DbSelectArea('ZS4')
  
  ZS4->(DbGotop())
  
  while ZS4->(!EOF())
    if oMark:IsMark() 
      oMark:MarkRec() 
    endif
    ZS4->(DbSkip())
  enddo

  oMark:Refresh(.T.) 
Return

User Function InverAlun()
  DbSelectArea('ZS4')
  
  ZS4->(DbGotop())
  
  while ZS4->(!EOF())
    oMark:MarkRec()
    
    ZS4->(DbSkip())
  enddo
  
  oMark:Refresh(.T.) 
Return


User Function DelAlun()
  if MsgYesNo('Confirma a exclusão dos cursos selecionados?')
    DbSelectArea('ZS4')
    
    ZS4->(DbGotop())
    
    while ZS4->(!EOF())
      if oMark:IsMark() .And. (ZS4->ZS4_AULAS) != 'SIM'
          RecLock('ZS4', .F.)
            ZS4->(DbDelete()) 
          ZS4->(MSUnlock())
      Else
        FwAlertError('Não é possível excluir o instrutor pois ele tem alunos em aula.')
      endif
      ZS4->(DbSkip())
    enddo
  Endif
  
  oMark:Refresh(.T.) 
Return

