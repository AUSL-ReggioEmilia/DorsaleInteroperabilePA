Imports System
Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports System.Data
Imports DI.OrderEntry.Admin.Data.Prestazioni
Imports DI.OrderEntry.Admin.Data.PrestazioniTableAdapters
Imports DI.OrderEntry.Admin.Data
Imports System.Web.Services
Imports System.Collections.Generic
Imports System.Web
Imports DI.PortalAdmin.Data
Imports System.Configuration
Imports System.Linq

Namespace DI.OrderEntry.Admin

	Public Class ListaPrestazioni
		Inherits Page

		Private Const PageSessionIdPrefix As String = "ListaPrestazioni_"

		Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load
			Form.DefaultButton = CercaButton.UniqueID
			If Not Page.IsPostBack Then
                'PrestazioniListView.Sort(SortExpression, SortDirection)
            Else
				SaveFilters()
			End If
			LoadFilters()
		End Sub

        ''' <summary>
        ''' Metodo chiamato da JS per caricare la lista delle prestazioni
        ''' </summary>
        ''' <param name="codiceDescrizione"></param>
        ''' <param name="sistema"></param>
        ''' <param name="attivo"></param>
        ''' <param name="sistemaAttivo"></param>
        ''' <param name="richiedibileSoloDaProfilo"></param>
        ''' <returns></returns>
        <WebMethod()>
        Public Shared Function LoadPrestazioni(codiceDescrizione As String, sistema As String, attivo As Boolean?, sistemaAttivo As Boolean?, richiedibileSoloDaProfilo As Boolean?) As Dictionary(Of String, Object)
            Try
                Dim prestazioniDataTable = New UiPrestazioniSelectDataTable()
                Dim list = New Dictionary(Of String, Object)()
                Dim idSistema As Guid? = Nothing

                codiceDescrizione = If(String.IsNullOrEmpty(codiceDescrizione), Nothing, Utils.JavascriptUnEscape(codiceDescrizione))
                If Not String.IsNullOrEmpty(sistema) Then
                    idSistema = New Guid(sistema)
                End If
                DataAdapterManager.Fill(prestazioniDataTable, Nothing, codiceDescrizione, idSistema, attivo, sistemaAttivo, richiedibileSoloDaProfilo)
                For Each row As UiPrestazioniSelectRow In prestazioniDataTable
                    Dim Prestazione = New With {.Id = row.ID, .Codice = row.Codice, .Descrizione = row.Descrizione, .SistemaErogante = row.SistemaErogante, .Attivo = row.Attivo, .CodiceSinonimo = If(row.IsCodiceSinonimoNull, String.Empty, row.CodiceSinonimo), .RichiedibileSoloDaProfilo = row.RichiedibileSoloDaProfilo}
                    list.Add(row.ID.ToString(), Prestazione)
                Next
                Return If(list.Count = 0, Nothing, list)
            Catch ex As Exception
                ExceptionsManager.TraceException(ex)
                Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)
                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
                Return Nothing
            End Try
        End Function

        ''' <summary>
        ''' Metodo di cancellazione delle prestazioni.
        ''' </summary>
        ''' <param name="idPrestazioni"></param>
        ''' <returns></returns>
        <WebMethod()>
		Public Shared Function DeletePrestazioni(idPrestazioni As String) As String
			Try
				Dim usernName = My.User.Name
				For Each idPrestazione In idPrestazioni.Split(";"c)
					Using adapter As New UiPrestazioniSelectTableAdapter()
						adapter.Delete(New Guid(idPrestazione), usernName)
					End Using
				Next
				Return "ok"
			Catch ex As Exception
				ExceptionsManager.TraceException(ex)
				Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)
				portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
				Return Nothing
			End Try
		End Function

        ''' <summary>
        ''' Metodo che ottiene la prestazione in base al suo id.
        ''' </summary>
        ''' <param name="idPrestazione"></param>
        ''' <returns></returns>
        <WebMethod()>
		Public Shared Function GetPrestazione(idPrestazione As String) As Object
			Try
				Dim prestazioneTable = New UiPrestazioniSelectDataTable()
                DataAdapterManager.Fill(prestazioneTable, New Guid(idPrestazione), Nothing, Nothing, Nothing, Nothing, Nothing)
                If prestazioneTable.Count = 0 Then
					Return Nothing
				Else
					Dim row = prestazioneTable(0)
                    Return New With {.Id = row.ID, .Codice = row.Codice, .Descrizione = row.Descrizione, .idErogante = row.IDSistemaErogante, .Attivo = row.Attivo, .CodiceSinonimo = If(row.IsCodiceSinonimoNull, String.Empty, row.CodiceSinonimo), .RichiedibileSoloDaProfilo = row.RichiedibileSoloDaProfilo}
                End If
			Catch ex As Exception
				ExceptionsManager.TraceException(ex)
				Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)
				portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
				Return Nothing
			End Try
		End Function

        ''' <summary>
        ''' Metodo di aggiornamento/inserimento di una prestazione.
        ''' </summary>
        ''' <param name="idPrestazione"></param>
        ''' <param name="codice"></param>
        ''' <param name="descrizione"></param>
        ''' <param name="erogante"></param>
        ''' <param name="attivo"></param>
        ''' <param name="codiceSinonimo"></param>
        ''' <returns></returns>
        <WebMethod()>
        Public Shared Function UpdatePrestazione(idPrestazione As String, codice As String, descrizione As String, erogante As String, attivo As Boolean?, codiceSinonimo As String, richiedibileSoloDaProfilo As Boolean) As String
            Try
                Dim idSistema As Guid? = Nothing
                If Not String.IsNullOrEmpty(erogante) Then
                    idSistema = New Guid(erogante)
                End If
                If String.IsNullOrEmpty(idPrestazione) Then
                    Dim prestazioneTable As New UiPrestazioniSelectDataTable()
                    prestazioneTable.AddUiPrestazioniSelectRow(Guid.NewGuid(), Nothing, Nothing, Nothing, My.User.Name, Utils.JavascriptUnEscape(codice), Utils.JavascriptUnEscape(descrizione), 0, 0, idSistema, Nothing, attivo, If(String.IsNullOrEmpty(codiceSinonimo), Nothing, Utils.JavascriptUnEscape(codiceSinonimo)), richiedibileSoloDaProfilo)
                    DataAdapterManager.Update(prestazioneTable)
                    Return prestazioneTable(0).ID.ToString()
                Else
                    Dim prestazioneTable As New UiPrestazioniSelectDataTable()
                    Dim row = prestazioneTable.AddUiPrestazioniSelectRow(New Guid(idPrestazione), Nothing, Nothing, Nothing, My.User.Name, Utils.JavascriptUnEscape(codice), Utils.JavascriptUnEscape(descrizione), 0, 0, idSistema, Nothing, attivo, If(String.IsNullOrEmpty(codiceSinonimo), Nothing, Utils.JavascriptUnEscape(codiceSinonimo)), richiedibileSoloDaProfilo)
                    prestazioneTable.AcceptChanges()
                    row.SetModified()
                    DataAdapterManager.Update(prestazioneTable)
                    Return idPrestazione
                End If
            Catch ex As Exception
                ExceptionsManager.TraceException(ex)
                Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)
                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
                'Return Nothing
                Throw ex
            End Try
        End Function

        <WebMethod()>
		Public Shared Function GetDatiAccessori(idPrestazione As String) As Dictionary(Of String, Object)
			Try
				Dim datiTable = New Data.DatiAccessori.UiPrestazioniDatiAccessoriListDataTable()
				Dim list = New Dictionary(Of String, Object)()
				DataAdapterManager.Fill(datiTable, New Guid(idPrestazione))
				For Each row In datiTable
					Dim dato = New With {.Codice = row.Codice, .Descrizione = row.Descrizione, .Etichetta = row.Etichetta, .Tipo = row.Tipo}
					list.Add(row.Codice, dato)
				Next
				Return If(list.Count = 0, Nothing, list)
			Catch ex As Exception
				ExceptionsManager.TraceException(ex)
				Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)
				portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
				Return Nothing
			End Try
		End Function

		<WebMethod()>
		Public Shared Function GetListaDatiAccessori(codice As String, descrizione As String) As Object()
			Try
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
				Return Nothing
			End Try
		End Function

		<WebMethod()>
		Public Shared Function DeleteDatiAccessoriDaPrestazione(idPrestazione As String, codiciDatiAccessori As String) As String
			Try
				For Each codice In codiciDatiAccessori.Split(";"c)
					DataAdapterManager.DeleteDatoAccessorioFromPrestazione(codice, New Guid(idPrestazione))
				Next
				Return "ok"
			Catch ex As Exception
				ExceptionsManager.TraceException(ex)
				Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)
				portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
				Return Nothing
			End Try
		End Function

		''' <summary>
		''' 
		''' </summary>
		''' <param name="idPrestazione"></param>
		''' <param name="codiciDatiAccessori">Elenco di codiciDatiAccessori concatenati da ";"</param>
		''' <returns></returns>
		''' <remarks></remarks>
		<WebMethod()>
		Public Shared Function InsertDatiAccessoriInPrestazione(idPrestazione As String, codiciDatiAccessori As String) As String
			Try
				Dim codici = From codice In codiciDatiAccessori.Split(";"c)
							 Select codice
				DataAdapterManager.InsertDatoAccessorioInPrestazione(New Guid(idPrestazione), codici.ToArray())
				Return "ok"
			Catch ex As Exception
				ExceptionsManager.TraceException(ex)
				Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)
				portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
				Return Nothing
			End Try
		End Function

		Private Sub LoadFilters()
			For Each control As Control In filterPanel.Controls
				Dim value As String = If(String.IsNullOrEmpty(control.ID), String.Empty, Session(PageSessionIdPrefix + control.ID))
				If value Is Nothing Then
					Continue For
				End If
				Dim filterTextBox = TryCast(control, TextBox)
				If filterTextBox IsNot Nothing Then
					filterTextBox.Text = value
				Else
					Dim filterComboBox = TryCast(control, DropDownList)
					If filterComboBox IsNot Nothing Then
						filterComboBox.SelectedValue = value
					Else
						Dim filterCheckBox = TryCast(control, CheckBox)
						If filterCheckBox IsNot Nothing Then
							filterCheckBox.Checked = Boolean.Parse(value)
						End If
					End If
				End If
			Next
		End Sub

		<WebMethod()>
		Public Shared Function SaveFilter(controlId As String, value As String) As String
			If HttpContext.Current.Session(PageSessionIdPrefix + controlId) Is Nothing Then
				HttpContext.Current.Session.Add(PageSessionIdPrefix + controlId, value)
			Else
				HttpContext.Current.Session(PageSessionIdPrefix + controlId) = value
			End If
			Return "ok"
		End Function

		Private Sub SaveFilters()
			For Each control As Control In filterPanel.Controls
				Dim value As String = String.Empty
				Dim filterTextBox = TryCast(control, TextBox)
				If filterTextBox IsNot Nothing Then
					value = filterTextBox.Text
				Else
					Dim filterComboBox = TryCast(control, DropDownList)
					If filterComboBox IsNot Nothing Then
						value = filterComboBox.SelectedValue
					Else
						Dim filterCheckBox = TryCast(control, CheckBox)
						If filterCheckBox IsNot Nothing Then
							value = filterCheckBox.Checked.ToString()
						End If
					End If
				End If
				If Session(PageSessionIdPrefix + control.ID) Is Nothing Then
					Session.Add(PageSessionIdPrefix + control.ID, value)
				Else
					Session(PageSessionIdPrefix + control.ID) = value
				End If
			Next
		End Sub

		Protected Sub ImportButton_Click(sender As Object, e As EventArgs) Handles ImportButton.Click
			Me.ErrorLabel.Visible = False
			Dim errorString As New Text.StringBuilder
			If CsvFileUpload.HasFile Then
				Try
					' se il file e' piu' grande di 10 Mb da errore
					If CsvFileUpload.PostedFile.ContentLength > CSVHelper.Size10MB Then
						ErrorLabel.Text = "Errore durante l'importazione da file csv. Il file deve avere una dimensione minore di 10 Mb."
						ErrorLabel.Visible = True
						Return
					End If
					Dim data As Byte() = CsvFileUpload.FileBytes
					If Not CSVHelper.IsValidUTF8(data) Then
						ErrorLabel.Text = "Errore durante l'importazione da file csv. Il file deve avere codifica UTF-8."
						ErrorLabel.Visible = True
						Return
					End If
                    Dim sErroriCol = CSVHelper.FirstLineContainsValues(data, {"CodiceAzienda", "CodiceSistema", "CodicePrestazione", "DescrizionePrestazione", "SinonimoPrestazione"})

                    If sErroriCol.Length = 0 Then
						Dim tbCSV As DataTable = CSVHelper.CsvToDataTable(data)
						Dim sistemi As New Sistemi.UiSistemiSelectDataTable()
                        DataAdapterManager.Fill(sistemi, Nothing, Nothing, Nothing, True, Nothing, Nothing, Nothing, Nothing)

                        For Each row In tbCSV.Rows
							Try
								Dim codiceAzienda = Utils.StringEmptyDBNullToNothing(row("CodiceAzienda"))
								Dim codiceSistema = Utils.StringEmptyDBNullToNothing(row("CodiceSistema"))
								Dim codicePrestazione = Utils.StringEmptyDBNullToNothing(row("CodicePrestazione"))
								Dim descrizionePrestazione = Utils.StringEmptyDBNullToNothing(row("DescrizionePrestazione"))
								Dim sinonimoPrestazione = Utils.StringEmptyDBNullToNothing(row("SinonimoPrestazione"))
								Dim resultSistema = From sistema In sistemi
													Where sistema.Azienda = codiceAzienda AndAlso sistema.Codice = codiceSistema
													Select sistema.ID
								If Not (resultSistema Is Nothing OrElse resultSistema.Count <> 1) Then
                                    DataAdapterManager.PrestazioniInsertOrUpdate(codicePrestazione, descrizionePrestazione, resultSistema.FirstOrDefault, My.User.Name, True, sinonimoPrestazione)
                                Else
									errorString.Append("Non è stato possibile aggiungere la seguente riga (non esiste il sistema erogante): " & "codiceSistema= " & codiceSistema & "; codiceAzienda= " & codiceAzienda & "; codicePrestazione= " & codicePrestazione & "; descrizionePrestazione= " & descrizionePrestazione & "; sinonimoPrestazione= " & sinonimoPrestazione)
								End If
							Catch ex As Exception
								ExceptionsManager.TraceException(ex)
								Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)
								portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
							End Try
						Next
					Else
						errorString.Append("Errore durante l'importazione da file csv. Il file deve avere le seguenti colonne: CodiceAzienda, CodiceSistema, CodicePrestazione, DescrizionePrestazione, SinonimoPrestazione.")
						errorString.Append("<br/>")
						errorString.Append(sErroriCol)
					End If
				Catch ex As Exception
					ExceptionsManager.TraceException(ex)
					Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)
					portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
					errorString.Append("Errore durante l'importazione da file csv, controllare il formato del file. Il file deve avere le seguenti colonne: CodiceAzienda, CodiceSistema, CodicePrestazione, DescrizionePrestazione, SinonimoPrestazione.")
					ErrorLabel.Visible = True
				End Try
			Else
				errorString.Append("Errore durante l'importazione da file csv, controllare il formato del file e se il file è vuoto.")
			End If
			If errorString.ToString.Length > 0 Then
#If DEBUG Then
				errorString.AppendLine("Intestazione letta: [" & CSVHelper.ReadFirstLine(CsvFileUpload.FileBytes) & "]")
#End If
				ErrorLabel.Text = errorString.ToString
				ErrorLabel.Visible = True
			End If
		End Sub

		<WebMethod()>
		Public Shared Function GetDatiAccessoriPrestazioni(idPrestazione As Guid, codiceDatoAccessorio As String) As Object
			Try
				Dim datoTable = New UiPrestazioniDatiAccessoriSelectDataTable()
				DataAdapterManager.Fill(datoTable, Nothing, codiceDatoAccessorio, idPrestazione)
				If datoTable.Count = 0 Then
					Return Nothing
				Else
					Dim row = (From dato In datoTable
							   Where String.Equals(dato.CodiceDatoAccessorio, codiceDatoAccessorio, StringComparison.InvariantCultureIgnoreCase)
							   Select dato).First()
					Return New With {.ID = row.Id,
									 .CodiceDatoAccessorio = row.CodiceDatoAccessorio,
									 .IdPrestazione = row.IDPrestazione,
									 .Attivo = row.Attivo,
									 .Eredita = row.Eredita,
									 .Sistema = row.Sistema,
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
		Public Shared Function UpdateDatiAccessoriPrestazioni(id As Guid, idPrestazione As Guid, codiceDatoAccessorio As String, attivo As Boolean, eredita As Boolean, sistema As Boolean, valoreDefault As String) As String
			Try
				Dim datoTable = New UiPrestazioniDatiAccessoriSelectDataTable()
				Dim row = datoTable.AddUiPrestazioniDatiAccessoriSelectRow(id, Utils.JavascriptUnEscape(codiceDatoAccessorio), idPrestazione, attivo, eredita, sistema, Utils.JavascriptUnEscape(HttpUtility.UrlDecode(valoreDefault)))
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
				Dim datoTable = New Data.DatiAccessori.UiLookupDatiAccessoriValoriDefaultDataTable()
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