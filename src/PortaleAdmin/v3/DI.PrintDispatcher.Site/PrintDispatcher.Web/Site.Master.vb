Imports System.Reflection
Imports DI.PortalAdmin
Imports DI.PortalAdmin.Data

Partial Public Class Site
    Inherits System.Web.UI.MasterPage

    Private Const APPLICATION_TITLE As String = "PrintDispatcher-Admin"
    Private Shared mDIPortalAdminUI As New UserInterface(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)
    Private mMyMenuLeft As New Dictionary(Of String, MenuLeftAttribute)
    Private mStartMenuLeft As DateTime
    Private msTreeViewCurrentValePath As String

    Protected ReadOnly Property InstrumentationKey As String
        Get
            Return Microsoft.ApplicationInsights.Extensibility.TelemetryConfiguration.Active.InstrumentationKey
        End Get
    End Property

    Protected Property ApplicationTitle() As String
        Get
            Dim o As Object = ViewState("ApplicationTitle")
            If o IsNot Nothing Then
                Return o.ToString()
            End If
            Return APPLICATION_TITLE
        End Get
        Private Set(ByVal value As String)
            ViewState.Add("ApplicationTitle", value)
        End Set
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Try
            If Not Page.IsPostBack Then

                ' Ottengo l'Header del sito (Loghi e tittolo)
                HeaderPlaceholder.Text = mDIPortalAdminUI.GetBootstrapHeader2(PortalsTitles.PrintDispatcher)

                '
                ' Set title
                ' ApplicationTitle = APPLICATION_TITLE
                '
                If SiteMap.CurrentNode IsNot Nothing Then
                    ApplicationTitle = SiteMap.CurrentNode.Description & " - " & APPLICATION_TITLE & " ver " & Reflection.Assembly.GetExecutingAssembly().GetName().Version.ToString()
                Else
                    ApplicationTitle = APPLICATION_TITLE & " ver " & Reflection.Assembly.GetExecutingAssembly().GetName().Version.ToString()
                End If
                '
                ' RECUPERO IL FOOTER
                '
                FooterPlaceHolder.InnerHtml = mDIPortalAdminUI.GetHtmlStatusbar("ver. " & Assembly.GetExecutingAssembly.GetName.Version.ToString)
                '
                ' Menu Orizzontale della DI
                '
                Try
                    Call PopulateMenu()
                    Call MenuOrizzontaleSitiDorsale_DataBind()
                Catch
                End Try

            End If
            '
            ' Get title
            '
            Page.Title = ApplicationTitle
        Catch ex As Exception
            My.Log.WriteException(ex, TraceEventType.Error, "Errore durante Site.Master.Page_Load().")
            Utility.GestisciErroriApplicationInsights(ex, "Errore durante Site.Master.Page_Load().")
        End Try
    End Sub

    Private Function BuildAllValuePath(sValuePath As String) As String()
        Try
            Dim oItemArray As String() = Split(sValuePath, "/")
            Dim iMaxIndex As Integer = oItemArray.Length - 1
            Dim oAllValuePath(iMaxIndex) As String
            oAllValuePath(0) = oItemArray(0)
            For i As Integer = 1 To iMaxIndex
                oAllValuePath(i) = oAllValuePath(i - 1) & "/" & oItemArray(i)
            Next
            Return oAllValuePath
        Catch ex As Exception
            Return Nothing
        End Try
    End Function

    Private Sub LeftMenuTreeView_DataBinding(sender As Object, e As System.EventArgs) Handles LeftMenuTreeView.DataBinding
        mStartMenuLeft = Date.Now()
        System.Diagnostics.Debug.WriteLine("")
        System.Diagnostics.Debug.WriteLine("---------->Start menu left binding")
    End Sub

    Private Sub LeftMenuTreeView_DataBound(ByVal sender As Object, ByVal e As System.EventArgs) Handles LeftMenuTreeView.DataBound
        PopolateLeftMenu_Reportistica()
    End Sub

    'Genera il menu a sinistra
    Private Sub LeftMenuTreeView_PreRender(sender As Object, e As EventArgs) Handles LeftMenuTreeView.PreRender
        Try
            Dim oTreeView As TreeView = DirectCast(sender, TreeView)
            Call RimuovoNodi(oTreeView)
            Call SelezionoNodo(oTreeView)
            System.Diagnostics.Debug.WriteLine(String.Format("---------->End menu left. Durata: {0} ms", Date.Now().Subtract(mStartMenuLeft).Milliseconds))
        Catch ex As Exception
        End Try
    End Sub

    Private Sub LeftMenuTreeView_TreeNodeDataBound(ByVal sender As Object, ByVal e As TreeNodeEventArgs) Handles LeftMenuTreeView.TreeNodeDataBound
        Try
            System.Diagnostics.Debug.WriteLine(e.Node.NavigateUrl)
            '
            ' Memorizzo ValuePath corrente = URL pagina navigata
            ' ATTENZIONE: e.Node.NavigateUrl può essere modificato aggiungendo dei parametri durante la navigazione
            '
            If String.Compare(Request.Url.AbsolutePath, e.Node.NavigateUrl.Split(CType("?", Char()))(0), True) = 0 Then
                msTreeViewCurrentValePath = e.Node.ValuePath
            End If
            '
            ' Attributo "hide" del SiteMap
            '
            Dim oNode As SiteMapNode = CType(e.Node.DataItem(), SiteMapNode)
            Dim sHideAttribute As String = oNode.Item("hide")
            Dim hide As Boolean = False
            If Not String.IsNullOrEmpty(sHideAttribute) Then
                Boolean.TryParse(sHideAttribute, hide)
            End If
            '
            ' Aggiungo item per la descrizione del menu
            '
            mMyMenuLeft.Add(e.Node.ValuePath, New MenuLeftAttribute(hide, e.Node.NavigateUrl))
        Catch
        End Try
    End Sub

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

    ''' <summary>
    ''' Popolazione del menu sinistro con eventuale reportistica
    ''' </summary>
    ''' <remarks></remarks>
    Private Sub PopolateLeftMenu_Reportistica()
        Try
            DI.PortalAdmin.Reports.ReportManager.FillTreeView(LeftMenuTreeView,
                                                              ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString,
                                                              DI.PortalAdmin.Reports.ReportingPortalsNames.PrintDispatcher, "ReportViewer.aspx?repository=di&reportName={0}")
            '
            ' Espando sempre i nodi del tree
            '
            Call LeftMenuTreeView.ExpandAll()
        Catch ex As Exception
            My.Log.WriteException(ex, TraceEventType.Error, "Errore durante Site.Master.PopolateLeftMenu_Reportistica().")
            Utility.GestisciErroriApplicationInsights(ex, "Errore durante Site.Master.PopolateLeftMenu_Reportistica().")

        End Try

    End Sub

    ''' <summary>
    ''' Popolazione del menu orizzontale della DI
    ''' </summary>
    ''' <remarks></remarks>
    Private Sub PopulateMenu()
        Try
            Me.MenuMain.Items.Clear()
            '
            ' Instanzio oggetto per ottenere le voci di menù
            '
            Dim oPortalDataAdapterManager As New DI.PortalAdmin.Data.PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)
            Dim dictionary As Dictionary(Of String, String) = oPortalDataAdapterManager.GetMainMenu()
            '
            ' Aggiungo le voci di menù al menù Main
            '
            For Each entry In dictionary

                Dim target = If(entry.Value.IndexOf("http", StringComparison.CurrentCultureIgnoreCase) > -1, "_blank", String.Empty)

                Dim newMenuItem As New MenuItem(entry.Key, Nothing, Nothing, Me.ResolveUrl(entry.Value), target)

                Me.MenuMain.Items.Add(newMenuItem)
            Next
        Catch ex As Exception
            My.Log.WriteException(ex, TraceEventType.Error, "Errore durante Site.Master.PopulateMenu().")
            Utility.GestisciErroriApplicationInsights(ex, "Errore durante Site.Master.PopolateLeftMenu_Reportistica().")
        End Try
    End Sub

    Private Sub RimuovoNodi(ByVal oTreeView As TreeView)
        If Not oTreeView Is Nothing AndAlso oTreeView.Nodes.Count > 0 Then
            '
            ' ATTENZIONE: Questo dictionary contiene solo valuepath(=key) relativi al tree composto nel sitemap
            '
            For Each sKey As String In mMyMenuLeft.Keys
                Try
                    Dim oMenuLeftAttribute As MenuLeftAttribute = mMyMenuLeft(sKey)
                    If oMenuLeftAttribute.Hide Then
                        '
                        ' Rimozione in base all'attributo "hide"
                        '
                        Dim oNode As TreeNode = oTreeView.FindNode(sKey)
                        If Not oNode Is Nothing Then
                            oNode.Parent.ChildNodes.Remove(oNode)
                        End If
                    End If
                Catch
                End Try
            Next
        End If
    End Sub

    Private Sub SelezionoNodo(ByVal oTreeView As TreeView)
        If Not oTreeView Is Nothing AndAlso oTreeView.Nodes.Count > 0 Then
            Dim oAllValuePath As String() = BuildAllValuePath(msTreeViewCurrentValePath)
            If Not oAllValuePath Is Nothing Then
                For i As Integer = oAllValuePath.Length - 1 To 0 Step -1
                    Dim oNode As TreeNode = oTreeView.FindNode(oAllValuePath(i))
                    If Not oNode Is Nothing Then
                        oNode.Selected = True
                        Exit For
                    End If
                Next
            End If
        End If
    End Sub

    Private Class MenuLeftAttribute
        Public Hide As Boolean = False
        Public NavigateUrl As String = String.Empty

        Public Sub New(Hide As Boolean, NavigateUrl As String)
            Me.Hide = Hide
            Me.NavigateUrl = NavigateUrl
        End Sub

    End Class

End Class