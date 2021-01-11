Imports System
Imports System.Data
Imports System.Web.UI.WebControls
Imports DI.DataWarehouse.Admin.Data

Public Class SistemiErogantiLista
    Inherits System.Web.UI.Page
    Private ReadOnly msPAGEKEY As String = Page.GetType().BaseType.FullName

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Try
            Page.Form.DefaultButton = butFiltriRicerca.UniqueID

            If Not Page.IsPostBack Then
                FilterHelper.Restore(pannelloFiltri, msPAGEKEY)
            End If
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
            LabelError.Text = "Si è verificato un errore durante caricamento della pagina."
        End Try
    End Sub

    Private Sub butFiltriRicerca_Click(sender As Object, e As EventArgs) Handles butFiltriRicerca.Click
        Try
            FilterHelper.SaveInSession(pannelloFiltri, msPAGEKEY)
            gvSistemiEroganti.DataBind()
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
            LabelError.Text = "Si è verificato un errore durante la ricerca dei Sistemi Eroganti."
        End Try
    End Sub

    Private Sub gvSistemiEroganti_RowDataBound(sender As Object, e As GridViewRowEventArgs) Handles gvSistemiEroganti.RowDataBound
        '
        'SIMONEB - 2017-06-13
        'Modifiche per l'evolutiva:SAC: RoleManager - Aggiungere nelle pagine indicate il filtro check attivo (riferito al sistema), di default deselezionato.
        '( TASK ASSENTE ) 
        '
        Try
            'TESTO SE LA ROW NON È  NOTHING.
            If Not e Is Nothing AndAlso Not e.Row Is Nothing AndAlso Not e.Row.DataItem Is Nothing Then

                'CREO UNA VARIABILE DI TIPO BOOLEANA (CHE PUÒ ESSERE NOTHING).
                Dim bAttivo As Boolean? = Nothing

                'SE IL VALORE SELEZIONATO NELLA DROPDOWNLIST NON È VUOTO ALLORA CASTO IL VALORE SELEZIONATO A BOOLEAN.
                'IN QUESTO MODO POSSO DISTINGUERE TRA ATTIVI, NON ATTIVI O MOSTRARLI TUTTI.
                If Not String.IsNullOrEmpty(ddlAttivo.SelectedValue) Then
                    bAttivo = CType(ddlAttivo.SelectedValue, Boolean)
                End If

                'SE bAttivo NON È NOTHING ALLORA FILTRO I DATI PER IL VALORE SELEZIONATO NELLA DDLATTIVO.
                'SE È bAttivo È NOTHING NON FACCIO NULLA E MOSTRO TUTTI I STISTEMI EROGANTI.
                If Not bAttivo Is Nothing Then
                    'OTTENGO LA DATAROW
                    Dim dtRowView As DataRowView = CType(e.Row.DataItem, DataRowView)
                    Dim oRow As BackEndDataSet.BevsSistemiErogantiRow = CType(dtRowView.Row, BackEndDataSet.BevsSistemiErogantiRow)

                    'OTTENGO IL VALORE DEI CAMPI "TipoReferti" , "TipoRicoveri" e "TipoNoteAnamnestiche".
                    Dim bTipoReferto As Boolean = CType(oRow.TipoReferti, Boolean)
                    Dim bTipoRicoveri As Boolean = CType(oRow.TipoRicoveri, Boolean)
                    Dim bTipoNoteAnamnestiche As Boolean = CType(oRow.TipoNoteAnamnestiche, Boolean)

                    'SE bAttivo È TRUE ALLORA MOSTRO SOLO I SISTEMI IN CUI ALMENO UNO TRA TipoReferti E TipoRicoveri SIA TRUE.
                    'SE bAttivo È FALSE ALLORA MOSTRO SOLO I SISTEMI IN CUI TipoReferti E TipoRicoveri SONO FALSE.
                    'If bAttivo Then
                    '    If Not bTipoReferto AndAlso Not bTipoRicoveri Then
                    '        e.Row.Visible = False
                    '    End If
                    'Else
                    '    If bTipoReferto Or bTipoRicoveri Then
                    '        e.Row.Visible = False
                    '    End If
                    'End If
                    'MODIFICA ETTORE 2018-06-27: semplifiato il test di visualizzaione delle righe
                    If bAttivo Then
                        e.Row.Visible = bTipoReferto Or bTipoRicoveri Or bTipoNoteAnamnestiche
                    Else
                        e.Row.Visible = Not (bTipoReferto Or bTipoRicoveri Or bTipoNoteAnamnestiche)
                    End If

                End If
            End If
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
            LabelError.Text = "Si è verificato un errore durante la ricerca dei Sistemi Eroganti."
        End Try
    End Sub

    Private Sub SistemiErogantiOds_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles SistemiErogantiOds.Selected
        GestioneErrori.ObjectDataSource_TrapError(e, LabelError)
    End Sub

    Private Sub SistemiErogantiOds_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles SistemiErogantiOds.Selecting
        Try
            'ottengo il selected value della dropdownlist ddlGeneraAnteprimaReferto
            Dim sValue As String = ddlGeneraAnteprimaReferto.SelectedValue

            'creo la variabile da passare all'objectdatasource
            '(di default è nothing)
            Dim bGeneraAnteprimaReferto As Boolean? = Nothing

            'se il selected value della dropDownList è valorizzato allora ne casto il valore a boolean
            If Not String.IsNullOrEmpty(sValue) Then
                bGeneraAnteprimaReferto = CType(sValue, Boolean)
            End If

            'passo il valore all'InputParameters dell'ObjectDataSource
            e.InputParameters("GeneraAnteprimaReferto") = bGeneraAnteprimaReferto

        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
            LabelError.Text = "Si è verificato un errore durante la ricerca dei Sistemi Eroganti."
        End Try
    End Sub

    'MODIFICA ETTORE: 2017-03-01 - non si va in insert perchè i sisyemi vengono sincronizzati da SAC tramire un job SQL
    'Private Sub NewButton_Click(sender As Object, e As System.EventArgs) Handles NewButton.Click

    '    Try
    '        Response.Redirect(Me.ResolveUrl("SistemiErogantiDettaglio.aspx"), False)
    '    Catch ex As Exception
    '        Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
    '        Utility.ShowErrorLabel(LabelError, sErrorMessage)
    '        LabelError.Text = "Si è verificato un errore durante la navigazione alla pagina di inserimento."
    '    End Try
    'End Sub
End Class