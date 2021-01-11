Imports System.Data.SqlClient

Imports Msg = OE.Core.Schemas.Msg

#If CONFIG = "Release 1.2" Or CONFIG = "Debug 1.2" Then
'Versione 1.2
Imports Wcf = OE.Core.Schemas.Wcf12
#Else
'Versione 1.0 e 1.1
Imports Wcf = OE.Core.Schemas.Wcf
#End If

Public Class DizionarioAdapter
    Inherits DizionariDSTableAdapters.CommandsAdapter
    Implements IAdapter

#Region " IAdapter "

    Private _bCanDisposeConnection As Boolean = False
    Private _connection As SqlConnection = Nothing
    Private _transaction As SqlTransaction = Nothing

    Public ReadOnly Property Connection As System.Data.SqlClient.SqlConnection Implements IAdapter.Connection
        Get
            Return _connection
        End Get
    End Property

    Public ReadOnly Property Transaction As System.Data.SqlClient.SqlTransaction Implements IAdapter.Transaction
        Get
            Return _transaction
        End Get
    End Property

    Private Sub SetCommandsConnection()

        DiagnosticsHelper.WriteDiagnostics("DizionarioAdapter.SetCommandsConnection()")

        For Each commands As IDbCommand In MyBase.CommandCollection

            If _connection IsNot Nothing AndAlso _connection.State = ConnectionState.Closed Then
                _connection.Open()
            End If

            ' Imposto tutti i commands sulla stessa connessione
            commands.Connection = _connection
        Next
    End Sub

    Public Sub BeginTransaction(ByVal isolationLevel As IsolationLevel) Implements IAdapter.BeginTransaction

        DiagnosticsHelper.WriteDiagnostics("DizionarioAdapter.BeginTransaction()")

        If _connection.State = ConnectionState.Closed Then

            Throw New Exception("Errore durante DizionarioAdapter.BeginTransaction(). La connessione al database è chiusa!")
        End If

        For Each commands As IDbCommand In MyBase.CommandCollection

            If _transaction Is Nothing Then
                _transaction = _connection.BeginTransaction(isolationLevel)
            End If

            ' Imposto tutti i commands sulla stessa transazione
            commands.Transaction = _transaction
        Next
    End Sub

    Public Sub Commit() Implements IAdapter.Commit

        DiagnosticsHelper.WriteDiagnostics("DizionarioAdapter.Commit()")

        If _transaction IsNot Nothing Then
            Try
                _transaction.Commit()
            Finally
                _transaction.Dispose()
            End Try

            _transaction = Nothing
        End If
    End Sub

    Public Sub Rollback() Implements IAdapter.Rollback

        DiagnosticsHelper.WriteDiagnostics("DizionarioAdapter.Rollback()")

        If _transaction IsNot Nothing Then
            Try
                _transaction.Rollback()
            Finally
                _transaction.Dispose()
            End Try

            _transaction = Nothing
        End If
    End Sub

    Private Sub ___Disposed(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Disposed

        DiagnosticsHelper.WriteDiagnostics("DizionarioAdapter.Disposed()")

        If _connection IsNot Nothing AndAlso _bCanDisposeConnection Then
            Try
                If _connection.State = ConnectionState.Open Then
                    _connection.Close()
                End If
            Finally
                _connection.Dispose()
            End Try

            _connection = Nothing
        End If

    End Sub

#End Region

#Region " Constructors "

    Public Sub New(ByVal connectionString As String)
        MyBase.New()

        DiagnosticsHelper.WriteDiagnostics("DizionarioAdapter.New()")

        If _connection Is Nothing Then
            _bCanDisposeConnection = True
            _connection = New SqlClient.SqlConnection(connectionString)
        End If

        ' Imposto tutti i commands sulla stessa connessione
        SetCommandsConnection()
    End Sub

    Public Sub New(ByVal connection As SqlConnection, ByVal transaction As SqlTransaction, ByVal isolationLevel As IsolationLevel)
        MyBase.New()

        DiagnosticsHelper.WriteDiagnostics("DizionarioAdapter.New()")

        'Imposto connection e setto da non DISPOSE
        _bCanDisposeConnection = False
        _connection = connection

        ' Imposto tutti i commands sulla stessa connessione
        SetCommandsConnection()

        _transaction = transaction

        ' Inizio la transazione
        BeginTransaction(isolationLevel)
    End Sub

#End Region

    Public Function GetPriorita() As Wcf.WsTypes.DizionariType.PrioritaType

        DiagnosticsHelper.WriteDiagnostics("DizionarioAdapter.GetPriorita()")

        Dim result As Wcf.WsTypes.DizionariType.PrioritaType = Nothing

        Using ta As New DizionariDSTableAdapters.PrioritaTableAdapter()
            ta.Connection = Connection
            ta.Transaction = Transaction

            Dim dt As DizionariDS.PrioritaDataTable = ta.GetData()
            If dt.Rows.Count > 0 Then

                'Ritorna una lista se ce ne almeno 1
                result = New Wcf.WsTypes.DizionariType.PrioritaType()
                For Each row In dt

#If CONFIG = "Release 1.2" Or CONFIG = "Debug 1.2" Then
                    'Versione 1.2
                    result.Add(New Wcf.BaseTypes.PrioritaType() With {.Codice = row.Codice, .Descrizione = row.Descrizione})
#Else
                    'Versione 1.0 e 1.1

                    If [Enum].IsDefined(GetType(Wcf.BaseTypes.PrioritaEnum), row.Codice) Then
                        ' Converto in Enum
                        Dim Codice As Wcf.BaseTypes.PrioritaEnum
                        Codice = DirectCast([Enum].Parse(GetType(Wcf.BaseTypes.PrioritaEnum), row.Codice), Wcf.BaseTypes.PrioritaEnum)

                        result.Add(New Wcf.BaseTypes.PrioritaType() With {.Codice = Codice, .Descrizione = row.Descrizione})
                    End If
#End If
                Next
            End If
        End Using

        Return result
    End Function

    Public Function GetRegimi() As Wcf.WsTypes.DizionariType.RegimiType

        DiagnosticsHelper.WriteDiagnostics("DizionarioAdapter.GetRegimi()")

        Dim result As Wcf.WsTypes.DizionariType.RegimiType = Nothing

        Using ta As New DizionariDSTableAdapters.RegimiTableAdapter()
            ta.Connection = Connection
            ta.Transaction = Transaction

            Dim dt As DizionariDS.RegimiDataTable = ta.GetData()
            If dt.Rows.Count > 0 Then

                'Ritorna una lista se ce ne almeno 1
                result = New Wcf.WsTypes.DizionariType.RegimiType()
                For Each row In dt

#If CONFIG = "Release 1.2" Or CONFIG = "Debug 1.2" Then
                    'Versione 1.2
                    result.Add(New Wcf.BaseTypes.RegimeType() With {.Codice = row.Codice, .Descrizione = row.Descrizione})
#Else
                    'Versione 1.0 e 1.1
                    If [Enum].IsDefined(GetType(Wcf.BaseTypes.RegimeEnum), row.Codice) Then
                        ' Converto in Enum
                        Dim Codice As Wcf.BaseTypes.RegimeEnum
                        Codice = DirectCast([Enum].Parse(GetType(Wcf.BaseTypes.RegimeEnum), row.Codice), Wcf.BaseTypes.RegimeEnum)

                        result.Add(New Wcf.BaseTypes.RegimeType() With {.Codice = Codice, .Descrizione = row.Descrizione})
                    End If
#End If
                Next
            End If
        End Using

        Return result
    End Function

    Public Function GetDatiAccessoriDefault() As Wcf.WsTypes.DizionariType.DatiAccessoriDefaultType

        DiagnosticsHelper.WriteDiagnostics("DizionarioAdapter.GetDatiAccessoriDefault()")

        Dim result As Wcf.WsTypes.DizionariType.DatiAccessoriDefaultType = Nothing

        Using ta As New DizionariDSTableAdapters.DatiAccessoriDefaultTableAdapter
            ta.Connection = Connection
            ta.Transaction = Transaction

            Dim dt As DizionariDS.AccessoriDefaultDataTable = ta.GetData()
            If dt.Rows.Count > 0 Then

                'Ritorna una lista se ce ne almeno 1
                result = New Wcf.WsTypes.DizionariType.DatiAccessoriDefaultType()
                For Each row In dt
                    result.Add(New Wcf.BaseTypes.CodiceDescrizioneType With {.Codice = row.Codice,
                                                                    .Descrizione = row.Descrizione})

                Next
            End If
        End Using

        Return result
    End Function

End Class
