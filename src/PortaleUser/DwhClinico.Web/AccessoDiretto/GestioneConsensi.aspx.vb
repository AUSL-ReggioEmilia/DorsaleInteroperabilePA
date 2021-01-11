Imports DwhClinico.Web.Utility
Imports DwhClinico.Data
Imports DI.PortalUser2

Public Class GestioneConsensi1
    Inherits System.Web.UI.Page

    Private mbValidationCancelSelect As Boolean = False
    Private mbConsensoGenericoNegato As Boolean = False 'Memorizzo se il paziente ha un consenso GENERICO NEGATO

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

    Private Property IsPazienteMinorenne As Boolean
        Get
            Return CType(ViewState("-IsPazienteMinorenne -"), Boolean)
        End Get
        Set(ByVal value As Boolean)
            ViewState("-IsPazienteMinorenne -") = value
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

    Public Property TipoConsensoPaziente As SacConsensiDataAccess.TipoConsenso
        '
        ' Salvo l'Id del paziente nel ViewState per averlo per tutta la durata della pagina
        '
        Get
            Return Me.ViewState("meTipoConsenso")
        End Get
        Set(value As SacConsensiDataAccess.TipoConsenso)
            Me.ViewState("meTipoConsenso") = value
        End Set
    End Property

    Private Property UrlReferrer As String
        '
        ' Salva nel ViewState la pagina di provenienza
        '
        Get
            Return CType(Me.ViewState("UrlReferrer"), String)
        End Get
        Set(value As String)
            Me.ViewState("UrlReferrer") = value
        End Set
    End Property
#End Region

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Try
            If SessionHandler.ValidaSessioneAccessoDiretto = Nothing Then
                '
                ' Se sono qui la sessione è scaduta e quindi mostro un messaggio di errore.
                '
                Throw New ApplicationException("La sessione di lavoro è scaduta.")
            End If

            '
            ' Ottengo l'id del paziente dal QueryString e lo salvo nel ViewState.
            '
            Dim sIdPaziente As String = Me.Request.QueryString("idpaziente")


            If Not Page.IsPostBack Then
                '
                ' Salvo nel ViewState l'id del paziente.
                '
                Me.IdPaziente = New Guid(sIdPaziente)

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


                Dim urlPazienti As String = SessionHandler.AccessoDirettoUrlPazienti
                Dim urlReferti As String = SessionHandler.AccessoDirettoUrlReferti
                If Not String.IsNullOrEmpty(urlPazienti) Then
                    menuItemPazienti.NavigateUrl = urlPazienti
                ElseIf Not String.IsNullOrEmpty(urlReferti) Then
                    oMenu.Items.Remove(menuItemPazienti)
                End If

                Me.UrlReferrer = urlReferti

                '
                ' Passo alla testata del paziente il token e l'id del paziente per fare il bind dei dati
                ' Lo faccio sempre
                '
                ucTestataPaziente.IdPaziente = New Guid(sIdPaziente)
                ucTestataPaziente.Token = Me.Token
                ucTestataPaziente.MostraSoloDatiAnagrafici = True

                PopolaCmdInformativa()

                cmdCancellaConsensi.Visible = Utility.CheckPermission(RoleManagerUtility2.ATTRIB_CONSENSO_NEG_CHANGE)
            End If

        Catch ex As Threading.ThreadAbortException
            '
            ' Non faccio niente
            '
        Catch ex As ApplicationException
            ucTestataPaziente.mbValidationCancelSelect = True
            mbValidationCancelSelect = True
            divErrorMessage.Visible = True
            lblErrorMessage.Text = ex.Message
            NascondoPagina()
            Logging.WriteError(ex, Me.GetType.Name)
        Catch ex As Exception
            ucTestataPaziente.mbValidationCancelSelect = True
            mbValidationCancelSelect = True
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

#Region "Funzioni Markup"

    Protected Function VisibilitaConcessioneConsenso(objRow As Object) As Boolean
        If My.Settings.NuovaGestioneConsensi = True And mbConsensoGenericoNegato Then
            'Non posso acquisire nessun consenso
            Return False
        Else
            Dim rigaConsenso As SacConsensiDataAccess.Consensi = CType(objRow, SacConsensiDataAccess.Consensi)
            Dim ultimoConsenso As String = ucTestataPaziente.UltimoConsensoAziendaleEspresso
            Return UserInterface.VisibilitaConcessioneConsenso(rigaConsenso, ultimoConsenso)
        End If
    End Function

    Protected Function VisibilitaNegazioneConsenso(objRow As Object) As Boolean
        Dim rigaConsenso As SacConsensiDataAccess.Consensi = CType(objRow, SacConsensiDataAccess.Consensi)
        Return UserInterface.VisibilitaNegazioneConsenso(rigaConsenso)
    End Function

    Protected Function GetColConsenso(ByVal oStato As Object) As String
        Return UserInterface.GetColConsenso(oStato)
    End Function

    Protected Function GetColTipoConsenso(ByVal oTipo As Object) As String
        Return UserInterface.GetColTipoConsenso(oTipo)
    End Function
#End Region

#Region "ModificaConsenso"
    Private Sub cmdCancellaConsensi_Click(sender As Object, e As EventArgs) Handles cmdCancellaConsensi.Click
        Try
            Dim oSacConsensiWs As SacConsensiDataAccess.ConsensiSoap

            ' DOPPIO CONTROLLO SULL'ATTRIBUTO CONSENSI_DELETE_ALL
            If Not HttpContext.Current.User.IsInRole(RoleManagerUtility2.ATTRIB_CONSENSI_DELETE_ALL) Then
                Exit Sub
            End If
            '
            ' Istanzio il webservice e imposto le credenziali in base al metodo di autenticazione Integrata(NTLM)/Basic
            '
            oSacConsensiWs = New SacConsensiDataAccess.ConsensiSoapClient
            If oSacConsensiWs Is Nothing Then
                Throw New Exception("Errore: il Web Service SacConsensiDataAccess.ConsensiSoapClient è nothing.")
            End If
            Utility.SetWsConsensiCredential(oSacConsensiWs)
            '
            ' INVOCO ConsensiEliminaPerIdPaziente
            Dim body As New SacConsensiDataAccess.ConsensiEliminaPerIdPazienteRequestBody(Me.IdPaziente.ToString, HttpContext.Current.User.Identity.Name)
            Dim request As New SacConsensiDataAccess.ConsensiEliminaPerIdPazienteRequest(body)
            oSacConsensiWs.ConsensiEliminaPerIdPaziente(request)

            ucTestataPaziente.InvalidaCache()

            SessionHandler.AccessoDirettoCancellaCache = True

            '
            ' Torno al chiamante
            '
            Esci()
        Catch ex As Exception
            ucTestataPaziente.mbValidationCancelSelect = True
            mbValidationCancelSelect = True
            NascondoPagina()
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'esecuzione del comando di Reset Consensi."
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub


    Private Sub Esci()
        Try
            Response.Redirect(Me.UrlReferrer, False)
        Catch ex As Threading.ThreadAbortException
            '
            ' Non faccio niente
            '
        Catch ex As Exception
            '
            ' Non faccio niente
            '
        End Try
    End Sub

    Public Sub OpenModaleModificaConsenso(DescrizioneConsenso As String, StatoConsenso As Boolean)
        '
        ' compongo il titolo della modale boostrap
        '
        PageTitle.InnerText = String.Format("Inserimento Consenso {0}", DescrizioneConsenso.ToUpper)

        '
        ' Resetto la sessione perchè ho premuto il pulsante per aprire la modale di inserimento
        '
        SessionHandler.AccessoDirettoConsensoInserito = False

        '
        ' in base allo stato del consenso mostro come selectedvalue "Positivo" o "negativo"
        '
        If StatoConsenso Then
            cboStatoConsenso.SelectedValue = "0"
        Else
            cboStatoConsenso.SelectedValue = "1"
        End If

        Call PageDataBind(ucTestataPaziente.DataNascitaPaziente)

        '
        ' registro lo script lato client per aprire la modale bootstrap
        '
        Dim functionJS As String = "$('#ModaleModificaConsenso').modal('show');"
        ScriptManager.RegisterStartupScript(Page, Page.GetType, "LanchServerSide", functionJS, True)
    End Sub

    Private Sub PageDataBind(Data As String)
        Try
            Dim DataNascita As Date = CType(Data, Date)

            '
            ' Ottengo le informazioni dell'utente corrente
            '
            Dim oCurrentUser As CurrentUser = GetCurrentUser()
            Dim oDettaglioUtente As Utility.DettaglioUtente = Utility.GetDettaglioUtente(oCurrentUser.DomainName, oCurrentUser.UserName)

            '
            ' Verifico se le informazioni dell'utente sono valorizzati
            '
            If oDettaglioUtente Is Nothing Then
                Throw New Exception("Dati dell'operatore non trovati!")
            End If
            lblUtenteNome.Text = oDettaglioUtente.NomeCompleto
            Dim Eta As Integer = Utility.CalcolaEta(DataNascita, Now)
            IsPazienteMinorenne = CBool(Eta < 18)
            Call InitUtenteAutorizzatoreDelMinore(IsPazienteMinorenne, Me.IdPaziente)
        Catch ex As Exception
            ucTestataPaziente.mbValidationCancelSelect = True
            mbValidationCancelSelect = True
            '
            ' Gestione dell'errore
            '
            Dim sMsg As String = If(ex.Message Is Nothing, "Errore durante il caricamento dei dati paziente e utente.", ex.Message)
            lblErrorMessage.Text = sMsg
            NascondoPagina()
            divErrorMessage.Visible = True
            Logging.WriteError(ex, sMsg)
        Finally
        End Try

    End Sub

    Private Sub InitUtenteAutorizzatoreDelMinore(ByVal bPazienteMinorenne As Boolean, ByVal IdPaziente As Guid)
        If IsPazienteMinorenne Then
            LoadComboRelazioniConMinore(cmbAutorizzatoreMinoreRelazioneColMinore, Utility.GetRelazioniConMinore())
            Dim oUtenteAutorizatoreMinore As UtenteAutorizzatoreMinore = Session(SESS_AUTORIZZATORE_CONSENSO_MINORE & IdPaziente.ToString)
            If Not oUtenteAutorizatoreMinore Is Nothing Then
                txtAutorizzatoreMinoreCognome.Text = oUtenteAutorizatoreMinore.Cognome
                txtAutorizzatoreMinoreNome.Text = oUtenteAutorizatoreMinore.Nome
                txtAutorizzatoreDataNascita.Text = oUtenteAutorizatoreMinore.DataNascita.ToString("d")
                txtAutorizzatoreLuogoNascita.Text = oUtenteAutorizatoreMinore.LuogoNascita
                cmbAutorizzatoreMinoreRelazioneColMinore.SelectedValue = oUtenteAutorizatoreMinore.RelazioneColMinoreId
            End If
        End If
        '
        ' Nascondo visualizzo i controlli dei dati dell'autorizzatore
        '
        trUtenteAutorizzatoreTitle.Visible = bPazienteMinorenne
        trUtenteAutorizzatoreCognome.Visible = bPazienteMinorenne
        trUtenteAutorizzatoreNome.Visible = bPazienteMinorenne
        trUtenteAutorizzatoreDataNascita.Visible = bPazienteMinorenne
        trUtenteAutorizzatoreLuogoNascita.Visible = bPazienteMinorenne
        trUtenteAutorizzatoreRelazioneColMinore.Visible = bPazienteMinorenne
        '
        ' Disabilito/Abilito i controlli di validazione associati ai controlli sopra

        ReqAutorizzatoreMinoreCognome.Enabled = bPazienteMinorenne
        ReqAutorizzatoreMinoreNome.Enabled = bPazienteMinorenne
        ReqAutorizzatoreDataNascita.Enabled = bPazienteMinorenne
        ReqAutorizzatoreLuogoNascita.Enabled = bPazienteMinorenne
        RangeValAutorizzatoreDataNascita.Enabled = bPazienteMinorenne
    End Sub

    Private Sub InserimentoConsenso(oSacConsensiWs As SacConsensiDataAccess.ConsensiSoap, oConsenso As SacConsensiDataAccess.Consenso)
        Dim body As New SacConsensiDataAccess.ConsensiAggiungiRequestBody(oConsenso)
        Dim request As New SacConsensiDataAccess.ConsensiAggiungiRequest(body)
        Call oSacConsensiWs.ConsensiAggiungi(request)
    End Sub


    Private Sub SalvaConsenso_OLD(sender As Object, e As EventArgs)
        '
        ' Pulsante Conferma
        '
        Dim oSacConsensiWs As SacConsensiDataAccess.ConsensiSoap = Nothing
        Dim sOperatoreCognome As String = String.Empty
        Dim sOperatoreNome As String = String.Empty
        Dim sOperatoreAccount As String = String.Empty
        Dim bStatoConsenso As Boolean = False
        Dim oAttributiType As SacConsensiDataAccess.AttributiType = Nothing
        Try
            If SessionHandler.AccessoDirettoConsensoInserito = False Then

                Dim iConsensoStato As Integer = CInt(cboStatoConsenso.SelectedValue)
                If iConsensoStato > -1 Then
                    bStatoConsenso = CBool(iConsensoStato)
                    '
                    ' Prendo informazioni sull'utente corrente
                    '
                    Dim oCurrentUser As CurrentUser = GetCurrentUser()

                    Dim oDettaglioUtente As Utility.DettaglioUtente = Utility.GetDettaglioUtente(oCurrentUser.DomainName, oCurrentUser.UserName)
                    sOperatoreAccount = oDettaglioUtente.AccountCompleto
                    sOperatoreCognome = oDettaglioUtente.Cognome
                    sOperatoreNome = oDettaglioUtente.Nome

                    If IsPazienteMinorenne Then
                        '
                        ' Salvo in sessione i dati dell'autorizzatore
                        ' I dati sono già stati validati, anche la data di nascita quindi la posso convertire direttamente
                        '
                        Dim oDataNascita As DateTime = Nothing
                        'La data è già stata validata lato client quindi posso convertire tranquillamente
                        Date.TryParse(txtAutorizzatoreDataNascita.Text, oDataNascita)
                        'Salvo i dati in sessione
                        Session(SESS_AUTORIZZATORE_CONSENSO_MINORE & Me.IdPaziente.ToString) = New UtenteAutorizzatoreMinore(
                                                                                      txtAutorizzatoreMinoreCognome.Text,
                                                                                      txtAutorizzatoreMinoreNome.Text,
                                                                                      oDataNascita,
                                                                                      txtAutorizzatoreLuogoNascita.Text,
                                                                                      cmbAutorizzatoreMinoreRelazioneColMinore.SelectedItem.Value)
                        '
                        ' Creo la classe con i dati del consenso da passare al metodo di inserimento consenso
                        '
                        oAttributiType = Utility.BuildAttributiAutorizzatoreDelMinore(txtAutorizzatoreMinoreCognome.Text,
                                                                                      txtAutorizzatoreMinoreNome.Text,
                                                                                      oDataNascita,
                                                                                      txtAutorizzatoreLuogoNascita.Text,
                                                                                      cmbAutorizzatoreMinoreRelazioneColMinore.SelectedItem.Text
                                                                                      )

                    End If
                    '--------------------------------------------------------------------------------------------------------
                    '
                    ' Istanzio il webservice e imposto le credenziali in base al metodo di autenticazione Integrata(NTLM)/Basic
                    '
                    oSacConsensiWs = New SacConsensiDataAccess.ConsensiSoapClient
                    If oSacConsensiWs Is Nothing Then
                        Throw New Exception("Errore: il Web Service SacConsensiDataAccess.ConsensiSoapClient è nothing.")
                    End If
                    Call Utility.SetWsConsensiCredential(oSacConsensiWs)
                    Dim oConsenso As SacConsensiDataAccess.Consenso = PopoloDatiConsenso(TipoConsensoPaziente, bStatoConsenso,
                                                     ucTestataPaziente.NomeAnagraficaErogante, ucTestataPaziente.CodiceAnagraficaErogante,
                                                      ucTestataPaziente.CognomePaziente, ucTestataPaziente.NomePaziente, ucTestataPaziente.CodiceFiscale, ucTestataPaziente.DataNascitaPaziente, ucTestataPaziente.CodiceSanitario,
                                                      sOperatoreAccount, sOperatoreCognome, sOperatoreNome,
                                                      oCurrentUser.HostName, oAttributiType)


                    Call InserimentoConsenso(oSacConsensiWs, oConsenso)
                    If bStatoConsenso = False Then
                        Select Case TipoConsensoPaziente
                            Case SacConsensiDataAccess.TipoConsenso.Generico
                                '1) Nego DOSSIER
                                oConsenso = PopoloDatiConsenso(SacConsensiDataAccess.TipoConsenso.Dossier, False,
                                                    ucTestataPaziente.NomeAnagraficaErogante, ucTestataPaziente.CodiceAnagraficaErogante,
                                                      ucTestataPaziente.CognomePaziente, ucTestataPaziente.NomePaziente, ucTestataPaziente.CodiceFiscale, ucTestataPaziente.DataNascitaPaziente, ucTestataPaziente.CodiceSanitario,
                                                      sOperatoreAccount, sOperatoreCognome, sOperatoreNome,
                                                      oCurrentUser.HostName, oAttributiType)
                                Call InserimentoConsenso(oSacConsensiWs, oConsenso)
                                '2) Nego DOSSIERSTORICO
                                oConsenso = PopoloDatiConsenso(SacConsensiDataAccess.TipoConsenso.DossierStorico, False,
                                                    ucTestataPaziente.NomeAnagraficaErogante, ucTestataPaziente.CodiceAnagraficaErogante,
                                                      ucTestataPaziente.CognomePaziente, ucTestataPaziente.NomePaziente, ucTestataPaziente.CodiceFiscale, ucTestataPaziente.DataNascitaPaziente, ucTestataPaziente.CodiceSanitario,
                                                      sOperatoreAccount, sOperatoreCognome, sOperatoreNome,
                                                      oCurrentUser.HostName, oAttributiType)
                                Call InserimentoConsenso(oSacConsensiWs, oConsenso)

                            Case SacConsensiDataAccess.TipoConsenso.Dossier
                                '1) Nego DOSSIERSTORICO
                                oConsenso = PopoloDatiConsenso(SacConsensiDataAccess.TipoConsenso.DossierStorico, False,
                                                     ucTestataPaziente.NomeAnagraficaErogante, ucTestataPaziente.CodiceAnagraficaErogante,
                                                      ucTestataPaziente.CognomePaziente, ucTestataPaziente.NomePaziente, ucTestataPaziente.CodiceFiscale, ucTestataPaziente.DataNascitaPaziente, ucTestataPaziente.CodiceSanitario,
                                                      sOperatoreAccount, sOperatoreCognome, sOperatoreNome,
                                                      oCurrentUser.HostName, oAttributiType)
                                Call InserimentoConsenso(oSacConsensiWs, oConsenso)

                            Case SacConsensiDataAccess.TipoConsenso.DossierStorico
                                'NON DEVO FARE NULLA
                        End Select
                    End If
                Else
                    '
                    ' Gestione dell'errore
                    '
                    lblErrorMessage.Text = "E' necessario selezionare un valore della casella 'consenso' per proseguire."
                End If

                '
                ' Memorizzo che il consenso è già stato acquisito
                '
                SessionHandler.AccessoDirettoConsensoInserito = True
            End If

            '
            ' Registro lo script lato client per chiudere la modale
            '
            Dim functionJS As String = "$('#ModaleModificaConsenso').modal('hide');"
            ScriptManager.RegisterStartupScript(Page, Page.GetType, "LanchServerSide", functionJS, True)
            '
            ' Invalido la cache della testata del paziente e rieseguo il bind in modo da visualizzare i dati corretti.
            '
            ucTestataPaziente.InvalidaCache()

            '
            ' Nascondo le informazione dei consensi contenute nella testata del paziente
            '
            ucTestataPaziente.MostraSoloDatiAnagrafici = True

            '
            ' Aggiorno i dati contenuti nella griglia
            '
            GridViewConsensiSAC.DataBind()
            SessionHandler.AccessoDirettoCancellaCache = True

        Catch ex As System.Web.Services.Protocols.SoapException
            '
            ' Messaggio di errore
            '
            Dim sMsgErr As String = "Errore:" & vbCrLf & ex.Message & vbCrLf &
                                    "Dettaglio:" & vbCrLf & ex.Detail.InnerText() & vbCrLf &
                                    "StackTrace:" & vbCrLf & ex.StackTrace
            Logging.WriteError(ex, sMsgErr)
            lblErrorMessage.Text = "Errore durante l'operazione d'inserimento del Consenso.<BR>Verificare l'esistenza del paziente nell' Anagrafica Centralizzata (SAC)."
            divErrorMessage.Visible = True
            ucTestataPaziente.mbValidationCancelSelect = True
            mbValidationCancelSelect = True
        Catch ex As Exception
            '
            ' Gestione dell'errore
            '
            lblErrorMessage.Text = "Errore durante l'operazione d'inserimento del Consenso."
            Logging.WriteError(ex, "Errore durante l'operazione d'inserimento del Consenso.")
            NascondoPagina()
            divErrorMessage.Visible = True
            ucTestataPaziente.mbValidationCancelSelect = True
            mbValidationCancelSelect = True
        Finally
        End Try
    End Sub

    Private Sub SalvaConsenso_NEW(sender As Object, e As EventArgs)
        '
        ' Pulsante Conferma
        '
        Dim oSacConsensiWs As SacConsensiDataAccess.ConsensiSoap = Nothing
        Dim sOperatoreCognome As String = String.Empty
        Dim sOperatoreNome As String = String.Empty
        Dim sOperatoreAccount As String = String.Empty
        Dim bStatoConsenso As Boolean = False
        Dim oAttributiType As SacConsensiDataAccess.AttributiType = Nothing
        Try
            If SessionHandler.AccessoDirettoConsensoInserito = False Then

                Dim iConsensoStato As Integer = CInt(cboStatoConsenso.SelectedValue)
                If iConsensoStato > -1 Then
                    bStatoConsenso = CBool(iConsensoStato)
                    '
                    ' Prendo informazioni sull'utente corrente
                    '
                    Dim oCurrentUser As CurrentUser = GetCurrentUser()

                    Dim oDettaglioUtente As Utility.DettaglioUtente = Utility.GetDettaglioUtente(oCurrentUser.DomainName, oCurrentUser.UserName)
                    sOperatoreAccount = oDettaglioUtente.AccountCompleto
                    sOperatoreCognome = oDettaglioUtente.Cognome
                    sOperatoreNome = oDettaglioUtente.Nome

                    If IsPazienteMinorenne Then
                        '
                        ' Salvo in sessione i dati dell'autorizzatore
                        ' I dati sono già stati validati, anche la data di nascita quindi la posso convertire direttamente
                        '
                        Dim oDataNascita As DateTime = Nothing
                        'La data è già stata validata lato client quindi posso convertire tranquillamente
                        Date.TryParse(txtAutorizzatoreDataNascita.Text, oDataNascita)
                        'Salvo i dati in sessione
                        Session(SESS_AUTORIZZATORE_CONSENSO_MINORE & Me.IdPaziente.ToString) = New UtenteAutorizzatoreMinore(
                                                                                      txtAutorizzatoreMinoreCognome.Text,
                                                                                      txtAutorizzatoreMinoreNome.Text,
                                                                                      oDataNascita,
                                                                                      txtAutorizzatoreLuogoNascita.Text,
                                                                                      cmbAutorizzatoreMinoreRelazioneColMinore.SelectedItem.Value)
                        '
                        ' Creo la classe con i dati del consenso da passare al metodo di inserimento consenso
                        '
                        oAttributiType = Utility.BuildAttributiAutorizzatoreDelMinore(txtAutorizzatoreMinoreCognome.Text,
                                                                                      txtAutorizzatoreMinoreNome.Text,
                                                                                      oDataNascita,
                                                                                      txtAutorizzatoreLuogoNascita.Text,
                                                                                      cmbAutorizzatoreMinoreRelazioneColMinore.SelectedItem.Text
                                                                                      )

                    End If
                    '--------------------------------------------------------------------------------------------------------
                    '
                    ' Istanzio il webservice e imposto le credenziali in base al metodo di autenticazione Integrata(NTLM)/Basic
                    '
                    oSacConsensiWs = New SacConsensiDataAccess.ConsensiSoapClient
                    If oSacConsensiWs Is Nothing Then
                        Throw New Exception("Errore: il Web Service SacConsensiDataAccess.ConsensiSoapClient è nothing.")
                    End If
                    Call Utility.SetWsConsensiCredential(oSacConsensiWs)
                    Dim oConsenso As SacConsensiDataAccess.Consenso = PopoloDatiConsenso(TipoConsensoPaziente, bStatoConsenso,
                                                     ucTestataPaziente.NomeAnagraficaErogante, ucTestataPaziente.CodiceAnagraficaErogante,
                                                      ucTestataPaziente.CognomePaziente, ucTestataPaziente.NomePaziente, ucTestataPaziente.CodiceFiscale, ucTestataPaziente.DataNascitaPaziente, ucTestataPaziente.CodiceSanitario,
                                                      sOperatoreAccount, sOperatoreCognome, sOperatoreNome,
                                                      oCurrentUser.HostName, oAttributiType)


                    Call InserimentoConsenso(oSacConsensiWs, oConsenso)
                    If bStatoConsenso = False Then
                        Select Case TipoConsensoPaziente
                            '
                            ' MODIFICA ETTORE 2019-03-07: L'interfaccia non da più la possibilità di acquisire il consenso GENERICO ne positivo ne negativo 
                            '                            non si può più negare il consenso GENERICO e quindi non si devono fare negazioni di eventuali DOSSIER e DOSSIERSTORICO
                            '
                            Case SacConsensiDataAccess.TipoConsenso.Dossier
                                '1) Nego DOSSIERSTORICO
                                oConsenso = PopoloDatiConsenso(SacConsensiDataAccess.TipoConsenso.DossierStorico, False,
                                                     ucTestataPaziente.NomeAnagraficaErogante, ucTestataPaziente.CodiceAnagraficaErogante,
                                                      ucTestataPaziente.CognomePaziente, ucTestataPaziente.NomePaziente, ucTestataPaziente.CodiceFiscale, ucTestataPaziente.DataNascitaPaziente, ucTestataPaziente.CodiceSanitario,
                                                      sOperatoreAccount, sOperatoreCognome, sOperatoreNome,
                                                      oCurrentUser.HostName, oAttributiType)
                                Call InserimentoConsenso(oSacConsensiWs, oConsenso)

                            Case SacConsensiDataAccess.TipoConsenso.DossierStorico
                                'NON DEVO FARE NULLA
                        End Select
                    End If
                Else
                    '
                    ' Gestione dell'errore
                    '
                    lblErrorMessage.Text = "E' necessario selezionare un valore della casella 'consenso' per proseguire."
                End If

                '
                ' Memorizzo che il consenso è già stato acquisito
                '
                SessionHandler.AccessoDirettoConsensoInserito = True
            End If

            '
            ' Registro lo script lato client per chiudere la modale
            '
            Dim functionJS As String = "$('#ModaleModificaConsenso').modal('hide');"
            ScriptManager.RegisterStartupScript(Page, Page.GetType, "LanchServerSide", functionJS, True)
            '
            ' Invalido la cache della testata del paziente e rieseguo il bind in modo da visualizzare i dati corretti.
            '
            ucTestataPaziente.InvalidaCache()

            '
            ' Nascondo le informazione dei consensi contenute nella testata del paziente
            '
            ucTestataPaziente.MostraSoloDatiAnagrafici = True

            '
            ' Aggiorno i dati contenuti nella griglia
            '
            GridViewConsensiSAC.DataBind()
            SessionHandler.AccessoDirettoCancellaCache = True

        Catch ex As System.Web.Services.Protocols.SoapException
            '
            ' Messaggio di errore
            '
            Dim sMsgErr As String = "Errore:" & vbCrLf & ex.Message & vbCrLf &
                                    "Dettaglio:" & vbCrLf & ex.Detail.InnerText() & vbCrLf &
                                    "StackTrace:" & vbCrLf & ex.StackTrace
            Logging.WriteError(ex, sMsgErr)
            lblErrorMessage.Text = "Errore durante l'operazione d'inserimento del Consenso.<BR>Verificare l'esistenza del paziente nell' Anagrafica Centralizzata (SAC)."
            divErrorMessage.Visible = True
            ucTestataPaziente.mbValidationCancelSelect = True
            mbValidationCancelSelect = True
        Catch ex As Exception
            '
            ' Gestione dell'errore
            '
            lblErrorMessage.Text = "Errore durante l'operazione d'inserimento del Consenso."
            Logging.WriteError(ex, "Errore durante l'operazione d'inserimento del Consenso.")
            NascondoPagina()
            divErrorMessage.Visible = True
            ucTestataPaziente.mbValidationCancelSelect = True
            mbValidationCancelSelect = True
        Finally
        End Try
    End Sub

    Private Sub cmdSalvaConsenso_Click(sender As Object, e As EventArgs) Handles cmdSalvaConsenso.Click
        If My.Settings.NuovaGestioneConsensi = False Then
            Call SalvaConsenso_OLD(sender, e)
        Else
            Call SalvaConsenso_NEW(sender, e)
        End If
    End Sub
#End Region

    Private Sub cmdEsci_Click(sender As Object, e As EventArgs) Handles cmdEsci.Click
        '
        ' Torno al chiamante
        '
        Esci()
    End Sub

#Region "ConsensiSacDataSource"
    Private Sub ConsensiSACDataSource_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles ConsensiSACDataSource.Selecting
        Try
            If mbValidationCancelSelect Then
                e.Cancel = True
                Exit Sub
            End If
            e.InputParameters("sIdPazienteSAC") = Me.IdPaziente.ToString
        Catch ex As Exception
            NascondoPagina()
            ucTestataPaziente.mbValidationCancelSelect = True
            mbValidationCancelSelect = True
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati!"
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

    Private Sub ConsensiSACDataSource_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles ConsensiSACDataSource.Selected
        Try
            divNoRecordFound.Visible = False
            If e.Exception IsNot Nothing Then
                If e.Exception.InnerException IsNot Nothing Then
                    '
                    ' Errore
                    '
                    Logging.WriteError(e.Exception.InnerException, Me.GetType.Name)
                End If
                lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati!"
                e.ExceptionHandled = True
                cmdCancellaConsensi.Visible = False
            Else
                Dim result As SacConsensiDataAccess.ConsensiCercaByIdPazienteResult = CType(e.ReturnValue, SacConsensiDataAccess.ConsensiCercaByIdPazienteResult)
                If result Is Nothing OrElse result.Count = 0 Then
                    divNoRecordFound.InnerText = "Non sono presenti consensi per il paziente."
                    divNoRecordFound.Visible = True
                    cmdCancellaConsensi.Visible = False
                Else
                    'Memorizzo se per il paziente c'è un consenso GENERICO NEGATO
                    Dim oConsensoGenericoNegatoList As List(Of SacConsensiDataAccess.Consensi) = (From c In result Where c.Tipo.ToUpper = "GENERICO" And c.Stato = False).ToList
                    If Not oConsensoGenericoNegatoList Is Nothing AndAlso oConsensoGenericoNegatoList.Count > 0 Then
                        mbConsensoGenericoNegato = True
                    End If
                End If
            End If
        Catch ex As Exception
            NascondoPagina()
            Logging.WriteError(ex, Me.GetType.Name)
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati!"
            ucTestataPaziente.mbValidationCancelSelect = True
            mbValidationCancelSelect = True
        End Try
    End Sub
#End Region

#Region "Eventi GridView"
    Private Sub GridViewConsensiSAC_PreRender(sender As Object, e As EventArgs) Handles GridViewConsensiSAC.PreRender
        '
        'Render per Bootstrap
        'Crea la Table con Theader e Tbody se l'header non è nothing.
        '
        If Not GridViewConsensiSAC.HeaderRow Is Nothing Then
            GridViewConsensiSAC.UseAccessibleHeader = True
            GridViewConsensiSAC.HeaderRow.TableSection = TableRowSection.TableHeader
        End If
    End Sub

    Private Sub GridViewConsensiSAC_RowCommand(sender As Object, e As GridViewCommandEventArgs) Handles GridViewConsensiSAC.RowCommand
        Try
            '
            ' Ottengo il CommandArgoument della griglia formato dal tipo di consenso e dal suo stato
            '
            Dim gridViewCommandArgoument() As String = e.CommandArgument.ToString.Split(",")
            Dim tipoConsenso As String = gridViewCommandArgoument(0)
            Dim statoConsenso As Boolean = CType(gridViewCommandArgoument(1), Boolean)
            '
            ' In base al tipoConsenso creo un nuovo consenso
            '
            If String.Compare(tipoConsenso, "Generico", True) = 0 Then
                TipoConsensoPaziente = SacConsensiDataAccess.TipoConsenso.Generico
            ElseIf String.Compare(tipoConsenso, "Dossier", True) = 0 Then
                TipoConsensoPaziente = SacConsensiDataAccess.TipoConsenso.Dossier
            ElseIf String.Compare(tipoConsenso, "DossierStorico", True) = 0 Then
                TipoConsensoPaziente = SacConsensiDataAccess.TipoConsenso.DossierStorico
            End If
            '
            ' Apro la modale del consenso
            '
            OpenModaleModificaConsenso(tipoConsenso, statoConsenso)
        Catch ex As Exception
            ucTestataPaziente.mbValidationCancelSelect = True
            mbValidationCancelSelect = True
            NascondoPagina()
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante il caricamento della modale"
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub
#End Region

    Private Sub PopolaCmdInformativa()
        '
        ' valorizzo l'url della informativa
        '
        Dim strUrlInfo As String = Me.ResolveUrl("~/Documenti/informativa.pdf")
        Dim strScript As String = "javascript:window.open('" & strUrlInfo & "','new_window');"
        cmdInformativa.Attributes.Item("onclick") = strScript
    End Sub
End Class