Imports Aspose.Words.Tables
Imports DI.PortalUser2
Imports DI.PortalUser2.Data
Imports DwhClinico.Data
Imports DwhClinico.Web
Imports DwhClinico.Web.Utility
Imports DwhClinico.Web.WcfDwhClinico
Imports System.Globalization

Partial Class Referti_RefertiListaPaziente
    Inherits System.Web.UI.Page

#Region "Varibili di pagina"

    '
    ' mbValidationCancelSelect e mbValidationSelect vengono usate per indicare se devono essere rieseguite le query oppure no
    '
    Private mbValidationCancelSelect As Boolean = False
    Private mbValidationSelect As Boolean = True
    Private mbDataSourceRefertiPerNosologicoCancelSelect As Boolean = True

    Private Const VS_CURRENT_LNK_VIEW As String = "{F65C0DE3-8114-47ed-B843-B6F3F97AB782}"
    Private Const GRID_PAGE_SIZE As Integer = 100
    Private mstrPageID As String
    Private ReadOnly PageSessionIdPrefix As String = Page.GetType().BaseType.FullName
    Private newPropertyValue As String

    ' Utilizzato per tenere traccia dell'ultimo giorno selezionato nel calendario
    Private Property SelectedDayDetail() As Date
        Get
            Return Session("DayDetail")
        End Get
        Set(ByVal value As Date)
            Session("DayDetail") = value
        End Set
    End Property

    '
    ' Key usate per salvare le liste dei tipiReferto in sessione
    '
    Private Const KEY_REFERTI_LISTA_TIPIREFERTO As String = "KEY_REFERTI_LISTA_TIPIREFERTO"
    Private Const KEY_PRESCRIZIONI_LISTA_TIPIREFERTO As String = "KEY_PRESCRIZIONI_LISTA_TIPIREFERTO"
    Private Const KEY_REFERTI_PER_EPISODI_LISTA_TIPIREFERTO As String = "KEY_REFERTI_PER_EPISODI_LISTA_TIPIREFERTO"

    '
    ' Lista dei referti riempita nel RowDataBound della griglia WebGridRefertiEpisodi
    ' Viene usata per comporre la lista dei tipi referto da inserire nella checkbox list dei filtri laterali
    '
    Dim listaReferti As New List(Of WcfDwhClinico.RefertoListaType)

    Dim InvalidaCacheRefertiPerNosologico As Boolean = False

    Dim mbDeleteRefertiPermission As Boolean = False

    '
    ' Variabile per gestire la visualizzazione a calendario
    '
    Public CalendarAdapter As CalendarAdapter

#End Region

#Region "Property"
    Public Property IdPaziente As Guid
        '
        ' Salvo l'Id del paziente nel ViewState per averlo per tutta la durata della pagina
        '
        Get
            Return Me.ViewState("IdPaziente")
        End Get
        Set(value As Guid)
            Me.ViewState("IdPaziente") = value
        End Set
    End Property

    Public Property CodiceFiscalePaziente As String
        Get
            Return Me.ViewState("CodiceFiscalePaziente")
        End Get
        Set(value As String)
            Me.ViewState("CodiceFiscalePaziente") = value
        End Set
    End Property

    Public Property ConsensoPaziente As String
        Get
            Return Me.ViewState("ConsensoPaziente")
        End Get
        Set(value As String)
            Me.ViewState("ConsensoPaziente") = value
        End Set
    End Property

    Public Property CodiceFiscaleRichiedente As String
        Get
            Return Me.ViewState("CodiceFiscaleRichiedente")
        End Get
        Set(value As String)
            Me.ViewState("CodiceFiscaleRichiedente") = value
        End Set
    End Property

    Private ReadOnly Property Token As WcfDwhClinico.TokenType
        '
        ' Ottiene il token da passare come parametro agli ObjectDataSource all'interno delle tab.
        ' Utilizza la property CodiceRuolo per creare il token
        '
        Get
            Dim TokenViewState As WcfDwhClinico.TokenType = TryCast(Me.ViewState("Token"), WcfDwhClinico.TokenType)
            If TokenViewState Is Nothing Then

                TokenViewState = Tokens.GetToken(Me.CodiceRuolo)

                Me.ViewState("Token") = TokenViewState
            End If
            Return TokenViewState
        End Get
    End Property

    Private ReadOnly Property CodiceRuolo As String
        '
        ' Salva nel ViewState il codice ruolo dell'utente
        ' Utilizzata per creare il token da passare come parametro all'ObjectDataSource all'interno delle tab.
        '
        Get
            Dim sCodiceRuolo As String = Me.ViewState("CodiceRuolo")
            If String.IsNullOrEmpty(sCodiceRuolo) Then
                '
                ' Prendo il ruolo dell'utente
                '
                Dim oRoleManagerUtility As New RoleManagerUtility2(Utility.GetAppSettings(Utility.PAR_DI_PORTAL_USER_CONNECTION_STRING, ""), My.Settings.SAC_ConnectionString, My.Settings.WsSac_User, My.Settings.WsSac_Password)
                Dim oRuoloCorrente As RoleManager.Ruolo = oRoleManagerUtility.RuoloCorrente
                '
                ' Salvo in ViewState
                '
                sCodiceRuolo = oRuoloCorrente.Codice
                Me.ViewState("CodiceRuolo") = sCodiceRuolo
            End If

            Return sCodiceRuolo
        End Get
    End Property

    Private ReadOnly Property DescrizioneRuolo As String
        '
        ' Salva nel ViewState la descrizione del ruolo dell'utente
        '
        Get
            Dim sDescrizioneRuolo As String = Me.ViewState("DescrizioneRuolo")
            If String.IsNullOrEmpty(sDescrizioneRuolo) Then
                '
                ' Prendo il ruolo dell'utente
                '
                Dim oRoleManagerUtility As New RoleManagerUtility2(Utility.GetAppSettings(Utility.PAR_DI_PORTAL_USER_CONNECTION_STRING, ""), My.Settings.SAC_ConnectionString, My.Settings.WsSac_User, My.Settings.WsSac_Password)
                Dim oRuoloCorrente As RoleManager.Ruolo = oRoleManagerUtility.RuoloCorrente
                '
                ' Salvo in ViewState
                '
                sDescrizioneRuolo = oRuoloCorrente.Descrizione
                Me.ViewState("DescrizioneRuolo") = sDescrizioneRuolo
            End If

            Return sDescrizioneRuolo
        End Get
    End Property

    Public Property IdEpisodio As Guid
        '
        ' Memorizza nel ViewState l'id dell'episodio da passare come parametro agli ObjectDataSource delle tab.
        '
        Get
            Return Me.ViewState("IdEpisodio")
        End Get
        Set(value As Guid)
            Me.ViewState("IdEpisodio") = value
        End Set
    End Property

    Private Property DataMinimaFiltro() As DateTime
        Get
            Return CType(ViewState("-DataMinimaFiltro-"), DateTime)
        End Get
        Set(ByVal value As DateTime)
            ViewState("-DataMinimaFiltro-") = value
        End Set
    End Property
#End Region

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Dim sIdPaziente As String = String.Empty
        Dim oPrintingConfig As New PrintUtil.PrintingConfig
        Try


            'UTILIZZO LA VARIABILE DI SESSIONE IsSessioneAttiva PER VERIFICARE SE LA SESSIONE È SCADUTA.
            If SessionHandler.ValidaSessioneAccessoStandard Is Nothing OrElse SessionHandler.ValidaSessioneAccessoStandard = False Then
                RedirectToHome()
            End If

            Trace.Write("inizio load")

            'OTTENGO L'ID DEL PAZIENTE DAL QUERY STRING.
            'SE L'ID DEL PAZIENTE È NOTHING ESEGUO UN REDIRECT ALLA HOME.
            sIdPaziente = Me.Request.QueryString("idpaziente")
            If String.IsNullOrEmpty(sIdPaziente) Then
                RedirectToHome()
            End If

            '
            'MODIFICATO DA SIMONEB IL 1/06/2017.
            'NON VALORIZZO LA VARIABILE MSTRPAGEID CON L'ID DELLA PAGINA MA CON UNA STRINGA GENERICA.
            'QUESTA VARIBABILE VIENE USATA PER VALORIZZARE LA KEY DELLA SESSIONE CON CUI DOBBIAMO SALVARE I VALORI DI FILTRO.
            'QUESTI VALORI DI FILTRO DEVONO ESSERE ACCESSIBILI DA ALTRE PAGINE E QUINDI È NECESSARIA UNA KEY DI SESSIONE UTILIZZABILE ANCHE IN ALTRE PAGINE.
            '
            mstrPageID = "RefertiListaPaziente"

            '
            ' Memorizzo SEMPRE se ho i diritti di cancellazione per Ruolo ad ogni caricamento della pagina
            '
            mbDeleteRefertiPermission = HttpContext.Current.User.IsInRole(RoleManagerUtility2.ATTRIB_OSC_REFERTI)

            '
            ' Solo la prima volta.
            '
            If Not IsPostBack Then

                '
                ' RESETTO LA VARIABILE DI LISTA DEI REFERTI OGNI VOLTA CHE PASSO DA QUI.
                '
                SessionHandler.ListaRefertiUrl = Nothing

                '
                ' Salvo l'id del paziente nel ViewState
                '
                If Not String.IsNullOrEmpty(sIdPaziente) Then
                    IdPaziente = New Guid(sIdPaziente)
                Else
                    Throw New Exception("Il parametro 'IdPaziente' è obbligatorio")
                End If

                '
                ' Cancello l'id del referto dalla sessione
                '
                SessionHandler.IdReferto = Nothing

                '
                ' Valorizzo l'url alla pagina di gestione del consenso. Questo url cambia tra AccessoStandard e AccessoDiretto.
                '
                ucTestataPaziente.UrlDettaglioConsensi = String.Format("~/Pazienti/GestioneConsensi.aspx?IdPaziente={0}", sIdPaziente)
                '
                ' Passo alla testata del paziente il token e l'id del paziente per fare il bind dei dati.
                '
                ucTestataPaziente.IdPaziente = New Guid(sIdPaziente)
                ucTestataPaziente.Token = Me.Token
                ucTestataPaziente.CodiceRuolo = Me.CodiceRuolo
                ucTestataPaziente.DescrizioneRuolo = Me.DescrizioneRuolo
                '
                ' Mostro la parte relativa alla gestione del consenso nella testa del paziente.
                '
                ucTestataPaziente.MostraSoloDatiAnagrafici = False



                Dim bPatientSummaryEnabled As Boolean = My.Settings.PatientSummaryEnabled

                '
                ' Inizialmente il pulsante è disabilitato, sarà la chimata AJAX ad abilitarlo
                ' Se la funzionalità del Patient Summary NON è abilitata il pulsante è SEMPRE invisibile
                '
                btnApriPdfPatientSummary.Enabled = False
                btnApriPdfPatientSummary.Visible = bPatientSummaryEnabled
                '
                ' Determino se chiamare la parte AJAX
                '
                If bPatientSummaryEnabled Then
                    hiddenCallEnableButtonPatientSummary.Value = "TRUE"
                Else
                    hiddenCallEnableButtonPatientSummary.Value = "FALSE"
                End If

                '
                ' Ricavo il codice fiscale del paziente.
                ' Lo UserControl della testata del paziente espone i dati del paziente
                '
                Me.CodiceFiscalePaziente = ucTestataPaziente.CodiceFiscale.ToString

                'ottengo il consenso del paziente.
                'necessario per il tracciamento degli accessi.
                Me.ConsensoPaziente = ucTestataPaziente.UltimoConsensoAziendaleEspresso

                Dim oCurrentUser As CurrentUser = Utility.GetCurrentUser()
                Dim oDettaglioUtente As DettaglioUtente = Utility.GetDettaglioUtente(oCurrentUser.DomainName, oCurrentUser.UserName)
                hiddenRichiedenteCodiceFiscale.Value = oDettaglioUtente.CodiceFiscale
                hiddenRichiedenteCognome.Value = oDettaglioUtente.Cognome
                hiddenRichiedenteNome.Value = oDettaglioUtente.Nome
                hiddenPazienteCodiceFiscale.Value = Me.CodiceFiscalePaziente
                hiddenIdPaziente.Value = Me.IdPaziente.ToString

                Me.CodiceFiscaleRichiedente = oDettaglioUtente.CodiceFiscale

                SetDefaultDate()

                ucModaleInvioLinkPerAccessoDiretto.InizialiPaziente = $"{ucTestataPaziente.CognomePaziente.Substring(0, 1)}.{ucTestataPaziente.NomePaziente.Substring(0, 1)}."

                '
                ' Imposto il pulsante di stampa
                ' MODIFICA ETTORE 2016-11-24: Spostata la ricerca della configurazione di stampa nel pulsante di stampa
                ' 
                PrintUtil.ConfigPrintButton(btnExecutePrint, True)

                '
                ' Ricarico i valori di filtro dalla sessione
                '
                LoadFilterValues()

                '
                ' Provo a riposizionare gli indici di pagina originari
                '
                SetOldPageIndex()

                '
                'Setta la tab corretta. In questo modo navigando all'indietro a questa pagina verrà selezionata la tab precedentemente selezionata.
                '
                RestoreSelectedTab()


                '
                ' La matrice delle prestazioni non viene salvata in cache quindi ricarico la griglia se la pagina non è in postBack()
                '
                If SessionHandler.CancellaCache OrElse MultiViewMain.GetActiveView Is ViewRisultatoMatrice Then
                    Cerca()
                    SessionHandler.CancellaCache = False
                End If


                Dim BtnFseVisible As Boolean = My.Settings.FsePulsanteAbilitato
                BtnFSE.Visible = BtnFseVisible
                If BtnFseVisible Then
                    BtnFSE.Enabled = False
                    '
                    'ESCLUDO Pazienti con codice fiscale vuoto o composto da "0000000000000000"
                    '
                    If (Not String.IsNullOrEmpty(CodiceFiscalePaziente)) AndAlso (CodiceFiscalePaziente <> Utility.CODICE_FISCALE_NULLO) Then
                        '
                        'Verifico che il RUOLO impostato dall'utente che naviga possa accedere al fascicolo sanitario elettronico
                        '
                        BtnFSE.Enabled = HttpContext.Current.User.IsInRole(RoleManagerUtility2.ATTRIB_ACCESSO_FSE)
                    End If

                    Utility.TraceWriteLine(String.Format("FSE Consensi: CodiceFiscalePaziente={0}, IdPaziente={1}, Pulsante FSE abilitato={2}", CodiceFiscalePaziente, IdPaziente, BtnFSE.Enabled))

                End If

                '
                'Nascondo o mostro la tab delle Note Anamnestiche in base alla setting ShowNoteAnamnesticheTab.
                '
                NoteAnamnesticheTab.Visible = My.Settings.ShowNoteAnamnesticheTab
                '
                'Nascondo o mostro la tab del Calendario in base alla setting ShowCalendarioTab.
                '
                CalendarioTab.Visible = My.Settings.ShowCalendarioTab


                'Traccio l'operazione
                Dim oTracciaOp As New TracciaOperazioniManager(Utility.GetAppSettings(Utility.PAR_DI_PORTAL_USER_CONNECTION_STRING, ""))
                oTracciaOp.TracciaOperazione(PortalsNames.DwhClinico, Page.AppRelativeVirtualPath, "Visualizzata lista referti", IdPaziente, Nothing)

            Else
                hiddenCallEnableButtonPatientSummary.Value = "TRUE"
            End If

            '
            ' Valorizzo la label per la data contenuta nei tab 
            '
            lblDataFiltri.Text = txtDataDal.Text

            '
            'Imposto le paginazioni bootstrap.
            '
            SetGridViewBootstrapStyle()


            'Leo 02/03/2020 : carico il calendario se in sessione
            If Session("CalendarAdapter") IsNot Nothing Then
                CalendarAdapter = CType(Session("CalendarAdapter"), CalendarAdapter)
                UpdateCalendar()

                ' Imposto se presente l'ultimo giorno selezionato in sessione
                If Session("DayDetail") IsNot Nothing Then
                    UpdateCalendarDetail(Session("DayDetail"))
                End If
            End If

        Catch ex As Threading.ThreadAbortException
            '
            ' Non faccio niente
            '
        Catch ex As ApplicationException
            '
            ' Cancello anche le select dello UserControl per la testata del paziente
            '
            ucTestataPaziente.mbValidationCancelSelect = True
            mbValidationCancelSelect = True
            divErrorMessage.Visible = True
            lblErrorMessage.Text = ex.Message
            Logging.WriteError(ex, Me.GetType.Name)
        Catch ex As Exception
            '
            ' Cancello anche le select dello UserControl per la testata del paziente
            '
            ucTestataPaziente.mbValidationCancelSelect = True
            mbValidationCancelSelect = True
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante il caricamento della pagina!"
            Logging.WriteError(ex, Me.GetType.Name)
        End Try

    End Sub

#Region "Calendario"

    Private Sub CreateCalendarioReferti()

        ' DATE DA FILTRI TXT
        Dim dallaData As Date = CType(txtDataDal.Text, Date)
        Dim sAllaData As String = txtAllaData.Text

        Dim allaData As Date
        If Not String.IsNullOrEmpty(sAllaData) Then
            allaData = sAllaData.ToString()
        Else
            allaData = Date.Now.Date()
        End If

        '
        ' Popolo il calendario
        '

        CalendarAdapter = New CalendarAdapter(dallaData, allaData, Me.Token, Me.IdPaziente)

        ' Salvo in sessione
        Session.Add("CalendarAdapter", CalendarAdapter)

        UpdateCalendar()

        Dim dataDefault As Nullable(Of Date)
        dataDefault = CalendarAdapter.GetDefaultDay()

        If dataDefault IsNot Nothing AndAlso Not dataDefault.Equals(DateTime.MinValue) Then

            ' Salvo in sessione l'ultimo giorno selezionato nel calendario
            Session("DayDetail") = dataDefault

            UpdateCalendarDetail(dataDefault)
        End If

    End Sub

    Protected Sub RepeaterMesi_ItemDataBound(sender As Object, e As RepeaterItemEventArgs)
        Dim rowCurrent As RepeaterItem = e.Item
        Dim nIndex As Integer = rowCurrent.ItemIndex

        If nIndex > -1 Then
            Dim currentMonth As CalendarMonth = CType(CalendarAdapter.MesiVisibili(nIndex), CalendarMonth)
            Dim subGridview As GridView = CType(e.Item.FindControl("GrigliaMese"), GridView)

            subGridview.DataSource = CalendarAdapter.GetCalendarMonthByWeeks(currentMonth).Rows
            subGridview.DataBind()
        End If
    End Sub

    Protected Sub GrigliaMese_RowCommand(sender As Object, e As GridViewCommandEventArgs)
        If e.CommandName = "SetDayDetail" Then

            Dim dataGiorno As DateTime = e.CommandArgument.ToString()

            ' Mi accerto che nel giorno selezionato ci sia almeno un referto
            If CalendarAdapter.HasRank(dataGiorno) Then

                ' Salvo in sessione l'ultimo giorno selezionato nel calendario
                Session("DayDetail") = dataGiorno

                UpdateCalendarDetail(dataGiorno)
            End If
        End If
    End Sub

    ' freccia per andare all'anno passato
    Protected Sub PreviousCalendarBtn_Click(sender As Object, e As EventArgs)
        CalendarAdapter.PreviousYear()
        UpdateCalendar()
    End Sub

    ' freccia per andare all'anno futuro
    Protected Sub NextCalendarBtn_Click(sender As Object, e As EventArgs)
        CalendarAdapter.NextYear()
        UpdateCalendar()
    End Sub

    Protected Sub UpdateCalendar()
        RepeaterMesi.DataSource = CalendarAdapter.MesiVisibili
        RepeaterMesi.DataBind()

        Dim lblCurrentYear As Label = CType(ViewCalendario.FindControl("lblCurrentYear"), Label)
        lblCurrentYear.Text = CalendarAdapter.CurrentYear

        UpdatePanelCalendario.Update()
    End Sub

    Protected Sub UpdateCalendarDetail(giorno As Date)

        If Not giorno.Equals(DateTime.MinValue) Then

            Dim dsCalendar As CalendarDataSource = New CalendarDataSource()
            Dim result As List(Of WcfDwhClinico.RefertoListaType) = dsCalendar.GetRefertiByData(giorno, IdPaziente)


            'Se è nullo, significa che è scaduta la cache.
            If result Is Nothing Then
                divErrorMessage.Visible = True
                lblErrorMessage.Text = "Errore durante il caricamento dei dati! Provare a ricaricare la pagina"
            End If

            'Carico nel'objectDataSource della griglida di dettaglio i referti della data seleionata da calendario
            WebGridDettaglioCalendario.DataSource = result
            WebGridDettaglioCalendario.DataBind()
            UpdatePanelDettaglio.Update()
        End If

    End Sub

    Private Sub WebGridDettaglioCalendario_RowDataBound(sender As Object, e As GridViewRowEventArgs) Handles WebGridDettaglioCalendario.RowDataBound
        'Se è una riga e il referto non è variato allora la riga diventa bold
        If e.Row.RowType = DataControlRowType.DataRow Then

            Dim refertoRow As RefertoListaType = e.Row.DataItem

            If Not refertoRow.Visionato Then
                e.Row.CssClass = "referto-nuovo"
            End If
        End If
    End Sub

#End Region

    Private Sub SetDefaultDate()
        If String.Compare(ucTestataPaziente.UltimoConsensoAziendaleEspresso, "Dossier", True) = 0 Then
            If ucTestataPaziente.DataUltimoConsensoAziendaleEspresso.HasValue Then
                DataMinimaFiltro = ucTestataPaziente.DataUltimoConsensoAziendaleEspresso
                '
                ' Se l'utente è un infermiere disabilito la combo del filtro temporale e imposta la data di default
                '
                If Utility.CheckPermission(RoleManagerUtility2.ATTRIB_REFERTI_INFERMIERI_VIEW) Then
                    Dim DataMinimaFiltroInferimieri As Date = Utility.LimitaDataPerInfermieri(DataMinimaFiltro)
                    If DataMinimaFiltro < DataMinimaFiltroInferimieri Then
                        DataMinimaFiltro = DataMinimaFiltroInferimieri
                    End If
                    '
                    ' Aggiungo un item alla combo del filtro temporale e lo seleziono
                    '
                    Dim Item As New ListItem
                    Item.Text = "Ultimi 3 mesi"
                    Item.Value = 4
                    cmbFiltroTemporale.Items.Add(Item)
                    cmbFiltroTemporale.SelectedValue = 4
                    cmbFiltroTemporale.Attributes.Add("disabled", "disabled")
                End If
            End If
        Else
            DataMinimaFiltro = Nothing
        End If
    End Sub

    Protected Sub CmdCerca_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles CmdCerca.Click
        Cerca()
    End Sub

    Protected Sub Cerca()
        Try
            '
            ' Invalido la cache degli ObjectDataSource
            '
            DataSource_InvalidaCache()

            '
            ' Cancello dalla sessione la lista dei TipiReferto collegata alla lista dei referti
            '
            Me.Session(String.Format("{0}_{1}", KEY_REFERTI_LISTA_TIPIREFERTO, Me.IdPaziente.ToString)) = Nothing
            Me.Session(String.Format("{0}_{1}", KEY_PRESCRIZIONI_LISTA_TIPIREFERTO, Me.IdPaziente.ToString)) = Nothing
            Me.Session(String.Format("{0}_{1}", KEY_REFERTI_PER_EPISODI_LISTA_TIPIREFERTO, Me.IdPaziente.ToString)) = Nothing

            '
            ' Al cerca tolgo la selezione da tutte le checkbox dei tipi referto per evitare che venga restituita una lista filtrata.
            '
            For Each item As ListItem In TipoRefertoCheckboxList.Items
                item.Selected = False
            Next
            For Each item As ListItem In TipoPrescrizioneCheckboxList.Items
                item.Selected = False
            Next
            For Each item As ListItem In TipoRefertoPerEpisodioCheckboxList.Items
                item.Selected = False
            Next

            '
            ' Se i filtri sono validi eseguo il DataBind della tabella visualizzata
            '
            If ValidateFiltersValue() Then
                If MultiViewMain.GetActiveView Is ViewPrescrizioni Then
                    WebGridPrescrizioni.DataBind()
                    TipoPrescrizioneCheckboxList.DataBind()

                ElseIf MultiViewMain.GetActiveView Is ViewCalendario Then
                    CreateCalendarioReferti()

                ElseIf MultiViewMain.GetActiveView Is ViewRefertiEpisodi Then
                    WebGridRefertiEpisodi.DataBind()
                    TipoRefertoPerEpisodioCheckboxList.DataBind()

                ElseIf MultiViewMain.GetActiveView Is ViewRisultatoMatrice Then
                    DataSourcePrestazioniMatrice.Select()

                ElseIf MultiViewMain.GetActiveView Is ViewReferti Then
                    WebGridReferti.DataBind()
                    TipoRefertoCheckboxList.DataBind()

                ElseIf MultiViewMain.GetActiveView Is ViewSchedePaziente Then
                    WebGridEventiSingoli.DataBind()

                ElseIf MultiViewMain.GetActiveView Is ViewNoteAnamnestiche Then
                    gvNoteAnamnestiche.DataBind()
                End If
            Else
                Throw New ApplicationException("Verificare i valori di filtro!")
            End If

            '
            ' Salvo i filtri selezionati in sessione
            '
            SaveFilterValues()
        Catch ex As Threading.ThreadAbortException
            '
            ' Non faccio niente
            '
        Catch ex As ApplicationException
            ucTestataPaziente.mbValidationCancelSelect = True
            mbValidationCancelSelect = True
            divErrorMessage.Visible = True
            lblErrorMessage.Text = ex.Message
            Logging.WriteError(ex, Me.GetType.Name)
        Catch ex As Exception
            ucTestataPaziente.mbValidationCancelSelect = True
            mbValidationCancelSelect = True
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati!"
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

    Private Sub SetOldPageIndex()
        Try
            Dim oCurrentPageIndex As Object
            oCurrentPageIndex = Me.Session(mstrPageID & WebGridReferti.ID)
            If Not oCurrentPageIndex Is Nothing Then WebGridReferti.PageIndex = CType(oCurrentPageIndex, Integer)
            oCurrentPageIndex = Me.Session(mstrPageID & WebGridPrescrizioni.ID)
            If Not oCurrentPageIndex Is Nothing Then WebGridPrescrizioni.PageIndex = CType(oCurrentPageIndex, Integer)
        Catch
        End Try
    End Sub

    Private Sub RedirectToHome()
        Response.Redirect(Me.ResolveUrl("~/Default.aspx"), True)
    End Sub

#Region "Filtri"
    Private Sub cmbFiltroTemporale_SelectedIndexChanged(sender As Object, e As EventArgs) Handles cmbFiltroTemporale.SelectedIndexChanged
        Try
            '
            ' Imposto la data del filtro temporale in base all'item selezionato nella combo
            '
            Select Case cmbFiltroTemporale.SelectedValue
                Case -1
                    'Se l'item selezionato è -1(item vuoto) allora non faccio nulla.
                Case 0
                    txtDataDal.Text = Now.AddDays(-7).ToString("dd/MM/yyyy")
                Case 1
                    txtDataDal.Text = Now.AddMonths(-1).ToString("dd/MM/yyyy")
                Case 2
                    txtDataDal.Text = Now.AddYears(-1).ToString("dd/MM/yyyy")
                Case 3
                    txtDataDal.Text = Now.AddYears(-5).ToString("dd/MM/yyyy")
                Case Else
                    Throw New ApplicationException("L'item selezionato non esiste.")
            End Select

            '
            ' Cancello il contenuto della textbox txtAllaData quando seleziono un item dalla drop cmbFiltriTemporale
            '
            txtAllaData.Text = Nothing

            Cerca()
        Catch ex As Threading.ThreadAbortException
            '
            ' Non faccio niente
            '
        Catch ex As ApplicationException
            divErrorMessage.Visible = True
            lblErrorMessage.Text = ex.Message
        Catch ex As Exception
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati!"
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

    Private Sub LoadFilterValues()
        Dim sIdPaziente As String = Me.IdPaziente.ToString.ToUpper
        '
        ' Inizializzo DataDal
        '
        txtDataDal.Text = CType(Me.Session(mstrPageID & txtDataDal.ID & sIdPaziente), String)
        If String.IsNullOrEmpty(txtDataDal.Text) Then
            Dim iMaxDayBefore As Integer = CType(My.Settings.Referti_FiltroDataDal_DefaultDaysBeforeNow, Integer)
            If iMaxDayBefore > 0 Then
                txtDataDal.Text = Now.Date.AddDays(-iMaxDayBefore).ToString("dd/MM/yyyy")
            End If
        End If
        If Utility.GetSessionForzaturaConsenso(IdPaziente) = False Then
            '
            ' se non ho forzato il consenso imposto data minima
            '
            Dim dFiltroDataDal As Nullable(Of Date) = Nothing
            If Not String.IsNullOrEmpty(txtDataDal.Text) Then
                dFiltroDataDal = Date.Parse(txtDataDal.Text)
            End If
            dFiltroDataDal = Utility.LimitaDataByDataMinima(dFiltroDataDal, DataMinimaFiltro)
            If dFiltroDataDal.HasValue Then
                txtDataDal.Text = dFiltroDataDal.Value.ToShortDateString()
            End If
        End If

        '
        ' Inizializzo AllaData
        '
        txtAllaData.Text = CType(Me.Session(mstrPageID & txtAllaData.ID & sIdPaziente), String)

        '
        'Ottengo il valore della combo salvato in sessione.
        '
        Dim sCmbFiltroTemporale As String = Me.Session(mstrPageID & cmbFiltroTemporale.ID & sIdPaziente)
        '
        'Se sCmbFiltroTemporale è nothing allora setto come default "Ultimo Anno" altrimenti setto come default il valore salvato in sessione
        '
        If Not String.IsNullOrEmpty(sCmbFiltroTemporale) Then
            cmbFiltroTemporale.SelectedValue = sCmbFiltroTemporale
        Else
            cmbFiltroTemporale.SelectedValue = 2
        End If
    End Sub

    Private Sub SaveFilterValues()
        Dim sIdPaziente As String = IdPaziente.ToString.ToUpper
        Me.Session(mstrPageID & txtDataDal.ID & sIdPaziente) = txtDataDal.Text
        Me.Session(mstrPageID & txtAllaData.ID & sIdPaziente) = txtAllaData.Text

        '
        'Salvo in sessione il valore della combo cmbFiltroTemporale.
        '
        Me.Session(mstrPageID & cmbFiltroTemporale.ID & sIdPaziente) = cmbFiltroTemporale.SelectedValue
    End Sub

    Private Function ValidateFiltersValue() As Boolean
        Dim bValidation As Boolean = True
        Dim odate As DateTime
        Try
            '
            ' Se l'utente è un infermiere disabilito la combo del filtro temporale e imposta la data di default
            '
            If Utility.CheckPermission(RoleManagerUtility2.ATTRIB_REFERTI_INFERMIERI_VIEW) Then
                Dim Data As Date = CType(txtDataDal.Text, Date)
            End If

            '
            ' Se c'è data minima devo validare la data inserita dall'utente con la data minima 
            ' Al page load come data di filtro iniziale al limeite devo mettere la data minima
            ' Eventualmente modifica la data txtDataDal.text
            '
            If Utility.GetSessionForzaturaConsenso(IdPaziente) = False Then
                '
                ' se non ho forzato il consenso imposto data minima
                '
                Dim dFiltroDataDal As Nullable(Of Date) = Nothing
                If Not String.IsNullOrEmpty(txtDataDal.Text) Then
                    dFiltroDataDal = Date.Parse(txtDataDal.Text)
                End If
                dFiltroDataDal = Utility.LimitaDataByDataMinima(dFiltroDataDal, DataMinimaFiltro)
                If dFiltroDataDal.HasValue Then
                    txtDataDal.Text = dFiltroDataDal.Value.ToShortDateString()
                End If
            End If
            '
            ' Controllo sempre il dato presente nel filtro
            '
            If txtDataDal.Text.Length > 0 Then
                If Not Date.TryParse(txtDataDal.Text, odate) Then
                    bValidation = False
                End If
            End If

            '
            ' Controllo se la DataAl è minore di DataDal
            '
            If txtAllaData.Text.Length > 0 Then
                If Not Date.TryParse(txtAllaData.Text, odate) Then
                    bValidation = False
                ElseIf CDate(txtAllaData.Text) < CDate(txtDataDal.Text) Then
                    bValidation = False
                End If
            End If
        Catch ex As Threading.ThreadAbortException
            '
            ' Non faccio niente
            '
        Catch ex As Exception
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'operazione di validazione dei filtri!"
            Logging.WriteWarning("Errore durante l'operazione di validazione dei filtri!" & vbCrLf & Utility.FormatException(ex))
            bValidation = False
        End Try
        mbValidationCancelSelect = Not bValidation
        Return bValidation
    End Function

    Private Sub cmdApplicaFiltri_Click(sender As Object, e As EventArgs) Handles cmdApplicaFiltri.Click
        Try
            '
            ' In base alla griglia visualizzata quando premo sul pulsante deseleziono tutte le checkbox dei filtri laterali e eseguo il bind dei dati.
            '
            If MultiViewMain.GetActiveView().ID = "ViewReferti" Then
                For Each item As ListItem In TipoRefertoCheckboxList.Items
                    item.Selected = False
                Next
                WebGridReferti.DataBind()
            ElseIf MultiViewMain.GetActiveView.ID = "ViewPrescrizioni" Then
                For Each item As ListItem In TipoPrescrizioneCheckboxList.Items
                    item.Selected = False
                Next
                WebGridPrescrizioni.DataBind()
            ElseIf MultiViewMain.GetActiveView.ID = "ViewRefertiEpisodi" Then
                For Each item As ListItem In TipoRefertoPerEpisodioCheckboxList.Items
                    item.Selected = False
                Next
                divWebGridRefertiEpisodi.DataBind()
            End If
        Catch ex As Threading.ThreadAbortException
            '
            ' Non faccio niente
            '
        Catch ex As Exception
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante il click sul bottone 'Applica Filtro'"
            Logging.WriteError(ex, Me.GetType.Name)
        End Try

    End Sub
#End Region

#Region "ObjectDataSource"

#Region "DataSourceRefertiSingoli"
    Private Sub DataSourceRefertiSingoli_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles DataSourceRefertiSingoli.Selecting
        Try
            If mbValidationCancelSelect Then
                e.Cancel = True
                Exit Sub
            End If

            ' MOMENTANEAMENTE NON UTILIZZATO PERCHE' GLI HEADER E IL SORTING DELLE TABELLE SONO DISABILITATI
            ' ORDINAMENTO
            'If Me.GridViewSortExpression.Length > 0 Then
            '    Dim sDir = If(Me.GridViewSortDirection = WebControls.SortDirection.Ascending, "@ASC", "@DESC")
            '    e.InputParameters("Ordinamento") = Me.GridViewSortExpression & sDir
            'End If
            e.InputParameters("ByPassaConsenso") = Utility.GetSessionForzaturaConsenso(Me.IdPaziente)
            e.InputParameters("IdPaziente") = Me.IdPaziente
            e.InputParameters("Token") = Me.Token()
        Catch ex As Threading.ThreadAbortException
            '
            ' Non faccio niente
            '
        Catch ex As Exception
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati!"
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

    Private Sub DataSourceRefertiSingoli_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles DataSourceRefertiSingoli.Selected
        Try
            divWebGridEventiSingoli.Visible = False
            btnExecutePrint.Visible = True
            divErrorMessage.Visible = False
            FiltriCheckBoxList.Visible = False

            'Ottengo il messaggio di errore.
            Dim messaggioErrore = HelperDataSourceException.GetObjectDataSourceExceptionMessage(e.Exception)

            'Testo se il messaggio di errore è vuoto. Se è valorizzato allora mostro il div d'errore.
            If Not String.IsNullOrEmpty(messaggioErrore) Then
                divErrorMessage.Visible = True
                lblErrorMessage.Text = messaggioErrore
                e.ExceptionHandled = True
            Else
                Dim result As List(Of WcfDwhClinico.RefertoListaType) = CType(e.ReturnValue, List(Of WcfDwhClinico.RefertoListaType))

                If result IsNot Nothing AndAlso result.Count > 0 Then
                    divWebGridEventiSingoli.Visible = True
                Else
                    Dim sMsgNoRecord As String = "Non è stata trovata nessuna scheda. Modificare eventualmente i parametri di filtro."
                    divMessageEventiSingoli.Visible = True
                    divMessageEventiSingoli.InnerText = sMsgNoRecord
                    divWebGridEventiSingoli.Visible = False
                    btnExecutePrint.Visible = False
                End If
            End If
        Catch ex As Threading.ThreadAbortException
            '
            ' Non faccio niente
            '
        Catch ex As Exception
            '
            ' Errore
            '
            Logging.WriteError(ex, Me.GetType.Name)
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati!"
        End Try
    End Sub
#End Region

#Region "DataSourceMain"

    Protected Sub DataSourceMain_Selected(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles DataSourceMain.Selected
        Try
            divWebGridReferti.Visible = False
            btnExecutePrint.Visible = True
            divErrorMessage.Visible = False
            '
            ' visualizzo il pulsante per filtrare e la checkboxlist solo se la griglia non è vuota
            '
            FiltriCheckBoxList.Visible = False

            'Ottengo il messaggio di errore.
            Dim messaggioErrore = HelperDataSourceException.GetObjectDataSourceExceptionMessage(e.Exception)

            'Testo se il messaggio di errore è vuoto. Se è valorizzato allora mostro il div d'errore.
            If Not String.IsNullOrEmpty(messaggioErrore) Then
                divErrorMessage.Visible = True
                lblErrorMessage.Text = messaggioErrore
                e.ExceptionHandled = True
            Else
                'casto e.ReturnValue al tipo giusto.
                Dim referti As List(Of WcfDwhClinico.RefertoListaType) = CType(e.ReturnValue, List(Of WcfDwhClinico.RefertoListaType))

                If referti IsNot Nothing AndAlso referti.Count > 0 Then
                    divWebGridReferti.Visible = True
                    FiltriCheckBoxList.Visible = True
                Else
                    'se sono qui la lista è vuota, quindi nascondo i filtri laterali, la checkbox per la selezione dei referti e mostro il div contenente il messaggio di lista vuota.
                    Dim sMsgNoRecord As String = "Non è stato trovato nessun referto. Modificare eventualmente i parametri di filtro."
                    divMessageReferti.Visible = True
                    divMessageReferti.InnerText = sMsgNoRecord
                    divWebGridReferti.Visible = False
                    FiltriCheckBoxList.Visible = False
                    btnExecutePrint.Visible = False
                End If
            End If
        Catch ex As Threading.ThreadAbortException
            '
            ' Non faccio niente

        Catch ex As Exception
            '
            ' Errore
            '
            Logging.WriteError(ex, Me.GetType.Name)
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati!"
        End Try

        Trace.Write("fine selected")
    End Sub

    Protected Sub DataSourceMain_Selecting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.ObjectDataSourceSelectingEventArgs) Handles DataSourceMain.Selecting
        Try
            Dim lstFiltriTipiReferto As New List(Of String)

            If mbValidationCancelSelect Then
                e.Cancel = True
                Exit Sub
            End If

            ' MOMENTANEAMENTE NON UTILIZZATO PERCHE' GLI HEADER E IL SORTING DELLE TABELLE SONO DISABILITATI
            ' ORDINAMENTO
            'If Me.GridViewSortExpression.Length > 0 Then
            '    Dim sDir = If(Me.GridViewSortDirection = WebControls.SortDirection.Ascending, "@ASC", "@DESC")
            '    e.InputParameters("Ordinamento") = Me.GridViewSortExpression & sDir
            'End If


            e.InputParameters("ByPassaConsenso") = Utility.GetSessionForzaturaConsenso(Me.IdPaziente)
            e.InputParameters("IdPaziente") = IdPaziente

            '
            ' Svuoto la lista contenente i filtri per tipi referto
            '
            lstFiltriTipiReferto.Clear()

            '
            ' Riempio la lista dei filtri in base alle checkbox selezionate nel filtro di spalla dx
            '
            For Each item As ListItem In TipoRefertoCheckboxList.Items
                If item.Selected Then
                    lstFiltriTipiReferto.Add(item.Value)
                End If
            Next

            e.InputParameters("lstFiltriTipiReferto") = lstFiltriTipiReferto
            e.InputParameters("Token") = Me.Token()

        Catch ex As Threading.ThreadAbortException
            '
            ' Non faccio niente
            '
        Catch ex As Exception
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati!"
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

#End Region

#Region "DataSourcePrestazioniMatrice"

    Protected Sub DataSourcePrestazioniMatrice_Selected(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles DataSourcePrestazioniMatrice.Selected
        Try
            'Nascondo i div d'errore.
            divErrorMessage.Visible = False

            'Ottengo il messaggio di errore.
            Dim messaggioErrore = HelperDataSourceException.GetObjectDataSourceExceptionMessage(e.Exception)

            'Testo se il messaggio di errore è vuoto. Se è valorizzato allora mostro il div d'errore.
            If Not String.IsNullOrEmpty(messaggioErrore) Then
                divErrorMessage.Visible = True
                lblErrorMessage.Text = messaggioErrore
                e.ExceptionHandled = True
            Else
                Dim result As WcfDwhClinico.MatricePrestazioniListaType = CType(e.ReturnValue, WcfDwhClinico.MatricePrestazioniListaType)
                If Not result Is Nothing AndAlso result.Count > 0 Then
                    '
                    ' Trasformo la lista delle matrici in un xml 
                    '
                    Dim oDt As WcfDwhClinico.MatricePrestazioniListaType = CType(e.ReturnValue, WcfDwhClinico.MatricePrestazioniListaType)
                    Dim strXml As String = String.Empty
                    Dim xmlSerializer As New System.Xml.Serialization.XmlSerializer(oDt.GetType)
                    Using memoryStream As New IO.MemoryStream
                        xmlSerializer.Serialize(memoryStream, oDt)
                        memoryStream.Position = 0
                        strXml = New IO.StreamReader(memoryStream).ReadToEnd
                    End Using
                    XmlRisultatoMatrice.DocumentContent = strXml
                    XmlRisultatoMatrice.DataBind()
                    btnCollapseMatrice.Visible = True
                Else
                    Dim sMsgNoRecord As String = "La ricerca non ha prodotto risultati. Modificare eventualmente i parametri di filtro."
                    divMessageMatrice.Visible = True
                    divMessageMatrice.InnerText = sMsgNoRecord
                    btnCollapseMatrice.Visible = False
                End If
            End If
        Catch ex As Threading.ThreadAbortException
            '
            ' Non faccio niente
            '
        Catch ex As ApplicationException
            divErrorMessage.Visible = True
            lblErrorMessage.Text = ex.Message
            Logging.WriteError(ex, Me.GetType.Name)
        Catch ex As Exception
            '
            ' Errore
            '
            Logging.WriteError(ex, Me.GetType.Name)
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati Prestazioni a Matrice!"
        End Try
    End Sub

    Protected Sub DataSourcePrestazioniMatrice_Selecting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.ObjectDataSourceSelectingEventArgs) Handles DataSourcePrestazioniMatrice.Selecting
        Try
            If mbValidationCancelSelect = True Then
                e.Cancel = True
                Exit Sub
            End If

            ' MOMENTANEAMENTE NON UTILIZZATO PERCHE' GLI HEADER E IL SORTING DELLE TABELLE SONO DISABILITATI
            ' ORDINAMENTO
            'If Me.GridViewSortExpression.Length > 0 Then
            '    Dim sDir = If(Me.GridViewSortDirection = WebControls.SortDirection.Ascending, "@ASC", "@DESC")
            '    e.InputParameters("Ordinamento") = Me.GridViewSortExpression & sDir
            'End If

            e.InputParameters("ByPassaConsenso") = Utility.GetSessionForzaturaConsenso(Me.IdPaziente)
            e.InputParameters("IdPaziente") = IdPaziente
            e.InputParameters("PrestazioneCodice") = Nothing
            e.InputParameters("SezioneCodice") = Nothing
            e.InputParameters("Token") = Me.Token()
        Catch ex As Threading.ThreadAbortException
            '
            ' Non faccio niente
            '
        Catch ex As ApplicationException
            divErrorMessage.Visible = True
            lblErrorMessage.Text = ex.Message
            Logging.WriteError(ex, Me.GetType.Name)
        Catch ex As Exception
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati Prestazioni a Matrice!"
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

#End Region

#Region "DataSourcePrescrizioni"

    Private Sub DataSourcePrescrizioni_Selected(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles DataSourcePrescrizioni.Selected
        Try
            divWebGridPrescrizione.Visible = False
            btnExecutePrint.Visible = True
            divErrorMessage.Visible = False
            '
            ' visualizzo il pulsante per filtrare e la checkboxlist solo se la griglia non è vuota
            '
            FiltriCheckBoxList.Visible = True

            'Ottengo il messaggio di errore.
            Dim messaggioErrore = HelperDataSourceException.GetObjectDataSourceExceptionMessage(e.Exception)

            'Testo se il messaggio di errore è vuoto. Se è valorizzato allora mostro il div d'errore.
            If Not String.IsNullOrEmpty(messaggioErrore) Then
                divErrorMessage.Visible = True
                lblErrorMessage.Text = messaggioErrore
                e.ExceptionHandled = True
            Else
                Dim result As List(Of WcfDwhClinico.PrescrizioneListaType) = CType(e.ReturnValue, List(Of WcfDwhClinico.PrescrizioneListaType))

                If result IsNot Nothing AndAlso result.Count > 0 Then
                    divWebGridPrescrizione.Visible = True
                Else
                    Dim sMsgNoRecord As String = "Non è stata trovata nessuna impegnativa. Modificare eventualmente i parametri di filtro."
                    divMessagePrescrizioni.Visible = True
                    divMessagePrescrizioni.InnerText = sMsgNoRecord
                    divWebGridPrescrizione.Visible = False
                    FiltriCheckBoxList.Visible = False
                    btnExecutePrint.Visible = False
                End If
            End If
        Catch ex As Threading.ThreadAbortException
            '
            ' Non faccio niente
            '
        Catch ex As ApplicationException
            divErrorMessage.Visible = True
            lblErrorMessage.Text = ex.Message
            Logging.WriteError(ex, Me.GetType.Name)
        Catch ex As Exception
            '
            ' Errore
            '
            Logging.WriteError(ex, Me.GetType.Name)
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati!"
        End Try
    End Sub

    Private Sub DataSourcePrescrizioni_Selecting(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceSelectingEventArgs) Handles DataSourcePrescrizioni.Selecting
        Try
            Dim lstFiltriTipiPrescrizione As New List(Of String)

            If mbValidationCancelSelect Then
                e.Cancel = True
                Exit Sub
            End If

            ' MOMENTANEAMENTE NON UTILIZZATO PERCHE' GLI HEADER E IL SORTING DELLE TABELLE SONO DISABILITATI
            ' ORDINAMENTO
            'If Me.GridViewSortExpression.Length > 0 Then
            '    Dim sDir = If(Me.GridViewSortDirection = WebControls.SortDirection.Ascending, "@ASC", "@DESC")
            '    e.InputParameters("Ordinamento") = Me.GridViewSortExpression & sDir
            'End If
            e.InputParameters("ByPassaConsenso") = Utility.GetSessionForzaturaConsenso(Me.IdPaziente)
            e.InputParameters("IdPaziente") = IdPaziente

            '
            ' Svuoto la lista contenente i filtri per tipi referto
            '
            lstFiltriTipiPrescrizione.Clear()

            '
            ' Riempio la lista dei filtri in base alle checkbox selezionate nel filtro di spalla dx
            '
            For Each item As ListItem In TipoPrescrizioneCheckboxList.Items
                If item.Selected Then
                    lstFiltriTipiPrescrizione.Add(item.Value)
                End If
            Next

            e.InputParameters("lstFiltriTipiPrescrizione") = lstFiltriTipiPrescrizione
            e.InputParameters("Token") = Me.Token
        Catch ex As Threading.ThreadAbortException
            '
            ' Non faccio niente
            '
        Catch ex As ApplicationException
            divErrorMessage.Visible = True
            lblErrorMessage.Text = ex.Message
            Logging.WriteError(ex, Me.GetType.Name)
        Catch ex As Exception
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati!"
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

#End Region

#Region "DataSourceEpisodi"
    Private Sub DataSourceEpisodi_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles DataSourceEpisodi.Selecting
        Try
            If mbValidationCancelSelect Then
                e.Cancel = True
                Exit Sub
            End If

            ' MOMENTANEAMENTE NON UTILIZZATO PERCHE' GLI HEADER E IL SORTING DELLE TABELLE SONO DISABILITATI
            ' ORDINAMENTO
            'If Me.GridViewSortExpression.Length > 0 Then
            '    Dim sDir = If(Me.GridViewSortDirection = WebControls.SortDirection.Ascending, "@ASC", "@DESC")
            '    e.InputParameters("Ordinamento") = Me.GridViewSortExpression & sDir
            'End If

            e.InputParameters("ByPassaConsenso") = Utility.GetSessionForzaturaConsenso(Me.IdPaziente)
            e.InputParameters("IdPaziente") = Me.IdPaziente
            e.InputParameters("Token") = Me.Token

        Catch ex As Threading.ThreadAbortException
            '
            ' Non faccio niente
            '
        Catch ex As ApplicationException
            divErrorMessage.Visible = True
            lblErrorMessage.Text = ex.Message
            Logging.WriteError(ex, Me.GetType.Name)
        Catch ex As Exception
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati!"
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

    Private Sub DataSourceEpisodi_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles DataSourceEpisodi.Selected
        Try
            divWebGridRefertiEpisodi.Visible = False
            btnExecutePrint.Visible = True
            divErrorMessage.Visible = False
            '
            ' nascondo il pulsante per filtrare la checkboxlist
            '
            FiltriCheckBoxList.Visible = False

            'Ottengo il messaggio di errore.
            Dim messaggioErrore = HelperDataSourceException.GetObjectDataSourceExceptionMessage(e.Exception)

            'Testo se il messaggio di errore è vuoto. Se è valorizzato allora mostro il div d'errore.
            If Not String.IsNullOrEmpty(messaggioErrore) Then
                divErrorMessage.Visible = True
                lblErrorMessage.Text = messaggioErrore
                e.ExceptionHandled = True
            Else
                Dim result As List(Of WcfDwhClinico.EpisodioListaType) = CType(e.ReturnValue, List(Of WcfDwhClinico.EpisodioListaType))

                If result IsNot Nothing AndAlso result.Count > 0 Then
                    FiltriCheckBoxList.Visible = True
                    divWebGridRefertiEpisodi.Visible = True
                Else
                    Dim sMsgNoRecord As String = "Non è stato trovato nessun episodio. Modificare eventualmente i parametri di filtro."
                    divMessageEpisodi.Visible = True
                    divMessageEpisodi.InnerText = sMsgNoRecord
                    divWebGridRefertiEpisodi.Visible = False
                    FiltriCheckBoxList.Visible = False
                    btnExecutePrint.Visible = False
                End If
            End If
        Catch ex As Threading.ThreadAbortException
            '
            ' Non faccio niente
            '
        Catch ex As ApplicationException
            divErrorMessage.Visible = True
            lblErrorMessage.Text = ex.Message
            Logging.WriteError(ex, Me.GetType.Name)
        Catch ex As Exception
            '
            ' Errore
            '
            Logging.WriteError(ex, Me.GetType.Name)
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati!"
        End Try
    End Sub
#End Region

#Region "DataSourceEventiEpisodi"
    Private Sub DataSourceEventiEpisodio_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles DataSourceEventiEpisodio.Selecting
        Try
            If mbValidationCancelSelect Or mbValidationSelect Then
                e.Cancel = True
                Exit Sub
            End If
            e.InputParameters("Token") = Me.Token
            e.InputParameters("IdRicovero") = Me.IdEpisodio
        Catch ex As Threading.ThreadAbortException
            '
            ' Non faccio niente
            '
        Catch ex As ApplicationException
            divErrorMessage.Visible = True
            lblErrorMessage.Text = ex.Message
            Logging.WriteError(ex, Me.GetType.Name)
        Catch ex As Exception
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati!"
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

    Private Sub DataSourceEventiEpisodio_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles DataSourceEventiEpisodio.Selected
        Try
            WebGridEventiEpisodio.Visible = False
            btnExecutePrint.Visible = True
            divErrorMessage.Visible = False
            '
            ' visualizzo il pulsante per filtrare e la checkboxlist solo se la griglia non è vuota
            '
            FiltriCheckBoxList.Visible = True

            'Ottengo il messaggio di errore.
            Dim messaggioErrore = HelperDataSourceException.GetObjectDataSourceExceptionMessage(e.Exception)

            'Testo se il messaggio di errore è vuoto. Se è valorizzato allora mostro il div d'errore.
            If Not String.IsNullOrEmpty(messaggioErrore) Then
                divErrorMessage.Visible = True
                lblErrorMessage.Text = messaggioErrore
                e.ExceptionHandled = True
            Else
                Dim result As WcfDwhClinico.EventiType = CType(e.ReturnValue, WcfDwhClinico.EventiType)
                If Not result Is Nothing AndAlso result.Count > 0 Then
                    WebGridEventiEpisodio.Visible = True
                Else
                    Dim sMsgNoRecord As String = "Non è stato trovato nessun referto. Modificare eventualmente i parametri di filtro."
                    WebGridEventiEpisodio.Visible = False
                End If
            End If
        Catch ex As Threading.ThreadAbortException
            '
            ' Non faccio niente
            '
        Catch ex As ApplicationException
            divErrorMessage.Visible = True
            lblErrorMessage.Text = ex.Message
            Logging.WriteError(ex, Me.GetType.Name)
        Catch ex As Exception
            '
            ' Errore
            '
            Logging.WriteError(ex, Me.GetType.Name)
            alertErrorEventiModal.Visible = True
            eventiModalLblError.Text = "Errore durante l'operazione di ricerca dei dati!"
        End Try
    End Sub

#End Region

#Region "DataSourceNoteAnamnestiche"
    Private Sub DataSourceNoteAnamnestiche_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles DataSourceNoteAnamnestiche.Selecting
        Try
            '
            'Utilizzo la setting ShowNoteAnamnesticheTab per denterminare se eseguire la query oppure no.
            '
            If mbValidationCancelSelect OrElse Not My.Settings.ShowNoteAnamnesticheTab Then
                '
                'Cancello la select e esco.
                '
                e.Cancel = True
                Exit Sub
            End If

            '
            'Verifico se bisogna forzare il consenso oppure no.
            '
            e.InputParameters("ByPassaConsenso") = Utility.GetSessionForzaturaConsenso(Me.IdPaziente)

            e.InputParameters("IdPaziente") = IdPaziente
            e.InputParameters("Token") = Me.Token()
        Catch ex As Threading.ThreadAbortException
            '
            ' Non faccio niente
            '
        Catch ex As Exception
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati!"
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

    Private Sub DataSourceNoteAnamnestiche_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles DataSourceNoteAnamnestiche.Selected
        Try
            '
            'Nascondo il div che contiene la griglia e il div di errore.
            '
            divWebGridNoteAnamnestiche.Visible = False
            divErrorMessage.Visible = False

            'Ottengo il messaggio di errore.
            Dim messaggioErrore = HelperDataSourceException.GetObjectDataSourceExceptionMessage(e.Exception)

            'Testo se il messaggio di errore è vuoto. Se è valorizzato allora mostro il div d'errore.
            If Not String.IsNullOrEmpty(messaggioErrore) Then
                divErrorMessage.Visible = True
                lblErrorMessage.Text = messaggioErrore
                e.ExceptionHandled = True
            Else
                '
                'Se sono qui significa che non si sono verificari errori.
                '
                Dim result As WcfDwhClinico.NoteAnamnesticheListaType = CType(e.ReturnValue, WcfDwhClinico.NoteAnamnesticheListaType)

                If result IsNot Nothing AndAlso result.Count > 0 Then
                    '
                    'Mostro la tabella.
                    '
                    divWebGridNoteAnamnestiche.Visible = True
                Else
                    '
                    'Mostro un messaggio per indicare all'utente che non sono stati trovati record.
                    '
                    divMessageNoteAnamnestiche.Visible = True
                    divMessageNoteAnamnestiche.InnerText = "Non è stata trovata nessuna nota anamnestica. Modificare eventualmente i parametri di filtro."

                    '
                    'Nascondo la tabella.
                    '
                    divWebGridNoteAnamnestiche.Visible = False
                End If
            End If

        Catch ex As Threading.ThreadAbortException
            '
            ' Non faccio niente
            '
        Catch ex As Exception
            '
            ' Errore
            '
            Logging.WriteError(ex, Me.GetType.Name)
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati!"
        End Try
    End Sub
#End Region

    Private Sub DataSource_InvalidaCache()
        '
        ' Invalido la cache della datasource 
        '
        If MultiViewMain.GetActiveView Is ViewPrescrizioni Then
            Dim dsPrescrizioni As New CustomDataSource.PrescrizioniCercaPerIdPaziente()
            dsPrescrizioni.ClearCache()

        ElseIf MultiViewMain.GetActiveView Is ViewCalendario Then
            Dim dsRefertiCalendario As New CalendarDataSource()
            Dim dsEpisodiCalendario As New CalendarDataSource.EpisodiCercaPerIdPaziente()
            dsRefertiCalendario.ClearCache(Me.IdPaziente)
            dsEpisodiCalendario.ClearCache(Me.IdPaziente)

        ElseIf MultiViewMain.GetActiveView Is ViewRefertiEpisodi Then
            Dim dsEpisodiReferti As New CustomDataSource.EpisodiCercaPerIdPaziente
            dsEpisodiReferti.ClearCache(Me.IdPaziente)
            InvalidaCacheRefertiPerNosologico = True

        ElseIf MultiViewMain.GetActiveView Is ViewRisultatoMatrice Then
            Dim dsMatrici As New CustomDataSource.MatricePrestazioniLabCercaPerIdPaziente
            dsMatrici.ClearCache(Me.IdPaziente)

        ElseIf MultiViewMain.GetActiveView Is ViewReferti Then
            Dim dsReferti As New CustomDataSource.RefertiCercaPerIdPaziente()
            dsReferti.ClearCache(Me.IdPaziente)

        ElseIf MultiViewMain.GetActiveView Is ViewSchedePaziente Then
            Dim dsEpisodiSingoli As New CustomDataSource.RefertiCercaRefertiSingoli
            dsEpisodiSingoli.ClearCache(Me.IdPaziente)

        ElseIf MultiViewMain.GetActiveView Is ViewNoteAnamnestiche Then
            Dim dsNoteAnamnestiche As New CustomDataSource.NoteAnamnesticheCercaPerIdPaziente
            dsNoteAnamnestiche.ClearCache()
        Else
            Throw New ApplicationException("Si è verificato un errore durante il caricamento dei dati.")
        End If
    End Sub
#End Region

#Region "Stampa Referti"
    Private Sub AddRefertoToPrintList(oList As System.Collections.Specialized.StringCollection, oCheckBox As CheckBox, sIdReferto As String)
        If Not oCheckBox Is Nothing AndAlso oCheckBox.Checked Then
            '
            ' Se la lista non contiene già l'id del referto allora lo aggiungo
            '
            If Not oList.Contains(sIdReferto) Then
                oList.Add(sIdReferto)
            End If
            oCheckBox.Checked = False
        End If
    End Sub

    Private Sub AddRefertoToPrintList(oList As List(Of PrintUtil.RefertiDaStampare), oCheckBox As CheckBox, oDataKey As DataKey)
        If Not oCheckBox Is Nothing AndAlso oCheckBox.Checked Then
            Dim sIdReferto As String = CType(oDataKey(0), String)
            Dim oRefertoDaStampare As New PrintUtil.RefertiDaStampare
            oRefertoDaStampare.IdReferto = New Guid(sIdReferto)
            oRefertoDaStampare.AziendaErogante = CType(oDataKey(1), String)
            oRefertoDaStampare.SistemaErogante = CType(oDataKey(2), String)
            If Not oDataKey(3) Is Nothing Then
                oRefertoDaStampare.Cognome = CType(oDataKey(3), String)
            End If
            If Not oDataKey(4) Is Nothing Then
                oRefertoDaStampare.Nome = CType(oDataKey(4), String)
            End If
            If Not oDataKey(5) Is Nothing Then
                oRefertoDaStampare.NumeroNosologico = CType(oDataKey(5), String)
            End If
            If Not oDataKey(6) Is Nothing Then
                oRefertoDaStampare.NumeroReferto = CType(oDataKey(6), String)
            End If
            oList.Add(oRefertoDaStampare)
            oCheckBox.Checked = False
        End If
    End Sub

    Private Sub GetRefertiEpisodiPrintList(oGrid As GridView, oList As List(Of PrintUtil.RefertiDaStampare))
        If Not oGrid Is Nothing Then
            For Each oGridRow As GridViewRow In oGrid.Rows
                If oGridRow.RowType = DataControlRowType.DataRow Then
                    '
                    ' Recupero la tabella dei referti innestata dentro la tabella degli episodi
                    '
                    Dim oNestedGrid As GridView = CType(oGridRow.FindControl("WebGridrefertiPerNosologico"), GridView)
                    For Each oNestedGridRow As GridViewRow In oNestedGrid.Rows
                        '
                        ' Recupero la checkbox
                        '
                        Dim oChekBox As CheckBox = CType(oNestedGridRow.FindControl("chkSelect"), CheckBox)
                        AddRefertoToPrintList(oList, oChekBox, oNestedGrid.DataKeys.Item(oNestedGridRow.RowIndex))
                    Next
                End If
            Next
        End If
    End Sub

    Private Sub GetRefertiPrintList(oGrid As GridView, oList As System.Collections.Specialized.StringCollection)
        If Not oGrid Is Nothing Then
            For Each oGridRow As GridViewRow In oGrid.Rows
                If oGridRow.RowType = DataControlRowType.DataRow Then
                    '
                    ' Recupero la checkbox dalla row
                    '
                    Dim oChekBox As CheckBox = CType(oGridRow.FindControl("chkSelect"), CheckBox)
                    '
                    ' Recupero l'id del referto dalla row 
                    '
                    Dim sIdReferto As String = oGrid.DataKeys.Item(oGridRow.RowIndex).Value.ToString
                    AddRefertoToPrintList(oList, oChekBox, sIdReferto)
                End If
            Next
        End If
    End Sub

    Private Sub GetRefertiPrintList(oGrid As GridView, oList As List(Of PrintUtil.RefertiDaStampare))
        If Not oGrid Is Nothing Then
            For Each oGridRow As GridViewRow In oGrid.Rows
                If oGridRow.RowType = DataControlRowType.DataRow Then
                    '
                    ' Recupero la checkbox dalla row
                    '
                    Dim oChekBox As CheckBox = CType(oGridRow.FindControl("chkSelect"), CheckBox)
                    AddRefertoToPrintList(oList, oChekBox, oGrid.DataKeys.Item(oGridRow.RowIndex))
                End If
            Next
        End If
    End Sub

    Protected Sub btnExecutePrint_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnExecutePrint.Click
        Try
            '
            ' Ottengo la griglia visibile
            '
            Dim oGrid As GridView = GetVisibleDataGrid2()
            Dim oList As New List(Of PrintUtil.RefertiDaStampare)

            '
            ' Se la griglia è la WebGridRefertiEpisodi allora devo cercare nella tabella dei referti innestata
            ' Altrimenti posso cercare direttamente le checkbox nelle row
            '
            If oGrid Is WebGridRefertiEpisodi Then
                GetRefertiEpisodiPrintList(oGrid, oList)
            Else
                GetRefertiPrintList(oGrid, oList)
            End If

            If Not oList Is Nothing AndAlso oList.Count > 0 Then
                '
                ' MODIFICA ETTORE 2016-11-24: Cerco la configurazione di stampa
                '
                Dim oPrintingConfig As PrintUtil.PrintingConfig = PrintUtil.GetMyPrintingConfig()
                If (Not oPrintingConfig Is Nothing) AndAlso
                        (Not String.IsNullOrEmpty(oPrintingConfig.PrinterServerName)) AndAlso
                        (Not String.IsNullOrEmpty(oPrintingConfig.PrinterName)) Then
                    '
                    ' Salvo in sessione la lista dei referti da stampare
                    '
                    PrintUtil.SessionRefertiDaStampare = oList
                    '
                    ' Recupero le informazioni della stampante
                    '
                    Dim sPrinterServer As String = oPrintingConfig.PrinterServerName
                    Dim sPrinterName As String = oPrintingConfig.PrinterName
                    '
                    'Valorizzo le property di StampaReferti
                    '
                    StampaReferti.PrinterName = sPrinterName
                    StampaReferti.PrinterServerName = sPrinterServer

                    StampaReferti.Token = Me.Token
                    StampaReferti.StampaReferto()

                    '
                    'Registro lo script che apre la modale Boostrap
                    '
                    Dim functionJS As String = "$('#ModalStampa').modal('show');"
                    ScriptManager.RegisterStartupScript(Page, Page.GetType, "LanchServerSide", functionJS, True)
                Else
                    '
                    ' Redirigo alla pagina di configurazione stampante
                    '
                    Dim sUrl As String = PrintUtil.GetPrinterConfigPage(Nothing)
                    Me.Response.Redirect(Me.ResolveUrl(sUrl), False)
                End If

            Else
                Dim sMsg As String = "Non è stato selezionato nessun referto per la stampa." & vbCrLf & "Selezionare uno o più referti utilizzando le caselle di spunta sulla lista!"
                ClientScript.RegisterStartupScript(Page.GetType(), "btnExecutePrint_Click", JSBuildScript(JSAlertCode(sMsg)))
            End If
        Catch ex As Exception
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante la stampa dei referti!"
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub
#End Region

#Region "Patient Summary"

    ''' <summary>
    ''' QUESTA DEVE ESSERE INVOCATA TRAMITE AJAX; l'apertura della pagina e/o messaggio utente potrebbe essere fatto lato client
    ''' </summary>
    ''' <remarks></remarks>
    <System.Web.Services.WebMethod()>
    Public Shared Function ShowPatientSummary(ByVal RichiedenteCodiceFiscale As String, ByVal RichiedenteCognome As String, ByVal RichiedenteNome As String, ByVal PazienteCodiceFiscale As String, ByVal IdPaziente As String) As Boolean
        Dim bIsValid As Boolean = False
        Dim iPdfLength As Integer = 0
        Try
            If My.Settings.PatientSummaryEnabled = True Then
                '
                ' Eseguo invocazione al web service solo se 
                '   1) PazienteCodiceFiscale è valorizzato e diverso dal "codicefiscale nullo"
                '   2) RichiedenteCognome e RichiedenteNome sono valorizzati
                '
                If (Not String.IsNullOrEmpty(PazienteCodiceFiscale) AndAlso PazienteCodiceFiscale <> Utility.CODICE_FISCALE_NULLO) AndAlso
                    (Not String.IsNullOrEmpty(RichiedenteCognome)) AndAlso (Not String.IsNullOrEmpty(RichiedenteNome)) Then
                    '
                    ' Se il richiedente non ha il codice fiscale lo sostituisco con "codicefiscale nullo"
                    '
                    If String.IsNullOrEmpty(Trim(RichiedenteCodiceFiscale)) Then RichiedenteCodiceFiscale = Utility.CODICE_FISCALE_NULLO
                    '
                    ' Verifico se il patient summary è valido
                    '
                    Dim dt As PazientiDataset.FevsPazientiPatientSummaryStatoDataTable = PatientSummaryUtil.GetStato(New Guid(IdPaziente))
                    If Not dt Is Nothing AndAlso dt.Rows.Count > 0 Then
                        Dim oRow As PazientiDataset.FevsPazientiPatientSummaryStatoRow = dt(0)
                        If Not oRow.IsIsValidNull Then
                            bIsValid = oRow.IsValid
                        End If
                        If Not oRow.IsPdfLengthNull Then
                            iPdfLength = oRow.PdfLength
                        End If
                    End If
                    If Not bIsValid Then
                        '
                        ' Se non valido...eseguo invocazione del webservice
                        '
                        Return GetPatientSummary(RichiedenteCodiceFiscale, RichiedenteCognome, RichiedenteNome, PazienteCodiceFiscale, IdPaziente)
                    ElseIf iPdfLength > 0 Then
                        '
                        ' E' valido: restituisco True e verrà ABILITATO Il pulsante per vedere il pDF
                        '
                        Return True
                    Else
                        '
                        ' Manca il PDF; restituisco False e verrà DISABILITATO il pulsante per vedere il pDF
                        '
                        Return False
                    End If
                End If
            End If

        Catch ex As Exception
            Logging.WriteError(ex, String.Format("Errore durante ShowPatientSummary IdPaziente Id={0}, CodiceFiscale={1}.", IdPaziente, PazienteCodiceFiscale))
        End Try

        Return False
    End Function


    ''' <summary>
    ''' Funzione che invoca il ws del patient summary e salva i dati nel database
    ''' </summary>
    ''' <param name="RichiedenteCodiceFiscale"></param>
    ''' <param name="RichiedenteCognome"></param>
    ''' <param name="RichiedenteNome"></param>
    ''' <param name="PazienteCodiceFiscale"></param>
    ''' <param name="IdPaziente"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Private Shared Function GetPatientSummary(ByVal RichiedenteCodiceFiscale As String, ByVal RichiedenteCognome As String, ByVal RichiedenteNome As String, ByVal PazienteCodiceFiscale As String, ByVal IdPaziente As String) As Boolean
        Dim bRet As Boolean = False
        Try
            Dim oRisposta As WcfPatientSummary.Risposta = PatientSummaryUtil.GetPatientSummary(RichiedenteCodiceFiscale, RichiedenteCognome, RichiedenteNome, PazienteCodiceFiscale)

            If Not oRisposta Is Nothing Then
                If Not oRisposta.InErrore Then
                    Call PatientSummaryUtil.Aggiorna(New Guid(IdPaziente), oRisposta.Dati.PDF, Nothing)
                    bRet = CBool(oRisposta.Dati.PDF.Length > 0)
                Else
                    Dim sErrore As String = PatientSummaryUtil.GetErrore(oRisposta)
                    Call PatientSummaryUtil.Aggiorna(New Guid(IdPaziente), Nothing, sErrore)
                    bRet = False
                End If
            Else
                Dim sErrore As String = "La risposta del web service è nothing!"
                Call PatientSummaryUtil.Aggiorna(New Guid(IdPaziente), Nothing, sErrore)
                bRet = False
            End If

        Catch ex As Exception
            Logging.WriteError(ex, "Errore durante InvokePatientSummary.")
        End Try
        Return bRet
    End Function

    ''' <summary>
    ''' Visualizzazione del PDF del Patient Summary
    ''' </summary>
    ''' <param name="sender"></param>
    ''' <param name="e"></param>
    ''' <remarks></remarks>
    Protected Sub btnApriPdfPatientSummary_Click(sender As Object, e As EventArgs) Handles btnApriPdfPatientSummary.Click
        Try
            btnApriPdfPatientSummary.Enabled = True
            '
            ' APERTURA IN NUOVA TAB DEL BROWSER (cosi però nella tab si visualizza localhost...)
            ' Aggiungere al pulsante onclientclick="document.forms[0].target ='_blank';"
            '
            'Dim sUrl As String = Me.ResolveUrl("~/Pazienti/PatientSummary.aspx") & String.Format("?{0}={1}", PAR_ID_PAZIENTE, mIdPaziente)
            'Me.Response.Redirect(sUrl, False)
            '
            ' Apertura in POP UP
            '
            Call ClientScript.RegisterStartupScript(Page.GetType(), "btnApriPdfPatientSummary_Click", ScriptOpenPatientSummaryWindow(IdPaziente))
        Catch ex As Exception
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante apertura del Patient Summary!"
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub


    ''' <summary>
    ''' Funzione per comporre lo scrip JAVASCRIPT per aprire il PDF in una nuova finestra
    ''' </summary>
    ''' <param name="oIdPaziente"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Private Function ScriptOpenPatientSummaryWindow(ByVal oIdPaziente As Guid) As String
        '
        ' Apro finestre con nome costante - occhio alla "\" sto passando la stringa a codice Java
        '
        Dim sUrl As String = Me.ResolveUrl("~/Pazienti/PatientSummary.aspx") & String.Format("?{0}={1}", PAR_ID_PAZIENTE, oIdPaziente)
        Dim sWindowName As String = "PatientSummary" 'NON DEVE CONTENERE SPAZI
        Dim sOpenWindowCode As String = Utility.JSOpenWindowCode(sUrl, sWindowName, True, False, False, False, False, False, True, True, 500, 500)
        Return Utility.JSBuildScript(sOpenWindowCode)
    End Function
#End Region

#Region "EventiGridView"

#Region "Eventi WebGridReferti"
    Private Sub WebGridReferti_PreRender(sender As Object, e As EventArgs) Handles WebGridReferti.PreRender
        Try
            '
            'Render per Bootstrap
            'Crea la Table con Theader e Tbody se l'header non è nothing.
            '
            If Not WebGridReferti.HeaderRow Is Nothing Then
                WebGridReferti.UseAccessibleHeader = True
                WebGridReferti.HeaderRow.TableSection = TableRowSection.TableHeader
            End If

            'Nascondo la colonna per la selezione dei referti da stampare se la setting è false
            WebGridReferti.Columns(0).Visible = My.Settings.Print_Enabled
        Catch ex As Exception
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Si è verificato un errore, contattare l'amministratore."
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

    Private Sub WebGridReferti_RowDataBound(sender As Object, e As GridViewRowEventArgs) Handles WebGridReferti.RowDataBound

        'Se è una riga e il referto non è variato allora la riga diventa bold
        If e.Row.RowType = DataControlRowType.DataRow Then

            Dim refertoRow As RefertoListaType = e.Row.DataItem

            If Not refertoRow.Visionato Then
                e.Row.CssClass = "referto-nuovo"
            End If
        End If
    End Sub

#End Region

#Region "WebGridPrescrizioni"
    Private Sub WebGridPrescrizioni_PreRender(sender As Object, e As EventArgs) Handles WebGridPrescrizioni.PreRender
        '
        'Render per Bootstrap
        'Crea la Table con Theader e Tbody se l'header non è nothing.
        '
        If Not WebGridPrescrizioni.HeaderRow Is Nothing Then
            WebGridPrescrizioni.UseAccessibleHeader = True
            WebGridPrescrizioni.HeaderRow.TableSection = TableRowSection.TableHeader
        End If
    End Sub

    ' MOMENTANEAMENTE NON UTILIZZATO PERCHE' GLI HEADER E IL SORTING DELLE TABELLE SONO DISABILITATI
    'Private Sub WebGridPrescrizioni_Sorting(sender As Object, e As GridViewSortEventArgs) Handles WebGridPrescrizioni.Sorting
    '    e.Cancel = True
    '    Me.GridViewSortExpression = e.SortExpression
    '    If Me.GridViewSortDirection Is Nothing OrElse Me.GridViewSortDirection.Value = SortDirection.Descending Then
    '        Me.GridViewSortDirection = SortDirection.Ascending
    '    Else
    '        Me.GridViewSortDirection = SortDirection.Descending
    '    End If
    '    DataSource_InvalidaCache()
    '    WebGridPrescrizioni.DataBind()
    'End Sub

    'MOMENTANEAMENTE NON UTILIZZATO PERCHE' GLI HEADER E IL SORTING DELLE TABELLE SONO DISABILITATI
    'Private Sub WebGridPrescrizioni_RowDataBound(sender As Object, e As GridViewRowEventArgs) Handles WebGridPrescrizioni.RowDataBound
    '    HelperGridView.AddHeaderSortingIcon(sender, e, GridViewSortExpression, GridViewSortDirection)
    'End Sub
#End Region

#Region "WebGridRefertiEpisodi"
    Private Sub WebGridRefertiEpisodi_RowDataBound(sender As Object, e As GridViewRowEventArgs) Handles WebGridRefertiEpisodi.RowDataBound
        ' MOMENTANEAMENTE NON UTILIZZATO PERCHE' GLI HEADER E IL SORTING DELLE TABELLE SONO DISABILITATI
        'HelperGridView.AddHeaderSortingIcon(sender, e, GridViewSortExpression, GridViewSortDirection)

        If e.Row.RowType = DataControlRowType.Header Then
            '
            ' Nascondo l'ultima colonna della griglia esterna
            '
            Dim rigaCorrente As GridViewRow = e.Row
            Dim cellCurrent As TableCell = rigaCorrente.Cells(rigaCorrente.Cells.Count - 1)
            cellCurrent.CssClass = "hidden"
        End If


        If e.Row.RowType = DataControlRowType.DataRow Then

            '
            ' Recupero la riga corrente
            '
            Dim rowCorrente As GridViewRow = e.Row
            Dim rowEpisodio As WcfDwhClinico.EpisodioListaType = CType(e.Row.DataItem, WcfDwhClinico.EpisodioListaType)
            rowCorrente.CssClass = "active"
            If (Not String.IsNullOrEmpty(rowEpisodio.StatoDescrizione)) AndAlso HelperRicoveri.IsEpisodioAperto(rowEpisodio.StatoDescrizione) Then
                rowCorrente.CssClass = "danger"
            End If

            '
            ' Recupero l'ObjectDataSource della riga corrente
            '
            Dim odsRefertiPerNosologico As ObjectDataSource = CType(rowCorrente.FindControl("DataSourceRefertiPerNosologico"), ObjectDataSource)

            '
            ' InvalidaCacheRefertiPerNosologico è true se abbiamo cliccato il bottone "cerca" o abbiamo cambiato tab
            '
            If InvalidaCacheRefertiPerNosologico Then

                Dim dsRefertiPerNosologico As New CustomDataSource.RefertiCercaPerNosologico

                '
                ' La key della cache in questo caso è composta dal NumeroNosologico e da AziendaErogante 
                '
                dsRefertiPerNosologico.ClearCache(rowEpisodio.NumeroNosologico, rowEpisodio.AziendaErogante)
            End If

            '
            ' Il Token e il ByPassaConsenso vengono valorizzati nell'evento selecting dell'ObjectDataSource DataSourceRefertiPerNosologico_Selecting
            ' (per poterlo vedere nel codice è stato definito all'interno del Markup)
            '
            odsRefertiPerNosologico.SelectParameters.Item("Nosologico").DefaultValue = rowEpisodio.NumeroNosologico
            odsRefertiPerNosologico.SelectParameters.Item("Azienda").DefaultValue = rowEpisodio.AziendaErogante
            'Quando true fa eseguire la query dell'object data source "DataSourceRefertiPerNosologico" usato per trovare i referti di un nosologico
            mbDataSourceRefertiPerNosologicoCancelSelect = False
            '
            ' Recupero la tabella dei referti dalla riga corrente
            '
            Dim gvSubQuery As GridView = TryCast(rowCorrente.FindControl("WebGridrefertiPerNosologico"), GridView)
            If gvSubQuery IsNot Nothing Then
                '
                ' ATTENZIONE:
                ' Quando eseguo il Bind dei dati vengono richiamati i metodi "DataSourceRefertiPerNosologico_Selecting" e "DataSourceRefertiPerNosologico_Selected"
                ' Nel metodo "DataSourceRefertiPerNosologico_Selecting" vengono passati all'ObjectDataSource tutti i parametri da dare alla GetData().
                ' Nel metodo "DataSourceRefertiPerNosologico_Selected" viene presa la lista dei referti restituita e messa dentro la variabile di modulo "listaReferti"
                ' listaReferti contiene tutti i referti associati agli episodi e viene usata per creare la lista dei TipiReferti usata dalla checkboxList dei filtri laterali
                '
                gvSubQuery.DataBind()
            End If

            For Each row As GridViewRow In gvSubQuery.Rows
                '
                ' Cerco la checkbox chkSelect nella gruiglia WebGridrefertiPerNosologico
                ' Se trovo la checkbox gli aggiungo una classe CSS formata da AziendaErogante e NumeroNosologico
                ' Questa classe CSS viene usata per selezionare/deselezionare tutti i referti di un episodio
                '
                Dim checkbox As CheckBox = CType(row.FindControl("chkSelect"), CheckBox)
                If Not checkbox Is Nothing Then
                    checkbox.CssClass = String.Format("{0}-{1}", rowEpisodio.AziendaErogante, rowEpisodio.NumeroNosologico)
                End If
            Next

            If gvSubQuery.Rows.Count > 0 Then

                '
                ' Creo il bottone per collassare la riga
                '
                Dim sbCellDiv As New StringBuilder
                sbCellDiv.AppendFormat("<button data-target='.{0}'", rowEpisodio.NumeroNosologico)
                sbCellDiv.AppendFormat("        class='btn btn-xs btn-default'", rowEpisodio.NumeroNosologico)
                sbCellDiv.AppendFormat("        data-toggle='collapse'")
                sbCellDiv.AppendFormat("        type='button'>")
                sbCellDiv.AppendFormat(" <div class='{0} collapse {1}' id='id-{2}'>", rowEpisodio.NumeroNosologico, If(rowEpisodio.DataConclusione Is Nothing, "in", ""), rowEpisodio.NumeroNosologico)
                sbCellDiv.AppendFormat("            <span class='glyphicon glyphicon-minus'></span>")
                sbCellDiv.AppendFormat("        </div>", rowEpisodio.NumeroNosologico)
                sbCellDiv.AppendFormat("        <div class='{0} collapse {1}'>", rowEpisodio.NumeroNosologico, If(rowEpisodio.DataConclusione Is Nothing, "", "in"))
                sbCellDiv.AppendFormat("            <span class='glyphicon glyphicon-plus'></span>")
                sbCellDiv.AppendFormat("        </div>", rowEpisodio.NumeroNosologico)
                sbCellDiv.AppendFormat("</button>")

                rowCorrente.Cells(0).Text = sbCellDiv.ToString()

                '
                ' Cerco la tabella della griglia
                '
                Dim tblGrid As System.Web.UI.WebControls.Table = CType(Me.WebGridRefertiEpisodi.Controls(0), System.Web.UI.WebControls.Table)

                '
                ' Recupero la posizione della riga corrente nella tabella
                '
                Dim nRowIndex As Integer = tblGrid.Rows.GetRowIndex(rowCorrente)

                '
                ' Crea una nuova riga e la posiziono dopo la riga corrente
                '
                Dim gvrSubFooter As New GridViewRow(nRowIndex + 1, 0, DataControlRowType.DataRow, DataControlRowState.Normal)

                '
                ' Aggiungo classe Css alla riga per il collassamento della row tramite bootstrap
                '
                gvrSubFooter.CssClass = String.Format("collapse {0} {1}", rowEpisodio.NumeroNosologico, If(rowEpisodio.DataConclusione Is Nothing, "in", ""))

                ' Creo una nuova cella per la riga aggiuntiva
                ' Con il contenuto dell'ultima cella
                '
                Dim cellExpanded As TableCell
                cellExpanded = rowCorrente.Cells(rowCorrente.Cells.Count - 1)
                cellExpanded.ColumnSpan = Me.WebGridRefertiEpisodi.Columns.Count - 1


                '
                ' Aggiunge due celle alla nuova riga
                '
                gvrSubFooter.Cells.Add(New TableCell())
                gvrSubFooter.Cells.Add(cellExpanded)

                '
                ' Aggiunge la nuova riga alla tabella della griglia
                '
                tblGrid.Controls.AddAt(nRowIndex + 1, gvrSubFooter)
                '
                ' Sostituosce l'ultima colonna con una cella vuota e la nasconde
                '
                Dim cellReplace As New TableCell
                cellReplace.CssClass = "hidden"
                rowCorrente.Cells.Add(cellReplace)
            Else
                '
                ' Nasconde l'ultima colonna della riga
                '
                Dim cellCurrent As TableCell = rowCorrente.Cells(rowCorrente.Cells.Count - 1)
                cellCurrent.CssClass = "hidden"
            End If
        End If
    End Sub

    Private Sub WebGridRefertiEpisodi_DataBound(sender As Object, e As EventArgs) Handles WebGridRefertiEpisodi.DataBound
        InvalidaCacheRefertiPerNosologico = False
    End Sub

    Private Sub WebGridRefertiEpisodi_PreRender(sender As Object, e As EventArgs) Handles WebGridRefertiEpisodi.PreRender
        '
        'Render per Bootstrap
        'Crea la Table con Theader e Tbody se l'header non è nothing.
        '
        If Not WebGridRefertiEpisodi.HeaderRow Is Nothing Then
            WebGridRefertiEpisodi.UseAccessibleHeader = True
            WebGridRefertiEpisodi.HeaderRow.TableSection = TableRowSection.TableHeader
        End If
    End Sub

    Protected Sub WebGridrefertiPerNosologico_PreRender(sender As Object, e As EventArgs)
        Try
            Dim gv As GridView = CType(sender, GridView)
            gv.Columns(0).Visible = My.Settings.Print_Enabled
        Catch ex As Exception
            Logging.WriteError(ex, Me.GetType.Name)
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Si è verificato un errore, contattare l'amministratore."
        End Try
    End Sub

    Protected Sub WebGridrefertiPerNosologico_RowDataBound(sender As Object, e As GridViewRowEventArgs)
        'Modifica 2020-05-19 KYRY: Referto variato
        '
        'Se il referto non è variato allora la riga diventa bold
        '
        If e.Row.RowType = DataControlRowType.DataRow Then
            Dim refertoRow As RefertoListaType = e.Row.DataItem

            If Not refertoRow.Visionato Then
                e.Row.CssClass = "referto-nuovo"
            End If
        End If
    End Sub

    Private Sub DataSourceLstTipiRefertiPerEpisodio_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles DataSourceLstTipiRefertiPerEpisodio.Selecting
        Try
            If mbValidationCancelSelect Then
                e.Cancel = True
                Exit Sub
            End If

            '
            ' listaReferti contiene tutti i referti contenuti nella tab "Episodi e Referti"
            ' Quest variabile viene usata per creare la lista di TipiReferto usata per creare la CheckboxList dei filtri laterali
            ' listaReferti viene riempita nell'evento "DataSourceRefertiPerNosologico_Selected"
            '
            e.InputParameters("listaReferti") = listaReferti
        Catch ex As Threading.ThreadAbortException
            '
            ' Non faccio niente
            '
        Catch ex As Exception
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati!"
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

    Protected Sub DataSourceRefertiPerNosologico_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs)
        Try
            If mbValidationCancelSelect Then
                e.Cancel = True
                Exit Sub
            End If
            '
            ' Evita di eseguire una query con Azienda e Nosologico vuoti
            '
            If mbDataSourceRefertiPerNosologicoCancelSelect Then
                e.Cancel = True
                Exit Sub
            End If

            Dim lstFiltriTipiReferto As New List(Of String)

            '
            ' I parametri Nosologico e AziendaErogante vengono valorizzati nell'evento RowDataBound della griglia WebGridEpisodi
            '
            e.InputParameters("Token") = Me.Token
            e.InputParameters("ByPassaConsenso") = Utility.GetSessionForzaturaConsenso(Me.IdPaziente)

            '
            ' Svuoto la lista contenente i filtri per tipi referto
            '
            lstFiltriTipiReferto.Clear()

            '
            ' Riempio la lista dei filtri in base alle checkbox selezionate nel filtro di spalla dx
            '
            For Each item As ListItem In TipoRefertoPerEpisodioCheckboxList.Items
                If item.Selected Then
                    lstFiltriTipiReferto.Add(item.Value)
                End If
            Next

            e.InputParameters("lstFiltriTipiReferto") = lstFiltriTipiReferto
        Catch ex As Threading.ThreadAbortException
            '
            ' Non faccio niente
            '
        Catch ex As ApplicationException
            divErrorMessage.Visible = True
            lblErrorMessage.Text = ex.Message
            Logging.WriteError(ex, Me.GetType.Name)
        Catch ex As Exception
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati!"
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

    Protected Sub DataSourceRefertiPerNosologico_Selected(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs)
        Try
            btnExecutePrint.Visible = True
            divErrorMessage.Visible = False

            'Ottengo il messaggio di errore.
            Dim messaggioErrore = HelperDataSourceException.GetObjectDataSourceExceptionMessage(e.Exception)

            'Testo se il messaggio di errore è vuoto. Se è valorizzato allora mostro il div d'errore.
            If Not String.IsNullOrEmpty(messaggioErrore) Then
                divErrorMessage.Visible = True
                lblErrorMessage.Text = messaggioErrore
                e.ExceptionHandled = True
            Else
                Dim Referti As List(Of WcfDwhClinico.RefertoListaType) = CType(e.ReturnValue, List(Of WcfDwhClinico.RefertoListaType))
                If Not Referti Is Nothing AndAlso Referti.Count > 0 Then

                    '
                    ' listaReferti è una variabile di modulo che contiene tutti i referti contenuti negli episodi
                    ' Viene usata per popolare la lista dei tipi referto usati dalla checkbox list per filtrare la gir WebGridRefertiEpisodi
                    '
                    listaReferti.AddRange(Referti)


                    ' TODO: KYRY --> Qui viene popolata la listaReferti con i referti e non fa uso della cache...


                End If
            End If
        Catch ex As Threading.ThreadAbortException
            '
            ' Non faccio niente
            '
        Catch ex As ApplicationException
            divErrorMessage.Visible = True
            lblErrorMessage.Text = ex.Message
            Logging.WriteError(ex, Me.GetType.Name)
        Catch ex As Exception
            '
            ' Errore
            '
            Logging.WriteError(ex, Me.GetType.Name)
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati!"
        End Try
    End Sub
#End Region

#Region "WebGridEventiSingoli"
    Private Sub WebGridRefSingoli_PreRender(sender As Object, e As EventArgs) Handles WebGridEventiSingoli.PreRender
        '
        'Render per Bootstrap
        'Crea la Table con Theader e Tbody se l'header non è nothing.
        '
        If Not WebGridEventiSingoli.HeaderRow Is Nothing Then
            WebGridEventiSingoli.UseAccessibleHeader = True
            WebGridEventiSingoli.HeaderRow.TableSection = TableRowSection.TableHeader
        End If
    End Sub
#End Region

    ''' <summary>
    ''' restituisce la GridView attualmente visibile
    ''' </summary>
    ''' <returns></returns>
    ''' <remarks></remarks>
    ''' 
    Private Function GetVisibleDataGrid2() As GridView
        Dim oGrid As GridView = Nothing
        If MultiViewMain.GetActiveView Is ViewPrescrizioni Then
            oGrid = WebGridPrescrizioni
        ElseIf MultiViewMain.GetActiveView Is ViewRefertiEpisodi Then
            oGrid = CType(ViewRefertiEpisodi.FindControl("WebGridRefertiEpisodi"), GridView)
        ElseIf MultiViewMain.GetActiveView Is ViewRisultatoMatrice Then
            '
            ' Niente
            '
        ElseIf MultiViewMain.GetActiveView Is ViewReferti Then
            oGrid = WebGridReferti
        ElseIf MultiViewMain.GetActiveView Is ViewSchedePaziente Then
            oGrid = WebGridEventiSingoli
        End If
        Return oGrid
    End Function
#End Region

#Region "Funzioni Markup"

#Region "Per prescrizioni"
    Protected Function GetPrescrizioneDataPrescrizione(objRow As Object) As String
        Dim oRow As WcfDwhClinico.PrescrizioneListaType = CType(objRow, WcfDwhClinico.PrescrizioneListaType)
        Return UserInterface.GetPrescrizioneDataPrescrizione(oRow)
    End Function

    Protected Function GetPrescrizioneNumero(objRow As Object) As String
        Dim oRow As WcfDwhClinico.PrescrizioneListaType = CType(objRow, WcfDwhClinico.PrescrizioneListaType)
        Return UserInterface.GetPrescrizioneNumero(oRow)
    End Function

    Protected Function GetPrescrizioneMedicoPrescrittoreDesc(objRow As Object) As String
        Dim oRow As WcfDwhClinico.PrescrizioneListaType = CType(objRow, WcfDwhClinico.PrescrizioneListaType)
        Return UserInterface.GetPrescrizioneMedicoPrescrittoreDesc(oRow)
    End Function

    Protected Function GetPrescrizioniFarmaciPrestazioni(objRow As Object) As String
        Dim oRow As WcfDwhClinico.PrescrizioneListaType = CType(objRow, WcfDwhClinico.PrescrizioneListaType)
        Return UserInterface.GetPrescrizioniFarmaciPrestazioni(oRow)
    End Function

    Protected Function GetPrescrizioneEsenzioneCodici(objRow As Object) As String
        Dim oRow As WcfDwhClinico.PrescrizioneListaType = CType(objRow, WcfDwhClinico.PrescrizioneListaType)
        Return UserInterface.GetPrescrizioneEsenzioneCodici(oRow)
    End Function

    Protected Function GetPrescrizioniPrioritaCodice(objRow As Object) As String
        Dim oRow As WcfDwhClinico.PrescrizioneListaType = CType(objRow, WcfDwhClinico.PrescrizioneListaType)
        Return UserInterface.GetPrescrizioniPrioritaCodice(oRow)
    End Function

    Protected Function GetPrescrizioniQuesitoDiagnosticoPropostaTerapeutica(objRow As Object) As String
        Dim oRow As WcfDwhClinico.PrescrizioneListaType = CType(objRow, WcfDwhClinico.PrescrizioneListaType)
        Return UserInterface.GetPrescrizioniQuesitoDiagnosticoPropostaTerapeutica(oRow)
    End Function

#End Region

#Region "Per NoteAnamnestiche"
    ''' <summary>
    ''' Restituisce l'icona relativa allo stato della nota anamnestica
    ''' </summary>
    ''' <param name="obj"></param>
    ''' <returns></returns>
    Protected Function GetIconaStatoNotaAnamnestica(ByVal obj As Object)
        Dim oRow As WcfDwhClinico.NotaAnamnesticaListaType = CType(obj, WcfDwhClinico.NotaAnamnesticaListaType)

        Return UserInterface.GetIconaStatoNotaAnamnestica(oRow)
    End Function

    Protected Function GetIconaStatoDettaglioNotaAnamnestica(ByVal obj As Object)
        Dim oRow As WcfDwhClinico.NotaAnamnesticaType = CType(obj, WcfDwhClinico.NotaAnamnesticaType)

        Return UserInterface.GetIconaStatoNotaAnamnestica(oRow)
    End Function
#End Region

    ''' <summary>
    ''' Valorizza l'icona di stato dell'invio del referto a SOLE.
    ''' </summary>
    ''' <param name="obj"></param>
    ''' <returns></returns>
    Protected Function GetIconaStatoInvioSole(ByVal obj As Object) As String
        Dim sReturn As String = String.Empty

        Dim oRow As WcfDwhClinico.RefertoListaType = DirectCast(obj, WcfDwhClinico.RefertoListaType)
        '
        ' Restituisco l'icona di stato invio a SOLE.
        '
        sReturn = UserInterface.GetIconaStatoInvioSOLE(oRow)

        Return sReturn
    End Function

    Protected Function GetUrlIconaTipoReferto(obj As Object) As String
        Dim oRow As WcfDwhClinico.RefertoListaType = DirectCast(obj, WcfDwhClinico.RefertoListaType)
        Dim sReturn As String = Nothing
        If Not oRow Is Nothing AndAlso Not String.IsNullOrEmpty(oRow.IdTipoReferto) Then
            'TODO: le immagini sono state rimpicciolite nel markup 20x20
            sReturn = String.Format("{0}?IdTipoReferto={1}", Me.ResolveUrl("~/GetIconaTipoReferto.ashx"), oRow.IdTipoReferto)
        Else
            sReturn = Me.ResolveUrl("~/images/blank.gif")
        End If
        Return sReturn
    End Function

    Protected Function GetLabelAnteprima(objrow As Object) As String
        Dim oRow As WcfDwhClinico.RefertoListaType = CType(objrow, WcfDwhClinico.RefertoListaType)
        Dim sHtml As String = String.Empty
        If Not String.IsNullOrEmpty(oRow.Anteprima) Then
            If oRow.Anteprima.Count > 40 Then
                sHtml = String.Format("<label data-toggle='tooltip' data-placement='top' title='{0}'>{1}...</label>", oRow.Anteprima.NullSafeToString.ToString, oRow.Anteprima.NullSafeToString.Substring(0, 40))
            Else
                sHtml = oRow.Anteprima
            End If
            sHtml += "<br/>"
        End If
        Return sHtml

    End Function

    Protected Function GetLabelAvvertenze(objrow As Object) As String
        Dim oRow As WcfDwhClinico.RefertoListaType = CType(objrow, WcfDwhClinico.RefertoListaType)
        Dim sHtml As String = String.Empty
        If Not String.IsNullOrEmpty(oRow.Avvertenze) Then

            Dim avvertenze As String() = oRow.Avvertenze.Split("|")

            For Each avvertenza In avvertenze
                sHtml += $"<span class='text-danger'>{avvertenza}</span><br/>"
            Next
        End If

        Return sHtml

    End Function

    Protected Function GetStringaDescrittiva(objrow As Object) As String
        Dim oRow As WcfDwhClinico.RefertoListaType = CType(objrow, WcfDwhClinico.RefertoListaType)
        Return UserInterface.GetStringaDescrittiva(oRow, Me.Page)
    End Function

    Protected Function GetDataEvento(objrow As Object) As String
        Dim oRow As WcfDwhClinico.RefertoListaType = CType(objrow, WcfDwhClinico.RefertoListaType)
        Dim sDataEvento As String = String.Empty
        If oRow.DataEvento <> Nothing Then
            sDataEvento = String.Format("{0:g}", oRow.DataEvento)
        End If

        Dim sDataReferto As String = String.Empty
        If oRow.DataReferto <> Nothing Then
            sDataReferto = String.Format("{0:d}", oRow.DataReferto)
        End If

        If oRow.DataReferto <> oRow.DataEvento Then
            Return String.Format("{0} </br> Refertato il {1}", sDataEvento, sDataReferto)
        Else
            Return String.Format("{0}", sDataEvento)
        End If
    End Function

    Protected Function GetNumeroReferto(objrow As Object) As String
        Dim oRow As WcfDwhClinico.RefertoListaType = CType(objrow, WcfDwhClinico.RefertoListaType)
        Dim sReturn As String = String.Empty
        If Not String.IsNullOrEmpty(oRow.NumeroReferto) Then
            sReturn = String.Format("N.Ref.: {0}", oRow.NumeroReferto.NullSafeToString)
        End If
        Return sReturn
    End Function

    Protected Function GetNumeroVersione(objrow As Object) As String
        Dim oRow As WcfDwhClinico.RefertoListaType = CType(objrow, WcfDwhClinico.RefertoListaType)
        Dim sReturn As String = String.Empty
        If oRow.NumeroVersione.HasValue AndAlso oRow.NumeroVersione.Value > 1 Then
            sReturn = String.Format("Versione: {0}", oRow.NumeroVersione.Value)
        End If
        Return sReturn
    End Function

    Protected Function GetPriorita(objrow As Object) As String
        Dim oRow As WcfDwhClinico.RefertoListaType = CType(objrow, WcfDwhClinico.RefertoListaType)
        Dim strHtml As String = String.Empty
        If oRow.PrioritaDescrizione IsNot Nothing Then
            strHtml = oRow.PrioritaDescrizione
        End If
        Return strHtml
    End Function

    ''' <summary>
    ''' Restuisce l'icona associata al tipo di epidosio nella tabella degli episodi
    ''' </summary>
    ''' <param name="objRow"></param>
    ''' <returns></returns>
    ''' 
    Protected Function GetSimboloTipoEpisodioRicovero(objRow As Object) As String
        Dim oRow As WcfDwhClinico.EpisodioListaType = CType(objRow, WcfDwhClinico.EpisodioListaType)
        Dim strHtml As String = String.Empty
        If Not oRow.TipoEpisodioCodice Is Nothing Then
            Dim sTipoEpisodioRicovero As String = oRow.TipoEpisodioCodice.ToUpper
            If Not String.IsNullOrEmpty(sTipoEpisodioRicovero) Then
                strHtml = HelperRicoveri.GetHtmlImgTipoEpisodioRicovero(sTipoEpisodioRicovero)
            End If
        End If
        Return strHtml
    End Function

    Protected Function GetTipoEpisodioDescrizione(objRow As Object) As String
        Dim oRow As WcfDwhClinico.EpisodioListaType = CType(objRow, WcfDwhClinico.EpisodioListaType)
        '
        ' Restiruisce la descrizione del tipo di episodio
        '
        Return String.Format("{0}", oRow.TipoEpisodioDescrizione.NullSafeToString.ToUpper)
    End Function

    Protected Function GetStatoEpisodio(objRow As Object) As String
        Dim oRow As WcfDwhClinico.EpisodioListaType = CType(objRow, WcfDwhClinico.EpisodioListaType)
        Return UserInterface.GetStatoEpisodio(oRow)
    End Function

    Protected Function GetInfoAccettazione(objRow As Object) As String
        Dim oRow As WcfDwhClinico.EpisodioListaType = CType(objRow, WcfDwhClinico.EpisodioListaType)
        Dim sHtml As String = String.Empty
        If oRow.DataApertura.HasValue Then
            sHtml = String.Format("Accettato in {0} </br> il {1:g}", oRow.StrutturaAperturaDescrizione.NullSafeToString, oRow.DataApertura)
        Else
            sHtml = String.Format("Accettato in {0}", oRow.StrutturaAperturaDescrizione.NullSafeToString)
        End If
        Return sHtml
    End Function

    Protected Function GetNosologico(objRow As Object) As String
        Dim oRow As WcfDwhClinico.EpisodioListaType = CType(objRow, WcfDwhClinico.EpisodioListaType)
        Return String.Format("{0}", oRow.NumeroNosologico)
    End Function



    ''' <summary>
    ''' Usata nel markup per visualizzare l'icona del tipo di ricovero in base al consenso minimo accordato 
    ''' </summary>
    ''' <param name="oTipoEpisodioRicovero"></param>
    ''' <param name="oFlagConsensoMinimo"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    ''' 
    Protected Function GetSimboloTipoEpisodioRicovero(ByVal oTipoEpisodioRicovero As Object, ByVal oFlagConsensoMinimo As Object) As String
        Dim strHtml As String = UserInterface.GetHtmlImgBlank(Me.Page)
        If Not oTipoEpisodioRicovero Is DBNull.Value Then
            Dim sTipoEpisodioRicovero As String = CType(oTipoEpisodioRicovero, String).ToUpper
            If Not String.IsNullOrEmpty(sTipoEpisodioRicovero) Then
                Dim eConsenso As ConsensoMinimoAccordato = CType(oFlagConsensoMinimo, ConsensoMinimoAccordato)
                If eConsenso > ConsensoMinimoAccordato.Nessuno Then
                    strHtml = HelperRicoveri.GetHtmlImgTipoEpisodioRicovero(sTipoEpisodioRicovero)
                End If
            End If
        End If
        Return strHtml
    End Function

    Protected Function CheckDeleteRefertiPermission() As Boolean
        Return mbDeleteRefertiPermission
    End Function

    Protected Function GetStatoImageUrl2(objRow As Object) As String
        Dim oRow As WcfDwhClinico.RefertoListaType = CType(objRow, WcfDwhClinico.RefertoListaType)
        Return Me.ResolveUrl(String.Format("~/Images/Referti/StatoRichiesta_{0}.gif", oRow.StatoRichiestaCodice))
    End Function

    Protected Function GetImgPresenzaWarning(objRow As Object) As String
        Dim oRow As WcfDwhClinico.RefertoListaType = CType(objRow, WcfDwhClinico.RefertoListaType)
        Return UserInterface.GetImgPresenzaWarning(oRow, Me.Page)
    End Function

    Protected Function GetImgPresenzaReferti(objRow As Object) As String
        Dim oRow As WcfDwhClinico.RefertoListaType = CType(objRow, WcfDwhClinico.RefertoListaType)
        Return UserInterface.GetImgPresenzaReferti(oRow, Me.Page)
    End Function

    Protected Function GetUrlLinkReferto(ByVal objRow As Object) As String
        Dim oRow As WcfDwhClinico.RefertoListaType = CType(objRow, WcfDwhClinico.RefertoListaType)
        Return Me.ResolveUrl(String.Format("~/Referti/RefertiDettaglio.aspx?IdReferto={0}", oRow.Id))
    End Function

    Protected Function GetUrlCancellaReferto(objRow As Object) As String
        Dim oRow As WcfDwhClinico.RefertoListaType = CType(objRow, WcfDwhClinico.RefertoListaType)
        Dim sUrl As String = Me.ResolveUrl(String.Format("~/Referti/RefertiCancella.aspx?Idreferto={0}", oRow.Id))
        Return sUrl
    End Function

    Protected Function GetEventoEpisodioDescr(objRow As Object) As String
        Dim oRow As WcfDwhClinico.EventoType = CType(objRow, WcfDwhClinico.EventoType)
        Dim sHtml As String = String.Format("{0} - ({1})", oRow.TipoEventoDescrizione.NullSafeToString, oRow.TipoEventoCodice.NullSafeToString)
        If String.IsNullOrEmpty(oRow.TipoEventoDescrizione) Then
            sHtml = String.Format("{0}", oRow.TipoEventoCodice.NullSafeToString)
        ElseIf String.IsNullOrEmpty(oRow.TipoEventoCodice) Then
            String.Format("{0}", oRow.TipoEventoDescrizione.NullSafeToString)
        End If
        Return sHtml
    End Function

    Protected Function GetDataEventoEpisodio(objRow As Object) As String
        Dim oRow As WcfDwhClinico.EventoType = CType(objRow, WcfDwhClinico.EventoType)
        Dim sHtml As String = String.Empty
        If oRow.DataEvento <> Nothing Then
            sHtml = String.Format("{0:g}", oRow.DataEvento)
        End If
        Return sHtml
    End Function

    Protected Function GetEventoRepartoRicovero(objRow As Object) As String
        Dim oRow As WcfDwhClinico.EventoType = CType(objRow, WcfDwhClinico.EventoType)
        Dim sHtml As String = String.Empty
        If Not String.IsNullOrEmpty(oRow.StrutturaDescrizione) AndAlso Not String.IsNullOrEmpty(oRow.StrutturaCodice) Then
            sHtml = String.Format("{0} - ({1})", oRow.StrutturaDescrizione.NullSafeToString, oRow.StrutturaCodice.NullSafeToString)
        End If
        Return sHtml
    End Function

    Protected Function GetEventoSettoreRicovero(objRow As Object) As String
        Dim oRow As WcfDwhClinico.EventoType = CType(objRow, WcfDwhClinico.EventoType)

        Dim sHtml As String = String.Empty
        If Not String.IsNullOrEmpty(oRow.SettoreDescrizione) Then
            sHtml = String.Format("{0}", oRow.SettoreDescrizione.NullSafeToString)
        End If
        Return sHtml
    End Function

    Protected Function GetEventoLettoRicovero(objRow As Object) As String
        Dim oRow As WcfDwhClinico.EventoType = CType(objRow, WcfDwhClinico.EventoType)
        Dim sHtml As String = String.Empty
        If Not String.IsNullOrEmpty(oRow.SettoreDescrizione) Then
            sHtml = String.Format("{0}", oRow.LettoCodice.NullSafeToString)
        End If
        Return sHtml
    End Function

#End Region

#Region "Modale Dettaglio Episodi"
    Private Sub UpdatePanelDettaglioEpisodio_Load(sender As Object, e As EventArgs) Handles UpdatePanelDettaglioEpisodio.Load
        If Not String.IsNullOrEmpty(hfIdEpisodio.Value.ToString) Then
            'ottengo l'id dell'episodio.
            IdEpisodio = New Guid(hfIdEpisodio.Value.ToString)

            '
            'Svuoto  il valore di hdIdEpisodio.
            'In questo modo se viene ricaricata la pagina la modale non viene riaperta.
            '
            hfIdEpisodio.Value = String.Empty
            mbValidationSelect = False

            '
            ' svuoto la cache della griglia prima di rieseguire il bind dei dati
            '
            Dim dsEventiEpisodio As New CustomDataSource.EpisodioOttieniPerId()
            dsEventiEpisodio.ClearCache(IdEpisodio.ToString)
            Dim dsEventiEpisodioCercaPerId As New CustomDataSource.EventiEpisodioCercaPerId()
            dsEventiEpisodioCercaPerId.ClearCache()

            '
            ' ottengo l'xml del dettaglio dell'episodio
            '
            Dim sXml As String = GetXmlTestataRicovero(Me.IdEpisodio)

            If Not String.IsNullOrEmpty(sXml) Then
                Call ShowTestataRicovero(sXml)

                'mbCancelSelectOperationOnTabChange = False
                WebGridEventiEpisodio.DataBind()
            End If

            ucInfoPaziente.DataBind()

            '
            ' Registro lo script per aprire la modale contenente le informazioni sull'Episodio
            '
            Dim functionJS As String = "$('#ModalDettaglioEpisodio').modal('show');"
            ScriptManager.RegisterStartupScript(Page, Page.GetType, "LanchServerSide2", functionJS, True)
        End If
    End Sub

    Private Sub ShowTestataRicovero(ByVal sXml As String)
        ' Viene utilizzata nel RowCommand della griglia WebGridRefertiEpisodi
        Try
            XmlInfoRicovero.DocumentContent = sXml
            XmlInfoRicovero.DataBind()
        Catch ex As Exception
            Logging.WriteError(ex, "ShowTestataRicovero: Si è verificato un errore durante la visualizzazione delle info di ricovero.")
            Throw
        End Try
    End Sub

    Private Function GetXmlTestataRicovero(ByVal IdRicovero As Guid) As String
        ' Viene utilizzata nel RowCommand della griglia WebGridRefertiEpisodi
        Try
            Dim strXml As String = String.Empty

            ucInfoPaziente.Visible = True
            WebGridEventiEpisodio.Visible = True
            divInfoRicovero.Visible = True

            '
            ' Ottengo il dettaglio dell'episodio
            '
            Dim EpisodioOttieniPerId As New CustomDataSource.EpisodioOttieniPerId
            Dim dettaglioRicovero As WcfDwhClinico.EpisodioType = EpisodioOttieniPerId.GetData(Me.Token, IdRicovero)

            If Not dettaglioRicovero Is Nothing Then
                ShowAttributiAnagrafici(dettaglioRicovero)

                '
                ' Creo un nuovo XmlSerializer per serializzare oggetti dello stesso tipo del dettaglio dell'episodio
                '
                Dim xmlSerializer As New System.Xml.Serialization.XmlSerializer(dettaglioRicovero.GetType)
                '
                ' Di default passo all'xml la trasformazione xslt TestataRicovero.xsl
                ' Se il dettaglio è una prenotazione allora passo all'xml la trasformazione xslt DettaglioPrenotazione1.xsl
                '
                XmlInfoRicovero.TransformSource = "~/Xslt/TestataRicovero1.xsl"
                If Not dettaglioRicovero Is Nothing Then
                    If dettaglioRicovero.Categoria.ToString.ToUpper = "PRENOTAZIONE" Then
                        XmlInfoRicovero.TransformSource = "~/Xslt/DettaglioPrenotazione1.xsl"
                    End If
                End If

                '
                ' trasformo il dettaglio dell'episodio in xml
                ' 
                Using memoryStream As New IO.MemoryStream
                    xmlSerializer.Serialize(memoryStream, dettaglioRicovero)
                    memoryStream.Position = 0
                    strXml = New IO.StreamReader(memoryStream).ReadToEnd
                End Using

                'traccio gli accessi al ricovero solo se dettaglioRicovero non è nothing.
                'se dettaglioRicovero è vuoto l'utente non visualizza niente quindi non è necessario tracciare gli accessi.
                TracciaAccessi.TracciaAccessiRicovero(Me.CodiceRuolo, Me.DescrizioneRuolo, "Apre Episodio", Me.IdPaziente, IdRicovero, SessionHandler.MotivoAccesso, SessionHandler.MotivoAccessoNote, 1, Me.ConsensoPaziente)
            Else
                Throw New ApplicationException("L'episodio selezionato non esiste!")
            End If
            Return strXml
        Catch ex As ApplicationException
            ucInfoPaziente.Visible = False
            WebGridEventiEpisodio.Visible = False
            divInfoRicovero.Visible = False
            alertErrorEventiModal.Visible = True
            eventiModalLblError.Text = ex.Message
        Catch ex As Exception
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante il caricamento dei dati riguardanti l'episodio."
            Logging.WriteError(ex, "GetXmlTestataRicovero: Si è verificato un errore durante la lettura delle info di ricovero.")
            Throw
        End Try
        Return ""
    End Function

    Private Sub ShowAttributiAnagrafici(dettaglioRicovero As WcfDwhClinico.EpisodioType)
        Try
            '
            ' Passo le informazioni sull'utente allo UserControl ucInfoPaziente contenuto nella modale del dettaglio dell'episodio
            '
            Dim Nome As String = String.Empty
            Dim Cognome As String = String.Empty
            Dim CodiceFiscale As String = String.Empty
            Dim CodiceSanitario As String = String.Empty
            Dim LuogoNascita As String = String.Empty
            Dim DataNascita As Date = Nothing
            If Not dettaglioRicovero Is Nothing AndAlso Not dettaglioRicovero.Paziente Is Nothing Then
                If Not dettaglioRicovero.Paziente.Nome Is Nothing Then
                    Nome = dettaglioRicovero.Paziente.Nome.ToString
                End If
                If Not dettaglioRicovero.Paziente.Cognome Is Nothing Then
                    Cognome = dettaglioRicovero.Paziente.Cognome.ToString
                End If
                If Not dettaglioRicovero.Paziente.CodiceFiscale Is Nothing Then
                    CodiceFiscale = dettaglioRicovero.Paziente.CodiceFiscale.ToString
                End If
                If Not dettaglioRicovero.Paziente.CodiceSanitario Is Nothing Then
                    CodiceSanitario = dettaglioRicovero.Paziente.CodiceSanitario.ToString
                End If
                If Not dettaglioRicovero.Paziente.ComuneNascita Is Nothing Then
                    LuogoNascita = dettaglioRicovero.Paziente.ComuneNascita.ToString
                End If
                If dettaglioRicovero.Paziente.DataNascita.HasValue Then
                    DataNascita = dettaglioRicovero.Paziente.DataNascita.Value
                End If
            End If
            ucInfoPaziente.Nome = Nome
            ucInfoPaziente.Cognome = Cognome
            ucInfoPaziente.DataNascita = DataNascita
            ucInfoPaziente.LuogoNascita = LuogoNascita
            ucInfoPaziente.CodiceFiscale = CodiceFiscale
        Catch ex As Exception
            '
            ' Non faccio nulla.
            '
        End Try
    End Sub
#End Region

#Region "Modale Dettaglio Nota"
    Dim odsNotaAnamnesticaCancelSelect As Boolean = True

    Private Sub udpNotaAnamnesticaDettaglio_Load(sender As Object, e As EventArgs) Handles udpNotaAnamnesticaDettaglio.Load
        Try
            If Not String.IsNullOrEmpty(hflNotaAnamnestica.Value.ToString) Then
                '
                'Prendo la nota anamnestica e svuoto l'hidden field.
                '
                Dim idNotaAnamnestica As Guid
                If Guid.TryParse(hflNotaAnamnestica.Value, idNotaAnamnestica) Then
                    hflNotaAnamnestica.Value = Nothing

                    '
                    'Ottengo il dettaglio della nota anamnestica e mostro le informazioni anagrafiche del paziente.
                    '
                    Dim ods As New CustomDataSource.NotaAnamnesticaOttieniPerId()
                    Dim dt As WcfDwhClinico.NotaAnamnesticaType = ods.GetData(Me.Token, idNotaAnamnestica)
                    If Not dt Is Nothing Then
                        If Not dt.Paziente Is Nothing Then
                            ucInfoPazienteNotaAnamnestica.Nome = dt.Paziente.Nome
                            ucInfoPazienteNotaAnamnestica.Cognome = dt.Paziente.Cognome
                            ucInfoPazienteNotaAnamnestica.DataNascita = dt.Paziente.DataNascita
                            ucInfoPazienteNotaAnamnestica.CodiceFiscale = dt.Paziente.CodiceFiscale
                            ucInfoPazienteNotaAnamnestica.LuogoNascita = dt.Paziente.ComuneNascita
                        End If
                    End If

                    '
                    'Passo all'ObjectDataSource l'id della nota anamnestica.
                    '
                    odsNotaAnamnestica.SelectParameters("IdNotaAnamnestica").DefaultValue = idNotaAnamnestica.ToString

                    '
                    'Setto a false "odsNotaAnamnesticaCancelSelect" in modo da permettere l'esecuzione della query.
                    '
                    odsNotaAnamnesticaCancelSelect = False

                    '
                    'Eseguo il bind dei dati.
                    '
                    fvNotaAnamestica.DataBind()

                    '
                    ' Registro lo script per aprire la modale contenente le informazioni sulla Nota Anamnestica.
                    '
                    Dim functionJS As String = "$('#ModaleDettaglioNotaAnamnestica').modal('show');"
                    ScriptManager.RegisterStartupScript(Page, Page.GetType, "LanchServerSide3", functionJS, True)
                End If
            End If
        Catch ex As Exception
            mbValidationCancelSelect = True

            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Si è verificato un errore durante l'apertura della Nota Anamnestica."
            '
            ' Errore
            '
            Dim sMsgErr As String = FormatException(ex) 'con formatException si visualizzano anche le inner exception
            Logging.WriteError(ex, sMsgErr)
        End Try
    End Sub

    Private Sub odsNotaAnamnestica_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsNotaAnamnestica.Selecting
        Try
            '
            'Utilizzo la setting ShowNoteAnamnesticheTab per denterminare se eseguire la query oppure no.
            '
            If odsNotaAnamnesticaCancelSelect OrElse Not My.Settings.ShowNoteAnamnesticheTab Then
                '
                'Cancello la select e esco.
                '
                e.Cancel = True
                Exit Sub
            End If

            e.InputParameters("Token") = Me.Token()
        Catch ex As Threading.ThreadAbortException
            '
            ' Non faccio niente
            '
        Catch ex As Exception
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati!"
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

    Private Sub odsNotaAnamnestica_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsNotaAnamnestica.Selected
        Try
            '
            'Controllo se ci sono errori.
            '
            '
            'Ottengo il messaggio di errore.
            Dim messaggioErrore = HelperDataSourceException.GetObjectDataSourceExceptionMessage(e.Exception)

            'Testo se il messaggio di errore è vuoto. Se è valorizzato allora mostro il div d'errore.
            If Not String.IsNullOrEmpty(messaggioErrore) Then
                divErrorMessage.Visible = True
                lblErrorMessage.Text = messaggioErrore
                e.ExceptionHandled = True
            Else
                'ottengo il dettaglio della nota.
                'mi serve per ottenere l'id della nota anamnestica.
                Dim oDettaglioNota As WcfDwhClinico.NotaAnamnesticaType = CType(e.ReturnValue, WcfDwhClinico.NotaAnamnesticaType)

                'Testo se oDettaglioNota è vuoto.
                If oDettaglioNota IsNot Nothing Then
                    'se oDettaglioNota è vuoto significa che non sto visualizzando nulla quindi NON traccio gli accessi.
                    TracciaAccessi.TracciaAccessiNotaAnamnestica(Me.CodiceRuolo, Me.DescrizioneRuolo, "Apre Nota Anmenstica", Me.IdPaziente, New Guid(oDettaglioNota.Id), SessionHandler.MotivoAccesso, SessionHandler.MotivoAccessoNote, 1, Me.ConsensoPaziente)
                End If
            End If
        Catch ex As Threading.ThreadAbortException
            '
            ' Non faccio niente
            '
        Catch ex As Exception
            '
            ' Errore
            '
            Logging.WriteError(ex, Me.GetType.Name)
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati!"
        End Try
    End Sub
#End Region

#Region "Eventi CheckBoxList"

#Region "TipoRefertoCheckboxList"
    Private Sub TipoRefertoCheckboxList_SelectedIndexChanged(sender As Object, e As EventArgs) Handles TipoRefertoCheckboxList.SelectedIndexChanged

        Try
            '
            ' ATTENZIONE:
            ' Ogni volta che seleziono una checkbox aggiorno la lista dei TipiReferto selezionati e la salvo in sessione
            '
            Dim checkBoxList As CheckBoxList = CType(sender, CheckBoxList)
            Dim listaTipiReferti As New List(Of String)

            For Each item As ListItem In checkBoxList.Items
                If item.Selected Then
                    listaTipiReferti.Add(item.Value)
                End If
            Next

            '
            ' Salvo in sessione la lista dei TipiReferti
            '
            Me.Session(String.Format("{0}_{1}", KEY_REFERTI_LISTA_TIPIREFERTO, Me.IdPaziente.ToString)) = listaTipiReferti
        Catch ex As Exception
            ucTestataPaziente.mbValidationCancelSelect = True
            mbValidationCancelSelect = True
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'operazione di filtro della lista dei referti!"
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

    Private Sub TipoRefertoCheckboxList_DataBound(sender As Object, e As EventArgs) Handles TipoRefertoCheckboxList.DataBound
        Try
            '
            ' ATTENZIONE
            ' Questo codice viene eseguito la prima volta che entro nella pagina e tutte le volte che viene premuto il pulsante "Cerca"
            ' Serve per reimpostare i filtri dei TipiReferto in base a quelli salvati in sessione
            '
            Dim listaTipiReferti As List(Of String) = CType(Me.Session(String.Format("{0}_{1}", KEY_REFERTI_LISTA_TIPIREFERTO, Me.IdPaziente.ToString)), List(Of String))

            Dim checkBoxList As CheckBoxList = CType(sender, CheckBoxList)
            If Not listaTipiReferti Is Nothing Then
                For Each item As ListItem In checkBoxList.Items
                    '
                    ' Per ogni item controllo se è contenuto nella lista dei TipiReferti
                    ' Se item è contenuto in listaTipiReferti allora lo seleziono 
                    '
                    If listaTipiReferti.Contains(item.Value) Then
                        item.Selected = True
                    End If
                Next

                ' Dopo aver reimpostato i filtri eseguo un bind in modo da visualizzare i dati correttamente filtrati
                WebGridReferti.DataBind()
            End If
        Catch ex As Exception
            ucTestataPaziente.mbValidationCancelSelect = True
            mbValidationCancelSelect = True
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'operazione di caricamento della lista dei tipi di referto!"
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub
#End Region

#Region "TipoPrescrizioniCheckboxList"
    Private Sub TipoPrescrizioneCheckboxList_SelectedIndexChanged(sender As Object, e As EventArgs) Handles TipoPrescrizioneCheckboxList.SelectedIndexChanged
        Try
            '
            ' ATTENZIONE:
            ' Ogni volta che seleziono una checkbox aggiorno la lista dei TipiPrescrizioni selezionati e la salvo in sessione
            '
            Dim checkBoxList As CheckBoxList = CType(sender, CheckBoxList)
            Dim listaTipiPrescrizioni As New List(Of String)

            For Each item As ListItem In checkBoxList.Items
                If item.Selected Then
                    listaTipiPrescrizioni.Add(item.Value)
                End If
            Next

            '
            ' Salvo in sessione la lista dei TipiPrescrizioni
            '
            Me.Session(String.Format("{0}_{1}", KEY_PRESCRIZIONI_LISTA_TIPIREFERTO, Me.IdPaziente.ToString)) = listaTipiPrescrizioni
        Catch ex As Exception
            ucTestataPaziente.mbValidationCancelSelect = True
            mbValidationCancelSelect = True
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'operazione di filtro della lista delle prescrizioni!"
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

    Private Sub TipoPrescrizioneCheckboxList_DataBound(sender As Object, e As EventArgs) Handles TipoPrescrizioneCheckboxList.DataBound
        Try
            '
            ' ATTENZIONE
            ' Questo codice viene eseguito la prima volta che entro nella pagina e tutte le volte che viene premuto il pulsante "Cerca"
            ' Serve per reimpostare i filtri dei TipiPrescrizioni in base a quelli salvati in sessione
            '
            Dim listaTipiPrescrizioni As List(Of String) = CType(Me.Session(String.Format("{0}_{1}", KEY_PRESCRIZIONI_LISTA_TIPIREFERTO, Me.IdPaziente.ToString)), List(Of String))

            Dim checkBoxList As CheckBoxList = CType(sender, CheckBoxList)
            If Not listaTipiPrescrizioni Is Nothing Then
                For Each item As ListItem In checkBoxList.Items
                    '
                    ' Per ogni item controllo se è contenuto nella lista dei TipiPrescrizioni
                    ' Se item è contenuto in listaTipiPrescrizioni allora lo seleziono 
                    '
                    If listaTipiPrescrizioni.Contains(item.Value) Then
                        item.Selected = True
                    End If
                Next


                ' Dopo aver reimpostato i filtri eseguo un bind in modo da visualizzare i dati correttamente filtrati
                WebGridPrescrizioni.DataBind()
            End If
        Catch ex As Exception
            ucTestataPaziente.mbValidationCancelSelect = True
            mbValidationCancelSelect = True
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'operazione di caricamento della lista dei tipi delle prescrizioni!"
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

#End Region

#Region "TipoRefertoPerEpisodiCheckboxList"
    Private Sub TipoRefertoPerEpisodioCheckboxList_SelectedIndexChanged(sender As Object, e As EventArgs) Handles TipoRefertoPerEpisodioCheckboxList.SelectedIndexChanged
        Try
            '
            ' ATTENZIONE:
            ' Ogni volta che seleziono una checkbox aggiorno la lista dei TipiReferto selezionati e la salvo in sessione
            '
            Dim checkBoxList As CheckBoxList = CType(sender, CheckBoxList)
            Dim listaTipiReferti As New List(Of String)

            For Each item As ListItem In checkBoxList.Items
                If item.Selected Then
                    listaTipiReferti.Add(item.Value)
                End If
            Next

            '
            ' Salvo in sessione la lista dei TipiReferti
            '
            Me.Session(String.Format("{0}_{1}", KEY_REFERTI_PER_EPISODI_LISTA_TIPIREFERTO, Me.IdPaziente.ToString)) = listaTipiReferti
        Catch ex As Exception
            ucTestataPaziente.mbValidationCancelSelect = True
            mbValidationCancelSelect = True
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'operazione di filtro dei referti nella lista degli episodi!"
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

    Private Sub TipoRefertoPerEpisodioCheckboxList_DataBound(sender As Object, e As EventArgs) Handles TipoRefertoPerEpisodioCheckboxList.DataBound
        Try
            '
            ' ATTENZIONE
            ' Questo codice viene eseguito la prima volta che entro nella pagina e tutte le volte che viene premuto il pulsante "Cerca"
            ' Serve per reimpostare i filtri dei TipiReferti in base a quelli salvati in sessione
            '
            Dim listaTipiReferti As List(Of String) = CType(Me.Session(String.Format("{0}_{1}", KEY_REFERTI_PER_EPISODI_LISTA_TIPIREFERTO, Me.IdPaziente.ToString)), List(Of String))

            Dim checkBoxList As CheckBoxList = CType(sender, CheckBoxList)
            If Not listaTipiReferti Is Nothing Then
                For Each item As ListItem In checkBoxList.Items
                    '
                    ' Per ogni item controllo se è contenuto nella lista dei TipiReferti
                    ' Se item è contenuto in listaTipiReferti allora lo seleziono 
                    '
                    If listaTipiReferti.Contains(item.Value) Then
                        item.Selected = True
                    End If
                Next

                ' Dopo aver reimpostato i filtri eseguo un bind in modo da visualizzare i dati correttamente filtrati
                'WebGridRefertiEpisodi.DataBind()
            End If
        Catch ex As Exception
            ucTestataPaziente.mbValidationCancelSelect = True
            mbValidationCancelSelect = True
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'operazione di caricamento della lista dei tipi dei referti nella lista degli episodi!"
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub
#End Region

#End Region

    Private Sub ucTestataPaziente_ConsensoModificato(sender As Object, e As EventArgs) Handles ucTestataPaziente.ConsensoModificato
        '
        ' Questo evento viene scatenato al click sui pulsanti di acquisizione di un consenso.
        ' Ogni volta che viene acquisito un consenso devo ricaricare i dati:
        '   1. Salvo in sessione che è necessario cancellare la cache degli ObjectDataSource.
        '   2. Salvo in sessione i filtri laterali -> questo perchè quando salvo il consenso rieseguo un redirtect a questa pagina.
        '
        SessionHandler.CancellaCache = True
        SaveFilterValues()
    End Sub

    Private Sub BtnFSE_Click(sender As Object, e As EventArgs) Handles BtnFSE.Click
        Try
            Dim isConsensoAbilitato As Boolean = False
            '
            'Controllo se il codice fiscale è valorizzato
            '
            If String.IsNullOrEmpty(ucTestataPaziente.CodiceFiscale) Then
                Throw New ApplicationException("Errore: Il codice fiscale del paziente non è valorizzato correttamente.")
            End If


            Utility.TraceWriteLine("FSE Consensi: Invocazione del servizio SOLE per verifica presenza consenso. CodiceFiscalePaziente: " & ucTestataPaziente.CodiceFiscale)

            '
            ' Chiamata al WS
            '
            Using oWcf As New WcfDwhClinico.ServiceClient
                Utility.SetWcfDwhClinicoCredential(oWcf)
                Dim oConsenso As WcfDwhClinico.ConsensoReturn = oWcf.FseConsensoOttieniPerCodiceFiscale(Token, ucTestataPaziente.CodiceFiscale)
                If oConsenso IsNot Nothing Then
                    If oConsenso.Errore IsNot Nothing Then
                        Throw New WsDwhException("Si è verificato un errore durante la verifica del consenso. ", oConsenso.Errore)
                    Else
                        If oConsenso.Consenso.AccessoFse Then

                            isConsensoAbilitato = True
                            '
                            'Eseguo un redirect alla pagina di gestione del Fascicolo Sanitario Elettronico.
                            '
                            Response.Redirect(String.Format("~/FSE/DocumentiLista.aspx?IdPaziente={0}", Me.IdPaziente), False)

                        Else
                            '
                            ' Se il paziente non ha dato il consenso mostro la modal per la richiesta consenso
                            '
                            ScriptManager.RegisterStartupScript(Page, Me.GetType(), "ModaleConsensoFSE", "$('#ModaleConsensoFSE').modal('show');", True)
                        End If
                    End If
                End If

                Utility.TraceWriteLine(String.Format("FSE Consensi: CodiceFiscalePaziente= {0}, ConsensoAbilitato = {1} Response: ConsensoConsultazione = {2}", ucTestataPaziente.CodiceFiscale, isConsensoAbilitato, oConsenso.Consenso.ConsensoConsultazione))

            End Using

        Catch ex As WsDwhException
            mbValidationCancelSelect = True

            divErrorMessage.Visible = True
            lblErrorMessage.Text = ex.Message

        Catch ex As ApplicationException
            mbValidationCancelSelect = True

            divErrorMessage.Visible = True
            lblErrorMessage.Text = ex.Message
        Catch ex As Exception
            mbValidationCancelSelect = True

            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Si è verificato un errore durante l'accesso al Fascicolo Sanitario Elettronico."
            '
            ' Errore
            '
            Dim sMsgErr As String = FormatException(ex) 'con formatException si visualizzano anche le inner exception
            Logging.WriteError(ex, sMsgErr)
        End Try
    End Sub

    Private Sub BtnAcquisisciConsensoFSE_Click(sender As Object, e As EventArgs) Handles BtnAcquisisciConsensoFSE.Click

        Try
            ' Recupero i dati del paziente dal SAC tramite il WS
            Dim oPazienteSac As New PazienteSac
            Dim datiPazienteSac As SacPazientiDataAccess.PazientiDettaglio2ByIdResponsePazientiDettaglio2 = oPazienteSac.GetDettaglioPaziente(IdPaziente.ToString)

            ' Definisco i dati necessari per la chiamata al WS
            Dim pazienteCodiceFiscale As String = datiPazienteSac.CodiceFiscale
            Dim pazienteCognome As String = datiPazienteSac.Cognome
            Dim pazienteNome As String = datiPazienteSac.Nome
            Dim codiceAslAss As String = datiPazienteSac.CodiceAslAss


            ' Verifico che i dati necessari per la chiamata al WS siano validi, altrimenti application exception
            If String.IsNullOrEmpty(pazienteCodiceFiscale) Then
                Throw New ApplicationException("Il codice fiscale del paziente non è valorizzato! Dato necessario per il consenso FSE")
            End If
            If String.IsNullOrEmpty(pazienteCognome) Then
                Throw New ApplicationException("Il cognome del paziente non è valorizzato! Dato necessario per il consenso FSE")
            End If
            If String.IsNullOrEmpty(pazienteNome) Then
                Throw New ApplicationException("Il nome del paziente non è valorizzato! Dato necessario per il consenso FSE")
            End If
            If String.IsNullOrEmpty(codiceAslAss) Then
                Throw New ApplicationException("Il codice ASL assistenza del paziente non è valorizzato! Dato necessario per il consenso FSE")
            End If
            If String.IsNullOrEmpty(Me.CodiceFiscaleRichiedente) Then
                Throw New ApplicationException("Il codice fiscale dell'utente corrente non è valorizzato! Dato necessario per il consenso FSE")
            End If

            '
            ' Effettuo la chiamata al WS
            '
            Using oWcf As New WcfDwhClinico.ServiceClient
                Utility.SetWcfDwhClinicoCredential(oWcf)
                '
                ' Chiamata al metodo che restituisce i dati
                '
                Dim erroreReturn As WcfDwhClinico.ErroreReturn = oWcf.FseConsensoAggiungiOppureModifica(Token, Consenso:=True, pazienteCodiceFiscale, pazienteCognome, pazienteNome, codiceAslAss, Me.CodiceFiscaleRichiedente)
                If erroreReturn.Errore IsNot Nothing Then
                    Throw New WsDwhException("Si è verificato un errore durante l'acquisizione del consenso. ", erroreReturn.Errore)
                Else
                    '
                    'Se non ci sono errori eseguo un redirect alla pagina di gestione del Fascicolo Sanitario Elettronico.
                    '
                    Response.Redirect(String.Format("~/FSE/DocumentiLista.aspx?IdPaziente={0}", Me.IdPaziente), False)

                    'Traccio l'operazione
                    Dim oTracciaOp As New TracciaOperazioniManager(Utility.GetAppSettings(Utility.PAR_DI_PORTAL_USER_CONNECTION_STRING, ""))
                    oTracciaOp.TracciaOperazione(PortalsNames.DwhClinico, Page.AppRelativeVirtualPath, "Acquisito consenso alla consultazione FSE", IdPaziente, Nothing)

                End If
            End Using

        Catch ex As WsDwhException
            mbValidationCancelSelect = True

            divErrorMessage.Visible = True
            lblErrorMessage.Text = ex.Message

        Catch ex As ApplicationException
            mbValidationCancelSelect = True

            divErrorMessage.Visible = True
            lblErrorMessage.Text = ex.Message
        Catch ex As Exception
            mbValidationCancelSelect = True

            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Si è verificato un errore durante l'acquisizione del consenso per l'accesso al Fascicolo Sanitario Elettronico."
            '
            ' Errore
            '
            Dim sMsgErr As String = FormatException(ex) 'con formatException si visualizzano anche le inner exception
            Logging.WriteError(ex, sMsgErr)
        End Try
    End Sub

    Private Sub BtnNegaConsensoFSE_Click(sender As Object, e As EventArgs) Handles BtnNegaConsensoFSE.Click

        Try
            ' Recupero i dati del paziente dal SAC tramite il WS
            Dim oPazienteSac As New PazienteSac
            Dim datiPazienteSac As SacPazientiDataAccess.PazientiDettaglio2ByIdResponsePazientiDettaglio2 = oPazienteSac.GetDettaglioPaziente(IdPaziente.ToString)

            ' Definisco i dati necessari per la chiamata al WS
            Dim pazienteCodiceFiscale As String = datiPazienteSac.CodiceFiscale
            Dim pazienteCognome As String = datiPazienteSac.Cognome
            Dim pazienteNome As String = datiPazienteSac.Nome
            Dim codiceAslAss As String = datiPazienteSac.CodiceAslAss


            ' Verifico che i dati necessari per la chiamata al WS siano validi, altrimenti application exception
            If String.IsNullOrEmpty(pazienteCodiceFiscale) Then
                Throw New ApplicationException("Il codice fiscale del paziente non è valorizzato! Dato necessario per il consenso FSE")
            End If
            If String.IsNullOrEmpty(pazienteCognome) Then
                Throw New ApplicationException("Il cognome del paziente non è valorizzato! Dato necessario per il consenso FSE")
            End If
            If String.IsNullOrEmpty(pazienteNome) Then
                Throw New ApplicationException("Il nome del paziente non è valorizzato! Dato necessario per il consenso FSE")
            End If
            If String.IsNullOrEmpty(codiceAslAss) Then
                Throw New ApplicationException("Il codice ASL assistenza del paziente non è valorizzato! Dato necessario per il consenso FSE")
            End If
            If String.IsNullOrEmpty(Me.CodiceFiscaleRichiedente) Then
                Throw New ApplicationException("Il codice fiscale dell'utente corrente non è valorizzato! Dato necessario per il consenso FSE")
            End If

            '
            ' Effettuo la chiamata al WS
            '
            Using oWcf As New WcfDwhClinico.ServiceClient
                Utility.SetWcfDwhClinicoCredential(oWcf)
                Dim erroreReturn As WcfDwhClinico.ErroreReturn = oWcf.FseConsensoAggiungiOppureModifica(Token, Consenso:=False, pazienteCodiceFiscale, pazienteCognome, pazienteNome, codiceAslAss, Me.CodiceFiscaleRichiedente)
                If erroreReturn IsNot Nothing Then
                    Throw New WsDwhException("Si è verificato un errore durante la negazione del consenso. ", erroreReturn.Errore)
                Else
                    'Traccio l'operazione
                    Dim oTracciaOp As New TracciaOperazioniManager(Utility.GetAppSettings(Utility.PAR_DI_PORTAL_USER_CONNECTION_STRING, ""))
                    oTracciaOp.TracciaOperazione(PortalsNames.DwhClinico, Page.AppRelativeVirtualPath, "Negato consenso alla consultazione FSE", IdPaziente, Nothing)

                End If
            End Using

        Catch ex As WsDwhException
            mbValidationCancelSelect = True

            divErrorMessage.Visible = True
            lblErrorMessage.Text = ex.Message

        Catch ex As ApplicationException
            mbValidationCancelSelect = True

            divErrorMessage.Visible = True
            lblErrorMessage.Text = ex.Message
        Catch ex As Exception
            mbValidationCancelSelect = True

            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Si è verificato un errore durante la negazione del consenso per l'accesso al Fascicolo Sanitario Elettronico."
            '
            ' Errore
            '
            Dim sMsgErr As String = FormatException(ex) 'con formatException si visualizzano anche le inner exception
            Logging.WriteError(ex, sMsgErr)
        End Try
    End Sub

#Region "Gestione TAB"
    ''' <summary>
    ''' Funzione che gestisce il click sulle tab
    ''' </summary>
    ''' <param name="sender"></param>
    ''' <param name="e"></param>
    Protected Sub SelectView(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.CommandEventArgs)
        '
        ' Viene chiamata quando si clicca su pulsanti tab
        '
        Dim olnkView As LinkButton = Nothing
        Try
            olnkView = CType(sender, LinkButton)
            _SetSelectedView(olnkView)
            Cerca()
        Catch ex As Threading.ThreadAbortException
            '
            ' Non faccio niente
            '
        Catch ex As Exception
            ucTestataPaziente.mbValidationCancelSelect = True
            mbValidationCancelSelect = True
            Logging.WriteError(ex, Me.GetType.Name)
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante selezione della tab!"
        End Try
    End Sub

    ''' <summary>
    ''' Funzione che si occupa della visualizzazione della tab.
    ''' </summary>
    ''' <param name="oClickedButton"></param>
    Private Sub _SetSelectedView(ByVal oClickedButton As LinkButton)
        Dim clickedTab As HtmlGenericControl = Nothing
        '
        ' Rimuovo la classe Bootstrap "active" da tutti i tab
        '
        tabLnkReferti.Attributes.Clear()
        CalendarioTab.Attributes.Clear()
        tabLnkRefertiEpisodi.Attributes.Clear()
        tabLnkRisultatoMatrice.Attributes.Clear()
        PrescrizioniTab.Attributes.Clear()
        SchedePazienteTab.Attributes.Clear()
        NoteAnamnesticheTab.Attributes.Clear()

        '
        ' Aggiungo al tab selezionato la classe Bootstrap "active"
        '
        clickedTab = oClickedButton.Parent
        clickedTab.Attributes.Add("class", "active")

        '
        ' Nascondo tutti i filtri laterali non generici (tutto tranne la selezione della data).
        ' Prima visualizza tutti poi nasconde quelli non necessari
        '
        btnExecutePrint.Visible = True
        FiltriCheckBoxList.Visible = True
        TipoRefertoCheckboxList.Visible = True
        TipoPrescrizioneCheckboxList.Visible = True
        TipoRefertoPerEpisodioCheckboxList.Visible = True

        Select Case oClickedButton.UniqueID
            Case lnkReferti.UniqueID 'Lista Referti
                MultiViewMain.SetActiveView(ViewReferti)
                TipoPrescrizioneCheckboxList.Visible = False
                TipoRefertoPerEpisodioCheckboxList.Visible = False

            Case lnkCalendario.UniqueID 'Calendario
                MultiViewMain.SetActiveView(ViewCalendario)
                'KYRYLO 2020-03-02: Rimuovo tutti i filtri ed il pulsante per stampare i referti selezionati (la selezione di referti in giorni diversi non è stata implementata). 
                btnExecutePrint.Visible = False
                FiltriCheckBoxList.Visible = False
                TipoRefertoCheckboxList.Visible = False
                TipoPrescrizioneCheckboxList.Visible = False
                TipoRefertoPerEpisodioCheckboxList.Visible = False

            Case lnkRefertiEpisodi.UniqueID 'Lista Episodi
                FiltriCheckBoxList.Visible = True
                MultiViewMain.SetActiveView(ViewRefertiEpisodi)
                TipoPrescrizioneCheckboxList.Visible = False
                TipoRefertoCheckboxList.Visible = False

            Case lnkRisultatoMatrice.UniqueID 'Lista Matrice
                FiltriCheckBoxList.Visible = False
                btnExecutePrint.Visible = False
                MultiViewMain.SetActiveView(ViewRisultatoMatrice)

            Case lnkPrescrizioni.UniqueID 'Prescrizioni
                TipoRefertoCheckboxList.Visible = False
                TipoRefertoPerEpisodioCheckboxList.Visible = False
                MultiViewMain.SetActiveView(ViewPrescrizioni)
                btnExecutePrint.Visible = False

            Case lnkSchedePaziente.UniqueID 'Schede paziente
                FiltriCheckBoxList.Visible = False
                MultiViewMain.SetActiveView(ViewSchedePaziente)

            Case lnkNoteAnamnestiche.UniqueID 'Lista NoteAnamnestiche
                '
                'Nascondo tutti i filtri.
                '
                FiltriCheckBoxList.Visible = False
                btnExecutePrint.Visible = False

                '
                'Seleziono la tab corretta.
                '
                MultiViewMain.SetActiveView(ViewNoteAnamnestiche)

                '
                'Traccio l'accesso alle note anamnestiche.
                '
            Case Else
                Throw New Exception("Non esiste il tab " & oClickedButton.Text)
        End Select
        '
        ' Salvo la Tab selezionata
        '
        Me.Session(mstrPageID & VS_CURRENT_LNK_VIEW) = oClickedButton.ID
    End Sub

    ''' <summary>
    ''' Ottiene la tab precedentemente selezionata dalla sessione e la riseleziona
    ''' </summary>
    Private Sub RestoreSelectedTab()
        '
        ' Seleziono la tab da visualizzare
        '
        Dim olnkView As LinkButton
        Select Case CType(Me.Session(mstrPageID & VS_CURRENT_LNK_VIEW), String)
            Case lnkReferti.ID
                olnkView = lnkReferti

            Case lnkCalendario.ID
                olnkView = lnkCalendario

            Case lnkRisultatoMatrice.ID
                olnkView = lnkRisultatoMatrice

            Case lnkPrescrizioni.ID
                olnkView = lnkPrescrizioni

            Case lnkRefertiEpisodi.ID
                olnkView = lnkRefertiEpisodi

            Case lnkSchedePaziente.ID
                olnkView = lnkSchedePaziente

            Case lnkNoteAnamnestiche.ID
                olnkView = lnkNoteAnamnestiche

            Case Else
                olnkView = lnkReferti
        End Select

        '
        ' Seleziono la tab ed eseguo ricerca
        '
        _SetSelectedView(olnkView)
    End Sub
#End Region

    Private Sub SetGridViewBootstrapStyle()
        '
        ' Paginazione di default
        '
        WebGridRefertiEpisodi.PageSize = GRID_PAGE_SIZE
        WebGridReferti.PageSize = GRID_PAGE_SIZE
        WebGridPrescrizioni.PageSize = GRID_PAGE_SIZE
        WebGridEventiSingoli.PageSize = GRID_PAGE_SIZE
        gvNoteAnamnestiche.PageSize = GRID_PAGE_SIZE

        '
        ' RENDERING PER BOOTSTRAP
        ' Converte i tag html generati dalla GridView per la paginazione
        ' e li adatta alle necessita dei CSS Bootstrap
        '
        WebGridReferti.PagerStyle.CssClass = "pagination-gridview"
        WebGridRefertiEpisodi.PagerStyle.CssClass = "pagination-gridview"
        WebGridEventiSingoli.PagerStyle.CssClass = "pagination-gridview"
        WebGridEventiEpisodio.PagerStyle.CssClass = "pagination-gridview"
        WebGridPrescrizioni.PagerStyle.CssClass = "pagination-gridview"
        gvNoteAnamnestiche.PagerStyle.CssClass = "pagination-gridview"
        ScriptManager.RegisterStartupScript(Page, Page.GetType(), "gridPagination", HelperGridView.GetScriptPaginationForBootstrap(), True)
    End Sub

    Private Sub Referti_RefertiListaPaziente_Unload(sender As Object, e As EventArgs) Handles Me.Unload
        'tracciamento degli accessi
        'LoadComplete è l'ultimo evento della pagina quindi le griglie sono già state riempite.
        If MultiViewMain.GetActiveView Is ViewPrescrizioni Then
            TracciaAccessi.TracciaAccessiLista(Me.CodiceRuolo, Me.DescrizioneRuolo, "Lista impegnative", Me.IdPaziente, SessionHandler.MotivoAccesso, SessionHandler.MotivoAccessoNote, WebGridPrescrizioni.Rows.Count, Me.ConsensoPaziente)
        ElseIf MultiViewMain.GetActiveView Is ViewRefertiEpisodi Then
            TracciaAccessi.TracciaAccessiLista(Me.CodiceRuolo, Me.DescrizioneRuolo, "Lista episodi", Me.IdPaziente, SessionHandler.MotivoAccesso, SessionHandler.MotivoAccessoNote, WebGridRefertiEpisodi.Rows.Count, Me.ConsensoPaziente)
        ElseIf MultiViewMain.GetActiveView Is ViewReferti Then
            TracciaAccessi.TracciaAccessiLista(Me.CodiceRuolo, Me.DescrizioneRuolo, "Lista referti", Me.IdPaziente, SessionHandler.MotivoAccesso, SessionHandler.MotivoAccessoNote, WebGridReferti.Rows.Count, Me.ConsensoPaziente)
        ElseIf MultiViewMain.GetActiveView Is ViewCalendario Then
            TracciaAccessi.TracciaAccessiLista(Me.CodiceRuolo, Me.DescrizioneRuolo, "Calendario", Me.IdPaziente, SessionHandler.MotivoAccesso, SessionHandler.MotivoAccessoNote, WebGridReferti.Rows.Count, Me.ConsensoPaziente)
        ElseIf MultiViewMain.GetActiveView Is ViewSchedePaziente Then
            TracciaAccessi.TracciaAccessiLista(Me.CodiceRuolo, Me.DescrizioneRuolo, "Lista referti", Me.IdPaziente, SessionHandler.MotivoAccesso, SessionHandler.MotivoAccessoNote, WebGridEventiSingoli.Rows.Count, Me.ConsensoPaziente)
        ElseIf MultiViewMain.GetActiveView Is ViewNoteAnamnestiche Then
            TracciaAccessi.TracciaAccessiLista(Me.CodiceRuolo, Me.DescrizioneRuolo, "Lista note anamnestiche", Me.IdPaziente, SessionHandler.MotivoAccesso, SessionHandler.MotivoAccessoNote, gvNoteAnamnestiche.Rows.Count, Me.ConsensoPaziente)
        End If
    End Sub

    Private Sub btnExecutePrint_PreRender(sender As Object, e As EventArgs) Handles btnExecutePrint.PreRender
        Try
            btnExecutePrint.Visible = My.Settings.Print_Enabled
        Catch ex As Exception
            Logging.WriteError(ex, Me.GetType.Name)
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Si è verificato un errore, contattare l'amministratore."
        End Try
    End Sub

    Private Sub DataSourceLstTipiReferti_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles DataSourceLstTipiReferti.Selecting

        e.InputParameters("IdPaziente") = IdPaziente
    End Sub

End Class