Imports System
Imports System.Web.UI.WebControls
Imports System.Data
Imports DI.OrderEntry.Admin

Public Class MonitoraggioUltimiArrivi
	Inherits System.Web.UI.Page

	Private ReadOnly msPAGEKEY As String = Page.GetType().BaseType.FullName

	Private Sub ods_Selecting(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceSelectingEventArgs) Handles odsRicevuti.Selecting, odsErogati.Selecting
		Try
			'PARAMETRO IN QUERY STRING DA USARE PER TESTARE LA PROCEDURA, NON VIENE MAI PASSATO IN URL
			Dim iNumeroOre As Integer
			If Integer.TryParse(Context.Request.QueryString("NumeroOre"), iNumeroOre) Then
				e.InputParameters("NumeroOre") = iNumeroOre
			End If
		Catch ex As Exception
			Utils.ShowErrorLabel(LabelError, GestioneErrori.TrapError(ex))
		End Try
	End Sub

	Private Sub ods_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsRicevuti.Selected, odsErogati.Selected
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

#End Region


End Class