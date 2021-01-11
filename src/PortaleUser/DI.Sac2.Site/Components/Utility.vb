Imports System.Net
Imports System.ServiceModel
Imports System.Web
Imports DI.PortalUser2
Imports Microsoft.VisualBasic.Constants

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

    Public Shared ConnectionStringPortalUser As String = ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalUserConnectionString").ConnectionString


    ''' <summary>
    ''' Funzione per scrivere nel trace (si visualizza con DebugView)
    ''' </summary>
    ''' <remarks></remarks>
    Public Shared Sub TraceWriteLine(sMessage As String)
        System.Diagnostics.Trace.WriteLine(String.Concat("SAC-USER: ", sMessage))
    End Sub


    Public Shared Function FormatException(ByVal exception As Exception) As String
        If exception Is Nothing Then
            Throw New ArgumentNullException("exception")
        End If
        Dim result As New System.Text.StringBuilder()
        Dim currentException As Exception = exception

        While exception IsNot Nothing
            result.AppendLine(exception.Message)
            result.AppendLine(exception.StackTrace)
            exception = exception.InnerException
        End While
        Return result.ToString()
    End Function


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
        Dim portal As DI.PortalUser2.Data.PortalDataAdapterManager = New DI.PortalUser2.Data.PortalDataAdapterManager(sDiPortalUserConnectionString)
        Dim dNow = DateTime.Now
        Call portal.TracciaAccessi(HttpContext.Current.User.Identity.Name, DI.PortalUser2.Data.PortalsNames.Sac, String.Format("Accesso effettuato il {0} alle ore {1}", dNow.ToString("dd/MM/yyy"), dNow.ToString("HH:mm:ss")), sRuoloCodice)
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



#Region "Parsing campo XML degli attributi"

    Public Const ATTRIBUTO_AUTORIZZATORE_NOME = "AutorizzatoreMinoreNome"
    Public Const ATTRIBUTO_AUTORIZZATORE_COGNOME = "AutorizzatoreMinoreCognome"
    Public Const ATTRIBUTO_AUTORIZZATORE_DATANASCITA = "AutorizzatoreMinoreDataNascita"
    Public Const ATTRIBUTO_AUTORIZZATORE_LUOGONASCITA = "AutorizzatoreMinoreLuogoNascita"
    Public Const ATTRIBUTO_AUTORIZZATORE_RELAZIONEMINORE = "AutorizzatoreMinoreRelazione"

    Public Shared Function ShowAttributi(oAttributi As Object) As String
        Dim sRet As String = String.Empty
        If Not oAttributi Is DBNull.Value Then
            Dim sAttributi As String = DirectCast(oAttributi, String)
            Dim oXml As System.Xml.Linq.XDocument = System.Xml.Linq.XDocument.Parse(sAttributi)
            Dim query As System.Collections.Generic.IEnumerable(Of System.Xml.Linq.XElement) = From p In oXml.Root.Elements("Attributo")
            If query.Count > 0 Then
                Dim oSb As New Text.StringBuilder
                For Each oAttributo As System.Xml.Linq.XElement In query
                    Dim sNomeAttributo As String = oAttributo.@Nome

                    Dim sValoreAttributo As String = oAttributo.@Valore
                    If String.Compare(sNomeAttributo, ATTRIBUTO_AUTORIZZATORE_DATANASCITA, True) = 0 Then
                        Dim dDataNascita As Date = Nothing
                        If Date.TryParse(sValoreAttributo, dDataNascita) Then
                            oSb.Append(sNomeAttributo) : oSb.Append(": ") : oSb.Append(dDataNascita.ToString("d")) : oSb.Append("<br/>")
                        End If
                    Else
                        oSb.Append(sNomeAttributo) : oSb.Append(": ") : oSb.Append(sValoreAttributo) : oSb.Append("<br/>")
                    End If
                Next
                sRet = oSb.ToString
            End If
        End If
        '
        ' Restituisco
        '
        Return sRet
    End Function


    Public Shared Function ShowAttributiWcf(attributi As WcfSacPazienti.AttributiType) As String
        Dim sRet As String = String.Empty

        Dim oSb As New Text.StringBuilder
        If attributi IsNot Nothing Then
            For Each attributo As WcfSacPazienti.AttributoType In attributi
                Dim nomeAttributo As String = attributo.Nome
                Dim valoreAttributo As String = attributo.Valore

                If String.Compare(nomeAttributo, ATTRIBUTO_AUTORIZZATORE_DATANASCITA, True) = 0 Then
                    Dim dDataNascita As Date = Nothing
                    If Date.TryParse(valoreAttributo, dDataNascita) Then
                        oSb.Append(nomeAttributo) : oSb.Append(": ") : oSb.Append(dDataNascita.ToString("d")) : oSb.Append("<br/>")
                    End If
                Else
                    oSb.Append(nomeAttributo) : oSb.Append(": ") : oSb.Append(valoreAttributo) : oSb.Append("<br/>")
                End If
            Next
            sRet = oSb.ToString
        End If

        Return sRet
    End Function




    Public Shared Function ShowAttributiAutorizzatoreMinore(oAttributi As Object) As String
        Dim sRet As String = String.Empty
        If Not oAttributi Is DBNull.Value Then

            Dim sAttributi As String = DirectCast(oAttributi, String)
            Dim oXml As System.Xml.Linq.XDocument = System.Xml.Linq.XDocument.Parse(sAttributi)
            'Leggo solo gli attributi che iniziano con "AutorizzatoreMinore"
            Dim query As System.Collections.Generic.IEnumerable(Of System.Xml.Linq.XElement) = From p In oXml.Root.Elements("Attributo") Where p.@Nome.StartsWith("AutorizzatoreMinore", StringComparison.CurrentCultureIgnoreCase)
            If query.Count > 0 Then
                Dim oSb As New Text.StringBuilder
                For Each oAttributo As System.Xml.Linq.XElement In query
                    Dim sNomeAttributo As String = oAttributo.@Nome
                    Dim sValoreAttributo As String = oAttributo.@Valore
                    If String.Compare(sNomeAttributo, ATTRIBUTO_AUTORIZZATORE_DATANASCITA, True) = 0 Then
                        Dim dDataNascita As Date = Nothing
                        If Date.TryParse(sValoreAttributo, dDataNascita) Then
                            'Rimuovo il testo "AutorizzatoreMinore"
                            sNomeAttributo = sNomeAttributo.Remove(0, 19)
                            oSb.Append(sNomeAttributo) : oSb.Append(": ") : oSb.Append(dDataNascita.ToString("d")) : oSb.Append("<br/>")
                        End If
                    Else
                        'Rimuovo il testo "AutorizzatoreMinore"
                        sNomeAttributo = sNomeAttributo.Remove(0, 19)
                        oSb.Append(sNomeAttributo) : oSb.Append(": ") : oSb.Append(sValoreAttributo) : oSb.Append("<br/>")
                    End If
                Next
                sRet = oSb.ToString
            End If
        End If
        '
        ' Restituisco
        '
        Return sRet

    End Function

#End Region

    Public Shared Function IsUserAnonimizzatore() As Boolean
        Return HttpContext.Current.User.IsInRole(RoleManagerUtility2.ATTRIB_UTE_ANONIMIZZATORE)
    End Function

    Public Shared Function IsUserPosizioniCollegate() As Boolean
        Return HttpContext.Current.User.IsInRole(RoleManagerUtility2.ATTRIB_UTE_POS_COLLEGATE)
    End Function


#Region "WCF"

    Public Shared Sub SetWcfSacPazientiCredential(ByVal oWs As WcfSacPazienti.PazientiClient)
        '
        ' Se User="" e Password="" -> authenticazione integrata altrimenti Basic
        '
        Dim sUser As String = My.Settings.WsSac_User
        Dim sPassword As String = My.Settings.WsSac_Password
        SetWCFCredentials(oWs.ChannelFactory.Endpoint.Binding, oWs.ClientCredentials, sUser, sPassword)
    End Sub

    ''' <summary>
    ''' Reimposta le credenziali di autenticazione al webservice
    ''' </summary>
    ''' <param name="oEndPointBinding">passare: oWs.ChannelFactory.Endpoint.Binding</param>
    ''' <param name="oCredentials">passare: oWs.ClientCredentials</param>
    ''' <param name="sUser">Nome Utente</param>
    ''' <param name="sPassword">Password</param>
    Public Shared Sub SetWCFCredentials(oEndPointBinding As ServiceModel.Channels.Binding, oCredentials As ServiceModel.Description.ClientCredentials, sUser As String, sPassword As String)
        Dim sErrorMsg As String = String.Empty
        Dim oBasicHttpBinding As BasicHttpBinding = TryCast(oEndPointBinding, BasicHttpBinding)
        If oBasicHttpBinding IsNot Nothing Then
            Dim oCredType = oBasicHttpBinding.Security.Transport.ClientCredentialType
            If oCredType = HttpClientCredentialType.Basic Then
                ' Autenticazione BASIC
                oCredentials.UserName.UserName = sUser
                oCredentials.UserName.Password = sPassword
                oBasicHttpBinding.UseDefaultWebProxy = False
                Exit Sub
            ElseIf oCredType = HttpClientCredentialType.Windows Then
                ' Autenticazione WINDOWS
                ' Se non ho fornito user e password lascio fare al sistema.
                If Not String.IsNullOrEmpty(sUser) AndAlso Not String.IsNullOrEmpty(sPassword) Then
                    oCredentials.Windows.ClientCredential = GetNetworkCredential(sUser, sPassword)
                End If
                Exit Sub
            Else
                sErrorMsg = String.Format("Il tipo di credenziali 'HttpClientCredentialType.{0}' non è gestito!", oCredType.ToString)
                sErrorMsg = sErrorMsg & vbCrLf &
                            "I tipi di credenziali gestiti sono: 'HttpClientCredentialType.Basic', 'HttpClientCredentialType.Windows'."
                Throw New ApplicationException(sErrorMsg)
            End If
        End If
        Dim oWSHttpBinding As WSHttpBinding = TryCast(oEndPointBinding, WSHttpBinding)
        If oWSHttpBinding IsNot Nothing Then
            Dim oCredType = oWSHttpBinding.Security.Transport.ClientCredentialType
            If oCredType = HttpClientCredentialType.Basic Then
                ' Autenticazione BASIC
                oCredentials.UserName.UserName = sUser
                oCredentials.UserName.Password = sPassword
                oWSHttpBinding.UseDefaultWebProxy = False
                Exit Sub
            ElseIf oCredType = HttpClientCredentialType.Windows Then
                ' Autenticazione WINDOWS
                ' Se non ho fornito user e password lascio fare al sistema.
                If Not String.IsNullOrEmpty(sUser) AndAlso Not String.IsNullOrEmpty(sPassword) Then
                    oCredentials.Windows.ClientCredential = GetNetworkCredential(sUser, sPassword)
                End If
                Exit Sub
            Else
                sErrorMsg = String.Format("Il tipo di credenziali 'HttpClientCredentialType.{0}' non è gestito!", oCredType.ToString)
                sErrorMsg = sErrorMsg & vbCrLf &
                            "I tipi di credenziali gestiti sono: 'HttpClientCredentialType.Basic', 'HttpClientCredentialType.Windows'."
                Throw New ApplicationException(sErrorMsg)
            End If
        End If
        '
        ' Se sono qui il tipo di binding non è gestito
        '
        sErrorMsg = String.Format("Il tipo di binding '{0}' non è gestito!", oEndPointBinding.ToString)
        sErrorMsg = sErrorMsg & vbCrLf &
                   "Utilizzare il tipo di binding 'BasicHttpBinding'/'WsHttpBinding'."
        Throw New ApplicationException(sErrorMsg)
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



#End Region


    ''' <summary>
    ''' Mostra il Testo passato nella Label e la rende visibile
    ''' </summary>
    ''' <param name="Label">Label da mostrare</param>
    ''' <param name="Text">Testo da visualizzare</param>
    ''' <remarks></remarks>
    Public Shared Sub ShowErrorLabel(Label As UI.WebControls.Label, Text As String)

        Label.Text = Text
        If Text.Length > 0 Then
            Label.Visible = True
            Label.Style.Add("display", "block")
        End If

    End Sub

End Class
