Imports System.Security.Principal
Imports System.Web.SessionState
Imports System.Web

Imports System.DirectoryServices.AccountManagement
Imports DI.Security
Imports DI.PortalUser2
Imports DI.PortalUser2.Data
Imports Microsoft.ApplicationInsights
Imports Microsoft.ApplicationInsights.Extensibility
Imports CustomInitializer.Telemetry

Namespace DI.Sac.User

    Public Class Global_asax
        Inherits HttpApplication

        Private Shared _usersLastRequestDateTime As New Dictionary(Of String, DateTime)()

        Sub Application_Start(ByVal sender As Object, ByVal e As EventArgs)
            ' Fires when the application is started
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

            ScriptManager.ScriptResourceMapping.AddDefinition("moment", New ScriptResourceDefinition() With {
                .Path = "~/Scripts/moment.min.js",
                .DebugPath = "~/Scripts/moment.js"})

            ScriptManager.ScriptResourceMapping.AddDefinition("momentLocales", New ScriptResourceDefinition() With {
              .Path = "~/Scripts/moment-with-locales.min.js",
              .DebugPath = "~/Scripts/moment-with-locales.js"})

            ScriptManager.ScriptResourceMapping.AddDefinition("datetimepicker", New ScriptResourceDefinition() With {
              .Path = "~/Scripts/bootstrap-datetimepicker.min.js",
              .DebugPath = "~/Scripts/bootstrap-datetimepicker.js"})

            ' necessario per far funzionare la validazione cliendside
            ValidationSettings.UnobtrusiveValidationMode = UnobtrusiveValidationMode.None

            'Custom telemetry initializer
            TelemetryConfiguration.Active.TelemetryInitializers.Add(New MyTelemetryInitializer())
        End Sub

        Sub Session_Start(ByVal sender As Object, ByVal e As EventArgs)
            Try
                Dim sDiPortalUserConnectionString As String = ConfigurationManager.ConnectionStrings(Utility.PORTAL_USER_CONNECTION_STRING).ConnectionString
                Dim sSACConnectionString As String = ConfigurationManager.ConnectionStrings(Utility.SAC_CONNECTION_STRING).ConnectionString
                If String.IsNullOrEmpty(sSACConnectionString) Then
                    Throw New NullReferenceException("Parametro di configurazione assente: SAC_ConnectionString")
                End If
                If String.IsNullOrEmpty(sDiPortalUserConnectionString) Then
                    Throw New NullReferenceException("Parametro di configurazione assente: AuslAsmnRe_PortalUserConnectionString")
                End If

                Dim portal = New PortalDataAdapterManager(sDiPortalUserConnectionString)
                Dim now = DateTime.Now
                portal.TracciaAccessi(User.Identity.Name, PortalsNames.Sac, String.Format("Accesso effettuato il {0} alle ore {1}", now.ToString("dd/MM/yyy"), now.ToString("HH:mm:ss")))
                '
                ' Leggo ultimo accesso
                '
                Dim oSess As New SessioneUtente(sSACConnectionString, sDiPortalUserConnectionString, My.Settings.WsSac_User, My.Settings.WsSac_Password)
                Dim oUltimoAccesso As SessioneUtente.UltimoAccesso = oSess.GetUltimoAccesso(User.Identity.Name, DI.PortalUser2.Data.PortalsNames.Sac)
                '
                ' Memorizzo i dati di ultimo accesso. Questa variabile di sessione la uso nelle pagine master
                '
                Me.Session.Add(Utility.SESS_DATI_ULTIMO_ACCESSO, oUltimoAccesso)
                Me.Session.Add("userName", User.Identity.Name)
            Catch ex As Exception
                '
                'SimoneB - 2017-07-19
                'Se si verificano degli errori nella dll Di.PortalUser2 e non si trappa l'errore si creerebbe un loop.
                'In questo modo se si verificano degli errori navigo ad una pagina html (che non fa ripartire il global.asax) e traccio gli errori.
                '

                'Traccio l'errore.
                'Scrivo solo nell'event log
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)


                'Navigo alla pagina di errore generico.
                Response.Redirect("~/ErrorUnknown.htm")
            End Try
        End Sub

        Sub Application_BeginRequest(ByVal sender As Object, ByVal e As EventArgs)

        End Sub

        Sub Application_PostAuthenticateRequest(sender As Object, e As EventArgs) Handles MyBase.PostAuthenticateRequest
            Try
                SyncLock _usersLastRequestDateTime
                    If Not _usersLastRequestDateTime.ContainsKey(User.Identity.Name) Then

                        _usersLastRequestDateTime.Add(User.Identity.Name, DateTime.Now)
                    Else
                        _usersLastRequestDateTime(User.Identity.Name) = DateTime.Now
                    End If
                End SyncLock
            Catch ex As Exception
                '
                'SimoneB - 2017-07-19
                'Se si verificano degli errori nella dll Di.PortalUser2 e non si trappa l'errore si creerebbe un loop.
                'In questo modo se si verificano degli errori navigo ad una pagina html (che non fa ripartire il global.asax) e traccio gli errori.
                '


                'Scrivo solo nell'event log
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)

                'Navigo alla pagina di errore generico.
                Response.Redirect("~/ErrorUnknown.htm")
            End Try
        End Sub

        Sub Application_AuthenticateRequest(ByVal sender As Object, ByVal e As EventArgs)
            Try


                '
                ' Questo evento viene chiamato per ogni risorsa non solo per le pagine ASPX
                ' ATTENZIONE: tutto il codice deve essere scritto all'interno dell'"If Request.IsAuthenticated Then"
                '
                If Request.IsAuthenticated Then
                    Dim sUrl As String = Request.Url.ToString.ToUpper
                    '
                    ' Non devo applicare il calcolo dei ruoli per l'utente utilizzato per il rendering PDF
                    '
                    If sUrl.Contains(".ASPX") Then
                        Dim oRoleManagerUtility As New RoleManagerUtility2(ConfigurationManager.ConnectionStrings(Utility.PORTAL_USER_CONNECTION_STRING).ConnectionString, ConfigurationManager.ConnectionStrings(Utility.SAC_CONNECTION_STRING).ConnectionString, My.Settings.WsSac_User, My.Settings.WsSac_Password)

                        Dim ruoloPrecedente As RoleManager.Ruolo = oRoleManagerUtility.RuoloCorrente

                        oRoleManagerUtility.InitializeUser()

                        Dim ruoloAttuale As RoleManager.Ruolo = oRoleManagerUtility.RuoloCorrente

                        If ruoloPrecedente.Codice <> ruoloAttuale.Codice Then
                            Dim sUrlRedirect As String = HttpContext.Current.Request.Url.AbsoluteUri
                            If (Not sUrl.Contains("Default.aspx")) Then
                                HttpContext.Current.Response.Redirect("~/Default.aspx", False)
                            End If
                        End If
                    End If
                End If

            Catch ex As Exception
                '
                'SimoneB - 2017-07-19
                'Se si verificano degli errori nella dll Di.PortalUser2 e non si trappa l'errore si creerebbe un loop.
                'In questo modo se si verificano degli errori navigo ad una pagina html (che non fa ripartire il global.asax) e traccio gli errori.
                '

                'Traccio l'errore.
                'Scrivo solo nell'event log
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)

                'Navigo alla pagina di errore generico.
                Response.Redirect("~/ErrorUnknown.htm")
            End Try
        End Sub

        Sub Application_Error(ByVal sender As Object, ByVal e As EventArgs)
            Dim sDiPortalUserConnectionString As String = ConfigurationManager.ConnectionStrings(Utility.PORTAL_USER_CONNECTION_STRING).ConnectionString
            If Not String.IsNullOrEmpty(sDiPortalUserConnectionString) Then
                Dim lastException As Exception = Server.GetLastError()

                If lastException IsNot Nothing Then

                    GestioneErrori.WriteException(lastException)

                    Dim portal = New PortalDataAdapterManager(sDiPortalUserConnectionString)

                    portal.TracciaErrori(lastException, User.Identity.Name, PortalsNames.Sac)
                End If
            Else
                '
                ' Errori non gestiti; prendo l'ultimo errore
                ' 
                Dim objError As Exception = Server.GetLastError().GetBaseException()
                Call My.Log.WriteException(objError, TraceEventType.Error, "Errore non gestito!")
            End If

            If HttpContext.Current.IsCustomErrorEnabled AndAlso Server.GetLastError() IsNot Nothing Then
                Dim ai = New TelemetryClient()
                ' or re-use an existing instance
                ai.TrackException(Server.GetLastError())
            End If
        End Sub

        Sub Session_End(ByVal sender As Object, ByVal e As EventArgs)
            Try
                Dim accessDate As DateTime = Nothing
                Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings(Utility.PORTAL_USER_CONNECTION_STRING).ConnectionString)
                Dim userName = Me.Session("userName").ToString()

                SyncLock _usersLastRequestDateTime
                    accessDate = If(_usersLastRequestDateTime.ContainsKey(userName), _usersLastRequestDateTime(userName), DateTime.Now)
                    _usersLastRequestDateTime.Remove(userName)
                End SyncLock

                portal.TracciaAccessi(userName, PortalsNames.Sac, String.Format("L'utente si è disconnesso il {0} alle ore {1}", accessDate.ToString("dd/MM/yyy"), accessDate.ToString("HH:mm:ss")))
            Catch ex As Exception
                '
                'SimoneB - 2017-07-19
                'Se si verificano degli errori nella dll Di.PortalUser2 e non si trappa l'errore si creerebbe un loop.
                'In questo modo se si verificano degli errori navigo ad una pagina html (che non fa ripartire il global.asax) e traccio gli errori.
                '

                'Traccio l'errore.
                'Scrivo solo nell'event log
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)

                'Navigo alla pagina di errore generico.
                Response.Redirect("~/ErrorUnknown.htm")
            End Try
        End Sub

        Sub Application_End(ByVal sender As Object, ByVal e As EventArgs)
            ' Fires when the application ends
        End Sub

    End Class

End Namespace