Imports System
Imports System.Web.UI.WebControls
Imports System.Data

Public Class UtentiSACAggiungiLista
	Inherits System.Web.UI.Page

	Private ReadOnly msPAGEKEY As String = Page.GetType().BaseType.FullName
	Private Const BACKPAGE As String = "UtentiLista.aspx"
	Private Const DETTAGLIOPAGE As String = "UtentiDettaglio.aspx?Id={0}"
	Private sIDUtente As String

	Private Sub Page_Load(sender As Object, e As System.EventArgs) Handles Me.Load
		Try
			Page.Form.DefaultButton = butFiltriRicerca.UniqueID
			If Not Page.IsPostBack Then
				FilterHelper.Restore(pannelloFiltri, msPAGEKEY)
			End If

		Catch ex As Exception
			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Utility.ShowErrorLabel(LabelError, sErrorMessage)
		End Try
	End Sub

	Protected Sub RicercaButton_Click(sender As Object, e As EventArgs) Handles butFiltriRicerca.Click
		Try
			LabelError.Visible = False

			FilterHelper.SaveInSession(pannelloFiltri, msPAGEKEY)
			ObjectDataSource_InvalidaCache(odsLista)
			gvLista.DataBind()

		Catch ex As Exception
			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Utility.ShowErrorLabel(LabelError, sErrorMessage)
		End Try

	End Sub

	Private Sub odsLista_Selected(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles odsLista.Selected
		ObjectDataSource_TrapError(sender, e)
	End Sub

	Private Sub gvLista_RowCommand(sender As Object, e As System.Web.UI.WebControls.GridViewCommandEventArgs) Handles gvLista.RowCommand
		Try
			If e.CommandName.ToUpper = "INSERT" Then
				Dim iRowIndex As Integer = e.CommandArgument
				sIDUtente = gvLista.DataKeys(iRowIndex).Values("Id").ToString
				odsLista.InsertParameters("Id").DefaultValue = sIDUtente
				odsLista.InsertParameters("Utente").DefaultValue = gvLista.DataKeys(iRowIndex).Values("Utente").ToString
				odsLista.InsertParameters("Descrizione").DefaultValue = Utility.IsNull(gvLista.DataKeys(iRowIndex).Values("Descrizione").ToString, String.Empty)
				odsLista.Insert()
			End If
		Catch ex As Exception
			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Utility.ShowErrorLabel(LabelError, sErrorMessage)
		End Try
	End Sub

	Private Sub odsLista_Inserted(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles odsLista.Inserted
		If Not ObjectDataSource_TrapError(sender, e) Then
			Response.Redirect(String.Format(DETTAGLIOPAGE, sIDUtente))
		End If
	End Sub

	Protected Sub butAnnullaTop_Click(sender As Object, e As EventArgs) Handles butAnnullaTop.Click, butAnnulla.Click
		Response.Redirect(BACKPAGE)
	End Sub

#Region "Funzioni"

	''' <summary>
	''' Gestisce gli errori del ObjectDataSource in maniera pulita
	''' </summary>
	''' <returns>True se si è verificato un errore</returns>
	Private Function ObjectDataSource_TrapError(ods As ObjectDataSourceView, e As ObjectDataSourceStatusEventArgs) As Boolean
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


	Private Sub ObjectDataSource_InvalidaCache(ods As ObjectDataSource)
		Dim sCacheKeyDependency As String
		If ods.EnableCaching Then
			sCacheKeyDependency = ods.CacheKeyDependency
			If Not String.IsNullOrEmpty(sCacheKeyDependency) Then
				System.Web.HttpContext.Current.Cache(sCacheKeyDependency) = New Object
			End If
		End If
	End Sub

#End Region

	
End Class