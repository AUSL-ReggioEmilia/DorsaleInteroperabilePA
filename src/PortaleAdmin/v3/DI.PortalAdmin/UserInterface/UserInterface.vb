Imports System.Net.NetworkInformation
Imports System.Reflection
Imports System.IO
Imports System
Imports System.Web
Imports System.Diagnostics
Imports System.Linq

Namespace DI.PortalAdmin

    Public Class UserInterface

        Private msResourceFooterHtm As String
        Private connectionStringPortalAdmin As String

        Private Const _StyleVisibile = "display:block;"
        Private Const _StyleNascosto = "display:none;"

#Region "Public"

        Public Sub New(PortalAdminConnectionString As String)
            connectionStringPortalAdmin = PortalAdminConnectionString

            'pre-carico il footer in modo da non doverlo rileggere ogni volta
            msResourceFooterHtm = GetEmbeddedResource("footer.htm")
        End Sub

        ''' <summary>
        ''' Ottiene una table html con la status bar già riempita con i dati
        ''' </summary>
        ''' <param name="AssemblyVersion">Numero di versione</param> 
        Public Function GetHtmlStatusbar(AssemblyVersion As String) As String
            Dim subtitle As String = String.Empty

            Using ta As New ConfigurazioniDataSetTableAdapters.ConfigurazioniOttieniBySessioneTableAdapter(connectionStringPortalAdmin)
                Dim dt As ConfigurazioniDataSet.ConfigurazioniOttieniBySessioneDataTable = ta.GetData("MenuPortali")

                If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
                    subtitle = (From configurazione As ConfigurazioniDataSet.ConfigurazioniOttieniBySessioneRow In dt.Rows Where configurazione.Chiave = "Subtitle" Select configurazione.ValoreString).FirstOrDefault
                End If
            End Using

            Dim s2 As String = GetLocalhostFqdn()
            Return String.Format(msResourceFooterHtm, AssemblyVersion, subtitle, s2)
        End Function


        Public Function IsBrowserSupported(ByVal oRequest As HttpRequest, ByRef sMessage As String) As Boolean
            'MODIFICA ETTORE 2019-02-20: messaggio solo per browser diversi da INTERNET EXPLORER
            Const MESSAGE_BROWSER_SUPPORTATI As String = "Utilizzare ""InternetExplorer"""
            Dim sBrowserName As String = String.Empty
            Dim bIsBrowserSupported As Boolean = False
            sMessage = String.Empty

            Dim oCap As HttpBrowserCapabilities = oRequest.Browser
            '--------------------------------------------------------------------
            ' Gestione particolare peer Edge
            '--------------------------------------------------------------------
            If (oRequest.UserAgent.ToUpper.Contains("EDGE") And
                (Not oCap.Browser.ToUpper.Contains("EDGE"))) Then
                bIsBrowserSupported = False
                '
                ' Per EDGE non vengono restituiti i corretti numeri di versione (oCap.Browser restituisce erroneamente "Chrome"!!!)
                ' Compongo messaggio ad hoc
                '
                sMessage = String.Concat("Il browser ""Edge"" non è supportato!", Microsoft.VisualBasic.vbCrLf, MESSAGE_BROWSER_SUPPORTATI)
                '
                ' Restituisco
                '
                Return bIsBrowserSupported
            End If
            '--------------------------------------------------------------------
            ' Altri BROWSER 
            '--------------------------------------------------------------------
            Select Case oCap.Browser.ToUpper
                Case "INTERNETEXPLORER", "IE"
                    'MODIFICA ETTORE: 2019-02-20: Va bene qualsiasi versione 
                    bIsBrowserSupported = True
            End Select
            '
            ' Preparo il messaggio da visualizzare
            '
            If Not bIsBrowserSupported Then
                'messaggio per l'utente
                sMessage = String.Format("Il browser ""{0}"" non è supportato!", oCap.Browser)
                sMessage = String.Concat(sMessage, " ", MESSAGE_BROWSER_SUPPORTATI)
            End If
            '
            '
            '
            Return bIsBrowserSupported
        End Function

        Public Function GetBootstrapHeader2(ByVal BannerTitle As String) As String
            Dim sMenu As String = String.Empty

            Dim bootstrapHeader = GetEmbeddedResource("headerBootstrap.htm")

            Using ta As New ConfigurazioniDataSetTableAdapters.ConfigurazioniOttieniBySessioneTableAdapter(connectionStringPortalAdmin)
                Dim dt As ConfigurazioniDataSet.ConfigurazioniOttieniBySessioneDataTable = ta.GetData("MenuPortali")

                If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
                    Dim subtitle As String = (From configurazione As ConfigurazioniDataSet.ConfigurazioniOttieniBySessioneRow In dt.Rows Where configurazione.Chiave = "Subtitle" Select configurazione.ValoreString).FirstOrDefault

                    '
                    ' I parametri non utilizzati (Copiati dal portale USER) non sono stati eliminati in previsione di una futura implementazione 
                    '

                    ' Non viene usata per il portale ADMIN 
                    Dim linkPortale As String = (From configurazione As ConfigurazioniDataSet.ConfigurazioniOttieniBySessioneRow In dt.Rows Where configurazione.Chiave = "LinkPortaleClinico" Select configurazione.ValoreString).FirstOrDefault

                    ' Non viene usata per il portale ADMIN
                    Dim linkMailReferenti As String = (From configurazione As ConfigurazioniDataSet.ConfigurazioniOttieniBySessioneRow In dt.Rows Where configurazione.Chiave = "LinkMailReferenti" Select configurazione.ValoreString).FirstOrDefault

                    ' Non viene usata per il portale ADMIN 
                    Dim linkMailReferentiVisibile As Boolean = (From configurazione As ConfigurazioniDataSet.ConfigurazioniOttieniBySessioneRow In dt.Rows Where configurazione.Chiave = "LinkMailReferentiVisibile" Select configurazione.ValoreBoolean).FirstOrDefault
                    Dim linkMailReferentiVisibileStyle = String.Empty
                    If Not linkMailReferentiVisibile Then
                        linkMailReferentiVisibileStyle = _StyleNascosto
                    End If

                    ' Non viene usata per il portale ADMIN 
                    Dim linkPortaleVisibile As Boolean = (From configurazione As ConfigurazioniDataSet.ConfigurazioniOttieniBySessioneRow In dt.Rows Where configurazione.Chiave = "LinkPortaleClinicoVisibile" Select configurazione.ValoreBoolean).FirstOrDefault
                    Dim linkPortaleVisibileStyle = String.Empty
                    If Not linkPortaleVisibile Then
                        linkPortaleVisibileStyle = _StyleNascosto
                    End If

                    ' Non viene usata per il portale ADMIN
                    Dim linkInformativaVisibile As Boolean = (From configurazione As ConfigurazioniDataSet.ConfigurazioniOttieniBySessioneRow In dt.Rows Where configurazione.Chiave = "LinkInformativaVisibile" Select configurazione.ValoreBoolean).FirstOrDefault
                    Dim linkInformativaVisibileStyle = String.Empty
                    If Not linkInformativaVisibile Then
                        linkInformativaVisibileStyle = _StyleNascosto
                    End If

                    ' Non viene usata per il portale ADMIN
                    Dim linkMailReferentiTooltip As String = (From configurazione As ConfigurazioniDataSet.ConfigurazioniOttieniBySessioneRow In dt.Rows Where configurazione.Chiave = "LinkMailReferentiTooltip" Select configurazione.ValoreString).FirstOrDefault
                    ' Non viene usata per il portale ADMIN
                    Dim linkPortaleClinicoTooltip As String = (From configurazione As ConfigurazioniDataSet.ConfigurazioniOttieniBySessioneRow In dt.Rows Where configurazione.Chiave = "LinkPortaleClinicoTooltip" Select configurazione.ValoreString).FirstOrDefault
                    ' Non viene usata per il portale ADMIN
                    Dim linkInformativaTooltip As String = (From configurazione As ConfigurazioniDataSet.ConfigurazioniOttieniBySessioneRow In dt.Rows Where configurazione.Chiave = "LinkInformativaTooltip" Select configurazione.ValoreString).FirstOrDefault

                    sMenu = String.Format(bootstrapHeader, BannerTitle, subtitle, linkPortale, linkMailReferenti, linkMailReferentiVisibileStyle, linkPortaleVisibileStyle, linkInformativaVisibileStyle, linkMailReferentiTooltip, linkPortaleClinicoTooltip, linkInformativaTooltip, GetURLInformazioni())
                End If
            End Using

            Return sMenu
        End Function


        Public Function GetSubTitle() As String

            Dim subtitle As String = ""

            Using ta As New ConfigurazioniDataSetTableAdapters.ConfigurazioniOttieniBySessioneTableAdapter(connectionStringPortalAdmin)

                Dim dt As ConfigurazioniDataSet.ConfigurazioniOttieniBySessioneDataTable = ta.GetData("MenuPortali")

                If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then

                    subtitle = (From configurazione As ConfigurazioniDataSet.ConfigurazioniOttieniBySessioneRow In dt.Rows Where configurazione.Chiave = "Subtitle" Select configurazione.ValoreString).FirstOrDefault
                End If
            End Using

            Return subtitle

        End Function

        ''' <summary>
        ''' Ottiene l'URL della pagina informazioni del portale home ADMIN
        ''' </summary>
        ''' <returns></returns>
        Public Function GetURLInformazioni() As String

            Using ta As New ConfigurazioniDataSetTableAdapters.ConfigurazioneMenuLista1TableAdapter(connectionStringPortalAdmin)
                Dim dt As ConfigurazioniDataSet.ConfigurazioneMenuLista1DataTable = ta.GetData()

                Dim items = dt.ToList()

                Return items.Where(Function(x) x.Titolo = "Informazioni").SingleOrDefault().Url
            End Using

        End Function

#End Region


#Region "Private"

        Private Function GetLocalhostFqdn() As String

            Dim oProperties = IPGlobalProperties.GetIPGlobalProperties()
            Return String.Format("{0}.{1}", oProperties.HostName, oProperties.DomainName)

        End Function


        Private Function GetEmbeddedResource(ResourceName As String) As String
            Dim oAssembly = Assembly.GetExecutingAssembly()
            Dim sRet As String = String.Empty

            Using stream As IO.Stream = oAssembly.GetManifestResourceStream(ResourceName)
                Trace.Assert(stream IsNot Nothing, "Risorsa " & ResourceName & " non trovata, controllare che sia settata la proprietà Build Action=Embedded Resource sul file")

                Using reader As New StreamReader(stream)
                    sRet = reader.ReadToEnd()
                End Using
            End Using

            Return sRet
        End Function

#End Region


    End Class


End Namespace

