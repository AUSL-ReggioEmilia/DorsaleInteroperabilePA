Imports System
Imports System.Web.UI
Imports System.Data
Imports DI.OrderEntry.Admin.Data
Imports DI.OrderEntry.Admin.Data.Ordini
Imports DI.PortalAdmin.Data
Imports System.Web.UI.WebControls
Imports System.Data.SqlTypes
Imports System.Web.Services
Imports System.Xml
Imports System.Xml.Xsl
Imports System.IO
Imports System.Text
Imports System.Web
Imports DI.Common
Imports System.Collections
Imports System.Data.SqlClient
Imports System.Configuration

Namespace DI.OrderEntry.Admin

	Public Class OrdiniRichiesti
		Inherits Page

		Private ReadOnly PageSessionIdPrefix As String = Page.GetType().BaseType.FullName

#Region "Proprietà"

		Private Property PageIndex() As Integer
			Get
				Dim o As Object = Session(PageSessionIdPrefix + "PageIndex")
				If o Is Nothing Then
					Return 0
				Else
					Return DirectCast(o, Integer)
				End If
			End Get
			Set(ByVal value As Integer)
				Session(PageSessionIdPrefix + "PageIndex") = value
			End Set
		End Property

		Private Property SortExpression() As String
			Get
				Dim o As Object = Session(PageSessionIdPrefix + "SortExpression")
				If o Is Nothing Then
					Return String.Empty
				Else
					Return o.ToString()
				End If
			End Get
			Set(ByVal value As String)
				Session(PageSessionIdPrefix + "SortExpression") = value
			End Set
		End Property

		Private Property SortDirection() As SortDirection
			Get
				Dim o As Object = Session(PageSessionIdPrefix + "SortDirection")
				If o Is Nothing Then
					Return Nothing
				Else
					Return DirectCast(o, SortDirection)
				End If
			End Get
			Set(ByVal value As SortDirection)
				Session(PageSessionIdPrefix + "SortDirection") = value
			End Set
		End Property
#End Region

		Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load

			If Not Page.IsPostBack Then

				FilterHelper.Restore(filterPanel, PageSessionIdPrefix)
				'RIPRISTINO ANCHE L'ORDINAMENTO EVENTUALMENTE SALVATO
				If Not String.IsNullOrEmpty(SortExpression.Length) Then
					OrdiniGridView.Sort(SortExpression, SortDirection)
				End If
			End If
		End Sub

		Private Sub SearchButton_Click(sender As Object, e As System.EventArgs) Handles SearchButton.Click

			FilterHelper.SaveInSession(filterPanel, PageSessionIdPrefix)
			OrdiniGridView.DataBind()

			'
			'2020-07-13 Kyrylo: Traccia Operazioni
			'
			Dim oTracciaOp As New TracciaOperazioniManager(Global_asax.ConnectionStringPortalAdmin)
			oTracciaOp.TracciaOperazione(PortalsNames.OrderEntry, Page.AppRelativeVirtualPath, "Ricerca ordini", filterPanel, Nothing)

		End Sub


		Protected Function GetValiditaIcon(ByVal isValido As Boolean, messaggio As String) As String

			If isValido Then
				Return "<img src='../Images/ok.png' title=""" + messaggio + """ />"
			Else
				Return "<img src='../Images/alert.png' title=""" + messaggio + """ />"
			End If
		End Function

		Protected Function GetSacPazienteUrl(ByVal id As Object) As String

			If id IsNot DBNull.Value Then
				Return String.Format(My.Settings.PazienteSacUrl, id)
			Else
				Return String.Empty
			End If
		End Function

		<WebMethod()> _
		Public Shared Function GetDatiAggiuntivi(ByVal id As String) As String

			Dim guid As Guid?

			If Not Utility.TryParseStringToGuid(id, guid) Then
				Return String.Empty
			End If

			Dim dataTable As New UiOrdiniTestateDatiAggiuntiviListDataTable()

			DataAdapterManager.Fill(dataTable, guid.Value)

			If dataTable.Count > 0 Then

				If dataTable(0).IsDatiAggiuntiviNull() Then
					Return My.Resources.NoDatiAggiuntivi
				End If

				Dim xslTransform As New XslCompiledTransform()

				xslTransform.Load(HttpContext.Current.Server.MapPath("~/Styles/DatiAggiuntivi.xslt"))

				Using memoryStream As New MemoryStream()

					Dim document As New XmlDocument()
					document.LoadXml(dataTable(0).DatiAggiuntivi)

					Dim xmlTextWriter As New XmlTextWriter(memoryStream, Encoding.UTF8)

					xslTransform.Transform(document.CreateNavigator(), xmlTextWriter)
					memoryStream.Position = 0

					Return Encoding.UTF8.GetString(memoryStream.ToArray())
				End Using
			Else
				Return My.Resources.NoDatiAggiuntivi
			End If
		End Function

#Region "Funzioni di Lookup"

		Public Function GetLookupAziendeData() As DataView

			Dim lookupAziendeDataTable As New UILookupAziendeDataTable()
			DataAdapterManager.Fill(lookupAziendeDataTable, Nothing, True)
			lookupAziendeDataTable.DefaultView.Sort = lookupAziendeDataTable.CodiceColumn.ColumnName
			Return lookupAziendeDataTable.DefaultView
		End Function

		Public Function GetLookupSistemiErogantiData() As DataView

			Dim lookupSistemi As New Data.Ennuple.UiLookupSistemiErogantiDataTable()
			DataAdapterManager.Fill(lookupSistemi, Nothing, True)
			lookupSistemi.DefaultView.Sort = lookupSistemi.DescrizioneColumn.ColumnName
			Return lookupSistemi.DefaultView
		End Function

		Public Function GetLookupSistemiRichiedentiData() As DataView

			Dim lookupSistemi As New Data.Ennuple.UiLookupSistemiRichiedentiDataTable()
			DataAdapterManager.Fill(lookupSistemi, Nothing, True)
			lookupSistemi.DefaultView.Sort = lookupSistemi.DescrizioneColumn.ColumnName
			Return lookupSistemi.DefaultView
		End Function

		Public Function GetLookupStati() As DataView

			Dim lookupStati As New UiLookupStatiCalcolatiOrdineDataTable()
			DataAdapterManager.Fill(lookupStati, Nothing, True)
			'	lookupStati.DefaultView.Sort = lookupStati.DescrizioneColumn.ColumnName
			Return lookupStati.DefaultView
		End Function

		'Public Function GetLookupStatiOrdineData() As DataView

		'   Dim lookupStatiOrdiniDataTable As New UILookupStatiOrdineDataTable()
		'	DataAdapterManager.Fill(lookupStatiOrdiniDataTable, Nothing, True)
		'	lookupStatiOrdiniDataTable.DefaultView.Sort = lookupStatiOrdiniDataTable.OrdinamentoColumn.ColumnName
		'	Return lookupStatiOrdiniDataTable.DefaultView
		'End Function

#End Region

		Private Sub MainObjectDataSource_Selecting(ByVal sender As Object, ByVal e As ObjectDataSourceSelectingEventArgs) Handles OrdiniListaObjectDataSource.Selecting

			If e.InputParameters("idSistemaRichiedente").ToString = Guid.Empty.ToString Then
				e.InputParameters("idSistemaRichiedente") = Nothing
			End If
			If e.InputParameters("idSistemaErogante").ToString() = Guid.Empty.ToString() Then
				e.InputParameters("idSistemaErogante") = Nothing
			End If

			Dim periodoInserimento = DirectCast(filterPanel.FindControl("PeriodoInserimentoDropDownList"), DropDownList).SelectedValue
			If periodoInserimento <> " " Then
				e.InputParameters("dataInserimentoDa") = Utility.GetDataDaPerFiltro(periodoInserimento)
				e.InputParameters("dataInserimentoA") = DateTime.Now
			End If

			Dim periodoRichiesta = DirectCast(filterPanel.FindControl("PeriodoRichiestaDropDownList"), DropDownList).SelectedValue

			If periodoRichiesta <> " " Then
				e.InputParameters("dataRichiestaDa") = Utility.GetDataDaPerFiltro(periodoRichiesta)
				e.InputParameters("dataRichiestaA") = DateTime.Now
			End If

			Dim text = "Ordini Richiesti|Parametri: "
			For Each item As DictionaryEntry In e.InputParameters
				If item.Value IsNot Nothing Then
					text &= item.Key & "=" & item.Value.ToString() & "; "
				End If
			Next

			' ORDINAMENTO
			If Me.SortExpression.Length > 0 Then
				Dim sDir = If(Me.SortDirection = WebControls.SortDirection.Ascending, "@ASC", "@DESC")
				e.InputParameters("Ordinamento") = Me.SortExpression & sDir
			End If

			DataAdapterManager.PortalAdminDataAdapterManager.TracciaAccessi(User.Identity.Name, PortalsNames.OrderEntry, text)
		End Sub

		Protected Sub OrdiniListaObjectDataSource_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles OrdiniListaObjectDataSource.Selected

			If e.Exception IsNot Nothing Then
				e.ExceptionHandled = True
				ExceptionsManager.TraceException(e.Exception)
				Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)
				portal.TracciaErrori(e.Exception, User.Identity.Name, PortalsNames.OrderEntry)
				Dim message = "Si è verificato un errore, contattare un amministratore."
				If e.Exception.InnerException IsNot Nothing Then
					Dim ex = TryCast(e.Exception.InnerException, SqlException)
					If ex IsNot Nothing Then
						Select Case ex.Number
							'timeOut
							Case -2
								message = "Timeout del server, specificare ulteriori parametri di ricerca."
						End Select
					End If
				End If

				ErrorLabel.Text = message
				ErrorLabel.Visible = True
			Else
				ErrorLabel.Visible = False
			End If
		End Sub

		Protected Sub OrdiniGridView_RowDataBound(ByVal sender As Object, ByVal e As GridViewRowEventArgs) Handles OrdiniGridView.RowDataBound

			If (e.Row.RowType = DataControlRowType.Header) Then
				Dim cellIndex = -1
				For Each field As DataControlField In OrdiniGridView.Columns
					e.Row.Cells(OrdiniGridView.Columns.IndexOf(field)).CssClass = "GridHeader"
					If field.SortExpression = OrdiniGridView.SortExpression AndAlso OrdiniGridView.SortExpression.Length > 0 Then
						cellIndex = OrdiniGridView.Columns.IndexOf(field)
					End If
				Next
				If cellIndex > -1 Then
					e.Row.Cells(cellIndex).CssClass = If(OrdiniGridView.SortDirection = SortDirection.Ascending, "GridHeaderSortAsc", "GridHeaderSortDesc")
				End If
			End If
		End Sub

		Protected Sub OrdiniGridView_Sorted(sender As Object, e As EventArgs) Handles OrdiniGridView.Sorted

			Me.SortExpression = OrdiniGridView.SortExpression
			Me.SortDirection = OrdiniGridView.SortDirection

		End Sub

		Protected Sub OrdiniGridView_PageIndexChanged(sender As Object, e As EventArgs) Handles OrdiniGridView.PageIndexChanged

			Me.PageIndex = OrdiniGridView.PageIndex

		End Sub

	End Class

End Namespace