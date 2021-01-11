Imports System.Security.Principal
Imports System.Web.SessionState
Imports System.Web
Imports System
Imports System.Web.Caching
Imports DI.PortalAdmin.Data
Imports System.Configuration
Imports System.Collections.Generic
Imports System.Linq
Imports System.Diagnostics
Imports System.DirectoryServices.AccountManagement
Imports DI.Security
Imports Microsoft.ApplicationInsights
Imports CustomInitializer.Telemetry
Imports Microsoft.ApplicationInsights.Extensibility

Namespace DI.Sac.Admin

    Public Class Global_asax
        Inherits HttpApplication

        Private Shared _usersLastRequestDateTime As New Dictionary(Of String, DateTime)()

        Public Shared ConnectionStringPortalAdmin As String = ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString

        Sub Application_Start(ByVal sender As Object, ByVal e As EventArgs)
            TelemetryConfiguration.Active.TelemetryInitializers.Add(New MyTelemetryInitializer())
        End Sub

        Sub Session_Start(ByVal sender As Object, ByVal e As EventArgs)

            Dim portal = New PortalDataAdapterManager(ConnectionStringPortalAdmin)

            Dim now = DateTime.Now

            portal.TracciaAccessi(User.Identity.Name, PortalsNames.Sac, String.Format("Accesso effettuato il {0} alle ore {1}", now.ToString("dd/MM/yyy"), now.ToString("HH:mm:ss")))

            Me.Session.Add("userName", User.Identity.Name)
        End Sub

        Sub Application_BeginRequest(ByVal sender As Object, ByVal e As EventArgs)

        End Sub

        Sub Application_PostAuthenticateRequest(sender As Object, e As EventArgs) Handles MyBase.PostAuthenticateRequest
            SyncLock _usersLastRequestDateTime
                If Not _usersLastRequestDateTime.ContainsKey(User.Identity.Name) Then

                    _usersLastRequestDateTime.Add(User.Identity.Name, DateTime.Now)
                Else
                    _usersLastRequestDateTime(User.Identity.Name) = DateTime.Now
                End If
            End SyncLock
        End Sub

        Sub Application_AuthenticateRequest(ByVal sender As Object, ByVal e As EventArgs)

            If Request.IsAuthenticated Then
                Dim userName As String = User.Identity.Name
                '
                ' Leggo i ruoli dalla cache
                '
                Dim roles As List(Of String) = RolesHelper.ReadRolesList(userName)
                If roles Is Nothing Then
                    '
                    ' Se l'utente fa parte del ruolo configurato nel setting SiteAdmins, gli assegno i diritti amministrativi
                    '
                    roles = RolesHelper.GetAllRoles(userName, User.IsInRole(My.Settings.SiteAdmins))
                    '
                    ' Scrivo i ruoli nella cache
                    '
                    RolesHelper.WriteRolesList(userName, roles)
                    '
                    ' Trace dei diritti utente
                    '
                    RolesHelper.TraceUserRoles(userName)
                End If
                '
                ' Associo i nuovi ruoli allo user corrente
                '
                Context.User = New HybridPrincipal(User.Identity, roles)
            End If
        End Sub

        Sub Application_Error(ByVal sender As Object, ByVal e As EventArgs)

            Dim lastException As Exception = Server.GetLastError()

            If lastException IsNot Nothing Then

                ExceptionsManager.TraceException(lastException)

                Dim portal = New PortalDataAdapterManager(ConnectionStringPortalAdmin)

                portal.TracciaErrori(lastException, User.Identity.Name, PortalsNames.Sac)
            End If

            '
            'Gestito errore generico su application insights.
            '
            If HttpContext.Current.IsCustomErrorEnabled AndAlso Server.GetLastError() IsNot Nothing Then
                Dim ai = New TelemetryClient()
                ' or re-use an existing instance
                ai.TrackException(Server.GetLastError())
            End If
        End Sub

        Sub Session_End(ByVal sender As Object, ByVal e As EventArgs)
            Dim accessDate As DateTime = Nothing
            Dim portal = New PortalDataAdapterManager(ConnectionStringPortalAdmin)
            Dim userName = Me.Session("userName").ToString()

            SyncLock _usersLastRequestDateTime
                accessDate = If(_usersLastRequestDateTime.ContainsKey(userName), _usersLastRequestDateTime(userName), DateTime.Now)
                _usersLastRequestDateTime.Remove(userName)
            End SyncLock

            portal.TracciaAccessi(userName, PortalsNames.Sac, String.Format("L'utente si è disconnesso il {0} alle ore {1}", accessDate.ToString("dd/MM/yyy"), accessDate.ToString("HH:mm:ss")))

        End Sub

        Sub Application_End(ByVal sender As Object, ByVal e As EventArgs)
            ' Fires when the application ends
        End Sub

        ''' <summary>
        ''' Ottiene la lista dei gruppi dell'utente selezionato
        ''' </summary>
        ''' <param name="userName"></param>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public Function GetGroups(userName As String) As List(Of GroupPrincipal)

            Dim domain = New PrincipalContext(ContextType.Domain)

            Dim user = UserPrincipal.FindByIdentity(domain, userName)

            Return GetGroups(user)
        End Function

        ''' <summary>
        ''' Ottiene la lista dei gruppi a cui appartiene il gruppo selezionato
        ''' </summary>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public Function GetGroups(principal As Principal) As List(Of GroupPrincipal)

            Dim result As New List(Of GroupPrincipal)()

            If principal IsNot Nothing Then

                Dim groups = principal.GetGroups()

                For Each group As Principal In groups

                    If Not _defaultGroupsToIgnore.Contains(group.Name) AndAlso TypeOf group Is GroupPrincipal Then

                        result.Add(group)

                        result.AddRange(GetGroups(group))
                    End If
                Next
            End If

            Return result
        End Function

        Private _defaultGroupsToIgnore As String() = New String() {
                "Domain Guests", "Domain Computers", "Group Policy Creator Owners", "Guests", "Users",
                "Domain Users", "Pre-Windows 2000 Compatible Access", "Exchange Domain Servers", "Schema Admins",
                "Enterprise Admins", "Domain Admins", "Cert Publishers", "Backup Operators", "Account Operators",
                "Server Operators", "Print Operators", "Replicator", "Domain Controllers", "WINS Users",
                "DnsAdmins", "DnsUpdateProxy", "DHCP Users", "DHCP Administrators", "Exchange Services",
                "Exchange Enterprise Servers", "Remote Desktop Users", "Network Configuration Operators",
                "Incoming Forest Trust Builders", "Performance Monitor Users", "Performance Log Users",
                "Windows Authorization Access Group", "Terminal Server License Servers", "Distributed COM Users",
                "Administrators", "Everybody", "RAS and IAS Servers", "MTS Trusted Impersonators",
                "MTS Impersonators", "Everyone", "LOCAL", "Authenticated Users"
            }
    End Class
End Namespace