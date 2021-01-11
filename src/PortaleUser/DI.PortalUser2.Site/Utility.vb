Imports System.Web
Imports Microsoft.VisualBasic.Constants

Imports System.Net
Imports System.ServiceModel

Public Class Utility

    ''' <summary>
    ''' Definisce dei codici che rappresentano i vari tipi di errore gestiti nelle pagine ErroPage.aspx per accesso standard e accesso diretto
    ''' </summary>
    ''' <remarks></remarks>
    Public Enum ErrorCode
        Unknow
        AccessDenied
        NoRights
        MissingResource
        Exception
    End Enum

    Public Const PORTAL_USER_CONNECTION_STRING As String = "AuslAsmnRe_PortalUserConnectionString"
    Public Const SAC_CONNECTION_STRING As String = "AuslAsmnRe_SacConnectionString"
    Public Const SESS_DATI_ULTIMO_ACCESSO As String = "-DATI_ULTIMO_ACCESSO-" 'usata per visualizzare i dati di ultimo accesso nel box delle info utente
    Private Const SESS_HOST_NAME As String = "-HOST_NAME-"

    ''' <summary>
    ''' Da utilizzare nella pagina navigata per aggiungere i parametri di query string all'url associato al ramo del tree cosi da poter navigare all'indietro tramite il menù di navigazione orizzontale
    ''' </summary>
    ''' <param name="oSiteMapNode">Normalmente uguale a SiteMap.CurrentNode</param>
    ''' <param name="sQueryString">L'intero query string da aggiungere all'url</param>
    ''' <remarks></remarks>
    Public Shared Sub SetSiteMapNodeQueryString(oSiteMapNode As SiteMapNode, sQueryString As String)
        Try
            If oSiteMapNode IsNot Nothing Then
                oSiteMapNode.ReadOnly = False
                sQueryString = sQueryString.TrimStart("?")
                sQueryString = String.Concat("?", sQueryString)
                oSiteMapNode.Url = String.Concat(oSiteMapNode.Url.Split("?")(0), sQueryString)
            End If
        Catch
        End Try
    End Sub

    ''' <summary>
    ''' Funzione per scrivere nel trace (si visualizza con DebugView)
    ''' </summary>
    ''' <remarks></remarks>
    Public Shared Sub TraceWriteLine(sMessage As String)
        System.Diagnostics.Trace.WriteLine(String.Concat("HOME-USER: ", sMessage))
    End Sub


#Region " Funzioni generiche per la cache "

    Public Class MyCache

        Public Shared Sub Write(sKey As String, value As Object, iSecToLive As Integer)
            If iSecToLive <= 0 Then iSecToLive = 60
            HttpContext.Current.Cache.Add(sKey, value, Nothing, System.DateTime.Now.AddSeconds(iSecToLive), Caching.Cache.NoSlidingExpiration, Caching.CacheItemPriority.Normal, Nothing)
        End Sub

        Public Shared Function Read(sKey As String) As Object
            Return HttpContext.Current.Cache(sKey)
        End Function

        Public Shared Sub Remove(sKey As String)
            HttpContext.Current.Cache.Remove(sKey)
        End Sub

    End Class

#End Region


#Region "Memorizzazione URL pagina visitata"
    Private Const URL_CORRENTE As String = "_UrlCorrente_"
    Public Shared Sub SetUrlCorrente()
        '
        ' Memorizzo la stringa originale con eventuali encoding
        '
        Dim sUrl As String = HttpContext.Current.Request.Url.OriginalString
        HttpContext.Current.Session(URL_CORRENTE) = sUrl
    End Sub

    Public Shared Function GetUrlCorrente() As String
        Return CType(HttpContext.Current.Session(URL_CORRENTE), String)
    End Function

#End Region




#Region "WebService"

    '****************************************************************************
    ' COME SI IMPOSTANO LE CREDENZIALI DI UN WEB SERVICE:
    ' Dim oWs as New <MyWebServiceReference>
    ' Call SetWCFCredentials(oWs.ChannelFactory.Endpoint.Binding, oWs.ClientCredentials, sUser, sPassword)
    '****************************************************************************

    ''' <summary>
    ''' Reimposta le credenziali di autenticazione al webservice
    ''' </summary>
    ''' <param name="oEndPointBinding">passare: oWs.ChannelFactory.Endpoint.Binding</param>
    ''' <param name="oCredentials">passare: oWs.ClientCredentials</param>
    ''' <param name="sUser">Nome Utente</param>
    ''' <param name="sPassword">Password</param>
    Public Shared Sub SetWCFCredentials(oEndPointBinding As ServiceModel.Channels.Binding, oCredentials As ServiceModel.Description.ClientCredentials, sUser As String, sPassword As String)
        Dim oBasicAuth As BasicHttpBinding = TryCast(oEndPointBinding, BasicHttpBinding)
        If oBasicAuth IsNot Nothing Then
            '
            ' basicBinding, SOAP 1.1
            '
            Dim oCredType = oBasicAuth.Security.Transport.ClientCredentialType
            If oCredType = HttpClientCredentialType.Basic Then
                '
                ' Autenticazione BASIC
                '
                oCredentials.UserName.UserName = sUser
                oCredentials.UserName.Password = sPassword
                oBasicAuth.UseDefaultWebProxy = False
                '
                ' Attenzione dipende anche dalla configurazione del WS (file web.config)
                '<security mode="Transport">
                '  <transport clientCredentialType="Basic"/>
                '</security>                '

            ElseIf oCredType = HttpClientCredentialType.Windows Then
                '
                ' Autenticazione WINDOWS
                ' Se non ho fornito user e password lascio fare al sistema.
                '
                If Not String.IsNullOrEmpty(sUser) AndAlso Not String.IsNullOrEmpty(sPassword) Then
                    oCredentials.Windows.ClientCredential = GetNetworkCredential(sUser, sPassword)
                End If
                '
                ' Attenzione dipende anche dalla configurazione del WS (file web.config)
                '<security mode="Transport">
                '  <transport clientCredentialType="Windows"/>
                '</security>
                '
            Else
                Dim sErrorMsg As String = String.Format("Il tipo di credenziali 'HttpClientCredentialType.{0}' non è gestito!", oCredType.ToString)
                sErrorMsg = sErrorMsg & vbCrLf & _
                            "I tipi di credenziali gestiti sono: 'HttpClientCredentialType.Basic', 'HttpClientCredentialType.Windows'."
                Throw New ApplicationException(sErrorMsg)
            End If
        Else
            Dim sErrorMsg As String = String.Format("Il tipo di binding '{0}' non è gestito!", oEndPointBinding.ToString)
            sErrorMsg = sErrorMsg & vbCrLf & _
                    "Utilizzare il tipo di binding 'BasicHttpBinding'."
            Throw New ApplicationException(sErrorMsg)
        End If
    End Sub


    Private Shared Function GetNetworkCredential(ByVal sUser As String, ByVal sPassword As String) As NetworkCredential

        Dim credentials As NetworkCredential

        If sUser.Length > 0 Then
            'Basic autentication                
            Dim domain As String = String.Empty
            Dim account As String() = sUser.Replace("\", "/").Split("/"c)

            If account.Length > 1 Then
                domain = account(0)
                sUser = account(1)
            End If

            credentials = New NetworkCredential(sUser, sPassword, domain)
        Else
            'Integrated autentication                
            credentials = CType(CredentialCache.DefaultCredentials(), NetworkCredential)
        End If

        Return credentials
    End Function


    Public Shared Function GetMyProxy(ByVal sProxyUrl As String, ByVal sProxyBypassList As String, ByVal sProxyBypassLocal As String, ByVal sUser As String, ByVal sPassword As String) As IWebProxy

        If sProxyUrl.Length > 0 Then
            '
            ' Crea credenziali
            '
            Dim oMyCred As NetworkCredential = GetNetworkCredential(sUser, sPassword)

            '
            ' Proxy BypassList
            '
            Dim asProxyBypassList() As String
            If sProxyBypassList.Length > 0 Then
                asProxyBypassList = sProxyBypassList.Split(";"c)
            Else
                asProxyBypassList = Nothing
            End If

            Return New WebProxy(sProxyUrl, CBool(sProxyBypassLocal), asProxyBypassList, oMyCred)
        Else
            Return Nothing
        End If
    End Function


    ''' <summary>
    ''' Restituisce l'url relativo all'application. Utile per trovare l'URL relatuivo a folder e pagine
    ''' </summary>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Function GetApplicationPath() As String
        Return HttpContext.Current.Request.ApplicationPath.TrimEnd("/") & "/"
    End Function

    ''' <summary>
    ''' Scrive nella tabella DiPortalUser.TracciaAccessi un record di log specificando il codice del ruolo selezionato dall'utente
    ''' </summary>
    ''' <param name="sRuoloCodice"></param>
    ''' <remarks></remarks>
    Public Shared Sub PortalUserTracciaAccessi(sRuoloCodice As String)
        '
        '  Scrivo il ruolo nel DbUserPortal 
        '
        Dim sDiPortalUserConnectionString As String = ConfigurationManager.ConnectionStrings(Utility.PORTAL_USER_CONNECTION_STRING).ConnectionString
        Dim portal As DI.PortalUser2.Data.PortalDataAdapterManager = New DI.PortalUser2.Data.PortalDataAdapterManager(sDiPortalUserConnectionString)
        Dim dNow = DateTime.Now
        Call portal.TracciaAccessi(HttpContext.Current.User.Identity.Name, DI.PortalUser2.Data.PortalsNames.Home, String.Format("Accesso effettuato il {0} alle ore {1}", dNow.ToString("dd/MM/yyy"), dNow.ToString("HH:mm:ss")), sRuoloCodice)
    End Sub

    Public Shared Function GetUserHostName() As String
        Dim sHostName As String = Nothing
        '
        ' Controllo se l'host name è in sessione.
        ' Se non c'è ottengo l'host name con la funzione "_GetUserHostName()" e poi la salvo in sessione
        ' Altrimenti restituisco la variabile di sessione
        '
        If HttpContext.Current.Session(SESS_HOST_NAME) Is Nothing Then
            sHostName = _GetUserHostName()
            HttpContext.Current.Session(SESS_HOST_NAME) = sHostName
        Else
            sHostName = CType(HttpContext.Current.Session(SESS_HOST_NAME), String)
        End If
        Return sHostName
    End Function


    Private Shared Function _GetUserHostName() As String
        Dim oNetIp As System.Net.IPHostEntry = Nothing
        Dim sRemoteAddr As String = HttpContext.Current.Request.ServerVariables("HTTP_X_FORWARDED_FOR")

        '
        ' Controllo se sRemoteAddr è vuota. Se è vuota allora uso la ServerVariabiles "remote_addr"
        '
        If String.IsNullOrEmpty(sRemoteAddr) Then
            sRemoteAddr = HttpContext.Current.Request.ServerVariables("remote_addr")
        End If

        Try
            oNetIp = System.Net.Dns.GetHostEntry(sRemoteAddr)
        Catch ex As Exception
            'Restituisco l'indirizzo IP
            Return sRemoteAddr
        End Try

        Dim sHostName As String = sRemoteAddr
        Try
            sHostName = oNetIp.HostName
        Catch ex As Exception
            'Se errore restituisco comunque indirizzo IP 
        End Try

        Return sHostName
    End Function


    ''' <summary>
    ''' Funzione utilizzata per navigare alla pagina di errore
    ''' </summary>
    ''' <param name="enumErrorCode"></param>
    ''' <param name="sErroreDescrizione"></param>
    ''' <param name="endResponse"></param>
    ''' <remarks></remarks>
    Public Shared Sub NavigateToErrorPage(enumErrorCode As Utility.ErrorCode, sErroreDescrizione As String, endResponse As Boolean)
        ErrorPage.SetErrorDescription(enumErrorCode, sErroreDescrizione)
        HttpContext.Current.Response.Redirect("~/ErrorPage.aspx", endResponse)
    End Sub

	''' <summary>
	''' Legge versione dell'assembly
	''' </summary>
	Public Shared Function GetAssemblyVersion() As String

		Dim asm = System.Reflection.Assembly.GetExecutingAssembly()
		Return String.Format("Ver: {0}", asm.GetName.Version)

	End Function
#End Region

End Class
