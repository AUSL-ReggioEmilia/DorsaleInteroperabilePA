Imports System
Imports System.Web.UI.WebControls
Imports DI.Sac.Admin
Imports OrganigrammaDataSetTableAdapters
Imports System.Data

Public Class TranscodificheUODettaglio
	Inherits System.Web.UI.Page

	Private Const BACKPAGE As String = "TranscodificheUOLista.aspx"
	Private ReadOnly msPAGEKEY As String = Page.GetType().BaseType.FullName
	Private mgIDUnitàOperativa As Guid
	Private mbErroreSalvataggio As Boolean = False

    Private Property IdUnitaOperativa() As Guid
        Get
            Return CType(Me.ViewState("IdUnitaOperativa"), Guid)
        End Get
        Set(value As Guid)
            Me.ViewState("IdUnitaOperativa") = value
        End Set
    End Property

    Private Property CodiceAnzienda() As String
        Get
            Return CType(Me.ViewState("CodiceAnzienda"), String)
        End Get
        Set(value As String)
            Me.ViewState("CodiceAnzienda") = value
        End Set
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

		Try
			If Not Page.IsPostBack Then
				If Request.QueryString("Id") Is Nothing Then
					Throw New ApplicationException("Parametro Id assente")
				End If

				mgIDUnitàOperativa = New Guid(Request.QueryString("Id"))
				Using ta As New UnitaOperativeTableAdapter
					Dim dt As DataTable = ta.GetDataById(mgIDUnitàOperativa)
					If dt.Rows.Count > 0 Then
                        Dim drUnitàOperativa As OrganigrammaDataSet.UnitaOperativeRow = dt.Rows(0)
                        Me.IdUnitaOperativa = drUnitàOperativa.ID
                        Me.CodiceAnzienda = drUnitàOperativa.CodiceAzienda
                        lblTitolo.Text = "Transcodifiche per l'unità operativa: " & drUnitàOperativa.CodiceAzienda & " - " & drUnitàOperativa.Codice & " - " & drUnitàOperativa.Descrizione
					End If
				End Using

			End If
		Catch ex As Exception

			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Utility.ShowErrorLabel(LabelError, sErrorMessage)

		End Try
	End Sub

	Protected Sub butSalva_Click(sender As Object, e As EventArgs) Handles butSalva.Click, butSalvaTop.Click
		Try

			For Each row As GridViewRow In gvLista.Rows
				gvLista.UpdateRow(row.RowIndex, False)
			Next

			If Not mbErroreSalvataggio Then
				Response.Redirect(BACKPAGE)
			End If

		Catch ex As Exception
			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Utility.ShowErrorLabel(LabelError, sErrorMessage)
		End Try
	End Sub

	Private Sub gvLista_RowUpdating(sender As Object, e As System.Web.UI.WebControls.GridViewUpdateEventArgs) Handles gvLista.RowUpdating
		Try

			e.NewValues("UtenteModifica") = User.Identity.Name
            e.NewValues("IdUnitaOperativa") = Me.IdUnitaOperativa
            e.NewValues("IdSistema") = e.Keys("IdSistema")
            e.NewValues("CodiceAzienda") = Me.CodiceAnzienda

        Catch ex As Exception
			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Utility.ShowErrorLabel(LabelError, sErrorMessage)
			mbErroreSalvataggio = True
		End Try
	End Sub

	Protected Sub butChiudi_Click(sender As Object, e As EventArgs) Handles butChiudi.Click, butChiudiTop.Click
		Response.Redirect(BACKPAGE)
	End Sub


#Region "ObjectDataSource"

	Private Sub ods_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsDettaglio.Selected
		If ObjectDataSource_TrapError(sender, e) Then
			mbErroreSalvataggio = True
		End If
	End Sub

	Private Sub ods_Inserted(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles odsDettaglio.Inserted
		If ObjectDataSource_TrapError(sender, e) Then
			mbErroreSalvataggio = True
		End If
	End Sub

	Private Sub ods_Updated(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles odsDettaglio.Updated
		If ObjectDataSource_TrapError(sender, e) Then
			mbErroreSalvataggio = True
		End If
	End Sub

	Private Sub ods_Deleted(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles odsDettaglio.Deleted
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
		If odsDettaglio.EnableCaching Then
			Cache(msPAGEKEY) = New Object
		End If
	End Sub


#End Region


End Class