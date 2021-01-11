Imports System.Web
Imports Microsoft.VisualBasic.Constants

Imports System.Net
Imports System.ServiceModel
Imports System
Imports System.Configuration

Public Class Utility

    ''' <summary>
    ''' Funzione per scrivere nel trace (si visualizza con DebugView)
    ''' </summary>
    ''' <remarks></remarks>
    Public Shared Sub TraceWriteLine(sMessage As String)
        System.Diagnostics.Trace.WriteLine(String.Concat("DLL_PORTAL_USER: ", sMessage))
    End Sub

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

    Public Shared Sub SetWcfSacCredential(ByVal oWs As WcfSacRoleManager.RoleManagerClient, ByVal User As String, ByVal Password As String)
        '
        ' Se User="" e Password="" -> authenticazione integrata altrimenti Basic
        '
        SetWCFCredentials(oWs.ChannelFactory.Endpoint.Binding, oWs.ClientCredentials, User, Password)
    End Sub

End Class
