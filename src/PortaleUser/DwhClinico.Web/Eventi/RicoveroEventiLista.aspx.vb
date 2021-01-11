Imports DwhClinico.Data
Imports DwhClinico.Web
Imports DwhClinico.Web.Utility

Partial Class Eventi_RicoveroEventiLista
    Inherits System.Web.UI.Page

    '
    ' L'Id del paziente di cui si deve mostrare la lista dei referti
    '
    Dim mIdPaziente As Guid = Nothing
    Dim mIdRicovero As Guid = Nothing
    '
    ' Memorizza se cancellare l'operazione di select di una Data Source
    '
    Private mbCancelSelectOperation As Boolean = False
    Private Const GRID_PAGE_SIZE As Integer = 100
    Private mstrPageID As String
    Private mbGoToNextPage As Boolean = True

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
                Throw New Exception("Il parametro '" & PAR_ID_RICOVERO & "' è obbligatorio")
            End If

            sIdPaziente = Me.Request.QueryString(PAR_ID_PAZIENTE)
            If Not sIdPaziente Is Nothing AndAlso sIdPaziente.Length > 0 Then
                mIdPaziente = New Guid(sIdPaziente)
            Else
                Throw New Exception("Il parametro '" & PAR_ID_PAZIENTE & "' è obbligatorio")
            End If
            '
            ' Determino se devo navigare automaticamente alla pagina successiva
            '
            Dim sNextPage As String = Me.Request.QueryString("nextpage") & ""
            If sNextPage.ToUpper = "FALSE" Then
                mbGoToNextPage = False
            End If
            '
            ' Solo la prima volta
            '
            If Not IsPostBack Then
                '*************************************************************************************
                ' Verifica del consenso ed eventuale data minima di filtro
                ' SacDettaglioPaziente.Session() è stata valorizzata nella pagina del consenso
                '*************************************************************************************
                If Not Utility.VerificaConsenso(mIdPaziente, SacDettaglioPaziente.Session()) Then
                    mbCancelSelectOperation = True
                    'lblErrorMessage.Text = sErrMsg
                    'lblErrorMessage.Visible = True
                    'Call ShowAll(False)
                    Call RedirectToHome()
                    Exit Sub
                End If
                '
                ' Inizializzazioni della pagina;
                ' visualizzo la modalità d'inserimento della data nel formato corrente
                '
                lblFormatoData.Text = Utility.FormatDateDescription()
                '
                ' Inizio determinazione eventuale data filtro minima basata sui consensi
                ' Se sono qui SacDettaglioPaziente.Session() è valorizzata
                '
                If Utility.GetSessionForzaturaConsenso(mIdPaziente) = False Then
                    Dim oDataMinimaFiltro As Date = Utility.GetConsensoDataMinimaDiFiltro(SacDettaglioPaziente.Session())
                    If oDataMinimaFiltro <> Nothing Then
                        divPageTitle.InnerText = String.Format("Elenco eventi del paziente da acquisizione Consenso Dossier {0}", oDataMinimaFiltro.ToShortDateString())
                    End If
                    '
                    ' Imposto la property di pagina qualsiasi valore abbia
                    '
                    DataMinimaFiltro = oDataMinimaFiltro
                End If
                '*************************************************************************************
                ' Fine Verifica del consenso ed eventuale data minima di filtro
                '*************************************************************************************
                '
                ' Traccia accessi
                '
                'Il dettaglio di un ricovero equivale alla lista dei suoi eventi
                Utility.TracciaAccessiRicovero("Lista eventi ricovero", mIdPaziente, mIdRicovero, SessionHandler.MotivoAccesso, SessionHandler.MotivoAccessoNote)
                '
                ' Paginazione di default
                '
                WebGridEventi.PageSize = GRID_PAGE_SIZE
                '
                ' Visualizzo la testata con i dati del paziente
                ' Questi dati li devo prendere dal record di accettazione del ricovero selezionato
                '
                Call ShowTestataPaziente(mIdRicovero)
                '
                ' Ricarico i valori di filtrob dalla sessione
                '
                Call LoadFilterValues()
                '
                ' Provo a riposizionare gli indici di pagina originari
                '
                Call SetOldPageIndex()
                '
                ' Eseguo la prima visualizzazione
                '
                Call ExecuteSearch()
                '
                ' Visualizzo le informazioni di ricovero
                '
                Dim sXml As String = GetXmlTestataRicovero(mIdRicovero)
                Call ShowTestataRicovero(sXml)
                '
                ' Aggiorno la barra di navigazione
                '
                Dim sUrl As String = String.Format("~/Eventi/RicoveroEventiLista.aspx?{0}={1}&{2}={3}&{4}={5}", PAR_ID_PAZIENTE, mIdPaziente.ToString, PAR_ID_RICOVERO, mIdRicovero.ToString, "nextpage", "false")
                'BarraNavigazione.SetCurrentItem("Eventi lista", Me.ResolveUrl(sUrl))
            Else
                If Not Utility.VerificaConsenso(mIdPaziente, SacDettaglioPaziente.Session()) Then
                    mbCancelSelectOperation = True
                    Call RedirectToHome()
                    Exit Sub
                End If
                '
                ' Visualizzo le informazioni di ricovero
                '
                Dim sXml As String = GetXmlTestataRicovero(mIdRicovero)
                Call ShowTestataRicovero(sXml)
            End If

            '
            'RENDERING PER BOOTSTRAP
            'Converte i tag html generati dalla GridView per la paginazione
            ' e li adatta alle necessita dei CSS Bootstrap
            '
            WebGridEventi.PagerStyle.CssClass = "pagination-gridview"
            ScriptManager.RegisterStartupScript(Page, Page.GetType(), "gridPagination", HelperGridView.GetScriptPaginationForBootstrap(), True)

        Catch ex As Exception
            lblErrorMessage.Text = "Errore durante il caricamento della pagina!"
            alertErrorMessage.Visible = True
            Logging.WriteError(ex, Me.GetType.Name)
        End Try

    End Sub

    Protected Sub cmdCerca_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdCerca.Click
        Try
            '
            ' Invalido la cache
            '
            HttpContext.Current.Cache("CKD_DataSourceMain") = New Object
            Call ExecuteSearch(True)
            '
            ' Bind della grid 
            '
            WebGridEventi.DataBind()

        Catch ex As Exception
            lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati!"
            alertErrorMessage.Visible = True
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

    Private Sub ExecuteSearch(Optional ByVal bReadFromDataSource As Boolean = False)
        '
        ' Eseguo la ricerca: solo se voglio rileggere i dati da DB pongo bReadFromDataSource = True 
        '
        Try
            mbCancelSelectOperation = False
            If ValidateFiltersValue() Then
                With DataSourceMain
                    .SelectParameters("IdRicovero").DefaultValue = mIdRicovero.ToString
                    .SelectParameters("DataEventoDal").DefaultValue = txtDataDal.Text
                End With
                '
                ' Eseguo select solo quando richiesto
                '
                If bReadFromDataSource Then DataSourceMain.Select()
                '
                ' Salvo in sessione i valori di filtro già validati
                '
                Call SaveFilterValues()

            Else
                mbCancelSelectOperation = True
                lblErrorMessage.Text = "Verificare i valori di filtro!"
                alertErrorMessage.Visible = True
            End If

        Catch ex As Exception
            lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati!"
            alertErrorMessage.Visible = True
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

    Private Sub LoadFilterValues()
        Dim sIdRicovero As String = mIdRicovero.ToString.ToUpper
        txtDataDal.Text = Me.Session(mstrPageID & txtDataDal.ID & sIdRicovero)
    End Sub

    Private Sub SaveFilterValues()
        Dim sIdRicovero As String = mIdRicovero.ToString.ToUpper
        Me.Session(mstrPageID & txtDataDal.ID & sIdRicovero) = txtDataDal.Text
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
                lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati!"
                alertErrorMessage.Visible = True
                e.ExceptionHandled = True

            ElseIf e.ReturnValue Is Nothing OrElse CType(e.ReturnValue, DataTable).Rows.Count = 0 Then
                lblNoRecordFound.Text = "Non è stato trovato nessun evento relativo al ricovero"
                'WebGridEventi.PagerStyle.Visible = False

            Else
                'Dim dtRicoveroEventi As RicoveriDataSet.FevsRicoveroPazienteEventiListaDataTable = CType(e.ReturnValue, RicoveriDataSet.FevsRicoveroPazienteEventiListaDataTable)
                'If mbGoToNextPage AndAlso dtRicoveroEventi.Rows.Count = 1 Then
                '    '
                '    ' Ho un solo evento: navigo al dettaglio 
                '    '
                '    Dim oIdRicovero As Guid = dtRicoveroEventi(0).IdRicovero
                '    Dim oIdPaziente As Guid = dtRicoveroEventi(0).IdPaziente
                '    Dim oIdEvento As Guid = dtRicoveroEventi(0).Id
                '    Dim sUrl As String = GetUrlLinkEventoDettaglio(oIdPaziente, oIdRicovero, oIdEvento)
                '    Call Response.Redirect(Me.ResolveUrl(sUrl))
                'Else
                '    lblNoRecordFound.Text = ""
                '    With C1WebGridEventi
                '        .PagerStyle.Visible = True
                '        .CurrentPageIndex = AdjustCurrentIndex(CType(e.ReturnValue, DataTable).Rows.Count, .PageSize, .CurrentPageIndex)
                '        Me.Session(mstrPageID & .ID) = .CurrentPageIndex
                '    End With
                'End If
                lblNoRecordFound.Text = ""
                With WebGridEventi
                    '.PagerStyle.Visible = True
                    .PageIndex = AdjustCurrentIndex(CType(e.ReturnValue, DataTable).Rows.Count, .PageSize, .PageIndex)
                    Me.Session(mstrPageID & .ID) = .PageIndex
                End With

            End If

        Catch ex As Threading.ThreadAbortException
            '
            ' Non faccio nulla
            '
        Catch ex As Exception
            '
            ' Errore
            '
            Logging.WriteError(ex, Me.GetType.Name)
            lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati!"
            alertErrorMessage.Visible = True
        End Try
    End Sub

    Protected Sub DataSourceMain_Selecting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.ObjectDataSourceSelectingEventArgs) Handles DataSourceMain.Selecting
        Try
            If mbCancelSelectOperation = True Then
                e.Cancel = True
            End If
        Catch ex As Exception
            lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati!"
            alertErrorMessage.Visible = True
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

#End Region

#End Region

#Region "Funzioni usate nella parte aspx"
    ''' <summary>
    ''' Fornisce URL al dettaglio discriminando iltipo di record (Prenotazione/Evento ADT)
    ''' </summary>
    ''' <param name="oNumeroNosologico"></param>
    ''' <param name="oIdPaziente"></param>
    ''' <param name="oIdRicovero"></param>
    ''' <param name="oIdEvento"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Protected Function GetUrlDettaglio(ByVal oNumeroNosologico As Object, ByVal oIdPaziente As Object, ByVal oIdRicovero As Object, ByVal oIdEvento As Object) As String
        Dim sRet As String = String.Empty
        If Utility.RicoveroIsPrenotazione(oIdRicovero) Then
            'Lista attesa/prenotazione
            sRet = GetUrlDettaglioPrenotazione(oIdRicovero)
        Else
            sRet = GetUrlLinkEventoDettaglio(oIdPaziente, oIdRicovero, oIdEvento)
        End If
        Return sRet
    End Function
    ''' <summary>
    ''' Per gestione riga "prenotazione"
    ''' </summary>
    ''' <param name="oIdRicovero">Id della tabella RicoveriBase relativo alla prenotazione</param>
    ''' <returns>url al dettaglio di una prenotazione</returns>
    ''' <remarks></remarks>
    Private Function GetUrlDettaglioPrenotazione(ByVal oIdRicovero As Object) As String
        Dim sRet As String = ""
        If Not oIdRicovero Is DBNull.Value Then
            sRet = Me.ResolveUrl("~/Eventi/PrenotazioneDettaglio.aspx") & _
                                    String.Format("?{0}={1}&{2}={3}", _
                                                PAR_ID_RICOVERO, oIdRicovero.ToString, _
                                                PAR_ID_PAZIENTE, mIdPaziente.ToString)
            If mbGoToNextPage = False Then
                sRet = sRet & "&nextpage=false"
            End If
        End If
        '
        '
        '
        Return sRet
    End Function


    Protected Function GetCodiceDescrizione(ByVal oCodice As Object, ByVal oDescrizione As Object) As String
        Dim sRet As String = ""
        Dim sCodice As String = ""
        Dim sDescrizione As String = ""

        If Not oCodice Is DBNull.Value Then
            sCodice = oCodice.ToString
        End If
        If Not oDescrizione Is DBNull.Value Then
            sDescrizione = oDescrizione.ToString
        End If

        If sCodice.Length > 0 AndAlso sDescrizione.Length > 0 Then
            sRet = sDescrizione & " - (" & sCodice & ")"
        ElseIf sCodice.Length > 0 Then
            sRet = "(" & sCodice & ")"
        ElseIf sDescrizione.Length > 0 Then
            sRet = sDescrizione
        End If

        Return sRet
    End Function


    Private Function GetUrlLinkEventoDettaglio(ByVal oIdPaziente As Object, ByVal oIdRicovero As Object, ByVal oIdEvento As Object) As String
        Dim sUrl As String = ""
        If (Not oIdPaziente Is DBNull.Value) AndAlso _
            (Not oIdRicovero Is DBNull.Value) AndAlso _
             (Not oIdEvento Is DBNull.Value) Then
            sUrl = Me.ResolveUrl("~/Eventi/RicoveroEventoDettaglio.aspx") & _
                                    String.Format("?{0}={1}&{2}={3}&{4}={5}", _
                                                PAR_ID_RICOVERO, oIdRicovero.ToString, _
                                                PAR_ID_EVENTO, oIdEvento.ToString, _
                                                PAR_ID_PAZIENTE, oIdPaziente.ToString)

        End If
        Return sUrl
    End Function


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

    Protected Function GetUrlLinkReferti(ByVal oIdPaziente As Object, ByVal oAziendaErogante As Object, ByVal oNumeroNosologico As Object) As String
        Dim sRet As String = ""
        If (Not oIdPaziente Is DBNull.Value) AndAlso _
                  (Not oAziendaErogante Is DBNull.Value) AndAlso _
                (Not oNumeroNosologico Is DBNull.Value) Then
            sRet = Me.ResolveUrl("~/Referti/RefertiListaRicoveroPaziente.aspx") & _
                                    String.Format("?{0}={1}&{2}={3}&{4}={5}&{6}={7}", _
                                                PAR_ID_RICOVERO, mIdRicovero.ToString, _
                                                PAR_ID_PAZIENTE, oIdPaziente.ToString, _
                                                PAR_NUMERO_NOSOLOGICO, oNumeroNosologico.ToString, _
                                                PAR_AZIENDA_EROGANTE, oAziendaErogante.ToString)
        End If
        '
        '
        '
        Return sRet
    End Function

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

    Private Sub ShowTestataPaziente(ByVal IdRicovero As Guid)
        '
        ' Devo visualizzare i dati del paziente prelevandoli dal record di accettazione 
        ' dell'episodio composto dalla lista di eventi visualizzati
        '
        Dim ta As RicoveriDataSet.FevsRicoveroTestataPazienteDataTable = Nothing
        Try
            '
            ' Inizializzo
            '
            lblNomeCognome.Text = ""
            lblLuogoNascita.Text = ""
            lblDataNascita.Text = ""
            lblCodiceFiscale.Text = ""
            lblCodiceSanitario.Text = ""
            lblDataDecessoValue.Text = ""
            lblDataDecesso.Visible = False
            Using oData As New Ricoveri
                ta = oData.RicoveroTestataPaziente(IdRicovero)
                If Not ta Is Nothing AndAlso ta.Count > 0 Then
                    With ta(0)

                        Dim sNome As String = ""
                        Dim sCognome As String = ""
                        If Not .IsNomeNull Then sNome = .Nome
                        If Not .IsCognomeNull Then sCognome = .Cognome
                        lblNomeCognome.Text = Trim(sNome & " " & sCognome)

                        If Not .IsComuneNascitaNull Then lblLuogoNascita.Text = .ComuneNascita
                        If Not .IsDataNascitaNull Then lblDataNascita.Text = .DataNascita.ToShortDateString
                        If Not .IsCodiceFiscaleNull Then lblCodiceFiscale.Text = .CodiceFiscale
                        If Not .IsCodiceSanitarioNull Then lblCodiceSanitario.Text = .CodiceSanitario
                    End With
                End If
            End Using
        Catch ex As Exception
            Throw ex
        Finally
            If Not ta Is Nothing Then
                ta.Dispose()
            End If
        End Try
    End Sub

    Private Sub SetOldPageIndex()
        Try
            Dim oCurrentPageIndex As Object
            oCurrentPageIndex = Me.Session(mstrPageID & WebGridEventi.ID)
            If Not oCurrentPageIndex Is Nothing Then WebGridEventi.PageIndex = CType(oCurrentPageIndex, Integer)
        Catch
        End Try
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
            lblErrorMessage.Text = "Errore durante l'operazione di validazione dei filtri!"
            alertErrorMessage.Visible = True
            Logging.WriteWarning("Errore durante l'operazione di validazione dei filtri!" & vbCrLf & Utility.FormatException(ex))
            bValidation = False
        End Try
        Return bValidation
    End Function

#Region "Testata Episodio"

    Private Function GetXmlTestataRicovero(ByVal IdRicovero As Guid) As String
        Try
            Using oRicoveri As New Ricoveri
                Using oDataSet As New RicoveriDataSet
                    '
                    ' Leggo i vecchi dati della testata del ricovero
                    '
                    Dim oTaTestata As RicoveriDataSet.FevsRicoveroTestataDataTable = oRicoveri.RicoveroTestata(IdRicovero)
                    If Not oTaTestata Is Nothing AndAlso oTaTestata.Rows.Count > 0 Then
                        oDataSet.Tables.Add(oTaTestata)
                    End If
                    '
                    ' Leggo i nuovi dati "Info di ricovero": non tutti i ricoveri hanno queste informazioni
                    '
                    Dim oTaInfo As RicoveriDataSet.FevsRicoveroInfoRicoveroDataTable = oRicoveri.GetRicoveroInfoRicovero(IdRicovero)
                    If Not oTaInfo Is Nothing AndAlso oTaInfo.Rows.Count > 0 Then
                        oDataSet.Tables.Add(oTaInfo)
                    Else
                        'creo la data table alvolo
                        oTaInfo = New RicoveriDataSet.FevsRicoveroInfoRicoveroDataTable()
                    End If
                    '
                    ' Aggiungo una riga alla datatatable oTaInfo (Nome,Valore) per passare l'url ai referti del nosologico
                    ' valore è un VARCHAR(8000), quindi non ho problemi di spazio
                    '
                    Dim sAziendaErogante As String = oTaTestata(0).AziendaErogante
                    Dim sNumeroNosologico As String = oTaTestata(0).NumeroNosologico
                    oTaInfo.AddFevsRicoveroInfoRicoveroRow("UrlLinkReferti", GetUrlLinkReferti(mIdPaziente, sAziendaErogante, sNumeroNosologico))
                    '
                    ' Aggiusto qualche nome, per non dovere usare il namespace manager
                    '
                    oDataSet.Namespace = ""
                    '
                    ' Salvo l'XML in sessione Prelevo l'XML 
                    '
                    Return oDataSet.GetXml
                End Using
            End Using
        Catch ex As Exception
            Logging.WriteError(ex, "GetXmlTestataRicovero: Si è verificato un errore durante la lettura delle info di ricovero.")
            Throw
        End Try
    End Function

    Private Sub ShowTestataRicovero(ByVal sXml As String)
        Try
            '
            ' Eseguo la trasformazione XSLT
            '
            XmlInfoRicovero.DocumentContent = sXml
            XmlInfoRicovero.DataBind()
        Catch ex As Exception
            Logging.WriteError(ex, "ShowTestataRicovero: Si è verificato un errore durante la visualizzazione delle info di ricovero.")
            Throw
        End Try
    End Sub

#End Region

    Private Sub ShowAll(ByVal bVisible As Boolean)
        divTestataPaziente.Visible = bVisible
        divFiltersContainer.Visible = bVisible
        divReportContainer.Visible = bVisible
    End Sub

    Private Sub RedirectToHome()
        Response.Redirect(Me.ResolveUrl("~/Default.aspx"), False)
    End Sub

    Private Sub WebGridEventi_PreRender(sender As Object, e As EventArgs) Handles WebGridEventi.PreRender
        '
        'Render per Bootstrap
        'Crea la Table con Theader e Tbody se l'header non è nothing.
        '
        If Not WebGridEventi.HeaderRow Is Nothing Then
            WebGridEventi.UseAccessibleHeader = True
            WebGridEventi.HeaderRow.TableSection = TableRowSection.TableHeader
        End If
    End Sub
End Class




