Imports System.Web.UI
Imports System.Web
Imports System.Web.UI.WebControls
Imports System
Imports System.Reflection
Imports System.Collections.Generic
Imports System.Configuration
Imports DI.PortalAdmin.Data
Imports DI.PortalAdmin.Reports
'Imports DI.Common
Imports DI.PortalAdmin

Namespace DI.DataWarehouse.Admin

	Partial Public Class Site
        Inherits MasterPage

        ''' <summary>
        ''' InstrumentationKey per ApplicationInsight
        ''' </summary>
        ''' <returns></returns>
        Protected ReadOnly Property InstrumentationKey As String
            Get
                Return Microsoft.ApplicationInsights.Extensibility.TelemetryConfiguration.Active.InstrumentationKey
            End Get
        End Property


        Private Shared mDIPortalAdminUI As New UserInterface(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)

		Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load
			Try

				'If SiteMap.CurrentNode IsNot Nothing Then
				'    Page.Title = SiteMap.CurrentNode.Description + " - Dorsale Interoperabile ver " + Assembly.GetExecutingAssembly().GetName().Version.ToString()
				'Else
				Page.Title = "Dorsale Interoperabile ver " + Assembly.GetExecutingAssembly().GetName().Version.ToString()
				'End If

				'
				' RECUPERO IL FOOTER 
				'
				FooterPlaceholder.Text = mDIPortalAdminUI.GetHtmlStatusbar("ver. " & Assembly.GetExecutingAssembly.GetName.Version.ToString)

				If Not IsPostBack Then

					' Ottengo l'Header del sito (Loghi e tittolo)
					LblHeaderTitle.Text = PortalsTitles.DwhClinico
					' Ottengo il sottotitolo
					LblHeaderSubTitle.Text = mDIPortalAdminUI.GetSubTitle()

					' Ottengo l'URL per la pagina Informazioni del portale HOME ADMIN
					LinkInformativaCE.HRef = mDIPortalAdminUI.GetURLInformazioni()

					PopulateMenu()
					'
					' Verifico la versione del browser
					'
					Call VerificaBrowser()
				End If

			Catch ex As Exception
				GestioneErrori.TrapError(ex)
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

			ReportManager.FillTreeView(LeftMenuTreeView, ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString, ReportingPortalsNames.DwhClinico, url)

			LeftMenuTreeView.ExpandAll()

			CleanTreeView(LeftMenuTreeView.Nodes)
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

		'Private Sub LeftMenuTreeView_TreeNodeDataBound(ByVal sender As Object, ByVal e As TreeNodeEventArgs) Handles LeftMenuTreeView.TreeNodeDataBound

		'	If e.Node.NavigateUrl.EndsWith("RefertiNoteDettaglio.aspx") _
		'	  OrElse e.Node.NavigateUrl.EndsWith("StiliDettaglio.aspx") _
		'	  OrElse e.Node.NavigateUrl.EndsWith("SistemiErogantiDocumentiDettaglio.aspx") _
		'	  OrElse e.Node.NavigateUrl.EndsWith("AbbonamentiStampeDettaglio.aspx") _
		'	  OrElse e.Node.NavigateUrl.EndsWith("FileUpload.aspx") _
		'	  OrElse e.Node.NavigateUrl.EndsWith("OscuramentiDettaglio.aspx") Then

		'		If Request.Url.AbsolutePath = e.Node.NavigateUrl Then
		'			e.Node.Parent.Selected = True
		'		End If

		'		e.Node.Parent.ChildNodes.Remove(e.Node)
		'	End If
		'End Sub

		Private Sub LeftMenuTreeView_TreeNodeDataBound(ByVal sender As Object, ByVal e As TreeNodeEventArgs) Handles LeftMenuTreeView.TreeNodeDataBound
			Try
				'
				' Attributo "hide" del SiteMap
				'
				Dim sHideAttribute As String = e.Node.DataItem("hide")
				Dim hide As Boolean = False
                If Not String.IsNullOrEmpty(sHideAttribute) Then
                    Boolean.TryParse(sHideAttribute, hide)
                    If hide Then
                        If Request.Url.AbsolutePath = e.Node.NavigateUrl Then
                            e.Node.Parent.Selected = True
                        End If
                        e.Node.Parent.ChildNodes.Remove(e.Node)
                    End If
                End If


                '
                'Simoneb -15/01/2018
                'Nascondo i tree node delle NoteAnamnestiche in base alla setting NoteAnamnestiche_Visualizza del web.config
                '
                If e.Node.NavigateUrl.ToUpper.Contains("NOTEANAMNESTICHE") Then
                    If Not My.Settings.NoteAnamnestiche_Visualizza Then
                        e.Node.Parent.ChildNodes.Remove(e.Node)
                    End If
                End If
                '
                ' ETTORE: 2018-01-19: nascondo gli item del treeview relativi al tool di export/import referto in base alle configurazioni 
                '
                If e.Node.NavigateUrl.ToUpper.Contains("PAGESTOOLS/REFERTOEXPORT.ASPX") Then
                    If Not My.Settings.ToolRefertoExport_Abilitato Then
                        e.Node.Parent.ChildNodes.Remove(e.Node)
                    End If
                End If
                If e.Node.NavigateUrl.ToUpper.Contains("PAGESTOOLS/REFERTOIMPORT.ASPX") Then
                    If Not My.Settings.ToolRefertoImport_Abilitato Then
                        e.Node.Parent.ChildNodes.Remove(e.Node)
                    End If
                End If



            Catch ex As Exception
				System.Diagnostics.Debug.Assert(False, ex.Message)
			End Try
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