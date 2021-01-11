Imports DwhClinico.Data
Imports DwhClinico.Web
Imports DwhClinico.Web.Utility
Imports System.Security
'--------------------------------------------------------------------------------------------
' QUESTA PAGINA NON E' UN ENTRY POINT.
' CI SI PUO' ARRIVARE SOLO NAVIGANDO FRA LE PAGINE DELL'ACCESSO DIRETTO
'--------------------------------------------------------------------------------------------
Partial Class AccessoDiretto_Evento
    Inherits System.Web.UI.Page

    Dim mIdRicovero As Guid = Nothing
    Dim mIdPaziente As Guid = Nothing
    Dim mIdEvento As Guid = Nothing
    '
    ' Memorizza se cancellare l'operazione di select di una Data Source
    '
    Dim mbDataSourceMainCancelSelectOperation As Boolean = False
    Private mstrPageID As String

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Dim sIdEvento As String = Nothing
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
            ' ' PageAddCss(Me)
            '
            ' Prelevo parametri dal query string
            '
            sIdRicovero = Me.Request.QueryString(PAR_ID_RICOVERO)
            If Not String.IsNullOrEmpty(sIdRicovero) Then
                mIdRicovero = New Guid(sIdRicovero)
            Else
                Throw New Exception("Il parametro '" & PAR_ID_RICOVERO & "' è obbligatorio")
            End If

            sIdEvento = Me.Request.QueryString(PAR_ID_EVENTO)
            If Not String.IsNullOrEmpty(sIdEvento) Then
                mIdEvento = New Guid(sIdEvento)
            Else
                Throw New Exception("Il parametro '" & PAR_ID_EVENTO & "' è obbligatorio")
            End If

            sIdPaziente = Me.Request.QueryString(PAR_ID_PAZIENTE)
            If Not String.IsNullOrEmpty(sIdPaziente) Then
                mIdPaziente = New Guid(sIdPaziente)
            Else
                Throw New Exception("Il parametro '" & PAR_ID_PAZIENTE & "' è obbligatorio")
            End If

            '
            ' Solo la prima volta
            '
            If Not IsPostBack Then
                Dim bPageEntryPoint As Boolean = Utility.AccessoDiretto_IsPageEntryPoint()
                '
                ' Aggiorno la barra di navigazione
                '
                'If bPageEntryPoint Then
                '    BarraNavigazione.ClearAll()
                'End If
                'BarraNavigazione.SetCurrentItem("Evento dettaglio", Me.Request.Url.AbsoluteUri)

                '
                ' Eseguo il caricamento dei dati 
                '
                Call ExecuteSearchDettaglio()
                '
                ' Visualizzo la testata con i dati del paziente
                '  (li leggo dal database)
                '
                Call ShowTestataPaziente(mIdRicovero)
                '
                ' Visualizzo le informazioni di ricovero
                '
                Dim sXml As String = GetXmlTestataRicovero(mIdRicovero)
                If Not String.IsNullOrEmpty(sXml) Then
                    Call ShowTestataRicovero(sXml)
                    '
                    ' Traccia accessi
                    '
                    If bPageEntryPoint Then
                        'Forzo il nmotivo dell'accesso a "Paziente in carico"
                        Utility.MotivoAccesso = New ListItem(MOTIVO_ACCESSO_PAZIENTE_IN_CARICO_TEXT, MOTIVO_ACCESSO_PAZIENTE_IN_CARICO_ID)
                    End If
					Utility.TracciaAccessiEvento("Apre evento ricovero", mIdPaziente, mIdEvento, Utility.MotivoAccesso, Utility.MotivoAccessoNote)
                Else
                    '
                    ' Mostro messaggio per segnalare che l'utente non ha accesso
                    '
                    lblErrorMessage.Text = Messaggi.MSG_OBJECT_NOT_VISIBLE_TO_USER
                    alertErrorMessage.Visible = True
                    Call ShowAll(False)
                End If
            Else
                '
                ' Visualizzo le informazioni di ricovero
                '
                Dim sXml As String = GetXmlTestataRicovero(mIdRicovero)
                If Not String.IsNullOrEmpty(sXml) Then
                    Call ShowTestataRicovero(sXml)
                Else
                    '
                    ' Mostro messaggio per segnalare che l'utente non ha accesso
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
        divInfoRicovero.Visible = bValue
        divReportContainer.Visible = bValue
    End Sub


    Private Sub ExecuteSearchDettaglio()
        '
        ' Eseguo la ricerca: solo se voglio rileggere i dati da DB pongo bReadFromDataSource = True 
        '
        Try
            With DataSourceMain
                .SelectParameters("IdEventi").DefaultValue = mIdEvento.ToString
            End With
            '
            ' Eseguo bind
            '
            DataSourceMain.Select()

        Catch ex As Exception
            lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati!"
            alertErrorMessage.Visible = True
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
                lblErrorMessage.Text = "Errore durante l'operazione di ricerca dei dati!"
                alertErrorMessage.Visible = True
                e.ExceptionHandled = True

            ElseIf e.ReturnValue Is Nothing OrElse CType(e.ReturnValue, DataTable).Rows.Count = 0 Then
                lblNoRecordFound.Text = "Non è stato trovato nessun evento"
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

    Protected Sub DataSourceMain_Selecting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.ObjectDataSourceSelectingEventArgs) Handles DataSourceMain.Selecting
        Try
            If mbDataSourceMainCancelSelectOperation = True Then
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
        If (Not oAziendaErogante Is DBNull.Value) AndAlso (Not oNumeroNosologico Is DBNull.Value) Then
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
        ' Devo visualizzare i dati del paziente prelevandoli dal record di accettazione = (Id=IdRicovero) 
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
                        Dim oRow As RicoveriDataSet.FevsRicoveroTestataRow = oTaTestata(0)
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
End Class
