Imports Microsoft.ApplicationInsights
Imports Microsoft.ApplicationInsights.Extensibility
Imports PrintDispatcherAdmin.CustomInitializer.Telemetry

Public Class Global_asax
    Inherits System.Web.HttpApplication

    Private Shared _usersLastRequestDateTime As New Dictionary(Of String, DateTime)()

    Sub Application_Start(ByVal sender As Object, ByVal e As EventArgs)
        TelemetryConfiguration.Active.TelemetryInitializers.Add(New MyTelemetryInitializer())
    End Sub

    Sub Session_Start(ByVal sender As Object, ByVal e As EventArgs)

        Dim portal = New DI.PortalAdmin.Data.PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)

        Dim now = DateTime.Now

        portal.TracciaAccessi(User.Identity.Name, DI.PortalAdmin.Data.PortalsNames.PrintDispatcher, String.Format("Accesso effettuato il {0} alle ore {1}", now.ToString("dd/MM/yyy"), now.ToString("HH:mm:ss")))

        Me.Session.Add("userName", User.Identity.Name)
    End Sub

    Sub Application_BeginRequest(ByVal sender As Object, ByVal e As EventArgs)

    End Sub

    Sub Application_PostAuthenticateRequest(ByVal sender As Object, ByVal e As EventArgs) Handles MyBase.PostAuthenticateRequest
        SyncLock _usersLastRequestDateTime
            If Not _usersLastRequestDateTime.ContainsKey(User.Identity.Name) Then

                _usersLastRequestDateTime.Add(User.Identity.Name, DateTime.Now)
            Else
                _usersLastRequestDateTime(User.Identity.Name) = DateTime.Now
            End If
        End SyncLock
    End Sub

    Sub Application_AuthenticateRequest(ByVal sender As Object, ByVal e As EventArgs)

    End Sub

    Sub Application_Error(ByVal sender As Object, ByVal e As EventArgs)

        Dim lastException As Exception = Server.GetLastError()

        If lastException IsNot Nothing Then

            My.Log.WriteException(lastException)

            Dim portal = New DI.PortalAdmin.Data.PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)
            portal.TracciaErrori(lastException, User.Identity.Name, DI.PortalAdmin.Data.PortalsNames.PrintDispatcher)

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
        Dim portal = New DI.PortalAdmin.Data.PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)
        Dim userName = Me.Session("userName").ToString()

        SyncLock _usersLastRequestDateTime
            accessDate = If(_usersLastRequestDateTime.ContainsKey(userName), _usersLastRequestDateTime(userName), DateTime.Now)
            _usersLastRequestDateTime.Remove(userName)
        End SyncLock

        portal.TracciaAccessi(userName, DI.PortalAdmin.Data.PortalsNames.PrintDispatcher, String.Format("L'utente si è disconnesso il {0} alle ore {1}", accessDate.ToString("dd/MM/yyy"), accessDate.ToString("HH:mm:ss")))
    End Sub

    Sub Application_End(ByVal sender As Object, ByVal e As EventArgs)
        ' Fires when the application ends
    End Sub

End Class