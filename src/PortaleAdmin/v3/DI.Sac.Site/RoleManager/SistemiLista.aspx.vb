Imports System
Imports System.Web.UI.WebControls
Imports DI.Sac.Admin
Imports System.Data
Imports OrganigrammaDataSetTableAdapters

Public Class SistemiLista
    Inherits System.Web.UI.Page

    Const FLAG_ATTIVO_TUTTI As String = ""
    Const FLAG_ATTIVO_SI As String = "1"
    Const FLAG_ATTIVO_NO As String = "0"
    Private ReadOnly msPAGEKEY As String = Page.GetType().BaseType.FullName

	Private Sub Page_Load(sender As Object, e As System.EventArgs) Handles Me.Load
		Try
			If Not Page.IsPostBack Then
				FilterHelper.Restore(pannelloFiltri, msPAGEKEY)
			End If
		Catch ex As Exception
			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Utility.ShowErrorLabel(LabelError, sErrorMessage)
		End Try
	End Sub

	Private Sub Page_PreRenderComplete(sender As Object, e As System.EventArgs) Handles Me.PreRenderComplete
		Try
			If Not Page.IsPostBack Then

				FilterHelper.Restore(ddlFiltriAzienda, msPAGEKEY)
				' SE AVEVO IMPOSTATO UN FILTRO NELLA DROPDOWN FORZO UN DATABIND 
				' CHE ALTRIMENTI NON SCATTEREBBE IN AUTOMATICO
				If ddlFiltriAzienda.SelectedValue.Length > 0 Then
					gvLista.DataBind()
				End If
			End If
		Catch ex As Exception
			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Utility.ShowErrorLabel(LabelError, sErrorMessage)
		End Try
	End Sub

	Protected Sub RicercaButton_Click(sender As Object, e As EventArgs) Handles butFiltriRicerca.Click

		Try
			LabelError.Visible = False
			If ValidazioneFiltri() Then
				FilterHelper.SaveInSession(pannelloFiltri, msPAGEKEY)
				Cache.Remove(odsLista.CacheKeyDependency)
				gvLista.PageIndex = 0
			End If

		Catch ex As Exception
			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Utility.ShowErrorLabel(LabelError, sErrorMessage)
		End Try

	End Sub

	Private Sub ods_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsLista.Selected
		ObjectDataSource_TrapError(sender, e)
	End Sub

	Protected Function ValidazioneFiltri() As Boolean

		'nulla da validare
		Return True

	End Function


#Region "Funzioni"

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

    Private Sub odsLista_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsLista.Selecting
        Try
            '
            ' SIMONE BITTI 2017-06-12: Passo il valore al parametro @Attivo (BOOLEAN NULLABILE) della query 
            '
            Dim sValue As String = ddlAttivo.SelectedValue
            Dim bAttivo As Boolean? = Nothing
            Select Case sValue
                Case FLAG_ATTIVO_TUTTI
                    bAttivo = Nothing 'passo NOTHING alla SP arriva NULL
                Case FLAG_ATTIVO_NO
                    bAttivo = False
                Case FLAG_ATTIVO_SI
                    bAttivo = True
            End Select
            e.InputParameters("Attivo") = bAttivo
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
        Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub

#End Region

End Class