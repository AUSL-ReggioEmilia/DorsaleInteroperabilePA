Imports System
Imports System.Web.UI
Imports System.Web.UI.WebControls

Public Class EventiInviiSoleSinottico
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        'MOSTRO LA COLONNA DEL SOTTO GRUPPO SOLO SE È SELEZIONATO L'ITEM "DETTAGLIATA" NEI FILTRI
        gvLista.Columns(1).Visible = rbtVisual.SelectedValue = "Dettagliata"

        'OGNI VOLTA CHE VIENE GENERATO UN POSTBACK ESEGUO IL BIND DELLA GRIGLIA.
        'QUESTO PERCHÈ I FILTRI ESEGUONO UN POSTBACK.
        If Page.IsPostBack Then
            gvLista.DataBind()
        End If
    End Sub

    Private Sub gvLista_RowDataBound(sender As Object, e As GridViewRowEventArgs) Handles gvLista.RowDataBound
        Try
            'OTTENGO LE ROW CHE RAPPRESENTANO IL TOTALE E QUELLE CHE SONO SOTTO GRUPPI.
            Dim IsTotale As Boolean = DataBinder.Eval(e.Row.DataItem, "IsTotale") = 1
            Dim IsSubTotale As Boolean = DataBinder.Eval(e.Row.DataItem, "IsSubTotale") = 1

            'SE LA ROW È UN SOTTO GRUPPO ED È SELEZIONATO L'ITEM "DETTAGLIATA" ALLORA AGGIUNGO UNO STILE ALLA GRIGLIA,
            'SETTO IL FONT A BOLD E CAMBIO IL CONTENUTO DELLA CELLA 1 INSERENDO LA SCRITTA "TOTALE"
            If IsSubTotale And rbtVisual.SelectedValue = "Dettagliata" Then
                e.Row.CssClass = "GridAlternatingItem"
                e.Row.Font.Bold = True
                If Not IsTotale Then e.Row.Cells(1).Text = "TOTALE"
            End If

            'SE NON È NE UNA RIGA DI DETTAGLIO NE LA PRIMA (È L'ULTIMA ROW DELLA GRIGLIA, CON I TOTALI) ALLORA SETTO LA CLASSE CSS INDENT 
            If Not IsSubTotale And Not IsTotale Then
                'testo indentato nella prima colonna
                e.Row.Cells(0).CssClass = "Indent"
            End If

            If IsTotale Then
                e.Row.CssClass = "GridAlternatingItem"
                e.Row.Font.Bold = True
                e.Row.Cells(0).Text = "TOTALE"
            End If
        Catch
            '
            'non trappo errori in fase di disegno della riga
            '
        End Try
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

            '## PER DEBUG ###
            'PARAMETRO IN QUERY STRING DA USARE PER TESTARE LA PROCEDURA, NON VIENE MAI PASSATO IN URL
            Dim iNumeroOre As Integer
            If Integer.TryParse(Context.Request.QueryString("NumeroOre"), iNumeroOre) Then
                e.InputParameters("DataDal") = DateTime.Now.Subtract(New TimeSpan(iNumeroOre, 0, 0))
            End If

            e.InputParameters("DataAl") = DateTime.Now


            'IMPORTANTE:
            'PERMETTE DI NASCONDERE LE ROW DI DETTAGLIO E MOSTRARE SOLO LA VERSIONE COMPATTATA
            If rbtVisual.SelectedValue = "Compatta" Then
                odsLista.FilterExpression = "IsSubTotale=1"
            End If
        Catch ex As Exception
            'TRAPPO L'ERRORE E MOSTRO IL MESSAGGIO
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(LabelError, sMessage)
        End Try
    End Sub

    Private Sub ods_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsLista.Selected
        'TRAPPO L'ERRORE
        ObjectDataSource_TrapError(e, LabelError)
    End Sub

    Private Sub gvLista_PreRender(sender As Object, e As EventArgs) Handles gvLista.PreRender
        Try
            'MOSTRO GLI ESITI SOLE STATI SOLO SE È SELEZIONATO "DETTAGLIATA"
            If rbtVisual.SelectedValue = "Dettagliata" Then
                gvLista.Columns(4).Visible = True 'Processato
                gvLista.Columns(5).Visible = True 'EsitoNV
                gvLista.Columns(6).Visible = True 'EsitoIV
                gvLista.Columns(7).Visible = True 'EsitoNULL
                gvLista.Columns(8).Visible = True 'EsitoAE
                gvLista.Columns(9).Visible = True 'EsitoAA
            Else
                gvLista.Columns(4).Visible = False 'Processato
                gvLista.Columns(5).Visible = False 'EsitoNV
                gvLista.Columns(6).Visible = False 'EsitoIV
                gvLista.Columns(7).Visible = False 'EsitoNULL
                gvLista.Columns(8).Visible = False 'EsitoAE
                gvLista.Columns(9).Visible = False 'EsitoAA
            End If
        Catch ex As Exception
            'TRAPPO L'ERRORE E MOSTRO IL MESSAGGIO
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(LabelError, sMessage)
        End Try
    End Sub
End Class