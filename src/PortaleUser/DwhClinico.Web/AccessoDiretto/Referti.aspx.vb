Imports DwhClinico.Data
Imports DwhClinico.Web
Imports DwhClinico.Web.Utility
Imports System.Security
Imports DI.PortalUser2
Imports DwhClinico.Web.WcfDwhClinico
Imports DI.PortalUser2.Data

'
' MODIFICA ETTORE 2015-03-20: Prima per capire se la pagina era un entry point usavo solo If Me.Request.UrlReferrer Is Nothing Then
' Non è corretto in generale perhè il chiamante potrebbe essere una applicazione web che quindi passerebbe il referrer (a meno di utilizzare window.open() per chiamare la pagina dell'accesso diretto)
' Inoltre C'era un bug: se invece di preme il pulsante ACCEDI del consenso si premeva annulla si visualizzavano comunque i referti.
' Per evitare ciò ho impostato una variabile di sessione associata al paziente e alla pressione del pulsante "Accedi"/"Accedi Forzato" dalla pagina dei consensi.
'

Partial Class AccessoDiretto_Referti
    Inherits System.Web.UI.Page

#Region "Variabili di pagina"
    Private mstrPageID As String
    Protected WithEvents DivPageTitle As Global.System.Web.UI.HtmlControls.HtmlGenericControl
    Private mbValidationCancelSelect As Boolean = False
    Private mbValidationSelect As Boolean = True
    Private ReadOnly PageSessionIdPrefix As String = Page.GetType().BaseType.FullName
    Private Const VS_CURRENT_LNK_VIEW As String = "{E55FFE43-3BC4-4531-A3BE-CBDFA54564E5}"
    Private Const GRID_PAGE_SIZE As Integer = 100
    Private mbDataSourceRefertiPerNosologicoCancelSelect As Boolean = True

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
    ' Lista dei referti riempita nel RowDataBound della griglia WebGridRefertiEpisodi
    ' Viene usata per comporre la lista dei tipi referto da inserire nella checkbox list dei filtri laterali
    '
    Dim listaReferti As New List(Of WcfDwhClinico.RefertoListaType)

    Dim InvalidaCacheRefertiPerNosologico As Boolean = False

    '
    ' Key usate per salvare le liste dei tipiReferto in sessione
    '
    Private Const KEY_AD_REFERTI_LISTA_TIPIREFERTO As String = "KEY_AD_REFERTI_LISTA_TIPIREFERTO"
    Private Const KEY_AD_PRESCRIZIONI_LISTA_TIPIREFERTO As String = "KEY_AD_PRESCRIZIONI_LISTA_TIPIREFERTO"
    Private Const KEY_AD_REFERTI_PER_EPISODI_LISTA_TIPIREFERTO As String = "KEY_AD_REFERTI_PER_EPISODI_LISTA_TIPIREFERTO"

    '
    ' Variabile per gestire la visualizzazione a calendario
    '
    Public CalendarAdapter As CalendarAdapter

#End Region

#Region "Property"
    Public Property ConsensoPaziente As String
        Get
            Return Me.ViewState("ConsensoPaziente")
        End Get
        Set(value As String)
            Me.ViewState("ConsensoPaziente") = value
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

    Public Property ShowPannelloPaziente As String
        Get
            Return Me.ViewState("ShowPannelloPaziente")
        End Get
        Set(value As String)
            Me.ViewState("ShowPannelloPaziente") = value
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

    ''' <summary>
    ''' DataMinimaFiltro viene valorizzata solo se non ho forzato l'accesso
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks></remarks>
    ''' 
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
        Try
            '
            ' Controllo la validità della sessione
            '
            If Not Page.IsPostBack AndAlso Utility.AccessoDiretto_IsPageEntryPoint() Then
                'Mostro o nascondo l'header della masterpage in base a quanto indicato nella querystring o precedentemente in sessione
                Utility.CheckShowHeaderParam(Request)
                '
                ' Se la pagina è EntryPoint e non è un PostBack allora valorizzo la variabile
                '
                SessionHandler.ValidaSessioneAccessoDiretto = True

            ElseIf SessionHandler.ValidaSessioneAccessoDiretto = Nothing Then
                '
                ' Se sono qui la sessione è scaduta e mostro un messaggio di errore.
                '
                Throw New ApplicationException("La sessione di lavoro è scaduta.")
            End If

            '
            ' Id della pagina
            '
            mstrPageID = "AccessoDiretto_Referti" 'Me.GetType.Name

            '
            ' Leggo i parametri dal QueryString
            '
            Dim oQueryString As Specialized.NameValueCollection = Me.Request.QueryString
            Dim sIdPaziente As String = oQueryString(PAR_ID_PAZIENTE)
            Dim sIdPazienteEsterno As String = oQueryString(PAR_ID_ESTERNO) ' Affinchè una ricerca dell'IdPaziente per IdEsterno restituisca qualcosa bisogna che IdEsterno="SAC_<IdPazienteAttivo>"
            Dim sNomeAnagrafica As String = oQueryString(PAR_NOME_ANAGRAFICA)
            Dim sIdAnagrafica As String = oQueryString(PAR_ID_ANAGRAFICA)
            Dim sNumeroNosologico As String = oQueryString(PAR_NUMERO_NOSOLOGICO)
            Dim sSistemaErogante As String = oQueryString(PAR_SISTEMA_EROGANTE)
            Dim sRepartoErogante As String = oQueryString(PAR_REPARTO_EROGANTE)
            Dim sRepartoRichiedenteCodice As String = oQueryString(PAR_REPARTO_RICHIEDENTE)
            Dim sDallaData As String = oQueryString(PAR_DALLA_DATA) 'sempre DD/MM/YYYY

            '
            ' Parametri opzionali
            '
            Dim sAziendaErogante As String = oQueryString(PAR_AZIENDA_EROGANTE)
            Dim sAnnoReferto As String = oQueryString("AnnoReferto")
            Dim sNumeroReferto As String = oQueryString("NumeroReferto")
            Dim sCodiceFiscale As String = oQueryString(PAR_CODICE_FISCALE)
            Dim sNumeroPrenotazione As String = oQueryString(PAR_NUMERO_PRENOTAZIONE)
            Dim sIdOrderEntry As String = oQueryString(PAR_ID_ORDER_ENTRY)

            '
            ' Solo la prima volta
            '
            If Not IsPostBack Then

                '
                ' Valorizzo l'url per tornare alla lista dei referti usato nella pagina di dettaglio referto.
                '
                SessionHandler.AccessoDirettoListaRefertiUrl = Request.Url.AbsoluteUri

                '
                ' Cancello dalla sessione idReferto
                '
                SessionHandler.IdReferto = Nothing

                ' SE LA PAGINA È ENTRY POINT NASCONDO LA VOCE DEL MENU "PAZIENTI"
                Dim oMenu As Menu = CType(Master.FindControl("MenuMain2"), Menu)
                ' IL LOAD DI QUESTA PAGINA VIENE PRIMA DI QUELLO DELLA MASTERPAGE. ESEGUO IL BIND DEI DATI PER ESSERE SICURO DI TROVARE IL MENU POPOLATO.
                oMenu.DataBind()
                'OTTENGO L'ITEM PAZIENTI.
                Dim menuItemPazienti As MenuItem = UserInterface.GetMenuItem(oMenu, "Pazienti")
                'SE L'ITEM NON E' STATO TROVATO MOSTRO UN MESSAGGIO DI ERRORE.
                If menuItemPazienti Is Nothing Then
                    Throw New ApplicationException("La voce del menu ""Pazienti"" non esiste.")
                End If

                SessionHandler.AccessoDirettoUrlReferti = HttpContext.Current.Request.Url.AbsoluteUri

                If Utility.AccessoDiretto_IsPageEntryPoint OrElse SessionHandler.AccessoDirettoUrlPazienti = Nothing Then
                    '
                    ' Inizio una nuova navigazione dalla pagina Referti e resetto la variabile di sessione per la voce del menu "Pazienti"
                    '
                    SessionHandler.AccessoDirettoUrlPazienti = Nothing
                    oMenu.Items.Remove(menuItemPazienti)

                    '
                    ' Se la pagina è EntryPoint allora salvo nel view state il motivo d'accesso "Paziente in carico"
                    '
                    SessionHandler.MotivoAccesso = New ListItem(MOTIVO_ACCESSO_PAZIENTE_IN_CARICO_TEXT, MOTIVO_ACCESSO_PAZIENTE_IN_CARICO_ID)
                Else
                    menuItemPazienti.NavigateUrl = SessionHandler.AccessoDirettoUrlPazienti
                End If

                '
                'Seleziono la Tab corretta.
                '
                RestoreSelectedTab()

                '---------------------------------------------------------------------------------------
                ' Verifico il parametro PAR_DALLA_DATA
                ' Imposto una data minima se non valorizzata (SOLO PER PAGINA REFERTI.ASPX)
                '---------------------------------------------------------------------------------------
                Dim dDallaData As Date = Nothing
                If String.IsNullOrEmpty(sDallaData) Then
                    GetDataDal()
                Else
                    If Not Date.TryParse(sDallaData, dDallaData) Then
                        Throw New ApplicationException(String.Format("Il parametro {0} non è formattato correttamente.", PAR_DALLA_DATA))
                    End If
                    txtDataDal.Text = String.Format("{0:d}", dDallaData)
                End If

                '
                ' Valorizzo la label per la data contenuta nei tab 
                '
                lblDataFiltri.Text = txtDataDal.Text
            End If

            ' imposto sempre le  giuste CustomDataSource in base ai parametri presenti per tutte le tab
            ' imposto la visualizzazione delle tab in base ai parametri dell'url
            '
            tabLnkReferti.Visible = False
            tabLnkCalendario.Visible = False
            tabLnkRefertiEpisodi.Visible = False
            tabLnkRisultatoMatrice.Visible = False
            tabLnkPrescrizioni.Visible = False
            tabLnkSchedePaziente.Visible = False
            tabLnkNoteAnamnestiche.Visible = False

            '
            ' Cancello la lista dei parametri delle DataSource
            ' Le seguenti query in base ai parametri vengono fatte ad ogni PostBack per poter settare il corretto TypeName e SelectMethod degli ObjectDataSource 
            ' perchè vengono impostati dinamicamente
            '
            DataSourceMain.SelectParameters.Clear()
            DataSourcePrescrizioni.SelectParameters.Clear()
            DataSourceEpisodi.SelectParameters.Clear()
            DataSourcePrestazioniMatrice.SelectParameters.Clear()
            DataSourceRefertiSingoli.SelectParameters.Clear()
            DataSourceNoteAnamnestiche.SelectParameters.Clear()

            '
            ' In base ai parametri del query string
            '
            If Not String.IsNullOrEmpty(sNumeroPrenotazione) Then
                '--------------------------------------------------------
                ' Ricerca per NumeroPrenotazione
                '--------------------------------------------------------
                tabLnkReferti.Visible = True
                '
                ' Cancello la cache
                '
                Dim oDs As New CustomDataSource.AccessoDirettoRefertiCercaPerNumeroPrenotazione
                oDs.ClearCache()
                '
                ' Imposto i parametri di filtro (i parametri mancanti, che sono quelli condivisi, vengono valorizzati nell'evento "Selecting")
                '
                DataSourceMain.TypeName = "DwhClinico.Web.CustomDataSource.AccessoDirettoRefertiCercaPerNumeroPrenotazione"
                DataSourceMain.SelectMethod = "GetData"
                DataSourceMain.SelectParameters.Add("NumeroPrenotazione", sNumeroPrenotazione)
                DataSourceMain.SelectParameters.Add("SistemaErogante", If(Not String.IsNullOrEmpty(sSistemaErogante), sSistemaErogante, Nothing))
                DataSourceMain.SelectParameters.Add("RepartoErogante", If(Not String.IsNullOrEmpty(sRepartoErogante), sRepartoErogante, Nothing))
                DataSourceMain.SelectParameters.Add("RepartoRichiedenteCodice", If(Not String.IsNullOrEmpty(sRepartoRichiedenteCodice), sRepartoRichiedenteCodice, Nothing))
                '
                ' Forzo il bind della griglia associata alla DataSourceMain, cosi si scatena l'evento "Selected" e se si trovano record si popola Me.IdPaziente
                '
                divWebGridReferti.DataBind()
                '
                ' Se non si sono ottenuti dei record rieseguo query per trovare IdPaziente
                '
                If Me.IdPaziente = Nothing Then
                    oDs.ClearCache()
                    '
                    ' Imposto ByPassaConsesno=True per essere sicuro che se il NumeroPrenotazione è corretto vengano restituiti record
                    '

                    '2020-04-06 Leo: Correzione dei parametri, prima andava sempre in errore
                    Dim oListareferti As List(Of WcfDwhClinico.RefertoListaType) = oDs.GetData(Me.Token, "", True, sNumeroPrenotazione, #1/1/1900#, Nothing,
                                If(Not String.IsNullOrEmpty(sSistemaErogante), sSistemaErogante, Nothing),
                                If(Not String.IsNullOrEmpty(sRepartoErogante), sRepartoErogante, Nothing),
                                If(Not String.IsNullOrEmpty(sRepartoRichiedenteCodice), sRepartoRichiedenteCodice, Nothing), Nothing)
                    If oListareferti IsNot Nothing AndAlso oListareferti.Count > 0 Then
                        Me.IdPaziente = New Guid(oListareferti(0).IdPaziente)
                    End If
                End If

            ElseIf Not String.IsNullOrEmpty(sIdOrderEntry) Then
                '--------------------------------------------------------
                ' Ricerca per IdOrderEntry
                '--------------------------------------------------------
                tabLnkReferti.Visible = True
                tabLnkRisultatoMatrice.Visible = True
                '
                ' Cancello la cache
                '
                Dim oDs As New CustomDataSource.AccessoDirettoRefertiCercaPerIdOrderEntry
                oDs.ClearCache()
                '
                ' Imposto i parametri di filtro (i parametri mancanti, che sono quelli condivisi, vengono valorizzati nell'evento "Selecting")
                '
                DataSourceMain.TypeName = "DwhClinico.Web.CustomDataSource.AccessoDirettoRefertiCercaPerIdOrderEntry"
                DataSourceMain.SelectMethod = "GetData"
                DataSourceMain.SelectParameters.Add("IdOrderEntry", sIdOrderEntry)

                '
                ' Forzo il bind della griglia associata alla DataSourceMain, cosi si scatena l'evento "Selected" e se si trovano record si popola Me.IdPaziente
                '
                divWebGridReferti.DataBind()
                '
                ' Se non si sono ottenuti dei record rieseguo query per trovare IdPaziente
                '
                If Me.IdPaziente = Nothing Then
                    oDs.ClearCache()
                    '
                    ' Imposto ByPassaConsesno=True per essere sicuro che se il IdOrderEntry è corretto vengano restituiti record
                    '
                    Dim oListareferti As List(Of WcfDwhClinico.RefertoListaType) = oDs.GetData(Me.Token, "", True, sIdOrderEntry, #1/1/1900#, Nothing, Nothing)
                    If oListareferti IsNot Nothing AndAlso oListareferti.Count > 0 Then
                        Me.IdPaziente = New Guid(oListareferti(0).IdPaziente)
                    End If
                End If
                '
                ' Imposto i parametri per la mmatrice delle prestazioni
                '
                DataSourcePrestazioniMatrice.TypeName = "DwhClinico.Web.CustomDataSource.AccessoDirettoMatricePrestazioniLabCercaPerIdPaziente"
                DataSourcePrestazioniMatrice.SelectMethod = "GetData"
                DataSourcePrestazioniMatrice.SelectParameters.Add("IdPaziente", Me.IdPaziente.ToString)

            ElseIf Not String.IsNullOrEmpty(sAziendaErogante) AndAlso Not String.IsNullOrEmpty(sNumeroNosologico) Then
                '--------------------------------------------------------
                ' Ricerca per AziendaErogante, NumeroNosologico
                '--------------------------------------------------------
                tabLnkReferti.Visible = True
                tabLnkRisultatoMatrice.Visible = True
                '
                ' Cancello la cache
                '
                Dim oDs As New CustomDataSource.AccessoDirettoRefertiCercaPerNosologico2
                oDs.ClearCache(sNumeroNosologico, sAziendaErogante)
                '
                ' Imposto i parametri di filtro (i parametri mancanti, che sono quelli condivisi, vengono valorizzati nell'evento "Selecting")
                '
                DataSourceMain.TypeName = "DwhClinico.Web.CustomDataSource.AccessoDirettoRefertiCercaPerNosologico2"
                DataSourceMain.SelectMethod = "GetData"
                DataSourceMain.SelectParameters.Add("NumeroNosologico", sNumeroNosologico)
                DataSourceMain.SelectParameters.Add("AziendaErogante", sAziendaErogante)
                '
                ' Forzo il bind della griglia associata alla DataSourceMain, cosi si scatena l'evento "Selected" e se si trovano record si popola Me.IdPaziente
                '
                divWebGridReferti.DataBind()
                '
                ' Se non si sono ottenuti dei record rieseguo query per trovare IdPaziente
                '
                If Me.IdPaziente = Nothing Then
                    oDs.ClearCache(sNumeroNosologico, sAziendaErogante)
                    '
                    ' Imposto ByPassaConsesno=True per essere sicuro che se il Azienda e Nosologico sono corretti vengano restituiti record
                    '
                    Dim oListareferti As List(Of WcfDwhClinico.RefertoListaType) = oDs.GetData(Me.Token, "", True, sNumeroNosologico, sAziendaErogante, #1/1/1900#, Nothing, Nothing)
                    If oListareferti IsNot Nothing AndAlso oListareferti.Count > 0 Then
                        Me.IdPaziente = New Guid(oListareferti(0).IdPaziente)
                    End If
                End If
                '
                ' Imposto i parametri per la matrice delle prestazioni
                '
                DataSourcePrestazioniMatrice.TypeName = "DwhClinico.Web.CustomDataSource.AccessoDirettoMatricePrestazioniLabCercaPerIdPaziente"
                DataSourcePrestazioniMatrice.SelectMethod = "GetData"
                DataSourcePrestazioniMatrice.SelectParameters.Add("IdPaziente", Me.IdPaziente.ToString)

            ElseIf Not String.IsNullOrEmpty(sIdPaziente) Then
                '--------------------------------------------------------
                ' Ricerca per IdPaziente
                '--------------------------------------------------------
                tabLnkReferti.Visible = True
                '
                ' Mostro la tab del Calendario solo se è abilitata dal setting ShowCalendarioTab.
                '
                tabLnkCalendario.Visible = My.Settings.ShowCalendarioTab
                tabLnkRefertiEpisodi.Visible = True
                tabLnkRisultatoMatrice.Visible = True
                tabLnkPrescrizioni.Visible = True
                tabLnkSchedePaziente.Visible = True
                tabLnkNoteAnamnestiche.Visible = True

                '
                ' Valorizzo la property Me.IdPaziente 
                '
                Me.IdPaziente = New Guid(sIdPaziente)

                DataSourceMain.TypeName = "DwhClinico.Web.CustomDataSource.AccessoDirettoRefertiCercaPerIdPaziente"
                DataSourceMain.SelectMethod = "GetData"
                DataSourceMain.SelectParameters.Add("IdPaziente", Me.IdPaziente.ToString)

                DataSourcePrescrizioni.TypeName = "DwhClinico.Web.CustomDataSource.AccessoDirettoPrescrizioniCercaPerIdPaziente"
                DataSourcePrescrizioni.SelectMethod = "GetData"
                DataSourcePrescrizioni.SelectParameters.Add("IdPaziente", Me.IdPaziente.ToString)

                DataSourceEpisodi.TypeName = "DwhClinico.Web.CustomDataSource.AccessoDirettoEpisodiCercaPerIdPaziente"
                DataSourceEpisodi.SelectMethod = "GetData"
                DataSourceEpisodi.SelectParameters.Add("IdPaziente", Me.IdPaziente.ToString)

                DataSourcePrestazioniMatrice.TypeName = "DwhClinico.Web.CustomDataSource.AccessoDirettoMatricePrestazioniLabCercaPerIdPaziente"
                DataSourcePrestazioniMatrice.SelectMethod = "GetData"
                DataSourcePrestazioniMatrice.SelectParameters.Add("IdPaziente", Me.IdPaziente.ToString)

                DataSourceRefertiSingoli.TypeName = "DwhClinico.Web.CustomDataSource.AccessoDirettoRefertiCercaRefertiSingoli"
                DataSourceRefertiSingoli.SelectMethod = "GetData"
                DataSourceRefertiSingoli.SelectParameters.Add("IdPaziente", Me.IdPaziente.ToString)

                DataSourceNoteAnamnestiche.TypeName = "DwhClinico.Web.CustomDataSource.AccessoDirettoNoteAnamnesticheCercaPerIdPaziente"
                DataSourceNoteAnamnestiche.SelectMethod = "GetData"
                DataSourceNoteAnamnestiche.SelectParameters.Add("IdPaziente", Me.IdPaziente.ToString)

            ElseIf Not String.IsNullOrEmpty(sIdPazienteEsterno) AndAlso Not String.IsNullOrEmpty(sNumeroReferto) Then

                tabLnkReferti.Visible = True
                tabLnkRisultatoMatrice.Visible = True
                '
                ' IdPazienteEsterno deve essere nella forma SAC_IdPaziente
                ' Una volta trovato l'idPaziente dall'IdPazienteEsterno mi comporto come la ricerca per IdPaziente
                '
                Dim oIdPaziente As Guid = Nothing
                Dim sIdPaziente1 As String = sIdPazienteEsterno.Substring(4)
                If Guid.TryParse(sIdPaziente1, oIdPaziente) Then
                    Me.IdPaziente = oIdPaziente
                End If

                DataSourceMain.TypeName = "DwhClinico.Web.CustomDataSource.AccessoDirettoRefertiCercaPerNumeroReferto"
                DataSourceMain.SelectMethod = "GetData"
                DataSourceMain.SelectParameters.Add("IdPaziente", Me.IdPaziente.ToString)
                DataSourceMain.SelectParameters.Add("NumeroReferto", sNumeroReferto)

                DataSourcePrestazioniMatrice.TypeName = "DwhClinico.Web.CustomDataSource.AccessoDirettoMatricePrestazioniLabCercaPerIdPaziente"
                DataSourcePrestazioniMatrice.SelectMethod = "GetData"
                DataSourcePrestazioniMatrice.SelectParameters.Add("IdPaziente", Me.IdPaziente.ToString)

            ElseIf Not String.IsNullOrEmpty(sIdPazienteEsterno) Then
                '
                ' Mail di foracchia del 10/06/2016: questa ricerca non serve più
                ' In questo caso segnalo errore
                '
                divErrorMessage.Visible = True
                mbValidationCancelSelect = True
                ucTestataPaziente.mbValidationCancelSelect = True
                lblErrorMessage.Text = String.Format("La ricerca per {0} non è valida.", PAR_ID_ESTERNO)
                NascondoPagina()
                '
                ' Esco dal Page_Load()
                '
                Exit Sub

            ElseIf Not String.IsNullOrEmpty(sNomeAnagrafica) AndAlso Not String.IsNullOrEmpty(sIdAnagrafica) Then
                '
                ' In questo caso rendo visibili tutti i tab
                '
                tabLnkReferti.Visible = True
                '
                ' Mostro la tab del Calendario solo se è abilitata dal setting ShowCalendarioTab.
                '
                tabLnkCalendario.Visible = My.Settings.ShowCalendarioTab
                tabLnkRefertiEpisodi.Visible = True
                tabLnkRisultatoMatrice.Visible = True
                tabLnkPrescrizioni.Visible = True
                tabLnkSchedePaziente.Visible = True
                tabLnkNoteAnamnestiche.Visible = True
                '
                ' Da Anagrafica, IdAnagrafica ottengo l'IdPaziente tramite il metodo PazienteOttieniPerAnagrafica del WS
                '
                Dim dsAccessoDirettoPazienteOttieniPerAnagrafica As New CustomDataSource.AccessoDirettoPazienteOttieniPerAnagrafica()
                Dim oPaziente As WcfDwhClinico.PazienteType = dsAccessoDirettoPazienteOttieniPerAnagrafica.GetData(Me.Token, sIdAnagrafica, sNomeAnagrafica)
                If oPaziente IsNot Nothing Then
                    Dim oIdPaziente As Guid = Nothing
                    If Guid.TryParse(oPaziente.Id, oIdPaziente) Then
                        Me.IdPaziente = oIdPaziente
                    End If
                End If

                DataSourceMain.TypeName = "DwhClinico.Web.CustomDataSource.AccessoDirettoRefertiCercaPerIdPaziente"
                DataSourceMain.SelectMethod = "GetData"
                DataSourceMain.SelectParameters.Add("IdPaziente", Me.IdPaziente.ToString)

                DataSourcePrescrizioni.TypeName = "DwhClinico.Web.CustomDataSource.AccessoDirettoPrescrizioniCercaPerIdPaziente"
                DataSourcePrescrizioni.SelectMethod = "GetData"
                DataSourcePrescrizioni.SelectParameters.Add("IdPaziente", Me.IdPaziente.ToString)

                DataSourceEpisodi.TypeName = "DwhClinico.Web.CustomDataSource.AccessoDirettoEpisodiCercaPerIdPaziente"
                DataSourceEpisodi.SelectMethod = "GetData"
                DataSourceEpisodi.SelectParameters.Add("IdPaziente", Me.IdPaziente.ToString)

                DataSourcePrestazioniMatrice.TypeName = "DwhClinico.Web.CustomDataSource.AccessoDirettoMatricePrestazioniLabCercaPerIdPaziente"
                DataSourcePrestazioniMatrice.SelectMethod = "GetData"
                DataSourcePrestazioniMatrice.SelectParameters.Add("IdPaziente", Me.IdPaziente.ToString)

                DataSourceRefertiSingoli.TypeName = "DwhClinico.Web.CustomDataSource.AccessoDirettoRefertiCercaRefertiSingoli"
                DataSourceRefertiSingoli.SelectMethod = "GetData"
                DataSourceRefertiSingoli.SelectParameters.Add("IdPaziente", Me.IdPaziente.ToString)

                DataSourceNoteAnamnestiche.TypeName = "DwhClinico.Web.CustomDataSource.AccessoDirettoNoteAnamnesticheCercaPerIdPaziente"
                DataSourceNoteAnamnestiche.SelectMethod = "GetData"
                DataSourceNoteAnamnestiche.SelectParameters.Add("IdPaziente", Me.IdPaziente.ToString)

            Else
                '
                ' Se sono qui la combinazione dei parametri dell'url è errata.
                '
                Throw New ApplicationException("La combinazione dei parametri non è valida.")
                Exit Sub
            End If

            '
            'Nascondo o mostro la tab delle Note Anamnestiche in base alla setting ShowNoteAnamnesticheTab.
            '
            tabLnkNoteAnamnestiche.Visible = My.Settings.ShowNoteAnamnesticheTab

            TableReportContainer.Visible = True
            If Me.IdPaziente = Nothing Then
                Throw New ApplicationException("Impossibile ricavare il dettaglio del paziente!")
                Exit Sub
            End If

            If Not Page.IsPostBack AndAlso Utility.AccessoDiretto_IsPageEntryPoint() Then
                '
                ' Funziona correttamente anche se usiamo come EntryPoint la pagina ricoveri.aspx (dove viene eseguito un response.redirect a questa pagina)
                ' Se eseguiamo un response.redirect allora HttpContext.Current.Request.UrlReferrer è nothing e quindi questa pagina risulta essere EntryPoint
                '
                SessionHandler.InvalidaCacheTestataPaziente(Me.IdPaziente)
            End If

            '
            ' Impostazioni per la visualizzazione del Pannello Paziente: valorizzo l'url al dettaglio dei consensi
            '
            ucTestataPaziente.UrlDettaglioConsensi = String.Format("~/AccessoDiretto/GestioneConsensi.aspx?IdPaziente={0}", Me.IdPaziente)
            ucTestataPaziente.IdPaziente = Me.IdPaziente
            ucTestataPaziente.Token = Me.Token
            ucTestataPaziente.MostraSoloDatiAnagrafici = False
            ucTestataPaziente.CodiceRuolo = Me.CodiceRuolo
            ucTestataPaziente.DescrizioneRuolo = Me.DescrizioneRuolo

            Me.CodiceFiscalePaziente = ucTestataPaziente.CodiceFiscale.ToString

            'ottengo il consenso del paziente.
            'necessario per il tracciamento degli accessi.
            Me.ConsensoPaziente = ucTestataPaziente.UltimoConsensoAziendaleEspresso

            If Not Page.IsPostBack Then
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
                End If

                '
                ' Ricarico i valori di filtro dalla sessione
                '
                Call LoadFilterValues()

                '
                '2020-07-15 Kyrylo: Traccia Operazioni
                '
                Dim oTracciaOp As New TracciaOperazioniManager(Utility.GetAppSettings(Utility.PAR_DI_PORTAL_USER_CONNECTION_STRING, ""))
                oTracciaOp.TracciaOperazione(PortalsNames.DwhClinico, Page.AppRelativeVirtualPath, "Visualizzata lista referti", IdPaziente, Nothing)

            End If


            If SessionHandler.AccessoDirettoCancellaCache Then
                Cerca()
                SessionHandler.AccessoDirettoCancellaCache = False
            End If

            'Abilitazione del pulsante dell'FSE
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

            'Abilito o disabilito il pulsante del patient summary
            AbilitaPatienSummary()

            '
            'Imposto gli stili bootstrap per le griglie.
            '
            SetGridViewBootstrapStyle()

            'Modifica Leo 2019/12/10: Nascondere Pannello Paziente se specificato nell'url
            Me.ShowPannelloPaziente = Request.QueryString("ShowPannelloPaziente")
            ucTestataPaziente.Visible = Utility.AccessoDirettoPannelloPazientVisibility(Request.QueryString)

            ' Modifica KYRY: Aggiunto il tab calendario
            ' Se presente carico il calendario dalla sessione
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
            ' Invalido la select degli ObjectDataSource nella testata del paziente.
            '
            ucTestataPaziente.mbValidationCancelSelect = True
            mbValidationCancelSelect = True
            divErrorMessage.Visible = True
            lblErrorMessage.Text = ex.Message
            NascondoPagina()
            Logging.WriteError(ex, Me.GetType.Name)
        Catch ex As Exception
            '
            ' Invalido la select degli ObjectDataSource nella testata del paziente.
            '
            ucTestataPaziente.mbValidationCancelSelect = True
            mbValidationCancelSelect = True
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante il caricamento della pagina!"
            NascondoPagina()
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

    ''' <summary>
    ''' Abilita o disabilita il pulsante del patient summary.
    ''' </summary>
    Private Sub AbilitaPatienSummary()
        'Abilitazione del pulsante del patient summary
        If Not Page.IsPostBack Then
            'Valorizzo gli hidden field necessari per l'abilitazione del patient summary.
            'Vengono poi utilizzati nella funzione "EnableButtonPatientSummary" lato Javascript.
            Dim oCurrentUser As CurrentUser = Utility.GetCurrentUser()
            Dim oDettaglioUtente As DettaglioUtente = Utility.GetDettaglioUtente(oCurrentUser.DomainName, oCurrentUser.UserName)
            hiddenRichiedenteCodiceFiscale.Value = oDettaglioUtente.CodiceFiscale 'codice fiscale dell'utente corrente.
            hiddenRichiedenteCognome.Value = oDettaglioUtente.Cognome 'cognome dell'utente corrente.
            hiddenRichiedenteNome.Value = oDettaglioUtente.Nome

            'Valorizzo il Codice Fiscale dell'utente corrente.
            'Viene usato per l'acquisizione del consenso FSE
            Me.CodiceFiscaleRichiedente = oDettaglioUtente.CodiceFiscale

            'Informazioni sul PAZIENTE.
            hiddenPazienteCodiceFiscale.Value = Me.CodiceFiscalePaziente
            hiddenIdPaziente.Value = Me.IdPaziente.ToString

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
        Else
            hiddenCallEnableButtonPatientSummary.Value = "TRUE"
        End If
    End Sub

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
                    If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
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

            If oRisposta IsNot Nothing Then
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
    ''' Funzione per comporre lo scrip JAVASCRIPT per aprire il PDF in una nuova finestra
    ''' </summary>
    ''' <param name="oIdPaziente"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Private Function ScriptOpenPatientSummaryWindow(ByVal oIdPaziente As Guid) As String
        '
        ' Apro finestre con nome costante - occhio alla "\" sto passando la stringa a codice Java
        '
        Dim sUrl As String = Me.ResolveUrl("~/AccessoDiretto/PatientSummary.aspx") & String.Format("?{0}={1}", PAR_ID_PAZIENTE, oIdPaziente)
        Dim sWindowName As String = "PatientSummary" 'NON DEVE CONTENERE SPAZI
        Dim sOpenWindowCode As String = Utility.JSOpenWindowCode(sUrl, sWindowName, True, False, False, False, False, False, True, True, 500, 500)
        Return Utility.JSBuildScript(sOpenWindowCode)
    End Function

    Private Sub NascondoPagina()
        divPage.Visible = False
        CType(Master.FindControl("divMenu2"), HtmlGenericControl).Visible = False
    End Sub

    Protected Sub cmdCerca_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdCerca.Click
        Cerca()
    End Sub

    Private Sub Cerca()
        Try
            '
            ' Invalido la cache degli ObjectDataSource
            '
            DataSource_InvalidaCache()

            '
            ' Cancello dalla sessione la lista dei TipiReferto collegata alla lista dei referti
            '
            Me.Session(String.Format("{0}_{1}", KEY_AD_REFERTI_LISTA_TIPIREFERTO, Me.IdPaziente.ToString)) = Nothing
            Me.Session(String.Format("{0}_{1}", KEY_AD_PRESCRIZIONI_LISTA_TIPIREFERTO, Me.IdPaziente.ToString)) = Nothing
            Me.Session(String.Format("{0}_{1}", KEY_AD_REFERTI_PER_EPISODI_LISTA_TIPIREFERTO, Me.IdPaziente.ToString)) = Nothing

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
            ' Se i filtri sono validi eseguo il della tabella visualizzata
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
                    WebGridRefertiSingoli.DataBind()

                ElseIf MultiViewMain.GetActiveView Is ViewNoteAnamnestiche Then
                    '
                    'DATABIND DELLE NOTE
                    '
                End If
            Else
                divErrorMessage.Visible = True
                lblErrorMessage.Text = "Verificare i valori di filtro!"
            End If

            '
            ' Valorizzo la label per la data contenuta nei tab 
            '
            lblDataFiltri.Text = txtDataDal.Text

            '
            ' Salvo i filtri selezionati in sessione
            '
            SaveFilterValues()
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

    Private Sub SetOldPageIndex()
        Try
            Dim oCurrentPageIndex As Object
            oCurrentPageIndex = Me.Session(mstrPageID & WebGridReferti.ID)
            If oCurrentPageIndex IsNot Nothing Then WebGridReferti.PageIndex = CType(oCurrentPageIndex, Integer)
            oCurrentPageIndex = Me.Session(mstrPageID & WebGridPrescrizioni.ID)
            If oCurrentPageIndex IsNot Nothing Then WebGridPrescrizioni.PageIndex = CType(oCurrentPageIndex, Integer)
        Catch
        End Try
    End Sub

#Region "Filtri"
    Private Sub cmbFiltroTemporale_SelectedIndexChanged(sender As Object, e As EventArgs) Handles cmbFiltroTemporale.SelectedIndexChanged
        Try
            GetDataDal()
            Cerca()
        Catch ex As Exception
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante la selezione della data."
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

    Private Sub GetDataDal()
        Try
            '
            ' Imposto la data del filtro temporale in base all'item selezionato nella combo
            '
            Select Case cmbFiltroTemporale.SelectedValue
                Case -1
                    ''Se l'item selezionato è -1(item vuoto) allora non faccio nulla.
                Case 0
                    txtDataDal.Text = Now.AddDays(-7).ToString("dd/MM/yyyy")
                Case 1
                    txtDataDal.Text = Now.AddMonths(-1).ToString("dd/MM/yyyy")
                Case 2
                    txtDataDal.Text = Now.AddYears(-1).ToString("dd/MM/yyyy")
                Case 3
                    txtDataDal.Text = Now.AddYears(-5).ToString("dd/MM/yyyy")
            End Select

            '
            ' Cancello il contenuto della textbox txtAllaData quando seleziono un item dalla drop cmbFiltriTemporale
            '
            txtAllaData.Text = Nothing
        Catch ex As Exception
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'operazione di lettura DataDal."
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

    Private Sub SaveFilterValues()
        Dim sIdPaziente As String = IdPaziente.ToString.ToUpper
        Me.Session(mstrPageID & txtDataDal.ID & sIdPaziente) = txtDataDal.Text
        Me.Session(mstrPageID & txtAllaData.ID & sIdPaziente) = txtAllaData.Text

        'Salvo in sessione il valore della combo cmbFiltroTemporale.
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

#Region "DataSourceMain"
    Protected Sub DataSourceMain_Selected(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles DataSourceMain.Selected
        Try
            divWebGridReferti.Visible = False
            divErrorMessage.Visible = False
            divMessageReferti.Visible = False

            'Visualizzo il pulsante per filtrare e la checkboxlist solo se la griglia non è vuota
            FiltriCheckBoxList.Visible = True

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
                    Dim bPagerStyleVisible As Boolean = True
                    divWebGridReferti.Visible = True
                    '
                    ' A questo punto ricavo l'IdPaziente da passare al Pannello paziente
                    ' Lo valorizzo solo se non è già valorizzato
                    '
                    If Me.IdPaziente = Nothing Then
                        Me.IdPaziente = New Guid(result(0).IdPaziente)
                    End If
                Else
                    divMessageReferti.Visible = True
                    divMessageReferti.InnerText = "Non è stato trovato nessun referto. Modificare eventualmente i parametri di filtro."
                    divWebGridReferti.Visible = False
                    FiltriCheckBoxList.Visible = False
                End If
            End If
        Catch ex As Exception
            '
            ' Errore
            '
            Logging.WriteError(ex, Me.GetType.Name)
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati!"
        End Try
    End Sub

    Protected Sub DataSourceMain_Selecting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.ObjectDataSourceSelectingEventArgs) Handles DataSourceMain.Selecting
        Try
            Dim lstFiltriTipiReferto As New List(Of String)

            If mbValidationCancelSelect Or Not tabLnkReferti.Visible Then
                e.Cancel = True
                Exit Sub
            End If

            ' MOMENTANEAMENTO NON USATO PERCHE' GLI HEADER DELLE GRIGLIE NON SONO VISIBILI
            ' ORDINAMENTO
            'If Me.GridViewSortExpression.Length > 0 Then
            '    Dim sDir = If(Me.GridViewSortDirection = WebControls.SortDirection.Ascending, "@ASC", "@DESC")
            '    e.InputParameters("Ordinamento") = Me.GridViewSortExpression & sDir
            'Else
            '    e.InputParameters("Ordinamento") = Nothing

            'End If
            e.InputParameters("Ordinamento") = Nothing
            e.InputParameters("ByPassaConsenso") = Utility.GetSessionForzaturaConsenso(Me.IdPaziente)
            e.InputParameters("DallaData") = CType(txtDataDal.Text, Date)
            If Not String.IsNullOrEmpty(txtAllaData.Text) Then
                e.InputParameters("AllaData") = CType(txtAllaData.Text, Date)
            Else
                e.InputParameters("AllaData") = Nothing
            End If
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
            '
            'Mostro la matrice e il pulsante
            '
            XmlRisultatoMatrice.Visible = True
            btnCollapseMatrice.Visible = True

            '
            'Nascondo i messaggi di errore.
            '
            divErrorMessage.Visible = False
            divMessageMatrice.Visible = False

            'Ottengo il messaggio di errore.
            Dim messaggioErrore = HelperDataSourceException.GetObjectDataSourceExceptionMessage(e.Exception)

            'Testo se il messaggio di errore è vuoto. Se è valorizzato allora mostro il div d'errore.
            If Not String.IsNullOrEmpty(messaggioErrore) Then
                divErrorMessage.Visible = True
                lblErrorMessage.Text = messaggioErrore
                e.ExceptionHandled = True
            Else
                Dim oDt As WcfDwhClinico.MatricePrestazioniListaType = CType(e.ReturnValue, WcfDwhClinico.MatricePrestazioniListaType)
                If oDt IsNot Nothing AndAlso oDt.Count > 0 Then
                    '
                    ' Trasformo la lista delle matrici in un xml 
                    '
                    Dim strXml As String = String.Empty
                    Dim xmlSerializer As New System.Xml.Serialization.XmlSerializer(oDt.GetType)
                    Using memoryStream As New IO.MemoryStream
                        xmlSerializer.Serialize(memoryStream, oDt)
                        memoryStream.Position = 0
                        strXml = New IO.StreamReader(memoryStream).ReadToEnd
                    End Using
                    XmlRisultatoMatrice.DocumentContent = strXml
                    XmlRisultatoMatrice.DataBind()
                Else
                    '
                    'Nascondo la matrice e il pulsante
                    '
                    XmlRisultatoMatrice.Visible = False
                    btnCollapseMatrice.Visible = False


                    divMessageMatrice.Visible = True
                    divMessageMatrice.InnerText = "Non è stato trovata nessuna matrice. Modificare eventualmente i parametri di filtro."
                End If
            End If
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
            If mbValidationCancelSelect Or Not tabLnkRisultatoMatrice.Visible Then
                e.Cancel = True
                Exit Sub
            End If
            e.InputParameters("Ordinamento") = Nothing
            e.InputParameters("ByPassaConsenso") = Utility.GetSessionForzaturaConsenso(Me.IdPaziente)
            e.InputParameters("DallaData") = CType(txtDataDal.Text, Date)
            If Not String.IsNullOrEmpty(txtAllaData.Text) Then
                e.InputParameters("AllaData") = CType(txtAllaData.Text, Date)
            Else
                e.InputParameters("AllaData") = Nothing
            End If
            e.InputParameters("PrestazioneCodice") = Nothing
            e.InputParameters("SezioneCodice") = Nothing
            e.InputParameters("Token") = Me.Token()
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
            divErrorMessage.Visible = False
            divMessagePrescrizioni.Visible = False

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
                    Dim bPagerStyleVisible As Boolean = True
                    divWebGridPrescrizione.Visible = True
                Else
                    Dim sMsgNoRecord As String = "Non è stato trovata nessuna prescrizione. Modificare eventualmente i parametri di filtro."
                    divMessagePrescrizioni.Visible = True
                    divMessagePrescrizioni.InnerText = sMsgNoRecord
                    divWebGridPrescrizione.Visible = False
                    FiltriCheckBoxList.Visible = False
                End If
            End If
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

            If mbValidationCancelSelect Or Not tabLnkPrescrizioni.Visible Then
                e.Cancel = True
                Exit Sub
            End If

            e.InputParameters("Ordinamento") = Nothing
            e.InputParameters("ByPassaConsenso") = Utility.GetSessionForzaturaConsenso(Me.IdPaziente)
            e.InputParameters("IdPaziente") = IdPaziente
            e.InputParameters("DallaData") = CType(txtDataDal.Text, Date)
            If Not String.IsNullOrEmpty(txtAllaData.Text) Then
                e.InputParameters("AllaData") = CType(txtAllaData.Text, Date)
            Else
                e.InputParameters("AllaData") = Nothing
            End If
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
        Catch ex As Exception
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati!"
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

#End Region

#Region "DataSourceRefertiSingoli"
    Private Sub DataSourceRefertiSingoli_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles DataSourceRefertiSingoli.Selecting
        Try
            If mbValidationCancelSelect Or Not tabLnkSchedePaziente.Visible Then
                e.Cancel = True
                Exit Sub
            End If

            ' MOMENTANEAMENTO NON USATO PERCHE' GLI HEADER DELLE GRIGLIE NON SONO VISIBILI
            ' ORDINAMENTO
            'If Me.GridViewSortExpression.Length > 0 Then
            '    Dim sDir = If(Me.GridViewSortDirection = WebControls.SortDirection.Ascending, "@ASC", "@DESC")
            '    e.InputParameters("Ordinamento") = Me.GridViewSortExpression & sDir
            'Else
            '    e.InputParameters("Ordinamento") = Nothing
            'End If
            e.InputParameters("Ordinamento") = Nothing
            e.InputParameters("ByPassaConsenso") = Utility.GetSessionForzaturaConsenso(Me.IdPaziente)
            e.InputParameters("DallaData") = CType(txtDataDal.Text, Date)
            If Not String.IsNullOrEmpty(txtAllaData.Text) Then
                e.InputParameters("AllaData") = CType(txtAllaData.Text, Date)
            Else
                e.InputParameters("AllaData") = Nothing
            End If
            e.InputParameters("Token") = Me.Token()
        Catch ex As Exception
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati!"
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

    Private Sub DataSourceRefertiSingoli_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles DataSourceRefertiSingoli.Selected
        Try
            divWebGridRefertiSingoli.Visible = False
            divErrorMessage.Visible = False
            divMessageEventiSingoli.Visible = False
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
                    Dim bPagerStyleVisible As Boolean = True
                    divWebGridRefertiSingoli.Visible = True
                Else
                    divMessageEventiSingoli.Visible = True
                    divMessageEventiSingoli.InnerText = "Non è stato trovato nessun referto. Modificare eventualmente i parametri di filtro."
                    divWebGridRefertiSingoli.Visible = False
                End If
            End If
        Catch ex As Exception
            '
            ' Errore
            '
            Logging.WriteError(ex, Me.GetType.Name)
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati!"
        End Try
    End Sub

    'Protected Sub DataSourceRefertiPerNosologico_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs)
    '    '
    '    ' I parametri Nosologico e AziendaErogante vengono valorizzati nell'evento RowDataBound della griglia WebGridEpisodi
    '    '
    '    e.InputParameters("Token") = Me.Token
    '    e.InputParameters("ByPassaConsenso") = Utility.GetSessionForzaturaConsenso(Me.IdPaziente)
    'End Sub
#End Region

#Region "DataSourceEpisodi"
    Private Sub DataSourceEpisodi_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles DataSourceEpisodi.Selecting
        Try
            If mbValidationCancelSelect Or Not tabLnkRefertiEpisodi.Visible Then
                e.Cancel = True
                Exit Sub
            End If

            ' MOMENTANEAMENTO NON USATO PERCHE' GLI HEADER DELLE GRIGLIE NON SONO VISIBILI
            ' ORDINAMENTO
            'If Me.GridViewSortExpression.Length > 0 Then
            '    Dim sDir = If(Me.GridViewSortDirection = WebControls.SortDirection.Ascending, "@ASC", "@DESC")
            '    e.InputParameters("Ordinamento") = Me.GridViewSortExpression & sDir
            'Else
            '    e.InputParameters("Ordinamento") = Nothing
            'End If

            e.InputParameters("Ordinamento") = Nothing
            e.InputParameters("ByPassaConsenso") = Utility.GetSessionForzaturaConsenso(Me.IdPaziente)
            e.InputParameters("DallaData") = CType(txtDataDal.Text, Date)
            If Not String.IsNullOrEmpty(txtAllaData.Text) Then
                e.InputParameters("AllaData") = CType(txtAllaData.Text, Date)
            Else
                e.InputParameters("AllaData") = Nothing
            End If
            e.InputParameters("Token") = Me.Token()
        Catch ex As Exception
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati!"
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

    Private Sub DataSourceEpisodi_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles DataSourceEpisodi.Selected
        Try
            divWebGridRefertiEpisodi.Visible = False
            divErrorMessage.Visible = False
            divMessageEpisodi.Visible = False

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
                    Dim bPagerStyleVisible As Boolean = True
                    divWebGridRefertiEpisodi.Visible = True
                    FiltriCheckBoxList.Visible = True
                Else
                    divMessageEpisodi.Visible = True
                    divMessageEpisodi.InnerText = "Non è stato trovato nessun episodio. Modificare eventualmente i parametri di filtro."
                    divWebGridRefertiEpisodi.Visible = False
                    FiltriCheckBoxList.Visible = False
                End If
            End If
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
        Catch ex As Exception
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati!"
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

    Private Sub DataSourceEventiEpisodio_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles DataSourceEventiEpisodio.Selected
        Try
            WebGridEventiEpisodio.Visible = False
            divErrorMessage.Visible = False
            'divMessage.Visible = False

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
                If result IsNot Nothing AndAlso result.Count > 0 Then
                    Dim bPagerStyleVisible As Boolean = True
                    WebGridEventiEpisodio.Visible = True
                Else
                    Dim sMsgNoRecord As String = "Non è stato trovato nessun referto. Modificare eventualmente i parametri di filtro."
                    'divMessage.Visible = True
                    'divMessage.InnerText = sMsgNoRecord
                    WebGridEventiEpisodio.Visible = False
                End If
            End If
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
            'Nel page.load imposto tabLnkNoteAnamnestiche.Visible = my.setting.showNoteAnamnesticheTab
            '   quindi mi basta controllare la visibilità della tab.
            '
            If mbValidationCancelSelect OrElse Not tabLnkNoteAnamnestiche.Visible Then
                e.Cancel = True
                Exit Sub
            End If

            e.InputParameters("Ordinamento") = Nothing
            e.InputParameters("ByPassaConsenso") = Utility.GetSessionForzaturaConsenso(Me.IdPaziente)
            e.InputParameters("IdPaziente") = Me.IdPaziente
            e.InputParameters("DallaData") = CType(txtDataDal.Text, Date)
            If Not String.IsNullOrEmpty(txtAllaData.Text) Then
                e.InputParameters("AllaData") = CType(txtAllaData.Text, Date)
            Else
                e.InputParameters("AllaData") = Nothing
            End If

            e.InputParameters("Token") = Me.Token
        Catch ex As Exception
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati!"
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

    Private Sub DataSourceNoteAnamnestiche_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles DataSourceNoteAnamnestiche.Selected
        Try
            divWebGridNoteAnamnestiche.Visible = False
            divErrorMessage.Visible = False
            divMessageNoteAnamnestiche.Visible = False

            'Ottengo il messaggio di errore.
            Dim messaggioErrore = HelperDataSourceException.GetObjectDataSourceExceptionMessage(e.Exception)

            'Testo se il messaggio di errore è vuoto. Se è valorizzato allora mostro il div d'errore.
            If Not String.IsNullOrEmpty(messaggioErrore) Then
                divErrorMessage.Visible = True
                lblErrorMessage.Text = messaggioErrore
                e.ExceptionHandled = True
            Else
                Dim result As WcfDwhClinico.NoteAnamnesticheListaType = CType(e.ReturnValue, WcfDwhClinico.NoteAnamnesticheListaType)

                If result IsNot Nothing AndAlso result.Count > 0 Then
                    Dim bPagerStyleVisible As Boolean = True
                    divWebGridNoteAnamnestiche.Visible = True
                Else
                    divMessageNoteAnamnestiche.Visible = True
                    divMessageNoteAnamnestiche.InnerText = "Non è stato trovata nessuna prescrizione. Modificare eventualmente i parametri di filtro."
                    divWebGridNoteAnamnestiche.Visible = False
                End If
            End If
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

    ''' <summary>
    ''' Inavlida la cache di tutti gli objectDataSource coinvolti
    ''' </summary>
    Private Sub DataSource_InvalidaCache()
        '
        ' Invalido la cache della datasource 
        ' La cache è stata implementata solo per la lista dei referti e prescrizioni solo perchè serve per i filtri laterali
        '
        If MultiViewMain.GetActiveView Is ViewPrescrizioni Then
            Dim dsPrescrizioni As New CustomDataSource.AccessoDirettoPrescrizioniCercaPerIdPaziente()
            dsPrescrizioni.ClearCache()

        ElseIf MultiViewMain.GetActiveView Is ViewCalendario Then
            Dim dsRefertiCalendario As New CalendarDataSource()
            Dim dsEpisodiCalendario As New CalendarDataSource.EpisodiCercaPerIdPaziente()
            dsRefertiCalendario.ClearCache(Me.IdPaziente)
            dsEpisodiCalendario.ClearCache(Me.IdPaziente)

        ElseIf MultiViewMain.GetActiveView Is ViewReferti Then
            Dim dsReferti As New CustomDataSource.AccessoDirettoRefertiCercaPerIdPaziente()
            dsReferti.ClearCache(Me.IdPaziente)

        ElseIf MultiViewMain.GetActiveView Is ViewRefertiEpisodi Then
            Dim dsEpisodiReferti As New CustomDataSource.AccessoDirettoEpisodiCercaPerIdPaziente
            dsEpisodiReferti.ClearCache(Me.IdPaziente)
            InvalidaCacheRefertiPerNosologico = True
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
            divErrorMessage.Visible = False

            '
            ' nascondo il pulsante per filtrare la checkboxlist
            '
            'Ottengo il messaggio di errore.
            Dim messaggioErrore = HelperDataSourceException.GetObjectDataSourceExceptionMessage(e.Exception)

            'Testo se il messaggio di errore è vuoto. Se è valorizzato allora mostro il div d'errore.
            If Not String.IsNullOrEmpty(messaggioErrore) Then
                divErrorMessage.Visible = True
                lblErrorMessage.Text = messaggioErrore
                e.ExceptionHandled = True
            Else
                Dim Referti As List(Of WcfDwhClinico.RefertoListaType) = CType(e.ReturnValue, List(Of WcfDwhClinico.RefertoListaType))
                If Referti IsNot Nothing AndAlso Referti.Count > 0 Then
                    Dim bPagerStyleVisible As Boolean = True

                    '
                    ' listaReferti è una variabile di modulo che contiene tutti i referti contenuti negli episodi
                    ' Viene usata per popolare la lista dei tipi referto usati dalla checkbox list per filtrare la gir WebGridRefertiEpisodi
                    '
                    listaReferti.AddRange(Referti)
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

#Region "EventiGridView"

#Region "Eventi WebGridReferti"
    Private Sub WebGridReferti_PreRender(sender As Object, e As EventArgs) Handles WebGridReferti.PreRender
        '
        'Render per Bootstrap
        'Crea la Table con Theader e Tbody se l'header non è nothing.
        '
        If WebGridReferti.HeaderRow IsNot Nothing Then
            WebGridReferti.UseAccessibleHeader = True
            WebGridReferti.HeaderRow.TableSection = TableRowSection.TableHeader
        End If
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
        If WebGridPrescrizioni.HeaderRow IsNot Nothing Then
            WebGridPrescrizioni.UseAccessibleHeader = True
            WebGridPrescrizioni.HeaderRow.TableSection = TableRowSection.TableHeader
        End If
    End Sub

    'MOMENTANEAMENTO NON USATO PERCHE' GLI HEADER DELLE GRIGLIE NON SONO VISIBILI
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
    'Private Sub WebGridPrescrizioni_RowDataBound(sender As Object, e As GridViewRowEventArgs) Handles WebGridPrescrizioni.RowDataBound
    '    HelperGridView.AddHeaderSortingIcon(sender, e, GridViewSortExpression, GridViewSortDirection)
    'End Sub
#End Region

#Region "WebGridRefertiEpisodi"

    Private Sub WebGridRefertiEpisodi_RowDataBound(sender As Object, e As GridViewRowEventArgs) Handles WebGridRefertiEpisodi.RowDataBound

        ' MOMENTANEAMENTO NON USATO PERCHE' GLI HEADER DELLE GRIGLIE NON SONO VISIBILI
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
            Dim OdsRefertiPerNosologico As ObjectDataSource = CType(rowCorrente.FindControl("DataSourceRefertiPerNosologico"), ObjectDataSource)

            '
            ' InvalidaCacheRefertiPerNosologico è true se abbiamo cliccato il bottone "cerca" o abbiamo cambiato tab
            '
            If InvalidaCacheRefertiPerNosologico Then
                Dim dsRefertiPerNosologico As New CustomDataSource.AccessoDirettoRefertiCercaPerNosologico

                '
                ' La key della cache in questo caso è composta dal NumeroNosologico e da AziendaErogante 
                '
                dsRefertiPerNosologico.ClearCache(rowEpisodio.NumeroNosologico, rowEpisodio.AziendaErogante)
            End If


            '
            ' Il Token e il ByPassaConsenso vengono valorizzati nell'evento selecting dell'ObjectDataSource DataSourceRefertiPerNosologico_Selecting
            ' (per poterlo vedere nel codice è stato definito all'interno del Markup)
            '
            OdsRefertiPerNosologico.SelectParameters.Item("Nosologico").DefaultValue = rowEpisodio.NumeroNosologico
            OdsRefertiPerNosologico.SelectParameters.Item("Azienda").DefaultValue = rowEpisodio.AziendaErogante
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

            If gvSubQuery.Rows.Count > 0 Then

                '
                ' Creo il bottone per collassare la riga
                '
                Dim sbCellDiv As New StringBuilder
                sbCellDiv.AppendFormat("<button data-target='.{0}'", rowEpisodio.NumeroNosologico)
                sbCellDiv.AppendFormat("        class='btn btn-xs btn-default'", rowEpisodio.NumeroNosologico)
                sbCellDiv.AppendFormat("        data-toggle='collapse'")
                sbCellDiv.AppendFormat("        type='button'>")
                sbCellDiv.AppendFormat(" <div class='{0} collapse {1}'>", rowEpisodio.NumeroNosologico, If(rowEpisodio.DataConclusione Is Nothing, "in", ""))
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
                Dim tblGrid As Table = CType(Me.WebGridRefertiEpisodi.Controls(0), Table)

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

                '
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
                ' Sostituisce l'ultima colonna con una cella vuota e la nasconde
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

    ' MOMENTANEAMENTO NON USATO PERCHE' GLI HEADER DELLE GRIGLIE NON SONO VISIBILI
    'Private Sub WebGridRefertiEpisodi_Sorting(sender As Object, e As GridViewSortEventArgs) Handles WebGridRefertiEpisodi.Sorting
    '    e.Cancel = True
    '    Me.GridViewSortExpression = e.SortExpression
    '    If Me.GridViewSortDirection Is Nothing OrElse Me.GridViewSortDirection.Value = SortDirection.Descending Then
    '        Me.GridViewSortDirection = SortDirection.Ascending
    '    Else
    '        Me.GridViewSortDirection = SortDirection.Descending
    '    End If
    '    DataSource_InvalidaCache()
    '    WebGridRefertiEpisodi.DataBind()
    'End Sub

    Private Sub WebGridRefertiEpisodi_PreRender(sender As Object, e As EventArgs) Handles WebGridRefertiEpisodi.PreRender
        '
        'Render per Bootstrap
        'Crea la Table con Theader e Tbody se l'header non è nothing.
        '
        If WebGridRefertiEpisodi.HeaderRow IsNot Nothing Then
            WebGridRefertiEpisodi.UseAccessibleHeader = True
            WebGridRefertiEpisodi.HeaderRow.TableSection = TableRowSection.TableHeader
        End If
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

#End Region

#Region "WebGridRefertiSingoli"
    Private Sub WebGridRefertiSingoli_PreRender(sender As Object, e As EventArgs) Handles WebGridRefertiSingoli.PreRender
        '
        'Render per Bootstrap
        'Crea la Table con Theader e Tbody se l'header non è nothing.
        '
        If WebGridRefertiSingoli.HeaderRow IsNot Nothing Then
            WebGridRefertiSingoli.UseAccessibleHeader = True
            WebGridRefertiSingoli.HeaderRow.TableSection = TableRowSection.TableHeader
        End If
    End Sub
#End Region

    Private Function GetVisibleDataGrid2() As GridView
        '
        ' Restituisce la GridView visibile
        '
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
            oGrid = WebGridRefertiSingoli
        End If
        Return oGrid
    End Function
#End Region

#Region "Funzioni usate nel markup"

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

    ''' <summary>
    ''' Restituisce l'icona relativa allo stato della nota anamnestica
    ''' </summary>
    ''' <param name="obj"></param>
    ''' <returns></returns>
    Protected Function GetIconaStatoDettaglioNotaAnamnestica(ByVal obj As Object)
        Dim oRow As WcfDwhClinico.NotaAnamnesticaType = CType(obj, WcfDwhClinico.NotaAnamnesticaType)

        Return UserInterface.GetIconaStatoNotaAnamnestica(oRow)
    End Function
#End Region

#Region "Per Eventi"
    Protected Function GetDataEvento(objrow As Object) As String
        Dim sDataEvento As String = Nothing
        Dim sDataReferto As String = Nothing
        Dim oRow As WcfDwhClinico.RefertoListaType = CType(objrow, WcfDwhClinico.RefertoListaType)
        '
        ' Per sicurezza controllo sempre che le date siano diverse da nothing.
        '
        If oRow.DataEvento <> Nothing Then
            sDataEvento = String.Format("{0:g}", oRow.DataEvento)
        End If
        If oRow.DataReferto <> Nothing Then
            sDataReferto = String.Format("{0:d}", oRow.DataReferto)
        End If

        If oRow.DataReferto <> oRow.DataEvento Then
            Return String.Format("{0} </br> Refertato il {1}", sDataEvento, sDataReferto)
        Else
            Return String.Format("{0}", sDataEvento)
        End If
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
        If Not String.IsNullOrEmpty(oRow.TipoEpisodioCodice) Then
            strHtml = HelperRicoveri.GetHtmlImgTipoEpisodioRicovero(oRow.TipoEpisodioCodice)
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
        If oTipoEpisodioRicovero IsNot DBNull.Value Then
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

    Protected Function GetEventoEpisodioDescr(objRow As Object) As String
        Dim oRow As WcfDwhClinico.EventoType = CType(objRow, WcfDwhClinico.EventoType)
        Return String.Format("{0} - ({1})", oRow.TipoEventoDescrizione.NullSafeToString, oRow.TipoEventoCodice.NullSafeToString)
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

#Region "Per Referti"
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

    Protected Function GetNumeroReferto(objrow As Object) As String
        Dim oRow As WcfDwhClinico.RefertoListaType = CType(objrow, WcfDwhClinico.RefertoListaType)
        Dim sReturn As String = String.Empty
        If Not String.IsNullOrEmpty(oRow.NumeroReferto) Then
            sReturn = String.Format("N.REF.: {0}", oRow.NumeroReferto.NullSafeToString)
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

    Protected Function GetUrlIconaTipoReferto(obj As Object) As String
        Dim oRow As WcfDwhClinico.RefertoListaType = DirectCast(obj, WcfDwhClinico.RefertoListaType)
        Dim sReturn As String = Nothing
        If oRow IsNot Nothing AndAlso Not String.IsNullOrEmpty(oRow.IdTipoReferto) Then
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
                sHtml = String.Format("<label data-toggle=""tooltip"" data-placement=""top"" title=""{0}"">{1}...</label>", oRow.Anteprima.NullSafeToString.ToString, oRow.Anteprima.NullSafeToString.Substring(0, 40))
            Else
                sHtml = oRow.Anteprima
            End If
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

    Protected Function GetPriorita(objrow As Object) As String
        Dim oRow As WcfDwhClinico.RefertoListaType = CType(objrow, WcfDwhClinico.RefertoListaType)
        Dim strHtml As String = String.Empty
        If oRow.PrioritaDescrizione IsNot Nothing Then
            strHtml = oRow.PrioritaDescrizione
        End If
        Return strHtml
    End Function

    Protected Function GetInfoAccettazione(objRow As Object) As String
        Dim oRow As WcfDwhClinico.EpisodioListaType = CType(objRow, WcfDwhClinico.EpisodioListaType)
        Dim sHtml As String = String.Empty
        If oRow.DataApertura.HasValue Then
            sHtml = String.Format("Accettato in {0} </br> il {1:g}", oRow.StrutturaAperturaDescrizione.NullSafeToString, oRow.DataApertura)
        End If
        Return sHtml
    End Function

    Protected Function GetNosologico(objRow As Object) As String
        Dim oRow As WcfDwhClinico.EpisodioListaType = CType(objRow, WcfDwhClinico.EpisodioListaType)
        Return String.Format("Nosologico: {0}", oRow.NumeroNosologico)
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
        Dim sUrl As String = Me.ResolveUrl(String.Format("~/AccessoDiretto/Referto.aspx?IdReferto={0}", oRow.Id))

        'Modifica leo: 2019/12/10 : se da query String: ShowPanelloPaziente è valorizzato allora passo anche ShowPanelloPaziente=(bool) alla pagina di dettaglio.
        Dim sShowPannelloPaziente As String = Me.ShowPannelloPaziente
        Dim bShowPannelloPaziente As Boolean = True
        If Not String.IsNullOrEmpty(sShowPannelloPaziente) Then
            If Boolean.TryParse(sShowPannelloPaziente, bShowPannelloPaziente) Then
                sUrl = sUrl & "&ShowPannelloPaziente=" & bShowPannelloPaziente.ToString
            Else
                'Se il try parse fallisce non faccio nulla
            End If
        End If
        '
        ' Restituzione
        '
        Return sUrl


    End Function

#End Region

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

#End Region

#Region "Modale Dettaglio Episodi"
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

            '
            ' Ottengo il dettaglio dell'episodio
            '
            Dim EpisodioOttieniPerId As New CustomDataSource.AccessoDirettoEpisodioOttieniPerId
            Dim dettaglioRicovero As WcfDwhClinico.EpisodioType = EpisodioOttieniPerId.GetData(Me.Token, IdRicovero)

            If dettaglioRicovero IsNot Nothing Then
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
                If dettaglioRicovero IsNot Nothing Then
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
            Logging.WriteError(ex, "GetXmlTestataRicovero: Si è verificato un errore durante la lettura delle info di ricovero.")
            Throw
        End Try
        Return ""
    End Function

    Private Sub ShowAttributiAnagrafici(dettaglioRicovero As WcfDwhClinico.EpisodioType)
        '
        ' Popolo gli attributi anagrafici del paziente all'interno della modale di dettaglio dell'episodio.
        '
        Dim Nome As String = String.Empty
        Dim Cognome As String = String.Empty
        Dim CodiceFiscale As String = String.Empty
        Dim CodiceSanitario As String = String.Empty
        Dim LuogoNascita As String = String.Empty
        Dim DataNascita As Date = Nothing
        If dettaglioRicovero IsNot Nothing AndAlso dettaglioRicovero.Paziente IsNot Nothing Then
            If dettaglioRicovero.Paziente.Nome IsNot Nothing Then
                Nome = dettaglioRicovero.Paziente.Nome.ToString
            End If
            If dettaglioRicovero.Paziente.Cognome IsNot Nothing Then
                Cognome = dettaglioRicovero.Paziente.Cognome.ToString
            End If
            If dettaglioRicovero.Paziente.CodiceFiscale IsNot Nothing Then
                CodiceFiscale = dettaglioRicovero.Paziente.CodiceFiscale.ToString
            End If
            If dettaglioRicovero.Paziente.CodiceSanitario IsNot Nothing Then
                CodiceSanitario = dettaglioRicovero.Paziente.CodiceSanitario.ToString
            End If
            If dettaglioRicovero.Paziente.ComuneNascita IsNot Nothing Then
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
    End Sub

    Private Sub UpdatePanelDettaglioEpisodio_Load(sender As Object, e As EventArgs) Handles UpdatePanelDettaglioEpisodio.Load
        If Not String.IsNullOrEmpty(hfIdEpisodio.Value.ToString) Then
            '
            ' Traccio gli accessi al dettaglio dell'episodio
            '
            'Utility.TracciaAccessiRicovero2(Me.CodiceRuolo, Me.DescrizioneRuolo, "Apre Episodio", Nothing, Nothing, SessionHandler.MotivoAccesso, SessionHandler.MotivoAccessoNote)
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
            Me.Session(String.Format("{0}_{1}", KEY_AD_REFERTI_LISTA_TIPIREFERTO, Me.IdPaziente.ToString)) = listaTipiReferti
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
            Dim listaTipiReferti As List(Of String) = CType(Me.Session(String.Format("{0}_{1}", KEY_AD_REFERTI_LISTA_TIPIREFERTO, Me.IdPaziente.ToString)), List(Of String))

            Dim checkBoxList As CheckBoxList = CType(sender, CheckBoxList)
            If listaTipiReferti IsNot Nothing Then
                For Each item As ListItem In checkBoxList.Items
                    '
                    ' Per ogni item controllo se è contenuto nella lista dei TipiReferti
                    ' Se item è contenuto in listaTipiReferti allora lo seleziono 
                    '
                    If listaTipiReferti.Contains(item.Value) Then
                        item.Selected = True
                    End If
                Next




                '
                ' Dopo aver reimpostato i filtri eseguo un bind in modo da visualizzare i dati correttamente filtrati
                '
                mbValidationCancelSelect = False
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
            Me.Session(String.Format("{0}_{1}", KEY_AD_PRESCRIZIONI_LISTA_TIPIREFERTO, Me.IdPaziente.ToString)) = listaTipiPrescrizioni
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
            Dim listaTipiPrescrizioni As List(Of String) = CType(Me.Session(String.Format("{0}_{1}", KEY_AD_PRESCRIZIONI_LISTA_TIPIREFERTO, Me.IdPaziente.ToString)), List(Of String))

            Dim checkBoxList As CheckBoxList = CType(sender, CheckBoxList)
            If listaTipiPrescrizioni IsNot Nothing Then
                For Each item As ListItem In checkBoxList.Items
                    '
                    ' Per ogni item controllo se è contenuto nella lista dei TipiPrescrizioni
                    ' Se item è contenuto in listaTipiPrescrizioni allora lo seleziono 
                    '
                    If listaTipiPrescrizioni.Contains(item.Value) Then
                        item.Selected = True
                    End If
                Next

                '
                ' Dopo aver reimpostato i filtri eseguo un bind in modo da visualizzare i dati correttamente filtrati
                '
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
            Me.Session(String.Format("{0}_{1}", KEY_AD_REFERTI_PER_EPISODI_LISTA_TIPIREFERTO, Me.IdPaziente.ToString)) = listaTipiReferti
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
            Dim listaTipiReferti As List(Of String) = CType(Me.Session(String.Format("{0}_{1}", KEY_AD_REFERTI_PER_EPISODI_LISTA_TIPIREFERTO, Me.IdPaziente.ToString)), List(Of String))

            Dim checkBoxList As CheckBoxList = CType(sender, CheckBoxList)
            If listaTipiReferti IsNot Nothing Then
                For Each item As ListItem In checkBoxList.Items
                    '
                    ' Per ogni item controllo se è contenuto nella lista dei TipiReferti
                    ' Se item è contenuto in listaTipiReferti allora lo seleziono 
                    '
                    If listaTipiReferti.Contains(item.Value) Then
                        item.Selected = True
                    End If
                Next

                '
                ' Dopo aver reimpostato i filtri eseguo un bind in modo da visualizzare i dati correttamente filtrati
                '
                WebGridRefertiEpisodi.DataBind()
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
        SessionHandler.AccessoDirettoCancellaCache = True
        SaveFilterValues()
    End Sub

#Region "Gestione tab"
    Protected Sub SelectView(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.CommandEventArgs)
        '
        ' Viene chiamata quando si clicca su pulsanti tab
        '
        Dim olnkView As LinkButton = Nothing
        Try
            olnkView = CType(sender, LinkButton)
            Call _SetSelectedView(olnkView)
            Cerca()
        Catch ex As Exception
            '
            ' Errore
            '
            Logging.WriteError(ex, Me.GetType.Name)
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante selezione della tab!"
        End Try
    End Sub

    Private Sub _SetSelectedView(ByVal oClickedButton As LinkButton)
        Dim clickedTab As HtmlGenericControl = Nothing

        '
        ' Rimuovo la classe Bootstrap "active" da tutti i tab
        '
        tabLnkReferti.Attributes.Clear()
        tabLnkCalendario.Attributes.Clear()
        tabLnkRefertiEpisodi.Attributes.Clear()
        tabLnkRisultatoMatrice.Attributes.Clear()
        tabLnkPrescrizioni.Attributes.Clear()
        tabLnkSchedePaziente.Attributes.Clear()
        tabLnkNoteAnamnestiche.Attributes.Clear()

        '
        ' Aggiungo al tab selezionato la classe Bootstrap "active"
        '
        clickedTab = oClickedButton.Parent
        clickedTab.Attributes.Add("class", "active")


        FiltriCheckBoxList.Visible = True
        TipoRefertoCheckboxList.Visible = True
        TipoPrescrizioneCheckboxList.Visible = True
        TipoRefertoPerEpisodioCheckboxList.Visible = True

        Select Case oClickedButton.UniqueID
            Case lnkReferti.UniqueID
                MultiViewMain.SetActiveView(ViewReferti)
                TipoPrescrizioneCheckboxList.Visible = False
                TipoRefertoPerEpisodioCheckboxList.Visible = False
                'Utility.TracciaAccessiLista2(Me.CodiceRuolo, Me.DescrizioneRuolo, "Lista referti", Me.IdPaziente, SessionHandler.MotivoAccesso, SessionHandler.MotivoAccessoNote)

            Case lnkCalendario.UniqueID 'Calendario
                MultiViewMain.SetActiveView(ViewCalendario)
                ' Rimuovo tutti i filtri ed il pulsante per stampare i referti selezionati (la selezione di referti in giorni diversi non è stata implementata). 
                FiltriCheckBoxList.Visible = False
                TipoRefertoCheckboxList.Visible = False
                TipoPrescrizioneCheckboxList.Visible = False
                TipoRefertoPerEpisodioCheckboxList.Visible = False

            Case lnkRefertiEpisodi.UniqueID
                MultiViewMain.SetActiveView(ViewRefertiEpisodi)
                FiltriCheckBoxList.Visible = True
                TipoPrescrizioneCheckboxList.Visible = False
                TipoRefertoCheckboxList.Visible = False
                'Utility.TracciaAccessiLista2(Me.CodiceRuolo, Me.DescrizioneRuolo, "Lista episodi", Me.IdPaziente, SessionHandler.MotivoAccesso, SessionHandler.MotivoAccessoNote)

            Case lnkRisultatoMatrice.UniqueID
                FiltriCheckBoxList.Visible = False
                MultiViewMain.SetActiveView(ViewRisultatoMatrice)

            Case lnkPrescrizioni.UniqueID
                TipoRefertoCheckboxList.Visible = False
                TipoRefertoPerEpisodioCheckboxList.Visible = False
                MultiViewMain.SetActiveView(ViewPrescrizioni)
                'Utility.TracciaAccessiLista2(Me.CodiceRuolo, Me.DescrizioneRuolo, "Lista impegnative", Me.IdPaziente, SessionHandler.MotivoAccesso, SessionHandler.MotivoAccessoNote)

            Case lnkSchedePaziente.UniqueID
                FiltriCheckBoxList.Visible = False
                MultiViewMain.SetActiveView(ViewSchedePaziente)
                'Utility.TracciaAccessiLista2(Me.CodiceRuolo, Me.DescrizioneRuolo, "Lista referti", Me.IdPaziente, SessionHandler.MotivoAccesso, SessionHandler.MotivoAccessoNote)

            Case lnkNoteAnamnestiche.UniqueID
                TipoRefertoCheckboxList.Visible = False
                TipoRefertoPerEpisodioCheckboxList.Visible = False
                MultiViewMain.SetActiveView(ViewNoteAnamnestiche)
                'Utility.TracciaAccessiLista2(Me.CodiceRuolo, Me.DescrizioneRuolo, "Lista Note Anamnestiche", Me.IdPaziente, SessionHandler.MotivoAccesso, SessionHandler.MotivoAccessoNote)

            Case Else
                Throw New Exception("Non esiste il tab " & oClickedButton.Text)
        End Select
        '
        ' Salvo il pulsante selezionato
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

#Region "Modale Dettaglio Nota Anamnestica"
    Dim OdsNotaAnamnesticaCancelSelect As Boolean = True
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
                    'Passo all'ObjectDataSource l'id della nota anamnestica.
                    '
                    OdsNotaAnamnestica.SelectParameters("IdNotaAnamnestica").DefaultValue = idNotaAnamnestica.ToString

                    '
                    'Setto a false "OdsNotaAnamnesticaCancelSelect" in modo da permettere l'esecuzione della query.
                    '
                    OdsNotaAnamnesticaCancelSelect = False

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

    Private Sub OdsNotaAnamnestica_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles OdsNotaAnamnestica.Selecting
        Try
            '
            'Nel page.load imposto tabLnkNoteAnamnestiche.Visible = my.setting.showNoteAnamnesticheTab
            '   quindi mi basta controllare la visibilità della tab.
            '
            If OdsNotaAnamnesticaCancelSelect OrElse Not tabLnkNoteAnamnestiche.Visible Then
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
            '
            ' Errore
            '
            Logging.WriteError(ex, Me.GetType.Name)
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati!"
        End Try
    End Sub

    Private Sub OdsNotaAnamnestica_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles OdsNotaAnamnestica.Selected
        Try
            '
            'Controllo se ci sono errori.
            '

            'Ottengo il messaggio di errore.
            Dim messaggioErrore = HelperDataSourceException.GetObjectDataSourceExceptionMessage(e.Exception)

            'Testo se il messaggio di errore è vuoto. Se è valorizzato allora mostro il div d'errore.
            If Not String.IsNullOrEmpty(messaggioErrore) Then
                divErrorMessage.Visible = True
                lblErrorMessage.Text = messaggioErrore
                e.ExceptionHandled = True
            Else
                '
                'Valorizzo i dati anagrafici del paziente mostrati nella modale di dettaglio della Nota Anamnestica.
                '
                Dim oDettaglioNota As WcfDwhClinico.NotaAnamnesticaType = CType(e.ReturnValue, WcfDwhClinico.NotaAnamnesticaType)

                'Testo se oDettaglioNota è vuoto.
                If oDettaglioNota IsNot Nothing Then
                    If oDettaglioNota.Paziente IsNot Nothing Then
                        ucInfoPazienteNotaAnamnestica.Nome = oDettaglioNota.Paziente.Nome
                        ucInfoPazienteNotaAnamnestica.Cognome = oDettaglioNota.Paziente.Cognome
                        ucInfoPazienteNotaAnamnestica.DataNascita = oDettaglioNota.Paziente.DataNascita
                        ucInfoPazienteNotaAnamnestica.CodiceFiscale = oDettaglioNota.Paziente.CodiceFiscale
                        ucInfoPazienteNotaAnamnestica.LuogoNascita = oDettaglioNota.Paziente.ComuneNascita
                    End If

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

    Private Sub SetGridViewBootstrapStyle()
        '
        ' Paginazione di default
        '
        WebGridRefertiEpisodi.PageSize = GRID_PAGE_SIZE
        WebGridReferti.PageSize = GRID_PAGE_SIZE
        WebGridPrescrizioni.PageSize = GRID_PAGE_SIZE
        WebGridRefertiSingoli.PageSize = GRID_PAGE_SIZE
        gvNoteAnamnestiche.PageSize = GRID_PAGE_SIZE

        '
        ' RENDERING PER BOOTSTRAP
        ' Converte i tag html generati dalla GridView per la paginazione
        ' e li adatta alle necessita dei CSS Bootstrap
        '
        WebGridReferti.PagerStyle.CssClass = "pagination-gridview"
        WebGridRefertiEpisodi.PagerStyle.CssClass = "pagination-gridview"
        WebGridRefertiSingoli.PagerStyle.CssClass = "pagination-gridview"
        WebGridEventiEpisodio.PagerStyle.CssClass = "pagination-gridview"
        WebGridPrescrizioni.PagerStyle.CssClass = "pagination-gridview"
        gvNoteAnamnestiche.PagerStyle.CssClass = "pagination-gridview"
        ScriptManager.RegisterStartupScript(Page, Page.GetType(), "gridPagination", HelperGridView.GetScriptPaginationForBootstrap(), True)
    End Sub

    Private Sub AccessoDiretto_Referti_Unload(sender As Object, e As EventArgs) Handles Me.Unload
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
            TracciaAccessi.TracciaAccessiLista(Me.CodiceRuolo, Me.DescrizioneRuolo, "Lista referti", Me.IdPaziente, SessionHandler.MotivoAccesso, SessionHandler.MotivoAccessoNote, WebGridRefertiSingoli.Rows.Count, Me.ConsensoPaziente)
        ElseIf MultiViewMain.GetActiveView Is ViewNoteAnamnestiche Then
            TracciaAccessi.TracciaAccessiLista(Me.CodiceRuolo, Me.DescrizioneRuolo, "Lista note anamnestiche", Me.IdPaziente, SessionHandler.MotivoAccesso, SessionHandler.MotivoAccessoNote, gvNoteAnamnestiche.Rows.Count, Me.ConsensoPaziente)
        End If
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
                            Response.Redirect(String.Format("~/AccessoDiretto/FSE/DocumentiLista.aspx?IdPaziente={0}", Me.IdPaziente), False)

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
                    Response.Redirect(String.Format("~/AccessoDiretto/FSE/DocumentiLista.aspx?IdPaziente={0}", Me.IdPaziente), False)

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
                '
                ' Chiamata al ws
                '
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

    Private Sub DataSourceLstTipiReferti_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles DataSourceLstTipiReferti.Selecting
        e.InputParameters("IdPaziente") = IdPaziente
    End Sub
End Class

