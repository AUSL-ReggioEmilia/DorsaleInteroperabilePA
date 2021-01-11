Imports System
Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports System.Data
Imports DI.OrderEntry.Admin.Data.Ennuple
Imports DI.OrderEntry.Admin.Data.EnnupleTableAdapters
Imports DI.OrderEntry.Admin.Data
Imports DI.Common
Imports System.Web.Services
Imports System.Collections.Generic
Imports System.Web
Imports DI.PortalAdmin.Data
Imports System.Configuration
Imports System.Linq
Imports System.Data.DataTableExtensions
Imports DI.OrderEntry.Admin.Data.Utenti

Namespace DI.OrderEntry.Admin

	Public Class GruppiUtenti
		Inherits Page

		Private Const PageSessionIdPrefix As String = "GruppiUtenti_"
		Private ReadOnly msPAGEKEY As String = Page.GetType().BaseType.FullName

		Private Sub Page_Load(sender As Object, e As System.EventArgs) Handles Me.Load

			If Not Page.IsPostBack Then
				FilterHelper.Restore(filterPanel, msPAGEKEY)
			End If

			Page.Form.DefaultButton = CercaButton.UniqueID

		End Sub

		Private Property SortExpression() As String
			Get
				Dim o As Object = Session(PageSessionIdPrefix + "SortExpression")
				If o Is Nothing Then Return String.Empty Else Return o.ToString()
			End Get
			Set(ByVal value As String)
				Session(PageSessionIdPrefix + "SortExpression") = value
			End Set
		End Property

		Private Property SortDirection() As SortDirection
			Get
				Dim o As Object = Session(PageSessionIdPrefix + "SortDirection")
				If o Is Nothing Then Return Nothing Else Return DirectCast(o, SortDirection)
			End Get
			Set(ByVal value As SortDirection)
				Session(PageSessionIdPrefix + "SortDirection") = value
			End Set
		End Property

		Protected Sub GridViewGruppiUtenti_Sorted(sender As Object, e As EventArgs) Handles GridViewGruppiUtenti.Sorted

			Me.SortExpression = GridViewGruppiUtenti.SortExpression
			Me.SortDirection = GridViewGruppiUtenti.SortDirection
		End Sub

		Protected Sub GridViewGruppiUtenti_ItemCommand(sender As Object, e As GridViewCommandEventArgs) Handles GridViewGruppiUtenti.RowCommand

			If e.CommandName = "Elimina" Then

				Try

					Dim idGruppo = New Guid(e.CommandArgument.ToString())
					DataAdapterManager.DeleteGroup(idGruppo)
					Response.Redirect(Request.RawUrl)

				Catch ex As Exception
					ExceptionsManager.TraceException(ex)
					Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)
					portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)

				End Try
			End If

		End Sub

		Protected Sub CaricaGruppi()
			Me.ErrorLabel.Visible = False
			FilterHelper.SaveInSession(filterPanel, msPAGEKEY)
			Me.GridViewGruppiUtenti.DataBind()
		End Sub

		<WebMethod()>
		Public Shared Function GetUtenti(idGruppo As String, ByVal descrizioneFiltroUtenteGruppo As String) As Dictionary(Of String, Object)
			Try
				Dim utentiDataTable = New UiUtentiListDataTable()
				Dim list = New Dictionary(Of String, Object)()

				DataAdapterManager.Fill(utentiDataTable, New Guid(idGruppo), descrizioneFiltroUtenteGruppo)

				For Each row As UiUtentiListRow In utentiDataTable

					'Dim user = New With {.NomeUtente = row.NomeUtente, .Descrizione = row.Descrizione, .Attivo = row.Attivo, row.Tipo}
					Dim user = New With {row.NomeUtente, row.Descrizione, row.Attivo, row.DescrizioneTipo}

					list.Add(row.ID.ToString(), user)
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
		Public Shared Function GetListaUtenti(descrizione As String) As Object()
			Try
				If Not String.IsNullOrEmpty(descrizione) Then
					descrizione = Utils.JavascriptUnEscape(descrizione)
				End If

				Dim utenteTable = New UiUtentiSelectDataTable()

				DataAdapterManager.Fill(utenteTable, Nothing)

				If utenteTable.Count = 0 Then
					Return Nothing
				Else
					'Select New With {.Id = row.ID, .NomeUtente = row.NomeUtente, .Descrizione = row.Descrizione, .Attivo = row.Attivo}
					Dim result = From row In utenteTable
					 Where String.IsNullOrEmpty(descrizione) _
					 OrElse row.Descrizione.IndexOf(descrizione, StringComparison.CurrentCultureIgnoreCase) > -1 _
					 OrElse row.NomeUtente.IndexOf(descrizione, StringComparison.CurrentCultureIgnoreCase) > -1
					Select New With {.Id = row.ID, .NomeUtente = row.NomeUtente, .Descrizione = row.Descrizione, .Attivo = row.Attivo, .DescrizioneTipo = row.DescrizioneTipo}

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
		Public Shared Function GetUtente(idUtente As String) As Object
			Try
				Dim utenteTable = New UiUtentiSelectDataTable()

				DataAdapterManager.Fill(utenteTable, New Guid(idUtente))

				If utenteTable.Count = 0 Then
					Return Nothing
				Else
					Dim row = utenteTable(0)

					Return New With {.NomeUtente = row.NomeUtente, .Descrizione = row.Descrizione, .Attivo = row.Attivo}
				End If
			Catch ex As Exception

				ExceptionsManager.TraceException(ex)

				Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)

				portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)

				Throw
			End Try
		End Function

		<WebMethod()>
		Public Shared Function UpdateUtente(idUtente As String, nomeUtente As String, descrizione As String, attivo As Boolean) As String
			Try
				If String.IsNullOrEmpty(idUtente) Then

					Dim utenteTable As New UiUtentiSelectDataTable()

					utenteTable.AddUiUtentiSelectRow(Guid.NewGuid(), Utils.JavascriptUnEscape(nomeUtente), Utils.JavascriptUnEscape(descrizione), attivo, 0, Nothing, 0, Nothing)

					DataAdapterManager.Update(utenteTable)

					Return utenteTable(0).ID.ToString()
				Else
					Dim utenteTable As New UiUtentiSelectDataTable()

					Dim row = utenteTable.AddUiUtentiSelectRow(New Guid(idUtente), Utils.JavascriptUnEscape(nomeUtente), Utils.JavascriptUnEscape(descrizione), attivo, 0, Nothing, 0, Nothing)

					utenteTable.AcceptChanges()

					row.SetModified()

					DataAdapterManager.Update(utenteTable)

					Return idUtente
				End If
			Catch ex As Exception

				ExceptionsManager.TraceException(ex)

				Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)

				portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)

				Throw
			End Try
		End Function

        <WebMethod()>
        Public Shared Function UpdateGruppo(idGruppo As String, descrizione As String, note As String) As String
            Try
                If String.IsNullOrEmpty(idGruppo) Then

                    Dim gruppoTable As New UiGruppiUtentiListDataTable()

                    gruppoTable.AddUiGruppiUtentiListRow(Guid.NewGuid(), Utils.JavascriptUnEscape(descrizione), Nothing, Utils.JavascriptUnEscape(note))

                    DataAdapterManager.Update(gruppoTable)

                    Return gruppoTable(0).ID.ToString()
                Else
                    Dim gruppoTable As New UiGruppiUtentiListDataTable()

                    Dim row = gruppoTable.AddUiGruppiUtentiListRow(New Guid(idGruppo), Utils.JavascriptUnEscape(descrizione), Nothing, Utils.JavascriptUnEscape(note))

                    gruppoTable.AcceptChanges()

                    row.SetModified()

                    DataAdapterManager.Update(gruppoTable)

                    Return idGruppo
                End If
            Catch ex As Exception

                ExceptionsManager.TraceException(ex)

                Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)

                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)

                Throw
            End Try
        End Function

        <WebMethod()>
		Public Shared Function DeleteGruppo(idGruppo As String) As String
			Try
				DataAdapterManager.DeleteGroup(New Guid(idGruppo))

				Return "ok"
			Catch ex As Exception

				ExceptionsManager.TraceException(ex)

				Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)

				portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)

				Return "error"
			End Try
		End Function

		<WebMethod()>
		Public Shared Function DeleteUserDaGruppo(idGruppo As String, idUtenti As String) As String
			Try
				For Each idUtente In idUtenti.Split(";"c)
					DataAdapterManager.DeleteUserFromGroup(New Guid(idUtente), New Guid(idGruppo))
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
		''' <param name="idGruppo"></param>
		''' <param name="idUtenti">Elenco di idUtente concatenati da ";"</param>
		''' <returns></returns>
		''' <remarks></remarks>
		<WebMethod()>
		Public Shared Function InsertUtentiInGruppo(idGruppo As String, idUtenti As String) As String
			Try
				Dim idUtentiGuid = From idUtente In idUtenti.Split(";"c)
				 Select New Guid(idUtente)

				DataAdapterManager.InsertUsersInGroup(New Guid(idGruppo), idUtentiGuid.ToArray())

				Return "ok"
			Catch ex As Exception

				ExceptionsManager.TraceException(ex)
				Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)
				portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)

				Throw
			End Try
		End Function


		Protected Sub ImportButton_Click(sender As Object, e As EventArgs) Handles ImportButton.Click

			Dim errorString As New Text.StringBuilder
			Dim dtUtente = New UiUtentiSelectDataTable()
			
			Dim iNumImportati As Integer = 0
			Dim iNumGiaPresenti As Integer = 0

			Me.ErrorLabel.Visible = False

			Try

				If Not CsvFileUpload.HasFile Then
					ErrorLabel.Text = "Selezionare il file CSV da importare e premere OK."
					ErrorLabel.Visible = True
					Return
				End If

				' se il file e' piu' grande di 10 Mb da errore
				If CsvFileUpload.PostedFile.ContentLength > CSVHelper.Size10MB Then
					ErrorLabel.Text = "Errore durante l'importazione: Il file deve avere una dimensione minore di 10MB."
					ErrorLabel.Visible = True
					Return
				End If

				If Not CSVHelper.IsValidUTF8(CsvFileUpload.FileBytes) Then
					ErrorLabel.Text = "Errore durante l'importazione: Il file deve avere codifica UTF-8."
					ErrorLabel.Visible = True
					Return
				End If

				Dim dtCSV As DataTable = CSVHelper.CsvToDataTable(CsvFileUpload.FileBytes)

				'pre-carico tutti i gruppi
				Dim taGruppi As New UiGruppiUtentiListTableAdapter()
                Dim dtGruppi = taGruppi.GetData(Nothing, Nothing, Nothing)

                If dtCSV.Columns.Contains("gruppo") And dtCSV.Columns.Contains("utente") Then
					For Each csvRow In dtCSV.Rows
                        Dim sDescGruppo As String = csvRow("gruppo").ToString.Trim
                        Dim sNoteGruppo As String = csvRow("note").ToString.Trim
                        Dim sUtente As String = csvRow("utente").ToString.Trim
						Dim gIDUtente As Guid
						Dim gIDGruppo As Guid

						Try
							'cerco il gruppo e se non esiste lo creo		
							Dim result = From row In dtGruppi
							 Where row.Descrizione.ToLower = sDescGruppo.ToLower
							   Select row.ID

							If result.Count = 0 Then
                                'UpdateGruppo sa anche inserire un record...
                                gIDGruppo = New Guid(UpdateGruppo(Nothing, sDescGruppo, sNoteGruppo))
                                'ricarico i gruppi
                                dtGruppi = taGruppi.GetData(Nothing, Nothing, Nothing)
                            Else
								gIDGruppo = result.ToArray.First
							End If

							'cerco l'utente
							DataAdapterManager.Fill(dtUtente, Nothing, sUtente, Nothing)
							'devo comunque ricercare l'utente fra i risultati perchè la stored procedure di ricerca
							'cerca anche nella descrizione...
							Dim resUtenti = From row In dtUtente
							 Where row.NomeUtente.ToLower = sUtente.ToLower
							  Select row.ID

							If resUtenti Is Nothing OrElse resUtenti.Count <> 1 Then
								errorString.AppendFormat("Errore durante l'importazione: Utente {0} non trovato.", sUtente)
								errorString.Append("<br/>")
								Continue For
							End If

							gIDUtente = resUtenti.FirstOrDefault

						Catch ex As Exception
							ExceptionsManager.TraceException(ex)
							Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)
							portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
						End Try

						Try
							'inserimento record:
							DataAdapterManager.InsertUsersInGroup(gIDGruppo, New Guid() {gIDUtente})
							iNumImportati += 1

						Catch ex As SqlClient.SqlException
							If ex.Number = 2601 Then
								'errore di chiave duplicata in inserimento... tutto ok
								iNumGiaPresenti += 1
							Else
								ExceptionsManager.TraceException(ex)
								Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)
								portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
								errorString.AppendFormat("Si è verificato un errore in fase di inserimento. Gruppo:{0}, Utente{1}", sDescGruppo, sUtente)
							End If
						End Try

					Next

					Dim sMessaggio As String = iNumImportati.ToString & " utenti inseriti nel gruppo assegnato. "
					If iNumGiaPresenti > 0 Then
						sMessaggio = sMessaggio & "<br />" & iNumGiaPresenti.ToString & " utenti erano già inclusi nel gruppo indicato."
					End If
					ClientScript.RegisterStartupScript(Me.GetType(), "Popup", "msgboxDIALOG('" & sMessaggio & "','Importazione da CSV');", True)

				Else
					errorString.Append("Errore durante l'importazione: Il file deve avere le seguenti colonne: Gruppo, Utente.")
				End If

			Catch ex As Exception
				ExceptionsManager.TraceException(ex)
				Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)
				portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
				errorString.Append("Errore durante l'importazione da file CSV.")
			End Try

			If errorString.Length > 0 Then
				ErrorLabel.Text = errorString.ToString
				ErrorLabel.Visible = True
			End If

		End Sub

	End Class

End Namespace