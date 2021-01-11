Imports System
Imports System.Web.UI.WebControls
Imports DI.Sac.Admin

Public Class RuoliDettaglio
    Inherits System.Web.UI.Page

	Private Const BACKPAGE As String = "RuoliLista.aspx"
	Private ReadOnly msPAGEKEY As String = Page.GetType().BaseType.FullName
	Private mbErroreSalvataggio As Boolean = False

	Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
		Try
			If Not Page.IsPostBack Then
				If String.IsNullOrEmpty(Request.QueryString("Id")) Then
					FormViewDettaglio.ChangeMode(FormViewMode.Insert)
					lblTitolo.Text = "Inserimento Nuovo Ruolo"
					toolbar.Visible = False
					lblTitoloMembri.Visible = False
					gvListaMembri.Visible = False

					'' RECUPERO LE INFORMAZIONI DEL RUOLO DA COPIARE
					If Not String.IsNullOrEmpty(Request.QueryString("IdRuoloDaCopiare")) Then
						Using ta As New OrganigrammaDataSetTableAdapters.RuoliTableAdapter
							Dim mID As Guid = New Guid(Request.QueryString("IdRuoloDaCopiare"))
							Dim dt = ta.GetData(mID)
							If dt.Rows.Count = 1 Then
								Dim txt As TextBox = FormViewDettaglio.FindControl("txtDescrizione")
								txt.Text = "Copia di " & dt(0).Descrizione
								lblTitolo.Text = String.Format("Inserimento Nuovo Ruolo (Copia di {0} - {1})", dt(0).Codice, dt(0).Descrizione)
							Else
								Throw New ApplicationException("Ruolo da copiare non trovato")
							End If
						End Using
					End If
				Else
					FormViewDettaglio.ChangeMode(FormViewMode.Edit)
					lblTitolo.Text = "Dettaglio Ruolo"
					'toolbar.Visible = True
				End If
			Else

			End If
		Catch ex As Exception
			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Utility.ShowErrorLabel(LabelError, sErrorMessage)
		End Try
	End Sub

	Protected Sub lnkElimina_Click()
		Try
			FormViewDettaglio.DeleteItem()
		Catch ex As Exception

			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Utility.ShowErrorLabel(LabelError, sErrorMessage)
		End Try
	End Sub


#Region "FormViewDettaglio"

	Private Sub FormViewDettaglio_PreRender(sender As Object, e As System.EventArgs) Handles FormViewDettaglio.PreRender
		Try
			If mbErroreSalvataggio Then
				FilterHelper.Restore(FormViewDettaglio, msPAGEKEY)
			End If
		Catch ex As Exception
			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Utility.ShowErrorLabel(LabelError, sErrorMessage)
		End Try
	End Sub

	Protected Sub FormViewDettaglio_ItemCommand(sender As Object, e As FormViewCommandEventArgs) Handles FormViewDettaglio.ItemCommand
		If e.CommandName.ToUpper = "CANCEL" Then
			Response.Redirect(BACKPAGE)
		End If
	End Sub

	Private Sub FormViewDettaglio_ItemUpdated(sender As Object, e As System.Web.UI.WebControls.FormViewUpdatedEventArgs) Handles FormViewDettaglio.ItemUpdated
		e.KeepInEditMode = True
	End Sub

	Private Sub FormViewDettaglio_ItemInserted(sender As Object, e As System.Web.UI.WebControls.FormViewInsertedEventArgs) Handles FormViewDettaglio.ItemInserted
		e.KeepInInsertMode = True
	End Sub

	Protected Sub butSalva_Click(sender As Object, e As EventArgs)
		Try
			'salvo i valori attuali perchè se c'è un errore 
			' di salvataggio li devo rileggere
			FilterHelper.SaveInSession(FormViewDettaglio, msPAGEKEY)

		Catch ex As Exception
			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Utility.ShowErrorLabel(LabelError, sErrorMessage)

		End Try
	End Sub

#End Region


#Region "ObjectDataSource"

	Private Sub ods_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsDettagli.Selected
		ObjectDataSource_TrapError(sender, e)
	End Sub

	Protected Sub ods_Inserting(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceMethodEventArgs) Handles odsDettagli.Inserting
		e.InputParameters("UtenteInserimento") = User.Identity.Name
	End Sub

	Protected Sub ods_Updating(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceMethodEventArgs) Handles odsDettagli.Updating
		e.InputParameters("UtenteModifica") = User.Identity.Name
	End Sub

	Private Sub ods_Inserted(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles odsDettagli.Inserted
		If ObjectDataSource_TrapError(sender, e) Then
			mbErroreSalvataggio = True
		Else
			ObjectDataSource_DiscardCache()
			Response.Redirect(BACKPAGE)
		End If
	End Sub

	Private Sub ods_Updated(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles odsDettagli.Updated
		If ObjectDataSource_TrapError(sender, e) Then
			mbErroreSalvataggio = True
		Else
			ObjectDataSource_DiscardCache()
			Response.Redirect(BACKPAGE)
		End If
	End Sub

	Private Sub ods_Deleted(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles odsDettagli.Deleted
		If ObjectDataSource_TrapError(sender, e) Then
			mbErroreSalvataggio = True
		Else
			ObjectDataSource_DiscardCache()
			Response.Redirect(BACKPAGE)
		End If
	End Sub
#End Region


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

	Private Sub ObjectDataSource_DiscardCache()
		If odsDettagli.EnableCaching Then
			Cache(msPAGEKEY) = New Object
		End If
	End Sub
#End Region

End Class