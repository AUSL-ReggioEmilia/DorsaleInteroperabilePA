Imports System
Imports System.Collections
Imports System.Collections.Generic
Imports System.Data
Imports System.IO
Imports System.Linq
Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports DI.DataWarehouse.Admin
Imports DI.PortalAdmin.Data

Public Class RinotificaMassivaReferti
    Inherits System.Web.UI.Page
    Private ReadOnly msPAGEKEY As String = Page.GetType().BaseType.FullName

    '
    'Indica il massimo numero di record da visualizzare.
    '
    Private Const maxNumRec As Integer = 1000
    Private Const maxNumRinotifichePerCiclo As Integer = 50

    Dim btnClicked As Boolean = False

    '
    'Indica il numero di referti restituiti dalla ricerca.
    '
    Protected Property numReferti() As Integer
        Get
            Return ViewState("NumeroRefertiOttenuti")
        End Get
        Set(ByVal value As Integer)
            ViewState.Add("NumeroRefertiOttenuti", value)
        End Set
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Try
            '
            'SETTO IL BOTTONE DI DEFAULT
            '
            Page.Form.DefaultButton = butFiltriRicerca.UniqueID
            If Not Page.IsPostBack Then
                cmbSistemaErogante.DataBind()


                '
                'RICARICO I FILTRI DALLA SESSIONE
                '
                FilterHelper.Restore(pannelloFiltri, msPAGEKEY)

                '
                'Nascondo la progress bar
                '
                progressbar.Visible = False
            End If
            btnClicked = False
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub

    Private Sub butFiltriRicerca_Click(sender As Object, e As EventArgs) Handles butFiltriRicerca.Click
        Try
            SessionHandler.listaRefertiNotificati = Nothing

            '
            'Quando premo il tasto "cerca" svuoto la label di stato della notifica.
            '
            lblStatoNotifica.Text = ""
            LabelError.Visible = False
            btnClicked = True

            '
            'SALVO IN SESSIONE I FILTRI.
            '
            FilterHelper.SaveInSession(pannelloFiltri, msPAGEKEY)
            gvReferti.DataBind()


            '
            '2020-07-03 Kyrylo: Traccia Operazioni
            '
            Dim oTracciaOp As New TracciaOperazioniManager(Global_asax.ConnectionStringPortalAdmin)
            oTracciaOp.TracciaOperazione(PortalsNames.DwhClinico, Page.AppRelativeVirtualPath, "Ricerca referti", pannelloFiltri, Nothing)


        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub

    Private Sub RefertiOds_Selected(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles RefertiOds.Selected
        Try
            '
            'GESTIONE ERRORE
            '
            If Not GestioneErrori.ObjectDataSource_TrapError(e, LabelError) Then
                btnRinotifica.Enabled = True
                lblMaxNumRow.Visible = True
                gvReferti.Visible = True

                '
                'Ottengo il data table.
                '
                Dim eG = CType(e.ReturnValue, DataTable)

                '
                'Ottengo il numero di row contenute nel data table.
                '
                Me.numReferti = eG.Rows.Count

                Dim sMessage As String = String.Format("La ricerca ha prodotto {0} record.", Me.numReferti)

                If Me.numReferti > maxNumRec Then
                    sMessage = String.Format("La ricerca ha prodotto {0} record. Raffinare la ricerca.", Me.numReferti)
                    gvReferti.Visible = False
                ElseIf Me.numReferti = 0 Then
                    btnRinotifica.Enabled = False
                    lblMaxNumRow.Visible = False
                End If

                lblMaxNumRow.Text = sMessage

                '
                'SALVO IN SESSIONE LA LISTA DEI REFERTI DA NOTIFICARE.
                '
                SessionHandler.listaReferti = eG
            End If

        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub

    Private Sub RefertiOds_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles RefertiOds.Selecting
        Try
            '
            'VALIDO FILTRI TESTA LE DATE SONO SE SONO STATI PREMUTI I PULSANTI "CERCA" O "NOTIFICA".
            'QUI TESTO NUOVAMENTE LE DATE IN MODO DA NON FARE LA QUERY LA PRIMA VOLTA.
            'IN QUESTO MODO EVITO DI MOSTRARE UN MESSAGGIO DI ERRORE LA PRIMA VOLTA CHE APRO LA PAGINA.
            '
            If ValidaFiltri() = False OrElse String.IsNullOrEmpty(txtDallaData.Text) Then
                e.Cancel = True
                Exit Sub
            End If

            e.InputParameters("DallaData") = CType(txtDallaData.Text, DateTime)


            Dim sDataModificaAl As String = txtAllaData.Text
            'NEL CASO DI [DATA MODIFICA AL] CON ORARIO 00:00:00 IMPOSTO 23:59:59 PER INCLUDERE TUTTA LA GIORNATA
            If sDataModificaAl.Length > 0 Then
                Dim dt As DateTime
                If DateTime.TryParse(sDataModificaAl, dt) Then
                    If dt.Hour = 0 AndAlso dt.Minute = 0 AndAlso dt.Second = 0 Then
                        '{0:s} è un SortableDateTime : "2015-03-09T16:05:07"
                        sDataModificaAl = String.Format("{0:s}", New DateTime(dt.Year, dt.Month, dt.Day, 23, 59, 59, 999))
                        e.InputParameters("AllaData") = CType(sDataModificaAl, DateTime)
                    End If
                End If
            End If

            'VALORIZZO AZIENDA E SISTEMA SOLO SE NON È VALORIZZATO L'ID DEL PAZIENTE.
            If String.IsNullOrEmpty(txtIdPaziente.Text) Then
                e.InputParameters("aziendaErogante") = cmbAziendaErogante.SelectedValue
                e.InputParameters("sistemaErogante") = cmbSistemaErogante.SelectedValue
            End If


            If String.IsNullOrEmpty(txtIdPaziente.Text) Then
                e.InputParameters("idPaziente") = Nothing
            Else
                '
                'viene controllato se è un guid corretto dentro ValidaFiltri()
                '
                e.InputParameters("idPaziente") = New Guid(txtIdPaziente.Text)
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
                If String.IsNullOrEmpty(txtDallaData.Text) Then
                    Utility.ShowErrorLabel(LabelError, "Per effettuare la ricerca compilare una delle combinazioni di filtri come indicato.")
                    bStato = False
                End If
            End If

            If btnClicked = True Then
                If String.IsNullOrEmpty(txtIdPaziente.Text) Then
                    If String.IsNullOrEmpty(cmbSistemaErogante.SelectedValue) OrElse String.IsNullOrEmpty(cmbAziendaErogante.SelectedValue) Then
                        Utility.ShowErrorLabel(LabelError, "Per effettuare la ricerca compilare una delle combinazioni di filtri come indicato.")
                        bStato = False
                    End If
                End If
            End If

            '
            'CONTROLLO CHE DALLA-DATA E ALLA-DATA SIANO DATE VALIDE.
            '
            If (txtDallaData.Text.Length > 0 AndAlso Not Utility.SQLTypes.IsValidDateTime(txtDallaData.Text)) OrElse (txtAllaData.Text.Length > 0 AndAlso Not Utility.SQLTypes.IsValidDateTime(txtAllaData.Text)) Then
                Utility.ShowErrorLabel(LabelError, "Il campo 'Dalla Data' o 'Alla Data' non è una data valida.")
                bStato = False
            End If

            '
            'CONTROLLO CHE L'ID PAZIENTE INSERITO SIA UN GUID CORRETTO.
            '
            If txtIdPaziente.Text.Length > 0 AndAlso Not Utility.SQLTypes.IsValidGuid(txtIdPaziente.Text) Then
                Utility.ShowErrorLabel(LabelError, "Il campo 'Id Paziente' non è un guid valido.")
                bStato = False
            End If

            If bStato = False Then
                lblMaxNumRow.Visible = False
            End If

            Return bStato
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Function

    Private Sub btnRinotifica_Click(sender As Object, e As EventArgs) Handles btnRinotifica.Click
        Try

            'IMPOSTO IL CURSORE D'ATTESA
            Dim functionJS As String = "ChangeCursor();"
            ScriptManager.RegisterStartupScript(Page, Page.GetType, "ChangeCursor", functionJS, True)

            '
            'Mostro la progress bar
            '
            progressbar.Visible = True

            btnAnnullaRinotifica.Enabled = True

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

    Private Sub cmbSistemaErogante_DataBound(sender As Object, e As System.EventArgs) Handles cmbSistemaErogante.DataBound
        Try
            cmbSistemaErogante.Items.Insert(0, "")
        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(LabelError, sMessage)
        End Try
    End Sub

    Dim mListaProcessati As New List(Of RefertoNotificato)
    Private Sub NotificaReferto()
        Try
            Dim sIdReferto As String = String.Empty
            Dim row As DataRow = Nothing

            '
            'Contiene la lista dei Referti da notificare.
            '
            Dim listaRefertiDaNotificare As DataTable = SessionHandler.listaReferti

            '
            'Controllo se la lista dei referti notificati è vuota. se non lo è la copio dentro mListaProcessati.
            '
            If Not SessionHandler.listaRefertiNotificati Is Nothing AndAlso SessionHandler.listaRefertiNotificati.Count <> 0 Then
                mListaProcessati = SessionHandler.listaRefertiNotificati
            End If

            '
            'Vado avanti solo se la lista dei Referti non è vuota.
            '
            If Not listaRefertiDaNotificare Is Nothing Then
                Dim dtTop100Referti As List(Of System.Data.DataRow) = listaRefertiDaNotificare.AsEnumerable().Take(maxNumRinotifichePerCiclo).ToList

                '
                'Vado avanti solo se la lista non è vuota.
                '
                If dtTop100Referti IsNot Nothing AndAlso dtTop100Referti.Count > 0 Then



                    '
                    'Ciclo tutte le row nella lista
                    '
                    For index = 0 To dtTop100Referti.Count - 1
                        Dim refertoProcessato As New RefertoNotificato

                        '
                        'Metto un Synclock quando prendo la righa e la rimuovo
                        '
                        SyncLock GlobalObject.gObjNotificaRefertiSynclock
                            '
                            'Ottengo la row del data table.
                            '
                            row = CType(dtTop100Referti.Item(index), DataRow)

                            '
                            'Ottengo l'id del referto.
                            '
                            sIdReferto = row.Item("ID").ToString

                            '
                            'Rimuovo la riga dal dataset. In questo modo evito di processre lo stesso referto più volte.
                            '
                            listaRefertiDaNotificare.Rows.Remove(row)
                        End SyncLock

                        '
                        'Aggiungo all'oggetto l'id del referto.
                        '
                        refertoProcessato.Id = sIdReferto

                        Try
                            Using da = New RefertiDataSetTableAdapters.QueriesTableAdapter
                                da.BeRefertiNotificaById(New Guid(sIdReferto))

                                '
                                'Se è andata a buon fine allora stato Notifica = "OK" altrimenti scrivo "Errore"
                                '
                                refertoProcessato.StatoNotifica = "OK"
                            End Using

                        Catch ex As Exception
                            '
                            ' popolo la colonna "statoNotifica" e "Eccezione"
                            '
                            refertoProcessato.StatoNotifica = "Errore"
                            refertoProcessato.Eccezione = ex.Message
                        End Try


                        '
                        'Aggiungo alla lista dei referti processati il referto corrente.
                        '
                        mListaProcessati.Add(refertoProcessato)
                    Next

                    '
                    'Salvo in sessione la lista dei referti processati.
                    '
                    SessionHandler.listaRefertiNotificati = mListaProcessati
                End If
            End If

            '
            'Calcolo il valore della progressbar in base ai referti notificati
            '
            Dim value As Integer
            value = (SessionHandler.listaRefertiNotificati.Count * 100) / Me.numReferti
            Dim functionJS As String = "$(function () {$('.progressbar').progressbar({value:" + value.ToString + " });});"
            ScriptManager.RegisterStartupScript(Page, Page.GetType, "ChangeProgressBarValue", functionJS, True)

            '
            'Aggiorno la variabile di sessione
            '
            SessionHandler.listaReferti = listaRefertiDaNotificare
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

            If Not SessionHandler.listaReferti Is Nothing AndAlso SessionHandler.listaReferti.Rows.Count > 0 Then
                '
                'abilito il bottone di annullamento se sono la notifica non è stata ancora completata.
                '
                btnAnnullaRinotifica.Enabled = True

                '
                'Notifico i referti
                '
                NotificaReferto()

                '
                'Mostro il numero di referti che sono stati inseriti.
                '
                If SessionHandler.listaRefertiNotificati IsNot Nothing Then
                    lblStatoNotifica.Text = String.Format("Notificati {0} di {1} referti.", SessionHandler.listaRefertiNotificati.Count.ToString, Me.numReferti.ToString)
                End If
                Timer1.Enabled = True
            Else
                '
                'Se sono qui l'inserimento è stato completato. 
                'Disabilito il bottone, campio il testo della label e blocco il timer.
                '
                btnAnnullaRinotifica.Enabled = False
                lblStatoNotifica.Text = ""

                butFiltriRicerca.Enabled = True
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
                butFiltriRicerca.Enabled = True

                '
                '2020-07-10 Kyrylo: Traccia Operazioni
                '

                Dim idRefertiNotificati As List(Of String) = New List(Of String)

                ' Ottengo tutti gli id dei referti rinotificati
                For Each refertoNotificato As RefertoNotificato In SessionHandler.listaRefertiNotificati
                    idRefertiNotificati.Add(refertoNotificato.Id)
                Next

                ' Traccio l'operazione di ritotifica con tutti gli id dei referti notificiati
                Dim oTracciaOp As New TracciaOperazioniManager(Global_asax.ConnectionStringPortalAdmin)
                oTracciaOp.TracciaOperazione(PortalsNames.DwhClinico, Page.AppRelativeVirtualPath, "Rinotificati massivamente referti", idRefertiNotificati, idPaziente:=Nothing)


            End If

        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(LabelError, sMessage)
        End Try
    End Sub

    Private Sub btnAnnullaRinotifica_Click(sender As Object, e As EventArgs) Handles btnAnnullaRinotifica.Click
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
            'Quando clicco su "Annulla Rinotifica" svuoto la sessione.
            'In questo modo non verranno più inseriti referti. 
            '
            SessionHandler.listaReferti = Nothing
        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(LabelError, sMessage)
        End Try
    End Sub

    Private Sub odsSistemiEroganti_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsSistemiEroganti.Selected
        GestioneErrori.ObjectDataSource_TrapError(e, LabelError)
    End Sub

    Private Sub btnEsportaReferti_Click(sender As Object, e As EventArgs) Handles btnEsportaReferti.Click
        Try
            '
            'Ottengo una IList dalla lista dei Referti Notificati in Sessione.
            '
            Dim ListOfEntity As IList = CType(SessionHandler.listaRefertiNotificati, IList)

            If Not ListOfEntity Is Nothing AndAlso ListOfEntity.Count > 0 Then
                Using str As MemoryStream = Excel.AnyListToExcel(ListOfEntity, "LISTA_REFERTI_NOTIFICATI")
                    If str IsNot Nothing Then
                        Response.Clear()
                        Response.Buffer = True
                        Response.AddHeader("content-disposition", "attachment;filename=" & "LISTA_REFERTI_NOTIFICATI" & ".xlsx")
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

    Private Sub gvReferti_RowDataBound(sender As Object, e As GridViewRowEventArgs) Handles gvReferti.RowDataBound
        Try
            If e.Row.RowType = DataControlRowType.DataRow Then
                Dim rw As DataRowView = e.Row.DataItem
                Dim oRow As RefertiDataSet.BeRefertiNotificaListaRow = rw.Row
                If Not oRow.IsCodiceOscuramentoNull Then
                    e.Row.CssClass = "StileRicoveroOscurato"
                End If
            End If
        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(LabelError, sMessage)
        End Try
    End Sub

    Private Sub cmbAziendaErogante_PreRender(sender As Object, e As EventArgs) Handles cmbAziendaErogante.PreRender
        Try
            Dim listItem As New ListItem With {.Text = "", .Value = ""}
            If cmbAziendaErogante.Items.IndexOf(listItem) = -1 Then
                cmbAziendaErogante.Items.Insert(0, listItem)
            End If
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub
End Class