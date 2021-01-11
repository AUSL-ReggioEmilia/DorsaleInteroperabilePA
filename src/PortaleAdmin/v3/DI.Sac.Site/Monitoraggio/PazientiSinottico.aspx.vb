Imports System
Imports System.Web.UI
Imports System.Web.UI.WebControls

Public Class PazientiSinottico
    Inherits System.Web.UI.Page

    Private Const FILTERKEY As String = "PazientiSinottico"

    Private Sub PazientiSinottico_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            FilterHelper.Restore(pannelloFiltri, FILTERKEY)
            gvLista.DataBind()
        End If
    End Sub

    Private Sub ddlFiltriPeriodo_SelectedIndexChanged(sender As Object, e As EventArgs) Handles ddlFiltriPeriodo.SelectedIndexChanged
        FilterHelper.SaveInSession(pannelloFiltri, FILTERKEY)
        gvLista.DataBind()
    End Sub

    Private Sub gvLista_RowDataBound(sender As Object, e As GridViewRowEventArgs) Handles gvLista.RowDataBound
        Try
            Dim IsTotale As Boolean = DataBinder.Eval(e.Row.DataItem, "IsTotale") = 1
            If IsTotale Then
                e.Row.CssClass = "GridAlternatingItem"
                e.Row.Font.Bold = True
                e.Row.Cells(0).Text = "TOTALE"
            End If
        Catch ex As Exception
            GestioneErrori.TrapError(ex)
            Dim sMessage As String = "Si è verificato un errore durante il caricamento della griglia."
            Utility.ShowErrorLabel(LabelError, sMessage)
        End Try
    End Sub

    Private Sub odsLista_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsLista.Selected
        GestioneErrori.ObjectDataSource_TrapError(e, LabelError)
    End Sub

    Private Sub odsLista_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsLista.Selecting
        Try
            Select Case ddlFiltriPeriodo.SelectedValue
                Case "1" 'Ultima ora
                    e.InputParameters("DataDal") = DateTime.Now.Subtract(New TimeSpan(1, 0, 0))
                Case "2" 'Oggi
                    e.InputParameters("DataDal") = DateTime.Today
                Case "3" 'Ultimi 7 Giorni
                    e.InputParameters("DataDal") = DateTime.Today.AddDays(-7)
                Case "4" 'Ultimi 30 Giorni
                    e.InputParameters("DataDal") = DateTime.Today.AddDays(-30)
            End Select
            e.InputParameters("DataAl") = DateTime.Now
        Catch ex As Exception
            GestioneErrori.TrapError(ex)
            Dim sMessage As String = "Si è verificato un errore durante la ricerca."
            Utility.ShowErrorLabel(LabelError, sMessage)
        End Try
    End Sub
End Class