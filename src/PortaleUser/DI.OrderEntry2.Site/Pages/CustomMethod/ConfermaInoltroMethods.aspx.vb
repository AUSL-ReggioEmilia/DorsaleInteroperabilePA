Imports System.Web.UI
Imports System.ServiceModel
Imports DI.OrderEntry.Services
Imports DI.PortalUser2.Data
Imports System.Web.Services
Imports System.Linq


Namespace DI.OrderEntry.User

	Public Class ConfermaInoltroMethods
		Inherits Page

		Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load

		End Sub

		<WebMethod()>
		Public Shared Function GetRichiesta(id As String) As Object
			Try
				Dim userData = UserDataManager.GetUserData()

				Using webService As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")

					Dim request = New OttieniOrdinePerIdGuidRequest(userData.Token, id)

					Dim response = webService.OttieniOrdinePerIdGuid(request)

					Dim result = response.OttieniOrdinePerIdGuidResult

					If result Is Nothing OrElse result.Ordine.RigheRichieste Is Nothing OrElse result.Ordine.RigheRichieste.Count = 0 Then
						Return Nothing
					End If

					Dim richiesta = New With
									{
									.Progressivo = result.Ordine.IdRichiestaOrderEntry,
									.Stato = result.DescrizioneStato.ToString(),
									.DataRichiesta = result.Ordine.DataRichiesta.ToString("dd/MM/yy HH:mm"),
									.DataPrenotazione = If(Not result.Ordine.DataPrenotazione.HasValue OrElse result.Ordine.DataPrenotazione = DateTime.MinValue, "-", result.Ordine.DataPrenotazione.Value.ToString("dd/MM/yy HH:mm")),
									.NumeroNosologico = result.Ordine.NumeroNosologico,
									.Priorita = If(String.IsNullOrEmpty(result.Ordine.Priorita.Descrizione), LookupManager.GetPriorita()(result.Ordine.Priorita.Codice), result.Ordine.Priorita.Descrizione),
									.Regime = If(String.IsNullOrEmpty(result.Ordine.Regime.Descrizione), LookupManager.GetRegime(result.Ordine.Regime.Codice), result.Ordine.Regime.Descrizione),
									.UnitaOperativa = If(String.IsNullOrEmpty(result.Ordine.UnitaOperativaRichiedente.UnitaOperativa.Descrizione), result.Ordine.UnitaOperativaRichiedente.UnitaOperativa.Codice, result.Ordine.UnitaOperativaRichiedente.UnitaOperativa.Descrizione),
									.Valido = result.StatoValidazione.Stato = StatoValidazioneEnum.AA,
									.DescrizioneStatoValidazione = result.StatoValidazione.Descrizione,
									.DatiAccessori = result.Ordine.DatiAggiuntivi,
					.Prestazioni = From riga In result.Ordine.RigheRichieste
								   Order By riga.SistemaErogante.Azienda.Codice, riga.SistemaErogante.Sistema.Codice, riga.Prestazione.Codice
								   Select New With
								{
								   .Id = riga.Prestazione.Id,
								   .Codice = riga.Prestazione.Codice,
								   .Descrizione = If(String.IsNullOrEmpty(riga.Prestazione.Descrizione), "-", riga.Prestazione.Descrizione),
								   .SistemaErogante = String.Format("{0}-{1}", riga.SistemaErogante.Azienda.Codice, riga.SistemaErogante.Sistema.Codice),
								   .Valido = result.StatoValidazione.Righe.Where(Function(e) e.Index = (result.Ordine.RigheRichieste.IndexOf(riga) + 1)).First().Stato = StatoValidazioneEnum.AA,
								   .DescrizioneStatoValidazione = result.StatoValidazione.Righe.Where(Function(e) e.Index = (result.Ordine.RigheRichieste.IndexOf(riga) + 1)).First().Descrizione,
								   .DatiAccessori = riga.DatiAggiuntivi,
								   .Tipo = riga.PrestazioneTipo
								}
									}

					'compilazione dati ripetibili
					Dim domandeDatiAccessori = webService.OttieniDatiAccessoriPerIdGuid(New OttieniDatiAccessoriPerIdGuidRequest(userData.Token, id)).OttieniDatiAccessoriPerIdGuidResult

					If domandeDatiAccessori.Count > 0 Then
						'
						'Dati Accessori Testata Richiesta
						'
						Utility.NormalizzaDatiAccessori(richiesta.DatiAccessori, domandeDatiAccessori)

						For Each prestazione In richiesta.Prestazioni
							'
							'Dati Accessori Prestazioni Richiesta
							'
							Utility.NormalizzaDatiAccessori(prestazione.DatiAccessori, domandeDatiAccessori)
						Next
					End If

					Return richiesta
				End Using
			Catch ex As FaultException(Of DataFault)

				Throw New Exception(ex.Detail.Message)
			Catch ex As Exception

				ExceptionsManager.TraceException(ex)

				Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)

				portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)

				Return Nothing
			End Try
		End Function

		'Private Shared Function GetValueFromDataType(value As String, dataType As String) As String

		'    If String.IsNullOrEmpty(value) Then
		'        Return value
		'    End If

		'    Select Case dataType

		'        Case "date"

		'            Return DateTime.Parse(value, CultureInfo.InvariantCulture).ToString("dd/MM/yyyy", New CultureInfo("it-IT")).Replace("."c, ":"c)

		'        Case "datetime"

		'            Return DateTime.Parse(value, CultureInfo.InvariantCulture).ToString("dd/MM/yyyy HH:mm:ss", New CultureInfo("it-IT")).Replace("."c, ":"c)

		'        Case "time"

		'            Return DateTime.Parse(value, CultureInfo.InvariantCulture).ToString("HH:mm:ss", New CultureInfo("it-IT")).Replace("."c, ":"c)

		'        Case "float"

		'            Return value.Replace("."c, ","c)

		'        Case Else

		'            Return value
		'    End Select
		'End Function
	End Class

End Namespace