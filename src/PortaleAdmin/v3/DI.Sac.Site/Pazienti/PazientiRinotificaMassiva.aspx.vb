Imports System
Imports System.Collections
Imports System.Collections.Generic
Imports System.Data
Imports System.IO
Imports System.Web
Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports DI.PortalAdmin.Data
Imports DI.Sac.Admin
Imports DI.Sac.Admin.Data.PazientiDataSetTableAdapters

Public Class PazienteRinotificato
    Public Property Id() As String
    Public Property StatoNotifica() As String
    Public Property Eccezione() As String
End Class

Public Class PazientiRinotificaMassiva
    Inherits System.Web.UI.Page

    Private gObjNotificaPazientiSynclock As Object = New Object

#Region "PROPERY E VARIABILI"
    'USATA PER SALVARE IN SESSIONE I FILTRI.
    Private ReadOnly msPAGEKEY As String = Page.GetType().BaseType.FullName

    'INDICA IL MASSIMO NUMERO DI RECORD DA VISUALIZZARE.
    Private Const maxNumRec As Integer = 1000

    'INDICA SE E' STATO PREMUTO IL BOTTONE "CERCA"
    Dim btnClicked As Boolean = False

    'INDICA QUANTI PAZIENTI RINOTIFICARE ALLA VOLTA
    Private Const maxNumRinotifichePerCiclo As Integer = 50

    'INDICA IL NUMERO DI PAZIENTI TROVATI NEL PERIODO DI TEMPO SELEZIONATO.
    Protected Property numPazienti() As Integer
        Get
            Return ViewState("NumeroPazientiOttenuti")
        End Get
        Set(ByVal value As Integer)
            ViewState.Add("NumeroPazientiOttenuti", value)
        End Set
    End Property

    Protected Property listaPazienti As DataTable
        '
        ' AGGIUNGE IN SESSIONE LA LISTA DEI PAZIENTI DA RINOTIFICARE
        '
        Get
            Return CType(HttpContext.Current.Session("LISTA_PAZIENTI_DA_RINOTIFICARE"), System.Data.DataTable)
        End Get
        Set(value As DataTable)
            HttpContext.Current.Session("LISTA_PAZIENTI_DA_RINOTIFICARE") = value
        End Set
    End Property

    Protected Property listaPazientiRinotificati As List(Of PazienteRinotificato)
        '
        ' AGGIUNGE IN SESSIONE LA LISTA DEI PAZIENTI DA RINOTIFICARE
        '
        Get
            Return CType(HttpContext.Current.Session("LISTA_PAZIENTI_RINOTIFICATI"), List(Of PazienteRinotificato))
        End Get
        Set(value As List(Of PazienteRinotificato))
            HttpContext.Current.Session("LISTA_PAZIENTI_RINOTIFICATI") = value
        End Set
    End Property
#End Region

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Try
            '
            'SETTO IL BOTTONE DI DEFAULT
            '
            Page.Form.DefaultButton = btnCerca.UniqueID

            If Not Page.IsPostBack Then
                'RICARICO I FILTRI DALLA SESSIONE
                FilterHelper.Restore(pannelloFiltri, msPAGEKEY)

                'NASCONDO LA PROGRESS BAR
                progressbar.Visible = False
                lblStatoNotifica.Text = ""
            End If

            'RESETTO LO STATO DELLA VARIABILE "btnClicked".
            btnClicked = False

        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub

    Private Sub btnCerca_Click(sender As Object, e As EventArgs) Handles btnCerca.Click
        Try
            'SVUOTO DALLA SESSIONE LA LISTA DEI PAZIENTI DA RINOTIFICARE.
            Me.listaPazientiRinotificati = Nothing

            'QUANDO PREMO IL TASTO "CERCA" SVUOTO LA LABEL DI STATO DELLA NOTIFICA.
            lblStatoNotifica.Text = ""
            LabelError.Visible = False

            'SETTO CHE HO CLICCATO "CERCA"
            btnClicked = True

            '
            'SALVO IN SESSIONE I FILTRI.
            '
            FilterHelper.SaveInSession(pannelloFiltri, msPAGEKEY)



            'ESEGUO IL BIND DELLA GRIGLIA.
            gvPazientiModificati.DataBind()

            '
            '2020-07-02 Kyrylo: Traccia Operazioni
            '
            Dim oTracciaOp As New TracciaOperazioniManager(Global_asax.ConnectionStringPortalAdmin)
            oTracciaOp.TracciaOperazione(PortalsNames.Sac, Page.AppRelativeVirtualPath, "Ricerca pazienti", pannelloFiltri, Nothing)


        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub

    Private Sub odsPazientiModificati_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsPazientiModificati.Selected
        Try
            If Not GestioneErrori.ObjectDataSource_TrapError(e, LabelError) Then
                'ABILITO IL PULSANTE DI RINOTIFICA.
                btnRinotifica.Enabled = True
                'MOSTRO LA LABEL.
                lblMaxNumRow.Visible = True
                'MOSTRO LA GRIDVIEW.
                gvPazientiModificati.Visible = True

                'OTTENGO IL DATA TABLE.
                Dim dtPazienti = CType(e.ReturnValue, DataTable)

                'OTTENGO IL NUMERO DI ROW CONTENUTE NEL DATA TABLE.
                Me.numPazienti = dtPazienti.Rows.Count

                Dim sMessage As String = String.Format("La ricerca ha prodotto {0} record.", Me.numPazienti)

                'SE IL NUMERO DI RECORD RESTITUITO DALLA SELECT È MAGGIORE DI maxNumRecord(1000) ALLORA NASCONDO LA GRIGLIA.
                If Me.numPazienti > maxNumRec Then
                    sMessage = String.Format("La ricerca ha prodotto {0} record. Raffinare la ricerca.", Me.numPazienti)
                    gvPazientiModificati.Visible = False
                ElseIf Me.numPazienti = 0 Then
                    btnRinotifica.Enabled = False
                    lblMaxNumRow.Visible = False
                End If

                'VALORIZZO LA LABEL.
                lblMaxNumRow.Text = sMessage

                '
                'SALVO IN SESSIONE LA LISTA DEI PAZIENTI DA NOTIFICARE.
                '
                Me.listaPazienti = dtPazienti
            End If
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub

    Private Sub odsPazientiModificati_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsPazientiModificati.Selecting
        Try
            'VALIDO I FILTRI "DataModificaDal" e "DataModificaAl"
            If ValidaFiltri() = False Then
                e.Cancel = True
                Exit Sub
            End If

            'SETTO IL PARAMENTRO DataModificaDal
            e.InputParameters("DataModificaDal") = CType(txtDataModificaDal.Text, DateTime)

            'SE txtDataModificaAl E' VUOTA ALLORA PASSO NOTHING ALTRIMENTI CASTO A DATETIME.
            Dim dDataModificaAl As Nullable(Of DateTime) = Nothing
            If Not String.IsNullOrEmpty(txtDataModificaAl.Text) Then
                dDataModificaAl = CType(txtDataModificaAl.Text, DateTime)
            End If
            e.InputParameters("DataModificaAl") = dDataModificaAl
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub

    Private Sub timerRinotifica_Tick(sender As Object, e As EventArgs) Handles timerRinotifica.Tick
        Try
            '
            'SE IL TIMER È DISABILITATO ALLORA ESCO DALLA FUNCTION:
            'QUESTO NEL CASO IN CUI IL TIMER RICOMINCI PRIMA CHE NOTIFICAREFERTO SIA ESEGUITO. IN QUESTO MODO SE IL TIMER È STATO DISABILITATO NON ESEGUE IL CODICE.
            '
            If timerRinotifica.Enabled = False Then
                Exit Sub
            End If
            timerRinotifica.Enabled = False

            'CONTROLLO SE LA LISTA NON È VUOTA E MAGGIORE DI 0
            If Not Me.listaPazienti Is Nothing AndAlso Me.listaPazienti.Rows.Count > 0 Then

                'ABILITO IL BOTTONE DI ANNULLAMENTO SE SONO LA NOTIFICA NON È STATA ANCORA COMPLETATA.
                btnAnnullaRinotifica.Enabled = True

                'NOTIFICO I PAZIENTI
                NotificaPaziente()

                'MOSTRO IL NUMERO DI PAZIENTI CHE SONO STATI RINOTIFICATI.
                If Me.listaPazientiRinotificati IsNot Nothing Then
                    lblStatoNotifica.Text = String.Format("Notificati {0} di {1} pazienti.", Me.listaPazientiRinotificati.Count.ToString, Me.numPazienti.ToString)
                End If

                'RIATTIVO IL TIMER.
                timerRinotifica.Enabled = True
            Else
                'SE SONO QUI L'INSERIMENTO È STATO COMPLETATO. 
                'DISABILITO IL BOTTONE, CAMPIO IL TESTO DELLA LABEL E BLOCCO IL TIMER.
                btnAnnullaRinotifica.Enabled = False

                lblStatoNotifica.Text = ""

                'MOSTRO UN ALERT QUANDO LA NOTIFICA È COMPLETA E MOSTRO IL BOTTONE DI ESPORTA.
                Dim functionJS As String = "alert('Notifica completata.\nÈ possibile verificare gli eventuali errori nel file excel.');$('.btn-esporta').css('display','block');$('body').css('cursor', 'default');$('.TabButton').removeAttr('disabled');"
                ScriptManager.RegisterStartupScript(Page, Page.GetType, "openModalNotificaCompleta", functionJS, True)
            End If
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub

    Private Function ValidaFiltri() As Boolean
        Try
            Dim bStato As Boolean = True

            '
            'SE HO PREMUTO IL BOTTONE CERCA O NOTIFICA ALLORA DALLA-DATA E ALLA-DATA DEVONO ESSERE VALORIZZATE.
            'VALIDO FILTRI TESTA LE DATE SONO SE SONO STATI PREMUTI I PULSANTI "CERCA" O "NOTIFICA".
            'NEL SELECTING DELL' ODS TESTO NUOVAMENTE LE DATE IN MODO DA NON FARE LA QUERY LA PRIMA VOLTA.
            'IN QUESTO MODO EVITO DI MOSTRARE UN MESSAGGIO DI ERRORE LA PRIMA VOLTA CHE APRO LA PAGINA.
            '
            If btnClicked = True Then
                If String.IsNullOrEmpty(txtDataModificaDal.Text) Then
                    Utility.ShowErrorLabel(LabelError, "Valorizzare il parametro 'Data modifica dal.'")
                    bStato = False
                End If
            Else
                'SE SONO QUI È LA PRIMA VOLTA CHE ACCEDO ALLA PAGINA.
                'SE E' LA PRIMA VOLTA CHE ACCEDO NON FACCIO ESEGUIRE LA QUERY MA NON MOSTRO IL MESSAGGIO DI ERRORE.
                If String.IsNullOrEmpty(txtDataModificaDal.Text) Then
                    bStato = False
                End If
            End If

            '
            'CONTROLLO CHE DALLA-DATA E ALLA-DATA SIANO DATE VALIDE.
            '
            If (txtDataModificaDal.Text.Length > 0 AndAlso Not Utility.IsValidDateTime(txtDataModificaDal.Text)) OrElse (txtDataModificaAl.Text.Length > 0 AndAlso Not Utility.IsValidDateTime(txtDataModificaAl.Text)) Then
                Utility.ShowErrorLabel(LabelError, "Il campo 'Dalla Data' o 'Alla Data' non è una data valida.")
                bStato = False
            End If

            'If bStato = False Then
            '    lblMaxNumRow.Visible = False
            'End If

            Return bStato
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Function

    Private Sub btnRinotifica_Click(sender As Object, e As EventArgs) Handles btnRinotifica.Click
        Try
            'IMPOSTO IL CURSORE D'ATTESA
            Dim functionJS As String = "ChangeCursor();$('.TabButton').attr('disabled','disabled');"
            ScriptManager.RegisterStartupScript(Page, Page.GetType, "ChangeCursor", functionJS, True)

            'MOSTRO LA PROGRESS BAR
            progressbar.Visible = True

            'ABILITO IL PULSANTE DI ANNULLAMENTO DELLA RINOTIFICA.
            btnAnnullaRinotifica.Enabled = True

            'ATTIVO IL TIMER.
            timerRinotifica.Enabled = True
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub

    Dim mListaProcessati As New List(Of PazienteRinotificato)
    Private Sub NotificaPaziente()
        Try
            Dim sIdPaziente As String = String.Empty
            Dim row As DataRow = Nothing

            'CONTIENE LA LISTA DEI PAZIENTI DA NOTIFICARE.
            Dim listaPazientiDaNotificare As DataTable = Me.listaPazienti

            'CONTROLLO SE LA LISTA DEI PAZIENTI NOTIFICATI È VUOTA. SE NON LO È LA COPIO DENTRO MLISTAPROCESSATI.
            If Not Me.listaPazientiRinotificati Is Nothing AndAlso Me.listaPazientiRinotificati.Count <> 0 Then
                mListaProcessati = Me.listaPazientiRinotificati
            End If

            'VADO AVANTI SOLO SE LA LISTA DEI PAZIENTI NON È VUOTA.
            If Not listaPazientiDaNotificare Is Nothing Then
                Dim dtTopPazienti As List(Of System.Data.DataRow) = listaPazientiDaNotificare.AsEnumerable().Take(maxNumRinotifichePerCiclo).ToList

                'VADO AVANTI SOLO SE LA LISTA NON È VUOTA.
                If dtTopPazienti IsNot Nothing AndAlso dtTopPazienti.Count > 0 Then

                    'CICLO TUTTE LE ROW NELLA LISTA
                    For index = 0 To dtTopPazienti.Count - 1
                        Dim pazienteProcessato As New PazienteRinotificato

                        'METTO UN SYNCLOCK QUANDO PRENDO LA RIGHA E LA RIMUOVO
                        SyncLock gObjNotificaPazientiSynclock
                            'OTTENGO LA ROW DEL DATA TABLE.
                            row = CType(dtTopPazienti.Item(index), DataRow)

                            'OTTENGO L'ID DEL REFERTO.
                            sIdPaziente = row.Item("ID").ToString

                            'RIMUOVO LA RIGA DAL DATASET. IN QUESTO MODO EVITO DI PROCESSRE LO STESSO REFERTO PIÙ VOLTE.
                            listaPazientiDaNotificare.Rows.Remove(row)
                        End SyncLock

                        'AGGIUNGO ALL'OGGETTO L'ID DEL RICOVERO.
                        pazienteProcessato.Id = sIdPaziente

                        Try
                            Using adapter = New FunctionTableAdapter()
                                Dim Utente As String = User.Identity.Name
                                adapter.PazientiUiRinotificaPazienteAttivo(New Guid(sIdPaziente), Utente)

                                'SE È ANDATA A BUON FINE ALLORA STATO NOTIFICA = "OK" ALTRIMENTI SCRIVO "ERRORE"
                                pazienteProcessato.StatoNotifica = "OK"
                            End Using
                        Catch ex As Exception
                            'POPOLO LA COLONNA "STATONOTIFICA" E "ECCEZIONE"
                            pazienteProcessato.StatoNotifica = "Errore"
                            pazienteProcessato.Eccezione = ex.Message
                        End Try


                        'AGGIUNGO ALLA LISTA DEI PAZIENTI PROCESSATI IL RICOVERO CORRENTE.
                        mListaProcessati.Add(pazienteProcessato)
                    Next

                    'SALVO IN SESSIONE LA LISTA DEI PAZIENTI PROCESSATI.
                    Me.listaPazientiRinotificati = mListaProcessati
                End If
            End If

            'CALCOLO IL VALORE DELLA PROGRESSBAR IN BASE AI PAZIENTI NOTIFICATI
            Dim value As Integer
            value = (Me.listaPazientiRinotificati.Count * 100) / Me.numPazienti
            Dim functionJS As String = "$(function () {$('.progressbar').progressbar({value:" + value.ToString + " });});"
            ScriptManager.RegisterStartupScript(Page, Page.GetType, "ChangeProgressBarValue", functionJS, True)

            '
            'Aggiorno la variabile di sessione
            '
            Me.listaPazienti = listaPazientiDaNotificare
        Catch ex As Exception

        End Try
    End Sub

    Private Sub btnAnnullaRinotifica_Click(sender As Object, e As EventArgs) Handles btnAnnullaRinotifica.Click
        '
        'L'EVENTO DEL BOTTONE VIENE ESEGUITO DOPO CHE IL TICK DEL TIMER E' TERMINATO
        '
        Try
            'DISABILITO IL TIMER, SVUOTO LA SESSIONE E CAMBIO LA SCRITTA.
            timerRinotifica.Enabled = False

            lblStatoNotifica.Text = ""

            '
            '1) MOSTRO ALERT PER NOTIFICA ANNULLATA
            '2) MOSTRO IL PULSANTE BTN-ESPORTA
            '3) RIABILITO I PULSANTI "CERCA" E "ANNULLA"
            '
            Dim functionJS As String = "alert('Notifica annullata.\nÈ possibile verificare gli eventuali errori nel file excel.');$('.btn-esporta').css('display','block');$('body').css('cursor', 'default');$('.TabButton').removeAttr('disabled');"
            ScriptManager.RegisterStartupScript(Page, Page.GetType, "openModalNotificaAnnullata", functionJS, True)

            '
            'QUANDO CLICCO SU "ANNULLA RINOTIFICA" SVUOTO LA SESSIONE.
            'IN QUESTO MODO NON VERRANNO PIÙ INSERITI PAZIENTI. 
            '
            Me.listaPazienti = Nothing
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub

    Private Sub btnEsportaPazienti_Click(sender As Object, e As EventArgs) Handles btnEsportaPazienti.Click
        Try
            '
            'Ottengo una IList dalla lista dei Pazienti Notificati in Sessione.
            '
            Dim ListOfEntity As IList = CType(Me.listaPazientiRinotificati, IList)

            If Not ListOfEntity Is Nothing AndAlso ListOfEntity.Count > 0 Then
                Using str As MemoryStream = Excel.AnyListToExcel(ListOfEntity, "LISTA_PAZIENTI_NOTIFICATI")
                    If str IsNot Nothing Then
                        Response.Clear()
                        Response.Buffer = True
                        Response.AddHeader("content-disposition", "attachment;filename=" & "LISTA_PAZIENTI_NOTIFICATI" & ".xlsx")
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
End Class