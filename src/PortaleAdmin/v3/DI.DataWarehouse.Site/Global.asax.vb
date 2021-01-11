Imports System
Imports System.Diagnostics
Imports System.Security.Principal
Imports System.Web.SessionState
Imports System.Web

Imports DI.DataWarehouse.Admin
Imports DI.DataWarehouse.Admin.Data
Imports DI.PortalAdmin.Data
Imports System.Configuration
Imports System.Collections.Generic
Imports Microsoft.ApplicationInsights
Imports CustomInitializer.Telemetry
Imports Microsoft.ApplicationInsights.Extensibility

Namespace DI.DataWarehouse.Admin

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

            portal.TracciaAccessi(User.Identity.Name, PortalsNames.DwhClinico, String.Format("Accesso effettuato il {0} alle ore {1}", now.ToString("dd/MM/yyy"), now.ToString("HH:mm:ss")))

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
            '    '
            '    ' Se l'utente fa parte del ruolo configurato nel setting SiteAdmins,
            '    ' gli assegno i diritti amministrativi
            '    '
            '    Dim boolIsInSiteAdmins As Boolean = False
            '    If User.IsInRole(My.Settings.SiteAdmins) Then boolIsInSiteAdmins = True
            '    '
            '    ' Get Roles
            '    '
            '    Dim sName As String = User.Identity.Name
            '    Dim sCacheName As String = String.Concat("Roles_", sName)
            '    Dim oRoles As Object = Context.Cache.Get(sCacheName)
            '    Dim asRoles As String()

            '    If oRoles Is Nothing Then
            '        asRoles = RolesHelper.GetAllRoles(sName, boolIsInSiteAdmins)
            '        Context.Cache.Add(sCacheName, asRoles, Nothing, DateTime.MaxValue, New TimeSpan(0, 3, 0), CacheItemPriority.Normal, Nothing)
            '    Else
            '        asRoles = CType(oRoles, String())
            '    End Ifs

            '    Dim oIdentity As New GenericIdentity(sName)
            '    Context.User = New GenericPrincipal(oIdentity, asRoles)
            'End If
        End Sub

        Sub Application_Error(ByVal sender As Object, ByVal e As EventArgs)
            '
            'Gestione errore generico su application insights.
            '
            If HttpContext.Current.IsCustomErrorEnabled AndAlso Server.GetLastError() IsNot Nothing Then
                Dim ai = New TelemetryClient()
                ' or re-use an existing instance
                ai.TrackException(Server.GetLastError())
            End If

            Dim lastException As Exception = Server.GetLastError()

            If lastException IsNot Nothing Then

                Utility.TrapError(lastException, True)

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

            portal.TracciaAccessi(userName, PortalsNames.DwhClinico, String.Format("L'utente si è disconnesso il {0} alle ore {1}", accessDate.ToString("dd/MM/yyy"), accessDate.ToString("HH:mm:ss")))
        End Sub

        Sub Application_End(ByVal sender As Object, ByVal e As EventArgs)
            ' Fires when the application ends
        End Sub

    End Class

End Namespace