Imports System
Imports System.Globalization
Imports DI.OrderEntry.Services
Imports System.Linq
Imports System.Collections.Generic
Imports System.Net
Imports System.ServiceModel
Imports System.Configuration
Imports DI.OrderEntry.User
Imports DI.PortalUser2.Data
Imports DI.OrderEntry.SacServices

Public Class Utility

	Public Const SESS_DATI_ULTIMO_ACCESSO As String = "ULTIMO_ACCESSO"  'usata per visualizzare i dati di ultimo accesso nel box delle info utente
	Private Const SESS_HOST_NAME As String = "-HOST_NAME-"
	Public Const PAR_DI_PORTAL_USER_CONNECTION_STRING As String = "DiPortalUser.ConnectionString"
	Public Const ErrorMessage As String = "Si è verificato un errore, contattare l'amministratore del sito"

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

	''' <summary>
	''' Naviga alla pagina di errore per l'accesso standard
	''' </summary>
	Public Shared Sub NavigateToErrorPage(enumErrorCode As Utility.ErrorCode, sErroreDescrizione As String, endResponse As Boolean)
		DI.OrderEntry.User.ErrorPage.SetErrorDescription(enumErrorCode, sErroreDescrizione)
		HttpContext.Current.Response.Redirect("~/ErrorPage.aspx", endResponse)
	End Sub


	''' <summary>
	''' Testo se siamo nel contesto dell'accesso diretto ed eventualmente cambio gli url di reindirizzamento
	''' </summary>
	''' <param name="sUrl"></param>
	''' <returns></returns>
	Shared Function buildUrl(sUrl As String, isAccessoDiretto As Boolean) As String
		If isAccessoDiretto Then
			sUrl = sUrl.Replace("/Pages", "/AccessoDiretto/Pages")
			sUrl = sUrl.Replace(".aspx", "")
		End If
		Return sUrl
	End Function

	''' <summary>
	''' 
	''' </summary>
	''' <param name="IdProvenienza"></param>
	''' <param name="Provenienza"></param>
	''' <returns></returns>
	Shared Function GetIdPazienteByProvenienza(IdProvenienza As String, Provenienza As String) As String
		Dim IdPaziente As String = String.Empty
		Try

			If Not String.IsNullOrEmpty(IdProvenienza) AndAlso Not String.IsNullOrEmpty(Provenienza) Then
				'
				'Ottengo l'id del paziente da IdProvenienza e Provenienza
				'
				Using SoapClient As New DI.OrderEntry.SacServices.PazientiSoapClient("PazientiSoap")
					Dim provenienzaRequest As New DI.OrderEntry.SacServices.PazientiDettaglio2ByIdProvenienzaRequest With {.idProvenienza = IdProvenienza, .provenienza = Provenienza}

					Dim response As PazientiDettaglio2ByIdProvenienzaResponse = SoapClient.PazientiDettaglio2ByIdProvenienza(provenienzaRequest)
					Dim dettPaziente As PazientiDettaglio2ByIdProvenienzaResponsePazientiDettaglio2 = response.PazientiDettaglio2ByIdProvenienzaResult.First

					IdPaziente = dettPaziente.Id
				End Using
			End If
		Catch ex As Exception
			ExceptionsManager.TraceException(ex)
			Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
			portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
			Throw
		End Try
		Return IdPaziente
	End Function

	Public Shared Sub CheckShowHeaderParam(ByRef Request As HttpRequest)
		Dim showHeader As String = Request.QueryString("ShowHeader")
		Try
			If Not String.IsNullOrEmpty(showHeader) Then
				Dim bShowHeader As Boolean = True
				If Boolean.TryParse(showHeader, bShowHeader) Then
					SessionHandler.ShowHeader = showHeader
				End If
			End If
		Catch ex As Exception
			ExceptionsManager.TraceException(ex)
			Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
			portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
			Throw
		End Try
	End Sub


	''' <summary>
	''' Restituisce l'id del paziente partendo dal Nosologico e dalla Azienda.
	''' </summary>
	''' <param name="nosologico"></param>
	''' <param name="azienda"></param>
	''' <returns></returns>
	Public Shared Function GetIdPazienteByNosologico(Nosologico As String, Azienda As String) As String
		Dim idPaziente As String = String.Empty

		Try
			If Not String.IsNullOrEmpty(Nosologico) AndAlso Not String.IsNullOrEmpty(Azienda) Then
				'2015-05-07:  SU INDICAZIONE DI CORRADO VIENE UTILIZZATO IL PRIMO CODICE AZIENDA
				'  CHE TROVO NELLE UNITA' OPERATIVE LEGATE AL RUOLO CORRENTE
				'  SI DA PER SCONTATO CHE IL RUOLO DEBBA ESSERE MONO AZIENDA
				Dim customDataSource As New CustomDataSource.UnitaOperative
				Dim unitaOperative As List(Of UnitaOperativa) = customDataSource.GetData()
				If unitaOperative.Count = 0 Then
					'
					'l'utente non ha i permessi sulle UO
					'
					Throw New Exception("Nessuna unità operativa configurata per il ruolo corrente.")
				End If

				Nosologico = Nosologico.Trim()

				Dim oEpisodio As WcfDwhClinico.EpisodioType = CustomDataSourceDettaglioPaziente.GetDatiRicoveroByNosologicoAzienda(Nosologico, Azienda)

				If oEpisodio Is Nothing Then
					Throw New ApplicationException("Il nosologico è inesistente.")
				Else
					If oEpisodio.DataConclusione.HasValue AndAlso oEpisodio.DataConclusione.Value.AddDays(My.Settings.IntervalloChiusuraRicovero) <= DateTime.Now Then
						Throw New ApplicationException("Il ricovero è chiuso.")
					End If

					'prendo l'ultimo evento in ordine cronologico che ha valorizzato il reparto codice
					Dim RepartoCodice = String.Empty

					' Se il paziente è dimesso allora lo prendo da StrutturaConclusione altrimenti lo prendo da StrutturaUltimoEvento.
					If oEpisodio.StrutturaConclusione IsNot Nothing Then
						RepartoCodice = oEpisodio.StrutturaConclusione.Codice
					ElseIf oEpisodio.StrutturaUltimoEvento IsNot Nothing Then
						RepartoCodice = oEpisodio.StrutturaUltimoEvento.Codice
					Else
						Throw New ApplicationException("Per questo nosologico non è stato valorizzato il reparto di ricovero.")
					End If


					'controllo autorizzazioni sul reparto per il ruolo corrente
					'Dim found = (From unita In unitaOperative
					'             Where String.Equals(unita.CodiceUO, azienda & "-" & RepartoCodice, StringComparison.CurrentCultureIgnoreCase)).ToArray().Count > 0
					Dim found = (From unita In unitaOperative
								 Where String.Equals(unita.CodiceUO, Azienda & "-" & RepartoCodice, StringComparison.CurrentCultureIgnoreCase))

					If found.ToArray.Count > 0 Then
						Return oEpisodio.IdPaziente & "§" & RepartoCodice
					Else
						Throw New ApplicationException("L'utente corrente non è abilitato alla creazione di un ordine per il reparto relativo al nosologico specificato.")
					End If
				End If
			End If

		Catch ex As CustomException(Of WcfDwhClinico.ErroreType)
			'
			' Eseguito solo se l'errore è restituito dalla chiamata al metodo del ws.
			'
			ExceptionsManager.TraceException(ex)
			Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
			portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
			Throw
		Catch ex As Exception
			ExceptionsManager.TraceException(ex)
			Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
			portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
			Throw
		End Try

		Return idPaziente
	End Function

	Public Shared Function GetStringFormatFromDataType(value As String, dataType As TipoDatoAccessorioEnum) As String

		If String.IsNullOrEmpty(value) Then
			Return value
		End If

		Select Case dataType
			Case TipoDatoAccessorioEnum.DateBox
				Return DateTime.Parse(value).ToString("yyyy-MM-dd", CultureInfo.InvariantCulture)

			Case TipoDatoAccessorioEnum.DateTimeBox
				Return DateTime.Parse(value).ToString("yyyy-MM-ddTHH:mm:ss", CultureInfo.InvariantCulture)

			Case TipoDatoAccessorioEnum.TimeBox
				Return DateTime.Parse(value).ToString("HH:mm:ss", CultureInfo.InvariantCulture)

			Case TipoDatoAccessorioEnum.FloatBox
				Return value.Replace(","c, "."c)

			Case Else
				Return value
		End Select
	End Function

	Public Shared Function GetFormattedValueFromDataType(value As String, dataType As TipoDatoAccessorioEnum) As String
		Dim sReturn As String = value

		Dim dt As DateTime

		Select Case dataType
			Case TipoDatoAccessorioEnum.DateBox
				If DateTime.TryParse(value, dt) Then
					sReturn = dt.ToString("dd/MM/yyyy", New CultureInfo("it-IT")).Replace("."c, ":"c)
				End If
			Case TipoDatoAccessorioEnum.DateTimeBox
				If DateTime.TryParse(value, dt) Then
					sReturn = dt.ToString("dd/MM/yyyy HH:mm:ss", New CultureInfo("it-IT")).Replace("."c, ":"c)
				End If
			Case TipoDatoAccessorioEnum.TimeBox
				If DateTime.TryParse(value, dt) Then
					sReturn = dt.ToString("HH:mm:ss", New CultureInfo("it-IT")).Replace("."c, ":"c)
				End If
			Case TipoDatoAccessorioEnum.FloatBox
				If Not String.IsNullOrEmpty(value) Then
					Return sReturn.Replace("."c, ","c)
				End If
		End Select

		Return sReturn
	End Function

	Public Shared Sub NormalizzaDatiAccessori(ByVal datiAccessori As List(Of DatiAggiuntiviType), ByVal domandeDatiAccessori As DatiAccessoriListaType)

		If datiAccessori.Count > 0 Then
			For Each dato As DatiAggiuntiviType In datiAccessori
				NormalizzaDatiAccessori(dato, domandeDatiAccessori)
			Next
		End If
	End Sub


	Public Shared Function GetErogante(Codice As String, Descrizione As String) As String
		Dim res As String = String.Empty
		Try
			res = String.Format("{0}-{1}", Codice, If(String.IsNullOrEmpty(Descrizione), Codice, Descrizione))
		Catch ex As Exception
			Throw New ApplicationException("Errore: " + ex.Message)
		End Try
		Return res
	End Function

	Public Shared Sub NormalizzaDatiAccessori(ByVal datiAccessori As DatiAggiuntiviType, ByVal domandeDatiAccessori As DatiAccessoriListaType)

		If datiAccessori IsNot Nothing AndAlso datiAccessori.Count > 0 Then

			For Each dato In datiAccessori

				If dato.DatoAccessorio Is Nothing Then

					Dim codice = dato.Nome.Split("_")(0)

					Dim datoAccessorio = domandeDatiAccessori.Where(Function(e) e.DatoAccessorio.Codice = codice).FirstOrDefault

					'dato.DatoAccessorio = datoAccessorio.DatoAccessorio

					If datoAccessorio IsNot Nothing AndAlso datoAccessorio.DatoAccessorio IsNot Nothing Then
						dato.DatoAccessorio = datoAccessorio.DatoAccessorio
					Else

						Dim datoAccessorioType As New DatoAccessorioType
						datoAccessorioType.Etichetta = dato.Nome
						dato.DatoAccessorio = datoAccessorioType
					End If

				End If

				dato.ValoreDato = Utility.GetFormattedValueFromDataType(dato.ValoreDato, dato.DatoAccessorio.Tipo)
			Next

			For Each datoAccessorio As DatoNomeValoreType In datiAccessori

				Dim valori = datoAccessorio.DatoAccessorio.Valori
				Dim codiceDescrizione = New Dictionary(Of String, String)()

				If Not String.IsNullOrEmpty(valori) Then

					Dim valoriCombo = valori.Split(New String() {"§;"}, StringSplitOptions.None)

					For Each elemento In valoriCombo

						Dim split = elemento.Split(New String() {"#;"}, StringSplitOptions.None)

						If split.Length > 1 Then

							codiceDescrizione.Add(split(0), split(1))
						Else
							codiceDescrizione.Add(split(0), split(0))
						End If
					Next

					Dim splitData = datoAccessorio.ValoreDato.Split(New String() {"§;"}, StringSplitOptions.None)
					If splitData.Length = 1 AndAlso codiceDescrizione.ContainsKey(datoAccessorio.ValoreDato) Then

						datoAccessorio.ValoreDato = codiceDescrizione(datoAccessorio.ValoreDato)
					Else
						Dim descriptions = From value In splitData
										   Where codiceDescrizione.ContainsKey(value)
										   Select codiceDescrizione(value)

						datoAccessorio.ValoreDato = String.Join(", ", descriptions.ToArray())
					End If
				End If
			Next
		End If


	End Sub

	Public Shared Sub NormalizzaDatiPersistenti(ByVal datiPersistenti As List(Of DatiPersistentiType), ByVal domandeDatiAccessori As DatiAccessoriListaType)

		If datiPersistenti.Count > 0 Then
			For Each dato As DatiPersistentiType In datiPersistenti
				NormalizzaDatiPersistenti(dato, domandeDatiAccessori)
			Next
		End If
	End Sub

	Public Shared Sub NormalizzaDatiPersistenti(ByVal datiPersistenti As DatiPersistentiType, ByVal domandeDatiAccessori As DatiAccessoriListaType)

		If datiPersistenti IsNot Nothing AndAlso datiPersistenti.Count > 0 Then

			For Each dato In datiPersistenti

				If dato.DatoAccessorio Is Nothing Then

					Dim codice = dato.Nome.Split("_")(0)

					Dim datoAccessorio = domandeDatiAccessori.Where(Function(e) e.DatoAccessorio.Codice = codice).FirstOrDefault

					'dato.DatoAccessorio = datoAccessorio.DatoAccessorio

					If datoAccessorio IsNot Nothing AndAlso datoAccessorio.DatoAccessorio IsNot Nothing Then
						dato.DatoAccessorio = datoAccessorio.DatoAccessorio
					Else

						Dim datoAccessorioType As New DatoAccessorioType
						datoAccessorioType.Etichetta = dato.Nome
						dato.DatoAccessorio = datoAccessorioType
					End If

				End If

				dato.ValoreDato = Utility.GetFormattedValueFromDataType(dato.ValoreDato, dato.DatoAccessorio.Tipo)
			Next

			For Each datoAccessorio As DatoNomeValoreType In datiPersistenti

				Dim valori = datoAccessorio.DatoAccessorio.Valori
				Dim codiceDescrizione = New Dictionary(Of String, String)()

				If Not String.IsNullOrEmpty(valori) Then

					Dim valoriCombo = valori.Split(New String() {"§;"}, StringSplitOptions.None)

					For Each elemento In valoriCombo

						Dim split = elemento.Split(New String() {"#;"}, StringSplitOptions.None)

						If split.Length > 1 Then

							codiceDescrizione.Add(split(0), split(1))
						Else
							codiceDescrizione.Add(split(0), split(0))
						End If
					Next

					Dim splitData = datoAccessorio.ValoreDato.Split(New String() {"§;"}, StringSplitOptions.None)
					If splitData.Length = 1 AndAlso codiceDescrizione.ContainsKey(datoAccessorio.ValoreDato) Then

						datoAccessorio.ValoreDato = codiceDescrizione(datoAccessorio.ValoreDato)
					Else
						Dim descriptions = From value In splitData
										   Where codiceDescrizione.ContainsKey(value)
										   Select codiceDescrizione(value)

						datoAccessorio.ValoreDato = String.Join(", ", descriptions.ToArray())
					End If
				End If
			Next
		End If

	End Sub

	'TODO : funzione da eliminare a favore del nuovo metodo di logging
#Region "Trace"

	''' <summary>
	''' Funzione per scrivere nel trace (si visualizza con DebugView) (Prefisso fissato "OE-USER: ")
	''' </summary>
	''' <remarks></remarks>
	Public Shared Sub TraceWriteLine(ByVal sMessage As String)
		If Not HttpContext.Current Is Nothing Then
			System.Diagnostics.Trace.WriteLine(sMessage, "OE-USER " & HttpContext.Current.User.Identity.Name)
		Else
			System.Diagnostics.Trace.WriteLine(sMessage, "OE-USER ")
		End If
	End Sub

#End Region

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


	''' <summary>
	''' Restituisce l'url relativo all'application. Utile per trovare l'URL relatuivo a folder e pagine
	''' </summary>
	''' <returns></returns>
	''' <remarks></remarks>
	Public Shared Function GetApplicationPath() As String
		Return HttpContext.Current.Request.ApplicationPath.TrimEnd("/") & "/"
	End Function


	''' <summary>
	''' Funzione generica che converte una stringa in enum, solleva eccezione se non riesce
	''' </summary>
	Public Shared Function StringToEnum(Of T)(str As String) As T

		Dim ret As T = DirectCast([Enum].Parse(GetType(T), str), T)
		Return ret

	End Function

#Region "Utility WcfDwhClinico"
	Public Enum ConsensoMinimoAccordato
		Nessuno '0
		Generico '1
		Dossier '2
		DossierStorico '3
	End Enum

	Public Shared Sub SetWcfDwhClinicoCredential(ByVal oWs As WcfDwhClinico.ServiceClient)
		'
		' Se User="" e Password="" -> authenticazione integrata altrimenti Basic
		'
		Dim sUser As String = My.Settings.WcfDwhClinico_User
		Dim sPassword As String = My.Settings.WcfDwhClinico_Password
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
#End Region

	Public Shared Function GetAzienda(User As String) As String
		Dim sResult As String = String.Empty
#If DEBUG Then
		'
		'SOLO IN DEBUG
		'
		If User.ToUpper.Contains("PROGEL.IT\") Then
			'
			' SETTO ASMN COME DEFAULT
			'
			sResult = "ASMN"
		End If
#End If
		'
		' [TASK = 3232] INSERIMENTO DI UN FILTRO AZIENDA CON DEFAULT L'AZIENDA COLLEGATA ALL'ACCOUNT
		' IN BASE AL DOMINIO CON CUI SI ACCEDE SETTO IL VALORE DELLA COMBO
		'
		If User.ToUpper.Contains("OSPEDALE\") OrElse User.ToUpper.Contains("@ASMN.NET") Then

			sResult = "ASMN"
		ElseIf User.ToUpper.Contains("MASTER_USL\") OrElse User.ToUpper.Contains("@AUSL.ORG") Then

			sResult = "AUSL"
		End If

		Return sResult
	End Function



	''' <summary>
	''' Restituisce una stringa con la descrizione del ricovero.
	''' </summary>
	''' <param name="azienda"></param>
	''' <param name="nosologico"></param>
	''' <returns></returns>
	Public Shared Function GetInfoRicovero(Azienda As String, Nosologico As String) As String
		Dim sRicovero As String = String.Empty

		Try
			'Ottengo le informazioni sul ricovero
			Dim ricovero As WcfDwhClinico.EpisodioType = CustomDataSourceDettaglioPaziente.GetDatiRicoveroByNosologicoAzienda(Nosologico, Azienda)

			If ricovero IsNot Nothing Then
				'prendo l'ultimo evento in ordine cronologico che ha valorizzato il reparto codice
				'Dim RepartoDesc = (From ric In infoRicovero.RicoveroEventi
				' Where Not String.IsNullOrEmpty(ric.RepartoRicoveroCodice)
				' Order By ric.DataEvento
				').Last.RepartoRicoveroDescr

				Dim descrizioneReparto As String = Nothing

				If ricovero.StrutturaConclusione IsNot Nothing Then
					descrizioneReparto = ricovero.StrutturaConclusione.Descrizione
				ElseIf ricovero.StrutturaUltimoEvento IsNot Nothing Then
					descrizioneReparto = ricovero.StrutturaUltimoEvento.Descrizione
				End If

				Dim s1 As String = If(ricovero.DataConclusione.HasValue, "Dimesso da", If(ricovero.NumeroNosologico.StartsWith("LA"), "Prenotato in", "Ricoverato in"))
				Dim data As DateTime? = If(ricovero.DataConclusione.HasValue, ricovero.DataConclusione.Value, If(ricovero.DataApertura.HasValue, ricovero.DataApertura.Value, Nothing))

				'TODO: rivedere la logica di lista accettazione "LA", andare a cercare fra gli attributi...
				'Se repartoDesc è vuota non verrà valorizzata la descrizione del  reparto di ricovero nel pannello paziente.
				sRicovero = $"{s1} <b>{descrizioneReparto}</b> il {data:d}<br />({ ricovero.NumeroNosologico})"
			End If
		Catch ex As CustomException(Of WcfDwhClinico.ErroreType)
			ExceptionsManager.TraceException(ex)
			Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
			portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
		Catch ex As Exception
			ExceptionsManager.TraceException(ex)
			Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
			portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
		End Try

		Return sRicovero

	End Function

	Public Shared Function SalvaBozzaRichiesta(idSac As String, nosologico As String, aziendauo As String) As String
		Try
			Dim userData = UserDataManager.GetUserData()

			Using webService As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")
				Dim sAzienda = String.Empty
				Dim sUOCodice As String = String.Empty
				Dim richiesta = New OrdineType()

				Dim iTrattino As Integer = aziendauo.IndexOf("-")
				If iTrattino > -1 Then
					sAzienda = aziendauo.Substring(0, iTrattino)
				End If

				richiesta.DataRichiesta = DateTime.Now
				richiesta.IdRichiestaOrderEntry = String.Empty
				richiesta.NumeroNosologico = nosologico
				richiesta.Regime = New RegimeType() With {.Codice = GetRegimeByTipoRicovero(nosologico, sAzienda).ToString}
				richiesta.Priorita = New PrioritaType() With {.Codice = PrioritaEnum.O.ToString}

				'Dim ts = CLng(DateTime.UtcNow.Subtract(New DateTime(1970, 1, 1)).TotalMilliseconds).ToString
				'Dim ts1 = New TimeSpan(DateTime.UtcNow.Ticks).ToString
				Dim ts = DateTime.UtcNow.ToString("yyyyMMddHHmmssfff")
				Dim timestamp = ts.Substring(0, If(ts.Length <= 18, ts.Length, 18))

				richiesta.IdRichiestaRichiedente = timestamp

				Dim username = HttpContext.Current.User.Identity.Name
				Dim userInfo = UserDataManager.GetDettaglioUtente(username)

				richiesta.Operatore = New OperatoreType() With {
					   .ID = username,
					   .Nome = userInfo.Nome,
					   .Cognome = userInfo.Cognome
					  }

				richiesta.SistemaRichiedente = New SistemaType() With {
					 .Azienda = New CodiceDescrizioneType() With {.Codice = DI.Common.Utility.GetAziendaRichiedente2()},
					 .Sistema = New CodiceDescrizioneType() With {.Codice = My.Settings.SistemaRichiedente}
					 }


				If String.IsNullOrEmpty(nosologico) Then

					Dim cds As New CustomDataSource.UnitaOperative
					Dim unita = cds.GetData()
					If unita.Count = 0 Then
						'
						'l'utente non ha i permessi sulle UO
						'
						'Throw New Exception("GetLookupUOPerRuolo non ha restituito righe.")
						Return "NoUO"
					End If

					sAzienda = unita.First.CodiceAzienda
					sUOCodice = unita.First.CodiceUO
					sUOCodice = sUOCodice.Substring(sUOCodice.IndexOf("-") + 1)

				Else
					If iTrattino > -1 Then
						sUOCodice = aziendauo.Substring(iTrattino + 1)
					End If
				End If

				richiesta.UnitaOperativaRichiedente = New StrutturaType() With
					   {
					 .Azienda = New CodiceDescrizioneType() With {.Codice = sAzienda},
					 .UnitaOperativa = New CodiceDescrizioneType() With {.Codice = sUOCodice}
					   }


                Dim ds As New CustomDataSourceDettaglioPaziente.Paziente
                'ds.ClearCache()
                Dim paziente = ds.GetDataById(idSac)

                '
                'Il ws del sac non restituisce Nothing se la non c'è la data nascita del paziente.
                'Per evitare che venga passata una data "01/01/0001 12:00AM" testo se la dataNascita è uguale alla data minima di vb.
                '
                Dim dataNascita As Date? = Nothing

				'
				'Se la DataNascita del paziente è diversa dalla data minima di vb allora valorizzo la variabile dataNascita, altrimenti lascio nothing.
				'
				If paziente.DataNascita > Date.MinValue Then
					dataNascita = paziente.DataNascita
				End If

				richiesta.Paziente = New PazienteType() With {
					 .IdSac = idSac,
					 .Cognome = paziente.Cognome,
					 .Nome = paziente.Nome,
					 .CodiceFiscale = paziente.CodiceFiscale,
					 .DataNascita = dataNascita,
					 .AnagraficaCodice = paziente.IdProvenienza,
					 .AnagraficaNome = paziente.Provenienza,
					 .CapResidenza = paziente.CapRes,
					 .CodiceIstatComuneNascita = paziente.ComuneNascitaCodice,
					 .CodiceIstatComuneResidenza = paziente.ComuneResCodice,
					 .CodiceIstatNazionalita = paziente.NazionalitaCodice,
					 .ComuneNascita = paziente.ComuneNascitaNome,
					 .ComuneResidenza = paziente.ComuneResNome,
					 .IndirizzoResidenza = paziente.IndirizzoRes,
					 .Nazionalita = paziente.NazionalitaNome,
					 .Sesso = paziente.Sesso,
					 .DataModifica = paziente.DataModifica
					   }

				richiesta.RigheRichieste = New RigheRichiesteType()
				Dim request = New AggiungiOppureModificaOrdineRequest(userData.Token, richiesta)
				Dim response = webService.AggiungiOppureModificaOrdine(request)
				If response.AggiungiOppureModificaOrdineResult.StatoValidazione.Stato <> StatoValidazioneEnum.AA Then
					Throw New Exception(response.AggiungiOppureModificaOrdineResult.StatoValidazione.Descrizione)
				End If

				Return response.AggiungiOppureModificaOrdineResult.Ordine.IdGuidOrderEntry
			End Using
		Catch ex As Exception
			ExceptionsManager.TraceException(ex)
			Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
			portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
			Throw
		End Try
	End Function

    Private Shared Function GetRegimeByTipoRicovero(nosologico As String, azienda As String) As RegimeEnum

        Dim infoRicovero As WcfDwhClinico.EpisodioType = Nothing

        If Not String.IsNullOrEmpty(nosologico) AndAlso Not String.IsNullOrEmpty(azienda) Then
            infoRicovero = CustomDataSourceDettaglioPaziente.GetDatiRicoveroByNosologicoAzienda(nosologico, azienda)
        End If

        If infoRicovero Is Nothing OrElse infoRicovero.TipoEpisodio Is Nothing Then

            Return RegimeEnum.AMB

        Else
            Select Case infoRicovero.TipoEpisodio.Codice
                Case "P" 'pronto soccorso
                    Return RegimeEnum.PS

                Case "D" 'day hospital
                    Return RegimeEnum.DH

                Case "O" 'ordinario
                    Return RegimeEnum.RO

                Case "S" 'day service
                    Return RegimeEnum.DSA

                Case "A" 'Altro
                    'MODIFICA ETTORE 2017-02-29: gestione tipo ricovero "Altro"
                    Return RegimeEnum.AMB

                Case "B" 'OBI
                    Return RegimeEnum.OBI

                Case Else
                    Return RegimeEnum.AMB
            End Select
        End If
    End Function

    'Modifica Leo 2019-11-06: funzione per creare stringa con separatori
    Public Shared Function StringConcatenate(ByVal oListItemCollection As System.Web.UI.WebControls.ListItemCollection, Optional ByVal sSeparatore As String = "§;") As String
        Dim sValue As String = String.Empty
        For Each oItem As System.Web.UI.WebControls.ListItem In oListItemCollection
            If oItem.Selected Then
                sValue = sValue & oItem.Value & sSeparatore
            End If
        Next
        'è necessario passare sSeparatore.ToCharArray altrimento non trimma
        sValue = sValue.TrimEnd(sSeparatore.ToCharArray)
        Return sValue
    End Function
End Class

Namespace DI.OrderEntry.User.Markup
	Public Class MarkupUtility
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
	End Class
End Namespace

