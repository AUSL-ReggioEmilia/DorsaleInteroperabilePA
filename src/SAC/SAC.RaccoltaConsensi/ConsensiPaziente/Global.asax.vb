Imports System.Web.SessionState
Imports Microsoft.ApplicationInsights
Imports DI.PortalUser2
Imports DI.PortalUser2.Data
Imports Microsoft.ApplicationInsights.Extensibility

Public Class Global_asax
    Inherits System.Web.HttpApplication

    Private usersLastRequestDateTime As System.Collections.Generic.Dictionary(Of String, DateTime) = New System.Collections.Generic.Dictionary(Of String, DateTime)

    Sub Application_Start(ByVal sender As Object, ByVal e As EventArgs)
        Try
            ' Code that runs on application startup
            Dim sJqueryVer As String = "1.11.2"

            ScriptManager.ScriptResourceMapping.AddDefinition("jquery", New ScriptResourceDefinition() With {
                .Path = String.Format("~/Scripts/jquery-{0}.min.js", sJqueryVer),
                .DebugPath = String.Format("~/Scripts/jquery-{0}.js", sJqueryVer),
                .CdnSupportsSecureConnection = False,
                .LoadSuccessExpression = "window.jQuery"})

            ScriptManager.ScriptResourceMapping.AddDefinition("bootstrap", New ScriptResourceDefinition() With {
                .Path = "~/Scripts/bootstrap.min.js",
                .DebugPath = "~/Scripts/bootstrap.js"})

            ScriptManager.ScriptResourceMapping.AddDefinition("respond", New ScriptResourceDefinition() With {
                .Path = "~/Scripts/respond.min.js",
                .DebugPath = "~/Scripts/respond.js"})

            Dim sModernVer As String = "2.8.3"

            ScriptManager.ScriptResourceMapping.AddDefinition("modernizr", New ScriptResourceDefinition() With {
                    .Path = String.Format("~/Scripts/modernizr-{0}.js", sModernVer),
                    .DebugPath = String.Format("~/Scripts/modernizr-{0}.js", sModernVer)})

            TelemetryConfiguration.Active.TelemetryInitializers.Add(New MyTelemetryInitializer())

        Catch ex As Exception
            Utility.NavigateToErrorPage(ErrorPage.ErrorCode.Exception, GestioneErrori.TrapError(ex), False)
        End Try

    End Sub

    Sub Session_Start(ByVal sender As Object, ByVal e As EventArgs)
        Try
            'Traccio l'accesso al portale.
            Dim msgTracciamentoAccessi As String = $"Accesso effettuato il {DateTime.Now.ToString("dd/MM/yyyy")} alle ore {DateTime.Now.ToString("HH:mm:ss")}"
            PortalUserSingleton.instance.PortalDataAdapterManager.TracciaAccessi(User.Identity.Name, PortalsNames.PortaleConsensi, msgTracciamentoAccessi)

            'Memorizzo in sessione le informazioni sull'ultimo accesso. Verranno utilizzati nella master page.
            HttpContext.Current.Session.Add(Utility.sess_dati_ultimo_accesso, PortalUserSingleton.instance.SessioneUtente.GetUltimoAccesso(User.Identity.Name, PortalsNames.PortaleConsensi))

            'Memorizzo il nome utente, utilizzato nella funzione SessionEnd per sapere chi è l'utente che si è disconnesso.
            HttpContext.Current.Session.Add(Utility.sess_user_name, User.Identity.Name)

        Catch ex As Exception
            Call GestioneErrori.TrapError(ex)
            Utility.NavigateToErrorPage(ErrorPage.ErrorCode.Exception, ex.Message, False)
        End Try
    End Sub

    Sub Application_BeginRequest(ByVal sender As Object, ByVal e As EventArgs)
        ' Fires at the beginning of each request
    End Sub


    Sub Application_PostAuthenticateRequest(ByVal sender As Object, ByVal e As EventArgs)
        Try
            SyncLock usersLastRequestDateTime
                If Not (usersLastRequestDateTime.ContainsKey(User.Identity.Name)) Then
                    usersLastRequestDateTime.Add(User.Identity.Name, DateTime.Now)
                Else
                    usersLastRequestDateTime(User.Identity.Name) = DateTime.Now
                End If
            End SyncLock
        Catch ex As Exception
            Utility.NavigateToErrorPage(ErrorPage.ErrorCode.Exception, GestioneErrori.TrapError(ex), False)
        End Try
    End Sub

    Sub Application_AuthenticateRequest(ByVal sender As Object, ByVal e As EventArgs)
        Dim sUrl As String = Request.Url.ToString.ToUpper
        Try
            If (Request.IsAuthenticated) Then
                If sUrl.Contains(".ASPX") Then
                    'Inizializzo l'utente.
                    PortalUserSingleton.instance.RoleManagerUtility.InitializeUser()
                End If
            End If
        Catch ex As Exception
            Utility.NavigateToErrorPage(ErrorPage.ErrorCode.Exception, GestioneErrori.TrapError(ex), False)
        End Try
    End Sub

    Sub Application_Error(ByVal sender As Object, ByVal e As EventArgs)
        Try
            '
            'Raccolgo gli errori su azure.
            '
            Dim lastException As Exception = Server.GetLastError()
            If HttpContext.Current.IsCustomErrorEnabled AndAlso lastException IsNot Nothing Then
                Dim ai = New TelemetryClient()
                ' or re-use an existing instance
                ai.TrackException(lastException)
            End If
            'Clear the error from the server
            Server.ClearError()
        Catch ex As Exception
            Call GestioneErrori.TrapError(ex)
        End Try
    End Sub

    Sub Session_End(ByVal sender As Object, ByVal e As EventArgs)
        Try
            'Ottengo lo user name dell'utente che si è disconnesso.
            Dim sUserName As String = HttpContext.Current.Session(Utility.sess_user_name)?.ToString()

            'Ottengo la connection string del database DiPortalUser.
            Dim portalUserConnectionString As String = My.Settings.PortalUserConnectionString

            If (Not (String.IsNullOrEmpty(portalUserConnectionString))) Then
                SyncLock usersLastRequestDateTime
                    Dim accessDate As DateTime = DateTime.Now
                    If (usersLastRequestDateTime.ContainsKey(sUserName)) Then
                        accessDate = usersLastRequestDateTime(sUserName)
                    End If
                End SyncLock
                'Traccio l'accesso al portale.
                Dim msgTracciamentoAccessi As String = $"L'utente si è disconnesso il {DateTime.Now.ToString("dd/MM/yyyy")} alle ore {DateTime.Now.ToString("HH:mm:ss")}"
                PortalUserSingleton.instance.PortalDataAdapterManager.TracciaAccessi(sUserName, PortalsNames.PortaleConsensi, msgTracciamentoAccessi)
            Else
                SyncLock usersLastRequestDateTime
                    usersLastRequestDateTime.Remove(sUserName)
                End SyncLock
            End If
        Catch ex As Exception
            Utility.NavigateToErrorPage(ErrorPage.ErrorCode.Exception, GestioneErrori.TrapError(ex), False)
        End Try
    End Sub

    Sub Application_End(ByVal sender As Object, ByVal e As EventArgs)
        ' Fires when the application ends
    End Sub

End Class