Imports System
Imports System.Diagnostics
Imports System.Security.Principal
Imports System.Web.SessionState
Imports System.Web

Imports System.Configuration
Imports System.Collections.Generic
Imports DI.OrderEntry.User.Data
Imports System.Linq
Imports System.Text
Imports System.Web.UI
Imports Microsoft.VisualBasic
Imports Microsoft.ApplicationInsights
Imports System.Web.Routing
Imports Microsoft.ApplicationInsights.Extensibility
Imports CustomInitializer.Telemetry

Namespace DI.OrderEntry.User

    Public Class Global_asax
        Inherits HttpApplication
        '
        ' CONNECTION STRINGS
        '

        Public Shared ConnectionStringPortalUser As String = ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalUserConnectionString").ConnectionString

        Private Shared _usersLastRequestDateTime As New Dictionary(Of String, DateTime)()

        Sub Application_Start(ByVal sender As Object, ByVal e As EventArgs)
            ' Fires when the application is started
            Dim sJqueryVer As String = "1.9.1"
            Dim sModernVer As String = "2.8.3"
            RegisterRoutes(RouteTable.Routes)

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

            ScriptManager.ScriptResourceMapping.AddDefinition("modernizr", New ScriptResourceDefinition() With {
                    .Path = String.Format("~/Scripts/modernizr-{0}.js", sModernVer),
                    .DebugPath = String.Format("~/Scripts/modernizr-{0}.js", sModernVer)})

            ScriptManager.ScriptResourceMapping.AddDefinition("master", New ScriptResourceDefinition() With {
                    .Path = String.Format("~/Scripts/master.js?{0}", Markup.MarkupUtility.GetAssemblyVersion),
                    .DebugPath = String.Format("~/Scripts/master.js?{0}", Markup.MarkupUtility.GetAssemblyVersion)})

            ' necessario per far funzionare la validazione cliendside
            ValidationSettings.UnobtrusiveValidationMode = UnobtrusiveValidationMode.None

            TelemetryConfiguration.Active.TelemetryInitializers.Add(New MyTelemetryInitializer())
        End Sub

        Sub RegisterRoutes(routes As RouteCollection)
            Try
                Dim queryStringDictionary As New RouteValueDictionary()
                queryStringDictionary.Add("AccessoDiretto", True)
                routes.MapPageRoute("AccessoDirettoListaOrdini2", "AccessoDiretto/Pages/{action}", "~/Pages/{action}.aspx", False, queryStringDictionary)
                routes.MapPageRoute("AccessoDirettoreport", "AccessoDiretto/Reports/{action}", "~/Reports/{action}.aspx", False, queryStringDictionary)
            Catch ex As Exception
                'Traccio l'errore.
                ExceptionsManager.TraceException(ex)
            End Try
        End Sub

        Sub Session_Start(ByVal sender As Object, ByVal e As EventArgs)
            Try

                Dim sPortalUserConnectionString = Global_asax.ConnectionStringPortalUser
                Dim portal = New PortalUser2.Data.PortalDataAdapterManager(sPortalUserConnectionString)

                Dim now = DateTime.Now
                Dim userName = User.Identity.Name


                'ad ogni sessione ripulisco la cache
                HttpRuntime.Cache.Remove(My.User.Name & "_lookupData")
                Me.Session.Add("userName", userName)

                If String.IsNullOrEmpty(My.Settings.SAC_ConnectionString) Then
                    Throw New NullReferenceException("Parametro di configurazione assente: SAC_ConnectionString")
                End If
                If String.IsNullOrEmpty(sPortalUserConnectionString) Then
                    Throw New NullReferenceException("Parametro di configurazione assente: AuslAsmnRe_PortalUserConnectionString")
                End If

                '
                ' MODIFICA 24-6-2015
                '
                Dim oSess As New DI.PortalUser2.SessioneUtente(My.Settings.SAC_ConnectionString, sPortalUserConnectionString, My.Settings.WsSac_User, My.Settings.WsSac_Password)
                Dim oUltimoAccesso As DI.PortalUser2.SessioneUtente.UltimoAccesso = oSess.GetUltimoAccesso(User.Identity.Name, DI.PortalUser2.Data.PortalsNames.DwhClinico)
                '
                ' Memorizzo i dati di ultimo accesso. Questa variabile di sessione la uso nelle pagine master
                '
                Me.Session.Add(Utility.SESS_DATI_ULTIMO_ACCESSO, oUltimoAccesso)

                portal.TracciaAccessi(User.Identity.Name, DI.PortalUser2.Data.PortalsNames.OrderEntry, String.Format("Accesso effettuato il {0} alle ore {1}", now.ToString("dd/MM/yyy"), now.ToString("HH:mm:ss")))
            Catch ex As Exception
                '
                'SimoneB - 2017-07-19
                'Se si verificano degli errori nella dll Di.PortalUser2 e non si trappa l'errore si creerebbe un loop.
                'In questo modo se si verificano degli errori navigo ad una pagina html (che non fa ripartire il global.asax) e traccio gli errori.
                '

                'Traccio l'errore.
                ExceptionsManager.TraceException(ex)

                'Navigo alla pagina di errore generico.
                Response.Redirect("~/ErrorUnknown.htm")
            End Try
        End Sub


        Sub Application_AuthenticateRequest(ByVal sender As Object, ByVal e As EventArgs)
            Try
                '
                ' Questo evento viene chiamato per ogni risorsa non solo per le pagine ASPX
                ' ATTENZIONE: tutto il codice deve essere scritto all'interno dell'"If Request.IsAuthenticated Then"
                ' E' stato testato il CONTAINS perchè questo progetto invoca dei Web Methods e l'url invocato può essere del tipo "xxx.aspx/NomeMetodo"
                '
                If Request.IsAuthenticated Then

                    Dim url As String = Request.Url.AbsolutePath.ToLower
                    If url.Contains("/accessodiretto") Then
                        url = url.Replace("/accessodiretto", "")
                        url = $"{url}.aspx" 'Aggiungo l'estensione in fondo
                    End If


                    If url.Contains(".aspx") Then
                        Dim oRoleManagerUtility As New RoleManagerUtility2(Global_asax.ConnectionStringPortalUser, My.Settings.SAC_ConnectionString, My.Settings.WsSac_User, My.Settings.WsSac_Password)
                        oRoleManagerUtility.InitializeUser()
                    End If
                End If
            Catch ex As Exception
                '
                'SimoneB - 2017-07-19
                'Se si verificano degli errori nella dll Di.PortalUser2 e non si trappa l'errore si creerebbe un loop.
                'In questo modo se si verificano degli errori navigo ad una pagina html (che non fa ripartire il global.asax) e traccio gli errori.
                '

                'Traccio l'errore.
                ExceptionsManager.TraceException(ex)

                'Navigo alla pagina di errore generico.
                Response.Redirect("~/ErrorUnknown.htm")
            End Try
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

                'Traccio l'errore.
                ExceptionsManager.TraceException(ex)

                'Navigo alla pagina di errore generico.
                Response.Redirect("~/ErrorUnknown.htm")
            End Try
        End Sub

        Sub Application_Error(ByVal sender As Object, ByVal e As EventArgs)
            Try
                If HttpContext.Current.IsCustomErrorEnabled AndAlso Server.GetLastError() IsNot Nothing Then
                    Dim ai = New TelemetryClient()
                    ' or re-use an existing instance
                    ai.TrackException(Server.GetLastError())
                End If

                Dim lastException As Exception = Server.GetLastError()

                If lastException IsNot Nothing Then

                    ExceptionsManager.TraceException(lastException)
                    Dim portal = New PortalUser2.Data.PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
                    portal.TracciaErrori(lastException, User.Identity.Name, PortalUser2.Data.PortalsNames.OrderEntry)

                    If lastException.Message.Contains("Accesso negato") Then
                        ExceptionsManager.TraceMessage("Nessun permesso definito per l'utente " & User.Identity.Name, TraceEventType.Information)
                        Dim parameters = New Dictionary(Of String, String)()
                        parameters.Add("message", "Nessun permesso definito per l'utente " & User.Identity.Name)
                        If Not Request.Url.PathAndQuery.Contains("AccessDenied") Then
                            RedirectWithPost("~\AccessDenied.aspx", parameters)
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
                ExceptionsManager.TraceException(ex)

                'Navigo alla pagina di errore generico.
                Response.Redirect("~/ErrorUnknown.htm")
            End Try
        End Sub

        Sub Session_End(ByVal sender As Object, ByVal e As EventArgs)
            Try
                Dim accessDate As DateTime = Nothing
                Dim portal = New PortalUser2.Data.PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalUserConnectionString").ConnectionString)
                Dim userName = Me.Session("userName").ToString()

                SyncLock _usersLastRequestDateTime
                    accessDate = If(_usersLastRequestDateTime.ContainsKey(userName), _usersLastRequestDateTime(userName), DateTime.Now)
                    _usersLastRequestDateTime.Remove(userName)
                End SyncLock

                portal.TracciaAccessi(userName, PortalUser2.Data.PortalsNames.OrderEntry, String.Format("L'utente si è disconnesso il {0} alle ore {1}", accessDate.ToString("dd/MM/yyy"), accessDate.ToString("HH:mm:ss")))
            Catch ex As Exception
                '
                'SimoneB - 2017-07-19
                'Se si verificano degli errori nella dll Di.PortalUser2 e non si trappa l'errore si creerebbe un loop.
                'In questo modo se si verificano degli errori navigo ad una pagina html (che non fa ripartire il global.asax) e traccio gli errori.
                '

                'Traccio l'errore.
                ExceptionsManager.TraceException(ex)

                'Navigo alla pagina di errore generico.
                Response.Redirect("~/ErrorUnknown.htm")
            End Try
        End Sub

        Sub Application_End(ByVal sender As Object, ByVal e As EventArgs)
            ' Fires when the application ends
        End Sub

        Public Shared Sub RedirectWithPost(postbackUrl As String, paramaters As IDictionary(Of String, String))
            HttpContext.Current.Response.Clear()

            Dim sb As New StringBuilder()
            sb.Append("<html>")
            sb.AppendFormat("<body onload='document.forms[""form""].submit()'>")
            sb.AppendFormat("<form name='form' action='{0}' method='post'>", DirectCast(HttpContext.Current.Handler, Page).ResolveUrl(postbackUrl))

            For Each paramater In paramaters
                sb.AppendFormat("<input type='hidden' name='{0}' value=""{1}"">", paramater.Key, paramater.Value)
            Next

            sb.Append("</form>")
            sb.Append("</body>")
            sb.Append("</html>")

            HttpContext.Current.Response.Write(sb.ToString())
            HttpContext.Current.Response.End()
        End Sub
    End Class

End Namespace