Imports System
Imports System.Configuration
Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports DI.DataWarehouse.Admin.Data

Namespace DI.DataWarehouse.Admin

    Public Class SoleAbilitazioni
        Inherits Page

		Private mPageId As String = Me.GetType().Name


        Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load

            LabelError.Visible = False

        End Sub

		Private Sub Page_PreRenderComplete(sender As Object, e As System.EventArgs) Handles Me.PreRenderComplete
			Try
				If Not Page.IsPostBack Then
					FilterHelper.Restore(filterPanel, mPageId)
				End If
			Catch ex As Exception
				Dim sMessage As String = Utility.TrapError(ex, True)
				Utility.ShowErrorLabel(LabelError, sMessage)
			End Try
		End Sub

		Protected Sub CercaButton_Click(sender As Object, e As EventArgs) Handles CercaButton.Click

			FilterHelper.SaveInSession(filterPanel, mPageId)

		End Sub

        Private Sub AbilitazioniObjectDataSource_SAVED(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles AbilitazioniObjectDataSource.Selected, AbilitazioniObjectDataSource.Inserted, AbilitazioniObjectDataSource.Updated
            ObjectDataSource_TrapError(sender, e) 
        End Sub

        Protected Sub AbilitazioniObjectDataSource_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles AbilitazioniObjectDataSource.Selecting
			Try

				If e.InputParameters.Contains("AziendaErogante") Then
					Dim codiceAzienda As String = e.InputParameters("AziendaErogante")
					If String.IsNullOrEmpty(codiceAzienda) OrElse codiceAzienda = " " Then
						e.InputParameters("AziendaErogante") = Nothing
					End If
				End If

				If e.InputParameters.Contains("SistemaErogante") Then
					Dim codiceSistema As String = e.InputParameters("SistemaErogante")
					If String.IsNullOrEmpty(codiceSistema) OrElse codiceSistema = " " Then
						e.InputParameters("SistemaErogante") = Nothing
					End If
				End If

			Catch ex As Exception
				Dim sMessage As String = Utility.TrapError(ex, True)
				Utility.ShowErrorLabel(LabelError, sMessage)
			End Try
        End Sub

        Protected Sub AbilitazioniObjectDataSource_Updating(sender As Object, e As ObjectDataSourceMethodEventArgs) Handles AbilitazioniObjectDataSource.Updating
            Try
                e.InputParameters("DataModifica") = DateTime.Now
                e.InputParameters("UtenteModifica") = User.Identity.Name
            Catch ex As Exception
                Dim sMessage As String = Utility.TrapError(ex, True)
                Utility.ShowErrorLabel(LabelError, sMessage)
            End Try
        End Sub

        Protected Sub AbilitazioniObjectDataSource_Inserting(sender As Object, e As ObjectDataSourceMethodEventArgs) Handles AbilitazioniObjectDataSource.Inserting
			Try

				Dim aziendaErogante = DirectCast(AbilitazioniListView.InsertItem.FindControl("AziendaDropDownList"), DropDownList).SelectedValue.Trim
				Dim sistemaErogante = DirectCast(AbilitazioniListView.InsertItem.FindControl("SistemaEroganteTextBox"), TextBox).Text.Trim

				If String.IsNullOrEmpty(sistemaErogante) Then
					e.Cancel = True
					LabelError.Text = "Specificare il Sistema Erogante."
					LabelError.Visible = True
				End If

				If DataAdapterManager.GetListaAbilitazioni(aziendaErogante, sistemaErogante).Count = 0 Then

					e.InputParameters("AziendaErogante") = aziendaErogante
					e.InputParameters("SistemaErogante") = sistemaErogante

					e.InputParameters("DataModifica") = DateTime.Now
					e.InputParameters("UtenteModifica") = User.Identity.Name

					If e.InputParameters("LivelloMinimoConsenso") Is Nothing Then
						Dim bLivello As Byte? = 255
						e.InputParameters("LivelloMinimoConsenso") = bLivello
					End If
				Else
					e.Cancel = True
					LabelError.Text = String.Format("Esiste già un record per {0}-{1}", aziendaErogante, sistemaErogante)
					LabelError.Visible = True
				End If
			Catch ex As Exception
				Dim sMessage As String = Utility.TrapError(ex, True)
				Utility.ShowErrorLabel(LabelError, sMessage)
			End Try
		End Sub


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


	End Class

End Namespace