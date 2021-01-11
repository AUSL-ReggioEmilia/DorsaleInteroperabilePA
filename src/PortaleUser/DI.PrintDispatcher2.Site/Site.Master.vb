Imports System.Web.UI
Imports System.Web
Imports System.Web.UI.WebControls
Imports System
Imports System.Reflection
Imports System.Net.NetworkInformation
Imports DI.PortalUser2
Imports DI.PortalUser2.Data

Namespace DI.OrderEntry.Admin
    Partial Public Class Site
        Inherits MasterPage

        Private Shared moDiUserInterface As New UserInterface(ConfigurationManager.ConnectionStrings(Utility.PORTAL_USER_CONNECTION_STRING).ConnectionString)
        Private msUserIdentityName As String = HttpContext.Current.User.Identity.Name.ToUpper
        Dim moRoleManagerUtility As New RoleManagerUtility2(ConfigurationManager.ConnectionStrings(Utility.PORTAL_USER_CONNECTION_STRING).ConnectionString, ConfigurationManager.ConnectionStrings(Utility.SAC_CONNECTION_STRING).ConnectionString, My.Settings.WsSac_User, My.Settings.WsSac_Password)

        Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load
            Try

                Page.Title = PortalsTitles.PrintDispatcher
                'lblTitle.Text = DI.PortalUser.Data.PortalsTitles.PrintDispatcher
                'lblSubTitle.Text = DI.PortalUser.Data.PortalsTitles.Titolare
                'idFooter.Text = mDIPortalAdminUI.GetHtmlBootstrapStatusbar("ver. " & Assembly.GetExecutingAssembly.GetName.Version.ToString)
                versioneAssembly.Text = Assembly.GetExecutingAssembly.GetName.Version.ToString
                Dim oProperties = IPGlobalProperties.GetIPGlobalProperties()
                nomeHost.Text = String.Format("{0}.{1}", oProperties.HostName, oProperties.DomainName)

                If Not IsPostBack Then
                    '
                    ' Per memorizzare l'ultima pagina visitata dall'utente
                    '
                    Utility.SetUrlCorrente()

                    '
                    ' Imposto l'header
                    '
                    Dim sAppPath As String = Utility.GetApplicationPath()
                    HeaderPlaceholder.Text = moDiUserInterface.GetBootstrapHeader2(PortalsTitles.PrintDispatcher)

                    '
                    ' Carico il menu orizzontale
                    '
                    Call PopulateMenu()
                    '
                    ' Popolo i dati all'interno del riquadro utente
                    '
                    Call PopolaInfoUtente()
                End If
                '
                ' A questo punto scrivo i dati di accesso: lo faccio solo una volta per sessione
                '
                If Session("WRITE_DATI_ACCESSO") Is Nothing Then
                    '
                    ' In caso di errore dovuto a mancanza di ruoli per l'utente cmbRuoliUtente.SelectedItem è nothing
                    '
                    If Not cmbRuoliUtente.SelectedItem Is Nothing Then
                        Session("WRITE_DATI_ACCESSO") = True
                        '
                        ' Scrivo la data di accesso corrente e il ruolo corrente: sarà quella letta alla prossima ripartenza della sessione
                        '
                        Dim oSess As New SessioneUtente(ConfigurationManager.ConnectionStrings(Utility.SAC_CONNECTION_STRING).ConnectionString, ConfigurationManager.ConnectionStrings(Utility.PORTAL_USER_CONNECTION_STRING).ConnectionString, My.Settings.WsSac_User, My.Settings.WsSac_Password)
                        oSess.SetUltimoAccesso(msUserIdentityName, PortalsNames.PrintDispatcher, Now(), cmbRuoliUtente.SelectedItem.Value)
                        '
                        ' Scrivo anche nella tabella DiUserPortal.LogAccessi con quale ruolo inizio la sessione.
                        '
                        Utility.PortalUserTracciaAccessi(cmbRuoliUtente.SelectedValue)
                    End If
                End If
            Catch ex As Exception
                'ottengo il nome della procedura per avere maggiori info su application insights
                Dim sCurrentMethodName = System.Reflection.MethodBase.GetCurrentMethod().Name
                'Scrivo solo nell'event log
                Call GestioneErrori.TrapError(ex, sCurrentMethodName)
                Me.NavigateToErrorPage(Utility.ErrorCode.Exception, "Si è verificato un errore durante il caricamento della pagina!", False)
            End Try
        End Sub

        Private Sub PopulateMenu()

            Me.MenuMain.Items.Clear()

            Dim adapter As New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings(Utility.PORTAL_USER_CONNECTION_STRING).ConnectionString)

            Dim idPortale As Integer = PortalDataAdapterManager.EnumPortalId.PrintDispatcher
            Dim listaPortalUserMenuItem As List(Of PortalUserMenuItem) = adapter.GetMainMenu(idPortale)

            For Each menuItem In listaPortalUserMenuItem
                Dim target = If(menuItem.Url.IndexOf("http", StringComparison.CurrentCultureIgnoreCase) > -1, "_blank", String.Empty)
                Dim newMenuItem As New MenuItem(menuItem.Descrizione, Nothing, Nothing, Me.ResolveUrl(menuItem.Url), target)
                Me.MenuMain.Items.Add(newMenuItem)
                newMenuItem.Selected = menuItem.IsSelected
            Next
        End Sub

        'Public Sub ChangeLeftMenuVisibility(ByVal show As Boolean)

        '    Me.LeftMenuHtmlTable.Style(HtmlTextWriterStyle.Display) = If(show, "block", "none")
        'End Sub

        'Private Sub LeftMenuTreeView_TreeNodeDataBound(ByVal sender As Object, ByVal e As TreeNodeEventArgs) Handles LeftMenuTreeView.TreeNodeDataBound

        'End Sub


#Region "popolazione combo ruoli utente"

        ''' <summary>
        ''' Carica la combo dei ruoli dell'utente
        ''' </summary>
        ''' <param name="oListRuoli"></param>
        ''' <remarks></remarks>
        Private Sub PopolaComboRuoliUtente(ByVal oListRuoli As Generic.List(Of RoleManager.Ruolo), ByVal sRuoloCorrenteCodice As String)
            '
            ' Ordino la lista dei ruoli
            '
            If Not oListRuoli Is Nothing AndAlso oListRuoli.Count > 1 Then
                oListRuoli.Sort(ListRuoliComparison)
            End If
            '
            ' Cancello gli item della combo
            '
            cmbRuoliUtente.Items.Clear()
            '
            ' Popola la combo con i ruoli dell'utente
            '
            cmbRuoliUtente.DataSource = oListRuoli
            cmbRuoliUtente.DataValueField = "Codice"
            cmbRuoliUtente.DataTextField = "Descrizione"
            '
            ' Bind della combo
            '
            cmbRuoliUtente.DataBind()
            '
            ' Inizializzo la combo con l'ultimo accesso
            ' 
            If Not String.IsNullOrEmpty(sRuoloCorrenteCodice) Then
                Dim oItem As System.Web.UI.WebControls.ListItem = cmbRuoliUtente.Items.FindByValue(sRuoloCorrenteCodice)
                If Not oItem Is Nothing Then
                    oItem.Selected = True
                End If
            End If
        End Sub

        Private Sub PopolaInfoUtente()
            '
            ' Visualizzo nome utente
            '
            lblUtente.Text = msUserIdentityName
            '
            ' Nome del PC
            '
            lblPostazione.Text = Utility.GetUserHostName()
            '
            ' Visualizzo ultimo accesso
            ' Session(Utility.SESS_DATI_ULTIMO_ACCESSO) è inizializzata nell'evento Session_Start() del Global.asax
            ' e non cambia più a meno che la sessione non termini
            '
            Dim oUltimoAccesso As SessioneUtente.UltimoAccesso = CType(Session(Utility.SESS_DATI_ULTIMO_ACCESSO), SessioneUtente.UltimoAccesso)
            If Not oUltimoAccesso Is Nothing Then
                lblLegend.Text = oUltimoAccesso.Utente.Nome & " " & oUltimoAccesso.Utente.Cognome
                lblUltimoAccesso.Text = oUltimoAccesso.UltimoAccessoDescrizione
            End If
            '
            ' Popolo combo ruoli
            '
            Dim oListRuoli As Generic.List(Of RoleManager.Ruolo) = moRoleManagerUtility.GetRuoli()
            '
            ' Controllo se vi sono dei ruoli 
            '
            If oListRuoli Is Nothing OrElse oListRuoli.Count = 0 Then
                '
                ' Nascondo la riga della tabella con la combi dei ruoli
                '
                trRuoli.Visible = False
                '
                ' Condizione di errore: navigo a pagina di errore
                '
                ' MODIFICA ETTORE 2018-12-03: non segnalo errore se l'utente non ha "ruoli role manager"
                ' Il Print Dispatcher deve poter funzionare anche per un utente che non ha "ruoli role manager" configurati.
                ' Call Me.NavigateToErrorPage(Utility.ErrorCode.NoRights, "L'utente non ha nessun ruolo configurato! Contattare l'amministratore.", False)
            Else
                '
                ' Il ruolo corrente non può essere nothing perchè viene dall'oggetto "contesto utente" che se nothing viene ricalcolato
                '
                Dim oRuoloCorrente As RoleManager.Ruolo = moRoleManagerUtility.RuoloCorrente
                '
                ' Popolo la combo
                '
                Call PopolaComboRuoliUtente(oListRuoli, oRuoloCorrente.Codice)
                '
                'Valorizzo il ruolo utente nella navbar
                '
                lblRuoloUtente.Text = cmbRuoliUtente.SelectedItem.Text
            End If
        End Sub

        '
        ' Funzioni private per ordinare la lista dei ruoli
        '
        Private ListRuoliComparison As Comparison(Of RoleManager.Ruolo) = AddressOf ListRuoliSort
        Private Function ListRuoliSort(p1 As RoleManager.Ruolo, p2 As RoleManager.Ruolo) As String
            Return p1.Descrizione.CompareTo(p2.Descrizione)
        End Function


        ''' <summary>
        ''' Naviga alla pagina di errore
        ''' </summary>
        ''' <param name="enumErrorCode"></param>
        ''' <param name="sErroreDescrizione"></param>
        ''' <param name="endResponse"></param>
        ''' <remarks>La funzione implementa un test sulla pagina ASPX richiesta per non creare una ricorsione</remarks>
        Private Sub NavigateToErrorPage(enumErrorCode As Utility.ErrorCode, sErroreDescrizione As String, endResponse As Boolean)
            Dim sAbsoluteUri As String = Request.Url.AbsoluteUri.ToString().ToUpper
            '
            ' Questo test evita una ricorsione infinita
            '
            If Not sAbsoluteUri.Contains("ERRORPAGE.ASPX") Then
                Call Utility.NavigateToErrorPage(enumErrorCode, sErroreDescrizione, endResponse)
            End If
        End Sub



        ''' <summary>
        ''' Selezione ruolo
        ''' </summary>
        ''' <param name="sender"></param>
        ''' <param name="e"></param>
        ''' <remarks></remarks>
        Private Sub cmbRuoliUtente_SelectedIndexChanged(sender As Object, e As System.EventArgs) Handles cmbRuoliUtente.SelectedIndexChanged
            '
            ' Creo un altro postback cosi si passa nuovamente per il global.asax nell'evento "Application_PostAuthenticateRequest"
            ' Navigo alla pagina corrente o alla Home cosi si riinizia tutto da capo?
            ' 
            Dim oCombo As UI.WebControls.DropDownList
            Try
                oCombo = DirectCast(sender, UI.WebControls.DropDownList)
                '
                ' Salvo in PortalUser.LogAccessi l'accesso con il ruolo corrente (lo utilizzerò per visualizzare le info di ultimo accesso)
                '
                Call Utility.PortalUserTracciaAccessi(oCombo.SelectedItem.Value)
                '
                ' Salvo nella tabella DatiUtente l'ultimo ruolo scelto dall'utente
                '
                Dim oPortalDataAdapterManager As PortalDataAdapterManager
                oPortalDataAdapterManager = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings(Utility.PORTAL_USER_CONNECTION_STRING).ConnectionString)
                oPortalDataAdapterManager.DatiUtenteSalvaValore(HttpContext.Current.User.Identity.Name.ToUpper, moRoleManagerUtility.DI_USER_RUOLO_CORRENTE_CODICE, oCombo.SelectedItem.Value)
                '
                ' Scrivo la data di accesso corrente e il ruolo corrente: sarà quella letta alla prossima ripartenza della sessione
                '
                Dim oSess As New SessioneUtente(ConfigurationManager.ConnectionStrings(Utility.SAC_CONNECTION_STRING).ConnectionString, ConfigurationManager.ConnectionStrings(Utility.PORTAL_USER_CONNECTION_STRING).ConnectionString, My.Settings.WsSac_User, My.Settings.WsSac_Password)
                oSess.SetUltimoAccesso(msUserIdentityName, PortalsNames.PrintDispatcher, Now(), cmbRuoliUtente.SelectedItem.Value)
                '
                ' Quando cambio ruolo navigo ad una pagina a cui tutti hanno accesso.
                ' Imposto EndResponse=False per non generare ThreadAbortException
                '
                Call GoToDefaultPage(False)
            Catch ex As Exception
                'ottengo il nome della procedura per avere maggiori info su application insights
                Dim sCurrentMethodName = System.Reflection.MethodBase.GetCurrentMethod().Name
                'Scrivo solo nell'event log
                Call GestioneErrori.TrapError(ex, sCurrentMethodName)
            End Try
        End Sub

#End Region


        Private Sub GoToDefaultPage(ByVal endResponse As Boolean)
            '
            ' Imposto EndResponse=False per non generare ThreadAbortException
            '
            Response.Redirect(Me.ResolveUrl("~/Dispatcher/StampeLista.aspx"), endResponse)
        End Sub

    End Class

End Namespace