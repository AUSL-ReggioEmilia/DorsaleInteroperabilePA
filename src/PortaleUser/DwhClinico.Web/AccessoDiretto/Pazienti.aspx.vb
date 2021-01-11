Imports DI.PortalUser2
Imports DwhClinico.Data
Imports DwhClinico.Web
Imports DwhClinico.Web.Utility

Partial Class AccessoDiretto_Pazienti
    Inherits System.Web.UI.Page

    '
    ' Varibili di modulo utilizzati nei metodi Selecting degli ObjectDataSource
    '
    Private _CodiceFiscale As String = String.Empty
    Private _Cognome As String = String.Empty
    Private _Nome As String = String.Empty
    Private _DataNascita As Date? = Nothing
    Private _CancelSelect As Boolean = False
    Const VS_OTHER_PARAM As String = "RefertiParam"

#Region "Property"
    Private ReadOnly PageSessionIdPrefix As String = Page.GetType().BaseType.FullName

    Private Property GridViewSortExpression() As String
        Get
            Dim o As Object = Session(PageSessionIdPrefix + "SortExpression")
            If o Is Nothing Then
                Return String.Empty
            Else
                Return o.ToString()
            End If
        End Get
        Set(ByVal value As String)
            Session(PageSessionIdPrefix + "SortExpression") = value
        End Set
    End Property

    Private Property GridViewSortDirection() As SortDirection?
        Get
            Dim o As Object = Session(PageSessionIdPrefix + "SortDirection")
            If o Is Nothing Then
                Return Nothing
            Else
                Return DirectCast(o, SortDirection?)
            End If
        End Get
        Set(ByVal value As SortDirection?)
            Session(PageSessionIdPrefix + "SortDirection") = value
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

    Private Property msOtherParam As String
        Get
            Return CType(Me.ViewState("msOtherParam"), String)
        End Get
        Set(value As String)
            Me.ViewState("msOtherParam") = value
        End Set
    End Property
#End Region

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Try
            '
            ' Controllo la validità della sessione.
            '
            If Not Page.IsPostBack AndAlso Utility.AccessoDiretto_IsPageEntryPoint() Then
                'Mostro o nascondo l'header della masterpage in base a quanto indicato nella querystring o precedentemente in sessione
                Utility.CheckShowHeaderParam(Request)
                '
                ' Se la pagina è EntryPoint e non è un PostBack allora valorizzo la variabile.
                '
                SessionHandler.ValidaSessioneAccessoDiretto = True
            ElseIf SessionHandler.ValidaSessioneAccessoDiretto = Nothing Then
                '
                ' Se sono qui la sessione è scaduta e mostro un messaggio di errore.
                '
                Throw New ApplicationException("La sessione di lavoro è scaduta.")
            End If

            '
            ' Solo la prima volta.
            '
            If Not IsPostBack Then
                '
                ' Inizio una nuova navigazione. Resetto le variabili di sessione relative ai menu.
                '
                SessionHandler.AccessoDirettoUrlPazienti = HttpContext.Current.Request.Url.AbsoluteUri
                SessionHandler.AccessoDirettoUrlReferti = Nothing

                '
                ' Questa pagina è entry point. rendo visibile solo la voce di menu "Pazienti" e gli passo l'URL corrente.
                '
                Dim oMenu As Menu = CType(Master.FindControl("MenuMain2"), Menu)
                '
                ' Il load di questa pagina viene prima di quello della MasterPage. Eseguo il bind dei dati per essere sicuro di trovare il menu popolato.
                '
                oMenu.DataBind()
                Dim menuItemPazienti As MenuItem = UserInterface.GetMenuItem(oMenu, "Pazienti")
                'Dim menuItemReferti As MenuItem = UserInterface.GetMenuItem(oMenu, "Referti")
                '
                ' se sono vuoti allora mostro un messaggio di errore.
                '
                If menuItemPazienti Is Nothing Then
                    Throw New ApplicationException("La voce del menu ""Pazienti"" non esiste.")
                End If
                'If menuItemReferti Is Nothing Then
                '    Throw New ApplicationException("La voce del menu ""Referti"" non esiste.")
                'End If

                '
                ' Rimuovo la voce "Referti" dal menu.
                '
                'oMenu.Items.Remove(menuItemReferti)

                '
                ' Passo all'item  "Pazienti" l'url corrente.
                '
                menuItemPazienti.NavigateUrl = SessionHandler.AccessoDirettoUrlPazienti

                '
                ' Carico i motivi di accesso.
                '
                CaricaCmbMotivoAccesso()

                '
                ' Prendo i filtri salvati nella Sessione.
                '
                Dim oQueryString As Specialized.NameValueCollection = Me.Request.QueryString

                '
                ' Ottengo i parametri dal QueryString.
                '
                Dim sCodiceSanitario As String = oQueryString(PAR_CODICE_SANITARIO)
                Dim sCodiceFiscale As String = oQueryString(PAR_CODICE_FISCALE)
                Dim sCognome As String = oQueryString(PAR_COGNOME)
                Dim sNome As String = oQueryString(PAR_NOME)
                Dim sDataNascita As String = oQueryString(PAR_DATA_NASCITA) 'sempre DD/MM/YYYY

                '
                ' Parametri per i referti e ricoveri
                '
                Me.msOtherParam = String.Format("{0}={1}&{2}={3}&{4}={5}&{6}={7}",
                                                        PAR_DALLA_DATA, oQueryString(PAR_DALLA_DATA) & "",
                                                        PAR_SISTEMA_EROGANTE, oQueryString(PAR_SISTEMA_EROGANTE) & "",
                                                        PAR_REPARTO_EROGANTE, oQueryString(PAR_REPARTO_EROGANTE) & "",
                                                        PAR_REPARTO_RICHIEDENTE, oQueryString(PAR_REPARTO_RICHIEDENTE) & "")

                '
                ' Converto se possibile la data da String a DateTime
                '
                Dim oDataNascita As Nullable(Of DateTime)
                If Not IsNothing(sDataNascita) AndAlso sDataNascita.Length > 0 Then
                    Try
                        Dim oCulture As Globalization.CultureInfo = New Globalization.CultureInfo(1040)
                        oDataNascita = Date.Parse(sDataNascita, oCulture)
                    Catch ex As Exception
                        oDataNascita = Nothing
                    End Try
                Else
                    oDataNascita = Nothing
                End If

                '
                ' Validazione dei parametri per la ricerca del paziente
                ' sCodiceSanitario OR (sCognome AND sNome AND sCodiceFiscale) OR (sCognome AND sNome AND sDataNascita) 
                '
                If ((Not sCognome Is Nothing AndAlso sCognome.Length > 0) AndAlso (Not sNome Is Nothing AndAlso sNome.Length > 0) _
                     AndAlso
                     ((Not String.IsNullOrEmpty(sCodiceFiscale)) Or (oDataNascita.HasValue))) Then

                    '
                    ' Salvo i parametri in variabili di classe che verranno utilizzate nel selecting dell'ObjectDataSource.
                    '
                    _CodiceFiscale = sCodiceFiscale
                    _Cognome = sCognome
                    _Nome = sNome
                    _DataNascita = oDataNascita
                    WebGridPazienti.DataBind()
                Else
                    Throw New ApplicationException("La combinazione dei parametri non è valida. Combinazioni valide: [Cognome,Nome,Codice Fiscale], [Cognome,Nome,Data Nascita]")
                End If
            End If

            '
            'RENDERING PER BOOTSTRAP
            'Converte i tag html generati dalla GridView per la paginazione
            ' e li adatta alle necessita dei CSS Bootstrap
            '
            WebGridPazienti.PagerStyle.CssClass = "pagination-gridview"
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "gridPagination", HelperGridView.GetScriptPaginationForBootstrap(), True)
        Catch ex As ApplicationException
            _CancelSelect = True
            ShowAlert(ex.Message)
            NascondoPagina()
            Logging.WriteError(ex, Me.GetType.Name)
        Catch ex As Exception
            _CancelSelect = True
            ShowAlert("Errore durante il caricamento della pagina!")
            NascondoPagina()
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

    ''' <summary>
    ''' Funzione per la visualizzazione degli errori
    ''' </summary>
    ''' <param name="Text"></param>
    Public Sub ShowAlert(Text As String)

        '
        ' Usare visible e non "display:none"
        ' Nascosto di Default e ad ogni postback si rinasconde poiche' non ha il ViewState attivo
        '
        DivAlertMessage.Visible = Text.Length > 0
        DivAlertMessage.InnerText = Text

    End Sub

    Private Sub NascondoPagina()
        divPage.Visible = False
        CType(Master.FindControl("divMenu2"), HtmlGenericControl).Visible = False
    End Sub

    Private Sub CaricaCmbMotivoAccesso()
        Call Utility.LoadComboMotiviAccesso(cmbMotiviAccesso)
        '
        ' Verifico se l'utente ha l'accesso tecnico
        '
        Dim bUtenteTecnico As Boolean = HttpContext.Current.User.IsInRole(RoleManagerUtility2.ATTRIB_UTE_TEC)
        Dim bUtenteConAccessoTecnico As Boolean = HttpContext.Current.User.IsInRole(RoleManagerUtility2.ATTRIB_UTE_ACC_TEC)
        If bUtenteTecnico OrElse bUtenteConAccessoTecnico Then
            '
            ' Aggiungo e seleziono MOTIVO_ACCESSO_NECESSITA_TECNICA_TEXT (solo se "Utente tecnico")
            '
            cmbMotiviAccesso.Items.Add(New ListItem(MOTIVO_ACCESSO_NECESSITA_TECNICA_TEXT, MOTIVO_ACCESSO_NECESSITA_TECNICA_ID))
            If bUtenteTecnico Then
                cmbMotiviAccesso.SelectedValue = MOTIVO_ACCESSO_NECESSITA_TECNICA_ID
            End If
        Else
            '
            ' Nell'Accesso diretto aggiungo sempre MOTIVO_ACCESSO_PAZIENTE_IN_CARICO_TEXT e lo metto come default
            '
            cmbMotiviAccesso.Items.Add(New ListItem(MOTIVO_ACCESSO_PAZIENTE_IN_CARICO_TEXT, MOTIVO_ACCESSO_PAZIENTE_IN_CARICO_ID))
            cmbMotiviAccesso.SelectedValue = MOTIVO_ACCESSO_PAZIENTE_IN_CARICO_ID
        End If
    End Sub

#Region "WebGrid"
    Private Sub WebGridPazienti_RowCommand(sender As Object, e As GridViewCommandEventArgs) Handles WebGridPazienti.RowCommand
        Try
            If e.CommandName = "1" Then
                If cmbMotiviAccesso.SelectedValue <> MOTIVO_ACCESSO_NOT_SELECTED_ID Then
                    'SALVO IN SESSIONE IL MOTIVO DI ACCESSO E LE NOTE DEL MOTIVO DI ACCESSO.
                    SessionHandler.MotivoAccesso = cmbMotiviAccesso.SelectedItem
                    SessionHandler.MotivoAccessoNote = txtMotivoAccessoNote.Text

                    'TESTO SE E.COMMANDARGUMENT È UN GUID VALIDO. 
                    'SE NON LO È MOSTRO UN MESSAGGIO D'ERRORE.
                    Dim gIdPaziente As Guid = Nothing
                    Dim sIdPaziente As String = e.CommandArgument
                    If Not Guid.TryParse(sIdPaziente, gIdPaziente) Then
                        Throw New ApplicationException("Si è verificato un errore. L'id del paziente non è un guid valido.")
                    End If

                    ' RESETTO LA FORZATURA DEL CONSENSO 
                    Utility.SetSessionForzaturaConsenso(gIdPaziente, False)

                    ' REDIRECT ALLA PAGINA DEI REFERTILISTAPAZIENTE.ASPX
                    Dim dsTestataPaziente As New CustomDataSource.PazienteOttieniPerId
                    dsTestataPaziente.ClearCache(New Guid(e.CommandArgument.ToString))

                    'CANCELLO LA CACHE DEGLI OBJECT DATA SOURCE.
                    SessionHandler.AccessoDirettoCancellaCache = True

                    ' RESETTO I DATI IN SESSIONE DEL DETTAGLIO PAZIENTE SAC.
                    SacDettaglioPaziente.Session(gIdPaziente) = Nothing

                    'ESEGUO UN REDIRECT ALLA PAGINA DEI REFERTI.
                    Dim sUrl As String = Me.ResolveUrl(String.Format("~/AccessoDiretto/Referti.aspx?IdPaziente={0}&{1}", gIdPaziente.ToString, Me.msOtherParam))
                    Response.Redirect(sUrl)
                Else
                    Throw New ApplicationException("Selezionare il motivo d'accesso!")
                End If
            End If
        Catch ex As Threading.ThreadAbortException
            '
            ' Non faccio niente
            '
        Catch ex As ApplicationException
            _CancelSelect = True
            ShowAlert(ex.Message)
        Catch ex As Exception
            _CancelSelect = True
            NascondoPagina()
            ShowAlert("Errore durante la pressione del pulsante.")
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

    Private Sub WebGridPazienti_Sorting(sender As Object, e As GridViewSortEventArgs) Handles WebGridPazienti.Sorting
        Try
            e.Cancel = True
            Me.GridViewSortExpression = e.SortExpression
            If Me.GridViewSortDirection Is Nothing OrElse Me.GridViewSortDirection.Value = SortDirection.Descending Then
                Me.GridViewSortDirection = SortDirection.Ascending
            Else
                Me.GridViewSortDirection = SortDirection.Descending
            End If
            WebGridPazienti.DataBind()
        Catch ex As Exception
            _CancelSelect = True
            NascondoPagina()
            ShowAlert("Errore durante il caricamento dei dati.")
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

    Private Sub GridViewMain_PreRender(sender As Object, e As EventArgs) Handles WebGridPazienti.PreRender
        Try
            '
            'Render per Bootstrap
            'Crea la Table con Theader e Tbody se l'header non è nothing.
            '
            If Not WebGridPazienti.HeaderRow Is Nothing Then
                WebGridPazienti.UseAccessibleHeader = True
                WebGridPazienti.HeaderRow.TableSection = TableRowSection.TableHeader
            End If

            '
            'Nascondo la colonna dell'icona delle note in base a ShowNoteAnamnesticheTab
            '
            WebGridPazienti.Columns(2).Visible = My.Settings.ShowNoteAnamnesticheTab
        Catch ex As Exception
            _CancelSelect = True
            NascondoPagina()
            ShowAlert("Errore durante il caricamento dei dati.")
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub
#End Region

#Region "ObjectDataSource"
    Private Sub PazientiDataSource_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles PazientiDataSource.Selecting
        Try
            If _CancelSelect Then
                e.Cancel = True
                Exit Sub
            End If
            e.InputParameters("Token") = Me.Token
            ' ORDINAMENTO
            If Me.GridViewSortExpression.Length > 0 Then
                Dim sDir = If(Me.GridViewSortDirection = WebControls.SortDirection.Ascending, "@ASC", "@DESC")
                e.InputParameters("Ordinamento") = Me.GridViewSortExpression & sDir
            End If
            e.InputParameters("Cognome") = _Cognome
            e.InputParameters("Nome") = _Nome
            e.InputParameters("DataNascita") = _DataNascita
            e.InputParameters("CodiceFiscale") = _CodiceFiscale
        Catch ex As Exception
            _CancelSelect = True
            NascondoPagina()
            ShowAlert("Errore durante la ricerca dei dati del paziente!")
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

    Private Sub PazientiDataSource_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles PazientiDataSource.Selected
        Try
            WebGridPazienti.Visible = False

            'Ottengo il messaggio di errore.
            Dim messaggioErrore = HelperDataSourceException.GetObjectDataSourceExceptionMessage(e.Exception)

            'Testo se il messaggio di errore è vuoto. Se è valorizzato allora mostro il div d'errore.
            If Not String.IsNullOrEmpty(messaggioErrore) Then
                ShowAlert(messaggioErrore)
                e.ExceptionHandled = True
            Else
                Dim result As WcfDwhClinico.PazientiListaType = CType(e.ReturnValue, WcfDwhClinico.PazientiListaType)
                If Not result Is Nothing AndAlso result.Count > 0 Then
                    Dim bPagerStyleVisible As Boolean = True
                    WebGridPazienti.Visible = True
                Else
                    Dim sMsgNoRecord As String = "Non è stato trovato nessun paziente."
                    divMessage.Visible = True
                    divMessage.InnerText = sMsgNoRecord
                    WebGridPazienti.Visible = False
                End If
            End If

        Catch ex As Exception
            _CancelSelect = True
            NascondoPagina()
            Logging.WriteError(ex, Me.GetType.Name)
            ShowAlert("Errore durante l'operazione di ricerca dei dati!")
        End Try
    End Sub
#End Region

#Region "Funzioni MarkUp"
    Protected Function GetImgPresenzaReferti(objRow As Object) As String
        Dim oRow As WcfDwhClinico.PazienteListaType = CType(objRow, WcfDwhClinico.PazienteListaType)
        Return UserInterface.GetImgPresenzaReferti(oRow, Me.Page)
    End Function

    Protected Function GetImgTipoEpisodioRicovero(objRow As Object) As String
        Dim oRow As WcfDwhClinico.PazienteListaType = CType(objRow, WcfDwhClinico.PazienteListaType)
        Return UserInterface.GetImgTipoEpisodioRicovero(oRow)
    End Function

    Protected Function GetImgConsenso(objRow As Object) As String
        Dim oRow As WcfDwhClinico.PazienteListaType = CType(objRow, WcfDwhClinico.PazienteListaType)
        Return UserInterface.GetImgConsenso(oRow, Me.Page)
    End Function

    Protected Function GetColumnPaziente(objRow As Object) As String
        Dim oRow As WcfDwhClinico.PazienteListaType = CType(objRow, WcfDwhClinico.PazienteListaType)
        Return UserInterface.GetColumnPaziente(oRow)
    End Function

    Protected Function GetInformazioniAnagrafiche(objRow As Object) As String
        Dim oRow As WcfDwhClinico.PazienteListaType = CType(objRow, WcfDwhClinico.PazienteListaType)
        Return UserInterface.GetInformazioniAnagrafiche(oRow)
    End Function

    Protected Function GetRicovero(objRow As Object) As String
        Dim oRow As WcfDwhClinico.PazienteListaType = CType(objRow, WcfDwhClinico.PazienteListaType)
        Return UserInterface.GetRicovero(oRow)
    End Function

    Protected Function GetAnteprima(objRow As Object) As String
        Dim oRow As WcfDwhClinico.PazienteListaType = CType(objRow, WcfDwhClinico.PazienteListaType)
        Return UserInterface.GetAnteprima(oRow)
    End Function

    Protected Function GetDomicilio(objRow As Object) As String
        Dim oRow As WcfDwhClinico.PazienteListaType = CType(objRow, WcfDwhClinico.PazienteListaType)
        Return UserInterface.GetDomicilio(oRow)
    End Function

    ''' <summary>
    ''' Restituisce l'icona di presenza delle Note Anamnestiche.
    ''' </summary>
    ''' <param name="objRow"></param>
    ''' <returns></returns>
    Protected Function GetImgPresenzaNoteAnamnestiche(objRow As Object) As String
        Dim oRow As WcfDwhClinico.PazienteListaType = CType(objRow, WcfDwhClinico.PazienteListaType)
        Return UserInterface.GetImgPresenzaNoteAnamnestiche(oRow, Me.Page)
    End Function
#End Region
End Class
