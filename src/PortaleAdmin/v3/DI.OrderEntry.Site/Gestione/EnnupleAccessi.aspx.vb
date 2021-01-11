Imports System
Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports System.Data
Imports DI.OrderEntry.Admin.Data.EnnupleAccessi
Imports DI.OrderEntry.Admin.Data.EnnupleAccessiTableAdapters
Imports DI.OrderEntry.Admin.Data.Ennuple
Imports DI.OrderEntry.Admin.Data.EnnupleTableAdapters
Imports DI.OrderEntry.Admin.Data
Imports DI.Common
Imports System.Web.Services
Imports System.Collections.Generic
Imports System.Web
Imports DI.PortalAdmin.Data
Imports System.Configuration
Imports System.Linq
Imports System.Data.DataTableExtensions

Namespace DI.OrderEntry.Admin

	Public Class EnnupleAccessi
		Inherits Page

		Private Const PageSessionIdPrefix As String = "EnnupleAccessi_"

		Private Property FilterLoaded() As Boolean
			Get
				Dim o As Object = Session(PageSessionIdPrefix + "FilterLoaded")
				If o Is Nothing Then Return String.Empty Else Return o.ToString()
			End Get
			Set(ByVal value As Boolean)
				Session(PageSessionIdPrefix + "FilterLoaded") = value
			End Set
		End Property

		Private Property SortExpression() As String
			Get
				Dim o As Object = Session(PageSessionIdPrefix + "SortExpression")
				If o Is Nothing Then Return String.Empty Else Return o.ToString()
			End Get
			Set(ByVal value As String)
				Session(PageSessionIdPrefix + "SortExpression") = value
			End Set
		End Property

		Private Property SortDirection() As SortDirection
			Get
				Dim o As Object = Session(PageSessionIdPrefix + "SortDirection")
				If o Is Nothing Then Return Nothing Else Return DirectCast(o, SortDirection)
			End Get
			Set(ByVal value As SortDirection)
				Session(PageSessionIdPrefix + "SortDirection") = value
			End Set
		End Property

		Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load

			If Not Page.IsPostBack Then

				EnnupleListView.Sort(SortExpression, SortDirection)
			Else

				If ErrorLabel.Visible Then
					ErrorLabel.Visible = False
				End If

				SaveFilters()
			End If

			LoadFilters()
		End Sub

		Protected Sub EnnupleObjectDataSource_Selecting(sender As Object, e As ObjectDataSourceMethodEventArgs) Handles EnnupleObjectDataSource.Selecting

			If Not Page.IsPostBack AndAlso Not Me.FilterLoaded Then
				e.Cancel = True
			End If
		End Sub

		Protected Sub EnnupleObjectDataSource_Inserting(sender As Object, e As ObjectDataSourceMethodEventArgs) Handles EnnupleObjectDataSource.Inserting

			e.InputParameters("UtenteInserimento") = My.User.Name

			Dim idSistemaErogante = DirectCast(EnnupleListView.InsertItem.FindControl("SistemaEroganteDropDownList"), DropDownList).SelectedValue
			Dim idStato = DirectCast(EnnupleListView.InsertItem.FindControl("StatoDropDownList"), DropDownList).SelectedValue

			If idSistemaErogante.Length > 0 Then e.InputParameters("IDSistemaErogante") = idSistemaErogante
			If idStato.Length > 0 Then e.InputParameters("IDStato") = idStato

			e.InputParameters("Inverso") = DirectCast(EnnupleListView.InsertItem.FindControl("NotCheckBox"), CheckBox).Checked

		End Sub

		Protected Sub EnnupleObjectDataSource_Updating(sender As Object, e As ObjectDataSourceMethodEventArgs) Handles EnnupleObjectDataSource.Updating

			e.InputParameters("UtenteModifica") = My.User.Name

		End Sub

		Protected Sub EnnupleListView_Sorted(sender As Object, e As EventArgs) Handles EnnupleListView.Sorted

			Me.SortExpression = EnnupleListView.SortExpression
			Me.SortDirection = EnnupleListView.SortDirection
		End Sub

		Private Sub LoadFilters()

			Me.FilterLoaded = False

			For Each control As Control In filterPanel.Controls

				Dim value As String = If(String.IsNullOrEmpty(control.ID), String.Empty, Session(PageSessionIdPrefix + control.ID))

				If value Is Nothing Then
					Continue For
				End If

				Dim filterTextBox = TryCast(control, TextBox)

				If filterTextBox IsNot Nothing Then

					filterTextBox.Text = value

					Me.FilterLoaded = True
				Else
					Dim filterComboBox = TryCast(control, DropDownList)

					If filterComboBox IsNot Nothing Then

						filterComboBox.SelectedValue = value

						Me.FilterLoaded = True
					Else
						Dim filterCheckBox = TryCast(control, CheckBox)

						If filterCheckBox IsNot Nothing Then

							filterCheckBox.Checked = Boolean.Parse(value)

							Me.FilterLoaded = True
						End If
					End If
				End If
			Next
		End Sub

		<WebMethod()>
		Public Shared Function SaveFilter(controlId As String, value As String) As String

			If HttpContext.Current.Session(PageSessionIdPrefix + controlId) Is Nothing Then

				HttpContext.Current.Session.Add(PageSessionIdPrefix + controlId, value)
			Else
				HttpContext.Current.Session(PageSessionIdPrefix + controlId) = value
			End If

			Return "ok"
		End Function

		Private Sub SaveFilters()

			For Each control As Control In filterPanel.Controls

				Dim value As String = String.Empty

				Dim filterTextBox = TryCast(control, TextBox)

				If filterTextBox IsNot Nothing Then

					value = filterTextBox.Text
				Else
					Dim filterComboBox = TryCast(control, DropDownList)

					If filterComboBox IsNot Nothing Then

						value = filterComboBox.SelectedValue
					Else
						Dim filterCheckBox = TryCast(control, CheckBox)

						If filterCheckBox IsNot Nothing Then

							value = filterCheckBox.Checked.ToString()
						End If
					End If
				End If

				If Session(PageSessionIdPrefix + control.ID) Is Nothing Then

					Session.Add(PageSessionIdPrefix + control.ID, value)
				Else
					Session(PageSessionIdPrefix + control.ID) = value
				End If
			Next
		End Sub

		Protected Sub EnnupleListView_ItemCommand(sender As Object, e As ListViewCommandEventArgs) Handles EnnupleListView.ItemCommand

			If e.CommandName = "Copy" Then

				Dim id = New Guid(e.CommandArgument.ToString())

				DataAdapterManager.CopiaEnnuplaAccessi(id, My.User.Name)

				Response.Redirect(Request.RawUrl)
			End If

			If e.CommandName = "Elimina" Then

				Dim id = New Guid(e.CommandArgument.ToString())

				DataAdapterManager.EliminaEnnuplaAccessi(id)

				Response.Redirect(Request.RawUrl)
			End If
		End Sub

		Protected Sub CercaButton_Click(sender As Object, e As EventArgs) Handles CercaButton.Click
			Me.EnnupleListView.DataBind()
		End Sub

		Public Sub SaveButton_Click()
			ErrorLabel.Visible = False
			ErrorLabel.Text = ""

			Dim id As Guid? = Nothing
			If Not Me.EnnuplaAccessiDetail_IdHiddenField.Value Is Nothing AndAlso Not String.IsNullOrEmpty(Me.EnnuplaAccessiDetail_IdHiddenField.Value.ToString) Then
				id = New Guid(Me.EnnuplaAccessiDetail_IdHiddenField.Value.ToString)
			End If

			Dim inverso = Me.EnnuplaAccessiDetail_NotCheckBox.Checked
			Dim idStato = If(Me.EnnuplaAccessiDetail_StatoDropDownList.SelectedValue Is Nothing OrElse String.IsNullOrEmpty(Me.EnnuplaAccessiDetail_StatoDropDownList.SelectedValue.ToString), Nothing, Me.EnnuplaAccessiDetail_StatoDropDownList.SelectedValue.ToString)
			Dim descrizione = Me.EnnuplaAccessiDetail_DescrizioneTextBox.Text
			Dim note = Me.EnnuplaAccessiDetail_NoteTextBox.Text

			Dim idSistemaErogante As Guid? = Nothing
			If Not Me.EnnuplaAccessiDetail_SistemaEroganteDropDownList.SelectedValue Is Nothing AndAlso Not String.IsNullOrEmpty(Me.EnnuplaAccessiDetail_SistemaEroganteDropDownList.SelectedValue.ToString) Then
				idSistemaErogante = New Guid(Me.EnnuplaAccessiDetail_SistemaEroganteDropDownList.SelectedValue.ToString)
			End If

			Dim idGruppoUtenti As Guid? = Nothing
			If Not Me.EnnuplaAccessiDetail_GruppoUtentiDropDownList.SelectedValue Is Nothing AndAlso Not String.IsNullOrEmpty(Me.EnnuplaAccessiDetail_GruppoUtentiDropDownList.SelectedValue.ToString) Then
				idGruppoUtenti = New Guid(Me.EnnuplaAccessiDetail_GruppoUtentiDropDownList.SelectedValue.ToString)
			End If

			Dim lettura = Me.EnnuplaAccessiDetail_LetturaCheckBox.Checked
			Dim scrittura = Me.EnnuplaAccessiDetail_ScritturaCheckBox.Checked
			Dim inoltro = Me.EnnuplaAccessiDetail_InoltroCheckBox.Checked

			' CONTROLLO PER NON LASCIAR INSERIRE UN'ENNUPLA CON (NOT + TUTTI + TUTTI)
			If inverso And
			 idSistemaErogante.HasValue = False _
			 And idGruppoUtenti.HasValue = False Then
				ErrorLabel.Visible = True
				ErrorLabel.Text = "Non è possibile inserire un'Ennupla che neghi l'accesso a tutti."
				Return
			End If

			Try
				Using uiEnnupleAccessiListTableAdapter As New DI.OrderEntry.Admin.Data.EnnupleAccessiTableAdapters.UiEnnupleAccessiListTableAdapter()

					If id.HasValue AndAlso id.Value <> Guid.Empty Then
						'modifica
						uiEnnupleAccessiListTableAdapter.Update(id, My.User.Name, idGruppoUtenti, descrizione, idSistemaErogante, lettura, inoltro, scrittura, inverso, idStato, note)
					Else
						'inserimento
						uiEnnupleAccessiListTableAdapter.Insert(My.User.Name, idGruppoUtenti, descrizione, idSistemaErogante, lettura, inoltro, scrittura, inverso, idStato, note)
					End If

				End Using

				Me.EnnupleListView.DataBind()

			Catch ex As Exception

				If ex.Message.Contains("duplicate") Then
					ErrorLabel.Text = "Errore in inserimento: non è stato possibile un nuovo permesso in quanto contiene i valori di gruppo utente, sistema erogante e not uguali ad uno già esistente."

				Else
					ErrorLabel.Text = "Errore in inserimento: non è stato possibile un nuovo permesso."
				End If

				ErrorLabel.Visible = True
				ExceptionsManager.TraceException(ex)

				Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)

				portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)

			End Try


		End Sub
	End Class

End Namespace