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

Namespace DI.PortalAdmin.Data

    ''' <summary>
    ''' Classe contente i valori che indicano il tipo di entry nel registro delle modifiche
    ''' </summary>
    ''' <remarks></remarks>
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
        Public Shared ReadOnly Connettori As String = "Connettori"
    End Class

    Public NotInheritable Class PortalsTitles
        Public Const Home As String = "DORSALE INTEROPERABILE"
        Public Const DwhClinico As String = "DATA WAREHOUSE CLINICO"
        Public Const OrderEntry As String = "ORDER ENTRY"
        Public Const Sac As String = "SISTEMA ANAGRAFICO CENTRALIZZATO"
        Public Const PrintManager As String = "PRINT MANAGER"
        Public Const PrintDispatcher As String = "PRINT DISPATCHER"
        Public Const Connettori As String = "CONNETTORI"
        Public Const WorkList As String = "WORKLIST ORDINI SISTEMA EROGANTE" 'non si vede nel PORTALE ADMIN DI
        Public Const OrderEntryPlanner As String = "ORDER ENTRY PLANNER" 'non si vede nel PORTALE ADMIN DI
        Public Const Titolare As String = "ARCISPEDALE S. MARIA NUOVA AZIENDA OSPEDALIERA DI REGGIO EMILIA V.le Risorgimento, 80 - 42100 Reggio Emilia - C.F. e P.IVA 01614660353"
        Public Const PortaleConsensi As String = "RACCOLTA DEI CONSENSI PRIVACY" 'non si vede nel PORTALE USER DI
        Public Const UpToDate As String = "UpToDate" 'non si vede nel PORTALE ADMIN DI
    End Class

    ''' <summary>
    ''' Classe che gestisce le azioni sul database
    ''' </summary>
    ''' <remarks></remarks>
    <DataObjectAttribute(True)>
    Public NotInheritable Class PortalDataAdapterManager

        Private _connectionString As String = String.Empty

        ''' <summary>
        ''' Istanzia un nuovo oggetto di tipo <see cref="DI.PortalAdmin.Data.PortalDataAdapterManager"></see>
        ''' </summary>
        ''' <param name="connectionString">La stringa di connessione</param>
        ''' <exception cref="System.ArgumentNullException">se la stringa di connessione è vuota o nulla</exception>
        ''' <remarks></remarks>
        Public Sub New(connectionString As String)

            If String.IsNullOrEmpty(connectionString) Then
                Throw New ArgumentNullException("Il parametro connectionString non può essere vuoto", "connectionString")
            End If

            _connectionString = connectionString
        End Sub

        ''' <summary>
        ''' Restituisce una lista dei report filtrata per categoria
        ''' </summary>
        ''' <param name="portalName">Il nomer del portale, scelto fra i valori della classe <see cref="DI.PortalAdmin.Reports.ReportingPortalsNames"></see></param>
        ''' <exception cref="System.ArgumentException">se il parametro 'portalName' è vuoto o nullo</exception>
        ''' <returns>La lista di oggetti <see cref="ConfigurazioniDataSet.ListaReportRow"></see></returns>
        ''' <remarks></remarks>
        Public Function GetReportsList(portalName As String) As List(Of ConfigurazioniDataSet.ListaReportRow)

            If String.IsNullOrEmpty(portalName) Then
                Throw New ArgumentNullException("portalName", "Il parametro 'portalName' non può essere vuoto o nullo")
            End If

            Dim result As List(Of ConfigurazioniDataSet.ListaReportRow) = Nothing

            Using ta As New ConfigurazioniDataSetTableAdapters.ListaReportTableAdapter(_connectionString)
                Dim dt As ConfigurazioniDataSet.ListaReportDataTable = ta.GetData(portalName)

                result = dt.ToList()
            End Using

            Return result
        End Function

        ''' <summary>
        ''' Restituisce la lista di voci del menu del portale
        ''' </summary>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public Function GetMainMenu() As Dictionary(Of String, String)

            Using ta As New ConfigurazioniDataSetTableAdapters.ConfigurazioneMenuLista1TableAdapter(_connectionString)
                Dim dt As ConfigurazioniDataSet.ConfigurazioneMenuLista1DataTable = ta.GetData()

                Dim dictionary = New Dictionary(Of String, String)()
                Dim items = dt.ToList()

                For Each row In items

                    If Thread.CurrentPrincipal.IsInRole(row.RuoloLettura) Then

                        dictionary.Add(row.Titolo, row.Url)
                    End If
                Next

                Return dictionary
            End Using
        End Function

        ''' <summary>
        ''' Registra gli accessi ai portali e tutte le letture su db o webservice che sono significative
        ''' </summary>
        ''' <param name="nomeUtente">Il nome dell'utente corrente</param>
        ''' <param name="nomePortale">Il nome del portale, compreso fra i valori dell'oggetto <see cref="DI.PortalAdmin.Data.PortalsNames">PortalsNames</see></param>
        ''' <param name="descrizione">Il testo contenente</param>
        ''' <remarks></remarks>
        Public Sub TracciaAccessi(nomeUtente As String, nomePortale As String, descrizione As String)

            Using adapter As New SqlDataAdapter("TracciaAccessi", _connectionString)

                adapter.SelectCommand.CommandType = CommandType.StoredProcedure
                adapter.SelectCommand.Parameters.Add("@NomeUtente", SqlDbType.VarChar, 200).Value = nomeUtente
                adapter.SelectCommand.Parameters.Add("@NomePortale", SqlDbType.VarChar, 200).Value = nomePortale
                adapter.SelectCommand.Parameters.Add("@Descrizione", SqlDbType.VarChar, 2147483647).Value = descrizione
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

            Using adapter As New SqlDataAdapter("TracciaErrori1", _connectionString)

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
    End Class

End Namespace