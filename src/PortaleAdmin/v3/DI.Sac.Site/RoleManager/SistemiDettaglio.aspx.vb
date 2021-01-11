Imports System
Imports System.Web.UI.WebControls
Imports DI.Sac.Admin

Public Class SistemiDettaglio
	Inherits System.Web.UI.Page

	Private Const BACKPAGE As String = "SistemiLista.aspx"
	Private ReadOnly msPAGEKEY As String = Page.GetType().BaseType.FullName
	Private mbErroreSalvataggio As Boolean = False

	Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

		Try
			If Not Page.IsPostBack Then
				If Request.QueryString("Id") = "" Then
					FormViewDettaglio.ChangeMode(FormViewMode.Insert)
					lblTitolo.Text = "Inserimento Nuovo Sistema"
					toolbar.Visible = False
					' PREIMPOSTO ATTIVO=TRUE
					Dim chkAttivo As CheckBox = FormViewDettaglio.FindControl("chkAttivo")
					chkAttivo.Checked = True
				Else
					FormViewDettaglio.ChangeMode(FormViewMode.Edit)
					toolbar.Visible = True
					lblTitolo.Text = "Dettaglio Sistema"
				End If
			Else

			End If
		Catch ex As Exception
			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Utility.ShowErrorLabel(LabelError, sErrorMessage)
		End Try
	End Sub

	Protected Sub lnkElimina_Click()
		Try
			FormViewDettaglio.DeleteItem()
		Catch ex As Exception

			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Utility.ShowErrorLabel(LabelError, sErrorMessage)

		End Try
	End Sub

#Region "FormViewDettaglio"

	Private Sub FormViewDettaglio_ItemInserting(sender As Object, e As System.Web.UI.WebControls.FormViewInsertEventArgs) Handles FormViewDettaglio.ItemInserting
		Try
			If e.Values("Erogante") = False And e.Values("Richiedente") = False Then
				e.Cancel = True
				Utility.ShowErrorLabel(LabelError, "Specificare se il sistema è di tipo Erogante o Richiedente.")
			End If
		Catch ex As Exception
			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Utility.ShowErrorLabel(LabelError, sErrorMessage)
		End Try
	End Sub

	Private Sub FormViewDettaglio_ItemUpdating(sender As Object, e As System.Web.UI.WebControls.FormViewUpdateEventArgs) Handles FormViewDettaglio.ItemUpdating
		Try
			If e.NewValues("Erogante") = False And e.NewValues("Richiedente") = False Then
				e.Cancel = True
				Utility.ShowErrorLabel(LabelError, "Specificare se il sistema è di tipo Erogante o Richiedente.")
			End If
		Catch ex As Exception
			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Utility.ShowErrorLabel(LabelError, sErrorMessage)
		End Try
	End Sub

	Private Sub FormViewDettaglio_PreRender(sender As Object, e As System.EventArgs) Handles FormViewDettaglio.PreRender
		Try
			If mbErroreSalvataggio Then
				FilterHelper.Restore(FormViewDettaglio, msPAGEKEY)
			End If
		Catch ex As Exception
			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Utility.ShowErrorLabel(LabelError, sErrorMessage)
		End Try
	End Sub

	Protected Sub FormViewDettaglio_ItemCommand(sender As Object, e As FormViewCommandEventArgs) Handles FormViewDettaglio.ItemCommand
		If e.CommandName.ToUpper = "CANCEL" Then
			Response.Redirect(BACKPAGE)
		End If
	End Sub


	Private Sub FormViewDettaglio_ItemUpdated(sender As Object, e As System.Web.UI.WebControls.FormViewUpdatedEventArgs) Handles FormViewDettaglio.ItemUpdated
		e.KeepInEditMode = True
	End Sub

	Private Sub FormViewDettaglio_ItemInserted(sender As Object, e As System.Web.UI.WebControls.FormViewInsertedEventArgs) Handles FormViewDettaglio.ItemInserted
		e.KeepInInsertMode = True
	End Sub

	Protected Sub butSalva_Click(sender As Object, e As EventArgs)
		Try
			'salvo i valori attuali perchè se c'è un errore 
			' di salvataggio li devo rileggere
			FilterHelper.SaveInSession(FormViewDettaglio, msPAGEKEY)

		Catch ex As Exception
			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Utility.ShowErrorLabel(LabelError, sErrorMessage)

		End Try
	End Sub

#End Region


#Region "ObjectDataSource"

	Private Sub ods_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsDettaglio.Selected
		ObjectDataSource_TrapError(sender, e)
	End Sub

	Private Sub ods_Inserted(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles odsDettaglio.Inserted
		If ObjectDataSource_TrapError(sender, e) Then
			mbErroreSalvataggio = True
		Else
			ObjectDataSource_DiscardCache()
			Response.Redirect(BACKPAGE)
		End If
	End Sub

	Private Sub ods_Updated(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles odsDettaglio.Updated
		If ObjectDataSource_TrapError(sender, e) Then
			mbErroreSalvataggio = True
		Else
			ObjectDataSource_DiscardCache()
			Response.Redirect(BACKPAGE)
		End If
	End Sub

	Private Sub ods_Deleted(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles odsDettaglio.Deleted
		If ObjectDataSource_TrapError(sender, e) Then
			mbErroreSalvataggio = True
		Else
			ObjectDataSource_DiscardCache()
			Response.Redirect(BACKPAGE)
		End If
	End Sub


	Protected Sub ods_Inserting(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceMethodEventArgs) Handles odsDettaglio.Inserting
		e.InputParameters("UtenteInserimento") = User.Identity.Name

	End Sub

	Protected Sub ods_Updating(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceMethodEventArgs) Handles odsDettaglio.Updating
		e.InputParameters("UtenteModifica") = User.Identity.Name
	End Sub

#End Region


#Region "Funzioni"

	''' <summary>
	''' Gestisce gli errori del ObjectDataSource in maniera pulita
	''' </summary>
	''' <returns>True se si è verificato un errore</returns>
	Private Function ObjectDataSource_TrapError(ods As ObjectDataSourceView, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) As Boolean
		Try
			If e.Exception IsNot Nothing AndAlso e.Exception.InnerException IsNot Nothing Then
				Utility.ShowErrorLabel(LabelError, GestioneErrori.TrapError(e.Exception.InnerException))
				e.ExceptionHandled = True
				Return True
			Else
				Return False
			End If
		Catch ex As Exception
			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Utility.ShowErrorLabel(LabelError, sErrorMessage)
			Return True
		End Try

	End Function

	Private Sub ObjectDataSource_DiscardCache()
		If odsDettaglio.EnableCaching Then
			Cache(msPAGEKEY) = New Object
		End If
	End Sub

    Private Sub odsRuoli_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsRuoli.Selecting
        Try
            '
            ' Passo all'OjectDataSource l'id del Sistema prendendolo dal SelectedValue della FormView 
            '
            Dim IdSistema As String = FormViewDettaglio.SelectedValue.ToString
            e.InputParameters("IdSistema") = IdSistema
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub

    Private Sub odsRuoli_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsRuoli.Selected
        ObjectDataSource_TrapError(sender, e)
    End Sub

    Private Sub lnkImpostaRuoli_Click(sender As Object, e As EventArgs) Handles lnkImpostaRuoli.Click
        Try
            '
            ' Navigo alla pagina di modifica dei ruoli di un sistema
            '
            Response.Redirect(Me.ResolveUrl(String.Format("~/RoleManager/SistemaRuoloLista.aspx?IdSistema={0}", FormViewDettaglio.SelectedValue.ToString)), True)
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try

    End Sub

    Private Sub lnkCompiaRuoli_Click(sender As Object, e As EventArgs) Handles lnkCompiaRuoli.Click
        '
        'Vado Alla pagina di selezione dei sistemi.
        '
        Response.Redirect(String.Format("RuoliCopiaDaSistema.aspx?Id={0}", Request.QueryString("Id")), False)
    End Sub
#End Region


End Class