Imports DI.PortalUser2
Imports DwhClinico.Data
Imports DwhClinico.Web
Imports DwhClinico.Web.Utility

Partial Class AccessoDiretto_RefertiAllegati
    Inherits System.Web.UI.Page

    Private mstrPageID As String = Nothing
    Private mbValidationCancelSelect As Boolean = False
    Private mIdReferto As String = Nothing 'Usata per aggiungere l'id del referto all'URL quando si ha più allegati

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

    Public Property BackUrl As String
        '
        ' Salvo l'Id del paziente nel ViewState per averlo per tutta la durata della pagina
        '
        Get
            Return Me.ViewState("BackUrl")
        End Get
        Set(value As String)
            Me.ViewState("BackUrl") = value
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

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Dim sIdEsternoAllegato As String = String.Empty
        Try
            If SessionHandler.ValidaSessioneAccessoDiretto = Nothing Then
                '
                ' Se sono qui la sessione è scaduta e quindi mostro un messaggio di errore.
                '
                Throw New ApplicationException("La sessione di lavoro è scaduta.")
            End If

            '
            ' Id della pagina
            '
            mstrPageID = Me.GetType.Name

            '
            ' Prelevo parametri dal query string
            '
            sIdEsternoAllegato = Me.Request.QueryString(PAR_ID_ESTERNO_ALLEGATO)
            mIdReferto = Me.Request.QueryString(PAR_ID_REFERTO)
            Me.ShowPannelloPaziente = Request.QueryString("ShowPannelloPaziente")

            '
            ' Se l'id dell'allegato è vuoto allora l'id del referto deve essere valorizzato.
            '
            If String.IsNullOrEmpty(sIdEsternoAllegato) Then
                If String.IsNullOrEmpty(mIdReferto) Then
                    Throw New ApplicationException("Il parametro 'IdReferto' è obbligatorio.")
                End If
            End If

            '
            ' Solo la prima volta
            '
            If Not IsPostBack Then
                If Not String.IsNullOrEmpty(mIdReferto) AndAlso String.IsNullOrEmpty(sIdEsternoAllegato) Then
                    'Idreferto valorizzato, sIdEsternoAllegato NON valorizzato
                    'Torno alla pagina di dettaglio del referto. 
                    'Uso la variabile di sessione SessionHandler.AccessoDirettoRefertoUrl perchè l'url può essere differente in quanto la pagina è entryPoint.
                    Me.BackUrl = SessionHandler.AccessoDirettoRefertoUrl
                ElseIf Not String.IsNullOrEmpty(mIdReferto) AndAlso Not String.IsNullOrEmpty(sIdEsternoAllegato) Then
                    'Idreferto valorizzato, sIdEsternoAllegato valorizzato
                    'Torno alla pagina che mostra elenco allegati

                    'Modifica leo: 2019/12/10 : se da query String: ShowPanelloPaziente è valorizzato allora passo anche ShowPanelloPaziente=(bool) alla precedente.
                    Dim sUrl = Me.ResolveUrl(String.Format("/AccessoDiretto/RefertiAllegati.aspx?{0}={1}", PAR_ID_REFERTO, mIdReferto))

                    Dim sShowPannelloPaziente As String = Me.ShowPannelloPaziente
                    Dim bShowPannelloPaziente As Boolean = True
                    If Not String.IsNullOrEmpty(sShowPannelloPaziente) Then
                        If Boolean.TryParse(sShowPannelloPaziente, bShowPannelloPaziente) Then
                            sUrl = sUrl & "&ShowPannelloPaziente=" & bShowPannelloPaziente.ToString
                        Else
                            'Se il try parse fallisce non faccio nulla
                        End If
                    End If

                    Me.BackUrl = sUrl

                End If


                '
                ' Ottengo il referto per mostrare gli attributi anagrafici del paziente.
                '
                Dim RefertoOttieniPerId As New CustomDataSource.AccessoDirettoRefertoOttieniPerId
                Dim dettaglioReferto As WcfDwhClinico.RefertoType = RefertoOttieniPerId.GetData(Me.Token, New Guid(mIdReferto))


                If Not dettaglioReferto Is Nothing Then
                    'ShowAttributiAnagrafici(dettaglioReferto)
                    Me.IdPaziente = New Guid(dettaglioReferto.IdPaziente)
                Else
                    Throw New ApplicationException("Impossibile caricare il referto.")
                End If

                '
                ' Passo alla testata del paziente il token e l'id del paziente per fare il bind dei dati
                ' L'id del paziente viene valorizzato all'interno del metodo ShowAttributiAnagrafici
                '
                ucTestataPaziente.IdPaziente = Me.IdPaziente
                ucTestataPaziente.Token = Me.Token
                ucTestataPaziente.CodiceRuolo = Me.CodiceRuolo
                ucTestataPaziente.DescrizioneRuolo = Me.DescrizioneRuolo
                ucTestataPaziente.MostraSoloDatiAnagrafici = True

                WebGridAllegati.Visible = False
                divTestataReferto.Visible = False
                divElencoAllegati.Visible = False
                TblPdfContainer.Visible = False
                divErrorMessage.Visible = False

                If Not String.IsNullOrEmpty(mIdReferto) AndAlso String.IsNullOrEmpty(sIdEsternoAllegato) Then
                    'Idreferto valorizzato, sIdEsternoAllegato NON valorizzato
                    Call ShowAllegatiByIdReferto(dettaglioReferto)
                ElseIf Not String.IsNullOrEmpty(mIdReferto) AndAlso Not String.IsNullOrEmpty(sIdEsternoAllegato) Then
                    'Idreferto valorizzato, sIdEsternoAllegato valorizzato
                    Call ShowAllegatiByIdAllegato(sIdEsternoAllegato)
                End If

                '
                ' Gestione voci del menu:
                ' In base all' EntryPoint mostro o nascondo le voci del menu.
                '
                Dim oMenu As Menu = CType(Master.FindControl("MenuMain2"), Menu)
                oMenu.DataBind()
                Dim menuItemPazienti As MenuItem = UserInterface.GetMenuItem(oMenu, "Pazienti")

                If menuItemPazienti Is Nothing Then
                    Throw New ApplicationException("La voce del menu ""Pazienti"" non esiste.")
                End If

                Dim urlPazienti As String = SessionHandler.AccessoDirettoUrlPazienti
                Dim urlReferti As String = SessionHandler.AccessoDirettoUrlReferti

                If urlPazienti Is Nothing AndAlso urlReferti Is Nothing Then
                    oMenu.Items.Remove(menuItemPazienti)
                Else
                    If urlPazienti Is Nothing Then
                        oMenu.Items.Remove(menuItemPazienti)
                    Else
                        menuItemPazienti.NavigateUrl = urlPazienti
                    End If
                End If
            End If

            '
            'RENDERING PER BOOTSTRAP
            'Converte i tag html generati dalla GridView per la paginazione
            ' e li adatta alle necessita dei CSS Bootstrap
            '
            WebGridAllegati.PagerStyle.CssClass = "pagination-gridview"
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "gridPagination", HelperGridView.GetScriptPaginationForBootstrap(), True)

            'Modifica Leo 2019/12/10: Nascondere Pannello Paziente se specificato nell'url
            ucTestataPaziente.Visible = Utility.AccessoDirettoPannelloPazientVisibility(Request.QueryString)

        Catch ex As Threading.ThreadAbortException
            '
            ' Non faccio nulla
            '
        Catch ex As ApplicationException
            '
            ' In caso di errore non eseguo il bind dei dati della testata del paziente.
            '
            ucTestataPaziente.mbValidationCancelSelect = True
            mbValidationCancelSelect = True
            lblErrorMessage.Text = ex.Message
            divErrorMessage.Visible = False
            NascondoPagina()
            Logging.WriteError(ex, Me.GetType.Name)
        Catch ex As Exception
            '
            ' In caso di errore non eseguo il bind dei dati della testata del paziente.
            '
            ucTestataPaziente.mbValidationCancelSelect = True
            mbValidationCancelSelect = True
            lblErrorMessage.Text = "Errore durante il caricamento della pagina."
            divErrorMessage.Visible = True
            NascondoPagina()
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

    Private Sub NascondoPagina()
        '
        ' Nasconde tutti gli elementi della pagina in caso di errore.
        '
        divPage.Visible = False
        CType(Master.FindControl("divMenu2"), HtmlGenericControl).Visible = False
    End Sub

    Private Sub ShowAllegatiByIdReferto(dettaglioReferto As WcfDwhClinico.RefertoType)
        Dim allegati As List(Of WcfDwhClinico.AllegatoType) = Nothing
        If Not dettaglioReferto.Allegati Is Nothing AndAlso dettaglioReferto.Allegati.Count > 0 Then
            '
            ' Filtro gli allegati per mostrare solo i pdf
            '
            allegati = (From c In dettaglioReferto.Allegati Where c.TipoContenuto = "application/pdf").ToList
        End If

        If allegati Is Nothing OrElse allegati.Count = 0 Then
            Call ShowHTMLRendering(mIdReferto)
        ElseIf Not allegati Is Nothing AndAlso allegati.Count = 1 Then
            Call ShowAllegatiByIdAllegato(allegati(0).IdEsterno)
        ElseIf Not allegati Is Nothing AndAlso allegati.Count > 1 Then
            Call ShowUI(dettaglioReferto)
        End If
    End Sub

    Private Sub ShowUI(ByVal RefertoDettaglio As WcfDwhClinico.RefertoType)
        divTestataReferto.Visible = True
        ShowTestataReferto(RefertoDettaglio)
        '
        ' Passo parametri a object data source e bind della grid
        ' 
        divElencoAllegati.Visible = True
        WebGridAllegati.Visible = True
        WebGridAllegati.DataSource = (From c In RefertoDettaglio.Allegati Where c.TipoContenuto = "application/pdf").ToList
        WebGridAllegati.DataBind()
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

    'Private Sub ShowAttributiAnagrafici(dettaglioReferto As WcfDwhClinico.RefertoType)
    '    '
    '    ' Passo le informazioni sull'utente allo UserControl ucInfoPaziente contenuto nella modale del dettaglio dell'episodio
    '    '
    '    Dim DataNascita As Date = Nothing
    '    If Not dettaglioReferto Is Nothing AndAlso Not dettaglioReferto.Paziente Is Nothing Then
    '        ucInfoPaziente.Nome = dettaglioReferto.Paziente.Nome
    '        ucInfoPaziente.Cognome = dettaglioReferto.Paziente.Cognome
    '        ucInfoPaziente.CodiceFiscale = dettaglioReferto.Paziente.CodiceFiscale
    '        ucInfoPaziente.LuogoNascita = dettaglioReferto.Paziente.ComuneNascita
    '        If dettaglioReferto.Paziente.DataNascita.HasValue Then
    '            ucInfoPaziente.DataNascita = dettaglioReferto.Paziente.DataNascita.Value
    '        End If
    '        '
    '        ' Ottengo l'id del paziente da salvare nel ViewState dal dettaglio del referto.
    '        '
    '        Me.IdPaziente = New Guid(dettaglioReferto.IdPaziente)
    '    End If
    'End Sub

    Private Sub ShowAllegatiByIdAllegato(ByVal sIdEsternoAllegato As String)
        Me.TblPdfContainer.Visible = True
        '
        ' Ricavo allegato e visualizzazione immediata
        '
        Dim sUrlContent As String = Me.ResolveUrl(String.Format("~/AccessoDiretto/ApreAllegato.aspx?{0}={1}&{2}={3}", PAR_ID_ESTERNO_ALLEGATO, sIdEsternoAllegato, PAR_ID_REFERTO, mIdReferto))
        Me.IframeMain.Attributes.Add("src", sUrlContent)
        Me.LinkNoIframeMain.HRef = sUrlContent
    End Sub

    Private Sub ShowHTMLRendering(ByVal sIdReferto As String)
        Me.TblPdfContainer.Visible = True
        Dim sTemplateUrlDettaglioreferto As String = My.Settings.WsRenderingPdf_UrlDettaglioReferto
        Dim sUrlReferto = Me.ResolveUrl(String.Format(sTemplateUrlDettaglioreferto, sIdReferto))
        Dim sUrlContent As String = Me.ResolveUrl(String.Format("~/HtmlRender.aspx"))
        sUrlContent = sUrlContent & String.Format("?{0}={1}", PAR_URL_TO_RENDER, sUrlReferto)
        Me.IframeMain.Attributes.Add("src", sUrlContent)
        Me.LinkNoIframeMain.HRef = sUrlContent
    End Sub

    Private Sub WebGridAllegati_PreRender(sender As Object, e As EventArgs) Handles WebGridAllegati.PreRender
        '
        'Render per Bootstrap
        'Crea la Table con Theader e Tbody se l'header non è nothing.
        '
        If Not WebGridAllegati.HeaderRow Is Nothing Then
            WebGridAllegati.UseAccessibleHeader = True
            WebGridAllegati.HeaderRow.TableSection = TableRowSection.TableHeader
        End If
    End Sub

#Region "Funzioni usate nel markup"
    Protected Function GetDataModificaAllegato(ByVal oDataModifica As Object) As String
        Dim sRet As String = String.Empty
        If Not oDataModifica Is Nothing Then
            Dim DataModifica As DateTime = DirectCast(oDataModifica, DateTime)
            sRet = DataModifica.ToShortDateString
        End If
        Return sRet
    End Function

    Protected Function BuildUrlOpenAllegato(ByVal oIdAllegato As Object) As String
        Dim sUrl As String = String.Empty
        If Not oIdAllegato Is Nothing Then
            sUrl = String.Format("~/AccessoDiretto/RefertiAllegati.aspx?{0}={1}&{2}={3}", PAR_ID_ESTERNO_ALLEGATO, oIdAllegato.ToString, PAR_ID_REFERTO, mIdReferto)
            sUrl = Me.ResolveUrl(sUrl)

            'Modifica leo: 2019/12/10 : se da query String: ShowPanelloPaziente = False allora passo anche ShowPanelloPaziente = False alla pagina di dettaglio.
            Dim sShowPannelloPaziente As String = Me.ShowPannelloPaziente
            Dim bShowPannelloPaziente As Boolean = True
            If Not String.IsNullOrEmpty(sShowPannelloPaziente) Then
                If Boolean.TryParse(sShowPannelloPaziente, bShowPannelloPaziente) Then
                    sUrl = sUrl & "&ShowPannelloPaziente=" & bShowPannelloPaziente.ToString
                Else
                    'Se il try parse fallisce non faccio nulla
                End If
            End If
        End If
        '
        '
        '
        Return sUrl
    End Function

    Protected Function GetDescrizioneAllegato(ByVal oDescrizione As Object) As String
        Dim sRet As String = String.Empty
        If Not oDescrizione Is Nothing Then
            sRet = DirectCast(oDescrizione, String)
        End If
        Return sRet
    End Function
#End Region

    Private Sub cmdEsci_Click(sender As Object, e As EventArgs) Handles cmdEsci.Click
        '
        'Questa funzione gestisce entrambi i pulsanti per tornare alla pagina precedente
        '
        Response.Redirect(Me.BackUrl)
    End Sub
End Class
