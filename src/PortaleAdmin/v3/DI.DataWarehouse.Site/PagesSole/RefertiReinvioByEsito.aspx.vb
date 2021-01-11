Imports System
Imports System.Collections
Imports System.Collections.Generic
Imports System.Data
Imports System.IO
Imports System.Linq
Imports System.Web
Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports DI.DataWarehouse.Admin.Data

Public Class RefertiReinvioByEsito
    Inherits System.Web.UI.Page

    Private ReadOnly msPAGEKEY As String = Page.GetType().BaseType.FullName

    '
    'Indica il massimo numero di record da visualizzare.
    '
    Private Const MAX_NUM_RECORD_DA_VISUALIZZARE As Integer = 1000
    Private Const MAX_RINOTIFICHE_PER_CICLO As Integer = 50



    Private gvCancelSelect As Boolean = True
    '
    ' I valori con cui caricare al combo degli Esiti
    '
    Protected CMB_ESITO_VALUE_TUTTI As String = "Tutti"
    Protected CMB_ESITO_VALUE_DA_INVIARE As String = "Da Inviare"
    Protected CMB_ESITO_VALUE_ERRATI As String = "Errato"

    '
    'Indica il numero di referti restituiti dalla ricerca.
    '
    Protected Property NumOggettiTrovati() As Integer
        Get
            Return ViewState("NumOggettiTrovati")
        End Get
        Set(ByVal value As Integer)
            ViewState.Add("NumOggettiTrovati", value)
        End Set
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Try
            '
            'SETTO IL BOTTONE DI DEFAULT
            '
            Page.Form.DefaultButton = btnCerca.UniqueID
            If Not Page.IsPostBack Then
                '
                ' Carico la combo degli esiti
                '
                cmbEsiti.Items.Add(CMB_ESITO_VALUE_TUTTI)
                cmbEsiti.Items.Add(CMB_ESITO_VALUE_DA_INVIARE)
                cmbEsiti.Items.Add(CMB_ESITO_VALUE_ERRATI)
                '
                ' RICARICO I FILTRI DALLA SESSIONE
                '
                FilterHelper.Restore(pannelloFiltri, msPAGEKEY)
                '
                ' Se txtMaxNumRecords è vuoto la inizializzo con 1000
                '
                If String.IsNullOrEmpty(txtMaxNumRecords.Text) Then
                    txtMaxNumRecords.Text = 1000
                End If
                '
                ' Imposto "Dalla data" ad un mesa fa
                '
                If String.IsNullOrEmpty(txtDallaData.Text) Then
                    txtDallaData.Text = Date.Now.Date.AddMonths(-1)
                End If
                '
                ' Nascondo la progress bar
                '
                progressbar.Visible = False
            End If

        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub

    Private Sub btnCerca_Click(sender As Object, e As EventArgs) Handles btnCerca.Click
        Try
            '
            ' Valido i parametri di filtro: se OK eseguo data bind 
            '
            If ValidateFilters() Then
                Me.Sole_ListaOggettiProcessati = Nothing
                '
                'Quando premo il tasto "cerca" svuoto la label di stato della notifica.
                '
                lblStatoNotifica.Text = ""
                LabelError.Visible = False
                'Deve essere impostato a false cosi viene rieseguita la query dall'object data source
                gvCancelSelect = False
                '
                'SALVO IN SESSIONE I FILTRI.
                '
                FilterHelper.SaveInSession(pannelloFiltri, msPAGEKEY)
                gvReferti.DataBind()
            End If

        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub

    Private Sub odsReferti_Selected(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles odsReferti.Selected
        Try
            '
            'GESTIONE ERRORE
            '
            If Not GestioneErrori.ObjectDataSource_TrapError(e, LabelError) Then
                btnRiprocessa.Enabled = True
                lblMaxNumRow.Visible = True
                gvReferti.Visible = True

                '
                'Ottengo il data table.
                '
                Dim dt As DataTable = CType(e.ReturnValue, DataTable)
                '
                'Ottengo il numero di row contenute nel data table.
                '
                Me.NumOggettiTrovati = dt.Rows.Count

                Dim sMessage As String = String.Format("La ricerca ha prodotto {0} record.", Me.NumOggettiTrovati)
                If Me.NumOggettiTrovati > MAX_NUM_RECORD_DA_VISUALIZZARE Then
                    sMessage = String.Format("La ricerca ha prodotto {0} record. Raffinare eventualmente la ricerca.", Me.NumOggettiTrovati)
                    gvReferti.Visible = False
                ElseIf Me.NumOggettiTrovati = 0 Then
                    btnRiprocessa.Enabled = False
                    lblMaxNumRow.Visible = False
                End If
                '
                ' Visualizzo il messaggio
                '
                lblMaxNumRow.Text = sMessage
                '
                ' SALVO IN SESSIONE LA LISTA DEGLI OGGETTI DA PROCESSARE.
                '
                Me.Sole_ListaOggettiDaProcessare = dt
            End If

        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub

    Private Sub odsReferti_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsReferti.Selecting
        Try
            If gvCancelSelect = True Then
                e.Cancel = True
                Exit Sub
            End If

            '---------------------------------------------------------------------------------------------
            ' Se sono qui i parametri di filtro sono stati valorizzati correttamente
            '---------------------------------------------------------------------------------------------
            '
            ' Valorizzo i parametri @Filtro_Stato_AE, @Filtro_Stato_NULL, @Filtro_Stato_IV
            ' Se ho selezionato "DA INVIARE" allora  Filtro_Stato_NULL=True , Filtro_Stato_IV= True
            ' Se ho selezionato "ERRATI" allora  @Filtro_Stato_AE=True
            ' Se ho selezionato "TUTTI" allora  Filtro_Stato_NULL=True , Filtro_Stato_IV= True, @Filtro_Stato_AE=True
            '
            Select Case cmbEsiti.SelectedValue.ToUpper
                Case CMB_ESITO_VALUE_TUTTI.ToUpper
                    e.InputParameters("Filtro_Stato_NULL") = True
                    e.InputParameters("Filtro_Stato_IV") = True
                    e.InputParameters("Filtro_Stato_AE") = True
                Case CMB_ESITO_VALUE_DA_INVIARE.ToUpper
                    e.InputParameters("Filtro_Stato_NULL") = True
                    e.InputParameters("Filtro_Stato_IV") = True
                    e.InputParameters("Filtro_Stato_AE") = False
                Case CMB_ESITO_VALUE_ERRATI.ToUpper
                    e.InputParameters("Filtro_Stato_NULL") = False
                    e.InputParameters("Filtro_Stato_IV") = False
                    e.InputParameters("Filtro_Stato_AE") = True
                Case Else
                    Throw New ApplicationException("Il valore selezionato della combo 'Esito' non è gestito.")
            End Select
            '
            ' DallaData
            '
            e.InputParameters("DallaData") = CType(txtDallaData.Text, DateTime)
            '
            ' AllaData: puo essere vuoto (default), quindi devo passare nothing
            '
            Dim dtAllaData As Nullable(Of Date)
            If Not String.IsNullOrEmpty(txtAllaData.Text) Then
                dtAllaData = CType(txtAllaData.Text, DateTime)
            End If
            e.InputParameters("AllaData") = dtAllaData
            '
            ' Max rows
            '
            e.InputParameters("MaxReinvii") = CType(txtMaxNumRecords.Text, Integer)


        Catch ex As Exception
            ' In caso di errore  non faccio eseguire la query dell'object data source
            e.Cancel = True
            '
            '
            '
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub

    Private Function ValidateFilters() As Boolean
        Dim sValidationMessage As String = String.Empty
        Try
            If String.IsNullOrEmpty(txtDallaData.Text) Then
                sValidationMessage = String.Format("Il parametro '{0}' è obbligatorio.", lblFilterDallaData.Text)
            Else
                If Not Utility.SQLTypes.IsValidDateTime(txtDallaData.Text) Then
                    sValidationMessage = String.Format("Il parametro '{0}' non contiene una data valida.", lblFilterDallaData.Text)
                End If
            End If

            If Not String.IsNullOrEmpty(txtAllaData.Text) AndAlso Not Utility.SQLTypes.IsValidDateTime(txtAllaData.Text) Then
                sValidationMessage = String.Format("Il parametro '{0}' non contiene una data valida.", lblFilterAllaData.Text)
            End If

            If String.IsNullOrEmpty(txtMaxNumRecords.Text) Then
                sValidationMessage = String.Format("Il parametro '{0}' è obbligatorio.", lblFilterMaxRecords.Text)
            Else
                Dim iResult As Integer
                If Not Integer.TryParse(txtMaxNumRecords.Text, iResult) Then
                    sValidationMessage = String.Format("Il parametro '{0}' deve essere un numero intero.", lblFilterMaxRecords.Text)
                End If
            End If
            '
            '
            '
            If Not String.IsNullOrEmpty(sValidationMessage) Then
                '
                ' Mostro l'intero messaggio di validazione
                '
                Utility.ShowErrorLabel(LabelError, sValidationMessage)
                '
                ' Nascondo 
                '
                lblMaxNumRow.Visible = False
            End If
            '
            ' Restituisco false se ci sono degli errori di validazione
            '
            Return String.IsNullOrEmpty(sValidationMessage)
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Function

    Private Sub btnRinotifica_Click(sender As Object, e As EventArgs) Handles btnRiprocessa.Click
        Try

            'IMPOSTO IL CURSORE D'ATTESA
            Dim functionJS As String = "ChangeCursor();"
            ScriptManager.RegisterStartupScript(Page, Page.GetType, "ChangeCursor", functionJS, True)

            '
            'Mostro la progress bar
            '
            progressbar.Visible = True

            btnAnnullaRiprocessa.Enabled = True

            '
            'Attivo il timer
            '
            Timer1.Enabled = True
        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(LabelError, sMessage)
        End Try
    End Sub

    Private Sub btnAnnulla_Click(sender As Object, e As EventArgs) Handles btnAnnulla.Click
        Try
            '
            'Resetto i filtri.
            '
            FilterHelper.Clear(pannelloFiltri, msPAGEKEY)

            '
            'Nascondo le label della pagina e la griglia
            '
            lblMaxNumRow.Visible = False
            lblStatoNotifica.Text = ""

            gvReferti.Visible = False
        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(LabelError, sMessage)
        End Try
    End Sub

    Dim mListaProcessati As New List(Of OggettoProcessato)
    Private Sub ProcessaOggetto()
        Try
            Dim sId As String = String.Empty
            Dim row As DataRow = Nothing

            '
            'Contiene la lista dei Referti da notificare.
            '
            Dim listaOggettiDaProcessare As DataTable = Me.Sole_ListaOggettiDaProcessare

            '
            'Controllo se la lista dei ricoveri notificati è vuota. se non lo è la copio dentro mListaProcessati.
            '
            If Not Me.Sole_ListaOggettiProcessati Is Nothing AndAlso Me.Sole_ListaOggettiProcessati.Count <> 0 Then
                mListaProcessati = Me.Sole_ListaOggettiProcessati
            End If

            '
            'Vado avanti solo se la lista dei Referti non è vuota.
            '
            If Not listaOggettiDaProcessare Is Nothing Then
                Dim dtOggetti As List(Of System.Data.DataRow) = listaOggettiDaProcessare.AsEnumerable().Take(MAX_RINOTIFICHE_PER_CICLO).ToList
                '
                'Vado avanti solo se la lista non è vuota.
                '
                If dtOggetti IsNot Nothing AndAlso dtOggetti.Count > 0 Then
                    '
                    'Ciclo tutte le row nella lista
                    '
                    For index = 0 To dtOggetti.Count - 1
                        Dim oOggettoProcessato As New OggettoProcessato

                        '
                        'Metto un Synclock quando prendo la righa e la rimuovo
                        '
                        SyncLock GlobalObject.gObjNotificaRefertiSynclock
                            '
                            'Ottengo la row del data table.
                            '
                            row = CType(dtOggetti.Item(index), DataRow)

                            '
                            'Ottengo l'id del referto.
                            '
                            sId = row.Item("IdReferto").ToString

                            '
                            'Rimuovo la riga dal dataset. In questo modo evito di processre lo stesso referto più volte.
                            '
                            listaOggettiDaProcessare.Rows.Remove(row)
                        End SyncLock
                        '
                        'Aggiungo all'oggetto l'id del ricovero.
                        '
                        oOggettoProcessato.Id = sId
                        Try
                            Using ta = New SoleTableAdapters.RefertiReinviaPerIdRefertoTableAdapter
                                '
                                ' Eseguo la SP SOLE per il processamento del singolo referto
                                '
                                ta.GetData(New Guid(sId), "DWH-ADMIN: Riprocessamento referto")
                                '
                                'Se è andata a buon fine allora stato Notifica = "OK" altrimenti scrivo "Errore"
                                '
                                oOggettoProcessato.StatoNotifica = "OK"
                            End Using

                        Catch ex As Exception
                            '
                            ' popolo la colonna "statoNotifica" e "Eccezione"
                            '
                            oOggettoProcessato.StatoNotifica = "Errore"
                            oOggettoProcessato.Eccezione = ex.Message
                        End Try
                        '
                        'Aggiungo alla lista dei referti processati il ricovero corrente.
                        '
                        mListaProcessati.Add(oOggettoProcessato)
                    Next
                    '
                    ' Salvo in sessione la lista dei referti processati.
                    ' A mListaProcessati durante il ciclo di processamento vengono rimossi i processati
                    '
                    Me.Sole_ListaOggettiProcessati = mListaProcessati
                End If
            End If

            '
            'Calcolo il valore della progressbar in base ai referti riprocessati
            '
            Dim value As Integer = (Me.Sole_ListaOggettiProcessati.Count * 100) / Me.NumOggettiTrovati
            Dim functionJS As String = "$(function () {$('.progressbar').progressbar({value:" + value.ToString + " });});"
            ScriptManager.RegisterStartupScript(Page, Page.GetType, "ChangeProgressBarValue", functionJS, True)

            '
            ' Aggiorno la variabile di sessione comtenente i referti da riprocessare
            '
            Me.Sole_ListaOggettiDaProcessare = listaOggettiDaProcessare
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub

    Private Sub Timer1_Tick(sender As Object, e As EventArgs) Handles Timer1.Tick
        Try
            '
            'Se il timer è disabilitato allora esco dalla function:
            'Questo nel caso in cui il timer ricominci prima che notificaReferto sia eseguito. In questo modo se il timer è stato disabilitato non esegue il codice.
            '
            If Timer1.Enabled = False Then
                Exit Sub
            End If
            Timer1.Enabled = False

            If Not Me.Sole_ListaOggettiDaProcessare Is Nothing AndAlso Me.Sole_ListaOggettiDaProcessare.Rows.Count > 0 Then
                '
                'abilito il bottone di annullamento se sono la notifica non è stata ancora completata.
                '
                btnAnnullaRiprocessa.Enabled = True
                '
                ' Processo un referto alla volta
                '
                Call ProcessaOggetto()
                '
                'Mostro il numero di referti che sono stati inseriti.
                '
                If Me.Sole_ListaOggettiProcessati IsNot Nothing Then
                    lblStatoNotifica.Text = String.Format("Processati {0} di {1} referti.", Me.Sole_ListaOggettiProcessati.Count.ToString, Me.NumOggettiTrovati.ToString)
                End If
                Timer1.Enabled = True
            Else
                '
                'Se sono qui l'inserimento è stato completato. 
                'Disabilito il bottone, campio il testo della label e blocco il timer.
                '
                btnAnnullaRiprocessa.Enabled = False
                lblStatoNotifica.Text = ""

                btnCerca.Enabled = True
                btnAnnulla.Enabled = True

                '
                'Mostro un alert quando la notifica è completa e mostro il bottone di esporta.
                '
                Dim functionJS As String = "alert('Notifica completata.\nÈ possibile verificare gli eventuali errori nel file excel.');$('.btn-esporta').css('display','block');$('.btn-cerca-annulla').removeAttr('disabled');$('body').css('cursor', 'default');"
                ScriptManager.RegisterStartupScript(Page, Page.GetType, "openModalNotificaCompleta", functionJS, True)

                '
                'Riabilito i pulsanti
                '
                btnAnnulla.Enabled = True
                btnCerca.Enabled = True
            End If

        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(LabelError, sMessage)
        End Try
    End Sub

    Private Sub btnAnnullaRiprocessa_Click(sender As Object, e As EventArgs) Handles btnAnnullaRiprocessa.Click
        '
        'L'EVENTO DEL BOTTONE VIENE ESEGUITO DOPO CHE IL TICK DEL TIMER E' TERMINATO
        '
        Try
            '
            'Disabilito il timer, svuoto la sessione e cambio la scritta.
            '
            Timer1.Enabled = False

            '
            '1) Mostro alert per Notifica Annullata
            '2) Mostro il pulsante btn-esporta
            '3) Riabilito i pulsanti "Cerca" e "Annulla"
            '
            Dim functionJS As String = "alert('Notifica annullata.\nÈ possibile verificare gli eventuali errori nel file excel.');$('.btn-esporta').css('display','block');$('.btn-cerca-annulla').removeAttr('disabled');$('body').css('cursor', 'default');"
            ScriptManager.RegisterStartupScript(Page, Page.GetType, "openModalNotificaAnnullata", functionJS, True)

            '
            ' Quando clicco su "Annulla" svuoto la sessione.
            ' In questo modo non verranno più inseriti referti. 
            '
            Me.Sole_ListaOggettiDaProcessare = Nothing
        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(LabelError, sMessage)
        End Try
    End Sub

    Private Sub btnEsportaInExcel_Click(sender As Object, e As EventArgs) Handles btnEsportaInExcel.Click
        Try
            '
            'Ottengo una IList dalla lista dei Referti Notificati in Sessione.
            '
            Dim ListOfEntity As IList = CType(Me.Sole_ListaOggettiProcessati, IList)

            If Not ListOfEntity Is Nothing AndAlso ListOfEntity.Count > 0 Then
                Using str As MemoryStream = Excel.AnyListToExcel(ListOfEntity, "LISTA_REFERTI_PROCESSATI")
                    If str IsNot Nothing Then
                        Response.Clear()
                        Response.Buffer = True
                        Response.AddHeader("content-disposition", "attachment;filename=" & "LISTA_REFERTI_PROCESSATI" & ".xlsx")
                        Response.ContentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
                        str.WriteTo(Response.OutputStream)
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

    Private Sub gvReferti_Sorting(sender As Object, e As GridViewSortEventArgs) Handles gvReferti.Sorting
        'Cosi viene rieseguita la query dell'object data source
        gvCancelSelect = False
    End Sub

#Region "Oggetti sessione"
    Private Const KEY_LISTA_OGGETTI_SOLE_DA_PROCESSARE As String = "Ref_61F6B2F0-58E5-40B4-B856-2AEE5BBA2651"
    Private Const KEY_LISTA_OGGETTI_SOLE_PROCESSATI As String = "Ref_317C95AF-E070-46F4-818C-DF0766A42769"
    Private Property Sole_ListaOggettiDaProcessare As DataTable
        '
        ' AGGIUNGE IN SESSIONE LA LISTA DEI REFERTI DA PROCESSARE
        '
        Get
            Return CType(HttpContext.Current.Session(KEY_LISTA_OGGETTI_SOLE_DA_PROCESSARE), System.Data.DataTable)
        End Get
        Set(value As DataTable)
            HttpContext.Current.Session(KEY_LISTA_OGGETTI_SOLE_DA_PROCESSARE) = value
        End Set
    End Property

    Private Property Sole_ListaOggettiProcessati As List(Of OggettoProcessato)
        '
        ' AGGIUNGE IN SESSIONE LA LISTA DEI REFERTI EFFETTIVAMENTE PROCESSATI.
        '
        Get
            Return CType(HttpContext.Current.Session(KEY_LISTA_OGGETTI_SOLE_PROCESSATI), List(Of OggettoProcessato))
        End Get
        Set(value As List(Of OggettoProcessato))
            HttpContext.Current.Session(KEY_LISTA_OGGETTI_SOLE_PROCESSATI) = value
        End Set
    End Property

    Private Class OggettoProcessato
        Public Property Id() As String
        Public Property StatoNotifica() As String
        Public Property Eccezione() As String
    End Class

#End Region





End Class