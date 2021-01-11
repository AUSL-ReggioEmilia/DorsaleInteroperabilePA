Imports System
Imports System.Web.UI
Imports System.Web.UI.WebControls

Namespace DI.OrderEntry.Admin

	Public Class SimulazioneEnnuple
		Inherits Page

		Private ReadOnly msPAGEKEY As String = Page.GetType().BaseType.FullName
		Private Const PageSessionIdPrefix As String = "Simulazione_"

		Private Sub SimulazioneEnnuple_PreRenderComplete(sender As Object, e As EventArgs) Handles Me.PreRenderComplete

			If Not Page.IsPostBack Then

				FilterHelper.Restore(filterPanel, msPAGEKEY)

				If UtenteFiltroTextBox.Text.Length = 0 Then UtenteFiltroTextBox.Text = My.User.Name
				If DataFiltroTextBox.Text.Length = 0 Then DataFiltroTextBox.Text = String.Format("{0:dd/MM/yyyy HH:mm}", Date.Now)

				EnnupleInteressateRepeater.DataBind()
				SimulazioneEnnupleGridView.DataBind()
			End If

			EnnupleInteressate.Visible = Page.IsPostBack

		End Sub

		Protected Sub CercaButton_Click(sender As Object, e As EventArgs) Handles CercaButton.Click

			FilterHelper.SaveInSession(filterPanel, msPAGEKEY)
			EnnupleInteressateRepeater.DataBind()
			SimulazioneEnnupleGridView.DataBind()

		End Sub

		Protected Sub SimulazioneEnnupleObjectDataSource_Selecting(sender As Object, e As ObjectDataSourceMethodEventArgs) Handles SimulazioneEnnupleObjectDataSource.Selecting

			If e.InputParameters("nomeUtente") Is Nothing OrElse e.InputParameters("idSistemaErogante") Is Nothing Then
				e.Cancel = True
				Exit Sub
			End If

			If e.InputParameters("giorno") Is Nothing Then
				e.InputParameters("giorno") = DateTime.Now
			End If

			If String.IsNullOrEmpty(e.InputParameters("prestazioneCodiceDescrizione")) Then
				e.InputParameters("prestazioneCodiceDescrizione") = Nothing
			End If

			If String.IsNullOrEmpty(e.InputParameters("idSistemaErogante")) Then
				e.InputParameters("idSistemaErogante") = Nothing
			End If

		End Sub

		Private Sub EnnupleInteressateObjectDataSource_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles EnnupleInteressateObjectDataSource.Selecting
			If e.InputParameters("nomeUtente") Is Nothing Then
				e.Cancel = True
				Exit Sub
			End If
		End Sub

	End Class

End Namespace
