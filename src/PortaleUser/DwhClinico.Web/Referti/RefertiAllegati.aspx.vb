Imports DI.PortalUser2
Imports DwhClinico.Data
Imports DwhClinico.Web
Imports DwhClinico.Web.Utility

Partial Class Referti_RefertiAllegati
    Inherits System.Web.UI.Page

    Private mIdReferto As String = Nothing 'Usata per aggiungere l'id del referto all'URL quando si ha più allegati

    Private Property BackUrl As String
        Get
            Return CType(ViewState("BackUrl"), String)
        End Get
        Set(value As String)
            ViewState("BackUrl") = value
        End Set
    End Property

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
#End Region

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Dim sIdEsternoAllegato As String = String.Empty
        Try
            'UTILIZZO LA VARIABILE DI SESSIONE IsSessioneAttiva PER VERIFICARE SE LA SESSIONE È SCADUTA.
            If SessionHandler.ValidaSessioneAccessoStandard Is Nothing OrElse SessionHandler.ValidaSessioneAccessoStandard = False Then
                ucTestataPaziente.mbValidationCancelSelect = True
                Call RedirectToHome()
                Exit Sub
            End If

            '
            ' Prelevo parametri dal query string
            ' 
            sIdEsternoAllegato = Me.Request.QueryString(PAR_ID_ESTERNO_ALLEGATO)
            mIdReferto = Me.Request.QueryString(PAR_ID_REFERTO)

            '
            ' se l'id dell'allegato è vuoto allora l'id del referto deve essere valorizzato
            '
            If String.IsNullOrEmpty(sIdEsternoAllegato) Then
                If String.IsNullOrEmpty(mIdReferto) Then
                    Throw New ApplicationException("Il parametro 'IdReferto' è obbligatorio.")
                End If
            End If

            '
            ' Solo la prima volta.
            '
            If Not IsPostBack Then
                If Not String.IsNullOrEmpty(mIdReferto) AndAlso String.IsNullOrEmpty(sIdEsternoAllegato) Then
                    'Idreferto valorizzato, sIdEsternoAllegato NON valorizzato
                    Me.BackUrl = Me.ResolveUrl(String.Format("~/Referti/RefertiDettaglio.aspx?{0}={1}", PAR_ID_REFERTO, mIdReferto))
                ElseIf Not String.IsNullOrEmpty(mIdReferto) AndAlso Not String.IsNullOrEmpty(sIdEsternoAllegato) Then
                    'Idreferto valorizzato, sIdEsternoAllegato valorizzato
                    Me.BackUrl = Me.ResolveUrl(String.Format("~/Referti/RefertiAllegati.aspx?{0}={1}", PAR_ID_REFERTO, mIdReferto))
                End If

                ' OTTENGO IL REFERTO PER MOSTRARE GLI ATTRIBUTI ANAGRAFICI DEL PAZIENTE.
                Dim RefertoOttieniPerId As New CustomDataSource.RefertoOttieniPerId
                Dim dettaglioReferto As WcfDwhClinico.RefertoType = RefertoOttieniPerId.GetData(Me.Token, New Guid(mIdReferto))

                'TESTO SE IL DETTAGLIO DEL REFERTO È NOTHING
                If dettaglioReferto IsNot Nothing Then
                    '
                    ' PASSO ALLA TESTATA DEL PAZIENTE IL TOKEN E L'ID DEL PAZIENTE PER FARE IL BIND DEI DATI
                    ' ATTENZIONE: RICAVO L'ID DEL PAZIENTE DAL DETTAGLIO DEL REFERTO.
                    '
                    ucTestataPaziente.IdPaziente = New Guid(dettaglioReferto.IdPaziente)
                    ucTestataPaziente.Token = Me.Token
                    ucTestataPaziente.CodiceRuolo = Me.CodiceRuolo
                    ucTestataPaziente.DescrizioneRuolo = Me.DescrizioneRuolo
                    ucTestataPaziente.MostraSoloDatiAnagrafici = True
                Else
                    Throw New ApplicationException("Impossibile caricare la testata del paziente.")
                End If

                lblErrorMessage.Visible = False
                divErrorMessage.Visible = False
                WebGridAllegati.Visible = False
                divTestataReferto.Visible = False
                divElencoAllegati.Visible = False
                TblPdfContainer.Visible = False

                If Not String.IsNullOrEmpty(mIdReferto) AndAlso String.IsNullOrEmpty(sIdEsternoAllegato) Then
                    'Idreferto valorizzato, sIdEsternoAllegato NON valorizzato
                    Call ShowAllegatiByIdReferto(dettaglioReferto)
                ElseIf Not String.IsNullOrEmpty(mIdReferto) AndAlso Not String.IsNullOrEmpty(sIdEsternoAllegato) Then
                    'Idreferto valorizzato, sIdEsternoAllegato valorizzato
                    Call ShowAllegatiByIdAllegato(sIdEsternoAllegato)
                End If
            End If

            '
            'RENDERING PER BOOTSTRAP
            'Converte i tag html generati dalla GridView per la paginazione
            ' e li adatta alle necessita dei CSS Bootstrap
            '
            WebGridAllegati.PagerStyle.CssClass = "pagination-gridview"
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "gridPagination", HelperGridView.GetScriptPaginationForBootstrap(), True)

        Catch ex As Threading.ThreadAbortException
            '
            ' Non faccio nulla
            '
        Catch ex As ApplicationException
            ucTestataPaziente.mbValidationCancelSelect = True
            lblErrorMessage.Text = ex.Message
            divErrorMessage.Visible = True
            Logging.WriteError(ex, Me.GetType.Name)
        Catch ex As Exception
            ucTestataPaziente.mbValidationCancelSelect = True
            lblErrorMessage.Text = "Errore durante il caricamento della pagina."
            divErrorMessage.Visible = True
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

    Private Sub RedirectToHome()
        Response.Redirect(Me.ResolveUrl("~/Default.aspx"), True)
    End Sub

    Private Sub ShowAllegatiByIdReferto(dettaglioReferto As WcfDwhClinico.RefertoType)
        If Not dettaglioReferto Is Nothing Then
            '
            ' Filtro gli allegati per mostrare solo i pdf
            '
            Dim allegati As List(Of WcfDwhClinico.AllegatoType) = Nothing
            If Not dettaglioReferto.Allegati Is Nothing Then
                allegati = (From c In dettaglioReferto.Allegati Where c.TipoContenuto = "application/pdf").ToList
            End If
            '
            ' Aggiorno la barra di navigazione e il titolo della pagina
            '
            If allegati Is Nothing OrElse allegati.Count = 0 Then
                Call ShowHTMLRendering(dettaglioReferto.Id)
            ElseIf Not allegati Is Nothing AndAlso allegati.Count = 1 Then
                Call ShowAllegatiByIdAllegato(allegati(0).IdEsterno.ToString())
            ElseIf Not allegati Is Nothing AndAlso allegati.Count > 1 Then
                ShowUI(dettaglioReferto)
            End If
        Else
            Throw New ApplicationException("Impossibile caricare referto.")
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

    Private Sub ShowAllegatiByIdAllegato(ByVal sIdEsternoAllegato As String)
        Me.TblPdfContainer.Visible = True
        '
        ' Ricavo allegato e visualizzazione immediata
        '
        Dim sUrlContent As String = Me.ResolveUrl(String.Format("~/Referti/ApreAllegato.aspx?{0}={1}&{2}={3}", PAR_ID_ESTERNO_ALLEGATO, sIdEsternoAllegato, PAR_ID_REFERTO, mIdReferto.ToString))
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

    Private Function GetStatoRichiestaImageUrl(ByVal oStato As Object) As String
        Return Me.ResolveUrl(String.Format("~/Images/Referti/StatoRichiesta_{0}.gif", oStato))
    End Function

#Region "Funzioni usate nel markup"
    Protected Function GetDataModificaAllegato(ByVal oDataModifica As Object) As String
        Dim sRet As String = String.Empty
        If Not oDataModifica Is DBNull.Value AndAlso oDataModifica IsNot Nothing Then
            Dim DataModifica As DateTime = DirectCast(oDataModifica, DateTime)
            sRet = DataModifica.ToShortDateString
        End If
        Return sRet
    End Function

    Protected Function BuildUrlOpenAllegato(ByVal oIdAllegato As Object) As String
        Dim sUrl As String = String.Empty
        If Not oIdAllegato Is DBNull.Value Then
            sUrl = String.Format("~/Referti/RefertiAllegati.aspx?{0}={1}&{2}={3}", PAR_ID_ESTERNO_ALLEGATO, oIdAllegato.ToString, PAR_ID_REFERTO, mIdReferto)
            sUrl = Me.ResolveUrl(sUrl)
        End If
        '
        '
        '
        Return sUrl
    End Function

    Protected Function GetDescrizioneAllegato(ByVal oDescrizione As Object) As String
        Dim sRet As String = String.Empty
        If Not oDescrizione Is DBNull.Value Then
            sRet = DirectCast(oDescrizione, String)
        End If
        '
        '
        '
        Return sRet
    End Function
#End Region

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

    Private Sub cmdEsci_Click(sender As Object, e As EventArgs) Handles cmdEsci.Click
        '
        ' Questa funzione gestisce entrambi i pulsanti per tornare alla pagina precedente
        '
        Me.Response.Redirect(Me.BackUrl)
    End Sub

End Class
