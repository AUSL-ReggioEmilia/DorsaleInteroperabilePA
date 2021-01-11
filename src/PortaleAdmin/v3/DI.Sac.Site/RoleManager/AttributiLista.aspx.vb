Imports System
Imports System.Web.UI.WebControls
Imports DI.Sac.Admin
Imports System.Data
Imports OrganigrammaDataSetTableAdapters


Public Class AttributiLista
    Inherits System.Web.UI.Page

    Private mbODSLista_CancelSelect As Boolean = False
	Private ReadOnly msPAGEKEY As String = Page.GetType().BaseType.FullName
	Private Const BACKPAGE As String = "RuoliLista.aspx"
	Private Const ATTRIBINSERISCIPAGE As String = "AttributiInserisci.aspx"
	Private mgIDRuolo As Guid

	Private Sub Page_Load(sender As Object, e As System.EventArgs) Handles Me.Load
		Try
			If Not Page.IsPostBack Then
				FilterHelper.Restore(pannelloFiltri, msPAGEKEY)
				mgIDRuolo = New Guid(Request.QueryString("ID").ToString)

				If Not Page.IsPostBack Then
					Using ta As New RuoliTableAdapter()
						Using dt As OrganigrammaDataSet.RuoliDataTable = ta.GetData(mgIDRuolo)
							If dt.Rows.Count = 1 Then
								Dim dr As OrganigrammaDataSet.RuoliRow = dt.Rows(0)
								lblTitolo.Text = "Accessi del Ruolo: " & dr.Codice & " - " & dr.Descrizione
							Else
								Utility.ShowErrorLabel(LabelError, "Ruolo " & mgIDRuolo.ToString & " non trovato!")
							End If
						End Using
					End Using
				End If

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

#Region "ObjectDataSource"

	Private Sub odsLista_Deleted(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsLista.Deleted
		ObjectDataSource_TrapError(sender, e)
	End Sub

	Private Sub ods_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsLista.Selected
		ObjectDataSource_TrapError(sender, e)
	End Sub

	Private Sub ods_Inserted(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsLista.Inserted
		ObjectDataSource_TrapError(sender, e)
	End Sub


	Private Sub odsLista_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsLista.Selecting
		Try
			'eseguo la ricerca solo se i filtri sono a posto
			e.Cancel = mbODSLista_CancelSelect

		Catch ex As Exception
			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Utility.ShowErrorLabel(LabelError, sErrorMessage)
		End Try
	End Sub

	Private Sub odsLista_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsLista.Selected
		Try
			If e.Exception Is Nothing Then
				'tutto bene
			Else
				ExceptionsManager.TraceException(e.Exception)
				LabelError.Visible = True
				LabelError.Text = MessageHelper.GetGridViewMessage(TypeGridViewError.CaricamentoDati)
				e.ExceptionHandled = True
			End If
		Catch ex As Exception
			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Utility.ShowErrorLabel(LabelError, sErrorMessage)
			mbODSLista_CancelSelect = True
		End Try
	End Sub
#End Region

	Protected Function ValidazioneFiltri() As Boolean

		'nulla da validare
		Return True

	End Function

	Protected Sub butAnnulla_Click(sender As Object, e As EventArgs) Handles butAnnulla.Click, butAnnullaTop.Click

		Response.Redirect(BACKPAGE)

	End Sub

	Protected Sub butElimina_Click(sender As Object, e As EventArgs) Handles butElimina.Click, butEliminaTop.Click
		Try
			For Each row As GridViewRow In gvLista.Rows
				Dim chkItem As CheckBox = row.FindControl("CheckBox")
				If chkItem.Checked Then
					odsLista.DeleteParameters("Id").DefaultValue = gvLista.DataKeys(row.RowIndex).Values("Id").ToString
					odsLista.DeleteParameters("TipoAttributo").DefaultValue = gvLista.DataKeys(row.RowIndex).Values("TipoAttributo").ToString
					odsLista.Delete()
				End If
			Next
		Catch ex As Exception
			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Utility.ShowErrorLabel(LabelError, sErrorMessage)
		End Try
	End Sub

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

End Class