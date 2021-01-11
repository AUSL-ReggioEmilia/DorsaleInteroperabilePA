Imports DwhClinico.Data
Imports DwhClinico.Web
Imports DwhClinico.Web.Utility
'----------------------------------------------------------------------------------------------------------
'
' MODIFICA ETTORE 2013-06-21: la pagina discrimina fra ricoveri/prenotazioni e adatta la UI
'                            create funzioni da usare in parte ASPX per gestire le differenze di visualizzazione
'
'----------------------------------------------------------------------------------------------------------
Partial Class Referti_RefertiListaRicoveroPaziente
    Inherits System.Web.UI.Page

    Dim mIdRicovero As Guid = Nothing
    Dim mIdPaziente As Guid = Nothing
    Dim msNumeroNosologico As String = Nothing
    Dim msAziendaEroganteNosologico As String = Nothing
    '
    ' Memorizza se cancellare l'operazione di select di una Data Source
    '
    Private mbCancelSelectOperation As Boolean = False
    Private Const VS_CURRENT_LNK_VIEW As String = "{41D479DC-EB55-433A-9431-0DE341C2CBAC}"
    Private Const GRID_PAGE_SIZE As Integer = 100
    Private mstrPageID As String
    '
    ' Per discriminare fra Ricovero e Prenotazione
    '
    Private mbIsPrenotazione As Boolean = False

    Private Property DataMinimaFiltro() As DateTime
        Get
            Return CType(ViewState("-DataMinimaFiltro-"), DateTime)
        End Get
        Set(ByVal value As DateTime)
            ViewState("-DataMinimaFiltro-") = value
        End Set
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Dim sErrMsg As String = ""
        Dim sIdPaziente As String = Nothing
        Dim sIdRicovero As String = Nothing
        Try
            '
            ' Id della pagina
            '
            mstrPageID = Me.GetType.Name
            '
            ' Aggiungo lo script per lo stylesheet
            '
            'PageAddCss(Me)
            '
            ' Prelevo parametri dal query string
            '

            sIdRicovero = Me.Request.QueryString(PAR_ID_RICOVERO)
            If Not sIdRicovero Is Nothing AndAlso sIdRicovero.Length > 0 Then
                mIdRicovero = New Guid(sIdRicovero)
            Else
                Throw New Exception("Il parametro '" & PAR_ID_RICOVERO & " ' è obbligatorio")
            End If

            sIdPaziente = Me.Request.QueryString(PAR_ID_PAZIENTE)
            If Not String.IsNullOrEmpty(sIdPaziente) Then
                mIdPaziente = New Guid(sIdPaziente)
            Else
                Throw New Exception("Il parametro '" & PAR_ID_PAZIENTE & "' è obbligatorio")
            End If

            msNumeroNosologico = Me.Request.QueryString(PAR_NUMERO_NOSOLOGICO)
            If String.IsNullOrEmpty(msNumeroNosologico) Then
                Throw New Exception("Il parametro '" & PAR_NUMERO_NOSOLOGICO & "' è obbligatorio")
            End If

            msAziendaEroganteNosologico = Me.Request.QueryString(PAR_AZIENDA_EROGANTE)
            If String.IsNullOrEmpty(msAziendaEroganteNosologico) Then
                Throw New Exception("Il parametro '" & PAR_AZIENDA_EROGANTE & "' è obbligatorio")
            End If
            '
            ' Discrimino fra ricovero/prenotazione
            '
            mbIsPrenotazione = Utility.RicoveroIsPrenotazione(mIdRicovero)

            '
            ' Solo la prima volta
            '
            If Not IsPostBack Then
                '***************************************************************************************
                ' Verifica del consenso ed eventuale data minima di filtro
                ' SacDettaglioPaziente.Session() è stata valorizzata nella pagina del consenso
                '***************************************************************************************
                If Not Utility.VerificaConsenso(mIdPaziente, SacDettaglioPaziente.Session()) Then
                    mbCancelSelectOperation = True
                    Call RedirectToHome()
                    Exit Sub
                End If
                '
                ' Invalido eventualmente la cache
                '
                If Not Session(SESS_INVALIDA_CACHE_LISTA_REFERTI) Is Nothing Then
                    Session(SESS_INVALIDA_CACHE_LISTA_REFERTI) = Nothing
                    Call InvalidaDataSourceCache()
                End If
                '
                ' Inizio determinazione eventuale data filtro minima basata sui consensi
                ' Se sono qui SacDettaglioPaziente.Session() è valorizzata
                '
                If Utility.GetSessionForzaturaConsenso(mIdPaziente) = False Then
                    Dim oDataMinimaFiltro As Date = Utility.GetConsensoDataMinimaDiFiltro(SacDettaglioPaziente.Session())
                    If oDataMinimaFiltro <> Nothing Then
                        divPageTitle.InnerText = String.Format("Elenco referti del paziente da acquisizione Consenso Dossier {0}", oDataMinimaFiltro.ToShortDateString())
                    End If
                    '
                    ' Imposto la property di pagina qualsiasi valore abbia
                    '
                    DataMinimaFiltro = oDataMinimaFiltro
                End If
                '
                ' Se sono un Infermiere devo impostare eventualmente una ulteriore data minima
                '
                If Utility.CheckPermission(RoleManagerUtility.ATTRIB_REFERTI_INFERMIERI_VIEW) Then
                    DataMinimaFiltro = Utility.LimitaDataPerInfermieri(DataMinimaFiltro)
                End If
                '***************************************************************************************
                ' Fine Verifica del consenso ed eventuale data minima di filtro
                '***************************************************************************************
                '
                ' Traccia accessi
                '***************************************************************
                Utility.TracciaAccessiLista("Lista referti", mIdPaziente, SessionHandler.MotivoAccesso, SessionHandler.MotivoAccessoNote)
                '***************************************************************
                ' Fine Traccia accessi
                '***************************************************************
                '
                ' Inizializzazioni della pagina;
                ' visualizzo la modalità d'inserimento della data nel formato corrente
                '
                lblFormatoData.Text = Utility.FormatDateDescription()
                '
                ' Paginazione di default
                '
                WebGridReferti.PageSize = GRID_PAGE_SIZE
                'C1WebGridSistemaErogante.PageSize = GRID_PAGE_SIZE
                'C1WebGridRepartoRichiedente.PageSize = GRID_PAGE_SIZE
                '
                ' Aggiorno la barra di navigazione
                '
                'BarraNavigazione.SetCurrentItem("Referti lista", "")
                '
                ' Visualizzo la testata con i dati del paziente
                '
                Call ShowTestataPaziente(mIdPaziente)
                '
                ' Ricarico i valori di filtrob dalla sessione
                '
                Call LoadFilterValues()
                '
                ' Provo a riposizionare gli indici di pagina originari
                '
                Call SetOldPageIndex()
                '
                ' Seleziono la tab da visualizzare
                '
                Dim olnkView As LinkButton
                Select Case CType(Me.Session(mstrPageID & VS_CURRENT_LNK_VIEW), String)
                    Case lnkReferti.ID
                        olnkView = lnkReferti
                    'Case lnkRepartoRichiedente.ID
                    '    olnkView = lnkRepartoRichiedente
                    'Case lnkSistemaErogante.ID
                    '    olnkView = lnkSistemaErogante
                    Case lnkRisultatoMatrice.ID
                        olnkView = lnkRisultatoMatrice
                    Case Else
                        olnkView = lnkReferti
                End Select
                '
                ' Seleziono la tab ed eseguo ricerca
                '
                Call SelectView(olnkView, Nothing)
                '
                ' Carico i dati dell'episodio
                '
                Call ExecuteSearchTestataEpisodio()
                '
                ' Eseguo la ricerca degli eventi singoli
                '
                Call ExecuteSearchEventiSingoliAll()
            Else
                If Not Utility.VerificaConsenso(mIdPaziente, SacDettaglioPaziente.Session()) Then
                    mbCancelSelectOperation = True
                    Call RedirectToHome()
                    Exit Sub
                End If
            End If

            '
            'RENDERING PER BOOTSTRAP
            'Converte i tag html generati dalla GridView per la paginazione
            ' e li adatta alle necessita dei CSS Bootstrap
            '
            WebGridReferti.PagerStyle.CssClass = "pagination-gridview"
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "gridPagination", HelperGridView.GetScriptPaginationForBootstrap(), True)
            WebGridRefSingoli.PagerStyle.CssClass = "pagination-gridview"
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "gridPagination", HelperGridView.GetScriptPaginationForBootstrap(), True)

        Catch ex As Exception
            alertErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante il caricamento della pagina!"
            Logging.WriteError(ex, Me.GetType.Name)
        End Try

    End Sub

    Protected Sub cmdCerca_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdCerca.Click
        Try
            '
            ' Invalido la cache
            '
            Call InvalidaDataSourceCache()
            'La matrice viene sempre rifatta
            Call ExecuteSearch(True)
            '
            ' Bind della grid visibile
            '
            If MultiViewMain.GetActiveView Is ViewRisultatoMatrice Then
                '
                ' Niente
                '
            ElseIf MultiViewMain.GetActiveView Is ViewReferti Then
                WebGridReferti.DataBind()
                'ElseIf MultiViewMain.GetActiveView Is ViewSistemaErogante Then
                '    C1WebGridSistemaErogante.DataBind()
                'ElseIf MultiViewMain.GetActiveView Is ViewRepartoRichiedente Then
                '    C1WebGridRepartoRichiedente.DataBind()
            End If

            Call ExecuteSearchEventiSingoliAll()
            WebGridRefSingoli.DataBind()

        Catch ex As Exception
            alertErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati!"
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

    Private Sub InvalidaDataSourceCache()
        Dim sCacheKeyDependency As String
        '
        ' Invalido la data source della lista dei referti
        '
        If DataSourceMain.EnableCaching Then
            sCacheKeyDependency = DataSourceMain.CacheKeyDependency
            If Not String.IsNullOrEmpty(sCacheKeyDependency) Then
                HttpContext.Current.Cache(sCacheKeyDependency) = New Object
            End If
        End If
        '
        ' Invalido la data source degli eventi singoli
        '
        If DataSourceEventiSingoli.EnableCaching Then
            sCacheKeyDependency = DataSourceEventiSingoli.CacheKeyDependency
            If Not String.IsNullOrEmpty(sCacheKeyDependency) Then
                HttpContext.Current.Cache(sCacheKeyDependency) = New Object
            End If
        End If
    End Sub

    Protected Sub SelectView(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.CommandEventArgs)
        '
        ' Viene chiamata quando si clicca su pulsanti tab
        '
        Dim olnkView As LinkButton = Nothing
        Try
            olnkView = CType(sender, LinkButton)
            Call _SetSelectedView(olnkView)
            Call ExecuteSearch()
        Catch ex As Exception
            '
            ' Errore
            '
            Logging.WriteError(ex, Me.GetType.Name)
            alertErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante selezione della tab!"
        End Try
    End Sub

    Private Sub _SetSelectedView(ByVal oClickedButton As LinkButton)
        Dim clickedTab As HtmlGenericControl = Nothing
        '
        'Tolgo la classe Bootstrap "active" da tutti i tag
        '
        tabLnkReferti.Attributes.Clear()
        tabLnkRisultatoMatrice.Attributes.Clear()
        'lnkReferti.CssClass = "ReportGroupUnSelectedTab"
        'lnkRepartoRichiedente.CssClass = "ReportGroupUnSelectedTab"
        'lnkSistemaErogante.CssClass = "ReportGroupUnSelectedTab"
        'lnkRisultatoMatrice.CssClass = "ReportGroupUnSelectedTab"

        '
        'Aggiungo la classe Bootstrap "active" al tab selezionato
        '
        clickedTab = oClickedButton.Parent
        clickedTab.Attributes.Add("class", "active")

        Select Case oClickedButton.UniqueID
            Case lnkReferti.UniqueID
                MultiViewMain.SetActiveView(ViewReferti)
            'Case lnkSistemaErogante.UniqueID
            '    MultiViewMain.SetActiveView(ViewSistemaErogante)
            'Case lnkRepartoRichiedente.UniqueID
            '    MultiViewMain.SetActiveView(ViewRepartoRichiedente)
            Case lnkRisultatoMatrice.UniqueID
                MultiViewMain.SetActiveView(ViewRisultatoMatrice)
            Case Else
                Throw New Exception("Non esiste il tab " & oClickedButton.Text)
        End Select
        '
        ' Salvo il pulsante selezionato
        '
        Me.Session(mstrPageID & VS_CURRENT_LNK_VIEW) = oClickedButton.ID
    End Sub

    Private Sub ExecuteSearch(Optional ByVal bReadFromDataSource As Boolean = False)
        '
        ' Eseguo la ricerca: solo se voglio rileggere i dati da DB pongo bReadFromDataSource = True 
        '
        Try
            mbCancelSelectOperation = False

            If ValidateFiltersValue() Then
                If MultiViewMain.GetActiveView Is ViewRisultatoMatrice Then
                    '
                    ' Ricavo i dati per la prestazione a matrice
                    '
                    With DataSourcePrestazioniMatrice
                        .SelectParameters("IdPaziente").DefaultValue = mIdPaziente.ToString
                        .SelectParameters("AziendaErogante").DefaultValue = Nothing 'AziendaErogante dei referti
                        .SelectParameters("SistemaErogante").DefaultValue = Nothing 'SistemaErogante dei referti
                        .SelectParameters("RepartoErogante").DefaultValue = Nothing 'RepartoErogante dei referti
                        .SelectParameters("DataDal").DefaultValue = txtDataDal.Text 'Data del referto 
                        .SelectParameters("NumeroReferto").DefaultValue = txtNumeroReferto.Text
                        .SelectParameters("PrestazioneCodice").DefaultValue = Nothing
                        .SelectParameters("SezioneCodice").DefaultValue = Nothing
                        '-----------------------------------------------------------------------------------------------
                        .SelectParameters("NumeroNosologico").DefaultValue = msNumeroNosologico
                        If String.IsNullOrEmpty(msAziendaEroganteNosologico) Then
                            .SelectParameters("AziendaEroganteNosologico").DefaultValue = Nothing
                        Else
                            .SelectParameters("AziendaEroganteNosologico").DefaultValue = msAziendaEroganteNosologico
                        End If

                    End With
                    Call DataSourcePrestazioniMatrice.Select()

                Else
                    '
                    ' Le successive tab hanno la stessa data source
                    '
                    With DataSourceMain
                        .SelectParameters("IdPaziente").DefaultValue = mIdPaziente.ToString
                        .SelectParameters("AziendaErogante").DefaultValue = Nothing
                        .SelectParameters("SistemaErogante").DefaultValue = Nothing
                        .SelectParameters("RepartoErogante").DefaultValue = Nothing
                        .SelectParameters("DataDal").DefaultValue = txtDataDal.Text
                        .SelectParameters("NumeroReferto").DefaultValue = txtNumeroReferto.Text
                        '------------------------------------------------------------------------------------------------
                        .SelectParameters("NumeroNosologico").DefaultValue = msNumeroNosologico
                        If String.IsNullOrEmpty(msAziendaEroganteNosologico) Then
                            .SelectParameters("AziendaEroganteNosologico").DefaultValue = Nothing
                        Else
                            .SelectParameters("AziendaEroganteNosologico").DefaultValue = msAziendaEroganteNosologico
                        End If

                    End With

                    If MultiViewMain.GetActiveView Is ViewReferti Then
                        DataSourceMain.SelectParameters("Sort").DefaultValue = "DataEventoMeseAnno desc"

                        'ElseIf MultiViewMain.GetActiveView Is ViewSistemaErogante Then
                        '    DataSourceMain.SelectParameters("Sort").DefaultValue = "SistemaErogante"

                        'ElseIf MultiViewMain.GetActiveView Is ViewRepartoRichiedente Then
                        '    DataSourceMain.SelectParameters("Sort").DefaultValue = "RepartoRichiedente"

                    End If
                    '
                    ' Eseguo select solo quando richiesto
                    '
                    If bReadFromDataSource Then DataSourceMain.Select()
                End If
                '
                ' Salvo in sessione i valori di filtro già validati
                '
                Call SaveFilterValues()
            Else
                mbCancelSelectOperation = True
                alertErrorMessage.Visible = True
                lblErrorMessage.Text = "Verificare i valori di filtro!"
            End If

        Catch ex As Exception
            alertErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati!"
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

    Private Sub LoadFilterValues()
        '
        ' Inizializzo DataDal e Numero referto
        '
        txtDataDal.Text = CType(Me.Session(mstrPageID & txtDataDal.ID), String)
        txtNumeroReferto.Text = CType(Me.Session(mstrPageID & txtNumeroReferto.ID), String)
    End Sub

    Private Sub SaveFilterValues()
        Me.Session(mstrPageID & txtDataDal.ID) = txtDataDal.Text
        Me.Session(mstrPageID & txtNumeroReferto.ID) = txtNumeroReferto.Text
    End Sub

    Private Function ValidateFiltersValue() As Boolean
        Dim bValidation As Boolean = True
        Dim odate As DateTime
        Try
            '
            ' Se c'è data minima devo validare la data inserita dall'utente con la data minima 
            ' Al page load come data di filtro iniziale al limeite devo mettere la data minima
            ' Eventualmente modifica la data txtDataDal.text
            '
            If Utility.GetSessionForzaturaConsenso(mIdPaziente) = False Then
                '
                ' se non ho forzato il consenso imposto data minima
                '
                Dim dFiltroDataDal As Nullable(Of Date) = Nothing
                If Not String.IsNullOrEmpty(txtDataDal.Text) Then
                    dFiltroDataDal = Date.Parse(txtDataDal.Text)
                End If
                dFiltroDataDal = Utility.LimitaDataByDataMinima(dFiltroDataDal, DataMinimaFiltro)
                If dFiltroDataDal.HasValue Then
                    txtDataDal.Text = dFiltroDataDal.Value.ToShortDateString()
                End If
            End If
            '
            ' Controllo sempre il dato presente nel filtro
            '
            If txtDataDal.Text.Length > 0 Then
                If Not Date.TryParse(txtDataDal.Text, odate) Then
                    bValidation = False
                End If
            End If

        Catch ex As Exception
            alertErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'operazione di validazione dei filtri!"
            Logging.WriteWarning("Errore durante l'operazione di validazione dei filtri!" & vbCrLf & Utility.FormatException(ex))
            bValidation = False
        End Try
        Return bValidation
    End Function

    Private Sub ExecuteSearchTestataEpisodio()
        '
        ' Eseguo la ricerca: solo se voglio rileggere i dati da DB pongo bReadFromDataSource = True 
        '
        Try
            With DataSourceTestataEpisodio
                .SelectParameters("IdRicovero").DefaultValue = mIdRicovero.ToString
            End With

        Catch ex As Exception
            alertErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati!"
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

#Region "Eventi objectDataSource"

#Region "DataSourceMain"

    Protected Sub DataSourceMain_Selected(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles DataSourceMain.Selected
        Try
            If e.Exception IsNot Nothing Then
                '
                ' Errore
                '
                Logging.WriteError(e.Exception, Me.GetType.Name)
                alertErrorMessage.Visible = True
                lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati!"
                e.ExceptionHandled = True

            ElseIf e.ReturnValue Is Nothing OrElse CType(e.ReturnValue, DataView).Count = 0 Then
                lblNoRecordFound.Text = "Non è stato trovato nessun referto"

                'WebGridAnnoMese.PagerStyle.Visible = False
                'C1WebGridSistemaErogante.PagerStyle.Visible = False
                'C1WebGridRepartoRichiedente.PagerStyle.Visible = False

            Else
                lblNoRecordFound.Text = ""

                Dim bPagerStyleVisible As Boolean = True

                With WebGridReferti
                    '.PagerStyle.Visible = bPagerStyleVisible
                    .PageIndex = AdjustCurrentIndex(CType(e.ReturnValue, DataView).Count, .PageSize, .PageIndex)
                    Me.Session(mstrPageID & .ID) = .PageIndex
                End With
                'With C1WebGridSistemaErogante
                '    .PagerStyle.Visible = bPagerStyleVisible
                '    .CurrentPageIndex = AdjustCurrentIndex(CType(e.ReturnValue, DataView).Count, .PageSize, .CurrentPageIndex)
                '    Me.Session(mstrPageID & .ID) = .CurrentPageIndex
                'End With
                'With C1WebGridRepartoRichiedente
                '    .PagerStyle.Visible = bPagerStyleVisible
                '    .CurrentPageIndex = AdjustCurrentIndex(CType(e.ReturnValue, DataView).Count, .PageSize, .CurrentPageIndex)
                '    Me.Session(mstrPageID & .ID) = .CurrentPageIndex
                'End With
            End If

        Catch ex As Exception
            '
            ' Errore
            '
            Logging.WriteError(ex, Me.GetType.Name)
            alertErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati!"
        End Try
    End Sub

    Protected Sub DataSourceMain_Selecting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.ObjectDataSourceSelectingEventArgs) Handles DataSourceMain.Selecting
        Try
            If mbCancelSelectOperation = True Then
                e.Cancel = True
            End If
        Catch ex As Exception
            alertErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati!"
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

#End Region

#Region "DataSourceEventiSingoli"

    Protected Sub DataSourceEventiSingoli_Selected(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles DataSourceEventiSingoli.Selected
        Try
            If e.Exception IsNot Nothing Then
                '
                ' Errore
                '
                Logging.WriteError(e.Exception, Me.GetType.Name)
                alertErrorMessage.Visible = True
                lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati 'Eventi singoli'!"
                e.ExceptionHandled = True

            ElseIf e.ReturnValue Is Nothing OrElse CType(e.ReturnValue, DataTable).Rows.Count = 0 Then
                '
                ' Gestione in testata (nuova)
                '
                divEventiSingoli.Visible = False
            Else
                '
                ' Gestione in testata (nuova)
                '
                divEventiSingoli.Visible = True
            End If

        Catch ex As Exception
            '
            ' Errore
            '
            Logging.WriteError(ex, Me.GetType.Name)
            alertErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati 'Eventi singoli'!"
        End Try
    End Sub

    Protected Sub DataSourceEventiSingoli_Selecting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.ObjectDataSourceSelectingEventArgs) Handles DataSourceEventiSingoli.Selecting
        Try
            If mbCancelSelectOperation = True Then
                e.Cancel = True
            End If
        Catch ex As Exception
            alertErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati 'Eventi Singoli'!"
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

#End Region

#Region "DataSourcePrestazioniMatrice"

    Protected Sub DataSourcePrestazioniMatrice_Selected(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles DataSourcePrestazioniMatrice.Selected
        Try
            If e.Exception IsNot Nothing Then
                '
                ' Errore
                '
                Logging.WriteError(e.Exception, Me.GetType.Name)
                alertErrorMessage.Visible = True
                lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati Prestazioni a Matrice!"
                e.ExceptionHandled = True

            ElseIf e.ReturnValue Is Nothing OrElse CType(e.ReturnValue, DataTable).Rows.Count = 0 Then
                lblPrestazioniMatrice.Text = "Non è stato trovato nessun record"

            Else 'If Not e.ReturnValue Is Nothing Then
                '
                ' La stored procedure restituiva sempre una riga (la prima riga serviva a creare il messaggio "no record")
                ' Ora la prima riga verrà tolta
                '
                lblPrestazioniMatrice.Text = ""
                Dim oDt As DataTable = CType(e.ReturnValue, DataTable)
                Using oDataset As New DataSet
                    Dim sXML As String
                    '
                    ' Attenzione: modifico il nome del dataset e della datatable per adattarli
                    ' alle query xpath usate nella trasformazione XSLT
                    '
                    oDataset.Namespace = ""
                    oDataset.DataSetName = "Table"
                    oDt.TableName = "Row"
                    oDataset.Tables.Add(oDt)
                    sXML = oDataset.GetXml
                    XmlRisultatoMatrice.DocumentContent = sXML
                    XmlRisultatoMatrice.DataBind()
                End Using
            End If

        Catch ex As Exception
            '
            ' Errore
            '
            Logging.WriteError(ex, Me.GetType.Name)
            alertErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati Prestazioni a Matrice!"
        End Try
    End Sub

    Protected Sub DataSourcePrestazioniMatrice_Selecting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.ObjectDataSourceSelectingEventArgs) Handles DataSourcePrestazioniMatrice.Selecting
        Try
            If mbCancelSelectOperation = True Then
                e.Cancel = True
            End If
        Catch ex As Exception
            alertErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati Prestazioni a Matrice!"
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

#End Region

#Region "DataSourceTestataEpisodio"

    Protected Sub DataSourceTestataEpisodio_Selected(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles DataSourceTestataEpisodio.Selected
        Try
            If e.Exception IsNot Nothing Then
                '
                ' Errore
                '
                Logging.WriteError(e.Exception, Me.GetType.Name)
                alertErrorMessage.Visible = True
                lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati della testata dell'episodio!"
                e.ExceptionHandled = True

            ElseIf e.ReturnValue Is Nothing OrElse CType(e.ReturnValue, DataTable).Rows.Count = 0 Then
                lblNoRecordFound.Text = "Non è stato trovata la testata dell'episodio!"
            Else
                lblNoRecordFound.Text = ""
            End If

        Catch ex As Exception
            '
            ' Errore
            '
            Logging.WriteError(ex, Me.GetType.Name)
            alertErrorMessage.Visible = True
            lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati!"
        End Try
    End Sub

#End Region

#End Region

#Region "Funzioni usate nella parte aspx"

    Protected Function GetDataOraEvento(ByVal oDataEvento As Object) As String
        Dim sRet As String = ""
        If Not oDataEvento Is DBNull.Value Then
            sRet = Format(oDataEvento, "g")
        End If
        '
        '
        '
        Return sRet
    End Function

    Protected Function GetUrlLinkReferto(ByVal oIdreferto As Object) As String
        Return Me.ResolveUrl(String.Format("~/Referti/RefertiDettaglio.aspx?IdReferto={0}", oIdreferto.ToString))
    End Function

    Protected Function GetStatoImageUrl(ByVal oStato As Object) As String
        Return Me.ResolveUrl(String.Format("~/Images/Referti/StatoRichiesta_{0}.gif", oStato))
    End Function

    Protected Function CheckDeleteRefertiPermission(ByVal sAziendaErogante As String, ByVal sSistemaErogante As String, ByVal sRepartoErogante As String) As Boolean
        Return VerificaPermessiCancellazioneReferto(sAziendaErogante, sSistemaErogante, sRepartoErogante)
    End Function

    Protected Function BuildEroganteDescrizione(oRepartoErogante As Object, oSpecialitaErogante As Object, oAziendaErogante As Object) As String
        Return Utility.BuildEroganteDescrizione(oRepartoErogante, oSpecialitaErogante, oAziendaErogante)
    End Function


#Region "Funzioni per aggiornare UI in base a ricovero/prenotazione"

    Protected Function GetTitoloSezioneEpisodio() As String
        Dim sRet As String = "Episodio"
        If mbIsPrenotazione Then
            sRet = "Prenotazione"
        End If
        Return sRet
    End Function

    Protected Function GetNumeroNosologicoEtichetta() As String
        Dim sRet As String = "Nosologico"
        If mbIsPrenotazione Then
            sRet = "Codice prenotazione"
        End If
        Return sRet
    End Function

    Protected Function GetRepartoEtichettaVisible() As String
        ' Visibile se non è una prenotazione
        Return Not mbIsPrenotazione
    End Function

#End Region


#End Region

    Private Function AdjustCurrentIndex(ByVal nRow As Integer, ByVal iPageSize As Integer, ByVal iCurrentPageIndex As Integer) As Integer
        Dim iMaxpage As Integer = nRow \ iPageSize
        If (iMaxpage * iPageSize) < nRow Then iMaxpage = iMaxpage + 1

        Dim iMaxPageIndex As Integer = iMaxpage - 1
        If iMaxPageIndex < 0 Then iMaxPageIndex = 0
        If iMaxPageIndex < iCurrentPageIndex Then
            Return iMaxPageIndex
        Else
            Return iCurrentPageIndex
        End If
    End Function

    Private Sub ShowTestataPaziente(ByVal IDPaziente As Guid)
        Using oDataset As New PazientiDataset
            Using oDataPaziente As New Pazienti
                oDataPaziente.Testata(oDataset.FevsPazientiTestata, IDPaziente)
            End Using
            '
            ' Inizializzo
            '
            lblNomeCognome.Text = ""
            lblLuogoNascita.Text = ""
            lblDataNascita.Text = ""
            lblCodiceFiscale.Text = ""
            lblCodiceSanitario.Text = ""
            lblDataDecessoValue.Text = ""
            '
            ' Visualizzo i dati del paziente
            '
            If oDataset.FevsPazientiTestata.Rows.Count > 0 Then
                With oDataset.FevsPazientiTestata(0)

                    Dim sNome As String = ""
                    Dim sCognome As String = ""
                    If Not .IsNomeNull Then sNome = .Nome
                    If Not .IsCognomeNull Then sCognome = .Cognome
                    lblNomeCognome.Text = Trim(sNome & " " & sCognome)

                    If Not .IsLuogoNascitaNull Then lblLuogoNascita.Text = .LuogoNascita
                    If Not .IsDataNascitaNull Then lblDataNascita.Text = .DataNascita.ToShortDateString

                    If Not .IsCodiceFiscaleNull Then lblCodiceFiscale.Text = .CodiceFiscale

                    If Not .IsCodiceSanitarioNull Then lblCodiceSanitario.Text = .CodiceSanitario

                    lblDataDecesso.Visible = True
                    If (Not .IsDecedutoNull) AndAlso (.Deceduto = True) Then
                        If Not .IsDataDecessoNull Then
                            lblDataDecessoValue.Text = .DataDecesso.ToShortDateString
                        End If
                    Else
                        lblDataDecesso.Visible = False 'non visualizzo la label con l'etichetta
                    End If

                End With

            End If
        End Using

    End Sub


    Private Function FindColumn(ByVal oGrid As C1.Web.C1WebGrid.C1WebGrid, ByVal sColumnName As String) As C1.Web.C1WebGrid.C1BaseColumn
        sColumnName = sColumnName.ToUpper
        For i As Integer = 0 To oGrid.Columns.Count - 1
            If oGrid.Columns(i).HeaderText.ToUpper = sColumnName Then
                Return oGrid.Columns(i)
            End If
        Next
        Return Nothing
    End Function

    Private Sub SetOldPageIndex()
        Try
            Dim oCurrentPageIndex As Object
            oCurrentPageIndex = Me.Session(mstrPageID & WebGridReferti.ID)
            If Not oCurrentPageIndex Is Nothing Then WebGridReferti.PageIndex = CType(oCurrentPageIndex, Integer)

            'oCurrentPageIndex = Me.Session(mstrPageID & C1WebGridSistemaErogante.ID)
            'If Not oCurrentPageIndex Is Nothing Then C1WebGridSistemaErogante.CurrentPageIndex = CType(oCurrentPageIndex, Integer)

            'oCurrentPageIndex = Me.Session(mstrPageID & C1WebGridRepartoRichiedente.ID)
            'If Not oCurrentPageIndex Is Nothing Then C1WebGridRepartoRichiedente.CurrentPageIndex = CType(oCurrentPageIndex, Integer)
        Catch
        End Try
    End Sub

    Private Sub ExecuteSearchEventiSingoliAll()
        '
        ' Cerco tutti gli eventi singoli di un paziente
        '
        With DataSourceEventiSingoli
            .SelectParameters("IdPaziente").DefaultValue = mIdPaziente.ToString
            .SelectParameters("NumeroNosologico").DefaultValue = Nothing
            .SelectParameters("DataDal").DefaultValue = txtDataDal.Text
        End With
    End Sub

    Private Sub ShowAll(ByVal bVisible As Boolean)
        divTestataPaziente.Visible = bVisible
        divFiltersContainer.Visible = bVisible
        divReportContainer.Visible = bVisible
    End Sub

    Private Sub RedirectToHome()
        Response.Redirect(Me.ResolveUrl("~/Default.aspx"), False)
    End Sub

    Private Sub WebGridRefSingoli_PreRender(sender As Object, e As EventArgs) Handles WebGridRefSingoli.PreRender
        '
        'Render per Bootstrap
        'Crea la Table con Theader e Tbody se l'header non è nothing.
        '
        If Not WebGridRefSingoli.HeaderRow Is Nothing Then
            WebGridRefSingoli.UseAccessibleHeader = True
            WebGridRefSingoli.HeaderRow.TableSection = TableRowSection.TableHeader
        End If
    End Sub
End Class




