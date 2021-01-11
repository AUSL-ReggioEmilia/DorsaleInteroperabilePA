Imports DI.PortalUser
Imports DI.PortalUser.RoleManager

Public Class RoleManagerUtility
    '
    ' Queste sono gli attributi restituti nella lista degli accessi dell'utente
    '
    'Public Const SIS_ACCESSO_SPECIALE = "SIS_ACCESSO_SPECIALE"         'Accesso speciale al sistema erogante
    'Public Const UO_ACCESSO_SPECIALE = "UO_ACCESSO_SPECIALE"           'Accesso speciale all'unità operativa
    'Public Const UO_PAZ_VIEW = "UO@{0}@{1}@PAZ_VIEW"                   'Accesso ai pazienti della unità operativa {0}=codice OU, {1}=codice azienda
    Public Const UO_PAZ_VIEW = "UO@{0}@{1}"                             'Se ho come accesso il codice dell'unità operativa significa che ho accesso ai Pazienti della unità operativa {0}=codice OU, {1}=codice azienda
    'Public Const UO_REF_VIEW = "UO@{0}@{1}@REF_VIEW"                   'QUESTA NON HA SENSO: Accesso ai referti della unità operativa  {0}=codice OU, {1}=codice azienda
    Public Const ATTRIB_REF_VIEW_ALL = "ATTRIB@REF_VIEW_ALL"            'Vedo tutti i referti
    Public Const ATTRIB_REF_VIEW_OSC = "ATTRIB@REF_VIEW_OSC"            'Vedo tutti i referti oscurati
    Public Const ATTRIB_PAZ_VIEW_ALL = "ATTRIB@PAZ_VIEW_ALL"            'Vedo tutti i pazienti
    Public Const ATTRIB_ACC_DIR_ENABLED = "ATTRIB@ACCES_NEC_CLIN"       'Vedo pulsante "accesso diretto per necessità clinica urgente" LA COSTANTE DEVE ESSERE MAIUSCOLA!!!
    Public Const ATTRIB_REFERTI_INFERMIERI_VIEW = "ATTRIB@REF_INF_VIEW"          'Abilita alla visualizzazione del pulsante "RefertiInfermieri" LA COSTANTE DEVE ESSERE MAIUSCOLA!!!
    Public Const ATTRIB_CONSENSO_NEG_CHANGE = "ATTRIB@CONSENSO_NEG_CHANGE"  'Abilita alla modifica di un consenso esplicitamente negato LA COSTANTE DEVE ESSERE MAIUSCOLA!!!
    Public Const ATTRIB_UTE_TEC = "ATTRIB@UTE_TEC"                      'Definisce l'utente come Utente tecnico, tracciamento nascosto
    Public Const ATTRIB_UTE_ACC_TEC = "ATTRIB@UTE_ACC_TEC"              'Definisce l'utente come Utente con accesso tecnico con tracciamento standard
    Public Const SE_REF_VIEW = "SE@{0}@{1}"                             'Se ho accesso al sistema significa che ho accesso ai referti per azienda-sistema erogante per {0}=codice SE, {1}=codice azienda

	'
	' Opzioni per DI-USER (opzioni cross-applicazioni user)
	'
	Public Const DI_USER_RUOLO_CORRENTE_CODICE = "DI_USER_RUOLO_CORRENTE_CODICE"	'memorizza ultimo ruolo usato dall'utente


    ''' <summary>
    ''' Classe utilizzata per salvare in sessione i dati dell'utente
    ''' </summary>
    ''' <remarks></remarks>
    Private Class RoleManagerUserCurrentData
		Public Property Ruoli As Generic.List(Of RoleManager.Ruolo) = Nothing
        Public Property Sistemi As Generic.List(Of RoleManager.Sistema) = Nothing
        Public Property UnitaOperative As Generic.List(Of RoleManager.UnitaOperativa) = Nothing
        Public Property Accessi As Generic.List(Of String) = Nothing

		Public Sub New(ByVal Ruoli As Generic.List(Of RoleManager.Ruolo), ByVal Sistemi As Generic.List(Of RoleManager.Sistema), ByVal UnitaOperative As Generic.List(Of RoleManager.UnitaOperativa), ByVal Accessi As Generic.List(Of String))
			Me.Ruoli = Ruoli
			Me.Sistemi = Sistemi
			Me.UnitaOperative = UnitaOperative
			Me.Accessi = Accessi
		End Sub
	End Class

	Public Property RuoloCorrente As RoleManager.Ruolo
		Get
			Dim oRuolo As RoleManager.Ruolo = TryCast(ReadCache(RM_CURRENT_USER_ROLE), RoleManager.Ruolo)
			If oRuolo Is Nothing Then
				Return New RoleManager.Ruolo() With {.Codice = "@@NULL", .Descrizione = "@@NULL"}
			Else
				Return oRuolo
			End If
		End Get
		Set(value As RoleManager.Ruolo)
			WriteCache(RM_CURRENT_USER_ROLE, value, 0)
		End Set
	End Property


	'
	' Nome per individuare gli oggetti in cache che memorizzano il corrente contesto dell'utente 
	'
	Private Const RM_CURRENT_USER_CONTEXT As String = "RM_CURRENT_USER_CONTEXT"
	Private Const RM_CURRENT_USER_ROLE As String = "RM_CURRENT_USER_ROLE"
	

	Private msUserName As String
    Private msPortalUserConnectionString As String
    Private msSACConnectionString As String

    Public Sub New(PortalUserConnectionString As String, SACConnectionString As String)
        msUserName = HttpContext.Current.User.Identity.Name.ToUpper
        msPortalUserConnectionString = PortalUserConnectionString
        msSACConnectionString = SACConnectionString
    End Sub

	Public Sub InitializeUser()
		'
		' Questa funzione viene chiamata in un evento del global.asax in cui la Sessione non è ancora disponibile
		'
		Dim t0 As DateTime = Nothing
		Dim oUserCurrentData As RoleManagerUserCurrentData = Nothing
		Dim sCodiceRuoloCorrente As String = String.Empty
		Dim oPortalDataAdapterManager = New DI.PortalUser.Data.PortalDataAdapterManager(msPortalUserConnectionString)
		Try
			t0 = Now()
			oUserCurrentData = DirectCast(ReadCache(RM_CURRENT_USER_CONTEXT), RoleManagerUserCurrentData)
			' 
			' Leggo dal DiPortalUser il ruolo scritto nella key "DI_USER_RUOLO_CORRENTE_CODICE" -> sCodiceRuoloDiportal
			' Se diverso da quello memorizzato in oUserCurrentData.RuoloCorrente.Codice si ri-inizializza il contesto utente
			' Ovviamente quando l'utente cambia ruolo dalla pagina bisogna scrivere nella key OpzioniUtente.DI_USER_RUOLO_CORRENTE_CODICE
			'
			sCodiceRuoloCorrente = oPortalDataAdapterManager.DatiUtenteOttieniValore(msUserName, DI_USER_RUOLO_CORRENTE_CODICE, "")

#If TRACE Then
			Utility.TraceWriteLine(String.Format("ROLE MANAGER: Codice ruolo scelto dall'utente : {0}", sCodiceRuoloCorrente))
#End If
			'
			' Se oUserCurrentData è nothing devo ricalcolare tutto 
			' Se sCodiceRuoloCorrente  è cambiato rispetto quello memorizzato in oUserCurrentData.RuoloCorrente.Codice devo ricalcolare tutto 
			'
			If (oUserCurrentData Is Nothing) OrElse _
			   ((Not oUserCurrentData Is Nothing) AndAlso (Me.RuoloCorrente.Codice <> sCodiceRuoloCorrente)) Then
#If TRACE Then
				If oUserCurrentData Is Nothing Then
					Utility.TraceWriteLine("ROLE MANAGER: Il contesto utente È NOTHING: ricalcolo tutto!")
				ElseIf ((Not String.IsNullOrEmpty(sCodiceRuoloCorrente)) And Me.RuoloCorrente.Codice <> sCodiceRuoloCorrente) Then
					Utility.TraceWriteLine("ROLE MANAGER: L'utente ha modificato il ruolo: ricalcolo tutto!")
				End If
#End If
				'
				' Inizializzo il contesto utente
				'
				oUserCurrentData = InitializeUserContext(sCodiceRuoloCorrente)
				If Not oUserCurrentData Is Nothing Then
					'
					' Ri-inizializzo l'Identity utilizzando i dati in sessione
					'
					Call InitializeUserPrincipal(oUserCurrentData.Accessi)
					'
					' MODIFICA ETTORE 2015-06-18: Forzo il redirect alla pagina di default (che è visibile a tutti) direttamente dal global.asax
					' Altrimenti se utente era in un ruolo che poteva vedere pagina Pazienti.aspx e poi da altro portale si seleziona un ruolo che non può vedere Pazienti.aspx
					' il web server richiedeva l'autenticazione.
					' Di pagine Default.aspx ce ne è una sola
					'
					If Me.RuoloCorrente.Codice <> sCodiceRuoloCorrente Then
						'SCRIVO SU DB IL RUOLO ASSEGNATO 
						oPortalDataAdapterManager.DatiUtenteSalvaValore(msUserName, RoleManagerUtility.DI_USER_RUOLO_CORRENTE_CODICE, Me.RuoloCorrente.Codice)

						Dim sUrl As String = HttpContext.Current.Request.Url.AbsoluteUri
						If (Not sUrl.Contains("Default.aspx")) AndAlso (Not sUrl.Contains("AccessoDiretto")) AndAlso (Not sUrl.Contains("Referti/ApreReferto.aspx")) Then
							'
							' Se la pagina è già la default inutile fare redirect, se è una pagina di accesso diretto NON DEVO fare redirect a nulla
							'
							HttpContext.Current.Response.Redirect("~/Default.aspx", False)

						End If
					End If

				Else
#If TRACE Then
					Utility.TraceWriteLine("ROLE MANAGER: ERRORE: Il contesto utente È NOTHING dopo InitializeUserContext()")
#End If
				End If

			ElseIf Not oUserCurrentData Is Nothing Then
#If TRACE Then
				Utility.TraceWriteLine(String.Format("ROLE MANAGER: Ruolo scelto dall'utente: {0}", Me.RuoloCorrente.Descrizione))
#End If
				'
				' Ri-inizializzo l'Identity utilizzando i dati in sessione
				'
				Call InitializeUserPrincipal(oUserCurrentData.Accessi)
			End If
#If TRACE Then
			Utility.TraceWriteLine(String.Format("ROLE MANAGER: InitializeUser(): durata {0} ms", Now.Subtract(t0).TotalMilliseconds))
#End If
		Catch ex As Exception
			Throw New Exception(String.Format("Errore in InitializeUser() per l'utente {0}.", msUserName), ex)
		End Try
	End Sub

	''' <summary>
	''' Legge i Ruoli, Unità Operative, Sistemi, Accessi dal role manager + gruppi di AD
	''' </summary>
	''' <returns></returns>
	''' <remarks></remarks>
	Private Function InitializeUserContext(ByVal sRuoloCodiceScelto As String) As RoleManagerUserCurrentData
		'
		' Inizializzo la lista dei gruppi
		' e la lista degli accessi comprensiva dei gruppi di ActiveDirectory
		'
		Dim oUserCurrentData As RoleManagerUserCurrentData = Nothing
		Dim t0 As DateTime = Nothing
		Dim oRoleManagerDa As RoleManager.DataAccess = Nothing
		Dim oListRuoli As Generic.List(Of RoleManager.Ruolo) = Nothing
		Try
			t0 = Now()
            oRoleManagerDa = New RoleManager.DataAccess(msSACConnectionString, msPortalUserConnectionString)
			'
			' Per ricavare ultimo Ruolo utilizzato dall'utente
			'
			oListRuoli = oRoleManagerDa.RuoliOttieniPerUtente(msUserName)
			If Not oListRuoli Is Nothing AndAlso oListRuoli.Count > 0 Then
#If TRACE Then
				Utility.TraceWriteLine(String.Format("ROLE MANAGER: InitializeUserContext(): Numero di ruoli: {0}", oListRuoli.Count))
#End If
				Dim oListAccessi As Generic.List(Of String) = Nothing
				Dim oListUnitaOperative As Generic.List(Of RoleManager.UnitaOperativa) = Nothing
				Dim oListSistemi As Generic.List(Of RoleManager.Sistema) = Nothing

				Dim oRuoloCorrente As RoleManager.Ruolo = Nothing
				'
				' Ricavo il ruolo corrente in base al codice scelto
				'
				If Not String.IsNullOrEmpty(sRuoloCodiceScelto) Then
					oRuoloCorrente = oListRuoli.Find(Function(e) e.Codice = sRuoloCodiceScelto)
					If oRuoloCorrente Is Nothing Then
						oRuoloCorrente = oListRuoli.Item(0)
					End If
				Else
					oRuoloCorrente = oListRuoli.Item(0)
				End If
				'
				' A questo punto oRuoloCorrente è valorizzato
				'
#If TRACE Then
				Utility.TraceWriteLine(String.Format("ROLE MANAGER: InitializeUserContext(): Ruolo corrente {0}-{1}", oRuoloCorrente.Codice, oRuoloCorrente.Descrizione))
#End If
				'
				' Lista di accessi da Role Manager
				'
				oListAccessi = oRoleManagerDa.AccessiOttienePerCodiceRuolo(oRuoloCorrente.Codice)
#If TRACE Then
				If Not oListAccessi Is Nothing Then
					Utility.TraceWriteLine(String.Format("ROLE MANAGER: InitializeUserContext(): Numero di accessi: {0}", oListAccessi.Count))
				End If
#End If
				'
				' Aggiungo alla lista i gruppi di Active Directory
				'
				Dim oListWinGroup As Generic.List(Of String) = GetWindowsGroup()
				For Each sWinGroup As String In oListWinGroup
					If Not oListAccessi.Contains(sWinGroup) Then
						oListAccessi.Add(sWinGroup)
					End If
				Next
				'
				' Lista di Unita Operative
				'
				oListUnitaOperative = oRoleManagerDa.UnitaOperativeOttieniPerCodiceRuolo(oRuoloCorrente.Codice)
#If TRACE Then
				If Not oListUnitaOperative Is Nothing Then
					Utility.TraceWriteLine(String.Format("ROLE MANAGER: InitializeUserContext(): Numero di Unità Operative: {0}", oListUnitaOperative.Count))
				End If
#End If
				'
				' Lista dei Sistemi
				'
				oListSistemi = oRoleManagerDa.SistemiOttieniPerCodiceRuolo(oRuoloCorrente.Codice)
#If TRACE Then
				If Not oListSistemi Is Nothing Then
					Utility.TraceWriteLine(String.Format("ROLE MANAGER: InitializeUserContext(): Numero di Sistemi: {0}", oListSistemi.Count))
				End If
#End If
				' 
				' Creo classe da salvare nella Cache/Application
				'
				oUserCurrentData = New RoleManagerUserCurrentData(oListRuoli, oListSistemi, oListUnitaOperative, oListAccessi)
				Me.RuoloCorrente = oRuoloCorrente
				'
				' A questo punto salvo tutto nella CACHE
				'
				Call WriteCache(RM_CURRENT_USER_CONTEXT, oUserCurrentData)
			End If
#If TRACE Then
			Utility.TraceWriteLine(String.Format("ROLE MANAGER: InitializeUserContext(): durata {0} ms", Now.Subtract(t0).TotalMilliseconds))
#End If
			'
			' Restituisco
			'
			Return oUserCurrentData

		Catch ex As Exception
			Throw New Exception(String.Format("Errore in InitializeUserContext() per l'utente {0}.", msUserName), ex)
		End Try
		Return Nothing
	End Function

	''' <summary>
	''' Scrive nell'oggetto CACHE con durata 10 minuti
	''' </summary>
	''' <param name="sKey"></param>
	''' <param name="oValue"></param>
	''' <remarks></remarks>
	Private Sub WriteCache(ByVal sKey As String, ByVal oValue As Object)
		WriteCache(sKey, oValue, 10)
	End Sub

	Private Sub WriteCache(ByVal sKey As String, ByVal oValue As Object, iMinutiDurata As Integer)
		Dim oHttpContextCurrent = HttpContext.Current
		If iMinutiDurata = 0 Then
			oHttpContextCurrent.Cache.Insert(sKey & "_" & msUserName, oValue, Nothing, Caching.Cache.NoAbsoluteExpiration, New TimeSpan(0, 60, 0))
		Else
			oHttpContextCurrent.Cache.Insert(sKey & "_" & msUserName, oValue, Nothing, DateTime.UtcNow.AddMinutes(iMinutiDurata), Caching.Cache.NoSlidingExpiration, Caching.CacheItemPriority.Normal, Nothing)
		End If
	End Sub


	''' <summary>
	''' Legge dall'oggetto CACHE
	''' </summary>
	''' <param name="sKey"></param>
	''' <returns></returns>
	''' <remarks></remarks>
	Private Function ReadCache(ByVal sKey As String) As Object

		Return HttpContext.Current.Cache(sKey & "_" & msUserName)

	End Function


	''' <summary>
	''' Fornisce lista dei gruppi di active directory per l'utente corrente
	''' </summary>
	''' <returns></returns>
	''' <remarks></remarks>
	Private Function GetWindowsGroup() As Generic.List(Of String)
		Dim principalCurrent As System.Security.Principal.IPrincipal = HttpContext.Current.User
		Dim identityCurrent As System.Security.Principal.IIdentity = principalCurrent.Identity
		'
		' Ottengo i Principal e Identity specificidi Windows
		'
		Dim principalWinCurrent As System.Security.Principal.WindowsPrincipal = DirectCast(principalCurrent, System.Security.Principal.WindowsPrincipal)
		Dim identityWinCurrent As System.Security.Principal.WindowsIdentity = DirectCast(principalWinCurrent.Identity, System.Security.Principal.WindowsIdentity)
		'
		' Ruoli .NET correnti
		'
		Dim oListWinGroup As New Generic.List(Of String)
		For Each winGroup As System.Security.Principal.IdentityReference In identityWinCurrent.Groups
			'
			' Lookup nome del gruppo
			'
			Try
				Dim ntAccountGroup As System.Security.Principal.NTAccount = winGroup.Translate(GetType(System.Security.Principal.NTAccount))
				Dim sRoleName As String = ntAccountGroup.Value
				If Not oListWinGroup.Contains(sRoleName) Then
					oListWinGroup.Add(sRoleName)
				End If
			Catch ex As Exception
				If ShowError_TraslazioneGruppo(winGroup.Value) Then
					Dim sErrMsg As String = String.Format("Errore durante traslazione gruppo '{0}' di windows per l'utente '{1}'.", winGroup.Value, principalCurrent.Identity.Name)
#If TRACE Then
					Utility.TraceWriteLine("ROLE MANAGER: " & sErrMsg)
#End If
					'Logging.WriteWarning(sErrMsg & vbCrLf & ex.Message)
				End If
			End Try
		Next
		'
		' Verifico di avere traslato dei gruppi...
		'
		If oListWinGroup.Count = 0 Then
			Dim sErrMsg As String = String.Format("La lista dei gruppi windows è vuota per l'utente '{0}'.", principalCurrent.Identity.Name)
			Throw New Exception(sErrMsg)
		End If

		'
		' Restituisco la lista dei gruppi di AD
		'
		Return oListWinGroup

	End Function


	Private Function ShowError_TraslazioneGruppo(ByVal winGropValue As String) As Boolean
		Dim bRet As Boolean = True
		'
		' Verifico l'identificatore del gruppo
		'
		Dim oArray As String() = Split(winGropValue, "-")
		If oArray.Length > 2 Then 'Almeno lungo 3
			Select Case oArray(2) 'confronto il terzo elemento
				Case "18", "16", "15"
					bRet = False 'Non devo visualizzare l'errore
				Case Else
					bRet = True	'Devo visualizzare l'errore
			End Select
		End If
		'
		' Restituisco
		'
		Return bRet
	End Function

	''' <summary>
	''' Inizializzo il System.Security.Principal.IPrincipal con tutti i ruoli/accessi per l'utente corrente
	''' </summary>
	''' <param name="oListAccessi">Lista dei ruoli dell'utente</param>
	''' <remarks></remarks>
	Private Sub InitializeUserPrincipal(ByVal oListAccessi As Generic.List(Of String))
		Dim t0 As DateTime = Now()
		Dim principalCurrent As System.Security.Principal.IPrincipal = HttpContext.Current.User
		Dim identityCurrent As System.Security.Principal.IIdentity = principalCurrent.Identity
		'
		' Imposto il Principal con la lista di accessi
		'
		Dim oHttpContextCurrent = HttpContext.Current
		oHttpContextCurrent.User = New System.Security.Principal.GenericPrincipal(identityCurrent, oListAccessi.ToArray)
		Threading.Thread.CurrentPrincipal = oHttpContextCurrent.User
#If TRACE Then
		Utility.TraceWriteLine(String.Format("ROLE MANAGER: InitializeUserPrincipal(): durata {0} ms", Now.Subtract(t0).TotalMilliseconds))
#End If
	End Sub

	''' <summary>
	''' Restituisce la lista dei ruoli dell'utente
	''' </summary>
	''' <returns></returns>
	''' <remarks>Non ripopola la cache perchè è appena stato fatto nel global.asax</remarks>
	Public Function GetRuoli() As Generic.List(Of RoleManager.Ruolo)
		Dim oRoleManagerUserCurrentData As RoleManagerUserCurrentData = DirectCast(ReadCache(RM_CURRENT_USER_CONTEXT), RoleManagerUserCurrentData)
		If Not oRoleManagerUserCurrentData Is Nothing Then
			Return oRoleManagerUserCurrentData.Ruoli
		End If
		Return Nothing
	End Function

	''' <summary>
	''' Restituisce la lista delle unità operative dell'utente
	''' </summary>
	''' <returns></returns>
	''' <remarks>Non ripopola la cache perchè è appena stato fatto nel global.asax</remarks>
	Public Function GetUnitaOperative() As Generic.List(Of RoleManager.UnitaOperativa)
		Dim oRoleManagerUserCurrentData As RoleManagerUserCurrentData = DirectCast(ReadCache(RM_CURRENT_USER_CONTEXT), RoleManagerUserCurrentData)
		If Not oRoleManagerUserCurrentData Is Nothing Then
			Return oRoleManagerUserCurrentData.UnitaOperative
		End If
		Return Nothing
	End Function

End Class
