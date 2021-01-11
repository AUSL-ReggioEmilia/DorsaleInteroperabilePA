Imports System.Collections.Generic
Imports System.ComponentModel
Imports System.Diagnostics
Imports System.Linq
Imports System.Net
Imports DI.OrderEntry.SacServices
Imports DI.PortalUser2.Data
Imports DI.PortalUser2
Imports System.Web.UI
Imports System.Web.Caching
Imports System.Web.Services
Imports System.Text
Imports Utility
Imports DI.OrderEntry.User
Imports WcfDwhClinico

Namespace DI.OrderEntry.User

	Public Class CustomDataSourceDettaglioPaziente
		Inherits Page

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

		Public Enum TipoReferti

			GiornoCorrente = 1
			UltimaSettimana
			UltimoMese
			OltreUltimoMese
		End Enum
#End Region

        <DataObject(True)>
        Public Class Paziente

            ''' <summary>
            ''' Ottiene un paziente Sac tramite il suo Id
            ''' </summary>
            ''' <param name="IdPaziente"></param>
            ''' <returns></returns>
            <DataObjectMethod(DataObjectMethodType.Select, True)>
            Public Function GetDataById(IdPaziente As String) As PazientiDettaglio2ByIdResponsePazientiDettaglio2
                Dim paziente As New PazientiDettaglio2ByIdResponsePazientiDettaglio2
                Try

                    Using webService As New PazientiSoapClient("PazientiSoap")

                        Dim result As PazientiDettaglio2ByIdResponsePazientiDettaglio2() = webService.PazientiDettaglio2ById(New PazientiDettaglio2ByIdRequest(IdPaziente)).PazientiDettaglio2ByIdResult

                        If result IsNot Nothing AndAlso result.Count > 0 Then
                            paziente = result.First()
                        End If
                    End Using

                Catch ex As Exception
                    ExceptionsManager.TraceException(ex)
                    Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
                    Dim errorText As String = PortalDataAdapterManager.FormatException(ex)
                End Try

                Return paziente
            End Function
        End Class

        <DataObject(True)>
		Public Class PazienteDwh
			Inherits CacheDataSource(Of WcfDwhClinico.PazienteType)


			''' <summary>
			''' Ottiene un paziente Sac tramite il suo Id
			''' </summary>
			''' <param name="IdPaziente"></param>
			''' <returns></returns>
			<DataObjectMethod(DataObjectMethodType.Select, True)>
			Public Function GetDataById(IdPaziente As String) As WcfDwhClinico.PazienteType
				Dim paziente As New WcfDwhClinico.PazienteType

				Try
					'Controllo se la lista è già in cache.
					paziente = Me.CacheData

					Using oWcf As New WcfDwhClinico.ServiceClient
						Call Utility.SetWcfDwhClinicoCredential(oWcf)
						'
						' Chiamata al metodo che restituisce i dati
						'
						Dim oPazientiReturn As WcfDwhClinico.PazienteReturn = oWcf.PazienteOttieniPerId(Token, New Guid(IdPaziente), True)
						If oPazientiReturn IsNot Nothing Then
							If oPazientiReturn.Errore IsNot Nothing Then
								Throw New CustomException(Of WcfDwhClinico.ErroreType)("Si è verificato un errore durante la lettura della lista pazienti.", oPazientiReturn.Errore)
							Else
								paziente = oPazientiReturn.Paziente
							End If
						End If

						Me.CacheData = paziente

					End Using

				Catch ex As Exception
					ExceptionsManager.TraceException(ex)
					Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
					portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
				End Try

				Return paziente
			End Function

		End Class

		<DataObject(True)>
		Public Class Esenzioni

			''' <summary>
			''' Ottiene Le esenzioni di un pazinente tramite il suo id (chiama Paziente.GetDataById)
			''' </summary>
			''' <param name="IdPaziente"></param>
			''' <returns></returns>
			<DataObjectMethod(DataObjectMethodType.Select, True)>
			Public Function GetDataByIdPaziente(IdPaziente As String) As List(Of PazientiDettaglio2ByIdResponsePazientiDettaglio2PazientiDettaglio2Esenzioni)
				Dim esenzioni As New List(Of PazientiDettaglio2ByIdResponsePazientiDettaglio2PazientiDettaglio2Esenzioni)

				Try
					Dim pazienteDataSource As New Paziente
					Dim paziente = pazienteDataSource.GetDataById(IdPaziente)

					If paziente IsNot Nothing Then
						If paziente.PazientiDettaglio2Esenzioni IsNot Nothing AndAlso paziente.PazientiDettaglio2Esenzioni.Count > 0 Then
							esenzioni = paziente.PazientiDettaglio2Esenzioni.ToList()
						End If
					End If
				Catch ex As Exception
					ExceptionsManager.TraceException(ex)
					Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
					Dim errorText As String = PortalDataAdapterManager.FormatException(ex)
				End Try

				Return esenzioni
			End Function
		End Class

		<DataObject(True)>
		Public Class Referti

			''' <summary>
			''' Ottiene i referti di un pazinente tramite il suo id
			''' </summary>
			''' <param name="IdPaziente"></param>
			''' <returns></returns>
			<DataObjectMethod(DataObjectMethodType.Select, True)>
			Public Function GetDataByIdPaziente(IdPaziente As String) As RefertiListaType
				Dim referti As New RefertiListaType
				Try
					If String.IsNullOrEmpty(IdPaziente) Then
						Return Nothing
					End If
					referti = GetRefertiByIdPaziente(IdPaziente)
					'result.Referti = (From referto In oReferti.OrderByDescending(Function(e) e.DataReferto)
					'				  Select New Referto With {
					'				 .Sistema_erogante = referto.AziendaErogante & "-" & referto.SistemaErogante,
					'				 .Data_referto = referto.DataReferto.ToString("d"),
					'				 .Stato_richiesta = referto.StatoRichiestaCodice,
					'				 .Anteprima = referto.Anteprima,
					'				 .Reparto_erogante = referto.RepartoErogante,
					'				 .Reparto_richiedente = referto.RepartoRichiedenteDescrizione,
					'				 .Nosologico = referto.NumeroNosologico,
					'				 .Link = My.Settings.DwhUrlReferto & referto.Id}).ToList()
				Catch ex As Exception
					ExceptionsManager.TraceException(ex)
					Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
					Dim errorText As String = PortalDataAdapterManager.FormatException(ex)
				End Try
				Return referti
			End Function


		End Class

		<DataObject(True)>
		Public Class Ricoveri

			''' <summary>
			''' Restituisce i dati del singolo ricovero se il parametro "nosologico" è specificato, altrimenti la lista di tutti i ricoveri
			''' </summary>
			''' <param name="nosologico"></param>
			''' <param name="idPaziente"></param>
			''' <returns></returns>
			''' <remarks></remarks>
			<DataObjectMethod(DataObjectMethodType.Select, True)>
			Public Function GetData(nosologico As String, idPaziente As String, aziendaErogante As String) As List(Of Episodio)
				Dim result As New List(Of Episodio)
				Try
					Dim infoRicovero As InfoRicovero = GetDatiRicovero(nosologico, aziendaErogante)
					If Not (infoRicovero Is Nothing) Then
						result = (From evento In infoRicovero.Eventi
								  Order By evento.DataEvento Descending
								  Select New Episodio With {.Id = evento.Id,
											.Descrizione = evento.TipoEventoDescrizione,
											.Data_Evento = evento.DataEvento.ToString("G"),
											.Reparto = evento.StrutturaDescrizione}).ToList()
						'result.Url = (My.Settings.DwhUrlEpisodi & idPaziente.ToString())
					End If
				Catch ex As Exception
					ExceptionsManager.TraceException(ex)
					Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
					portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
				End Try
				Return result
			End Function
		End Class

		''' <summary>
		''' chiamata anche dalla Home.aspx
		''' </summary>		
		Public Shared Function GetSacPazienteUrl(ByVal id As Object) As String
			Try
				If id IsNot Nothing Then
					Return My.Settings.PazienteSacUrl & id
				Else
					Return String.Empty
				End If
			Catch ex As Exception
				ExceptionsManager.TraceException(ex)
				Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
				portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
				Throw
			End Try
		End Function

		'Public Shared Function GetDettaglioPaziente(id As String) As PazientiDettaglio2ByIdResponsePazientiDettaglio2()
		'	Try
		'		If HttpContext.Current.Cache("DettaglioPaziente" & id) IsNot Nothing Then

		'			Return HttpContext.Current.Cache("DettaglioPaziente" & id)
		'		End If

		'		Using webService As New PazientiSoapClient("PazientiSoap")

		'			Dim result = webService.PazientiDettaglio2ById(New PazientiDettaglio2ByIdRequest(id)).PazientiDettaglio2ByIdResult

		'			If result Is Nothing Then
		'				Return Nothing
		'			End If

		'			HttpContext.Current.Cache.Add("DettaglioPaziente" & id, result, Nothing, DateTime.Now.AddMinutes(1), Cache.NoSlidingExpiration, CacheItemPriority.BelowNormal, Nothing)

		'			Return result
		'		End Using
		'	Catch ex As Exception
		'		ExceptionsManager.TraceException(ex)
		'		Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
		'		Dim errorText As String = PortalDataAdapterManager.FormatException(ex)
		'		portal.TracciaErrori("id Paziente: " & id & Environment.NewLine & errorText, HttpContext.Current.User.Identity.Name, TraceEventType.Error, PortalsNames.OrderEntry)
		'		Return Nothing
		'	End Try
		'End Function

		Public Shared Function GetNosologico() As String
			Try
				If HttpContext.Current.Request("Nosologico") Is Nothing Then
					Return Nothing
				Else
					Return "<b>Episodio:</b>&nbsp" & HttpContext.Current.Request("Nosologico")

				End If
			Catch ex As Exception
				ExceptionsManager.TraceException(ex)
				Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
				portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
				Throw
			End Try

		End Function

		<Flags()>
		Public Enum DwhWsDatiDaRestituire

			AttributiPaziente = 1
			Esenzioni = 2
			Ricoveri = 4
			Referti = 8
		End Enum

		Public Function GetPeriodoUltimoReferto(idPaziente As String) As TipoReferti
			Try
				Dim ora = DateTime.Now
				Dim dettaglioPaziente As WcfDwhClinico.PazienteType = Nothing

                Dim ds As New PazienteDwh
				dettaglioPaziente = ds.GetDataById(idPaziente)

                If dettaglioPaziente IsNot Nothing AndAlso dettaglioPaziente.UltimoRefertoData.HasValue Then
					'
					' In base alla data dell'ultimo referto restituisco la data corretta.
					'
					If dettaglioPaziente.UltimoRefertoData.Value.Day = ora.Day Then
						Return TipoReferti.GiornoCorrente
					ElseIf dettaglioPaziente.UltimoRefertoData.Value.Date >= ora.Date.AddDays(-7) Then
						Return TipoReferti.UltimaSettimana
					ElseIf dettaglioPaziente.UltimoRefertoData.Value.Date >= ora.Date.AddDays(-30) Then
						Return TipoReferti.UltimoMese
					Else
						Return TipoReferti.OltreUltimoMese
					End If
				Else
					Return Nothing
				End If
			Catch ex As Exception
				ExceptionsManager.TraceException(ex)
				Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
				portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
				Return Nothing
			End Try
		End Function

		Protected Shared Function GetLinksRicoveri(idPaziente As String) As String
			Try
				Dim ricoveri = GetDatiRicoveri(idPaziente)

				If ricoveri Is Nothing Then
					Return String.Empty
				End If

				Dim links = New StringBuilder()

				For Each ricovero In ricoveri

					'links.Append(GetLinkRicovero(idPaziente))
				Next

				Return links.ToString()

			Catch ex As Exception
				ExceptionsManager.TraceException(ex)
				Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
				portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
				Return Nothing
			End Try
		End Function

		Protected Shared Function GetAge(dataNascita As Object) As String
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



#Region "Metodi che sfruttano i WS3 del DWH"
		Public Shared Function GetDatiRicoveri(idPaziente As String) As List(Of InfoRicovero)
			Dim listaRicoveri As WcfDwhClinico.EpisodiListaType = Nothing
			Dim listaEventi As WcfDwhClinico.EventiType = Nothing
			Dim info = New List(Of InfoRicovero)

			'
			' L'id del paziente deve essere valorizzato.
			'
			If String.IsNullOrEmpty(idPaziente) Then
				Return Nothing
			End If

			Try
				'
				' Ottengo la lista di tutti gli episodi del paziente.
				'
				listaRicoveri = GetDatiEpisodiByIdPaziente(New Guid(idPaziente))

				If listaRicoveri Is Nothing OrElse listaRicoveri.Count <= 0 Then
					Return Nothing
				End If

				For Each item As WcfDwhClinico.EpisodioListaType In listaRicoveri
					If item.DataConclusione.HasValue Then 'significa che il ricovero è chiuso
						Continue For
					End If

					If HttpContext.Current.Cache("RicoveroPaziente" & item.NumeroNosologico) IsNot Nothing Then
						info.Add(HttpContext.Current.Cache("RicoveroPaziente" & item.NumeroNosologico))
						Continue For
					End If

					'
					' Per ogni episodio ottengo la lista degli eventi.
					'
					listaEventi = GetEventiByIdEpisodio(New Guid(item.Id))

					If listaEventi Is Nothing OrElse listaEventi.Count <= 0 Then
						Return Nothing
					End If

					Dim accettazione = listaEventi.Where(Function(evento) evento.TipoEventoCodice = "A")(0)
					Dim eventoCorrente = listaEventi.OrderByDescending(Function(evento) evento.DataEvento)(0)
					Dim eventiDimissioni = listaEventi.Where(Function(evento) evento.TipoEventoCodice = "D")

					Dim infoRicovero

					If eventiDimissioni.Count = 0 Then
						infoRicovero = New InfoRicovero(listaEventi, accettazione, eventoCorrente)
					Else
						infoRicovero = New InfoRicovero(listaEventi, accettazione, eventoCorrente, eventiDimissioni(0))
					End If

					'
					' Salvo in sessione le informazioni sul ricovero.
					'
					HttpContext.Current.Cache.Add("RicoveroPaziente" & item.NumeroNosologico, infoRicovero, Nothing, DateTime.Now.AddMinutes(1), Cache.NoSlidingExpiration, CacheItemPriority.Low, Nothing)

					info.Add(infoRicovero)
				Next

				Return info
			Catch ex As Exception

				ExceptionsManager.TraceException(ex)

				Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)

				portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)

				Return Nothing
			End Try
		End Function

		Public Shared Function GetEventiByIdEpisodio(IdRicovero As Guid) As WcfDwhClinico.EventiType
			Dim oEventiEpisodio As WcfDwhClinico.EventiType = Nothing
			Try
				'
				' Recupero dati dal WS
				'
				Using oWcf As New WcfDwhClinico.ServiceClient
					Call Utility.SetWcfDwhClinicoCredential(oWcf)

					'
					' Chiamata al metodo che restituisce i dati
					'
					Dim oEpisodioReturn As WcfDwhClinico.EpisodioReturn = oWcf.EpisodioOttieniPerId(Token, IdRicovero)

					If oEpisodioReturn IsNot Nothing Then
						If oEpisodioReturn.Errore IsNot Nothing Then
							Throw New CustomException(Of WcfDwhClinico.ErroreType)("Si è verificato un errore durante la lettura della lista degli eventi dell'episodio.", oEpisodioReturn.Errore)
						Else
							oEventiEpisodio = oEpisodioReturn.Episodio.Eventi
						End If
					End If
				End Using

				Return oEventiEpisodio
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

		Public Shared Function GetDatiRicoveroByNosologicoAzienda(nosologico As String, AziendaErogante As String) As WcfDwhClinico.EpisodioType
			Dim oEpisodio As New WcfDwhClinico.EpisodioType
			Dim consenso As Nullable(Of Boolean) = Nothing

			Try
				'
				' Il nosologico e l'azienda erogante devono essere valorizzati
				'
				If String.IsNullOrEmpty(nosologico) OrElse String.IsNullOrEmpty(AziendaErogante) Then
					Return Nothing
				End If

				'
				' Controllo se è presente in sessione
				'
				If HttpContext.Current.Cache("GetDatiRicoveroByNosologicoAzienda_" & nosologico & "_" & AziendaErogante) IsNot Nothing Then
					Return HttpContext.Current.Cache("GetDatiRicoveroByNosologicoAzienda_" & nosologico & "_" & AziendaErogante)
				End If

				Using oWcf As New WcfDwhClinico.ServiceClient
					Call Utility.SetWcfDwhClinicoCredential(oWcf)


					'==========================================================================================================================
					'IMPORTANTE
					'Se le setting "My.Settings.ByPassOscuramenti_Utente" e "My.Settings.ByPassOscuramenti_Ruolo" sono valorizzate TokenByPassOscuramenti 
					' è valorizzato e bypassa gli oscuramenti
					'Se GetTokenPerByPassOscuramenti restituisce nothing creo il token nel metodo standard
					'==========================================================================================================================
					Dim oToken As WcfDwhClinico.TokenType = Tokens.GetTokenPerByPassOscuramenti()
					If oToken Is Nothing Then
						oToken = Token
					End If

					Dim oEpisodioReturn As WcfDwhClinico.EpisodioReturn = oWcf.EpisodioOttieniPerNosologico(oToken, nosologico, AziendaErogante)

					If oEpisodioReturn IsNot Nothing Then
						If oEpisodioReturn.Errore IsNot Nothing Then
							Throw New CustomException(Of WcfDwhClinico.ErroreType)("Si è verificato un errore durante la lettura della lista degli episodi.", oEpisodioReturn.Errore)
						Else
							oEpisodio = oEpisodioReturn.Episodio
						End If
					End If
				End Using

				If oEpisodio Is Nothing Then
					Return Nothing
				End If

				'
				' Salvo in sessione il dettaglio del ricovero.
				'
				HttpContext.Current.Cache("GetDatiRicoveroByNosologicoAzienda_" & nosologico & "_" & AziendaErogante) = oEpisodio

				Return oEpisodio
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

		Public Shared Function GetDatiEpisodiByIdPaziente(idPaziente As Guid) As WcfDwhClinico.EpisodiListaType
			Try
				Dim oEpisodi As New WcfDwhClinico.EpisodiListaType

				'
				' Ottengo il dettaglio del paziente.
				' Il metodo del ws "EpisodiCercaPerIdPaziente" necessita il parametro DataDal per funzionare.
				' Ottengo la data di nascita del paziente dal dettaglio salvato in cache da passare come parametro al metodo del ws
				'
				Dim ds As New CustomDataSourceDettaglioPaziente.Paziente
				Dim dettaglioPaziente As PazientiDettaglio2ByIdResponsePazientiDettaglio2 = ds.GetDataById(idPaziente.ToString)

				Dim byPassaConsenso As Boolean = CType(Utility.GetAppSettings("ByPassaConsenso", True), Boolean)

				Using oWcf As New WcfDwhClinico.ServiceClient
					Call Utility.SetWcfDwhClinicoCredential(oWcf)

					Dim oEpisodioReturn As WcfDwhClinico.EpisodiReturn = oWcf.EpisodiCercaPerIdPaziente(Token, MAX_NUM_RECORD, Nothing, byPassaConsenso, idPaziente, dettaglioPaziente.DataNascita, Nothing)

					If oEpisodioReturn IsNot Nothing Then
						If oEpisodioReturn.Errore IsNot Nothing Then
							Throw New CustomException(Of WcfDwhClinico.ErroreType)("Si è verificato un errore durante la lettura della lista degli episodi.", oEpisodioReturn.Errore)
						Else
							oEpisodi = oEpisodioReturn.Episodi
						End If
					End If
				End Using

				If oEpisodi Is Nothing Then
					Return Nothing
				End If

				Return oEpisodi

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

		Public Shared Function GetDatiRicovero(nosologico As String, aziendaErogante As String) As InfoRicovero
			Dim oEpisodio As WcfDwhClinico.EpisodioType = Nothing
			Try
				If String.IsNullOrEmpty(nosologico) OrElse String.IsNullOrEmpty(aziendaErogante) Then
					Return Nothing
				End If

				If HttpContext.Current.Cache("RicoveroPaziente" & nosologico) IsNot Nothing Then
					'
					' Controllo se è già presente in cache il dettaglio del ricovero
					'
					Return HttpContext.Current.Cache("RicoveroPaziente" & nosologico)
				End If

				Using oWcf As New WcfDwhClinico.ServiceClient
					Call Utility.SetWcfDwhClinicoCredential(oWcf)

					Dim oEpisodioReturn As WcfDwhClinico.EpisodioReturn = oWcf.EpisodioOttieniPerNosologico(Token, nosologico, aziendaErogante)

					If oEpisodioReturn IsNot Nothing Then
						If oEpisodioReturn.Errore IsNot Nothing Then
							Throw New CustomException(Of WcfDwhClinico.ErroreType)("Si è verificato un errore durante la lettura della lista degli episodi.", oEpisodioReturn.Errore)
						Else
							oEpisodio = oEpisodioReturn.Episodio
						End If
					End If
				End Using

				If oEpisodio Is Nothing Then
					Return Nothing
				End If

				Dim accettazione = oEpisodio.Eventi.Where(Function(evento) evento.TipoEventoCodice = "A")(0)
				Dim eventoCorrente = oEpisodio.Eventi.OrderByDescending(Function(evento) evento.DataEvento)(0)
				Dim eventiDimissioni = oEpisodio.Eventi.Where(Function(evento) evento.TipoEventoCodice = "D")

				Dim ricovero

				If eventiDimissioni.Count = 0 Then
					ricovero = New InfoRicovero(oEpisodio.Eventi, accettazione, eventoCorrente)
				Else
					ricovero = New InfoRicovero(oEpisodio.Eventi, accettazione, eventoCorrente, eventiDimissioni(0))
				End If

				'
				' Salvo in cache
				'
				HttpContext.Current.Cache.Add("RicoveroPaziente" & nosologico, ricovero, Nothing, DateTime.Now.AddMinutes(1), Cache.NoSlidingExpiration, CacheItemPriority.Low, Nothing)

				Return ricovero
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

		Public Shared Function GetDatiRicovero2(idPaziente As String) As WcfDwhClinico.EpisodioListaType
			Dim ultimoEpisodio As WcfDwhClinico.EpisodioListaType = Nothing
			Try
				If String.IsNullOrEmpty(idPaziente) Then
					Return Nothing
				End If

				If HttpContext.Current.Cache("RicoveroPaziente2" & idPaziente) IsNot Nothing Then
					Return HttpContext.Current.Cache("RicoveroPaziente2" & idPaziente)
				End If

				Dim listaEpisodi As WcfDwhClinico.EpisodiListaType = GetDatiEpisodiByIdPaziente(New Guid(idPaziente))

				If listaEpisodi Is Nothing OrElse listaEpisodi.Count <= 0 Then
					Return Nothing
				End If

				ultimoEpisodio = listaEpisodi(0)

				HttpContext.Current.Cache.Add("RicoveroPaziente2" & idPaziente, ultimoEpisodio, Nothing, DateTime.Now.AddMinutes(1), Cache.NoSlidingExpiration, CacheItemPriority.Low, Nothing)

				Return ultimoEpisodio
			Catch ex As Exception
				ExceptionsManager.TraceException(ex)
				Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
				portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
				Return Nothing
			End Try
		End Function

		Public Shared Function GetRefertiByIdPaziente(idPaziente As String) As WcfDwhClinico.RefertiListaType
			Dim oReferti As WcfDwhClinico.RefertiListaType = Nothing
			Try
				If String.IsNullOrEmpty(idPaziente) Then
					Return Nothing
				End If

				Dim ds As New CustomDataSourceDettaglioPaziente.Paziente
				Dim dPaziente As PazientiDettaglio2ByIdResponsePazientiDettaglio2 = ds.GetDataById(idPaziente.ToString)

				Dim byPassaConsenso As Boolean = CType(Utility.GetAppSettings("ByPassaConsenso", True), Boolean)

				Using oWcf As New WcfDwhClinico.ServiceClient
					Call Utility.SetWcfDwhClinicoCredential(oWcf)
					'
					' Chiamata al metodo che restituisce i dati
					'
					Dim oRefertiReturn As WcfDwhClinico.RefertiReturn = oWcf.RefertiCercaPerIdPaziente(Token, MAX_NUM_RECORD, Nothing, byPassaConsenso, New Guid(idPaziente), dPaziente.DataNascita, Nothing, Nothing, Nothing, Nothing, Nothing)
					If oRefertiReturn IsNot Nothing Then
						If oRefertiReturn.Errore IsNot Nothing Then
							Throw New CustomException(Of WcfDwhClinico.ErroreType)("Si è verificato un errore durante la lettura della lista dei referti.", oRefertiReturn.Errore)
						Else
							oReferti = oRefertiReturn.Referti
						End If
					End If
				End Using

				If oReferti Is Nothing OrElse oReferti.Count <= 0 Then
					Return Nothing
				End If

				Return oReferti

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


#End Region

#Region "Gestione Testata Paziente"
		Protected Shared Function GetSimboloTipoEpisodioRicovero(dettaglioPaziente As WcfDwhClinico.PazienteType) As String
			'
			' Ottiene l'Image dell'episodio da mostrare nella testata del paziente
			'
			Dim strHtml As String = String.Empty
			Try
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
			Catch ex As Exception
				ExceptionsManager.TraceException(ex)
				Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
				portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
				Throw
			End Try


			Return strHtml
		End Function

		Private Shared Function GetHtmlImgTipoEpisodioRicovero(ByVal sTipoEpisodioRicovero As String, sTooltip As String) As String
			'
			' Crea il codice html per l'immagine legata al tipo di ricovero
			' gli viene passato il testo contenente le informazioni sul ricovero che verrà visualizzato come tooltip bootstrap
			'
			Dim strHtml As String = String.Empty
			Try
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
			Catch ex As Exception
				ExceptionsManager.TraceException(ex)
				Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
				portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
				Throw
			End Try


			Return strHtml
		End Function


#End Region



	End Class

	Public Class InfoRicovero

		Private _eventi As WcfDwhClinico.EventiType
		Private _accettazione As WcfDwhClinico.EventoType
		Private _eventoCorrente As WcfDwhClinico.EventoType
		Private _dimissione As WcfDwhClinico.EventoType

		Public ReadOnly Property Eventi As WcfDwhClinico.EventiType
			Get
				Return _eventi
			End Get
		End Property

		Public ReadOnly Property Accettazione As WcfDwhClinico.EventoType
			Get
				Return _accettazione
			End Get
		End Property

		Public ReadOnly Property EventoCorrente As WcfDwhClinico.EventoType
			Get
				Return _eventoCorrente
			End Get
		End Property

		Public ReadOnly Property Dimissione As WcfDwhClinico.EventoType
			Get
				Return _dimissione
			End Get
		End Property

		Public Sub New(eventi As WcfDwhClinico.EventiType, accettazione As WcfDwhClinico.EventoType)

			Me.New(eventi, accettazione, Nothing)
		End Sub

		Public Sub New(eventi As WcfDwhClinico.EventiType, accettazione As WcfDwhClinico.EventoType, eventoCorrente As WcfDwhClinico.EventoType)

			Me.New(eventi, accettazione, eventoCorrente, Nothing)
		End Sub

		Public Sub New(eventi As WcfDwhClinico.EventiType, accettazione As WcfDwhClinico.EventoType, eventoCorrente As WcfDwhClinico.EventoType, dimissione As WcfDwhClinico.EventoType)
			_eventi = eventi
			_accettazione = accettazione
			_eventoCorrente = eventoCorrente
			_dimissione = dimissione
		End Sub
	End Class

	Public Class EsenzioniTestata
		Public Property Esenzioni As PazientiDettaglio2ByIdResponsePazientiDettaglio2PazientiDettaglio2Esenzioni
		Public Property Url As String
	End Class

	Public Class RefertiTestata
		Public Property Referti As List(Of Referto)
		Public Property Url As String
	End Class
	Public Class RicoveriTestata
		Public Property ListaEpisodi As List(Of Episodio)
		Public Property Url As String
	End Class


	Public Class Referto
		Public Property Sistema_erogante As String
		Public Property Data_referto As String
		Public Property Stato_richiesta As String
		Public Property Anteprima As String
		Public Property Reparto_erogante As String
		Public Property Reparto_richiedente As String
		Public Property Nosologico As String
		Public Property Link As String
	End Class


	Public Class Episodio
		Public Property Id As String
		Public Property Descrizione As String
		Public Property Data_Evento As String
		Public Property Reparto As String

	End Class

End Namespace