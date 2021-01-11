Imports System
Imports System.Data
Imports System.IO
Imports System.Runtime.CompilerServices
Imports System.Runtime.Remoting.Messaging
Imports System.Web.Services.Description
Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports DI.Sac.Admin
Imports Microsoft.VisualBasic
Imports System.Windows.Forms

Public Class RuoliLista
    Inherits System.Web.UI.Page

    Private mbODSLista_CancelSelect As Boolean = False
    Private ReadOnly msPAGEKEY As String = Page.GetType().BaseType.FullName
    Private Const lblText As String = "Sono stati mostrati solo i primi 1000 record perchè la ricerca ha prodotto più di 1000 risultati."

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
                'FilterHelper.Restore(pannelloFiltri, PAGEKEY)
                gvLista.Sort(gvLista.Columns(0).SortExpression, SortDirection.Ascending)
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

    Private Sub odsLista_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsLista.Selecting
        Try
            'eseguo la ricerca solo se i filtri sono a posto
            e.Cancel = mbODSLista_CancelSelect
        Catch ex As Exception

        End Try
    End Sub

    Private Sub odsLista_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsLista.Selected
        Try
            If e.Exception Is Nothing Then
                Dim gvTop As Integer = CInt(odsLista.SelectParameters.Item("Top").DefaultValue)
                Dim eG = CType(e.ReturnValue, DataTable)
                If eG.Rows.Count = gvTop Then
                    lblGvLista.Visible = True
                    lblGvLista.Text = lblText
                Else
                    lblGvLista.Visible = False
                End If
            Else
                ObjectDataSource_TrapError(sender, e)
                lblGvLista.Visible = False
            End If
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
            lblGvLista.Visible = False
        End Try
    End Sub

    Protected Function ValidazioneFiltri() As Boolean
        Dim bValidazione As Boolean = True

        Return bValidazione

    End Function



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

    Private Sub ExportExcelMassivo_Click(sender As Object, e As EventArgs) Handles ExportExcelMassivo.Click
        Try

            'Chiamo la funzione che ricava il prospetto dei ruoli dal DB e torna un file Excel come stream
            Dim prosp As ProspettoRuoliExcel = New ProspettoRuoliExcel()
            Using memStream As MemoryStream = prosp.ExportExcelProspettoRuoli()

                If memStream IsNot Nothing Then
                    Response.Buffer = True
                    Response.AddHeader("content-disposition", "attachment;filename=" & $"ProspettoRuoli_{DateTime.Today.ToShortDateString()}" & ".xlsx")
                    Response.ContentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
                    memStream.WriteTo(Response.OutputStream)
                    Response.Flush()
                    Response.[End]()
                End If
            End Using

        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try

    End Sub

    Private Sub gvLista_RowCommand(sender As Object, e As GridViewCommandEventArgs) Handles gvLista.RowCommand

        Try
            If e.CommandName = "Excel" Then
                Dim idRuolo As Guid = New Guid(e.CommandArgument.ToString())

                'Chiamo la funzione che ricava il prospetto del ruolo dal DB e torna un file Excel come stream
                Dim prosp As ProspettoRuoliExcel = New ProspettoRuoliExcel()
                Using memStream As MemoryStream = prosp.ExportExcelProspettoRuoli(idRuolo)

                    If memStream IsNot Nothing Then
                        Response.Buffer = True
                        Response.AddHeader("content-disposition", "attachment;filename=" & $"ProspettoRuolo_{idRuolo}_{DateTime.Today.ToShortDateString()}" & ".xlsx")
                        Response.ContentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
                        memStream.WriteTo(Response.OutputStream)
                        Response.Flush()
                        Response.[End]()
                    End If
                End Using

            End If

        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub

#End Region

End Class