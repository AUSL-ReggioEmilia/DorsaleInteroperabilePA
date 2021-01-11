Imports System.Collections
Imports System.Security.Principal
'
Namespace DI.Security

    ''' <summary>
    ''' Classe che eredita da <see cref="System.Security.Principal.WindowsPrincipal"></see> e gestisce una modalità ibrida di autenticazione
    ''' basata sia su AD che su ruoli aggiuntivi eventualmente specificati
    ''' </summary>
    ''' <remarks></remarks>
    Public Class HybridPrincipal
        Inherits WindowsPrincipal

        Private _customRoles As List(Of String)

        ''' <summary>
        ''' Istanzia un nuovo oggetto HybridPrincipal
        ''' </summary>
        ''' <param name="identity">L'oggetto <see cref="System.Security.Principal.WindowsIdentity"></see> di base</param>
        ''' <remarks></remarks>
        Public Sub New(ByVal identity As WindowsIdentity)
            MyBase.New(identity)

            _customRoles = New List(Of String)()
        End Sub

        ''' <summary>
        ''' Istanzia un nuovo oggetto HybridPrincipal
        ''' </summary>
        ''' <param name="identity">L'oggetto <see cref="System.Security.Principal.WindowsIdentity"></see> di base</param>
        ''' <param name="roles">La lista dei ruoli aggiuntivi</param>
        ''' <remarks></remarks>
        Public Sub New(ByVal identity As WindowsIdentity, roles As IEnumerable(Of String))
            MyBase.New(identity)

            _customRoles = New List(Of String)()

            AddRolesRange(roles)
        End Sub

        ''' <summary>
        ''' Determina se l'utente collegato appartiene a un gruppo di AD o a un ruolo applicativo
        ''' </summary>
        ''' <param name="roleName"></param>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public Overloads Overrides Function IsInRole(ByVal roleName As String) As Boolean

            Return _customRoles.Contains(roleName) OrElse MyBase.IsInRole(roleName)
        End Function

        ''' <summary>
        ''' Aggiunge un elemento alla lista dei ruoli applicativi
        ''' </summary>
        ''' <param name="role">il ruolo da aggiungere</param>
        ''' <remarks></remarks>
        Public Sub AddRole(ByVal role As String)
            _customRoles.Add(role)
        End Sub

        ''' <summary>
        ''' Aggiunge una serie di elementi alla lista dei ruoli applicativi
        ''' </summary>
        ''' <param name="roles">Una lista di ruoli da aggiungere</param>
        ''' <remarks></remarks>
        Public Sub AddRolesRange(ByVal roles As IEnumerable(Of String))
            _customRoles.AddRange(roles)
        End Sub
    End Class

End Namespace