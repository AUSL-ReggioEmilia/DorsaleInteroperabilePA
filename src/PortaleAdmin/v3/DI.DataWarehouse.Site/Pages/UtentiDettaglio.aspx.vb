Imports System
Imports System.Web.UI
Imports System.Web.UI.WebControls

Namespace DI.DataWarehouse.Admin

	Partial Class UtentiDettaglio
		Inherits Page

		Private Const BACKPAGE As String = "UtentiLista.aspx"

		Dim mUtentiRow As Data.BackEndDataSet.UtentiRow


		Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

			Try
				If Not Page.IsPostBack Then
					FormViewDettaglio.ChangeMode(FormViewMode.Edit)
					LabelTitolo.Text = "Dettaglio Utente"
				End If
			Catch ex As Exception
				Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
				Utility.ShowErrorLabel(LabelError, sErrorMessage)
			End Try
		End Sub

		Private Sub Page_PreRenderComplete(sender As Object, e As System.EventArgs) Handles Me.PreRenderComplete
			Try
				Dim ddlRuoli As DropDownList = FormViewDettaglio.FindControl("ddlRuolo")
				LabelWarning.Visible = ddlRuoli.Items.Count = 1	'un item c'è sempre, quello vuoto ""

				If Not mUtentiRow Is Nothing AndAlso Not mUtentiRow.IsRuoloNull Then
					Dim listItem = ddlRuoli.Items.FindByValue(mUtentiRow.IdRuolo.ToString)
					If listItem IsNot Nothing Then
						listItem.Selected = True
					End If
				End If

			Catch ex As Exception
				Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
				Utility.ShowErrorLabel(LabelError, sErrorMessage)
			End Try
		End Sub

		Private Sub odsDettaglio_Selected(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles odsDettaglio.Selected
			Try
				'caricamento manuale dell'item selezionato nella ddlRuolo
				If Not ObjectDataSource_TrapError(sender, e) Then
					Dim dtUtentiRow = DirectCast(e.ReturnValue, Data.BackEndDataSet.UtentiDataTable)
					mUtentiRow = dtUtentiRow(0)
				End If
			Catch ex As Exception
				Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
				Utility.ShowErrorLabel(LabelError, sErrorMessage)
			End Try
		End Sub

		Private Sub odsRuoli_Selected(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles odsRuoli.Selected
			ObjectDataSource_TrapError(sender, e)
		End Sub


		Private Sub ods_Updated(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles odsDettaglio.Updated, odsDettaglio.Deleted
			If Not ObjectDataSource_TrapError(sender, e) Then
				Session("UtentiLista_InvalidaCache") = True	'INVALIDO LA CACHE DELLA PAGINA DI LISTA
				Response.Redirect(BACKPAGE)
			End If
		End Sub

		Private Sub FormViewDettaglio_ItemUpdated(sender As Object, e As System.Web.UI.WebControls.FormViewUpdatedEventArgs) Handles FormViewDettaglio.ItemUpdated
			e.KeepInEditMode = True
		End Sub

		Private Sub FormViewDettaglio_ItemInserted(sender As Object, e As System.Web.UI.WebControls.FormViewInsertedEventArgs) Handles FormViewDettaglio.ItemInserted
			e.KeepInInsertMode = True
		End Sub

		Protected Sub FormViewDettaglio_ItemCommand(sender As Object, e As FormViewCommandEventArgs) Handles FormViewDettaglio.ItemCommand
			If e.CommandName.ToUpper = "CANCEL" Then
				Response.Redirect(BACKPAGE)
			End If
		End Sub


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



#End Region

		Private Sub odsDettaglio_Updating(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceMethodEventArgs) Handles odsDettaglio.Updating
			Try
				Dim ddlRuoli As DropDownList = FormViewDettaglio.FindControl("ddlRuolo")

				If ddlRuoli.SelectedValue IsNot Nothing Then
					e.InputParameters("IdRuolo") = ddlRuoli.SelectedValue
				End If

			Catch ex As Exception
				Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
				Utility.ShowErrorLabel(LabelError, sErrorMessage)

			End Try

		End Sub
	End Class

End Namespace