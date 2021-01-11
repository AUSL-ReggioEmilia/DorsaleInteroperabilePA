Imports System
Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports System.Data

Namespace DI.DataWarehouse.Admin

	Partial Class GdALista
		Inherits Page

		Private Sub DataSourceMain_Selected(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles DataSourceMain.Selected
			Try
				Dim dt = DirectCast(e.ReturnValue, AccessiDataSet.GdADataTable)
				'
				' WORKAROUND PER GRIDVIEW CHE NON MOSTRA NEANCHE GLI HEADER SE NON SONO PRESENTI RIGHE
				'
				If dt.Count = 0 Then
					For Each c As DataColumn In dt.Columns
						c.AllowDBNull = True
					Next
					Dim dr = dt.NewGdARow()
					dr.Id = Guid.Empty 'USO GUID.EMPTY PER RICONOSCERE LA RIGA E NON MOSTRARLA
					dt.AddGdARow(dr)
				End If
			Catch
			End Try
		End Sub

		Private Sub GridViewMain_RowDataBound(sender As Object, e As System.Web.UI.WebControls.GridViewRowEventArgs) Handles GridViewMain.RowDataBound
			Try
				'
				' WORKAROUND PER GRIGLIA CHE NON MOSTRA NEANCHE GLI HEADER SE NON SONO PRESENTI RIGHE
				'
				If e.Row.RowType = DataControlRowType.DataRow Then
					If GridViewMain.DataKeys(e.Row.RowIndex).Values("Id") = Guid.Empty Then
						e.Row.Visible = False
					End If
				End If
			Catch
			End Try
		End Sub

		Private Sub DataSourceMain_Inserting(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceMethodEventArgs) Handles DataSourceMain.Inserting
			Try
				e.InputParameters("UtenteInserimento") = User.Identity.Name
				Dim ddlAzienda As DropDownList = GridViewMain.FooterRow.FindControl("AziendaDropDownList")
				e.InputParameters("AziendaCodice") = ddlAzienda.SelectedValue
				Dim txtDesc As TextBox = GridViewMain.FooterRow.FindControl("TextBoxDescrizione")
				e.InputParameters("Descrizione") = txtDesc.Text

			Catch ex As Exception
				Dim sMessage As String = Utility.TrapError(ex, True)
				Utility.ShowErrorLabel(LabelError, sMessage)
			End Try
		End Sub

		Private Sub DataSourceMain_Updating(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceMethodEventArgs) Handles DataSourceMain.Updating
			e.InputParameters("UtenteModifica") = User.Identity.Name
		End Sub

		Private Sub DataSourceMain_Inserted(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles DataSourceMain.Inserted, DataSourceMain.Updated, DataSourceMain.Deleted
			ObjectDataSource_TrapError(sender, e)
		End Sub

		Protected Sub GridViewMain_RowCommand(sender As Object, e As GridViewCommandEventArgs) Handles GridViewMain.RowCommand
			Try
				' SE LA PAGINA E' VALIDATA RICHIAMO LA INSERT
				If e.CommandName = "Insert" AndAlso Page.IsValid Then
					DataSourceMain.Insert()
				End If
				' NASCONDO LA RIGA DI INSERIMENTO
				GridViewMain.ShowFooter = False

			Catch ex As Exception
				Dim sMessage As String = Utility.TrapError(ex, True)
				Utility.ShowErrorLabel(LabelError, sMessage)
			End Try
		End Sub

		Protected Sub NewButton_Click(sender As Object, e As EventArgs) Handles NewButton.Click
			GridViewMain.EditIndex = -1
			GridViewMain.ShowFooter = True
		End Sub


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

	End Class

End Namespace