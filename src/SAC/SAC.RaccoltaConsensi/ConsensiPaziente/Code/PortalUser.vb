Imports DI.PortalUser2
Imports DI.PortalUser2.Data
Imports System

'<summary>
'Classe SINGLETON inizializzata nel global.asax per condividere le property in tutto il progetto.
'</summary>
Public NotInheritable Class PortalUserSingleton

#Region "PublicProperties"
    Public ReadOnly RoleManagerUtility As RoleManagerUtility2
    Public ReadOnly SessioneUtente As SessioneUtente
    Public ReadOnly PortalDataAdapterManager As PortalDataAdapterManager
#End Region

    Private Sub New()
        'Ottengo la connection string del database DiPortalUser.
        Dim portalUserConnectionString As String = My.Settings.PortalUserConnectionString

        'Ottengo la connection string del database SAC.
        Dim sacConnectionString As String = System.Configuration.ConfigurationManager.ConnectionStrings("SACConnectionString").ConnectionString

        'Ottengo l'utente SAC.
        Dim SacWs_User As String = My.Settings.SACUsername

        '//Ottengo la password SAC.
        Dim SacWs_Password As String = My.Settings.SACPassword

        '	//Controllo che "portalUserConnectionString" sia valorizzata.
        If String.IsNullOrEmpty(portalUserConnectionString) Then
            Throw New Exception("Parametro di configurazione assente: PortalUserConnectionString.")
        End If

        'Controllo che "sacConnectionString" sia valorizzata.
        If String.IsNullOrEmpty(sacConnectionString) Then
            Throw New Exception("Parametro di configurazione assente: SacConnectionString.")
        End If

        SessioneUtente = New SessioneUtente(sacConnectionString, portalUserConnectionString, SacWs_User, SacWs_Password)
        RoleManagerUtility = New RoleManagerUtility2(portalUserConnectionString, sacConnectionString, SacWs_User, SacWs_Password)
        PortalDataAdapterManager = New PortalDataAdapterManager(portalUserConnectionString)
    End Sub

    Private Shared _instance As PortalUserSingleton
    Public Shared ReadOnly Property instance As PortalUserSingleton
        Get
            If (_instance Is Nothing) Then
                _instance = New PortalUserSingleton()
            End If
            Return _instance
        End Get
    End Property

End Class
