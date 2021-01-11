Imports System
Imports System.Linq
Imports System.IO
Imports System.Web.UI
Imports System.Data

Imports DI.OrderEntry.Admin.Data
Imports DI.OrderEntry.Admin.Data.Ordini
Imports System.Web.UI.WebControls
Imports System.Data.SqlTypes
Imports System.Drawing
Imports System.Web.Services
Imports System.Xml.Xsl
Imports System.Web
Imports System.Web.Caching
Imports System.Xml
Imports System.Text
Imports System.Collections.Generic
Imports System.Web.Script.Serialization
Imports DI.Common
Imports DI.PortalAdmin.Data
Imports System.Security.Cryptography
Imports DI.OrderEntry.Admin.Data.OrdiniTableAdapters
Imports DI.OrderEntry.WS

Namespace DI.OrderEntry.Admin

	Public Class OrdiniDettaglio
		Inherits Page

		Private Const PageSessionIdPrefix As String = "OrdiniDettaglio_"

		Private Shared VirtualPath As String = ""
		Private Shared NumeroOE As String = ""

		Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load

			' Serve per il TracciaOperazione
			VirtualPath = Page.AppRelativeVirtualPath

		End Sub

		<WebMethod()> _
		Public Shared Function GetDatiTestata(ByVal id As String) As Object
			Try
				Dim testataDataTable As UiOrdiniListDataTable

				Using adapter As New UiOrdiniListTableAdapter()

                    testataDataTable = adapter.GetData(1, "", New Guid(id), Nothing, Nothing, Nothing, Nothing, Nothing, Nothing, Nothing, Nothing, Nothing, Nothing, Nothing, Nothing, Nothing, Nothing, Nothing, Nothing, Nothing, Nothing)
                End Using

				Dim row = testataDataTable(0)
				Dim testata = New With {
				  .Id = row.Id,
				  .NumeroOrdine = row.NumeroOrdine,
				  .IdRichiestaRichiedente = row.IdRichiestaRichiedente,
				  .DataRichiesta = row.DataRichiesta.ToString("G"),
				  .DataInserimento = row.DataInserimento.ToString("G"),
				  .DataModifica = row.DataModifica.ToString("G"),
				  .DataPrenotazione = If(row.IsDataPrenotazioneNull() OrElse row.DataPrenotazione = DateTime.MinValue, String.Empty, row.DataPrenotazione.ToString("G")),
				  .Regime = row.Regime,
				  .Priorita = row.Priorita,
				  .UnitaOperativaRichiedente = row.UnitaOperativaRichiedente,
				  .SistemaRichiedente = row.SistemaRichiedente,
				  .StatoOrderEntry = row.StatoOrderEntry,
				  .StatoOrderEntryDescrizione = row.StatoOrderEntryDescrizione,
				  .DatiAnagraficiPaziente = If(row.IsDatiAnagraficiPazienteNull(), String.Empty, row.DatiAnagraficiPaziente),
				  .CodiceAnagrafica = row.CodiceAnagrafica,
				  .Nosologico = If(row.IsNumeroNosologicoNull(), String.Empty, row.NumeroNosologico),
				  .LinkPazienteIdSac = If(row.IsPazienteIdSacNull(), "#", String.Format(My.Settings.PazienteSacUrl, row.PazienteIdSac)),
				  .LinkPazienteRefertiDwh = If(row.IsPazienteIdSacNull(), "#", String.Format(My.Settings.DwhUrlReferti, row.PazienteIdSac)),
				  .OperatoreCognome = If(row.IsOperatoreCognomeNull, "", row.OperatoreCognome),
				  .OperatoreNome = If(row.IsOperatoreNomeNull, "", row.OperatoreNome),
				  .OperatoreId = If(row.IsOperatoreIdNull, "", row.OperatoreId),
				  .TicketInserimentoUserName = If(row.IsTicketInserimentoUserNameNull, "#", row.TicketInserimentoUserName),
				  .TicketModificaUserName = If(row.IsTicketModificaUserNameNull, "#", row.TicketModificaUserName),
				  .DescrizioneUnitaOperativaRichiedente = If(row.IsDescrizioneUnitaOperativaRichiedenteNull, "#", row.DescrizioneUnitaOperativaRichiedente)
				  }

				'
				'2020-07-13 Kyrylo: Traccia Operazioni --> Traccio l'operazione qui perchè il popolamento dei dati viene fatto da JS. Qui è lunico punto nel vb dove ho i dati.
				'
				NumeroOE = row.NumeroOrdine
				Dim oTracciaOp As New TracciaOperazioniManager(Global_asax.ConnectionStringPortalAdmin)
				oTracciaOp.TracciaOperazione(PortalsNames.OrderEntry, VirtualPath, "Visualizzato dettaglio ordine", idPaziente:=Nothing, Nothing, NumeroOE, "Numero OE")


				Return testata
			Catch ex As Exception

				ExceptionsManager.TraceException(ex)

				Throw
			End Try
		End Function

		<WebMethod()> _
		Public Shared Function EliminaOrdine(ByVal id As String) As String

			Dim result

			Dim username = HttpContext.Current.User.Identity.Name

			Try
				Using webService As New OrderEntryAdminClient("BasicHttpBinding_IOrderEntryAdmin")

					'Dim token = webService.CreaTokenAccessoDelega(My.User.Name, My.Settings.AziendaRichiedente, My.Settings.SistemaRichiedente)
					result = webService.CancellaOrdinePerIdGuid(username, id)
				End Using

				'
				'2020-07-13 Kyrylo: Traccia Operazioni
				'
				Dim oTracciaOp As New TracciaOperazioniManager(Global_asax.ConnectionStringPortalAdmin)
				oTracciaOp.TracciaOperazione(PortalsNames.OrderEntry, VirtualPath, "Cancellato ordine", idPaziente:=Nothing, Nothing, NumeroOE, "Numero OE")

			Catch ex As Exception

				ExceptionsManager.TraceException(ex)

				Throw
			End Try

			If result.StatoValidazione.Stato <> StatoValidazioneEnum.AA Then

				Return result.StatoValidazione.Descrizione
			End If

			Return "ok"
		End Function

		<WebMethod()> _
		Public Shared Function InoltraOrdine(ByVal id As String) As String

			Dim result
			Dim username = HttpContext.Current.User.Identity.Name
			Try
				Using webService As New OrderEntryAdminClient("BasicHttpBinding_IOrderEntryAdmin")

					'Dim token = webService.CreaTokenAccessoDelega(My.User.Name, My.Settings.AziendaRichiedente, My.Settings.SistemaRichiedente)
					result = webService.InoltraOrdinePerIdGuid(username, id)
				End Using

				'
				'2020-07-13 Kyrylo: Traccia Operazioni
				'
				Dim oTracciaOp As New TracciaOperazioniManager(Global_asax.ConnectionStringPortalAdmin)
				oTracciaOp.TracciaOperazione(PortalsNames.OrderEntry, VirtualPath, "Inoltrato ordine", idPaziente:=Nothing, Nothing, NumeroOE, "Numero OE")

			Catch ex As Exception

				ExceptionsManager.TraceException(ex)

				Throw
			End Try

			If result.StatoValidazione.Stato <> StatoValidazioneEnum.AA Then

				Return result.StatoValidazione.Descrizione
			End If

			Return "ok"
		End Function

		<WebMethod()> _
		Public Shared Function ReinoltraOrdine(ByVal id As String) As String

			Dim result
			Dim username = HttpContext.Current.User.Identity.Name
			Try
				Using webService As New OrderEntryAdminClient("BasicHttpBinding_IOrderEntryAdmin")

					'Dim token = webService.CreaTokenAccessoDelega(My.User.Name, My.Settings.AziendaRichiedente, My.Settings.SistemaRichiedente)
					result = webService.ReinoltraOrdinePerIdGuid(username, id)
				End Using

				'
				'2020-07-13 Kyrylo: Traccia Operazioni
				'
				Dim oTracciaOp As New TracciaOperazioniManager(Global_asax.ConnectionStringPortalAdmin)
				oTracciaOp.TracciaOperazione(PortalsNames.OrderEntry, VirtualPath, "Reinoltrato ordine", idPaziente:=Nothing, Nothing, NumeroOE, "Numero OE")

			Catch ex As Exception

				ExceptionsManager.TraceException(ex)

				Throw
			End Try

			If result.StatoValidazione.Stato <> StatoValidazioneEnum.AA Then
				Return result.StatoValidazione.Descrizione
			End If

			Return "ok"
		End Function

		Protected Shared Function GetDispatcherUrl(id As String) As String

			Dim testataDataTable As UiOrdiniListDataTable

			Using adapter As New UiOrdiniListTableAdapter()
                testataDataTable = adapter.GetData(1, "", New Guid(id), Nothing, Nothing, Nothing, Nothing, Nothing, Nothing, Nothing, Nothing, Nothing, Nothing, Nothing, Nothing, Nothing, Nothing, Nothing, Nothing, Nothing, Nothing)
            End Using

			Return String.Format(My.Settings.DispatcherUrl, testataDataTable(0).NumeroOrdine)
		End Function

		<WebMethod()> _
		Public Shared Function GetDatiAggiuntiviRigaRichiesta(ByVal id As String) As String
			Try
				Dim guid As Guid?

				If Not Utility.TryParseStringToGuid(id, guid) Then
					Return My.Resources.NoDatiAggiuntivi
				End If

				Dim dataTable As New UiOrdiniRigheRichiesteDatiAggiuntiviListDataTable()

				DataAdapterManager.Fill(dataTable, guid.Value)

				If dataTable.Count > 0 Then

					If dataTable(0).IsDatiAggiuntiviNull() Then
						Return My.Resources.NoDatiAggiuntivi
					End If

					Dim xslTransform As New XslCompiledTransform()

					xslTransform.Load(HttpContext.Current.Server.MapPath("~/Styles/DatiAggiuntivi.xslt"))

					Using memoryStream As New MemoryStream()

						Dim document As New XmlDocument()
						document.LoadXml(dataTable(0).DatiAggiuntivi)

						Dim xmlTextWriter As New XmlTextWriter(memoryStream, Encoding.UTF8)

						xslTransform.Transform(document.CreateNavigator(), xmlTextWriter)
						memoryStream.Position = 0

						Return Encoding.UTF8.GetString(memoryStream.ToArray())
					End Using
				Else
					Return My.Resources.NoDatiAggiuntivi
				End If
			Catch ex As Exception
				ExceptionsManager.TraceException(ex)

				Return My.Resources.ErroreCaricamentoDati
			End Try
		End Function

		<WebMethod()> _
		Public Shared Function GetDatiAggiuntiviTestataErogata(ByVal id As String) As String
			Try
				Dim guid As Guid?

				If Not Utility.TryParseStringToGuid(id, guid) Then
					Return My.Resources.NoDatiAggiuntivi
				End If

				Dim dataTable As New UiOrdiniErogatiTestateDatiAggiuntiviListDataTable()

				DataAdapterManager.Fill(dataTable, guid.Value)

				If dataTable.Count > 0 Then

					If dataTable(0).IsDatiAggiuntiviNull() Then
						Return My.Resources.NoDatiAggiuntivi
					End If

					Dim xslTransform As New XslCompiledTransform()

					xslTransform.Load(HttpContext.Current.Server.MapPath("~/Styles/DatiAggiuntivi.xslt"))

					Using memoryStream As New MemoryStream()

						Dim document As New XmlDocument()
						document.LoadXml(dataTable(0).DatiAggiuntivi)

						Dim xmlTextWriter As New XmlTextWriter(memoryStream, Encoding.UTF8)

						xslTransform.Transform(document.CreateNavigator(), xmlTextWriter)
						memoryStream.Position = 0

						Return Encoding.UTF8.GetString(memoryStream.ToArray())
					End Using
				Else
					Return My.Resources.NoDatiAggiuntivi
				End If
			Catch ex As Exception
				ExceptionsManager.TraceException(ex)

				Return My.Resources.ErroreCaricamentoDati
			End Try
		End Function

		<WebMethod()> _
		Public Shared Function GetOrdineData(idTestata As Guid) As List(Of OrdineRichiestoErogato)

			Dim returnList As New List(Of OrdineRichiestoErogato)()

			Try
				Using odcDettaglio As New OrdiniDettaglioDataContext()

					'lista di testate richieste + erogate raggruppate per sistema erogante
					'il valore di Erogato indica se la testata richiesta ha corrispondenza in testata erogato
					Dim testateRichiesteErogate = odcDettaglio.UiOrdiniTestateRichiesteErogateList(idTestata).ToList()

					If testateRichiesteErogate.Count > 0 Then

						For Each testata In testateRichiesteErogate

							If testata.Erogato Then
								'carico le righe erogate
								returnList.Add(New OrdineRichiestoErogato(testata, odcDettaglio.UiOrdiniRigheList(idTestata, testata.Id).ToArray()))
							Else
								'carico le righe richieste
								returnList.Add(New OrdineRichiestoErogato(testata, odcDettaglio.UiOrdiniRigheRichiesteList(idTestata, testata.IDSistemaErogante).ToArray()))
							End If

						Next
					Else
						For Each testata In odcDettaglio.UiOrdiniErogatiFinteTestateSelect(idTestata)
							'carico le righe richieste
							returnList.Add(New OrdineRichiestoErogato(testata, odcDettaglio.UiOrdiniRigheRichiesteList(idTestata, testata.IDSistemaErogante).ToArray()))
						Next
					End If

					Return returnList
				End Using
			Catch ex As Exception

				ExceptionsManager.TraceException(ex)
				Return returnList

			Finally
				DataAdapterManager.PortalAdminDataAdapterManager.TracciaAccessi(HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry, "Dettaglio Ordine id:" + idTestata.ToString())
			End Try
		End Function

		<WebMethod()> _
		Public Shared Function GetTrackingData(idTestata As Guid) As List(Of UiTrackingListResult)

			Dim returnList As New List(Of UiTrackingListResult)()

			Try
				Using ordiniDettaglioDataContext As New OrdiniDettaglioDataContext()

					For Each messaggio As UiTrackingListResult In ordiniDettaglioDataContext.UiTrackingList(idTestata)

						returnList.Add(messaggio)
					Next

					Return returnList
				End Using
			Catch ex As Exception

				ExceptionsManager.TraceException(ex)

				Return returnList
			End Try
		End Function

		<WebMethod()> _
		Public Shared Function GetDatiAggiuntiviRigaErogata(ByVal id As String) As String

			Dim guid As Guid?

			If Not Utility.TryParseStringToGuid(id, guid) Then

				Return My.Resources.NoDatiAggiuntivi
			End If

			Dim dataTable As New UiOrdiniRigheErogateDatiAggiuntiviListDataTable()

			DataAdapterManager.Fill(dataTable, guid.Value)

			If dataTable.Count > 0 Then

				If dataTable(0).IsDatiAggiuntiviNull() Then
					Return My.Resources.NoDatiAggiuntivi
				End If

				Dim xslTransform As New XslCompiledTransform()

				xslTransform.Load(HttpContext.Current.Server.MapPath("~/Styles/DatiAggiuntivi.xslt"))

				Using memoryStream As New MemoryStream()

					Dim document As New XmlDocument()
					document.LoadXml(dataTable(0).DatiAggiuntivi)

					Dim xmlTextWriter As New XmlTextWriter(memoryStream, Encoding.UTF8)

					xslTransform.Transform(document.CreateNavigator(), xmlTextWriter)
					memoryStream.Position = 0

					Return Encoding.UTF8.GetString(memoryStream.ToArray())
				End Using
			Else
				Return My.Resources.NoDatiAggiuntivi
			End If
		End Function

		<WebMethod()> _
		Public Shared Function GetPdfUrl(base64Content As String) As String

			Return ""
		End Function

		<WebMethod()> _
		Public Shared Function GetDatiVersione(ByVal id As String) As String
			Try
				Dim guid As Guid?

				If Not Utility.TryParseStringToGuid(id, guid) Then

					Return My.Resources.NoDatiAggiuntivi
				End If

				Dim dataTable As New UiTrackingSelectDataTable()

				DataAdapterManager.Fill(dataTable, guid.Value)

				If dataTable.Count > 0 Then

					If dataTable(0).Messaggio.Length = 0 Then
						Return My.Resources.NoDatiAggiuntivi
					End If

					Dim xslTransform As New XslCompiledTransform()

					xslTransform.Load(HttpContext.Current.Server.MapPath("~/Styles/TreeView.xslt"), New XsltSettings(False, True), New XmlUrlResolver())

					Using memoryStream As New MemoryStream()

						Dim document As New XmlDocument()
						document.LoadXml(dataTable(0).Messaggio)

						Dim xmlTextWriter As New XmlTextWriter(memoryStream, Encoding.UTF8)

						xslTransform.Transform(document.CreateNavigator(), xmlTextWriter)
						memoryStream.Position = 0

						Return Encoding.UTF8.GetString(memoryStream.ToArray())
					End Using
				Else
					Return My.Resources.NoDatiAggiuntivi
				End If
			Catch ex As Exception
				ExceptionsManager.TraceException(ex)

				Return My.Resources.ErroreCaricamentoDati
			End Try
		End Function

		<WebMethod()> _
		Public Shared Function GetMessaggiValidazione(ByVal idTestata As String) As Object

			Dim guid As Guid?

			If Not Utility.TryParseStringToGuid(idTestata, guid) Then
				Return My.Resources.NoMessaggioValidazione
			End If

			Try
				Dim uiOrdiniMessaggiValidazioneListDataTable As New UiOrdiniMessaggiValidazioneListDataTable

				DataAdapterManager.Fill(uiOrdiniMessaggiValidazioneListDataTable, guid)

				If uiOrdiniMessaggiValidazioneListDataTable.Count > 0 Then

					If uiOrdiniMessaggiValidazioneListDataTable(0).IsValidazioneNull() Then
						Return My.Resources.NoMessaggioValidazione
					End If

					Dim xslTransform As New XslCompiledTransform()

					xslTransform.Load(HttpContext.Current.Server.MapPath("~/Styles/MessaggiValidazione.xslt"))

					Using memoryStream As New MemoryStream()

						Dim document As New XmlDocument()
						document.LoadXml(uiOrdiniMessaggiValidazioneListDataTable(0).Validazione)

						Dim xmlTextWriter As New XmlTextWriter(memoryStream, Encoding.UTF8)

						xslTransform.Transform(document.CreateNavigator(), xmlTextWriter)
						memoryStream.Position = 0

						Return Encoding.UTF8.GetString(memoryStream.ToArray()).Replace(Environment.NewLine, "<br />")
					End Using
				Else
					Return My.Resources.NoMessaggioValidazione
				End If

			Catch ex As Exception
				ExceptionsManager.TraceException(ex)
				Throw
			End Try
		End Function

		Private Shared Function GetRowColor(ByVal idRigaRichiedente As String, ByVal idRigaErogata As String, ByVal idRigaRichiedenteDaErogante As String, getDarker As Boolean) As String

			If idRigaRichiedente Is Nothing Then

				Return ColorTranslator.ToHtml(If(getDarker, Color.Gray, Color.LightGray)) '#D3D3D3
			End If

			If idRigaErogata Is Nothing AndAlso idRigaRichiedenteDaErogante Is Nothing Then

				Return ColorTranslator.ToHtml(If(getDarker, Color.FromArgb(174, 98, 98), Color.FromArgb(250, 140, 140)))
			End If

			Return ColorTranslator.ToHtml(If(getDarker, Color.Green, Color.LightGreen)) '#90EE90
		End Function

		<WebMethod()>
		Public Shared Function SaveBase64AndGetId(base64 As String) As String

			Dim hash = base64.GetHashCode()

			If HttpContext.Current.Cache(hash) IsNot Nothing Then
				Return hash
			Else
				HttpContext.Current.Cache.Add(hash, base64, Nothing, Cache.NoAbsoluteExpiration, New TimeSpan(0, 30, 0), CacheItemPriority.BelowNormal, Nothing)

				Return hash
			End If
		End Function

		''' <summary>
		''' Get the MD5 Hash of a String
		''' </summary>
		''' <param name="stringToHash">The String to Hash</param>
		''' <returns></returns>
		''' <remarks></remarks>
		Function GetMD5Hash(ByVal stringToHash As String) As String

			Dim md5Provider As New MD5CryptoServiceProvider()
			Dim bytesToHash() As Byte = Encoding.ASCII.GetBytes(stringToHash)

			bytesToHash = md5Provider.ComputeHash(bytesToHash)

			Dim result As New StringBuilder()

			For Each b As Byte In bytesToHash
				result.Append(b.ToString("x2"))
			Next

			Return result.ToString()
		End Function

	End Class

	Public Class OrdineErogato

		Private _testataErogato As ITestataErogataMarker
		Private _righe As IRigheMarker()

		Public ReadOnly Property TestataErogato As ITestataErogataMarker
			Get
				Return _testataErogato
			End Get
		End Property

		Public ReadOnly Property Righe As IRigheMarker()
			Get
				Return _righe
			End Get
		End Property

		Public Sub New(testataErogato As ITestataErogataMarker, righe As IRigheMarker())

			_testataErogato = testataErogato
			_righe = righe
		End Sub
	End Class

	Public Class OrdineRichiestoErogato

		Private _testataErogato As ITestataRichiestoErogatoMarker
		Private _righe As IRigheMarker()

		Public ReadOnly Property TestataErogato As ITestataRichiestoErogatoMarker
			Get
				Return _testataErogato
			End Get
		End Property

		Public ReadOnly Property Righe As IRigheMarker()
			Get
				Return _righe
			End Get
		End Property

		Public Sub New(testataErogato As ITestataRichiestoErogatoMarker, righe As IRigheMarker())

			_testataErogato = testataErogato
			_righe = righe
		End Sub

	End Class
End Namespace


Namespace DI.OrderEntry.Admin.Data
	'Old gestione
	Public Interface ITestataErogataMarker
	End Interface

	Public Interface IRigheMarker
	End Interface

	Partial Public Class UiOrdiniErogatiListResult
		Implements ITestataErogataMarker

	End Class

	Partial Public Class UiOrdiniRigheListResult
		Implements IRigheMarker

	End Class

	Partial Public Class UiOrdiniErogatiFinteTestateSelectResult
		Implements ITestataErogataMarker

	End Class

	Partial Public Class UiOrdiniRigheRichiesteListResult
		Implements IRigheMarker

	End Class


	'New gestione
	Public Interface ITestataRichiestoErogatoMarker
	End Interface

	Public Interface IRigheRichiestoErogatoMarker
	End Interface

	Partial Public Class UiOrdiniTestateRichiesteErogateListResult
		Implements ITestataRichiestoErogatoMarker

	End Class

	Partial Public Class UiOrdiniRigheListResult
		Implements IRigheRichiestoErogatoMarker

	End Class

	Partial Public Class UiOrdiniRigheRichiesteListResult
		Implements IRigheRichiestoErogatoMarker

	End Class

End Namespace