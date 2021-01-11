Imports DwhClinico.Data
Imports DwhClinico.Web
Imports DwhClinico.Web.Utility
Imports System.Security
Imports DI.PortalUser2

Partial Class AccessoDiretto_Ricovero
    Inherits System.Web.UI.Page

    Private mbCancelSelectOperation As Boolean = False
    Private mstrPageID As String

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
                ' TODO: lettura ultimo ruolo: cosa succede se i dati vengono cancellati dal database?
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

    Public Property IdRicovero As Guid
        Get
            Return Me.ViewState("IdRicovero")
        End Get
        Set(value As Guid)
            Me.ViewState("IdRicovero") = value
        End Set
    End Property
#End Region

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Dim sIdRicovero As String = Nothing
        Dim sAziendaErogante As String = Nothing
        Dim sNumeroNosologico As String = Nothing
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
                Throw New ApplicationException("La sessione di lavoro è scaduta.")
            End If

            '
            ' Id della pagina
            '
            mstrPageID = Me.GetType.Name

            '
            ' Solo la prima volta
            '
            If Not IsPostBack Then
                '
                ' Ottengo i parametri da QueryString
                '
                sIdRicovero = Me.Request.QueryString(PAR_ID_RICOVERO)
                sAziendaErogante = Me.Request.QueryString(PAR_AZIENDA_EROGANTE)
                sNumeroNosologico = Me.Request.QueryString(PAR_NUMERO_NOSOLOGICO)

                '
                ' In base all' EntryPoint mostro o nascondo le voci del menu.
                '
                Dim oMenu As Menu = CType(Master.FindControl("MenuMain2"), Menu)
                oMenu.DataBind()
                Dim menuItemPazienti As MenuItem = UserInterface.GetMenuItem(oMenu, "Pazienti")
                'Dim menuItemReferti As MenuItem = UserInterface.GetMenuItem(oMenu, "Referti")

                '
                ' Controllo che gli item siano valorizzati correttamente.
                '
                If menuItemPazienti Is Nothing Then
                    Throw New ApplicationException("La voce del menu ""Pazienti"" non esiste.")
                End If
                'If menuItemReferti Is Nothing Then
                '    Throw New ApplicationException("La voce del menu ""Referti"" non esiste.")
                'End If

                '
                ' Verifico se la pagina è entry point
                '
                Dim bPageEntryPoint As Boolean = Utility.AccessoDiretto_IsPageEntryPoint()

                If bPageEntryPoint Then
                    '
                    ' Se la pagina è EntryPoint resetto le varibili di sessione legate all'url del menu.
                    '
                    SessionHandler.AccessoDirettoUrlPazienti = Nothing
                    SessionHandler.AccessoDirettoUrlReferti = Nothing
                    oMenu.Items.Remove(menuItemPazienti)
                    '
                    ' Nascondo il menu nel caso in cui la pagina sia EntryPoint
                    '
                    'CType(Master.FindControl("divMenu2"), HtmlGenericControl).Visible = False

                    '
                    ' Forzo il nmotivo dell'accesso a "Paziente in carico" se la pagina è EntryPoint
                    '
                    SessionHandler.MotivoAccesso = New ListItem(MOTIVO_ACCESSO_PAZIENTE_IN_CARICO_TEXT, MOTIVO_ACCESSO_PAZIENTE_IN_CARICO_ID)
                Else
                    Dim urlPazienti As String = SessionHandler.AccessoDirettoUrlPazienti
                    Dim urlReferti As String = SessionHandler.AccessoDirettoUrlReferti
                    If Not String.IsNullOrEmpty(urlPazienti) Then
                        menuItemPazienti.NavigateUrl = urlPazienti
                        'menuItemReferti.NavigateUrl = urlReferti
                    ElseIf Not String.IsNullOrEmpty(urlReferti) Then
                        'menuItemReferti.NavigateUrl = urlReferti
                        oMenu.Items.Remove(menuItemPazienti)
                    End If
                End If

                '
                ' Devo Ottenere l'id del ricovero e l'id del paziente per valorizzare la testata del paziente
                '
                Dim oDettagliOEpisodio As WcfDwhClinico.EpisodioType = Nothing
                If Not String.IsNullOrEmpty(sIdRicovero) Then
                    Dim oIdRicovero As Guid = Nothing
                    If Guid.TryParse(sIdRicovero, oIdRicovero) Then
                        Me.IdRicovero = oIdRicovero
                    Else
                        Throw New ApplicationException("L'id dell'episodio non è corretto.")
                    End If
                    '
                    ' Eseguo la query del WS per ottenere l'id del paziente.
                    ' In questo caso i dati restituiti dal metodo vengono salvati in cache quindi anche se la query viene eseguita più volte non è un problema
                    '
                    Dim ds As New CustomDataSource.AccessoDirettoEpisodioOttieniPerId
                    oDettagliOEpisodio = ds.GetData(Me.Token, Me.IdRicovero)
                    If oDettagliOEpisodio Is Nothing Then
                        Throw New ApplicationException("Impossibile trovare l'episodio.")
                    End If
                    Me.IdPaziente = New Guid(oDettagliOEpisodio.IdPaziente)
                ElseIf Not String.IsNullOrEmpty(sNumeroNosologico) AndAlso Not String.IsNullOrEmpty(sAziendaErogante) Then
                    '
                    ' eseguo la query per ottenere idReferto e idPaziente
                    '
                    Dim ds As New CustomDataSource.AccessoDirettoEpisodioOttieniPerNosologico
                    oDettagliOEpisodio = ds.GetData(Me.Token, sNumeroNosologico, sAziendaErogante)
                    If oDettagliOEpisodio Is Nothing Then
                        Throw New ApplicationException("Impossibile trovare l'episodio.")
                    End If
                    Me.IdPaziente = New Guid(oDettagliOEpisodio.IdPaziente)
                    Me.IdRicovero = New Guid(oDettagliOEpisodio.Id)
                Else
                    Throw New ApplicationException("La combinazione dei filtri è errata.")
                End If

                If Not Page.IsPostBack AndAlso Utility.AccessoDiretto_IsPageEntryPoint() Then
                    '
                    ' se la pagina non è in PostBack ed è EntryPoint allora invalido la cache
                    ' 
                    SessionHandler.InvalidaCacheTestataPaziente(Me.IdPaziente)
                End If

                'valorizzo i parametri necessari allo userControl della testata del paziente.
                ucTestataPaziente.IdPaziente = Me.IdPaziente
                ucTestataPaziente.Token = Me.Token
                ucTestataPaziente.MostraSoloDatiAnagrafici = True


                'ottengo il consenso del paziente.
                'necessario per il tracciamento degli accessi.
                Me.ConsensoPaziente = ucTestataPaziente.UltimoConsensoAziendaleEspresso

                Dim sXml As String = GetXmlRicovero(oDettagliOEpisodio)
                If String.IsNullOrEmpty(sXml) Then
                    Throw New Exception("Si è verificato un errore durante la generazione dell'xml relativo all'episodio.")
                End If
                ShowAttributiAnagrafici(oDettagliOEpisodio)
                Call ShowTestataRicovero(sXml)
                WebGridEventi.DataBind()

                ' Traccia accessi
                '(il bind dei dati viene eseguito prima di questa chiamata quindi se si dovesse verificare un errore, l'utente non vedrebbe il ricovero e non verrebbe tracciato nemmeno l'accesso)
                TracciaAccessi.TracciaAccessiRicovero(Me.CodiceRuolo, Me.DescrizioneRuolo, "Apre Episodio", Me.IdPaziente, Me.IdRicovero, SessionHandler.MotivoAccesso, SessionHandler.MotivoAccessoNote, 1, Me.ConsensoPaziente)
            End If

            '
            'RENDERING PER BOOTSTRAP
            'Converte i tag html generati dalla GridView per la paginazione
            ' e li adatta alle necessita dei CSS Bootstrap
            '
            WebGridEventi.PagerStyle.CssClass = "pagination-gridview"
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "gridPagination", HelperGridView.GetScriptPaginationForBootstrap(), True)
        Catch ex As Threading.ThreadAbortException
            mbCancelSelectOperation = True
        Catch ex As ApplicationException
            mbCancelSelectOperation = True
            divErrorMessage.Visible = True
            lblErrorMessage.Text = ex.Message
            NascondoPagina()
            Logging.WriteError(ex, Me.GetType.Name)
        Catch ex As Exception
            mbCancelSelectOperation = True
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante il caricamento della pagina!"
            NascondoPagina()
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

    Private Sub NascondoPagina()
        divPage.Visible = False
        CType(Master.FindControl("divMenu2"), HtmlGenericControl).Visible = False
    End Sub

    Private Sub WebGridEventi_PreRender(sender As Object, e As EventArgs) Handles WebGridEventi.PreRender
        '
        'Render per Bootstrap
        'Crea la Table con Theader e Tbody se l'header non è nothing.
        '
        If Not WebGridEventi.HeaderRow Is Nothing Then
            WebGridEventi.UseAccessibleHeader = True
            WebGridEventi.HeaderRow.TableSection = TableRowSection.TableHeader
        End If
    End Sub

#Region "Eventi objectDataSource"

#Region "DataSourceRicoveroEventi"

    Protected Sub DataSourceRicoveroEventi_Selected(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles DataSourceRicoveroEventi.Selected
        Try
            WebGridEventi.Visible = False
            divErrorMessage.Visible = False

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
                    Dim bPagerStyleVisible As Boolean = True
                    WebGridEventi.Visible = True
                Else
                    Dim sMsgNoRecord As String = "Non è stato trovato nessun referto. Modificare eventualmente i parametri di filtro."
                    divMessage.Visible = True
                    divMessage.InnerText = sMsgNoRecord
                    WebGridEventi.Visible = False
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

    Protected Sub DataSourceRicoveroEventi_Selecting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.ObjectDataSourceSelectingEventArgs) Handles DataSourceRicoveroEventi.Selecting
        Try
            If mbCancelSelectOperation Then
                e.Cancel = True
                Exit Sub
            End If
            e.InputParameters("Token") = Me.Token
            e.InputParameters("IdRicovero") = Me.IdRicovero
        Catch ex As Exception
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati!"
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

#End Region

#End Region

#Region "Testata Episodio"

    Private Sub ShowAttributiAnagrafici(dettaglioRicovero As WcfDwhClinico.EpisodioType)
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
    End Sub

    Private Function GetXmlRicovero(dettaglioRicovero As WcfDwhClinico.EpisodioType) As String
        Try
            Dim sXml As String = String.Empty
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
                sXml = New IO.StreamReader(memoryStream).ReadToEnd
            End Using
            Return sXml
        Catch ex As Exception
            Logging.WriteError(ex, "GetXmlTestataRicovero: Si è verificato un errore durante la lettura delle info di ricovero.")
            Throw
        End Try
    End Function

    Private Sub ShowTestataRicovero(ByVal sXml As String)
        Try
            XmlInfoRicovero.DocumentContent = sXml
            XmlInfoRicovero.DataBind()
        Catch ex As Exception
            Logging.WriteError(ex, "ShowTestataRicovero: Si è verificato un errore durante la visualizzazione delle info di ricovero.")
            Throw
        End Try
    End Sub

#End Region

#Region "Funzioni del MarkUp"
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

End Class
