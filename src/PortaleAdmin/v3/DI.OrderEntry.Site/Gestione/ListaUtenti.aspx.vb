Imports System
Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports System.Data
Imports DI.OrderEntry.Admin.Data.Utenti
Imports DI.OrderEntry.Admin.Data.UtentiTableAdapters
Imports DI.OrderEntry.Admin.Data
Imports DI.Common
Imports System.Web.Services
Imports System.Collections.Generic
Imports System.Web
Imports DI.PortalAdmin.Data
Imports System.Configuration
Imports System.Linq
Imports System.Data.DataTableExtensions
Imports System.IO
Imports System.Text

Namespace DI.OrderEntry.Admin

	Public Class ListaUtenti
		Inherits Page

		Private Const PageSessionIdPrefix As String = "ListaUtenti_"
		Private Const PAGESACCercaUtente = "SACCercaUtente.aspx"
		Private Const PAGESACCercaGruppo = "SACCercaGruppo.aspx"


		Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load

			Page.Form.DefaultButton = CercaButton.UniqueID

			If Not Page.IsPostBack Then
				FilterHelper.Restore(filterPanel, PageSessionIdPrefix)
				If CodiceDescrizioneFiltroTextBox.Text.Length > 0 Then

				End If
				'PageLoadUtenti Then
			End If

		End Sub

		<WebMethod()>
		Public Shared Function LoadUtenti(codiceDescrizione As String, attivo As Boolean?, nonattivo As Boolean?, delega As Integer?) As Dictionary(Of String, Object)
			Try
				Dim utentiDataTable = New UiUtentiSelectDataTable()
				Dim list = New Dictionary(Of String, Object)()
				Dim bAttivi As Boolean?

				If (attivo And nonattivo) Or (Not attivo And Not nonattivo) Then
					bAttivi = Nothing
				Else
					bAttivi = attivo
				End If

				DataAdapterManager.Fill(utentiDataTable, Nothing, If(String.IsNullOrEmpty(codiceDescrizione), Nothing, HttpUtility.HtmlDecode(HttpUtility.UrlDecode(codiceDescrizione))), bAttivi, delega)

				For Each row As UiUtentiSelectRow In utentiDataTable
					Dim Utente = New With {.Id = row.ID,
					  .NomeUtente = row.NomeUtente,
					 .Descrizione = If(row.IsDescrizioneNull(), String.Empty, row.Descrizione),
					 .Delega = row.Delega,
					 .DescrizioneDelega = row.DescrizioneDelega,
					 .Tipo = row.Tipo,
					 .DescrizioneTipo = row.DescrizioneTipo,
					 .Attivo = row.Attivo
					 }

					list.Add(row.ID.ToString(), Utente)
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
		Public Shared Function DeleteUtenti(idUtenti As String) As String
			Try
				For Each idUtente In idUtenti.Split(";"c)

					Using adapter As New UiUtentiSelectTableAdapter()

						adapter.Delete(New Guid(idUtente))
					End Using
				Next

				Return "ok"
			Catch ex As Exception

				ExceptionsManager.TraceException(ex)

				Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)

				portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)

				Throw
			End Try
		End Function

		'<WebMethod()>
		'Public Shared Function GetUtente(idUtente As String) As Object
		'	Try
		'		Dim utenteTable = New UiUtentiSelectDataTable()

		'		DataAdapterManager.Fill(utenteTable, New Guid(idUtente), Nothing, Nothing)

		'		If utenteTable.Count = 0 Then
		'			Return Nothing
		'		Else
		'			Dim row = utenteTable(0)

		'			Return New With {.Id = row.ID,
		'			 .Codice = row.NomeUtente,
		'			  .Descrizione = row.Descrizione,
		'			  .Delega = row.Delega,
		'			  .Attivo = row.Attivo}
		'		End If
		'	Catch ex As Exception

		'		ExceptionsManager.TraceException(ex)

		'		Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)

		'		portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)

		'		Throw
		'	End Try
		'End Function

		'<WebMethod()>
		'Public Shared Function UpdateUtente(idUtente As String, ByVal delega As Integer, attivo As Boolean) As String
		'	Try
		'		If String.IsNullOrEmpty(idUtente) Then

		'			Dim ta As New UiUtentiSelectTableAdapter()

		'			ta.Update(New Guid(idUtente), attivo, delega)

		'			Return idUtente
		'		Else
		'			Dim ta As New UiUtentiSelectTableAdapter()
		'			ta.Update(New Guid(idUtente), attivo, delega)
		'			Return idUtente
		'		End If
		'	Catch ex As Exception

		'		ExceptionsManager.TraceException(ex)

		'		Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)

		'		portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)

		'		Throw
		'	End Try
		'End Function

		<WebMethod()>
		Public Shared Function SaveFilter(controlId As String, value As String) As String
			If HttpContext.Current.Session(PageSessionIdPrefix + controlId) Is Nothing Then
				HttpContext.Current.Session.Add(PageSessionIdPrefix + controlId, HttpUtility.HtmlDecode(HttpUtility.UrlDecode(value)))
			Else
				HttpContext.Current.Session(PageSessionIdPrefix + controlId) = HttpUtility.HtmlDecode(HttpUtility.UrlDecode(value))
			End If

			Return "ok"
		End Function

		Protected Sub ImportButton_Click(sender As Object, e As EventArgs) Handles ImportButton.Click

			Me.ErrorLabel.Visible = False

			If CsvFileUpload.HasFile Then

				Try

					' se il file e' piu' grande di 10 Mb da errore
					If CsvFileUpload.PostedFile.ContentLength > 1024 * 1024 * 10 Then
						ErrorLabel.Text = "Errore durante l'importazione da file csv. Il file deve avere una dimensione inferiore a 10MB."
						ErrorLabel.Visible = True
						Return
					End If

					Dim bom() As Byte = Encoding.UTF8.GetPreamble()
					Dim data() As Byte = CsvFileUpload.FileBytes
					Dim UTF8OK As Boolean = True
					For c As Integer = 0 To bom.Length - 1
						If data.Length < c + 1 OrElse Not data(c) = bom(c) Then
							UTF8OK = False
						End If
					Next
					If Not UTF8OK Then
						ErrorLabel.Text = "Errore durante l'importazione da file csv. Il file deve avere codifica UTF-8."
						ErrorLabel.Visible = True
						Return
					End If

					Dim table = DirectCast(ReadToEnd(CsvFileUpload.FileBytes), DataTable)

					If (table.Columns.Contains("NomeUtente") AndAlso table.Columns.Contains("DescrizioneUtente")) Then

						For Each row In table.Rows
							Try
								DataAdapterManager.UtentiInsertOrUpdate(row("NomeUtente"), row("DescrizioneUtente"), 1, 0)
							Catch ex As Exception
								ExceptionsManager.TraceException(ex)
								Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)
								portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
							End Try
						Next

					Else
						ErrorLabel.Text = "Errore durante l'importazione.<br /> Il file deve avere le seguenti colonne: NomeUtente, DescrizioneUtente con intestazioni di colonna nella prima riga."
						ErrorLabel.Visible = True
					End If

				Catch ex As Exception

					ExceptionsManager.TraceException(ex)

					Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)

					portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)

					ErrorLabel.Text = "Errore durante l'importazione da file csv, controllare il formato del file.  Il file deve avere le seguenti colonne: NomeUtente, DescrizioneUtente."
					ErrorLabel.Visible = True

				End Try

			Else
				ErrorLabel.Text = "Errore durante l'importazione da file csv, controllare il formato del file"
				ErrorLabel.Visible = True
			End If
		End Sub

		Protected Function ReadToEnd(fileByte As Byte()) As Object

			Dim dataSource As New DataTable
			Dim mystring As String = System.Text.UTF8Encoding.UTF8.GetString(fileByte)
			Dim fileContent As String() = mystring.Split(New String() {Microsoft.VisualBasic.vbCrLf}, StringSplitOptions.RemoveEmptyEntries)

			If (fileContent.Length > 0) Then
				Dim columns As String() = fileContent(0).Split(",")
				For Each column As String In columns
					dataSource.Columns.Add(column.ToLower)
				Next
				For Each line As String In fileContent

					If Array.IndexOf(fileContent, line) = 0 Then
						Continue For
					End If

					Dim rowData As String() = line.Split(",")
					dataSource.Rows.Add(rowData)
				Next
			End If

			Return dataSource

		End Function


		Protected Sub butAggiungiUtente_Click(sender As Object, e As EventArgs) Handles butAggiungiUtente.Click
			Response.Redirect(PAGESACCercaUtente)
		End Sub

		Protected Sub butAggiungiGruppo_Click(sender As Object, e As EventArgs) Handles butAggiungiGruppo.Click
			Response.Redirect(PAGESACCercaGruppo)
		End Sub

		Private Sub CercaButton_Click(sender As Object, e As System.EventArgs) Handles CercaButton.Click

		End Sub
	End Class

End Namespace