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

Public Class RinotificaMassivaRicoveri
    Inherits System.Web.UI.Page


    Private ReadOnly msPAGEKEY As String = Page.GetType().BaseType.FullName
    '
    'Indica il massimo numero di record da visualizzare.
    '
    Private Const maxNumRec As Integer = 1000
    Private Const maxNumRinotifichePerCiclo As Integer = 50


    Dim btnClicked As Boolean = False


    '
    'Indica il numero di ricoveri restituiti dalla ricerca.
    '
    Protected Property numRicoveri() As Integer
        Get
            Return ViewState("NumeroRicoveriOttenuti")
        End Get
        Set(ByVal value As Integer)
            ViewState.Add("NumeroRicoveriOttenuti", value)
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
            '
            'Svuoto la variabile di sessione
            '
            SessionHandler.listaRicoveriNotificati = Nothing

            lblStatoNotifica.Text = ""
            LabelError.Visible = False
            btnClicked = True

            '
            'SALVO IN SESSIONE I FILTRI.
            '
            FilterHelper.SaveInSession(pannelloFiltri, msPAGEKEY)
            gvRicoveri.DataBind()

            '
            '2020-07-10 Kyrylo: Traccia Operazioni
            '
            Dim oTracciaOp As New TracciaOperazioniManager(Global_asax.ConnectionStringPortalAdmin)
            oTracciaOp.TracciaOperazione(PortalsNames.DwhClinico, Page.AppRelativeVirtualPath, "Ricerca ricoveri", pannelloFiltri, Nothing)

        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub

    Private Sub odsRicoveri_Selected(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles odsRicoveri.Selected
        Try
            '
            'GESTIONE ERRORE
            '
            If Not GestioneErrori.ObjectDataSource_TrapError(e, LabelError) Then
                btnRinotifica.Enabled = True
                lblMaxNumRow.Visible = True
                gvRicoveri.Visible = True

                Dim eG = CType(e.ReturnValue, DataTable)


                '
                'Ottengo il numero di row contenute nel data table.
                '
                Me.numRicoveri = eG.Rows.Count

                Dim sMessage As String = String.Format("La ricerca ha prodotto {0} record.", Me.numRicoveri)

                If Me.numRicoveri > maxNumRec Then
                    sMessage = String.Format("La ricerca ha prodotto {0} record. Raffinare la ricerca.", Me.numRicoveri)
                    gvRicoveri.Visible = False
                ElseIf Me.numRicoveri = 0 Then
                    btnRinotifica.Enabled = False
                    lblMaxNumRow.Visible = False
                End If

                lblMaxNumRow.Text = sMessage

                '
                'SALVO IN SESSIONE LA LISTA DEI RICOVERI DA NOTIFICARE.
                '
                SessionHandler.listaRicoveri = eG
            End If



        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub

    Private Sub odsRicoveri_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsRicoveri.Selecting
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

            gvRicoveri.Visible = False
        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(LabelError, sMessage)
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

    Private Sub cmbSistemaErogante_DataBound(sender As Object, e As System.EventArgs) Handles cmbSistemaErogante.DataBound
        Try
            cmbSistemaErogante.Items.Insert(0, "")
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub


    Dim mListaProcessati As New List(Of RicoveroNotificato)
    Private Sub NotificaRicoveri()
        Try
            Dim sAziendaErogante As String = String.Empty
            Dim sNumeroNosologico As String = String.Empty
            Dim sId As String = String.Empty
            Dim row As DataRow = Nothing

            '
            'Contiene la lista dei Ricoveri da notificare.
            '
            Dim listaRicoveriDaNotificare As DataTable = SessionHandler.listaRicoveri

            '
            'Controllo se la lista dei ricoveri notificati è vuota. se non lo è la copio dentro mListaProcessati.
            '
            If Not SessionHandler.listaRicoveriNotificati Is Nothing AndAlso SessionHandler.listaRicoveriNotificati.Count <> 0 Then
                mListaProcessati = SessionHandler.listaRicoveriNotificati
            End If

            '
            'Vado avanti solo se la lista dei Ricoveri non è vuota.
            '
            If Not listaRicoveriDaNotificare Is Nothing AndAlso listaRicoveriDaNotificare.Rows.Count > 0 Then
                '
                'Lista delle row che verranno inserite nella tabella. Prendo 100 righe alla volta.
                '
                Dim dtTop100Ricoveri As List(Of System.Data.DataRow) = listaRicoveriDaNotificare.AsEnumerable().Take(maxNumRinotifichePerCiclo).ToList

                '
                'Vado avanti solo se la lista non è vuota.
                '
                If dtTop100Ricoveri IsNot Nothing AndAlso dtTop100Ricoveri.Count > 0 Then

                    '
                    'Ciclo tutte le row nella lista
                    '
                    For index = 0 To dtTop100Ricoveri.Count - 1



                        Dim ricoveroProcessato As New RicoveroNotificato


                        '
                        'Metto un Synclock quando prendo la righa e la rimuovo
                        '
                        SyncLock GlobalObject.gObjNotificaRicoveriSynclock
                            '
                            'Ottengo la row del data table.
                            '
                            row = CType(dtTop100Ricoveri.Item(index), DataRow)

                            '
                            'Ottengo IdRicovero, NumeroNosologico e AziendaErogante del ricovero.
                            '
                            sAziendaErogante = row.Item("AziendaErogante").ToString
                            sNumeroNosologico = row.Item("NumeroNosologico").ToString
                            sId = row.Item("ID").ToString

                            '
                            'Rimuovo la riga dal dataset. In questo modo evito di processre lo stesso ricovero più volte.
                            '
                            listaRicoveriDaNotificare.Rows.Remove(row)
                        End SyncLock

                        '
                        'Aggiungo all'oggetto l'id del ricovero.
                        '
                        ricoveroProcessato.Id = sId
                        ricoveroProcessato.AziendaErogante = sAziendaErogante
                        ricoveroProcessato.NumeroNosologico = sNumeroNosologico

                        Try
                            Using da = New RicoveriDataSetTableAdapters.QueriesTableAdapter
                                da.BeRicoveroNotificaEventi(sAziendaErogante, sNumeroNosologico)
                                '
                                'Se è andata a buon fine allora stato Notifica = "OK" altrimenti scrivo "Errore"
                                '
                                ricoveroProcessato.StatoNotifica = "OK"
                            End Using
                        Catch ex As Exception
                            '
                            ' popolo la colonna "statoNotifica" e "Eccezione"
                            '
                            ricoveroProcessato.StatoNotifica = "Errore"
                            ricoveroProcessato.Eccezione = ex.Message
                        End Try

                        '
                        'Aggiungo alla lista dei ricoveri processati il ricovero corrente.
                        '
                        mListaProcessati.Add(ricoveroProcessato)
                    Next

                    '
                    'Salvo in sessione la lista dei ricoveri processati.
                    '
                    SessionHandler.listaRicoveriNotificati = mListaProcessati

                End If
            End If


            Dim value As Integer
            value = (SessionHandler.listaRicoveriNotificati.Count * 100) / Me.numRicoveri
            Dim functionJS As String = "$(function () {$('.progressbar').progressbar({value:" + value.ToString + " });});"

            ScriptManager.RegisterStartupScript(Page, Page.GetType, "ChangeProgressBarValue", functionJS, True)
            '
            'Aggiorno la variabile di sessione
            '
            SessionHandler.listaRicoveri = listaRicoveriDaNotificare
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub

    Private Sub Timer1_Tick(sender As Object, e As EventArgs) Handles Timer1.Tick
        Try
            '
            'Se il timer è disabilitato allora esco dalla function:
            'Questo nel caso in cui il timer ricominci prima che notificaRicovero sia eseguito. In questo modo se il timer è stato disabilitato non esegue il codice.
            '
            If Timer1.Enabled = False Then
                Exit Sub
            End If
            Timer1.Enabled = False

            If Not SessionHandler.listaRicoveri Is Nothing AndAlso SessionHandler.listaRicoveri.Rows.Count > 0 Then
                '
                'abilito il bottone di annullamento se sono la notifica non è stata ancora completata.
                '
                btnAnnullaRinotifica.Enabled = True

                '
                'Notifico i ricoveri.
                '
                NotificaRicoveri()

                '
                'Mostro il numero di ricoveri che sono stati inseriti.
                '
                If SessionHandler.listaRicoveriNotificati IsNot Nothing Then
                    lblStatoNotifica.Text = String.Format("Notificati {0} di {1} ricoveri.", SessionHandler.listaRicoveriNotificati.Count.ToString, Me.numRicoveri.ToString)
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

                Dim idRicoveriNotificati As List(Of String) = New List(Of String)

                ' Ottengo tutti gli id dei referti rinotificati
                For Each ricoveroNotificato As RicoveroNotificato In SessionHandler.listaRicoveriNotificati
                    idRicoveriNotificati.Add(ricoveroNotificato.Id)
                Next

                ' Traccio l'operazione di ritotifica con tutti gli id dei referti notificiati
                Dim oTracciaOp As New TracciaOperazioniManager(Global_asax.ConnectionStringPortalAdmin)
                oTracciaOp.TracciaOperazione(PortalsNames.DwhClinico, Page.AppRelativeVirtualPath, "Rinotificati massivamente ricoveri", idRicoveriNotificati, idPaziente:=Nothing)

            End If
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
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
            'Quando clicco su "Annulla Rinotifica" svuoto la sessione.
            'In questo modo non verranno più inseriti ricoveri. 
            '
            SessionHandler.listaRicoveri = Nothing

            '
            '1) Mostro alert per Notifica Annullata
            '2) Mostro il pulsante btn-esporta
            '3) Riabilito i pulsanti "Cerca" e "Annulla"
            '
            Dim functionJS As String = "alert('Notifica annullata.\nÈ possibile verificare gli eventuali errori nel file excel.');$('.btn-esporta').css('display','block');$('.btn-cerca-annulla').removeAttr('disabled');$('body').css('cursor', 'default');"
            ScriptManager.RegisterStartupScript(Page, Page.GetType, "openModalNotificaCompleta", functionJS, True)
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub

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
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub

    Private Sub odsSistemiEroganti_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsSistemiEroganti.Selected
        GestioneErrori.ObjectDataSource_TrapError(e, LabelError)
    End Sub

    Private Sub btnEsportaRicoveri_Click(sender As Object, e As EventArgs) Handles btnEsportaRicoveri.Click
        Try

            Dim ListOfEntity As IList = CType(SessionHandler.listaRicoveriNotificati, IList)
            If Not ListOfEntity Is Nothing AndAlso ListOfEntity.Count > 0 Then
                Using str As MemoryStream = Excel.AnyListToExcel(ListOfEntity, "LISTA_EVENTI_RINOTIFICATI.") ', table.Name
                    If str IsNot Nothing Then
                        Response.Clear()
                        Response.Buffer = True
                        Response.AddHeader("content-disposition", "attachment;filename=" & "LISTA_EVENTI_RINOTIFICATI." & ".xlsx")
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

    Private Sub gvRicoveri_RowDataBound(sender As Object, e As GridViewRowEventArgs) Handles gvRicoveri.RowDataBound
        Try
            If e.Row.RowType = DataControlRowType.DataRow Then
                Dim rw As DataRowView = e.Row.DataItem
                Dim oRow As RicoveriDataSet.BeRicoveriNotificaListaRow = rw.Row
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