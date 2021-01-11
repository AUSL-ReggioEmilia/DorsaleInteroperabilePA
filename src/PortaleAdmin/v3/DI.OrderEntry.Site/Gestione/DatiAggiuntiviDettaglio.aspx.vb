Imports System
Imports System.Web.UI.WebControls
Imports DI.Common
Imports DI.OrderEntry.Admin

Public Class DatiAggiuntiviDettaglio
	Inherits System.Web.UI.Page

	Private Const BACKPAGE As String = "DatiAggiuntiviLista.aspx"
	Private ReadOnly msPAGEKEY As String = Page.GetType().BaseType.FullName
	Private mbErroreSalvataggio As Boolean = False

	Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
		Try
			If Not Page.IsPostBack Then
				If String.IsNullOrEmpty(Request.QueryString("Nome")) Then
					FormViewDettaglio.ChangeMode(FormViewMode.Insert)
					LabelTitolo.Text = "Inserimento Dato Aggiuntivo"
				Else
					FormViewDettaglio.ChangeMode(FormViewMode.Edit)
					LabelTitolo.Text = "Dettaglio Dato Aggiuntivo"
				End If
			End If
		Catch ex As Exception
			ExceptionsManager.TraceException(ex)
			Utils.ShowErrorLabel(LabelError, ex.Message)
		End Try
	End Sub

	Private Sub FormViewDettaglio_PreRender(sender As Object, e As System.EventArgs) Handles FormViewDettaglio.PreRender
		Try
			If mbErroreSalvataggio Then
				FilterHelper.Restore(FormViewDettaglio, msPAGEKEY)
			End If
		Catch ex As Exception
			ExceptionsManager.TraceException(ex)
			Utils.ShowErrorLabel(LabelError, ex.Message)
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
			ExceptionsManager.TraceException(ex)
			Utils.ShowErrorLabel(LabelError, ex.Message)
		End Try
	End Sub

#Region "ObjectDataSource"

	Private Sub ods_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsDettagli.Selected
		ObjectDataSource_TrapError(sender, e)
	End Sub

	Private Sub odsDettagli_Inserted(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles odsDettagli.Inserted
		If ObjectDataSource_TrapError(sender, e) Then
			mbErroreSalvataggio = True
		Else
			Response.Redirect(BACKPAGE)
		End If
	End Sub

	Private Sub ods_Updated(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles odsDettagli.Updated
		If ObjectDataSource_TrapError(sender, e) Then
			mbErroreSalvataggio = True
		Else
			Response.Redirect(BACKPAGE)
		End If
	End Sub

	Private Sub odsDettagli_Deleted(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles odsDettagli.Deleted
		If ObjectDataSource_TrapError(sender, e) Then
			mbErroreSalvataggio = True
		Else
			Response.Redirect(BACKPAGE)
		End If
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
				ExceptionsManager.TraceException(e.Exception.InnerException)
				Utils.ShowErrorLabel(LabelError, e.Exception.InnerException.Message)
				e.ExceptionHandled = True
				Return True
			Else
				Return False
			End If
		Catch ex As Exception
			ExceptionsManager.TraceException(ex)
			Utils.ShowErrorLabel(LabelError, ex.Message)
			Return True
		End Try

	End Function

	Private Sub ObjectDataSource_DiscardCache()
		If odsDettagli.EnableCaching Then
			Cache(msPAGEKEY) = New Object
		End If
	End Sub


#End Region

End Class