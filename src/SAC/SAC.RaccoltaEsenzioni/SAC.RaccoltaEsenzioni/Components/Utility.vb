Imports System.Net
Imports System.ServiceModel

Module Utility


    '
    ' Stringa di connessione al portale utente della DI
    '
    Public Const PAR_DI_PORTAL_USER_CONNECTION_STRING As String = "DiPortalUser.ConnectionString"

    Public Function FormatException(ByVal exception As Exception) As String
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


    Public Function GetAppSettings(ByVal Setting As String, ByVal DefaultValue As String) As String
        '
        ' Ritorna la configurazione
        '
        Try
            Dim sRet As String = ConfigurationManager.AppSettings(Setting)
            If sRet Is Nothing Then
                '
                ' Se non c'è il default
                '
                Return DefaultValue
            Else
                Return sRet
            End If
        Catch ex As Exception
            Return DefaultValue
        End Try
    End Function

#Region "WCF"

    Public Sub SetWcfSacPazientiCredential(ByVal oWs As WcfSacPazienti.PazientiClient)
        '
        ' Se User="" e Password="" -> authenticazione integrata altrimenti Basic
        '
        Dim sUser As String = My.Settings.WcfSac_User
        Dim sPassword As String = My.Settings.WcfSac_Password
        SetWCFCredentials(oWs.ChannelFactory.Endpoint.Binding, oWs.ClientCredentials, sUser, sPassword)
    End Sub

    ''' <summary>
    ''' Reimposta le credenziali di autenticazione al webservice
    ''' </summary>
    ''' <param name="oEndPointBinding">passare: oWs.ChannelFactory.Endpoint.Binding</param>
    ''' <param name="oCredentials">passare: oWs.ClientCredentials</param>
    ''' <param name="sUser">Nome Utente</param>
    ''' <param name="sPassword">Password</param>
    Public Sub SetWCFCredentials(oEndPointBinding As ServiceModel.Channels.Binding, oCredentials As ServiceModel.Description.ClientCredentials, sUser As String, sPassword As String)
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

    Private Function GetNetworkCredential(ByVal sUser As String, ByVal sPassword As String) As NetworkCredential

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
    Public Sub ShowErrorLabel(Label As UI.WebControls.Label, Text As String)

        Label.Text = Text
        If Text.Length > 0 Then
            Label.Visible = True
            Label.Style.Add("display", "block")
        End If

    End Sub

    ''' <summary>
    ''' Se l'oggetto è Nothing restituisce NullString
    ''' </summary>
    <System.Runtime.CompilerServices.Extension()>
    Public Function NullSafeToString(Of T)(this As T, Optional NullString As String = "") As String
        If this Is Nothing Then
            Return NullString
        End If
        Return this.ToString()
    End Function


    ''' <summary>
    ''' Ritorna DefaultValue se Value è NULL, altrimenti Value
    ''' </summary>
    Public Function IsNull(Of T)(ByVal Value As T, ByVal DefaultValue As T) As T
        If Value Is Nothing OrElse Convert.IsDBNull(Value) Then
            Return DefaultValue
        Else
            Return Value
        End If
    End Function

    ''' <summary>
    ''' Versione della DLL dell'applicazione web
    ''' </summary>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Function GetAssemblyVersion() As String
        '
        ' Legge versione della DLL
        '
        Try
            Return String.Format("Ver: {0}", System.Reflection.Assembly.GetExecutingAssembly.GetName.Version.ToString())
        Catch
            Return String.Empty
        End Try
    End Function
End Module
