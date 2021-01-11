Imports System
Imports System.Web.UI
Imports System.Web.UI.WebControls

Namespace DI.DataWarehouse.Admin

	Partial Class SottoscrizioniDettaglio
		Inherits Page

		Dim mddlAziendaSelectedIndex As Integer? = Nothing
		Dim mddlSistemaSelectedIndex As Integer? = Nothing

		Private Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
			Try
				If Not IsPostBack Then
					If Request.QueryString(Constants.Id) Is Nothing Then
						'
						' PASSO IN MODALITÀ INSERIMENTO
						'
						fwMain.ChangeMode(FormViewMode.Insert)
						' ORA IL PULSANTE SALVA DEVE INVOCARE IL METODO INSERT
						Dim butSalva As LinkButton = fwMain.FindControl("butSalva")
						If butSalva IsNot Nothing Then butSalva.CommandName = "Insert"
						Dim butElimina As LinkButton = fwMain.FindControl("butElimina")
						If butElimina IsNot Nothing Then butElimina.Visible = False

						'DISABILITO L'INSERIMENTO DEI DETTAGLI FINTANTO CHE NON HO UN RECORD DI TESTATA
						fwEditRigaDettaglio.Enabled = False
					End If

					Dim txtBox As TextBox = fwMain.FindControl("RenameAllegatoTextBox")
					If txtBox IsNot Nothing Then txtBox.Attributes.Add("readonly", "readonly")
					txtBox = fwMain.FindControl("NomeTextBox")
					If txtBox IsNot Nothing Then Page.SetFocus(txtBox)

				End If

				Page.Form.DefaultButton = hiddenbutton.UniqueID

			Catch ex As Exception
				Dim sMessage As String = Utility.TrapError(ex, True)
				Utility.ShowErrorLabel(LabelError, sMessage)
			End Try
		End Sub


#Region "FORM PRINCIPALE"

		Private Sub fwMain_Init(sender As Object, e As EventArgs) Handles fwMain.Init
			'
			' RIUSO L'EDITITEMTEMPLATE ANCHE PER L'INSERIMENTO
			'
			fwMain.InsertItemTemplate = fwMain.EditItemTemplate
		End Sub
		Private Sub DataSource_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles DataSourceMain.Selected, DataSourceSottoscrizioniDettaglio.Selected
			ObjectDataSource_TrapError(e)
		End Sub

		Private Sub DataSourceMain_Inserting(sender As Object, e As ObjectDataSourceMethodEventArgs) Handles DataSourceMain.Inserting
			e.InputParameters("UtenteInserimento") = User.Identity.Name
		End Sub

		Private Sub DataSourceMain_Inserted(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles DataSourceMain.Inserted
			Try
				' RICARICO LA STESSA PAGINA PASSANDO L'ID DEL RECORD CREATO
				Dim newID = e.OutputParameters("InsertedId")
				Response.Redirect(Page.ResolveUrl(String.Format("SottoscrizioniDettaglio.aspx?Id={0}", newID)), False)

			Catch ex As Exception
				Dim sMessage As String = Utility.TrapError(ex, True)
				Utility.ShowErrorLabel(LabelError, sMessage)
			End Try
		End Sub
		Private Sub DataSourceMain_Updating(sender As Object, e As ObjectDataSourceMethodEventArgs) Handles DataSourceMain.Updating
			e.InputParameters("UtenteModifica") = User.Identity.Name
		End Sub
		Private Sub DataSourceMain_Deleted(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles DataSourceMain.Deleted
			If Not ObjectDataSource_TrapError(e) Then
				Response.Redirect(Page.ResolveUrl("SottoscrizioniLista.aspx"), False)
			End If
		End Sub

#End Region

#Region "RIGHE DI DETTAGLIO"

		Protected Sub ddlSistemaErogante_DataBound(sender As Object, e As EventArgs)
			' RISELEZIONO IL VALORE PRECEDENTE AL POSTBACK
			Try
				If mddlSistemaSelectedIndex.HasValue Then
					DirectCast(sender, DropDownList).SelectedIndex = mddlSistemaSelectedIndex
				End If
			Catch
				'NON BLOCCO L'ESECUZIONE
			End Try
		End Sub

		Protected Sub ddlAziendaErogante_DataBound(sender As Object, e As EventArgs)
			' RISELEZIONO IL VALORE PRECEDENTE AL POSTBACK
			Try
				If mddlAziendaSelectedIndex.HasValue Then
					DirectCast(sender, DropDownList).SelectedIndex = mddlAziendaSelectedIndex
				End If
			Catch
				'NON BLOCCO L'ESECUZIONE
			End Try
		End Sub

		Private Sub DataSourceSottoscrizioniDettaglio_Inserting(sender As Object, e As ObjectDataSourceMethodEventArgs) Handles DataSourceSottoscrizioniDettaglio.Inserting
			Try
				e.InputParameters("UtenteInserimento") = User.Identity.Name

				Dim ddl = DirectCast(fwEditRigaDettaglio.FindControl("ddlSistemaErogante"), DropDownList)
				e.InputParameters("SistemaEroganteCodice") = ddl.SelectedValue
				mddlSistemaSelectedIndex = ddl.SelectedIndex

				ddl = DirectCast(fwEditRigaDettaglio.FindControl("ddlAziendaErogante"), DropDownList)
				e.InputParameters("AziendaEroganteCodice") = ddl.SelectedValue
				mddlAziendaSelectedIndex = ddl.SelectedIndex

			Catch ex As Exception
				Dim sMessage As String = Utility.TrapError(ex, True)
				Utility.ShowErrorLabel(LabelError, sMessage)
			End Try
		End Sub

		Private Sub DataSourceSottoscrizioniDettaglio_Deleted(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles DataSourceSottoscrizioniDettaglio.Deleted
			ObjectDataSource_TrapError(e)
		End Sub

#End Region


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