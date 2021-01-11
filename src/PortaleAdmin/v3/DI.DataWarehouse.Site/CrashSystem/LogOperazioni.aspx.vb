Imports System
Imports System.Web.UI.WebControls
Imports System.Web.UI

Public Class LogOperazioni
	Inherits Page

	Private ReadOnly msPAGEKEY As String = Page.GetType().BaseType.FullName

	Private Sub ddlSistemaErogante_DataBound(sender As Object, e As EventArgs) Handles ddlSistemaErogante.DataBound
		ddlSistemaErogante.Items.Insert(0, New ListItem("Tutti", ""))
	End Sub

	Private Sub SearchButton_Click(sender As Object, e As EventArgs) Handles SearchButton.Click
		gvLista.DataBind()
	End Sub

	Private Sub odsLista_Selecting(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceSelectingEventArgs) Handles odsLista.Selecting
		Try
			Select Case ddlFiltriPeriodo.SelectedValue
				Case "1" 'Ultima ora
					e.InputParameters("DataDal") = DateTime.UtcNow.Subtract(New TimeSpan(1, 0, 0))
				Case "2" 'Oggi
					e.InputParameters("DataDal") = DateTime.Today
				Case "3" 'Ultimi 7 Giorni
					e.InputParameters("DataDal") = DateTime.Today.AddDays(-7)
				Case "4" 'Ultimi 30 Giorni
					e.InputParameters("DataDal") = DateTime.Today.AddDays(-30)
			End Select

			'## PER DEBUG ###
			'PARAMETRO IN QUERY STRING DA USARE PER TESTARE LA PROCEDURA, NON VIENE MAI PASSATO IN URL
			Dim iNumeroOre As Integer
			If Integer.TryParse(Context.Request.QueryString("NumeroOre"), iNumeroOre) Then
				e.InputParameters("DataDal") = DateTime.UtcNow.Subtract(New TimeSpan(iNumeroOre, 0, 0))
			End If

			e.InputParameters("DataAl") = DateTime.UtcNow
			If rbtVisual.SelectedValue = "Compatta" Then
				odsLista.FilterExpression = "SottoscrizioniDettaglioId Is NULL"
			End If

		Catch ex As Exception
			Dim sMessage As String = Utility.TrapError(ex, True)
			Utility.ShowErrorLabel(LabelError, sMessage)
		End Try
	End Sub

	Private Sub gvLista_RowDataBound(sender As Object, e As System.Web.UI.WebControls.GridViewRowEventArgs) Handles gvLista.RowDataBound
		Try
			If e.Row.RowType = DataControlRowType.DataRow Then
				Dim IsDettaglio As Boolean = DataBinder.Eval(e.Row.DataItem, "SottoscrizioniDettaglioId").ToString.Length > 0
				If IsDettaglio Then
					e.Row.CssClass = "GridAlternatingItem"
				End If
			End If
		Catch
			'non trappo errori in fase di disegno della riga
		End Try
	End Sub

	Private Sub ods_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsLista.Selected
		ObjectDataSource_TrapError(sender, e)
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



#End Region

End Class