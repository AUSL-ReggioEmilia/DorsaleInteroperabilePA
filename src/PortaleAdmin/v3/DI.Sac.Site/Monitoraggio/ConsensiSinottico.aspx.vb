Imports System
Imports System.Web.UI
Imports System.Web.UI.WebControls

Public Class ConsensiSinottico
    Inherits System.Web.UI.Page
    Private Const FILTERKEY As String = "ConsensiSinottico"

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            FilterHelper.Restore(pannelloFiltri, FILTERKEY)
            gvLista.DataBind()
        End If

        gvLista.Columns(1).Visible = rbtVisual.SelectedValue = "Dettagliata"
        gvLista.Width = If(rbtVisual.SelectedValue = "Dettagliata", 800, 600)
    End Sub

    Private Sub ddlFiltriPeriodo_SelectedIndexChanged(sender As Object, e As EventArgs) Handles ddlFiltriPeriodo.SelectedIndexChanged
        FilterHelper.SaveInSession(pannelloFiltri, FILTERKEY)

        gvLista.DataBind()
    End Sub

    Private Sub gvLista_RowDataBound(sender As Object, e As GridViewRowEventArgs) Handles gvLista.RowDataBound
        Try
            Dim IsTotale As Boolean = DataBinder.Eval(e.Row.DataItem, "IsTotale") = 1
            Dim IsSubTotale As Boolean = DataBinder.Eval(e.Row.DataItem, "IsSubTotale") = 1

            'subtotale
            If IsSubTotale And rbtVisual.SelectedValue = "Dettagliata" Then
                e.Row.CssClass = "GridAlternatingItem"
                e.Row.Font.Bold = True
                If Not IsTotale Then e.Row.Cells(1).Text = "TOTALE"
            End If

            'righe di dettaglio:
            If Not IsSubTotale And Not IsTotale Then
                'testo indentato nella prima colonna
                e.Row.Cells(0).CssClass = "Indent"
            End If

            'totale
            If IsTotale Then
                e.Row.CssClass = "GridAlternatingItem"
                e.Row.Font.Bold = True
                e.Row.Cells(0).Text = "TOTALE"
            End If
        Catch
            'non trappo errori in fase di disegno della riga
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
            If rbtVisual.SelectedValue = "Compatta" Then
                odsLista.FilterExpression = "IsSubTotale=1"
            End If
        Catch ex As Exception
            GestioneErrori.TrapError(ex)
            Dim sMessage As String = "Si è verificato un errore durante la ricerca."
            Utility.ShowErrorLabel(LabelError, sMessage)
        End Try
    End Sub

    Private Sub rbtVisual_SelectedIndexChanged(sender As Object, e As EventArgs) Handles rbtVisual.SelectedIndexChanged
        FilterHelper.SaveInSession(pannelloFiltri, FILTERKEY)

        gvLista.DataBind()
    End Sub

    Protected Function getStatoField(Stato As Object)
        Dim bStato As Boolean
        Dim sResult As String = String.Empty
        Try
            If Boolean.TryParse(Stato, bStato) Then
                If bStato Then
                    sResult = "Concesso"
                Else
                    sResult = "Negato"
                End If
            End If
            Return sResult
        Catch ex As Exception
            '
            'Gestione Errore
            '
            GestioneErrori.TrapError(ex)
            Return Nothing
        End Try
    End Function
End Class