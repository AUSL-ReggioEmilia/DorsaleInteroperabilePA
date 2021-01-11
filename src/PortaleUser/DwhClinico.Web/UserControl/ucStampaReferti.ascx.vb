Imports DwhClinico.Data
Imports DwhClinico.Web
Imports DwhClinico.Web.Utility
Imports DwhClinico.Web.WsPrintManager


Public Class ucStampaReferti
    Inherits System.Web.UI.UserControl

    Private Const USER_MESSAGE_WAIT As String = "Attendere..."
    Private Const USER_MESSAGE_END_PRINTING As String = "<BR><BR><BR><BR><BR>La stampa dei documenti è terminata."
    Private Const USER_MESSAGE_SESSION_TIMEOUT As String = "<BR><BR><BR><BR><BR>La sessione è scaduta!<BR>Impossibile visualizzare lo stato corrente della stampa"

#Region "Property"
    Public Property Token() As WcfDwhClinico.TokenType
        Get
            Return CType(ViewState("Token"), WcfDwhClinico.TokenType)
        End Get
        Set(ByVal value As WcfDwhClinico.TokenType)
            ViewState("Token") = value
        End Set
    End Property

    Public Property PrinterServerName() As String
        Get
            Return DirectCast(ViewState("-ViewState-PrinterServerName"), String)
        End Get
        Set(ByVal value As String)
            ViewState("-ViewState-PrinterServerName") = value
        End Set
    End Property

    Public Property PrinterName() As String
        Get
            Return DirectCast(ViewState("-ViewState-PrinterName"), String)
        End Get
        Set(ByVal value As String)
            ViewState("-ViewState-PrinterName") = value
        End Set
    End Property

    Private Property DocumentiSottomessi() As Generic.List(Of PrintUtil.StampeDocumentoReferto)
        Get
            Return DirectCast(Session("DocSottomessi-A324DC9B-5FB6-4ded-9C60-889B89A14B2C"), Generic.List(Of PrintUtil.StampeDocumentoReferto))
        End Get
        Set(ByVal value As Generic.List(Of PrintUtil.StampeDocumentoReferto))
            Session("DocSottomessi-A324DC9B-5FB6-4ded-9C60-889B89A14B2C") = value
        End Set
    End Property

    Private Property RefertiDaSottomettere() As System.Collections.Queue
        Get
            Return DirectCast(Session("Ref-7F9E9F49-22F0-4787-B646-FD1A84311164"), System.Collections.Queue)
        End Get
        Set(ByVal value As System.Collections.Queue)
            Session("Ref-7F9E9F49-22F0-4787-B646-FD1A84311164") = value
        End Set
    End Property
#End Region

    Public Sub StampaReferto()
        Try
            '
            ' Nascondo la griglia per evitare di vedere i dati della stampa precedente
            '
            GridViewStatoStampa.Visible = False
            '
            ' Recupero la lista dei dei referti da stampare
            '
            'Dim oRefSel As System.Collections.Specialized.StringCollection = PrintUtil.SessionRefertiDaStampare()
            Dim oRefSel As List(Of PrintUtil.RefertiDaStampare) = PrintUtil.SessionRefertiDaStampare
            If oRefSel Is Nothing OrElse oRefSel.Count = 0 Then
                Throw New Exception("L'elenco dei referti da stampare è obbligatorio")
            End If

            '
            ' Copio in una coda 
            '
            Dim oQueue As New System.Collections.Queue()
            For Each s In oRefSel
                oQueue.Enqueue(s)
            Next
            RefertiDaSottomettere = oQueue
            '
            ' cancello i dati in sessione
            '
            PrintUtil.SessionRefertiDaStampare().Clear()
            '
            ' Cancello anche l'oggetto VsRefertiInStampa (visto che sono partito dall'inizio)
            ' Questo fa si che ad ogni ripartenza vedo solo i documenti dei referti appena sottomessi (FONDAMENTALE)
            '
            If Not DocumentiSottomessi Is Nothing Then
                DocumentiSottomessi.Clear()
            End If
            '**********************************************************************************************
            '
            ' Visualizzo l'utente corrente
            '
            lblUtente.Text = HttpContext.Current.User.Identity.Name
            '
            ' Leggo la stampante da utilizzare
            '
            Dim sUserAccount As String = HttpContext.Current.User.Identity.Name
            Dim sPrinterServerName As String = PrinterServerName
            Dim sPrinterName As String = PrinterName
            If Not String.IsNullOrEmpty(sPrinterServerName) AndAlso Not String.IsNullOrEmpty(sPrinterName) Then
                '
                ' Visualizzo le informazioni sulla stampante
                '
                Dim sPrinterInfo As String = PrinterServerName & "\" & PrinterName
                If sPrinterInfo.Length > 45 Then
                    lblPrinterInfo.Text = sPrinterInfo.Substring(0, 42) & "..."
                Else
                    lblPrinterInfo.Text = sPrinterInfo
                End If
                lblPrinterInfo.ToolTip = sPrinterInfo
                '
                ' Messaggio iniziale...
                '
                divAttesaStampa.Visible = True
                lblUserMessage.Text = USER_MESSAGE_WAIT
                '
                ' Disabilito il pulsante di uscita; il timer lo riabilita dopo la sottomissione
                '
                cmdEsci.Enabled = False
                '
                ' Posso stampare: imposto il timer ad un tempo breve fissato
                ' NON AVENDO IL PULSANTE DI STAMPA IMPOSTO IL TIMER AD UN TEMPO BREVE PREFISSATO DI 1000 ms
                '
                TimerStampeRefresh.Interval = 1000 ' 1 secondo
                TimerStampeRefresh.Enabled = True
            Else
                lblErrorMessage.Text = "Non è configurata nessuna stampante!"
                divAttesaStampa.Visible = False
            End If

        Catch ex As Exception
            lblErrorMessage.Text = "Errore durante il caricamento della pagina!"
            Logging.WriteError(ex, Me.GetType.Name)
            '
            ' Disabilito il timer
            '
            TimerStampeRefresh.Enabled = False
        End Try
    End Sub

    Protected Sub TimerStampeRefresh_Tick(ByVal sender As Object, ByVal e As System.EventArgs) Handles TimerStampeRefresh.Tick
        Dim bErrorSottomissione As Boolean = False
        Dim bEndPrinting As Boolean = False
        Try
            '
            ' Disabilito il timer
            '
            TimerStampeRefresh.Enabled = False
            '
            ' Scrivo Data e Ora
            '
            lblDataOra.Text = Now.ToString
            '
            ' Se devo sottomettere alla stampa...
            '
            If RefertiDaSottomettere.Count > 0 Then
                Try
                    Call SottomettoDocumenti_TuttiGliAllegati()
                    '
                    ' Modifico l'intervallo del timer al valore configurato
                    '
                    TimerStampeRefresh.Interval = CType(My.Settings.StampaReferti_UiStampeRefreshInterval_Ms, Integer)
                    '
                    ' Ho sottomesso le stampe, posso anche uscire
                    '
                    cmdEsci.Enabled = True

                Catch ex As Exception
                    lblErrorMessage.Text = "Errore durante la sottomissione della stampa!"
                    Logging.WriteError(ex, Me.GetType.Name)
                    '
                    ' Se errore -> il timer non viene più riattivato
                    '
                    bErrorSottomissione = True
                End Try

            Else
                '
                ' Aggiornamento dello stato della stampa
                '
                If Not DocumentiSottomessi Is Nothing Then
                    Call AggiornoStatoStampe()
                End If
            End If
            '
            ' Faccio sempre il Bind della griglia
            '
            If Not DocumentiSottomessi Is Nothing Then
                '
                ' A questo punto potrei eliminare dalla lista dei referti sottomessi quelli che risultano stampati
                ' da un certo intervallo di tempo
                '
                Call DocumentiSottomessiRemove()
                '
                '
                '
                If DocumentiSottomessi.Count > 0 Then
                    divAttesaStampa.Visible = False
                    GridViewStatoStampa.Visible = True
                    GridViewStatoStampa.DataSource = DocumentiSottomessi
                    GridViewStatoStampa.DataBind()
                Else
                    GridViewStatoStampa.Visible = False
                    divAttesaStampa.Visible = True
                    lblUserMessage.Text = USER_MESSAGE_END_PRINTING
                    bEndPrinting = True
                End If
            Else
                GridViewStatoStampa.Visible = False
                divAttesaStampa.Visible = True
                lblUserMessage.Text = USER_MESSAGE_SESSION_TIMEOUT
                bEndPrinting = True
            End If
            '
            ' Tolgo il messaggio di uscita
            '
            If bEndPrinting Then
                'cmdEsci.OnClientClick = cmdEsciClientClickCode(False)
            End If

        Catch ex As Exception
            lblErrorMessage.Text = "Errore durante il monitoraggio dello stato della stampa!"
            Logging.WriteError(ex, Me.GetType.Name)

        Finally
            If (Not bErrorSottomissione) AndAlso (Not bEndPrinting) Then
                '
                ' Riabilito il timer
                '
                TimerStampeRefresh.Enabled = True
            End If
        End Try
    End Sub

    Protected Sub cmdEsci_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdEsci.Click
        Try
            '
            ' Disabilito il Timer
            '
            TimerStampeRefresh.Enabled = False

            '
            ' Registro uno script lato client per chiudere la modale
            '
            Dim functionJS As String = "$('#ModalStampa').modal('hide');"
            ScriptManager.RegisterStartupScript(Page, Page.GetType, "LanchServerSide", functionJS, True)
        Catch ex As Exception
            lblErrorMessage.Text = String.Format("Errore durante pressione pulsante '{0}'!", cmdEsci.Text)
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub


#Region "Sottomissione/Aggiornamento stato stampa"
    Private Function SottomettoDocumenti_TuttiGliAllegati() As Boolean
        Dim sErrore As String = String.Empty
        Dim oWs As WsPrintManager.Ver1SoapClient = Nothing
        Dim oWsRendering As WsRenderingPdf.RenderingPdfSoap = Nothing
        Dim sUserAccount As String = HttpContext.Current.User.Identity.Name
        Dim sTemplateUrlDettaglioreferto As String = String.Empty
        Dim oRefertoDaStampare As PrintUtil.RefertiDaStampare = Nothing
        Dim sIdReferto As String = String.Empty
        '
        ' Lista temporanea per costruire gli oggetti rappresentanti le stampe sottomesse
        '
        Dim oDocumentiSottomessi As New Generic.List(Of PrintUtil.StampeDocumentoReferto)
        '
        '
        '
        Try

            sTemplateUrlDettaglioreferto = My.Settings.WsRenderingPdf_UrlDettaglioReferto
            '
            ' Instanzio WebService del PrintManager
            '
            oWs = New WsPrintManager.Ver1SoapClient
            Call PrintUtil.InitWsPrintManager(oWs)
            oWsRendering = New WsRenderingPdf.RenderingPdfSoapClient
            Call PrintUtil.InitWsRenderingPdf(oWsRendering)
            '
            ' Per ogni referto da stampare che ho memorizzato nel ViewState...
            '
            Dim iCounter As Integer = 0
            Do While RefertiDaSottomettere.Count > 0
                oRefertoDaStampare = RefertiDaSottomettere.Dequeue()
                iCounter = iCounter + 1

                Try
                    sErrore = String.Empty
                    sIdReferto = oRefertoDaStampare.IdReferto.ToString

                    '
                    ' Cerco gli allegati del referto.
                    ' 
                    Dim ds As New CustomDataSource.RefertoPdfOttieniPerId()
                    Dim oAllegati As WcfDwhClinico.AllegatiPdfType = ds.GetData(Me.Token, New Guid(sIdReferto), WcfDwhClinico.RefertoPdfModalitaEnum.PdfOppureRendering)

                    '
                    ' Sottometto al print manager
                    '
                    If Not oAllegati Is Nothing AndAlso oAllegati.Count > 0 Then
                        '
                        ' Ci sono uno o più allegati: li mando in stampa tutti
                        '
                        For Each oAllegato As WcfDwhClinico.AllegatoPdfType In oAllegati
                            Dim oPDFByte As Byte() = oAllegato.Contenuto
                            '
                            ' Ricavo le info relative al referto
                            '
                            Dim oStampeDocumento As New PrintUtil.StampeDocumentoReferto(sIdReferto)
                            Call InizializzoInfoDocumentoReferto(oStampeDocumento, oRefertoDaStampare)
                            '
                            ' Aggiungo alla lista
                            '
                            oDocumentiSottomessi.Add(oStampeDocumento)
                            '
                            ' Sottometto i byte del documento alla stampa
                            '
                            Dim oJobGuid As System.Guid = PrintUtil.PrintPdfDocument(oWs, oPDFByte, PrinterServerName, PrinterName, oStampeDocumento.JobName)
                            If oJobGuid <> Nothing Then
                                '
                                ' Salvo nella mia struttura assieme a tutte le altre informazioni
                                ' 
                                oStampeDocumento.IdJob = oJobGuid.ToString
                                oStampeDocumento.Stato = PrintUtil.StampeStato.Sottomessa
                                oStampeDocumento.DataSottomissione = Now()
                            Else
                                Dim sNomeFile As String = String.Empty
                                If Not String.IsNullOrEmpty(oAllegato.NomeFile) Then sNomeFile = oAllegato.NomeFile
                                Dim sDescrizione As String = String.Empty
                                If Not String.IsNullOrEmpty(oAllegato.Descrizione) Then sDescrizione = oAllegato.Descrizione
                                sErrore = String.Format("Errore durante la sottomissione alla stampa dell'allegato con NomeFile='{0}', Descrizione='{1}'", sNomeFile, sDescrizione)
                                oStampeDocumento.Errore = sErrore
                                Throw New Exception(sErrore & String.Format(", IdAllegato='{0}'", oAllegato.Id))
                            End If
                        Next
                    Else
                        Throw New Exception("Non è stato possibile ricavare gli allegati del referto.")
                    End If

                Catch ex As Exception
                    '
                    ' Eccezione su singolo elemento del ciclo
                    '
                    Logging.WriteError(ex, String.Format("Durante la sottomissione alla stampa: IdReferto={0}", sIdReferto))
                End Try
            Loop
            '
            ' Salvo...
            '
            If DocumentiSottomessi Is Nothing Then
                DocumentiSottomessi = oDocumentiSottomessi
            Else
                DocumentiSottomessi.AddRange(oDocumentiSottomessi)
            End If

            '
            '
            '
            Return True

        Catch ex As Exception
            Throw

        Finally
            If Not oWs Is Nothing Then
                oWs = Nothing
            End If
            If Not oWsRendering Is Nothing Then
                oWsRendering = Nothing
            End If
        End Try
    End Function

    ''' <summary>
    ''' Aggiornamento dello stato delle stampe
    ''' </summary>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Private Function AggiornoStatoStampe() As Integer
        Dim AggiornamentiCounter As Integer = 0
        '
        ' Per tutti i referti selezionati dall'utente devo ricavare i byte del referto e sottometterli al PrintManager
        '
        Dim oWs As WsPrintManager.Ver1SoapClient = Nothing
        Try
            '
            ' Instanzio WebService del PrintManager
            '
            oWs = New WsPrintManager.Ver1SoapClient
            Call PrintUtil.InitWsPrintManager(oWs)
            '
            ' Per ogni referto in stampa...
            '
            Dim oDocumentiSottomessi As Generic.List(Of PrintUtil.StampeDocumentoReferto) = DocumentiSottomessi
            For Each oRefertoInStampa As PrintUtil.StampeDocumentoReferto In oDocumentiSottomessi
                Try
                    If Not String.IsNullOrEmpty(oRefertoInStampa.IdJob) AndAlso
                            String.IsNullOrEmpty(oRefertoInStampa.Errore) AndAlso
                                Not (oRefertoInStampa.Stato = PrintUtil.StampeStato.Terminata OrElse
                                    oRefertoInStampa.Stato = PrintUtil.StampeStato.Cancellata) Then
                        '
                        ' Interrogo il PrintManager
                        '
                        Dim oInfo As JobInfo = oWs.JobEnumById(New Guid(oRefertoInStampa.IdJob))
                        If oInfo Is Nothing Then
                            '
                            ' Segnalo nell'event log come Errore
                            '
                            Dim sMsgLog As String = String.Format("AggiornoStatoStampa(): JobEnumById() ha restituito nothing per IdJob '{0}'.)", oRefertoInStampa.IdJob)
                            Logging.WriteError(Nothing, sMsgLog)
                            '
                            ' Cosi la volta successiva non viene riprocessato
                            '
                            oRefertoInStampa.Errore = "Impossibile ottenere informazioni per il Job di stampa"

                        Else
                            '
                            ' Eseguo un lookup dello stato: aggiorno oRefertoInStampa con il nuovo stato/errore
                            '
                            Call AggiornamentoStatoStampaLookUpStato(oInfo, oRefertoInStampa)
                            AggiornamentiCounter = AggiornamentiCounter + 1

                        End If
                    End If

                Catch ex As Exception
                    Logging.WriteError(ex, String.Format("Durante la lettura dello stato della stampa per il Job='{0}', IdReferto={1}", oRefertoInStampa.IdJob, oRefertoInStampa.IdReferto))

                End Try
            Next

        Catch ex As Exception
            lblErrorMessage.Text = "Errore durante la lettura dello stato della stampa!"
            Logging.WriteError(ex, Me.GetType.Name)

        Finally
            If Not oWs Is Nothing Then
                oWs = Nothing
            End If

        End Try
        '
        ' Restituisco il numero di aggiornamenti
        '
        Return AggiornamentiCounter
    End Function


    ''' <summary>
    ''' Aggiornamento dello stato della singola stampa
    ''' </summary>
    ''' <param name="oInfo"></param>
    ''' <param name="oDocInStampa"></param>
    ''' <remarks></remarks>
    Private Sub AggiornamentoStatoStampaLookUpStato(ByVal oInfo As JobInfo, ByVal oDocInStampa As PrintUtil.StampeDocumentoReferto)
        '
        '
        '
        Dim iStampeCodaStato As PrintUtil.StampeStato = PrintUtil.StampeStato.Sottomessa
        Dim sErrore As String = String.Empty
        Dim sStatus As String = oInfo.JobStatus
        '
        ' Controllo il nothing dello status e lo segnalo
        '
        If String.IsNullOrEmpty(sStatus) Then
            Dim sMsgLog As String = String.Format("AggiornoStatoStampa(): JobStatus per IdJob '{0}' relativo al referto '{1}' è nothing.)", oDocInStampa.IdJob, oDocInStampa.IdReferto)
            Logging.WriteWarning(sMsgLog)
        End If
        '
        ' Eseguo il Look up 
        '
        iStampeCodaStato = PrintUtil.LookUpStatoJobDiStampa(CType(oInfo, Object), sErrore)
        '
        ' Scrivo nella coda del Dwh lo stato della stampa
        '
        If Not String.IsNullOrEmpty(sErrore) Then
            '
            ' Segnalo nell'event log come Errore
            '
            Dim sMsgLog As String = String.Format("Errore associato alla stampa con IdJob '{0}', IdReferto '{1}': {2}.)", oDocInStampa.IdJob, oDocInStampa.IdReferto, sErrore)
            Logging.WriteError(Nothing, sMsgLog)
            '
            ' Aggiorno la mia lista di stampa
            '
            oDocInStampa.Errore = sErrore

        ElseIf iStampeCodaStato = PrintUtil.StampeStato.Terminata Then
            '
            ' Segnalo nell'event log come Information
            '
            Dim sMsgLog As String = String.Format("La stampa con IdJob '{0}', IdReferto '{1}' è stata completata.)", oDocInStampa.IdJob, oDocInStampa.IdReferto)
            Logging.WriteInformation(sMsgLog)

        ElseIf iStampeCodaStato = PrintUtil.StampeStato.Cancellata Then
            Dim sMsgLog As String = String.Format("La stampa con IdJob '{0}', IdReferto '{1}' è stata cancellata.)", oDocInStampa.IdJob, oDocInStampa.IdReferto)
            Logging.WriteInformation(sMsgLog)

        ElseIf iStampeCodaStato = PrintUtil.StampeStato.InPausa Then
            Dim sMsgLog As String = String.Format("La stampa con IdJob '{0}', IdReferto '{1}' è stata messa in pausa.)", oDocInStampa.IdJob, oDocInStampa.IdReferto)
            Logging.WriteInformation(sMsgLog)
        End If
        '
        ' Scrivo nella mia struttura lo stato
        '
        oDocInStampa.Stato = iStampeCodaStato

    End Sub

    Private Sub InizializzoInfoDocumentoReferto(ByVal oStampeDocumento As PrintUtil.StampeDocumentoReferto, oRefertoDaStampare As PrintUtil.RefertiDaStampare)
        Using oStampe As New Stampe
            If Not oRefertoDaStampare Is Nothing Then
                oStampeDocumento.JobName = String.Format("{0}-{1}-{2}", oRefertoDaStampare.AziendaErogante, oRefertoDaStampare.SistemaErogante, oRefertoDaStampare.NumeroReferto)
                If String.IsNullOrEmpty(oStampeDocumento.JobName) Then
                    oStampeDocumento.JobName = "DWH"
                End If
                oStampeDocumento.AziendaErogante = oRefertoDaStampare.AziendaErogante
                oStampeDocumento.SistemaErogante = oRefertoDaStampare.SistemaErogante
                If Not String.IsNullOrEmpty(oRefertoDaStampare.NumeroNosologico) Then
                    oStampeDocumento.NumeroNosologico = oRefertoDaStampare.NumeroNosologico
                End If
                If Not String.IsNullOrEmpty(oRefertoDaStampare.NumeroReferto) Then
                    oStampeDocumento.NumeroReferto = oRefertoDaStampare.NumeroReferto
                End If
                If Not String.IsNullOrEmpty(oRefertoDaStampare.Cognome) Then
                    oStampeDocumento.Cognome = oRefertoDaStampare.Cognome
                End If
                If Not String.IsNullOrEmpty(oRefertoDaStampare.Nome) Then
                    oStampeDocumento.Nome = oRefertoDaStampare.Nome
                End If
            End If
        End Using
    End Sub


    ''' <summary>
    ''' Dopo un certo tempo rimuove dalla lista dei documenti sottomessi quelli la cui stampa è terminata o sono in errore
    ''' </summary>
    ''' <remarks></remarks>
    Private Sub DocumentiSottomessiRemove()
        Try
            Dim oDocList As Generic.List(Of PrintUtil.StampeDocumentoReferto) = DocumentiSottomessi
            If Not oDocList Is Nothing Then
                For i As Integer = oDocList.Count - 1 To 0 Step -1
                    Dim oItem As PrintUtil.StampeDocumentoReferto = oDocList(i)
                    Dim oNow As DateTime = Now()
                    If oItem.Stato = PrintUtil.StampeStato.Terminata And oNow > oItem.DataSottomissione.AddMinutes(5) Then
                        oDocList.RemoveAt(i)
                    ElseIf Not String.IsNullOrEmpty(oItem.Errore) And oNow > oItem.DataSottomissione.AddMinutes(10) Then
                        oDocList.RemoveAt(i)
                    ElseIf oNow > oItem.DataSottomissione.AddMinutes(20) Then
                        oDocList.RemoveAt(i)
                    End If
                Next
            End If
        Catch
        End Try
    End Sub

#End Region

#Region "Funzioni Utilizzate Nel Markup"

    Protected Function LookUpImgStatoCoda(ByVal Stato As Object, ByVal Errore As Object) As String
        Dim sRet As String = ""
        Dim iStato As PrintUtil.StampeStato = CType(Stato, PrintUtil.StampeStato)
        If Errore Is DBNull.Value OrElse Trim(Errore).Length = 0 Then
            Select Case iStato
                Case PrintUtil.StampeStato.Sottomessa
                    sRet = Me.ResolveUrl("~/Images/Printer.gif")
                Case PrintUtil.StampeStato.Terminata
                    sRet = Me.ResolveUrl("~/Images/Print_Ok.gif")
                Case PrintUtil.StampeStato.Cancellata
                    sRet = Me.ResolveUrl("~/Images/Print_Canceled.gif")
                Case PrintUtil.StampeStato.InPausa
                    sRet = Me.ResolveUrl("~/Images/Print_Paused.gif")
                Case Else
                    sRet = Me.ResolveUrl("~/Images/blank.gif")
            End Select
        Else
            sRet = Me.ResolveUrl("~/Images/Print_Err.gif")
        End If
        Return sRet
    End Function

    Protected Function LookUpImgStatoCodaTooltip(ByVal Stato As Object, ByVal Errore As Object) As String
        Dim sRet As String = ""
        Dim iStato As PrintUtil.StampeStato = CType(Stato, PrintUtil.StampeStato)
        If Errore Is DBNull.Value OrElse Trim(Errore).Length = 0 Then
            Select Case iStato
                Case PrintUtil.StampeStato.Sottomessa
                    sRet = "In stampa"
                Case PrintUtil.StampeStato.Terminata
                    sRet = "Terminata"
                Case PrintUtil.StampeStato.DaSottomettere
                    sRet = "Da sottomettere"
                Case PrintUtil.StampeStato.Cancellata
                    sRet = "Stampa cancellata"
                Case PrintUtil.StampeStato.InPausa
                    sRet = "Stampa in pausa"
                Case Else
                    sRet = ""
            End Select
        Else
            sRet = Errore
        End If
        Return sRet
    End Function

#End Region

#Region "GridViewStatoStampa"
    Private Sub GridViewStatoStampa_PreRender(sender As Object, e As EventArgs) Handles GridViewStatoStampa.PreRender
        '
        'Render per Bootstrap
        'Crea la Table con Theader e Tbody se l'header non è nothing.
        '
        If Not GridViewStatoStampa.HeaderRow Is Nothing Then
            GridViewStatoStampa.UseAccessibleHeader = True
            GridViewStatoStampa.HeaderRow.TableSection = TableRowSection.TableHeader
        End If
    End Sub

    Protected Sub GridViewStatoStampa_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs) Handles GridViewStatoStampa.PageIndexChanging
        Dim oGridView As GridView = Nothing
        Try
            If Not DocumentiSottomessi Is Nothing Then
                oGridView = DirectCast(sender, GridView)
                oGridView.PageIndex = e.NewPageIndex
                oGridView.DataSource = DocumentiSottomessi
                oGridView.DataBind()
            End If
        Catch ex As Exception
            lblErrorMessage.Text = "Errore durante la paginazione della lista!"
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

#End Region

End Class
