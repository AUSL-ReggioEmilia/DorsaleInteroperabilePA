Imports System
Imports System.Collections.Generic
Imports System.Threading
Imports System.Data
Imports System.Data.SqlClient
Imports System.IO
Imports System.Diagnostics
Imports System.Text
Imports System.Linq
Imports System.Data.Linq
Imports System.ComponentModel
Imports System.Web

Namespace DI.PortalUser2.Data

	''' <summary>
	''' Classe contenente i valori che indicano il tipo di entry nel registro delle modifiche
	''' </summary>
	Public NotInheritable Class LogEntryTypes

		Private Sub New()

		End Sub

		Public Shared ReadOnly Update As Char = "U"c
		Public Shared ReadOnly Insert As Char = "I"c
		Public Shared ReadOnly Delete As Char = "D"c
		Public Shared ReadOnly Validate As Char = "V"c

	End Class

	''' <summary>
	''' Classe contente i valori che indicano il nome del portale da indicare nel log degli accessi
	''' </summary>
	''' <remarks></remarks>
	Public NotInheritable Class PortalsNames

		Private Sub New()

		End Sub

		Public Shared ReadOnly Home As String = "Home"
		Public Shared ReadOnly DwhClinico As String = "DwhClinico"
		Public Shared ReadOnly OrderEntry As String = "OrderEntry"
		Public Shared ReadOnly Sac As String = "Sac"
		Public Shared ReadOnly PrintManager As String = "PrintManager"
		Public Shared ReadOnly PrintDispatcher As String = "PrintDispatcher"
		Public Shared ReadOnly WorkList As String = "WorkListOrdniSistemaErogante"
		Public Shared ReadOnly OrderEntryPlanner As String = "OrderEntryPlanner"
		Public Shared ReadOnly PortaleConsensi As String = "PortaleConsensi" 'non si vede nel PORTALE USER DI
		Public Shared ReadOnly UpToDate As String = "PortaleUpToDate" 'non si vede nel PORTALE USER DI
	End Class


	Public NotInheritable Class PortalsTitles
		Public Const Home As String = "DORSALE INTEROPERABILE"
		Public Const DwhClinico As String = "DATA WAREHOUSE CLINICO"
		Public Const OrderEntry As String = "ORDER ENTRY"
		Public Const Sac As String = "SISTEMA ANAGRAFICO CENTRALIZZATO"
		'Public Const PrintManager As String = "PrintManager"
		Public Const PrintDispatcher As String = "RISTAMPA ETICHETTE"
		Public Const WorkList As String = "WORKLIST ORDINI SISTEMA EROGANTE"
		Public Const OrderEntryPlanner As String = "ORDER ENTRY PLANNER"
		Public Const Titolare As String = "ARCISPEDALE S. MARIA NUOVA AZIENDA OSPEDALIERA DI REGGIO EMILIA V.le Risorgimento, 80 - 42100 Reggio Emilia - C.F. e P.IVA 01614660353"
		Public Const PortaleConsensi As String = "RACCOLTA DEI CONSENSI PRIVACY" 'non si vede nel PORTALE USER DI
		Public Const UpToDate As String = "UpToDate"
	End Class


	''' <summary>
	''' Classe che gestisce le azioni sul database
	''' </summary>
	''' <remarks></remarks>
	<DataObjectAttribute(True)>
	Public Class PortalDataAdapterManager

		Public Enum EnumPortalId
			Home = 1
			OrderEntry = 2
			Sac = 3
			Dwh = 4
			PrintDispatcher = 5
			Worklist = 6
			OrderEntryPlanner = 7
			UpToDate = 8
		End Enum



		Private _connectionString As String = String.Empty

		'''' <summary>
		'''' Istanzia un nuovo oggetto di tipo <see cref="DI.PortalUser.Data.PortalDataAdapterManager"></see>
		'''' </summary>
		'''' <param name="connectionString">La stringa di connessione</param>
		'''' <exception cref="System.ArgumentNullException">se la stringa di connessione è vuota o nulla</exception>
		'''' <remarks></remarks>
		Public Sub New(connectionString As String)

			If String.IsNullOrEmpty(connectionString) Then
				Throw New ArgumentNullException("Il parametro connectionString non può essere vuoto", "connectionString")
			End If

			_connectionString = connectionString

		End Sub

		'''' <summary>
		'''' Restituisce una lista dei report filtrata per categoria
		'''' </summary>
		'''' <param name="portalName">Il nome del portale, scelto fra i valori della classe <see cref="DI.PortalUser2.Reports.ReportingPortalsNames"></see></param>
		'''' <exception cref="System.ArgumentException">se il parametro 'portalName' è vuoto o nullo</exception>
		'''' <returns>La lista di oggetti <see cref="DI.PortalUser2.Data.ListaReportResult"></see></returns>
		'''' <remarks></remarks>
		Public Function GetReportsList(portalName As String) As List(Of ListaReportResult)

			If String.IsNullOrEmpty(portalName) Then
				Throw New ArgumentNullException("portalName", "Il parametro 'portalName' non può essere vuoto o nullo")
			End If

			Using context As New PortaleDataContext(_connectionString)

				Return context.ListaReport(portalName).ToList()
			End Using
		End Function

		''' <summary>
		''' Restituisce la lista di voci del menu del portale
		''' </summary>
		''' <returns></returns>
		''' <remarks></remarks>
		Public Function GetMainMenu() As Dictionary(Of String, String)

			Using ta As New ConfigurazioniDataSetTableAdapters.ConfigurazioneMenuListaTableAdapter(_connectionString)
				Dim dt As ConfigurazioniDataSet.ConfigurazioneMenuListaDataTable = ta.GetData()


				Dim dictionary = New Dictionary(Of String, String)()

				For Each row In dt.Rows
					If Thread.CurrentPrincipal.IsInRole(row.RuoloLettura) Then

						If Not row.IsUrlTestNull AndAlso Not row.IsRuoloTestNull Then
							If HttpContext.Current.User.IsInRole(row.RuoloTest) Then
								dictionary.Add(row.Titolo, row.UrlTest)
							End If
						Else
							dictionary.Add(row.Titolo, row.Url)
						End If
					End If
				Next

				Return dictionary
			End Using
		End Function

		''' <summary>
		''' Restituisce la lista di voci del menu del portale
		''' </summary>
		''' <returns></returns>
		''' <remarks></remarks>
		Public Function GetMainMenu(IdPortale As Integer) As List(Of PortalUserMenuItem)
			Dim listaMenuItem As New List(Of PortalUserMenuItem)

			Using ta As New ConfigurazioniDataSetTableAdapters.ConfigurazioneMenuListaTableAdapter(_connectionString)
				Dim dt As ConfigurazioniDataSet.ConfigurazioneMenuListaDataTable = ta.GetData()

				For Each row In dt.Rows
					If Thread.CurrentPrincipal.IsInRole(row.RuoloLettura) Then
						Dim portalUserMenuItem As New PortalUserMenuItem
						portalUserMenuItem.Descrizione = row.Titolo
						portalUserMenuItem.Id = row.Id
						portalUserMenuItem.Url = row.Url

						If Not portalUserMenuItem.Url.IndexOf("[NetbiosDomain]") = -1 Then

							Dim resultUrl As String = String.Empty
							Dim NetbiosDomain As String = String.Empty
							Dim UserName As String = String.Empty

							NetbiosDomain = HttpContext.Current.User.Identity.Name.Split("\\")(0)
							UserName = HttpContext.Current.User.Identity.Name.Split("\\")(1)

							resultUrl = portalUserMenuItem.Url.Replace("[NetbiosDomain]", NetbiosDomain)
							resultUrl = resultUrl.Replace("[UserName]", UserName)

							portalUserMenuItem.Url = resultUrl
						End If

						If Not row.IsUrlTestNull AndAlso Not row.IsRuoloTestNull Then
							If HttpContext.Current.User.IsInRole(row.RuoloTest) Then
								portalUserMenuItem.Url = row.UrlTest
							End If
						End If

						portalUserMenuItem.IsSelected = row.Id = IdPortale
						listaMenuItem.Add(portalUserMenuItem)
					End If
				Next

				Return listaMenuItem
			End Using
		End Function


		''' <summary>
		''' Restituisce le informazioni relative all'ultima volta che l'utente si è collegato al portale
		''' </summary>
		''' <param name="nomeUtente">Il nome dell'utente</param>
		''' <param name="nomePortale">Il nome del portale, scelto fra i valori della classe <see cref="DI.PortalUser2.Reports.ReportingPortalsNames"></see></param>
		''' <param name="getLastRole">Specifica se recuperare l'ultimo utente loggato nella precedente sessione (true) o l'ultimo ruolo selezionato prima di quello corrente</param>
		''' <exception cref="System.ArgumentException">se uno dei parametri 'nomePortale' e 'nomeUtente' è vuoto o nullo</exception>
		''' <returns></returns>
		''' <remarks></remarks>
		Public Function GetUltimoAccesso(nomeUtente As String, nomePortale As String, getLastRole As Boolean) As UltimoAccesso

			If String.IsNullOrEmpty(nomeUtente) Then
				Throw New ArgumentNullException("nomeUtente", "Il parametro 'nomeUtente' non può essere vuoto o nullo")
			End If

			If String.IsNullOrEmpty(nomePortale) Then
				Throw New ArgumentNullException("nomePortale", "Il parametro 'nomePortale' non può essere vuoto o nullo")
			End If

			Using context As New PortaleDataContext(_connectionString)

				Dim result = context.UltimoAccesso(nomeUtente, nomePortale).ToList()

				If result.Count < 2 Then
					Return Nothing
				Else
					If getLastRole Then
						Return New UltimoAccesso(result(0).DataAccesso, result(0).Ruolo)
					Else
						Return New UltimoAccesso(result(1).DataAccesso, result(1).Ruolo)
					End If
				End If
			End Using
		End Function

		Public Class UltimoAccesso

			Private _dataUltimoAccesso As DateTime
			Private _ruolo As String

			Friend Sub New(dataUltimoAccesso As DateTime, ruolo As String)

				_dataUltimoAccesso = dataUltimoAccesso
				_ruolo = ruolo
			End Sub

			Public ReadOnly Property DataUltimoAccesso As DateTime
				Get
					Return _dataUltimoAccesso
				End Get
			End Property

			Public ReadOnly Property Ruolo As String
				Get
					Return _ruolo
				End Get
			End Property
		End Class

		'''' <summary>
		'''' Registra gli accessi ai portali e tutte le letture su db o webservice che sono significative
		'''' </summary>
		'''' <param name="nomeUtente">Il nome dell'utente corrente</param>
		'''' <param name="nomePortale">Il nome del portale, compreso fra i valori dell'oggetto <see cref="DI.PortalUser.Data.PortalsNames">PortalsNames</see></param>
		'''' <param name="descrizione">Il testo contenente le note d'accesso</param>
		'''' <remarks></remarks>
		Public Sub TracciaAccessi(nomeUtente As String, nomePortale As String, descrizione As String)

			TracciaAccessi(nomeUtente, nomePortale, descrizione, Nothing)
		End Sub

		'''' <summary>
		'''' Registra gli accessi ai portali e tutte le letture su db o webservice che sono significative
		'''' </summary>
		'''' <param name="nomeUtente">Il nome dell'utente corrente</param>
		'''' <param name="nomePortale">Il nome del portale, compreso fra i valori dell'oggetto <see cref="DI.PortalUser.Data.PortalsNames">PortalsNames</see></param>
		'''' <param name="descrizione">Il testo contenente le note d'accesso</param>
		'''' <param name="ruolo">L'eventuale ruolo associato all'accesso</param>
		'''' <remarks></remarks>
		Public Sub TracciaAccessi(nomeUtente As String, nomePortale As String, descrizione As String, ruolo As String)

			Using adapter As New SqlDataAdapter("TracciaAccessi", _connectionString)

				adapter.SelectCommand.CommandType = CommandType.StoredProcedure
				adapter.SelectCommand.Parameters.Add("@NomeUtente", SqlDbType.VarChar, 200).Value = nomeUtente
				adapter.SelectCommand.Parameters.Add("@NomePortale", SqlDbType.VarChar, 2147483647).Value = nomePortale
				adapter.SelectCommand.Parameters.Add("@Descrizione", SqlDbType.VarChar, 8000).Value = descrizione
				adapter.SelectCommand.Parameters.Add("@Ruolo", SqlDbType.VarChar, 200).Value = ruolo
				adapter.SelectCommand.Parameters.Add("@DataAccesso", SqlDbType.DateTime2).Value = DateTime.Now

				Try
					adapter.SelectCommand.Connection.Open()

					adapter.SelectCommand.ExecuteNonQuery()
				Finally
					adapter.SelectCommand.Connection.Close()
				End Try
			End Using
		End Sub

		''' <summary>
		''' Registra le modifiche effettuate su un insieme di dati
		''' </summary>
		''' <param name="dataTable">L'oggetto <see cref="System.Data.DataTable">DataTable</see> che contiene i dati da registrare</param>
		''' <remarks>Questo metodo deve essere chiamato prima di un eventuale AcceptChanges (eseguito automaticamente in seguito ad un update) 
		''' e RejectChanges, in quanto questi due metodi eliminano la versione precedente o successiva alla modifica.
		''' Attenzione: se la tabella contiene più righe, ogni singola riga viene importata in una tabella temporanea e passata ricorsivamente
		''' alla stessa funzione</remarks>
		Public Sub TracciaModifiche(ByVal dataTable As DataTable, ByVal nomeUtente As String)
			Try
				Dim changesDataTable = dataTable.GetChanges()

				If changesDataTable Is Nothing OrElse changesDataTable.Rows.Count = 0 Then
					Return
				End If

				If changesDataTable.Rows.Count > 1 Then

					For Each row As DataRow In changesDataTable.Rows

						Dim tempDataTable As DataTable = dataTable.Clone()

						tempDataTable.ImportRow(row)

						TracciaModifiche(tempDataTable, nomeUtente)
					Next

					Return
				End If

				Dim currentRow As DataRow = changesDataTable.Rows(0)

				Dim newValue As Object = DBNull.Value
				Dim oldValue As Object = DBNull.Value

				Dim entryType As Char
				Dim tableId As String = String.Empty

				Select Case currentRow.RowState

					Case DataRowState.Modified

						tableId = currentRow("Id").ToString()

						entryType = LogEntryTypes.Update

						oldValue = GetXml(changesDataTable, True)
						newValue = GetXml(changesDataTable, False)

					Case DataRowState.Deleted

						tableId = currentRow("Id", DataRowVersion.Original).ToString()

						entryType = LogEntryTypes.Delete

						oldValue = GetXml(changesDataTable, True)

					Case DataRowState.Added

						tableId = currentRow("Id").ToString()

						entryType = LogEntryTypes.Insert

						newValue = GetXml(changesDataTable, False)
				End Select

				Using adapter As New SqlDataAdapter("TracciaModifiche", _connectionString)

					adapter.SelectCommand.CommandType = CommandType.StoredProcedure
					adapter.SelectCommand.Parameters.Add("@Id", SqlDbType.UniqueIdentifier).Value = Guid.NewGuid()
					adapter.SelectCommand.Parameters.Add("@UtenteNome", SqlDbType.VarChar, 100).Value = nomeUtente
					adapter.SelectCommand.Parameters.Add("@DataModifica", SqlDbType.DateTime2).Value = DateTime.Now
					adapter.SelectCommand.Parameters.Add("@TipoOperazione", SqlDbType.Char, 1).Value = entryType
					adapter.SelectCommand.Parameters.Add("@NomeTabella", SqlDbType.VarChar, 100).Value = dataTable.TableName
					adapter.SelectCommand.Parameters.Add("@IdTabella", SqlDbType.VarChar, 200).Value = tableId
					adapter.SelectCommand.Parameters.Add("@VecchioValore", SqlDbType.Xml, 2147483647).Value = oldValue
					adapter.SelectCommand.Parameters.Add("@NuovoValore", SqlDbType.Xml, 2147483647).Value = newValue

					Try
						adapter.SelectCommand.Connection.Open()

						adapter.SelectCommand.ExecuteNonQuery()
					Finally
						adapter.SelectCommand.Connection.Close()
					End Try
				End Using
			Catch ex As Exception
				TracciaErrori(ex, nomeUtente, PortalsNames.Home)
			End Try
		End Sub

		''' <summary>
		''' Traccia un'eccezione sul db segnalandolo come Errore
		''' </summary> 
		''' <param name="exception">L'eccezione da tracciare</param>
		''' <param name="nomeUtente">Il nome dell'utente corrente</param>
		''' <remarks></remarks>
		Public Sub TracciaErrori(ByVal exception As Exception, nomeUtente As String, portalName As String)
			TracciaErrori(exception, nomeUtente, TraceEventType.Error, portalName)
		End Sub

		''' <summary>
		''' Traccia un'eccezione sul db
		''' </summary>
		''' <param name="exception">L'eccezione da tracciare</param>
		''' <param name="nomeUtente">Il nome dell'utente corrente</param>
		''' <param name="errorType">La gravità dell'errore</param>
		''' <remarks></remarks>
		Public Sub TracciaErrori(ByVal exception As Exception, nomeUtente As String, ByVal errorType As TraceEventType, portalName As String)

			Dim errorText As String = FormatException(exception)

			TracciaErrori(errorText, nomeUtente, errorType, portalName)
		End Sub

		''' <summary>
		''' Traccia un messaggio d'errore sul db
		''' </summary>
		''' <param name="message">Il messaggio d'errore da tracciare</param>
		''' <param name="nomeUtente">Il nome dell'utente corrente</param>
		''' <param name="errorType">La gravità dell'errore</param>
		''' <remarks></remarks>
		Public Sub TracciaErrori(ByVal message As String, nomeUtente As String, ByVal errorType As TraceEventType, portalName As String)

			Using adapter As New SqlDataAdapter("TracciaErrori", _connectionString)

				adapter.SelectCommand.CommandType = CommandType.StoredProcedure
				adapter.SelectCommand.Parameters.Add("@Errore", SqlDbType.VarChar, 2147483647).Value = message
				adapter.SelectCommand.Parameters.Add("@Tipo", SqlDbType.VarChar, 50).Value = [Enum].GetName(GetType(TraceEventType), errorType)
				adapter.SelectCommand.Parameters.Add("@NomeMacchina", SqlDbType.VarChar, 100).Value = My.Computer.Name
				adapter.SelectCommand.Parameters.Add("@Utente", SqlDbType.VarChar, 100).Value = nomeUtente
				adapter.SelectCommand.Parameters.Add("@NomePortale", SqlDbType.VarChar, 100).Value = portalName
				adapter.SelectCommand.Parameters.Add("@DataInserimento", SqlDbType.DateTime2).Value = DateTime.Now

				Try
					adapter.SelectCommand.Connection.Open()

					adapter.SelectCommand.ExecuteNonQuery()
				Finally
					adapter.SelectCommand.Connection.Close()
				End Try
			End Using
		End Sub

		''' <summary>
		''' Formatta il contenuto di un'eccezione in un oggetto <see cref="String">String</see>
		''' </summary>
		''' <param name="exception">L'eccezione il cui contenuto formattare</param>
		''' <returns>Un oggetto String contenente il testo dell'eccezione</returns>
		''' <remarks>L'eccezione viene formattata nella seguente modalità:
		''' - Tipo
		''' - Messaggio
		''' - StackTrace
		'''        
		''' per tutte le InnerException, a partire dalla più esterna
		'''</remarks>
		Public Shared Function FormatException(ByVal exception As Exception) As String

			If exception Is Nothing Then
				Throw New ArgumentNullException("exception")
			End If

			Dim result As New StringBuilder()
			Dim currentException As Exception = exception

			While currentException IsNot Nothing

				result.AppendLine(currentException.GetType().ToString())
				result.AppendLine(currentException.Message)
				result.AppendLine(currentException.StackTrace)

				currentException = currentException.InnerException
			End While

			Return result.ToString()
		End Function

		''' <summary>
		''' Restituisce una stringa contenente l'xml relativo al dato corrente o originale
		''' </summary>
		''' <param name="table">l'oggetto DataTable da convertire in Xml</param>
		''' <param name="getOriginal">determina se convertire le righe correnti o originali</param>
		''' <returns>una stringa contenente l'xml relativo al dato corrente o originale</returns>
		''' <remarks></remarks>
		Private Shared Function GetXml(ByVal table As DataTable, ByVal getOriginal As Boolean) As String

			Dim tableToWrite As DataTable

			If getOriginal Then

				Using dataView As New DataView(table, String.Empty, String.Empty, DataViewRowState.ModifiedOriginal Or
								   DataViewRowState.OriginalRows)
					tableToWrite = dataView.ToTable()
				End Using
			Else
				tableToWrite = table
			End If

			Using stream As New StringWriter()

				tableToWrite.WriteXml(stream)

				Return stream.ToString()
			End Using
		End Function

		'''' <summary>
		'''' Restituisce la lista delle modifiche effettuate sulle tabelle monitorate
		'''' </summary>
		'''' <param name="portalName">Il nomer del portale, scelto fra i valori della classe <see cref="DI.PortalUser.Data.PortalsNames"></see></param>
		'''' <exception cref="System.ArgumentException">se il parametro 'portalName' è vuoto o nullo</exception>
		'''' <param name="tableName">Il nome della tabella</param>
		'''' <returns>La lista di oggetti <see cref="DI.PortalUser.Data.ArchivioModificheListaResult"></see></returns>
		'''' <remarks></remarks>
		<DataObjectMethod(DataObjectMethodType.Select)>
		Public Function GetArchivioModifiche(portalName As String, tableName As String) As List(Of ArchivioModificheListaResult)

			If String.IsNullOrEmpty(portalName) Then
				Throw New ArgumentNullException("portalName", "Il parametro 'portalName' non può essere vuoto o nullo")
			End If

			Using context As New PortaleDataContext(_connectionString)

				Return context.ArchivioModificheLista(portalName, tableName).ToList()
			End Using
		End Function

		''' <summary>
		''' Restituisce la lista dei campi modificifati per una data tabella/id
		''' </summary>     
		''' <param name="id">id della riga </param>
		''' <returns>Un oggetto <see cref="System.Data.DataTable"></see> contenente la righa richiesta</returns>
		''' <remarks></remarks>
		Public Function GetDettaglioArchivioModifiche(id As Integer) As ArchivioModificheDettaglioResult

			Using context As New PortaleDataContext(_connectionString)

				Return context.ArchivioModificheDettaglio(id).ToArray()(0)
			End Using
		End Function


#Region "Tabella DatiUtente"

		''' <summary>
		''' DatiUtente : Ottiene il Valore associato alla chiave passata
		''' </summary>
		Public Function DatiUtenteOttieniValore(Utente As String, Chiave As String, [Default] As String, Optional UseCache As Boolean = True) As String

			Dim oRet = DatiUtenteOttieniObject(Utente, Chiave, UseCache)

			If oRet Is Nothing Then
				Return [Default]
			Else
				If [Default].GetType() IsNot oRet.GetType() Then
					Throw New InvalidCastException(String.Format("DatiUtenteOttieniValore({0}, {1}) - Il dato letto da database è di tipo {2}, era atteso {3}.", Utente, Chiave, oRet.GetType.ToString, [Default].GetType.ToString))
				End If

				Return oRet
			End If

		End Function



		''' <summary>
		''' DatiUtente : Ottiene il Valore associato alla chiave passata
		''' </summary>
		Public Function DatiUtenteOttieniValore(Utente As String, Chiave As String, [Default] As DateTime?, Optional UseCache As Boolean = True) As DateTime?

			Dim oRet = DatiUtenteOttieniObject(Utente, Chiave, UseCache)

			If oRet Is Nothing Then
				Return [Default]
			Else
				If [Default].GetType() IsNot oRet.GetType() Then
					Throw New InvalidCastException(String.Format("DatiUtenteOttieniValore({0}, {1}) - Il dato letto da database è di tipo {2}, era atteso {3}.", Utente, Chiave, oRet.GetType.ToString, [Default].GetType.ToString))
				End If

				Return oRet
			End If

		End Function


		''' <summary>
		''' Legge da Cache o da DB, ritorna un object, oppure Nothing se non lo trova
		''' </summary>
		Private Function DatiUtenteOttieniObject(Utente As String, Chiave As String, UseCache As Boolean) As Object
			Dim oRetValue As Object = Nothing

			If UseCache Then
				oRetValue = CacheRead(Utente, Chiave)
			End If

			If oRetValue Is Nothing Then
				Using context As New PortaleDataContext(_connectionString)
					Dim oResults = context.DatiUtenteOttieniValore(Utente, Chiave).ToList
					If oResults.Count = 0 Then
						oRetValue = Nothing
					Else
						oRetValue = oResults(0).Valore
						If UseCache Then 'LO SALVO IN CACHE
							CacheWrite(Utente, Chiave, oRetValue)
						End If
					End If
				End Using
			End If

			Return oRetValue
		End Function

		''' <summary>
		''' Legge dalla cache, ritorna nothing se non trova nulla
		''' </summary>
		Private Function CacheRead(Utente As String, Chiave As String) As Object
			Dim Key As String = Utente & "§" & Chiave

			'TODO Implementare lettura dalla Cache

			Return Nothing
		End Function


		''' <summary>
		'''Scrive nella cache
		''' </summary>
		Private Sub CacheWrite(Utente As String, Chiave As String, Valore As Object)
			Dim Key As String = Utente & "§" & Chiave

			'TODO Implementare scrittura Cache

		End Sub

		''' <summary>
		''' DatiUtente: Salva in Cache e su DB il Valore associato alla chiave passata
		''' </summary>
		Public Sub DatiUtenteSalvaValore(Utente As String, Chiave As String, Valore As String)

			CacheWrite(Utente, Chiave, Valore)

			Using context As New PortaleDataContext(_connectionString)
				context.DatiUtenteSalvaValore(Utente, Chiave, Valore)
			End Using

		End Sub

		''' <summary>
		''' DatiUtente: Salva in Cache e su DB il Valore associato alla chiave passata
		''' </summary>
		Public Sub DatiUtenteSalvaValore(Utente As String, Chiave As String, Valore As DateTime?)

			CacheWrite(Utente, Chiave, Valore)

			Using context As New PortaleDataContext(_connectionString)
				context.DatiUtenteSalvaValore(Utente, Chiave, Valore)
			End Using

		End Sub
#End Region


	End Class


	Public Class PortalUserMenuItem
		Public Property Id As Integer

		Public Property Url As String

		Public Property Descrizione As String

		Public Property IsSelected As Boolean
	End Class


End Namespace