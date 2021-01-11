Imports DwhClinico.Web
Imports DwhClinico.Data
Imports DwhClinico.Web.Utility
Imports DI.PortalUser2
Imports System.Runtime.InteropServices.WindowsRuntime

Partial Class Referti_RefertiDettaglio
    Inherits System.Web.UI.Page

    Private mbRuoloCancellazione As Boolean
    Private _cancelSelect As Boolean = False

#Region "Property"

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

#Region "PropertyPaziente"
    Private Property IdPaziente As Guid
        Get
            Return CType(Me.ViewState("IdPaziente"), Guid)
        End Get
        Set(value As Guid)
            Me.ViewState("IdPaziente") = value
        End Set
    End Property

    Private Property IdReferto As Guid
        Get
            Return ViewState("IdReferto")
        End Get
        Set(value As Guid)
            ViewState("IdReferto") = value
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

    Private Property SistemaErogante As String
        Get
            Return CType(Me.ViewState("SistemaErogante"), String)
        End Get
        Set(value As String)
            Me.ViewState("SistemaErogante") = value
        End Set
    End Property

    Private Property Nome As String
        Get
            Return CType(Me.ViewState("Nome"), String)
        End Get
        Set(value As String)
            Me.ViewState("Nome") = value
        End Set
    End Property

    Private Property Cognome As String
        Get
            Return CType(Me.ViewState("Cognome"), String)
        End Get
        Set(value As String)
            Me.ViewState("Cognome") = value
        End Set
    End Property

    Private Property NumeroReferto As String
        Get
            Return CType(Me.ViewState("NumeroReferto"), String)
        End Get
        Set(value As String)
            Me.ViewState("NumeroReferto") = value
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

    Public Property ConsensoPaziente As String
        Get
            Return Me.ViewState("ConsensoPaziente")
        End Get
        Set(value As String)
            Me.ViewState("ConsensoPaziente") = value
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

#End Region

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Dim oPrintingConfig As New PrintUtil.PrintingConfig
        Dim dettaglioReferto As WcfDwhClinico.RefertoType = Nothing
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

            'USO SessionHandler.IsSessioneAttiva PER VERIFICARE CHE LA SESSIONE SIA ANCORA ATTIVA.
            If SessionHandler.ValidaSessioneAccessoStandard Is Nothing OrElse SessionHandler.ValidaSessioneAccessoStandard = False Then
                _cancelSelect = True
                RedirectToHome()
                Exit Sub
            End If

            '
            ' MEMORIZZO SEMPRE SE UTENTE APPARTIENE AL RUOLO DI DEFAULT DI CANCELLAZIONE.
            '
            mbRuoloCancellazione = CheckPermission(My.Settings.Role_Delete)

            If Not Me.IsPostBack Then
                If String.IsNullOrEmpty(SessionHandler.ListaRefertiUrl) Then
                    SessionHandler.ListaRefertiUrl = Me.ResolveUrl(Request.UrlReferrer.AbsoluteUri)
                End If

                '
                ' LEGGO PARAMETRI
                '
                Dim sIdReferto As String = Me.Request.QueryString(PAR_ID_REFERTO) & ""
                Dim sUrlContent As String = Me.Request.QueryString(PAR_URL) & ""

                '
                ' ALMENO UNO TRA I PARAMETRI SURLCONTENT E SIDREFERTO DEVE ESSERE VALORIZZATO. 
                '
                If String.IsNullOrEmpty(sUrlContent) AndAlso String.IsNullOrEmpty(sIdReferto) Then
                    Throw New ApplicationException("Parametri non validi.")
                End If

                '
                '
                'ATTENZIONE:
                'L' IdReferto PUò ESSERE OTTENUTO PRENDENDOLO DIRETTAMENTE DAL PARAMETRO "IdReferto" OPPURE DAL URL DI VISUALIZZAZIONI CONTENUTO DENTRO IL PARAMETRO sUrlContent.
                'QUINDI TESTO SE L'ID DEL REFERTO OTTENUTO DAL PARAMETRO IdReferto É VALORIZZATO, SE è VUOTO ALLORA PROVO A PRENDERLO DA UrlContent.
                'UNA VOLTA TROVATO IdReferto LO METTO IN SESSIONE.
                '
                If Not String.IsNullOrEmpty(sIdReferto) Then
                    If Not Guid.TryParse(sIdReferto, Me.IdReferto) Then
                        Throw New ApplicationException("L'id del referto non è nel formato corretto.")
                    End If
                    Me.IdReferto = New Guid(sIdReferto)
                    SessionHandler.IdReferto = sIdReferto
                Else
                    Dim sIdReferto1 = Utility.GetQueryStringParameterValue(Me.Page, sUrlContent, PAR_ID_REFERTO)
                    If Not String.IsNullOrEmpty(sIdReferto1) Then
                        sIdReferto = sIdReferto1
                        Me.IdReferto = New Guid(sIdReferto)
                        SessionHandler.IdReferto = sIdReferto
                    End If
                End If

                '
                'SE A QUESTO PUNTO NON HO ANCORA TROVATO L'IdReferto PROVO A PRENDERLO DALLA SESSIONE.
                'SE NEANCHE LA SESSIONE E' VALORIZZATA ALLORA ESEGUO UN THROW DI UNA ECCEZIONE.
                '
                If String.IsNullOrEmpty(sIdReferto) Then
                    If Not String.IsNullOrEmpty(SessionHandler.IdReferto) Then
                        'SALVO NEL VIEW STATE L'ID DEL REFERTO.
                        sIdReferto = SessionHandler.IdReferto
                        Me.IdReferto = New Guid(sIdReferto)
                    End If

                    'SE SONO COSTRETTO A PRENDERE L'ID DALLA SESSIONE VUOL DIRE CHE l'ID NON E' PRESENTE NEL QUERY STRING.
                    'SE NON E' PRESENTE NEL QUERY STRING SIGNIFICA CHE HO CLICCATO UNO DEI LINK ALL?INTERNO DELLA PAGINA DI VISUALIZZAZIONI, QUINDI NASCONDO I PULSANTI RELATIVO AL REFERTO.
                    ButtonAggiungiNota.Visible = False
                    btnApriAllegato.Visible = False
                    btnExecutePrint.Visible = False
                    divElencoNote.Visible = False
                Else
                    divElencoNote.Visible = True
                    '
                    'LO FACCIO SOLO SE L'ID DEL REFERTO E' PRESENTE DENTRO AL QUERY STRING (parametro IdReferto o UrlContent)
                    'SE NON E' PRESENTE NEL QUERY STRING SIGNIFICA CHE HO CLICCATO UNO DEI LINK ALL?INTERNO DELLA PAGINA DI VISUALIZZAZIONI, QUINDI NASCONDO I PULSANTI RELATIVO AL REFERTO.
                    '
                    '
                    '
                    ' In base alla configurazione visualizzo/nascondo il pulsante per aggiungere le note 
                    '
                    ButtonAggiungiNota.Visible = (Not String.IsNullOrEmpty(sIdReferto)) AndAlso
                                                CType(My.Settings.ButtonAggiungiNota_Visible, Boolean)

                    '
                    ' Visualizzazione del pulsante per aprire gli allegati
                    '
                    btnApriAllegato.Visible = (Not String.IsNullOrEmpty(sIdReferto)) AndAlso
                                                CheckPermission(My.Settings.RefertiOpenDocument_Role)
                    btnApriAllegato.Text = My.Settings.RefertiOpenDocument_Text

                    '
                    ' Visualizzo/nascondo il pulsante di stampa e il pulsante per la configurazione stampante
                    '
                    Call PrintUtil.ConfigPrintButton(btnExecutePrint, True)
                End If

                '
                ' OTTENGO IL DETTAGLIO DEL REFERTO PER POPOLARE GLI ATTRIBUTI ANAGRAFICI DEL PAZIENTE.
                '
                If Not String.IsNullOrEmpty(sIdReferto) Then
                    Dim ds As New CustomDataSource.RefertoOttieniPerId
                    dettaglioReferto = ds.GetData(Me.Token, New Guid(sIdReferto))

                    '
                    'Se non ho trovato il referto genero un errore.
                    '
                    If dettaglioReferto Is Nothing Then
                        Throw New Exception("Impossibile ottenere il dettaglio del referto.")
                    End If

                    Me.IdPaziente = New Guid(dettaglioReferto.IdPaziente)
                    Me.AziendaErogante = dettaglioReferto.AziendaErogante
                    Me.SistemaErogante = dettaglioReferto.SistemaErogante
                    If Not dettaglioReferto.Paziente Is Nothing Then
                        Me.Nome = dettaglioReferto.Paziente.Nome
                        Me.Cognome = dettaglioReferto.Paziente.Cognome
                    End If
                    Me.NumeroNosologico = dettaglioReferto.NumeroNosologico
                    Me.NumeroReferto = dettaglioReferto.NumeroReferto

                    Me.NumeroVersione = dettaglioReferto.Attributi.Where(Function(x) x.Nome = "Dwh@NumeroVersione").Select(Function(y) y.Valore).FirstOrDefault
                    Me.Avvertenze = dettaglioReferto.Attributi.Where(Function(x) x.Nome = "Dwh@Avvertenze").Select(Function(y) y.Valore).FirstOrDefault

                    ShowPanelNumeroVersione()
                    ShowPanelAvvertenze()

                    '
                    'Ottengo l'icona dello stato d'invio a SOLE.
                    '
                    Dim sHtmlEsitoSole As String = UserInterface.GetIconaStatoInvioSOLE(dettaglioReferto)
                    '
                    'Se sHtmlEsitoSole non è vuoto lo inserisco nella pagina altrimenti nascondo il Bootstrap Jumbotron che la dovrebbe contenere.
                    '
                    If String.IsNullOrEmpty(sHtmlEsitoSole) Then
                        divEsito.Visible = False
                    Else
                        divEsito.Visible = True
                        contenitoreEsitoSOLE.InnerHtml = sHtmlEsitoSole
                    End If

                End If

                '
                'VALORIZZO I DATI PER OTTENERE LA TESTATA DEL PAZIENTE.
                'ATTENZIONE: RICAVO L'ID DEL PAZIENTE DAL DETTAGLIO DEL REFERTO.
                '
                ucTestataPaziente.IdPaziente = Me.IdPaziente
                ucTestataPaziente.Token = Me.Token
                ucTestataPaziente.CodiceRuolo = Me.CodiceRuolo
                ucTestataPaziente.DescrizioneRuolo = Me.DescrizioneRuolo
                ucTestataPaziente.MostraSoloDatiAnagrafici = True

                'ottengo l'ultimo consenso espresso del paziente.
                'lo user control ucTestataPaziente espone diverse property del paziente.
                Me.ConsensoPaziente = ucTestataPaziente.UltimoConsensoAziendaleEspresso

                ucModaleInvioLinkPerAccessoDiretto.InizialiPaziente = $"{ucTestataPaziente.CognomePaziente.Substring(0, 1)}.{ucTestataPaziente.NomePaziente.Substring(0, 1)}."
                ucModaleInvioLinkPerAccessoDiretto.NumeroReferto = dettaglioReferto.NumeroReferto
                ucModaleInvioLinkPerAccessoDiretto.DataReferto = dettaglioReferto.DataReferto

                '
                ' MODIFICA ETTORE 2018-04-16: Eseguo sempre la chiamata così l'iframe viene re-impostato sempre (c'è un Iframe)
                '
                Call SetLinkModalitaImportazione()

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
                        '
                        ' Valorizzo i parametri dello UserControl e eseguo il bind
                        '
                        RefertoDettaglioPdf.dettaglioReferto = dettaglioReferto
                        RefertoDettaglioPdf.IsAccessoDiretto = False
                        RefertoDettaglioPdf.CancelSelect = False
                        RefertoDettaglioPdf.DataBind()
                        RefertoDettaglioPdf.Visible = True

                    Case DettaglioReferto_TipoVisualizzaione.Esterna ' 2, 'ESTERNO
                        '
                        ' Valorizzo i parametri dello UserControl e eseguo il bind
                        '
                        If String.IsNullOrEmpty(sUrlContent) Then
                            RefertoDettaglioEsterno.UrlContent = Me.ResolveUrl(String.Format("~/Referti/ApreReferto.aspx?{0}={1}", PAR_ID_REFERTO, Me.IdReferto.ToString))
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
                        RefertoDettaglioInterno.IsAccessoDiretto = False  'SIAMO NELLA MODALITA' STANDARD!
                        'Questo UrlContent deve essere quello passato dal query string, che equivale all'URL cliccato sul dettaglio
                        RefertoDettaglioInterno.UrlContent = Me.Request.QueryString(PAR_URL) & ""
                        RefertoDettaglioInterno.DettaglioReferto = dettaglioReferto
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

                '
                ' Imposto parametri per query lista note
                '
                If Me.IdReferto <> Guid.Empty Then
                    Me.DataSourceNote.SelectParameters("IdReferto").DefaultValue = Me.IdReferto.ToString
                End If

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

                '
                'Modifica 2020-05-13 KYRY: referto variato
                '
                'Aggiorno il numero di visualizzazioni del referto (solo se non e un untente tecnico)
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
                    Dim dsReferti As New CustomDataSource.RefertiCercaPerIdPaziente()
                    dsReferti.ImpostaRefertoVisionato(Me.IdReferto, Me.IdPaziente)

                    ' Calendario
                    Dim dsCalendario As New CalendarDataSource()
                    dsCalendario.ImpostaRefertoVisionato(Me.IdReferto, Me.IdPaziente)

                    ' Episodi
                    Dim dsRefertiEpisodi As New CustomDataSource.RefertiCercaPerNosologico()
                    dsRefertiEpisodi.ImpostaRefertoVisionato(Me.IdReferto, Me.NumeroNosologico, Me.AziendaErogante)

                End If


            End If
        Catch ex As Threading.ThreadAbortException
            '
            ' Non faccio niente
            '
        Catch ex As ApplicationException
            ucTestataPaziente.mbValidationCancelSelect = True
            _cancelSelect = True
            divErrorMessage.Visible = True
            lblErrorMessage.Text = ex.Message
            Logging.WriteError(ex, Me.GetType.Name)
        Catch ex As Exception
            ucTestataPaziente.mbValidationCancelSelect = True
            _cancelSelect = True
            NascondoPagina()
            lblErrorMessage.Text = "Errore: contattare l'amministratore!"
            divErrorMessage.Visible = True
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

    Private Sub NascondoPagina()
        divPage.Visible = False
    End Sub

    Private Sub RedirectToHome()
        Response.Redirect(Me.ResolveUrl("~/Default.aspx"), True)
    End Sub

    Private Sub SetLinkModalitaImportazione()
        Dim sAziendaErogante As String = Me.AziendaErogante
        Dim sSistemaErogante As String = Me.SistemaErogante
        '
        ' Utilizzo la query per ricavare la testata del referto per ottenere il l'AziendaErogante e il SistemaErogante
        '
        hlModoImportazione.Visible = False

        If Not String.IsNullOrEmpty(sAziendaErogante) AndAlso Not String.IsNullOrEmpty(sSistemaErogante) Then
            Dim sUrlDocument As String = ""
            '
            ' Eseguo una query per AziendaErogante e SistemaErogante sulla tabella SistemiErogantiDocumenti
            ' per cercare l'Id del documento
            '
            Dim oCustomDataSource As New CustomDataSource.SistemiErogantiDocumenti

            Dim oRow As DocumentiDataSet.FevsSistemiErogantiDocumentiRow = oCustomDataSource.GetData(sAziendaErogante, sSistemaErogante)
            If Not oRow Is Nothing Then
                '
                ' Prelevo l'Id del documento
                '
                Dim sIDDocumento As String = oRow.IdDocumento.ToString
                '
                ' Creo un link che apre la pagina del DocumentViewer
                '
                Dim sDocumentViewerUrl As String = String.Format("{0}?{1}={2}&{3}={4}", Me.ResolveUrl("~/DocumentViewer.ashx"), PAR_ID_DOC, sIDDocumento, PAR_DOC_TABLE, "SistemiErogantiDocumenti")
                '
                ' Valorizzo l'attributo src dell'iframe contenente la modalità di generazione del referto
                '
                ModalIframe.Attributes("src") = sDocumentViewerUrl

                '
                ' ATTENZIONE: Bisogna prefissare il codice di JSOpenWindowCode con la stringa "JavaScript:" altrimenti non funziona!!!
                '
                hlModoImportazione.Visible = True
            End If

        End If

    End Sub

    Protected Sub ButtonAggiungiNota_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles ButtonAggiungiNota.Click

        Try
            Dim sIdReferto As String = Me.IdReferto.ToString
            If sIdReferto.Length > 0 Then
                '
                ' Apre form note
                '
                Me.Response.Redirect(Me.ResolveUrl(
                        String.Format("~/Referti/RefertiNote.aspx?{0}={1}", PAR_ID_REFERTO, sIdReferto)
                                    ))
            End If
        Catch ex As Threading.ThreadAbortException
            '
            ' Non faccio niente
            '
        Catch ex As ApplicationException
        Catch ex As Exception
            ucTestataPaziente.mbValidationCancelSelect = True
            _cancelSelect = True
            Logging.WriteError(ex, Me.GetType.Name)
            divErrorMessage.Visible = True
            lblErrorMessage.Text = String.Format("Si è verificato un errore durante la pressione del pulsante '{0}'", ButtonAggiungiNota.Text)
        End Try

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
                Throw New Exception
            End If
        Catch ex As Threading.ThreadAbortException
            '
            ' Non faccio niente
            '
        Catch ex As ApplicationException
        Catch ex As Exception
            ucTestataPaziente.mbValidationCancelSelect = True
            _cancelSelect = True
            Logging.WriteError(ex, Me.GetType.Name)
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati!"
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
        If sRuoloDelete Is DBNull.Value Then sRuoloDelete = ""
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
        Catch ex As Threading.ThreadAbortException
            '
            ' Non faccio niente
            '
        Catch ex As Exception
            ucTestataPaziente.mbValidationCancelSelect = True
            _cancelSelect = True
            Logging.WriteError(ex, Me.GetType.Name)
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante la cancellazione della nota!"
        End Try
    End Sub

#End Region

    Protected Sub btnExecutePrint_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnExecutePrint.Click
        Try
            Dim sUrl As String = String.Empty
            Dim sIdReferto As String = Me.IdReferto.ToString

            '
            ' 1) Cerco la configurazione fatta dall'utente
            ' 2) Se non la trovo cerco la configurazione su PrintManager
            '
            Dim oPrintingConfig As PrintUtil.PrintingConfig = PrintUtil.GetUserPrintingConfig()
            If oPrintingConfig Is Nothing Then
                oPrintingConfig = PrintUtil.GetMyPrintingConfig()
            End If

            If (Not oPrintingConfig Is Nothing) AndAlso
                (Not String.IsNullOrEmpty(oPrintingConfig.PrinterServerName)) AndAlso
                (Not String.IsNullOrEmpty(oPrintingConfig.PrinterName)) Then
                '
                '  Memorizzo in sessione il referto da stampare
                '
                Dim oList As New List(Of PrintUtil.RefertiDaStampare)
                Dim oRefertoDaStampare As New PrintUtil.RefertiDaStampare
                oRefertoDaStampare.IdReferto = Me.IdReferto
                oRefertoDaStampare.AziendaErogante = Me.AziendaErogante
                oRefertoDaStampare.SistemaErogante = Me.SistemaErogante
                If Not String.IsNullOrEmpty(Me.Cognome) Then
                    oRefertoDaStampare.Cognome = Me.Cognome
                End If
                If Not String.IsNullOrEmpty(Me.Nome) Then
                    oRefertoDaStampare.Nome = Me.Nome
                End If
                If Not String.IsNullOrEmpty(Me.NumeroNosologico) Then
                    oRefertoDaStampare.NumeroNosologico = Me.NumeroNosologico
                End If
                If Not String.IsNullOrEmpty(Me.NumeroReferto) Then
                    oRefertoDaStampare.NumeroReferto = Me.NumeroReferto
                End If
                oList.Add(oRefertoDaStampare)
                PrintUtil.SessionRefertiDaStampare = oList

                Dim sPrinterServer As String = oPrintingConfig.PrinterServerName
                Dim sPrinterName As String = oPrintingConfig.PrinterName

                '
                'Valorizzo le property dell'UserControl StampaReferti
                '
                StampaReferti.PrinterName = sPrinterName
                StampaReferti.PrinterServerName = sPrinterServer
                StampaReferti.Token = Me.Token
                StampaReferti.StampaReferto()

                '
                'Registro lo script che apre la modale Boostrap per la stampa
                '
                Dim functionJS As String = "$('#ModalStampa').modal('show');"
                ScriptManager.RegisterStartupScript(Page, Page.GetType, "LanchServerSide", functionJS, True)
                Exit Sub
            Else
                '
                ' Redirigo alla pagina di configurazione stampante
                '
                sUrl = PrintUtil.GetPrinterConfigPage(sIdReferto)
                Me.Response.Redirect(Me.ResolveUrl(sUrl), False)

            End If

        Catch ex As Threading.ThreadAbortException
            '
            ' Causata dal redirect: non faccio niente
            '
        Catch ex As Exception
            ucTestataPaziente.mbValidationCancelSelect = True
            _cancelSelect = True
            Logging.WriteError(ex, Me.GetType.Name)
            divErrorMessage.Visible = True
            lblErrorMessage.Text = String.Format("Si è verificato un errore durante la pressione del pulsante '{0}'", btnExecutePrint.Text)
        End Try
    End Sub

    Protected Sub btnApriAllegato_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnApriAllegato.Click
        '
        ' Questo pulsante per ora è usato esclusivamente da AUSL per ovviare alla stampa degli allegati dei referti
        ' 1) Se non ci sono allegati: rendering dell'HTML e visualizzazione del PDF (visualizzazione sulla pagina)
        ' 2) Se c'è un solo allegato visualizzazione del PDF
        ' 3) Se ci sono più allegati visualizzazione di una pagina intermedia che visualizza una lista degli allegati con drill-down
        '
        Try
            Dim sIdReferto As String = Me.IdReferto.ToString
            If Not String.IsNullOrEmpty(sIdReferto) Then
                Dim sUrl As String = Me.ResolveUrl("~/Referti/RefertiAllegati.aspx") & "?IdReferto=" & sIdReferto
                Me.Response.Redirect(sUrl)
            End If

        Catch ex As Threading.ThreadAbortException
            '
            ' Causata dal redirect: non faccio niente
            '
        Catch ex As Exception
            ucTestataPaziente.mbValidationCancelSelect = True
            _cancelSelect = True
            Logging.WriteError(ex, Me.GetType.Name)
            divErrorMessage.Visible = True
            lblErrorMessage.Text = String.Format("Si è verificato un errore durante la pressione del pulsante '{0}'", btnApriAllegato.Text)
        End Try
    End Sub

    Private Sub DataSourceNote_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles DataSourceNote.Selecting
        '
        ' se _cancelSelect = true allora non eseguo la selects
        '
        e.Cancel = _cancelSelect
    End Sub

    Private Sub cmdEsci_Click(sender As Object, e As EventArgs) Handles cmdEsci.Click
        Try
            Utility.TraceWriteLine(String.Format("Click cmdEsci (Pag: RefertiDettaglio.aspx). BackUrl:{0},IdReferto:{1}", SessionHandler.ListaRefertiUrl, Me.IdReferto))

            'SE SESSIONHANDLER.LISTAREFERTIURL E' VUOTA ALLORA ESEGUO UN REDIRECT ALLA HOME.
            If Not String.IsNullOrEmpty(SessionHandler.ListaRefertiUrl) Then
                Response.Redirect(SessionHandler.ListaRefertiUrl)
            Else
                RedirectToHome()
            End If
        Catch ex As Exception
            divErrorMessage.Visible = True
            lblErrorMessage.Text = String.Format("Si è verificato un errore durante la pressione del pulsante '{0}'", cmdEsci.Text)
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

    Private Sub btnExecutePrint_PreRender(sender As Object, e As EventArgs) Handles btnExecutePrint.PreRender
        Try
            btnExecutePrint.Visible = My.Settings.Print_Enabled
        Catch ex As Exception
            divErrorMessage.Visible = True
            lblErrorMessage.Text = String.Format("Si è verificato un errore, contattare l'amministratore.")
            Logging.WriteError(ex, Me.GetType.Name)
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
