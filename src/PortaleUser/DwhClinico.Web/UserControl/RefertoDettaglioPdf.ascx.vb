Imports DI.PortalUser2
Imports DwhClinico.Data
Public Class RefertoDettaglioPdf
    Inherits System.Web.UI.UserControl
    Public Property dettaglioReferto As WcfDwhClinico.RefertoType
        '
        'Salva nel view state l'Id del referto
        '
        Get
            Return CType(Me.ViewState("dettaglioReferto"), WcfDwhClinico.RefertoType)
        End Get
        Set(value As WcfDwhClinico.RefertoType)
            Me.ViewState("dettaglioReferto") = value
        End Set
    End Property

    Public Property IsAccessoDiretto As Boolean
        '
        'Salva nel view state se siamo nell'accesso diretto.
        '
        Get
            Return CType(Me.ViewState("IsAccessoDiretto"), Boolean)
        End Get
        Set(value As Boolean)
            Me.ViewState("IsAccessoDiretto") = value
        End Set
    End Property

    Public Property CancelSelect As Boolean
        '
        'Salva nel view state se non deve essere eseguito il codice.
        '
        Get
            Return CType(Me.ViewState("CancelSelect"), Boolean)
        End Get
        Set(value As Boolean)
            Me.ViewState("CancelSelect") = value
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

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Dim oListaAllegatiPrincipale As List(Of WcfDwhClinico.AllegatoType) = Nothing
        Dim oAllegatoPrincipale As WcfDwhClinico.AllegatoType = Nothing
        Try
            If Not Me.CancelSelect Then
                '
                'Testo se il dettaglio del referto è valorizzato.
                '
                If Me.dettaglioReferto Is Nothing Then
                    Throw New Exception("Impossibile recuperare il dettaglio del referto.")
                End If

                '
                'Nascondo i div d'errore.
                '
                divErrorMessage.Visible = False
                lblErrorMessage.Text = String.Empty
                divMessage.Visible = False
                lblMessage.Text = String.Empty

                '
                ' Testo se ci sono degli allegati.
                '
                If dettaglioReferto.Allegati IsNot Nothing AndAlso dettaglioReferto.Allegati.Count > 0 Then
                    '
                    'Ottengo la lista degli allegati principale, ovvero quello il cui nome finisce con _PDF.
                    '
                    oListaAllegatiPrincipale = (From c In dettaglioReferto.Allegati Where c.NomeFile.ToUpper.EndsWith("_PDF")).ToList

                    '
                    'Se la lista degli allegati principali non è vuota allora prendo il primo.
                    '
                    If oListaAllegatiPrincipale IsNot Nothing AndAlso oListaAllegatiPrincipale.Count > 0 Then
                        oAllegatoPrincipale = oListaAllegatiPrincipale.Item(0)
                    Else
                        '
                        'Se la lista degli allegati principali è vuota allora prendo il primo allegato pdf generale.
                        '
                        Dim oAllegatiPdf As List(Of WcfDwhClinico.AllegatoType) = (From c In dettaglioReferto.Allegati Where c.TipoContenuto = "application/pdf").ToList
                        If Not oAllegatiPdf Is Nothing AndAlso oAllegatiPdf.Count > 0 Then
                            oAllegatoPrincipale = oAllegatiPdf.Item(0)
                        End If
                    End If

                    If oAllegatoPrincipale IsNot Nothing Then
                        Dim sUrlContent As String = String.Empty

                        If Me.IsAccessoDiretto Then
                            'Valorizzo l'url per l'accesso diretto.
                            sUrlContent = Me.ResolveUrl(String.Format("~/AccessoDiretto/ApreAllegato.aspx?{0}={1}&{2}={3}", Utility.PAR_ID_ALLEGATO, oAllegatoPrincipale.Id, Utility.PAR_ID_REFERTO, Me.dettaglioReferto.Id))
                        Else
                            'Valorizzo l'url per l'accesso diretto.
                            sUrlContent = Me.ResolveUrl(String.Format("~/Referti/ApreAllegato.aspx?{0}={1}&{2}={3}", Utility.PAR_ID_ALLEGATO, oAllegatoPrincipale.Id, Utility.PAR_ID_REFERTO, Me.dettaglioReferto.Id))
                        End If

                        Me.IframeMain.Attributes.Add("src", sUrlContent)
                    End If
                Else
                    '
                    'Se sono qui non ci sono allegati.
                    '
                    lblMessage.Text = "Non sono presenti allegati da visualizzare."
                End If
            End If
        Catch ex As Exception
            divErrorMessage.Visible = True
            lblErrorMessage.Text = ex.Message

            'loggo l'errore
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub
End Class