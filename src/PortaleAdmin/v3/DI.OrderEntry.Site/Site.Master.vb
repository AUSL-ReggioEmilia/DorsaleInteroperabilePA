Imports System.Web.UI
Imports System.Web
Imports System.Web.UI.WebControls
Imports System
Imports System.Reflection
Imports System.Collections.Generic
Imports System.Configuration
Imports DI.PortalAdmin.Data
Imports DI.PortalAdmin.Reports
Imports DI.PortalAdmin


Namespace DI.OrderEntry.Admin

    Partial Public Class Site
        Inherits MasterPage

        Public WithEvents LeftMenuTreeView As TreeView
        Private Shared mDIPortalAdminUI As New UserInterface(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)

        Protected ReadOnly Property InstrumentationKey As String
            Get
                Return Microsoft.ApplicationInsights.Extensibility.TelemetryConfiguration.Active.InstrumentationKey
            End Get
        End Property

        Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load

            If SiteMap.CurrentNode IsNot Nothing Then
                Page.Title = SiteMap.CurrentNode.Description + " - Dorsale Interoperabile ver 1.0"
            Else
                Page.Title = "Dorsale Interoperabile ver 1.0"
            End If

            If Not IsPostBack Then


                ' Ottengo l'Header del sito (Loghi e tittolo)
                LblHeaderTitle.Text = PortalsTitles.OrderEntry
                ' Ottengo il sottotitolo
                LblHeaderSubTitle.Text = mDIPortalAdminUI.GetSubTitle()

                ' Ottengo l'URL per la pagina Informazioni del portale HOME ADMIN
                LinkInformativaCE.HRef = mDIPortalAdminUI.GetURLInformazioni()

                '-------------------------------------------------
                ' MODIFICA ETTORE 2019-02-19: questo DataBind viene usato per lo script presente nel markup che legge la instrumentation key di AppInsights
                ' E' stato usato il DataBind perchè l'istruzione instrumentationKey: "<%= InstrumentationKey %>" generava errore
                '-------------------------------------------------
                Page.Header.DataBind()
                '-------------------------------------------------
                '
                '
                '
                PopulateMenu()
                '
                ' RECUPERO IL FOOTER 
                '
                Dim AppVersion = Assembly.GetExecutingAssembly.GetName.Version.ToString
                Dim span = "<span title='Framework Version:" & Utils.FrameworkVersion & "'>ver. " & AppVersion & "</span>"
                FooterPlaceholder.Text = mDIPortalAdminUI.GetHtmlStatusbar(span)
                '
                ' Verifico la versione del browser
                '
                Call VerificaBrowser()
            End If

        End Sub

        ''' <summary>
        ''' Popola il menu orizzontale
        ''' </summary>
        Private Sub PopulateMenu()

            Me.MenuMain.Items.Clear()

            Dim adapter As New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)

            Dim dictionary As Dictionary(Of String, String) = adapter.GetMainMenu()

            For Each entry In dictionary
                Dim target = If(entry.Value.IndexOf("http", StringComparison.CurrentCultureIgnoreCase) > -1, "_blank", String.Empty)
                Dim newMenuItem As New MenuItem(entry.Key, Nothing, Nothing, Me.ResolveUrl(entry.Value), target)
                Me.MenuMain.Items.Add(newMenuItem)
            Next
        End Sub

        ''' <summary>
        ''' Popola il TreeView a sinistra
        ''' </summary>
        ''' <remarks></remarks>
        Private Sub PopolateLeftMenu()

            Dim url = "Pages/ReportViewer.aspx?repository=di&reportName={0}"
            ReportManager.FillTreeView(LeftMenuTreeView, ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString, ReportingPortalsNames.OrderEntry, url)
            LeftMenuTreeView.ExpandAll()

        End Sub

        Private Sub CleanTreeView(nodes As TreeNodeCollection)

            For Each node As TreeNode In nodes

                If node.ChildNodes.Count > 0 Then
                    node.NavigateUrl = String.Empty
                    node.SelectAction = TreeNodeSelectAction.Expand
                End If

                CleanTreeView(node.ChildNodes)
            Next
        End Sub

        Public Sub ChangeLeftMenuVisibility(ByVal show As Boolean)

            Me.LeftMenuHtmlTable.Style(HtmlTextWriterStyle.Display) = If(show, "block", "none")
        End Sub

        Private Sub LeftMenuTreeView_TreeNodeDataBound(ByVal sender As Object, ByVal e As TreeNodeEventArgs) Handles LeftMenuTreeView.TreeNodeDataBound

            If e.Node.NavigateUrl.EndsWith("OrdiniDettaglio.aspx") Then

                If Request.Url.AbsolutePath = e.Node.NavigateUrl Then
                    e.Node.Parent.Selected = True
                End If

                e.Node.Parent.ChildNodes.Remove(e.Node)
            Else
                '
                ' Attributo "hide" del SiteMap
                '
                Dim sHideAttribute As String = e.Node.DataItem("hide")
                Dim hide As Boolean = False
                If Not String.IsNullOrEmpty(sHideAttribute) Then
                    Boolean.TryParse(sHideAttribute, hide)
                End If
                If hide Then
                    If Request.Url.AbsolutePath = e.Node.NavigateUrl Then
                        e.Node.Parent.Selected = True
                    End If
                    e.Node.Parent.ChildNodes.Remove(e.Node)
                End If
            End If
        End Sub

        Protected Sub LeftMenuTreeView_DataBound(sender As Object, e As EventArgs) Handles LeftMenuTreeView.DataBound

            PopolateLeftMenu()

        End Sub

        Private Sub VerificaBrowser()
            Dim sUserMessage As String = String.Empty
            If Not mDIPortalAdminUI.IsBrowserSupported(Request, sUserMessage) Then
                divBrowserCompatibilityMsg.Visible = True
                lblBrowserCompatibilityMsg.Text = sUserMessage
            End If
        End Sub

    End Class

End Namespace