Imports DwhClinico.Data
Imports DwhClinico.Web
Imports System.Xml
Imports DwhClinico.Web.Utility
Imports System.Net.NetworkInformation
Imports DI.PortalUser2
Imports DI.PortalUser2.Data


'USA DI.PORTALUSER
Partial Class Portale_Default
	Inherits System.Web.UI.MasterPage

    Const SES_SELECT_MENU As String = "SelectedMenu"
	Const SES_SELECT_SUBMENU As String = "SelectedSubMenu"

	Private Shared oDiUserInterface As New UserInterface()

	Private msUserIdentityName As String = HttpContext.Current.User.Identity.Name.ToUpper
	'Dim moRoleManagerUtility As New RoleManagerUtility2(Utility.GetAppSettings(Utility.PAR_DI_PORTAL_USER_CONNECTION_STRING, ""), My.Settings.SAC_ConnectionString, My.Settings.WsSac_User, My.Settings.WsSac_Password)

	Protected Overrides Sub OnPreRender(ByVal e As System.EventArgs)
		'
		' Scrive nella pagina gli script JS per aprire i popup.
		'
		Dim sClientCode As String = ""
		If Not Page.ClientScript.IsClientScriptBlockRegistered(Me.GetType.Name) Then
			'
			' Aggiungo tutte le funzioni lato client
			'
			sClientCode = sClientCode & JSOpenWindowFunction() & vbCrLf
			'
			' Registro lo script
			'
			Page.ClientScript.RegisterClientScriptBlock(GetType(Page), Me.GetType.Name, JSBuildScript(sClientCode))
		End If
	End Sub


	Private Shared moDiUserInterface As New DI.PortalUser2.UserInterface(Utility.GetAppSettings(Utility.PAR_DI_PORTAL_USER_CONNECTION_STRING, ""))

	Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
		ucMenuRuoliUtente.IsAccessoDiretto = False

		Page.Title = PortalsTitles.DwhClinico

		Dim oProperties = IPGlobalProperties.GetIPGlobalProperties()

		Try

			'
			' Resetto sempre Accesso Diretto
			'
			Me.Session(SESS_ACCESSO_DIRETTO) = False

			'VALORIZZO LA VARIABILE UTILIZZATA PER VERIFICARE SE LA SESSIONE E' ATTIVA.
			SessionHandler.ValidaSessioneAccessoStandard = True

			If Not IsPostBack() Then

				'
				'SimoneB - 29/06/2017
				'Imposto l'header bootstrap usando il nuovo logo della dorsale.
				'
				Dim sAppPath As String = Utility.GetApplicationPath()
				HeaderPlaceholder.Text = moDiUserInterface.GetBootstrapHeader2(PortalsTitles.DwhClinico)

				MenuMain.Style.Remove("float")

				'
				' Modifica Ettore 2014-03-05: per memorizzare l'ultima pagina visitata dall'utente
				'
				Call Utility.SetUrlCorrente()
			End If

			'
			' Popolo il menu orizzontale del portale user della DI
			'
			PopulateMenu()

			''
			'' MODIFICA ETTORE 2015-06-17: 
			'' A questo punto scrivo i dati di accesso: lo faccio solo una volta per sessione
			''
			'If Session("WRITE_DATI_ACCESSO") Is Nothing Then
			'    '
			'    ' In caso di errore dovuto a mancanza di ruoli per l'utente cmbRuoliUtente.SelectedItem è nothing
			'    '
			'    If Not cmbRuoliUtente.SelectedItem Is Nothing Then
			'        Session("WRITE_DATI_ACCESSO") = True
			'        '
			'        ' Scrivo la data di accesso corrente e il ruolo corrente: sarà quella letta alla prossima ripartenza della sessione
			'        '
			'        Dim oSess As New SessioneUtente(My.Settings.SAC_ConnectionString, Utility.GetAppSettings(Utility.PAR_DI_PORTAL_USER_CONNECTION_STRING, ""), My.Settings.WsSac_User, My.Settings.WsSac_Password)
			'        oSess.SetUltimoAccesso(msUserIdentityName, PortalsNames.DwhClinico, Now(), cmbRuoliUtente.SelectedItem.Value)
			'        '
			'        ' Scrivo anche nella tabella DiUserPortal.LogAccessi con quale ruolo inizio la sessione.
			'        '
			'        Utility.PortalUserTracciaAccessi(cmbRuoliUtente.SelectedValue)
			'    End If
			'End If
		Catch ex As Exception
			Logging.WriteError(ex, Me.GetType.Name)
			Me.NavigateToErrorPage(Utility.ErrorCode.Exception, "Si è verificato un errore durante il caricamento della pagina!", False)
		End Try
	End Sub

	Private Sub GoToPageErrorNoRights()
		Try
			Me.Response.Redirect(Me.ResolveUrl("~/ErrorNoRights.htm"), True)
		Catch ex As Threading.ThreadAbortException
			'
			' Non faccio nulla
			'
		End Try
	End Sub

    '''' <summary>
    '''' Popolazione del menu orizzontale della DI
    '''' </summary>
    '''' <remarks></remarks>
    'Private Sub PopoloMenuOrizzontaleDi()
    '    Try
    '        Dim sDiPortalUserConnectionString As String = GetAppSettings(PAR_DI_PORTAL_USER_CONNECTION_STRING, "")
    '        If Not String.IsNullOrEmpty(sDiPortalUserConnectionString) Then
    '            'DiPortalUserMenu.Visible = True
    '            Me.MenuMain.Items.Clear()
    '            '
    '            ' Instanzio oggetto per ottenere le voci di menù
    '            '
    '            Dim oPortalDataAdapterManager As New PortalDataAdapterManager(sDiPortalUserConnectionString)
    '            Dim dictionary As Generic.Dictionary(Of String, String) = oPortalDataAdapterManager.GetMainMenu()
    '            '
    '            ' Aggiungo le voci di menù al menù Main
    '            '
    '            For Each entry In dictionary
    '                Dim target = If(entry.Value.IndexOf("http", StringComparison.CurrentCultureIgnoreCase) > -1, "_blank", String.Empty)
    '                Dim newMenuItem As New MenuItem(entry.Key, Nothing, Nothing, Me.ResolveUrl(entry.Value), target)
    '                Me.MenuMain.Items.Add(newMenuItem)
    '            Next
    '            MenuMain.Items(3).Selected = True
    '        Else
    '            'DiPortalUserMenu.Visible = False
    '        End If
    '    Catch ex As Exception
    '        'DiPortalUserMenu.Visible = False
    '        Logging.WriteError(ex, "Errore durante caricamento del menu del portale DiPortaluser.")
    '    End Try
    'End Sub

    ''
    '' Funzioni private per ordinare la lista dei ruoli
    ''
    'Private ListRuoliComparison As Comparison(Of RoleManager.Ruolo) = AddressOf ListRuoliSort
    'Private Function ListRuoliSort(p1 As RoleManager.Ruolo, p2 As RoleManager.Ruolo) As String
    '    Return p1.Descrizione.CompareTo(p2.Descrizione)
    'End Function


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

	Private Sub GoToDefaultPage(ByVal endResponse As Boolean)
		'
		' Imposto EndResponse=False per non generare ThreadAbortException
		'
		Response.Redirect(Me.ResolveUrl("~/Default.aspx"), endResponse)
	End Sub

	''' <summary>
	''' Funzione per la visualizzazione degli errori
	''' </summary>
	''' <param name="ErrorMessage"></param>
	Public Sub ShowErrorLabel(ErrorMessage As String)
		DivError.Visible = True

		Utility.ShowErrorLabel(LabelError, ErrorMessage)

		updError.Update()
	End Sub

	Private Sub MenuMain2_PreRender(sender As Object, e As EventArgs) Handles MenuMain2.PreRender
		Try
			Dim itemDaEliminare As MenuItem = Nothing

			For Each item As MenuItem In MenuMain2.Items
				'Se  My.Settings.Print_Enabled è true salvo dentro itemDaEliminare l'item da eliminare
				If Not My.Settings.Print_Enabled AndAlso item.DataPath.ToLower.Contains("configurazionestampa.aspx") Then
					itemDaEliminare = item
				End If
			Next

			'Non posso eliminarlo nel ciclo, quindi lo elimino appena il for è terminato.
			If Not itemDaEliminare Is Nothing Then
				MenuMain2.Items.Remove(itemDaEliminare)
			End If

		Catch ex As Exception
			Logging.WriteError(ex, "Errore durante caricamento del menu.")
		End Try
	End Sub

	Private Sub PopulateMenu()
		Try
			Me.MenuMain.Items.Clear()

			Dim adapter As New PortalDataAdapterManager(GetAppSettings(PAR_DI_PORTAL_USER_CONNECTION_STRING, ""))

			Dim idPortale As Integer = PortalDataAdapterManager.EnumPortalId.Dwh
			Dim listaPortalUserMenuItem As List(Of PortalUserMenuItem) = adapter.GetMainMenu(idPortale)

			For Each menuItem In listaPortalUserMenuItem
				Dim target = If(menuItem.Url.IndexOf("http", StringComparison.CurrentCultureIgnoreCase) > -1, "_blank", String.Empty)
				Dim newMenuItem As New MenuItem(menuItem.Descrizione, Nothing, Nothing, Me.ResolveUrl(menuItem.Url), target)
				Me.MenuMain.Items.Add(newMenuItem)
				newMenuItem.Selected = menuItem.IsSelected
			Next
		Catch ex As Exception
			Logging.WriteError(ex, "Errore durante caricamento del menu del portale DiPortaluser.")
		End Try
	End Sub
End Class

