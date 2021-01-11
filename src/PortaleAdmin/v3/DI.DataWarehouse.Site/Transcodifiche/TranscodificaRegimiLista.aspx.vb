Imports System
Imports System.Web.UI
Imports System.Web.UI.WebControls

Public Class TranscodificaRegimiLista
    Inherits System.Web.UI.Page

#Region "Property di pagina"
    Private ReadOnly msPAGEKEY As String = Page.GetType().BaseType.FullName

    Private gvCancelSelect = True

    Private Const PAGE_DETAIL As String = "~/Transcodifiche/TranscodificaRegimiDettaglio.aspx"

#End Region

    Private Sub TranscodificaRegimiLista_Load(sender As Object, e As EventArgs) Handles Me.Load
        Try
            '
            'Setta il pulsante di default.
            '
            Me.Form.DefaultButton = Me.SearchButton.UniqueID
            If Not Page.IsPostBack Then

                Call LoadDropDownListAziende()
                '
                'Ricarica i filtri prendendoli dalla sessione.
                '
                FilterHelper.Restore(filterPanel, msPAGEKEY)
                '
                'Se l'azienda è valorizzata allora carica i sistemi.
                '
                If ddlAziendeEroganti.SelectedValue.Trim <> String.Empty Then
                    '
                    'Se nei filtri salvati trovoa l'azienda, carico la sua lista sistemi eroganti
                    '
                    LoadDropDownListSistemi()
                    '
                    'Ripeto il caricamento del contenuto della dropdown
                    '
                    FilterHelper.Restore(ddlSistemiEroganti, msPAGEKEY)
                End If

                '
                ' Imposto la cancellazione della query principale in base alla valorizzazione dei filtri
                '
                'If Not String.IsNullOrEmpty(ddlAziendeEroganti.SelectedValue) OrElse
                '        Not String.IsNullOrEmpty(ddlSistemiEroganti.SelectedValue) OrElse
                '        Not String.IsNullOrEmpty(txtCodiceEsterno.Text) Then
                '    gvCancelSelect = False
                'Else
                '    gvCancelSelect = True
                'End If
                '
                ' Forzo esecuzione all'ingresso della pagina
                '
                gvCancelSelect = False

            End If
        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(lblError, sMessage)
        End Try
    End Sub

#Region "ObjectDataSource"
    Private Sub odsTranscodificaRegimi_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsTranscodificaRegimi.Selected
        '
        'Gestisco eventuali errori.
        '
        GestioneErrori.ObjectDataSource_TrapError(e, lblError)
    End Sub

    Private Sub odsTranscodificaRegimi_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsTranscodificaRegimi.Selecting
        Try
            '
            'Cancello la query se gvCancelSelect è true.
            '
            If gvCancelSelect Then
                e.Cancel = True
                Exit Sub
            End If

            '
            'Verifico che il campo sia valorizzato.
            '

            e.InputParameters("AziendaErogante") = ddlAziendeEroganti.SelectedValue
            e.InputParameters("SistemaErogante") = ddlSistemiEroganti.SelectedValue

            If String.IsNullOrEmpty(txtCodiceEsterno.Text) Then
                e.InputParameters("CodiceEsterno") = Nothing
            Else
                e.InputParameters("CodiceEsterno") = txtCodiceEsterno.Text
            End If

        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(lblError, sMessage)
        End Try
    End Sub
#End Region

#Region "Filtri"
    Private Sub SearchButton_Click(sender As Object, e As EventArgs) Handles SearchButton.Click
        Try
            '
            'Eseguo il bind dei dati solo se i filtri impostati sono validi.
            '
            If ValidateFilters() Then
                '
                'Salvo i filtri in sessione.
                '
                FilterHelper.SaveInSession(filterPanel, msPAGEKEY)

                '
                'Imposto a false la variabile gvCancelSelect in modo da eseguire la query dell'ObjectDataSource.
                '
                gvCancelSelect = False

                '
                'Eseguo il bind dei dati.
                '
                gvTranscodificaRegimi.DataBind()
            End If
        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(lblError, sMessage)
        End Try
    End Sub

    ''' <summary>
    ''' Verifica se i valori dei filtri sono impostati correttamente.
    ''' </summary>
    ''' <returns></returns>
    Private Function ValidateFilters() As Boolean
        '
        ' Lascio la funzione nel caso in futuro sia necessaria una validazione
        '
        Dim result As Boolean = True
        Return result
    End Function

#End Region

#Region "Eventi_GridView"
    Private Sub gvTranscodificaRegimi_RowCommand(sender As Object, e As GridViewCommandEventArgs) Handles gvTranscodificaRegimi.RowCommand
        Try
            '
            ' Ottengo l'index della row per ottenere l'ID del record da cancellare (memorizzato nelle DataKeys della gridView).
            '
            Dim rowIndex As Integer = e.CommandArgument
            Dim gID As Guid = gvTranscodificaRegimi.DataKeys(rowIndex).Values("Id")

            If e.CommandName.ToUpper = "CANCELLA" Then
                '
                ' Eseguo SP di rimozione
                '
                Using ta As New TranscodificheDataSetTableAdapters.TranscodificaRegimiOttieniTableAdapter
                    ta.Delete(gID)
                End Using
                '
                ' Mostro alert di CANCELLAZIONE
                '
                Page.ClientScript.RegisterStartupScript(Me.GetType, "msg", "alert('La transcodifica è stata cancellata!');", True)
                '
                ' Rieseguo query di ricerca
                '
                gvCancelSelect = False
                gvTranscodificaRegimi.DataBind()
            End If
        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(lblError, sMessage)
        End Try
    End Sub
#End Region


    Private Sub ddlAziendeEroganti_SelectedIndexChanged(sender As Object, e As EventArgs) Handles ddlAziendeEroganti.SelectedIndexChanged
        '
        ' In seguito a modifica selezione dell'azienda ricarico la ddl dei sistemi
        '
        Try
            LoadDropDownListSistemi()
        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(lblError, sMessage)
        End Try
    End Sub

#Region "Caricamento DropDown List"

    Private Sub LoadDropDownListAziende()
        Dim dt As DI.DataWarehouse.Admin.Data.BackEndDataSet.AziendeErogantiListaDataTable = Nothing
        Try
            Using ta As New DI.DataWarehouse.Admin.Data.BackEndDataSetTableAdapters.AziendeErogantiListaTableAdapter
                dt = ta.GetData()
            End Using
            'Cancello gli item presenti
            ddlAziendeEroganti.Items.Clear()
            'Eseguo bind
            ddlAziendeEroganti.DataSource = dt
            ddlAziendeEroganti.DataTextField = "Descrizione"
            ddlAziendeEroganti.DataValueField = "Codice"
            ddlAziendeEroganti.DataBind()
            '
            'Inserisco un item vuoto nella dropdownlist delle aziende.
            '
            ddlAziendeEroganti.Items.Insert(0, "")
        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(lblError, sMessage)
        End Try
    End Sub


    ''' <summary>
    ''' Funzione che si occupa del caricamento della dropdownlist dei sistemi in base al valore selezionato di ddlAziendeEroganti.
    ''' </summary>
    Private Sub LoadDropDownListSistemi()
        Dim dt As DI.DataWarehouse.Admin.Data.BackEndDataSet.SistemiErogantiListaDataTable = Nothing
        Try
            If Not String.IsNullOrEmpty(ddlAziendeEroganti.SelectedValue) Then
                ' Eseguo query per popolare ddlSistemiEroganti
                Using ta As New DI.DataWarehouse.Admin.Data.BackEndDataSetTableAdapters.SistemiErogantiListaTableAdapter
                    dt = ta.GetDataByAziendaETipo(ddlAziendeEroganti.SelectedValue, "Referti")
                End Using
                'Cancello gli item presenti
                ddlSistemiEroganti.Items.Clear()
                'Eseguo bind
                ddlSistemiEroganti.DataSource = dt
                ddlSistemiEroganti.DataTextField = "Descrizione"
                ddlSistemiEroganti.DataValueField = "Codice"
                ddlSistemiEroganti.DataBind()
                '
                'Inserisce un item vuoto nella dropdownlist dei sistemi.
                '
                ddlSistemiEroganti.Items.Insert(0, "")
            End If
        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(lblError, sMessage)
        End Try
    End Sub

    Private Sub NewButton_Click(sender As Object, e As EventArgs) Handles NewButton.Click
        Try
            Response.Redirect(Me.ResolveUrl(PAGE_DETAIL), False)
        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(lblError, sMessage)
        End Try
    End Sub

#End Region
End Class