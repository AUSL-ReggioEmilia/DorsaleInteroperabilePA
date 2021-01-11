Imports System
Imports System.Web.UI.WebControls
Imports DI.Sac.Admin
Imports OrganigrammaDataSetTableAdapters
Imports System.Data

Public Class UnitaOperativaRegimi
	Inherits System.Web.UI.Page

	Private msBACKPAGE As String = "UnitaOperativeDettaglio.aspx?id={0}"
	Private ReadOnly msPAGEKEY As String = Page.GetType().BaseType.FullName
	Private mbErroreSalvataggio As Boolean = False

	Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
		Try
			If Request.QueryString("Id") Is Nothing Then
				Throw New ApplicationException("Parametro Id assente")
			End If
			Dim mgIDUnitàOperativa = New Guid(Request.QueryString("Id"))
			msBACKPAGE = String.Format(msBACKPAGE, Request.QueryString("Id"))

			If Not Page.IsPostBack Then
				Using ta As New UnitaOperativeTableAdapter
					Dim dt = ta.GetDataById(mgIDUnitàOperativa)
					If dt.Rows.Count > 0 Then
						lblTitolo.Text = "Impostazione dei Regimi di ricovero per:<br />" & dt(0).CodiceAzienda & " - " & dt(0).Codice & " - " & dt(0).Descrizione
					Else
						Throw New ApplicationException("Unità Operativa non trovata")
					End If
				End Using
			End If

		Catch ex As Exception
			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Utility.ShowErrorLabel(LabelError, sErrorMessage)
		End Try
	End Sub

	Protected Sub butSalva_Click(sender As Object, e As EventArgs) Handles butSalva.Click
		Try
			For Each row As GridViewRow In gvLista.Rows
				gvLista.UpdateRow(row.RowIndex, False)
			Next

			If Not mbErroreSalvataggio Then
				Response.Redirect(msBACKPAGE)
			End If

		Catch ex As Exception
			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Utility.ShowErrorLabel(LabelError, sErrorMessage)
		End Try
	End Sub

	Protected Sub butChiudi_Click(sender As Object, e As EventArgs) Handles butChiudi.Click
		Response.Redirect(msBACKPAGE)
	End Sub


#Region "ObjectDataSource"

	Private Sub ods_Updating(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceMethodEventArgs) Handles odsGrid.Updating
		Try
			e.InputParameters("UtenteModifica") = User.Identity.Name
		Catch ex As Exception
			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Utility.ShowErrorLabel(LabelError, sErrorMessage)
			mbErroreSalvataggio = True
		End Try
	End Sub

	Private Sub ods_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsGrid.Selected
		If ObjectDataSource_TrapError(sender, e) Then
			mbErroreSalvataggio = True
		End If
	End Sub

	Private Sub ods_Inserted(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles odsGrid.Inserted
		If ObjectDataSource_TrapError(sender, e) Then
			mbErroreSalvataggio = True
		End If
	End Sub

	Private Sub ods_Updated(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles odsGrid.Updated
		If ObjectDataSource_TrapError(sender, e) Then
			mbErroreSalvataggio = True
		End If
	End Sub

	Private Sub ods_Deleted(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles odsGrid.Deleted
		If ObjectDataSource_TrapError(sender, e) Then
			mbErroreSalvataggio = True
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
		If odsGrid.EnableCaching Then
			Cache(msPAGEKEY) = New Object
		End If
	End Sub

#End Region

	
End Class