Imports System
Imports System.Web.UI
Imports System.Web.UI.WebControls

Namespace DI.DataWarehouse.Admin

	Partial Class SottoscrizioniLista
		Inherits Page

		Private mPageId As String = Me.GetType().Name

		Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load

			Page.SetFocus(CercaButton)
			Page.Form.DefaultButton = CercaButton.UniqueID

		End Sub

		Private Sub Page_PreRenderComplete(sender As Object, e As System.EventArgs) Handles Me.PreRenderComplete
			Try
				If Not Page.IsPostBack Then
					FilterHelper.Restore(Me, mPageId)
                    'rieseguo la ricerca se ho recuperato qualcosa dai filtri precedentemente impostati
                    If NomeTextBox.Text.Length > 0 Or DescrizioneTextBox.Text.Length > 0 Then
						GridViewMain.DataBind()
					End If
				End If

			Catch ex As Exception
				Dim sMessage As String = Utility.TrapError(ex, True)
				Utility.ShowErrorLabel(LabelError, sMessage)
			End Try
		End Sub

		Protected Sub CercaButton_Click(ByVal sender As Object, ByVal e As EventArgs) Handles CercaButton.Click
			Try
				FilterHelper.SaveInSession(Me, mPageId)
				GridViewMain.DataBind()
			Catch ex As Exception
				Dim sMessage As String = Utility.TrapError(ex, True)
				Utility.ShowErrorLabel(LabelError, sMessage)
			End Try
		End Sub

		Private Sub DataSourceMain_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles DataSourceMain.Selected
			ObjectDataSource_TrapError(e)
		End Sub


#Region "Funzioni"

		''' <summary>
		''' Gestisce gli errori del ObjectDataSource in maniera pulita
		''' </summary>
		''' <returns>True se si è verificato un errore</returns>
		Private Function ObjectDataSource_TrapError(e As ObjectDataSourceStatusEventArgs) As Boolean
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

End Namespace