Imports DI.PortalUser2
Imports DwhClinico.Data
Imports DwhClinico.Web
Imports DwhClinico.Web.Utility

Partial Class Pazienti_PazientiCancella
    Inherits System.Web.UI.Page
    '
    ' Costanti per la memorizzazione nel ViewState
    '
    Private Const VS_BACK_URL As String = "back_url"

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
#End Region

    Private Sub Page_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load
        Dim oIdPaziente As Guid
        Dim sIdPaziente As String
        Try
            'UTILIZZO LA VARIABILE DI SESSIONE IsSessioneAttiva PER VERIFICARE SE LA SESSIONE È SCADUTA.
            If SessionHandler.ValidaSessioneAccessoStandard Is Nothing OrElse SessionHandler.ValidaSessioneAccessoStandard = False Then
                RedirectToHome()
                Exit Sub
            End If

            ' LEGGE I PARAMETRI DAL QUERY STRING.
            sIdPaziente = Request.QueryString(PAR_ID_PAZIENTE)
            If Not Guid.TryParse(sIdPaziente, oIdPaziente) Then
                Throw New ApplicationException("I parametri della pagina non sono corretti.")
            End If

            If Not IsPostBack Then
                divPage.Visible = True
                divErrorMessage.Visible = False
                '
                ' memorizzo l'id del paziente 
                '
                Me.IdPaziente = oIdPaziente
                '
                ' Verifico il ruolo di cancellazione
                '
                If Not CheckPermission(My.Settings.Role_Delete) Then
                    '
                    ' Se l'utente non ha i permessi segnalo che l'utente non ha i diritti
                    '
                    Throw New ApplicationException("L'utente non ha i diritti per accedere alla pagina.")
                Else
                    '
                    ' Passo alla testata del paziente il token e l'id del paziente per fare il bind dei dati
                    '
                    ucTestataPaziente.IdPaziente = Me.IdPaziente
                    ucTestataPaziente.Token = Me.Token
                    ucTestataPaziente.CodiceRuolo = Me.CodiceRuolo
                    ucTestataPaziente.DescrizioneRuolo = Me.CodiceRuolo
                    ucTestataPaziente.MostraSoloDatiAnagrafici = True

                    'ottengo l'ultimo consenso espresso del paziente.
                    'lo user control ucTestataPaziente espone diverse property del paziente.
                    Me.ConsensoPaziente = ucTestataPaziente.UltimoConsensoAziendaleEspresso

                    '
                    ' Memorizzo Url di provenienza
                    '
                    ViewState(VS_BACK_URL) = Me.ResolveUrl(Request.UrlReferrer.AbsoluteUri)
                End If

            End If
        Catch ex As Threading.ThreadAbortException
            '
            ' Non faccio niente
            '
        Catch ex As ApplicationException
            divErrorMessage.Visible = True
            lblErrorMessage.Text = ex.Message
            NascondoPagina()
            Logging.WriteError(ex, Me.GetType.Name)
        Catch ex As Exception
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante il caricamento della pagina!"
            NascondoPagina()
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

    Private Sub NascondoPagina()
        divPage.Visible = False
    End Sub

    Private Sub RedirectToHome()
        Response.Redirect(Me.ResolveUrl("~/Default.aspx"), True)
    End Sub

    ''' <summary>
    ''' Esegue la cancellazione logica di un paziente.
    ''' </summary>
    ''' <returns></returns>
    Private Function Delete() As Boolean
        Try
            '
            ' Effettua la cancellazione e logga l'operazione
            ' QUERY SU DB
            Using oData As New Pazienti
                oData.CancellazionePazienteAggiungi(Me.IdPaziente, Context.User.Identity.Name)
            End Using

            '
            'TODO: 2018-11-27: con il nuovo "oscuramento per IdPaziente" (tabella PazientiOscurati) quando sarà completo bisognerà poi rimuovere la tabella PazientiCancellati
            '
            Dim oIdReparto As Guid

            ' Tracciamento degli accessi
            ' Traccio l'eliminazione logica di un paziente.
            Dim sOperazione As String = GetCancellazionePazienteOperation(Me.IdPaziente, oIdReparto)
            TracciaAccessi.TracciaAccessiPaziente(Me.CodiceRuolo, Me.DescrizioneRuolo, sOperazione, Me.IdPaziente, SessionHandler.MotivoAccesso, SessionHandler.MotivoAccessoNote, 1, Me.ConsensoPaziente)

            Return True
        Catch ex As Exception
            '
            ' Segnalazione dell'errore
            '
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Si è verificato un errore durante la cancellazione."
            Logging.WriteError(ex, "Errore durante la cancellazione del paziente " & Me.IdPaziente.ToString)
            Return False
        End Try

    End Function



    Private Sub GoBack()
        '
        ' Torna alla pagina chiamante
        '
        Dim sBackUrl As String = ViewState(VS_BACK_URL) & ""
        If sBackUrl.Length > 0 Then
            Response.Redirect(Me.ResolveUrl(sBackUrl))
        End If
    End Sub

    Private Function GetCancellazionePazienteOperation(ByVal oIdPaziente As Guid, ByVal oIdReparto As Guid) As String
        '
        ' Restituisce il testo dell'operazione per il log.
        '
        Dim oSB As New System.Text.StringBuilder
        Dim sIdReparto As String

        oSB = oSB.Append("Cancellazione logica paziente")
        oSB = oSB.Append(ControlChars.CrLf)

        If oIdReparto.Equals(Guid.Empty) Then
            sIdReparto = String.Empty
        Else
            sIdReparto = oIdReparto.ToString
        End If

        If Not String.IsNullOrEmpty(sIdReparto) Then
            oSB = oSB.AppendFormat("IdReparto={0}", sIdReparto)
        End If
        Return oSB.ToString
    End Function

    Protected Sub cmdCancella_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdCancella.Click
        '
        ' Salvo i dati e chiudo
        '
        If Delete() Then
            Session(SESS_INVALIDA_CACHE_LISTA_PAZIENTI) = True
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
