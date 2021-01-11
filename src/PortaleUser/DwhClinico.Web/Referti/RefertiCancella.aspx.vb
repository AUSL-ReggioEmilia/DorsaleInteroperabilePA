Imports DI.PortalUser2
Imports DwhClinico.Data
Imports DwhClinico.Web
Imports DwhClinico.Web.Utility

Partial Class Referti_RefertiCancella
    Inherits System.Web.UI.Page

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

    Public Property IdReferto As Guid
        Get
            Return Me.ViewState("IdReferto")
        End Get
        Set(value As Guid)
            Me.ViewState("IdReferto") = value
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
#End Region

    Private Sub Page_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load
        Try
            'UTILIZZO LA VARIABILE DI SESSIONE IsSessioneAttiva PER VERIFICARE SE LA SESSIONE È SCADUTA.
            If SessionHandler.ValidaSessioneAccessoStandard Is Nothing OrElse SessionHandler.ValidaSessioneAccessoStandard = False Then
                Call RedirectToHome()
                Exit Sub
            End If

            ' OTTENGO I PARAMETRI DAL QUERY STRING.
            Dim sIdReferto As String = Request.QueryString(PAR_ID_REFERTO)
            If Not Guid.TryParse(sIdReferto, Me.IdReferto) Then
                Throw New ApplicationException("La combinazione dei parametri non è corretta.")
            End If

            If Not IsPostBack Then
                ' MOSTRO LE INFORMAZIONI DEL REFERTO E LA TESTATA DEL PAZIENTE SOLO SE L'UTENTE HA I DIRITTI DI CANCELLAZIONE/OSCURAMENTO DEL REFERTO
                If HttpContext.Current.User.IsInRole(RoleManagerUtility2.ATTRIB_OSC_REFERTI) Then
                    'OTTENGO IL DETTAGLIO DEL REFERTO.
                    Dim dettaglioReferto As WcfDwhClinico.RefertoType = Nothing
                    Dim RefertoOttieniPerId As New CustomDataSource.RefertoOttieniPerId
                    dettaglioReferto = RefertoOttieniPerId.GetData(Me.Token, Me.IdReferto)

                    'TESTO SE IL DETTAGLIO DEL REFERTO NON È NOTHING.
                    If Not dettaglioReferto Is Nothing Then
                        If Not dettaglioReferto.Paziente Is Nothing Then
                            'RICAVO L'ID DEL PAZIENTE DAL DETTAGLIO DEL REFERTO.
                            Me.IdPaziente = New Guid(dettaglioReferto.IdPaziente)

                            'RICAVO L'ID DEL PAZIENTE DA PASSARE ALLA TESTATA DEL PAZIENTE DAL DETTAGLIO DEL REFERTO.
                            ucTestataPaziente.IdPaziente = Me.IdPaziente
                            ucTestataPaziente.Token = Me.Token
                            ucTestataPaziente.CodiceRuolo = Me.CodiceRuolo
                            ucTestataPaziente.CodiceRuolo = Me.DescrizioneRuolo
                            ucTestataPaziente.MostraSoloDatiAnagrafici = True

                            'ottengo l'ultimo consenso espresso del paziente.
                            'lo user control ucTestataPaziente espone diverse property del paziente.
                            Me.ConsensoPaziente = ucTestataPaziente.UltimoConsensoAziendaleEspresso

                            ' VALORIZZO GLI ATTRIBUTI ANAGRAFICI DEL PAZIENTE COLLEGATI AL REFERTO
                            ucInfoPaziente.Nome = dettaglioReferto.Paziente.Nome
                            ucInfoPaziente.Cognome = dettaglioReferto.Paziente.Cognome
                            ucInfoPaziente.CodiceFiscale = dettaglioReferto.Paziente.CodiceFiscale
                            ucInfoPaziente.LuogoNascita = dettaglioReferto.Paziente.ComuneNascita
                            If dettaglioReferto.Paziente.DataNascita.HasValue Then
                                ucInfoPaziente.DataNascita = dettaglioReferto.Paziente.DataNascita.Value
                            End If

                            ' VALORIZZO LE INFORMAZIONI DEL REFERTO
                            lblNumeroReferto.Text = dettaglioReferto.NumeroReferto
                            If dettaglioReferto.DataReferto <> Nothing Then
                                lblDataReferto.Text = String.Format("{0:d}", dettaglioReferto.DataReferto)
                            End If
                            lblNosologico.Text = dettaglioReferto.NumeroNosologico
                            lblAziendaErogante.Text = dettaglioReferto.AziendaErogante
                            lblSistemaErogante.Text = dettaglioReferto.SistemaErogante
                            If Not dettaglioReferto.RepartoErogante Is Nothing Then
                                lblRepartoErogante.Text = dettaglioReferto.RepartoErogante.Descrizione
                            End If
                            If Not dettaglioReferto.RepartoRichiedente Is Nothing Then
                                lblRepartoRichiedente.Text = dettaglioReferto.RepartoRichiedente.Descrizione
                            End If
                        End If
                    Else
                        Throw New ApplicationException("Impossibile trovare il referto.")
                    End If
                Else
                    '
                    ' Accesso negato
                    '
                    Response.Redirect(Me.ResolveUrl("~/AccessDenied.htm"))
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
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante il caricamento della pagina."
            Logging.WriteError(ex, "Page_Load")
        End Try
    End Sub

    Private Sub RedirectToHome()
        Response.Redirect(Me.ResolveUrl("~/Default.aspx"), True)
    End Sub

    Private Function Delete() As Boolean
        '
        ' Esegue cancellazione
        '
        Try
            '
            ' Effettua la cancellazione e logga l'operazione
            'QUERY SU DB
            Using oData As Referti = New Referti
                oData.CancellazioneRefertoDettaglioUpdate(Me.IdReferto, Context.User.Identity.Name)
            End Using

            '
            ' Traccia accessi
            '
            TracciaAccessi.TracciaAccessiLista(Me.CodiceRuolo, Me.DescrizioneRuolo, "Cancellazione logica del referto " & Me.IdReferto.ToString, Me.IdPaziente, SessionHandler.MotivoAccesso, SessionHandler.MotivoAccessoNote, 1, Me.ConsensoPaziente)

            Return True
        Catch ex As Threading.ThreadAbortException
            '
            ' Non faccio niente
            '
        Catch ex As Exception
            '
            ' Segnalazione dell'errore
            '
            lblErrorMessage.Text = "Si è verificato un errore durante la cancellazione."
            divErrorMessage.Visible = True
            Logging.WriteError(ex, "Errore durante la cancellazione del paziente " & Me.IdReferto.ToString)
            Return False
        End Try
    End Function

    Private Sub GoBack()
        Try
            ' TORNA ALLA PAGINA CHIAMANTE
            Response.Redirect("~/Referti/RefertiListaPaziente.aspx?IdPaziente=" & Me.IdPaziente.ToString)
        Catch ex As Exception
            Dim sErrore As String = "Si è verificato un errore durante la navigazione alla pagina dei referti."
            lblErrorMessage.Text = sErrore
            divErrorMessage.Visible = True
            Logging.WriteError(ex, sErrore & "IdReferto=" & Me.IdReferto.ToString)
        End Try
    End Sub

    Public Function GetCancellazioneRefertoOperation(ByVal oIdReferto As Guid) As String
        '
        ' Restituisce il testo dell'operazione per il log.
        '
        Dim oSB As New System.Text.StringBuilder

        oSB = oSB.Append("Cancellazione logica referto")
        oSB = oSB.Append(ControlChars.CrLf)
        oSB = oSB.AppendFormat("IdReferto={0}", oIdReferto.ToString)

        Return oSB.ToString
    End Function

    Protected Sub cmdCancella_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdCancella.Click
        '
        ' Salvo i dati e chiudo
        '
        If Delete() Then
            '
            ' Comando l'aggiornamento dei dati nella pagina di lista dei referti
            '
            SessionHandler.CancellaCache = True
            GoBack()
        End If
    End Sub

    Protected Sub cmdBack_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdBack.Click
        '
        ' Torna alla lista
        '
        GoBack()
    End Sub
End Class