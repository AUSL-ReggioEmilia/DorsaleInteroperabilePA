Imports DwhClinico.Data
Imports DwhClinico.Web
Imports DwhClinico.Web.Utility
'************************************************************************************************************************
' MODIFICHE:
'   1)  In seguito a modifica dei consensi ho gestito i nuovi tipi di consesno DOSSIER, DOSSIERSTORICO
'   2)  La negazione del consenso N implica la negazione dei consesni N+1 
'               (se GENERICO viene NEGATO, allora si nega DOSSIER e DOSSIERSTORICO)
'               (se DOSSIER  viene NEGATO, allora si nega DOSSIERSTORICO)
'               (se DOSSIERSTORICO viene NEGATO non faccio nulla)
'************************************************************************************************************************
Partial Class Pazienti_PazientiConsensoModifica
    Inherits System.Web.UI.Page
    '
    ' Variabili private della classe
    '
    Private meTipoConsenso As SacConsensiDataAccess.TipoConsenso
    Private mguidIdPaziente As Guid

    Private Property IsPazienteMinorenne As Boolean
        Get
            Return CType(ViewState("-IsPazienteMinorenne -"), Boolean)
        End Get
        Set(ByVal value As Boolean)
            ViewState("-IsPazienteMinorenne -") = value
        End Set
    End Property

    Private Sub Page_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load
        Try
            '
            ' Leggo parametri dal QueryString
            '
            mguidIdPaziente = New Guid(Request.QueryString(PAR_ID_PAZIENTE))
            '
            ' Memorizzo il tipo di consenso
            '
            Dim sTipoConsenso As String = Request.QueryString(PAR_ID_TIPO_CONSENSO)
            If String.IsNullOrEmpty(sTipoConsenso) Then
                meTipoConsenso = SacConsensiDataAccess.TipoConsenso.Generico
            Else
                meTipoConsenso = CType(CType(sTipoConsenso, Integer), SacConsensiDataAccess.TipoConsenso)
                Select Case meTipoConsenso
                    Case SacConsensiDataAccess.TipoConsenso.Generico, SacConsensiDataAccess.TipoConsenso.Dossier, SacConsensiDataAccess.TipoConsenso.DossierStorico
                        'OK
                    Case Else
                        Throw New ApplicationException(String.Format("Il TipoConsenso {0} non è gestito!", sTipoConsenso))
                End Select
            End If
            '
            ' Aggiungo lo script per lo stylesheet
            '
            'PageAddCss(Me)
            If Not IsPostBack Then
                '
                ' Eseguo il bind della griglia con i dati (solo se è un PostBack)
                '
                Call PageDataBind()
                '
                ' Aggiorno la barra di navigazione
                '
                BarraNavigazione.SetCurrentItem("Modifica consenso", "")
            End If
            '
            ' Inizializzo la pagina
            '
            Call InitializePage()
        Catch ex As ApplicationException
            cmdOK.Enabled = False
            lblErrorMessage.Text = ex.Message
        Catch ex As Exception
            cmdOK.Enabled = False
            lblErrorMessage.Text = "Errore durante il caricamento della pagina!"
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

    Private Sub InitializePage()
        '
        ' Inizializzo la pagina
        '
        '
        ' Aggiungo lo script lato client
        ' ATTENZIONE: il control deve avere la proprietà CauseValidation = False
        ' altrimenti viene aggiunto sempre uno script di sistema nell'evento OnClick
        ' e quello della conferma non viene eseguito !
        '
        Dim strScript As String

        'strScript = "javascript:return confirm('Confermi la modifica del consenso?');"
        'cmdOK.Attributes.Item("onclick") = strScript

        strScript = "javascript:document.location.href='PazientiConsenso.aspx?" & PAR_ID_PAZIENTE & "=" & mguidIdPaziente.ToString & "'"
        cmdAnnulla.Attributes.Item("onclick") = strScript

        Dim strUrlInfo As String = Me.ResolveUrl("~/Documenti/informativa.pdf")

        strScript = "javascript:window.open('" & strUrlInfo & "','new_window');"
        cmdInformativa.Attributes.Item("onclick") = strScript
        '
        ' Aggiorno User Interface
        '
        Call UpdateUI()

    End Sub

    Private Sub PageDataBind()
        '
        ' Eseguo il bind della pagina con i dati
        '
        Try
            '
            ' Prendo username
            '
            Dim oCurrentUser As CurrentUser = GetCurrentUser()
            Dim oDettaglioUtente As Utility.DettaglioUtente = Utility.GetDettaglioUtente(oCurrentUser.DomainName, oCurrentUser.UserName)
            '
            ' Prendo i dati del paziente dai dati salvati in sessione
            '
            Dim oSacDettaglioPaziente As SacDettaglioPaziente = SacDettaglioPaziente.Session()
            If oSacDettaglioPaziente Is Nothing Then
                Dim oPazienteSac As New PazienteSac
                oSacDettaglioPaziente = oPazienteSac.GetData(mguidIdPaziente.ToString)
                SacDettaglioPaziente.Session() = oSacDettaglioPaziente
            End If
            '
            ' Verifico
            '
            If oDettaglioUtente Is Nothing Then
                '
                ' Errore
                '
                lblErrorMessage.Text = "Dati dell'operatore non trovati!"
                lblErrorMessage.Visible = True
            End If
            If oSacDettaglioPaziente Is Nothing Then
                '
                ' Errore
                '
                lblErrorMessage.Text = "Dati del paziente non trovati!"
                lblErrorMessage.Visible = True
            End If
            '
            ' Eseguo il bind con i dati del paziente
            '
            If (Not oDettaglioUtente Is Nothing) And (Not oSacDettaglioPaziente Is Nothing) Then
                '
                ' Dati del paziente
                '
                lblCognome.Text = oSacDettaglioPaziente.Cognome
                lblNome.Text = oSacDettaglioPaziente.Nome
                lblCodiceFiscale.Text = oSacDettaglioPaziente.CodiceFiscale
                lblDataNascita.Text = String.Empty
                If oSacDettaglioPaziente.DataNascita.HasValue Then
                    lblDataNascita.Text = oSacDettaglioPaziente.DataNascita.Value.ToShortDateString
                End If
                lblLuogoNascita.Text = oSacDettaglioPaziente.LuogoNascita
                '
                ' Dati dell'utente loggato
                '
                lblUtenteNome.Text = oDettaglioUtente.NomeCompleto
                '
                ' Visualizzo il titolo
                '
                PageTitle.InnerText = String.Format("Inserimento nuovo consenso ""{0}"" per {1} {2}", Utility.TipoConsensoDescrizione(meTipoConsenso), oSacDettaglioPaziente.Cognome, oSacDettaglioPaziente.Nome)
            End If
            '
            ' Imposto il consenso ad un valore di default...
            ' Se attualmente Positivo -> Negativo
            ' Se attualmente Negativo -> Positivo
            '
            Dim oConsenso As Consenso = GetConsensoByTipoConsenso(meTipoConsenso, oSacDettaglioPaziente)
            If Not oConsenso Is Nothing Then
                Select Case oConsenso.Stato
                    Case ConsensoStato.NonAcquisito, ConsensoStato.Negato
                        'seleziono il positivo
                        cboConsenso.Items.FindByValue("1").Selected = True
                    Case ConsensoStato.Accordato
                        'seleziono il negativo 
                        cboConsenso.Items.FindByValue("0").Selected = True
                End Select
            End If
            '
            ' MODIFICA ETTORE 2016-01-22: Dati dell'Autorizzatore per il minore
            '
            Dim Eta As Integer = Utility.CalcolaEta(oSacDettaglioPaziente.DataNascita, Now)
            IsPazienteMinorenne = CBool(Eta < 18)
            Call InitUtenteAutorizzatoreDelMinore(IsPazienteMinorenne, oSacDettaglioPaziente.IdPaziente)

        Catch ex As Exception
            '
            ' Gestione dell'errore
            '
            Dim sMsg As String = "Errore durante il caricamento dei dati paziente e utente."
            lblErrorMessage.Text = sMsg
            lblErrorMessage.Visible = True
            Logging.WriteError(ex, sMsg)
        Finally
        End Try

    End Sub

    Private Sub UpdateUI()
        '
        ' Aggiorno User Interface
        '
        cmdOK.Enabled = CInt(cboConsenso.SelectedValue) <> -1

    End Sub

    Private Sub cmdOK_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdOK.Click
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
                '
                ' Prendo i dati del paziente dai dati salvati in sessione
                '
                Dim oSacDettaglioPaziente As SacDettaglioPaziente = SacDettaglioPaziente.Session()
                If oSacDettaglioPaziente Is Nothing Then
                    Dim oPazienteSac As New PazienteSac
                    oSacDettaglioPaziente = oPazienteSac.GetData(mguidIdPaziente.ToString)
                    SacDettaglioPaziente.Session() = oSacDettaglioPaziente
                End If
                '--------------------------------------------------------------------------------------------------------
                ' MODIFICA ETTORE 2016-01-22: salvataggio dei dati dell'autorizzatore del minore in sessione
                '--------------------------------------------------------------------------------------------------------
                If IsPazienteMinorenne Then
                    '
                    ' Salvo in sessione i dati dell'autorizzatore
                    ' I dati sono già stati validati, anche la data di nascita quindi la posso convertire direttamente
                    '
                    Dim oDataNascita As DateTime = Nothing
                    'La data è già stata validata lato client quindi posso convertire tranquillamente
                    Date.TryParse(txtAutorizzatoreDataNascita.Text, oDataNascita)
                    'Salvo i dati in sessione
                    Session(SESS_AUTORIZZATORE_CONSENSO_MINORE & oSacDettaglioPaziente.IdPaziente.ToString) = New UtenteAutorizzatoreMinore(
                                                                                  txtAutorizzatoreMinoreCognome.Text, _
                                                                                  txtAutorizzatoreMinoreNome.Text, _
                                                                                  oDataNascita, _
                                                                                  txtAutorizzatoreLuogoNascita.Text, _
                                                                                  cmbAutorizzatoreMinoreRelazioneColMinore.SelectedItem.Value)
                    '
                    ' Creo la classe con i dati del consenso da passare al metodo di inserimento consenso
                    '
                    oAttributiType = Utility.BuildAttributiAutorizzatoreDelMinore(txtAutorizzatoreMinoreCognome.Text, _
                                                                                  txtAutorizzatoreMinoreNome.Text, _
                                                                                  oDataNascita, _
                                                                                  txtAutorizzatoreLuogoNascita.Text, _
                                                                                  cmbAutorizzatoreMinoreRelazioneColMinore.SelectedItem.Text
                                                                                  )

                End If
                '
                ' Istanzio il webservice e imposto le credenziali in base al metodo di autenticazione Integrata(NTLM)/Basic
                '
                oSacConsensiWs = New SacConsensiDataAccess.ConsensiSoapClient
                If oSacConsensiWs Is Nothing Then
                    Throw New Exception("Errore: il Web Service SacConsensiDataAccess.ConsensiSoapClient è nothing.")
                End If
                Call Utility.SetWsConsensiCredential(oSacConsensiWs)
                '
                ' Creo la classe con i dati del consenso da passare al metodo di inserimento consenso
                '
                Dim oConsenso As SacConsensiDataAccess.Consenso = PopoloDatiConsenso(meTipoConsenso, bStatoConsenso, _
                                                  oSacDettaglioPaziente.Provenienza, oSacDettaglioPaziente.IdProvenienza, _
                                                  oSacDettaglioPaziente.Cognome, oSacDettaglioPaziente.Nome, oSacDettaglioPaziente.CodiceFiscale, oSacDettaglioPaziente.DataNascita, oSacDettaglioPaziente.CodiceSanitario, _
                                                  sOperatoreAccount, sOperatoreCognome, sOperatoreNome, _
                                                  oCurrentUser.HostName, oAttributiType)

                Call InserimentoConsenso(oSacConsensiWs, oConsenso)
                '
                ' Se sto negando consenso N nego anche i consensi N+1
                '
                If bStatoConsenso = False Then
                    Select Case meTipoConsenso
                        Case SacConsensiDataAccess.TipoConsenso.Generico
                            '1) Nego DOSSIER
                            oConsenso = PopoloDatiConsenso(SacConsensiDataAccess.TipoConsenso.Dossier, False, _
                                                oSacDettaglioPaziente.Provenienza, oSacDettaglioPaziente.IdProvenienza, _
                                                  oSacDettaglioPaziente.Cognome, oSacDettaglioPaziente.Nome, oSacDettaglioPaziente.CodiceFiscale, oSacDettaglioPaziente.DataNascita, oSacDettaglioPaziente.CodiceSanitario, _
                                                  sOperatoreAccount, sOperatoreCognome, sOperatoreNome, _
                                                  oCurrentUser.HostName, oAttributiType)
                            Call InserimentoConsenso(oSacConsensiWs, oConsenso)
                            '2) Nego DOSSIERSTORICO
                            oConsenso = PopoloDatiConsenso(SacConsensiDataAccess.TipoConsenso.DossierStorico, False, _
                                                oSacDettaglioPaziente.Provenienza, oSacDettaglioPaziente.IdProvenienza, _
                                                  oSacDettaglioPaziente.Cognome, oSacDettaglioPaziente.Nome, oSacDettaglioPaziente.CodiceFiscale, oSacDettaglioPaziente.DataNascita, oSacDettaglioPaziente.CodiceSanitario, _
                                                  sOperatoreAccount, sOperatoreCognome, sOperatoreNome, _
                                                  oCurrentUser.HostName, oAttributiType)
                            Call InserimentoConsenso(oSacConsensiWs, oConsenso)

                        Case SacConsensiDataAccess.TipoConsenso.Dossier
                            '1) Nego DOSSIERSTORICO
                            oConsenso = PopoloDatiConsenso(SacConsensiDataAccess.TipoConsenso.DossierStorico, False, _
                                                oSacDettaglioPaziente.Provenienza, oSacDettaglioPaziente.IdProvenienza, _
                                                  oSacDettaglioPaziente.Cognome, oSacDettaglioPaziente.Nome, oSacDettaglioPaziente.CodiceFiscale, oSacDettaglioPaziente.DataNascita, oSacDettaglioPaziente.CodiceSanitario, _
                                                  sOperatoreAccount, sOperatoreCognome, sOperatoreNome, _
                                                  oCurrentUser.HostName, oAttributiType)
                            Call InserimentoConsenso(oSacConsensiWs, oConsenso)

                        Case SacConsensiDataAccess.TipoConsenso.DossierStorico
                            'NON DEVO FARE NULLA
                    End Select
                End If
                '
                ' Ridireziono alla pagina del consenso
                ' 
                Response.Redirect("PazientiConsenso.aspx?" & PAR_ID_PAZIENTE & "=" & mguidIdPaziente.ToString, False)

            Else
                '
                ' Gestione dell'errore
                '
                lblErrorMessage.Text = "E' necessario selezionare un valore della casella 'consenso' per proseguire."
            End If

        Catch ex As System.Web.Services.Protocols.SoapException
            '
            ' Messaggio di errore
            '
            Dim sMsgErr As String = "Errore:" & vbCrLf & ex.Message & vbCrLf & _
                                    "Dettaglio:" & vbCrLf & ex.Detail.InnerText() & vbCrLf & _
                                    "StackTrace:" & vbCrLf & ex.StackTrace
            Logging.WriteError(ex, sMsgErr)
            lblErrorMessage.Text = "Errore durante l'operazione d'inserimento del Consenso.<BR>Verificare l'esistenza del paziente nell' Anagrafica Centralizzata (SAC)."

        Catch ex As Exception
            '
            ' Gestione dell'errore
            '
            lblErrorMessage.Text = "Errore durante l'operazione di modifica del Consenso."
            Logging.WriteError(ex, "Errore durante l'operazione di modifica del Consenso.")
        Finally
        End Try

    End Sub

    Private Sub chkConsenso_CheckedChanged(ByVal sender As System.Object, ByVal e As System.EventArgs)
        '
        ' Aggiorno User Interface
        '
        Call UpdateUI()
    End Sub


    Private Function PopoloDatiConsenso(ByVal eTipoConsenso As SacConsensiDataAccess.TipoConsenso, ByVal bStatoConsenso As Boolean, _
                                       ByVal sPazienteProvenienza As String, ByVal sPazienteIdProvenienza As String, _
                                         ByVal sPazienteCognome As String, ByVal sPazienteNome As String, ByVal sPazienteCodiceFiscale As String, _
                                         ByVal dPazienteDataNascita As Nullable(Of Date), ByVal sPazienteCodiceSanitario As String, _
                                         ByVal sAccountOperatore As String, ByVal sOperatoreCognome As String, ByVal sOperatoreNome As String, _
                                         ByVal sOperatoreComputer As String, _
                                         ByVal oAttributiType As SacConsensiDataAccess.AttributiType) As SacConsensiDataAccess.Consenso
        Dim oConsenso As New SacConsensiDataAccess.Consenso
        With oConsenso
            .DataStato = DateTime.Now

            .PazienteProvenienza = sPazienteProvenienza
            .PazienteIdProvenienza = sPazienteIdProvenienza

            .OperatoreCognome = sOperatoreCognome
            .OperatoreComputer = sOperatoreComputer
            .OperatoreId = sAccountOperatore
            .OperatoreNome = sOperatoreNome
            .PazienteCognome = sPazienteCognome
            .PazienteNome = sPazienteNome
            .PazienteCodiceFiscale = sPazienteCodiceFiscale
            If dPazienteDataNascita.HasValue Then .PazienteDataNascita = dPazienteDataNascita
            .PazienteTesseraSanitaria = sPazienteCodiceSanitario
            .Stato = bStatoConsenso
            .Tipo = eTipoConsenso
            .Attributi = oAttributiType
        End With
        '
        ' Restituisco
        '
        Return oConsenso

    End Function


    Private Sub InserimentoConsenso(oSacConsensiWs As SacConsensiDataAccess.ConsensiSoap, oConsenso As SacConsensiDataAccess.Consenso)
        Dim body As New SacConsensiDataAccess.ConsensiAggiungiRequestBody(oConsenso)
        Dim request As New SacConsensiDataAccess.ConsensiAggiungiRequest(body)
        Call oSacConsensiWs.ConsensiAggiungi(request)
    End Sub


    Private Function GetConsensoByTipoConsenso(ByVal eTipoConsenso As SacConsensiDataAccess.TipoConsenso, ByVal oSacDettaglioPaziente As SacDettaglioPaziente) As Consenso
        Dim oConsenso As Consenso = Nothing
        Select Case eTipoConsenso
            Case SacConsensiDataAccess.TipoConsenso.Generico
                oConsenso = oSacDettaglioPaziente.GetConsensoGenerico()
            Case SacConsensiDataAccess.TipoConsenso.Dossier
                oConsenso = oSacDettaglioPaziente.GetConsensoDossier()
            Case SacConsensiDataAccess.TipoConsenso.DossierStorico
                oConsenso = oSacDettaglioPaziente.GetConsensoDossierStorico()
        End Select
        Return oConsenso
    End Function

    ''' <summary>
    ''' Funzione per inizializzare i controlli dell'utente autorizzatore del minore
    ''' </summary>
    ''' <param name="bPazienteMinorenne"></param>
    ''' <param name="IdPaziente"></param>
    ''' <remarks></remarks>
    Private Sub InitUtenteAutorizzatoreDelMinore(ByVal bPazienteMinorenne As Boolean, ByVal IdPaziente As Guid)
        If IsPazienteMinorenne Then
            lblUtenteAutorizzatoreTitolo.Text = My.Settings.DatiAutenteAutorizzatore_Titolo
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

End Class
