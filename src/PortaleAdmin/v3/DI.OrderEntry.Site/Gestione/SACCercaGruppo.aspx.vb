Imports System
Imports System.Web.UI.WebControls
Imports System.Collections.Generic

Public Class SACCercaGruppo
	Inherits Web.UI.Page

	Private listaErrori As List(Of String) = New List(Of String)

	Private ReadOnly msPAGEKEY As String = Page.GetType().BaseType.FullName
	Const BACKPAGE = "ListaUtenti.aspx"

	Private Sub Page_Load(sender As Object, e As System.EventArgs) Handles Me.Load
		If Not Page.IsPostBack Then
			FilterHelper.Restore(pannelloFiltri, msPAGEKEY)
		End If
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
			Utils.ShowErrorLabel(LabelError, sErrorMessage)
		End Try

	End Sub

	Private Sub odsLista_Selecting(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceSelectingEventArgs) Handles odsLista.Selecting
		e.Cancel = (Not Page.IsPostBack And txtFiltriUtente.Text.Length = 0 And txtFiltriDescrizione.Text.Length = 0)
		gvLista.EmptyDataText = If(Page.IsPostBack, "Nessun risultato!", "Impostare i filtri e premere Cerca.")
	End Sub

	Private Sub odsLista_Inserted(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles odsLista.Inserted
		If Not ObjectDataSource_TrapError(sender, e) Then

		End If
	End Sub

	Protected Function ValidazioneFiltri() As Boolean

		'nulla da validare
		Return True

	End Function


#Region "Funzioni"

	''' <summary>
	''' Gestisce gli errori del ObjectDataSource in maniera pulita
	''' </summary>
	''' <returns>True se si è verificato un errore</returns>
	Private Function ObjectDataSource_TrapError(ods As ObjectDataSourceView, e As ObjectDataSourceStatusEventArgs) As Boolean
		Try
			If e.Exception IsNot Nothing AndAlso e.Exception.InnerException IsNot Nothing Then
				Utils.ShowErrorLabel(LabelError, GestioneErrori.TrapError(e.Exception.InnerException))
				e.ExceptionHandled = True
				Return True
			Else
				Return False
			End If
		Catch ex As Exception
			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Utils.ShowErrorLabel(LabelError, sErrorMessage)
			Return True
		End Try

	End Function

	Protected Sub btnAggiungi_Click(sender As Object, e As EventArgs)
		Dim tempString As String = String.Empty
		For Each row As GridViewRow In gvLista.Rows
			If (row.RowType = DataControlRowType.DataRow) Then
				Dim checkBox As CheckBox = CType(row.FindControl("Checkbox"), CheckBox)
				If checkBox.Checked Then
					Try
						tempString = gvLista.DataKeys(row.RowIndex).Values("Gruppo").ToString
						odsLista.InsertParameters("Utente").DefaultValue = tempString
						odsLista.InsertParameters("Descrizione").DefaultValue = gvLista.DataKeys(row.RowIndex).Values("Descrizione").ToString
						odsLista.InsertParameters("Attivo").DefaultValue = "True"
						odsLista.InsertParameters("Delega").DefaultValue = "0"
						odsLista.InsertParameters("Tipo").DefaultValue = "1" '0:utente  1:gruppo
						odsLista.Insert()
					Catch ex As Exception
						divErrore.InnerHtml = divErrore.InnerHtml & "<br>" & tempString
						listaErrori.Add(tempString)
					End Try
				End If
			End If
		Next
		If listaErrori.Count < 1 Then
			Response.Redirect(BACKPAGE)
		Else
			divErrore.Visible = True
		End If
	End Sub

#End Region

End Class