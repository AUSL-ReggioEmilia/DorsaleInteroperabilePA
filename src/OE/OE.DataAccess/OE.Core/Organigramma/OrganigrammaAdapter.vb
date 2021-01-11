Imports System.Data.SqlClient
Imports OE.Core

Imports Msg = OE.Core.Schemas.Msg

#If CONFIG = "Release 1.2" Or CONFIG = "Debug 1.2" Then
'Versione 1.2
Imports Wcf = OE.Core.Schemas.Wcf12
#Else
'Versione 1.0 e 1.1
Imports Wcf = OE.Core.Schemas.Wcf
#End If

Public Class OrganigrammaAdapter
    Inherits OrganigrammaDSTableAdapters.CommandsAdapter
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

        DiagnosticsHelper.WriteDiagnostics("OrganigrammaAdapter.SetCommandsConnection()")

        For Each commands As IDbCommand In MyBase.CommandCollection

            If _connection IsNot Nothing AndAlso _connection.State = ConnectionState.Closed Then
                _connection.Open()
            End If

            ' Imposto tutti i commands sulla stessa connessione
            commands.Connection = _connection
        Next
    End Sub

    Public Sub BeginTransaction(ByVal isolationLevel As IsolationLevel) Implements IAdapter.BeginTransaction

        DiagnosticsHelper.WriteDiagnostics("OrganigrammaAdapter.BeginTransaction()")

        If _connection.State = ConnectionState.Closed Then

            Throw New Exception("Errore durante OrganigrammaAdapter.BeginTransaction(). La connessione al database è chiusa!")
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

        DiagnosticsHelper.WriteDiagnostics("OrganigrammaAdapter.Commit()")

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

        DiagnosticsHelper.WriteDiagnostics("OrganigrammaAdapter.Rollback()")

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

        DiagnosticsHelper.WriteDiagnostics("OrganigrammaAdapter.Disposed()")

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

        DiagnosticsHelper.WriteDiagnostics("OrganigrammaAdapter.New()")

        If _connection Is Nothing Then
            _bCanDisposeConnection = True
            _connection = New SqlClient.SqlConnection(connectionString)
        End If

        ' Imposto tutti i commands sulla stessa connessione
        SetCommandsConnection()
    End Sub

    Public Sub New(ByVal connection As SqlConnection, ByVal transaction As SqlTransaction, ByVal isolationLevel As IsolationLevel)
        MyBase.New()

        DiagnosticsHelper.WriteDiagnostics("OrganigrammaAdapter.New()")

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

    Public Function GetAziende() As Wcf.WsTypes.DizionariType.AziendeType

        DiagnosticsHelper.WriteDiagnostics("OrganigrammaAdapter.GetAziende()")

        Dim list As Wcf.WsTypes.DizionariType.AziendeType = Nothing

        Using ta As New OrganigrammaDSTableAdapters.AziendeTableAdapter()
            ta.Connection = Connection
            ta.Transaction = Transaction

            Dim dt As OrganigrammaDS.AziendeDataTable = ta.GetData()
            If dt.Rows.Count > 0 Then

                list = New Wcf.WsTypes.DizionariType.AziendeType()

                For Each row In dt

                    list.Add(New Wcf.BaseTypes.CodiceDescrizioneType() With {.Codice = row.Codice,
                                                                             .Descrizione = If(row.IsDescrizioneNull(), Nothing, row.Descrizione)})
                Next
            End If
        End Using

        Return list
    End Function


    Private Function GetAziendaByCodice(ByVal codice As String) As OrganigrammaDS.AziendaRow

        DiagnosticsHelper.WriteDiagnostics("OrganigrammaAdapter.GetAziendaByCodice()")

        If String.IsNullOrEmpty(codice) Then
            Throw New OrderEntryArgumentNullException("codice")
        End If

        'Cerco nella cache
        Dim row As OrganigrammaDS.AziendaRow = Nothing
        row = My.CacheAziende.TryFindByCodice(codice)

        If row Is Nothing Then

            'Leggo dal DB
            Using ta As New OrganigrammaDSTableAdapters.AziendaTableAdapter()
                ta.Connection = Connection
                ta.Transaction = Transaction

                Dim dt As OrganigrammaDS.AziendaDataTable = ta.GetDataByCodice(codice)

                If dt.Rows.Count > 0 Then
                    ' Ritorno e aggiungo alla cache
                    row = dt.First
                    My.CacheAziende.TryAdd(row)
                End If
            End Using
        End If

        Return row

    End Function

    Public Function GetUnitaOperative() As Wcf.WsTypes.DizionariType.UnitaOperativeType

        DiagnosticsHelper.WriteDiagnostics("OrganigrammaAdapter.GetUnitaOperative()")

        Dim list As Wcf.WsTypes.DizionariType.UnitaOperativeType = Nothing

        Using ta As New OrganigrammaDSTableAdapters.UnitaOperativeTableAdapter()
            ta.Connection = Connection
            ta.Transaction = Transaction

            Dim dt As OrganigrammaDS.UnitaOperativeDataTable = ta.GetData()
            If dt.Rows.Count > 0 Then

                list = New Wcf.WsTypes.DizionariType.UnitaOperativeType()

                For Each row In dt

                    list.Add(New Wcf.BaseTypes.StrutturaType() With {
                             .Azienda = New Wcf.BaseTypes.CodiceDescrizioneType() With {.Codice = row.AziendaCodice,
                                                                                        .Descrizione = If(row.IsAziendaDescrizioneNull, Nothing, row.AziendaDescrizione)},
                             .UnitaOperativa = New Wcf.BaseTypes.CodiceDescrizioneType() With {.Codice = row.UnitaOperativaCodice,
                                                                                               .Descrizione = If(row.IsUnitaOperativaDescrizioneNull, Nothing, row.UnitaOperativaDescrizione)}
                         })
                Next
            End If
        End Using

        Return list
    End Function

    Public Function GetUnitaOperativaByID(ByVal id As Guid) As OrganigrammaDS.UnitaOperativaRow

        DiagnosticsHelper.WriteDiagnostics("OrganigrammaAdapter.GetUnitaOperativaByID()")

        Dim row As OrganigrammaDS.UnitaOperativaRow = Nothing

        Using ta As New OrganigrammaDSTableAdapters.UnitaOperativaTableAdapter()
            ta.Connection = Connection
            ta.Transaction = Transaction

            Dim dt As OrganigrammaDS.UnitaOperativaDataTable = ta.GetDataByID(id)
            If dt.Rows.Count > 0 Then
                row = dt.First()
            End If
        End Using

        Return row
    End Function

    Public Function GetUnitaOperativaByCodice(ByVal codice As String, ByVal codiceAzienda As String) As OrganigrammaDS.UnitaOperativaRow

        DiagnosticsHelper.WriteDiagnostics("OrganigrammaAdapter.GetUnitaOperativaByCodice()")

        If String.IsNullOrEmpty(codice) Then
            Throw New OrderEntryArgumentNullException("codice unità operativa")
        End If

        If String.IsNullOrEmpty(codiceAzienda) Then
            Throw New OrderEntryArgumentNullException("codice azienda unità operativa")
        End If

        'Cerco nella cache
        Dim row As OrganigrammaDS.UnitaOperativaRow = Nothing
        row = My.CacheUnitaOperative.TryFindByCodice(codice, codiceAzienda)

        If row Is Nothing Then

            'Leggo dal DB
            Using ta As New OrganigrammaDSTableAdapters.UnitaOperativaTableAdapter()
                ta.Connection = Connection
                ta.Transaction = Transaction

                Dim dt As OrganigrammaDS.UnitaOperativaDataTable = ta.GetDataByCodice(codice, codiceAzienda)
                If dt.Rows.Count > 0 Then
                    ' Ritorno e aggiungo alla cache
                    row = dt.First
                    My.CacheUnitaOperative.TryAdd(row)
                End If
            End Using

        End If

        Return row

    End Function


    Public Function GetSistemiRichiedenti() As Wcf.WsTypes.DizionariType.SistemiRichiedentiType

        DiagnosticsHelper.WriteDiagnostics("OrganigrammaAdapter.GetSistemiRichiedenti()")

        Dim list As Wcf.WsTypes.DizionariType.SistemiRichiedentiType = Nothing

        Using ta As New OrganigrammaDSTableAdapters.SistemiRichiedentiTableAdapter()
            ta.Connection = Connection
            ta.Transaction = Transaction

            Dim dt As OrganigrammaDS.SistemiRichiedentiDataTable = ta.GetData()
            If dt.Rows.Count > 0 Then

                list = New Wcf.WsTypes.DizionariType.SistemiRichiedentiType()

                For Each row In dt

                    list.Add(New Wcf.BaseTypes.SistemaType() With {
                             .Azienda = New Wcf.BaseTypes.CodiceDescrizioneType() With {.Codice = row.AziendaCodice,
                                                                                        .Descrizione = If(row.IsAziendaDescrizioneNull, Nothing, row.AziendaDescrizione)},
                             .Sistema = New Wcf.BaseTypes.CodiceDescrizioneType() With {.Codice = row.SistemaCodice,
                                                                                        .Descrizione = If(row.IsSistemaDescrizioneNull, Nothing, row.SistemaDescrizione)}
                         })
                Next
            End If
        End Using

        Return list
    End Function

    Public Function GetSistemiEroganti(tokenAccesso As Wcf.WsTypes.TokenAccessoType) As Wcf.WsTypes.DizionariType.SistemiErogantiType

        DiagnosticsHelper.WriteDiagnostics("OrganigrammaAdapter.GetSistemiEroganti()")

        Dim list As Wcf.WsTypes.DizionariType.SistemiErogantiType = Nothing

        Using ta As New OrganigrammaDSTableAdapters.SistemiErogantiTableAdapter()
            ta.Connection = Connection
            ta.Transaction = Transaction

            Dim dt As OrganigrammaDS.SistemiErogantiDataTable = ta.GetDataByUtente(tokenAccesso.Utente)
            If dt.Rows.Count > 0 Then
                'Crea lista e la popola
                list = New Wcf.WsTypes.DizionariType.SistemiErogantiType()
                For Each row In dt
                    list.Add(New Wcf.BaseTypes.SistemaType() With {
                             .Azienda = New Wcf.BaseTypes.CodiceDescrizioneType() With {.Codice = row.AziendaCodice,
                                                                                        .Descrizione = If(row.IsAziendaDescrizioneNull, Nothing, row.AziendaDescrizione)},
                             .Sistema = New Wcf.BaseTypes.CodiceDescrizioneType() With {.Codice = row.SistemaCodice,
                                                                                        .Descrizione = If(row.IsSistemaDescrizioneNull, Nothing, row.SistemaDescrizione)}
                         })
                Next
            End If
        End Using

        Return list
    End Function

    Public Function GetSistemaByCodice(ByVal codice As String, ByVal codiceAzienda As String) As OrganigrammaDS.SistemaRow

        DiagnosticsHelper.WriteDiagnostics("OrganigrammaAdapter.GetSistemaByCodice()")

        'Cerco nella cache
        Dim row As OrganigrammaDS.SistemaRow = Nothing
        row = My.CacheSistemi.TryFindByCodice(codice, codiceAzienda)

        If row Is Nothing Then

            'Leggo dal DB
            Using ta As New OrganigrammaDSTableAdapters.SistemaTableAdapter()
                ta.Connection = Connection
                ta.Transaction = Transaction

                Dim dt As OrganigrammaDS.SistemaDataTable

                'Controllo se sistema vuoto (profilo)
                If String.IsNullOrEmpty(codice) AndAlso String.IsNullOrEmpty(codiceAzienda) Then
                    'Cerco per Id vuoto
                    dt = ta.GetDataByID(Guid.Empty)
                Else
                    'Cerco per sistama + azienda
                    dt = ta.GetDataByCodice(codice, codiceAzienda)
                End If

                If dt.Rows.Count > 0 Then
                    ' Ritorno e aggiungo alla cache
                    row = dt.First
                    My.CacheSistemi.TryAdd(row)
                End If
            End Using
        End If

        Return row
    End Function



    Public Function GetSistemaIdByCodice(ByVal codice As String, ByVal codiceAzienda As String) As Guid

        DiagnosticsHelper.WriteDiagnostics("OrganigrammaAdapter.GetSistemaIdByCodice()")

        If String.IsNullOrEmpty(codice) AndAlso String.IsNullOrEmpty(codiceAzienda) Then

            'se vuoto torno 0000-00000000-
            Return Guid.Empty
        Else
            Dim rowSistemaErogante As OrganigrammaDS.SistemaRow = GetSistemaByCodice(codice, codiceAzienda)
            If rowSistemaErogante Is Nothing Then
                '
                ' Errore
                '
                Dim reason As String = String.Format("Il sistema {0}@{1} non è codificato nell'order entry.",
                                                                                                codice,
                                                                                                codiceAzienda)
                Throw New OrderEntryNotFoundException("Sistema", reason)
            End If

            Return rowSistemaErogante.ID
        End If

    End Function




    Public Function GetSistemaByID(ByVal id As Guid) As OrganigrammaDS.SistemaRow

        DiagnosticsHelper.WriteDiagnostics("OrganigrammaAdapter.GetSistemaByID()")

        Dim row As OrganigrammaDS.SistemaRow = Nothing

        Using ta As New OrganigrammaDSTableAdapters.SistemaTableAdapter()
            ta.Connection = Connection
            ta.Transaction = Transaction

            Dim dt As OrganigrammaDS.SistemaDataTable = ta.GetDataByID(id)
            If dt.Rows.Count > 0 Then
                row = dt.First()
            End If
        End Using

        Return row
    End Function


    Private Sub ConsolidaAzienda(ByRef obj As Msg.QueueTypes.StrutturaType)

        DiagnosticsHelper.WriteDiagnostics("OrganigrammaAdapter.ConsolidaAzienda()")

        Dim azienda As OrganigrammaDS.AziendaRow = GetAziendaByCodice(obj.Azienda.Codice)
        If azienda IsNot Nothing Then
            '
            ' Se trovato completa i dati
            '
            If Not azienda.IsDescrizioneNull Then
                obj.Azienda.Descrizione = azienda.Descrizione
            End If
        End If

    End Sub

    Private Sub ConsolidaAzienda(ByRef obj As Msg.QueueTypes.SistemaType)

        DiagnosticsHelper.WriteDiagnostics("OrganigrammaAdapter.ConsolidaAzienda()")

        Dim azienda As OrganigrammaDS.AziendaRow = GetAziendaByCodice(obj.Azienda.Codice)
        If azienda IsNot Nothing Then
            '
            ' Se trovato completa i dati
            '
            If Not azienda.IsDescrizioneNull Then
                obj.Azienda.Descrizione = azienda.Descrizione
            End If
        End If

    End Sub

    Private Sub ConsolidaAzienda(ByRef obj As Wcf.BaseTypes.StrutturaType)

        DiagnosticsHelper.WriteDiagnostics("OrganigrammaAdapter.ConsolidaAzienda()")

        Dim azienda As OrganigrammaDS.AziendaRow = GetAziendaByCodice(obj.Azienda.Codice)
        If azienda IsNot Nothing Then
            '
            ' Se trovato completa i dati
            '
            If Not azienda.IsDescrizioneNull Then
                obj.Azienda.Descrizione = azienda.Descrizione
            End If
        End If

    End Sub

    Private Sub ConsolidaAzienda(ByRef obj As Wcf.BaseTypes.SistemaType)

        DiagnosticsHelper.WriteDiagnostics("OrganigrammaAdapter.ConsolidaAzienda()")

        Dim azienda As OrganigrammaDS.AziendaRow = GetAziendaByCodice(obj.Azienda.Codice)
        If azienda IsNot Nothing Then
            '
            ' Se trovato completa i dati
            '
            If Not azienda.IsDescrizioneNull Then
                obj.Azienda.Descrizione = azienda.Descrizione
            End If
        End If

    End Sub


    Public Function ConsolidaUnitaOperativa(ByRef obj As Msg.QueueTypes.StrutturaType) As OrganigrammaDS.UnitaOperativaRow

        DiagnosticsHelper.WriteDiagnostics("OrganigrammaAdapter.ConsolidaUnitaOperativa()")
        '
        ' Cerca unità operativa
        '
        Dim unitaOperativa As OrganigrammaDS.UnitaOperativaRow = Nothing
        unitaOperativa = GetUnitaOperativaByCodice(obj.UnitaOperativa.Codice, obj.Azienda.Codice)
        If unitaOperativa Is Nothing Then
            '
            ' Non trovata, aggiunge se AutoSyncUnitaOperative
            '
            If ConfigurationHelper.AutoSyncUnitaOperative Then
                unitaOperativa = InsertUnitaOperativa(obj)
            End If
        End If
        '
        ' Se trovato completa i dati
        '
        If unitaOperativa IsNot Nothing AndAlso Not unitaOperativa.IsDescrizioneNull() Then
            obj.UnitaOperativa.Descrizione = unitaOperativa.Descrizione
        End If

        If unitaOperativa IsNot Nothing AndAlso Not unitaOperativa.IsDescrizioneAziendaNull() Then
            obj.Azienda.Descrizione = unitaOperativa.DescrizioneAzienda
        End If

        Return unitaOperativa
    End Function

    Public Function ConsolidaUnitaOperativa(ByRef obj As Wcf.BaseTypes.StrutturaType) As OrganigrammaDS.UnitaOperativaRow

        DiagnosticsHelper.WriteDiagnostics("OrganigrammaAdapter.ConsolidaUnitaOperativa()")
        '
        ' Cerca unità operativa
        '
        Dim unitaOperativa As OrganigrammaDS.UnitaOperativaRow = Nothing
        unitaOperativa = GetUnitaOperativaByCodice(obj.UnitaOperativa.Codice, obj.Azienda.Codice)
        '
        ' Se trovato completa i dati
        '
        If unitaOperativa IsNot Nothing AndAlso Not unitaOperativa.IsDescrizioneNull Then
            obj.UnitaOperativa.Descrizione = unitaOperativa.Descrizione
        End If

        If unitaOperativa IsNot Nothing AndAlso Not unitaOperativa.IsDescrizioneAziendaNull Then
            obj.Azienda.Descrizione = unitaOperativa.DescrizioneAzienda
        End If

        Return unitaOperativa
    End Function


    Public Function ConsolidaSistema(ByRef obj As Msg.QueueTypes.SistemaType, ByVal erogante As Boolean, ByVal richiedente As Boolean) As OrganigrammaDS.SistemaRow

        DiagnosticsHelper.WriteDiagnostics("OrganigrammaAdapter.ConsolidaSistema()")
        '
        ' Cerca sistema
        '
        Dim sistema As OrganigrammaDS.SistemaRow = Nothing

        If obj.Sistema IsNot Nothing And obj.Azienda IsNot Nothing Then
            '
            ' Cerco per codici
            '
            sistema = GetSistemaByCodice(obj.Sistema.Codice, obj.Azienda.Codice)
            If sistema Is Nothing Then
                '
                ' Non trovata, aggiunge se AutoSyncUnitaOperative
                '
                If richiedente AndAlso ConfigurationHelper.AutoSyncSistemiRichiedenti Then
                    sistema = InsertSistema(obj, erogante, richiedente)

                ElseIf erogante AndAlso ConfigurationHelper.AutoSyncSistemiEroganti Then
                    sistema = InsertSistema(obj, erogante, richiedente)
                End If
            End If
            '
            ' Se trovato completa i dati
            '
            If sistema IsNot Nothing AndAlso Not sistema.IsDescrizioneNull() Then
                obj.Sistema.Descrizione = sistema.Descrizione
            End If

            If sistema IsNot Nothing AndAlso Not sistema.IsDescrizioneAziendaNull() Then
                obj.Azienda.Descrizione = sistema.DescrizioneAzienda
            End If
        End If

        Return sistema
    End Function

    Public Function ConsolidaSistema(ByRef obj As Wcf.BaseTypes.SistemaType, ByVal erogante As Boolean, ByVal richiedente As Boolean) As OrganigrammaDS.SistemaRow

        DiagnosticsHelper.WriteDiagnostics("OrganigrammaAdapter.ConsolidaSistema()")
        '
        ' Cerca sistema
        '
        Dim sistema As OrganigrammaDS.SistemaRow = Nothing

        If obj.Sistema IsNot Nothing And obj.Azienda IsNot Nothing Then

            ' Cerco per codici
            sistema = GetSistemaByCodice(obj.Sistema.Codice, obj.Azienda.Codice)

            ' Se trovato completa i dati
            If sistema IsNot Nothing AndAlso Not sistema.IsDescrizioneNull() Then
                obj.Sistema.Descrizione = sistema.Descrizione
            End If

            If sistema IsNot Nothing AndAlso Not sistema.IsDescrizioneAziendaNull() Then
                obj.Azienda.Descrizione = sistema.DescrizioneAzienda
            End If
        End If

        Return sistema

    End Function


    Private Function InsertUnitaOperativa(ByVal obj As Msg.QueueTypes.StrutturaType) As OrganigrammaDS.UnitaOperativaRow

        DiagnosticsHelper.WriteDiagnostics("OrganigrammaAdapter.InsertUnitaOperativa()")

        CoreUnitaOperativeInsert(obj.UnitaOperativa.Codice, obj.UnitaOperativa.Descrizione, obj.Azienda.Codice)
        Return GetUnitaOperativaByCodice(obj.UnitaOperativa.Codice, obj.Azienda.Codice)

    End Function

    Private Function InsertSistema(ByVal obj As Msg.QueueTypes.SistemaType, ByVal erogante As Boolean, ByVal richiedente As Boolean) As OrganigrammaDS.SistemaRow

        DiagnosticsHelper.WriteDiagnostics("OrganigrammaAdapter.InsertSistema()")

        CoreSistemiInsert(obj.Sistema.Codice, obj.Sistema.Descrizione, erogante, richiedente, obj.Azienda.Codice)
        Return GetSistemaByCodice(obj.Sistema.Codice, obj.Azienda.Codice)

    End Function



    Public Shared Function GetIdSistemaByCodice(ByVal codice As String, ByVal codiceAzienda As String) As Guid

        DiagnosticsHelper.WriteDiagnostics("OrganigrammaAdapter.GetIdSistemaByCodice()")

        'NON Controllo parametri, il sistema puù essere vuoto (nei profili)

        Dim row As OrganigrammaDS.SistemaRow = Nothing

        'Cerco nella cache
        row = My.CacheSistemi.TryFindByCodice(codice, codiceAzienda)
        If row Is Nothing Then

            'Leggo dal DB
            Using ta As New OrganigrammaDSTableAdapters.SistemaTableAdapter()
                ta.Connection.ConnectionString = My.OrderEntryConfig.ConnectionString

                Dim dt As OrganigrammaDS.SistemaDataTable

                'Controllo se sistema vuoto (profilo)
                If String.IsNullOrEmpty(codice) AndAlso String.IsNullOrEmpty(codiceAzienda) Then
                    'Cerco per Id vuoto
                    dt = ta.GetDataByID(Guid.Empty)
                Else
                    'Cerco per sistama + azienda
                    dt = ta.GetDataByCodice(codice, codiceAzienda)
                End If

                If dt.Rows.Count > 0 Then
                    ' Ritorno e aggiungo alla cache
                    row = dt.First
                    My.CacheSistemi.TryAdd(row)
                End If
            End Using

        End If

        'Ritorna ID
        If row IsNot Nothing Then
            Return row.ID
        Else
            'Errore non trovato
            Dim reason = String.Format("Il sistema richiedente {0} non è codificato nell'order entry.", _
                                                            String.Concat(codice, "@", codiceAzienda))
            Throw New ApplicationException(reason)
        End If

    End Function

    Public Shared Function GetIdUnitaOperativaByCodice(ByVal codice As String, ByVal codiceAzienda As String) As Guid

        DiagnosticsHelper.WriteDiagnostics("OrganigrammaAdapter.GetIdUnitaOperativaByCodice()")

        'Controllo parametri
        If String.IsNullOrEmpty(codice) Then
            Throw New OrderEntryArgumentNullException("codice unità operativa")
        End If
        If String.IsNullOrEmpty(codiceAzienda) Then
            Throw New OrderEntryArgumentNullException("codice azienda unità operativa")
        End If

        Dim row As OrganigrammaDS.UnitaOperativaRow = Nothing

        'Cerco nella cache
        row = My.CacheUnitaOperative.TryFindByCodice(codice, codiceAzienda)
        If row Is Nothing Then

            'Leggo dal DB
            Using ta As New OrganigrammaDSTableAdapters.UnitaOperativaTableAdapter()
                ta.Connection.ConnectionString = My.OrderEntryConfig.ConnectionString

                Dim dt As OrganigrammaDS.UnitaOperativaDataTable = ta.GetDataByCodice(codice, codiceAzienda)
                If dt.Rows.Count > 0 Then
                    ' Ritorno e aggiungo alla cache
                    row = dt.First
                    My.CacheUnitaOperative.TryAdd(row)
                End If
            End Using

        End If

        'Ritorna ID
        If row IsNot Nothing Then
            Return row.ID
        Else
            'Errore non trovato
            Dim reason = String.Format("L'unità operativa {0} non è codificata nell'order entry.", _
                                                            String.Concat(codice, "@", codiceAzienda))
            Throw New ApplicationException(reason)
        End If

    End Function

End Class