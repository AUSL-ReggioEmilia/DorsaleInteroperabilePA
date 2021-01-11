Imports System.Diagnostics
Imports System.Linq
Imports System.Web.Caching
Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports DI.OrderEntry.SacServices
Imports DI.OrderEntry.User
Imports DI.OrderEntry.User.CustomDataSourceDettaglioPaziente
Imports DI.PortalUser2
Imports DI.PortalUser2.Data
Imports Utility

Public Class UcDettaglioPaziente
	Inherits System.Web.UI.UserControl
#Region "Public Property"
	Const MAX_NUM_RECORD As Integer = 1000
	Public Shared ReadOnly Property Token As WcfDwhClinico.TokenType
		'
		' Ottiene il token da passare come parametro agli ObjectDataSource all'interno delle tab.
		' Utilizza la property CodiceRuolo per creare il token
		'
		Get
			Dim TokenViewState As WcfDwhClinico.TokenType = Tokens.GetToken(CodiceRuolo)

			Return TokenViewState
		End Get
	End Property
	Public Shared ReadOnly Property CodiceRuolo As String
		'
		' Salva nel ViewState il codice ruolo dell'utente
		' Utilizzata per creare il token da passare come parametro all'ObjectDataSource all'interno delle tab.
		'
		Get
			Dim sCodiceRuolo As String = String.Empty
			'
			' Prendo il ruolo dell'utente
			'
			Dim oRoleManagerUtility As New RoleManagerUtility2(Utility.GetAppSettings(Utility.PAR_DI_PORTAL_USER_CONNECTION_STRING, ""), My.Settings.SAC_ConnectionString, My.Settings.WsSac_User, My.Settings.WsSac_Password)
			Dim oRuoloCorrente As RoleManager.Ruolo = oRoleManagerUtility.RuoloCorrente
			'
			' Salvo in ViewState
			'
			sCodiceRuolo = oRuoloCorrente.Codice

			Return sCodiceRuolo
		End Get
	End Property
	Public Shared ReadOnly Property DescrizioneRuolo As String
		'
		' Salva nel ViewState la descrizione del ruolo dell'utente
		'
		Get
			Dim sDescrizioneRuolo As String = String.Empty
			'
			' Prendo il ruolo dell'utente
			'
			Dim oRoleManagerUtility As New RoleManagerUtility2(Utility.GetAppSettings(Utility.PAR_DI_PORTAL_USER_CONNECTION_STRING, ""), My.Settings.SAC_ConnectionString, My.Settings.WsSac_User, My.Settings.WsSac_Password)
			Dim oRuoloCorrente As RoleManager.Ruolo = oRoleManagerUtility.RuoloCorrente
			'
			' Salvo in ViewState
			'
			sDescrizioneRuolo = oRuoloCorrente.Descrizione

			Return sDescrizioneRuolo
		End Get
	End Property
	Public Property ExecuteQuery() As Boolean = False
	'    Get
	'        Return Me.ViewState("ExecuteQuery")
	'    End Get
	'    Set(ByVal value As Boolean)
	'        Me.ViewState.Add("ExecuteQuery", value)
	'    End Set
	'End Property
	Public Property ExecuteEsenzioniSelect() As Boolean = False
	'Get
	'	Return Me.ViewState("ExecuteEsenzioniSelect")
	'End Get
	'Set(ByVal value As Boolean)
	'	Me.ViewState.Add("ExecuteEsenzioniSelect", value)
	'End Set
	Public Property ExecuteRicoveriSelect() As Boolean = False
	'	Get
	'		Return Me.ViewState("ExecuteRicoveriSelect")
	'	End Get
	'	Set(ByVal value As Boolean)
	'		Me.ViewState.Add("ExecuteRicoveriSelect", value)
	'	End Set
	'End Property
	Public Property ExecuteRefertiSelect() As Boolean = False
	'	Get
	'		Return Me.ViewState("ExecuteRefertiSelect")
	'	End Get
	'	Set(ByVal value As Boolean)
	'		Me.ViewState.Add("ExecuteRefertiSelect", value)
	'	End Set
	'End Property
	Public Property IdPaziente() As String
		Get
			Return Me.ViewState("IdPaziente")
		End Get
		Set(ByVal value As String)
			Me.ViewState.Add("IdPaziente", value)
		End Set
	End Property
	Public Property Nosologico() As String
		Get
			Return Me.ViewState("Nosologico")
		End Get
		Set(ByVal value As String)
			Me.ViewState.Add("Nosologico", value)
		End Set
	End Property

#End Region

	Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
		Try
			'If Not Page.IsPostBack Then

			'End If
		Catch ex As Exception
			ExceptionsManager.TraceException(ex)
			Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
			portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
		End Try
	End Sub

#Region "Utilities&Generic"

	Public Shared Function GetNosologico2() As String
		Dim result As String = Nothing
		Try
			If Not (HttpContext.Current.Request("Nosologico") Is Nothing AndAlso HttpContext.Current.Request.QueryString("nosologico") Is Nothing) Then
				result = "<b>Episodio:</b>&nbsp" & (If(String.IsNullOrEmpty(HttpContext.Current.Request("Nosologico")), HttpContext.Current.Request.QueryString("nosologico"), HttpContext.Current.Request("Nosologico")))
			End If
		Catch ex As Exception
			ExceptionsManager.TraceException(ex)
			Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
			portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
		End Try
		Return result
	End Function
	Private Function GetDettaglioPazienteById(idPaziente As String) As WcfDwhClinico.PazienteType
		Dim oPazienti As WcfDwhClinico.PazienteType = Nothing

		Try
			If String.IsNullOrEmpty(idPaziente) Then
				Return Nothing
			End If

			Using oWcf As New WcfDwhClinico.ServiceClient
				Call Utility.SetWcfDwhClinicoCredential(oWcf)
				'
				' Chiamata al metodo che restituisce i dati
				'
				Dim oPazientiReturn As WcfDwhClinico.PazienteReturn = oWcf.PazienteOttieniPerId(Token, New Guid(idPaziente), True)
				If oPazientiReturn IsNot Nothing Then
					If oPazientiReturn.Errore IsNot Nothing Then
						Throw New CustomException(Of WcfDwhClinico.ErroreType)("Si è verificato un errore durante la lettura della lista pazienti.", oPazientiReturn.Errore)
					Else
						oPazienti = oPazientiReturn.Paziente
					End If
				End If
			End Using
			Return oPazienti
		Catch ex As CustomException(Of WcfDwhClinico.ErroreType)
			'
			' Eseguito solo se l'errore è restituito dalla chiamata al metodo del ws.
			'
			ExceptionsManager.TraceException(ex)
			Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
			portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)

			Return Nothing
		Catch ex As Exception
			ExceptionsManager.TraceException(ex)
			Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
			portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)

			Return Nothing
		End Try
	End Function
	Private Sub odsPazienteDettaglio_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsPazienteDettaglio.Selecting
		Try
			e.Cancel = Not Me.ExecuteQuery
			e.InputParameters("IdPaziente") = Me.IdPaziente
		Catch ex As Exception
			ExceptionsManager.TraceException(ex)
			Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
			portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
		End Try
	End Sub
	Protected Function GetAge2(dataNascita As Object) As String
		Try
			If dataNascita Is Nothing Then
				Return String.Empty
			End If
			If Not TypeOf dataNascita Is Date Then
				Return String.Empty
			End If

			'Dim compleanno = DateTime.Parse(dataNascita)
			Dim dtNascita = CType(dataNascita, Date)
			Dim oggi = DateTime.Today

			Dim anni As Integer = oggi.Year - dtNascita.Year
			If oggi.DayOfYear < dtNascita.DayOfYear Then anni -= 1

			If anni < 12 Then

				Dim mesi As Integer

				Dim annoScorso As DateTime = dtNascita.AddYears(anni)

				For i As Integer = 1 To 12

					If (annoScorso.AddMonths(i) = oggi) Then

						mesi = i
						Exit For

					ElseIf (annoScorso.AddMonths(i) >= oggi) Then

						mesi = i - 1
						Exit For
					End If
				Next

				Dim giorni As Integer = oggi.Subtract(annoScorso.AddMonths(mesi)).Days

				Dim anniString = If(anni = 1, "anno", "anni")
				Dim mesiString = If(mesi = 1, "mese", "mesi")
				Dim giorniString = If(giorni = 1, "giorno", "giorni")

				If anni >= 1 Then
					Return String.Format("({0} {1}, {2} {3}, {4} {5})", anni, anniString, mesi, mesiString, giorni, giorniString)
				Else
					If mesi >= 1 Then
						Return String.Format("({0} {1}, {2} {3})", mesi, mesiString, giorni, giorniString)
					Else
						Return String.Format("({0} {1})", giorni, giorniString)
					End If
				End If
			Else
				Return String.Format("({0} anni)", anni)
			End If
		Catch ex As Exception
			ExceptionsManager.TraceException(ex)
			Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
			portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
			Return Nothing
		End Try
	End Function
#End Region

#Region "Esenzioni"

	Public Sub SetLinkEsenzioniVisibility(idPaziente As String)
		Try
			If Not idPaziente Is Nothing Then
				Dim ds As New CustomDataSourceDettaglioPaziente.Paziente
				Dim dettaglio = ds.GetDataById(idPaziente.ToString)
				Dim hasEsenzioni = dettaglio.PazientiDettaglio2Esenzioni IsNot Nothing AndAlso dettaglio.PazientiDettaglio2Esenzioni.Count > 0
				If hasEsenzioni Then
					Me.FindControl("lnkLinkEsenzioni").Visible = True
				End If
			End If
		Catch ex As Exception
			ExceptionsManager.TraceException(ex)
			Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
			Dim errorText As String = PortalDataAdapterManager.FormatException(ex)
			portal.TracciaErrori("id Paziente: " & ID & Environment.NewLine & errorText, HttpContext.Current.User.Identity.Name, TraceEventType.Error, PortalsNames.OrderEntry)
		End Try
	End Sub
	Public Sub ShowEsenzioni()
		Try
			ExecuteEsenzioniSelect = True
			gvEsenzioni.DataBind()
			Dim functionJS As String = "$('#modalEsenzioni').modal('show');"
			ScriptManager.RegisterStartupScript(Page, Page.GetType, "LanchServerSide", functionJS, True)
		Catch ex As Exception
			ExceptionsManager.TraceException(ex)
			Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
			Dim errorText As String = PortalDataAdapterManager.FormatException(ex)
			portal.TracciaErrori("id Paziente: " & ID & Environment.NewLine & errorText, HttpContext.Current.User.Identity.Name, TraceEventType.Error, PortalsNames.OrderEntry)
		End Try
	End Sub
	Private Sub odsEsenzioni_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsEsenzioni.Selecting
		Try
			e.Cancel = Not Me.ExecuteEsenzioniSelect
			e.InputParameters("IdPaziente") = Me.IdPaziente
		Catch ex As Exception
			ExceptionsManager.TraceException(ex)
			Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
			Dim errorText As String = PortalDataAdapterManager.FormatException(ex)
			portal.TracciaErrori("id Paziente: " & ID & Environment.NewLine & errorText, HttpContext.Current.User.Identity.Name, TraceEventType.Error, PortalsNames.OrderEntry)
		End Try
	End Sub
#End Region

#Region "Referti"
	Private Sub odsReferti_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsReferti.Selecting
		Try
			e.Cancel = Not Me.ExecuteRefertiSelect
			e.InputParameters("IdPaziente") = Me.IdPaziente
		Catch ex As Exception
			ExceptionsManager.TraceException(ex)
			Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
			Dim errorText As String = PortalDataAdapterManager.FormatException(ex)
			portal.TracciaErrori("id Paziente: " & ID & Environment.NewLine & errorText, HttpContext.Current.User.Identity.Name, TraceEventType.Error, PortalsNames.OrderEntry)
		End Try
	End Sub
	Public Sub SetLinkRefertiVisibility(idPaziente As String)
		'
		' OTTIENE L'ICONA PER VISUALIZZARE I REFERTI DEL PAZIENTE PRESENTE NELLA TESTATA DEL PAZIENTE 
		'
		Try
			Dim periodoReferto As TipoReferti
			Dim imgReferti As HtmlControls.HtmlImage = CType(fvPaziente.FindControl("imgReferti"), HtmlControls.HtmlImage)
			Dim linkbutton As LinkButton = CType(fvPaziente.FindControl("lnkReferti"), LinkButton)
			Dim ds As New CustomDataSourceDettaglioPaziente
			periodoReferto = ds.GetPeriodoUltimoReferto(idPaziente)
			Select Case periodoReferto
				Case TipoReferti.GiornoCorrente
					linkbutton.Visible = True
					imgReferti.Attributes.Item("src") = VirtualPathUtility.ToAbsolute("~/Images/PresenzaReferti1.gif")
				Case TipoReferti.UltimaSettimana
					linkbutton.Visible = True
					imgReferti.Attributes.Item("src") = VirtualPathUtility.ToAbsolute("~/Images/PresenzaReferti7.gif")
				Case TipoReferti.UltimoMese
					linkbutton.Visible = True
					imgReferti.Attributes.Item("src") = VirtualPathUtility.ToAbsolute("~/Images/PresenzaReferti30.gif")
			End Select
		Catch ex As Exception
			ExceptionsManager.TraceException(ex)
			Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
			portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
		End Try
	End Sub
	Public Function GetIconStatoRichiesta(statoRichiesta As Integer) As String
		Dim resultIcon As String = String.Empty
		Try
			Select Case statoRichiesta
				Case 0
					resultIcon = "~/Images/stato_referto_incorso.gif"
				Case 1
					resultIcon = "~/Images/stato_referto_completato.gif"
			End Select
		Catch ex As Exception
			ExceptionsManager.TraceException(ex)
			Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
			portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
		End Try
		Return resultIcon
	End Function
	Public Function GetLinkReferto(IdReferto As String) As String
		Dim resultUrl As String = String.Empty
		Try
			resultUrl = My.Settings.DwhUrlReferto & IdReferto
		Catch ex As Exception
			ExceptionsManager.TraceException(ex)
			Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
			portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
		End Try
		Return resultUrl
	End Function
	Public Function GetUrlTuttiReferti() As String
		Dim resultUrl As String = String.Empty
		Try
			resultUrl = My.Settings.DwhUrlReferti & Me.IdPaziente
		Catch ex As Exception
			ExceptionsManager.TraceException(ex)
			Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
			portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
		End Try
		Return resultUrl
	End Function
	Public Sub ShowReferti()
		Try
			ExecuteRefertiSelect = True
			gvReferti.DataBind()
			Dim functionJS As String = "$('#modalReferti').modal('show');"
			ScriptManager.RegisterStartupScript(Page, Page.GetType, "LanchServerSide", functionJS, True)
		Catch ex As Exception
			ExceptionsManager.TraceException(ex)
			Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
			Dim errorText As String = PortalDataAdapterManager.FormatException(ex)
			portal.TracciaErrori("id Paziente: " & ID & Environment.NewLine & errorText, HttpContext.Current.User.Identity.Name, TraceEventType.Error, PortalsNames.OrderEntry)
		End Try
	End Sub
#End Region

#Region "Ricoveri"
	Public Function GetElement() As String
		'
		' Ottiene il link contente l'icona di stato dell'episodio mostrata nella testa del paziente.
		'
		Dim resultElement As String = String.Empty
		Try
			Dim dettaglioPaziente As WcfDwhClinico.PazienteType = Nothing
			If HttpContext.Current.Cache("DettaglioPazienteWs3" & IdPaziente) IsNot Nothing Then
				'
				' Controllo se l'ultimo referto del paziente è in cache.
				'
				dettaglioPaziente = HttpContext.Current.Cache("DettaglioPazienteWs3" & IdPaziente)
			Else
				dettaglioPaziente = GetDettaglioPazienteById(IdPaziente)
				HttpContext.Current.Cache.Add("DettaglioPazienteWs3" & IdPaziente, dettaglioPaziente, Nothing, Now.AddMinutes(5), Cache.NoSlidingExpiration, CacheItemPriority.Low, Nothing)
			End If
			If dettaglioPaziente.Episodio.AziendaErogante IsNot Nothing Then
				Dim aziendaerogante As String = dettaglioPaziente.Episodio.AziendaErogante
				If Not dettaglioPaziente Is Nothing Then
					Dim imageUrl As String = GetSimboloTipoEpisodioRicovero(dettaglioPaziente)
					If String.IsNullOrEmpty(imageUrl) Then
						resultElement = String.Empty
					Else
						If Not (String.IsNullOrEmpty(Me.Nosologico)) Then
							Dim linkbutton As LinkButton = CType(fvPaziente.FindControl("lnkRicoveri"), LinkButton)
							linkbutton.Visible = True
							resultElement = imageUrl
						End If
					End If
				End If
			End If
		Catch ex As Exception
			ExceptionsManager.TraceException(ex)
			Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
			portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
		End Try
		Return resultElement
	End Function
	Private Function GetSimboloTipoEpisodioRicovero(dettaglioPaziente As WcfDwhClinico.PazienteType) As String
		'
		' Ottiene l'Image dell'episodio da mostrare nella testata del paziente
		'
		Dim strHtml As String = String.Empty
		If Not dettaglioPaziente Is Nothing AndAlso Not dettaglioPaziente.Episodio Is Nothing Then
			If Not dettaglioPaziente.Episodio.TipoEpisodio Is Nothing AndAlso String.Compare(dettaglioPaziente.Episodio.Categoria, "Ricovero", True) = 0 Then
				Dim sTipoEpisodioRicovero As String = CType(dettaglioPaziente.Episodio.TipoEpisodio.Codice, String).ToUpper
				If Not String.IsNullOrEmpty(sTipoEpisodioRicovero) AndAlso Not dettaglioPaziente.ConsensoAziendale Is Nothing AndAlso Not String.IsNullOrEmpty(dettaglioPaziente.ConsensoAziendale.Codice) Then
					Dim eConsenso As ConsensoMinimoAccordato = CType(dettaglioPaziente.ConsensoAziendale.Codice, ConsensoMinimoAccordato)
					'
					' visualizzo l'icona del ricovero solo se il consenso minimo accordato è il DossierStorico
					'
					If eConsenso = ConsensoMinimoAccordato.DossierStorico Then
						'
						' Creo il testo contenente le informazioni sul ricovero
						'
						Dim sTooltip As String = String.Empty
						If Not dettaglioPaziente.Episodio.DataConclusione.HasValue AndAlso dettaglioPaziente.Episodio.StrutturaConclusione Is Nothing Then
							'
							' Solo se il ricovero è ancora in corso e quindi solo se la DataConclusione e la StrutturaConclusione sono nothing
							'
							If dettaglioPaziente.Episodio.DataApertura.HasValue AndAlso Not dettaglioPaziente.Episodio.StrutturaUltimoEvento Is Nothing Then
								If dettaglioPaziente.Episodio.DataUltimoEvento.HasValue Then
									sTooltip = String.Format("Ricoverato nel reparto {0} dal {1:d}", dettaglioPaziente.Episodio.StrutturaUltimoEvento.Descrizione, dettaglioPaziente.Episodio.DataUltimoEvento.Value)
								Else
									sTooltip = String.Format("Ricoverato nel reparto {0}", dettaglioPaziente.Episodio.StrutturaUltimoEvento.Descrizione)
								End If
							End If
						Else
							'
							' Solo se il ricovero è concluso e quindi solo se la DataConclusione e la StrutturaConclusione non sono nothing
							'
							If dettaglioPaziente.Episodio.DataConclusione.HasValue Then
								sTooltip = String.Format("Dimesso dal reparto {0} il {1:d}", dettaglioPaziente.Episodio.StrutturaConclusione.Descrizione, dettaglioPaziente.Episodio.DataConclusione.Value)
							Else
								sTooltip = String.Format("Dimesso dal reparto {0}", dettaglioPaziente.Episodio.StrutturaConclusione.Descrizione)
							End If
						End If

						'
						' genero il codice html legato all'icona del ricovero.
						' genera anche un tooltip bootstrap che contiene le informazioni sul ricovero
						'
						strHtml = GetHtmlImgTipoEpisodioRicovero(sTipoEpisodioRicovero, sTooltip)
					End If
				End If
			End If
		End If
		Return strHtml
	End Function
	Private Function GetHtmlImgTipoEpisodioRicovero(ByVal sTipoEpisodioRicovero As String, sTooltip As String) As String
		'
		' Crea il codice html per l'immagine legata al tipo di ricovero
		' gli viene passato il testo contenente le informazioni sul ricovero che verrà visualizzato come tooltip bootstrap
		'
		Dim strHtml As String = String.Empty
		Select Case sTipoEpisodioRicovero.ToUpper
			Case "O" 'Ricovero Ordinario
				strHtml = "<img src='" & VirtualPathUtility.ToAbsolute("~/images/RicoveroOrdinario.gif") & "' data-toggle='tooltip' data-placement='top' title='" & sTooltip & "' > "
			Case "D" 'Day Hospital
				strHtml = "<img src='" & VirtualPathUtility.ToAbsolute("~/images/RicoveroDH.gif") & "' data-toggle='tooltip' data-placement='top' title='" & sTooltip & "'>"
			Case "S" 'Day Service
				strHtml = "<img src='" & VirtualPathUtility.ToAbsolute("~/images/RicoveroDS.gif") & "' data-toggle='tooltip' data-placement='top' title='" & sTooltip & "'>"
			Case "P" 'Pronto Soccorso
				strHtml = "<img src='" & VirtualPathUtility.ToAbsolute("~/images/RicoveroPS.gif") & "' data-toggle='tooltip' data-placement='top' title='" & sTooltip & "'>"
				'Case "B" 'OBI
				'    strHtml = "<img src='" & VirtualPathUtility.ToAbsolute("~/images/RicoveroOBI.gif") & "' data-toggle='tooltip' data-placement='top' title='" & sTooltip & "'>"
		End Select
		Return strHtml
	End Function
	Public Sub ShowRicovero()
		Try
			Dim resultElement As String = String.Empty
			Dim azerogante As String = String.Empty

			Dim dettaglioPaziente As WcfDwhClinico.PazienteType = Nothing
			If HttpContext.Current.Cache("DettaglioPazienteWs3" & IdPaziente) IsNot Nothing Then
				'
				' Controllo se l'ultimo referto del paziente è in cache.
				'
				dettaglioPaziente = HttpContext.Current.Cache("DettaglioPazienteWs3" & IdPaziente)
			Else
				dettaglioPaziente = GetDettaglioPazienteById(IdPaziente)
				HttpContext.Current.Cache.Add("DettaglioPazienteWs3" & IdPaziente, dettaglioPaziente, Nothing, Now.AddMinutes(5), Cache.NoSlidingExpiration, CacheItemPriority.Low, Nothing)
			End If
			If Not dettaglioPaziente Is Nothing Then
				azerogante = dettaglioPaziente.Episodio.AziendaErogante
			End If
			odsRicoveri.SelectParameters("nosologico").DefaultValue = Me.Nosologico
			odsRicoveri.SelectParameters("idPaziente").DefaultValue = Me.IdPaziente
			odsRicoveri.SelectParameters("aziendaErogante").DefaultValue = azerogante
			ExecuteRicoveriSelect = True
			gvRicoveri.DataBind()
			Dim functionJS As String = "$('#modalRicoveri').modal('show');"
			ScriptManager.RegisterStartupScript(Page, Page.GetType, "LanchServerSide", functionJS, True)
		Catch ex As Exception
			ExceptionsManager.TraceException(ex)
			Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
			portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
		End Try
	End Sub
	Public Function GetUrlTuttiRicoveri() As String
		Dim resultUrl As String = String.Empty
		Try
			resultUrl = My.Settings.DwhUrlEpisodi & Me.IdPaziente
		Catch ex As Exception
			ExceptionsManager.TraceException(ex)
			Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
			portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
		End Try
		Return resultUrl
	End Function

	Private Sub odsRicoveri_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsRicoveri.Selecting
		Try
			e.Cancel = Not Me.ExecuteRicoveriSelect
		Catch ex As Exception
			ExceptionsManager.TraceException(ex)
			Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
			Dim errorText As String = PortalDataAdapterManager.FormatException(ex)
			portal.TracciaErrori("id Paziente: " & ID & Environment.NewLine & errorText, HttpContext.Current.User.Identity.Name, TraceEventType.Error, PortalsNames.OrderEntry)
		End Try
	End Sub

	Private Sub odsPazienteDettaglio_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsPazienteDettaglio.Selected
		Try
			SetLinkEsenzioniVisibility(Me.IdPaziente)
			SetLinkRefertiVisibility(Me.IdPaziente)
			'SetLinkRicoveriVisibility(Me.IdPaziente)
		Catch ex As Exception
			ExceptionsManager.TraceException(ex)
			Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
			portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
		End Try
	End Sub
#End Region
End Class