Imports System
Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports System.Data
Imports DI.OrderEntry.Admin.Data.Sistemi
Imports DI.OrderEntry.Admin.Data.SistemiTableAdapters
Imports DI.OrderEntry.Admin.Data
Imports DI.OrderEntry.Admin.Data.DatiAccessori
Imports DI.OrderEntry.Admin.Data.DatiAccessoriTableAdapters
Imports System.Web.Services
Imports System.Collections.Generic
Imports System.Web
Imports DI.PortalAdmin.Data
Imports System.Configuration
Imports System.Linq
Imports System.Data.DataTableExtensions
Imports System.IO
Imports System.Diagnostics

Namespace DI.OrderEntry.Admin
	Public Class ListaSistemi
		Inherits Page

		Private Const PageSessionIdPrefix As String = "ListaSistemi_"

		Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load
			Page.Form.DefaultButton = CercaButton.UniqueID

			If Not Page.IsPostBack Then
				FilterHelper.Restore(filterPanel, PageSessionIdPrefix)
			End If
		End Sub

		Private Sub AziendaFiltroDropDownList_DataBound(sender As Object, e As System.EventArgs) Handles AziendaFiltroDropDownList.DataBound
			If Not Page.IsPostBack Then
				' RICARICO IL VALORE PRECEDENTEMENTE IMPOSTATO
				FilterHelper.Restore(AziendaFiltroDropDownList, PageSessionIdPrefix)
			End If
		End Sub

        <WebMethod()>
        Public Shared Function LoadSistemi(codiceDescrizione As String, azienda As String, erogante As Boolean?, richiedente As Boolean?, attivo As Boolean?, cancellazionePostInoltro As Boolean?, cancellazionePostInCarico As Boolean?) As Dictionary(Of String, Object)
            Try
                If (erogante AndAlso richiedente) Then
                    erogante = Nothing
                    richiedente = Nothing
                ElseIf (erogante AndAlso Not richiedente) Then
                    erogante = True
                    richiedente = Nothing
                ElseIf (Not erogante AndAlso richiedente) Then
                    erogante = Nothing
                    richiedente = True
                End If
                Dim sistemiDataTable = New UiSistemiSelectDataTable()
                Dim list = New Dictionary(Of String, Object)()
                DataAdapterManager.Fill(sistemiDataTable, Nothing, If(String.IsNullOrEmpty(codiceDescrizione), Nothing, codiceDescrizione), If(String.IsNullOrEmpty(azienda), Nothing, azienda), erogante, richiedente, attivo, cancellazionePostInoltro, cancellazionePostInCarico)
                For Each row As UiSistemiSelectRow In sistemiDataTable
                    Dim sistema = New With {.Id = row.ID, .Codice = row.Codice, .Descrizione = row.Descrizione, .Azienda = row.Azienda, .Erogante = row.Erogante, .Richiedente = row.Richiedente, .Attivo = row.Attivo, .CancellazionePostInoltro = row.CancellazionePostInoltro, .CancellazionePostInCarico = row.CancellazionePostInCarico}
                    list.Add(row.ID.ToString(), sistema)
                Next
                Return If(list.Count = 0, Nothing, list)
            Catch ex As Exception
                ExceptionsManager.TraceException(ex)
                Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)
                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
                Throw
            End Try
        End Function

        ' 
        ' NON PIU' POSSIBILE DAL 2/10/2014
        '<WebMethod()>
        'Public Shared Function DeleteSistemi(idSistemi As String) As String
        '    Try
        '        For Each idSistema In idSistemi.Split(";"c)
        '            Using adapter As New UiSistemiSelectTableAdapter()
        '                adapter.Delete(New Guid(idSistema))
        '            End Using
        '        Next
        '        Return "ok"
        '    Catch ex As Exception
        '        ExceptionsManager.TraceException(ex)
        '        Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)
        '        portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
        '        Throw
        '    End Try
        'End Function

        <WebMethod()>
		Public Shared Function GetSistema(idSistema As String) As Object
			Try
				Dim sistemaTable = New UiSistemiSelectDataTable()
                DataAdapterManager.Fill(sistemaTable, New Guid(idSistema), Nothing, Nothing, Nothing, Nothing, Nothing, Nothing, Nothing)
                If sistemaTable.Count = 0 Then
					Return Nothing
				Else
					Dim row = sistemaTable(0)
                    Return New With {.Id = row.ID, .Codice = row.Codice, .Descrizione = row.Descrizione, .Azienda = row.Azienda, .Erogante = row.Erogante, .Richiedente = row.Richiedente, .Attivo = row.Attivo, .CancellazionePostInoltro = row.CancellazionePostInoltro, .CancellazionePostInCarico = row.CancellazionePostInCarico}
                End If
			Catch ex As Exception
				ExceptionsManager.TraceException(ex)
				Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)
				portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
				Throw
			End Try
		End Function

        '<WebMethod()>
        'Public Shared Function UpdateSistema(idSistema As String, attivo As Boolean, cancellazionePostInoltro As Boolean) As String
        '	Try
        '		Dim sistemaTable As New UiSistemiSelectDataTable()
        '		'Dim row = sistemaTable.AddUiSistemiSelectRow(New Guid(idSistema), HttpUtility.UrlDecode(codice), HttpUtility.UrlDecode(descrizione), erogante, richiedente, HttpUtility.UrlDecode(azienda), attivo, cancellazionePostInoltro)
        '		Dim row = sistemaTable.AddUiSistemiSelectRow(New Guid(idSistema), "", Nothing, Nothing, Nothing, "", attivo, cancellazionePostInoltro)
        '		sistemaTable.AcceptChanges()
        '		row.SetModified()
        '		DataAdapterManager.Update(sistemaTable)
        '		Return idSistema
        '	Catch ex As Exception
        '		ExceptionsManager.TraceException(ex)
        '		Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)
        '		portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
        '		Throw
        '	End Try
        'End Function

        <WebMethod()>
        Public Shared Function UpdateSistema(idSistema As String, codice As String, descrizione As String, azienda As String, erogante As Boolean, richiedente As Boolean, attivo As Boolean, cancellazionePostInoltro As Boolean, cancellazionePostInCarico As Boolean) As String
            Try
                If String.IsNullOrEmpty(idSistema) Then
                    Dim sistemaTable As New UiSistemiSelectDataTable()
                    sistemaTable.AddUiSistemiSelectRow(Guid.NewGuid(), HttpUtility.UrlDecode(codice), HttpUtility.UrlDecode(descrizione), erogante, richiedente, HttpUtility.UrlDecode(azienda), attivo, cancellazionePostInoltro, cancellazionePostInCarico)
                    DataAdapterManager.Update(sistemaTable)
                    Return sistemaTable(0).ID.ToString()
                Else
                    Dim sistemaTable As New UiSistemiSelectDataTable()
                    Dim row = sistemaTable.AddUiSistemiSelectRow(New Guid(idSistema), HttpUtility.UrlDecode(codice), HttpUtility.UrlDecode(descrizione), erogante, richiedente, HttpUtility.UrlDecode(azienda), attivo, cancellazionePostInoltro, cancellazionePostInCarico)
                    sistemaTable.AcceptChanges()
                    row.SetModified()
                    DataAdapterManager.Update(sistemaTable)
                    Return idSistema
                End If
            Catch ex As Exception
                ExceptionsManager.TraceException(ex)
                Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)
                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
                Throw
            End Try
        End Function

        <WebMethod()>
		Public Shared Function GetDatiAccessori(idSistema As String) As Dictionary(Of String, Object)
			Try
				Dim datiTable = New Data.DatiAccessori.UiSistemiDatiAccessoriListDataTable()
				Dim list = New Dictionary(Of String, Object)()
				DataAdapterManager.Fill(datiTable, New Guid(idSistema))
				For Each row In datiTable
					Dim dato = New With {.Codice = row.Codice, .Descrizione = row.Descrizione, .Etichetta = row.Etichetta, .Tipo = row.Tipo}
					list.Add(row.Codice, dato)
				Next
				Return If(list.Count = 0, Nothing, list)
			Catch ex As Exception
				ExceptionsManager.TraceException(ex)
				Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)
				portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
				Throw
			End Try
		End Function

		<WebMethod()>
		Public Shared Function GetListaDatiAccessori(codice As String, descrizione As String) As Object()
			Try
				If Not String.IsNullOrEmpty(codice) Then
					codice = HttpUtility.UrlDecode(codice)
				End If
				If Not String.IsNullOrEmpty(descrizione) Then
					descrizione = HttpUtility.UrlDecode(descrizione)
				End If

				Dim datiTable = New Data.DatiAccessori.UiDatiAccessoriListDataTable()
				DataAdapterManager.Fill(datiTable, codice, descrizione, Nothing, 1000)
				If datiTable.Count = 0 Then
					Return Nothing
				Else
					Dim result = From row In datiTable
					 Select New With {.Codice = row.Codice, .Etichetta = row.Etichetta, .Descrizione = row.Descrizione, .Tipo = row.Tipo}
					Return result.ToArray()
				End If
			Catch ex As Exception
				ExceptionsManager.TraceException(ex)
				Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)
				portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
				Throw
			End Try
		End Function

		<WebMethod()>
		Public Shared Function DeleteDatiAccessoriDaSistema(idSistema As String, codiciDatiAccessori As String) As String
			Try
				For Each codice In codiciDatiAccessori.Split(";"c)
					DataAdapterManager.DeleteDatoAccessorioFromSistema(codice, New Guid(idSistema))
				Next
				Return "ok"
			Catch ex As Exception
				ExceptionsManager.TraceException(ex)
				Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)
				portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
				Throw
			End Try
		End Function

		''' <summary>
		''' 
		''' </summary>
		''' <param name="idSistema"></param>
		''' <param name="codiciDatiAccessori">Elenco di codiciDatiAccessori concatenati da ";"</param>
		''' <returns></returns>
		''' <remarks></remarks>
		<WebMethod()>
		Public Shared Function InsertDatiAccessoriInSistema(idSistema As String, codiciDatiAccessori As String) As String
			Try
				Dim codici = From codice In codiciDatiAccessori.Split(";"c)
								   Select codice
				DataAdapterManager.InsertDatoAccessorioInSistema(New Guid(idSistema), codici.ToArray())
				Return "ok"
			Catch ex As Exception
				ExceptionsManager.TraceException(ex)
				Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)
				portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
				Throw
			End Try
		End Function

		<WebMethod()>
		Public Shared Function SaveFilter(controlId As String, value As String) As String
			If HttpContext.Current.Session(PageSessionIdPrefix + controlId) Is Nothing Then
				HttpContext.Current.Session.Add(PageSessionIdPrefix + controlId, value)
			Else
				HttpContext.Current.Session(PageSessionIdPrefix + controlId) = value
			End If
			Return "ok"
		End Function

		<WebMethod()>
		Public Shared Function GetDatiAccessoriSistemi(idSistema As Guid, codiceDatoAccessorio As String) As Object
			Try
				Dim datoTable = New UiSistemiDatiAccessoriSelectDataTable()
				DataAdapterManager.Fill(datoTable, Nothing, codiceDatoAccessorio, idSistema)
				If datoTable.Count = 0 Then
					Return Nothing
				Else
					Dim row = (From dato In datoTable
							   Where String.Equals(dato.CodiceDatoAccessorio, codiceDatoAccessorio, StringComparison.InvariantCultureIgnoreCase)
							   Select dato).First()
					'Return New With {.ID = row.Id, _
					'                 .CodiceDatoAccessorio = row.CodiceDatoAccessorio, _
					'                 .IdSistema = row.IdSistema, _
					'                 .Attivo = row.Attivo, _
					'                 .EreditaSistema = row.EreditaSistema, _
					'                 .Sistema = row.Sistema, _
					'                 .EreditaValoreDefault = row.EreditaValoreDefault, _
					'                 .ValoreDefault = row.ValoreDefault}
					Return New With {.ID = row.Id, _
									 .CodiceDatoAccessorio = row.CodiceDatoAccessorio, _
									 .IdSistema = row.IdSistema, _
									 .Attivo = row.Attivo, _
									 .Eredita = row.Eredita, _
									 .Sistema = row.Sistema, _
									 .ValoreDefault = row.ValoreDefault}
				End If
			Catch ex As Exception
				ExceptionsManager.TraceException(ex)
				Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)
				portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
				Throw
			End Try
		End Function

		<WebMethod()>
		Public Shared Function UpdateDatiAccessoriSistemi(id As Guid, idSistema As Guid, codiceDatoAccessorio As String, attivo As Boolean, eredita As Boolean, sistema As Boolean, valoreDefault As String) As String
			Try
				Dim datoTable = New UiSistemiDatiAccessoriSelectDataTable()
				Dim row = datoTable.AddUiSistemiDatiAccessoriSelectRow(id, HttpUtility.UrlDecode(codiceDatoAccessorio), idSistema, attivo, eredita, sistema, HttpUtility.HtmlDecode(HttpUtility.UrlDecode(valoreDefault)))
				datoTable.AcceptChanges()
				row.SetModified()
				DataAdapterManager.Update(datoTable)
				Return codiceDatoAccessorio
			Catch ex As Exception
				ExceptionsManager.TraceException(ex)
				Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)
				portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
				Throw
			End Try
		End Function

		<WebMethod()>
		Public Shared Function GetDatiSistemaDiDefault() As Object
			Try
				Dim datoTable = New UiLookupDatiAccessoriValoriDefaultDataTable()
				DataAdapterManager.Fill(datoTable)
				If datoTable.Count = 0 Then
					Return Nothing
				Else
					Return (From dato In datoTable
							Select New With {.Codice = dato.Codice, .Descrizione = dato.Descrizione}).ToArray()
				End If
			Catch ex As Exception
				ExceptionsManager.TraceException(ex)
				Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)
				portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
				Throw
			End Try
		End Function

	End Class
End Namespace