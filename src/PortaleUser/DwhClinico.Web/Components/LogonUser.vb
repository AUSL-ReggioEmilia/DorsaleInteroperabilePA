Imports Microsoft.VisualBasic
Imports System.Diagnostics
Imports System.Security.Principal
Imports System.Runtime.InteropServices

Public Class LogonUser
    Implements IDisposable

#Region " IDisposable Support "
    ' This code added by Visual Basic to correctly implement the disposable pattern.
    Public Sub Dispose() Implements IDisposable.Dispose
        ' Do not change this code.  Put cleanup code in Dispose(ByVal disposing As Boolean) above.
        Dispose(True)
        GC.SuppressFinalize(Me)
    End Sub
#End Region

    Private disposedValue As Boolean = False        ' To detect redundant calls

    ' IDisposable
    Protected Overridable Sub Dispose(ByVal disposing As Boolean)
        If Not Me.disposedValue Then
            If disposing Then
                ' TODO: free managed resources when explicitly called
            End If
            '
            ' Chiude
            '
            If Not _dupeTokenHandle = IntPtr.Zero Then
                CloseHandle(_dupeTokenHandle)
            End If

        End If
        Me.disposedValue = True
    End Sub

    Private Declare Auto Function LogonUser Lib "advapi32.dll" (ByVal lpszUsername As [String], _
               ByVal lpszDomain As [String], ByVal lpszPassword As [String], _
               ByVal dwLogonType As Integer, ByVal dwLogonProvider As Integer, _
               ByRef phToken As IntPtr) As Boolean

    Private Declare Auto Function CloseHandle Lib "kernel32.dll" (ByVal handle As IntPtr) As Boolean

    Private Declare Auto Function DuplicateToken Lib "advapi32.dll" (ByVal ExistingTokenHandle As IntPtr, _
                    ByVal SECURITY_IMPERSONATION_LEVEL As Integer, _
                    ByRef DuplicateTokenHandle As IntPtr) As Boolean

    Dim _dupeTokenHandle As IntPtr = IntPtr.Zero

    Public Function Impersonate(ByVal sDomain As String, ByVal sUser As String, _
                                    ByVal sPassword As String) As WindowsImpersonationContext

        Const LOGON32_PROVIDER_DEFAULT As Integer = 0
        Const LOGON32_LOGON_INTERACTIVE As Integer = 2

        Const SecurityImpersonation As Integer = 2

        Dim tokenHandle As IntPtr = IntPtr.Zero

        If String.IsNullOrEmpty(sUser) Then
            Throw New ArgumentNullException
        End If

        Try
            '
            ' Logon
            '
            Dim returnValue As Boolean = LogonUser(sUser, sDomain, _
                                                 sPassword, LOGON32_LOGON_INTERACTIVE, _
                                                 LOGON32_PROVIDER_DEFAULT, tokenHandle)

            If returnValue = False Then
                Dim ret As Integer = Marshal.GetLastWin32Error()
                Dim sError As String = String.Format("LogonUser() fallita con codice d'errore:: {0} ", ret)

                Throw New ApplicationException(sError)
            End If
            '
            ' Dupplica token
            '
            Dim retVal As Boolean = DuplicateToken(tokenHandle, _
                                            SecurityImpersonation, _dupeTokenHandle)

            If returnValue = False Then
                Dim ret As Integer = Marshal.GetLastWin32Error()
                Dim sError As String = String.Format("Duplicazione del token fallita con codice d'errore: {0} ", ret)

                Throw New ApplicationException(sError)
            End If
            '
            ' Utente della configurazione
            '
            Return New WindowsIdentity(_dupeTokenHandle).Impersonate

        Catch ex As Exception
            '
            ' chiude
            '
            If Not _dupeTokenHandle = IntPtr.Zero Then
                CloseHandle(_dupeTokenHandle)
            End If

            Throw New ApplicationException("Errore durante LogonUser.Impersonate() di un login!", ex)
        Finally
            '
            ' chiude
            '
            If Not tokenHandle = IntPtr.Zero Then
                CloseHandle(tokenHandle)
            End If

        End Try

    End Function

    Public Function Impersonate() As WindowsImpersonationContext
        '
        ' Impersonifica utente corrente
        '
        Dim WindowsUserCurrent As WindowsIdentity
        Try
            WindowsUserCurrent = TryCast(HttpContext.Current.User.Identity, WindowsIdentity)
            If WindowsUserCurrent Is Nothing Then
                Throw New ApplicationException("Errore WindowsIdentity non trovato!")
            End If
            '
            '
            '
            Return WindowsUserCurrent.Impersonate

        Catch ex As Exception
            Throw New ApplicationException("Errore durante LogonUser.Impersonate() dell'utente corrente!", ex)
        End Try

    End Function

    Public Function ImpersonateProcess() As WindowsImpersonationContext

        Try
            Return WindowsIdentity.Impersonate(IntPtr.Zero)

        Catch ex As Exception

            Throw New ApplicationException("Errore durante LogonUser.ImpersonateProcess()!", ex)

        End Try

    End Function

End Class
