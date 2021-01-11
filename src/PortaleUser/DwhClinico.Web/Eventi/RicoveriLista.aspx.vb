Imports DwhClinico.Data
Imports DwhClinico.Web
Imports DwhClinico.Web.Utility

Partial Class Eventi_RicoveriLista
    Inherits System.Web.UI.Page

    '
    ' L'Id del paziente di cui si deve mostrare la lista dei referti
    '
    Dim mIdPaziente As Guid = Nothing
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
            sIdPaziente = Me.Request.QueryString(PAR_ID_PAZIENTE)
            If Not sIdPaziente Is Nothing AndAlso sIdPaziente.Length > 0 Then
                mIdPaziente = New Guid(sIdPaziente)
            Else
                Throw New Exception("Il parametro '" & PAR_ID_PAZIENTE & " ' è obbligatorio")
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
                '************************************************************************************
                ' Verifica del consenso ed eventuale data minima di filtro
                ' SacDettaglioPaziente.Session() è stata valorizzata nella pagina del consenso
                '************************************************************************************
                If Not Utility.VerificaConsenso(mIdPaziente, SacDettaglioPaziente.Session()) Then
                    mbCancelSelectOperation = True
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
                        divPageTitle.InnerText = String.Format("Elenco episodi da acquisizione Consenso Dossier {0}", oDataMinimaFiltro.ToShortDateString())
                    End If
                    '
                    ' Imposto la property di pagina qualsiasi valore abbia
                    '
                    DataMinimaFiltro = oDataMinimaFiltro
                End If
                '************************************************************************************
                ' Fine Verifica del consenso ed eventuale data minima di filtro
                '************************************************************************************
                '
                ' Traccia accessi
                '
                Utility.TracciaAccessiLista("Lista Ricoveri", mIdPaziente, SessionHandler.MotivoAccesso, SessionHandler.MotivoAccessoNote)
                '
                ' Paginazione di default
                '
                WebGridEpisodi.PageSize = GRID_PAGE_SIZE
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
                ' Eseguo la prima visualizzazione
                '
                Call ExecuteSearch()
                '
                ' Aggiorno la barra di navigazione
                '
                Dim sUrl As String = String.Format("~/Eventi/RicoveriLista.aspx?{0}={1}&{2}={3}", PAR_ID_PAZIENTE, mIdPaziente.ToString, "nextpage", "false")
                'BarraNavigazione.SetCurrentItem("Episodi lista", Me.ResolveUrl(sUrl))
            Else
                mbGoToNextPage = False
                '
                ' Riverifico il consenso ad ogni postback
                '
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
            WebGridEpisodi.PagerStyle.CssClass = "pagination-gridview"
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
            WebGridEpisodi.DataBind()

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
                    .SelectParameters("IdPaziente").DefaultValue = mIdPaziente.ToString
                    .SelectParameters("DataEpisodio").DefaultValue = txtDataDal.Text
                    .SelectParameters("AziendaErogante").DefaultValue = "" 'per ora non filtro
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
        Dim sIdPaziente As String = mIdPaziente.ToString.ToUpper
        txtDataDal.Text = Me.Session(mstrPageID & txtDataDal.ID & sIdPaziente)
    End Sub

    Private Sub SaveFilterValues()
        Dim sIdPaziente As String = mIdPaziente.ToString.ToUpper
        Me.Session(mstrPageID & txtDataDal.ID & sIdPaziente) = txtDataDal.Text
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
                lblNoRecordFound.Text = "Non è stato trovato nessun evento"
                'WebGridEpisodi.PagerStyle.Visible = False

            Else
                Dim dtRicoveri As RicoveriDataSet.FevsRicoveriPazienteListaDataTable = CType(e.ReturnValue, RicoveriDataSet.FevsRicoveriPazienteListaDataTable)
                If mbGoToNextPage AndAlso dtRicoveri.Rows.Count = 1 Then
                    '
                    ' Ho un solo ricovero: navigo alla lista dei suoi eventi
                    '
                    Dim oIdRicovero As Guid = dtRicoveri(0).IdRicovero
                    Dim sNumeroNosologico As String = dtRicoveri(0).NumeroNosologico
                    Dim sUrl As String = GetUrlDettaglio(oIdRicovero, sNumeroNosologico)
                    Call Response.Redirect(Me.ResolveUrl(sUrl))

                Else
                    lblNoRecordFound.Text = ""

                    With WebGridEpisodi
                        '.PagerStyle.Visible = True
                        .PageIndex = AdjustCurrentIndex(dtRicoveri.Rows.Count, .PageSize, .PageIndex)
                        Me.Session(mstrPageID & .ID) = .PageIndex
                    End With

                End If

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
    ''' Discrimina fra il dettaglio di un ricovero e il dettaglio di una prenotazione
    ''' </summary>
    ''' <param name="oIdRicovero">Id ricovero/prenotazione</param>
    ''' <param name="oNumeroNosologico">numero nosologico associato</param>
    ''' <returns>url alla pagina desiderata</returns>
    ''' <remarks></remarks>
    Protected Function GetUrlDettaglio(ByVal oIdRicovero As Object, ByVal oNumeroNosologico As Object) As String
        Dim sRet As String = String.Empty
        If (Not oIdRicovero Is DBNull.Value) Then
            If Utility.RicoveroIsPrenotazione(oIdRicovero) Then
                'Lista attesa/prenotazione
                sRet = GetUrlDettaglioPrenotazione(oIdRicovero)
            Else
                sRet = GetUrlLinkEventiLista(oIdRicovero)
            End If
        End If
        Return sRet
    End Function

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


    Private Function GetUrlLinkEventiLista(ByVal oIdRicovero As Object) As String
        '
        ' Se manca il consenso non creo il link ai referti
        '
        Dim sRet As String = ""
        If Not oIdRicovero Is DBNull.Value Then
            sRet = Me.ResolveUrl("~/Eventi/RicoveroEventiLista.aspx") & _
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

    Protected Function GetUrlLinkReferti(ByVal oIdRicovero As Object, ByVal oAziendaErogante As Object, ByVal oNumeroNosologico As Object) As String
        Dim sRet As String = ""
        If (Not oIdRicovero Is DBNull.Value) AndAlso (Not oAziendaErogante Is DBNull.Value) AndAlso (Not oNumeroNosologico Is DBNull.Value) Then
            sRet = Me.ResolveUrl("~/Referti/RefertiListaRicoveroPaziente.aspx") & _
                                    String.Format("?{0}={1}&{2}={3}&{4}={5}&{6}={7}", _
                                                PAR_ID_PAZIENTE, mIdPaziente.ToString, _
                                                PAR_ID_RICOVERO, oIdRicovero.ToString, _
                                                PAR_NUMERO_NOSOLOGICO, oNumeroNosologico.ToString, _
                                                PAR_AZIENDA_EROGANTE, oAziendaErogante.ToString)
        End If
        '
        '
        '
        Return sRet
    End Function


    Protected Function GetEpisodioDesc(ByVal oNumeroNosologico As Object, ByVal oTipoEpisodioDescr As Object) As String
        Return Utility.GetEpisodioDesc(oNumeroNosologico, oTipoEpisodioDescr)
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

    Private Sub SetOldPageIndex()
        Try
            Dim oCurrentPageIndex As Object
            oCurrentPageIndex = Me.Session(mstrPageID & WebGridEpisodi.ID)
            If Not oCurrentPageIndex Is Nothing Then WebGridEpisodi.PageIndex = CType(oCurrentPageIndex, Integer)
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


    Private Sub ShowAll(ByVal bVisible As Boolean)
        divTestataPaziente.Visible = bVisible
        divFiltersContainer.Visible = bVisible
        divReportContainer.Visible = bVisible
    End Sub

    Private Sub RedirectToHome()
        Response.Redirect(Me.ResolveUrl("~/Default.aspx"), False)
    End Sub

    Private Sub WebGridEpisodi_PreRender(sender As Object, e As EventArgs) Handles WebGridEpisodi.PreRender
        '
        'Render per Bootstrap
        'Crea la Table con Theader e Tbody se l'header non è nothing.
        '
        If Not WebGridEpisodi.HeaderRow Is Nothing Then
            WebGridEpisodi.UseAccessibleHeader = True
            WebGridEpisodi.HeaderRow.TableSection = TableRowSection.TableHeader
        End If
    End Sub
End Class




