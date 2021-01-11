Imports System
Imports System.Configuration
Imports System.Web
Imports System.Web.Services
Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports DI.OrderEntry.Admin
Imports DI.OrderEntry.Admin.Data
Imports DI.PortalAdmin.Data

Public Class EnnupleDatiAccessori
	Inherits System.Web.UI.Page

	Private Const PageSessionIdPrefix As String = "EnnupleDatiAccessori_"
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

	Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
		If Not Page.IsPostBack Then

			EnnupleListView.Sort(SortExpression, SortDirection)
		Else
			SaveFilters()
		End If

		LoadFilters()
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

	Public Sub SaveButton_Click()
		ErrorLabel.Visible = False
		ErrorLabel.Text = ""

		Dim id As Guid? = Nothing
		If Not Me.EnnuplaDetail_IdHiddenField.Value Is Nothing AndAlso Not String.IsNullOrEmpty(Me.EnnuplaDetail_IdHiddenField.Value.ToString) Then
			id = New Guid(Me.EnnuplaDetail_IdHiddenField.Value.ToString)
		End If

		Dim inverso = Me.EnnuplaDetail_NotCheckBox.Checked

		Dim idStato = If(Me.EnnuplaDetail_StatoDropDownList.SelectedValue Is Nothing OrElse String.IsNullOrEmpty(Me.EnnuplaDetail_StatoDropDownList.SelectedValue.ToString), Nothing, Me.EnnuplaDetail_StatoDropDownList.SelectedValue.ToString)

		Dim descrizione = Me.EnnuplaDetail_DescrizioneTextBox.Text

		Dim note = Me.EnnuplaDetail_NoteTextBox.Text

		Dim codiceDatoAccessori As String = Nothing
		If Not Me.EnnuplaDetail_DatiAccessoriDropDownList.SelectedValue Is Nothing AndAlso Not String.IsNullOrEmpty(Me.EnnuplaDetail_DatiAccessoriDropDownList.SelectedValue.ToString) Then
			codiceDatoAccessori = Me.EnnuplaDetail_DatiAccessoriDropDownList.SelectedValue.ToString
		End If

		Dim idGruppoUtenti As Guid? = Nothing
		If Not Me.EnnuplaDetail_GruppoUtentiDropDownList.SelectedValue Is Nothing AndAlso Not String.IsNullOrEmpty(Me.EnnuplaDetail_GruppoUtentiDropDownList.SelectedValue.ToString) Then
			idGruppoUtenti = New Guid(Me.EnnuplaDetail_GruppoUtentiDropDownList.SelectedValue.ToString)
		End If

		Dim orarioInizio As TimeSpan? = Nothing
		Dim orarioFine As TimeSpan? = Nothing

		If Me.EnnuplaDetail_OraInizioTextBox.Text.Length > 0 Then orarioInizio = TimeSpan.Parse(Me.EnnuplaDetail_OraInizioTextBox.Text)
		If Me.EnnuplaDetail_OraFineTextBox.Text.Length > 0 Then orarioFine = TimeSpan.Parse(Me.EnnuplaDetail_OraFineTextBox.Text)

		Dim lunedi = Me.EnnuplaDetail_LunediCheckBox.Checked
		Dim martedi = Me.EnnuplaDetail_MartediCheckBox.Checked
		Dim mercoledi = Me.EnnuplaDetail_MercolediCheckBox.Checked
		Dim giovedi = Me.EnnuplaDetail_GiovediCheckBox.Checked
		Dim venerdi = Me.EnnuplaDetail_VenerdiCheckBox.Checked
		Dim sabato = Me.EnnuplaDetail_SabatoCheckBox.Checked
		Dim domenica = Me.EnnuplaDetail_DomenicaCheckBox.Checked

		Dim idUnitaOperativa As Guid? = Nothing
		If Not Me.EnnuplaDetail_UnitaOperativaDropDownList.SelectedValue Is Nothing AndAlso Not String.IsNullOrEmpty(Me.EnnuplaDetail_UnitaOperativaDropDownList.SelectedValue.ToString) Then
			idUnitaOperativa = New Guid(Me.EnnuplaDetail_UnitaOperativaDropDownList.SelectedValue.ToString)
		End If

		Dim idSistemaRichiedente As Guid? = Nothing
		If Not Me.EnnuplaDetail_SistemaRichiedenteDropDownList.SelectedValue Is Nothing AndAlso Not String.IsNullOrEmpty(Me.EnnuplaDetail_SistemaRichiedenteDropDownList.SelectedValue.ToString) Then
			idSistemaRichiedente = New Guid(Me.EnnuplaDetail_SistemaRichiedenteDropDownList.SelectedValue.ToString)
		End If

		Dim idRegime As String = Nothing
		If Not Me.EnnuplaDetail_RegimeDropDownList.SelectedValue Is Nothing AndAlso Not String.IsNullOrEmpty(Me.EnnuplaDetail_RegimeDropDownList.SelectedValue.ToString) Then
			idRegime = Me.EnnuplaDetail_RegimeDropDownList.SelectedValue.ToString
		End If

		Dim idPriorita As String = Nothing
		If Not Me.EnnuplaDetail_PrioritaDropDownList.SelectedValue Is Nothing AndAlso Not String.IsNullOrEmpty(Me.EnnuplaDetail_PrioritaDropDownList.SelectedValue.ToString) Then
			idPriorita = Me.EnnuplaDetail_PrioritaDropDownList.SelectedValue.ToString
		End If

		' CONTROLLO PER NON LASCIAR INSERIRE UN'ENNUPLA CON (NOT + TUTTI + TUTTI + TUTTI ...)
		If inverso And
		 idGruppoUtenti.HasValue = False _
		 And String.IsNullOrEmpty(codiceDatoAccessori) = True _
		 And idUnitaOperativa.HasValue = False _
		 And idSistemaRichiedente.HasValue = False _
		 And idRegime Is Nothing _
		 And idPriorita Is Nothing Then
			ErrorLabel.Visible = True
			ErrorLabel.Text = "Non è possibile inserire un'Ennupla che neghi l'accesso a tutti i dati accessori."
			Return
		End If

		Try
			Using uiEnnupleDatiAccessoriListTableAdapter As New DI.OrderEntry.Admin.Data.EnnupleTableAdapters.UiEnnupleDatiAccessoriListTableAdapter()

				If id.HasValue AndAlso id.Value <> Guid.Empty Then
					'modifica
					uiEnnupleDatiAccessoriListTableAdapter.Update(id, My.User.Name, idGruppoUtenti, codiceDatoAccessori, descrizione, orarioInizio, orarioFine, lunedi, martedi, mercoledi, giovedi, venerdi, sabato, domenica, idUnitaOperativa, idSistemaRichiedente, idRegime, idPriorita, inverso, idStato, note)
				Else
					'inserimento
					uiEnnupleDatiAccessoriListTableAdapter.Insert(My.User.Name, idGruppoUtenti, codiceDatoAccessori, descrizione, orarioInizio, orarioFine, lunedi, martedi, mercoledi, giovedi, venerdi, sabato, domenica, idUnitaOperativa, idSistemaRichiedente, idRegime, idPriorita, inverso, idStato, note)
				End If

			End Using

			Me.EnnupleListView.DataBind()

		Catch ex As Exception

			If ex.Message.Contains("duplicate") Then
				ErrorLabel.Text = "Errore in inserimento: non è stato possibile un nuovo permesso in quanto contiene i valori uguali ad uno già esistente."
			Else
				ErrorLabel.Text = "Errore in inserimento: non è stato possibile un nuovo permesso."
			End If

			ErrorLabel.Visible = True
			ExceptionsManager.TraceException(ex)

			Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)

			portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)

		End Try

	End Sub

	Protected Sub EnnupleObjectDataSource_Selecting(sender As Object, e As ObjectDataSourceMethodEventArgs) Handles EnnupleObjectDataSource.Selecting

		If Not Page.IsPostBack AndAlso Not Me.FilterLoaded Then
			e.Cancel = True
		End If
	End Sub

	Protected Sub EnnupleObjectDataSource_Inserting(sender As Object, e As ObjectDataSourceMethodEventArgs) Handles EnnupleObjectDataSource.Inserting

		e.InputParameters("UtenteInserimento") = My.User.Name

		Dim idUo = DirectCast(EnnupleListView.InsertItem.FindControl("UnitaOperativaDropDownList"), DropDownList).SelectedValue
		Dim idSistemaRichiedente = DirectCast(EnnupleListView.InsertItem.FindControl("SistemaRichiedenteDropDownList"), DropDownList).SelectedValue
		Dim codiceRegime = DirectCast(EnnupleListView.InsertItem.FindControl("RegimeDropDownList"), DropDownList).SelectedValue
		Dim codicePriorita = DirectCast(EnnupleListView.InsertItem.FindControl("PrioritaDropDownList"), DropDownList).SelectedValue
		Dim idStato = DirectCast(EnnupleListView.InsertItem.FindControl("StatoDropDownList"), DropDownList).SelectedValue

		Dim Lunedi = DirectCast(EnnupleListView.InsertItem.FindControl("LunediCheckBox"), CheckBox).Checked
		Dim Martedi = DirectCast(EnnupleListView.InsertItem.FindControl("MartediCheckBox"), CheckBox).Checked
		Dim Mercoledi = DirectCast(EnnupleListView.InsertItem.FindControl("MercolediCheckBox"), CheckBox).Checked
		Dim Giovedi = DirectCast(EnnupleListView.InsertItem.FindControl("GiovediCheckBox"), CheckBox).Checked
		Dim Venerdi = DirectCast(EnnupleListView.InsertItem.FindControl("VenerdiCheckBox"), CheckBox).Checked
		Dim Sabato = DirectCast(EnnupleListView.InsertItem.FindControl("SabatoCheckBox"), CheckBox).Checked
		Dim Domenica = DirectCast(EnnupleListView.InsertItem.FindControl("DomenicaCheckBox"), CheckBox).Checked

		Dim orarioInizio = DirectCast(EnnupleListView.InsertItem.FindControl("OrarioInizioTextBox"), TextBox).Text
		Dim orarioFine = DirectCast(EnnupleListView.InsertItem.FindControl("OrarioFineTextBox"), TextBox).Text

		If idUo.Length > 0 Then e.InputParameters("IDUnitaOperativa") = idUo
		If idSistemaRichiedente.Length > 0 Then e.InputParameters("IDSistemaRichiedente") = idSistemaRichiedente
		If codiceRegime.Length > 0 Then e.InputParameters("CodiceRegime") = codiceRegime
		If codicePriorita.Length > 0 Then e.InputParameters("CodicePriorita") = codicePriorita
		If idStato.Length > 0 Then e.InputParameters("IDStato") = idStato

		e.InputParameters("Lunedi") = Lunedi
		e.InputParameters("Martedi") = Martedi
		e.InputParameters("Mercoledi") = Mercoledi
		e.InputParameters("Giovedi") = Giovedi
		e.InputParameters("Venerdi") = Venerdi
		e.InputParameters("Sabato") = Sabato
		e.InputParameters("Domenica") = Domenica

		If orarioInizio.Length > 0 Then e.InputParameters("OrarioInizio") = TimeSpan.Parse(orarioInizio)
		If orarioFine.Length > 0 Then e.InputParameters("OrarioFine") = TimeSpan.Parse(orarioFine)
	End Sub

	Protected Sub EnnupleObjectDataSource_Updating(sender As Object, e As ObjectDataSourceMethodEventArgs) Handles EnnupleObjectDataSource.Updating

		e.InputParameters("UtenteModifica") = My.User.Name

		Dim orarioInizio = DirectCast(EnnupleListView.EditItem.FindControl("OrarioInizioTextBox"), TextBox).Text
		Dim orarioFine = DirectCast(EnnupleListView.EditItem.FindControl("OrarioFineTextBox"), TextBox).Text

		If orarioInizio.Length > 0 Then e.InputParameters("OrarioInizio") = TimeSpan.Parse(orarioInizio)
		If orarioFine.Length > 0 Then e.InputParameters("OrarioFine") = TimeSpan.Parse(orarioFine)
	End Sub

	Protected Sub EnnupleListView_Sorted(sender As Object, e As EventArgs) Handles EnnupleListView.Sorted

		Me.SortExpression = EnnupleListView.SortExpression
		Me.SortDirection = EnnupleListView.SortDirection
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

		'If e.CommandName = "Copy" Then

		'    Dim id = New Guid(e.CommandArgument.ToString())

		'    DataAdapterManager.CopiaEnnupla(id, My.User.Name)

		'    Response.Redirect(Request.RawUrl)
		'End If

		If e.CommandName = "Elimina" Then

			Dim id = New Guid(e.CommandArgument.ToString())

			Using uiEnnupleDatiAccessoriListTableAdapter As New DI.OrderEntry.Admin.Data.EnnupleTableAdapters.UiEnnupleDatiAccessoriListTableAdapter()

				'modifica
				uiEnnupleDatiAccessoriListTableAdapter.Delete(id)

			End Using

			Me.EnnupleListView.DataBind()

			'DataAdapterManager.EliminaEnnupla(id)
			'Response.Redirect(Request.RawUrl)
		End If
	End Sub

	Protected Sub CercaButton_Click(sender As Object, e As EventArgs) Handles CercaButton.Click
		Me.EnnupleListView.DataBind()
	End Sub
End Class