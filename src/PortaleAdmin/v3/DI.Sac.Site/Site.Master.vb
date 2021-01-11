Imports System.Web.UI
Imports System.Web
Imports System.Web.UI.WebControls
Imports System
Imports System.Reflection
Imports System.Collections.Generic
Imports System.Configuration
Imports DI.PortalAdmin.Data
Imports DI.PortalAdmin.Reports
Imports Microsoft.VisualBasic.Strings
Imports DI.PortalAdmin

Namespace DI.DataWarehouse.Admin

    Partial Public Class Site
        Inherits MasterPage

        Private Shared mDIPortalAdminUI As New UserInterface(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)

        Protected ReadOnly Property InstrumentationKey As String
            Get
                Return Microsoft.ApplicationInsights.Extensibility.TelemetryConfiguration.Active.InstrumentationKey
            End Get
        End Property

        Private msTreeViewCurrentValePath As String
        Private Class MenuLeftAttribute
            Public Hide As Boolean = False
            Public NavigateUrl As String = String.Empty
            Public Roles As System.Collections.IList = Nothing

            Public Sub New(Hide As Boolean, NavigateUrl As String, Roles As System.Collections.IList)
                Me.Hide = Hide
                Me.NavigateUrl = NavigateUrl
                Me.Roles = Roles
            End Sub

        End Class
        Private mMyMenuLeft As New Dictionary(Of String, MenuLeftAttribute)
        Private mStartMenuLeft As DateTime

        Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load
            Try
                Page.Title = "Dorsale Interoperabile ver " + Assembly.GetExecutingAssembly().GetName().Version.ToString()

                If Not IsPostBack Then

                    ' Ottengo l'Header del sito (Loghi e tittolo)
                    LblHeaderTitle.Text = PortalsTitles.Sac
                    ' Ottengo il sottotitolo
                    LblHeaderSubTitle.Text = mDIPortalAdminUI.GetSubTitle()

                    ' Ottengo l'URL per la pagina Informazioni del portale HOME ADMIN
                    LinkInformativaCE.HRef = mDIPortalAdminUI.GetURLInformazioni()

                    PopulateMenu()
                    '
                    ' RECUPERO IL FOOTER 
                    '
                    FooterPlaceholder.Text = mDIPortalAdminUI.GetHtmlStatusbar("ver. " & Assembly.GetExecutingAssembly.GetName.Version.ToString)
                    '
                    ' Verifico la versione del browser
                    '
                    Call VerificaBrowser()
                End If

            Catch ex As Exception
                'Scrivo solo nell'event log
                Call GestioneErrori.TrapError(ex)
            End Try
        End Sub

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

        Private Sub PopolateLeftMenu()

            Dim url = "Pages/ReportViewer.aspx?repository=di&reportName={0}"

            ReportManager.FillTreeView(LeftMenuTreeView, ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString, ReportingPortalsNames.Sac, url)

            LeftMenuTreeView.ExpandAll()

        End Sub


        Public Sub ChangeLeftMenuVisibility(ByVal show As Boolean)
            Me.LeftMenuHtmlTable.Style(HtmlTextWriterStyle.Display) = If(show, "block", "none")
        End Sub


        Private Sub LeftMenuTreeView_DataBinding(sender As Object, e As System.EventArgs) Handles LeftMenuTreeView.DataBinding
            mStartMenuLeft = Date.Now()
            System.Diagnostics.Debug.WriteLine("")
            System.Diagnostics.Debug.WriteLine("---------->Start menu left binding")
        End Sub

        Private Sub LeftMenuTreeView_TreeNodeDataBound(ByVal sender As Object, ByVal e As TreeNodeEventArgs) Handles LeftMenuTreeView.TreeNodeDataBound
            Try
                System.Diagnostics.Debug.WriteLine(e.Node.NavigateUrl)
                '
                ' Memorizzo ValuePath corrente = URL pagina navigata
                ' ATTENZIONE: e.Node.NavigateUrl può essere modificato aggiungendo dei parametri durante la navigazione
                '
                If String.Compare(Request.Url.AbsolutePath, e.Node.NavigateUrl.Split("?")(0), True) = 0 Then
                    msTreeViewCurrentValePath = e.Node.ValuePath
                End If
                '
                ' Attributo "hide" del SiteMap
                '
                Dim sHideAttribute As String = e.Node.DataItem("hide")
                Dim hide As Boolean = False
                If Not String.IsNullOrEmpty(sHideAttribute) Then
                    Boolean.TryParse(sHideAttribute, hide)
                End If
                '
                ' Attributo "roles" del SiteMap
                '
                Dim oListRoles As System.Collections.IList = DirectCast(e.Node.DataItem, SiteMapNode).Roles
                '
                ' Aggiungo item per la descrizione del menu
                '
                mMyMenuLeft.Add(e.Node.ValuePath, New MenuLeftAttribute(hide, e.Node.NavigateUrl, oListRoles))
            Catch
            End Try
        End Sub


        Protected Sub LeftMenuTreeView_DataBound(sender As Object, e As EventArgs) Handles LeftMenuTreeView.DataBound
            Try
                PopolateLeftMenu()
            Catch ex As Exception
                'Scrivo solo nell'event log
                Call GestioneErrori.TrapError(ex)
            End Try
        End Sub


        Private Sub LeftMenuTreeView_PreRender(sender As Object, e As System.EventArgs) Handles LeftMenuTreeView.PreRender
            Try
                Dim oTreeView As TreeView = DirectCast(sender, TreeView)
                Call RimuovoNodi(oTreeView)
                Call SelezionoNodo(oTreeView)
                System.Diagnostics.Debug.WriteLine(String.Format("---------->End menu left. Durata: {0} ms", Date.Now().Subtract(mStartMenuLeft).Milliseconds))
            Catch ex As Exception
                'Scrivo solo nell'event log
                Call GestioneErrori.TrapError(ex)
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
                        Else
                            '
                            ' Rimozione del nodo via codice in base ai ruoli dell'utente
                            '
                            If Not oMenuLeftAttribute.Roles Is Nothing AndAlso oMenuLeftAttribute.Roles.Count > 0 Then
                                Dim bRemove As Boolean = True
                                For Each sRole In oMenuLeftAttribute.Roles
                                    If HttpContext.Current.User.IsInRole(sRole) Then
                                        bRemove = False
                                        Exit For
                                    End If
                                Next
                                If bRemove Then
                                    Dim oNode As TreeNode = oTreeView.FindNode(sKey)
                                    If Not oNode Is Nothing Then
                                        oNode.Parent.ChildNodes.Remove(oNode)
                                    End If
                                End If
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

        Private Sub VerificaBrowser()
            Dim sUserMessage As String = String.Empty
            If Not mDIPortalAdminUI.IsBrowserSupported(Request, sUserMessage) Then
                divBrowserCompatibilityMsg.Visible = True
                lblBrowserCompatibilityMsg.Text = sUserMessage
            End If
        End Sub

    End Class

End Namespace