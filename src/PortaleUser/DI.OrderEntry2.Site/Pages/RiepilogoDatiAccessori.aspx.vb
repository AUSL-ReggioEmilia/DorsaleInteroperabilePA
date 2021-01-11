Imports System.Collections.Generic
Imports System.ComponentModel
Imports System.Linq
Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports CustomDataSource
Imports DI.OrderEntry.Services
Imports DI.OrderEntry.User
Imports DI.PortalUser2.Data

Public Class RiepilogoDatiAccessori
	Inherits System.Web.UI.Page
	Public Property IdRichiesta() As String
		Get
			Return Me.ViewState("IdRichiesta")
		End Get
		Set(ByVal value As String)
			Me.ViewState.Add("IdRichiesta", value)
		End Set
	End Property
	Public Property isAccessoDiretto() As Boolean
		Get
			Return Me.ViewState("isAccessoDiretto")
		End Get
		Set(ByVal value As Boolean)
			Me.ViewState.Add("isAccessoDiretto", value)
		End Set
	End Property

	Private Sub RiepilogoDatiAccessori_PreInit(sender As Object, e As EventArgs) Handles Me.PreInit
		Try
			If RouteData.Values("AccessoDiretto") IsNot Nothing Then
				isAccessoDiretto = CType(RouteData.Values("AccessoDiretto"), Boolean)
				If isAccessoDiretto Then
					Me.MasterPageFile = "~/SiteAccessoDiretto.master"
				End If
			End If
		Catch ex As Exception
			gestioneErrori(ex)
		End Try
	End Sub

	Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load
		Try
			'Ricavo dai parametri della querystring i dati necessari perchè alcune operazioni da effettuare in seguito funzionino
			If Not Page.IsPostBack Then

                'Cancello la cache per evitare di utilizzare dati vecchi o sbagliati
                Dim dataSource2 As New PrestazioniErogate
				dataSource2.ClearCache()

				Me.IdRichiesta = Request.QueryString("IdRichiesta")
			End If

			Using webService As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")
				Dim userData = UserDataManager.GetUserData()
				Dim request = New OttieniOrdinePerIdGuidRequest(userData.Token, Me.IdRichiesta)
				Dim resp = webService.OttieniOrdinePerIdGuid(request)
				Dim Richiesta As StatoType = resp.OttieniOrdinePerIdGuidResult

				If Richiesta IsNot Nothing Then

					'inizializzo i campi con i relativi valori
					lblIdRichiesta.InnerText = CType(Richiesta.Ordine.IdRichiestaOrderEntry, String)
					lblUo.InnerText = CType(Richiesta.Ordine.UnitaOperativaRichiedente.UnitaOperativa.Descrizione, String)
					lblRegime.InnerText = CType(Richiesta.Ordine.Regime.Descrizione, String)
					lblPriorita.InnerText = CType(Richiesta.Ordine.Priorita.Descrizione, String)

					Dim dataPrenotazione As String = If(Not Richiesta.Ordine.DataPrenotazione.HasValue OrElse Richiesta.Ordine.DataPrenotazione = DateTime.MinValue, "-", Richiesta.Ordine.DataPrenotazione.Value.ToString("dd/MM/yy HH:mm"))
					lblDataPrenotazione.InnerText = CType(dataPrenotazione, String)
				End If
			End Using
		Catch ex As Exception
			gestioneErrori(ex)
		End Try
	End Sub

	''' <summary>
	''' Funzione per trappare gli errori e mostrare il div d'errore.
	''' </summary>
	''' <param name="ex"></param>
	Private Sub gestioneErrori(ex As Exception)

		'Testo di errore generico da visualizzare nel divError della pagina.
		Dim errorMessage As String = "Si è verificato un errore. Contattare l'amministratore del sito"

		'Se ex è una ApplicationException, allora contiene un messaggio di errore personalizzato che viene visualizzato poi
		'nel divError della pagina.
		If TypeOf ex Is ApplicationException Then
			errorMessage = ex.Message
		End If

		'Scrivo l'errore nell'event viewer.
		ExceptionsManager.TraceException(ex)
		Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
		portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)

		'Visualizzo il messaggio di errore nella pagina.
		divErrorMessage.Visible = True
		lblError.Text = errorMessage
	End Sub

	''' <summary>
	''' Recupero il campo etichetta dall'oggetto DatoAccessorio
	''' </summary>
	''' <param name="oDatoAccessorio"></param>
	''' <returns></returns>
	Protected Function GetEtichetta(oDatoAccessorio As Object) As String
		Dim etichetta As String = String.Empty

		Try
			Dim datoAccessorio As DatoAccessorioType = CType(oDatoAccessorio, DatoAccessorioType)
			etichetta = datoAccessorio.Etichetta
		Catch ex As Exception
			'
			'Vado avanti
			'
		End Try
		Return etichetta
	End Function

	Protected Sub rptDatiAccessoriErogante_ItemDataBound(sender As Object, e As RepeaterItemEventArgs)
		Try
			If e.Item.ItemType = ListItemType.Item OrElse e.Item.ItemType = ListItemType.AlternatingItem Then
				Dim sistema As String = TryCast(e.Item.DataItem, String)
				Dim rptDatiAccessoriPrestazioni As Repeater = TryCast(e.Item.FindControl("rptDatiAccessoriPrestazioni"), Repeater)
				rptDatiAccessoriPrestazioni.DataSource = getItem(sistema)
				rptDatiAccessoriPrestazioni.DataBind()
			End If
		Catch ex As Exception
			gestioneErrori(ex)
		End Try
	End Sub

	Public Function getItem(sistema As String) As Dictionary(Of String, String)
		Dim result As Dictionary(Of String, String) = New Dictionary(Of String, String)
		Try
			Dim prestazioni As List(Of PrestazioneErogata) = GetPrestazioniBySistema(Me.IdRichiesta, sistema)
			For Each p In prestazioni
				result.Add(p.Id, p.Codice)
			Next
		Catch ex As Exception
			gestioneErrori(ex)
		End Try
		Return result
	End Function

	Private Sub gvDatiAccessoriTestata_PreRender(sender As Object, e As EventArgs) Handles gvDatiAccessoriTestata.PreRender
		Try
			'Render per Bootstrap
			'Crea la Table con Theader e Tbody se l'header non è nothing.
			If Not gvDatiAccessoriTestata.HeaderRow Is Nothing Then
				gvDatiAccessoriTestata.UseAccessibleHeader = True
				gvDatiAccessoriTestata.HeaderRow.TableSection = TableRowSection.TableHeader
			End If

			'Converte i tag html generati dalla GridView per la paginazione
			' e li adatta alle necessita dei CSS Bootstrap
			gvDatiAccessoriTestata.PagerStyle.CssClass = "pagination-gridview"
			ScriptManager.RegisterStartupScript(Page, Page.GetType(), "gridPagination", HelperGridView.GetScriptPaginationForBootstrap(), True)
		Catch ex As Exception
			gestioneErrori(ex)
		End Try
	End Sub


	''' <summary>
	''' Ottiene la lista dei distinti CodiciEroganti tramite query LINQ sull'oggetto restituito da GetPrestazioniInseriteFromRichiesta
	''' </summary>
	''' <param name="IdRichiesta"></param>
	''' <returns></returns>
	<DataObjectMethod(DataObjectMethodType.Select)>
	Public Function GetDistinctSistemiFromPrestazioni(IdRichiesta As String) As List(Of String)
		Dim eroganti As New List(Of String)
		Try
			Dim datasource As New PrestazioniErogate
			'ottengo tutte le prestazioni della richiesta
			Dim listaPrestazioni As List(Of PrestazioneErogata) = datasource.GetData(IdRichiesta)

			eroganti = (From prestazione In listaPrestazioni
						Select prestazione.SistemaErogante).Distinct().ToList()
		Catch ex As Exception
			ExceptionsManager.TraceException(ex)
			Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
			portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
		End Try
		Return eroganti
	End Function

	''' <summary>
	''' Ottiene la lista delle prestazioni per l'erogante e id richiesta
	''' </summary>
	''' <param name="IdRichiesta"></param>
	''' <param name="Sistema"></param>
	''' <returns></returns>
	<DataObjectMethod(DataObjectMethodType.Select)>
	Public Function GetPrestazioniBySistema(IdRichiesta As String, Sistema As String) As List(Of PrestazioneErogata)

		Dim prestazioni As New List(Of PrestazioneErogata)

		Try
			Dim datasource As New PrestazioniErogate
			'ottengo tutte le prestazioni della richiesta
			Dim listaPrestazioni As List(Of PrestazioneErogata) = datasource.GetData(IdRichiesta)

			If listaPrestazioni IsNot Nothing AndAlso listaPrestazioni.Count > 0 Then
				prestazioni = (From prestazione In listaPrestazioni
							   Where String.Equals(prestazione.SistemaErogante, Sistema)
							   Select prestazione).ToList()
			End If
		Catch ex As Exception
			ExceptionsManager.TraceException(ex)
			Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
			portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
		End Try

		Return prestazioni
	End Function

End Class