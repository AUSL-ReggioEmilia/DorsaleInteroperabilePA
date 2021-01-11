Imports DwhClinico.Data
Imports DwhClinico.Web
Imports DwhClinico.Web.Utility
Imports DI.PortalUser2.RoleManager
Imports System.Net.NetworkInformation
Imports DI.PortalUser2.Data
Imports DI.PortalUser2

Partial Class AccessoDiretto_AccessoDiretto
    Inherits System.Web.UI.MasterPage

    Private Shared moDiUserInterface As New DI.PortalUser2.UserInterface(Utility.GetAppSettings(Utility.PAR_DI_PORTAL_USER_CONNECTION_STRING, ""))
    Private msUserIdentityName As String = HttpContext.Current.User.Identity.Name.ToUpper
    Dim moRoleManagerUtility As New RoleManagerUtility2(Utility.GetAppSettings(Utility.PAR_DI_PORTAL_USER_CONNECTION_STRING, ""), My.Settings.SAC_ConnectionString, My.Settings.WsSac_User, My.Settings.WsSac_Password)


    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Page.Title = PortalsTitles.DwhClinico
        Dim oProperties = IPGlobalProperties.GetIPGlobalProperties()

        '
        'Indico allo user control che siamo nell'accesso diretto.
        '
        ucMenuRuoliUtente.IsAccessoDiretto = True

        Try
            '
            ' Notifico che si entra in Accesso Diretto
            '
            Me.Session(SESS_ACCESSO_DIRETTO) = True

            If Not IsPostBack Then
                'Imposto visibile o non visibile l'header in base a quanto voluto dall'utente tramite parametro "ShowHeader" nella querystring in precedenza
                Me.HeaderPlaceholder.Visible = SessionHandler.ShowHeader
                '
                'SimoneB - 29/06/2017
                'Imposto l'header bootstrap usando il nuovo logo della dorsale.
                '
                Dim sAppPath As String = Utility.GetApplicationPath()
                HeaderPlaceholder.Text = moDiUserInterface.GetBootstrapHeader2(PortalsTitles.DwhClinico)

                '
                ' Titolo
                '
                If Me.Page.Title = "Untitled Page" Then
                    Me.Page.Title = "Accesso diretto"
                End If
            End If
        Catch ex As Exception
            Logging.WriteError(ex, Me.GetType.Name)
            Me.NavigateToAccessoDirettoErrorPage(Utility.ErrorCode.Exception, "Si è verificato un errore durante il caricamento della pagina!", False)
        End Try
    End Sub

    ''' <summary>
    ''' Naviga alla pagina di errore
    ''' </summary>
    ''' <param name="enumErrorCode"></param>
    ''' <param name="sErroreDescrizione"></param>
    ''' <param name="endResponse"></param>
    ''' <remarks>La funzione implementa un test sulla pagina ASPX richiesta per non creare una ricorsione</remarks>
    Private Sub NavigateToAccessoDirettoErrorPage(enumErrorCode As Utility.ErrorCode, sErroreDescrizione As String, endResponse As Boolean)
        Dim sAbsoluteUri As String = Request.Url.AbsoluteUri.ToString().ToUpper
        '
        ' Questo test evita una ricorsione infinita
        '
        If Not sAbsoluteUri.Contains("ERRORPAGE.ASPX") Then
            Call Utility.NavigateToAccessoDirettoErrorPage(enumErrorCode, sErroreDescrizione, endResponse)
        End If
    End Sub

End Class

