Imports System
Imports System.Web.UI.WebControls
Imports DI.Sac.Admin
Imports System.Data
Imports OrganigrammaDataSetTableAdapters
Imports DI.Sac.Admin.Data.UtentiDataSetTableAdapters
Imports DI.Sac.Admin.Data.UtentiDataSet


Public Class UtentiSQLAggiungiLista
	Inherits System.Web.UI.Page

	Private Const BACKPAGE As String = "UtentiLista.aspx"
	Private ReadOnly msPAGEKEY As String = Page.GetType().BaseType.FullName

	Private Sub Page_Load(sender As Object, e As System.EventArgs) Handles Me.Load

		Try
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
			If ValidazioneFiltri() Then
				FilterHelper.SaveInSession(pannelloFiltri, msPAGEKEY)
				Cache.Remove(odsLista.CacheKeyDependency)
				gvLista.PageIndex = 0
			End If

		Catch ex As Exception
			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Utility.ShowErrorLabel(LabelError, sErrorMessage)
		End Try

	End Sub

	Protected Sub butChiudi_Click(sender As Object, e As EventArgs) Handles butAnnulla.Click, butAnnullaTop.Click
		Response.Redirect(BACKPAGE)
	End Sub

	Private Sub ods_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsLista.Selected
		ObjectDataSource_TrapError(sender, e)
	End Sub

	Protected Function ValidazioneFiltri() As Boolean

		'nulla da validare
		Return True

	End Function

	Protected Sub chkboxSelectAll_CheckedChanged(ByVal sender As Object, ByVal e As EventArgs)
		Try
			Dim ChkBoxHeader As CheckBox = CType(gvLista.HeaderRow.FindControl("chkboxSelectAll"), CheckBox)
			For Each row As GridViewRow In gvLista.Rows
				CType(row.FindControl("CheckBox"), CheckBox).Checked = ChkBoxHeader.Checked
			Next
		Catch ex As Exception
			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Utility.ShowErrorLabel(LabelError, sErrorMessage)
		End Try
	End Sub


	Protected Sub butConfermaTop_Click(sender As Object, e As EventArgs) Handles butConferma.Click, butConfermaTop.Click
		Dim iNumChecked As Integer = 0
		Dim iErrori As Integer = 0
		Try
			For Each row As GridViewRow In gvLista.Rows
				If DirectCast(row.FindControl("CheckBox"), CheckBox).Checked Then
					iNumChecked += 1
					Dim sUtente As String = gvLista.DataKeys(row.RowIndex).Values("Name")
					Dim sDesc As String = Utility.StringEmptyDBNullToNothing(gvLista.DataKeys(row.RowIndex).Values("Type_Desc"))
					If Not Add(sUtente, sDesc, Nothing, Nothing, 0) Then
						iErrori += 1
					End If
				End If
			Next
			If iErrori = 0 Then
				If iNumChecked > 0 Then
					Response.Redirect(BACKPAGE)
				ElseIf iNumChecked = 0 Then
					Utility.ShowErrorLabel(LabelError, "Selezionare i membri da aggiungere.")
				End If
			End If

		Catch ex As Exception
			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Utility.ShowErrorLabel(LabelError, sErrorMessage)
		End Try
	End Sub


	Protected Function Add(ByVal utente As String, ByVal descrizione As String, ByVal dipartimentale As String, ByVal emailResponsabile As String, ByVal disattivato As Byte?) As Boolean
		Try
			Using adapter As New UtentiTableAdapter()

				Dim dt As UtentiDataTable = adapter.GetData(utente)
				If dt.Rows.Count > 0 Then
					' Update
					Dim oRow As UtentiRow = dt(0)
					If Not oRow.IsDipartimentaleNull() Then dipartimentale = oRow.Dipartimentale
					If Not oRow.IsEmailResponsabileNull() Then emailResponsabile = oRow.EmailResponsabile
					disattivato = oRow.Disattivato
					adapter.Update(utente, descrizione, dipartimentale, emailResponsabile, disattivato)
				Else
					adapter.Insert(utente, descrizione, dipartimentale, emailResponsabile, disattivato)
				End If
			End Using
			Return True
		Catch ex As Exception
			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Utility.ShowErrorLabel(LabelError, sErrorMessage)
			Return False
		End Try
	End Function


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

#End Region




End Class