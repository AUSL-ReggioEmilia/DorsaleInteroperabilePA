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
Imports DI.OrderEntry.Admin
Imports DI.OrderEntry.Admin.Data.Utenti

Public Class GruppiPrestazioniServer
	Inherits System.Web.UI.Page

	Private Const PageSessionIdPrefix As String = "GruppiPrestazioni_"
    Private ReadOnly msPAGEKEY As String = Page.GetType().BaseType.FullName

    Public Sub CaricaGruppi()
        Me.ErrorLabel.Visible = False
        Me.ObjectDataSourceGruppiPrestazioni.DataBind()
        Me.GridViewGruppiPrestazioni.DataBind()
        FilterHelper.SaveInSession(filterPanel, msPAGEKEY)
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

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load

        Form.DefaultButton = filterCercaButton.UniqueID

        If Not Page.IsPostBack Then
            FilterHelper.Restore(filterPanel, msPAGEKEY)
            Me.GridViewGruppiPrestazioni.Sort(SortExpression, SortDirection)
        End If
    End Sub

    Protected Sub GridViewGruppiPrestazioni_Sorted(sender As Object, e As EventArgs) Handles GridViewGruppiPrestazioni.Sorted

        Me.SortExpression = GridViewGruppiPrestazioni.SortExpression
        Me.SortDirection = GridViewGruppiPrestazioni.SortDirection
    End Sub

    Protected Sub GridViewGruppiPrestazioni_ItemCommand(sender As Object, e As GridViewCommandEventArgs) Handles GridViewGruppiPrestazioni.RowCommand
		Try
			Select Case e.CommandName
				Case "Elimina"
					Dim idGruppo = New Guid(e.CommandArgument.ToString())
					DataAdapterManager.DeleteGroupPrestazioni(idGruppo)
					Response.Redirect(Request.RawUrl)
			End Select

		Catch ex As Exception
			ExceptionsManager.TraceException(ex)
			Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)
			portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
		End Try
	End Sub

	Protected Sub ImportButton_Click(sender As Object, e As EventArgs) Handles ImportButton.Click

		Dim errorString As New Text.StringBuilder
		Dim iNumImportati As Integer = 0
		Dim iNumGiàPresenti As Integer = 0

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

			'precarico i sistemi eroganti
			Dim dtSistemiErog = New UiLookupSistemiErogantiDataTable()
			DataAdapterManager.Fill(dtSistemiErog, Nothing, False)

			'precarico i gruppi di prestazioni
			Dim taGruppiPrest As New UiGruppiPrestazioniListTableAdapter()
            Dim dtGruppiPrest = taGruppiPrest.GetData(Nothing, Nothing, Nothing, Nothing, Nothing)

            If dtCSV.Columns.Contains("Gruppo") And dtCSV.Columns.Contains("Preferito") And
             dtCSV.Columns.Contains("CodicePrestazione") And dtCSV.Columns.Contains("AziendaEroganteSistemaCodice") And
             dtCSV.Columns.Contains("Note") Then

                Dim gIdGruppo As Guid = Nothing
                Dim sOLDDescGruppo As String = ""
                Dim gIdSistema As Guid = Nothing
                Dim sOLDAziendaEroganteSistemaCodice As String = ""
                Dim iRiga As Integer = 0

                For Each csvRow In dtCSV.Rows
                    iRiga += 1
                    Dim gIdPrestazione As Guid = Nothing
                    Dim bPreferito As Boolean = csvRow("Preferito").ToString.Trim = "1"
                    Dim sCodicePrestazione As String = csvRow("CodicePrestazione").ToString.Trim
                    Dim sDescGruppo As String = csvRow("gruppo").ToString.Trim
                    Dim sAziendaEroganteSistemaCodice As String = csvRow("AziendaEroganteSistemaCodice").ToString.Trim
                    Dim sNote As String = csvRow("Note").ToString()

                    Try
                        'salto le righe incomplete
                        If String.IsNullOrEmpty(sDescGruppo) Or String.IsNullOrEmpty(sCodicePrestazione) Or String.IsNullOrEmpty(sAziendaEroganteSistemaCodice) Then
                            errorString.AppendFormat("Riga {0} incompleta. ", iRiga.ToString)
                            Continue For
                        End If

                        'non ricerco il gruppo se è uguale a quello del giro prima
                        If sOLDDescGruppo <> sDescGruppo Then
                            'cerco il gruppo di prestazioni
                            Dim result = From gruppo In dtGruppiPrest
                                         Where gruppo.Descrizione.ToLower = sDescGruppo.ToLower
                                         Select gruppo.ID

                            If result.Count = 0 Then
                                'UpdateGruppo sa anche inserire un record...
                                gIdGruppo = New Guid(UpdateGruppo(Nothing, sDescGruppo, bPreferito, Nothing, sNote))
                                'ricarico la datatable dei gruppi
                                dtGruppiPrest = taGruppiPrest.GetData(Nothing, Nothing, Nothing, Nothing, sNote)
                            Else
                                gIdGruppo = result.ToArray.First
                            End If

                            sOLDDescGruppo = sDescGruppo
                        End If

                        'non ricerco il sistema se è uguale a quello del giro prima
                        If sOLDAziendaEroganteSistemaCodice <> sAziendaEroganteSistemaCodice Then
                            'cerco il sistema erogante
                            Dim result = From sis In dtSistemiErog
                                         Where sis.Descrizione.ToLower = sAziendaEroganteSistemaCodice.ToLower
                                         Select sis.Id
                            If result.Count = 0 Then
                                errorString.AppendFormat("Sistema Erogante {0} non trovato. ", sAziendaEroganteSistemaCodice)
                                gIdSistema = Nothing
                                Continue For
                            End If
                            gIdSistema = result.ToArray.First
                            sOLDAziendaEroganteSistemaCodice = sAziendaEroganteSistemaCodice
                        End If

                        'cerco la prestazione
                        Dim dtPrestazione = New UiPrestazioniSelectDataTable()
                        DataAdapterManager.Fill(dtPrestazione, Nothing, sCodicePrestazione, gIdSistema, Nothing)
                        If dtPrestazione.Count = 0 Then
                            errorString.AppendFormat("Prestazione {0} non trovata. ", sCodicePrestazione)
                            Continue For
                        End If
                        gIdPrestazione = dtPrestazione(0).ID

                    Catch ex As Exception
                        ExceptionsManager.TraceException(ex)
                        Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)
                        portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
                    End Try

                    Try
                        'inserisco la prestazione nel gruppo
                        DataAdapterManager.InsertPrestazioniInGroup(gIdGruppo, New Guid() {gIdPrestazione})
                        iNumImportati += 1

                    Catch ex As SqlClient.SqlException
                        If ex.Number = 2601 Then
                            'errore di chiave duplicata in inserimento... tutto ok
                            iNumGiàPresenti += 1
                        Else
                            ExceptionsManager.TraceException(ex)
                            Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)
                            portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
                            errorString.AppendFormat("La riga {0} non puù essere importata.  ", iRiga.ToString)
                        End If
                    End Try

                Next

                Dim sMessaggio As String = iNumImportati.ToString & " prestazioni inserite nel gruppo assegnato. "
                If iNumGiàPresenti > 0 Then
                    sMessaggio = sMessaggio & "<br />" & iNumGiàPresenti.ToString & " prestazioni erano già incluse nel gruppo indicato."
                End If
                ClientScript.RegisterStartupScript(Me.GetType(), "Popup", "msgboxDIALOG('" & sMessaggio & "','Importazione da CSV');", True)

                GridViewGruppiPrestazioni.DataBind()
            Else
                errorString.Append("Il file deve avere le seguenti colonne: Gruppo,Preferito,CodicePrestazione,AziendaEroganteSistemaCodice,Note")
            End If

		Catch ex As Exception
			ExceptionsManager.TraceException(ex)
			Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)
			portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
			errorString.Append("Contattare l'amministratore. ")
		End Try

		If errorString.Length > 0 Then
			errorString.Insert(0, "Errore durante l'importazione: ")
			ErrorLabel.Text = errorString.ToString
			ErrorLabel.Visible = True
		End If

	End Sub

	<WebMethod()>
	Public Shared Function GetLookupSistemiEroganti() As Dictionary(Of String, String)
		Try
			Dim sistemiLookup = New UiLookupSistemiErogantiDataTable()

			DataAdapterManager.Fill(sistemiLookup, Nothing, False)

			Return (From sistema In sistemiLookup
			 Select New With {.Id = sistema.Id, .Descrizione = sistema.Descrizione}).ToDictionary(Of String, String)(Function(kv) CType(kv.Id, Guid).ToString(), Function(kv) kv.Descrizione)
		Catch ex As Exception

			ExceptionsManager.TraceException(ex)

			Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)

			portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)

			Throw
		End Try
	End Function

    <WebMethod()>
    Public Shared Function UpdateGruppo(idGruppo As String, descrizione As String, ByVal preferito As Boolean, CopiaDaGruppoId As String, note As String) As String
        Try
            If String.IsNullOrEmpty(idGruppo) Then

                Dim gruppoTable As New UiGruppiPrestazioniListDataTable()
                gruppoTable.AddUiGruppiPrestazioniListRow(Nothing, Utils.JavascriptUnEscape(descrizione), preferito, Nothing, note)
                DataAdapterManager.Update(gruppoTable)
                Dim gIDNuovoGruppo As Guid = gruppoTable(0).ID
                'copio le stesse prestazioni anche sul nuovo gruppo
                If Not String.IsNullOrEmpty(CopiaDaGruppoId) Then
                    Dim gIDGruppoOrigine As Guid = New Guid(CopiaDaGruppoId)
                    DataAdapterManager.PrestazioniGruppiPrestazioniCopy(gIDGruppoOrigine, gIDNuovoGruppo)
                End If

                Return gIDNuovoGruppo.ToString()

            Else
                Dim gruppoTable As New UiGruppiPrestazioniListDataTable()
                Dim row = gruppoTable.AddUiGruppiPrestazioniListRow(New Guid(idGruppo), Utils.JavascriptUnEscape(descrizione), preferito, Nothing, note)
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
            DataAdapterManager.DeleteGroupPrestazioni(New Guid(idGruppo))

            Return "ok"
        Catch ex As Exception
            ExceptionsManager.TraceException(ex)

            Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)

            portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)

            Return "error"
        End Try
    End Function

    <WebMethod()>
	Public Shared Function DeletePrestazioneDaGruppo(idGruppo As String, idPrestazioni As String) As String
		Try
			For Each idPrestazione In idPrestazioni.Split(";"c)
				DataAdapterManager.DeletePrestazioneFromGroup(New Guid(idPrestazione.ToString()), New Guid(idGruppo))
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
	''' <param name="idPrestazioni">Elenco di idPrestazione concatenati da ";"</param>
	''' <returns></returns>
	''' <remarks></remarks>
	<WebMethod()>
	Public Shared Function InsertPrestazioniInGruppo(idGruppo As String, idPrestazioni As String) As String
		Try
			Dim idPrestazioniGuid = From idPrestazione In idPrestazioni.Split(";"c)
			 Select New Guid(idPrestazione)

			DataAdapterManager.InsertPrestazioniInGroup(New Guid(idGruppo), idPrestazioniGuid.ToArray())

			Return "ok"
		Catch ex As Exception

			ExceptionsManager.TraceException(ex)

			Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)

			portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)

			Throw
		End Try
	End Function

	<WebMethod()>
	Public Shared Function GetPrestazioni(idGruppo As String, descrizioneFiltroPrestazioneGruppo As String, idSistemiErogantiFiltroPrestazioneGruppo As String) As Dictionary(Of String, Object)
		Try
			'System.Threading.Thread.Sleep(5000)

			If Not String.IsNullOrEmpty(descrizioneFiltroPrestazioneGruppo) Then
				descrizioneFiltroPrestazioneGruppo = HttpUtility.UrlDecode(descrizioneFiltroPrestazioneGruppo)
			End If

			Dim idSE As Guid? = Nothing

			If Not String.IsNullOrEmpty(idSistemiErogantiFiltroPrestazioneGruppo) Then
				idSE = New Guid(idSistemiErogantiFiltroPrestazioneGruppo)
			End If

			Dim prestazioniDataTable = New UiPrestazioniListDataTable()
			Dim list = New Dictionary(Of String, Object)()

			DataAdapterManager.Fill(prestazioniDataTable, New Guid(idGruppo), descrizioneFiltroPrestazioneGruppo, idSE)

			For Each row As UiPrestazioniListRow In prestazioniDataTable

				Dim Prestazione = New With {.Id = row.ID, .Codice = row.Codice, .Descrizione = row.Descrizione, .SistemaErogante = row.SistemaErogante}

				list.Add(row.ID.ToString(), Prestazione)
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
	Public Shared Function GetListaPrestazioni(descrizione As String, idSistemaErogante As String) As Object()


		Try
			If Not String.IsNullOrEmpty(descrizione) Then
				descrizione = HttpUtility.UrlDecode(descrizione)
			End If

			Dim idSE As Guid? = Nothing

			If Not String.IsNullOrEmpty(idSistemaErogante) Then
				idSE = New Guid(idSistemaErogante)
			End If

			Dim prestazioneTable = New UiPrestazioniSelectDataTable()

			DataAdapterManager.Fill(prestazioneTable, Nothing, descrizione, idSE, Nothing)

			If prestazioneTable.Count = 0 Then
				Return Nothing
			Else
				Dim result = From row In prestazioneTable
				 Select New With {.Id = row.ID, .Codice = row.Codice, .Descrizione = row.Descrizione, .SistemaErogante = row.SistemaErogante}

				Return result.ToArray()
			End If
		Catch ex As Exception

			ExceptionsManager.TraceException(ex)

			Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)

			portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)

			Throw
		End Try
	End Function
End Class