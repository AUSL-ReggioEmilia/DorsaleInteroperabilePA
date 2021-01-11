Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports System.Reflection
Imports System.Collections.Generic
Imports System.Net.NetworkInformation
Imports DI.PortalUser2
Imports DI.PortalUser2.Data
Imports System.Web.UI.HtmlControls

Namespace DI.OrderEntry.User

	Partial Public Class SiteAccessoDiretto
		Inherits MasterPage

		Private msTreeViewCurrentValePath As String
		Private Shared mDIPortalAdminUI As New UserInterface(Global_asax.ConnectionStringPortalUser)
		Private msUserIdentityName As String = HttpContext.Current.User.Identity.Name.ToUpper
		Private moRoleManagerUtility As New RoleManagerUtility2(Global_asax.ConnectionStringPortalUser, My.Settings.SAC_ConnectionString, My.Settings.WsSac_User, My.Settings.WsSac_Password)

		'
		'USATA PER NASOCNDERE GLI ELEMENTI DELLA SITE MAP IN BASE AL ROLE E ALL'ATTRIBUTO "HIDE"
		'L'OGGETTO DI TIPO SecondMenuAttribute VIENE POPOLATO CON L'URL DELLA SITEMAP, IL VALORE DELL'ATTRIBUTO "HIDE" E IL VALORE DELL'ATTRIBUTO "ROLES"
		'
		Private Class SecondMenuAttribute
			Public Hide As Boolean = False
			Public NavigateUrl As String = String.Empty
			Public Roles As System.Collections.IList = Nothing

			Public Sub New(Hide As Boolean, NavigateUrl As String, Roles As System.Collections.IList)
				Me.Hide = Hide
				Me.NavigateUrl = NavigateUrl
				Me.Roles = Roles
			End Sub
		End Class

		Private mMyMenuLeft As New Dictionary(Of String, SecondMenuAttribute)

		Private Sub Page_PreRender(sender As Object, e As EventArgs) Handles Me.PreRender
			'Me.PHead.Controls.Add(New LiteralControl(String.Format("<meta http-equiv='refresh' content='{0};url={1}'>", Session.Timeout * 60, "Default.aspx")))
		End Sub

		Private Shared Property LastPageVisited As String
			Get
				Dim history = DirectCast(HttpContext.Current.Cache("LastPageVisited_" & HttpContext.Current.Request.LogonUserIdentity.Name), List(Of String))

				If history Is Nothing OrElse history.Count < 2 Then
					Return Nothing
				End If

				Return history(history.Count - 1)
			End Get
			Set(value As String)

				Dim history = DirectCast(HttpContext.Current.Cache("LastPageVisited_" & HttpContext.Current.Request.LogonUserIdentity.Name), List(Of String))

				If history Is Nothing Then
					history = New List(Of String)()
					HttpContext.Current.Cache.Add("LastPageVisited_" & HttpContext.Current.Request.LogonUserIdentity.Name, history, Nothing, DateTime.Now.AddDays(1), Caching.Cache.NoSlidingExpiration, Caching.CacheItemPriority.High, Nothing)
				End If
				If history.Count > 2 Then
					history.RemoveAt(0)
				End If
				history.Add(value)
			End Set
		End Property

		Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load
			Try
				'NASCONDO IL DIV D'ERRORE.
				divErrore.Visible = False
				lblErrore.Text = String.Empty

				'IMPOSTO IL TITOLO DELLA PAGINA.
				Page.Title = PortalsTitles.OrderEntry

				versioneAssembly.Text = Assembly.GetExecutingAssembly.GetName.Version.ToString
				Dim oProperties = IPGlobalProperties.GetIPGlobalProperties()
				nomeHost.Text = String.Format("{0}.{1}", oProperties.HostName, oProperties.DomainName)


				If Me.Page.AppRelativeVirtualPath.EndsWith("Login.aspx") Then
					'ChangeLeftMenuVisibility(False)
				Else
					UserDataManager.GetUserData()
				End If

				Dim lastPage = LastPageVisited


				If SessionHandler.FromStampaOrdine = False Then
					'controllo che sia una chiamata Ajax
					If lastPage IsNot Nothing AndAlso
							Request.UrlReferrer IsNot Nothing AndAlso
							Request.Url.PathAndQuery <> Request.UrlReferrer.PathAndQuery AndAlso
							lastPage <> Request.UrlReferrer.PathAndQuery AndAlso
							lastPage <> Request.Url.PathAndQuery AndAlso
							Not Request.UrlReferrer.AbsoluteUri.Contains("OrderEntry") Then
						HttpContext.Current.Response.Redirect(lastPage, False)
						Return
					End If
				Else
					SessionHandler.FromStampaOrdine = False
				End If

				LastPageVisited = Request.Url.PathAndQuery

				If Not IsPostBack Then


					'
					' Popolo i dati all'interno del riquadro utente
					'
					PopolaInfoUtente()

					Dim index = Request.Url.PathAndQuery.IndexOf("Pages")

					If index > 0 Then

						Select Case Request.Url.PathAndQuery.Substring(index)

							Case "Pages/ListaPazientiRicoverati.aspx",
							  "Pages/ListaPazienti.aspx?mode=ricerca",
							  "Pages/PazientePerNosologico.aspx",
							  "Pages/ListaOrdini.aspx?mode=attiviUtente",
							  "Pages/ListaOrdini.aspx?mode=attiviRuolo",
							  "Pages/ListaOrdini.aspx?mode=evasi",
							  "Pages/ProfiliUtente.aspx",
							  "Pages/Home.aspx"

								Session("entryPage") = Request.Url.PathAndQuery
						End Select
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
							Dim oSess As New SessioneUtente(My.Settings.SAC_ConnectionString, Global_asax.ConnectionStringPortalUser, My.Settings.WsSac_User, My.Settings.WsSac_Password)
							oSess.SetUltimoAccesso(msUserIdentityName, PortalsNames.OrderEntry, Now(), cmbRuoliUtente.SelectedItem.Value)

							' SCRIVO ANCHE NELLA TABELLA LOGACCESSI, CON QUALE RUOLO L'UTENTE APRE LA SESSIONE
							Dim oPortalDataAdapterManager As PortalDataAdapterManager
							oPortalDataAdapterManager = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
							oPortalDataAdapterManager.TracciaAccessi(Me.Session("userName"), PortalsNames.OrderEntry, String.Format("Accesso effettuato il {0} alle ore {1}", Now.ToString("dd/MM/yyy"), Now.ToString("HH:mm:ss")), cmbRuoliUtente.SelectedValue)

						End If
					End If



					'Effettua il controllo del parametro ShowHeader nella query string e lo imposta nella session
					Utility.CheckShowHeaderParam(Request)

					'Imposto visibile o non visibile l'header in base a quanto voluto dall'utente tramite parametro "ShowHeader" nella querystring in precedenza
					Me.HeaderPlaceholder.Visible = SessionHandler.ShowHeader

					'IMPOSTO L'HEADER
					Dim sAppPath As String = Utility.GetApplicationPath()

					HeaderPlaceholder.Text = mDIPortalAdminUI.GetBootstrapHeader2(PortalsTitles.OrderEntry)
				End If

			Catch ex As Exception
				ExceptionsManager.TraceException(ex)
				Me.NavigateToErrorPage(Utility.ErrorCode.Exception, "Si è verificato un errore durante il caricamento della pagina!", False)
			End Try
		End Sub


		''' <summary>
		''' Comparison per KeyValuePair
		''' </summary>
		''' <remarks></remarks>
		Shared KeyValuePairComparison As Comparison(Of KeyValuePair(Of Integer, String)) = AddressOf ValueComparer

		''' <summary>
		''' comparatore sulla proprietà Value usato dal metodo List.Sort
		''' </summary>
		Private Shared Function ValueComparer(p1 As KeyValuePair(Of Integer, String), p2 As KeyValuePair(Of Integer, String)) As String
			Return p1.Value.CompareTo(p2.Value)
		End Function

		Public Shared Function GetUrlPazienteSac() As String

			Return My.Settings.PazienteSacUrl

		End Function


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
			Dim oPortalDataAdapterManager As PortalDataAdapterManager
			oPortalDataAdapterManager = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)

			Try
				oCombo = DirectCast(sender, UI.WebControls.DropDownList)
				'
				' Salvo in PortalUser.LogAccessi l'accesso con il ruolo corrente (lo utilizzerò per visualizzare le info di ultimo accesso)
				'
				oPortalDataAdapterManager.TracciaAccessi(Me.Session("userName"), PortalsNames.OrderEntry, String.Format("Accesso effettuato il {0} alle ore {1}", Now.ToString("dd/MM/yyy"), Now.ToString("HH:mm:ss")), oCombo.SelectedValue)
				'
				' Salvo nella tabella DatiUtente l'ultimo ruolo scelto dall'utente
				'
				oPortalDataAdapterManager.DatiUtenteSalvaValore(HttpContext.Current.User.Identity.Name.ToUpper, moRoleManagerUtility.DI_USER_RUOLO_CORRENTE_CODICE, oCombo.SelectedItem.Value)
				'
				' Scrivo la data di accesso corrente e il ruolo corrente: sarà quella letta alla prossima ripartenza della sessione
				'
				Dim oSess As New SessioneUtente(My.Settings.SAC_ConnectionString, Global_asax.ConnectionStringPortalUser, My.Settings.WsSac_User, My.Settings.WsSac_Password)
				oSess.SetUltimoAccesso(msUserIdentityName, PortalsNames.OrderEntry, DateTime.Now, oCombo.SelectedItem.Value)

				'
				'Cancello il token salvato in sessione
				'
				SessionHandler.Token = Nothing


				'
				' Quando cambio ruolo navigo alla pagina di Home a cui tutti hanno accesso.
				' Altrimenti si potrebbe verificare un errore se l'utente stava visualizzando una pagina che dopo 
				' il cambio di ruolo non deve più essere accessibile
				'
				GoToDefaultPage(False)

			Catch ex As Exception

				ExceptionsManager.TraceException(ex)
				oPortalDataAdapterManager.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)

			End Try

		End Sub

		Private Sub GoToDefaultPage(ByVal endResponse As Boolean)
			'
			' Imposto EndResponse=False per non generare ThreadAbortException
			'
			Response.Redirect(SessionHandler.EntryPointAccessoDiretto)
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
				Call Me.NavigateToErrorPage(Utility.ErrorCode.NoRights, "L'utente non ha nessun ruolo configurato! Contattare l'amministratore.", False)
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

		'Private Sub MenuMain2_PreRender(sender As Object, e As EventArgs) Handles MenuMain2.PreRender
		'	Try
		'		'CHIAMO LA FUNZIONE PER RIMUOVERE I NODI IN BASE AI RUOLI E IN BASE ALL'ATTRIBUTO HIDE.
		'		RimuovoNodi(CType(sender, Menu))
		'	Catch ex As Exception
		'		divErrore.Visible = True
		'		lblErrore.Text = "Si è verificato un errore durante il caricamento del menù."
		'		'TRACCIO L'ERRORE
		'		ExceptionsManager.TraceException(ex)
		'	End Try
		'End Sub

		'Private Sub MenuMain2_MenuItemDataBound(sender As Object, e As MenuEventArgs) Handles MenuMain2.MenuItemDataBound
		'	Try
		'		'
		'		'MEMORIZZO VALUEPATH CORRENTE = URL PAGINA NAVIGATA
		'		'ATTENZIONE: E.NODE.NAVIGATEURL PUÒ ESSERE MODIFICATO AGGIUNGENDO DEI PARAMETRI DURANTE LA NAVIGAZIONE
		'		'
		'		If String.Compare(Request.Url.AbsolutePath, e.Item.NavigateUrl.Split("?")(0), True) = 0 Then
		'			msTreeViewCurrentValePath = e.Item.ValuePath
		'		End If

		'		'
		'		'OTTENGO GLI ITEM CON ATTRIBUTO "HIDE" DEL SITEMAP
		'		'
		'		Dim sHideAttribute As String = e.Item.DataItem("hide")
		'		Dim hide As Boolean = False
		'		If Not String.IsNullOrEmpty(sHideAttribute) Then
		'			Boolean.TryParse(sHideAttribute, hide)
		'		End If
		'		'
		'		'ATTRIBUTO "ROLES" DEL SITEMAP
		'		'
		'		Dim oListRoles As System.Collections.IList = DirectCast(e.Item.DataItem, SiteMapNode).Roles
		'		'
		'		'AGGIUNGO ITEM PER LA DESCRIZIONE DEL MENU
		'		'
		'		mMyMenuLeft.Add(e.Item.ValuePath, New SecondMenuAttribute(hide, e.Item.NavigateUrl, oListRoles))
		'	Catch ex As Exception
		'		divErrore.Visible = True
		'		lblErrore.Text = "Si è verificato un errore durante il caricamento del menù."
		'		'TRACCIO L'ERRORE
		'		ExceptionsManager.TraceException(ex)
		'	End Try
		'End Sub
		Private Sub RimuovoNodi(ByVal oMenu As Menu)
			Try
				'
				'FUNZIONE CHIAMATA NELL'EVENTO "MENUMAIN2_MENUITEMDATABOUND".
				'FUNZIONE CHE SI OCCUPA DI RIMUOVERE GLI ITEM DELLA SITEMAP DEL MENU IN BASE ALL'ATTRIBUTO HIDE E ROLES.
				'
				If Not oMenu Is Nothing AndAlso oMenu.Items.Count > 0 Then
					'
					'ATTENZIONE: QUESTO DICTIONARY CONTIENE SOLO VALUEPATH(=KEY) RELATIVI AL TREE COMPOSTO NEL SITEMAP.
					'
					For Each sKey As String In mMyMenuLeft.Keys
						Dim oMenuLeftAttribute As SecondMenuAttribute = mMyMenuLeft(sKey)
						If oMenuLeftAttribute.Hide Then
							'
							'RIMOZIONE IN BASE ALL'ATTRIBUTO "HIDE".
							'SE HIDE = TRUE ALLORA RIMUOVO L'ITEM.
							'
							Dim oItem As MenuItem = oMenu.FindItem(sKey)
							If Not oItem Is Nothing Then
								oItem.Parent.ChildItems.Remove(oItem)
							End If
						Else
							'
							'RIMOZIONE DEL NODO VIA CODICE IN BASE AI RUOLI DELL'UTENTE.
							'
							If Not oMenuLeftAttribute.Roles Is Nothing AndAlso oMenuLeftAttribute.Roles.Count > 0 Then
								Dim bRemove As Boolean = True
								'
								'PER OGNI RUOLO ASSEGNATO ALL'ITEM CONTROLLO SE L'UTENTE E ISINROLE.
								'
								For Each sRole In oMenuLeftAttribute.Roles
									'SE L'UTENTE HA QUEL RUOLO ALLORA IMPOSTO BREMOVE = FALSE E NON RIMUOVO L'ITEM.
									If HttpContext.Current.User.IsInRole(sRole) Then
										bRemove = False
										Exit For
									End If
								Next
								If bRemove Then
									'OTTENGO IL RUOLO IN BASE ALL'PATH.
									Dim oItem As MenuItem = oMenu.FindItem(sKey)
									If Not oItem Is Nothing Then
										'RIMUOVO L'ITEM PERCHE' L'UTENTE NON POSSIEDE IL RUOLO INDICATO.
										oItem.Parent.ChildItems.Remove(oItem)
									End If
								End If
							End If
						End If
					Next
				End If
			Catch ex As Exception
				divErrore.Visible = True
				lblErrore.Text = "Si è verificato un errore durante il caricamento del menù."
				'TRACCIO L'ERRORE
				ExceptionsManager.TraceException(ex)
			End Try
		End Sub
		Sub NascondiPannelloUtente()
			Try
				divUtente.Visible = False
			Catch ex As Exception
				divErrore.Visible = True
				lblErrore.Text = "Si è verificato un errore durante il caricamento del menù."
				'TRACCIO L'ERRORE
				ExceptionsManager.TraceException(ex)
			End Try
		End Sub
	End Class



End Namespace