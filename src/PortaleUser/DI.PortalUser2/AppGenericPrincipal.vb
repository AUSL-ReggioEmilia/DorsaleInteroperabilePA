Imports System.Security.Principal
Imports System.Web

Public Class AppGenericPrincipal
    Inherits GenericPrincipal

    Sub New(identity As WindowsIdentity, roles As String())
        '
        ' COPIO SID esitenti WindowsIdentity + nuovi ruoli
        '
        MyBase.New(identity, CopyRoleList(identity, roles))
    End Sub

    Private Shared Function CopyRoleList(identity As WindowsIdentity, roles As String()) As String()
        '
        ' Compilo ruoli dell'utente
        '
        Dim listRoles As New Generic.List(Of String)

        For Each irGroup As IdentityReference In identity.Groups
            '
            ' Aggiungo i SID dell'utente
            '
            If Not listRoles.Contains(irGroup.Value) Then
                listRoles.Add(irGroup.Value)
            End If
        Next
        '
        ' Appendo i CUSTOM
        '
        If roles IsNot Nothing AndAlso roles.Length > 0 Then
            For Each role As String In roles
                '
                ' Aggiungo se non c'è già
                '
                If Not listRoles.Contains(role) Then
                    listRoles.Add(role)
                End If
            Next
        End If

        Return listRoles.ToArray

    End Function

    Public Shared Function InitializeWithWindowsUser(addRoles As String()) As AppGenericPrincipal
        '
        ' Inizializzo copiando un Windows Identity e aggiungo RUOLI
        '
        ' Mi serve per leggere utente corrente e la lista dei suoi SID
        '
        Dim principalCurrent As IPrincipal = HttpContext.Current.User
        If principalCurrent Is Nothing Then
            Throw New ApplicationException("HttpContext.Current.User not found!")
        End If
        '
        ' Ritorno il Principal con i RUOLI applicativi COPIATO dal WindowsIdentity
        '
        Dim identityWindows As WindowsIdentity = TryCast(principalCurrent.Identity, WindowsIdentity)
        If identityWindows IsNot Nothing Then
            '
            ' Sostituisco Principal con AppGenericPrincipal
            '
            Dim principal As New AppGenericPrincipal(identityWindows, addRoles)
            HttpContext.Current.User = principal

            Return principal
        Else
            Throw New ApplicationException("WindowsIdentity not found!")
        End If

    End Function

    Public Overrides Function IsInRole(role As String) As Boolean

        If Not String.IsNullOrEmpty(role) Then
            '
            ' SPLIT con il carattere ';' per separare una lista di RUOLI
            '
            Dim asRoles As String() = role.Split(";"c)
            If asRoles IsNot Nothing AndAlso asRoles.Length > 0 Then
                '
                ' Loop  su tutti i non vuoti
                '
                For Each sRoleSplited As String In asRoles
                    If Not String.IsNullOrEmpty(sRoleSplited) Then
                        '
                        ' Rimuovo spazi prima e dopo
                        '
                        sRoleSplited = sRoleSplited.Trim()
                        '
                        ' Test ROLE
                        '
                        If IsInRoleBase(sRoleSplited) Then
                            '
                            ' Se trovato esce
                            '
                            Return True
                        End If
                    End If
                Next
            End If
        End If

        Return False

    End Function

    Public Function FirstValidRole(role As String) As String

        If Not String.IsNullOrEmpty(role) Then
            '
            ' SPLIT con il carattere ';' per separare una lista di RUOLI
            '
            Dim asRoles As String() = role.Split(";"c)
            If asRoles IsNot Nothing AndAlso asRoles.Length > 0 Then
                '
                ' Loop  su tutti i non vuoti
                '
                For Each sRoleSplited As String In asRoles
                    If Not String.IsNullOrEmpty(sRoleSplited) Then
                        '
                        ' Rimuovo spazi prima e dopo
                        '
                        sRoleSplited = sRoleSplited.Trim()
                        '
                        ' Test ROLE
                        '
                        If IsInRoleBase(sRoleSplited) Then
                            '
                            ' Se trovato esce
                            '
                            Return sRoleSplited
                        End If
                    End If
                Next
            End If
        End If

        Return Nothing

    End Function

    Private Function IsInRoleBase(role As String) As Boolean

        Dim bResult As Boolean = False

        If Not String.IsNullOrEmpty(role) Then
            '
            ' Cerco subito nella lista
            ' Potrebbe essere un RUOLO, un GRUPPO oppure un SID
            '
            bResult = MyBase.IsInRole(role)

            If Not bResult Then
                '
                ' Cerco se è un gruppo di NT per nome
                ' Prima TRASLO il Nome nel SID
                ' Poi cerco il SID nella lista
                Try
                    Dim ntRole As NTAccount = New NTAccount(role)
                    Dim irGroup As IdentityReference = ntRole.Translate(GetType(SecurityIdentifier))
                    '
                    ' Cerco nella lista per SID
                    '
                    bResult = MyBase.IsInRole(irGroup.Value)

                Catch ex As Exception
                End Try
            End If
        End If

        Return bResult

    End Function
End Class
