Imports System.Web.HttpContext
Imports System.Xml
Imports System.Xml.Serialization
Imports DwhClinico.Data
Imports System.Net
Imports System.ServiceModel
Imports DI.PortalUser2.Data

Public Class Utility
	''' <summary>
	''' Definisce dei codici che rappresentano i vari tipi di errore gestiti nelle pagine ErroPage.aspx per accesso standard e accesso diretto
	''' </summary>
	''' <remarks></remarks>
	Public Enum ErrorCode
		Unknow
		AccessDenied
		NoRights
		MissingResource
		Exception
	End Enum

#Region "Costanti Pubblice"
	'
	' Costanti pubbliche
	'
	Public Const PAR_ID_PAZIENTE As String = "IdPaziente"
	Public Const PAR_ID_REFERTO As String = "IdReferto"
	Public Const PAR_ID_RICOVERO As String = "IdRicovero"
	Public Const PAR_ID_ALLEGATO As String = "IdAllegato"
	Public Const PAR_ID_ESTERNO_ALLEGATO As String = "IdEsternoAllegato"
	Public Const PAR_ID_ESTERNO As String = "IdEsterno"
	Public Const PAR_NOME As String = "Nome"
	Public Const PAR_COGNOME As String = "Cognome"
	Public Const PAR_CODICE_SANITARIO As String = "CodiceSanitario"
	Public Const PAR_CODICE_FISCALE As String = "CodiceFiscale"
	Public Const PAR_DATA_NASCITA As String = "DataNascita"
	Public Const PAR_DALLA_DATA As String = "DallaData"
	Public Const PAR_SISTEMA_EROGANTE As String = "SistemaErogante"
	Public Const PAR_REPARTO_EROGANTE As String = "RepartoErogante"
	Public Const PAR_REPARTO_RICHIEDENTE As String = "RepartoRichiedente"
	Public Const PAR_REPARTO_RICOVERO As String = "RepartoRicovero" 'ha il medesimo significato di PAR_REPARTO_RICHIEDENTE
	Public Const PAR_NOME_ANAGRAFICA As String = "NomeAnagrafica"
	Public Const PAR_ID_ANAGRAFICA As String = "IdAnagrafica"
	Public Const PAR_NUMERO_NOSOLOGICO As String = "NumeroNosologico"
	Public Const PAR_NUMERO_PRENOTAZIONE As String = "NumeroPrenotazione"
	Public Const PAR_ID_ORDER_ENTRY As String = "IdOrderEntry"
	Public Const PAR_AZIENDA_EROGANTE As String = "AziendaErogante"
	Public Const PAR_URL As String = "Url"
	Public Const PAR_NAVBAR As String = "NavBar"
	Public Const PAR_CODE_URL As String = "CodeUrl"
	Public Const PAR_ID_DOC As String = "IdDoc"
	Public Const PAR_DOC_TABLE As String = "DocTable"
	Public Const PAR_URL_TO_RENDER As String = "UrlToRender"
	Public Const PAR_PRINTER_SERVER_NAME As String = "PrinterServerName"
	Public Const PAR_PRINTER_NAME As String = "PrinterName"
	Public Const PAR_ENTRY_POINT As String = "EntryPoint"

	'
	' Stringa di connessione al portale utente della DI
	'
	Public Const PAR_DI_PORTAL_USER_CONNECTION_STRING As String = "DiPortalUser.ConnectionString"
	Public Const SESS_ACCESSO_DIRETTO As String = "accesso_diretto"
	Public Const SESS_INVALIDA_CACHE_LISTA_REFERTI As String = "InvalidaCacheListaReferti"
	Public Const SESS_INVALIDA_CACHE_LISTA_PAZIENTI As String = "InvalidaCacheListaPazienti"
	Public Const SESS_INVALIDA_CACHE_LISTA_RICOVERI As String = "InvalidaCacheListaRicoveri"
	Public Const SESS_DATI_ULTIMO_ACCESSO As String = "ULTIMO_ACCESSO-AA01EDD6-9AAF-437A-BFAB-C7EACCC23FAC" 'usata per visualizzare i dati di ultimo accesso nel box delle info utente
	Public Const SESS_AUTORIZZATORE_CONSENSO_MINORE As String = "AutorizzatoreConsensoDelMinore-39454FCD-12F6-457E-8FDE-DD69811CA807"  'usata per visualizzare i dati di ultimo accesso nel box delle info utente
	Public Const FLD_ID_REFERTO As String = "@Id_Referto"
	Public Const PAR_COMANDO As String = "Comando"
	Public Const CODICE_FISCALE_NULLO As String = "0000000000000000"

	'
	' I possibili tipi di Prescrizioni/Impegnative
	'
	Public Const TIPO_PRESCRIZIONE_SPECIALISTICA As String = "Specialistica"
	Public Const TIPO_PRESCRIZIONE_FARMACEUTICA As String = "Farmaceutica"

	Private Const SESS_HOST_NAME As String = "-HOST_NAME-"

	Public Const MSG_MAX_NUM_RECORD As String = "La ricerca ha restituito il numero massimo di risultati, affinare il criterio di ricerca!"


	'
	' Per importazione delle visualizzazioni all'interno del DWH
	'
	Public Enum DettaglioReferto_TipoVisualizzaione
		Unknow = -1
		InternaWs2 = 1
		Esterna = 2
		PDF = 3
		InternaWs3 = 4
	End Enum


#End Region

    ''' <summary>
    ''' Effettua il controllo del parametro "ShowHeader" nella querystring e lo imposta come parametro di sessione
    ''' </summary>
    ''' <param name="Request"></param>
    Public Shared Sub CheckShowHeaderParam(ByRef Request As HttpRequest)
        Dim showHeader As String = Request.QueryString("ShowHeader")

        If Not String.IsNullOrEmpty(showHeader) Then
            Dim bShowHeader As Boolean = True
            If Boolean.TryParse(showHeader, bShowHeader) Then
                SessionHandler.ShowHeader = showHeader
            End If
        End If
    End Sub

    ''' <summary>
    ''' Mostra il Testo passato nella Label e la rende visibile
    ''' </summary>
    ''' <param name="Label">Label da mostrare</param>
    ''' <param name="Text">Testo da visualizzare</param>
    ''' <remarks></remarks>
    Public Shared Sub ShowErrorLabel(Label As UI.WebControls.Label, Text As String)

		Label.Text = Text
		If Text.Length > 0 Then
			Label.Visible = True
			Label.Style.Add("display", "block")
		End If

	End Sub

	''' <summary>
	''' Conversione da Url relativo a url assoluto
	''' </summary>
	''' <param name="relativeUrl"></param>
	''' <returns></returns>
	''' <remarks></remarks>
	Public Shared Function ConvertRelativeUrlToAbsoluteUrl(ByVal relativeUrl As String) As String
		Dim sRet As String = ""
		Dim sPort As String = HttpContext.Current.Request.Url.Port
		If Not String.IsNullOrEmpty(sPort) Then sPort = ":" & sPort
		If (HttpContext.Current.Request.IsSecureConnection) Then
			sRet = String.Format("{0}://{1}{2}{3}", Uri.UriSchemeHttps, HttpContext.Current.Request.Url.Host, sPort, relativeUrl)
		Else
			sRet = String.Format("{0}://{1}{2}{3}", Uri.UriSchemeHttp, HttpContext.Current.Request.Url.Host, sPort, relativeUrl)
		End If
		Return sRet
	End Function

	Public Shared Function GetCurrentUser() As CurrentUser
		'
		' Ritorna l'utente corrente (senza il dominio)
		'
		Dim strUsername As String
		Dim typeCurrentUser As CurrentUser

		If HttpContext.Current.User.Identity.IsAuthenticated Then
			strUsername = HttpContext.Current.User.Identity.Name
		Else
			'
			' Anonimo
			'
			strUsername = "ASPNET"
		End If
		'
		' Separo il dominio dal nome
		'
		Dim nPos As Integer = strUsername.IndexOf("\"c)
		If nPos > 0 Then
			typeCurrentUser.UserName = strUsername.Substring(nPos + 1)
			typeCurrentUser.DomainName = strUsername.Substring(0, nPos)
		Else
			typeCurrentUser.UserName = strUsername
			typeCurrentUser.DomainName = ""
		End If

		typeCurrentUser.HostName = GetUserHostName()    'questa restituisce il nome e se non riesce l'indirizzo IP
		typeCurrentUser.HostAddress = HttpContext.Current.Request.UserHostAddress

		Return typeCurrentUser
	End Function

	Public Shared Function GetUserHostName() As String
		Dim sHostName As String = Nothing

		'
		' Controllo se l'host name è in sessione.
		' Se non c'è ottengo l'host name con la funzione "_GetUserHostName()" e poi la salvo in sessione
		' Altrimenti restituisco la variabile di sessione
		'
		If HttpContext.Current.Session(SESS_HOST_NAME) Is Nothing Then
			sHostName = _GetUserHostName()
			HttpContext.Current.Session(SESS_HOST_NAME) = sHostName
		Else
			sHostName = CType(HttpContext.Current.Session(SESS_HOST_NAME), String)
		End If
		Return sHostName

	End Function

	Private Shared Function _GetUserHostName() As String
		Dim oNetIp As System.Net.IPHostEntry = Nothing
		Dim sRemoteAddr As String = HttpContext.Current.Request.ServerVariables("HTTP_X_FORWARDED_FOR")

		'
		' Controllo se sRemoteAddr è vuota. Se è vuota allora uso la ServerVariabiles "remote_addr"
		'
		If String.IsNullOrEmpty(sRemoteAddr) Then
			sRemoteAddr = HttpContext.Current.Request.ServerVariables("remote_addr")
		End If

		Try
			oNetIp = System.Net.Dns.GetHostEntry(sRemoteAddr)
		Catch ex As Exception
			'Restituisco l'indirizzo IP
			Return sRemoteAddr
		End Try

		Dim sHostName As String = sRemoteAddr
		Try
			sHostName = oNetIp.HostName
		Catch ex As Exception
			'Se errore restituisco comunque indirizzo IP 
		End Try

		Return sHostName

	End Function

	Public Shared Function GetUserHostIP() As String
		Return HttpContext.Current.Request.UserHostName 'questa restituisce indirizzo IP
	End Function

	Public Shared Function GetAppSettings(ByVal Setting As String, ByVal DefaultValue As String) As String
		'
		' Ritorna la configurazione
		'
		Try
			Dim sRet As String = ConfigurationManager.AppSettings(Setting)
			If sRet Is Nothing Then
				'
				' Se non c'è il default
				'
				Return DefaultValue
			Else
				Return sRet
			End If
		Catch ex As Exception
			Return DefaultValue
		End Try
	End Function

	Public Shared Function CheckPermission(ByVal sRole As String) As Boolean
		If Not sRole Is Nothing AndAlso sRole.Length > 0 Then
			Return System.Web.HttpContext.Current.User.IsInRole(sRole)
		End If
		Return False
	End Function

	''' <summary>
	''' MODIFICA ETTORE 2015-06-05: I permessi di cancellazione dipendono solo dall'appartenenza aad un ruolo configurato nel web.config
	''' </summary>
	''' <returns></returns>
	''' <remarks></remarks>
	Public Shared Function VerificaPermessiCancellazionePaziente() As Boolean
		'
		' Verifica se l'utente corrente possiede i permessi di cancellazione
		'
		Return CheckPermission(My.Settings.Role_Delete)
	End Function


	''' <summary>
	''' Serve a limitare i parametri di filtro delle query in base ad una eventuale data minima
	''' </summary>
	''' <param name="dDataInput"></param>
	''' <param name="oDataMinimaPossibile"></param>
	''' <returns></returns>
	''' <remarks></remarks>
	Public Shared Function LimitaDataByDataMinima(ByVal dDataInput As Nullable(Of Date), ByVal oDataMinimaPossibile As Nullable(Of Date)) As Nullable(Of Date)
		'
		' Se la oDataMinimaPossibile <> nothing allora c'è una data minima da applicare
		'
		'
		Dim dDataRet As Nullable(Of Date) = Nothing

		If dDataInput = #12:00:00 AM# Then dDataInput = Nothing
		If oDataMinimaPossibile = #12:00:00 AM# Then oDataMinimaPossibile = Nothing

		If oDataMinimaPossibile.HasValue Then
			If (Not dDataInput.HasValue) Then
				' dDataInput NON E' VALORIZATO -> significa NULL per cui si vedrebbero tutti gli oggetti
				' quindi imposto la data minima
				dDataRet = oDataMinimaPossibile
			Else
				'
				' Il parametro dDataInput è valorizzato: controllo che non sia minore della data minima
				'
				If dDataInput < oDataMinimaPossibile Then
					dDataRet = oDataMinimaPossibile
				Else
					dDataRet = dDataInput
				End If
			End If
		End If
		'
		'
		'
		Return dDataRet
	End Function

	''' <summary>
	''' Funzione da utilizzare quando un utente è infermiere per limitare i dati restituiti dalla lista referti
	''' </summary>
	''' <param name="dDataInput"></param>
	''' <returns></returns>
	''' <remarks></remarks>
	Public Shared Function LimitaDataPerInfermieri(ByVal dDataInput As Date) As Date
		'
		' Gli infermieri vedono solo i rferti degli ultimi N giorni
		'
		Dim iUltimiNGiorni As Integer = 90
		'
		' Imposto una data minima per gli infermieri
		'
		Dim dDataMinimaPerInfermieri As DateTime = Now.Date.AddDays(-iUltimiNGiorni)
		If dDataInput = Nothing Then
			dDataInput = dDataMinimaPerInfermieri
		ElseIf dDataInput <= dDataMinimaPerInfermieri Then
			dDataInput = dDataMinimaPerInfermieri
		ElseIf dDataInput > dDataMinimaPerInfermieri Then
			'Lascio il valore corrente della data di input
			'L'infermiere potrà editare la data
		End If
		Return dDataInput
	End Function

	Public Shared Function FormatException(ByVal exception As Exception) As String
		If exception Is Nothing Then
			Throw New ArgumentNullException("exception")
		End If
		Dim result As New System.Text.StringBuilder()
		Dim currentException As Exception = exception

		While exception IsNot Nothing
			result.AppendLine(exception.Message)
			result.AppendLine(exception.StackTrace)
			exception = exception.InnerException
		End While
		Return result.ToString()
	End Function

	Public Shared Sub SetSessionForzaturaConsenso(ByVal IdPaziente As Guid, ByVal Value As Boolean)
		HttpContext.Current.Session("ForzaturaConsenso-" & IdPaziente.ToString) = Value
	End Sub

	Public Shared Function GetSessionForzaturaConsenso(ByVal IdPaziente As Guid) As Boolean
		Dim obj As Object = HttpContext.Current.Session("ForzaturaConsenso-" & IdPaziente.ToString)
		If obj Is Nothing Then
			Return False
		Else
			Return CType(HttpContext.Current.Session("ForzaturaConsenso-" & IdPaziente.ToString), Boolean)
		End If
	End Function

#Region "JavaScript"

#Region "OpenWindow"

	Public Shared Function JSOpenWindowCode(ByVal sURL As String,
												ByVal sWindowName As String,
												ByVal bResizable As Boolean,
												ByVal bLocation As Boolean, ByVal bMenuBar As Boolean,
												ByVal bToolbar As Boolean, ByVal bScrolbars As Boolean,
												ByVal bStatus As Boolean, ByVal bTitlebar As Boolean,
												ByVal bReplace As Boolean,
												ByVal iHeight As Integer, ByVal iWidth As Integer) As String
		'
		' Apre una nuova finestra in popup
		'
		Dim iTop As Integer = 0
		Dim iLeft As Integer = 0
		Dim sOptions As String = String.Empty
		Dim sLocation As String = "no"
		Dim sMenuBar As String = "no"
		Dim sResizable As String = "no"
		Dim sToolbar As String = "no"
		Dim sScrolbars As String = "no"
		Dim sStatus As String = "no"
		Dim sTitleBar As String = "no"
		Dim sReplace As String = "false"

		If bResizable Then sResizable = "yes"
		If bToolbar Then sToolbar = "yes"
		If bScrolbars Then sScrolbars = "yes"
		If bStatus Then sStatus = "yes"
		If bTitlebar Then sTitleBar = "yes"
		If bReplace Then sReplace = "true"
		If bLocation Then sLocation = "yes"
		If bMenuBar Then sMenuBar = "yes"

		If String.IsNullOrEmpty(sWindowName) Then sWindowName = "_blank"

		sOptions &= "location=" & sLocation & ",menubar=" & sMenuBar
		sOptions &= ",resizable=" & sResizable & ",toolbar=" & sToolbar & ",scrollbars=" & sScrolbars
		sOptions &= ",status=" & sStatus & ",titlebar=" & sTitleBar

		Dim sFunction As String = "OpenWindow('" & sURL & "','" & sWindowName & "','" & sOptions & "'," & sReplace & "," & iWidth & "," & iHeight & ");"
		Return sFunction

	End Function

	Public Shared Function JSOpenWindowCode(ByVal sURL As String, ByVal bResizable As Boolean,
											 ByVal bLocation As Boolean, ByVal bMenuBar As Boolean,
											 ByVal bToolbar As Boolean, ByVal bScrolbars As Boolean,
											 ByVal bStatus As Boolean, ByVal bTitlebar As Boolean,
											 ByVal bReplace As Boolean,
											 ByVal iHeight As Integer, ByVal iWidth As Integer) As String
		Return JSOpenWindowCode(sURL, "", bResizable, bLocation, bMenuBar, bToolbar, bScrolbars, bStatus, bTitlebar, bReplace, iHeight, iWidth)
	End Function

	Public Shared Function JSOpenWindowFunction() As String
		'
		' Prima si registra la funzione poi si registra JSOpenWindow
		'
		Dim sScript As String
		sScript = "function OpenWindow(sURL, sWindowName, sOptions, bReplace, iWidth, iHeight)" & vbCrLf &
				 "{ try {" & vbCrLf &
				 "var w = 640, h = 480;" & vbCrLf &
				 "var newwindow;" & vbCrLf &
				 "if (document.all || document.layers)" & vbCrLf &
					 "{" & vbCrLf &
					 "w = screen.availWidth;" & vbCrLf &
					 "h = screen.availHeight;" & vbCrLf &
					 "}" & vbCrLf &
				 "var iLeft = (w-iWidth)/2;" & vbCrLf &
				 "var iTop = (h-iHeight)/2;" & vbCrLf &
				 "var Options = sOptions + ',left=' + iLeft + ',top=' + iTop + ',width=' + iWidth + ',height=' + iHeight;" & vbCrLf &
				 "newwindow = window.open(sURL,sWindowName,Options, bReplace);" & vbCrLf &
				 "newwindow.opener = self;" & vbCrLf &
				 "newwindow.focus();" & vbCrLf &
				 "} catch(err){}" & vbCrLf &
				 "}" & vbCrLf
		Return sScript
	End Function

	Public Shared Function JSCloseWindowCode() As String
		'Fondamentale il "return false;"
		Return "javascript:window.close();return false;"
	End Function

#End Region

	Public Shared Function JSBuildScript(ByVal sClientCode As String) As String
		Const JS_SCRIPT As String = vbCrLf &
				"<script language=""javascript"" type=""text/javascript"">" & vbCrLf &
				"<!--" & vbCrLf &
				"{0}" & vbCrLf &
				"// -->" & vbCrLf &
				"</script>"
		sClientCode = sClientCode.Trim().TrimStart("<!--".ToCharArray).TrimEnd("// -->".ToCharArray)
		Return String.Format(JS_SCRIPT, sClientCode)
	End Function

	Public Shared Sub JSTranslateOnEnterToButtonClick(ByVal oTextBoxControl As TextBox, ByVal oButton As Button)
		Dim sJava As String = String.Format("Javascript: fButtonClickOnEnterKey(document.all.{0},document.all.{1})", oTextBoxControl.ClientID, oButton.ClientID)
		oTextBoxControl.Attributes.Add("onkeydown", sJava)
	End Sub

	Public Shared Function JSCancelF5Function() As String
		Dim sFunction As String = "function document.onkeydown()"
		sFunction = sFunction & "{"
		sFunction = sFunction & "if(event.keyCode == 116 )"
		sFunction = sFunction & "{"
		sFunction = sFunction & "event.keyCode = 0;"
		sFunction = sFunction & "event.cancelBubble = true;"
		sFunction = sFunction & "return false;"
		sFunction = sFunction & "}"
		sFunction = sFunction & "}"
		Return sFunction
	End Function

	Public Shared Function JSAlertCode(ByVal sMsg As String) As String
		Return "alert('" & JSParseString(sMsg) & "');"
	End Function

	Private Shared Function JSParseString(ByVal sText As String) As String
		'
		' Sostituisce l'apostrofo con \', i tab, gli a capo...
		' La stringa deve essere scritta in formato VB senza sequenze di escape!!!
		'
		sText = Replace(sText, "\", "\\") 'Deve essere il primo replace!!!
		sText = Replace(sText, vbCrLf, "\n")
		sText = Replace(sText, vbCr, "\r")
		sText = Replace(sText, vbLf, "\f")
		sText = Replace(sText, "'", "\'")
		sText = Replace(sText, vbTab, "\b")
		sText = Replace(sText, """", "\""""")
		'
		' Per eventuali accentate bisogna fare replace con \xESADEC...
		'
		Return sText
	End Function

#End Region

#Region "WebService"
	Public Shared Sub SetWsConsensiCredential(ByVal oWs As SacConsensiDataAccess.ConsensiSoapClient)
		'
		' Se User="" e Password="" -> authenticazione integrata altrimenti Basic
		'
		Dim sUser As String = My.Settings.SacDataAccess_User
		Dim sPassword As String = My.Settings.SacDataAccess_Password
		SetWCFCredentials(oWs.ChannelFactory.Endpoint.Binding, oWs.ClientCredentials, sUser, sPassword)
	End Sub

	Public Shared Sub SetWsPazientiCredential(ByVal oWs As SacPazientiDataAccess.PazientiSoapClient)
		'
		' Se User="" e Password="" -> authenticazione integrata altrimenti Basic
		'
		Dim sUser As String = My.Settings.SacDataAccess_User
		Dim sPassword As String = My.Settings.SacDataAccess_Password
		SetWCFCredentials(oWs.ChannelFactory.Endpoint.Binding, oWs.ClientCredentials, sUser, sPassword)
	End Sub

	Public Shared Sub SetWcfDwhClinicoCredential(ByVal oWs As WcfDwhClinico.ServiceClient)
		'
		' Se User="" e Password="" -> authenticazione integrata altrimenti Basic
		'
		Dim sUser As String = My.Settings.WcfDwhClinico_User
		Dim sPassword As String = My.Settings.WcfDwhClinico_Password
		SetWCFCredentials(oWs.ChannelFactory.Endpoint.Binding, oWs.ClientCredentials, sUser, sPassword)
	End Sub

	''' <summary>
	''' Setta le credenziali per il wcf del sac
	''' </summary>
	''' <param name="oWs"></param>
	Public Shared Sub SetWcfSacCredential(ByVal oWs As WcfSacRoleManager.RoleManagerClient)
		'
		' Se User="" e Password="" -> authenticazione integrata altrimenti Basic
		'
		Dim sUser As String = My.Settings.SacDataAccess_User
		Dim sPassword As String = My.Settings.SacDataAccess_Password
		'
		' Se User="" e Password="" -> authenticazione integrata altrimenti Basic
		'
		SetWCFCredentials(oWs.ChannelFactory.Endpoint.Binding, oWs.ClientCredentials, sUser, sPassword)
	End Sub

	''' <summary>
	''' Reimposta le credenziali di autenticazione al webservice
	''' </summary>
	''' <param name="oEndPointBinding">passare: oWs.ChannelFactory.Endpoint.Binding</param>
	''' <param name="oCredentials">passare: oWs.ClientCredentials</param>
	''' <param name="sUser">Nome Utente</param>
	''' <param name="sPassword">Password</param>
	Public Shared Sub SetWCFCredentials(oEndPointBinding As ServiceModel.Channels.Binding, oCredentials As ServiceModel.Description.ClientCredentials, sUser As String, sPassword As String)
		Dim sErrorMsg As String = String.Empty
		Dim oBasicHttpBinding As BasicHttpBinding = TryCast(oEndPointBinding, BasicHttpBinding)
		If oBasicHttpBinding IsNot Nothing Then
			Dim oCredType = oBasicHttpBinding.Security.Transport.ClientCredentialType
			If oCredType = HttpClientCredentialType.Basic Then
				' Autenticazione BASIC
				oCredentials.UserName.UserName = sUser
				oCredentials.UserName.Password = sPassword
				oBasicHttpBinding.UseDefaultWebProxy = False
				Exit Sub
			ElseIf oCredType = HttpClientCredentialType.Windows Then
				' Autenticazione WINDOWS
				' Se non ho fornito user e password lascio fare al sistema.
				If Not String.IsNullOrEmpty(sUser) AndAlso Not String.IsNullOrEmpty(sPassword) Then
					oCredentials.Windows.ClientCredential = GetNetworkCredential(sUser, sPassword)
				End If
				Exit Sub
			Else
				sErrorMsg = String.Format("Il tipo di credenziali 'HttpClientCredentialType.{0}' non è gestito!", oCredType.ToString)
				sErrorMsg = sErrorMsg & vbCrLf &
							"I tipi di credenziali gestiti sono: 'HttpClientCredentialType.Basic', 'HttpClientCredentialType.Windows'."
				Throw New ApplicationException(sErrorMsg)
			End If
		End If
		Dim oWSHttpBinding As WSHttpBinding = TryCast(oEndPointBinding, WSHttpBinding)
		If oWSHttpBinding IsNot Nothing Then
			Dim oCredType = oWSHttpBinding.Security.Transport.ClientCredentialType
			If oCredType = HttpClientCredentialType.Basic Then
				' Autenticazione BASIC
				oCredentials.UserName.UserName = sUser
				oCredentials.UserName.Password = sPassword
				oWSHttpBinding.UseDefaultWebProxy = False
				Exit Sub
			ElseIf oCredType = HttpClientCredentialType.Windows Then
				' Autenticazione WINDOWS
				' Se non ho fornito user e password lascio fare al sistema.
				If Not String.IsNullOrEmpty(sUser) AndAlso Not String.IsNullOrEmpty(sPassword) Then
					oCredentials.Windows.ClientCredential = GetNetworkCredential(sUser, sPassword)
				End If
				Exit Sub
			Else
				sErrorMsg = String.Format("Il tipo di credenziali 'HttpClientCredentialType.{0}' non è gestito!", oCredType.ToString)
				sErrorMsg = sErrorMsg & vbCrLf &
							"I tipi di credenziali gestiti sono: 'HttpClientCredentialType.Basic', 'HttpClientCredentialType.Windows'."
				Throw New ApplicationException(sErrorMsg)
			End If
		End If
		'
		' Se sono qui il tipo di binding non è gestito
		'
		sErrorMsg = String.Format("Il tipo di binding '{0}' non è gestito!", oEndPointBinding.ToString)
		sErrorMsg = sErrorMsg & vbCrLf &
				   "Utilizzare il tipo di binding 'BasicHttpBinding'/'WsHttpBinding'."
		Throw New ApplicationException(sErrorMsg)
	End Sub

	Private Shared Function GetNetworkCredential(ByVal sUser As String, ByVal sPassword As String) As NetworkCredential

		Dim credentials As NetworkCredential

		If sUser.Length > 0 Then
			'Basic autentication                
			Dim domain As String = String.Empty
			Dim account As String() = sUser.Replace("\", "/").Split("/"c)

			If account.Length > 1 Then
				domain = account(0)
				sUser = account(1)
			End If

			credentials = New NetworkCredential(sUser, sPassword, domain)
		Else
			'Integrated autentication                
			credentials = CType(CredentialCache.DefaultCredentials(), NetworkCredential)
		End If

		Return credentials
	End Function

	Public Shared Function GetMyProxy(ByVal sProxyUrl As String, ByVal sProxyBypassList As String, ByVal sProxyBypassLocal As String, ByVal sUser As String, ByVal sPassword As String) As IWebProxy

		If sProxyUrl.Length > 0 Then
			'
			' Crea credenziali
			'
			Dim oMyCred As NetworkCredential = GetNetworkCredential(sUser, sPassword)

			'
			' Proxy BypassList
			'
			Dim asProxyBypassList() As String
			If sProxyBypassList.Length > 0 Then
				asProxyBypassList = sProxyBypassList.Split(";"c)
			Else
				asProxyBypassList = Nothing
			End If

			Return New WebProxy(sProxyUrl, CBool(sProxyBypassLocal), asProxyBypassList, oMyCred)
		Else
			Return Nothing
		End If
	End Function
#End Region

#Region "Memorizzazione URL pagina visitata"
	Private Const URL_CORRENTE As String = "_UrlCorrente_"

	Public Shared Sub SetUrlCorrente()
		'
		' Memorizzo la stringa originale con eventuali encoding
		'
		Dim sUrl As String = HttpContext.Current.Request.Url.OriginalString
		HttpContext.Current.Session(URL_CORRENTE) = sUrl
	End Sub

	Public Shared Function GetUrlCorrente() As String
		Return CType(HttpContext.Current.Session(URL_CORRENTE), String)
	End Function

#End Region

#Region "Trace"

	''' <summary>
	''' Funzione per scrivere nel trace (si visualizza con DebugView) (Prefisso fissato "DWH-USER: ")
	''' </summary>
	''' <remarks></remarks>
	Public Shared Sub TraceWriteLine(ByVal sMessage As String)
		If Not HttpContext.Current Is Nothing Then
			System.Diagnostics.Trace.WriteLine(sMessage, "DWH-USER " & HttpContext.Current.User.Identity.Name)
		Else
			System.Diagnostics.Trace.WriteLine(sMessage, "DWH-USER ")
		End If
	End Sub

	Public Shared Sub TraceWrite(ByVal sMessage As String)
		If Not HttpContext.Current Is Nothing Then
			System.Diagnostics.Trace.Write(sMessage, "DWH-USER " & HttpContext.Current.User.Identity.Name)
		Else
			System.Diagnostics.Trace.Write(sMessage, "DWH-USER ")
		End If
	End Sub

#End Region

	''' <summary>
	''' Naviga alla pagina di errore per l'accesso standard
	''' </summary>
	''' <param name="enumErrorCode"></param>
	''' <param name="sErroreDescrizione"></param>
	''' <param name="endResponse"></param>
	''' <remarks></remarks>
	Public Shared Sub NavigateToErrorPage(enumErrorCode As Utility.ErrorCode, sErroreDescrizione As String, endResponse As Boolean)
		ErrorPage.SetErrorDescription(enumErrorCode, sErroreDescrizione)
		HttpContext.Current.Response.Redirect("~/ErrorPage.aspx", endResponse)
	End Sub

	''' <summary>
	''' Naviga alla pagina di errore per l'accesso diretto
	''' </summary>
	''' <param name="enumErrorCode"></param>
	''' <param name="sErroreDescrizione"></param>
	''' <param name="endResponse"></param>
	''' <remarks></remarks>
	Public Shared Sub NavigateToAccessoDirettoErrorPage(enumErrorCode As Utility.ErrorCode, sErroreDescrizione As String, endResponse As Boolean)
		AccessoDiretto_ErrorPage.SetErrorDescription(enumErrorCode, sErroreDescrizione)
		HttpContext.Current.Response.Redirect("~/AccessoDiretto/ErrorPage.aspx", endResponse)
	End Sub

	''' <summary>
	''' Versione della DLL dell'applicazione web
	''' </summary>
	''' <returns></returns>
	''' <remarks></remarks>
	Public Shared Function GetAssemblyVersion() As String
		'
		' Legge versione della DLL
		'
		Try
			Return String.Format("Ver: {0}", System.Reflection.Assembly.GetExecutingAssembly.GetName.Version.ToString())
		Catch
			Return String.Empty
		End Try
	End Function

#Region "Utenti: lettura dati utente"
	Public Class DettaglioUtente
		Public IdUtente As Guid = Guid.Empty
		Public DomainName As String = String.Empty
		Public AccountName As String = String.Empty
		Public Nome As String = String.Empty
		Public Cognome As String = String.Empty
		Public Email As String = String.Empty
		Public NomeCompleto As String = String.Empty
		Public AccountCompleto As String = String.Empty
		Public CodiceFiscale As String = String.Empty

		Public Sub New()
			Me.IdUtente = Guid.Empty
			Me.DomainName = String.Empty
			Me.AccountName = String.Empty
			Me.Nome = String.Empty
			Me.Cognome = String.Empty
			Me.Email = String.Empty
			Me.NomeCompleto = String.Empty
			Me.AccountCompleto = String.Empty
			Me.CodiceFiscale = String.Empty
		End Sub

		Public Sub New(ByVal IdUtente As Guid, ByVal DomainName As String, ByVal Accountname As String, ByVal Nome As String, ByVal Cognome As String, ByVal Email As String, ByVal NomeCompleto As String, ByVal AccountCompleto As String, ByVal CodiceFiscale As String)
			Me.IdUtente = IdUtente
			Me.DomainName = DomainName
			Me.AccountName = Accountname
			Me.Nome = Nome
			Me.Cognome = Cognome
			Me.Email = Email
			Me.NomeCompleto = NomeCompleto
			Me.AccountCompleto = AccountCompleto
			Me.CodiceFiscale = CodiceFiscale
		End Sub

	End Class


	''' <summary>
	''' Restituisce il dettaglio del paziente prendendolo dal Role Manager.
	''' </summary>
	''' <param name="sDomainName"></param>
	''' <param name="sAccountName"></param>
	''' <returns></returns>
	Public Shared Function GetDettaglioUtente(ByVal sDomainName As String, ByVal sAccountName As String) As DettaglioUtente
		Dim accountUtente As String = String.Format("{0}\{1}", sDomainName, sAccountName)
		Dim SESS_KEY_DETTAGLIO_UTENTE As String = String.Format("KEY-DETTAGLIO-UTENTE-{0}", accountUtente)
		Try
			'ottengo il dettaglio dell'utente dalla sessione.
			Dim dettaglioUtente As DettaglioUtente = CType(HttpContext.Current.Session(SESS_KEY_DETTAGLIO_UTENTE), DettaglioUtente)

			'controllo se il dettaglio dell'utente è valrizzato.
			If dettaglioUtente Is Nothing Then
				'se non è valorizzato lo prendo chiamando il metodo del role manager.
				Dim dataAccess As New DI.PortalUser2.RoleManager.DataAccess(My.Settings.SacDataAccess_User, My.Settings.SacDataAccess_Password)
				Dim utente As DI.PortalUser2.RoleManager.Utente = dataAccess.UtenteOttieniDettaglio(accountUtente)

				'se utente non è vuoto allora creo un nuovo oggetto di tipo DettaglioUtente.
				If utente IsNot Nothing Then
					dettaglioUtente = New DettaglioUtente(utente.IdUtente, sDomainName, sAccountName, utente.Nome, utente.Cognome, utente.Email, utente.NomeCompleto, accountUtente, utente.CodiceFiscale)
				Else
					If Not String.IsNullOrEmpty(sAccountName) Then
						'
						' sAccountName è presente allora c'è anche il dominio
						' Allora l'operatore non e codificato nella tabella Utenti
						'
						dettaglioUtente = New DettaglioUtente(Guid.Empty, sDomainName, sAccountName, String.Empty, String.Empty, String.Empty, accountUtente, accountUtente, String.Empty)

						' Warning
						'
						Logging.WriteWarning(String.Format("L'utente {0}\{1} non è stato trovato nella tabella degli utenti!", sDomainName, sAccountName))
					Else
						'
						' Anonimo
						'
						dettaglioUtente = New DettaglioUtente(Guid.Empty, String.Empty, "Anonimo", String.Empty, String.Empty, String.Empty, "Anonimo", "Anonimo", String.Empty)
					End If
				End If

				'Aggiungo in sessione il dettaglio dell'utente.
				HttpContext.Current.Session.Add(SESS_KEY_DETTAGLIO_UTENTE, dettaglioUtente)
			End If

			'restituisco
			Return dettaglioUtente
		Catch ex As Exception
			Logging.WriteError(ex, String.Format("Errore durante utility.GetDettaglioUtente() per l'utente {0}", HttpContext.Current.User.Identity.Name))
			Throw ex
		End Try
		Return Nothing
	End Function
#End Region

#Region "Motivi di accesso"
	'
	' Motivi di accesso caricati dinamicamente
	'
	Public Const MOTIVO_ACCESSO_NOT_SELECTED_ID As String = ""
	Public Const MOTIVO_ACCESSO_NOT_SELECTED_TEXT As String = "<Selezionare il motivo dell'accesso>"
	Public Const MOTIVO_ACCESSO_NECESSITA_TECNICA_ID As String = "-1000"
	Public Const MOTIVO_ACCESSO_NECESSITA_TECNICA_TEXT As String = "Accesso per necessità tecniche"
	Public Const MOTIVO_ACCESSO_PAZIENTE_IN_CARICO_ID As String = "-1001"
	Public Const MOTIVO_ACCESSO_PAZIENTE_IN_CARICO_TEXT As String = "Paziente in carico"

	''' <summary>
	''' Carica la dropdownlist con i motivi di accesso configurati e aggiunge in prima posizione l'item vuoto
	''' </summary>
	''' <param name="cmb"></param>
	''' <remarks></remarks>
	Public Shared Sub LoadComboMotiviAccesso(cmb As DropDownList)
		'QUERY SU DB
		Using oUtenti As New Enumerazioni
			Using odt As EnumerazioniDataset.FevsMotiviAccessoListaDataTable = oUtenti.GetMotiviAccesso()
				If Not odt Is Nothing AndAlso odt.Rows.Count > 0 Then
					cmb.DataSource = odt
					cmb.DataValueField = "Id"
					cmb.DataTextField = "Descrizione"
					cmb.DataBind()
				End If
			End Using
		End Using
		'
		' Aggiungo campo vuoto in prima posizione
		'
		cmb.Items.Insert(0, New System.Web.UI.WebControls.ListItem(MOTIVO_ACCESSO_NOT_SELECTED_TEXT, MOTIVO_ACCESSO_NOT_SELECTED_ID))
	End Sub
#End Region

	Public Shared Function GetQueryStringParameterValue(P As Page, ByVal UrlQueryString As String, ByVal ParameterName As String) As String
		Try
			'
			' provo a cercare l'id del referto nel sUrlContent
			' Ottieniamo l'url anche se QueryString non è codificato
			Dim url As String = P.Server.HtmlDecode(UrlQueryString)
			Dim array1 As String() = url.Split("?")
			If array1.Count > 0 Then
				Dim array2 As String() = array1(1).Split("&")
				If array2.Count > 0 Then
					Dim query = (From c In array2 Where c.Contains(ParameterName))
					If query.Count > 0 Then
						Dim array3 As String() = query(0).Split("=")
						If array3.Count > 0 Then
							Return array3(1)
						End If
					End If
				End If
			End If
			Return Nothing
		Catch ex As Exception
			Return Nothing
		End Try
	End Function

	''' <summary>
	''' Mi dice se una pagina è usata come Entry Point (usata in ACCESSO DIRETTO)
	''' </summary>
	''' <returns></returns>
	''' <remarks></remarks>
	Public Shared Function AccessoDiretto_IsPageEntryPoint() As Boolean
		'
		' Riusciamo a ottenere correttamente l'UrlReferrer se accediamo alla pagina tramite hyperlink
		' Se eseguiamo un response.redirect allora HttpContext.Current.Request.UrlReferrer è nothing
		'
		If HttpContext.Current.Request.UrlReferrer Is Nothing Then
			Return True
		End If

		Dim sReferrerUri As String = HttpContext.Current.Request.UrlReferrer.AbsoluteUri.ToUpper
		Dim sCurrentPageUri As String = HttpContext.Current.Request.Url.AbsoluteUri.ToUpper
		'
		' La pagina chiamata è ancora Entry Point se la parte HOST fra i due è differente
		' Significa che il referrer non è una pagina dell'accesso diretto
		'
		Dim oArrayReferrerUri As String() = Split(sReferrerUri, "ACCESSODIRETTO")
		Dim oArrayAbsoluteUri As String() = Split(sCurrentPageUri, "ACCESSODIRETTO")
		If oArrayReferrerUri(0) <> oArrayAbsoluteUri(0) Then
			Return True
		End If
		'
		' Se sono qui NON E' ENTRY POINT 
		'
		Return False
	End Function

#Region "Info ultimo accesso"

	''' <summary>
	''' Scrive nella tabella DiPortalUser.TracciaAccessi un record di log specificando il codice del ruolo selezionato dall'utente
	''' </summary>
	''' <param name="sRuoloCodice"></param>
	''' <remarks></remarks>
	Public Shared Sub PortalUserTracciaAccessi(sRuoloCodice As String)
		'USA DI.PORTALUSER
		'
		'  Scrivo il ruolo nel DbUserPortal 
		'
		Dim sDiPortalUserConnectionString As String = Utility.GetAppSettings(Utility.PAR_DI_PORTAL_USER_CONNECTION_STRING, "")
		Dim portal As PortalDataAdapterManager = New PortalDataAdapterManager(sDiPortalUserConnectionString)
		Dim dNow = DateTime.Now
		Call portal.TracciaAccessi(HttpContext.Current.User.Identity.Name, PortalsNames.DwhClinico, String.Format("Accesso effettuato il {0} alle ore {1}", dNow.ToString("dd/MM/yyy"), dNow.ToString("HH:mm:ss")), sRuoloCodice)
	End Sub

#End Region

#Region "Funzioni per filtrare i referti/ricoveri/eventi  in base agli accessi"
	'
	' Il filtro si basa sull'azienda erogante, il sistema erogante e sull'accesso agli oscurati
	' CheckAccesso(HttpContext.Current.User, AziendaErogante , SistemaErogante , Oscuramenti )
	' Il cmpo Oscuramenti viene visto come una stringa da DOT NET
	'
	''' <summary>
	''' Funzione per testare la visibilità di un oggetto (referto/ricovero/evento)
	''' </summary>
	''' <param name="oContextUser"></param>
	''' <param name="AziendaErogante"></param>
	''' <param name="SistemaErogante"></param>
	''' <param name="Oscuramenti">Bisogna prima verificare che il campo Oscuramenti restituito dalla SP non sia NULL. Se null bisogna passare String.Empty o Nothing</param>
	''' <returns></returns>
	''' <remarks></remarks>
	Public Shared Function CheckAccesso(oContextUser As System.Security.Principal.IPrincipal, ByVal AziendaErogante As String, ByVal SistemaErogante As String, ByVal Oscuramenti As String) As Boolean
		Dim bRet As Boolean = False
		'
		' 1) Eseguo prima il controllo per Azienda e Sistema erogante: IsInRole() dell'accesso 
		'
		If Not oContextUser.IsInRole(String.Format(RoleManagerUtility2.SE_REF_VIEW, SistemaErogante, AziendaErogante)) Then Return False
		'
		' 2) Controllo la lista degli oscuramenti: se vuota allora oggetto visibile
		'
		If String.IsNullOrEmpty(Oscuramenti) Then Return True
		'
		' Se lista Oscuramenti non vuota verifico se gli oscuramenti sono bypassabili:
		'
		bRet = CheckByPassOscuramenti(oContextUser, Oscuramenti)
		'
		' Restituisco
		'
		Return bRet
	End Function

	''' <summary>
	''' Funzione che controlla se un oggetto oscurato è bypassabile da un determinato ruolo
	''' </summary>
	''' <param name="oContextUser"></param>
	''' <param name="sOscuramenti"></param>
	''' <returns></returns>
	''' <remarks></remarks>
	Private Shared Function CheckByPassOscuramenti(oContextUser As System.Security.Principal.IPrincipal, ByVal sOscuramenti As String) As Boolean
		'--------------------------------------------------------------------------------------------------
		' ESEMPIO XML LISTA DEGLI OSCURAMENTI
		'--------------------------------------------------------------------------------------------------
		'<Oscuramenti>
		'  <Oscuramento CodiceOscuramento="100034" IdRuolo="01000000-0000-0000-0000-000000000000" />
		'  <Oscuramento CodiceOscuramento="100034" IdRuolo="02000000-0000-0000-0000-000000000000" />
		'  <Oscuramento CodiceOscuramento="100035" IdRuolo="01000000-0000-0000-0000-000000000000" />
		'  <Oscuramento CodiceOscuramento="100035" IdRuolo="03000000-0000-0000-0000-000000000000" />
		'  <Oscuramento CodiceOscuramento="100035" IdRuolo="04000000-0000-0000-0000-000000000000" />
		'  <Oscuramento CodiceOscuramento="100040"  />
		'</Oscuramenti>
		'--------------------------------------------------------------------------------------------------
		Const ELEMENT_OSCURAMENTO As String = "Oscuramento"
		Const ATTRIB_CODICE_OSCURAMENTO As String = "CodiceOscuramento"
		Const ATTRIB_ID_RUOLO As String = "IdRuolo"
		Dim bByPassaOscuramento As Boolean = False
#If DEBUG Then
		Dim t0 As DateTime = Now()
#End If
		'
		' Costruisco documento XML
		'
		Dim oXml As System.Xml.Linq.XDocument = System.Xml.Linq.XDocument.Parse(sOscuramenti)
		'
		' Seleziono tutti i nodi <Oscuramento> e li ordino per valore dell'attributo "CodiceOscuramento"
		'
		Dim query As System.Collections.Generic.IEnumerable(Of System.Xml.Linq.XElement) = From p In oXml.Root.Elements(ELEMENT_OSCURAMENTO) Order By p.Attribute(ATTRIB_CODICE_OSCURAMENTO).Value
		'
		' Se sOscuramenti non è una stringa vuota c'è sempre almeno un nodo
		'
		If query.Count > 0 Then

			Dim oFirstOscuramento As System.Xml.Linq.XElement = query.First()
			Dim sOldCodiceOscuramento As String = oFirstOscuramento.Attribute(ATTRIB_CODICE_OSCURAMENTO).Value

			For Each oOscuramento As System.Xml.Linq.XElement In query
				'
				' Questo c'è sempre
				'
				Dim sCurrentCodiceOscuramento As String = oOscuramento.Attribute(ATTRIB_CODICE_OSCURAMENTO).Value
				'
				' L'attributo idRuolo potrebbe mancare: in tal caso lo imposto a String.Empty (= un IdRuolo impossibile) 
				'
				Dim sCurrentIdRuolo As String = String.Empty
				Dim oAttrIdRuolo As System.Xml.Linq.XAttribute = oOscuramento.Attribute(ATTRIB_ID_RUOLO)
				If Not oAttrIdRuolo Is Nothing Then
					sCurrentIdRuolo = oAttrIdRuolo.Value
				End If
				'
				' Se ho cambiato il codice di oscuramento è bByPassaOscuramento è false allora sOldCodiceOscuramento non era bypassabile: esco restituendo false
				'
				If sOldCodiceOscuramento <> sCurrentCodiceOscuramento And bByPassaOscuramento = False Then Return False
				'
				' Se sto analizzando lo stesso codice di oscuramento e bByPassaOscuramento = False verifico se posso bypassarlo
				'
				If sOldCodiceOscuramento = sCurrentCodiceOscuramento And bByPassaOscuramento = False Then
					bByPassaOscuramento = oContextUser.IsInRole(sCurrentIdRuolo)
					'ElseIf sOldCodiceOscuramento = sCurrentCodiceOscuramento And bByPassaOscuramento = True Then
					'    'NON FACCIO NIENTE
				ElseIf sOldCodiceOscuramento <> sCurrentCodiceOscuramento Then
					'Se sono passato a unnhovo codice di oscuramento verififo se posso bypassarlo
					bByPassaOscuramento = oContextUser.IsInRole(sCurrentIdRuolo)
				End If
				'
				' Memorizzo Codice oscuramento corrente
				'
				sOldCodiceOscuramento = sCurrentCodiceOscuramento
			Next
		Else
			bByPassaOscuramento = True
		End If
#If DEBUG Then
		Debug.WriteLine(String.Format("CheckByPassOscuramenti() : {0} ms", Now.Subtract(t0).TotalMilliseconds))
#End If
		'
		'
		'
		Return bByPassaOscuramento

	End Function

#End Region

	''' <summary>
	''' CREATA DA ETTORE 2015-06-05: Compone l'url alla pagina di visualizzazione del dettaglio di un referto (usata in FE e Accesso Diretto)
	''' </summary>
	''' <param name="IdReferto"></param>
	''' <returns></returns>
	''' <remarks></remarks>
	Public Shared Function GetUrlDettaglioReferto(ByVal IdReferto As Guid) As String
		'QUERY SU DB
		'
		' Carica info su referto
		'
		Dim sUrl As String = ""
		Using oData As New Referti
			Using odt As RefertiDataSet.RefertoStiliDisponibiliDataTable = oData.RefertoStiliDisponibili(IdReferto)
				If (Not odt Is Nothing) AndAlso (odt.Rows.Count > 0) Then
					'
					' Uso pagina web configurata nella tabella "RefertiStili"
					'
					Dim oRow As RefertiDataSet.RefertoStiliDisponibiliRow = odt(0)
					'
					' Concatena link e parametri 
					'
					Dim strLink As String = oRow.PaginaWeb
					Dim strParam As String = oRow.Parametri
					sUrl = strLink & "?" & strParam.Replace(FLD_ID_REFERTO, IdReferto.ToString)
				Else
					'
					' Usa stile dei default
					'
					Dim strLink As String = My.Settings.ApreReferto_DefaultView
					sUrl = strLink.Replace(FLD_ID_REFERTO, IdReferto.ToString)
				End If
			End Using
		End Using
		'
		' Restituisco 
		'
		Return sUrl
	End Function

	Public Shared Function GetRefertiStiliDisponibili(ByVal IdReferto As Guid) As RefertiDataSet.RefertoStiliDisponibiliRow
		'QUERY SU DB
		'
		' Carica la riga dello stile del referto
		'
		Dim oRow As RefertiDataSet.RefertoStiliDisponibiliRow = Nothing
		Using oData As New Referti
			Using odt As RefertiDataSet.RefertoStiliDisponibiliDataTable = oData.RefertoStiliDisponibili(IdReferto)
				If (Not odt Is Nothing) AndAlso (odt.Rows.Count > 0) Then
					oRow = odt(0)
				End If
			End Using
		End Using
		'
		' Restituisco 
		'
		Return oRow
	End Function

	''' <summary>
	''' Restituisce l'url relativo all'application. Utile per trovare l'URL relatuivo a folder e pagine
	''' </summary>
	''' <returns></returns>
	''' <remarks></remarks>
	Public Shared Function GetApplicationPath() As String
		Return HttpContext.Current.Request.ApplicationPath.TrimEnd("/") & "/"
	End Function

	''' <summary>
	''' Calcolo dell'età partendo dalla Data di Nascita fino a una Data di Riferimento
	''' </summary>
	Public Shared Function CalcolaEta(DataNascita As Date, DataRiferimento As Date) As Integer
		Dim Eta As Integer = DataRiferimento.Year - DataNascita.Year
		If DataNascita > DataRiferimento.AddYears(Eta) Then
			Eta -= 1
		End If
		Return Eta
	End Function

#Region "Utente autorizzatore"
	Public Const ATTRIBUTO_AUTORIZZATORE_NOME = "AutorizzatoreMinoreNome"
	Public Const ATTRIBUTO_AUTORIZZATORE_COGNOME = "AutorizzatoreMinoreCognome"
	Public Const ATTRIBUTO_AUTORIZZATORE_DATANASCITA = "AutorizzatoreMinoreDataNascita"
	Public Const ATTRIBUTO_AUTORIZZATORE_LUOGONASCITA = "AutorizzatoreMinoreLuogoNascita"
	Public Const ATTRIBUTO_AUTORIZZATORE_RELAZIONEMINORE = "AutorizzatoreMinoreRelazione"

	''' <summary>
	''' Restituisce le possibili relazioni con un minore
	''' </summary>
	''' <returns></returns>
	''' <remarks></remarks>
	Public Shared Function GetRelazioniConMinore() As SacConsensiDataAccess.RelazioniConMinoreType
		Dim oRet As SacConsensiDataAccess.RelazioniConMinoreType
		Dim oSacConsensiWs As SacConsensiDataAccess.ConsensiSoapClient = New SacConsensiDataAccess.ConsensiSoapClient
		Call Utility.SetWsConsensiCredential(oSacConsensiWs)
		oRet = oSacConsensiWs.RelazioniConMinoreCerca()
		Return oRet
	End Function

	''' <summary>
	''' Utilizzata per caricare compbo delle relazioni con il minore
	''' </summary>
	''' <param name="oCombo"></param>
	''' <param name="oRelazioni"></param>
	''' <remarks></remarks>
	Public Shared Sub LoadComboRelazioniConMinore(ByRef oCombo As DropDownList, ByVal oRelazioni As SacConsensiDataAccess.RelazioniConMinoreType)
		Const ID_RELAZIONE_CON_MINORE_GENITORE As String = "1"
		If Not oRelazioni Is Nothing AndAlso oRelazioni.Count > 0 Then
			For Each oRelazione As SacConsensiDataAccess.RelazioneConMinoreType In oRelazioni
				Dim oItem As New ListItem(oRelazione.Descrizione, oRelazione.Id)
				oCombo.Items.Add(oItem)
			Next
			oCombo.SelectedValue = ID_RELAZIONE_CON_MINORE_GENITORE
		End If
	End Sub

	''' <summary>
	''' Usata per il salvataggio in sessione 
	''' </summary>
	''' <remarks></remarks>
	Public Class UtenteAutorizzatoreMinore
		Public Cognome As String
		Public Nome As String
		Public DataNascita As DateTime
		Public LuogoNascita As String
		Public RelazioneColMinoreId As String

		Public Sub New(ByVal Cognome As String, ByVal Nome As String, ByVal DataNascita As Date, ByVal LuogoNascita As String, ByVal RelazioneColMinoreId As String)
			Me.Cognome = Cognome
			Me.Nome = Nome
			Me.DataNascita = DataNascita
			Me.LuogoNascita = LuogoNascita
			Me.RelazioneColMinoreId = RelazioneColMinoreId
		End Sub
	End Class


	Public Shared Function BuildAttributiAutorizzatoreDelMinore(ByVal Cognome As String, ByVal Nome As String, ByVal DataNascita As DateTime, ByVal LuogoNascita As String, ByVal RelazioneColMinore As String) As SacConsensiDataAccess.AttributiType
		Const FORMAT_DATA_DB = "{0:yyyy-MM-dd}"
		Dim oAttributiType As SacConsensiDataAccess.AttributiType
		Dim oAttributoType As SacConsensiDataAccess.AttributoType
		oAttributiType = New SacConsensiDataAccess.AttributiType

		oAttributoType = New SacConsensiDataAccess.AttributoType() With {.Nome = ATTRIBUTO_AUTORIZZATORE_COGNOME, .Valore = Cognome.Trim}
		oAttributiType.Add(oAttributoType)

		oAttributoType = New SacConsensiDataAccess.AttributoType() With {.Nome = ATTRIBUTO_AUTORIZZATORE_NOME, .Valore = Nome.Trim}
		oAttributiType.Add(oAttributoType)

		oAttributoType = New SacConsensiDataAccess.AttributoType() With {.Nome = ATTRIBUTO_AUTORIZZATORE_DATANASCITA, .Valore = String.Format(FORMAT_DATA_DB, DataNascita)}
		oAttributiType.Add(oAttributoType)

		oAttributoType = New SacConsensiDataAccess.AttributoType() With {.Nome = ATTRIBUTO_AUTORIZZATORE_LUOGONASCITA, .Valore = LuogoNascita.Trim}
		oAttributiType.Add(oAttributoType)

		oAttributoType = New SacConsensiDataAccess.AttributoType() With {.Nome = ATTRIBUTO_AUTORIZZATORE_RELAZIONEMINORE, .Valore = RelazioneColMinore.Trim}
		oAttributiType.Add(oAttributoType)

		Return oAttributiType
	End Function

#End Region

#Region "GestioneConsensi"
	Public Shared Function PopoloDatiConsenso(ByVal eTipoConsenso As SacConsensiDataAccess.TipoConsenso, ByVal bStatoConsenso As Boolean,
										ByVal sPazienteProvenienza As String, ByVal sPazienteIdProvenienza As String,
										  ByVal sPazienteCognome As String, ByVal sPazienteNome As String, ByVal sPazienteCodiceFiscale As String,
										  ByVal dPazienteDataNascita As Nullable(Of Date), ByVal sPazienteCodiceSanitario As String,
										  ByVal sAccountOperatore As String, ByVal sOperatoreCognome As String, ByVal sOperatoreNome As String,
										  ByVal sOperatoreComputer As String,
										  ByVal oAttributiType As SacConsensiDataAccess.AttributiType) As SacConsensiDataAccess.Consenso
		Dim oConsenso As New SacConsensiDataAccess.Consenso
		With oConsenso
			.DataStato = DateTime.Now

			.PazienteProvenienza = sPazienteProvenienza
			.PazienteIdProvenienza = sPazienteIdProvenienza

			.OperatoreCognome = sOperatoreCognome
			.OperatoreComputer = sOperatoreComputer
			.OperatoreId = sAccountOperatore
			.OperatoreNome = sOperatoreNome
			.PazienteCognome = sPazienteCognome
			.PazienteNome = sPazienteNome
			.PazienteCodiceFiscale = sPazienteCodiceFiscale
			If dPazienteDataNascita.HasValue Then .PazienteDataNascita = dPazienteDataNascita
			.PazienteTesseraSanitaria = sPazienteCodiceSanitario
			.Stato = bStatoConsenso
			.Tipo = eTipoConsenso
			.Attributi = oAttributiType
		End With
		'
		' Restituisco
		'
		Return oConsenso
	End Function
#End Region

	Public Shared Function GetInizialiPaziente(ByVal sCognome As String, ByVal sNome As String) As String
		Dim sRet As String = ""
		'
		' In questo caso visualizzo solo le iniziali del nome e del cognome
		'
		Dim sArray As String() = Nothing
		'Split del Cognome
		sArray = Split(sCognome, " ")
		For Each s As String In sArray
			sRet = sRet & Left(s, 1) & ". "
		Next
		'Split del Nome
		sArray = Split(sNome, " ")
		For Each s As String In sArray
			sRet = sRet & Left(s, 1) & ". "
		Next
		'
		' Restituisco 
		'
		Return sRet.TrimEnd(" ")
	End Function

	''' <summary>
	''' Funzione che verifica se il nodo delle informazioni di un tipo refertoReturn è inizializzato
	''' Se lo è lancia un'application exception contenente le varie stringhe informative concatenate tra loro
	''' </summary>
	''' <param name="oRefertoReturn"></param>
	Public Shared Sub VerificaInformazioni(oRefertoReturn As WcfDwhClinico.RefertoReturn)
		If Not oRefertoReturn.Informazioni Is Nothing Then
			Dim tempString As String = String.Empty
			For Each info In oRefertoReturn.Informazioni
				tempString += info.Descrizione + "</br>"
			Next
			Throw New ApplicationException(tempString)
		End If
	End Sub

#Region "Funzioni per visualizzazioni di dettaglio"

	Public Shared Function ExecXsltTransformation(ByVal sXslt As String, ByVal argList As System.Xml.Xsl.XsltArgumentList, ByVal sXml As String) As String
		'
		' Carico il flusso XML
		'
		Dim oStringXml As IO.StringReader = New IO.StringReader(sXml)
		'
		' Flusso di output HTML
		'
		Dim oStringHtml As IO.StringWriter = New IO.StringWriter
		Dim oWriter As System.Xml.XmlTextWriter = New System.Xml.XmlTextWriter(oStringHtml)
		'
		' Trasformo XML + XSLT in HTML
		'
		Dim oXslt As System.Xml.Xsl.XslCompiledTransform = New System.Xml.Xsl.XslCompiledTransform

		oXslt.Load(New System.Xml.XmlTextReader(New System.IO.StringReader(sXslt)))
		oXslt.Transform(New System.Xml.XPath.XPathDocument(oStringXml), argList, oWriter)
		oWriter.Flush()
		'
		' Restituisco
		'
		Return oStringHtml.ToString
	End Function


	Public Shared Function ExecXsltTransformation(ByVal sXslt As String, ByVal argList As System.Xml.Xsl.XsltArgumentList, ByVal oByteXmlData As Byte()) As String

		Using oOutStream As System.IO.MemoryStream = New System.IO.MemoryStream(1)

			Dim xslt As System.Xml.Xsl.XslCompiledTransform = New System.Xml.Xsl.XslCompiledTransform()

			Using oXsltReader As System.Xml.XmlReader = System.Xml.XmlReader.Create(New IO.StringReader(sXslt))

				xslt.Load(oXsltReader)

				Using oXmlIOStream As New System.IO.MemoryStream(oByteXmlData)

					Using oXmlReader As System.Xml.XmlReader = System.Xml.XmlReader.Create(oXmlIOStream)
						'
						' Eseguo la trasformazione
						'
						xslt.Transform(oXmlReader, argList, oOutStream)
						oOutStream.Position = 0
						'
						' Questo per restituire una stringa
						'
						Using oReader As New System.IO.StreamReader(oOutStream)

							Return oReader.ReadToEnd()
						End Using

					End Using

				End Using

			End Using

		End Using
	End Function



	Public Shared Function ExecXsltTransformation(ByVal oByteXsltData As Byte(), ByVal argList As System.Xml.Xsl.XsltArgumentList, ByVal oByteXmlData As Byte()) As Byte()
		Using oOutStream As System.IO.MemoryStream = New System.IO.MemoryStream(1)

			Dim xslt As System.Xml.Xsl.XslCompiledTransform = New System.Xml.Xsl.XslCompiledTransform()

			Using oXsltIOStream As New System.IO.MemoryStream(oByteXsltData)

				Using oXsltReader As System.Xml.XmlReader = System.Xml.XmlReader.Create(oXsltIOStream)

					xslt.Load(oXsltReader)

					Using oXmlIOStream As New System.IO.MemoryStream(oByteXmlData)

						Using oXmlReader As System.Xml.XmlReader = System.Xml.XmlReader.Create(oXmlIOStream)

							xslt.Transform(oXmlReader, argList, oOutStream)

							Return oOutStream.GetBuffer()

						End Using

					End Using

				End Using

			End Using

		End Using
	End Function

	''' <summary>
	''' Restituisce l'allegato principale, quello con in posizione 0 e con il nome che finisce con "_PDF"
	''' </summary>
	''' <param name="oAllegati"></param>
	''' <returns></returns>
	Public Shared Function GetIdAllegatoPdfPrincipale(ByVal oAllegati As WcfDwhClinico.AllegatiType) As String
		Dim sIdAllegatoPdf As String = String.Empty

		If Not oAllegati Is Nothing AndAlso oAllegati.Count > 0 Then
			For Each oAllegato As WcfDwhClinico.AllegatoType In oAllegati
				If oAllegato.Posizione = 0 AndAlso
				   String.Compare(oAllegato.TipoContenuto, "application/pdf", True) = 0 AndAlso
				   System.IO.Path.GetFileNameWithoutExtension(oAllegato.NomeFile).ToUpper.EndsWith("_PDF") Then
					sIdAllegatoPdf = oAllegato.Id
					Exit For
				End If
			Next
		End If
		Return sIdAllegatoPdf
	End Function

	''' <summary>
	''' Restituisce il primo allegato PDF che è presente negli allegati
	''' </summary>
	''' <param name="oAllegati"></param>
	''' <returns></returns>
	Public Shared Function GetIdAllegatoPdf(ByVal oAllegati As WcfDwhClinico.AllegatiType) As String
		Dim sIdAllegatoPdf As String = String.Empty

		If Not oAllegati Is Nothing AndAlso oAllegati.Count > 0 Then
			For Each oAllegato As WcfDwhClinico.AllegatoType In oAllegati
				If String.Compare(oAllegato.TipoContenuto, "application/pdf", True) = 0 Then
					sIdAllegatoPdf = oAllegato.Id
					Exit For
				End If
			Next
		End If
		Return sIdAllegatoPdf
	End Function


	Public Shared Sub BuildLinkAllegato(ByVal oLink As System.Web.UI.WebControls.HyperLink, ByVal sIdAllegato As String)
		'"_top": apre il documento nello stesso frame dove era il link
		oLink.Visible = False
		Try
			If Not String.IsNullOrEmpty(sIdAllegato) Then
				'
				' Utilizzo la pagina predefinita del DWH per aprire il documento PDF: 
				'
				Dim sUrlApreAllegato As String = "/Dwhclinico/TracciaAccessi.aspx?Url=/DwhClinico/referti/ApreAllegato.aspx?IdAllegato={0}"
				'Sostituisco l'Id dell'allegato
				oLink.NavigateUrl = String.Format(sUrlApreAllegato, sIdAllegato)
				oLink.Visible = True
			End If
		Catch ex As Exception
		End Try
	End Sub

	Public Shared Function GetByteXmlCda(ByVal oAllegati As WcfDwhClinico.AllegatiType) As Byte()
		Dim oByte As Byte() = Nothing
		If Not oAllegati Is Nothing Then
			For Each oAllegato As WcfDwhClinico.AllegatoType In oAllegati
				If oAllegato.Posizione = 0 AndAlso
				   String.Compare(oAllegato.TipoContenuto, "text/xml", True) = 0 AndAlso
				   System.IO.Path.GetFileNameWithoutExtension(oAllegato.NomeFile).ToUpper.EndsWith("_CDA") Then
					oByte = oAllegato.Contenuto
					Exit For
				End If
			Next
		End If
		Return oByte
	End Function


	Public Shared Function GetByteAllegatoXml(ByVal oAllegati As WcfDwhClinico.AllegatiType) As Byte()
		'TODO: verificare se la logica di ricerca degli allegati può andare bene, altrimenti bisogna aggiungere ulteriore colonna di configurazione: NomeAllegatoTerminaCon
		'
		' La ricerca degli allegati XML: CEDAP, ONCONET, SitAsmn_01_00, EIM2_02_00, ESD_ASMN_02_00  si deve cercare il nome che finisce con _XML
		' La ricerca degli allegati XML: RadioTerapia_02_00  si cerca il primo XML 
		'
		Dim oByte As Byte() = Nothing
		If Not oAllegati Is Nothing Then
			'
			' Prima cerco allegato con nome che finisce con _XML
			'
			For Each oAllegato As WcfDwhClinico.AllegatoType In oAllegati
				If String.Compare(oAllegato.TipoContenuto, "text/xml", True) = 0 AndAlso
				   System.IO.Path.GetFileNameWithoutExtension(oAllegato.NomeFile).ToUpper.EndsWith("_XML") Then
					oByte = oAllegato.Contenuto
					Exit For
				End If
			Next

			If oByte Is Nothing Then
				'
				' Se non ho trovato nulla cerco il primo allegato XML
				'
				For Each oAllegato As WcfDwhClinico.AllegatoType In oAllegati
					If String.Compare(oAllegato.TipoContenuto, "application/xml", True) = 0 Then
						oByte = oAllegato.Contenuto
						Exit For
					End If
				Next
			End If
		End If
		Return oByte
	End Function

	Public Shared Function GetByteAllegatoXml_2(ByVal oAllegati As WcfDwhClinico.AllegatiType, sPatternNomeAllegato As String) As Byte()
		'
		' La ricerca degli allegati XML: CEDAP, ONCONET, SitAsmn_01_00, EIM2_02_00, ESD_ASMN_02_00  si deve cercare il nome che finisce con _XML
		' La ricerca degli allegati XML: RadioTerapia_02_00  si cerca il primo XML 
		' "application/xml" vale solo per RadioTerapia_02_00
		'
		Dim oByte As Byte() = Nothing
		If Not oAllegati Is Nothing Then
			For Each oAllegato As WcfDwhClinico.AllegatoType In oAllegati
				If (String.Compare(oAllegato.TipoContenuto, "text/xml", True) = 0 OrElse String.Compare(oAllegato.TipoContenuto, "application/xml", True) = 0) AndAlso IsLike(oAllegato.NomeFile, sPatternNomeAllegato) Then
					oByte = oAllegato.Contenuto
					Exit For
				End If
			Next
		End If
		Return oByte
	End Function

	Private Shared Function IsLike(ByVal sValue As String, sPattern As String) As Boolean
		'Uso il ToUpper per non utilizzare l'Option Compare
		sValue = sValue.ToUpper
		sPattern = sPattern.ToUpper
		Return sValue Like sPattern
	End Function


	Public Shared Function GetByteAllegatoRTF(ByVal oAllegati As WcfDwhClinico.AllegatiType) As Byte()
		Dim oByte As Byte() = Nothing
		If Not oAllegati Is Nothing Then
			'
			' Prima cerco allegato con nome che finisce con _XML
			'
			For Each oAllegato As WcfDwhClinico.AllegatoType In oAllegati
				If String.Compare(oAllegato.TipoContenuto, "application/rtf", True) = 0 Then
					oByte = oAllegato.Contenuto
					Exit For
				End If
			Next
		End If
		Return oByte
	End Function


	Public Shared Function IsTextRtf(ByVal sValue As String) As Boolean
		'
		' Un testo RTF inizia con "{\rtf"
		'
		Dim bRet As Boolean = False
		If Not String.IsNullOrEmpty(sValue) Then
			'Tolgo eventuali spazi iniziali e memorizzo i primi 5 caratteri
			Dim s As String = sValue.TrimStart(" ").Substring(0, 5)
			If String.Compare(s, "{\rtf", True) = 0 Then
				bRet = True
			End If
		End If
		'
		'
		'
		Return bRet
	End Function


	Public Shared Function GetHtmlFromRtf(ByVal sReferto As String) As String
		'1) lo leggo e lo converto in HTML e lo visualizzo. Devo anche aggiungere una label per il titolo: "Referto:"
		Dim oArrayRtf As Byte() = System.Text.Encoding.UTF8.GetBytes(sReferto)
		Dim oAspose As New AsposeUtil
		Dim oDoc As Aspose.Words.Document = oAspose.DocumentCreate(oArrayRtf)
		oAspose.ExportImageAsBase64 = True
		Dim oArrayHtml As Byte() = oAspose.DocumentConvertToByteArray(oDoc, Aspose.Words.SaveFormat.Html)
		Return System.Text.Encoding.UTF8.GetString(oArrayHtml)
	End Function

	Public Shared Function GetAttributoValue(ByVal sNomeAttributo As String, oAttributi As WcfDwhClinico.AttributiType) As String
		Dim sValue As String = String.Empty
		' Eseguo il ToUpper
		Dim sNomeAttributo_Upper As String = sNomeAttributo.ToUpper
		If Not oAttributi Is Nothing AndAlso oAttributi.Count > 0 Then
			Dim oListValues As List(Of String) = (From i In oAttributi Where i.Nome.ToUpper = sNomeAttributo_Upper Select i.Valore).ToList
			If Not oListValues Is Nothing AndAlso oListValues.Count > 0 Then
				sValue = oListValues(0)
			End If
		End If
		'
		'
		'
		Return sValue
	End Function



#Region "Per visualizzazione di METAFORA"

	Public Shared Function METAFORA_BuildLinkMatricePrestazioni(ByVal sHtmlCDA As String, ByVal sXmlreferto As String, ByVal IdPaziente As String, ByVal bAccessoDiretto As Boolean) As String
		Dim sRet As String = String.Empty
		Try
			Dim oCollPrestazioni As System.Collections.Hashtable = METAFORA_GetSezioneDescrizione_Prestazioni_Lacc(sXmlreferto)
			sRet = METAFORA_AddLinkPrestazioniMatrice(sHtmlCDA, IdPaziente, oCollPrestazioni, bAccessoDiretto)
		Catch ex As Exception
			'
			' Restituisco l'originale
			'
			sRet = sHtmlCDA
		End Try
		'
		'
		'
		Return sRet
	End Function

	Private Shared Function METAFORA_GetSezioneDescrizione_Prestazioni_Lacc(ByVal sXmlReferto As String) As Hashtable
		'
		' Questa funziona solo per versione WS2
		'
		Dim sSezioneDescrizione As String = String.Empty
		Dim sSezioneCodice As String = String.Empty
		Dim oCollPrestazioni As New System.Collections.Hashtable
		Dim oDoc As New System.Xml.XmlDocument
		oDoc.LoadXml(sXmlReferto)

		Dim oNsMan As System.Xml.XmlNamespaceManager = New System.Xml.XmlNamespaceManager(oDoc.NameTable)
		oNsMan.AddNamespace("My", "http://dwhClinico.org/dataResult/2")
		'
		' Prendo tutte le "Prestazioni" che hanno "PrestazioniAttributi/PrestTipo" <> M o non hanno l'attributo "PrestazioniAttributi/PrestTipo"
		'
		Dim oNodes As System.Xml.XmlNodeList = oDoc.SelectNodes("//Root/SezioneReferto/My:Referto/My:Prestazioni[  count(  My:PrestazioniAttributi[My:Nome='PrestTipo'   and My:Valore ='M' ] )=0  ]", oNsMan)
		For Each oNode As System.Xml.XmlNode In oNodes
			Dim oNodeSezioneDescrizione As System.Xml.XmlNode = oNode.SelectSingleNode("My:SezioneDescrizione", oNsMan)
			Dim oNodeSezioneCodice As System.Xml.XmlNode = oNode.SelectSingleNode("My:SezioneCodice", oNsMan)
			If (Not oNodeSezioneDescrizione Is Nothing) AndAlso (Not oNodeSezioneCodice Is Nothing) Then
				sSezioneDescrizione = oNodeSezioneDescrizione.InnerText
				sSezioneCodice = oNodeSezioneCodice.InnerText
				If (Not String.IsNullOrEmpty(sSezioneDescrizione)) AndAlso (Not oNodeSezioneCodice Is Nothing) Then
					If Not oCollPrestazioni.Contains(sSezioneDescrizione) Then
						oCollPrestazioni.Add(sSezioneDescrizione, sSezioneCodice)
					End If
				End If
			End If
		Next

		Return oCollPrestazioni
	End Function


	Private Shared Function METAFORA_AddLinkPrestazioniMatrice(ByVal sHtmlCDA As String, ByVal IdPaziente As String, ByVal oCollPrestazioni As Hashtable, ByVal bAccessoDiretto As Boolean) As String
		'
		' Sostituisco in sHtmlCDA i testi uguali a Key con l'opportuno link 
		'
		Const LINK As String = "<a href='{0}' target=_top>{1}</a>"

		Dim sUrlPrestazioni0 As String = "/Dwhclinico/Referti/MatricePrestazioniBySezioneCodice.aspx?IdPaziente={0}&SezioneCodice={1}"
		If bAccessoDiretto Then
			sUrlPrestazioni0 = "/Dwhclinico/AccessoDiretto/MatricePrestazioniBySezioneCodice.aspx?IdPaziente={0}&SezioneCodice={1}"
		End If

		Try
			'
			' Ripulisco da caratteri di ritorno a capo
			'
			sHtmlCDA = Replace(sHtmlCDA, vbCrLf, String.Empty, , , CompareMethod.Text)
			sHtmlCDA = Replace(sHtmlCDA, vbCr, String.Empty, , , CompareMethod.Text)
			sHtmlCDA = Replace(sHtmlCDA, vbLf, String.Empty, , , CompareMethod.Text)
			'
			'
			'
			For Each sSezioneDescrizione As String In oCollPrestazioni.Keys
				Dim sSezioneCodice As String = oCollPrestazioni.Item(sSezioneDescrizione).ToString
				Dim sUrlPrestazioni As String = String.Format(sUrlPrestazioni0, IdPaziente, sSezioneCodice)
				Dim sLink As String = String.Format(LINK, sUrlPrestazioni, sSezioneDescrizione)
				'
				' Sostituzione con Replace: se cambiano lo stylesheet, cioè modificano le intestazioni di sezione in modo tale che
				' non siano più comprese fra "<tr><td><b>" e "</b></td></tr>" questa smette di funzionare
				' Poichè siamo noi a verificare lo stylesheet prima di metterlo in produzione questa eventualità può essere controllata
				'
				'sHtmlCDA = Replace(sHtmlCDA, "<tr><td><b>" & sSezioneDescrizione & "</b></td></tr>", "<tr><td><b>" & sLink & "</b></td></tr>", , , CompareMethod.Text)
				sHtmlCDA = Replace(sHtmlCDA, "<td><b>" & sSezioneDescrizione & "</b></td>", "<td><b>" & sLink & "</b></td>", , , CompareMethod.Text)

				'-------------------------------------------------------------------------------------------------------------------------
				' Sostituzione whole word ORIGINALE: questa da errore se ci sonmo delle parentesi non bilanciate e non esegue la sostituzione se vi sono delle parentesi
				' sHtmlCDA = RegularExpressions.Regex.Replace(sHtmlCDA, "\b" & sSezioneDescrizione & "\b", sLink, RegexOptions.IgnoreCase)
				'-------------------------------------------------------------------------------------------------------------------------

				'-------------------------------------------------------------------------------------------------------------------------
				' Questa funziona ma sostituisce tutte le occorrenze di una parola sia che sia la sezione o la prestazione
				'-------------------------------------------------------------------------------------------------------------------------
				'Try
				'    sSezioneDescrizione = System.Text.RegularExpressions.Regex.Escape(sSezioneDescrizione)
				'    sHtmlCDA = RegularExpressions.Regex.Replace(sHtmlCDA, "\b" & sSezioneDescrizione & "(?:\b|(?![A-Za-z0-9]))", sLink, RegexOptions.IgnoreCase)
				'Catch ex As Exception
				'    Dim sMsg As String = String.Format("Errore Regular Expression durante la costruzione dei link alle prestazioni per il referto CDA '{0}':", mIdreferto)
				'    sMsg = sMsg & vbCrLf & ex.Message & vbCrLf & vbCrLf & Util.AdditionalInfoOnError()
				'    My.Application.Log.WriteEntry(sMsg, TraceEventType.Warning)
				'End Try
				'-------------------------------------------------------------------------------------------------------------------------
			Next
		Catch ex As Exception
		End Try
		'
		' Restituisco
		'
		Return sHtmlCDA
	End Function
#End Region
#End Region


	Public Shared Function AccessoDirettoPannelloPazientVisibility(oQueryString As NameValueCollection) As Boolean
		' Leo: controllo da query String il parametro ShowPanelloPaziente, ritorno se bisogna nascondere il pannello o no
		Dim bRet As Boolean = True
		Dim sShowPannelloPaziente As String = oQueryString("ShowPannelloPaziente")
		If Not String.IsNullOrEmpty(sShowPannelloPaziente) Then
			Dim bShowPannelloPaziente As Boolean = True
			If Boolean.TryParse(sShowPannelloPaziente, bShowPannelloPaziente) Then
				bRet = bShowPannelloPaziente
			End If
		End If
		'
		' 
		'
		Return bRet
	End Function


End Class

#Region "Lettura consensi paziente da WS-Pazienti SAC"

''' <summary>
''' Enumera i valori del consenso minimo che il paziente ha accordato
''' </summary>
''' <remarks>Sono gli stessi valori restituiti dalla funzione SqlServer dbo.GetPazientiConsensoMinimo()</remarks>
Public Enum ConsensoMinimoAccordato
	Nessuno '0
	Generico '1
	Dossier '2
	DossierStorico '3
End Enum

'
' Usata per implementare le nuove regole di accesso ai dati baste sul consenso GENERICO, DOSSIER, DOSSIERSTORICO
'
Public Enum ConsensoStato
	Negato '0
	Accordato '1
	NonAcquisito '2
End Enum

''' <summary>
''' Classe che descrive il consenso SAC
''' </summary>
''' <remarks></remarks>
Public Class Consenso
	Public Property IdTipo As SacConsensiDataAccess.TipoConsenso
	Public Property Tipo As String
	Public Property Stato As ConsensoStato = ConsensoStato.NonAcquisito
	Public Property DataStato As Nullable(Of DateTime)
	Public Property OperatoreId As String
	Public Property OperatoreCognome As String
	Public Property OperatoreNome As String
	Public Property OperatoreComputer As String
End Class

''' <summary>
''' Classe che descrive il paziente SAC, usata in particolare per la rilevazione dei consensi
''' </summary>
''' <remarks></remarks>
Public Class SacDettaglioPaziente
	Public Const TIPO_GENERICO = "Generico"
	Public Const TIPO_DOSSIER = "Dossier"
	Public Const TIPO_DOSSIER_STORICO = "DossierStorico"

	Public Property Provenienza As String
	Public Property IdProvenienza As String
	Public Property IdPaziente As Guid
	Public Property Cognome As String = String.Empty
	Public Property Nome As String = String.Empty
	Public Property DataNascita As Nullable(Of DateTime)
	Public Property CodiceFiscale As String = String.Empty
	Public Property DataDecesso As Nullable(Of DateTime)
	Public Property LuogoNascita As String = String.Empty
	Public Property CodiceSanitario As String = String.Empty
	Public Property Consensi As New Dictionary(Of String, Consenso)

	Public Function GetConsensoGenerico() As Consenso
		For Each sKey As String In Me.Consensi.Keys
			If sKey = TIPO_GENERICO.ToUpper Then
				Return Me.Consensi(sKey)
			End If
		Next
		Return Nothing
	End Function

	Public Function GetConsensoDossier() As Consenso
		For Each sKey As String In Me.Consensi.Keys
			If sKey = TIPO_DOSSIER.ToUpper Then
				Return Me.Consensi(sKey)
			End If
		Next
		Return Nothing
	End Function

	Public Function GetConsensoDossierStorico() As Consenso
		For Each sKey As String In Me.Consensi.Keys
			If sKey = TIPO_DOSSIER_STORICO.ToUpper Then
				Return Me.Consensi(sKey)
			End If
		Next
		Return Nothing
	End Function


	Private Const SESSION_NAME As String = "SacDettaglioPaziente"

	Public Shared Property Session(ByVal IdPaziente As Guid) As SacDettaglioPaziente

		Get
			Dim sCacheKey As String = SESSION_NAME & HttpContext.Current.User.Identity.Name & IdPaziente.ToString
			Return CType(HttpContext.Current.Cache.Item(sCacheKey), SacDettaglioPaziente)
		End Get
		Set(value As SacDettaglioPaziente)
			Dim sCacheKey As String = SESSION_NAME & HttpContext.Current.User.Identity.Name & IdPaziente.ToString
			If value Is Nothing Then
				HttpContext.Current.Cache.Remove(sCacheKey)
			Else
				'Bisogna definire il tempo
				HttpContext.Current.Cache.Insert(sCacheKey, value, Nothing, DateTime.UtcNow.AddMinutes(5), System.Web.Caching.Cache.NoSlidingExpiration)
			End If

		End Set
	End Property

End Class

''' <summary>
''' Classe per la lettura tramite WS-paziente SAC dei dati del paziente
''' </summary>
''' <remarks></remarks>
<System.ComponentModel.DataObject(True)>
Public Class PazienteSac
	<System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select)>
	Public Function GetData(ByVal sIdPazienteSAC As String) As SacDettaglioPaziente
		Try
			Dim oSacPazientiWs As SacPazientiDataAccess.PazientiSoapClient = Nothing
			Dim oSacDettaglioPaziente As SacDettaglioPaziente = Nothing

			oSacPazientiWs = New SacPazientiDataAccess.PazientiSoapClient

			If oSacPazientiWs Is Nothing Then
				Throw New Exception("Errore: il Web Service SacPazientiDataAccess.Pazienti è nothing.")
			End If
			'
			' Imposto le credenziali
			'
			Call Utility.SetWsPazientiCredential(oSacPazientiWs)
			'
			' Eseguo la chiamata
			'
			Dim oPazienteResponse As SacPazientiDataAccess.PazientiDettaglio2ByIdResponsePazientiDettaglio2()
			oPazienteResponse = oSacPazientiWs.PazientiDettaglio2ById(sIdPazienteSAC)

			If Not oPazienteResponse Is Nothing AndAlso oPazienteResponse.Length > 0 Then
				oSacDettaglioPaziente = New SacDettaglioPaziente()

				oSacDettaglioPaziente.Provenienza = oPazienteResponse(0).Provenienza
				oSacDettaglioPaziente.IdProvenienza = oPazienteResponse(0).IdProvenienza

				oSacDettaglioPaziente.IdPaziente = New Guid(oPazienteResponse(0).Id)
				oSacDettaglioPaziente.Cognome = oPazienteResponse(0).Cognome
				oSacDettaglioPaziente.Nome = oPazienteResponse(0).Nome
				If oPazienteResponse(0).DataNascita <> Nothing Then
					oSacDettaglioPaziente.DataNascita = oPazienteResponse(0).DataNascita
				End If
				oSacDettaglioPaziente.CodiceFiscale = oPazienteResponse(0).CodiceFiscale
				If oPazienteResponse(0).DataDecesso <> Nothing Then
					oSacDettaglioPaziente.DataDecesso = oPazienteResponse(0).DataDecesso
				End If
				oSacDettaglioPaziente.LuogoNascita = oPazienteResponse(0).ComuneNascitaNome
				oSacDettaglioPaziente.CodiceSanitario = oPazienteResponse(0).Tessera
				'
				' Popolo la parte dei consensi
				'
				Dim oArrayConsensi As SacPazientiDataAccess.PazientiDettaglio2ByIdResponsePazientiDettaglio2PazientiDettaglio2Consensi() = oPazienteResponse(0).PazientiDettaglio2Consensi()
				If Not oArrayConsensi Is Nothing Then
					'
					' MI ASSICURO COMUNQUE DI AVERE UNA LISTA UNIVOCA PER TIPO DI CONSENSO 
					' Rendo univoca la lista dei consensi: per ogni tipo GENRICO, DOSSIER, DOSSIERSTORICO memorizzo quello con DataStato maggiore
					' (il web service dovrebbe già restituire cosi i dati: per ogni tipo di consenso quello a datastato max)
					'   - ordino per DataStato DESCENDING e poi aggiungo il consenso solo se non esiste
					'
					Dim orderedArrayConsensi = oArrayConsensi.OrderByDescending(Function(e) e.DataStato)
					For Each item As SacPazientiDataAccess.PazientiDettaglio2ByIdResponsePazientiDettaglio2PazientiDettaglio2Consensi In orderedArrayConsensi
						Dim sTipo As String = item.Tipo.ToUpper
						If sTipo = SacDettaglioPaziente.TIPO_GENERICO.ToUpper OrElse
							sTipo = SacDettaglioPaziente.TIPO_DOSSIER.ToUpper OrElse
							sTipo = SacDettaglioPaziente.TIPO_DOSSIER_STORICO.ToUpper Then

							Dim oConsenso As New Consenso

							If sTipo = SacDettaglioPaziente.TIPO_GENERICO.ToUpper Then
								oConsenso.IdTipo = SacConsensiDataAccess.TipoConsenso.Generico
							ElseIf sTipo = SacDettaglioPaziente.TIPO_DOSSIER.ToUpper Then
								oConsenso.IdTipo = SacConsensiDataAccess.TipoConsenso.Dossier
							ElseIf sTipo = SacDettaglioPaziente.TIPO_DOSSIER_STORICO.ToUpper Then
								oConsenso.IdTipo = SacConsensiDataAccess.TipoConsenso.DossierStorico
							End If

							oConsenso.Tipo = item.Tipo
							If item.Stato Then
								oConsenso.Stato = ConsensoStato.Accordato
							Else
								oConsenso.Stato = ConsensoStato.Negato
							End If
							oConsenso.DataStato = item.DataStato
							oConsenso.OperatoreId = item.OperatoreId
							oConsenso.OperatoreCognome = item.OperatoreCognome
							oConsenso.OperatoreNome = item.OperatoreNome
							oConsenso.OperatoreComputer = item.OperatoreComputer
							'
							' Aggiungo alla lista
							'
							If Not oSacDettaglioPaziente.Consensi.Keys.Contains(sTipo) Then
								oSacDettaglioPaziente.Consensi.Add(sTipo, oConsenso)
							End If
						End If
					Next
				End If
				'
				' Verifico se ho trovato i possibili consensi e se no inizializzo i mancanti con NON ACQUISITO
				'
				If Not oSacDettaglioPaziente.Consensi.Keys.Contains(SacDettaglioPaziente.TIPO_GENERICO.ToUpper) Then
					Dim oConsenso As New Consenso
					oConsenso.IdTipo = SacConsensiDataAccess.TipoConsenso.Generico
					oConsenso.Tipo = SacDettaglioPaziente.TIPO_GENERICO
					oConsenso.Stato = ConsensoStato.NonAcquisito
					oSacDettaglioPaziente.Consensi.Add(SacDettaglioPaziente.TIPO_GENERICO.ToUpper, oConsenso)
				End If
				If Not oSacDettaglioPaziente.Consensi.Keys.Contains(SacDettaglioPaziente.TIPO_DOSSIER.ToUpper) Then
					Dim oConsenso As New Consenso
					oConsenso.IdTipo = SacConsensiDataAccess.TipoConsenso.Dossier
					oConsenso.Tipo = SacDettaglioPaziente.TIPO_DOSSIER
					oConsenso.Stato = ConsensoStato.NonAcquisito
					oSacDettaglioPaziente.Consensi.Add(SacDettaglioPaziente.TIPO_DOSSIER.ToUpper, oConsenso)
				End If
				If Not oSacDettaglioPaziente.Consensi.Keys.Contains(SacDettaglioPaziente.TIPO_DOSSIER_STORICO.ToUpper) Then
					Dim oConsenso As New Consenso
					oConsenso.IdTipo = SacConsensiDataAccess.TipoConsenso.DossierStorico
					oConsenso.Tipo = SacDettaglioPaziente.TIPO_DOSSIER_STORICO
					oConsenso.Stato = ConsensoStato.NonAcquisito
					oSacDettaglioPaziente.Consensi.Add(SacDettaglioPaziente.TIPO_DOSSIER_STORICO.ToUpper, oConsenso)
				End If

				Return oSacDettaglioPaziente
			Else
				Return Nothing
			End If
		Catch ex As Exception
			'
			' Errore
			'
			Logging.WriteError(ex, Me.GetType.Name)
			Throw
		End Try
	End Function

    Public Function GetDettaglioPaziente(ByVal sIdPazienteSAC As String) As SacPazientiDataAccess.PazientiDettaglio2ByIdResponsePazientiDettaglio2
        Try
            Dim oSacPazientiWs As SacPazientiDataAccess.PazientiSoapClient = Nothing
            Dim oSacDettaglioPaziente As SacDettaglioPaziente = Nothing

            oSacPazientiWs = New SacPazientiDataAccess.PazientiSoapClient

            If oSacPazientiWs Is Nothing Then
                Throw New Exception("Errore: il Web Service SacPazientiDataAccess.Pazienti è nothing.")
            End If
            '
            ' Imposto le credenziali
            '
            Call Utility.SetWsPazientiCredential(oSacPazientiWs)
            '
            ' Eseguo la chiamata
            '
            Dim oPazienteResponse As SacPazientiDataAccess.PazientiDettaglio2ByIdResponsePazientiDettaglio2()
            oPazienteResponse = oSacPazientiWs.PazientiDettaglio2ById(sIdPazienteSAC)

            If Not oPazienteResponse Is Nothing AndAlso oPazienteResponse.Length > 0 Then
                Return oPazienteResponse(0)
            Else
                Return Nothing
            End If

        Catch ex As Exception
            '
            ' Errore
            '
            Logging.WriteError(ex, Me.GetType.Name)
            Throw
        End Try
    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select)>
	Public Function GetData(ByVal IdPazienteSAC As Guid) As SacDettaglioPaziente
		Return GetData(IdPazienteSAC.ToString)
	End Function

End Class


#End Region
