Imports System.Web.UI
Imports System.Web
Imports System.Web.UI.WebControls
Imports System
Imports System.Reflection
Imports System.Collections.Generic
Imports System.Configuration
Imports DI.PortalAdmin.Data
Imports DI.PortalAdmin.Reports

Namespace DI.PortalAdmin

    Partial Public Class Site
        Inherits MasterPage

        Private userInterface As UserInterface = New UserInterface(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)

        Protected ReadOnly Property InstrumentationKey As String
            Get
                Return Microsoft.ApplicationInsights.Extensibility.TelemetryConfiguration.Active.InstrumentationKey
            End Get
        End Property

        Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load
            Try

                Page.Title = "Dorsale Interoperabile ver " + Assembly.GetExecutingAssembly().GetName().Version.ToString()

                If Not IsPostBack Then

                    ' Ottengo l'Header del sito (Loghi e tittolo)
                    HeaderPlaceholder.Text = UserInterface.GetBootstrapHeader2(PortalsTitles.Home)

                    PopulateMenu()
                End If
            Catch ex As Exception
                divAlertMessage.Visible = True
                divAlertMessage.InnerText = GestioneErrori.TrapError(ex)
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
            Try
                Dim url = "Pages/ReportViewer.aspx?repository=di&reportName={0}"

                ReportManager.FillTreeView(LeftMenuTreeView, ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString, ReportingPortalsNames.Home, url)

                LeftMenuTreeView.ExpandAll()
            Catch ex As Exception

            End Try
        End Sub

        Private Sub LeftMenuTreeView_PreRender(sender As Object, e As EventArgs) Handles LeftMenuTreeView.PreRender
            Try
                'CICLO TUTTI I NODI DEL TREE VIEW
                For Each treeNode As TreeNode In LeftMenuTreeView.Nodes
                    'DICHIARO UNA VARIABILE IN CUI SALVERÒ L'URL DEL TREE NODE.
                    Dim sNodePath As String = String.Empty
                    'SALVO IN UNA VARIABLE L'URL DELLA PAGINA IN CUI MI TROVO(PATH + QUERY STRING)
                    Dim sPath As String = Request.Url.PathAndQuery
                    'TESTO SE treeNode E' VUOTO.
                    If treeNode IsNot Nothing Then
                        'SE IL TREE NODE HA DEI CHILD NODES ALLORA SIGNIFICA CHE È UN ROOT NODE.
                        If treeNode.ChildNodes.Count > 0 Then
                            'SE SONO QUI IL NODO E' UN ROOT NODE E NE DISABILITO LA POSSIBILITà DI CLICCARLO.
                            treeNode.SelectAction = TreeNodeSelectAction.None
                            'CICLO TUTTI I CHILD NODE DEL ROOT NODE.
                            For Each childNode As TreeNode In treeNode.ChildNodes
                                'OTTENGO IL PATH DEL CHILD NODE.
                                sNodePath = childNode.NavigateUrl
                                'SE L'URL DELLA PAGINA CORRENTE E' UGUALE AL PATH DEL NODO ALLORA LO SELEZIONO E ESCO DAL FOR.
                                If sNodePath.ToUpper = sPath.ToUpper Then
                                    childNode.Selected = True
                                End If
                            Next
                        Else
                            'SE SONO QUI IL NODO NON E' UN CHILD NODE.
                            sNodePath = treeNode.NavigateUrl
                            If sNodePath.ToUpper = sPath.ToUpper Then
                                'SE L'URL DELLA PAGINA CORRENTE E' UGUALE AL PATH DEL NODO ALLORA LO SELEZIONO E ESCO DAL FOR.
                                treeNode.Selected = True
                            End If
                        End If
                    End If
                Next
            Catch ex As Exception
                divAlertMessage.Visible = True
                divAlertMessage.InnerText = GestioneErrori.TrapError(ex)
            End Try
        End Sub

        Private Sub LeftMenuTreeView_DataBound(sender As Object, e As EventArgs) Handles LeftMenuTreeView.DataBound
            'POPOLO IL MENU LATERALE.
            PopolateLeftMenu()
        End Sub
    End Class
End Namespace