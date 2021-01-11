Imports DwhClinico.Web
Imports DwhClinico.Data
Imports DwhClinico.Web.Utility
Imports DwhClinico.Web.WsPrintManager
Imports DI.PortalUser2

Partial Class Referti_StampaReferto
    Inherits System.Web.UI.Page

    Private Const VS_BACK_URL As String = "VS-BackUrl"

#Region "Property per la generazione del Token"
    Private ReadOnly Property Token As WcfDwhClinico.TokenType
        '
        ' Ottiene il token da passare come parametro agli ObjectDataSource all'interno delle tab.
        ' Utilizza la property CodiceRuolo per creare il token
        '
        Get
            Dim TokenViewState As WcfDwhClinico.TokenType = TryCast(Me.ViewState("Token"), WcfDwhClinico.TokenType)
            If TokenViewState Is Nothing Then

                TokenViewState = Tokens.GetToken(Me.CodiceRuolo)

                Me.ViewState("Token") = TokenViewState
            End If
            Return TokenViewState
        End Get
    End Property

    Private ReadOnly Property CodiceRuolo As String
        '
        ' Salva nel ViewState il codice ruolo dell'utente
        ' Utilizzata per creare il token da passare come parametro all'ObjectDataSource all'interno delle tab.
        '
        Get
            Dim sCodiceRuolo As String = Me.ViewState("CodiceRuolo")
            If String.IsNullOrEmpty(sCodiceRuolo) Then
                '
                ' Prendo il ruolo dell'utente
                '
                Dim oRoleManagerUtility As New RoleManagerUtility2(Utility.GetAppSettings(Utility.PAR_DI_PORTAL_USER_CONNECTION_STRING, ""), My.Settings.SAC_ConnectionString, My.Settings.WsSac_User, My.Settings.WsSac_Password)
                Dim oRuoloCorrente As RoleManager.Ruolo = oRoleManagerUtility.RuoloCorrente
                '
                ' Salvo in ViewState
                '
                sCodiceRuolo = oRuoloCorrente.Codice
                Me.ViewState("CodiceRuolo") = sCodiceRuolo
            End If

            Return sCodiceRuolo
        End Get
    End Property
#End Region

#Region "Registrazione script lato client"

    Protected Overrides Sub OnPreRender(ByVal e As System.EventArgs)
        Dim sClientCode As String = ""
        If Not Page.ClientScript.IsClientScriptBlockRegistered(Me.GetType.Name) Then
            '
            ' Aggiungo tutte le funzioni lato client
            '
            sClientCode = sClientCode & JSOpenWindowFunction() & vbCrLf
            '
            ' Registro lo script
            '
            Page.ClientScript.RegisterClientScriptBlock(GetType(Page), Me.GetType.Name, JSBuildScript(sClientCode))
        End If
    End Sub

#End Region

    '
    ' Dato l'ID del referto da stampare lo manda in stampa:
    ' 1) Se esiste allegato stampa "diretta" dell'allegato
    ' 2) altrimenti stampa del refertp renderizzato (invocando DwhClinico.printing)
    '
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Dim sParAzione As String = String.Empty
        Dim oWs As WsPrintManager.Ver1SoapClient = Nothing
        Try
            If Not Me.IsPostBack Then
                divPdfContainer.Visible = False
                divStampaContainer.Visible = False
                divStampaByRenderingPdf.Visible = False
                trStampaDiretta.Visible = False
                '
                ' Prelevo l'URL alla pagina di stampa dell'applicazione DwhClinico.Printing
                '
                Dim sRenderingPageUrl As String = My.Settings.Printing_PageUrl
                If String.IsNullOrEmpty(sRenderingPageUrl) Then
                    Throw New Exception("La configurazione 'Printing_PageUrl' è obbligatoria.")
                End If
                '
                ' Memorizzo l'url di ritorno: da passare all'applicazione di stampa
                '
                If Not IsNothing(Request.UrlReferrer) Then
                    ViewState(VS_BACK_URL) = Request.UrlReferrer.AbsoluteUri.ToString()
                End If
                '
                ' Leggo parametri da query string
                '
                Dim sIdReferto As String = Me.Request.QueryString(PAR_ID_REFERTO) & ""
                If String.IsNullOrEmpty(sIdReferto) Then
                    Throw New Exception(String.Format("Il parametro '{0}' (id del referto da stampare) è obbligatorio.", PAR_ID_REFERTO))
                End If
                '
                ' Prelevo la configurazione di stampa
                '
                Dim sPrinterServerName As String = ""
                Dim sPrinterName As String = ""
                Dim oPrintingConfig As PrintUtil.PrintingConfig = PrintUtil.GetUserPrintingConfig()
                If Not oPrintingConfig Is Nothing Then
                    sPrinterServerName = oPrintingConfig.PrinterServerName
                    sPrinterName = oPrintingConfig.PrinterName
                End If
                '
                ' Controllo se devo visualizzare Pdf di test...
                '
                Dim sParTestPDF As String = Me.Request.QueryString("TESTPDF") & ""
                If sParTestPDF = "1" Then
                    Dim sUrlContent As String = PrintUtil.BuildUrlToPrintByIdReferto(Me, sIdReferto)
                    Dim sUrl As String = String.Format("{0}?{1}={2}&{3}={4}&{5}={6}&{7}={8}", sRenderingPageUrl,
                                                                                PAR_URL, sUrlContent,
                                                                                "PrinterServerName", sPrinterServerName,
                                                                                "PrinterName", sPrinterName,
                                                                                "TESTPDF", sParTestPDF)
                    Me.IframePdf.Attributes.Add("src", sUrl)
                    Me.LinkNoIframePdf.HRef = sUrl

                    divPdfContainer.Visible = True

                Else
                    '
                    ' Verifico cosa stampare: allegato o pagina dwh renderizzata in PDF:
                    '
                    Dim oPDFByte As Byte() = Nothing
                    oPDFByte = GetAllegatoPdfDaStampare(New Guid(sIdReferto))
                    If Not oPDFByte Is Nothing AndAlso oPDFByte.Length > 0 Then
                        oWs = New WsPrintManager.Ver1SoapClient
                        Call PrintUtil.InitWsPrintManager(oWs)
                        Dim oJobGuid As System.Guid = PrintUtil.PrintPdfDocument(oWs, oPDFByte, sPrinterServerName, sPrinterName, "DWH")
                        '
                        ' Dovrò usare il guid in seguito per i test sulla coda di stampa
                        '
                        lblUserInformation.Text = String.Format("Il documento è stato sottomesso alla stampante '{0}\{1}'...", sPrinterServerName, sPrinterName)
                        divStampaContainer.Visible = True
                        trStampaDiretta.Visible = True
                    Else
                        '
                        ' Rendering della pagina del referto
                        '
                        Dim sUrlContent As String = PrintUtil.BuildUrlToPrintByIdReferto(Me, sIdReferto)
                        Dim sUrl As String = String.Format("{0}?{1}={2}&{3}={4}&{5}={6}", sRenderingPageUrl,
                                                                            PAR_URL, sUrlContent,
                                                                            "PrinterServerName", sPrinterServerName,
                                                                            "PrinterName", sPrinterName)

                        divStampaContainer.Visible = True
                        divStampaByRenderingPdf.Visible = True
                        Me.IframeStampa.Attributes.Add("src", sUrl)
                        Me.LinkNoIframeStampa.HRef = sUrl
                    End If
                End If
            End If

        Catch ex As Exception
            Logging.WriteError(ex, "Referti_StampaReferto")
            lblErrorMessage.Text = "Si è verificato un errore durante il caricamento della pagina."
        Finally
            If Not oWs Is Nothing Then
                oWs = Nothing
            End If
        End Try

    End Sub


    Protected Sub btnExit_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnExit.Click
        Try
            Call GoBack()
        Catch ex As Threading.ThreadAbortException
            '
            ' Non faccio niente
            '
        Catch ex As Exception
            Logging.WriteError(ex, Me.GetType.Name)
            lblErrorMessage.Text = String.Format("Si è verificato un errore durante la pressione del pulsante '{0}'. Contattare l'amministratore", btnExit.Text)
        End Try

    End Sub

    Private Sub GoBack()
        '
        ' Torna alla pagina chiamante
        '
        Dim sBackUrl As String = ViewState(VS_BACK_URL) & ""
        If sBackUrl.Length > 0 Then
            Response.Redirect(Me.ResolveUrl(sBackUrl))
        End If
    End Sub

    ''' <summary>
    ''' 
    ''' </summary>
    ''' <param name="oIdReferto">Id del referto</param>
    ''' <returns>Restituisce i byte dell'allegato del referto se presente altrimenti nothing</returns>
    ''' <remarks></remarks>
    Private Function GetAllegatoPdfDaStampare(ByVal oIdReferto As Guid) As Byte()
        Dim oPDFByte As Byte() = Nothing
        Dim ds As New CustomDataSource.RefertoOttieniPerId
        Dim oRefertoType As WcfDwhClinico.RefertoType = ds.GetData(Me.Token, oIdReferto)
        If Not oRefertoType Is Nothing Then
            Dim oAllegatiType As WcfDwhClinico.AllegatiType = oRefertoType.Allegati
            Dim idEsternoReferto As String = oRefertoType.IdEsterno
            If Not oAllegatiType Is Nothing AndAlso oAllegatiType.Count > 0 Then
                Dim oAllegatiPDf As List(Of WcfDwhClinico.AllegatoType) = (From c In oAllegatiType Where c.TipoContenuto = "application/pdf").ToList
                If oAllegatiPDf.Count = 1 Then
                    oPDFByte = oAllegatiPDf(0).Contenuto
                Else
                    '
                    ' Ce ne è più di 1
                    ' Cerco quello con NomeFile=<IdEsternoReferto>_pdf.pdf 
                    '
                    Dim sFilter As String = String.Format("{0}_pdf.pdf", idEsternoReferto)
                    Dim oAllegatiPDfFiltrata = (From c In oAllegatiType Where String.Compare(c.NomeFile, sFilter, True) = 0).ToList
                    If oAllegatiPDfFiltrata.Count > 0 Then
                        '
                        ' Prendo sempre il primo della lista appena filtrata
                        '
                        oPDFByte = oAllegatiPDfFiltrata(0).Contenuto
                    Else
                        '
                        ' Se la lista filtrata è vuota prendo il primo della lista originale.
                        '
                        oPDFByte = oAllegatiPDf(0).Contenuto
                    End If
                End If
            End If
        End If
        Return oPDFByte
    End Function

End Class
