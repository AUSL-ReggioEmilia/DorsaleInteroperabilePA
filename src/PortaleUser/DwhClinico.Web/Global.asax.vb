Imports System.Web.SessionState
Imports DI.PortalUser2
Imports DI.PortalUser2.Data
Imports DwhClinico.Web.Utility
Imports DwhClinico.Data
Imports Microsoft.ApplicationInsights
Imports DwhClinico.Web.CustomInitializer.Telemetry
Imports Microsoft.ApplicationInsights.Extensibility
Imports DwhClinico.Web.CustomProcessor.Telemetry

Public Class Global_asax
    Inherits System.Web.HttpApplication

    Private Shared _usersLastRequestDateTime As New Generic.Dictionary(Of String, DateTime)()

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

            '
            ' Lettura DizionarioTipireferto
            '
            Try
                Dim oDizionarioTipiReferto As New CustomDataSource.DizionarioTipiRefertoOttieni
                'Ricavo tutti i dati da mettere nell'APPLICATION
                oDizionarioTipiReferto.InitializeData()
            Catch ex As Exception
                Call Logging.WriteError(ex, Me.GetType.Name)
            End Try

            TelemetryConfiguration.Active.TelemetryInitializers.Add(New MyTelemetryInitializer())

            'Modifica Leo 2019-11-28
            'Chiama la classe Component/MyTelemetryProcessor.vb -> filtra alcune pagine per non mandare su application insights
            Dim builder = TelemetryConfiguration.Active.DefaultTelemetrySink.TelemetryProcessorChainBuilder
            builder.Use(Function([next]) New MyTelemetryProcessor([next]))
            builder.Build()

        Catch ex As Exception
            '
            'SimoneB - 2017-07-19
            'Se si verificano degli errori nella dll Di.PortalUser2 e non si trappa l'errore si creerebbe un loop.
            'In questo modo se si verificano degli errori navigo ad una pagina html (che non fa ripartire il global.asax) e traccio gli errori.
            '

            'Traccio l'errore.
            Call Logging.WriteError(ex, Me.GetType.Name)

            'Navigo alla pagina di errore generico.
            Response.Redirect("~/ErrorUnknown.htm")
        End Try
    End Sub

    Sub Session_Start(ByVal sender As Object, ByVal e As EventArgs)
        Dim sUrl As String = Request.Url.ToString.ToUpper
        Try
            ' Code that runs when a new session is started
            Dim sDiPortalUserConnectionString As String = Utility.GetAppSettings(Utility.PAR_DI_PORTAL_USER_CONNECTION_STRING, "")

            If String.IsNullOrEmpty(My.Settings.SAC_ConnectionString) Then
                Throw New NullReferenceException("Parametro di configurazione assente: SAC_ConnectionString")
            End If
            If String.IsNullOrEmpty(sDiPortalUserConnectionString) Then
                Throw New NullReferenceException("Parametro di configurazione assente: AuslAsmnRe_PortalUserConnectionString")
            End If
            Dim portal = New PortalDataAdapterManager(sDiPortalUserConnectionString)
            Dim now = DateTime.Now
            portal.TracciaAccessi(User.Identity.Name, PortalsNames.DwhClinico, String.Format("Accesso effettuato il {0} alle ore {1}", now.ToString("dd/MM/yyy"), now.ToString("HH:mm:ss")))
            '
            ' MODIFICA ETTORE 2015-06-17
            '
            Dim oSess As New SessioneUtente(My.Settings.SAC_ConnectionString, sDiPortalUserConnectionString, My.Settings.WsSac_User, My.Settings.WsSac_Password)
            Dim oUltimoAccesso As SessioneUtente.UltimoAccesso = oSess.GetUltimoAccesso(User.Identity.Name, PortalsNames.DwhClinico)
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

            Call Logging.WriteError(ex, Me.GetType.Name)

            'Navigo alla pagina di errore generico.
            Response.Redirect("~/ErrorUnknown.htm")
        End Try
    End Sub

    Sub Application_BeginRequest(ByVal sender As Object, ByVal e As EventArgs)

    End Sub

    Sub Application_PostAuthenticateRequest(ByVal sender As Object, ByVal e As EventArgs) Handles MyBase.PostAuthenticateRequest
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
            Call Logging.WriteError(ex, Me.GetType.Name)

            'Navigo alla pagina di errore generico.
            Response.Redirect("~/ErrorUnknown.htm")
        End Try
    End Sub

    Sub Application_AuthenticateRequest(ByVal sender As Object, ByVal e As EventArgs)
        Dim sUrl As String = Request.Url.ToString.ToUpper
        Try
            '
            ' Questo evento viene chiamato per ogni risorsa non solo per le pagine ASPX
            ' ATTENZIONE: tutto il codice deve essere scritto all'interno dell'"If Request.IsAuthenticated Then"
            '
            If Request.IsAuthenticated Then

                '
                ' Leggo utente corrente e utente configurato per rendering PDF
                '
                Dim sWsRenderingPdfUser As String = My.Settings.WsRenderingPdf_User.ToUpper()
                Dim sCurrentUser As String = HttpContext.Current.User.Identity.Name.ToUpper()
#If DEBUG Then
                If sCurrentUser = sWsRenderingPdfUser Then
                    Dim sMsg As String = String.Format("Accesso con utente RenderingPdfUser alla pagina {0}", HttpContext.Current.Request.Url.AbsoluteUri)
                    Utility.TraceWriteLine(sMsg)
                End If
#End If
                '
                ' Non devo applicare il calcolo dei ruoli per l'utente utilizzato per il rendering PDF
                '
                If sUrl.Contains(".ASPX") AndAlso sCurrentUser <> sWsRenderingPdfUser Then
                    Dim oRoleManagerUtility As New RoleManagerUtility2(Utility.GetAppSettings(Utility.PAR_DI_PORTAL_USER_CONNECTION_STRING, ""), My.Settings.SAC_ConnectionString, My.Settings.WsSac_User, My.Settings.WsSac_Password)
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
            Call Logging.WriteError(ex, Me.GetType.Name)

            'Navigo alla pagina di errore generico.
            Response.Redirect("~/ErrorUnknown.htm")
        End Try
    End Sub

    Sub Application_Error(ByVal sender As Object, ByVal e As EventArgs)
        Try
            '
            'Raccolgo gli errori su azure.
            '
            If HttpContext.Current.IsCustomErrorEnabled AndAlso Server.GetLastError() IsNot Nothing Then
                Dim ai = New TelemetryClient()
                ' or re-use an existing instance
                ai.TrackException(Server.GetLastError())
            End If

            Dim sDiPortalUserConnectionString As String = Web.Utility.GetAppSettings(Web.Utility.PAR_DI_PORTAL_USER_CONNECTION_STRING, "")
            If Not String.IsNullOrEmpty(sDiPortalUserConnectionString) Then
                Dim lastException As Exception = Server.GetLastError()
                If lastException IsNot Nothing Then
                    'TODO PRENDERE ANCHE LA INNER EXCEPTION
                    MyLogging.WriteError(lastException, "")
                    Dim portal = New PortalDataAdapterManager(sDiPortalUserConnectionString)
                    portal.TracciaErrori(lastException, User.Identity.Name, PortalsNames.DwhClinico)
                End If
            Else
                '
                ' Errori non gestiti; prendo l'ultimo errore
                ' 
                Dim objError As Exception = Server.GetLastError().GetBaseException()
                Call MyLogging.WriteError(objError, "Errore non gestito!")
            End If
        Catch ex As Exception
            '
            'SimoneB - 2017-07-19
            'Se si verificano degli errori nella dll Di.PortalUser2 e non si trappa l'errore si creerebbe un loop.
            'In questo modo se si verificano degli errori navigo ad una pagina html (che non fa ripartire il global.asax) e traccio gli errori.
            '

            'Traccio l'errore.
            Call Logging.WriteError(ex, Me.GetType.Name)

            'Navigo alla pagina di errore generico.
            Response.Redirect("~/ErrorUnknown.htm")
        End Try
    End Sub

    Sub Session_End(ByVal sender As Object, ByVal e As EventArgs)
        Try
            ' Code that runs when a session ends. 
            ' Note: The Session_End event is raised only when the sessionstate mode
            ' is set to InProc in the Web.config file. If session mode is set to StateServer 
            ' or SQLServer, the event is not raised.
            '
            ' ATTENZIONE: qui bisogna usare Me.Session e non HttpContext.Current che è NOTHING!!!
            '
            Dim accessDate As DateTime = Nothing
            Dim userName = Me.Session("userName").ToString()
            Dim sDiPortalUserConnectionString As String = Utility.GetAppSettings(Web.Utility.PAR_DI_PORTAL_USER_CONNECTION_STRING, "")

            If Not String.IsNullOrEmpty(sDiPortalUserConnectionString) Then
                Dim portal = New PortalDataAdapterManager(sDiPortalUserConnectionString)
                SyncLock _usersLastRequestDateTime
                    accessDate = If(_usersLastRequestDateTime.ContainsKey(userName), _usersLastRequestDateTime(userName), DateTime.Now)
                    _usersLastRequestDateTime.Remove(userName)
                End SyncLock
                portal.TracciaAccessi(userName, PortalsNames.DwhClinico, String.Format("L'utente si è disconnesso il {0} alle ore {1}", accessDate.ToString("dd/MM/yyy"), accessDate.ToString("HH:mm:ss")))
            Else
                SyncLock _usersLastRequestDateTime
                    _usersLastRequestDateTime.Remove(userName)
                End SyncLock
            End If
        Catch ex As Exception
            '
            'SimoneB - 2017-07-19
            'Se si verificano degli errori nella dll Di.PortalUser2 e non si trappa l'errore si creerebbe un loop.
            'In questo modo se si verificano degli errori navigo ad una pagina html (che non fa ripartire il global.asax) e traccio gli errori.
            '

            'Traccio l'errore.
            Call Logging.WriteError(ex, Me.GetType.Name)

            'Navigo alla pagina di errore generico.
            Response.Redirect("~/ErrorUnknown.htm")
        End Try
    End Sub

    Sub Application_End(ByVal sender As Object, ByVal e As EventArgs)
        ' Fires when the application ends
    End Sub
End Class