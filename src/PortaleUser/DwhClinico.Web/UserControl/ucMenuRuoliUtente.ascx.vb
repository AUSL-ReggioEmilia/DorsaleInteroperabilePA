Imports DwhClinico.Data
Imports System.Net.NetworkInformation
Imports DI.PortalUser2
Imports DI.PortalUser2.Data

Public Class ucMenuRuoliUtente
    Inherits System.Web.UI.UserControl

    ''' <summary>
    ''' Property usata per capire se siamo nell'accesso diretto oppure no.
    ''' </summary>
    ''' <returns></returns>
    Public Shared Property IsAccessoDiretto() As Boolean

    Private ListRuoliComparison As Comparison(Of RoleManager.Ruolo) = AddressOf ListRuoliSort
    Const SES_SELECT_MENU As String = "SelectedMenu"
    Const SES_SELECT_SUBMENU As String = "SelectedSubMenu"
    Private msUserIdentityName As String = HttpContext.Current.User.Identity.Name.ToUpper
    Dim moRoleManagerUtility As New RoleManagerUtility2(Utility.GetAppSettings(Utility.PAR_DI_PORTAL_USER_CONNECTION_STRING, ""), My.Settings.SAC_ConnectionString, My.Settings.WsSac_User, My.Settings.WsSac_Password)

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        versioneAssembly.Text = Utility.GetAssemblyVersion()

        Dim oProperties = IPGlobalProperties.GetIPGlobalProperties()
        nomeHost.Text = String.Format("{0}.{1}", oProperties.HostName, oProperties.DomainName)


        If Not Page.IsPostBack Then
            '
            ' Popolo i dati all'interno del riquadro utente
            '
            Call PopolaInfoUtente()
        End If

        '
        ' MODIFICA ETTORE 2015-06-17: 
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
                Dim oSess As New SessioneUtente(My.Settings.SAC_ConnectionString, Utility.GetAppSettings(Utility.PAR_DI_PORTAL_USER_CONNECTION_STRING, ""), My.Settings.WsSac_User, My.Settings.WsSac_Password)
                oSess.SetUltimoAccesso(msUserIdentityName, PortalsNames.DwhClinico, Now(), cmbRuoliUtente.SelectedItem.Value)
                '
                ' Scrivo anche nella tabella DiUserPortal.LogAccessi con quale ruolo inizio la sessione.
                '
                Utility.PortalUserTracciaAccessi(cmbRuoliUtente.SelectedValue)
            End If
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
            oPortalDataAdapterManager = New PortalDataAdapterManager(Utility.GetAppSettings(Utility.PAR_DI_PORTAL_USER_CONNECTION_STRING, ""))
            oPortalDataAdapterManager.DatiUtenteSalvaValore(HttpContext.Current.User.Identity.Name.ToUpper, moRoleManagerUtility.DI_USER_RUOLO_CORRENTE_CODICE, oCombo.SelectedItem.Value)
            '
            ' MODIFICA ETTORE 2015-06-17: 
            ' Scrivo la data di accesso corrente e il ruolo corrente: sarà quella letta alla prossima ripartenza della sessione
            '
            Dim oSess As New SessioneUtente(My.Settings.SAC_ConnectionString, Utility.GetAppSettings(Utility.PAR_DI_PORTAL_USER_CONNECTION_STRING, ""), My.Settings.WsSac_User, My.Settings.WsSac_Password)
            oSess.SetUltimoAccesso(msUserIdentityName, PortalsNames.DwhClinico, Now(), cmbRuoliUtente.SelectedItem.Value)
            '
            ' Comando di invalidare la cache della pagina che elenca i referti e i ricoveri
            '
            Session(Utility.SESS_INVALIDA_CACHE_LISTA_REFERTI) = True
            Session(Utility.SESS_INVALIDA_CACHE_LISTA_RICOVERI) = True


            If IsAccessoDiretto Then
                '
                ' Navigo alla pagina corrente: non posso fare altro
                '
                Dim sUrl As String = Request.UrlReferrer.AbsoluteUri.ToString()
                sUrl = Me.ResolveUrl(sUrl)
                '
                ' Imposto EndResponse=False per non generare ThreadAbortException
                '
                Response.Redirect(sUrl, False)
            Else
                '
                ' Quando cambio ruolo navigo alla pagina di Home a cui tutti hanno accesso.
                ' Altrimenti si potrebbe verificare un errore se l'utente ad esempio aveva selezionato l'item del tree "Pazienti"
                ' e il cambio di ruolo "trimma" questo item in seguito alla location path impostata nel web.config 
                ' 'Dim sUrl As String = Request.UrlReferrer.AbsoluteUri.ToString()
                ' Imposto EndResponse=False per non generare ThreadAbortException
                '
                '
                'Cancello il token salvato in sessione
                '
                SessionHandler.Token = Nothing
                Call GoToDefaultPage(False)
            End If


        Catch ex As Exception
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub


    ''' <summary>
    ''' Carica la combo dei ruoli dell'utente
    ''' </summary>
    ''' <param name="oListRuoli"></param>
    ''' <remarks></remarks>
    Private Sub PopolaComboRuoliUtente(ByVal oListRuoli As Generic.List(Of RoleManager.Ruolo), ByVal sRuoloCorrenteCodice As String)
        '
        ' MODIFICA ETTORE 2015-03-19: Ordino la lista dei ruoli
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

    ''' <summary>
    ''' Valorizza i controlli del riquadro delle info utente + combo dei ruoli
    ''' </summary>
    ''' <remarks></remarks>
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
            If IsAccessoDiretto Then
                Me.NavigateToAccessoDirettoErrorPage(Utility.ErrorCode.Exception, "Si è verificato un errore durante il caricamento della pagina!", False)
            Else
                Call Me.NavigateToErrorPage(Utility.ErrorCode.NoRights, "L'utente non ha nessun ruolo configurato! Contattare l'amministratore.", False)
            End If
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
    ''' Naviga alla pagina di errore dell'accesso diretto
    ''' </summary>
    ''' <param name="enumErrorCode"></param>
    ''' <param name="sErroreDescrizione"></param>
    ''' <param name="endResponse"></param>
    Private Sub NavigateToAccessoDirettoErrorPage(enumErrorCode As Utility.ErrorCode, sErroreDescrizione As String, endResponse As Boolean)
        Dim sAbsoluteUri As String = Request.Url.AbsoluteUri.ToString().ToUpper
        '
        ' Questo test evita una ricorsione infinita
        '
        If Not sAbsoluteUri.Contains("ERRORPAGE.ASPX") Then
            Call Utility.NavigateToAccessoDirettoErrorPage(enumErrorCode, sErroreDescrizione, endResponse)
        End If
    End Sub

    ''' <summary>
    ''' Naviga alla pagina di errore dell'accesso standard
    ''' </summary>
    ''' <param name="endResponse"></param>
    Private Sub GoToDefaultPage(ByVal endResponse As Boolean)
        '
        ' Imposto EndResponse=False per non generare ThreadAbortException
        '
        Response.Redirect(Me.ResolveUrl("~/Default.aspx"), endResponse)
    End Sub
End Class