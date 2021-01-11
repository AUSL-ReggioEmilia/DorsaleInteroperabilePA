Imports System.Web.Services
Imports System.ComponentModel
Imports System.Collections.Generic
Imports DI.OrderEntry.Services
Imports DI.OrderEntry.User
Imports DI.PortalUser2.Data
Imports System.Web.Script.Serialization



' To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line.
<Script.Services.ScriptService()>
<WebService(Namespace:="http://tempuri.org/")>
<WebServiceBinding(ConformsTo:=WsiProfiles.BasicProfile1_1)>
<ToolboxItem(False)>
Public Class RiassuntoOrdineMethods
	Inherits WebService

	<WebMethod(EnableSession:=True)>
	<Script.Services.ScriptMethod(ResponseFormat:=Script.Services.ResponseFormat.Json)>
	Public Function OttieniDatiAggiuntiviRichiesta(IdRichiesta As String) As String
		Dim result As String = String.Empty
		Dim DatiAccessori As New Dictionary(Of String, DatoAggiuntivoVisualizzazioneType)
		Try
			Dim ds As New DI.OrderEntry.User.RiassuntoOrdineMethods
			DatiAccessori = ds.OttieniDatiAggiuntiviRichiesta(IdRichiesta)
			If DatiAccessori.Values.Count > 0 Then
				For Each item As DatoAggiuntivoVisualizzazioneType In DatiAccessori.Values
					If Not String.Equals(item.TipoContenuto.ToLower, "pdf") Then
						Dim chiave As String = item.Nome.ToString()
						Dim valore As String = item.ValoreDato.ToString()
						result += $"<label class=""col-sm-5 control-label"">{chiave}</label><div class=""col-sm-7""><p> {valore}</p></div>"
					End If
				Next
				result += "</div>"
			Else
				result = "Nessun dato accessorio presente"
			End If
		Catch ex As Exception
			ExceptionsManager.TraceException(ex)
			Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
			portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
			Throw
		End Try
		Return result
	End Function

	<WebMethod(EnableSession:=True)>
	Public Function OttieniDatiAggiuntiviRichiestaPdf(IdRichiesta As String) As String

		Dim result As List(Of DatoAccessorioDizionario) = New List(Of DatoAccessorioDizionario)
		Dim DatiAccessori As New Dictionary(Of String, DatoAggiuntivoVisualizzazioneType)
		Try
			Dim ds As New DI.OrderEntry.User.RiassuntoOrdineMethods
			DatiAccessori = ds.OttieniDatiAggiuntiviRichiesta(IdRichiesta)
			If DatiAccessori.Values.Count > 0 Then
				For Each item As DatoAggiuntivoVisualizzazioneType In DatiAccessori.Values
					If String.Equals(item.TipoContenuto?.ToLower, "pdf") Then
						Dim DatiAcc As DatoAccessorioDizionario = New DatoAccessorioDizionario

						DatiAcc.Chiave = item.Nome.ToString()
						DatiAcc.Valore = SaveBase64AndGetId(item.ValoreDato)
						result.Add(DatiAcc)
					End If
				Next


			End If
		Catch ex As Exception
			ExceptionsManager.TraceException(ex)
			Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
			portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
			Throw
		End Try
		Return New JavaScriptSerializer().Serialize(result)
	End Function

	<WebMethod(EnableSession:=True)>
	Public Function DatiAggiuntiviSistemaErogante2(IdRichiesta As String, SistemaErogante As String) As String


		Dim result As List(Of DatoAccessorioDizionario) = New List(Of DatoAccessorioDizionario)

		Try
			Dim datiAcc As List(Of DatoNomeValoreType)
			Dim RiassuntoOrdineMethods As New RiassuntoOrdineMethods
			datiAcc = DI.OrderEntry.User.RiassuntoOrdineMethods.DatiAggiuntiviSistemaErogante(IdRichiesta, SistemaErogante)

			If datiAcc IsNot Nothing AndAlso datiAcc.Count > 0 Then
				For Each datoAccessorio In datiAcc
					If datoAccessorio.ValoreDato IsNot Nothing Then
						Dim DatiAccessori As DatoAccessorioDizionario = New DatoAccessorioDizionario
						DatiAccessori.Chiave = datoAccessorio.DatoAccessorio.Etichetta
						DatiAccessori.Valore = datoAccessorio.ValoreDato
						DatiAccessori.Tipo = datoAccessorio.TipoContenuto
						If Not String.IsNullOrEmpty(DatiAccessori.Tipo) Then
							DatiAccessori.Tipo = DatiAccessori.Tipo.ToLower
						End If

						If DatiAccessori.Tipo = "pdf" Then
							DatiAccessori.Valore = SaveBase64AndGetId(datoAccessorio.ValoreDato)
						End If

						result.Add(DatiAccessori)
					End If
				Next
			End If

		Catch ex As Exception
			ExceptionsManager.TraceException(ex)
			Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
			portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
			Throw
		End Try
		Return New JavaScriptSerializer().Serialize(result)
	End Function

	<WebMethod(EnableSession:=True)>
	Public Function DatiAggiuntiviPrestazione(IdRichiesta As String, IdPrestazione As String) As String


		Dim result As List(Of DatoAccessorioDizionario) = New List(Of DatoAccessorioDizionario)
		Try
			If Not (String.IsNullOrEmpty(IdRichiesta) AndAlso String.IsNullOrEmpty(IdPrestazione)) Then

				Dim datiAcc As List(Of DatoNomeValoreType) = New List(Of DatoNomeValoreType)
				Dim ds As New DI.OrderEntry.User.RiassuntoOrdineMethods
				datiAcc = ds.DatiAggiuntiviPrestazione(IdRichiesta, IdPrestazione)

				If datiAcc IsNot Nothing AndAlso datiAcc.Count > 0 Then
					For Each datoAccessorio In datiAcc
						If (Not (String.IsNullOrEmpty(datoAccessorio.DatoAccessorio.Etichetta) AndAlso String.IsNullOrEmpty(datoAccessorio.ValoreDato) AndAlso String.IsNullOrEmpty(datoAccessorio.TipoContenuto))) Then
							Dim DatiAccessori As DatoAccessorioDizionario = New DatoAccessorioDizionario
							DatiAccessori.Chiave = datoAccessorio.DatoAccessorio.Etichetta
							DatiAccessori.Valore = datoAccessorio.ValoreDato
							DatiAccessori.Tipo = datoAccessorio.TipoContenuto?.ToLower()

							If DatiAccessori.Tipo = "pdf" Then
								DatiAccessori.Valore = SaveBase64AndGetId(datoAccessorio.ValoreDato)
							End If

							result.Add(DatiAccessori)
						End If
					Next
				End If

			End If

		Catch ex As Exception
			ExceptionsManager.TraceException(ex)
			Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
			portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
			Throw
		End Try
		Return New JavaScriptSerializer().Serialize(result)
	End Function

	Protected Function SaveBase64AndGetId(base64 As String) As String
		Dim hash As String = String.Empty
		hash = base64.GetHashCode().ToString

		If HttpContext.Current.Cache(hash) IsNot Nothing Then
			Return hash
		Else
			HttpContext.Current.Cache.Add(hash, base64, Nothing, System.Web.Caching.Cache.NoAbsoluteExpiration, New TimeSpan(0, 30, 0), System.Web.Caching.CacheItemPriority.BelowNormal, Nothing)

			Return hash
		End If

		Return hash
	End Function

	Public Class DatoAccessorioDizionario
		Public Property Chiave As String
		Public Property Valore As String
		Public Property Tipo As String
	End Class
End Class