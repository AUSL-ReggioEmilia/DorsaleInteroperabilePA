Imports System.Collections.Generic
Imports System.Data
Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports CustomDataSource
Imports DI.OrderEntry.Services
Imports DI.PortalUser2.Data

Namespace DI.OrderEntry.User

    Public Class ListaOrdiniPianificati
        Inherits Page

        'creo delle variabili di pagina che sono necessarie per il loading della gvOrdini in quanto formano parte della key su cui effettuo la select
        Public Property codice() As String
            Get
                Return Me.ViewState("codice")
            End Get
            Set(ByVal value As String)
                Me.ViewState.Add("codice", value)
            End Set
        End Property

        Public Property codiceAzienda() As String
            Get
                Return Me.ViewState("codiceAzienda")
            End Get
            Set(ByVal value As String)
                Me.ViewState.Add("codiceAzienda", value)
            End Set
        End Property

        Public Property IdPaziente() As String
            Get
                Return Me.ViewState("IdPaziente")
            End Get
            Set(ByVal value As String)
                Me.ViewState.Add("IdPaziente", value)
            End Set
        End Property

        Public Property AziendaErogante() As String
            Get
                Return Me.ViewState("AziendaErogante")
            End Get
            Set(ByVal value As String)
                Me.ViewState.Add("AziendaErogante", value)
            End Set
        End Property

        Public Property isAccessoDiretto() As Boolean
            Get
                Return Me.ViewState("isAccessoDiretto")
            End Get
            Set(ByVal value As Boolean)
                Me.ViewState.Add("isAccessoDiretto", value)
            End Set
        End Property

        Public Property nosologico() As String
            Get
                Return Me.ViewState("nosologico")
            End Get
            Set(ByVal value As String)
                Me.ViewState.Add("nosologico", value)
            End Set
        End Property

        Private executeSelect As Boolean = False
        Private msPAGEKEY As String = Page.GetType().BaseType.FullName
        Private Const errorMessage As String = "Errore nella combinazione di parametri passata nella querystring<br />Le combinazioni accettate sono: Nosologico-Azienda Erogante e IdProvenienza-Provenienza."

        Protected Sub ListaOrdini_PreInit(sender As Object, e As EventArgs) Handles Me.PreInit
            Try
                '
                'ATTENZIONE: Il cambio della master è gestibile solo nel preinit della pagina				'
                '
                If RouteData.Values("AccessoDiretto") IsNot Nothing Then
                    isAccessoDiretto = CType(RouteData.Values("AccessoDiretto"), Boolean)
                    If isAccessoDiretto Then
                        Me.MasterPageFile = "~/SiteAccessoDiretto.master"
                    End If
                End If
            Catch ex As Exception
                gestioneErrori(ex)
            End Try

        End Sub

        Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load
            Try
                If Not Page.IsPostBack Then

                    ' Imposto il default del range di date --> Poi nel GetData della griglia imposo l'ora della DataPrenotazioneAl alle 23:59:59
                    txtDataPrenotazioneDal.Text = Date.Today
                    txtDataPrenotazioneAl.Text = Date.Today

                    'Cancello la cache per evitare di utilizzare dati vecchi o sbagliati
                    Dim dataSource2 As New PrestazioniErogate
                    dataSource2.ClearCache()

                    Me.nosologico = Request.QueryString("Nosologico")

                    Redirector.SetTarget(Utility.buildUrl(Request.Url.AbsoluteUri, Me.isAccessoDiretto), True)

                    If isAccessoDiretto Then

                        'Nascondo i filtri nel pannello che non mi servono
                        divFiltriAccessoStandard.Visible = False

                        'Combinazioni possibili:
                        '1) idProvenienza e Provenienza
                        '2) Nosologico e AziendaErogante
                        Dim idProvenienza As String = Request.QueryString("idProvenienza")
                        Dim provenienza As String = Request.QueryString("Provenienza")
                        Me.AziendaErogante = Request.QueryString("AziendaErogante")

                        'Mostro nel divErrorMessage un messaggio se nella query string i parametri non sono forniti nelle rispettive coppie
                        If Not ((Not String.IsNullOrEmpty(idProvenienza) AndAlso Not String.IsNullOrEmpty(provenienza)) OrElse (Not String.IsNullOrEmpty(nosologico) AndAlso Not String.IsNullOrEmpty(AziendaErogante))) Then
                            Throw New ApplicationException(errorMessage)
                        End If

                        'Setto l'url ricavato in precedenza come variabile in sessione
                        SessionHandler.EntryPointAccessoDiretto = Request.Url.AbsoluteUri

                        'Ottengo l'idPaziente in base alla combinazione dei parametri
                        If Not String.IsNullOrEmpty(idProvenienza) AndAlso Not String.IsNullOrEmpty(provenienza) Then
                            Me.IdPaziente = Utility.GetIdPazienteByProvenienza(idProvenienza, provenienza)
                            If Me.IdPaziente Is Nothing OrElse String.IsNullOrEmpty(Me.IdPaziente) Then
                                'genero una nuova eccezione
                                Throw New ApplicationException("Il paziente non è stato trovato")
                            End If
                        End If

                        'Forzo il DataBind della tabella
                        executeSelect = True

                        'Pulisco la cache quando premo "cerca"
                        Dim ordiniPianificati As New OrdiniPianificati
                        ordiniPianificati.ClearCache()

                        GvOrdini.DataBind()
                    Else
                        FilterHelper.Restore(filterPanel, msPAGEKEY)
                    End If
                End If
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub

        Private Sub CercaButton_Click(sender As Object, e As System.EventArgs) Handles CercaButton.Click
            Try

                'Valido i filtri
                If CheckFilters() Then

                    'Setto la variabile executeSelect a True in modo da eseguire il bind dei dati.
                    'Se è false l'ODS blocca il bind dei dati.
                    executeSelect = True

                    ' Avvio il timer per il refresh continuo!
                    TimerGridPazienti.Enabled = True

                    ' Salvo i filtri in sessione
                    FilterHelper.SaveInSession(filterPanel, msPAGEKEY)

                    'Pulisco la cache quando premo "cerca"
                    Dim ordiniPianificati As New OrdiniPianificati
                    ordiniPianificati.ClearCache()

                    'Rieseguo il bind dei dati.
                    GvOrdini.DataBind()

                    '
                    '2020-07-15 Kyrylo: Traccia Operazioni
                    '
                    Dim oTracciaOp As New TracciaOperazioniManager(Global_asax.ConnectionStringPortalUser)
                    oTracciaOp.TracciaOperazione(PortalsNames.OrderEntry, Page.AppRelativeVirtualPath, "Ricerca ordini pianificati", filterPanel, Nothing)


                Else
                    'Se i filtri non sono validi pulisco la giglia
                    PulisciGrigliaOrdini()
                End If

            Catch ex As Exception
                'In caso di errore pulisco la giglia
                PulisciGrigliaOrdini()
                gestioneErrori(ex)
            Finally
                UpdatePanelGriglia.Update()
            End Try

        End Sub

        'Verifico che nome e cognome siano validati nel caso in cui il periodo selezionato sia superiore a un mese
        Private Function CheckFilters() As Boolean
            Dim res As Boolean = True
            Try
                If Not (Me.isAccessoDiretto) Then

                    'Controllo se la dataPrenotazioneDal esiste ed è valida.
                    Dim dataDal As Date = DateTime.Now
                    If Not String.IsNullOrEmpty(txtDataPrenotazioneDal.Text) Then
                        Dim dataTester As DateTime
                        If DateTime.TryParse(txtDataPrenotazioneDal.Text, dataTester) Then
                            dataDal = CType(txtDataPrenotazioneDal.Text, Date)
                        End If
                    End If

                    'Controllo se la dataPrenotazioneAl esiste ed è valida.
                    Dim dataAl As Date = DateTime.Now
                    If Not String.IsNullOrEmpty(txtDataPrenotazioneAl.Text) Then
                        Dim dataTester As DateTime
                        If DateTime.TryParse(txtDataPrenotazioneAl.Text, dataTester) Then
                            dataAl = CType(txtDataPrenotazioneAl.Text, Date)
                        End If
                    End If

                    'Se DataAl > DataDal allora mostro un messaggio di errore
                    If (dataDal > dataAl) Then

                        lblError.Text = "la ""Data prenotazione dal"" non può essere superiore a ""Data prenotazione al"""
                        divErrorMessage.Visible = True
                        Return False
                    End If

                    Dim dataDalMassima As DateTime = dataDal.AddMonths(1)

                    'Se periodo > 1 MESE
                    If (dataAl > dataDalMassima) Then

                        If (String.IsNullOrEmpty(txtNome.Text) OrElse String.IsNullOrEmpty(txtCognome.Text)) Then
                            lblError.Text = "Occorre inserire Nome e Cognome se il periodo temporale è maggiore di un mese"
                            divErrorMessage.Visible = True
                            res = False
                        End If
                    End If

                End If
            Catch ex As Exception
                gestioneErrori(ex)
            End Try

            Return res

        End Function

        Private Sub PulisciGrigliaOrdini()

            'Pulisco i filtri in sessione e pulisco la cache caricando nessun risultato nella griglia
            FilterHelper.Clear(filterPanel, msPAGEKEY)

            ' Disabilito il timer altrimenti continua a cercare anche se i filtri non sono validi!
            TimerGridPazienti.Enabled = False

            'Pulisco la cache quando premo "cerca"
            Dim ordiniPianificati As New OrdiniPianificati
            ordiniPianificati.ClearCache()

            'Disabilito il DataBind della tabella
            executeSelect = False
            'Pulisco la griglia(carica "nessun risultato" poiche excuteSelect è fasle).
            GvOrdini.DataBind()

        End Sub

        Private Sub GvOrdini_RowDataBound(sender As Object, e As GridViewRowEventArgs) Handles GvOrdini.RowDataBound

            If e.Row.RowType = DataControlRowType.DataRow Then
                '
                ' Riga corrente per cercare i controlli
                '
                Dim rowCurrent As GridViewRow = e.Row

                '
                ' 2020-06-03 KYRY: Coloro diversamente (giallo pastello) le righe nello stato "Programmato"
                '
                Dim ordineRow As OrdinePianificato = e.Row.DataItem

                If ordineRow.Ordine.StatoOrderEntryDescrizione = "Programmato" Then
                    rowCurrent.CssClass = "stato-programmato"
                End If

            End If

        End Sub

        Private Sub OdsOrdini_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles OdsOrdini.Selecting
            Try
                If Not executeSelect Then
                    e.Cancel = True
                    Exit Sub
                End If

                'Passo i parametri che ho salvato alla pressione del pulsante "cerca" in sessione!
                'lo faccio perchè cosi il timer che scatta ogni 60 secondi ri esegue la ricerca con i filtri in sessione
                'Se non prendo i parametri dalla sessione rischio di cercare con filtri non validi (es: mentre l'utente scrive il timer scatta ed esegue la ricerca utilizzando dati incompleti)
                e.InputParameters("Cognome") = FilterHelper.GetSavedValue(txtCognome, msPAGEKEY)
                e.InputParameters("Nome") = FilterHelper.GetSavedValue(txtNome, msPAGEKEY)
                e.InputParameters("DataNascita") = FilterHelper.GetSavedValue(txtDataNascita, msPAGEKEY)
                e.InputParameters("Nosologico") = FilterHelper.GetSavedValue(txtNosologico, msPAGEKEY)
                e.InputParameters("Uo") = FilterHelper.GetSavedValue(ddlUo, msPAGEKEY)
                e.InputParameters("SistemaErogante") = FilterHelper.GetSavedValue(ddlSistemiEroganti, msPAGEKEY)
                e.InputParameters("DataPrenotazioneDal") = FilterHelper.GetSavedValue(txtDataPrenotazioneDal, msPAGEKEY)
                e.InputParameters("DataPrenotazioneAl") = FilterHelper.GetSavedValue(txtDataPrenotazioneAl, msPAGEKEY)
                e.InputParameters("AziendaErogante") = Me.AziendaErogante
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub

        Private Sub OdsOrdini_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles OdsOrdini.Selected
            Try
                Dim ordineList As List(Of OrdinePianificato) = CType(e.ReturnValue, List(Of OrdinePianificato))

                'Controllo quanti record ci sono
                If ordineList IsNot Nothing AndAlso ordineList.Count > 150 Then
                    'Avviso che ci sono più di 150 record!
                    LblAllertTopRecord.Text = "Attenzione! Ci sono più di 150 ordini, occorre affinare la ricerca"
                    LblAllertTopRecord.Visible = True

                End If
            Catch ex As Exception
                'Loggo l'errore
                gestioneErrori(ex)
            End Try
        End Sub

        Private Sub TimerGridPazienti_Tick(sender As Object, e As EventArgs) Handles TimerGridPazienti.Tick
            Try

                executeSelect = True

                'Pulisco la cache quando premo "cerca"
                Dim ordiniPianificati As New OrdiniPianificati
                ordiniPianificati.ClearCache()

                GvOrdini.DataBind()

            Catch ex As Exception
                'In caso di errore pulisco la giglia
                PulisciGrigliaOrdini()
                gestioneErrori(ex)
            End Try

        End Sub

        Protected Function GetDettaglioUrl(ByVal idRichiesta As Object, ByVal idPaziente As Object, stato As String, nosologico As String) As String
            Dim numnosologico As String = If(nosologico Is Nothing, "", "&Nosologico=" & nosologico)
            Dim page As String = If(stato = "Inserito" OrElse stato = "Modificato", "ComposizioneOrdine", "RiassuntoOrdine")
            Return Utility.buildUrl($"{page}.aspx?IdRichiesta={idRichiesta}&IdPaziente={idPaziente}{numnosologico}", Me.isAccessoDiretto)
        End Function

        Protected Function GetDatiAccessoriUrl(idRichiesta As Object) As String
            Dim result As String = String.Empty
            Try
                If idRichiesta IsNot Nothing Then
                    result = Utility.buildUrl($"RiepilogoDatiAccessori.aspx?IdRichiesta={idRichiesta}", Me.isAccessoDiretto)
                End If
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
            Return result
        End Function

        Protected Function GetSacPazienteUrl(ByVal id As Object) As String
            If id IsNot Nothing Then
                Return My.Settings.PazienteSacUrl & id
            Else
                Return String.Empty
            End If
        End Function

        Public Shared Function GetUrlRefertiDwh(idPaziente As String) As String

            Return String.Format("{0}{1}", My.Settings.DwhUrlReferti, idPaziente)
        End Function

        Public Shared Function GetUrlRefertoOrdineDwh(annoNumero As String) As String

            Return String.Format("{0}{1}", My.Settings.DwhUrlRefertoOrdine, annoNumero)
        End Function

        Protected Function MustIconBeVisible(ordine As Ordine) As Boolean
            Dim res As Boolean = False
            Try
                If Not (String.IsNullOrEmpty(ordine.IdRichiestaRichiedente) OrElse String.IsNullOrEmpty(ordine.SistemaRichiedente)) Then
                    Dim datiAgg As List(Of DatoNomeValoreType) = RiassuntoOrdineMethods.DatiAggiuntiviSistemaErogante(ordine.IdRichiestaRichiedente, ordine.SistemaRichiedente)
                    If datiAgg IsNot Nothing AndAlso datiAgg.Count > 0 Then
                        res = True
                    End If
                End If
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
            Return res
        End Function

        Protected Sub btnOpenModalDatiAccessori_Click(sender As Object, e As EventArgs)
            Try
                Dim LinkButton As LinkButton = CType(sender, LinkButton)
                Dim argument As String = LinkButton.CommandArgument.ToString()
                ScriptManager.RegisterStartupScript(Page, Page.GetType, "LanchServerSide", $"getDatiAccessoriAsync({argument})", True)
            Catch ex As Exception
                gestioneErrori(ex)
            End Try
        End Sub

        '''<summary>
        ''' Funzione per trappare gli errori e mostrare il div d'errore.
        ''' </summary>
        ''' <param name="ex"></param>
        Private Sub gestioneErrori(ex As Exception)

            'Testo di errore generico da visualizzare nel divError della pagina.
            Dim errorMessage As String = "Si è verificato un errore. Contattare l'amministratore del sito"

            'Se ex è una ApplicationException, allora contiene un messaggio di errore personalizzato che viene visualizzato poi
            'nel divError della pagina.
            If TypeOf ex Is ApplicationException Then
                Dim message As String = ex.Message

                If ex.InnerException IsNot Nothing AndAlso Not String.IsNullOrEmpty(ex.InnerException.Message) Then
                    message = ex.InnerException.Message
                End If

                If isAccessoDiretto Then
                    divPage.Visible = False
                    errorMessage = message
                End If
                errorMessage = message
            End If

            'Scrivo l'errore nell'event viewer.ì
            ExceptionsManager.TraceException(ex)
            Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
            portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)

            'Visualizzo il messaggio di errore nella pagina.
            divErrorMessage.Visible = True
            lblError.Text = errorMessage
        End Sub

    End Class

End Namespace