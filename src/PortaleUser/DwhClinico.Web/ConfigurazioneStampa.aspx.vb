Imports DwhClinico.Data
Imports DwhClinico.Web
Imports DwhClinico.Web.Utility
'Imports System.Printing
Imports DwhClinico.Web.DwhClinico.Web
Imports System.Printing
Imports DwhClinico.Web.WsPrintManager
'----------------------------------------------------------------------------------------------------
' La pagina può essere invocata in due modi differenti:
'   1) Dal menu (idreferto non è valorizzato)
'   2) Dalla lista referti senza passare il parametro IdReferto
'   3) Dal dettaglio del referto passando il parametro IdReferto (in questo caso viene cercato un allegato e viene stampato)
'----------------------------------------------------------------------------------------------------

Partial Class ConfigurazioneStampa
    Inherits System.Web.UI.Page

    Private Property HostName() As String
        Get
            Return DirectCast(ViewState("-HostName-"), String)
        End Get
        Set(ByVal value As String)
            ViewState("-HostName-") = value
        End Set
    End Property

    Private Property CurrentPrintingConfiguration() As String
        Get
            Return DirectCast(ViewState("-CurrentPrintingConfiguration-"), String)
        End Get
        Set(ByVal value As String)
            ViewState("-CurrentPrintingConfiguration-") = value
        End Set
    End Property

    Private Property IdReferto As String
        Get
            Return CType(ViewState("IdReferto"), String)
        End Get
        Set(value As String)
            ViewState("IdReferto") = value
        End Set
    End Property

    Private Property BackUrl As String
        Get
            Return CType(ViewState("BackUrl"), String)
        End Get
        Set(value As String)
            ViewState("BackUrl") = value
        End Set
    End Property

    Private Property MsgNoConfig As String
        Get
            Return CType(ViewState("MsgNoConfig"), String)
        End Get
        Set(value As String)
            ViewState("MsgNoConfig") = value
        End Set
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Try
            If Not Me.IsPostBack Then
                Me.HostName = ""
                '
                ' Visualizzo il messaggio di testata
                '
                Dim sHowToMsg As String = "Selezionare la propria configurazione di stampa. Tale configurazione verrà in seguito utilizzata da questo computer. Se si cambia computer sarà necessario selezionare una nuova configurazione."
                sHowToMsg = sHowToMsg & String.Format("E' possibile verificare il funzionamento della stampante relativa alla configurazione selezionata premendo il pulsante '{0}'", btnStampaPaginaDiTest.Text)
                lblHowToMsg.Text = sHowToMsg
                Dim sIdReferto As String = Me.Request.QueryString(PAR_ID_REFERTO) & ""

                '
                ' Memorizzo comunque l'Id del referto (potrebbe non essere valorizzato)
                '
                Me.IdReferto = sIdReferto

                If String.IsNullOrEmpty(sIdReferto) Then
                    'Provengo dal link "Configurazione Stampante" o dalla lista referto
                    Me.BackUrl = Me.ResolveUrl("~/Default.aspx")
                    btnStampa.Visible = False
                    btnSalvaConfig.Visible = True
                    btnStampaPaginaDiTest.Visible = True
                    btnGeneraPDF.Visible = False
                    Me.MsgNoConfig = String.Format("Nessuna configurazione di stampa è presente per l'utente corrente!<BR>Selezionare un server di stampa e relativa stampante e premere il pulsante '{0}'.", btnSalvaConfig.Text)
                Else
                    'Me.BackUrl  = Me.ResolveUrl(Request.UrlReferrer.AbsoluteUri)
                    Me.BackUrl = Me.ResolveUrl("~/Default.aspx")
                    btnStampa.Visible = True
                    btnSalvaConfig.Visible = False
                    btnStampaPaginaDiTest.Visible = True
                    btnGeneraPDF.Visible = CType(My.Settings.Printing_ShowGeneraPDF, Boolean)
                    Me.MsgNoConfig = String.Format("Nessuna configurazione di stampa è presente per l'utente corrente!<BR>Selezionare un server di stampa e relativa stampante e premere il pulsante '{0}'.", btnStampa.Text)
                End If

                '
                ' Inizializzo interfaccia per configurazione di stampa
                '
                Call InitUI()
            End If

        Catch ex As Exception
            Dim sMsgErr As String = FormatException(ex)
            Logging.WriteError(ex, sMsgErr)
            lblErrorMessage.Text = "Si è verificato un errore durante il caricamento della pagina."
            alertErrorMessage.Visible = True
        End Try

    End Sub

    Private Sub LoadComboPrinterServers(ByVal oArrayServerInfo As ServerInfo())
        '
        ' ATTENZIONE: Lo stato del server di stampa può essere solo "On line" o "Off line"
        '
        Dim sText As String = String.Empty
        Dim sValue As String = String.Empty
        Dim oItem As System.Web.UI.WebControls.ListItem
        cmbNetPrinterServer.Items.Clear()
        oItem = New System.Web.UI.WebControls.ListItem("< Selezionare un server >", "")
        cmbNetPrinterServer.Items.Add(oItem)

        If Not oArrayServerInfo Is Nothing Then
            If oArrayServerInfo.Count > 0 Then
                '
                ' Copio in un Generic.List(Of T) che so ordinare
                '
                Dim oList As New Generic.List(Of ServerInfo)
                For Each oServerInfo In oArrayServerInfo
                    Dim oItemServerInfo As New ServerInfo()
                    oItemServerInfo.Name = oServerInfo.Name
                    oItemServerInfo.Status = oServerInfo.Status
                    oItemServerInfo.FullName = oServerInfo.FullName
                    oItemServerInfo.MajorVersion = oServerInfo.MajorVersion
                    oItemServerInfo.MinorVersion = oServerInfo.MinorVersion
                    oList.Add(oItemServerInfo)
                Next
                '
                ' Ordino
                '
                oList.Sort(ListServerInfoComparison)
                'TODO: miglioramento implementare ordinamento con una extension
                'oArrayServerInfo.ToList(
                '
                '
                '
                For Each oServerInfo As ServerInfo In oList 'oArrayServerInfo
                    sValue = oServerInfo.Name
                    If String.Compare(oServerInfo.Status, "On line", True) = 0 Then
                        sText = sValue
                    Else
                        sText = sValue & " - [" & oServerInfo.Status & "]"
                    End If
                    oItem = New System.Web.UI.WebControls.ListItem(sText, sValue)
                    cmbNetPrinterServer.Items.Add(oItem)
                Next

            End If
        End If
    End Sub

    Private Sub LoadComboPrinterNames(ByVal oCombo As DropDownList, ByVal oArrayQueueInfo As QueueInfo())
        Dim sText As String = String.Empty
        Dim sValue As String = String.Empty
        Dim oItem As System.Web.UI.WebControls.ListItem
        oCombo.Items.Clear()
        oItem = New System.Web.UI.WebControls.ListItem("< Selezionare una stampante >", "")
        oCombo.Items.Add(oItem)
        If Not oArrayQueueInfo Is Nothing Then
            If oArrayQueueInfo.Count > 0 Then
                '
                ' Copio in un Generic.List(Of T) che so ordinare
                '
                Dim oList As New Generic.List(Of QueueInfo)
                For Each oQueueInfo In oArrayQueueInfo
                    Dim oItemQueueInfo As New QueueInfo()
                    oItemQueueInfo.Name = oQueueInfo.Name
                    oItemQueueInfo.QueueStatus = oQueueInfo.QueueStatus
                    oItemQueueInfo.FullName = oQueueInfo.FullName
                    oList.Add(oItemQueueInfo)
                Next
                '
                ' Ordino
                '
                oList.Sort(ListQueueInfoComparison)
                'TODO: miglioramento implementare ordinamento con una extension
                'oArrayQueueInfo.ToList(
                '
                ' Carico la combo
                '
                For Each oQueueInfo As QueueInfo In oList 'oArrayQueueInfo

                    sValue = oQueueInfo.Name
                    Dim s As String = PrintQueueStatus_ToItalian(LookUpPrintQueueStatus(oQueueInfo.QueueStatus))
                    If Not String.IsNullOrEmpty(s) Then
                        sText = sValue & " - [" & s & "]"
                    Else
                        sText = sValue
                    End If

                    oItem = New System.Web.UI.WebControls.ListItem(sText, sValue)
                    oCombo.Items.Add(oItem)

                Next
            End If

        End If
    End Sub


    '
    ' Ordinamento di oggetti ServerInfo
    '
    Private ListServerInfoComparison As Comparison(Of ServerInfo) = AddressOf ListServerInfoSort
    Private Function ListServerInfoSort(p1 As ServerInfo, p2 As ServerInfo) As String
        Return p1.Name.CompareTo(p2.Name)
    End Function

    '
    ' Ordinamento di oggetti QueueInfo
    '
    Private ListQueueInfoComparison As Comparison(Of QueueInfo) = AddressOf ListQueueInfoSort
    Private Function ListQueueInfoSort(p1 As QueueInfo, p2 As QueueInfo) As String
        Return p1.Name.CompareTo(p2.Name)
    End Function


#Region "Interrogazioni al PrintManager"

    ''' <summary>
    ''' Restituisce oggetto con la configurazione di stampa di default (server\stampante)
    ''' </summary>
    ''' <param name="oWs"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Private Function GetDefaultPrintersSettings(ByVal oWs As WsPrintManager.Ver1SoapClient) As QueuePath
        '
        ' Legge il web service per ricavare le impostazioni di stampa dell'utente
        '
        Dim oImpersonationContext As System.Security.Principal.WindowsImpersonationContext = Nothing
        Try
            '------------------------------------------------------------------------------------
            ' Impersonificazione dell'utente loggato
            '------------------------------------------------------------------------------------
            oImpersonationContext = (New LogonUser()).Impersonate()

            Dim oQueuePath As QueuePath = oWs.QueueGetMyDefault()

            '------------------------------------------------------------------------------------
            ' Ripristino WindowsIdentity iniziale
            '------------------------------------------------------------------------------------
            If oImpersonationContext IsNot Nothing Then
                oImpersonationContext.Undo()
                oImpersonationContext.Dispose()
                oImpersonationContext = Nothing
            End If

            Return oQueuePath

        Catch ex As System.Web.Services.Protocols.SoapException
            '
            ' Ripristino WindowsIdentity iniziale
            '
            If oImpersonationContext IsNot Nothing Then
                oImpersonationContext.Undo()
                oImpersonationContext.Dispose()
                oImpersonationContext = Nothing
            End If
            '
            ' Messaggio di errore
            '
            Dim sMsgErr As String = "Errore:" & vbCrLf & ex.Message & vbCrLf & _
                                    "Dettaglio:" & vbCrLf & ex.Detail.InnerText() & vbCrLf & _
                                    "StackTrace:" & vbCrLf & ex.StackTrace
            '
            ' Loggo l'errore
            '
            Logging.WriteError(ex, sMsgErr)
            Throw
        Catch ex As Exception
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

    ''' <summary>
    ''' Restituisce array di oggetti contenenti i server di stampa e il loro stato
    ''' </summary>
    ''' <param name="oWs"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Private Function GetPrinterServers(ByVal oWs As WsPrintManager.Ver1SoapClient) As ServerInfo()
        '
        ' Legge il web service per ricavare le impostazioni di stampa dell'utente
        '
        Dim oImpersonationContext As System.Security.Principal.WindowsImpersonationContext = Nothing
        Try
            '------------------------------------------------------------------------------------
            ' Impersonificazione dell'utente loggato
            '------------------------------------------------------------------------------------
            oImpersonationContext = (New LogonUser()).Impersonate()

            Dim oServerInfo As ServerInfo() = oWs.ServerEnum()

            '------------------------------------------------------------------------------------
            ' Ripristino WindowsIdentity iniziale
            '------------------------------------------------------------------------------------
            If oImpersonationContext IsNot Nothing Then
                oImpersonationContext.Undo()
                oImpersonationContext.Dispose()
                oImpersonationContext = Nothing
            End If

            Return oServerInfo

        Catch ex As System.Web.Services.Protocols.SoapException
            '
            ' Ripristino WindowsIdentity iniziale
            '
            If oImpersonationContext IsNot Nothing Then
                oImpersonationContext.Undo()
                oImpersonationContext.Dispose()
                oImpersonationContext = Nothing
            End If
            '
            ' Messaggio di errore
            '
            Dim sMsgErr As String = "Errore:" & vbCrLf & ex.Message & vbCrLf & _
                                    "Dettaglio:" & vbCrLf & ex.Detail.InnerText() & vbCrLf & _
                                    "StackTrace:" & vbCrLf & ex.StackTrace
            '
            ' Loggo l'errore
            '
            Logging.WriteError(ex, sMsgErr)
            Throw
        Catch ex As Exception
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

    ''' <summary>
    ''' Restituisce array di oggetti contenenti l'elenco delle stampanti (e il loro stato) associate ad un server di stampa
    ''' </summary>
    ''' <param name="oWs"></param>
    ''' <param name="sPrinterServername"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Private Function GetPrinterNames(ByVal oWs As WsPrintManager.Ver1SoapClient, ByVal sPrinterServername As String) As QueueInfo()
        '
        ' Legge il web service per ricavare le impostazioni di stampa dell'utente
        '
        Dim oImpersonationContext As System.Security.Principal.WindowsImpersonationContext = Nothing
        Try
            '------------------------------------------------------------------------------------
            ' Impersonificazione dell'utente loggato
            '------------------------------------------------------------------------------------
            oImpersonationContext = (New LogonUser()).Impersonate()

            Dim oInfo As QueueInfo() = oWs.QueueEnum(sPrinterServername)

            '------------------------------------------------------------------------------------
            ' Ripristino WindowsIdentity iniziale
            '------------------------------------------------------------------------------------
            If oImpersonationContext IsNot Nothing Then
                oImpersonationContext.Undo()
                oImpersonationContext.Dispose()
                oImpersonationContext = Nothing
            End If

            Return oInfo

        Catch ex As System.Web.Services.Protocols.SoapException
            '
            ' Ripristino WindowsIdentity iniziale
            '
            If oImpersonationContext IsNot Nothing Then
                oImpersonationContext.Undo()
                oImpersonationContext.Dispose()
                oImpersonationContext = Nothing
            End If
            '
            ' Messaggio di errore
            '
            Dim sMsgErr As String = "Errore:" & vbCrLf & ex.Message & vbCrLf & _
                                    "Dettaglio:" & vbCrLf & ex.Detail.InnerText() & vbCrLf & _
                                    "StackTrace:" & vbCrLf & ex.StackTrace
            '
            ' Loggo l'errore
            '
            Logging.WriteError(ex, sMsgErr)
            Throw
        Catch ex As Exception
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

#End Region

    Private Sub GoBack()
        '
        ' Torna alla pagina chiamante
        '
        Dim sBackUrl As String = Me.BackUrl
        If sBackUrl.Length > 0 Then
            Response.Redirect(Me.ResolveUrl(sBackUrl), False) 'con false non si interrompe l'esecuzione della pagina e non viene generato "threading abort exception"
        End If
    End Sub

    Private Function SavePrinterConfiguration() As Boolean
        Dim sStatus As String = String.Empty
        Dim oArray As String() = Nothing
        '
        '
        '
        If rbConfigNetPrinter.Checked Then
            If Not String.IsNullOrEmpty(Trim(cmbNetPrinterServer.SelectedValue)) AndAlso
                Not String.IsNullOrEmpty(Trim(cmbNetPrinterName.SelectedValue)) Then
                '
                ' Verifico che server di stampa e stampante siano valide
                '
                oArray = Split(cmbNetPrinterServer.SelectedItem.Text, "-")
                If oArray.GetLength(0) = 2 Then

                    sStatus = Replace(Replace(oArray(1).TrimStart(" "c), "[", ""), "]", "")

                    Dim sMsg As String = String.Format("Attenzione: Il server di stampa scelto, '{0}', non è valido!", cmbNetPrinterServer.SelectedValue)
                    sMsg = sMsg & String.Format("<BR>Stato del server di stampa: '{0}'", sStatus)
                    sMsg = sMsg & "<BR>Selezionare un nuovo server di stampa e relativa stampante."
                    Call ShowWrongConfig(sMsg)
                    lblMessagePredefConfig.Text = "Selezionare una configurazione di stampa valida" 'al posto del mesaggio bisognerebbe mostrare una immagine
                    alertMessagePredefConfig.Visible = True
                    Return False

                Else
                    oArray = Split(cmbNetPrinterName.SelectedItem.Text, "-")
                    If oArray.GetLength(0) = 2 Then

                        sStatus = Replace(Replace(oArray(1).TrimStart(" "c), "[", ""), "]", "")

                        If MyQueueStatus_IsStatusError(sStatus) Then
                            Dim sMsg As String = String.Format("Attenzione: La stampante scelta, '{0}' non è valida!", cmbNetPrinterName.SelectedValue)
                            sMsg = sMsg & String.Format("<BR>Stato della stampante: '{0}'.", sStatus)
                            sMsg = sMsg & "<BR>Selezionare un nuova stampante!"
                            Call ShowWrongConfig(sMsg)
                            lblMessagePredefConfig.Text = "Selezionare una configurazione di stampa valida" 'al posto del mesaggio bisognerebbe mostrare una immagine
                            alertMessagePredefConfig.Visible = True
                            Return False

                        End If

                    End If
                End If
                '
                ' Salvo
                '
                Call Me.SaveDbUserPrintingConfig(0, cmbNetPrinterServer.SelectedValue, cmbNetPrinterName.SelectedValue)
                '
                ' MODIFICA ETTORE 2016-11-24: forzo la rilettura della configurazione di stampa nelle pagine successive
                '
                PrintUtil.ReloadMyPrintingConfig()
            Else
                lblMessagePredefConfig.Text = "Selezionare una configurazione di stampa valida"
                alertMessagePredefConfig.Visible = True
                Return False

            End If

        ElseIf rbConfigPersonal.Checked Then
            If Not String.IsNullOrEmpty(Trim(txtPersonalPrinterServer.Text)) AndAlso _
                Not String.IsNullOrEmpty(Trim(cmbPersonalPrinterName.SelectedValue)) Then

                oArray = Split(cmbPersonalPrinterName.SelectedItem.Text, "-")
                If oArray.GetLength(0) = 2 Then

                    sStatus = Replace(Replace(oArray(1).TrimStart(" "c), "[", ""), "]", "")

                    If MyQueueStatus_IsStatusError(sStatus) Then
                        Dim sMsg As String = String.Format("Attenzione: La stampante scelta, '{0}' non è valida!", cmbPersonalPrinterName.SelectedValue)
                        sMsg = sMsg & String.Format("<BR>Stato della stampante: '{0}'.", sStatus)
                        sMsg = sMsg & "<BR>Selezionare un nuova stampante!"
                        Call ShowWrongConfig(sMsg)
                        lblMessagePersonalConfig.Text = "Selezionare una configurazione di stampa valida" 'al posto del mesaggio bisognerebbe mostrare una immagine
                        Return False

                    End If

                End If
                '
                ' Salvo
                '
                Call Me.SaveDbUserPrintingConfig(1, Trim(txtPersonalPrinterServer.Text), cmbPersonalPrinterName.SelectedValue)

            Else
                lblMessagePersonalConfig.Text = "Il server di stampa e/o la stampante non sono validi!"
                Return False

            End If

        ElseIf rbConfigLocalPrinter.Checked Then
            If Not String.IsNullOrEmpty(Trim(txtLocalPrinterServer.Text)) AndAlso _
                Not String.IsNullOrEmpty(Trim(cmbLocalPrinterName.SelectedValue)) Then
                oArray = Split(cmbLocalPrinterName.SelectedItem.Text, "-")
                If oArray.GetLength(0) = 2 Then

                    sStatus = Replace(Replace(oArray(1).TrimStart(" "c), "[", ""), "]", "")

                    If MyQueueStatus_IsStatusError(sStatus) Then
                        Dim sMsg As String = String.Format("Attenzione: La stampante scelta, '{0}' non è valida!", cmbLocalPrinterName.SelectedValue)
                        sMsg = sMsg & String.Format("<BR>Stato della stampante: '{0}'.", sStatus)
                        sMsg = sMsg & "<BR>Selezionare un nuova stampante!"
                        Call ShowWrongConfig(sMsg)
                        lblMessageLocalPrinterConfig.Text = "Selezionare una configurazione di stampa valida" 'al posto del mesaggio bisognerebbe mostrare una immagine
                        alertMessageLocalPrinterConfig.Visible = True
                        Return False

                    End If

                End If
                '
                ' Salvo
                '
                Call Me.SaveDbUserPrintingConfig(2, Trim(txtLocalPrinterServer.Text), cmbLocalPrinterName.SelectedValue)

            Else
                lblMessageLocalPrinterConfig.Text = "Il server di stampa e/o la stampante non sono validi!"
                alertMessageLocalPrinterConfig.Visible = True
                Return False

            End If

        Else
            If rbConfigPersonal.Visible = False Then
                lblErrorMessage.Text = String.Format("Selezionare quale sezione di configurazione utilizzare: '{0}', '{1}', '{2}'", rbConfigNetPrinter.Text, rbConfigLocalPrinter.Text, rbConfigPersonal.Text)
                alertErrorMessage.Visible = True
            Else
                lblErrorMessage.Text = String.Format("Selezionare quale sezione di configurazione utilizzare: '{0}', '{1}'", rbConfigNetPrinter.Text, rbConfigLocalPrinter.Text)
                alertErrorMessage.Visible = True
            End If
            Return False

        End If
        '
        ' Nascondo il messaggio che avvisa che l'utente non ha salvato una configurazione di stampa
        '
        Call ShowWrongConfig(Nothing)
        Return True
    End Function

    ''' <summary>
    ''' 
    ''' </summary>
    ''' <param name="oArrayServerInfo"></param>
    ''' <param name="sPrinterServerName"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Private Function GetPrinterServerStatus(ByVal oArrayServerInfo As ServerInfo(), ByVal sPrinterServerName As String) As String
        If Not oArrayServerInfo Is Nothing Then
            For Each oServerInfo As ServerInfo In oArrayServerInfo
                If String.Compare(oServerInfo.Name, sPrinterServerName, True) = 0 Then
                    Return PrinterServerStatus_ToItalian(oServerInfo.Status)
                End If
            Next
        End If
        Return Nothing
    End Function

    Private Function PrinterServerStatus_ToItalian(ByVal sStatus As String) As String
        Dim sRet As String = String.Empty
        Select Case sStatus.ToUpper
            Case "ON LINE"
                sRet = ""
            Case "OFF LINE"
                sRet = "Off line"
        End Select
        Return sRet
    End Function

    Private Function MyPrinterServerStatus_IsStatusError(ByVal sStatus As String) As Boolean
        '
        ' Solo se Off line...
        '
        If String.IsNullOrEmpty(sStatus) Then
            Return False
        End If
        Return True
    End Function


    Private Function GetPrinterStatus(ByVal oArrayQueueInfo As QueueInfo(), ByVal sPrinterName As String) As String
        If Not oArrayQueueInfo Is Nothing Then
            For Each oQueueInfo As QueueInfo In oArrayQueueInfo
                If String.Compare(oQueueInfo.Name, sPrinterName, True) = 0 Then
                    Return PrintQueueStatus_ToItalian(LookUpPrintQueueStatus(oQueueInfo.QueueStatus))
                End If
            Next
        End If
        Return Nothing
    End Function

    Private Function LookUpPrintQueueStatus(ByVal sStatus As String) As System.Printing.PrintQueueStatus
        '
        ' for each s in [Enum].GetName(GetType(PrintQueueStatus), PrintQueueValue.QueueStatus) -> fornisce il testo dell'enum
        ' Converto la stringa stato nell'equivalente valore dell'enum
        '
        Try
            If String.IsNullOrEmpty(sStatus) Then
                Return System.Printing.PrintQueueStatus.None
            Else
                Return CType([Enum].Parse(GetType(System.Printing.PrintQueueStatus), sStatus, True), System.Printing.PrintQueueStatus)
            End If
        Catch ex As Exception
            Dim sMsgErr As String = FormatException(ex)
            Logging.WriteError(ex, "LookUpPrintQueueStatus():" & vbCrLf & sMsgErr)
        End Try
        '
        ' In caso di errore...
        '
        Return System.Printing.PrintQueueStatus.None

    End Function

    Private Function PrintQueueStatus_ToItalian(ByVal iPrintQueueStatus As System.Printing.PrintQueueStatus) As String
        Dim sRet As String = String.Empty
        Select Case iPrintQueueStatus
            Case PrintQueueStatus.Error
                sRet = "In Errore"
            Case PrintQueueStatus.NoToner
                sRet = "Toner terminato"
            Case PrintQueueStatus.Offline
                sRet = "Off line"
            Case PrintQueueStatus.OutOfMemory
                sRet = "Errore memoria"
            Case PrintQueueStatus.PaperJam
                sRet = "Errore carta"
            Case PrintQueueStatus.PaperOut
                sRet = "Errore carta"
            Case PrintQueueStatus.PaperProblem
                sRet = "Errore carta"
            Case PrintQueueStatus.ServerUnknown
                sRet = "In Errore"
            Case PrintQueueStatus.UserIntervention
                sRet = "Intervento utente"
                'Questi sono warning
            Case PrintQueueStatus.Paused
                sRet = "In pausa"
            Case PrintQueueStatus.TonerLow
                sRet = "Toner basso"
        End Select
        Return sRet
    End Function

    Private Function MyQueueStatus_IsStatusError(ByVal sStatus As String) As Boolean
        If String.IsNullOrEmpty(sStatus) Then
            Return False
        ElseIf sStatus = "In pausa" Then
            Return False
        ElseIf sStatus = "Toner basso" Then
            Return False
        End If
        Return True
    End Function

    Private Sub InitUI()
        Dim oWs As WsPrintManager.Ver1SoapClient = Nothing
        Try
            '
            '
            '
            Call ShowWrongConfig(Nothing)
            rbConfigNetPrinter.Checked = False
            rbConfigLocalPrinter.Checked = False
            rbConfigPersonal.Checked = False
            '
            ' Inizializzo le combo delle stampanti con il primo elemento vuoto (in base alla configurazione la combo verrà ricaricata)
            '
            Call LoadComboPrinterNames(cmbNetPrinterName, Nothing)
            Call LoadComboPrinterNames(cmbPersonalPrinterName, Nothing)
            '
            ' Configurazione di default per la scelta della stampante locale
            '
            Call LoadComboPrinterNames(cmbLocalPrinterName, Nothing)
            Dim sHostName As String = Utility.GetUserHostName()
            If sHostName.Length > 0 Then
                sHostName = "\\" & sHostName.TrimStart("\\")
                txtLocalPrinterServer.Text = sHostName
                Me.HostName = sHostName
            End If
            '
            ' Prelevo attuale configurazione di stampa da database
            '
            Dim oPrintingConfig As PrintUtil.PrintingConfig = PrintUtil.GetUserPrintingConfig()
            '
            ' Inizializzo il web service e imposto le credenziali
            '
            oWs = New WsPrintManager.Ver1SoapClient
            PrintUtil.InitWsPrintManager(oWs)
            '
            ' Carico tutti i server di stampa per l'utente corrente
            '
            Dim oArrayPrinterServer As ServerInfo() = GetPrinterServers(oWs)
            '
            ' Se esiste già una configurazione di stampa scelta dall'utente...
            '
            If (Not oPrintingConfig Is Nothing) AndAlso (Not String.IsNullOrEmpty(oPrintingConfig.PrinterServerName)) AndAlso (Not String.IsNullOrEmpty(oPrintingConfig.PrinterName)) Then
                '
                ' Memorizzo stringa con la configurazione corrente
                '
                CurrentPrintingConfiguration = String.Format("Attuale configurazione di stampa: '{0}' '{1}'", oPrintingConfig.PrinterServerName, oPrintingConfig.PrinterName)

                '
                ' Carico sempre le stampanti predefinite a prescindere dal tipo di configurazione "Predefinita=Stampanti di rete/Personalizzata/StampantiLocali"
                '
                Call LoadComboPrinterServers(oArrayPrinterServer)
                '
                ' In base al tipo di configurazione (Di rete, Locale, personalizzata)...
                ' 0=Stampante di rete, 1=Stampante personalizzata, 2=Stampante locale
                '
                If oPrintingConfig.ConfigType = 0 Then
                    Call InitUIPrinterSelection_NetPrinter(oWs, oPrintingConfig, oArrayPrinterServer)
                ElseIf oPrintingConfig.ConfigType = 1 Then
                    Call InitUIPrinterSelection_PersonalPrinter(oWs, oPrintingConfig)
                ElseIf oPrintingConfig.ConfigType = 2 Then
                    Call InitUIPrinterSelection_LocalPrinter(oWs, oPrintingConfig)
                End If
            Else
                '
                ' Nessuna configurazione presente
                '
                Call InitUIPrinterSelection_NoConfig(oWs, oArrayPrinterServer)
            End If
            '
            ' Abilito il pannello in base al tipo di configurazione scelta
            '
            cmbNetPrinterServer.Enabled = rbConfigNetPrinter.Checked
            cmbNetPrinterName.Enabled = rbConfigNetPrinter.Checked

            txtLocalPrinterServer.Enabled = rbConfigLocalPrinter.Checked
            cmdLocalFindPrinter.Enabled = rbConfigLocalPrinter.Checked
            cmbLocalPrinterName.Enabled = rbConfigLocalPrinter.Checked

            txtPersonalPrinterServer.Enabled = rbConfigPersonal.Checked
            cmdPersonalFindPrinter.Enabled = rbConfigPersonal.Checked
            cmbPersonalPrinterName.Enabled = rbConfigPersonal.Checked

        Catch ex As Exception
            Dim sMsgErr As String = FormatException(ex)
            Logging.WriteError(ex, sMsgErr)
            lblErrorMessage.Text = "Si è verificato un errore durante il caricamento delle impostazioni di stampa.<BR>" & _
                                    "Provare a ricreare una nuova configurazione di stampa."
            alertErrorMessage.Visible = True
        Finally
            If Not oWs Is Nothing Then
                oWs = Nothing
            End If
        End Try

    End Sub

    Private Sub InitUIPrinterSelection_NetPrinter(ByVal oWs As WsPrintManager.Ver1SoapClient, ByVal oPrintingConfig As PrintUtil.PrintingConfig, ByVal oArrayPrinterServer As ServerInfo())
        Dim MyPrinterServerName As String = oPrintingConfig.PrinterServerName
        Dim MyPrinterName As String = oPrintingConfig.PrinterName

        rbConfigNetPrinter.Checked = False

        If oArrayPrinterServer Is Nothing OrElse oArrayPrinterServer.Length = 0 Then 'dovuto ad una modifica dei permessi o a mancanza di configurazione
            Dim sMsg1 As String = String.Empty
            sMsg1 = "Attenzione: Non ci sono attualmente server di stampa predefiniti per l'utente corrente.<BR>Contattare l'amministratore!"
            sMsg1 = sMsg1 & "<BR>Stampante attualmente configurata: " & MyPrinterServerName & " " & MyPrinterName
            Call ShowWrongConfig(sMsg1)
            '
            ' Disabilito il pannello "Configurazione Predefinita"
            '
            tblConfigNetPrinter.Disabled = True
            Exit Sub
        End If
        '
        ' A questo punto ci sono server di stampa per l'utente corrente...
        '
        ' Controllo se il server di stampa scelto dall'utente sia ancora On Line...
        ' e se esiste nella lista dei server predefiniti
        '
        Dim sMsgErr As String = String.Empty
        Dim sPrinterServerStatus As String = GetPrinterServerStatus(oArrayPrinterServer, MyPrinterServerName)
        If sPrinterServerStatus Is Nothing OrElse MyPrinterServerStatus_IsStatusError(sPrinterServerStatus) Then
            sMsgErr = String.Format("Attenzione: Il server di stampa '{0}' configurato in precedenza non è più valido!", MyPrinterServerName)
            If Not sPrinterServerStatus Is Nothing Then
                sMsgErr = sMsgErr & String.Format("<BR>Stato del server di stampa: '{0}'", sPrinterServerStatus)
            End If
            sMsgErr = sMsgErr & "<BR>Stampante attualmente configurata: " & MyPrinterServerName & " " & MyPrinterName
            sMsgErr = sMsgErr & "<BR>Selezionare un nuovo server di stampa e relativa stampante."
        End If
        '
        ' Carico la combo dei server di stampa
        '
        Call LoadComboPrinterServers(oArrayPrinterServer)
        '
        ' Carico le stampanti associate al server scelto dall'utente
        '
        Dim oArrayQueueInfo As QueueInfo() = GetPrinterNames(oWs, MyPrinterServerName)
        Call LoadComboPrinterNames(cmbNetPrinterName, oArrayQueueInfo)
        '
        ' Seleziono gli item delle combo presenti nella configurazione nel COOKY
        '
        cmbNetPrinterServer.SelectedValue = MyPrinterServerName
        cmbNetPrinterName.SelectedValue = MyPrinterName
        '
        ' Verifico la consistenza della configurazione esistente: Il server e la stampante correnti devono esistere
        ' nelle combo: nel caso che il selezionato sia diverso dal configurato viene visualizzato un errore
        '
        If String.IsNullOrEmpty(sMsgErr) Then
            If cmbNetPrinterServer.SelectedValue.ToUpper <> MyPrinterServerName.ToUpper Then
                sMsgErr = String.Format("Attenzione: Il server di stampa '{0}' configurato in precedenza non è più valido!<BR>Selezionare un nuovo server di stampa e relativa stampante.", MyPrinterServerName)
            ElseIf cmbNetPrinterName.SelectedValue.ToUpper <> MyPrinterName.ToUpper Then
                sMsgErr = String.Format("Attenzione: La stampante '{0}' configurata in precedenza non è più valida!.<BR>Selezionare un nuova stampante.", MyPrinterName)
            End If
        End If
        If String.IsNullOrEmpty(sMsgErr) Then
            '
            ' Allora server e stampante esistono...controllo che alla stampante non sia associato uno stato di errore
            ' 
            Dim sPrinterStatus As String = GetPrinterStatus(oArrayQueueInfo, MyPrinterName)
            If sPrinterStatus Is Nothing OrElse MyQueueStatus_IsStatusError(sPrinterStatus) Then
                sMsgErr = String.Format("Attenzione: La stampante '{0}' configurata in precedenza presenta dei problemi!", MyPrinterName)
                sMsgErr = sMsgErr & String.Format("<BR>Stato della stampante: '{0}'.", sPrinterStatus)
                sMsgErr = sMsgErr & "<BR>Selezionare eventualmente un nuova stampante!"
            End If
        End If
        '
        ' Visualizzo messaggio se presente
        '
        If Not String.IsNullOrEmpty(sMsgErr) Then
            Call ShowWrongConfig(sMsgErr)
        Else
            '
            ' ..altrimenti tuto ok
            '
            rbConfigNetPrinter.Checked = True
            '
            ' Mostro l'attuale configurazione
            '
            Dim sPrinterStatus As String = GetPrinterStatus(oArrayQueueInfo, MyPrinterName)
            Dim sMsg As String = String.Format("Stampante corrente:<BR>'{0}' '{1}'", MyPrinterServerName, MyPrinterName)
            If Not String.IsNullOrEmpty(sPrinterStatus) Then
                sMsg = sMsg & " Stato stampante: " & sPrinterStatus
            End If
            Call ShowActualConfig(sMsg)
        End If
    End Sub

    Private Sub InitUIPrinterSelection_PersonalPrinter(ByVal oWs As WsPrintManager.Ver1SoapClient, ByVal oPrintingConfig As PrintUtil.PrintingConfig)
        Dim MyPrinterServerName As String = oPrintingConfig.PrinterServerName
        Dim MyPrinterName As String = oPrintingConfig.PrinterName

        rbConfigPersonal.Checked = False
        '
        ' Non carico nessuna stampante nella combo delle stampanti di rete
        ' (Visualizzo solo il testo "<Selezionare una stampante>"
        '
        Call LoadComboPrinterNames(cmbNetPrinterName, Nothing)
        '
        ' Scrivo il nome del server
        '
        txtPersonalPrinterServer.Text = MyPrinterServerName
        '
        ' Carico le stampanti associate al server
        '
        Dim oArrayQueueInfo As QueueInfo() = GetPrinterNames(oWs, MyPrinterServerName)
        Call LoadComboPrinterNames(cmbPersonalPrinterName, oArrayQueueInfo)
        '
        ' Seleziono il nome della stampante 
        '
        cmbPersonalPrinterName.SelectedValue = MyPrinterName
        '
        ' Verifico la consistenza della configurazione del nome della stampante: la stampante corrente deve esistere
        ' nella combo: altrimenti segnalazione all'utente
        '
        Dim sMsgErr As String = String.Empty
        If cmbPersonalPrinterName.SelectedValue.ToUpper <> MyPrinterName.ToUpper Then
            sMsgErr = String.Format("Attenzione: La stampante '{0}' configurata in precedenza non è più valida!.<BR>Selezionare un nuova stampante.", MyPrinterName)
        End If
        If String.IsNullOrEmpty(sMsgErr) Then
            '
            ' La stampante esiste...controllo che non sia associata ad  uno stato di errore 
            '
            Dim sPrinterStatus As String = GetPrinterStatus(oArrayQueueInfo, MyPrinterName)
            If sPrinterStatus Is Nothing OrElse MyQueueStatus_IsStatusError(sPrinterStatus) Then
                sMsgErr = String.Format("Attenzione: La stampante '{0}' configurata in precedenza presenta dei problemi!", MyPrinterName)
                sMsgErr = sMsgErr & String.Format("<BR>Stato della stampante: '{0}'.", sPrinterStatus)
                sMsgErr = sMsgErr & "<BR>Selezionare eventualmente un nuova stampante!"
            End If
        End If
        If Not String.IsNullOrEmpty(sMsgErr) Then
            Call ShowWrongConfig(sMsgErr)
        Else
            rbConfigPersonal.Checked = True
            '
            ' Mostro l'attuale configurazione
            '
            Dim sPrinterStatus As String = GetPrinterStatus(oArrayQueueInfo, MyPrinterName)
            Dim sMsg As String = String.Format("Stampante attualmente configurata:<BR>'{0}' '{1}'", MyPrinterServerName, MyPrinterName)
            If Not String.IsNullOrEmpty(sPrinterStatus) Then
                sMsg = sMsg & String.Format(" Stato della stampante: '{0}'.", sPrinterStatus)
            End If
            Call ShowActualConfig(sMsg)
        End If

    End Sub

    Private Sub InitUIPrinterSelection_LocalPrinter(ByVal oWs As WsPrintManager.Ver1SoapClient, ByVal oPrintingConfig As PrintUtil.PrintingConfig)
        Dim MyPrinterServerName As String = oPrintingConfig.PrinterServerName
        Dim MyPrinterName As String = oPrintingConfig.PrinterName

        rbConfigLocalPrinter.Checked = False
        '
        ' Non carico nessuna stampante nella combo delle STAMPANTI DI RETE
        ' (Visualizzo solo il testo "<Selezionare una stampante>"
        '
        Call LoadComboPrinterNames(cmbNetPrinterName, Nothing)
        '
        ' Ho già valorizzato prima il nome del coumputer: txtLocalPrinterServer.Text è già valorizzata
        '
        Dim sHostName As String = txtLocalPrinterServer.Text
        '
        ' Se ho il nome del server in configurazione carico la combo con le possibili stampanti
        '
        Dim sMsgErr As String = String.Empty
        '
        ' Verifico che il nome del PC salvato in configurazione sia uguale al "vero" nome del PC
        '
        If MyPrinterServerName.ToUpper <> sHostName.ToUpper Then
            sMsgErr = sMsgErr & String.Format("Attenzione: L'attuale nome della macchina locale ('{0}') è diverso da quello precedentemente salvato in configurazione ('{1}').", sHostName, MyPrinterServerName)
            sMsgErr = sMsgErr & String.Format("<BR>Premere il pulsante '{0}' e selezionare una nuova stampante!", cmdLocalFindPrinter.Text)
            Call ShowWrongConfig(sMsgErr)
        End If

        '
        ' Esco se errore, ma ho già visualizzato il messaggio
        '
        If Not String.IsNullOrEmpty(sMsgErr) Then Exit Sub


        '
        ' Carico le stampanti locali associate al PC (questa da errore se il client non è condiviso!!!)
        ' 
        Dim oArrayQueueInfo As QueueInfo() = GetPrinterNames(oWs, sHostName)
        Call LoadComboPrinterNames(cmbLocalPrinterName, oArrayQueueInfo)

        '
        ' Seleziono il nome della stampante salvata in configurazione
        '
        cmbLocalPrinterName.SelectedValue = MyPrinterName
        '
        ' Verifico la consistenza della configurazione del nome della stampante: la stampante corrente deve esistere
        ' nella combo: altrimenti segnalazione all'utente
        '
        If cmbLocalPrinterName.SelectedValue.ToUpper <> MyPrinterName.ToUpper Then
            sMsgErr = String.Format("Attenzione: La stampante '{0}' configurata in precedenza non è più valida!.<BR>Selezionare un nuova stampante.", MyPrinterName)
        End If
        If String.IsNullOrEmpty(sMsgErr) Then
            '
            ' La stampante esiste...controllo che non sia associata ad uno stato di errore 
            '
            Dim sPrinterStatus As String = GetPrinterStatus(oArrayQueueInfo, MyPrinterName)
            If sPrinterStatus Is Nothing OrElse MyQueueStatus_IsStatusError(sPrinterStatus) Then
                sMsgErr = String.Format("Attenzione: La stampante '{0}' configurata in precedenza presenta dei problemi!", MyPrinterName)
                sMsgErr = sMsgErr & String.Format("<BR>Stato della stampante: '{0}'.", sPrinterStatus)
                sMsgErr = sMsgErr & "<BR>Selezionare eventualmente un nuova stampante!"
            End If
        End If
        If Not String.IsNullOrEmpty(sMsgErr) Then
            Call ShowWrongConfig(sMsgErr)
        Else
            rbConfigLocalPrinter.Checked = True
            '
            ' Mostro l'attuale stato della stampante selezionata
            '
            Dim sPrinterStatus As String = GetPrinterStatus(oArrayQueueInfo, MyPrinterName)
            Dim sMsg As String = String.Format("Stampante attualmente configurata:<BR>'{0}' '{1}'", MyPrinterServerName, MyPrinterName)
            If Not String.IsNullOrEmpty(sPrinterStatus) Then
                sMsg = sMsg & String.Format("<BR>Stato della stampante: '{0}'.", sPrinterStatus)
            End If
            Call ShowActualConfig(sMsg)
        End If

    End Sub

    Private Sub InitUIPrinterSelection_NoConfig(ByVal oWs As WsPrintManager.Ver1SoapClient, ByVal oArrayPrinterServer As ServerInfo())
        Dim sMsg As String = String.Empty
        '
        ' Non esiste ancora una configurazione di stampa scelta dall'utente
        ' Propongo come configurazione Predefinita la configurazione di default dell'utente corrente...
        ' 
        rbConfigNetPrinter.Checked = True
        '
        ' Carico le impostazioni di stampa di default per l'utente (devo verificare se sono ancora valide)
        '
        Dim oDefaultQueuePath As QueuePath = GetDefaultPrintersSettings(oWs)
        '
        ' Verifico se le impostazioni di default sono ancora valide
        '
        Dim sDefaultPrinterServerName As String = String.Empty
        Dim sDefaultPrinterName As String = String.Empty
        If Not oDefaultQueuePath Is Nothing Then
            sDefaultPrinterServerName = oDefaultQueuePath.Server
            sDefaultPrinterName = oDefaultQueuePath.Name
        End If
        '
        ' Carico combo dei server di stampa
        '
        Call LoadComboPrinterServers(oArrayPrinterServer)

        If Not String.IsNullOrEmpty(sDefaultPrinterServerName) Then
            Dim sPrinterServerStatus As String = GetPrinterServerStatus(oArrayPrinterServer, sDefaultPrinterServerName)
            If sPrinterServerStatus Is Nothing OrElse MyPrinterServerStatus_IsStatusError(sPrinterServerStatus) Then
                sMsg = String.Format("Attenzione: Il server di stampa '{0}' non è valido!", sDefaultPrinterServerName)
                If Not sPrinterServerStatus Is Nothing Then
                    sMsg = sMsg & String.Format("<BR>Stato del server di stampa: '{0}'", sPrinterServerStatus)
                End If
                sMsg = sMsg & "<BR>Selezionare un nuovo server di stampa e relativa stampante."
                'La chiamo alla fine - Call ShowWrongConfig(sMsg)
            End If
        End If

        Dim oArrayQueueInfo As QueueInfo() = Nothing
        If Not String.IsNullOrEmpty(sDefaultPrinterServerName) Then
            Try
                oArrayQueueInfo = GetPrinterNames(oWs, sDefaultPrinterServerName)
            Catch ex As Exception
                Dim sMsgErr As String = String.Format("Errore in InitUIPrinterSelection_NoConfig() durante la ricerca delle stampanti associate al DefaultPrinterServer '{0}'", sDefaultPrinterServerName)
                Logging.WriteError(ex, Me.GetType.Name)
            End Try
        End If
        Call LoadComboPrinterNames(cmbNetPrinterName, oArrayQueueInfo)
        '
        ' Seleziono gli item della combo corrispondenti alla configurazione di default Server/Stampante
        ' Se esiste una stampante di default viene selezionata altrimenti viene selezionato il primo item della combo delle stampanti!
        '
        cmbNetPrinterServer.SelectedValue = sDefaultPrinterServerName
        cmbNetPrinterName.SelectedValue = sDefaultPrinterName

        '
        ' Segnalo che non è stata salvata nessuna configurazione per l'utente corrente...
        '
        sMsg = sMsg & "<BR>" & Me.MsgNoConfig
        '
        ' Visualizzo
        '
        Call ShowWrongConfig(sMsg)

    End Sub

    Private Sub ShowWrongConfig(ByVal sMsg As String)
        If String.IsNullOrEmpty(sMsg) Then
            divConfigMsg.Visible = False 'Nascondo il container di lblConfigMsg e imgPrinterStatus
        Else
            divConfigMsg.Visible = True
            lblConfigMsg.Text = sMsg & "<BR><BR>" & CurrentPrintingConfiguration
            imgPrinterStatus.Attributes.Add("class", "halflings halflings-remove")
        End If
    End Sub

    Private Sub ShowActualConfig(ByVal sMsg As String)
        If String.IsNullOrEmpty(sMsg) Then
            divConfigMsg.Visible = False 'Nascondo il container di lblConfigMsg e imgPrinterStatus
        Else
            divConfigMsg.Visible = True
            lblConfigMsg.Text = sMsg
            imgPrinterStatus.Attributes.Add("class", "glyphicons glyphicons-print")
        End If
    End Sub



#Region "Eventi dei controlli"

    Protected Sub btnSalvaConfig_Click(ByVal sender As Object, ByVal e As EventArgs) Handles btnSalvaConfig.Click
        '
        ' Salva la configurazione scelta dall'utente in un cooky
        '
        Try
            If SavePrinterConfiguration() Then
                '
                ' Torno alla pagina chiamante
                '
                Call GoBack()
            End If
        Catch ex As Threading.ThreadAbortException
            '
            ' Non faccio niente
            '
        Catch ex As Exception
            Logging.WriteError(ex, Me.GetType.Name)
            If lblErrorMessage.Text.Length = 0 Then
                lblErrorMessage.Text = "Si è verificato un errore durante il salvataggio della configurazione di stampa.<BR>Contattare l'amministratore."
            alertErrorMessage.Visible = True
            End If
        End Try
    End Sub

    Protected Sub btnStampa_Click(ByVal sender As Object, ByVal e As EventArgs) Handles btnStampa.Click
        '
        ' Questo pulsante si visualizza se è stato premuto STAMPA ma non c'è ancora una configurazione salvata
        ' Salvo la configurazione selezionate e alla pagina di stampa StampaReferto.aspx
        '
        Try
            If SavePrinterConfiguration() Then
                Dim sIdReferto As String = Me.IdReferto
                If Not String.IsNullOrEmpty(sIdReferto) Then
                    Dim sUrl As String = Me.ResolveUrl("~/Referti/StampaReferto.aspx")
                    sUrl = sUrl & String.Format("?{0}={1}", PAR_ID_REFERTO, sIdReferto)
                    Me.Response.Redirect(sUrl)
                End If
            End If

        Catch ex As Threading.ThreadAbortException
            '
            ' Non faccio niente
            '
        Catch ex As Exception
            Logging.WriteError(ex, Me.GetType.Name)
            lblErrorMessage.Text = "Si è verificato un errore durante la stampa.<BR>Contattare l'amministratore."
            alertErrorMessage.Visible = True
        End Try
    End Sub

    Private Sub cmbNetPrinterServer_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmbNetPrinterServer.SelectedIndexChanged
        Dim oWs As WsPrintManager.Ver1SoapClient = Nothing
        Dim oCmb As DropDownList = Nothing
        Dim sPrinterServerName As String = String.Empty
        Try
            oCmb = CType(sender, DropDownList)
            sPrinterServerName = oCmb.SelectedItem.Value
            If Not String.IsNullOrEmpty(sPrinterServerName) Then
                '
                ' Dichiaro il web service e imposto le credenziali e leggo le configurazioni per la stampante
                '
                oWs = New WsPrintManager.Ver1SoapClient
                PrintUtil.InitWsPrintManager(oWs)
                '
                ' Carico la combo delle stampanti
                '
                Dim oArrayQueueInfo As QueueInfo() = GetPrinterNames(oWs, sPrinterServerName)
                Call LoadComboPrinterNames(cmbNetPrinterName, oArrayQueueInfo)
                '
                ' Seleziono la stampante di default se il server è quello di default
                '
                Dim oDefaultQueuePath As QueuePath = GetDefaultPrintersSettings(oWs)
                If Not oDefaultQueuePath Is Nothing Then
                    If oDefaultQueuePath.Server.ToUpper = sPrinterServerName.ToUpper Then
                        cmbNetPrinterName.SelectedValue = oDefaultQueuePath.Name
                    End If
                End If

            Else
                Call LoadComboPrinterNames(cmbNetPrinterName, Nothing)
            End If

        Catch ex As Exception
            Logging.WriteError(ex, Me.GetType.Name)
            lblErrorMessage.Text = "Si è verificato un errore durante il caricamento della lista delle stampanti.<BR>Contattare l'amministratore."
            alertErrorMessage.Visible = True
        Finally
            If Not oWs Is Nothing Then
                oWs = Nothing
            End If
        End Try
    End Sub


    Private Sub rbConfigNetPrinter_CheckedChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles rbConfigNetPrinter.CheckedChanged
        Try
            cmbNetPrinterServer.Enabled = True
            cmbNetPrinterName.Enabled = True

            cmbLocalPrinterName.Enabled = False
            cmdLocalFindPrinter.Enabled = False
            txtLocalPrinterServer.Enabled = False

            cmbPersonalPrinterName.Enabled = False
            cmdPersonalFindPrinter.Enabled = False
            txtPersonalPrinterServer.Enabled = False

        Catch ex As Exception
            Logging.WriteError(ex, Me.GetType.Name)
            lblErrorMessage.Text = String.Format("Si è verificato un errore durante la selezione della sezione di configurazione '{0}'.<BR>Contattare l'amministratore.", rbConfigNetPrinter.Text)
            alertErrorMessage.Visible = True
        End Try
    End Sub

    Protected Sub rbConfigLocalPrinter_CheckedChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles rbConfigLocalPrinter.CheckedChanged
        Try
            cmbNetPrinterServer.Enabled = False
            cmbNetPrinterName.Enabled = False

            cmbLocalPrinterName.Enabled = True
            cmdLocalFindPrinter.Enabled = True
            txtLocalPrinterServer.Enabled = True

            cmbPersonalPrinterName.Enabled = False
            cmdPersonalFindPrinter.Enabled = False
            txtPersonalPrinterServer.Enabled = False

        Catch ex As Exception
            Logging.WriteError(ex, Me.GetType.Name)
            lblErrorMessage.Text = String.Format("Si è verificato un errore durante la selezione della sezione di configurazione '{0}'.<BR>Contattare l'amministratore.", rbConfigLocalPrinter.Text)
            alertErrorMessage.Visible = True
        End Try

    End Sub

    Private Sub rbConfigPersonal_CheckedChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles rbConfigPersonal.CheckedChanged
        Try
            cmbNetPrinterServer.Enabled = False
            cmbNetPrinterName.Enabled = False

            cmbLocalPrinterName.Enabled = False
            cmdLocalFindPrinter.Enabled = False
            txtLocalPrinterServer.Enabled = False

            cmbPersonalPrinterName.Enabled = True
            cmdPersonalFindPrinter.Enabled = True
            txtPersonalPrinterServer.Enabled = True

        Catch ex As Exception
            Logging.WriteError(ex, Me.GetType.Name)
            lblErrorMessage.Text = String.Format("Si è verificato un errore durante la selezione della sezione di configurazione '{0}'.<BR>Contattare l'amministratore.", rbConfigPersonal.Text)
            alertErrorMessage.Visible = True
        End Try
    End Sub


    Protected Sub cmdPersonalFindPrinter_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdPersonalFindPrinter.Click
        '
        ' Dato il nome del server di stampa (nella parte di configurazione personale/manuale) ricavo le stampanti ad esso associate
        '
        Dim oWs As WsPrintManager.Ver1SoapClient = Nothing
        Dim sPrinterServerName As String = String.Empty
        Try
            sPrinterServerName = Trim(txtPersonalPrinterServer.Text)
            If Not String.IsNullOrEmpty(sPrinterServerName) Then
                '
                ' Dichiaro il web service e imposto le credenziali e leggo le configurazioni per la stampante
                '
                oWs = New WsPrintManager.Ver1SoapClient
                PrintUtil.InitWsPrintManager(oWs)
                '
                ' Carico la combo delle stampanti
                '
                Dim oArrayQueueInfo As QueueInfo() = Nothing
                Try
                    oArrayQueueInfo = GetPrinterNames(oWs, sPrinterServerName)
                Catch ex As Exception
                    Logging.WriteError(ex, Me.GetType.Name)
                    Dim sMsg As String = String.Format("Si è verificato un errore durante la ricerca delle stampanti associate al server '{0}'.", sPrinterServerName)
                    sMsg = sMsg & "Verificare che il nome del server sia corretto!"
                    lblErrorMessage.Text = sMsg
                    alertErrorMessage.Visible = True
                End Try
                Call LoadComboPrinterNames(cmbPersonalPrinterName, oArrayQueueInfo)
            Else
                '
                ' Avviso l'utente
                '
                lblMessagePersonalConfig.Text = "Inserire il nome del server!."
            End If
        Catch ex As Exception
            Logging.WriteError(ex, Me.GetType.Name)
            Dim sMsg As String = String.Format("Si è verificato un errore inaspettato durante la ricerca delle stampanti associate al server '{0}'.", sPrinterServerName)
            sMsg = sMsg & "<BR>Contattare l'amministratore."
            lblErrorMessage.Text = sMsg
            alertErrorMessage.Visible = True
        End Try
    End Sub

    Protected Sub cmdLocalFindPrinter_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles cmdLocalFindPrinter.Click
        '
        ' Dato il nome del server di stampa (nella parte di configurazione personale/manuale) ricavo le stampanti ad esso associate
        '
        Dim oWs As WsPrintManager.Ver1SoapClient = Nothing
        Dim sPrinterServerName As String = String.Empty
        Try
            sPrinterServerName = Trim(txtLocalPrinterServer.Text)
            If Not String.IsNullOrEmpty(sPrinterServerName) Then
                '
                ' Dichiaro il web service e imposto le credenziali e leggo le configurazioni per la stampante
                '
                oWs = New WsPrintManager.Ver1SoapClient
                PrintUtil.InitWsPrintManager(oWs)
                '
                ' Carico la combo delle stampanti
                '
                Dim oArrayQueueInfo As QueueInfo() = Nothing
                Try
                    oArrayQueueInfo = GetPrinterNames(oWs, sPrinterServerName)
                    If (Not oArrayQueueInfo Is Nothing) AndAlso (oArrayQueueInfo.Length = 0) Then
                        lblMessageLocalPrinterConfig.Text = String.Format("Non ci sono stampanti locali per il computer '{0}'!", sPrinterServerName)
                        alertMessageLocalPrinterConfig.Visible = True
                    End If
                Catch ex As Exception
                    Logging.WriteError(ex, Me.GetType.Name)
                    Dim sMsg As String = String.Format("Si è verificato un errore durante la ricerca delle stampanti associate al computer '{0}'.", sPrinterServerName)
                    sMsg = sMsg & "<BR>Verificare che il nome del computer sia corretto!"
                    sMsg = sMsg & "<BR>Se l'errore persiste contattare l'amministratore."
                    lblErrorMessage.Text = sMsg
                    alertErrorMessage.Visible = True
                End Try
                Call LoadComboPrinterNames(cmbLocalPrinterName, oArrayQueueInfo)
            Else
                '
                ' Avviso l'utente
                '
                lblMessageLocalPrinterConfig.Text = "Inserire il nome del computer!."
                alertMessageLocalPrinterConfig.Visible = True
            End If
        Catch ex As Exception
            Logging.WriteError(ex, Me.GetType.Name)
            Dim sMsg As String = String.Format("Si è verificato un errore inaspettato durante la ricerca delle stampanti associate al computer '{0}'.", sPrinterServerName)
            sMsg = sMsg & "<BR>Contattare l'amministratore."
            lblErrorMessage.Text = sMsg
            alertErrorMessage.Visible = True
        End Try
    End Sub


    Protected Sub btnEsci_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnEsci.Click
        Try
            '
            ' Torno alla pagina chiamante
            '
            Call GoBack()
        Catch ex As Exception
            Logging.WriteError(ex, Me.GetType.Name)
            lblErrorMessage.Text = String.Format("Si è verificato un errore durante la pressione del pulsante '{0}'", btnEsci.Text)
            alertErrorMessage.Visible = True
        End Try
    End Sub

    ''' <summary>
    ''' Generazione del PDF di prova
    ''' </summary>
    ''' <param name="sender"></param>
    ''' <param name="e"></param>
    ''' <remarks></remarks>
    Protected Sub btnGeneraPDF_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnGeneraPDF.Click
        '
        ' Vado alla pagina di stampa StampaReferto.aspx dicendo di visualizzare il PDF di test
        '
        Try
            Dim sIdReferto As String = Me.IdReferto
            If Not String.IsNullOrEmpty(sIdReferto) Then
                Dim sUrl As String = Me.ResolveUrl("~/Referti/StampaReferto.aspx")
                sUrl = sUrl & String.Format("?{0}={1}&{2}={3}", PAR_ID_REFERTO, sIdReferto, "TESTPDF", "1")
                Me.Response.Redirect(sUrl)
            End If

        Catch ex As System.Threading.ThreadAbortException
            '
            ' Non faccio niente
            '
        Catch ex As Exception
            Logging.WriteError(ex, Me.GetType.Name)
            If lblErrorMessage.Text.Length = 0 Then
                lblErrorMessage.Text = "Si è verificato un errore durante la generazione del PDf del referto. Contattare l'amministratore."
                alertErrorMessage.Visible = True
            End If
        End Try
    End Sub

#Region "Stampa di test"

    Protected Sub btnStampaPaginaDiTest_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnStampaPaginaDiTest.Click
        Dim sErrore As String = String.Empty
        Dim sUserMsg As String = String.Empty
        Dim oStampaStato As PrintUtil.StampeStato = PrintUtil.StampeStato.Sottomessa
        Dim sPrinterServerName As String = String.Empty
        Dim sPrinterName As String = String.Empty
        Dim iTipoConfigurazione As Integer

        Try
            '
            ' Devo determinare con quale configurazione eseguire il test
            '
            If rbConfigNetPrinter.Checked Then
                sPrinterServerName = cmbNetPrinterServer.SelectedValue
                sPrinterName = cmbNetPrinterName.SelectedValue
                iTipoConfigurazione = 0
            ElseIf rbConfigPersonal.Checked Then
                sPrinterServerName = Trim(txtPersonalPrinterServer.Text)
                sPrinterName = cmbPersonalPrinterName.SelectedValue
                iTipoConfigurazione = 1
            ElseIf rbConfigLocalPrinter.Checked Then
                sPrinterServerName = Trim(txtLocalPrinterServer.Text)
                sPrinterName = cmbLocalPrinterName.SelectedValue
                iTipoConfigurazione = 2
            End If

            If String.IsNullOrEmpty(sPrinterServerName) OrElse String.IsNullOrEmpty(sPrinterName) Then
                sUserMsg = "Attenzione:"
                sUserMsg = sUserMsg & "Il nome del server di stampa o della stampante non è corretto."
                sUserMsg = sUserMsg & "<BR>Verificare le impostazioni della configurazione attualmente selezionata."
                lblErrorMessage.Text = sUserMsg
                alertErrorMessage.Visible = True
                Exit Sub

            End If

            Dim oJobInfo As JobInfo = StampaPaginaDiTest(sPrinterServerName, sPrinterName)
            If Not oJobInfo Is Nothing Then
                '
                ' sErrore è passato byref
                '
                oStampaStato = PrintUtil.LookUpStatoJobDiStampa(CType(oJobInfo, Object), sErrore)
                If oStampaStato = PrintUtil.StampeStato.Terminata Then
                    sUserMsg = "La stampa della pagina di test è stata completata!"
                ElseIf oStampaStato = PrintUtil.StampeStato.Cancellata Then
                    sUserMsg = "La stampa della pagina di test è stata cancellata!"
                ElseIf oStampaStato = PrintUtil.StampeStato.InPausa Then
                    sUserMsg = "La stampa della pagina di test è in pausa!"
                ElseIf Not String.IsNullOrEmpty(sErrore) Then
                    sUserMsg = "La stampa della pagina di test non è stata completata." & vbCrLf
                    ' Aggiungo la stringa di errore al messaggio per l'utente
                    sUserMsg = sUserMsg & "Errore:" & vbCrLf & sErrore
                Else
                    sUserMsg = "La stampa della pagina di test non è stata completata entro il tempo prestabilito!"
                    sErrore = sUserMsg 'per salvataggio du DB
                End If
            Else
                sUserMsg = "Impossibile determinare lo stato della stampa!"
                sErrore = sUserMsg 'per salvataggio du DB
            End If
            '
            ' Salvo il risultato su DB: se errore vado avanti
            '
            Call SaveTestStampante(HttpContext.Current.User.Identity.Name, Me.HostName, iTipoConfigurazione, sPrinterServerName, sPrinterName, sErrore)
            '
            ' Visualizzo messaggio utente
            '
            lblErrorMessage.Text = sUserMsg
            alertErrorMessage.Visible = True
            'ClientScript.RegisterStartupScript(Me.GetType(), "btnStampaPaginaDiTest_Click", Utility.JSBuildScript(Utility.JSAlertCode(sUserMsg)))

        Catch ex As Exception
            '
            ' Discriminare i possibili errori cosi da fornire all'utente un messaggio comprensibile... 
            '
            Logging.WriteError(ex, Me.GetType.Name)
            lblErrorMessage.Text = "Si è verificato un errore durante la stampa della pagina di test.<BR>Contattare l'amministratore."
            alertErrorMessage.Visible = True
        End Try
    End Sub

    Private Function StampaPaginaDiTest(ByVal sPrinterServer As String, ByVal sPrinterName As String) As JobInfo
        Dim sErrore As String = String.Empty
        Dim oWs As WsPrintManager.Ver1SoapClient = Nothing
        Dim sApplicationName As String = "Dwh Clinico"
        Try
            oWs = New WsPrintManager.Ver1SoapClient
            Call PrintUtil.InitWsPrintManager(oWs)
            '
            ' Definisco il nome del job
            '
            Dim objJobInfo As Object = PrintUtil.PrintTestPage(oWs, sPrinterServer, sPrinterName, "Dwh Clinico - Prova di stampa")
            Return CType(objJobInfo, JobInfo)

        Catch ex As Exception
            '
            ' Discriminare i possibili errori cosi da fornire all'utente un messaggio comprensibile... 
            '
            Logging.WriteError(ex, Me.GetType.Name)
            lblErrorMessage.Text = "Si è verificato un errore durante la sottomissione alla stampa del documento di test.<BR>Contattare l'amministratore."
            alertErrorMessage.Visible = True
        Finally
            If Not oWs Is Nothing Then
                oWs = Nothing
            End If
        End Try
        '
        '
        '
        Return Nothing
    End Function


    Private Sub SaveDbUserPrintingConfig(ByVal iTipoConfigurazione As Integer, ByVal sServerDiStampa As String, ByVal sStampante As String)
        Try
            Dim oPrintingConfig As New PrintUtil.PrintingConfig()
            oPrintingConfig.ConfigType = iTipoConfigurazione
            oPrintingConfig.PrinterServerName = sServerDiStampa
            oPrintingConfig.PrinterName = sStampante
            Call PrintUtil.SetUserPrintingConfig(oPrintingConfig)

        Catch ex As Exception
            Logging.WriteError(ex, Me.GetType.Name)
            lblErrorMessage.Text = "Si è verificato un errore durante il salvataggio della configurazione di stampa.<BR>Contattare l'amministratore."
            alertErrorMessage.Visible = True
        End Try
    End Sub

    Private Sub SaveTestStampante(ByVal sUserAccount As String, ByVal sHostname As String, ByVal iTipoConfigurazione As Integer, ByVal sServerDiStampa As String, ByVal sStampante As String, ByVal sErrore As String)
        Try
            Using oStampe As Stampe = New Stampe()
                oStampe.StampeConfigurazioniAggiornaTestStampante(sUserAccount, sHostname, iTipoConfigurazione, sServerDiStampa, sStampante, sErrore)
            End Using

        Catch ex As Exception
            Logging.WriteError(ex, Me.GetType.Name)
            lblErrorMessage.Text = "Si è verificato un errore durante il salvataggio delle informazioni relative al test stampa.<BR>Contattare l'amministratore."
            alertErrorMessage.Visible = True
        End Try
    End Sub


#End Region

#End Region

End Class
