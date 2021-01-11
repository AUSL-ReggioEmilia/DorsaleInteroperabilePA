Imports DI.PortalUser2
Imports DwhClinico.Data
Imports DwhClinico.Web.Utility

Partial Class Pazienti_Pazienti
    Inherits System.Web.UI.Page

    '
    ' Costanti per la memorizzazione nel ViewState
    '
    Private Const VS_PERMESSI_CANCELLAZIONE As String = "permessi_cancellazione"

    '
    ' Variabili private della classe
    '
    Private mstrPageID As String
    Private mbCancelSelectOperation As Boolean = False

    '
    ' Variabile per il permesso di cancellazione paziente
    '
    Private mbPermCancella As Boolean

#Region "Property"
    Private ReadOnly PageSessionIdPrefix As String = Page.GetType().BaseType.FullName

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
#End Region

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load


        '
        ' Id della pagina
        '
        mstrPageID = Me.GetType.Name

        '
        ' Solo la prima volta
        '
        If Not IsPostBack Then
            CaricaCmbMotivoAccesso()

            If Not Session(SESS_INVALIDA_CACHE_LISTA_PAZIENTI) Is Nothing Then
                Session(SESS_INVALIDA_CACHE_LISTA_PAZIENTI) = Nothing
                Call DataSourcePazienti_InvalidaCache()
            End If

            mbPermCancella = VerificaPermessiCancellazionePaziente()

            ViewState(VS_PERMESSI_CANCELLAZIONE) = mbPermCancella
            '
            ' Carico i filtri salvati nella Sessione
            '
            Call LoadFilterValues()

            '
            ' eseguo il bind della griglia solo se ho in sessione il cognome
            '
            If Not Me.Session(mstrPageID & txtCognome.ID) Is Nothing Then
                GridViewMain.DataBind()
            End If

        Else
            mbPermCancella = CType(ViewState(VS_PERMESSI_CANCELLAZIONE), Boolean)
        End If

        '
        'RENDERING PER BOOTSTRAP
        'Converte i tag html generati dalla GridView per la paginazione
        ' e li adatta alle necessita dei CSS Bootstrap
        '
        GridViewMain.PagerStyle.CssClass = "pagination-gridview"
        ScriptManager.RegisterStartupScript(Page, Page.GetType(), "gridPagination", HelperGridView.GetScriptPaginationForBootstrap(), True)
    End Sub

    Protected Sub cmdCerca_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdCerca.Click
        Try
            mbCancelSelectOperation = False
            EsegueRicerca()

        Catch ex As Exception
            mbCancelSelectOperation = True
            '
            ' Errore
            '
            Logging.WriteError(ex, Me.GetType.Name)
            ShowAlert("Errore durante l'operazione di ricerca dei dati!")
        End Try
    End Sub

    Private Sub EsegueRicerca()
        '
        ' Invalido la cache della datasource 
        '
        DataSourcePazienti_InvalidaCache()
        '
        ' Eseguo il bind della griglia con i dati
        '
        GridViewMain.DataBind()
    End Sub

#Region "ObjectDataSource"
    Private Sub DataSourcePazienti_InvalidaCache()
        '
        ' Invalido la cache della datasource 
        '
        Dim dsPazienti As New CustomDataSource.PazientiCercaPerGeneralita()
        dsPazienti.ClearCache()
    End Sub

    Protected Sub DataSourcePazienti_Selecting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.ObjectDataSourceSelectingEventArgs) Handles DataSourcePazienti.Selecting
        Try
            If mbCancelSelectOperation Then
                e.Cancel = True
                Exit Sub
            End If
            If ValidateFiltersValue() Then
                '
                ' Salvo in sessione i filtri
                '
                Call SaveFilterValues()


                ' ORDINAMENTO
                If Me.GridViewSortExpression.Length > 0 Then
                    Dim sDir = If(Me.GridViewSortDirection = WebControls.SortDirection.Ascending, "@ASC", "@DESC")
                    e.InputParameters("Ordinamento") = Me.GridViewSortExpression & sDir
                End If
                e.InputParameters("Token") = Me.Token
            Else
                e.Cancel = True
                ShowAlert("Verificare i valori di filtro!")
            End If

        Catch ex As Exception
            Logging.WriteError(ex, Me.GetType.Name)
            ShowAlert("Errore durante l'operazione di ricerca dei dati!")
        End Try
    End Sub

    Protected Sub DataSourcePazienti_Selected(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles DataSourcePazienti.Selected
        Try
            divGridView.Visible = False
            '
            ' visualizzo il pulsante per filtrare e la checkboxlist solo se la griglia non è vuota
            '
            'Ottengo il messaggio di errore.
            Dim messaggioErrore = HelperDataSourceException.GetObjectDataSourceExceptionMessage(e.Exception)

            'Testo se il messaggio di errore è vuoto. Se è valorizzato allora mostro il div d'errore.
            If Not String.IsNullOrEmpty(messaggioErrore) Then
                ShowAlert(messaggioErrore)
                e.ExceptionHandled = True
            Else
                Dim result As List(Of WcfDwhClinico.PazienteListaType) = CType(e.ReturnValue, List(Of WcfDwhClinico.PazienteListaType))
                If Not result Is Nothing AndAlso result.Count > 0 Then
                    Dim bPagerStyleVisible As Boolean = True
                    divGridView.Visible = True
                Else
                    Dim sMsgNoRecord As String = "Non è stato trovato nessun paziente. Modificare eventualmente i parametri di filtro."
                    divMessage.Visible = True
                    divMessage.InnerText = sMsgNoRecord
                    divGridView.Visible = False
                End If
            End If
        Catch ex As Exception
            '
            ' Errore
            '
            Logging.WriteError(ex, Me.GetType.Name)
            ShowAlert("Errore durante l'operazione di ricerca dei dati!")
        End Try
    End Sub
#End Region

#Region "Filtri"
    Private Sub LoadFilterValues()
        txtNome.Text = CType(Me.Session(mstrPageID & txtNome.ID), String)
        txtCognome.Text = CType(Me.Session(mstrPageID & txtCognome.ID), String)
        txtAnnoNascita.Text = CType(Me.Session(mstrPageID & txtAnnoNascita.ID), String)
        'txtLuogoNascita.Text = CType(Me.Session(mstrPageID & txtLuogoNascita.ID), String)
    End Sub

    Private Sub SaveFilterValues()
        Me.Session(mstrPageID & txtNome.ID) = txtNome.Text
        Me.Session(mstrPageID & txtCognome.ID) = txtCognome.Text
        Me.Session(mstrPageID & txtAnnoNascita.ID) = txtAnnoNascita.Text
        'Me.Session(mstrPageID & txtLuogoNascita.ID) = txtLuogoNascita.Text
    End Sub

    Private Function ValidateFiltersValue() As Boolean
        Dim bValidation As Boolean = True
        Try
            If txtAnnoNascita.Text.Length > 0 Then
                Dim oAnno As Integer
                If Not Integer.TryParse(txtAnnoNascita.Text, oAnno) Then
                    bValidation = False
                Else
                    If oAnno < 1900 Or oAnno > System.Data.SqlTypes.SqlDateTime.MaxValue.Value.Year Then
                        bValidation = False
                    End If
                End If
            End If

            If txtCognome.Text.Trim.Length = 0 Then
                bValidation = False
                If IsPostBack Then
                    divMessage.Visible = True
                    divMessage.InnerHtml = "Il parametro di ricerca Cognome è obbligatorio!."
                End If
            End If
        Catch ex As Exception
            Logging.WriteWarning("Errore durante l'operazione di validazione dei filtri!" & vbCrLf & Utility.FormatException(ex))
            bValidation = False
        End Try

        Return bValidation
    End Function
#End Region

#Region "GridViewMain"
    Private Sub GridViewMain_PreRender(sender As Object, e As EventArgs) Handles GridViewMain.PreRender
        '
        'Render per Bootstrap
        'Crea la Table con Theader e Tbody se l'header non è nothing.
        '
        If Not GridViewMain.HeaderRow Is Nothing Then
            GridViewMain.UseAccessibleHeader = True
            GridViewMain.HeaderRow.TableSection = TableRowSection.TableHeader
        End If

        '
        'Nascondo la colonna dell'icona delle note in base a ShowNoteAnamnesticheTab
        '
        GridViewMain.Columns(2).Visible = My.Settings.ShowNoteAnamnesticheTab
    End Sub

    Private Sub GridViewMain_Sorting(sender As Object, e As GridViewSortEventArgs) Handles GridViewMain.Sorting
        e.Cancel = True
        Me.GridViewSortExpression = e.SortExpression
        If Me.GridViewSortDirection Is Nothing OrElse Me.GridViewSortDirection.Value = SortDirection.Descending Then
            Me.GridViewSortDirection = SortDirection.Ascending
        Else
            Me.GridViewSortDirection = SortDirection.Descending
        End If
        EsegueRicerca()
    End Sub



    Private Sub GridViewMain_RowDataBound(sender As Object, e As GridViewRowEventArgs) Handles GridViewMain.RowDataBound
        HelperGridView.AddHeaderSortingIcon(sender, e, GridViewSortExpression, GridViewSortDirection)
    End Sub

    Private Sub GridViewMain_RowCommand(sender As Object, e As GridViewCommandEventArgs) Handles GridViewMain.RowCommand
        Dim sIdPaziente As String = e.CommandArgument.ToString

        If e.CommandName = "1" Then
            Dim IdPaziente As Guid = New Guid(sIdPaziente)
            '
            ' Resetto la forzatura del consenso 
            '
            Utility.SetSessionForzaturaConsenso(IdPaziente, False)
            '
            ' Resetto i dati in cache del dettaglio paziente
            '
            Dim dsTestataPaziente As New CustomDataSource.PazienteOttieniPerId
            dsTestataPaziente.ClearCache(IdPaziente)
            '
            ' Resetto i dati in sessione del dettaglio paziente SAC
            '
            SacDettaglioPaziente.Session(IdPaziente) = Nothing

            SessionHandler.CancellaCache = True
            '
            ' Navigo alla pagina dei referti del paziente
            '
            Call NavigaAllaPagina("~/Referti/RefertiListaPaziente.aspx", e.CommandArgument)
        ElseIf e.CommandName = "OscuramentoPaziente" Then
            Response.Redirect(String.Format("~/Pazienti/PazientiCancella.aspx?{0}={1}", PAR_ID_PAZIENTE, e.CommandArgument))
        End If
    End Sub
#End Region

#Region "MotivazioneAccesso"
    Private Sub CaricaCmbMotivoAccesso()
        Call Utility.LoadComboMotiviAccesso(cmbMotiviAccesso)
        '
        ' Verifico se l'utente ha l'accesso tecnico
        ' TODO: MODIFICARE LA LOGICA DELLA MOTIVAZIONE DI ACCESSO
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
            ' In base alla pagina di provenienza imposto default per il motivo dell'accesso
            '
            If Request.UrlReferrer IsNot Nothing Then
                Dim sPath As String = Request.UrlReferrer.AbsolutePath.ToUpper
                If Not sPath.Contains("/PAZIENTI/PAZIENTI.ASPX") Then
                    '
                    ' Se si arriva alla pagina del consenso navigando "all'indietro"...
                    ' Seleziono valore già selezionato in precedenza leggendolo dalla sessione (Se si seleziona un item che non esiste NON viene generato un errore)
                    '
                    Dim oItemMotivoAccesso As ListItem = SessionHandler.MotivoAccesso
                    If Not oItemMotivoAccesso Is Nothing Then
                        If cmbMotiviAccesso.Items.FindByValue(oItemMotivoAccesso.Value) Is Nothing Then
                            cmbMotiviAccesso.Items.Add(oItemMotivoAccesso)
                        End If
                        cmbMotiviAccesso.SelectedValue = oItemMotivoAccesso.Value
                    End If
                End If
            End If
        End If
    End Sub

    Private Sub NavigaAllaPagina(sUrl As String, id As String)
        Try
            '
            ' Controllo se è stato selezionato un motivo d'accesso
            ' Se è stato selezionato allora salvo in sessione il motivo e le note perchè vengono utilizzate in ogni pagina per tracciare gli accessi
            '
            If cmbMotiviAccesso.SelectedValue <> MOTIVO_ACCESSO_NOT_SELECTED_ID Then
                SessionHandler.MotivoAccesso = cmbMotiviAccesso.SelectedItem
                SessionHandler.MotivoAccessoNote = txtMotivoAccessoNote.Text

                '
                ' Redirect alla pagina dei RefertiListaPaziente.aspx
                '
                Response.Redirect(Me.ResolveUrl(sUrl) & "?idpaziente=" & id)
            Else
                '
                ' Mostro messaggio di errore
                '
                ShowAlert("Selezionare il motivo d'accesso!")

            End If
        Catch ex As Threading.ThreadAbortException
            ' Non faccio niente: causato dal redirect
        Catch ex As Exception
            ' Gestione dell'errore
            ShowAlert("Errore durante la pressione del pulsante.")
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

#End Region

#Region "Funzioni usate nel markup"

    ''' <summary>
    ''' Restituisce l'icona di presenza delle Note Anamnestiche.
    ''' </summary>
    ''' <param name="objRow"></param>
    ''' <returns></returns>
    Protected Function GetImgPresenzaNoteAnamnestiche(objRow As Object) As String
        Dim oRow As WcfDwhClinico.PazienteListaType = CType(objRow, WcfDwhClinico.PazienteListaType)
        Return UserInterface.GetImgPresenzaNoteAnamnestiche(oRow, Me.Page)
    End Function

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

    ' 2020-02-19 KYRYLO: Aggiunta il controllo dei permessi per visulizzare la "X" di oscura paziente
    Protected Function CheckDeletePermission() As Boolean
        Return mbPermCancella
    End Function

#End Region
End Class
