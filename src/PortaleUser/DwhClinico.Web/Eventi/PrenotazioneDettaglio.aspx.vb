Imports DwhClinico.Data
Imports DwhClinico.Web
Imports DwhClinico.Web.Utility
'
' Dalla pagina RicoveriLista.aspx facendo drill-down su di una prenotazione si naviga a questa pagina di dettaglio.
' 1) Visualizza i dati di testata paziente (prelevati dagli attributi del record della prenotazione in RicoveriAttributi)
' 2) Tramite trasformazione XSLT visualizza i dati della prenotazione:
'       Tali dati li leggiamo dalla tabella EventiBase relativamente all'ultimo record lista di attesa (gli attributi sono sempre quelli dell'ultimo stato) 
'       quindi li leggo dall'ultimo evento lista di attesa
'
'

Partial Class Eventi_PrenotazioneDettaglio
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

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
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
                '***************************************************************************************
                ' Verifica del consenso
                ' SacDettaglioPaziente.Session() è stata valorizzata nella pagina del consenso
                '***************************************************************************************
                Dim sErrMsg As String = ""
                If Not Utility.VerificaConsenso(mIdPaziente, SacDettaglioPaziente.Session()) Then
                    mbCancelSelectOperation = True
                    Call RedirectToHome()
                    Exit Sub
                End If
                '***************************************************************
                ' Fine verifica del consenso
                '***************************************************************
                '
                ' Traccia accessi
                '
                Utility.TracciaAccessiRicovero("Dettaglio prenotazione", mIdPaziente, mIdRicovero, SessionHandler.MotivoAccesso, SessionHandler.MotivoAccessoNote)
                '
                ' Visualizzo la testata con i dati del paziente
                '
                Call ShowTestataPaziente(mIdRicovero)
                '
                ' Visualizzo le informazioni di ricovero
                '
                Dim sXml As String = GetXmlDettaglioPrenotazione(mIdRicovero)
                Call ShowDettaglioPrenotazione(sXml)
                '
                ' Aggiorno la barra di navigazione
                '
                Dim sUrl As String = String.Format("~/Eventi/PrenotazioneDettaglio.aspx?{0}={1}&{2}={3}&{4}={5}", PAR_ID_PAZIENTE, mIdPaziente.ToString, PAR_ID_RICOVERO, mIdRicovero.ToString, "nextpage", "false")
                'BarraNavigazione.SetCurrentItem("Prenotazione dettaglio", Me.ResolveUrl(sUrl))
            Else
                '
                ' Visualizzo le informazioni di ricovero
                '
                Dim sXml As String = GetXmlDettaglioPrenotazione(mIdRicovero)
                Call ShowDettaglioPrenotazione(sXml)
            End If

        Catch ex As Exception
            lblErrorMessage.Text = "Errore durante il caricamento della pagina!"
            alertErrorMessage.Visible = True
            Logging.WriteError(ex, Me.GetType.Name)
        End Try

    End Sub

#Region "Funzioni usate nella parte aspx"
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


#Region "Dettaglio della prenotazione"

    Private Function GetXmlDettaglioPrenotazione(ByVal IdPrenotazione As Guid) As String
        '
        ' LA FUNZIONE NON ESEGUE NESSUNA VERIFICA DI ACCESSO IN QUANDO QUESTA PAGINA VIENE CHIAMATA DOPO LA LISTA
        '
        Try
            Using oPrenotazioni As New Prenotazioni
                Using oDataSet As New PrenotazioniDataSet
                    '
                    ' Leggo i dati di testata della prenotazione (record tabella Ricoveri)
                    '
                    Dim oTaTestata As PrenotazioniDataSet.FevsPrenotazioneTestataDataTable = oPrenotazioni.PrenotazioneTestata(IdPrenotazione)
                    If Not oTaTestata Is Nothing AndAlso oTaTestata.Rows.Count > 0 Then
                        oDataSet.Tables.Add(oTaTestata)
                    End If
                    '
                    ' Leggo i dati associati alla prenotazione
                    '
                    Dim oTaDatiDettaglio As PrenotazioniDataSet.FevsPrenotazioniDettaglioDataTable = oPrenotazioni.GetPrenotazioneDettaglio(IdPrenotazione)
                    If Not oTaDatiDettaglio Is Nothing AndAlso oTaDatiDettaglio.Rows.Count > 0 Then
                        oDataSet.Tables.Add(oTaDatiDettaglio)
                    Else
                        'creo la data table alvolo
                        oTaDatiDettaglio = New PrenotazioniDataSet.FevsPrenotazioniDettaglioDataTable()
                    End If
                    '
                    ' Aggiungo una riga alla datatatable oTaInfo (Nome,Valore) per passare l'url ai referti del nosologico
                    ' valore è un VARCHAR(8000), quindi non ho problemi di spazio
                    '
                    Dim sAziendaErogante As String = oTaTestata(0).AziendaErogante
                    Dim sNumeroNosologico As String = oTaTestata(0).NumeroNosologico
                    oTaDatiDettaglio.AddFevsPrenotazioniDettaglioRow("UrlLinkReferti", GetUrlLinkReferti(mIdPaziente, sAziendaErogante, sNumeroNosologico))
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
            Logging.WriteError(ex, "GetXmlDettaglioPrenotazione: Si è verificato un errore durante la lettura del dettaglio della prenotazione.")
            Throw
        End Try
    End Function

    Private Sub ShowDettaglioPrenotazione(ByVal sXml As String)
        Try
            '
            ' Eseguo la trasformazione XSLT
            '
            XmlDettaglioPrenotazione.DocumentContent = sXml
            XmlDettaglioPrenotazione.DataBind()
        Catch ex As Exception
            Logging.WriteError(ex, "ShowDettaglioPrenotazione: Si è verificato un errore durante la visualizzazione delle informazioni della prenotazione.")
            Throw
        End Try
    End Sub

#End Region

    Private Sub RedirectToHome()
        Response.Redirect(Me.ResolveUrl("~/Default.aspx"), False)
    End Sub

End Class
