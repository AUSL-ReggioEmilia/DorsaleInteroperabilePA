Imports System
Imports System.Web.UI.WebControls
Imports System.Data
Imports System.Web.UI

Public Class RefertiSinottico
	Inherits System.Web.UI.Page

	Private ReadOnly msPAGEKEY As String = Page.GetType().BaseType.FullName


	Private Sub Page_Load(sender As Object, e As System.EventArgs) Handles Me.Load

		gvLista.Columns(1).Visible = rbtVisual.SelectedValue = "Dettagliata"
		gvLista.Width = If(rbtVisual.SelectedValue = "Dettagliata", 800, 600)

		If Page.IsPostBack Then
			gvLista.DataBind()
		End If
	End Sub

	Private Sub gvLista_RowDataBound(sender As Object, e As System.Web.UI.WebControls.GridViewRowEventArgs) Handles gvLista.RowDataBound
		Try
			Dim IsTotale As Boolean = DataBinder.Eval(e.Row.DataItem, "IsTotale") = 1
			Dim IsSubTotale As Boolean = DataBinder.Eval(e.Row.DataItem, "IsSubTotale") = 1

			'subtotale
			If IsSubTotale And rbtVisual.SelectedValue = "Dettagliata" Then
				e.Row.CssClass = "GridAlternatingItem"
				e.Row.Font.Bold = True
				If Not IsTotale Then e.Row.Cells(1).Text = "TOTALE"
			End If

			'righe di dettaglio:
			If Not IsSubTotale And Not IsTotale Then
				'testo indentato nella prima colonna
				e.Row.Cells(0).CssClass = "Indent"
			End If

			'totale
			If IsTotale Then
				e.Row.CssClass = "GridAlternatingItem"
				e.Row.Font.Bold = True
				e.Row.Cells(0).Text = "TOTALE"
			End If
		Catch
			'non trappo errori in fase di disegno della riga
		End Try
	End Sub

	Private Sub odsLista_Selecting(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceSelectingEventArgs) Handles odsLista.Selecting
		Try
			Select Case ddlFiltriPeriodo.SelectedValue
				Case "1" 'Ultima ora
					e.InputParameters("DataDal") = DateTime.Now.Subtract(New TimeSpan(1, 0, 0))
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
				e.InputParameters("DataDal") = DateTime.Now.Subtract(New TimeSpan(iNumeroOre, 0, 0))
			End If

			e.InputParameters("DataAl") = DateTime.Now
			If rbtVisual.SelectedValue = "Compatta" Then
				odsLista.FilterExpression = "IsSubTotale=1"
			End If

		Catch ex As Exception
			Dim sMessage As String = Utility.TrapError(ex, True)
			Utility.ShowErrorLabel(LabelError, sMessage)
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