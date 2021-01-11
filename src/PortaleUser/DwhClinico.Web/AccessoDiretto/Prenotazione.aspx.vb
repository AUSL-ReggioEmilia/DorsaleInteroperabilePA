Imports DwhClinico.Data
Imports DwhClinico.Web
Imports DwhClinico.Web.Utility
Imports System.Security
'
' Dalla pagina Ricoveri.aspx facendo drill-down su di una prenotazione si naviga a questa pagina di dettaglio.
' 1) Visualizza i dati di testata paziente (prelevati dagli attributi del record della prenotazione in RicoveriAttributi)
' 2) Tramite trasformazione XSLT visualizza i dati della prenotazione
'
Partial Class AccessoDiretto_Prenotazione
    Inherits System.Web.UI.Page

    '
    ' L'Id del paziente di cui si deve mostrare la lista dei referti
    '
    Dim mIdPaziente As Guid = Nothing
    Dim mIdRicovero As Nullable(Of Guid) = Nothing

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Dim sIdRicovero As String = Nothing
        Dim sAziendaErogante As String = Nothing
        Dim sNumeroNosologico As String = Nothing
        Try
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
                '
                ' Controllo esistenza di AziendaErogante e Nosologico
                '
                sAziendaErogante = Me.Request.QueryString(PAR_AZIENDA_EROGANTE)
                sNumeroNosologico = Me.Request.QueryString(PAR_NUMERO_NOSOLOGICO)
                If String.IsNullOrEmpty(sAziendaErogante) AndAlso String.IsNullOrEmpty(sNumeroNosologico) Then
                    Throw New Exception(String.Format("Errore nei parametri: utilizzare '0' oppure {1} e {2}", PAR_ID_RICOVERO, PAR_AZIENDA_EROGANTE, PAR_NUMERO_NOSOLOGICO))
                End If
            End If
            '
            ' Solo la prima volta
            '
            If Not IsPostBack Then
                '
                ' Ricavo informazioni sul ricovero: se sono qui o mIdRicovero è valorizzato oppure lo sono sAziendaErogante e sNumeroNosologico
                '
                Dim oRowRicovero As AccessoDirettoDataSet.RicoveroRow

                Dim iConsensoMinimoAccordato As ConsensoMinimoAccordato = ConsensoMinimoAccordato.Nessuno
                Using oAccessoDiretto As New AccessoDiretto
                    oRowRicovero = oAccessoDiretto.GetRicovero(mIdRicovero, sAziendaErogante, sNumeroNosologico)
                    mIdRicovero = oRowRicovero.Id
                    mIdPaziente = oRowRicovero.IdPaziente
                    iConsensoMinimoAccordato = CType(oRowRicovero.Consenso, ConsensoMinimoAccordato)
                End Using
                If Not mIdRicovero.HasValue Then
                    lblErrorMessage.Text = "Impossibile ricavare la prenotazione!"
                    alertErrorMessage.Visible = True
                    Call ShowAll(False)
                End If
                '
                ' Verifico se c'è il consenso per i paziente associato a tale ricovero
                ' A questo punto IdRicovero, IdPaziente, Consenso sono sempre valorizzati
                ' Se la pagina è utilizzata come entry point bypasso il consenso
                ' Se la pagina NON è utilizzata come entry point significa che ho premuto un link per arrivare qui (la cui visibilità dipende dalla DataMinima di filtro)
                '
                Dim bPageEntryPoint As Boolean = Utility.AccessoDiretto_IsPageEntryPoint()

                Dim bBypassoConsenso As Boolean = bPageEntryPoint OrElse _
                                                (Utility.GetSessionForzaturaConsenso(mIdPaziente) = True) OrElse _
                                                (Utility.AccessoDiretto_AccessoDaConsenso(mIdPaziente))

                If Not bBypassoConsenso Then
                    '
                    ' Vado alla pagina del consenso e imposto sUrlToGo per tornare a questa pagina
                    '
                    ' If bPageEntryPoint Then BarraNavigazione.ClearAll()
                    Dim sUrlToGo As String = Me.ResolveUrl(String.Format("~/AccessoDiretto/Prenotazione.aspx?IdRicovero={0}", mIdRicovero))
                    Dim sUrl As String = GetUrlToPaginaConsenso(mIdPaziente, sUrlToGo)
                    Call Response.Redirect(Me.ResolveUrl(sUrl), False)

                Else
                    '
                    ' Aggiorno la barra di navigazione
                    '
                    'If bPageEntryPoint Then
                    '    BarraNavigazione.ClearAll()
                    'End If
                    'BarraNavigazione.SetCurrentItem("Prenotazione dettaglio", Me.Request.Url.AbsoluteUri)
                    '
                    ' Visualizzo le informazioni di ricovero
                    '
                    Dim sXml As String = GetXmlDettaglioPrenotazione(mIdRicovero)
                    If Not String.IsNullOrEmpty(sXml) Then
                        Call ShowDettaglioPrenotazione(sXml)
                        '
                        ' Visualizzo la testata con i dati del paziente associati alla PRENOTAZIONE
                        '  (li leggo dal database)
                        '
                        Call ShowTestataPaziente(mIdRicovero)
                        '
                        ' Traccia accessi
                        '
                        If bPageEntryPoint Then
                            'Forzo il nmotivo dell'accesso a "Paziente in carico"
                            Utility.MotivoAccesso = New ListItem(MOTIVO_ACCESSO_PAZIENTE_IN_CARICO_TEXT, MOTIVO_ACCESSO_PAZIENTE_IN_CARICO_ID)
                        End If
						Utility.TracciaAccessiRicovero("Dettaglio prenotazione", mIdPaziente, mIdRicovero, Utility.MotivoAccesso, Utility.MotivoAccessoNote)
                    Else
                        '
                        ' Mostro messaggio per segnalare che l'utente non ha accesso
                        '
                        lblErrorMessage.Text = Messaggi.MSG_OBJECT_NOT_VISIBLE_TO_USER
                        alertErrorMessage.Visible = True
                        Call ShowAll(False)
                    End If
                End If
            Else
                '
                ' Visualizzo le informazioni di ricovero
                '
                Dim sXml As String = GetXmlDettaglioPrenotazione(mIdRicovero)
                If Not String.IsNullOrEmpty(sXml) Then
                    Call ShowDettaglioPrenotazione(sXml)
                Else
                    '
                    ' Mostro messaggio pr segnalare che l'utente non ha accesso
                    '
                    lblErrorMessage.Text = Messaggi.MSG_OBJECT_NOT_VISIBLE_TO_USER
                    alertErrorMessage.Visible = True
                    Call ShowAll(False)
                End If

            End If

        Catch ex As Exception
            lblErrorMessage.Text = "Errore durante il caricamento della pagina!"
            alertErrorMessage.Visible = True
            Logging.WriteError(ex, Me.GetType.Name)
        End Try

    End Sub

    Private Sub ShowAll(ByVal bValue As Boolean)
        divTestataPaziente.Visible = bValue
        divDettaglioPrenotazione.Visible = bValue
    End Sub


#Region "Funzioni usate nella parte aspx"
    Protected Function GetUrlLinkReferti(ByVal oIdPaziente As Object, ByVal oAziendaErogante As Object, ByVal oNumeroNosologico As Object) As String
        Dim sRet As String = ""
        If (Not oIdPaziente Is DBNull.Value) AndAlso _
                  (Not oAziendaErogante Is DBNull.Value) AndAlso _
                (Not oNumeroNosologico Is DBNull.Value) Then
            sRet = Me.ResolveUrl("~/AccessoDiretto/RicoveroReferti.aspx") & _
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
        Try
            Using oPrenotazioni As New Prenotazioni
                Using oDataSet As New PrenotazioniDataSet
                    '
                    ' Leggo i dati di testata della prenotazione (record tabella Ricoveri)
                    '
                    Dim oTaTestata As PrenotazioniDataSet.FevsPrenotazioneTestataDataTable = oPrenotazioni.PrenotazioneTestata(IdPrenotazione)
                    '
                    ' Verifico se l'utente può vedere la prenotazione in base al campo Oscuramenti
                    '
                    If Not oTaTestata Is Nothing AndAlso oTaTestata.Rows.Count > 0 Then
                        Dim oRow As PrenotazioniDataSet.FevsPrenotazioneTestataRow = oTaTestata(0)
                        Dim oContextUser As Principal.IPrincipal = Me.Context.User
                        Dim sOscuramenti As String = String.Empty
                        If Not oRow.IsOscuramentiNull Then sOscuramenti = oRow.Oscuramenti
                        If Not Utility.CheckAccesso(oContextUser, oRow.AziendaErogante, oRow.SistemaErogante, sOscuramenti) Then
                            '
                            ' Se non ho accesso all'oggetto restituisco NOTHING
                            '
                            Return Nothing
                        End If
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

    Private Function GetUrlToPaginaConsenso(ByVal IdPaziente As Object, ByVal UrlToGo As String) As String
        '
        ' Da usare nella lista per comporre il link
        '
        UrlToGo = Me.Server.UrlEncode(UrlToGo)
        Dim sUrl As String = String.Format("~/AccessoDiretto/PazientiConsenso.aspx?{0}={1}&{2}={3}", PAR_ID_PAZIENTE, IdPaziente, PAR_URL_TO, UrlToGo)
        Return Me.ResolveUrl(sUrl)
    End Function

End Class
