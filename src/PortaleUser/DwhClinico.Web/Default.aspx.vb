Imports DwhClinico.Data
Imports DwhClinico.Web
Imports DwhClinico.Web.Utility
Imports System.Net
Imports DI.PortalUser2.Data
Imports DI.PortalUser2

'Imports DwhClinico.Web.DwhNewsLists

Partial Class _Default
    Inherits System.Web.UI.Page

    Private mbCancelSelectOperation As Boolean = False
    Private cmdCercaValidaSelect As Boolean = False
    Private oRoleManagerUtility As New RoleManagerUtility2(Utility.GetAppSettings(Utility.PAR_DI_PORTAL_USER_CONNECTION_STRING, ""), My.Settings.SAC_ConnectionString, My.Settings.WsSac_User, My.Settings.WsSac_Password)
    Const REPARTI_RICOVERO_ITEM_TUTTI_VALUE As String = ""
    Const REPARTI_RICOVERO_ITEM_TUTTI_TEXT As String = "<Tutte le Unità Operative>"
    Private Const MAX_NUM_RECORD_PAZIENTI_RICOVERATI As Integer = 100
    Private mPortalDataAdapterManager As PortalDataAdapterManager
    Private mstrPageID As String
    Private ReadOnly PageSessionIdPrefix As String = Page.GetType().BaseType.FullName

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
        Try
            mPortalDataAdapterManager = New PortalDataAdapterManager(Utility.GetAppSettings(Utility.PAR_DI_PORTAL_USER_CONNECTION_STRING, ""))
            '
            ' Id della pagina
            '
            mstrPageID = Me.GetType.Name

            If Not IsPostBack Then

                '
                ' Valorizzo la combo per il motivo d'accesso
                '
                CaricaCmbMotivoAccesso()

                '
                ' Quando passo per la default.aspx forzo la rilettura delle configurazioni di stampa su PrintManager
                '
                Call PrintUtil.ReloadMyPrintingConfig()

                '
                ' Visualizzo il messaggio della privacy
                '
                Call ShowPrivacyWarning()

                '
                ' Carico le combo
                '
                Call LoadComboRepartiRicovero()

                '
                ' Leggo dal database valore corrente del codice reparto richiedente e lo seleziono nella combo delle Unità Operative
                '
                Dim sCodiceReparto_CodiceAzienda As String = mPortalDataAdapterManager.DatiUtenteOttieniValore(HttpContext.Current.User.Identity.Name, OpzioniUtente.DWH_USER_REP_RIC_CODICE, "")
                cmbUnitaOperative.SelectedValue = sCodiceReparto_CodiceAzienda
                '
                ' Carico combo dei TipiRicovero/Regimi passandogli il reparto/unità operativa selezionato
                '
                Call LoadComboTipoRicovero(sCodiceReparto_CodiceAzienda)
                Call LoadComboStatoEpisodio()

                '
                ' Ricarico i valori di filtro precedentemente salvati
                '
                Call LoadFilterValues()

                'SE HIDEHOMEALERT = FALSE ALLORA MOSTRO L'ALERT E IMPOSTO A TRUE LA VARIABILE DI SESSIONE.
                'IN QUESTO MODO NON MOSTRO L'ALERT TUTTE LE VOLTE.
                If SessionHandler.HideHomeAlert = False Then
                    Dim functionJS As String = "$('#alertModal').modal('show');"
                    ScriptManager.RegisterStartupScript(Page, Page.GetType, "LanchServerSide2", functionJS, True)
                    btnChiudiAlert.Focus()
                    SessionHandler.HideHomeAlert = True
                End If
            End If

            Dim bShowPazienti As Boolean = CBool(cmbUnitaOperative.Items.Count > 0)

            If Not Page.IsPostBack Then
                '
                ' Eseguo query: solo se ho degli item nella combo delle unita operative e solo se è la prima volta che entro nella pagina
                '
                If bShowPazienti Then
                    Call ShowPazientiReparti()
                End If
            End If

            '
            ' Visualizzo nascondo in base all'avere delle unità operative
            '
            panelPazientiReparto.Visible = bShowPazienti
            divHomeImg.Visible = Not bShowPazienti
            divPage.Visible = bShowPazienti

            '
            'RENDERING PER BOOTSTRAP
            'Converte i tag html generati dalla GridView per la paginazione
            ' e li adatta alle necessita dei CSS Bootstrap
            '
            GridViewPazientiReparto.PagerStyle.CssClass = "pagination-gridview"
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "gridPagination", HelperGridView.GetScriptPaginationForBootstrap(), True)
        Catch ex As Threading.ThreadAbortException
            '
            ' Non faccio niente
            '
        Catch ex As ApplicationException
            Logging.WriteError(ex, Me.GetType.Name)
            ShowAlert(ex.Message)
        Catch ex As Exception
            Logging.WriteError(ex, Me.GetType.Name)
            ShowAlert("Errore durante il caricamento della pagina!")
        End Try
    End Sub

#Region "Pazienti ricoverati nei reparti basato su ROLE MANAGER"
    Private Sub LoadComboStatoEpisodio()
        Try
            If cmbStatoEpisodio.Items.Count = 0 Then
                cmbStatoEpisodio.Items.Add(New ListItem("Dimesso", "0"))
                cmbStatoEpisodio.Items.Add(New ListItem("Ricoverato", "1") With {.Selected = True})  'SELECTED
                cmbStatoEpisodio.Items.Add(New ListItem("In prenotazione", "3"))
            End If

            'solo per il tipo ricovero Ordinario aggiungo lo stato episodio Trasferito 
            If cmbTipoRicovero.SelectedValue = "O" Then
                If cmbStatoEpisodio.Items.FindByValue("4") Is Nothing Then
                    cmbStatoEpisodio.Items.Add(New ListItem("Trasferito", "4"))
                End If
            Else
                'per gli altri tipo ricovero elimino lo stato episodio Trasferito
                Dim oItm As ListItem = cmbStatoEpisodio.Items.FindByValue("4")
                If oItm IsNot Nothing Then
                    cmbStatoEpisodio.Items.Remove(oItm)
                    'ri seleziono il default: Ricoverato
                    oItm = cmbStatoEpisodio.Items.FindByValue("1")
                    If oItm IsNot Nothing Then
                        cmbStatoEpisodio.ClearSelection()
                        oItm.Selected = True
                    End If
                End If

            End If
        Catch ex As Threading.ThreadAbortException
            '
            ' Non faccio niente
            '
        Catch ex As Exception
            Dim sMsgErr As String = "Si è verificato un errore durante il caricamento degli stati del ricovero."
            Logging.WriteError(ex, Me.GetType.Name & vbCrLf & sMsgErr)
        End Try
    End Sub

    ''' <summary>
    ''' Identifica il reparto scelto dall'utente. E' scritto nel formato "CodiceReparto;CodiceAzienda"
    ''' </summary>
    Private Sub LoadComboTipoRicovero(ByVal sCodiceReparto_CodiceAzienda As String)
        Try
            cmbTipoRicovero.Items.Clear()
            Dim sCodiceReparto As String = Nothing
            Dim sCodiceAzienda As String = Nothing
            Dim oList As Generic.List(Of RoleManager.Regime) = Nothing
            Dim oRoleManagerDa As New RoleManager.DataAccess(My.Settings.SAC_ConnectionString, My.Settings.WsSac_User, My.Settings.WsSac_Password)
            If (sCodiceReparto_CodiceAzienda <> REPARTI_RICOVERO_ITEM_TUTTI_VALUE) AndAlso (Not String.IsNullOrEmpty(sCodiceReparto_CodiceAzienda)) Then
                Dim oCodici As String() = Split(sCodiceReparto_CodiceAzienda, ";")
                If oCodici.GetUpperBound(0) > 0 Then
                    sCodiceReparto = oCodici(0)
                    sCodiceAzienda = oCodici(1)
                End If
            End If
            oList = oRoleManagerUtility.GetRegimiByUnitaOperativa(sCodiceAzienda, sCodiceReparto)
            cmbTipoRicovero.DataSource = oList
            cmbTipoRicovero.DataValueField = "Codice"
            cmbTipoRicovero.DataTextField = "Descrizione"
            cmbTipoRicovero.DataBind()
        Catch ex As Threading.ThreadAbortException
            '
            ' Non faccio niente
            '
        Catch ex As Exception
            ShowAlert("Si è verificato un errore durante il caricamento dei tipi di ricovero.")
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

    Private Sub LoadComboRepartiRicovero()
        Dim oListUnitaOperative As Generic.List(Of RoleManager.UnitaOperativa) = Nothing
        Try
            oListUnitaOperative = oRoleManagerUtility.GetUnitaOperative()
            cmbUnitaOperative.Items.Clear()
            If Not oListUnitaOperative Is Nothing AndAlso oListUnitaOperative.Count > 0 Then
                '
                ' Aggiungo l'item <Tutti>
                '
                Dim oItemCombo As New ListItem(REPARTI_RICOVERO_ITEM_TUTTI_TEXT, REPARTI_RICOVERO_ITEM_TUTTI_VALUE)
                cmbUnitaOperative.Items.Add(oItemCombo)
                '
                ' Ordino la lista delle unità operative
                '
                oListUnitaOperative.Sort(ListUnitaOperativeComparison)
                For Each oUnitaOperativa As RoleManager.UnitaOperativa In oListUnitaOperative
                    Dim sText As String = String.Format("{0} - ({1}-{2})", oUnitaOperativa.Descrizione, oUnitaOperativa.Codice, oUnitaOperativa.CodiceAzienda)
                    Dim sValue As String = String.Format("{0};{1}", oUnitaOperativa.Codice, oUnitaOperativa.CodiceAzienda)
                    oItemCombo = New ListItem(sText, sValue)
                    cmbUnitaOperative.Items.Add(oItemCombo)
                Next
            End If
        Catch ex As Exception
            ShowAlert("Si è verificato un errore durante il caricamento dei tipi di ricovero.")
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

    Private ListUnitaOperativeComparison As Comparison(Of RoleManager.UnitaOperativa) = AddressOf ListUnitaOperativeSort
    Private Function ListUnitaOperativeSort(p1 As RoleManager.UnitaOperativa, p2 As RoleManager.UnitaOperativa) As String
        If Not p1 Is Nothing AndAlso Not p2 Is Nothing Then
            If Not String.IsNullOrEmpty(p1.Descrizione) AndAlso Not String.IsNullOrEmpty(p2.Descrizione) Then
                Return p1.Descrizione.CompareTo(p2.Descrizione)
            End If
        End If
    End Function

    '
    ' Versione su ricoverati per codice dell'unita operativa
    ' Utilizzare il corretto objectdata source (cambiano i parametri di select)
    '
    Private Sub ShowPazientiReparti()
        Try
            mbCancelSelectOperation = True
            If ValidateFiltersValue() Then
                panelPazientiReparto.Visible = True

                mbCancelSelectOperation = False
                '
                ' Invalido la cache della datasource 
                '
                DataSourcePazienti_InvalidaCache()

                GridViewPazientiReparto.DataBind()

                '
                ' Salvo ultima selezione utente
                '
                If CStr(Me.Session(mstrPageID & cmbUnitaOperative.ID) & "") <> cmbUnitaOperative.SelectedValue Then
                    mPortalDataAdapterManager.DatiUtenteSalvaValore(HttpContext.Current.User.Identity.Name, OpzioniUtente.DWH_USER_REP_RIC_CODICE, cmbUnitaOperative.SelectedValue)
                End If

                '
                ' Salvo i valori di filtro
                '
                Call SaveFilterValues()
            End If
        Catch ex As Exception
            ShowAlert("Errore durante l'operazione di ricerca dei dati!")
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

    ''' <summary>
    ''' Funzione prer popolare il parametro TABLE della query ricerca pazienti ricoverati
    ''' </summary>
    ''' <param name="sRepartiRicoveroSelectedValue"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Private Function CreateRepartiRicoveroParameter(sRepartiRicoveroSelectedValue As String) As WcfDwhClinico.RepartiParam
        Dim oDt As New WcfDwhClinico.RepartiParam()

        If sRepartiRicoveroSelectedValue = REPARTI_RICOVERO_ITEM_TUTTI_VALUE Then
            For Each oItem As ListItem In cmbUnitaOperative.Items
                If oItem.Value <> REPARTI_RICOVERO_ITEM_TUTTI_VALUE Then
                    Dim oArray As String() = Split(oItem.Value, ";")
                    Dim sReparto As String = oArray(0)
                    Dim sAzienda As String = oArray(1)
                    Dim reparto As New WcfDwhClinico.RepartoParam With {.AziendaCodice = sAzienda, .RepartoCodice = sReparto}

                    oDt.Add(reparto)
                End If
            Next
        Else
            Dim oArray As String() = Split(sRepartiRicoveroSelectedValue, ";")
            Dim sReparto As String = oArray(0)
            Dim sAzienda = oArray(1)
            Dim reparto As New WcfDwhClinico.RepartoParam With {.AziendaCodice = sAzienda, .RepartoCodice = sReparto}
            oDt.Add(reparto)
        End If
        Return oDt
    End Function

    ''' <summary>
    ''' Serve a verificare che le corrette combinazioni di filtro siano specificate
    ''' </summary>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Private Function ValidateFiltersValue() As Boolean
        Dim bValidation As Boolean = True
        Dim sTipoRicovero As String = String.Empty
        Dim sStatoEpisodio As String = String.Empty
        Try
            sTipoRicovero = cmbTipoRicovero.SelectedValue.ToUpper()
            sStatoEpisodio = cmbStatoEpisodio.SelectedValue.ToUpper()
            If (sTipoRicovero = "D" OrElse sTipoRicovero = "S") AndAlso (txtCognome.Text.Length < 2) Then
                Throw New ApplicationException("Se il tipo ricovero è 'Day Hospital' o 'Day Service' specificare almeno 2 lettere del cognome!")
            ElseIf (sStatoEpisodio = "0" OrElse sStatoEpisodio = "3") AndAlso (txtCognome.Text.Length < 2) Then
                Throw New ApplicationException("Per la ricerca di 'Dimissioni' o 'Prenotazioni' specificare almeno 2 lettere del cognome!")
            End If
            If (sTipoRicovero = "O" And sStatoEpisodio = "4" And txtCognome.Text.Length < 2) Then
                Throw New ApplicationException("Per la ricerca di 'Trasferiti' specificare almeno 2 lettere del cognome!")
            End If

            '
            'SIMONE B - 2017-10-18
            'VALIDAZIONE DEL FILTRO "NOME"
            '
            If Not String.IsNullOrEmpty(txtNome.Text) Then
                If String.IsNullOrEmpty(txtCognome.Text) Then
                    ' SE IL NOME E' VALORIZZATO ALLORA ANCHE IL CAMPO COGNOME DEVE ESSERLO.
                    Throw New ApplicationException("Se il filtro 'Nome' è valorizzato specificare anche il cognome.")
                End If
            End If
        Catch ex As ApplicationException
            ShowAlert(ex.Message)
            bValidation = False
        Catch ex As Exception
            ShowAlert("Errore durante l'operazione di validazione dei filtri!")
            Logging.WriteError(ex, Me.GetType.Name)
            bValidation = False
        End Try
        Return bValidation
    End Function


#End Region

#Region "ObjectDataSource"
    Protected Sub DataSourcePazientiReparto_Selecting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.ObjectDataSourceSelectingEventArgs) Handles DataSourcePazientiReparto.Selecting
        Try
            If mbCancelSelectOperation Then
                e.Cancel = True
                Exit Sub
            End If


            ' ORDINAMENTO
            If Me.GridViewSortExpression.Length > 0 Then
                Dim sDir = If(Me.GridViewSortDirection = WebControls.SortDirection.Ascending, "@ASC", "@DESC")
                e.InputParameters("Ordinamento") = Me.GridViewSortExpression & sDir
            End If
            e.InputParameters("UnitaOperative") = CreateRepartiRicoveroParameter(cmbUnitaOperative.SelectedValue)
            e.InputParameters("Token") = Me.Token
            e.InputParameters("maxNumRecord") = MAX_NUM_RECORD_PAZIENTI_RICOVERATI + 2
        Catch ex As Threading.ThreadAbortException
            '
            ' Non faccio niente
            '
        Catch ex As Exception
            Logging.WriteError(ex, Me.GetType.Name)
            ShowAlert("Errore durante l'operazione di ricerca dei dati!")
        End Try
    End Sub

    Protected Sub DataSourcePazientiReparto_Selected(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles DataSourcePazientiReparto.Selected
        Try
            'Nascondo i div d'errore.
            divGridView.Visible = False
            divMessage.Visible = False

            'Ottengo il messaggio di errore.
            Dim messaggioErrore = HelperDataSourceException.GetObjectDataSourceExceptionMessage(e.Exception)

            'Testo se il messaggio di errore è vuoto. Se è valorizzato allora mostro il div d'errore.
            If Not String.IsNullOrEmpty(messaggioErrore) Then
                ShowAlert(messaggioErrore)
                e.ExceptionHandled = True
            Else
                '
                ' Verifico che venga effettivamente restituito qualcosa
                '
                Dim result As List(Of WcfDwhClinico.PazienteListaType) = CType(e.ReturnValue, List(Of WcfDwhClinico.PazienteListaType))
                If Not result Is Nothing AndAlso result.Count > 0 Then
                    If result.Count > MAX_NUM_RECORD_PAZIENTI_RICOVERATI Then
                        divMessage.Visible = True
                        divMessage.InnerText = Utility.MSG_MAX_NUM_RECORD
                        divGridView.Visible = True
                    Else
                        Dim bPagerStyleVisible As Boolean = True
                        divGridView.Visible = True
                    End If
                Else
                    Dim sMsgNoRecord As String = "Non è stato trovato nessun ricovero. Modificare eventualmente i parametri di filtro."
                    divMessage.Visible = True
                    divMessage.InnerText = sMsgNoRecord
                    divGridView.Visible = False
                End If
            End If

        Catch ex As Threading.ThreadAbortException
            '
            ' Non faccio niente
            '
        Catch ex As ApplicationException
            Logging.WriteError(ex, Me.GetType.Name)
            ShowAlert("Errore durante l'operazione di ricerca dei dati!")
        Catch ex As Exception
            '
            ' Errore
            '
            Logging.WriteError(ex, Me.GetType.Name)
            ShowAlert("Errore durante l'operazione di ricerca dei dati!")
        End Try
    End Sub

    Private Sub DataSourcePazienti_InvalidaCache()
        '
        ' Invalido la cache della datasource 
        '
        Dim dsPazienti As New CustomDataSource.PazientiRicoveratiCercaPerReparti()
        dsPazienti.ClearCache()
    End Sub
#End Region

#Region "GridViewPazientiReparto"
    Private Sub GridViewPazientiReparto_RowCommand(sender As Object, e As GridViewCommandEventArgs) Handles GridViewPazientiReparto.RowCommand
        If e.CommandName = "1" Then

            Dim sIdPaziente As String = e.CommandArgument.ToString
            '
            ' Resetto i dati in cache del dettaglio paziente
            '
            Dim dsTestataPaziente As New CustomDataSource.PazienteOttieniPerId
            dsTestataPaziente.ClearCache(New Guid(sIdPaziente))
            '
            ' Resetto i dati in sessione del dettaglio paziente SAC
            '
            SacDettaglioPaziente.Session(New Guid(sIdPaziente)) = Nothing

            SessionHandler.CancellaCache = True

            '
            ' Resetto la forzatura del consenso 
            '
            Utility.SetSessionForzaturaConsenso(New Guid(sIdPaziente), False)
            Call NavigaAllaPagina("~/Referti/RefertiListaPaziente.aspx", e.CommandArgument)
        End If
    End Sub

    Private Sub GridViewPazientiReparto_RowDataBound(sender As Object, e As GridViewRowEventArgs) Handles GridViewPazientiReparto.RowDataBound
        HelperGridView.AddHeaderSortingIcon(sender, e, GridViewSortExpression, GridViewSortDirection)
    End Sub

    Private Sub GridViewPazientiReparto_Sorting(sender As Object, e As GridViewSortEventArgs) Handles GridViewPazientiReparto.Sorting
        e.Cancel = True
        Me.GridViewSortExpression = e.SortExpression
        If Me.GridViewSortDirection Is Nothing OrElse Me.GridViewSortDirection.Value = SortDirection.Descending Then
            Me.GridViewSortDirection = SortDirection.Ascending
        Else
            Me.GridViewSortDirection = SortDirection.Descending
        End If
        ShowPazientiReparti()
    End Sub

    Private Sub GridViewPazientiReparto_PreRender(sender As Object, e As EventArgs) Handles GridViewPazientiReparto.PreRender
        '
        'Render per Bootstrap
        'Crea la Table con Theader e Tbody se l'header non è nothing.
        '
        If Not GridViewPazientiReparto.HeaderRow Is Nothing Then
            GridViewPazientiReparto.UseAccessibleHeader = True
            GridViewPazientiReparto.HeaderRow.TableSection = TableRowSection.TableHeader
        End If

        '
        'Nascondo la colonna dell'icona delle note in base a ShowNoteAnamnesticheTab
        '
        GridViewPazientiReparto.Columns(2).Visible = My.Settings.ShowNoteAnamnesticheTab
    End Sub
#End Region

#Region "Motivazione Accesso"
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
            ' Aggiungo alla combo il motivo "Paziente in carico"
            '
            If cmbMotiviAccesso.Items.FindByValue(MOTIVO_ACCESSO_PAZIENTE_IN_CARICO_ID) Is Nothing Then
                cmbMotiviAccesso.Items.Add(New ListItem(MOTIVO_ACCESSO_PAZIENTE_IN_CARICO_TEXT, MOTIVO_ACCESSO_PAZIENTE_IN_CARICO_ID))
            End If
            cmbMotiviAccesso.SelectedValue = MOTIVO_ACCESSO_PAZIENTE_IN_CARICO_ID
            '
            ' Seleziono valore già selezionato in precedenza leggendolo dalla sessione (Se si seleziona un item che non esiste NON viene generato un errore)
            ' Se il valore è MOTIVO_ACCESSO_PAZIENTE_IN_CARICO_ID verrà riselezionato un'altra volta
            '
            Dim oItemMotivoAccesso As ListItem = SessionHandler.MotivoAccesso
            If Not oItemMotivoAccesso Is Nothing Then
                If cmbMotiviAccesso.Items.FindByValue(oItemMotivoAccesso.Value) Is Nothing Then
                    cmbMotiviAccesso.Items.Add(oItemMotivoAccesso)
                End If
                cmbMotiviAccesso.SelectedValue = oItemMotivoAccesso.Value
            End If
        End If
    End Sub

    Private Sub NavigaAllaPagina(sUrl As String, id As String)
        Try
            If cmbMotiviAccesso.SelectedValue <> MOTIVO_ACCESSO_NOT_SELECTED_ID Then
                SessionHandler.MotivoAccesso = cmbMotiviAccesso.SelectedItem
                SessionHandler.MotivoAccessoNote = txtMotivoAccessoNote.Text
                '
                ' Redirect alla pagina dei RefertiListaPaziente.aspx
                '
                Response.Redirect(Me.ResolveUrl(sUrl) & "?idpaziente=" & id)
            Else
                Throw New ApplicationException("Selezionare il motivo d'accesso!")
            End If
        Catch ex As Threading.ThreadAbortException
            '
            ' Non faccio niente
            '
        Catch ex As ApplicationException
            ShowAlert(ex.Message)
        Catch ex As Exception
            ShowAlert("Errore durante la pressione del pulsante.")
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub
#End Region

#Region "Validazione Filtri"
    Private Sub SaveFilterValues() 'da usare in execute search
        Try
            Me.Session(mstrPageID & cmbUnitaOperative.ID) = cmbUnitaOperative.SelectedValue
            Me.Session(mstrPageID & cmbStatoEpisodio.ID) = cmbStatoEpisodio.SelectedValue
            Me.Session(mstrPageID & cmbTipoRicovero.ID) = cmbTipoRicovero.SelectedValue
            Me.Session(mstrPageID & txtCognome.ID) = txtCognome.Text
            Me.Session(mstrPageID & txtNome.ID) = txtNome.Text
        Catch
        End Try
    End Sub

    Private Sub LoadFilterValues()
        Try
            '
            ' Inizializzo la combo dei ricoveri
            '
            Dim sValue As String = CStr(Me.Session(mstrPageID & cmbUnitaOperative.ID) & "")
            If String.IsNullOrEmpty(sValue) Then
                sValue = cmbUnitaOperative.SelectedValue
                Me.Session(mstrPageID & cmbUnitaOperative.ID) = sValue
            End If
            '
            ' Inizializzo gli altri campi di filtro
            '
            cmbStatoEpisodio.SelectedValue = CStr(Me.Session(mstrPageID & cmbStatoEpisodio.ID) & "")
            cmbTipoRicovero.SelectedValue = CStr(Me.Session(mstrPageID & cmbTipoRicovero.ID) & "")
            txtCognome.Text = CType(Me.Session(mstrPageID & txtCognome.ID), String)
            txtNome.Text = CType(Me.Session(mstrPageID & txtNome.ID), String)
        Catch
        End Try

    End Sub

#End Region

    ''' <summary>
    ''' Scatta a seguito di una selezione di un reparto di ricovero da parte dell'utente
    ''' </summary>
    ''' <param name="sender"></param>
    ''' <param name="e"></param>
    ''' <remarks></remarks>
    Private Sub cmbUnitaOperative_SelectedIndexChanged(sender As Object, e As System.EventArgs) Handles cmbUnitaOperative.SelectedIndexChanged
        '
        ' Devo ricaricare la combo dei "tipi di ricovero"/"regimi di ricovero"
        '
        Try
            Dim cmbUnitaOperative As DropDownList = CType(sender, DropDownList)
            Call LoadComboTipoRicovero(cmbUnitaOperative.SelectedValue)
            LoadComboStatoEpisodio()
        Catch ex As Threading.ThreadAbortException
            '
            ' Non faccio niente
            '
        Catch ex As Exception
            Logging.WriteError(ex, Me.GetType.Name)
            ShowAlert("Errore durante l'operazione di caricamento dei tipi di ricovero!")
        End Try
    End Sub

    Private Sub cmbTipoRicovero_SelectedIndexChanged(sender As Object, e As System.EventArgs) Handles cmbTipoRicovero.SelectedIndexChanged
        '
        ' Devo ricaricare la combo Stato Episodio
        '
        Try
            LoadComboStatoEpisodio()
        Catch ex As Threading.ThreadAbortException
            '
            ' Non faccio niente
            '
        Catch ex As Exception
            '
            ' Errore
            '
            Logging.WriteError(ex, Me.GetType.Name)
            ShowAlert("Errore durante l'operazione di caricamento degli stati episodio.")
        End Try
    End Sub

    Private Sub cmdCerca_Click(sender As Object, e As System.EventArgs) Handles cmdCerca.Click
        Try
            Call ShowPazientiReparti()
            cmdCercaValidaSelect = True
        Catch ex As Threading.ThreadAbortException
            '
            ' Non faccio niente
            '
        Catch ex As Exception
            '
            ' Errore
            '
            Logging.WriteError(ex, Me.GetType.Name)
            ShowAlert("Errore durante l'operazione di ricerca dei dati!")
        End Try
    End Sub

    Private Sub ShowPrivacyWarning()
        Try
            Dim sPrivacyWarningText As String = My.Settings.Messaggio_WarningPrivacy
            divPrivacyWarning.Visible = False
            If Not String.IsNullOrEmpty(sPrivacyWarningText) Then
                divPrivacyWarning.Visible = True
                lblPrivacyWarning.Text = sPrivacyWarningText
            End If
        Catch ex As Threading.ThreadAbortException
            '
            ' Non faccio niente
            '
        Catch ex As Exception
            Dim sMsgErr As String = "Errore durante visualizzazione del messaggio della privacy."
            Logging.WriteError(ex, Me.GetType.Name & vbCrLf & sMsgErr)
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

#Region "Funzioni Markup"

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

    Protected Function GetColumnPaziente(objRow As Object) As String
        Dim oRow As WcfDwhClinico.PazienteListaType = CType(objRow, WcfDwhClinico.PazienteListaType)
        Return UserInterface.GetColumnPazienteRicoverato(oRow)
    End Function

    Protected Function GetColumnAnagrafica(objRow As Object) As String
        Dim oRow As WcfDwhClinico.PazienteListaType = CType(objRow, WcfDwhClinico.PazienteListaType)
        Return UserInterface.GetInformazioniAnagrafiche(oRow)
    End Function

    Protected Function GetColumnRicovero(objRow As Object) As String
        Dim oRow As WcfDwhClinico.PazienteListaType = CType(objRow, WcfDwhClinico.PazienteListaType)
        Return UserInterface.GetRicovero(oRow)
    End Function

    Protected Function GetColumnAnteprima(objRow As Object) As String
        Dim oRow As WcfDwhClinico.PazienteListaType = CType(objRow, WcfDwhClinico.PazienteListaType)
        Return UserInterface.GetAnteprima(oRow)
    End Function

    Protected Function GetImgConsenso(objRow As Object) As String
        Dim oRow As WcfDwhClinico.PazienteListaType = CType(objRow, WcfDwhClinico.PazienteListaType)
        Return UserInterface.GetImgConsenso(oRow, Me.Page)
    End Function

    Private Sub btnChiudiAlert_Click(sender As Object, e As EventArgs) Handles btnChiudiAlert.Click
        '
        'Imposto il focus sul bottone.
        '
        cmdCerca.Focus()
    End Sub

#End Region

End Class
