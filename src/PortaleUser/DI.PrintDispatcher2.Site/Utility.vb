Imports DI.PortalUser2.Data

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


    ''' <summary>
    ''' Legge versione dell'assembly
    ''' </summary>
    Public Shared Function GetAssemblyVersion() As String

        Dim asm = System.Reflection.Assembly.GetExecutingAssembly()
        Return String.Format("Ver: {0}", asm.GetName.Version)

    End Function


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
    ''' Scrive nella tabella DiPortalUser.TracciaAccessi un record di log specificando il codice del ruolo selezionato dall'utente
    ''' </summary>
    ''' <param name="sRuoloCodice"></param>
    ''' <remarks></remarks>
    Public Shared Sub PortalUserTracciaAccessi(sRuoloCodice As String)
        '
        '  Scrivo il ruolo nel DbUserPortal 
        '
        Dim sDiPortalUserConnectionString As String = ConfigurationManager.ConnectionStrings(Utility.PORTAL_USER_CONNECTION_STRING).ConnectionString
        Dim portal As PortalDataAdapterManager = New PortalDataAdapterManager(sDiPortalUserConnectionString)
        Dim dNow = DateTime.Now
        Call portal.TracciaAccessi(HttpContext.Current.User.Identity.Name, PortalsNames.PrintDispatcher, String.Format("Accesso effettuato il {0} alle ore {1}", dNow.ToString("dd/MM/yyy"), dNow.ToString("HH:mm:ss")), sRuoloCodice)
    End Sub


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
    ''' Restituisce l'url relativo all'application. Utile per trovare l'URL relatuivo a folder e pagine
    ''' </summary>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Function GetApplicationPath() As String
        Return HttpContext.Current.Request.ApplicationPath.TrimEnd("/") & "/"
    End Function

    ''' <summary>
    ''' Funzione per scrivere nel trace (si visualizza con DebugView)
    ''' </summary>
    ''' <remarks></remarks>
    Public Shared Sub TraceWriteLine(sMessage As String)
        System.Diagnostics.Trace.WriteLine(String.Concat("PRINTDISPATCHER-USER: ", sMessage))
    End Sub



End Class
