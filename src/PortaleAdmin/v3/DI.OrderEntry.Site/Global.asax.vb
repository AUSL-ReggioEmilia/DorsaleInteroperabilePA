Imports System
Imports System.Security.Principal
Imports System.Web.SessionState
Imports System.Web
Imports DI.OrderEntry.Admin.Data
Imports System.Diagnostics
Imports DI.PortalAdmin.Data
Imports System.Configuration
Imports System.Collections.Generic
Imports Microsoft.ApplicationInsights
Imports CustomInitializer.Telemetry
Imports Microsoft.ApplicationInsights.Extensibility

Namespace DI.OrderEntry.Admin

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

            portal.TracciaAccessi(User.Identity.Name, PortalsNames.OrderEntry, String.Format("Accesso effettuato il {0} alle ore {1}", now.ToString("dd/MM/yyy"), now.ToString("HH:mm:ss")))

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

            'If Request.IsAuthenticated Then

            '    Dim userName As String = User.Identity.Name
            '    Dim cachedRoles As Object = Context.Cache("Roles_" & userName)
            '    Dim roles As String()

            '    If cachedRoles Is Nothing Then

            '        'Se l'utente fa parte del ruolo configurato nel setting SiteAdmins, gli assegno i diritti amministrativi
            '        roles = RolesHelper.GetAllRoles(userName, User.IsInRole(My.Settings.SiteAdmins))
            '        Context.Cache.Add("Roles_" & userName, roles, Nothing, DateTime.MaxValue, New TimeSpan(0, 3, 0), CacheItemPriority.Normal, Nothing)
            '    Else
            '        roles = DirectCast(cachedRoles, String())
            '    End If

            '    Dim identity As New GenericIdentity(userName)
            '    Context.User = New GenericPrincipal(identity, roles)
            'End If
        End Sub

        Sub Application_Error(ByVal sender As Object, ByVal e As EventArgs)
            Try
                Dim lastException As Exception = Server.GetLastError()
                If lastException IsNot Nothing Then
                    ExceptionsManager.TraceException(lastException)
                    Dim portal = New PortalDataAdapterManager(ConnectionStringPortalAdmin)
                    portal.TracciaErrori(lastException, User.Identity.Name, PortalsNames.OrderEntry)
                    '
                    ' Raccolgo gli errori su azure.
                    '
                    If HttpContext.Current.IsCustomErrorEnabled AndAlso lastException IsNot Nothing Then
                        Dim ai = New TelemetryClient()
                        ' or re-use an existing instance
                        ai.TrackException(lastException)
                    End If
                End If
            Catch ex As Exception
                ExceptionsManager.TraceException(ex)
            End Try

        End Sub

        Sub Session_End(ByVal sender As Object, ByVal e As EventArgs)
            Dim accessDate As DateTime = Nothing
            Dim portal = New PortalDataAdapterManager(ConnectionStringPortalAdmin)
            Dim userName = Me.Session("userName").ToString()

            SyncLock _usersLastRequestDateTime
                accessDate = If(_usersLastRequestDateTime.ContainsKey(userName), _usersLastRequestDateTime(userName), DateTime.Now)
                _usersLastRequestDateTime.Remove(userName)
            End SyncLock

            portal.TracciaAccessi(userName, PortalsNames.OrderEntry, String.Format("L'utente si è disconnesso il {0} alle ore {1}", accessDate.ToString("dd/MM/yyy"), accessDate.ToString("HH:mm:ss")))
        End Sub

        Sub Application_End(ByVal sender As Object, ByVal e As EventArgs)

        End Sub

    End Class

End Namespace