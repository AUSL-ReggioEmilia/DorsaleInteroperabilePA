Imports DwhClinico.Data
Imports DwhClinico.Web
Imports DwhClinico.Web.Utility
Public Class ucTestataPaziente
    Inherits System.Web.UI.UserControl

#Region "Property"

    Public mbValidationCancelSelect As Boolean = False
    Protected moSacDettaglioPaziente As SacDettaglioPaziente = Nothing

#Region "Property passate dall'esterno"
    '
    '
    ' QUESTE PROPERTY VENGONO VALORIZZATE DALLE PAGINE IN LO USERCONTROL VIENE IMPLEMENTATO
    '
    '
    Public WriteOnly Property MostraSoloDatiAnagrafici() As Boolean
        '
        ' Visualizza o nasconde la gestione dei consensi nella testata del paziente.
        '
        Set(ByVal value As Boolean)
            fvInfoPaziente.FindControl("divInferiore").Visible = Not value
        End Set
    End Property

    Public Property IdPaziente As Guid
        Get
            Return ViewState("IdPaziente")
        End Get
        Set(value As Guid)
            ViewState("IdPaziente") = value
        End Set
    End Property

    Public Property CodiceRuolo As String
        Get
            Return ViewState("CodiceRuolo")
        End Get
        Set(value As String)
            ViewState("CodiceRuolo") = value
        End Set
    End Property

    Public Property DescrizioneRuolo As String
        Get
            Return ViewState("DescrizioneRuolo")
        End Get
        Set(value As String)
            ViewState("DescrizioneRuolo") = value
        End Set
    End Property

    Public Property Token As WcfDwhClinico.TokenType
        Get
            Return ViewState("Token")
        End Get
        Set(value As WcfDwhClinico.TokenType)
            ViewState("Token") = value
        End Set
    End Property
#End Region

#Region "Property esposte dallo UserControl"
    Public Property CodiceFiscale As String
        Get
            Return ViewState("CodiceFiscalePaziente")
        End Get
        Set(value As String)
            ViewState("CodiceFiscalePaziente") = value
        End Set
    End Property

    Public Property DataNascitaPaziente As String
        Get
            Return ViewState("DataNascitaPaziente")
        End Get
        Set(value As String)
            ViewState("DataNascitaPaziente") = value
        End Set
    End Property

    Public Property ComuneNascitaDescrizione As String
        Get
            Return ViewState("ComuneNascitaDescrizione")
        End Get
        Set(value As String)
            ViewState("ComuneNascitaDescrizione") = value
        End Set
    End Property

    Public Property ComuneNascitaCodice As String
        Get
            Return ViewState("ComuneNascitaCodice")
        End Get
        Set(value As String)
            ViewState("ComuneNascitaCodice") = value
        End Set
    End Property

    Public Property UltimoConsensoAziendaleEspresso As String
        Get
            Return ViewState("UltimoConsensoAziendaleEspresso")
        End Get
        Set(value As String)
            ViewState("UltimoConsensoAziendaleEspresso") = value
        End Set
    End Property

    Public Property DataUltimoConsensoAziendaleEspresso As Date?
        Get
            Return ViewState("DataUltimoConsensoAziendaleEspresso")
        End Get
        Set(value As Date?)
            ViewState("DataUltimoConsensoAziendaleEspresso") = value
        End Set
    End Property

    Public Property CognomePaziente As String
        Get
            Return ViewState("CognomePaziente")
        End Get
        Set(value As String)
            ViewState("CognomePaziente") = value
        End Set
    End Property

    Public Property CodiceSanitario As String
        Get
            Return ViewState("CodiceSanitario")
        End Get
        Set(value As String)
            ViewState("CodiceSanitario") = value
        End Set
    End Property

    Public Property NomePaziente As String
        Get
            Return ViewState("NomePaziente")
        End Get
        Set(value As String)
            ViewState("NomePaziente") = value
        End Set
    End Property

    Public Property NomeAnagraficaErogante As String
        Get
            Return ViewState("NomeAnagraficaErogante")
        End Get
        Set(value As String)
            ViewState("NomeAnagraficaErogante") = value
        End Set
    End Property

    Public Property CodiceAnagraficaErogante As String
        Get
            Return ViewState("CodiceAnagraficaErogante")
        End Get
        Set(value As String)
            ViewState("CodiceAnagraficaErogante") = value
        End Set
    End Property
#End Region

    Private Property IsPazienteMinorenne As Boolean
        '
        ' Property utilizzata per salvare nel view state se il paziente è minorenne
        '
        Get
            Return CType(ViewState(" - IsPazienteMinorenne - "), Boolean)
        End Get
        Set(ByVal value As Boolean)
            ViewState(" - IsPazienteMinorenne - ") = value
        End Set
    End Property

    Public Property TipoConsenso As SacConsensiDataAccess.TipoConsenso
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

    Public Property UrlDettaglioConsensi As String
        Get
            Return Me.ViewState("UrlDettaglioConsensi")
        End Get
        Set(value As String)
            Me.ViewState("UrlDettaglioConsensi") = value
        End Set
    End Property
#End Region

    Private Sub fvInfoPaziente_ItemCommand(sender As Object, e As FormViewCommandEventArgs) Handles fvInfoPaziente.ItemCommand
        Try
            If e.CommandName.ToString = "Generico" Then
                '
                ' Salvo nel ViewState il consenso da acquisire. Questo perchè sfrutto la stessa modale di acquisizione per tutti i consensi
                '
                Me.TipoConsenso = CType(CType(SacConsensiDataAccess.TipoConsenso.Generico, Integer), SacConsensiDataAccess.TipoConsenso)

                PopolaCmdInformativa()

                '
                ' Apro la modale per l'acquisizione del consenso.
                '
                OpenModalConsenso()

                '
                ' ATTENZIONE:
                ' Questo RaiseEvent viene trappato all'interno della pagina RefertiListaPaziente.
                ' Motivo: Ogni volta che viene acquisito un consenso devo ricaricare i dati. 
                '         Questo evento mi permette di salvarmi in sessione i filtri laterali e di cancellare la cache.                
                '         Dentro all'evento cmdOK_Click viene rieseguito un redirect alla pagina RefertiListaPaziente per ricaricare completamente i dati.
                '
                RaiseEvent ConsensoModificato(Nothing, Nothing)

            ElseIf e.CommandName.ToString = "Dossier" Then
                '
                ' Salvo nel ViewState il consenso da acquisire. Questo perchè sfrutto la stessa modale di acquisizione per tutti i consensi
                '
                Me.TipoConsenso = CType(CType(SacConsensiDataAccess.TipoConsenso.Dossier, Integer), SacConsensiDataAccess.TipoConsenso)

                PopolaCmdInformativa()

                '
                ' Apro la modale per l'acquisizione del consenso.
                '
                OpenModalConsenso()

                '
                ' ATTENZIONE:
                ' Questo RaiseEvent viene trappato all'interno della pagina RefertiListaPaziente.
                ' Motivo: Ogni volta che viene acquisito un consenso devo ricaricare i dati. 
                '         Questo evento mi permette di salvarmi in sessione i filtri laterali e di cancellare la cache.                
                '         Dentro all'evento cmdOK_Click viene rieseguito un redirect alla pagina RefertiListaPaziente per ricaricare completamente i dati.
                '
                RaiseEvent ConsensoModificato(Nothing, Nothing)

            ElseIf e.CommandName.ToString = "DossierStorico" Then
                '
                ' Salvo nel ViewState il consenso da acquisire. Questo perchè sfrutto la stessa modale di acquisizione per tutti i consensi
                '
                Me.TipoConsenso = CType(CType(SacConsensiDataAccess.TipoConsenso.DossierStorico, Integer), SacConsensiDataAccess.TipoConsenso)
                PopolaCmdInformativa()

                '
                ' Apro la modale per l'acquisizione del consenso.
                '
                OpenModalConsenso()

                '
                ' ATTENZIONE:
                ' Questo RaiseEvent viene trappato all'interno della pagina padre(RefertiListaPaziente -> AccessoStandard; Referti -> AccessoDiretto).
                ' Motivo: Ogni volta che viene acquisito un consenso devo ricaricare i dati. 
                '         Questo evento mi permette di salvarmi in sessione i filtri laterali e di cancellare la cache.                
                '         Dentro all'evento cmdOK_Click viene rieseguito un redirect alla pagina RefertiListaPaziente per ricaricare completamente i dati.
                '
                RaiseEvent ConsensoModificato(Nothing, Nothing)

            ElseIf e.CommandName.ToString = "ForzaturaConsenso" Then
                '
                ' FORZATURA DEL CONSENSO
                ' Salvo in sessione che è stato forzato il consenso
                '
                Call SetSessionForzaturaConsenso(Me.IdPaziente, True)

                'Traccio che è stato forzato il consenso
                'in questo caso nel parametro NumeroRecord passo Nothing perchè l'utente non visualizza nessun record.
                Call TracciaAccessi.TracciaAccessiPaziente(Me.CodiceRuolo, Me.DescrizioneRuolo, "Forzatura del consenso per urgenze", Me.IdPaziente, SessionHandler.MotivoAccesso, SessionHandler.MotivoAccessoNote, Nothing, Me.UltimoConsensoAziendaleEspresso)
                fvInfoPaziente.DataBind()

                '
                ' ATTENZIONE:
                ' Questo RaiseEvent viene trappato all'interno della pagina RefertiListaPaziente.
                ' Motivo: Ogni volta che viene acquisito un consenso devo ricaricare i dati. 
                '         Questo evento mi permette di salvarmi in sessione i filtri laterali e di cancellare la cache.                
                '         Dentro all'evento cmdOK_Click viene rieseguito un redirect alla pagina RefertiListaPaziente per ricaricare completamente i dati.
                '
                RaiseEvent ConsensoModificato(Nothing, Nothing)

                '
                ' Ogni volta che forzo il consenso ricarico i dati. Per farlo ho bisogno di eseguire un redirect 
                ' alla pagina padre(RefertiListaPaziente -> AccessoStandard; Referti -> AccessoDiretto).
                '
                Response.Redirect(Request.Url.AbsoluteUri)
            End If
        Catch ex As Threading.ThreadAbortException
            '
            ' Non faccio niente
            '
        Catch ex As Exception
            mbValidationCancelSelect = True
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante il caricamento dei dati del paziente."
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

#Region "ModaleConsenso"
    Private Sub cmdOK_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdOK.Click
        '
        ' EVENTO CHE SI OCCUPA DI SALVARE IL CONSENSO. cmdOK è all'interno della modale di acquisizione del consenso.
        '

        '
        ' Invalido la sessione per essere sicuro che vengano aggiornati i dati del paziente corrente.
        '
        SacDettaglioPaziente.Session(Me.IdPaziente) = Nothing
        Dim oSacConsensiWs As SacConsensiDataAccess.ConsensiSoap = Nothing
        Dim sOperatoreCognome As String = String.Empty
        Dim sOperatoreNome As String = String.Empty
        Dim sOperatoreAccount As String = String.Empty
        Dim bStatoConsenso As Boolean = False
        Dim oAttributiType As SacConsensiDataAccess.AttributiType = Nothing
        Try
            Dim iConsensoStato As Integer = CInt(cboConsenso.SelectedValue)
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
                Dim oConsenso As SacConsensiDataAccess.Consenso = Utility.PopoloDatiConsenso(TipoConsenso, bStatoConsenso,
                                                 Me.NomeAnagraficaErogante, Me.CodiceAnagraficaErogante,
                                                 Me.CognomePaziente, Me.NomePaziente, Me.CodiceFiscale, Me.DataNascitaPaziente, Me.CodiceSanitario,
                                                  sOperatoreAccount, sOperatoreCognome, sOperatoreNome,
                                                  oCurrentUser.HostName, oAttributiType)


                Call InserimentoConsenso(oSacConsensiWs, oConsenso)
            Else
                Throw New ApplicationException("E' necessario selezionare un valore della casella 'consenso' per proseguire.")
            End If
            '
            ' Registro lo script lato client per chiudere la modale.
            '
            Dim functionJS As String = "$('#ModalConsenso').modal('hide');"
            ScriptManager.RegisterStartupScript(Page, Page.GetType, "LanchServerSide", functionJS, True)
            '
            ' Imposto come default value l'item "Scegli consenso".
            '
            cboConsenso.SelectedValue = "-1"
            '
            ' Invalido la cache e aggiorno i dati.
            '
            InvalidaCache()

            '
            ' Eseguo un redirect alla pagina padre per essere sicuro di ricaricare i dati.
            '
            Response.Redirect(Request.Url.AbsoluteUri)

        Catch ex As System.Web.Services.Protocols.SoapException
            mbValidationCancelSelect = True
            Dim sMsgErr As String = "Errore:" & vbCrLf & ex.Message & vbCrLf &
                                    "Dettaglio:" & vbCrLf & ex.Detail.InnerText() & vbCrLf &
                                    "StackTrace:" & vbCrLf & ex.StackTrace
            Logging.WriteError(ex, sMsgErr)
            lblErrorMessage.Text = "Errore durante l'operazione d'inserimento del Consenso.<BR>Verificare l'esistenza del paziente nell' Anagrafica Centralizzata (SAC)."
            divErrorMessage.Visible = True
        Catch ex As Threading.ThreadAbortException
            '
            ' Non faccio niente
            '
        Catch ex As ApplicationException
            divErrorMessage.Visible = True
            lblErrorMessage.Text = ex.Message
        Catch ex As Exception
            mbValidationCancelSelect = True
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'operazione d'inserimento del Consenso."
            Logging.WriteError(ex, Me.GetType.Name)
        Finally
        End Try
    End Sub

    Public Event ConsensoModificato As EventHandler

    Private Sub InserimentoConsenso(oSacConsensiWs As SacConsensiDataAccess.ConsensiSoap, oConsenso As SacConsensiDataAccess.Consenso)
        Dim body As New SacConsensiDataAccess.ConsensiAggiungiRequestBody(oConsenso)
        Dim request As New SacConsensiDataAccess.ConsensiAggiungiRequest(body)
        Call oSacConsensiWs.ConsensiAggiungi(request)
    End Sub

    ''' <summary>
    ''' Funzione per inizializzare i controlli dell'utente autorizzatore del minore
    ''' </summary>
    ''' <param name="bPazienteMinorenne"></param>
    ''' <param name="IdPaziente"></param>
    ''' <remarks></remarks>
    ''' 
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
        '
        ReqAutorizzatoreMinoreCognome.Enabled = bPazienteMinorenne
        ReqAutorizzatoreMinoreNome.Enabled = bPazienteMinorenne
        ReqAutorizzatoreDataNascita.Enabled = bPazienteMinorenne
        ReqAutorizzatoreLuogoNascita.Enabled = bPazienteMinorenne
        RangeValAutorizzatoreDataNascita.Enabled = bPazienteMinorenne
    End Sub

    Public Sub OpenModalConsenso()
        '
        ' Quando arrivo qui significa che il consenso non è stato ancora espresso quindi setto la dropDownList del consenso su "Positivo"
        '
        cboConsenso.SelectedValue = 1
        PageTitle.InnerText = String.Format("Inserimento Consenso {0}", Me.TipoConsenso.ToString)
        Call PageDataBind(fvInfoPaziente.DataKey(0))
        Dim functionJS As String = "$('#ModalConsenso').modal('show');"
        ScriptManager.RegisterStartupScript(Page, Page.GetType, "LanchServerSide", functionJS, True)
    End Sub

    Private Sub cboConsenso_SelectedIndexChanged(sender As Object, e As EventArgs) Handles cboConsenso.SelectedIndexChanged
        '
        ' Abilito il pulsante per salvare il consenso solo se l'item selezionato è diverso da "Scegli il consenso"
        '
        cmdOK.Enabled = CInt(cboConsenso.SelectedValue) <> -1
    End Sub

    Private Sub PopolaCmdInformativa()
        '
        ' valorizzo l'url della informativa
        '
        Dim strUrlInfo As String = Me.ResolveUrl("~/Documenti/informativa.pdf")
        Dim strScript As String = "javascript:window.open('" & strUrlInfo & "','new_window');"
        cmdInformativa.Attributes.Item("onclick") = strScript
    End Sub

    Private Sub PageDataBind(Data As String)
        Try
            Dim DataNascita As Date = CType(Data, Date)
            cmdOK.Enabled = CInt(cboConsenso.SelectedValue) <> -1
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
            '
            ' Gestione dell'errore
            '
            Dim sMsg As String = If(ex.Message Is Nothing, "Errore durante il caricamento dei dati paziente e utente.", ex.Message)
            lblErrorMessage.Text = sMsg
            lblErrorMessage.Visible = True
            divErrorMessage.Visible = True
            Logging.WriteError(ex, sMsg)
        Finally
        End Try

    End Sub
#End Region

#Region "ObjectDataSource"
    Public Sub InvalidaCache()
        '
        ' Invalida la cache della CustomDataSource per aggiornare i dati del paziente.
        ' E' pubblica in modo da permettere alle pagine in cui questo UserControl viene utilizzato di forzare l'aggiornamento dei dati del paziente.
        '
        Dim dsTestataPaziente As New CustomDataSource.PazienteOttieniPerId
        dsTestataPaziente.ClearCache(Me.IdPaziente)
        '
        '  Invalido anche i dati del paziente provenienti dal SAC
        '
        SacDettaglioPaziente.Session(Me.IdPaziente) = Nothing
        fvInfoPaziente.DataBind()
    End Sub

    Private Sub DataSourceTestataPaziente_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles DataSourceTestataPaziente.Selected
        'TODO: nel pannello paziente viene usata una funzione esterna per i log degli eventi. Bisognerebbe generare un evento gestito dalla pagina in cui il pannello viene usato.
        Try
            divErrorMessage.Visible = False

            'Ottengo il messaggio di errore.
            Dim messaggioErrore = HelperDataSourceException.GetObjectDataSourceExceptionMessage(e.Exception)

            'Testo se il messaggio di errore è vuoto. Se è valorizzato allora mostro il div d'errore.
            If Not String.IsNullOrEmpty(messaggioErrore) Then
                divErrorMessage.Visible = True
                lblErrorMessage.Text = messaggioErrore
                e.ExceptionHandled = True
            Else
                Dim dettaglioPaziente As WcfDwhClinico.PazienteType = CType(e.ReturnValue, WcfDwhClinico.PazienteType)
                If Not dettaglioPaziente Is Nothing Then
                    '
                    ' Lo UserControl espone alcune informazioni sul paziente.
                    '
                    CodiceFiscale = dettaglioPaziente.CodiceFiscale
                    If Not dettaglioPaziente.ConsensoAziendale Is Nothing Then
                        Me.UltimoConsensoAziendaleEspresso = dettaglioPaziente.ConsensoAziendale.Descrizione
                        Me.DataUltimoConsensoAziendaleEspresso = dettaglioPaziente.ConsensoAziendale.Data
                    Else
                        Me.UltimoConsensoAziendaleEspresso = Nothing
                        Me.DataUltimoConsensoAziendaleEspresso = Nothing
                    End If

                    If dettaglioPaziente.DataNascita.HasValue Then
                        Me.DataNascitaPaziente = dettaglioPaziente.DataNascita.Value
                    End If
                    Me.CognomePaziente = dettaglioPaziente.Cognome
                    Me.NomePaziente = dettaglioPaziente.Nome
                    Me.CodiceSanitario = dettaglioPaziente.CodiceSanitario
                    If Not dettaglioPaziente.ComuneNascita Is Nothing Then
                        Me.ComuneNascitaCodice = dettaglioPaziente.ComuneNascita.Codice
                        Me.ComuneNascitaDescrizione = dettaglioPaziente.ComuneNascita.Descrizione
                    End If
                    Me.NomeAnagraficaErogante = dettaglioPaziente.NomeAnagraficaErogante
                    Me.CodiceAnagraficaErogante = dettaglioPaziente.CodiceAnagraficaErogante
                Else
                    Throw New ApplicationException("Il paziente non esiste.")
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
            Logging.WriteError(ex, Me.GetType.Name)
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati!"
        End Try
    End Sub

    Private Sub DataSourceTestataPaziente_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles DataSourceTestataPaziente.Selecting
        Try
            If mbValidationCancelSelect Then
                e.Cancel = True
                Exit Sub
            End If
            '
            ' Questi parametri vengono passati dalla pagina in cui lo UserControl viene implementata
            '
            e.InputParameters("Token") = Token
            e.InputParameters("idPaziente") = IdPaziente
        Catch ex As Threading.ThreadAbortException
            '
            ' Non faccio niente
            '
        Catch ex As Exception
            Logging.WriteError(ex, Me.GetType.Name)
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati!"
        End Try
    End Sub

    Private Sub DataSourcePazientiAccessiLista_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles DataSourcePazientiAccessiLista.Selecting
        Try
            If mbValidationCancelSelect Then
                e.Cancel = True
                Exit Sub
            End If
            Dim bShowListaAccessiPaziente As Boolean = CBool(CInt(My.Settings.ListaAccessiPaziente_Visible))
            If bShowListaAccessiPaziente Then
                e.InputParameters("IdPaziente") = Me.IdPaziente.ToString
            Else
                e.Cancel = True
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
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati!"
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

    Private Sub DataSourcePazientiAccessiLista_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles DataSourcePazientiAccessiLista.Selected
        Try
            '
            ' Ottengo la label in cui scrivere l'ultimo accesso ai dati del paziente
            '
            Dim lblUltimoAccesso As Label = CType(fvInfoPaziente.FindControl("lblUltimoAccesso"), Label)
            Dim cmdUltimoAccesso As Button = CType(fvInfoPaziente.FindControl("cmdUltimiAccessi"), Button)
            '
            ' contenitore delle label dell'ultimo accesso
            '
            Dim divUltimoAccesso As HtmlGenericControl = CType(fvInfoPaziente.FindControl("divUltimoAccesso"), HtmlGenericControl)
            lblUltimoAccesso.Visible = False
            divUltimoAccesso.Visible = False
            cmdUltimoAccesso.Visible = False
            If Not e.ReturnValue Is Nothing Then
                '
                ' Se vengono restituiti i dati prendo la prima riga della tabella per ricavare la data e l'utente di accesso
                '
                Dim odt As Data.PazientiDataset.FevsPazientiAccessiListaDataTable = CType(e.ReturnValue, Data.PazientiDataset.FevsPazientiAccessiListaDataTable)
                If odt.Rows.Count > 0 Then
                    Dim ultimaRow As Data.PazientiDataset.FevsPazientiAccessiListaRow = CType(odt.Rows(0), Data.PazientiDataset.FevsPazientiAccessiListaRow)
                    Dim DataUltimoAccesso As Date = ultimaRow.DataDiAccesso
                    Dim UtenteUltimoAccesso As String = ultimaRow.Utente
                    lblUltimoAccesso.Text = String.Format("{0} - {1:g}", UtenteUltimoAccesso.ToUpper, DataUltimoAccesso)
                    lblUltimoAccesso.Visible = True
                    cmdUltimoAccesso.Visible = True
                    divUltimoAccesso.Visible = True
                End If
            End If
        Catch ex As Threading.ThreadAbortException
            '
            ' Non faccio niente
            '
        Catch ex As Exception
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'operazione di lettura ultimo accesso!"
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub
#End Region

#Region "Funzioni Del Markup"

    Protected Function GetUltimoEpisodioDescrizione(objrow As Object) As String
        Dim oRow As WcfDwhClinico.PazienteType = CType(objrow, WcfDwhClinico.PazienteType)
        Dim result As String = String.Empty
        Dim bInfoConsensoVisible As Boolean = GetInfoEpisodioVisibility(oRow)

        If bInfoConsensoVisible Then
            '
            'Testo dentro GetInfoEpisodioVisibility se tutti i nodi sono valorizzati
            '
            If Not String.IsNullOrEmpty(oRow.Episodio.NumeroNosologico) Then
                result = String.Format("<strong>Episodio:</strong> {0}", oRow.Episodio.NumeroNosologico)
            End If
        End If

        Return result
    End Function

    ''' <summary>
    ''' Ottiene nome cogmone e sesso del paziente (COGNOME NOME (SESSO))
    ''' </summary>
    ''' <param name="objrow"></param>
    ''' <returns></returns>
    Protected Function GetNomeCognome(objrow As Object) As String
        Dim oRow As WcfDwhClinico.PazienteType = CType(objrow, WcfDwhClinico.PazienteType)
        Return String.Format("{0} {1} ({2})", oRow.Cognome.NullSafeToString.ToUpper, oRow.Nome.NullSafeToString.ToUpper, oRow.Sesso.NullSafeToString.ToUpper)
    End Function

    ''' <summary>
    ''' Ottiene l'url al SAC per il dettaglio del paziente.
    ''' </summary>
    ''' <param name="objrow"></param>
    ''' <returns></returns>
    Protected Function GetPazienteSacUrl(objrow As Object) As String
        Dim oRow As WcfDwhClinico.PazienteType = CType(objrow, WcfDwhClinico.PazienteType)
        Return Me.ResolveUrl(String.Format(My.Settings.UrlSacPaziente, oRow.Id))
    End Function

    ''' <summary>
    ''' Restituisce le informazioni legate al paziente
    ''' </summary>
    ''' <param name="objrow"></param>
    ''' <returns></returns>
    Protected Function GetInfoPaziente(objrow As Object) As String
        Dim sHtml As String = String.Empty

        Dim oRow As WcfDwhClinico.PazienteType = CType(objrow, WcfDwhClinico.PazienteType)
        If Not oRow Is Nothing Then
            Dim comuneNascitaDescrizione As String = Nothing
            If oRow.ComuneNascita IsNot Nothing Then
                comuneNascitaDescrizione = oRow.ComuneNascita.Descrizione
            End If
            If oRow.DataNascita.HasValue Then
                sHtml = String.Format(" CF: <strong>{0}</strong> nato il <strong>{1:d} </strong> <strong>({2})</strong> a <strong>{3}</strong>", oRow.CodiceFiscale.NullSafeToString.ToUpper, oRow.DataNascita, Utility.CalcolaEta(oRow.DataNascita, Now).ToString, comuneNascitaDescrizione.NullSafeToString.ToUpper)
            Else
                sHtml = String.Format(" CF: <strong>{0}</strong> nato a <strong>{1}</strong>", oRow.CodiceFiscale.NullSafeToString.ToUpper, comuneNascitaDescrizione.NullSafeToString.ToUpper)
            End If
            If oRow.DataDecesso.HasValue Then
                sHtml = String.Format("{0}.Deceduto il <label class='text-danger'>{1:d}</label>.", sHtml, oRow.DataDecesso)
            End If
        End If

        Return sHtml
    End Function


    Private Function GetInfoConsenso_OLD(idLabel As String, descrizioneConsenso As String) As String
        'VECCHIA GESTIONE CONSENSI
        If SacDettaglioPaziente.Session(Me.IdPaziente) Is Nothing Then
            Dim oPazienteSac As New PazienteSac
            Try
                '
                ' Invoco classe che wrappa il web service pazienti del SAC
                '
                moSacDettaglioPaziente = oPazienteSac.GetData(Me.IdPaziente.ToString)
                SacDettaglioPaziente.Session(Me.IdPaziente) = moSacDettaglioPaziente
            Catch ex As Exception
                divErrorMessage.Visible = True
                lblErrorMessage.Text = "Si è verificato un errore durante la ricerca dei dati."
            End Try
        Else
            moSacDettaglioPaziente = SacDettaglioPaziente.Session(Me.IdPaziente)
        End If
        Dim infoConsenso As String = String.Empty
        Dim consenso As Consenso = Nothing
        '
        ' Se nothing rieseguo la query
        '
        If descrizioneConsenso = "Base" Then
            consenso = moSacDettaglioPaziente.GetConsensoGenerico()
        ElseIf descrizioneConsenso = "Dossier" Then
            consenso = moSacDettaglioPaziente.GetConsensoDossier()
        ElseIf descrizioneConsenso = "Dossier Storico" Then
            consenso = moSacDettaglioPaziente.GetConsensoDossierStorico()
        End If

        If consenso.Stato = ConsensoStato.NonAcquisito Then
            '
            ' se il consenso non è acquisito nascondo la label con le informazioni sul consenso
            '
            CType(fvInfoPaziente.FindControl(idLabel), Label).Visible = False
        ElseIf consenso.Stato = ConsensoStato.Accordato Then
            infoConsenso = String.Format("{0}: {1:d}", descrizioneConsenso, consenso.DataStato.Value)
        ElseIf consenso.Stato = ConsensoStato.Negato Then
            CType(fvInfoPaziente.FindControl(idLabel), Label).CssClass = "label label-danger"
            infoConsenso = String.Format("{0} NEGATO", descrizioneConsenso)
        End If
        Return infoConsenso
    End Function

    Private Function GetInfoConsenso_NEW(idLabel As String, descrizioneConsenso As String) As String
        'NUOVA GESTONE CONSENSI
        If SacDettaglioPaziente.Session(Me.IdPaziente) Is Nothing Then
            Dim oPazienteSac As New PazienteSac
            Try
                '
                ' Invoco classe che wrappa il web service pazienti del SAC
                '
                moSacDettaglioPaziente = oPazienteSac.GetData(Me.IdPaziente.ToString)
                SacDettaglioPaziente.Session(Me.IdPaziente) = moSacDettaglioPaziente
            Catch ex As Exception
                divErrorMessage.Visible = True
                lblErrorMessage.Text = "Si è verificato un errore durante la ricerca dei dati."
            End Try
        Else
            moSacDettaglioPaziente = SacDettaglioPaziente.Session(Me.IdPaziente)
        End If
        Dim infoConsenso As String = String.Empty
        Dim consenso As Consenso = Nothing
        Dim consensoGenerico As Consenso = Nothing
        '
        ' Se nothing rieseguo la query
        '
        If descrizioneConsenso = "Base" Then
            consenso = moSacDettaglioPaziente.GetConsensoGenerico()
            If consenso.Stato = ConsensoStato.NonAcquisito OrElse consenso.Stato = ConsensoStato.Accordato Then
                '
                ' NON DEVO MOSTRARE LA LABEL DEL CONSENSO BASE
                '
                CType(fvInfoPaziente.FindControl(idLabel), Label).Visible = False
            ElseIf consenso.Stato = ConsensoStato.Negato Then
                CType(fvInfoPaziente.FindControl(idLabel), Label).CssClass = "label label-danger"
                infoConsenso = String.Format("{0} NEGATO", descrizioneConsenso)
            End If
        ElseIf descrizioneConsenso = "Dossier" Then
            consensoGenerico = moSacDettaglioPaziente.GetConsensoGenerico()
            If consensoGenerico.Stato = ConsensoStato.Negato Then
                CType(fvInfoPaziente.FindControl(idLabel), Label).Visible = False
            Else
                consenso = moSacDettaglioPaziente.GetConsensoDossier()
                If consenso.Stato = ConsensoStato.Accordato Then
                    infoConsenso = String.Format("{0}: {1:d}", descrizioneConsenso, consenso.DataStato.Value)
                ElseIf consenso.Stato = ConsensoStato.Negato Then
                    CType(fvInfoPaziente.FindControl(idLabel), Label).CssClass = "label label-danger"
                    infoConsenso = String.Format("{0} NEGATO", descrizioneConsenso)
                End If
            End If
        ElseIf descrizioneConsenso = "Dossier Storico" Then
            consensoGenerico = moSacDettaglioPaziente.GetConsensoGenerico()
            If consensoGenerico.Stato = ConsensoStato.Negato Then
                CType(fvInfoPaziente.FindControl(idLabel), Label).Visible = False
            Else
                consenso = moSacDettaglioPaziente.GetConsensoDossierStorico()
                If consenso.Stato = ConsensoStato.Accordato Then
                    infoConsenso = String.Format("{0}: {1:d}", descrizioneConsenso, consenso.DataStato.Value)
                ElseIf consenso.Stato = ConsensoStato.Negato Then
                    CType(fvInfoPaziente.FindControl(idLabel), Label).CssClass = "label label-danger"
                    infoConsenso = String.Format("{0} NEGATO", descrizioneConsenso)
                End If
            End If
        End If

        Return infoConsenso
    End Function

    Protected Function GetInfoConsenso(idLabel As String, descrizioneConsenso As String) As String
        If My.Settings.NuovaGestioneConsensi = False Then
            Return GetInfoConsenso_OLD(idLabel, descrizioneConsenso)
        Else
            Return GetInfoConsenso_NEW(idLabel, descrizioneConsenso)
        End If
    End Function


    Private Function GetTestoAcquisisciConsenso_OLD(dettaglio As Object) As String
        Dim dettaglioPaziente As WcfDwhClinico.PazienteType = CType(dettaglio, WcfDwhClinico.PazienteType)
        Dim cmdAcquisisciConsenso As Button = CType(fvInfoPaziente.FindControl("cmdAcquisisciConsenso"), Button)
        Dim commandText As String = String.Empty
        If dettaglioPaziente IsNot Nothing Then
            If Not moSacDettaglioPaziente Is Nothing Then
                Dim consensoGenerico As Consenso = moSacDettaglioPaziente.GetConsensoGenerico()
                If consensoGenerico.Stato = ConsensoStato.NonAcquisito OrElse consensoGenerico.Stato = ConsensoStato.Negato Then
                    commandText = "Acquisisci Generico"
                    cmdAcquisisciConsenso.CommandName = "Generico"
                Else
                    ' se sono qui il Generico è stato acquisito positivo
                    Dim consensoDossier As Consenso = moSacDettaglioPaziente.GetConsensoDossier()
                    If consensoDossier.Stato = ConsensoStato.Negato OrElse consensoDossier.Stato = ConsensoStato.NonAcquisito Then
                        commandText = "Acquisisci Dossier"
                        cmdAcquisisciConsenso.CommandName = "Dossier"
                    Else
                        ' se sono qui il Dossier è stato acquisito positivo
                        Dim consensoDossierStorico As Consenso = moSacDettaglioPaziente.GetConsensoDossierStorico()

                        If consensoDossierStorico.Stato = ConsensoStato.NonAcquisito OrElse consensoDossierStorico.Stato = ConsensoStato.Negato Then
                            commandText = "Acquisisci Dossier Storico"
                            cmdAcquisisciConsenso.CommandName = "DossierStorico"
                        Else
                            ' se sono qui ho tutti i consensi
                            fvInfoPaziente.FindControl("cmdAcquisisciConsenso").Visible = False
                        End If
                    End If
                End If
            End If
        End If
        Return commandText
    End Function

    Private Function GetTestoAcquisisciConsenso_NEW(dettaglio As Object) As String
        'NUOVA GESTIONE CONSENSI
        Dim dettaglioPaziente As WcfDwhClinico.PazienteType = CType(dettaglio, WcfDwhClinico.PazienteType)
        Dim cmdAcquisisciConsenso As Button = CType(fvInfoPaziente.FindControl("cmdAcquisisciConsenso"), Button)
        Dim commandText As String = String.Empty
        If dettaglioPaziente IsNot Nothing Then
            If Not moSacDettaglioPaziente Is Nothing Then
                Dim consensoGenerico As Consenso = moSacDettaglioPaziente.GetConsensoGenerico()
                If consensoGenerico.Stato = ConsensoStato.NonAcquisito OrElse consensoGenerico.Stato = ConsensoStato.Accordato Then
                    Dim consensoDossier As Consenso = moSacDettaglioPaziente.GetConsensoDossier()
                    If consensoDossier.Stato = ConsensoStato.Negato OrElse consensoDossier.Stato = ConsensoStato.NonAcquisito Then
                        commandText = "Acquisisci Dossier"
                        cmdAcquisisciConsenso.CommandName = "Dossier"
                    Else
                        ' se sono qui il Dossier è stato acquisito positivo
                        Dim consensoDossierStorico As Consenso = moSacDettaglioPaziente.GetConsensoDossierStorico()

                        If consensoDossierStorico.Stato = ConsensoStato.NonAcquisito OrElse consensoDossierStorico.Stato = ConsensoStato.Negato Then
                            commandText = "Acquisisci Dossier Storico"
                            cmdAcquisisciConsenso.CommandName = "DossierStorico"
                        Else
                            ' se sono qui ho tutti i consensi
                            fvInfoPaziente.FindControl("cmdAcquisisciConsenso").Visible = False
                        End If
                    End If
                ElseIf consensoGenerico.Stato = ConsensoStato.Negato Then
                    ' Se il paziente ha il consenso GENERICO negato allora non deve essere più possibile acquisire nessun consenso
                    cmdAcquisisciConsenso.Visible = False
                End If

            End If
        End If
        Return commandText
    End Function

    Protected Function GetTestoAcquisisciConsenso(dettaglio As Object) As String
        If My.Settings.NuovaGestioneConsensi = False Then
            Return GetTestoAcquisisciConsenso_OLD(dettaglio)
        Else
            Return GetTestoAcquisisciConsenso_NEW(dettaglio)
        End If
    End Function

    Protected Function GetConsensoStoricoVisibility(objrow As Object) As Boolean
        Dim oRow As WcfDwhClinico.PazienteType = CType(objrow, WcfDwhClinico.PazienteType)
        Dim btnDossier As Button = CType(fvInfoPaziente.FindControl("btnConsensoDossierStorico1"), Button)
        Dim bReturn As Boolean = False
        If oRow.ConsensoAziendale Is Nothing Then
            bReturn = True
            '
            ' Applico le classi bootstrap per disabilitare il bottone se non è stato dato nessun consenso o se il consenso è generico
            '
            btnDossier.Attributes.Add("disabled", "disabled")
        ElseIf oRow.ConsensoAziendale.Codice = 1 Then
            bReturn = True
            '
            ' Applico le classi bootstrap per disabilitare il bottone se non è stato dato nessun consenso o se il consenso è generico
            '
            btnDossier.Attributes.Add("disabled", "disabled")
        ElseIf oRow.ConsensoAziendale.Codice = 2 Then
            bReturn = True
        End If
        Return bReturn
    End Function

    Protected Function GetCmdForzaturaConsensoVisibility(objrow As Object) As Boolean
        Dim oRow As WcfDwhClinico.PazienteType = CType(objrow, WcfDwhClinico.PazienteType)
        Dim bReturn As Boolean = True
        '
        ' se non posso forzare il consenso o se è già stato forzato allora non mostro il pulsante di forzatura del consenso
        '
        If Not Me.Context.User.IsInRole(RoleManagerUtility2.ATTRIB_ACC_DIR_ENABLED) OrElse Utility.GetSessionForzaturaConsenso(IdPaziente) Then
            bReturn = False
        Else
            If Not oRow.ConsensoAziendale Is Nothing Then
                '
                ' se l'ultimo consenso espresso è il DissierStorico(3) allora non mostro il pulsante di forzatura del consenso
                '
                If oRow.ConsensoAziendale.Codice = "3" Then
                    bReturn = False
                End If
            End If
        End If
        Return bReturn
    End Function

    Protected Function GetCmdForzaturaConsensoDisabled(objrow As Object) As Boolean
        Dim oRow As WcfDwhClinico.PazienteType = CType(objrow, WcfDwhClinico.PazienteType)
        Dim bReturn As Boolean = False
        If Utility.GetSessionForzaturaConsenso(IdPaziente) = True Then
            bReturn = True
        End If
        Return bReturn
    End Function

    Protected Function GetNavigateUrlDettaglioConsensi() As String
        Dim sUrl As String = UrlDettaglioConsensi
        If Not String.IsNullOrEmpty(sUrl) Then
            Return Me.ResolveUrl(sUrl)
        End If
        Return Nothing
    End Function

    Private Sub cmdAcquisizioneConsensoAnnulla_Click(sender As Object, e As EventArgs) Handles cmdAcquisizioneConsensoAnnulla.Click
        ' imposto come default value l'item "Scegli consenso"
        cboConsenso.SelectedValue = "-1"
        '
        ' Registro lo script lato client per chiudere la modale
        '
        Dim functionJS As String = "$('#ModalConsenso').modal('hide');"
        ScriptManager.RegisterStartupScript(Page, Page.GetType, "LanchServerSide", functionJS, True)
    End Sub

    Protected Function GetImgPresenzaReferti(objPazienteType As Object) As String
        '
        ' MODIFICA ETTORE 2017-04-04: la visualizzazione dei dati dipende dal consenso e dalla data del consenso
        '
        Dim oPazienteType As WcfDwhClinico.PazienteType = CType(objPazienteType, WcfDwhClinico.PazienteType)
        Dim sRetHtml As String = String.Empty
        Dim dDataConsenso As Nullable(Of Date) = Nothing
        Dim dDataUltimoReferto As Nullable(Of Date) = Nothing
        Dim bIconaVisibile As Boolean = False
        Try
            If Not oPazienteType Is Nothing AndAlso oPazienteType.UltimoRefertoData.HasValue Then
                If Not oPazienteType.ConsensoAziendale Is Nothing AndAlso Not String.IsNullOrEmpty(oPazienteType.ConsensoAziendale.Codice) Then
                    '
                    ' Se sono qui ho il consenso aziendale: memorizzo la data del consenso aziendale
                    '
                    If oPazienteType.ConsensoAziendale.Data <> Nothing Then
                        dDataConsenso = oPazienteType.ConsensoAziendale.Data
                    End If
                    dDataUltimoReferto = oPazienteType.UltimoRefertoData
                    bIconaVisibile = UserInterface.GetVisibilitaOggettoByDataConsenso(oPazienteType.ConsensoAziendale.Codice, dDataConsenso, dDataUltimoReferto)
                    '
                    '
                    '
                    If bIconaVisibile Then
                        '
                        ' Restituisce l'icona di presenza referti in base alla data dell'ultimo referto
                        '
                        sRetHtml = GetHtmlImgPresenzaReferti(oPazienteType)
                    End If
                End If
            End If
        Catch
            sRetHtml = String.Empty
        End Try
        Return sRetHtml
    End Function

    ''' <summary>
    ''' Ottiene l'icona di presenza delle Note Anamnestiche.
    ''' </summary>
    ''' <param name="Obj"></param>
    ''' <returns></returns>
    Protected Function GetImgPresenzaNotaAnamnestica(ByVal Obj As Object) As String
        Dim oRow As WcfDwhClinico.PazienteType = CType(Obj, WcfDwhClinico.PazienteType)
        Return UserInterface.GetImgPresenzaNoteAnamnestiche(oRow, Me.Page)
    End Function

    Private Function GetHtmlImgPresenzaReferti(oPaziente As WcfDwhClinico.PazienteType) As String
        Dim sTooltip As String = String.Empty
        Dim strHtml As String = String.Empty

        If oPaziente.UltimoRefertoData.HasValue Then
            Dim DataUltimoReferto As Date = oPaziente.UltimoRefertoData.Value
            sTooltip = String.Format("{0} {1:d}", oPaziente.UltimoRefertoSistemaErogante, DataUltimoReferto)
            '
            ' Restituisce l'icona relativa all'ultima data di modifica del referto nella pagina dei referti
            '
            If Now.AddDays(-1) <= DataUltimoReferto Then
                strHtml = "<img runat='server' src='" & Page.ResolveUrl("~/Images/PresenzaReferti1.gif") & "' data-toggle='tooltip' data-placement='top' title='" & sTooltip & "' > "
            ElseIf Now.AddDays(-7) <= DataUltimoReferto Then
                strHtml = "<img runat='server' src='" & Page.ResolveUrl("~/Images/PresenzaReferti7.gif") & "' data-toggle='tooltip' data-placement='top' title='" & sTooltip & "' > "
            ElseIf Now.AddDays(-30) <= DataUltimoReferto Then
                strHtml = "<img runat='server' src='" & Page.ResolveUrl("~/Images/PresenzaReferti30.gif") & "' data-toggle='tooltip' data-placement='top' title='" & sTooltip & "' > "
                'Else
                'Volendo si potrebbe mostrare un immagine per i referti più vecchi di 30 giorni
                'strHtml = "<img runat='server' src='" & Page.ResolveUrl("~/Images/PresenzaRefertiOlder.gif") & "' data-toggle='tooltip' data-placement='top' title='" & sTooltip & "' > "
            End If
        End If
        Return strHtml
    End Function

    Protected Function GetSimboloTipoEpisodioRicovero(objPazienteType As Object) As String
        Dim sRetHtml As String = String.Empty
        Try
            '
            ' MODIFICA ETTORE 2017-04-04: la visualizzazione dei dati dipende dal consenso e dalla data del consenso
            '
            Dim oPazienteType As WcfDwhClinico.PazienteType = CType(objPazienteType, WcfDwhClinico.PazienteType)
            Dim dDataConsenso As Nullable(Of Date) = Nothing
            Dim dDataAccettazione As Nullable(Of Date) = Nothing
            Dim bDatiVisibili As Boolean = GetInfoEpisodioVisibility(oPazienteType)


            If bDatiVisibili Then
                Dim sTipoEpisodioRicovero As String = CType(oPazienteType.Episodio.TipoEpisodio.Codice, String).ToUpper
                '
                ' Creo il testo contenente le informazioni sul ricovero
                '
                Dim sTooltip As String = String.Empty
                If Not oPazienteType.Episodio.DataConclusione.HasValue AndAlso oPazienteType.Episodio.StrutturaConclusione Is Nothing Then
                    '
                    ' Solo se il ricovero è ancora in corso e quindi solo se la DataConclusione e la StrutturaConclusione sono nothing
                    '
                    If oPazienteType.Episodio.DataApertura.HasValue AndAlso Not oPazienteType.Episodio.StrutturaUltimoEvento Is Nothing Then
                        If oPazienteType.Episodio.DataUltimoEvento.HasValue Then
                            sTooltip = String.Format("Ricoverato nel reparto {0} dal {1:d}", oPazienteType.Episodio.StrutturaUltimoEvento.Descrizione.NullSafeToString, oPazienteType.Episodio.DataUltimoEvento.Value)
                        Else
                            sTooltip = String.Format("Ricoverato nel reparto {0}", oPazienteType.Episodio.StrutturaUltimoEvento.Descrizione.NullSafeToString)
                        End If
                    End If
                Else
                    '
                    ' Solo se il ricovero è concluso e quindi solo se la DataConclusione e la StrutturaConclusione non sono nothing
                    '
                    If oPazienteType.Episodio.DataConclusione.HasValue Then
                        sTooltip = String.Format("Dimesso dal reparto {0} il {1:d}", oPazienteType.Episodio.StrutturaConclusione.Descrizione.NullSafeToString, oPazienteType.Episodio.DataConclusione.Value)
                    Else
                        sTooltip = String.Format("Dimesso dal reparto {0}", oPazienteType.Episodio.StrutturaConclusione.Descrizione.NullSafeToString)
                    End If
                End If

                '
                ' genero il codice html legato all'icona del ricovero.
                ' genera anche un tooltip bootstrap che contiene le informazioni sul ricovero
                '
                sRetHtml = Me.GetHtmlImgTipoEpisodioRicovero(sTipoEpisodioRicovero, sTooltip)
            End If
        Catch
            sRetHtml = String.Empty
        End Try
        '
        '
        '
        Return sRetHtml
    End Function

    Private Function GetHtmlImgTipoEpisodioRicovero(ByVal sTipoEpisodioRicovero As String, sTooltip As String) As String
        '
        ' Crea il codice html per l'immagine legata al tipo di ricovero
        ' gli viene passato il testo contenente le informazioni sul ricovero che verrà visualizzato come tooltip bootstrap
        '
        Dim strHtml As String = String.Empty
        Select Case sTipoEpisodioRicovero.ToUpper
            Case "O" 'Ricovero Ordinario
                strHtml = "<img src='" & VirtualPathUtility.ToAbsolute("~/images/RicoveroOrdinario.gif") & "' data-toggle='tooltip' data-placement='top' title='" & sTooltip & "' > "
            Case "D" 'Day Hospital
                strHtml = "<img src='" & VirtualPathUtility.ToAbsolute("~/images/RicoveroDH.gif") & "' data-toggle='tooltip' data-placement='top' title='" & sTooltip & "'>"
            Case "S" 'Day Service
                strHtml = "<img src='" & VirtualPathUtility.ToAbsolute("~/images/RicoveroDS.gif") & "' data-toggle='tooltip' data-placement='top' title='" & sTooltip & "'>"
            Case "P" 'Pronto Soccorso
                strHtml = "<img src='" & VirtualPathUtility.ToAbsolute("~/images/RicoveroPS.gif") & "' data-toggle='tooltip' data-placement='top' title='" & sTooltip & "'>"
            Case "B" 'OBI
                strHtml = "<img src='" & VirtualPathUtility.ToAbsolute("~/images/RicoveroOBI.gif") & "' data-toggle='tooltip' data-placement='top' title='" & sTooltip & "'>"
        End Select
        Return strHtml
    End Function
#End Region

    Private Function GetInfoEpisodioVisibility(oPaziente As WcfDwhClinico.PazienteType) As Boolean
        Dim bReturn = False

        '
        'Controll se oPaziente non è vuoto e se l'episodio è concluso.
        '
        If Not oPaziente Is Nothing AndAlso Not oPaziente.Episodio Is Nothing AndAlso Not oPaziente.Episodio.DataConclusione.HasValue Then
            '
            'Cointrollo il tipoEpisodio e la categoria
            '
            If Not oPaziente.Episodio.TipoEpisodio Is Nothing AndAlso String.Compare(oPaziente.Episodio.Categoria, "Ricovero", True) = 0 Then
                Dim sTipoEpisodioRicovero As String = CType(oPaziente.Episodio.TipoEpisodio.Codice, String).ToUpper

                '
                'Controllo i consensi
                '
                If Not String.IsNullOrEmpty(sTipoEpisodioRicovero) AndAlso Not oPaziente.ConsensoAziendale Is Nothing AndAlso Not String.IsNullOrEmpty(oPaziente.ConsensoAziendale.Codice) Then
                    Dim dDataConsenso As Nullable(Of Date) = Nothing
                    Dim dDataAccettazione As Nullable(Of Date) = Nothing
                    If oPaziente.ConsensoAziendale.Data <> Nothing Then
                        dDataConsenso = oPaziente.ConsensoAziendale.Data
                    End If
                    dDataAccettazione = oPaziente.Episodio.DataApertura
                    bReturn = UserInterface.GetVisibilitaOggettoByDataConsenso(oPaziente.ConsensoAziendale.Codice, dDataConsenso, dDataAccettazione)
                End If
            End If
        End If

        Return bReturn
    End Function
End Class