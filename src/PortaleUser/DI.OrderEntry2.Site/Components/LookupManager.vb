Imports System.Web.Caching
Imports DI.OrderEntry.Services
Imports System.Collections.Generic
Imports System.Linq
Imports System.ComponentModel
Imports DI.PortalUser2.Data

Namespace DI.OrderEntry.User

	Public Class LookupManager

		Public Shared ReadOnly Separator As Char = Convert.ToChar(2) 'carattere non stampabile STX da usare per le concatenazioni di codici

		Private Shared _aziende As Dictionary(Of String, String)
		Private Shared _sistemiRichiedenti As Dictionary(Of String, Dictionary(Of String, String))
		Private Shared _sistemiEroganti As Dictionary(Of String, Dictionary(Of String, String))
		Private Shared _unitaOperative As Dictionary(Of String, Dictionary(Of String, String))
		Private Shared _priorita As Dictionary(Of String, String)
		Private Shared _regime As Dictionary(Of String, String)
		Private Shared _lookupDataName As String = String.Empty

		Shared Sub New()

			_sistemiRichiedenti = New Dictionary(Of String, Dictionary(Of String, String))()
			_sistemiEroganti = New Dictionary(Of String, Dictionary(Of String, String))()
			_unitaOperative = New Dictionary(Of String, Dictionary(Of String, String))()
			_lookupDataName = My.User.Name & "_lookupData"

		End Sub

		''' <summary>
		''' Restituisce un oggetto contenente tutti i valori di lookup utilizzati nell'applicazione
		''' </summary>
		''' <returns></returns>
		''' <remarks></remarks>
		Private Shared Function GetLookupData() As DizionariType

			If HttpContext.Current.Cache(_lookupDataName) Is Nothing Then

				Using webService As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")

					Dim token = webService.CreaTokenAccessoDelega(New CreaTokenAccessoDelegaRequest(My.User.Name, Common.Utility.GetAziendaRichiedente2(), My.Settings.SistemaRichiedente)).CreaTokenAccessoDelegaResult

					Dim lookupData = webService.OttieniListeDizionari(New OttieniListeDizionariRequest(token)).OttieniListeDizionariResult

					HttpContext.Current.Cache.Add(_lookupDataName, lookupData, Nothing, DateTime.Now.AddMinutes(2), Cache.NoSlidingExpiration, CacheItemPriority.BelowNormal, AddressOf CacheItemRemovedCallback)

					Return lookupData
				End Using
			End If

			Return HttpContext.Current.Cache(_lookupDataName)
		End Function

		''' <summary>
		''' Restituisce l'elenco codice/descrizione delle priorità
		''' </summary>
		''' <returns></returns>
		''' <remarks></remarks>
		<DataObjectMethod(DataObjectMethodType.Select)>
		Public Shared Function GetPriorita() As Dictionary(Of String, String)

			If _priorita Is Nothing Then

				Dim lookup = GetLookupData()

				Dim requestedLookup = From priorita In lookup.Priorita
									  Select priorita.Codice, priorita.Descrizione
									  Order By Descrizione

				_priorita = requestedLookup.ToDictionary(Of String, String)(Function(kv) kv.Codice, Function(kv) kv.Descrizione)
			End If

			Return _priorita
		End Function

		''' <summary>
		''' Restituisce l'elenco codice/descrizione dei regimi
		''' </summary>
		''' <returns></returns>
		''' <remarks></remarks>
		Public Shared Function GetRegime() As Dictionary(Of String, String)

			If _regime Is Nothing Then

				Dim lookup = GetLookupData()

				Dim requestedLookup = From regime In lookup.Regimi
									  Select regime.Codice, regime.Descrizione
									  Order By Descrizione

				_regime = requestedLookup.ToDictionary(Of String, String)(Function(kv) kv.Codice, Function(kv) kv.Descrizione)
			End If

			Return _regime
		End Function

		''' <summary>
		''' Restituisce l'elenco codice/descrizione delle aziende
		''' </summary>
		''' <returns></returns>
		''' <remarks></remarks>
		<DataObjectMethod(DataObjectMethodType.Select)>
		Public Shared Function GetAziende() As Dictionary(Of String, String)

			If _aziende Is Nothing Then

				Dim lookup = GetLookupData()

				Dim requestedLookup = From azienda In lookup.Aziende
									  Select azienda.Codice, azienda.Descrizione
									  Order By Descrizione

				_aziende = requestedLookup.ToDictionary(Of String, String)(Function(kv) kv.Codice, Function(kv) kv.Descrizione)
			End If

			Return _aziende
		End Function

		''' <summary>
		''' Restituisce l'elenco codice/descrizione dei sistemi richiedenti filtrato per azienda di appartenenza
		''' </summary>
		''' <param name="azienda">L'azienda d'apartenenza</param>
		''' <returns></returns>
		''' <remarks></remarks>
		Public Shared Function GetSistemiRichiedenti(azienda As String) As Dictionary(Of String, String)

			If _sistemiRichiedenti Is Nothing OrElse Not _sistemiRichiedenti.ContainsKey(azienda) Then

				Dim lookup = GetLookupData()

				Dim requestedLookup = From sistema In lookup.SistemiRichiedenti
									  Where sistema.Azienda.Codice = azienda
									  Select sistema.Sistema.Codice, sistema.Sistema.Descrizione
									  Order By Descrizione

				_sistemiRichiedenti.Add(azienda, requestedLookup.ToDictionary(Of String, String)(Function(kv) kv.Codice, Function(kv) kv.Descrizione))
			End If

			Return _sistemiRichiedenti(azienda)
		End Function

		''' <summary>
		''' Restituisce l'elenco codice/descrizione dei sistemi eroganti filtrato per azienda di appartenenza
		''' </summary>
		''' <param name="azienda">L'azienda d'apartenenza</param>
		''' <returns></returns>
		''' <remarks></remarks>
		<DataObjectMethod(DataObjectMethodType.Select)>
		Public Shared Function GetSistemiEroganti(azienda As String) As Dictionary(Of String, String)
			Dim dict As New Dictionary(Of String, String)
			Try
				If azienda IsNot Nothing Then
					If _sistemiEroganti Is Nothing OrElse Not _sistemiEroganti.ContainsKey(azienda) Then
						Dim lookup = GetLookupData()
						Dim requestedLookup = From sistema In lookup.SistemiEroganti
											  Where (String.IsNullOrEmpty(azienda) OrElse sistema.Azienda.Codice = azienda)
											  Select sistema.Sistema.Codice, sistema.Sistema.Descrizione
											  Order By Descrizione
						_sistemiEroganti.Add(azienda, requestedLookup.ToDictionary(Function(kv) kv.Codice, Function(kv) kv.Descrizione))
					End If
					Return _sistemiEroganti(azienda)
				End If
			Catch ex As Exception
				ExceptionsManager.TraceException(ex)
				Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
				portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
			End Try
			Return dict
		End Function

		''' <summary>
		''' Restituisce l'elenco codice/descrizione dei sistemi eroganti con l'azienda specificata nella descrizione
		''' </summary>       
		''' <returns></returns>
		''' <remarks></remarks>
		<DataObjectMethod(DataObjectMethodType.Select)>
		Public Shared Function GetSistemiEroganti() As Dictionary(Of String, String)

			Dim lookup = GetLookupData()

			Dim requestedLookup = (From sistema In lookup.SistemiEroganti
								   Select New With {.Codice = String.Format("{0}-{1}", sistema.Azienda.Codice, sistema.Sistema.Codice), .Descrizione = String.Format("{0} - {1}", sistema.Azienda.Codice, If(String.IsNullOrEmpty(sistema.Sistema.Descrizione), sistema.Sistema.Codice, sistema.Sistema.Descrizione))}).OrderBy(Function(e) e.Descrizione)

			Return requestedLookup.ToDictionary(Of String, String)(Function(kv) kv.Codice, Function(kv) kv.Descrizione)
		End Function

		Public Shared Function GetSistemiErogantiForFiltro() As Dictionary(Of String, String)

			Dim lookup = GetLookupData()

			Dim requestedLookup = (From sistema In lookup.SistemiEroganti
								   Select New With {.Codice = String.Concat(sistema.Azienda.Codice, Separator, sistema.Sistema.Codice),
									.Descrizione = String.Format("{0} - ({1}-{2})", sistema.Sistema.Descrizione, sistema.Sistema.Codice, sistema.Azienda.Codice)}).OrderBy(Function(e) e.Descrizione)

			Return requestedLookup.ToDictionary(Of String, String)(Function(kv) kv.Codice, Function(kv) kv.Descrizione)
		End Function

		''' <summary>
		''' Restituisce l'elenco codice/descrizione delle unità operative filtrato per azienda di appartenenza
		''' </summary>
		''' <param name="azienda">L'azienda d'apartenenza</param>
		''' <returns></returns>
		''' <remarks></remarks>
		Public Shared Function GetUnitaOperative(azienda As String) As IDictionary(Of String, String)

			If _unitaOperative Is Nothing OrElse Not _unitaOperative.ContainsKey(azienda) Then

				Dim lookup = GetLookupData()

				Dim requestedLookup = From uo In lookup.UnitaOperative
									  Where uo.Azienda.Codice = azienda
									  Select uo.UnitaOperativa.Codice, uo.UnitaOperativa.Descrizione
									  Order By Descrizione

				_unitaOperative.Add(azienda, requestedLookup.ToDictionary(Of String, String)(Function(kv) kv.Codice, Function(kv) If(String.IsNullOrEmpty(kv.Descrizione), kv.Codice, kv.Descrizione)))

			End If

			Return _unitaOperative(azienda)
		End Function

		''' <summary>
		''' Restituisce un lookup delle unità operative con le descrizioni correttamente valorizzate
		''' </summary>
		''' <param name="lookup"></param>
		''' <returns></returns>
		''' <remarks></remarks>
		Public Shared Function GetUOCompleteLookup(lookup As Dictionary(Of String, String), azienda As String) As IDictionary(Of String, String)

			Dim newLookup = New Dictionary(Of String, String)(lookup.Count)

			For Each element In lookup

				Dim key = element.Key
				Dim descriptions = (From uo In GetUnitaOperative(azienda)
									Where uo.Key = key
									Select uo.Value)

				Dim description = If(descriptions.Count = 0, key, descriptions.First)

				newLookup.Add(element.Value, description)
			Next

			Return newLookup.OrderBy(Function(e) e.Value).ToDictionary(Of String, String)(Function(kv) kv.Key, Function(kv) kv.Value)
		End Function

		Public Shared Function GetUODescription(codiceAzienda As String, codiceUO As String) As String

			Dim description = codiceUO
			Dim descriptions = (From uo In GetUnitaOperative(codiceAzienda)
								Where uo.Key = codiceUO
								Select uo.Value)

			If descriptions.Count > 0 AndAlso Not String.IsNullOrEmpty(descriptions.First) Then

				description = descriptions.First
			End If

			Return codiceAzienda & "-" & description
		End Function

		Public Shared Function GetDescrizioneStatoRigaRichiedente(codice As OperazioneRigaRichiestaOrderEntryEnum) As String

			Select Case codice

				Case OperazioneRigaRichiestaOrderEntryEnum.CA
					Return "Cancellata"

				Case OperazioneRigaRichiestaOrderEntryEnum.IS
					Return "Inserita"

				Case OperazioneRigaRichiestaOrderEntryEnum.MD
					Return "Modificata"

				Case Else
					Return String.Empty
			End Select
		End Function

		Public Shared Function GetDescrizioneStatoRigaErogante(codice As StatoRigaErogataOrderEntryEnum) As String

			Select Case codice

				Case StatoRigaErogataOrderEntryEnum.CA
					Return "Cancellata"

				Case StatoRigaErogataOrderEntryEnum.CM
					Return "Erogata"

				Case StatoRigaErogataOrderEntryEnum.IC
					Return "In carico"

				Case StatoRigaErogataOrderEntryEnum.IP
					Return "Programmata"

				Case Else
					Return String.Empty
			End Select
		End Function

		Public Shared Function GetDescrizioneStatoTestataErogante(codice As StatoTestataErogatoOrderEntryEnum) As String

			Select Case codice

				Case StatoTestataErogatoOrderEntryEnum.CA
					Return "Cancellato"

				Case StatoTestataErogatoOrderEntryEnum.CM
					Return "Erogato"

				Case StatoTestataErogatoOrderEntryEnum.IC
					Return "In carico"

				Case StatoTestataErogatoOrderEntryEnum.IP
					Return "Programmato"

				Case Else
					Return String.Empty
			End Select
		End Function

		Private Shared Sub CacheItemRemovedCallback(key As String, value As Object, reason As CacheItemRemovedReason)

			If String.Equals(key, _lookupDataName, StringComparison.CurrentCultureIgnoreCase) Then

				_aziende = Nothing
				_priorita = Nothing
				_regime = Nothing

				If _sistemiEroganti IsNot Nothing Then
					_sistemiEroganti.Clear()
				End If

				If _sistemiRichiedenti IsNot Nothing Then
					_sistemiRichiedenti.Clear()
				End If

				If _unitaOperative IsNot Nothing Then
					_unitaOperative.Clear()
				End If
			End If
		End Sub

	End Class

	Public Class UnitaOperativa

		Private _codiceAzienda As String
		Private _codiceUO As String
		Private _descrizioneUO As String

		Public ReadOnly Property CodiceAzienda As String
			Get
				Return _codiceAzienda
			End Get
		End Property

		Public ReadOnly Property CodiceUO As String
			Get
				Return _codiceUO
			End Get
		End Property

		Public ReadOnly Property DescrizioneUO As String
			Get
				Return _descrizioneUO
			End Get
		End Property

		Public Sub New(codiceAzienda As String, codiceUO As String, descrizioneUO As String)

			_codiceAzienda = codiceAzienda
			_codiceUO = codiceUO
			_descrizioneUO = descrizioneUO
		End Sub
	End Class
End Namespace