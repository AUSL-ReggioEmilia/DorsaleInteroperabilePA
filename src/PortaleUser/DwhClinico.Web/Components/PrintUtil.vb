Imports Microsoft.VisualBasic
Imports DwhClinico.Web
Imports DwhClinico.Web.DwhClinico.Web
Imports DwhClinico.Data
Imports DwhClinico.Web.WsPrintManager


Public Class PrintUtil

#Region "Configurazione di stampa"

    Public Enum CustomErrorCode
        InvalidPrinterName = 100
        UnknownPrinterDriver = 101
    End Enum

    <Serializable()> _
    Public Class PrintingConfig
        Public ConfigType As Integer
        Public PrinterServerName As String
        Public PrinterName As String

        Public Sub New()
        End Sub
        ''' <summary>
        ''' Da usare per salvare su database: deve essere correttamente valorizzato anche ConfigType (vedi ConfiguraStampante.aspx)
        ''' </summary>
        ''' <param name="PrinterServerName"></param>
        ''' <param name="Printername"></param>
        ''' <param name="ConfigType">0=NET Printer, 1=Personal printer, 2=Local printer</param>
        ''' <remarks></remarks>
        Public Sub New(ByVal PrinterServerName As String, ByVal Printername As String, ByVal ConfigType As Integer)
            Me.ConfigType = ConfigType
            Me.PrinterServerName = PrinterServerName
            Me.PrinterName = Printername
        End Sub
        ''' <summary>
        ''' Da NON usare per salvare su database
        ''' </summary>
        ''' <param name="PrinterServerName"></param>
        ''' <param name="Printername"></param>
        ''' <remarks></remarks>
        Public Sub New(ByVal PrinterServerName As String, ByVal Printername As String)
            Me.ConfigType = -1 'significa che non è una configurazione utente fatta tramite la pagina ConfiguraStampante.aspx
            Me.PrinterServerName = PrinterServerName
            Me.PrinterName = Printername
        End Sub

    End Class

    Public Shared Sub SetUserPrintingConfig(ByVal oPrintingConfig As PrintingConfig)
        If Not oPrintingConfig Is Nothing Then
            Dim sUserAccount As String = HttpContext.Current.User.Identity.Name
            Dim sUserHostName As String = "\\" & Utility.GetUserHostName().TrimStart("\\")
            Call SaveDbUserPrintingConfig(sUserAccount, sUserHostName, oPrintingConfig.ConfigType, oPrintingConfig.PrinterServerName, oPrintingConfig.PrinterName)
        End If
    End Sub

    Public Shared Function GetUserPrintingConfig() As PrintingConfig

        Dim oPrintingConfig As PrintingConfig = Nothing
        Try
            Dim sUserAccount As String = HttpContext.Current.User.Identity.Name
            Dim sUserHostName As String = "\\" & Utility.GetUserHostName().TrimStart("\\")
            Dim oRow As StampeDataset.FevsStampeConfigurazioniStampaDettaglioRow = GetDbUserPrintingConfig(sUserAccount, sUserHostName)
            If oRow Is Nothing Then
                '
                ' Lo faccio per compatibilità perchè nel database ci sono gli indirizzi IP e ora la funzione Utility.GetUserHostName() restituisce il nome del PC
                '
                sUserHostName = "\\" & Utility.GetUserHostIP().TrimStart("\\")
                oRow = GetDbUserPrintingConfig(sUserAccount, sUserHostName)
            End If
            If Not oRow Is Nothing Then
                oPrintingConfig = New PrintingConfig
                oPrintingConfig.ConfigType = oRow.TipoConfigurazione
                oPrintingConfig.PrinterServerName = oRow.ServerDiStampa
                oPrintingConfig.PrinterName = oRow.Stampante
            End If
        Catch ex As Exception
            'non faccio nulla
        End Try
        Return oPrintingConfig

    End Function

    Private Shared Function GetDbUserPrintingConfig(ByVal sUserAccount As String, ByVal sUserHostname As String) As StampeDataset.FevsStampeConfigurazioniStampaDettaglioRow
        Using oStampe As Stampe = New Stampe()
            Using oTa As StampeDataset.FevsStampeConfigurazioniStampaDettaglioDataTable = _
                    oStampe.StampeConfigurazioniDettaglio(sUserAccount, sUserHostname)
                If Not oTa Is Nothing AndAlso oTa.Rows.Count > 0 Then
                    Return oTa(0)
                End If
            End Using
        End Using
        Return Nothing
    End Function

    Private Shared Sub SaveDbUserPrintingConfig(ByVal sUserAccount As String, ByVal sUserHostName As String, ByVal iTipoConfigurazione As Integer, ByVal sServerDiStampa As String, ByVal sStampante As String)
        Using oStampe As Stampe = New Stampe()
            oStampe.StampeConfigurazioniAggiorna(sUserAccount, sUserHostName, iTipoConfigurazione, sServerDiStampa, sStampante)
        End Using
    End Sub

    Public Shared Sub ConfigPrintButton(ByVal btn As Button, ByVal bCanPrint As Boolean)
        'MODIFICA ETTORE 2016-11-24: l'abilitazione del pulsante di stampa NON DIPENDE dalla presenza della configurazione di stampa
        Try
            btn.Visible = bCanPrint
            btn.Enabled = True
        Catch
        End Try
    End Sub

#End Region


    ''' <summary>
    ''' Inizializzazione del ws di stampa + impostazione delle credenziali
    ''' </summary>
    ''' <param name="oWs"></param>
    ''' <remarks></remarks>
    Public Shared Sub InitWsPrintManager(ByVal oWs As WsPrintManager.Ver1SoapClient)
        Dim sUser As String = My.Settings.WsPrintManager_User
        Dim sPassword As String = My.Settings.WsPrintManager_Password

        Utility.SetWCFCredentials(oWs.ChannelFactory.Endpoint.Binding, oWs.ClientCredentials, sUser, sPassword)
    End Sub


    ''' <summary>
    ''' Inizializzazione del webservice per il rendering HTML->PDF
    ''' </summary>
    ''' <param name="oWs"></param>
    ''' <remarks></remarks>
    Public Shared Sub InitWsRenderingPdf(ByVal oWs As WsRenderingPdf.RenderingPdfSoapClient)

        Dim sUser As String = My.Settings.WsRenderingPdf_User
        Dim sPassword As String = My.Settings.WsRenderingPdf_Password
        Utility.SetWCFCredentials(oWs.ChannelFactory.Endpoint.Binding, oWs.ClientCredentials, sUser, sPassword)

    End Sub

    Public Shared Function PrintPdfDocument(ByVal oWs As WsPrintManager.Ver1SoapClient, ByVal oBytes As Byte(), ByVal sPrinterServer As String, ByVal sPrinterName As String, ByVal sJobName As String) As System.Guid
        Dim oJobGuid As System.Guid = Nothing
        Dim oImpersonationContext As System.Security.Principal.WindowsImpersonationContext = Nothing
        Try
            '
            ' L'utente che richiede la stampa
            '
            Dim sUserSubmitter As String = HttpContext.Current.User.Identity.Name

            oImpersonationContext = New LogonUser().Impersonate()

            oJobGuid = oWs.JobAddPdfDocument(sPrinterServer, sPrinterName, sJobName, sUserSubmitter, oBytes)
            If oImpersonationContext IsNot Nothing Then
                oImpersonationContext.Undo()
                oImpersonationContext.Dispose()
                oImpersonationContext = Nothing
            End If
            '
            '
            '
            Return oJobGuid

        Catch ex As System.Web.Services.Protocols.SoapException
            '
            ' Messaggio di errore
            '
            Dim sMsgErr As String = "Errore:" & vbCrLf & ex.Message & vbCrLf &
                                    "Dettaglio:" & vbCrLf & ex.Detail.InnerText() & vbCrLf &
                                    "StackTrace:" & vbCrLf & ex.StackTrace
            Logging.WriteError(ex, sMsgErr)
            Throw
        Catch ex As Exception
            Dim sMsgErr As String = Utility.FormatException(ex)
            Logging.WriteError(ex, sMsgErr)
            Throw
        Finally
            '
            ' Ripristino WindowsIdentity iniziale
            '
            If oImpersonationContext IsNot Nothing Then
                oImpersonationContext.Undo()
                oImpersonationContext.Dispose()
                oImpersonationContext = Nothing
            End If
        End Try
    End Function

    Public Shared Function PrintTestPage(ByVal oWs As WsPrintManager.Ver1SoapClient, ByVal sPrinterServer As String, ByVal sPrinterName As String, ByVal sJobName As String) As JobInfo
        Dim oJobGuid As System.Guid = Nothing
        Dim oImpersonationContext As System.Security.Principal.WindowsImpersonationContext = Nothing
        Try
            '
            ' L'utente che richiede la stampa
            '
            Dim sUserSubmitter As String = HttpContext.Current.User.Identity.Name

            oImpersonationContext = (New LogonUser()).Impersonate()
            '
            ' Questo metodo crea un PDF al volo e aspetta per 1 minuto al max il risultato della stampa
            '
            Dim oJobInfo As JobInfo = oWs.PrintTestPage(sPrinterServer, sPrinterName, sJobName, sUserSubmitter, "Dwh Clinico")

            If oImpersonationContext IsNot Nothing Then
                oImpersonationContext.Undo()
                oImpersonationContext.Dispose()
                oImpersonationContext = Nothing
            End If
            '
            '
            '
            Return oJobInfo

        Catch ex As System.Web.Services.Protocols.SoapException
            '
            ' Messaggio di errore
            '
            Dim sMsgErr As String = "Errore:" & vbCrLf & ex.Message & vbCrLf & _
                                    "Dettaglio:" & vbCrLf & ex.Detail.InnerText() & vbCrLf & _
                                    "StackTrace:" & vbCrLf & ex.StackTrace
            Logging.WriteError(ex, sMsgErr)
            Throw
        Catch ex As Exception
            Dim sMsgErr As String = Utility.FormatException(ex)
            Logging.WriteError(ex, sMsgErr)
            Throw
        Finally
            '
            ' Ripristino WindowsIdentity iniziale
            '
            If oImpersonationContext IsNot Nothing Then
                oImpersonationContext.Undo()
                oImpersonationContext.Dispose()
                oImpersonationContext = Nothing
            End If
        End Try
    End Function

    Public Shared Function LookUpStatoJobDiStampa(ByVal oInfo As JobInfo, ByRef sErrore As String) As PrintUtil.StampeStato
        '
        ' ATTENZIONE: La proprietà oInfo.JobStatus viene scritta nel formato "Stato1|Stato2|...|StatoN"
        ' Quindi bisogna cercare lo stato di interesse in base ad una priorità: prima se Deleted, Paused, Completed...
        '
        Dim iStampeCodaStato As PrintUtil.StampeStato = PrintUtil.StampeStato.Sottomessa
        Dim sStatus As String = oInfo.JobStatus
        sErrore = String.Empty
        '
        ' Controllo il nothing dello status
        '
        If String.IsNullOrEmpty(sStatus) Then
            sStatus = String.Empty
        End If

        If Not String.IsNullOrEmpty(oInfo.ErrorConverted) Then
            '
            ' C'è stato un errore durante la conversione
            '
            sErrore = oInfo.ErrorConverted

        ElseIf (Not String.IsNullOrEmpty(oInfo.ErrorPrinted)) _
                AndAlso oInfo.ErrorPrinted.ToUpper = "JOB NON PIÙ IN CODA" _
                AndAlso sStatus.ToUpper.Contains("COMPLETATO NON CONFERMATO") Then
            '
            ' In questo caso segnalo che la stampa è terminata correttamente
            '
            iStampeCodaStato = PrintUtil.StampeStato.Terminata

        ElseIf Not String.IsNullOrEmpty(oInfo.ErrorPrinted) Then
            '
            ' C'è stato un errore durante la stampa
            '
            sErrore = oInfo.ErrorPrinted

            If String.Compare(String.Format("[{0}]", CInt(PrintUtil.CustomErrorCode.InvalidPrinterName)), sErrore, True) > 0 Then
                sErrore = "Il nome della stampante non è valido."

            ElseIf String.Compare(String.Format("[{0}]", CInt(PrintUtil.CustomErrorCode.UnknownPrinterDriver)), sErrore, True) > 0 Then
                sErrore = "Non è presente il driver della stampante. Installare il driver!"

            End If

        Else
            '
            ' Controllo lo stato
            '
            Select Case sStatus.ToUpper
                Case "COMPLETATO NON CONFERMATO"
                    iStampeCodaStato = PrintUtil.StampeStato.Terminata
                Case "JOB IN QUEUE"
                    iStampeCodaStato = PrintUtil.StampeStato.Sottomessa
                Case "ERROR IN QUEUE"
                    sErrore = "Errore nella coda di stampa"
                Case Else
                    If sStatus.Contains([Enum].GetName(GetType(System.Printing.PrintJobStatus), System.Printing.PrintJobStatus.Deleted)) Then
                        'sErrore = "La stampa è stata cancellata"
                        iStampeCodaStato = PrintUtil.StampeStato.Cancellata
                    ElseIf sStatus.Contains([Enum].GetName(GetType(System.Printing.PrintJobStatus), System.Printing.PrintJobStatus.Paused)) Then
                        iStampeCodaStato = PrintUtil.StampeStato.InPausa
                    ElseIf sStatus.Contains([Enum].GetName(GetType(System.Printing.PrintJobStatus), System.Printing.PrintJobStatus.Completed)) Then
                        iStampeCodaStato = PrintUtil.StampeStato.Terminata
                    ElseIf sStatus.Contains([Enum].GetName(GetType(System.Printing.PrintJobStatus), System.Printing.PrintJobStatus.Offline)) Then
                        sErrore = "La stampante è OffLine"
                    ElseIf sStatus.Contains([Enum].GetName(GetType(System.Printing.PrintJobStatus), System.Printing.PrintJobStatus.PaperOut)) Then
                        sErrore = "La stampante è in PaperOut"
                    ElseIf sStatus.Contains([Enum].GetName(GetType(System.Printing.PrintJobStatus), System.Printing.PrintJobStatus.UserIntervention)) Then
                        sErrore = "La stampante richiede un intervento utente"
                    End If
            End Select
        End If
        Return iStampeCodaStato
    End Function

    Public Shared Function GetPrinterConfigPage(ByVal sIdreferto As String) As String
        ' MODIFICA ETTORE 2016-11-24
        ' Visualizzo pagina di configurazione della stampante
        '
        ' Se sIdreferto è valorizzato la pagina di configurazione mostra nuovi pulsanti
        ' Se sIdreferto NON è valorizzato la pagina di configurazione mostra i pulsanti STANDARD, quelli visualizzati se si naviga con il link "Configura stampante"
        Return String.Format("~/ConfigurazioneStampa.aspx?{0}={1}", Utility.PAR_ID_REFERTO, sIdreferto)
    End Function


    Public Shared Function BuildUrlToPrintByIdReferto(ByVal oPage As Page, ByVal sIdReferto As String) As String
        '
        ' Questa è la funzione che deve determinare l'url da stampare eseguendo il codice presente
        ' in ApreReferto.aspx
        '
        Return BuildUrlToPrintByIdReferto(oPage, sIdReferto, True)
    End Function

    Public Shared Function BuildUrlToPrintByIdReferto(ByVal oPage As Page, ByVal sIdReferto As String, ByVal bEncode As Boolean) As String
        '
        ' Questa è la funzione che deve determinare l'url da stampare eseguendo il codice presente
        ' in ApreReferto.aspx
        '
        Dim sUrlToPrint As String
        sUrlToPrint = oPage.ResolveUrl(String.Format("~/Referti/ApreReferto.aspx?{0}={1}", Utility.PAR_ID_REFERTO, sIdReferto))
        sUrlToPrint = Utility.ConvertRelativeUrlToAbsoluteUrl(sUrlToPrint)
        If bEncode Then
            sUrlToPrint = oPage.Server.UrlEncode(sUrlToPrint)
        End If
        Return sUrlToPrint
    End Function

    Public Shared Function GetBytesRefertoHTML(ByVal oWsRenderingPdf As WsRenderingPdf.RenderingPdfSoapClient, ByVal sUrlReferto As String, ByVal UserAccount As String) As Byte()
        '
        ' Rendering PDF della pagina HTML di dettaglio del referto 
        ' va bene un unico url per entrambi i site?
        '
        Dim oPDFByte As Byte() = Nothing
        Try
            '
            ' L'url del referto da renderizzare
            '
            oPDFByte = oWsRenderingPdf.GetByteReferto(sUrlReferto, UserAccount)

        Catch ex As Exception
            Throw
        End Try
        Return oPDFByte
    End Function


    Public Enum StampeStato
        '
        ' Equivalente allo stato della coda delle sottoscrizioni per ora
        '
        DaSottomettere = 1
        Sottomessa = 2
        Terminata = 3
        Cancellata = 100
        InPausa = 101
    End Enum

    <Serializable()> _
    Public Class StampeDocumentoReferto
        Private _IdReferto As String
        Private _IdJob As String
        Private _JobName As String
        Private _DataInserimento As DateTime   'la data in cui l'utente seleziona il referto
        Private _DataSottomissione As DateTime   'la data in cui inizia il processo di stampa
        Private _Stato As StampeStato
        Private _Cognome As String        'il cognome del paziente
        Private _Nome As String           'il nome del paziente
        Private _AziendaErogante As String
        Private _SistemaErogante As String
        Private _NumeroReferto As String
        Private _NumeroNosologico As String
        Private _Errore As String
        '
        ' Usando le property una lista di tali oggetti è direttamente Bindabile!
        '
        Public Property IdReferto() As String
            Get
                Return _IdReferto
            End Get
            Set(ByVal value As String)
                _IdReferto = value
            End Set
        End Property
        Public Property IdJob() As String
            Get
                Return _IdJob
            End Get
            Set(ByVal value As String)
                _IdJob = value
            End Set
        End Property
        Public Property JobName() As String
            Get
                Return _JobName
            End Get
            Set(ByVal value As String)
                _JobName = value
            End Set
        End Property
        Public Property DataInserimento() As DateTime
            Get
                Return _DataInserimento
            End Get
            Set(ByVal value As DateTime)
                _DataInserimento = value
            End Set
        End Property
        Public Property DataSottomissione() As DateTime
            Get
                Return _DataSottomissione
            End Get
            Set(ByVal value As DateTime)
                _DataSottomissione = value
            End Set
        End Property
        Public Property Stato() As StampeStato
            Get
                Return _Stato
            End Get
            Set(ByVal value As StampeStato)
                _Stato = value
            End Set
        End Property
        Public Property Cognome() As String
            Get
                Return _Cognome
            End Get
            Set(ByVal value As String)
                _Cognome = value
            End Set
        End Property
        Public Property Nome() As String
            Get
                Return _Nome
            End Get
            Set(ByVal value As String)
                _Nome = value
            End Set
        End Property
        Public Property AziendaErogante() As String
            Get
                Return _AziendaErogante
            End Get
            Set(ByVal value As String)
                _AziendaErogante = value
            End Set
        End Property
        Public Property SistemaErogante() As String
            Get
                Return _SistemaErogante
            End Get
            Set(ByVal value As String)
                _SistemaErogante = value
            End Set
        End Property
        Public Property NumeroReferto() As String
            Get
                Return _NumeroReferto
            End Get
            Set(ByVal value As String)
                _NumeroReferto = value
            End Set
        End Property
        Public Property NumeroNosologico() As String
            Get
                Return _NumeroNosologico
            End Get
            Set(ByVal value As String)
                _NumeroNosologico = value
            End Set
        End Property
        Public Property Errore() As String
            Get
                Return _Errore
            End Get
            Set(ByVal value As String)
                _Errore = value
            End Set
        End Property

        Public Sub New(ByVal IdReferto As String)
            _IdReferto = IdReferto
            _DataInserimento = Now()
            _Stato = StampeStato.DaSottomettere
        End Sub

    End Class

    Public Shared Property SessionRefertiDaStampare() As List(Of RefertiDaStampare)
        Get
            Return DirectCast(HttpContext.Current.Session("PrintUtil_SessionRefertiDaStampare"), List(Of RefertiDaStampare))
        End Get
        Set(ByVal value As List(Of RefertiDaStampare))
            HttpContext.Current.Session("PrintUtil_SessionRefertiDaStampare") = value
        End Set
    End Property

    Public Class RefertiDaStampare
        Public IdReferto As Guid
        Public AziendaErogante As String = String.Empty
        Public SistemaErogante As String = String.Empty
        Public Cognome As String = String.Empty
        Public Nome As String = String.Empty
        Public NumeroNosologico As String = String.Empty
        Public NumeroReferto As String = String.Empty
    End Class

#Region "Configurazione di stampa da PrintManager"
    Private Const SESS_PRINTING_CONFIG As String = "printing-config"

    Private Shared Function GetPrintManagerPrintingConfig() As PrintUtil.PrintingConfig
        '
        ' MODIFICA ETTORE 2016-11-24: tolto lettura/salvataggio in sessione (lo faccio nella nuova GetMyPrintingConfig())
        '
        Dim oPmPrintingConfig As PrintUtil.PrintingConfig = Nothing
        Using oWs As New WsPrintManager.Ver1SoapClient
            PrintUtil.InitWsPrintManager(oWs)
            Dim sHostName = Utility.GetUserHostName()
            Dim oQueueInfos As QueueInfo() = oWs.QueueEnumOfComputer(sHostName)
            If (Not oQueueInfos Is Nothing) AndAlso (oQueueInfos.Length > 0) Then
                Dim sFullname As String = oQueueInfos(0).FullName 'Il nome delle coda di stampa nella forma "\\server\stampante"
                sFullname = sFullname.TrimStart("\\")
                Dim oArray As String() = Split(sFullname, "\")
                Dim sPrinterServer As String = "\\" & oArray(0)
                Dim sPrinter As String = oArray(1)
                oPmPrintingConfig = New PrintUtil.PrintingConfig(sPrinterServer, sPrinter)
            End If
        End Using
        Return oPmPrintingConfig
    End Function

    ''' <summary>
    ''' Cancella i dati di configurazione salvati in sessione. La successiva chiamata a GetPrintingConfigFromPrintManager() causerà la rilettura dei dati su PrintManager
    ''' </summary>
    ''' <remarks></remarks>
    Public Shared Sub ReloadMyPrintingConfig()
        HttpContext.Current.Session(SESS_PRINTING_CONFIG) = Nothing
    End Sub

    ''' <summary>
    ''' Restituisce la configurazione di stampa per l'utente corrente; prima legge sul database e se non la trova legge da PrinManager 
    ''' </summary>
    ''' <returns></returns>
    Public Shared Function GetMyPrintingConfig() As PrintUtil.PrintingConfig
        'CREATA DA ETTORE 2016-11-24
        Dim oPrintingConfig As PrintUtil.PrintingConfig = CType(HttpContext.Current.Session(SESS_PRINTING_CONFIG), PrintUtil.PrintingConfig)
        If oPrintingConfig Is Nothing Then
            oPrintingConfig = PrintUtil.GetUserPrintingConfig()
            If oPrintingConfig Is Nothing Then
                oPrintingConfig = PrintUtil.GetPrintManagerPrintingConfig()
            End If
            HttpContext.Current.Session(SESS_PRINTING_CONFIG) = oPrintingConfig
        End If
        '
        ' Restituisco
        '
        Return oPrintingConfig
    End Function

#End Region

End Class
