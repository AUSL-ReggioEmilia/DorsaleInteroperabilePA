Imports System.Web.Routing
Imports DI.PortalAdmin
Imports DI.PortalAdmin.Data

Public Class SiteMaster
    Inherits MasterPage

    Protected ReadOnly Property InstrumentationKey As String
        Get
            Return Microsoft.ApplicationInsights.Extensibility.TelemetryConfiguration.Active.InstrumentationKey
        End Get
    End Property

    Protected tableCurrent As MetaTable

    Private userInterface As UserInterface = New UserInterface(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)


    Protected Sub Page_Init(ByVal sender As Object, ByVal e As EventArgs)
        tableCurrent = DynamicDataRouteHandler.GetRequestMetaTable(Context)
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs)
        Try
            If Not Page.IsPostBack Then

                ' Ottengo l'Header del sito (Loghi e tittolo)
                HeaderPlaceholder.Text = UserInterface.GetBootstrapHeader2(PortalsTitles.Connettori)


                '-------------------------------------------------
                ' MODIFICA ETTORE 2019-02-19: questo DataBind viene usato per lo script presente nel markup che legge la instrumentation key di AppInsights
                ' E' stato usato il DataBind perchè l'istruzione instrumentationKey: "<%= InstrumentationKey %>" generava errore
                '-------------------------------------------------
                Page.Header.DataBind()
                '-------------------------------------------------
                If Global_asax.DefaultModel.VisibleTables.Count = 0 Then
                    Throw New InvalidOperationException("There are no accessible tables. " &
                        "Make sure that at least one data model is registered in Global.asax " &
                        "and scaffolding is enabled or implement custom pages.")
                End If
                '
                ' Lista delle Table visibili
                '
                Dim visibleTables As List(Of MetaTable) = Global_asax.DefaultModel.VisibleTables
                If visibleTables.Count = 0 Then
                    Throw New InvalidOperationException("There are no accessible tables. " &
                        "Make sure that at least one data model is registered in Global.asax " &
                        "and scaffolding is enabled or implement custom pages.")
                End If

                MenuOrizzontaleSitiDorsale_DataBind()
                'LeftMenuTreeView_DataBind() 'Vecchia TreeView per il menu sinistro

                '
                ' Popolo le DrtopDownList per la selezione del menù dell'ambito corrente
                ' L'ambito è identificato nel DisplayName come prima parte del nome se separati con /
                '
                Dim menuDwh As List(Of Scope) = GetMenuScopesByGroup("Dwh")
                If (menuDwh.Count > 0) Then
                    RepeaterDWH.DataSource = menuDwh
                    RepeaterDWH.DataBind()
                    'Imposto il div del reapeater visisble se ha dei menu da far vedere
                    DivRepeaterDWH.Visible = True
                End If

                Dim menuOe As List(Of Scope) = GetMenuScopesByGroup("Oe")
                If (menuOe.Count > 0) Then
                    RepeaterOE.DataSource = menuOe
                    RepeaterOE.DataBind()
                    'Imposto il div del reapeater visisble se ha dei menu da far vedere
                    DivRepeaterOE.Visible = True
                End If

                Dim menuOeApp As List(Of Scope) = GetMenuScopesByGroup("OeApp")
                If (menuOeApp.Count > 0) Then
                    RepeaterOEApp.DataSource = menuOeApp
                    RepeaterOEApp.DataBind()
                    'Imposto il div del reapeater visisble se ha dei menu da far vedere
                    DivRepeaterOEApp.Visible = True
                End If

                '
                ' Bind menu di sinistra della voce della DropDopwn selezionata
                '
                RepeaterScopeTable.DataSource = GetMenuScopeTables(Me.TableSelected)
                RepeaterScopeTable.DataBind()

            End If

        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            ShowAlert(sErrorMessage)
        End Try
    End Sub

#Region "DropDownList Bottni Menu Sinistro"
    Private Sub repeaterDWH_ItemCommand(source As Object, e As RepeaterCommandEventArgs) Handles RepeaterDWH.ItemCommand
        If e.CommandName = "selectMenu" Then
            '
            ' Bind menu di sinistra ALL TABLE
            '
            UpdateSelectedMenu(e.CommandArgument.ToString)
        End If
    End Sub

    Private Sub RepeaterOE_ItemCommand(source As Object, e As RepeaterCommandEventArgs) Handles RepeaterOE.ItemCommand
        If e.CommandName = "selectMenu" Then
            '
            ' Bind menu di sinistra ALL TABLE
            '
            UpdateSelectedMenu(e.CommandArgument.ToString)
        End If
    End Sub

    Private Sub RepeaterOEApp_ItemCommand(source As Object, e As RepeaterCommandEventArgs) Handles RepeaterOEApp.ItemCommand
        If e.CommandName = "selectMenu" Then
            '
            ' Bind menu di sinistra ALL TABLE
            '
            UpdateSelectedMenu(e.CommandArgument.ToString)
        End If
    End Sub

    Private Sub UpdateSelectedMenu(commandArgument As String)
        '
        ' Menu selezionato
        '
        Me.TableSelected = commandArgument

        Dim menuScopedTable = GetMenuScopeTables(commandArgument)

        RepeaterScopeTable.DataSource = menuScopedTable
        RepeaterScopeTable.DataBind()

        '
        ' Naviga alla prima table 
        '
        If menuScopedTable IsNot Nothing Then
            Dim firstTable As MetaTable = menuScopedTable.FirstOrDefault

            If firstTable IsNot Nothing Then
                Dim sURL = firstTable.GetActionPath("List")
                Response.Redirect(sURL, False)
            End If
        End If

    End Sub
#End Region

#Region "Utiliti Markup"
    Protected Function GetChildDisplayName(name As String) As String

        Dim iPos As Integer = name.LastIndexOf("/"c)
        Dim displayName As String = name.Substring(iPos + 1)

        Return displayName
    End Function

    Protected Function GetChildCss(name As String) As String

        If tableCurrent IsNot Nothing AndAlso tableCurrent.Name = name Then
            Return "TreeSelectedNode"
        Else
            Return "TreeNode"
        End If

    End Function

    ''' <summary>
    ''' Mostra il Testo nel div e lo rende visibile
    ''' </summary>
    ''' <param name="Text">Testo da visualizzare</param>
    Public Sub ShowAlert(Text As String)

        '
        ' Usare visible e non "display:none"
        ' Nascosto di Default e ad ogni postback si rinasconde poiche' non ha il ViewState attivo
        '
        divAlertMessage.Visible = Text.Length > 0
        divAlertMessage.InnerText = Text

    End Sub

    Public Function ShowAlertIfError(e As LinqDataSourceStatusEventArgs) As Boolean

        'Show Error specifio per l'evento LinqDataSourceStatusEventArgs
        If e.Exception IsNot Nothing Then

            Me.ShowAlert(GestioneErrori.TrapError(e.Exception))
            e.ExceptionHandled = True
            Return True

        Else
            Return False
        End If

    End Function
#End Region

    Private Sub MenuOrizzontaleSitiDorsale_DataBind()
        Dim dictionary = TryCast(Session("MenuMain"), Dictionary(Of String, String))
        If dictionary Is Nothing Then
            Dim adapter As New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)
            dictionary = adapter.GetMainMenu()
            Session("MenuMain") = dictionary
        End If

        MenuMain.Items.Clear()
        For Each entry In dictionary
            Dim target = If(entry.Value.IndexOf("http", StringComparison.CurrentCultureIgnoreCase) > -1, "_blank", String.Empty)
            Dim newMenuItem As New MenuItem(entry.Key, Nothing, Nothing, Me.ResolveUrl(entry.Value), target)
            MenuMain.Items.Add(newMenuItem)
        Next

    End Sub

    '
    ' GESTIONE MENU LATERALE SINISTRO
    '
#Region "Gestione Menu Laterale Sinistro"

    ''' <summary>
    ''' Trova il nodo padre, se necessario crea tutti i nodi padre per contenere il figlio
    ''' </summary>
    ''' <param name="rootNode"></param>
    ''' <param name="fullpath"></param>
    ''' <returns></returns>
    Private Function FindOrCreateParentNodes(rootNode As TreeNode, fullpath As String) As TreeNode

        Dim arrPath = fullpath.Split("/"c)
        Dim nodeCollection = rootNode.ChildNodes
        Dim parentNode As TreeNode = rootNode


        For i As Integer = 0 To arrPath.Length - 1

            Dim path = BuildPath(arrPath, i)
            parentNode = FindNode(rootNode.ChildNodes, path)

            'se non esiste il padre, lo creo
            If parentNode Is Nothing Then
                parentNode = New TreeNode(arrPath(i), path)
                parentNode.ToolTip = parentNode.Text

                'i nodi padre non sono cliccabili
                parentNode.SelectAction = TreeNodeSelectAction.None
                nodeCollection.Add(parentNode)
            End If
            nodeCollection = parentNode.ChildNodes
        Next

        Return parentNode
    End Function

    Private Function FindNode(nodes As TreeNodeCollection, value As String) As TreeNode

        Dim foundNode As TreeNode = Nothing

        For Each node As TreeNode In nodes
            If String.Compare(node.Value, value, True) = 0 Then
                Return node
            Else
                foundNode = FindNode(node.ChildNodes, value)
            End If
        Next

        Return foundNode

    End Function

    ''' <summary>
    ''' Restituisce il Path concatenato con /, fino al livello passato
    ''' </summary>
    ''' <param name="categorie"></param>
    ''' <param name="livello"></param>
    Private Shared Function BuildPath(categorie As String(), livello As Integer) As String

        Dim value = String.Empty

        For i As Integer = 0 To categorie.Length - 1
            If i <= livello Then
                value &= categorie(i)
            End If
        Next

        Return value
    End Function

    Private Function GetMenuScopes() As Scopes

        Dim listAmbiti As Scopes = Me.MenuScopes
        If listAmbiti Is Nothing Then
            '
            ' Crea se non trovato
            '
            listAmbiti = New Scopes
            '
            ' Popola con le table visibili
            '
            Dim visibleTables As List(Of MetaTable) = Global_asax.DefaultModel.VisibleTables
            For Each table As MetaTable In visibleTables

                '
                'CONTROLLO ACCESSO -> PRESENZA ATTRIBUTO RuoloAccesso nella tabella corrente
                '
                Dim attrRuoloAccesso As RuoloAccesso =
                CType(Attribute.GetCustomAttribute(table.RootEntityType, GetType(RuoloAccesso)), RuoloAccesso)

                If Not RuoloAccessoManager.IsInRole(attrRuoloAccesso) Then
                    'Se non ho accesso alla voce del menu la nascondo (saltandola)
                    Continue For
                End If

                '
                ' Parse del DisplayName
                '
                Dim sAmbito As String = "Nessuno"
                Dim sDisplayNome As String = table.DisplayName
                '
                ' Separa Ambito e Nome
                '
                Dim asPath As String() = sDisplayNome.Split("/"c)
                If asPath.Length > 1 Then
                    sAmbito = asPath(0)

                    sDisplayNome = sDisplayNome.Substring(sDisplayNome.IndexOf("/"c) + 1)
                End If
                '
                ' Aggiungi alla lista
                '
                Dim ambito = listAmbiti.FindOrAddScope(sAmbito)
                ambito.AddTable(table.Name, sDisplayNome)
            Next

            '
            ' Persiste le informazioni
            '
            Me.MenuScopes = listAmbiti
            '
            ' Set default
            '
            If listAmbiti.Count > 0 Then
                Me.TableSelected = listAmbiti.First.Name
            End If
        End If

        Return listAmbiti

    End Function

    Private Function GetMenuScopesByGroup(gruppo As String) As List(Of Scope)

        Dim scopes As New List(Of Scope)

        '
        ' Per ottenere i menu per gruppi, li suddivido
        ' Customizzazioni
        '
        Select Case gruppo
            Case "Oe"
                scopes = Me.GetMenuScopes().Where(Function(x) x.DisplayName.StartsWith(gruppo)).ToList()
                scopes.Remove(Me.GetMenuScopes().Where(Function(x) x.DisplayName.StartsWith("OeGestioneOrdiniErogante")).FirstOrDefault)
                scopes.Remove(Me.GetMenuScopes().Where(Function(x) x.DisplayName.StartsWith("OePlanner")).FirstOrDefault)

            Case "OeApp"
                Dim scopeTemp As Scope

                'OeGestioneOrdiniErogante
                scopeTemp = Me.GetMenuScopes().Where(Function(x) x.DisplayName.StartsWith("OeGestioneOrdiniErogante")).FirstOrDefault
                If scopeTemp IsNot Nothing Then
                    scopes.Add(scopeTemp)
                End If

                'OePlanner
                scopeTemp = Me.GetMenuScopes().Where(Function(x) x.DisplayName.StartsWith("OePlanner")).FirstOrDefault
                If scopeTemp IsNot Nothing Then
                    scopes.Add(scopeTemp)
                End If

            Case "Dwh" : scopes = Me.GetMenuScopes().Where(Function(x) x.DisplayName.StartsWith(gruppo)).ToList()
        End Select

        Return scopes
    End Function

    Private Function GetMenuScopeTables(ambito As String) As List(Of MetaTable)

        If String.IsNullOrEmpty(ambito) Then
            Return Nothing
        End If
        '
        ' Carica i MetaTable dell'ambito
        '
        Dim listAmbiti As Scopes = Me.MenuScopes
        If listAmbiti IsNot Nothing Then
            Dim ambitoCorrente = listAmbiti.FindScope(ambito)

            Dim visibleTables As List(Of MetaTable) = Global_asax.DefaultModel.VisibleTables
            Dim listMetaTable As New List(Of MetaTable)
            Dim listMetaTableTilde As New List(Of MetaTable)
            '
            ' Lista dei MetaTable, utile per usare asp:DynamicHyperLink
            '
            For Each table As Table In ambitoCorrente.Tables

                '
                'CONTROLLO ACCESSO -> PRESENZA ATTRIBUTO RuoloAccesso nella tabella corrente
                '
                Dim attrRuoloAccesso As RuoloAccesso =
                CType(Attribute.GetCustomAttribute(visibleTables.Where(Function(t) t.Name = table.Name).FirstOrDefault.RootEntityType, GetType(RuoloAccesso)), RuoloAccesso)

                If Not RuoloAccessoManager.IsInRole(attrRuoloAccesso) Then
                    'Se non ho accesso alla voce del menu la nascondo (saltandola)
                    Continue For
                End If

                '
                ' Aggiungo la tabella
                '
                If table.DisplayName.StartsWith("~"c) Then
                    'Se ha la tilte le aggiungo poi in fondo
                    listMetaTableTilde.Add(visibleTables.Where(Function(t) t.Name = table.Name).FirstOrDefault)
                Else
                    listMetaTable.Add(visibleTables.Where(Function(t) t.Name = table.Name).FirstOrDefault)
                End If

            Next

            'Aggiungo in fondo le tabelle che iniziando con la ~ "Tilde"
            listMetaTable.AddRange(listMetaTableTilde)

            Return listMetaTable
        Else
            Return Nothing
        End If

    End Function

    ''' <summary>
    ''' Accesso alla lista degli ambiti
    ''' Persiste nell'Application
    ''' </summary>
    ''' <returns></returns>
    Protected Property MenuScopes() As Scopes
        Get
            Return CType(Me.Application("MenuScopes"), Scopes)
        End Get
        Set(value As Scopes)
            Me.Application("MenuScopes") = value
        End Set
    End Property

    ''' <summary>
    ''' Accesso al nome della TABLE selezionata
    ''' Persiste nella sessione
    ''' </summary>
    ''' <returns></returns>
    Protected Property TableSelected() As String
        Get
            Return CType(Me.Session("TableSelected"), String)
        End Get
        Set(value As String)
            Me.Session("TableSelected") = value
        End Set
    End Property

#End Region

#Region "Classi per bind Ambiti"

    <Serializable>
    Protected Class Scopes
        Inherits List(Of Scope)

        Public Function FindOrAddScope(scope As String) As Scope
            '
            ' Cerco oppure Aggiungo uno Scope
            '
            Dim scopeExist As Scope = Me.Where(Function(e) e.DisplayName = scope).FirstOrDefault
            If scopeExist Is Nothing Then

                scopeExist = New Scope() With {.Name = scope, .DisplayName = scope}
                Me.Add(scopeExist)
            End If

            Return scopeExist
        End Function

        Public Function FindScope(scope As String) As Scope
            '
            ' Cerco oppure Aggiungo uno Scope
            '
            Return Me.Where(Function(e) e.DisplayName = scope).FirstOrDefault
        End Function

    End Class

    <Serializable>
    Protected Class Scope
        Public Property Name As String
        Public Property DisplayName As String
        Public Property Tables As New List(Of Table)

        Public Sub AddTable(name As String, displayName As String)

            Dim table As New Table With {.Name = name, .DisplayName = displayName}
            Tables.Add(table)

        End Sub

    End Class

    <Serializable>
    Protected Class Table
        Public Property Name As String
        Public Property DisplayName As String
    End Class

#End Region

End Class
