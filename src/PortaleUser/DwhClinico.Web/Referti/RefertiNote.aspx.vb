Imports DI.PortalUser2
Imports DwhClinico.Data
Imports DwhClinico.Web
Imports DwhClinico.Web.Utility

Partial Class Referti_RefertiNote
    Inherits System.Web.UI.Page

    Private mbValidationCancelSelect As Boolean = False

#Region "Property"
    Public Property IdReferto As Guid
        Get
            Return Me.ViewState("IdReferto")
        End Get
        Set(value As Guid)
            Me.ViewState("IdReferto") = value
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
                ' DI.PORTALUSER
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

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Try
            'USO SessionHandler.IsSessioneAttiva PER VERIFICARE CHE LA SESSIONE SIA ANCORA ATTIVA.
            If SessionHandler.ValidaSessioneAccessoStandard Is Nothing OrElse SessionHandler.ValidaSessioneAccessoStandard = False Then
                ' ANNULLO LA SELECT DELL'OBJECTDATASOURCE DELLA TESTATA DEL PAZIENTE
                ucTestataPaziente.mbValidationCancelSelect = True
                mbValidationCancelSelect = True
                Call RedirectToHome()
                Exit Sub
            End If

            'OTTENGO L'ID DEL REFERTO DAL QUERY STRING.
            'SE L'ID DEL REFERTO È VUOTO MOSTRO UN MESSAGGIO DI ERRORE.
            Dim sIdReferto As String = Request.QueryString(PAR_ID_REFERTO)
            If String.IsNullOrEmpty(sIdReferto) Then
                Throw New ApplicationException("La combinazione dei parametri non è valida.")
            End If

            '
            ' Solo la prima volta
            '
            If Not IsPostBack Then
                If Not Guid.TryParse(sIdReferto, Me.IdReferto) Then
                    Throw New ApplicationException("L'id del referto non è valido.")
                End If

                '
                ' QUERY PER OTTENERE IL DETTAGLIO DEL REFERTO E LE INFORMAZIONI DEL PAZIENTE
                '
                Dim RefertoOttieniPerId As New CustomDataSource.RefertoOttieniPerId
                Dim dettaglioReferto As WcfDwhClinico.RefertoType = RefertoOttieniPerId.GetData(Me.Token, Me.IdReferto)
                If Not dettaglioReferto Is Nothing Then
                    '
                    ' PASSO ALLA TESTATA DEL PAZIENTE IL TOKEN E L'ID DEL PAZIENTE PER FARE IL BIND DEI DATI
                    ' ATTENZIONE: L'ID DEL PAZIENTE VIENE RICAVATO DIRETTAMENTE DAL DETTAGLIO DEL REFERTO.
                    '
                    ucTestataPaziente.IdPaziente = New Guid(dettaglioReferto.IdPaziente)
                    ucTestataPaziente.Token = Me.Token
                    ucTestataPaziente.CodiceRuolo = Me.CodiceRuolo
                    ucTestataPaziente.DescrizioneRuolo = Me.DescrizioneRuolo
                    ucTestataPaziente.MostraSoloDatiAnagrafici = True 'NASCONDO LA GESTIONE DEI CONSENSI NELLA TESTATA DEL PAZIENTE 

                    '
                    ' Popolo gli attributi anagrafici del paziente.
                    '
                    ShowAttributiAnagrafici(dettaglioReferto)
                    '
                    ' popolo il dettaglio del referto
                    '
                    ShowTestataReferto(dettaglioReferto)
                Else
                    Throw New ApplicationException("Il referto non esiste o è stato cancellato.")
                End If

                '
                ' Memorizzo url di provenienza per ritornare al chiamante dopo aver salvato la nota
                '
                If Not IsNothing(Request.UrlReferrer) Then
                    ViewState("UrlReferrer") = Request.UrlReferrer.AbsoluteUri.ToString()
                End If
            End If
        Catch ex As Threading.ThreadAbortException
            '
            ' Non faccio nulla: causato dal redirect
            '
        Catch ex As ApplicationException
            divErrorMessage.Visible = True
            lblErrorMessage.Text = ex.Message
            Logging.WriteError(ex, Me.GetType.Name)
        Catch ex As Exception
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante il caricamento della pagina."
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

    Private Sub RedirectToHome()
        Response.Redirect(Me.ResolveUrl("~/Default.aspx"), True)
    End Sub

    Private Sub ShowAttributiAnagrafici(dettaglioReferto As WcfDwhClinico.RefertoType)
        If Not dettaglioReferto.Paziente Is Nothing Then
            ucInfoPaziente.Nome = dettaglioReferto.Paziente.Nome
            ucInfoPaziente.Cognome = dettaglioReferto.Paziente.Cognome
            ucInfoPaziente.CodiceFiscale = dettaglioReferto.Paziente.CodiceFiscale
            ucInfoPaziente.LuogoNascita = dettaglioReferto.Paziente.ComuneNascita
            If dettaglioReferto.Paziente.DataNascita.HasValue Then
                ucInfoPaziente.DataNascita = dettaglioReferto.Paziente.DataNascita.Value
            End If
        End If
    End Sub
    Private Sub ShowTestataReferto(ByVal oReferto As WcfDwhClinico.RefertoType)
        '
        ' Restituisce informazioni sul referto corrente
        '
        lblNumeroReferto.Text = oReferto.NumeroReferto
        If oReferto.DataReferto <> Nothing Then
            lblDataReferto.Text = String.Format("{0:d}", oReferto.DataReferto)
        End If
        lblNosologico.Text = oReferto.NumeroNosologico
        lblAziendaErogante.Text = oReferto.AziendaErogante
        lblSistemaErogante.Text = oReferto.SistemaErogante
        If Not oReferto.RepartoErogante Is Nothing Then
            lblRepartoErogante.Text = oReferto.RepartoErogante.Descrizione
        End If
        If Not oReferto.RepartoRichiedente Is Nothing Then
            lblRepartoRichiedente.Text = oReferto.RepartoRichiedente.Descrizione
        End If
    End Sub

    Protected Sub cmdSalva_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdSalva.Click
        Dim oCurrentUser As CurrentUser
        Dim sCurrentUser As String
        Try
            If txtNote.Text.Length = 0 Then
                Throw New ApplicationException("Il campo Note è obbligatorio!")
            Else
                '
                ' Prelevo info utente e salvo la nota
                '
                oCurrentUser = GetCurrentUser()
                sCurrentUser = oCurrentUser.DomainName & "\" & oCurrentUser.UserName
                Using odata As New Referti
                    odata.AggiungiNote(Me.IdReferto, sCurrentUser, txtNote.Text)
                End Using

                'TORNO ALLA PAGINA DI DETTAGLIO DEL REFERTO.
                TornaIndietro()
            End If
        Catch ex As Threading.ThreadAbortException
            '
            ' Non faccio nulla: causato dal redirect
            '
        Catch ex As ApplicationException
            divErrorMessage.Visible = True
            lblErrorMessage.Text = ex.Message
        Catch ex As Exception
            divErrorMessage.Visible = True
            lblErrorMessage.Text = "Si è verificato un errore durante il salvataggio delle note del referto."
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

    Private Sub cmdEsci_Click(sender As Object, e As EventArgs) Handles cmdEsci.Click
        'TORNO ALLA PAGINA DI DETTAGLIO DEL REFERTO.
        TornaIndietro()
    End Sub

    Private Sub TornaIndietro()
        ' TORNA ALLA PAGINA DI DETTAGLIO DEL REFERTO.
        Dim sBackUrl As String = "~/Referti/RefertiDettaglio.aspx?IdReferto=" & Me.IdReferto.ToString
        Response.Redirect(sBackUrl)
    End Sub
End Class
