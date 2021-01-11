Imports System.Web.Routing
Imports System.Web.DynamicData
Imports System.Web.Optimization
Imports DI.PortalAdmin.Data
Imports Microsoft.ApplicationInsights
Imports CustomInitializer.Telemetry
Imports Microsoft.ApplicationInsights.Extensibility

Public Class Global_asax
    Inherits HttpApplication

    Private Shared _usersLastRequestDateTime As New Dictionary(Of String, DateTime)()

    Public Const RouteValueActions As String = "List|Details|Edit|Insert|Import"

    Private Shared s_defaultModel As New MetaModel

    Public Shared ReadOnly Property DefaultModel() As MetaModel
        Get
            Return s_defaultModel
        End Get
    End Property

    Public Shared Sub RegisterRoutes(ByVal routes As RouteCollection)


        '                     IMPORTANT: DATA MODEL REGISTRATION 
        ' Uncomment this line to register a LINQ to SQL model for ASP.NET Dynamic Data.
        ' Set ScaffoldAllTables = true only if you are sure that you want all tables in the
        ' data model to support a scaffold (i.e. templates) view. To control scaffolding for
        ' individual tables, create a partial class for the table and apply the
        ' <ScaffoldTable(true)> attribute to the partial class.
        ' Note: Make sure that you change "YourDataContextType" to the name of the data context
        ' class in your application.

        'DwhConnAnthema
        If (Not ConfigurationManager.ConnectionStrings("AuslAsmnRe_DwhConnAnthemaConnectionString") Is Nothing) Then
            DefaultModel.RegisterContext(GetType(DwhConnAnthemaDataContext), New ContextConfiguration() With {.ScaffoldAllTables = False})
        End If

        'DwhConnSole3 --> Serve anche il DB DhwClinicoV3 per la configurazione dei connettori SOLE
        If (Not ConfigurationManager.ConnectionStrings("AuslAsmnRe_DwhConnSole3ConnectionString") Is Nothing) Then
            DefaultModel.RegisterContext(GetType(DwhConnSole3DataContext), New ContextConfiguration() With {.ScaffoldAllTables = False})
        End If
        If (Not ConfigurationManager.ConnectionStrings("AuslAsmnRe_DwhClinicoV3ConnectionString") Is Nothing) Then
            DefaultModel.RegisterContext(GetType(DwhClinicoV3DataContext), New ContextConfiguration() With {.ScaffoldAllTables = False})
        End If

        'DwhConnFileRefertoInput
        If (Not ConfigurationManager.ConnectionStrings("AuslAsmnRe_DwhConnFileRefertoInputConnectionString") Is Nothing) Then
            DefaultModel.RegisterContext(GetType(DwhConnFileRefertoInputDataContext), New ContextConfiguration() With {.ScaffoldAllTables = False})
        End If

        'DwhOut_DSA
        If (Not ConfigurationManager.ConnectionStrings("Ausl_DwhOut_DSAConnectionString") Is Nothing) Then
            DefaultModel.RegisterContext(GetType(DwhOutDsaDataContext), New ContextConfiguration() With {.ScaffoldAllTables = False})
        End If

        'DwhOut_MedicinaNucleare
        If (Not ConfigurationManager.ConnectionStrings("Asmn_DwhOut_MedicinaNucleareConnectionString") Is Nothing) Then
            DefaultModel.RegisterContext(GetType(DwhOutMedicinaNucleareDataContext), New ContextConfiguration() With {.ScaffoldAllTables = False})
        End If

        'DwhOut_Screening
        If (Not ConfigurationManager.ConnectionStrings("Asmn_DwhOut_ScreeningConnectionString") Is Nothing) Then
            DefaultModel.RegisterContext(GetType(DwhOutScreeningDataContext), New ContextConfiguration() With {.ScaffoldAllTables = False})
        End If

        'OeBtConfig
        If (Not ConfigurationManager.ConnectionStrings("AuslAsmnRe_OeBtConfigConnectionString") Is Nothing) Then
            DefaultModel.RegisterContext(GetType(OeBtConfigDataContext), New ContextConfiguration() With {.ScaffoldAllTables = False})
        End If

        'OeConnAnthema
        If (Not ConfigurationManager.ConnectionStrings("AuslAsmnRe_OeConnAnthemaConnectionString") Is Nothing) Then
            DefaultModel.RegisterContext(GetType(OeConnAnthemaDataContext), New ContextConfiguration() With {.ScaffoldAllTables = False})
        End If

        'OeConnCup
        If (Not ConfigurationManager.ConnectionStrings("ASMN_OeConnCupConnectionString") Is Nothing) Then
            DefaultModel.RegisterContext(GetType(OeConnCupDataContext), New ContextConfiguration() With {.ScaffoldAllTables = False})
        End If

        'OeConnARTEXE
        If (Not ConfigurationManager.ConnectionStrings("AuslAsmnRe_OeConnARTEXEConnectionString") Is Nothing) Then
            DefaultModel.RegisterContext(GetType(OeConnARTEXEDataContext), New ContextConfiguration() With {.ScaffoldAllTables = False})
        End If

        'OeConnAuslGst
        If (Not ConfigurationManager.ConnectionStrings("AuslAsmnRe_OeConnGSTConnectionString") Is Nothing) Then
            DefaultModel.RegisterContext(GetType(OeConnAuslGST.OeConnAuslGstDataContext), New ContextConfiguration() With {.ScaffoldAllTables = False})
        End If

        'OeConnAsmnGst
        If (Not ConfigurationManager.ConnectionStrings("AuslAsmnRe_OeConnGST_ASMNConnectionString") Is Nothing) Then
            DefaultModel.RegisterContext(GetType(OeConnAsmnGST.OeConnAsmnGSTDataContext), New ContextConfiguration() With {.ScaffoldAllTables = False})
        End If

        'OeConnVna
        If (Not ConfigurationManager.ConnectionStrings("AuslAsmnRe_OeConnVNAConnectionString") Is Nothing) Then
            DefaultModel.RegisterContext(GetType(OeConnVnaDataContext), New ContextConfiguration() With {.ScaffoldAllTables = False})
        End If

        'DwhConnStage
        If (Not ConfigurationManager.ConnectionStrings("AuslAsmnRe_DwhConnStageConnectionString") Is Nothing) Then
            DefaultModel.RegisterContext(GetType(DwhConnStageDataContext), New ContextConfiguration() With {.ScaffoldAllTables = False})
        End If

        'OeGestioneOrdiniErogante
        If (Not ConfigurationManager.ConnectionStrings("AuslAsmnRe_OeGestioneOrdiniEroganteConnectionString") Is Nothing) Then
            DefaultModel.RegisterContext(GetType(OeGestioneOrdiniErogante.OeGestioneOrdiniEroganteDataContext), New ContextConfiguration() With {.ScaffoldAllTables = False})
        End If

        'DwhClinicoMMG
        If (Not ConfigurationManager.ConnectionStrings("AuslAsmnRe_DwhClinicoMMGConnectionString") Is Nothing) Then
            DefaultModel.RegisterContext(GetType(DwhClinicoMMGDataContext), New ContextConfiguration() With {.ScaffoldAllTables = False})
        End If

        'OePlannerDataContext
        If (Not ConfigurationManager.ConnectionStrings("AuslAsmnRe_OePlannerConnectionString") Is Nothing) Then
            DefaultModel.RegisterContext(GetType(OePlanner.OePlannerDataContext), New ContextConfiguration() With {.ScaffoldAllTables = False})
        End If


        'Dim oConnectionStringSettings As ConnectionStringSettings = Nothing
        'oConnectionStringSettings = ConfigurationManager.ConnectionStrings("AuslAsmnRe_OePlannerConnectionString")
        'If (Not oConnectionStringSettings Is Nothing) AndAlso (Not String.IsNullOrEmpty(oConnectionStringSettings.ConnectionString)) Then
        '    DefaultModel.RegisterContext(GetType(OePlanner.OePlannerDataContext), New ContextConfiguration() With {.ScaffoldAllTables = False})
        'End If

        ''CupConnLHADataContext'
        'DefaultModel.RegisterContext(GetType(CupConnLHADataContext), New ContextConfiguration() With {.ScaffoldAllTables = False})

        ' The following statement supports separate-page mode, where the List, Detail, Insert, and 
        ' Update tasks are performed by using separate pages. To enable this mode, uncomment the following 
        ' route definition, and comment out the route definitions in the combined-page mode section that follows.
        routes.Add(New DynamicDataRoute("{table}/{action}.aspx") With {
            .Constraints = New RouteValueDictionary(New With {.Action = RouteValueActions}),
            .Model = DefaultModel})

        ' The following statements support combined-page mode, where the List, Detail, Insert, and
        ' Update tasks are performed by using the same page. To enable this mode, uncomment the
        ' following routes and comment out the route definition in the separate-page mode section above.
        'routes.Add(New DynamicDataRoute("{table}/ListDetails.aspx") With {
        '	.Action = PageAction.List,
        '	.ViewName = "ListDetails",
        '	.Model = DefaultModel})

        'routes.Add(New DynamicDataRoute("{table}/ListDetails.aspx") With {
        '	.Action = PageAction.Details,
        '	.ViewName = "ListDetails",
        '	.Model = DefaultModel})

    End Sub

    Private Sub Application_Start(ByVal sender As Object, ByVal e As EventArgs)
        RegisterRoutes(RouteTable.Routes)
        BundleConfig.RegisterBundles(BundleTable.Bundles)
        '
        ' Inizializzazione per AppInsight
        '
        TelemetryConfiguration.Active.TelemetryInitializers.Add(New MyTelemetryInitializer())

        '
        ' Registro i Ruoli di Accesso
        '
        RuoloAccessoManager.Initiliaze()

    End Sub

    Sub Session_Start(ByVal sender As Object, ByVal e As EventArgs)

        Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)

        Dim now = DateTime.Now

        portal.TracciaAccessi(User.Identity.Name, PortalsNames.Connettori, String.Format("Accesso effettuato il {0} alle ore {1}", now.ToString("dd/MM/yyy"), now.ToString("HH:mm:ss")))

        Me.Session.Add("userName", User.Identity.Name)
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

    Sub Session_End(ByVal sender As Object, ByVal e As EventArgs)
        Dim accessDate As DateTime = Nothing
        Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)
        Dim userName = Me.Session("userName").ToString()

        SyncLock _usersLastRequestDateTime
            accessDate = If(_usersLastRequestDateTime.ContainsKey(userName), _usersLastRequestDateTime(userName), DateTime.Now)
            _usersLastRequestDateTime.Remove(userName)
        End SyncLock

        portal.TracciaAccessi(userName, PortalsNames.Connettori, String.Format("L'utente si è disconnesso il {0} alle ore {1}", accessDate.ToString("dd/MM/yyy"), accessDate.ToString("HH:mm:ss")))
    End Sub

    Sub Application_Error(ByVal sender As Object, ByVal e As EventArgs)
        Try
            '
            ' LOG DEGLI ERRORI APPLICATIVI
            '
            Call GestioneErrori.TrapError(Server.GetLastError())
        Catch
            Call GestioneErrori.TrapError(Server.GetLastError())
        End Try
    End Sub


End Class
