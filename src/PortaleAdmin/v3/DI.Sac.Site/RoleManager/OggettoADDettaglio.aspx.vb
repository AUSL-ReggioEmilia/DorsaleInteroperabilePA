Imports System
Imports System.Web.UI.WebControls
Imports DI.Sac.Admin

Public Class OggettoADDettaglio
	Inherits System.Web.UI.Page

	Private Const BACKPAGE As String = "OggettiAD.aspx"
	Private ReadOnly msPAGEKEY As String = Page.GetType().BaseType.FullName

	Private mbods_CanSelect = True

	Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
		Try
			If Not Page.IsPostBack Then
				If Request.QueryString("Id") Is Nothing Then
					Utility.ShowErrorLabel(LabelError, "Errore: Parametro ID non passato")
					mbods_CanSelect = False
				End If
			End If
		Catch ex As Exception
			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Utility.ShowErrorLabel(LabelError, sErrorMessage)
		End Try
	End Sub

	Private Sub butAnnulla_Click(sender As Object, e As System.EventArgs) Handles butAnnulla.Click
		Response.Redirect(BACKPAGE)
	End Sub

#Region "ObjectDataSource"

	Private Sub ods_Selecting(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceSelectingEventArgs) Handles odsDettaglio.Selecting, odsGruppiOttieniPerUtente.Selecting, odsMembriOttieniPerGruppo.Selecting
		e.Cancel = Not mbods_CanSelect
	End Sub

	Private Sub ods_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsDettaglio.Selected
		Dim msUtente As String = ""
		Dim mbDiTipoUtente As Boolean

		If Not ObjectDataSource_TrapError(sender, e) Then
			Dim dt As OrganigrammaDataSet.OggettiActiveDirectoryDataTable
			dt = DirectCast(e.ReturnValue, OrganigrammaDataSet.OggettiActiveDirectoryDataTable)

			If dt.Rows.Count = 0 Then
				Utility.ShowErrorLabel(LabelError, "Errore: Oggetto non trovato con ID: " & Request.QueryString("Id"))
			Else
				msUtente = dt.Rows(0)("Utente")
				mbDiTipoUtente = dt.Rows(0)("Tipo").ToString.ToUpper = "UTENTE"

				lblTitolo.Text = "Dettaglio " & dt.Rows(0)("Tipo") & "  di Active Directory: " & msUtente
				lblTitoloMembriGruppo.Text = "Membri del gruppo: " & msUtente
				lblTitoloMembriGruppo.Visible = Not mbDiTipoUtente
				gvListaMembridelGruppo.Visible = Not mbDiTipoUtente
				Toolbar.Visible = False	' mbDiTipoUtente
			End If
		End If
	End Sub

	Private Sub odsGriglie_Selected(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles odsGruppiOttieniPerUtente.Selected, odsMembriOttieniPerGruppo.Selected
		ObjectDataSource_TrapError(sender, e)
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
		If odsDettaglio.EnableCaching Then
			Cache(msPAGEKEY) = New Object
		End If
	End Sub

#End Region

	
End Class