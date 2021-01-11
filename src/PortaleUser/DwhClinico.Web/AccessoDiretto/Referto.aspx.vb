Imports DwhClinico.Data
Imports DwhClinico.Web
Imports DwhClinico.Web.Utility
Imports System.Security
Imports DI.PortalUser2

Partial Class AccessoDiretto_Referto
    Inherits System.Web.UI.Page

    Private mbValidationCancelSelect As Boolean = False
    Private mbRuoloCancellazione As Boolean

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

    Public Property ConsensoPaziente As String
        Get
            Return Me.ViewState("ConsensoPaziente")
        End Get
        Set(value As String)
            Me.ViewState("ConsensoPaziente") = value
        End Set
    End Property

    Public Property ShowPannelloPaziente As String
        Get
            Return Me.ViewState("ShowPannelloPaziente")
        End Get
        Set(value As String)
            Me.ViewState("ShowPannelloPaziente") = value
        End Set
    End Property

    Private Property NumeroNosologico As String
        Get
            Return CType(Me.ViewState("NumeroNosologico"), String)
        End Get
        Set(value As String)
            Me.ViewState("NumeroNosologico") = value
        End Set
    End Property

    Private Property AziendaErogante As String
        Get
            Return CType(Me.ViewState("AziendaErogante"), String)
        End Get
        Set(value As String)
            Me.ViewState("AziendaErogante") = value
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

    Public Property IdReferto As Guid
        '
        ' Memorizza nel ViewState l'id dell'episodio da passare come parametro agli ObjectDataSource delle tab.
        '
        Get
            Return Me.ViewState("IdReferto")
        End Get
        Set(value As Guid)
            Me.ViewState("IdReferto") = value
        End Set
    End Property

    Private Property NumeroVersione As Integer?
        Get
            Return CType(Me.ViewState("NumeroVersione"), Integer?)
        End Get
        Set(value As Integer?)
            Me.ViewState("NumeroVersione") = value
        End Set
    End Property

    Private Property Avvertenze As String
        Get
            Return CType(Me.ViewState("Avvertenze"), String)
        End Get
        Set(value As String)
            Me.ViewState("Avvertenze") = value
        End Set
    End Property

#End Region

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Dim oReturn As WcfDwhClinico.RefertoType = Nothing
        Try
            If Not Page.IsPostBack Then
                '
                'Impedisco bind automatico degli userControl.
                '
                RefertoDettaglioPdf.CancelSelect = True
                RefertoDettaglioEsterno.CancelSelect = True
                RefertoDettaglioInterno.CancelSelect = True

                '
                'Nascondo tutti gli UserControl nel markup.
                '
                RefertoDettaglioEsterno.Visible = False
                RefertoDettaglioPdf.Visible = False
                RefertoDettaglioInterno.Visible = False
            End If

            'Mostro o nascondo l'header della masterpage in base a quanto indicato nella querystring o precedentemente in sessione
            Utility.CheckShowHeaderParam(Request)

            'Modifica Leo 2019/12/10: Nascondere Pannello Paziente se specificato nell'url
            Me.ShowPannelloPaziente = Request.QueryString("ShowPannelloPaziente")
            ucTestataPaziente.Visible = Utility.AccessoDirettoPannelloPazientVisibility(Request.QueryString)

            '
            ' Controllo la validità della sessione
            '
            If Not Page.IsPostBack AndAlso Utility.AccessoDiretto_IsPageEntryPoint() Then
                '
                ' Se la pagina è EntryPoint e non è un PostBack allora valorizzo la variabile
                '
                SessionHandler.ValidaSessioneAccessoDiretto = True
            ElseIf SessionHandler.ValidaSessioneAccessoDiretto = Nothing Then
                '
                ' Se sono qui la sessione è scaduta e quindi mostro un messaggio di errore.
                '
                Throw New ApplicationException("La sessione di lavoro è scaduta.")
            End If

            '
            ' Memorizzo sempre se utente appartiene al ruolo di default di cancellazione
            '
            mbRuoloCancellazione = CheckPermission(My.Settings.Role_Delete)

            If Not Me.IsPostBack Then
                '
                ' Valorizzo l'url di ritorno a questa pagina usata nella pagina RefertiAllegati.aspx
                '
                SessionHandler.AccessoDirettoRefertoUrl = Request.Url.AbsoluteUri

                btnApriAllegato.Visible = False
                Dim oQueryString As Specialized.NameValueCollection = Me.Request.QueryString
                '
                ' Questi sono i possibili parametri per cercare il referto( la ricerca per numero referto non esiste)
                '
                Dim sIdReferto As String = oQueryString(PAR_ID_REFERTO)
                Dim sIdRefertoEsterno As String = oQueryString(PAR_ID_ESTERNO)
                Dim sNumeroPrenotazione As String = oQueryString(PAR_NUMERO_PRENOTAZIONE)
                Dim sUrlContent As String = Me.Request.QueryString(PAR_URL)
                Dim sEntryPoint As String = Me.Request.QueryString(PAR_ENTRY_POINT)


                Dim bPageEntryPoint As Boolean = Utility.AccessoDiretto_IsPageEntryPoint()
                If sEntryPoint = "0" Then
                    '
                    ' sEntryPoint viene aggiunto all'url nella pagina TracciaAccessi.aspx per stabilire se la pagina è entry point oppure no.
                    ' Questo viene fatto a causa dell'response.redirect di TracciaAccessi che non valorizza l'url referrer.
                    '
                    bPageEntryPoint = False
                End If

                Dim oMenu As Menu = CType(Master.FindControl("MenuMain2"), Menu)
                '
                ' Il load di questa pagina viene prima di quello della MasterPage. Eseguo il bind dei dati per essere sicuro di trovare il menu popolato.
                '
                oMenu.DataBind()
                Dim menuItemPazienti As MenuItem = UserInterface.GetMenuItem(oMenu, "Pazienti")

                '
                ' Verifico che gli item siano effettivamente popolati. Se non lo sono genero una ApplicationExceptions
                '
                If menuItemPazienti Is Nothing Then
                    Throw New ApplicationException("La voce del menu ""Pazienti"" non esiste.")
                End If
                oMenu.Items.Remove(menuItemPazienti)


                If bPageEntryPoint Then
                    '
                    ' Se la pagina è EntryPoint resetto le varibili di sessione legate all'url del menu.
                    '
                    SessionHandler.AccessoDirettoUrlPazienti = Nothing
                    SessionHandler.AccessoDirettoUrlReferti = Nothing


                    '
                    ' resetto l'url per tornare alla pagina dei referti
                    '
                    SessionHandler.AccessoDirettoListaRefertiUrl = String.Empty

                    '
                    ' Se la pagina è EntryPoint allora bisogna forzare il motivo dell'accesso a "Paziente in carico"
                    '
                    SessionHandler.MotivoAccesso = New ListItem(MOTIVO_ACCESSO_PAZIENTE_IN_CARICO_TEXT, MOTIVO_ACCESSO_PAZIENTE_IN_CARICO_ID)
                Else
                    Dim urlPazienti As String = SessionHandler.AccessoDirettoUrlPazienti
                    Dim urlReferti As String = SessionHandler.AccessoDirettoUrlReferti
                    If Not String.IsNullOrEmpty(urlPazienti) Then
                        menuItemPazienti.NavigateUrl = urlPazienti
                    ElseIf Not String.IsNullOrEmpty(urlReferti) Then
                        oMenu.Items.Remove(menuItemPazienti)
                    End If
                End If

                '
                ' Mostro il bottone per tornare alla lista dei referti solo se SessionHandler.AccessoDirettoListaRefertiUrl è valorizzato.
                ' La variabile SessionHandler.AccessoDirettoListaRefertiUrl viene valorizzata nella pagina della lista dei referti.
                '
                If Not String.IsNullOrEmpty(SessionHandler.AccessoDirettoListaRefertiUrl) Then
                    cmdEsci.Visible = True
                Else
                    cmdEsci.Visible = False
                End If


                If sUrlContent Is Nothing OrElse sUrlContent.Length = 0 Then
                    If Not String.IsNullOrEmpty(sIdReferto) Then
                        '
                        ' Eseguo il metodo per ricavare il referto per Id in modo da ottenre anche l'id del paziente
                        '
                        Dim ds As New CustomDataSource.AccessoDirettoRefertoOttieniPerId
                        Try
                            If Guid.TryParse(sIdReferto, Me.IdReferto) Then
                                oReturn = ds.GetData(Me.Token, Me.IdReferto)
                                If oReturn Is Nothing Then
                                    Throw New ApplicationException("Impossibile trovare il referto.")
                                End If
                                Me.IdPaziente = New Guid(oReturn.IdPaziente)
                            Else
                                Throw New ApplicationException("L'id del referto non è nel formato corretto.")
                            End If
                        Catch ex As ApplicationException
                            Throw New ApplicationException(ex.Message)
                        End Try
                    ElseIf Not String.IsNullOrEmpty(sIdRefertoEsterno) Then
                        '
                        ' La ricerca per IdRefertoEsterno e IdRefertoEsterno + NumeroPrenotazione sono eseguite con la stessa CustomDataSource
                        ' Eseguo il metodo del WS per ricavare l'id del referto
                        '
                        Dim ds As New CustomDataSource.AccessoDirettoRefertoOttieniPerIdEsterno
                        '
                        ' Corrado ha detto che l'id esterno viene passato prefissato dall'azienda.
                        '
                        'Tolto la combinazione IdRefertoEsterno,NumeroPrenotazione dalla ricerca(email Tartaglia del 21/06/2016)
                        oReturn = ds.GetData(Me.Token, sIdRefertoEsterno)
                        If oReturn Is Nothing Then
                            Throw New ApplicationException("Impossibile trovare il referto.")
                        End If
                        Me.IdPaziente = New Guid(oReturn.IdPaziente)
                        Me.IdReferto = New Guid(oReturn.Id)

                    ElseIf Not String.IsNullOrEmpty(sNumeroPrenotazione) Then
                        Dim ds As New CustomDataSource.AccessoDirettoRefertiCercaPerNumeroPrenotazione
                        '
                        ' Nel dettaglio si bypassa sempre il consenso, quindi anche se cerco usando una lista lo imposto a TRUE
                        '
                        Dim oRefertoLista As List(Of WcfDwhClinico.RefertoListaType) = ds.GetData(Me.Token, Nothing, True, sNumeroPrenotazione, #1/1/1900#, Now, Nothing, Nothing, Nothing, Nothing)
                        If oRefertoLista Is Nothing OrElse oRefertoLista.Count > 1 Then
                            Throw New ApplicationException("La ricerca per NumeroPrenotazione non è univoca.")
                        Else
                            Dim oReferto As WcfDwhClinico.RefertoListaType = CType(oRefertoLista.Item(0), WcfDwhClinico.RefertoListaType)
                            If oReferto Is Nothing Then
                                Throw New ApplicationException("Impossibile trovare il referto.")
                            End If
                            Me.IdPaziente = New Guid(oReferto.IdPaziente)
                            Me.IdReferto = New Guid(oReferto.Id)

                        End If
                        '
                        ' Eseguo il metodo AccessoDirettoRefertoOttieniPerId per visualizzare gli attributi anagrafici del paziente
                        '
                        Dim dsAccessoDirettoRefertoOttieniPerId As New CustomDataSource.AccessoDirettoRefertoOttieniPerId
                        oReturn = dsAccessoDirettoRefertoOttieniPerId.GetData(Me.Token, Me.IdReferto)
                    Else
                        '
                        ' Invalido le select degli ObjectDataSource
                        '
                        ucTestataPaziente.mbValidationCancelSelect = True
                        mbValidationCancelSelect = True
                        divErrorMessage.Visible = True
                        lblErrorMessage.Text = "La combinazione dei parametri non è valida."
                        NascondoPagina()
                        Exit Sub
                    End If

                    'SessionHandler.AccessoDirettoIdReferto = Me.IdReferto.ToString
                    SessionHandler.IdReferto = Me.IdReferto.ToString


                    '
                    ' SOLO A QUESTO PUNTO SI VISUALIZZA IL PULSANTE DI APERTURA ALLEGATI
                    '
                    btnApriAllegato.Visible = CheckPermission(My.Settings.RefertiOpenDocument_Role)
                    btnApriAllegato.Text = My.Settings.RefertiOpenDocument_Text
                Else
                    '
                    ' Se sUrlContent è valorizzato allora sto mostrando un allegato e nascondo i pulsanti presenti nella pagina
                    '
                    btnApriAllegato.Visible = False

                    '
                    ' è valorizzato il parametro sUrlContent. Tento di ricavare l'id del referto.
                    '
                    sIdReferto = Utility.GetQueryStringParameterValue(Me.Page, sUrlContent, PAR_ID_REFERTO)
                    If String.IsNullOrEmpty(sIdReferto) Then
                        'sIdReferto = SessionHandler.AccessoDirettoIdReferto
                        sIdReferto = SessionHandler.IdReferto
                    End If
                    If Not String.IsNullOrEmpty(sIdReferto) Then
                        Me.IdReferto = New Guid(sIdReferto)
                        '
                        ' Eseguo il metodo AccessoDirettoRefertoOttieniPerId per visualizzare gli attributi anagrafici del paziente
                        '
                        Dim dsAccessoDirettoRefertoOttieniPerId As New CustomDataSource.AccessoDirettoRefertoOttieniPerId
                        oReturn = dsAccessoDirettoRefertoOttieniPerId.GetData(Me.Token, Me.IdReferto)
                        If oReturn Is Nothing Then
                            Throw New ApplicationException("Impossibile trovare il referto.")
                        End If
                        Me.IdPaziente = New Guid(oReturn.IdPaziente)

                    End If
                End If

                If oReturn Is Nothing Then
                    Throw New ApplicationException("Impossibile trovare il referto.")
                End If

                ' Recupero i paramteri dal referto
                Me.NumeroNosologico = oReturn.NumeroNosologico
                Me.AziendaErogante = oReturn.AziendaErogante

                '
                'Modifica 2020-05-20 KYRY: Numero versione e Avvertenze
                '
                Me.NumeroVersione = oReturn.Attributi.Where(Function(x) x.Nome = "Dwh@NumeroVersione").Select(Function(y) y.Valore).FirstOrDefault
                Me.Avvertenze = oReturn.Attributi.Where(Function(x) x.Nome = "Dwh@Avvertenze").Select(Function(y) y.Valore).FirstOrDefault

                ShowPanelNumeroVersione()
                ShowPanelAvvertenze()

                '
                'Ottengo l'icona dello stato d'invio a SOLE.
                '
                Dim sHtmlEsitoSole As String = UserInterface.GetIconaStatoInvioSOLE(oReturn)
                '
                'Se sHtmlEsitoSole non è vuoto lo inserisco nella pagina altrimenti nascondo il Bootstrap Jumbotron che la dovrebbe contenere.
                '
                If String.IsNullOrEmpty(sHtmlEsitoSole) Then
                    divEsito.Visible = False
                Else
                    divEsito.Visible = True
                    contenitoreEsitoSOLE.InnerHtml = sHtmlEsitoSole
                End If


                '
                ' Se sUrlContent è valorizzato 
                '
                If Not String.IsNullOrEmpty(sUrlContent) Then
                    sUrlContent = Me.ResolveUrl(sUrlContent)
                End If

                '
                ' Imposto parametri per query lista note
                '
                Me.DataSourceNote.SelectParameters("IdReferto").DefaultValue = Me.IdReferto.ToString

                '
                ' GESTIONE DI VISUALIZZAZIONI ALL'INTERNO DEL DWH.
                ' IL TIPO DI VISUALIZZAZIONE (ESTERNO,INTERNO O PDF) E' DEFINITO IN UNA TABELLA DI DB.
                '
                Dim iTipo As DettaglioReferto_TipoVisualizzaione = DettaglioReferto_TipoVisualizzaione.Unknow
                '
                'OTTENGO LO STILE DI VISUALIZZAZIONE DEL REFERTO.
                '
                Dim rowRefertoStile As RefertiDataSet.RefertoStiliDisponibiliRow = Utility.GetRefertiStiliDisponibili(Me.IdReferto)
                If Not rowRefertoStile Is Nothing Then
                    iTipo = CType(rowRefertoStile.Tipo, DettaglioReferto_TipoVisualizzaione)
                End If

                Select Case iTipo
                    Case DettaglioReferto_TipoVisualizzaione.PDF 'PDF
                        'Valorizzo i parametri dello UserControl e eseguo il bind
                        RefertoDettaglioPdf.dettaglioReferto = oReturn
                        RefertoDettaglioPdf.IsAccessoDiretto = False
                        RefertoDettaglioPdf.CancelSelect = False
                        RefertoDettaglioPdf.DataBind()
                        RefertoDettaglioPdf.Visible = True
                    Case DettaglioReferto_TipoVisualizzaione.Esterna ' 2, 'ESTERNO
                        'Valorizzo i parametri dello UserControl e eseguo il bind
                        If String.IsNullOrEmpty(sUrlContent) Then
                            RefertoDettaglioEsterno.UrlContent = String.Format("{0}&Tipo=BOOTSTRAP_ACC_DIR", Utility.GetUrlDettaglioReferto(Me.IdReferto))
                        Else
                            RefertoDettaglioEsterno.UrlContent = sUrlContent
                        End If
                        RefertoDettaglioEsterno.CancelSelect = False
                        RefertoDettaglioEsterno.DataBind()
                        RefertoDettaglioEsterno.Visible = True

                    Case DettaglioReferto_TipoVisualizzaione.InternaWs2, DettaglioReferto_TipoVisualizzaione.InternaWs3
                        'MODIFICA ETTORE 2018-04-10
                        '
                        ' Valorizzo i parametri dello UserControl e eseguo il bind
                        '
                        RefertoDettaglioInterno.CancelSelect = False
                        RefertoDettaglioInterno.IsAccessoDiretto = True 'SIAMO NELL'ACCESSO DIRETTO!!!
                        'Questo deve essere l'URL passato dal query string
                        RefertoDettaglioInterno.UrlContent = sUrlContent
                        RefertoDettaglioInterno.DettaglioReferto = oReturn
                        RefertoDettaglioInterno.TipoVisualizzazione = iTipo
                        If Not rowRefertoStile.IsXsltTestataNull Then RefertoDettaglioInterno.XsltTestata = rowRefertoStile.XsltTestata
                        If Not rowRefertoStile.IsXsltRigheNull Then RefertoDettaglioInterno.XsltDettaglio = rowRefertoStile.XsltRighe
                        If Not rowRefertoStile.IsXsltAllegatoXmlNull Then RefertoDettaglioInterno.XsltAllegatoXml = rowRefertoStile.XsltAllegatoXml
                        'Supporta ricerca like
                        If Not rowRefertoStile.IsNomeFileAllegatoXmlNull Then RefertoDettaglioInterno.NomeFileAllegatoXml = rowRefertoStile.NomeFileAllegatoXml

                        RefertoDettaglioInterno.ShowAllegatoRTF = rowRefertoStile.ShowAllegatoRTF
                        RefertoDettaglioInterno.ShowLinkDocumentoPdf = rowRefertoStile.ShowLinkDocumentoPdf

                        RefertoDettaglioInterno.DataBind()
                        RefertoDettaglioInterno.Visible = True

                    Case Else
                        Throw New ApplicationException("Impossibile ricavare lo stile di visualizzazione del referto. Contattare l'amministratore.")
                End Select

                '************************ FINE MODIFICA SIMONE B ************************

                '
                ' Se arrivo in questo punto l'id del paziente è valorizzato e lo passo allo UserControl del pannello paziente
                '
                ucTestataPaziente.IdPaziente = Me.IdPaziente
                ucTestataPaziente.Token = Me.Token
                ucTestataPaziente.MostraSoloDatiAnagrafici = True

                'ottengo il consenso del paziente.
                'necessario per il tracciamento degli accessi.
                Me.ConsensoPaziente = ucTestataPaziente.UltimoConsensoAziendaleEspresso


                'Se sUrlContent è valorizzato allora traccio l'accesso valorizzando il parametro Operazione con il link che verrà aperto dentro l'iFrame.
                '*** sUrlContent È VALORIZZATO SE SI CLICCA DENTRO UNO DEI LINK ALL'INTERNO DI UNA VISUALIZZAZIONE ***
                If Not String.IsNullOrEmpty(sUrlContent) Then
                    TracciaAccessi.TracciaAccessiReferto(Me.CodiceRuolo, Me.DescrizioneRuolo, "Apre URL=" & sUrlContent, Me.IdPaziente, Nothing, SessionHandler.MotivoAccesso, SessionHandler.MotivoAccessoNote, Nothing, Me.ConsensoPaziente)
                Else
                    'Se sono qui sto accedendo direttamente al dettaglio del ricovero, quindi ne traccio l'accesso salvando l'id del ricovero.
                    If Me.IdReferto <> Guid.Empty Then
                        TracciaAccessi.TracciaAccessiReferto(Me.CodiceRuolo, Me.DescrizioneRuolo, "Apre referto", Me.IdPaziente, Me.IdReferto, SessionHandler.MotivoAccesso, SessionHandler.MotivoAccessoNote, 1, Me.ConsensoPaziente)
                    End If
                End If

                If Not Page.IsPostBack AndAlso Utility.AccessoDiretto_IsPageEntryPoint() Then
                    '
                    ' se la pagina non è in PostBack ed è EntryPoint allora invalido la cache
                    ' 
                    SessionHandler.InvalidaCacheTestataPaziente(Me.IdPaziente)
                End If

                'Modifica 2020-05-13 KYRY: referto variato
                '
                'Aggiorno il numero di visualizzazioni del referto (solo se l'untente non è tecnico)
                '
                Dim bUtenteTecnico As Boolean = HttpContext.Current.User.IsInRole(RoleManagerUtility2.ATTRIB_UTE_TEC)

                If Not bUtenteTecnico Then

                    Using oWcf As New WcfDwhClinico.ServiceClient
                        Utility.SetWcfDwhClinicoCredential(oWcf)
                        '
                        ' Chiamata al metodo che incrementa il numero di visualizzazioni
                        '
                        Dim erroreType As WcfDwhClinico.ErroreType = oWcf.RefertoIncrementaVisionatoById(Token, IdReferto)

                        ' Se c'è un errore lo segnalo
                        If erroreType IsNot Nothing Then
                            Throw New WsDwhException("Si è verificato un errore, contattare l'amministratore.", erroreType)
                        End If
                    End Using

                    '
                    ' Imposto il referto a visionato nelle tre cache interessate (Referti, Calendario e RefertiEpisodi)
                    '

                    ' Referti
                    Dim dsReferti As New CustomDataSource.AccessoDirettoRefertiCercaPerIdPaziente()
                    dsReferti.ImpostaRefertoVisionato(Me.IdReferto, Me.IdPaziente)

                    ' Calendario
                    Dim dsCalendario As New CalendarDataSource()
                    dsCalendario.ImpostaRefertoVisionato(Me.IdReferto, Me.IdPaziente)

                    ' Episodi
                    Dim dsRefertiEpisodi As New CustomDataSource.AccessoDirettoRefertiCercaPerNosologico()
                    dsRefertiEpisodi.ImpostaRefertoVisionato(Me.IdReferto, Me.NumeroNosologico, Me.AziendaErogante)

                    ' TODO: KYRY --> Verificare se serve davvero usare due Classi diverse per il AccessoDirettoRefertiCercaPerNosologico uno per
                    ' i referti legati all'episodio e uno specifico per la ricerca tramite parametri da url (AccessoDirettoRefertiCercaPerNosologico2)

                    ' Episodi
                    'Dim dsRefertiEpisodi2 As New CustomDataSource.AccessoDirettoRefertiCercaPerNosologico2()
                    'dsRefertiEpisodi.ImpostaRefertoVisionato(Me.IdReferto, Me.NumeroNosologico, Me.AziendaErogante)

                End If

            End If
        Catch ex As Threading.ThreadAbortException
            '
            ' Non faccio niente: causato da Redirect()
            '
            'Catch ex As CustomException(Of WcfDwhClinico.ErroreType)
            '    mbValidationCancelSelect = True
            '    NascondoPagina()
            '    divErrorMessage.Visible = True
            '    lblErrorMessage.Text = ex.ExtraData.Descrizione
            '    divPage.Visible = False
        Catch ex As ApplicationException
            mbValidationCancelSelect = True
            NascondoPagina()
            divErrorMessage.Visible = True
            lblErrorMessage.Text = ex.Message
            divPage.Visible = False
            Logging.WriteError(ex, Me.GetType.Name)
        Catch ex As Exception
            mbValidationCancelSelect = True
            NascondoPagina()
            lblErrorMessage.Text = "Errore: contattare l'amministratore!"
            divErrorMessage.Visible = True
            divPage.Visible = False
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

    Private Sub NascondoPagina()
        '
        ' Funzione usata per nascondere gli elementi della pagina in caso di errore.
        '
        divPage.Visible = False
        CType(Master.FindControl("divMenu2"), HtmlGenericControl).Visible = False
    End Sub

    Private Sub ShowAttributiAnagrafici(dettaglioReferto As WcfDwhClinico.RefertoType)
        '
        ' Passo le informazioni sull'utente allo UserControl ucInfoPaziente contenuto nella modale del dettaglio dell'episodio
        '
        Dim Nome As String = String.Empty
        Dim Cognome As String = String.Empty
        Dim CodiceFiscale As String = String.Empty
        Dim CodiceSanitario As String = String.Empty
        Dim LuogoNascita As String = String.Empty
        Dim DataNascita As Date = Nothing
        If Not dettaglioReferto Is Nothing AndAlso Not dettaglioReferto.Paziente Is Nothing Then
            If Not dettaglioReferto.Paziente.Nome Is Nothing Then
                Nome = dettaglioReferto.Paziente.Nome.ToString
            End If
            If Not dettaglioReferto.Paziente.Cognome Is Nothing Then
                Cognome = dettaglioReferto.Paziente.Cognome.ToString
            End If
            If Not dettaglioReferto.Paziente.CodiceFiscale Is Nothing Then
                CodiceFiscale = dettaglioReferto.Paziente.CodiceFiscale.ToString
            End If
            If Not dettaglioReferto.Paziente.CodiceSanitario Is Nothing Then
                CodiceSanitario = dettaglioReferto.Paziente.CodiceSanitario.ToString
            End If
            If Not dettaglioReferto.Paziente.ComuneNascita Is Nothing Then
                LuogoNascita = dettaglioReferto.Paziente.ComuneNascita.ToString
            End If
            If dettaglioReferto.Paziente.DataNascita.HasValue Then
                DataNascita = dettaglioReferto.Paziente.DataNascita.Value
            End If
        End If
    End Sub

#Region "Lista note del referto"

    Protected Sub DataSourceNote_Selected(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles DataSourceNote.Selected
        '
        ' Eseguo la ricerca
        '
        Try
            divElencoNote.Visible = False
            If Not e.ReturnValue Is Nothing Then
                Dim dtList As RefertiDataSet.FevsRefertiNoteListaDataTable = CType(e.ReturnValue, RefertiDataSet.FevsRefertiNoteListaDataTable)
                If dtList.Rows.Count > 0 Then
                    divElencoNote.Visible = True
                End If
            End If
            If e.Exception IsNot Nothing Then
                '
                ' Errore
                '
                Logging.WriteError(e.Exception, Me.GetType.Name)
                lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati."
                divErrorMessage.Visible = True
            End If
        Catch ex As Exception
            '
            ' Errore
            '
            Logging.WriteError(ex, Me.GetType.Name)
            lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati."
            divErrorMessage.Visible = True
        End Try
    End Sub

    Protected Function GetNota(ByVal sNota As Object) As String
        '
        ' Serve a fare encoding del testo che potrebbe contenere caratteri come "<", ">" ecc...
        '
        If Not sNota Is Nothing AndAlso sNota.length > 0 Then
            Return Server.HtmlEncode(sNota)
        Else
            Return Nothing
        End If
    End Function

    Protected Function GetCancellaVisibile(ByVal sRuoloDelete As Object) As Boolean
        If mbRuoloCancellazione OrElse CheckPermission(sRuoloDelete) Then
            Return True
        Else
            Return False
        End If
    End Function

    Protected Sub RepeaterNote_ItemCommand(ByVal source As Object, ByVal e As System.Web.UI.WebControls.RepeaterCommandEventArgs) Handles RepeaterNote.ItemCommand
        Dim oIdNote As Guid
        Try
            '
            ' Eseguo la cancellazione logica della nota
            '
            oIdNote = New Guid(e.CommandArgument.ToString)
            Using odata As New Referti
                odata.CancellaNote(oIdNote)
            End Using
            Me.DataSourceNote.Select()
            Me.RepeaterNote.DataBind()
        Catch ex As Exception
            Logging.WriteError(ex, Me.GetType.Name)
            lblErrorMessage.Text = "Errore durante la cancellazione della nota!"
            divErrorMessage.Visible = True
        End Try
    End Sub

#End Region

    Protected Sub btnApriAllegato_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnApriAllegato.Click
        '
        ' 1) Se non ci sono allegati: rendering dell'HTML e visualizzazione del PDF (visualizzazione sulla pagina)
        ' 2) Se c'è un solo allegato visualizzazione del PDF
        ' 3) Se ci sono più allegati visualizzazione di una pagina intermedia che visualizza una lista degli allegati con drill-down
        '
        Try
            Dim sIdReferto As String = Me.IdReferto.ToString
            If Not String.IsNullOrEmpty(sIdReferto) Then

                Dim sShowPannelloPaziente As String = Me.ShowPannelloPaziente
                Dim bShowPannelloPaziente As Boolean = True
                Dim sUrl As String = Me.ResolveUrl("~/AccessoDiretto/RefertiAllegati.aspx") & "?IdReferto=" & sIdReferto

                'Modifica leo: 2019/12/10 : se da query String: ShowPanelloPaziente = False allora passo anche ShowPanelloPaziente = False alla pagina degli allegati.
                If Not String.IsNullOrEmpty(sShowPannelloPaziente) Then
                    If Boolean.TryParse(sShowPannelloPaziente, bShowPannelloPaziente) Then
                        sUrl = Me.ResolveUrl("~/AccessoDiretto/RefertiAllegati.aspx") & "?IdReferto=" & sIdReferto & "&ShowPannelloPaziente=" & bShowPannelloPaziente.ToString
                    End If
                End If

                Me.Response.Redirect(sUrl)
            End If
        Catch ex As Threading.ThreadAbortException
            '
            ' Non faccio niente
            '
        Catch ex As Exception
            Logging.WriteError(ex, Me.GetType.Name)
            lblErrorMessage.Text = String.Format("Si è verificato un errore durante la pressione del pulsante '{0}'", btnApriAllegato.Text)
            divErrorMessage.Visible = True
        End Try
    End Sub

    Private Sub cmdEsci_Click(sender As Object, e As EventArgs) Handles cmdEsci.Click
        Try
            Utility.TraceWriteLine(String.Format("ACCESSO DIRETTO: Click cmdEsci (Pag: RefertiDettaglio.aspx). BackUrl:{0},IdReferto:{1}", SessionHandler.ListaRefertiUrl, Me.IdReferto))

            If Not String.IsNullOrEmpty(SessionHandler.AccessoDirettoListaRefertiUrl) Then
                Response.Redirect(SessionHandler.AccessoDirettoListaRefertiUrl)
            Else
                Throw New ApplicationException("La sessione di lavoro è scaduta.")
            End If
        Catch ex As ApplicationException
            NascondoPagina()
            lblErrorMessage.Text = ex.Message
            divErrorMessage.Visible = True
        Catch ex As Exception
            Logging.WriteError(ex, Me.GetType.Name)
            lblErrorMessage.Text = String.Format("Si è verificato un errore durante la pressione del pulsante '{0}'", btnApriAllegato.Text)
            divErrorMessage.Visible = True
        End Try
    End Sub

    Private Sub ShowPanelAvvertenze()

        Dim sHtml As String = String.Empty

        If Not String.IsNullOrEmpty(Me.Avvertenze) Then
            ' Divide la concatenazione di stringhe in un array di stringhe
            Dim avvertenze As String() = Me.Avvertenze.Split("|")
            ' Aggiunge ogni stringa all'html da visualizzare
            For Each avvertenza In avvertenze
                sHtml += $"<span class='text-danger'>{avvertenza}</span><br/>"
            Next
            ' Rende visibile il pannello con le avvertenze
            Me.DivPannelloAvvertenze.Visible = True
        End If

        Me.LabelAvertenze.Text = sHtml

    End Sub

    Private Sub ShowPanelNumeroVersione()

        Dim sReturn As String = String.Empty

        ' Controlla se è presente la versione e se è paggiore di 1
        If Me.NumeroVersione.HasValue AndAlso Me.NumeroVersione.Value > 1 Then
            ' Formatta la scritta della versione
            sReturn = String.Format("Versione: {0}", Me.NumeroVersione.Value)
            ' Rende visibile la label della versione
            Me.LabelVersione.Visible = True
            Me.PanelEsternoLabelVersione.Attributes.Add("class", "panel panel-default")
            Me.PanelInternoLabelVersione.Attributes.Add("class", "panel-body small")
        End If

        Me.LabelVersione.Text = sReturn

    End Sub

End Class
