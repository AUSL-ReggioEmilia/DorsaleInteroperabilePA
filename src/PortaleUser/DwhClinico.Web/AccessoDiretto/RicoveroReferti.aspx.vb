Imports DwhClinico.Data
Imports DwhClinico.Web
Imports DwhClinico.Web.Utility
Imports System.Security

Partial Class AccessoDiretto_RicoveroReferti
    Inherits System.Web.UI.Page


    Dim mIdRicovero As Guid = Nothing
    Dim mIdPaziente As Guid = Nothing
    Dim msNumeroNosologico As String = Nothing
    Dim msAziendaEroganteNosologico As String = Nothing
    '
    ' Memorizza se cancellare l'operazione di select di una Data Source
    '
    Private mbCancelSelectOperation As Boolean = False
    Private Const GRID_PAGE_SIZE As Integer = 100
    Private mstrPageID As String
    '
    ' Per discriminare fra Ricovero e Prenotazione
    '
    Private mbIsPrenotazione As Boolean = False

    Dim moPazienteSac As New PazienteSac

    ''' <summary>
    ''' DataMinimaFiltro viene valorizzata solo se non ho forzato l'accesso
    ''' </summary>
    ''' <value></value>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Private Property DataMinimaFiltro() As DateTime
        Get
            Return CType(ViewState("-DataMinimaFiltro-"), DateTime)
        End Get
        Set(ByVal value As DateTime)
            ViewState("-DataMinimaFiltro-") = value
        End Set
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Dim sIdPaziente As String = Nothing
        Dim sIdRicovero As String = Nothing
        Dim oSacDettaglioPaziente As SacDettaglioPaziente = Nothing
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
            ' Prelevo parametri dal query string (sono tutti obbligatori)
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
                '
                ' Inizializzazioni della pagina;
                '
                '
                ' Paginazione di default
                '
                WebGridMain.PageSize = GRID_PAGE_SIZE
                '
                ' Aggiorno la barra di navigazione
                '
                'BarraNavigazione.SetCurrentItem("Referti lista", "")
                '
                ' Visualizzo la testata con i dati del paziente
                '
                oSacDettaglioPaziente = moPazienteSac.GetData(mIdPaziente)
                If oSacDettaglioPaziente Is Nothing Then
                    mbCancelSelectOperation = True
                    Throw New ApplicationException("Impossibile ricavare il dettaglio del paziente!")
                End If
                Call ShowTestataPaziente(oSacDettaglioPaziente)
                '
                ' Memorizzo eventuale data di filtro dovuta al consenso, se non ho forzato l'accesso
                '
                If Utility.GetSessionForzaturaConsenso(mIdPaziente) = False Then
                    DataMinimaFiltro = GetConsensoDataMinimaDiFiltro(oSacDettaglioPaziente)
                End If
                '
                ' Traccia accessi
                '
				Utility.TracciaAccessiLista("Lista referti", mIdPaziente, Utility.MotivoAccesso, Utility.MotivoAccessoNote)
                '
                ' Ricarico i valori di filtrob dalla sessione
                '
                Call LoadFilterValues()
                '
                ' Provo a riposizionare gli indici di pagina originari
                '
                Call SetOldPageIndex()
                '
                ' Ricerca dei referti
                '
                Call ExecuteSearch()
                '
                ' Carico i dati dell'episodio
                '
                Call ExecuteSearchTestataEpisodio()
            End If

            '
            'RENDERING PER BOOTSTRAP
            'Converte i tag html generati dalla GridView per la paginazione
            ' e li adatta alle necessita dei CSS Bootstrap
            '
            WebGridMain.PagerStyle.CssClass = "pagination-gridview"
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
            HttpContext.Current.Cache("CKD_DataSourceRicoveroReferti") = New Object
            Call ExecuteSearch(True)

            WebGridMain.DataBind()

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
            '
            ' Le successive tab hanno la stessa data source
            '
            With DataSourceRicoveroReferti
                .SelectParameters("IdPaziente").DefaultValue = mIdPaziente.ToString
                'TODO: si deve filtrare per Azienda Erogante nella visualizzazione dei referti?
                .SelectParameters("AziendaErogante").DefaultValue = Nothing  'AziendaErogante Referti
                .SelectParameters("NumeroNosologico").DefaultValue = msNumeroNosologico

                Dim oDallaData As Nullable(Of DateTime)
                If DataMinimaFiltro <> Nothing Then oDallaData = DataMinimaFiltro
                If oDallaData.HasValue Then
                    .SelectParameters("DataDal").DefaultValue = oDallaData
                Else
                    .SelectParameters("DataDal").DefaultValue = Nothing
                End If


                If String.IsNullOrEmpty(msAziendaEroganteNosologico) Then
                    .SelectParameters("AziendaEroganteNosologico").DefaultValue = Nothing
                Else
                    .SelectParameters("AziendaEroganteNosologico").DefaultValue = msAziendaEroganteNosologico
                End If
            End With
            '
            ' Eseguo select solo quando richiesto
            '
            If bReadFromDataSource Then DataSourceRicoveroReferti.Select()

        Catch ex As Exception
            lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati!"
            alertErrorMessage.Visible = True
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

    Private Sub LoadFilterValues()
        '
        ' Nessun filtro
        '
    End Sub

    Private Sub ExecuteSearchTestataEpisodio()
        '
        ' Eseguo la ricerca: solo se voglio rileggere i dati da DB pongo bReadFromDataSource = True 
        '
        Try
            With DataSourceTestataEpisodio
                .SelectParameters("IdRicovero").DefaultValue = mIdRicovero.ToString
            End With

        Catch ex As Exception
            lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati!"
            alertErrorMessage.Visible = True
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

#Region "Eventi objectDataSource"

#Region "DataSourceRicoveroReferti"

    Protected Sub DataSourceRicoveroReferti_Selected(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles DataSourceRicoveroReferti.Selected
        Dim dtList As AccessoDirettoDataSet.RicoveroRefertiListaDataTable = Nothing
        Try
            '
            ' Modifico titolo in caso di data minima di filtro dovuta a consenso minimo Dossier
            '
            If DataMinimaFiltro <> Nothing Then
                divPageTitle.InnerText = String.Format("Elenco referti del ricovero da acquisizione Consenso Dossier {0}", DataMinimaFiltro.ToShortDateString())
            End If
            lblNoRecordFound.Text = ""
            If e.Exception IsNot Nothing Then
                '
                ' Errore
                '
                Logging.WriteError(e.Exception, Me.GetType.Name)
                lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati!"
                alertErrorMessage.Visible = True
                Call ShowAll(False)
                e.ExceptionHandled = True

            ElseIf e.ReturnValue Is Nothing OrElse CType(e.ReturnValue, DataTable).Rows.Count = 0 Then
                lblNoRecordFound.Text = "Non è stato trovato nessun referto"
                Call ShowAll(False)
                'WebGridMain.PagerStyle.Visible = False
            Else
                '
                ' Se sono qui la data table contiene dei dati
                '
                dtList = CType(e.ReturnValue, AccessoDirettoDataSet.RicoveroRefertiListaDataTable)
                '
                ' Filtro con IsInRole
                '
                dtList = FiltraReferti(dtList)

                '
                ' Se sono qui dtList non è nothing
                ' Scrivo indicazioni se non è stato trovato nessun record
                ' Se presente uno o più referti li visualizzo (NESSUN REDIRECT AUTOMATICO)
                '
                If dtList.Rows.Count = 0 Then
                    lblNoRecordFound.Text = "Non è stato trovato nessun referto"
                    Call ShowAll(False)
                End If

                Dim bPagerStyleVisible As Boolean = True

                With WebGridMain
                    '.PagerStyle.Visible = bPagerStyleVisible
                    .PageIndex = AdjustCurrentIndex(CType(e.ReturnValue, DataTable).Rows.Count, .PageSize, .PageIndex)
                    Me.Session(mstrPageID & .ID) = .PageIndex
                End With
            End If

        Catch ex As Exception
            '
            ' Errore
            '
            Logging.WriteError(ex, Me.GetType.Name)
            lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati!"
            alertErrorMessage.Visible = True
        End Try
    End Sub

    Protected Sub DataSourceRicoveroReferti_Selecting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.ObjectDataSourceSelectingEventArgs) Handles DataSourceRicoveroReferti.Selecting
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


#Region "DataSourceTestataEpisodio"

    Protected Sub DataSourceTestataEpisodio_Selected(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) Handles DataSourceTestataEpisodio.Selected
        Try
            If e.Exception IsNot Nothing Then
                '
                ' Errore
                '
                Logging.WriteError(e.Exception, Me.GetType.Name)
                lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati della testata dell'episodio!"
                alertErrorMessage.Visible = True
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
            lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati!"
            alertErrorMessage.Visible = True
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
        Return Me.ResolveUrl(String.Format("~/AccessoDiretto/Referto.aspx?IdReferto={0}", oIdreferto.ToString))
    End Function

    Protected Function GetStatoImageUrl(ByVal oStato As Object) As String
        Return Me.ResolveUrl(String.Format("~/Images/Referti/StatoRichiesta_{0}.gif", oStato))
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
        Dim sRet As String = "Nosologico:"
        If mbIsPrenotazione Then
            sRet = "Codice prenotazione:"
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

    'Private Sub ShowTestataPaziente(ByVal IDPaziente As Guid)
    '    Using oDataset As New PazientiDataset
    '        Using oDataPaziente As New Pazienti
    '            oDataPaziente.Testata(oDataset.FevsPazientiTestata, IDPaziente)
    '        End Using
    '        '
    '        ' Inizializzo
    '        '
    '        lblCognome.Text = ""
    '        lblNome.Text = ""
    '        lblLuogoNascita.Text = ""
    '        lblDataNascita.Text = ""
    '        lblCodiceFiscale.Text = ""
    '        lblCodiceSanitario.Text = ""
    '        '
    '        ' Visualizzo i dati del paziente
    '        '
    '        If oDataset.FevsPazientiTestata.Rows.Count > 0 Then
    '            With oDataset.FevsPazientiTestata(0)

    '                Dim sNome As String = ""
    '                Dim sCognome As String = ""
    '                If Not .IsNomeNull Then lblNome.Text = .Nome
    '                If Not .IsCognomeNull Then lblCognome.Text = .Cognome

    '                If Not .IsLuogoNascitaNull Then lblLuogoNascita.Text = .LuogoNascita
    '                If Not .IsDataNascitaNull Then lblDataNascita.Text = .DataNascita.ToShortDateString

    '                If Not .IsCodiceFiscaleNull Then lblCodiceFiscale.Text = .CodiceFiscale

    '                If Not .IsCodiceSanitarioNull Then lblCodiceSanitario.Text = .CodiceSanitario
    '            End With

    '        End If
    '    End Using

    'End Sub

    ''' <summary>
    ''' Visualizzo i dati del paziente in base ai dati della classe oSacDettaglioPaziente
    ''' </summary>
    ''' <param name="oSacDettaglioPaziente"></param>
    ''' <remarks></remarks>
    Private Sub ShowTestataPaziente(ByVal oSacDettaglioPaziente As SacDettaglioPaziente)
        '
        ' Inizializzo
        '
        lblCognome.Text = String.Empty
        lblNome.Text = String.Empty
        lblDataNascita.Text = String.Empty
        lblLuogoNascita.Text = String.Empty
        lblCodiceFiscale.Text = String.Empty
        lblCodiceSanitario.Text = String.Empty
        lblDataDecesso.Text = String.Empty
        If Not oSacDettaglioPaziente Is Nothing Then
            '
            ' Visualizzo i dati del paziente
            '
            lblCognome.Text = oSacDettaglioPaziente.Cognome
            lblNome.Text = oSacDettaglioPaziente.Nome
            If oSacDettaglioPaziente.DataNascita.HasValue Then
                lblDataNascita.Text = oSacDettaglioPaziente.DataNascita.Value.ToShortDateString
            End If
            lblLuogoNascita.Text = oSacDettaglioPaziente.LuogoNascita
            lblCodiceFiscale.Text = oSacDettaglioPaziente.CodiceFiscale
            lblCodiceSanitario.Text = oSacDettaglioPaziente.CodiceSanitario

            If oSacDettaglioPaziente.DataDecesso.HasValue Then
                lblDataDecesso.Visible = True
                lblDataDecesso.Text = oSacDettaglioPaziente.DataDecesso.Value.ToShortDateString()
            Else
                lblDataDecesso.Visible = False
            End If
        End If
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
            oCurrentPageIndex = Me.Session(mstrPageID & WebGridMain.ID)
            If Not oCurrentPageIndex Is Nothing Then WebGridMain.PageIndex = CType(oCurrentPageIndex, Integer)
        Catch
        End Try
    End Sub


    Private Sub ShowAll(ByVal bTableReportContainerVisible As Boolean)
        divReportContainer.Visible = bTableReportContainerVisible
    End Sub


    Private Function FiltraReferti(dtList As AccessoDirettoDataSet.RicoveroRefertiListaDataTable) As AccessoDirettoDataSet.RicoveroRefertiListaDataTable
        Dim oContextUser As Principal.IPrincipal = Me.Context.User
        For Each drReferto As AccessoDirettoDataSet.RicoveroRefertiListaRow In dtList
            'If drReferto.IsRuoloVisualizzazioneSistemaEroganteNull Then
            '    '
            '    ' Rimuovo perche vuoto
            '    '
            '    drReferto.Delete()
            'ElseIf Not oContextUser.IsInRole(drReferto.RuoloVisualizzazioneSistemaErogante) Then
            '    '
            '    ' Rimuovo perche non nel ruolo
            '    '
            '    drReferto.Delete()
            'End If
            'If drReferto.RowState <> DataRowState.Deleted Then
            '    If drReferto.IsRuoloVisualizzazioneRepartoRichiedenteNull Then
            '        '
            '        ' Rimuovo perche vuoto
            '        '
            '        drReferto.Delete()
            '    ElseIf Not oContextUser.IsInRole(drReferto.RuoloVisualizzazioneRepartoRichiedente) Then
            '        '
            '        ' Rimuovo perche non nel ruolo
            '        '
            '        drReferto.Delete()
            '    End If
            'End If
            Dim sOscuramenti As String = String.Empty
            If Not drReferto.IsOscuramentiNull Then sOscuramenti = drReferto.Oscuramenti
            If Not Utility.CheckAccesso(oContextUser, drReferto.AziendaErogante, drReferto.SistemaErogante, sOscuramenti) Then
                drReferto.Delete()
            End If
        Next
        dtList.AcceptChanges()
        '
        '
        '
        Return dtList

    End Function

End Class
