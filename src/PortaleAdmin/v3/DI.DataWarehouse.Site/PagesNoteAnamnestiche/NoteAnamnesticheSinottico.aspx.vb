Imports System
Imports System.Web.UI
Imports System.Web.UI.WebControls

Public Class NoteAnamnesticheSinottico
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        '
        'Mostro o nascondo la prima colonna della griglia in base al selected value di rtbVisual.
        '
        gvLista.Columns(1).Visible = rbtVisual.SelectedValue = "Dettagliata"

        '
        'Aumento le dimnesioni della griglia se seleziono la visualizzazione Dettagliata.
        '
        gvLista.Width = If(rbtVisual.SelectedValue = "Dettagliata", 800, 600)

        If Page.IsPostBack Then
            '
            'Eseguo il bind della griglia.
            '
            gvLista.DataBind()
        End If
    End Sub

    Private Sub gvLista_RowDataBound(sender As Object, e As GridViewRowEventArgs) Handles gvLista.RowDataBound
        Try
            '
            'Ottengo le row che rappresentano il totale e quelle che sono sotto gruppi.
            '
            Dim IsTotale As Boolean = DataBinder.Eval(e.Row.DataItem, "IsTotale") = 1
            Dim IsSubTotale As Boolean = DataBinder.Eval(e.Row.DataItem, "IsSubTotale") = 1

            '
            'Se la row è un sotto gruppo ed è selezionato l'item "dettagliata" allora aggiungo uno stile alla griglia,
            'Setto il font a bold e cambio il contenuto della cella 1 inserendo la scritta "totale"
            '
            If IsSubTotale And rbtVisual.SelectedValue = "Dettagliata" Then
                e.Row.CssClass = "GridAlternatingItem"
                e.Row.Font.Bold = True
                If Not IsTotale Then e.Row.Cells(1).Text = "TOTALE"
            End If

            '
            'Se non è ne una riga di dettaglio ne la prima (è l'ultima row della griglia, con i totali) allora setto la classe css indent.
            '
            If Not IsSubTotale And Not IsTotale Then
                'Testo indentato nella prima colonna
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

#Region "ObjectDataSource"
    Private Sub odsListaSinottico_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsListaSinottico.Selected
        GestioneErrori.ObjectDataSource_TrapError(e, LabelError)
    End Sub

    Private Sub odsListaSinottico_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsListaSinottico.Selecting
        Try
            '
            'In base al selected value della dropDownList valorizzo l'input parameter.
            '
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

            '## PER DEBUG ###
            'PARAMETRO IN QUERY STRING DA USARE PER TESTARE LA PROCEDURA, NON VIENE MAI PASSATO IN URL
            Dim iNumeroOre As Integer
            If Integer.TryParse(Context.Request.QueryString("NumeroOre"), iNumeroOre) Then
                e.InputParameters("DataDal") = DateTime.Now.Subtract(New TimeSpan(iNumeroOre, 0, 0))
            End If

            e.InputParameters("DataAl") = DateTime.Now
            If rbtVisual.SelectedValue = "Compatta" Then
                odsListaSinottico.FilterExpression = "IsSubTotale=1"
            End If

        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(LabelError, sMessage)
        End Try
    End Sub
#End Region

End Class