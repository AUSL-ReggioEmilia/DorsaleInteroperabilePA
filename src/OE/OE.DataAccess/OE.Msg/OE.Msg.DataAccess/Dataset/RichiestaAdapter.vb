Imports System.Data.SqlClient
Imports System.Data.Linq
Imports System.Text
Imports OE.Core
Imports OE.Core.Schemas.Msg
Imports OE.Core.Schemas.Msg.QueueTypes

Friend Class RichiestaAdapter
    Inherits OrdiniDSTableAdapters.CommandsAdapter
    Implements IAdapter

#Region " Connection & Transaction "

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
        DiagnosticsHelper.WriteDiagnostics("RichiestaAdapter.SetCommandsConnection()")

        For Each commands As IDbCommand In MyBase.CommandCollection
            '
            ' Se necessario apro la connessione
            '
            If _connection IsNot Nothing AndAlso _connection.State = ConnectionState.Closed Then
                _connection.Open()
            End If
            '
            ' Setto su tutti i command sulla stessa connesione
            '
            commands.Connection = _connection
        Next
    End Sub

    Public Sub BeginTransaction(ByVal isolationLevel As IsolationLevel) Implements IAdapter.BeginTransaction
        DiagnosticsHelper.WriteDiagnostics("RichiestaAdapter.BeginTransaction()")
        '
        ' Controllo se la connessione è aperta
        '
        If _connection.State = ConnectionState.Closed Then
            '
            ' Genero l'eccezione
            '
            Throw New Exception("Errore durante RichiestaAdapter.BeginTransaction(). La connessione al database è chiusa!")
        End If

        For Each commands As IDbCommand In MyBase.CommandCollection
            '
            ' Se necessario inizio la transazione
            '
            If _transaction Is Nothing Then
                _transaction = _connection.BeginTransaction(isolationLevel)
            End If
            '
            ' Setto su tutti i command sulla stessa transazione
            '
            commands.Transaction = _transaction
        Next
    End Sub

    Public Sub Commit() Implements IAdapter.Commit
        DiagnosticsHelper.WriteDiagnostics("RichiestaAdapter.Commit()")

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
        DiagnosticsHelper.WriteDiagnostics("RichiestaAdapter.Rollback()")

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
        DiagnosticsHelper.WriteDiagnostics("RichiestaAdapter.Disposed()")

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

        DiagnosticsHelper.WriteDiagnostics("RichiestaAdapter.New()")
        '
        ' Creo la connessione
        '
        If _connection Is Nothing Then
            _bCanDisposeConnection = True
            _connection = New System.Data.SqlClient.SqlConnection(connectionString)
        End If
        '
        ' Setto su tutti i command sulla stessa connesione
        '
        SetCommandsConnection()

    End Sub

    Public Sub New(ByVal connection As SqlConnection, ByVal transaction As SqlTransaction, ByVal isolationLevel As IsolationLevel)
        MyBase.New()

        DiagnosticsHelper.WriteDiagnostics("RichiestaAdapter.New()")
        '
        ' Set della connessione e non DISPOSE
        '
        _bCanDisposeConnection = False
        _connection = connection
        '
        ' Setto su tutti i command sulla stessa connesione
        '
        SetCommandsConnection()
        '
        ' Set della transaction
        '
        _transaction = transaction
        '
        ' Inizio la transazione
        '
        BeginTransaction(isolationLevel)

    End Sub

#End Region


#Region "Testata"

    Private Function GetTestataByProtocollo(ByVal anno As Integer, ByVal numero As Integer) As OrdiniDS.TestataRow
        DiagnosticsHelper.WriteDiagnostics("RichiestaAdapter.GetTestataByProtocollo()")

        Dim row As OrdiniDS.TestataRow = Nothing

        Using ta As New OrdiniDSTableAdapters.TestataTableAdapter()
            ta.Connection = Me._connection
            ta.Transaction = Me._transaction

            Dim dt As OrdiniDS.TestataDataTable = ta.GetDataByProtocollo(anno, numero)
            If dt.Rows.Count > 0 Then
                row = dt.First()
            End If
        End Using

        Return row

    End Function

    Private Function GetTestataByIDSistemaRichiedente(ByVal idSistemaRichiedente As Guid, ByVal idRichiestaRichiedente As String) As OrdiniDS.TestataRow
        DiagnosticsHelper.WriteDiagnostics("RichiestaAdapter.GetTestataByIDSistemaRichiedente()")

        If Guid.Equals(idSistemaRichiedente, Guid.Empty) Then
            Throw New OrderEntryArgumentNullException("idSistemaRichiedente")
        End If

        If String.IsNullOrEmpty(idRichiestaRichiedente) Then
            Throw New OrderEntryArgumentNullException("idRichiestaRichiedente")
        End If

        Dim row As OrdiniDS.TestataRow = Nothing

        Using ta As New OrdiniDSTableAdapters.TestataTableAdapter()
            ta.Connection = Me._connection
            ta.Transaction = Me._transaction

            Dim dt As OrdiniDS.TestataDataTable = ta.GetDataByIDSistemaRichiedente(idSistemaRichiedente, idRichiestaRichiedente)
            If dt.Rows.Count > 0 Then
                row = dt.First()
            End If
        End Using

        Return row

    End Function

    Public Function GetTestata(ByVal obj As QueueTypes.TestataRichiestaType,
                               ByVal idSistemaRichiedente As Nullable(Of Guid)) As OrdiniDS.TestataRow

        DiagnosticsHelper.WriteDiagnostics("RichiestaAdapter.GetTestata()")

        Return GetTestata(obj.IdRichiestaOrderEntry, idSistemaRichiedente, obj.IdRichiestaRichiedente)

    End Function

    Public Function GetTestata(ByVal idRichiestaOrderEntry As String,
                               ByVal idSistemaRichiedente As Nullable(Of Guid),
                               idRichiestaRichiedente As String) As OrdiniDS.TestataRow

        DiagnosticsHelper.WriteDiagnostics("RichiestaAdapter.GetTestata()")

        Dim testata As OrdiniDS.TestataRow = Nothing

        'Estraggo Numeo+Anno da idOE, potrevve avere lo split
        If Not String.IsNullOrEmpty(idRichiestaOrderEntry) AndAlso idRichiestaOrderEntry.Contains("@") Then
            Dim aIdOe As String() = idRichiestaOrderEntry.Split("@"c)
            idRichiestaOrderEntry = aIdOe(0)
        End If

        ' 1. Cerco la testata richiesta per IdRichiestaOrderEntry (anno/numero)
        If Not String.IsNullOrEmpty(idRichiestaOrderEntry) AndAlso idRichiestaOrderEntry.Contains("/") Then

            Dim protocollo As String() = idRichiestaOrderEntry.Split("/"c)
            Dim anno, numero As Integer

            If Integer.TryParse(protocollo(0), anno) AndAlso Integer.TryParse(protocollo(1), numero) Then
                ' Cerco per Anno e Numero
                testata = GetTestataByProtocollo(anno, numero)
            End If
        End If

        If testata Is Nothing Then
            '2. Cerco la testata richiesta per  idSistemaRichiedente e IdRichiestaRichiedente
            If idSistemaRichiedente.HasValue AndAlso Not String.IsNullOrEmpty(idRichiestaRichiedente) Then

                testata = GetTestataByIDSistemaRichiedente(idSistemaRichiedente.Value, idRichiestaRichiedente)
            End If
        End If

        Return testata

    End Function

#End Region

#Region "TestataDatiAggiuntivi"

    Private Function GetTestataDatoAggiuntivoByIDDatoAggiuntivo(ByVal idOrdineTestata As Guid,
                                                                ByVal idDatoAggiuntivo As String) As OrdiniDS.TestataDatoAggiuntivoRow

        DiagnosticsHelper.WriteDiagnostics("RichiestaAdapter.GetTestataDatoAggiuntivoByIDDatoAggiuntivo()")

        If Guid.Equals(idOrdineTestata, Guid.Empty) Then
            Throw New OrderEntryArgumentNullException("idOrdineTestata")
        End If

        Dim row As OrdiniDS.TestataDatoAggiuntivoRow = Nothing

        If Not String.IsNullOrEmpty(idDatoAggiuntivo) Then

            Using ta As New OrdiniDSTableAdapters.TestataDatoAggiuntivoTableAdapter()
                ta.Connection = Me._connection
                ta.Transaction = Me._transaction

                Dim dt As OrdiniDS.TestataDatoAggiuntivoDataTable = ta.GetDataByIDDatoAggiuntivo(idOrdineTestata, idDatoAggiuntivo)
                If dt.Rows.Count > 0 Then
                    row = dt.First()
                End If
            End Using
        End If

        Return row

    End Function

    Private Function GetTestataDatiAggiuntiviByIdOrdineTestata(ByVal idOrdineTestata As Guid) As List(Of OrdiniDS.TestataDatoAggiuntivoRow)

        DiagnosticsHelper.WriteDiagnostics("RichiestaAdapter.GetTestataDatiAggiuntiviByIdOrdineTestata()")

        If Guid.Equals(idOrdineTestata, Guid.Empty) Then
            Throw New OrderEntryArgumentNullException("idOrdineTestata")
        End If

        Dim rows As List(Of OrdiniDS.TestataDatoAggiuntivoRow) = Nothing

        Using ta As New OrdiniDSTableAdapters.TestataDatoAggiuntivoTableAdapter()
            ta.Connection = Me._connection
            ta.Transaction = Me._transaction

            Dim dt As OrdiniDS.TestataDatoAggiuntivoDataTable = ta.GetDataByIDOrdineTestata(idOrdineTestata)
            If dt.Rows.Count > 0 Then

                rows = New List(Of OrdiniDS.TestataDatoAggiuntivoRow)
                rows.AddRange(dt.Rows.Cast(Of OrdiniDS.TestataDatoAggiuntivoRow))
            End If
        End Using

        Return rows

    End Function

#End Region

#Region "RigheRichieste"

    Private Function GetRigaRichiestaByRigaRichiedente(ByVal idOrdineTestata As Guid,
                                                       ByVal idRigaRichiedente As String) As OrdiniDS.RigaRichiestaRow

        DiagnosticsHelper.WriteDiagnostics("RichiestaAdapter.GetRigaRichiestaByRigaRichiedente()")

        If Guid.Equals(idOrdineTestata, Guid.Empty) Then
            Throw New OrderEntryArgumentNullException("idOrdineTestata")
        End If

        Dim row As OrdiniDS.RigaRichiestaRow = Nothing

        If Not String.IsNullOrEmpty(idRigaRichiedente) Then

            Using ta As New OrdiniDSTableAdapters.RigaRichiestaTableAdapter()
                ta.Connection = Me._connection
                ta.Transaction = Me._transaction

                Dim dt As OrdiniDS.RigaRichiestaDataTable = ta.GetDataByRigaRichiedente(idOrdineTestata, idRigaRichiedente)
                If dt.Rows.Count > 0 Then
                    row = dt.First()
                End If
            End Using
        End If

        Return row

    End Function

    Private Function GetRigheRichiesteByIdOrdineTestata(ByVal idOrdineTestata As Guid) As List(Of OrdiniDS.RigaRichiestaRow)

        DiagnosticsHelper.WriteDiagnostics("RichiestaAdapter.GetRigheRichiesteByIdOrdineTestata()")

        If Guid.Equals(idOrdineTestata, Guid.Empty) Then
            Throw New OrderEntryArgumentNullException("idOrdineTestata")
        End If

        Dim rows As List(Of OrdiniDS.RigaRichiestaRow) = Nothing

        Using ta As New OrdiniDSTableAdapters.RigaRichiestaTableAdapter()
            ta.Connection = Me._connection
            ta.Transaction = Me._transaction

            Dim dt As OrdiniDS.RigaRichiestaDataTable = ta.GetDataByIDOrdineTestata(idOrdineTestata)
            If dt.Rows.Count > 0 Then

                rows = New List(Of OrdiniDS.RigaRichiestaRow)
                rows.AddRange(dt.Rows.Cast(Of OrdiniDS.RigaRichiestaRow))
            End If
        End Using

        Return rows

    End Function

#End Region

#Region "RigheRichiesteDatiAggiuntivi"

    Private Function GetRigaRichiestaDatoAggiuntivoByIDDatoAggiuntivo(ByVal idRigaRichiesta As Guid,
                                                                      ByVal idDatoAggiuntivo As String) As OrdiniDS.RigaRichiestaDatoAggiuntivoRow

        DiagnosticsHelper.WriteDiagnostics("RichiestaAdapter.GetRigaRichiestaDatoAggiuntivoByIDDatoAggiuntivo()")

        If Guid.Equals(idRigaRichiesta, Guid.Empty) Then
            Throw New OrderEntryArgumentNullException("idRigaRichiesta")
        End If

        Dim row As OrdiniDS.RigaRichiestaDatoAggiuntivoRow = Nothing

        If Not String.IsNullOrEmpty(idDatoAggiuntivo) Then

            Using ta As New OrdiniDSTableAdapters.RigaRichiestaDatoAggiuntivoTableAdapter()
                ta.Connection = Me._connection
                ta.Transaction = Me._transaction

                Dim dt As OrdiniDS.RigaRichiestaDatoAggiuntivoDataTable = ta.GetDataByIDDatoAggiuntivo(idRigaRichiesta, idDatoAggiuntivo)
                If dt.Rows.Count > 0 Then
                    row = dt.First()
                End If
            End Using
        End If

        Return row

    End Function

    Private Function GetRigaRichiestaDatiAggiuntiviByIDRigaRichiesta(ByVal idRigaRichiesta As Guid) As List(Of OrdiniDS.RigaRichiestaDatoAggiuntivoRow)

        DiagnosticsHelper.WriteDiagnostics("RichiestaAdapter.GetRigaRichiestaDatiAggiuntiviByIDRigaRichiesta()")

        If Guid.Equals(idRigaRichiesta, Guid.Empty) Then
            Throw New OrderEntryArgumentNullException("idRigaRichiesta")
        End If

        Dim rows As List(Of OrdiniDS.RigaRichiestaDatoAggiuntivoRow) = Nothing

        Using ta As New OrdiniDSTableAdapters.RigaRichiestaDatoAggiuntivoTableAdapter()
            ta.Connection = Me._connection
            ta.Transaction = Me._transaction

            Dim dt As OrdiniDS.RigaRichiestaDatoAggiuntivoDataTable = ta.GetDataByIDRigaRichiesta(idRigaRichiesta)
            If dt.Rows.Count > 0 Then

                rows = New List(Of OrdiniDS.RigaRichiestaDatoAggiuntivoRow)
                rows.AddRange(dt.Rows.Cast(Of OrdiniDS.RigaRichiestaDatoAggiuntivoRow))
            End If
        End Using

        Return rows

    End Function


#End Region

#Region "Consoloda Elabora Legge"

    Private Sub ConsolidaRichiesta(ByRef obj As QueueTypes.TestataRichiestaType, ByVal testataRow As OrdiniDS.TestataRow)
        DiagnosticsHelper.WriteDiagnostics("RichiestaAdapter.ConsolidaRichiesta()")

        '
        ' Consolido la testata
        '
        obj.IdRichiestaOrderEntry = String.Concat(testataRow.Anno, "/", testataRow.Numero)
        obj.IdRichiestaRichiedente = testataRow.IDRichiestaRichiedente

    End Sub

    Private Sub ConsolidaRigheRichieste(ByVal ticket As Guid,
                                        ByRef righeRichieste As QueueTypes.RigheRichiesteType,
                                        ByVal statoOrderEntry As OperazioneTestataRichiestaOrderEntryEnum)

        DiagnosticsHelper.WriteDiagnostics("RichiestaAdapter.ConsolidaRigheRichieste()")

        If righeRichieste IsNot Nothing Then
            Using prestazioneAdapter As New PrestazioneAdapter(Me.Connection, Me.Transaction, ConfigurationHelper.TransactionIsolationLevel)

                For Each riga As QueueTypes.RigaRichiestaType In righeRichieste

                    ' Consolido del sistema erogante
                    Dim sistemaErogante As OrganigrammaDS.SistemaRow

                    Using organigrammaAdapter As New OrganigrammaAdapter(Me.Connection.ConnectionString)
                        sistemaErogante = organigrammaAdapter.ConsolidaSistema(riga.SistemaErogante, True, False)
                    End Using

                    If sistemaErogante Is Nothing Then
                        Throw New OrderEntryNotFoundException("Sistema erogante riga richiesta non trovato.",
                                      String.Format("Sistema={0}, Azienda={1}",
                                                    riga.SistemaErogante.Sistema.Codice, riga.SistemaErogante.Azienda.Codice))

                    End If

                    ' Consolido la prestazione
                    prestazioneAdapter.Consolida(ticket, sistemaErogante.ID, riga.Prestazione, True)

                    'se lo stato o.e. di testata è CA setto riga a CA
                    If statoOrderEntry = OperazioneTestataRichiestaOrderEntryEnum.CA Then
                        riga.OperazioneOrderEntry = OperazioneRigaRichiestaOrderEntryEnum.CA.ToString
                    End If

                    ' Se vuoto IdRigaRichiedente, setto richiedente al valore del Codice Prestazione + Sistema erogante
                    '
                    If String.IsNullOrEmpty(riga.IdRigaRichiedente) Then
                        riga.IdRigaRichiedente = righeRichieste.GeneraUnicoIdRigaRichiedente(riga)
                    End If

                Next
            End Using
        End If

    End Sub

    Public Sub RicalcolaAnteprima(ByVal ticket As Guid, ByVal idTestata As Guid)
        DiagnosticsHelper.WriteDiagnostics("RichiestaAdapter.RicalcolaAnteprima()")

        'Ricalcola anteprima e salva in testata

        'Eseguire fuori dalla TRANSAZIONE perche genera DEADLOCK
        Dim sAnteprima As String = AnteprimaRigheRichieste(idTestata)
        MsgOrdiniTestateUpdateAnteprima(idTestata, sAnteprima)

    End Sub

    Public Function Elabora(ByVal ticket As Guid, ByVal obj As QueueTypes.TestataRichiestaType) As Guid
        DiagnosticsHelper.WriteDiagnostics("RichiestaAdapter.Elabora()")

        Dim unitaOperativaRichiedente As OrganigrammaDS.UnitaOperativaRow
        Dim sistemaRichiedente As OrganigrammaDS.SistemaRow

        Using organigrammaAdapter As New OrganigrammaAdapter(Me.Connection.ConnectionString)

            ' Consolido unità operativa richiedente
            unitaOperativaRichiedente = organigrammaAdapter.ConsolidaUnitaOperativa(obj.UnitaOperativaRichiedente)
            If unitaOperativaRichiedente Is Nothing Then
                '
                ' Se non esiste e non è stata creata
                '
                Throw New OrderEntryNotFoundException("Unità operativa richiedente",
                                                    String.Format("L'unità operativa richiedente {0}@{1} non è codificato nell'order entry.", _
                                                            obj.UnitaOperativaRichiedente.Azienda.Codice, _
                                                            obj.UnitaOperativaRichiedente.UnitaOperativa.Codice))
            End If

            ' Consolido sistema richiedente
            sistemaRichiedente = organigrammaAdapter.ConsolidaSistema(obj.SistemaRichiedente, False, True)
            If sistemaRichiedente Is Nothing Then
                '
                ' Se non esiste e non è stata creata
                '
                Throw New OrderEntryNotFoundException("Sistema richiedente",
                                                      String.Format("Il sistema richiedente {0}@{1} non è codificato nell'order entry.", _
                                                                    obj.UnitaOperativaRichiedente.Azienda.Codice, _
                                                                    obj.UnitaOperativaRichiedente.UnitaOperativa.Codice))
            End If
        End Using

        ' Controllo se la testata d'ordine esiste
        '
        Dim testata As OrdiniDS.TestataRow = GetTestata(obj, sistemaRichiedente.ID)

        ' Get operazione OE
        '
        Dim operazioneOE As OperazioneTestataRichiestaOrderEntryEnum =
            DirectCast([Enum].Parse(GetType(OperazioneTestataRichiestaOrderEntryEnum), obj.OperazioneOrderEntry), OperazioneTestataRichiestaOrderEntryEnum)

        ' Get regime (solo per controllare se è nell'ENUM)
        '
        If obj.Regime IsNot Nothing Then
            Dim regime As QueueTypes.RegimeEnum = DirectCast([Enum].Parse(GetType(QueueTypes.RegimeEnum), obj.Regime.Codice), QueueTypes.RegimeEnum)
        Else
            '
            ' Errore se non valorizzato
            '
            Dim bIgnoraRegimeVuoto = ConfigurationHelper.GetOptionValue("IgnoraRegimeVuoto", False)
            If Not bIgnoraRegimeVuoto Then
                Throw New OrderEntryNotFoundException("Regime", "Il nodo Regime non può essere vuoto")
            End If
        End If

        ' Valuto i dati delle righe richeste, valorizzo dati mancanti e prestazione
        '
        ConsolidaRigheRichieste(ticket, obj.RigheRichieste, operazioneOE)

        If testata Is Nothing Then

            ' Insert testata
            testata = InsertTestata(ticket, unitaOperativaRichiedente.ID, sistemaRichiedente.ID, obj)

            ' Insert righe richieste
            InsertRigheRichieste(ticket, testata.ID, obj.RigheRichieste)
        Else

            ' Versioning
            Versioning(ticket, testata.ID, testata.StatoOrderEntry, obj.Data)

            ' Update testata
            testata = UpdateTestata(ticket, testata, unitaOperativaRichiedente.ID, sistemaRichiedente.ID, obj)

            ' Update righe richieste
            UpdateRigheRichieste(ticket, testata.ID, operazioneOE, obj.RigheRichieste)
        End If

        If testata Is Nothing Then
            Throw New OrderEntryNotFoundException("Testata ordine.",
                                                  String.Format("IdRichiestaOrderEntry={0}, CodiceSistemaRichiedente={1}, IdRichiestaRichiedente={2}",
                                                                obj.IdRichiestaOrderEntry, obj.SistemaRichiedente.Sistema.Codice, obj.IdRichiestaRichiedente))
        End If

        ' Save dei dati aggiuntivi e Merge dati persistenti
        SaveTestataDatiAggiuntivi(ticket, testata.ID, obj.DatiAggiuntivi)
        MergeTestataDatiPersistenti(ticket, testata.ID, obj.DatiPersistenti)

        ' Consolido la richiesta
        ConsolidaRichiesta(obj, testata)

        ' Return
        Return testata.ID
    End Function

    Public Function Legge(ByVal idRichiestaOrderEntry As String) As QueueTypes.TestataRichiestaType

        DiagnosticsHelper.WriteDiagnostics("RichiestaAdapter.Legge()")

        Dim idOrdineTestata As Guid
        Dim returnType As New QueueTypes.TestataRichiestaType
        Dim testataRow As OrdiniDS.TestataRow = Nothing

        'Rimuovo eventuale IdSplit
        If Not String.IsNullOrEmpty(idRichiestaOrderEntry) AndAlso idRichiestaOrderEntry.Contains("@") Then
            Dim aIdOe As String() = idRichiestaOrderEntry.Split("@"c)
            idRichiestaOrderEntry = aIdOe(0)
        End If

        ' Cerco la testata dell'ordine
        If Not String.IsNullOrEmpty(idRichiestaOrderEntry) AndAlso idRichiestaOrderEntry.Contains("/") Then

            Dim protocollo As String() = idRichiestaOrderEntry.Split("/"c)
            Dim anno, numero As Integer

            If Integer.TryParse(protocollo(0), anno) AndAlso Integer.TryParse(protocollo(1), numero) Then
                ' Cerco per Anno e Numero
                testataRow = GetTestataByProtocollo(anno, numero)
            End If
        End If

        If testataRow Is Nothing Then
            ' Non trovato
            Throw New ApplicationException("Ordine non trovato!")
        End If

        idOrdineTestata = testataRow.ID

        'Leggo dati aggiuntivi e persistenti della testata
        Dim testataDatiAggiuntiviRow As List(Of OrdiniDS.TestataDatoAggiuntivoRow)
        testataDatiAggiuntiviRow = GetTestataDatiAggiuntiviByIdOrdineTestata(idOrdineTestata)

        'Creo nodo dati aggiuntivi
        Dim testataDatiAggiuntivi As QueueTypes.DatiAggiuntiviType = Nothing
        Dim testataDatiPersistenti As QueueTypes.DatiPersistentiType = Nothing

        If testataDatiAggiuntiviRow IsNot Nothing AndAlso testataDatiAggiuntiviRow.Count > 0 Then
            testataDatiAggiuntivi = testataDatiAggiuntiviRow.ToTestataDatiAggiuntiviType
            testataDatiPersistenti = testataDatiAggiuntiviRow.ToTestataDatiPersistentiType
        End If

        'Creo nodo testata
        returnType = testataRow.ToTestataRichiestaType(testataDatiAggiuntivi, testataDatiPersistenti)

        ' Cerco le righe dell'ordine
        Dim righeRichiesteRow As List(Of OrdiniDS.RigaRichiestaRow)
        righeRichiesteRow = GetRigheRichiesteByIdOrdineTestata(idOrdineTestata)

        If righeRichiesteRow IsNot Nothing AndAlso righeRichiesteRow.Count > 0 Then
            'Creo nodo righe richieste
            returnType.RigheRichieste = New QueueTypes.RigheRichiesteType

            For Each rigaRichiestaRow In righeRichiesteRow

                'Leggo dati aggiuntivi della riga
                Dim rigaRichiestaDatiAggiuntiviRow As List(Of OrdiniDS.RigaRichiestaDatoAggiuntivoRow)
                rigaRichiestaDatiAggiuntiviRow = GetRigaRichiestaDatiAggiuntiviByIDRigaRichiesta(rigaRichiestaRow.ID)

                'Creo nodo dati aggiuntivi
                Dim rigaRichiestaDatiAggiuntivi As QueueTypes.DatiAggiuntiviType = Nothing

                If rigaRichiestaDatiAggiuntiviRow IsNot Nothing AndAlso rigaRichiestaDatiAggiuntiviRow.Count > 0 Then
                    rigaRichiestaDatiAggiuntivi = rigaRichiestaDatiAggiuntiviRow.ToRigaRichiestaDatiAggiuntiviType
                End If

                'Creo il nodo della riga e aggiungo
                Dim rigaRichiesta = rigaRichiestaRow.ToRigaRichiestaType(rigaRichiestaDatiAggiuntivi)
                returnType.RigheRichieste.Add(rigaRichiesta)
            Next
        Else
            ' Righe non trovate
            Throw New ApplicationException("Ordine non contiene nessuna riga richiesta!")
        End If

        Return returnType

    End Function

#End Region


#Region "Testata DB"

    Private Function InsertTestata(ByVal ticket As Guid,
                                   ByVal idUnitaOperativaRichiedente As Guid,
                                   ByVal idSistemaRichiedente As Guid,
                                   ByVal obj As QueueTypes.TestataRichiestaType) As OrdiniDS.TestataRow

        DiagnosticsHelper.WriteDiagnostics("RichiestaAdapter.InsertTestata()")

        '
        ' Valori XML
        '
        Dim operazioneRichiedente As String = DataContractSerializerHelper.GetXML(obj.OperazioneRichiedente)
        Dim operatore As String = DataContractSerializerHelper.GetXML(obj.Operatore)
        Dim priorita As String = DataContractSerializerHelper.GetXML(obj.Priorita)
        Dim tipoEpisodio As String = DataContractSerializerHelper.GetXML(obj.TipoEpisodio)
        Dim pazienteXML As String = DataContractSerializerHelper.GetXML(obj.Paziente)
        Dim consensi As String = DataContractSerializerHelper.GetXML(obj.Consensi)
        Dim regime As String = DataContractSerializerHelper.GetXML(obj.Regime)

        Dim anno As Integer = DateTime.Now.Year

        Dim paziente As QueueTypes.PazienteType = obj.Paziente.GetInstance
        Dim idSac As Nullable(Of Guid) = paziente.IdSac.ParseGuid("Paziente.IdSac")

        'Nello schema di BT dataPrenotazione non è nillable e potrebbe arrivare la data minima invece di NOTHING
        Dim dataPrenotazione As DateTime? = Nothing
        If obj.DataPrenotazione.HasValue Then
            If DateDiff(DateInterval.Day, DateTime.MinValue, obj.DataPrenotazione.Value) <> 0 Then
                dataPrenotazione = obj.DataPrenotazione
            End If
        End If

        'Calcola anteprima
        Dim sAnteprima As String = AnteprimaRigheRichieste(obj.RigheRichieste)

        MsgOrdiniTestateInsert(IDTicketInserimento:=ticket,
                               Anno:=anno,
                               IDUnitaOperativaRichiedente:=idUnitaOperativaRichiedente,
                               IDSistemaRichiedente:=idSistemaRichiedente,
                               NumeroNosologico:=obj.NumeroNosologico,
                               IDRichiestaRichiedente:=obj.IdRichiestaRichiedente,
                               DataRichiesta:=obj.DataRichiesta,
                               StatoOrderEntry:=obj.OperazioneOrderEntry,
                               SottoStatoOrderEntry:=SottoStatiOrderEntry.TestataRichiesta.INS_10.ToString(),
                               StatoRichiedente:=operazioneRichiedente,
                               Data:=obj.Data,
                               Operatore:=operatore,
                               Priorita:=priorita,
                               TipoEpisodio:=tipoEpisodio,
                               AnagraficaCodice:=paziente.AnagraficaCodice,
                               AnagraficaNome:=paziente.AnagraficaNome,
                               PazienteIdRichiedente:=paziente.IdRichiedente,
                               PazienteIdSac:=idSac,
                               PazienteRegime:=Nothing,
                               PazienteCognome:=paziente.Cognome,
                               PazienteNome:=paziente.Nome,
                               PazienteDataNascita:=paziente.DataNascita,
                               PazienteSesso:=paziente.Sesso,
                               PazienteCodiceFiscale:=paziente.CodiceFiscale,
                               Paziente:=pazienteXML,
                               Consensi:=consensi,
                               Note:=obj.Note,
                               Regime:=regime,
                               DataPrenotazione:=dataPrenotazione,
                               AnteprimaPrestazioni:=sAnteprima)
        '
        ' Return
        '
        Return GetTestata(obj, idSistemaRichiedente)

    End Function

    Private Function UpdateTestata(ByVal ticket As Guid, ByVal testata As OrdiniDS.TestataRow,
                                                         ByVal idUnitaOperativaRichiedente As Guid,
                                                         ByVal idSistemaRichiedente As Guid,
                                                         ByVal obj As QueueTypes.TestataRichiestaType) As OrdiniDS.TestataRow

        DiagnosticsHelper.WriteDiagnostics("RichiestaAdapter.UpdateTestata()")

        Dim idOrdineTestata As Guid = testata.ID

        ' Calcolo la data modifica stato
        Dim dataModificaStato As Nullable(Of DateTime) = Nothing
        If DirectCast([Enum].Parse(GetType(OperazioneTestataRichiestaOrderEntryEnum), testata.StatoOrderEntry), OperazioneTestataRichiestaOrderEntryEnum) <>
            DirectCast([Enum].Parse(GetType(OperazioneTestataRichiestaOrderEntryEnum), obj.OperazioneOrderEntry), OperazioneTestataRichiestaOrderEntryEnum) Then

            dataModificaStato = DateTime.Now
        Else

            If Not testata.IsDataModificaStatoNull() Then
                dataModificaStato = testata.DataModificaStato
            End If
        End If

        ' Valori XML
        Dim operazioneRichiedente As String = DataContractSerializerHelper.GetXML(obj.OperazioneRichiedente)
        Dim operatore As String = DataContractSerializerHelper.GetXML(obj.Operatore)
        Dim priorita As String = DataContractSerializerHelper.GetXML(obj.Priorita)
        Dim tipoEpisodio As String = DataContractSerializerHelper.GetXML(obj.TipoEpisodio)
        Dim pazienteXML As String = DataContractSerializerHelper.GetXML(obj.Paziente)
        Dim consensi As String = DataContractSerializerHelper.GetXML(obj.Consensi)
        Dim regime As String = DataContractSerializerHelper.GetXML(obj.Regime)

        Dim paziente As QueueTypes.PazienteType = obj.Paziente.GetInstance
        Dim idSac As Nullable(Of Guid) = paziente.IdSac.ParseGuid("Paziente.IdSac")

        'Nello schema di BT dataPrenotazione non è nillable e potrebbe arrivare la data minima invece di NOTHING
        Dim dataPrenotazione As DateTime? = Nothing
        If obj.DataPrenotazione.HasValue Then
            If DateDiff(DateInterval.Day, DateTime.MinValue, obj.DataPrenotazione.Value) <> 0 Then
                dataPrenotazione = obj.DataPrenotazione
            End If
        End If

        'Calcola anteprima
        Dim sAnteprima As String
        If obj.OperazioneOrderEntry <> OperazioneTestataRichiestaOrderEntryEnum.HD.ToString Then
            sAnteprima = AnteprimaRigheRichieste(obj.RigheRichieste)
        Else
            'In cancellazione mantiene i dati
            If testata.IsAnteprimaPrestazioniNull Then
                'Se vuoto comunque compilo
                sAnteprima = AnteprimaRigheRichieste(obj.RigheRichieste)
            Else
                sAnteprima = testata.AnteprimaPrestazioni
            End If
        End If

        MsgOrdiniTestateUpdate(ID:=idOrdineTestata,
                               IDTicketModifica:=ticket,
                               IDUnitaOperativaRichiedente:=idUnitaOperativaRichiedente,
                               IDSistemaRichiedente:=idSistemaRichiedente,
                               NumeroNosologico:=obj.NumeroNosologico,
                               IDRichiestaRichiedente:=obj.IdRichiestaRichiedente,
                               DataRichiesta:=obj.DataRichiesta,
                               StatoOrderEntry:=obj.OperazioneOrderEntry,
                               DataModificaStato:=dataModificaStato,
                               StatoRichiedente:=operazioneRichiedente,
                               Data:=obj.Data,
                               Operatore:=operatore,
                               Priorita:=priorita,
                               TipoEpisodio:=tipoEpisodio,
                               AnagraficaCodice:=paziente.AnagraficaCodice,
                               AnagraficaNome:=paziente.AnagraficaNome,
                               PazienteIdRichiedente:=paziente.IdRichiedente,
                               PazienteIdSac:=idSac,
                               PazienteRegime:=Nothing,
                               PazienteCognome:=paziente.Cognome,
                               PazienteNome:=paziente.Nome,
                               PazienteDataNascita:=paziente.DataNascita,
                               PazienteSesso:=paziente.Sesso,
                               PazienteCodiceFiscale:=paziente.CodiceFiscale,
                               Paziente:=pazienteXML,
                               Consensi:=consensi,
                               Note:=obj.Note,
                               Regime:=regime,
                               DataPrenotazione:=dataPrenotazione,
                               AnteprimaPrestazioni:=sAnteprima)
        '
        ' Return
        '
        Return GetTestata(obj, idSistemaRichiedente)

    End Function

    <Obsolete("Usare SaveTestataDatiAggiuntivi() + MergeTestataDatiPersistenti()")> _
    Private Sub MergeTestataDatiAggiuntiviPersistenti(ByVal ticket As Guid,
                                                      ByVal idOrdineTestata As Guid,
                                                      ByVal datiAggiuntivi As QueueTypes.DatiAggiuntiviType,
                                                      ByVal datiPersistenti As QueueTypes.DatiPersistentiType)

        DiagnosticsHelper.WriteDiagnostics("RichiestaAdapter.MergeTestataDatiAggiuntiviPersistenti()")

        '
        ' DELETE dei dati aggiuntivi
        '
        MsgOrdiniTestateDatiAggiuntiviDeleteByIDOrdine(idOrdineTestata)
        '
        ' INSERT dei dati aggiuntivi
        '
        If datiAggiuntivi IsNot Nothing Then
            For Each item As QueueTypes.DatoNomeValoreType In datiAggiuntivi

                If String.IsNullOrEmpty(item.TipoDato) Then
                    Throw New OrderEntryArgumentNullException("TipoDato")
                End If

                MsgOrdiniTestateDatiAggiuntiviInsert(IDTicketInserimento:=ticket,
                                                     IDOrdineTestata:=idOrdineTestata,
                                                     IDDatoAggiuntivo:=item.Id,
                                                     Nome:=item.Nome,
                                                     TipoDato:=item.TipoDato,
                                                     TipoContenuto:=item.TipoContenuto,
                                                     ValoreDato:=item.ValoreDato,
                                                     ParametroSpecifico:=False,
                                                     Persistente:=False)
            Next
        End If

        '
        ' MODIFICA(insert/update) dei dati aggiuntivi persistenti
        '
        If datiPersistenti IsNot Nothing Then
            For Each item As QueueTypes.DatoNomeValoreType In datiPersistenti
                If String.IsNullOrEmpty(item.TipoDato) Then
                    Throw New OrderEntryArgumentNullException("TipoDato")
                End If

                '
                ' Cerco il dato aggiuntivo persistente
                '
                Dim datoAggiuntivoPersistente As OrdiniDS.TestataDatoAggiuntivoRow = GetTestataDatoAggiuntivoByIDDatoAggiuntivo(idOrdineTestata, item.Id)

                If datoAggiuntivoPersistente Is Nothing Then
                    MsgOrdiniTestateDatiAggiuntiviInsert(IDTicketInserimento:=ticket,
                                                         IDOrdineTestata:=idOrdineTestata,
                                                         IDDatoAggiuntivo:=item.Id,
                                                         Nome:=item.Nome,
                                                         TipoDato:=item.TipoDato,
                                                         TipoContenuto:=item.TipoContenuto,
                                                         ValoreDato:=item.ValoreDato,
                                                         ParametroSpecifico:=False,
                                                         Persistente:=True)
                Else
                    MsgOrdiniTestateDatiAggiuntiviUpdate(ID:=datoAggiuntivoPersistente.ID,
                                                         IDTicketModifica:=ticket,
                                                         Nome:=item.Nome,
                                                         TipoDato:=item.TipoDato,
                                                         TipoContenuto:=item.TipoContenuto,
                                                         ValoreDato:=item.ValoreDato,
                                                         ParametroSpecifico:=False,
                                                         Persistente:=True)
                End If

            Next
        End If

    End Sub


    Private Sub SaveTestataDatiAggiuntivi(ByVal ticket As Guid,
                                                  ByVal idOrdineTestata As Guid,
                                                  ByVal datiAggiuntivi As QueueTypes.DatiAggiuntiviType)

        DiagnosticsHelper.WriteDiagnostics("RichiestaAdapter.MergeTestataDatiAggiuntiviPersistenti()")

        ' DELETE dei dati aggiuntivi
        MsgOrdiniTestateDatiAggiuntiviDeleteByIDOrdine(idOrdineTestata)

        ' INSERT dei dati aggiuntivi
        If datiAggiuntivi IsNot Nothing Then
            For Each item As QueueTypes.DatoNomeValoreType In datiAggiuntivi

                ' Controlla tipo dato
                If String.IsNullOrEmpty(item.TipoDato) Then
                    Throw New OrderEntryArgumentNullException("TipoDato")
                End If

                MsgOrdiniTestateDatiAggiuntiviInsert(IDTicketInserimento:=ticket,
                                                     IDOrdineTestata:=idOrdineTestata,
                                                     IDDatoAggiuntivo:=item.Id,
                                                     Nome:=item.Nome,
                                                     TipoDato:=item.TipoDato,
                                                     TipoContenuto:=item.TipoContenuto,
                                                     ValoreDato:=item.ValoreDato,
                                                     ParametroSpecifico:=False,
                                                     Persistente:=False)
            Next
        End If
    End Sub

    Private Sub MergeTestataDatiPersistenti(ByVal ticket As Guid,
                                                      ByVal idOrdineTestata As Guid,
                                                      ByVal datiPersistenti As QueueTypes.DatiPersistentiType)

        DiagnosticsHelper.WriteDiagnostics("RichiestaAdapter.MergeTestataDatiPersistenti()")


        ' MODIFICA(insert/update) dei dati aggiuntivi persistenti

        If datiPersistenti IsNot Nothing Then
            For Each item As QueueTypes.DatoNomeValoreType In datiPersistenti

                If String.IsNullOrEmpty(item.TipoDato) Then
                    Throw New OrderEntryArgumentNullException("TipoDato")
                End If


                ' Cerco il dato aggiuntivo persistente
                'TODO: Sandro, mi sembra che la ricerca dei dati persistenti sia errata, non ha lo scope delle solo persistenti
                Dim datoAggiuntivoPersistente As OrdiniDS.TestataDatoAggiuntivoRow = GetTestataDatoAggiuntivoByIDDatoAggiuntivo(idOrdineTestata, item.Id)

                If datoAggiuntivoPersistente Is Nothing Then

                    DiagnosticsHelper.WriteDiagnostics("RichiestaAdapter.MergeTestataDatiPersistenti() -> MsgOrdiniTestateDatiAggiuntiviInsert")

                    MsgOrdiniTestateDatiAggiuntiviInsert(IDTicketInserimento:=ticket,
                                                         IDOrdineTestata:=idOrdineTestata,
                                                         IDDatoAggiuntivo:=item.Id,
                                                         Nome:=item.Nome,
                                                         TipoDato:=item.TipoDato,
                                                         TipoContenuto:=item.TipoContenuto,
                                                         ValoreDato:=item.ValoreDato,
                                                         ParametroSpecifico:=False,
                                                         Persistente:=True)
                Else

                    DiagnosticsHelper.WriteDiagnostics("RichiestaAdapter.MergeTestataDatiPersistenti() -> MsgOrdiniTestateDatiAggiuntiviUpdate")

                    MsgOrdiniTestateDatiAggiuntiviUpdate(ID:=datoAggiuntivoPersistente.ID,
                                                         IDTicketModifica:=ticket,
                                                         Nome:=item.Nome,
                                                         TipoDato:=item.TipoDato,
                                                         TipoContenuto:=item.TipoContenuto,
                                                         ValoreDato:=item.ValoreDato,
                                                         ParametroSpecifico:=False,
                                                         Persistente:=True)
                End If

            Next
        End If

    End Sub

    Private Function AnteprimaRigheRichieste(ByVal objRigheRichieste As QueueTypes.RigheRichiesteType) As String
        '
        ' Calcola l'anteprima delle righe della richiesta
        '
        If objRigheRichieste IsNot Nothing AndAlso objRigheRichieste.Count > 0 Then

            ' Solo le non CA o senza stato
            Dim righeAnteprima = objRigheRichieste.Where(Function(e) String.IsNullOrEmpty(e.OperazioneOrderEntry) OrElse _
                                            e.OperazioneOrderEntry <> QueueTypes.OperazioneRigaRichiestaOrderEntryEnum.CA.ToString)

            ' Codice o Descrizione in DISTINCT
            Dim DescrizioniAnteprima = righeAnteprima.Select(Function(e) IIf(String.IsNullOrEmpty(e.Prestazione.Descrizione), _
                                                                             e.Prestazione.Codice, _
                                                                             e.Prestazione.Descrizione).ToString).Distinct

            ' Carico una lista di stringhe
            Dim listAnteprime As New List(Of String)
            listAnteprime.AddRange(DescrizioniAnteprima)

            'Ritorno l'anteprima come stringa

            If listAnteprime.Count > 0 Then
                Return String.Join("; ", listAnteprime.ToArray)
            Else
                Return Nothing
            End If
        Else
            Return Nothing
        End If

    End Function

    Private Function AnteprimaRigheRichieste(ByVal idOrdineTestata As Guid) As String
        '
        ' Processa le righe lette dal DB per calcolare l'anteprima
        '
        DiagnosticsHelper.WriteDiagnostics("OrdineAdapter.UpdateAnteprimaRigheRichieste()")

        Dim righeRichieste As New QueueTypes.RigheRichiesteType

        Dim listRighe As List(Of OrdiniDS.RigaRichiestaRow) = GetRigheRichiesteByIdOrdineTestata(idOrdineTestata)
        '
        'TODO: 2017-02-21 Aggiunto controllo da testare
        '
        If listRighe IsNot Nothing AndAlso listRighe.Count > 0 Then
            For Each row As OrdiniDS.RigaRichiestaRow In listRighe.FindAll(Function(e) Not e.IsStatoOrderEntryNull _
                                            AndAlso e.StatoOrderEntry <> OperazioneRigaRichiestaOrderEntryEnum.CA.ToString)
                '
                ' Aggiunge le non CA
                '
                righeRichieste.Add(row.ToRigaRichiestaType(Nothing))
            Next
        End If

        'Calcola anteprima
        Return AnteprimaRigheRichieste(righeRichieste)

    End Function

#End Region

#Region "Righe DB"

    Private Sub UpdateRigheRichieste(ByVal ticket As Guid,
                                     ByVal idOrdineTestata As Guid,
                                     ByVal statoOETestata As OperazioneTestataRichiestaOrderEntryEnum,
                                     ByVal righeRichieste As QueueTypes.RigheRichiesteType)

        DiagnosticsHelper.WriteDiagnostics("RichiestaAdapter.UpdateRigheRichieste()")

        If statoOETestata = OperazioneTestataRichiestaOrderEntryEnum.HD Then

            ' DELETE dei dati aggiuntivi
            MsgOrdiniRigheRichiesteDatiAggiuntiviDeleteByIDOrdine(idOrdineTestata)

            ' DELETE delle righe richieste
            MsgOrdiniRigheRichiesteDeleteByIDOrderEntry(idOrdineTestata)

            ' INSERT delle righe richieste
            InsertRigheRichieste(ticket, idOrdineTestata, righeRichieste)
        Else

            ' Merge delle righe richieste
            MergeRigheRichieste(ticket, idOrdineTestata, righeRichieste)
        End If
    End Sub

    Private Sub MergeRigheRichieste(ByVal ticket As Guid,
                                    ByVal idOrdineTestata As Guid,
                                    ByVal righeRichieste As QueueTypes.RigheRichiesteType)

        DiagnosticsHelper.WriteDiagnostics("RichiestaAdapter.MergeRigheRichieste()")

        Dim listRigheRichieste As New List(Of Guid)

        'Servono per verificare se insert o update
        '
        Dim righeCorrenti As List(Of OrdiniDS.RigaRichiestaRow)
        righeCorrenti = GetRigheRichiesteByIdOrdineTestata(idOrdineTestata)

        If righeCorrenti IsNot Nothing AndAlso righeCorrenti.Count > 0 Then

            ' Carico solo le non CA per calcolare le future CA
            '
            Dim righeCorrentiNonCA = righeCorrenti.FindAll(Function(e) Not e.IsStatoOrderEntryNull AndAlso
                                                               e.StatoOrderEntry <> OperazioneRigaRichiestaOrderEntryEnum.CA.ToString)
            listRigheRichieste.AddRange(righeCorrentiNonCA.Select(Function(e) e.ID))
        End If

        ' IdRiga più grande già nel DB
        '
        Dim iMaxIdRiga As Integer = righeCorrenti.GetMaxIdRigaOrderEntry()

        ' Su tutte le righe
        '
        If righeRichieste IsNot Nothing Then
            For Each item As QueueTypes.RigaRichiestaType In righeRichieste
                '
                ' Cerco la riga richiesta se c'è già
                '
                Dim rigaRichiesta As OrdiniDS.RigaRichiestaRow = Nothing
                Dim sIdRigaRichiedente As String = item.IdRigaRichiedente
                If righeCorrenti IsNot Nothing AndAlso righeCorrenti.Count > 0 Then
                    rigaRichiesta = righeCorrenti.Find(Function(e) Not e.IsIDRigaRichiedenteNull AndAlso e.IDRigaRichiedente = sIdRigaRichiedente)
                End If

                If rigaRichiesta Is Nothing Then
                    ' Insert
                    '
                    ' Progressivo IdRiga
                    '
                    iMaxIdRiga += 1
                    item.IdRigaOrderEntry = iMaxIdRiga.ToString()

                    rigaRichiesta = InsertRigaRichiesta(ticket, idOrdineTestata, item)
                Else
                    ' Update
                    '
                    ' Progressivo IdRiga leggo dal DB se c'è
                    '
                    If Not rigaRichiesta.IsIDRigaOrderEntryNull Then
                        item.IdRigaOrderEntry = rigaRichiesta.IDRigaOrderEntry
                    Else
                        iMaxIdRiga += 1
                        item.IdRigaOrderEntry = iMaxIdRiga.ToString()
                    End If

                    UpdateRigaRichiesta(ticket, idOrdineTestata, item)
                    listRigheRichieste.Remove(rigaRichiesta.ID)
                End If

                ' Save dei dati aggiuntivi della riga
                '
                If rigaRichiesta IsNot Nothing AndAlso item.DatiAggiuntivi IsNot Nothing Then
                    SaveRigaRichiestaDatiAggiuntivi(ticket, idOrdineTestata, rigaRichiesta.ID, item.DatiAggiuntivi)
                End If
            Next

            ' Aggiorno lo stato delle righe restanti nella collection listRigheRichieste a 'CA'
            '
            If listRigheRichieste.Count > 0 Then
                Dim ids As String = ConcatIDs(listRigheRichieste)
                MsgOrdiniRigheRichiesteUpdateStato(ticket, ids, OperazioneRigaRichiestaOrderEntryEnum.CA.ToString())
            End If

        End If

    End Sub

    Private Function InsertRigaRichiesta(ByVal ticket As Guid,
                                         ByVal idOrdineTestata As Guid,
                                         ByVal rigaRichiesta As QueueTypes.RigaRichiestaType) As OrdiniDS.RigaRichiestaRow

        DiagnosticsHelper.WriteDiagnostics("RichiestaAdapter.InsertRigaRichiesta()")

        ' Get del sistema erogante
        Dim sistemaErogante As OrganigrammaDS.SistemaRow

        Using organigrammaAdapter As New OrganigrammaAdapter(Me.Connection.ConnectionString)
            sistemaErogante = organigrammaAdapter.GetSistemaByCodice(rigaRichiesta.SistemaErogante.Sistema.Codice, rigaRichiesta.SistemaErogante.Azienda.Codice)
        End Using

        If sistemaErogante Is Nothing Then
            Throw New OrderEntryNotFoundException("sistema erogante", rigaRichiesta.SistemaErogante.Sistema.Codice & "|" & _
                                                                     rigaRichiesta.SistemaErogante.Azienda.Codice)
        End If

        ' Get della prestazione
        Dim prestazione As PrestazioniDS.PrestazioneRow

        Using prestazioneAdapter As New PrestazioneAdapter(Me.Connection, Me.Transaction, ConfigurationHelper.TransactionIsolationLevel)
            prestazione = prestazioneAdapter.GetBySistemaErogante(rigaRichiesta.Prestazione.Codice, sistemaErogante.ID)
        End Using

        If prestazione Is Nothing Then
            Throw New OrderEntryNotFoundException("prestazione", rigaRichiesta.Prestazione.Codice & " | " & _
                                                                    rigaRichiesta.SistemaErogante.Sistema.Codice & "|" & _
                                                                    rigaRichiesta.SistemaErogante.Azienda.Codice)
        End If

        ' Operazione OrderEntry
        Dim operazioneOrderEntry As String
        If String.IsNullOrEmpty(rigaRichiesta.OperazioneOrderEntry) Then

            operazioneOrderEntry = OperazioneRigaRichiestaOrderEntryEnum.IS.ToString()
            rigaRichiesta.OperazioneOrderEntry = operazioneOrderEntry
        Else

            operazioneOrderEntry = DirectCast([Enum].Parse(GetType(OperazioneRigaRichiestaOrderEntryEnum), rigaRichiesta.OperazioneOrderEntry), OperazioneRigaRichiestaOrderEntryEnum).ToString()
        End If

        ' Valori XML
        Dim operazioneRichiedente As String = DataContractSerializerHelper.GetXML(rigaRichiesta.OperazioneRichiedente)
        Dim consensi As String = DataContractSerializerHelper.GetXML(rigaRichiesta.Consensi)

        ' Insert della riga
        MsgOrdiniRigheRichiesteInsert(IDTicketInserimento:=ticket,
                                      IDOrdineTestata:=idOrdineTestata,
                                      StatoOrderEntry:=operazioneOrderEntry,
                                      IDPrestazione:=prestazione.ID,
                                      IDSistemaErogante:=sistemaErogante.ID,
                                      IDRigaOrderEntry:=rigaRichiesta.IdRigaOrderEntry,
                                      IDRigaRichiedente:=rigaRichiesta.IdRigaRichiedente,
                                      IDRigaErogante:=rigaRichiesta.IdRigaErogante,
                                      IDRichiestaErogante:=rigaRichiesta.IdRichiestaErogante,
                                      StatoRichiedente:=operazioneRichiedente,
                                      Consensi:=consensi)
        ' Return
        Return GetRigaRichiestaByRigaRichiedente(idOrdineTestata, rigaRichiesta.IdRigaRichiedente)
    End Function

    Private Function UpdateRigaRichiesta(ByVal ticket As Guid,
                                         ByVal idOrdineTestata As Guid,
                                         ByVal rigaRichiesta As QueueTypes.RigaRichiestaType) As OrdiniDS.RigaRichiestaRow

        DiagnosticsHelper.WriteDiagnostics("RichiestaAdapter.UpdateRigaRichiesta()")

        ' Get del sistema erogante
        Dim sistemaErogante As OrganigrammaDS.SistemaRow

        Using organigrammaAdapter As New OrganigrammaAdapter(Me.Connection.ConnectionString)
            sistemaErogante = organigrammaAdapter.GetSistemaByCodice(rigaRichiesta.SistemaErogante.Sistema.Codice, _
                                                                     rigaRichiesta.SistemaErogante.Azienda.Codice)
        End Using

        If sistemaErogante Is Nothing Then
            Throw New OrderEntryNotFoundException("sistema erogante", rigaRichiesta.SistemaErogante.Sistema.Codice & "|" & _
                                                                     rigaRichiesta.SistemaErogante.Azienda.Codice)
        End If

        ' Get della prestazione
        Dim prestazione As PrestazioniDS.PrestazioneRow

        Using prestazioneAdapter As New PrestazioneAdapter(Me.Connection, Me.Transaction, ConfigurationHelper.TransactionIsolationLevel)
            prestazione = prestazioneAdapter.GetBySistemaErogante(rigaRichiesta.Prestazione.Codice, sistemaErogante.ID)
        End Using

        If prestazione Is Nothing Then
            Throw New OrderEntryNotFoundException("prestazione", rigaRichiesta.Prestazione.Codice & " | " & _
                                                                    rigaRichiesta.SistemaErogante.Sistema.Codice & "|" & _
                                                                    rigaRichiesta.SistemaErogante.Azienda.Codice)
        End If

        ' Operazione OrderEntry
        Dim operazioneOrderEntry As String
        If String.IsNullOrEmpty(rigaRichiesta.OperazioneOrderEntry) Then

            operazioneOrderEntry = OperazioneRigaRichiestaOrderEntryEnum.MD.ToString()
            rigaRichiesta.OperazioneOrderEntry = operazioneOrderEntry
        Else

            operazioneOrderEntry = DirectCast([Enum].Parse(GetType(OperazioneRigaRichiestaOrderEntryEnum), rigaRichiesta.OperazioneOrderEntry), OperazioneRigaRichiestaOrderEntryEnum).ToString()
        End If

        ' Calcolo la data modifica stato
        Dim dataModificaStato As Nullable(Of DateTime) = Nothing
        Dim rigaCorrente = GetRigaRichiestaByRigaRichiedente(idOrdineTestata, rigaRichiesta.IdRigaRichiedente)

        If Not rigaCorrente.IsStatoOrderEntryNull() Then

            If DirectCast([Enum].Parse(GetType(OperazioneRigaRichiestaOrderEntryEnum), rigaCorrente.StatoOrderEntry), OperazioneRigaRichiestaOrderEntryEnum) <>
                DirectCast([Enum].Parse(GetType(OperazioneRigaRichiestaOrderEntryEnum), operazioneOrderEntry), OperazioneRigaRichiestaOrderEntryEnum) Then

                dataModificaStato = DateTime.Now
            Else

                If Not rigaCorrente.IsDataModificaStatoNull() Then
                    dataModificaStato = rigaCorrente.DataModificaStato
                End If
            End If
        End If

        ' Valori XML
        Dim operazioneRichiedente As String = DataContractSerializerHelper.GetXML(rigaRichiesta.OperazioneRichiedente)
        Dim consensi As String = DataContractSerializerHelper.GetXML(rigaRichiesta.Consensi)

        MsgOrdiniRigheRichiesteUpdate(IDTicketModifica:=ticket,
                                      IDOrdineTestata:=idOrdineTestata,
                                      IDRigaRichiedente:=rigaRichiesta.IdRigaRichiedente,
                                      StatoOrderEntry:=operazioneOrderEntry,
                                      DataModificaStato:=dataModificaStato,
                                      IDPrestazione:=prestazione.ID,
                                      IDSistemaErogante:=sistemaErogante.ID,
                                      IDRigaOrderEntry:=rigaRichiesta.IdRigaOrderEntry,
                                      IDRigaErogante:=rigaRichiesta.IdRigaErogante,
                                      IDRichiestaErogante:=rigaRichiesta.IdRichiestaErogante,
                                      StatoRichiedente:=operazioneRichiedente,
                                      Consensi:=consensi)

        Return GetRigaRichiestaByRigaRichiedente(idOrdineTestata, rigaRichiesta.IdRigaRichiedente)
    End Function

    Private Sub InsertRigheRichieste(ByVal ticket As Guid,
                                     ByVal idOrdineTestata As Guid,
                                     ByVal righeRichieste As QueueTypes.RigheRichiesteType)

        DiagnosticsHelper.WriteDiagnostics("RichiestaAdapter.InsertRigheRichieste()")

        If righeRichieste IsNot Nothing Then
            '
            ' IdRiga progressivo su tutte le righe
            '
            Dim iMaxIdRiga As Integer = 0

            For Each riga As QueueTypes.RigaRichiestaType In righeRichieste
                '
                ' Progressivo su IdRigaOrderEntry
                '
                iMaxIdRiga += 1
                riga.IdRigaOrderEntry = iMaxIdRiga.ToString()
                '
                ' Insert della riga
                '
                Dim rigaRichiesta As OrdiniDS.RigaRichiestaRow = InsertRigaRichiesta(ticket, idOrdineTestata, riga)
                '
                ' Save dei dati aggiuntivi
                '
                If rigaRichiesta IsNot Nothing AndAlso riga.DatiAggiuntivi IsNot Nothing Then
                    SaveRigaRichiestaDatiAggiuntivi(ticket, idOrdineTestata, rigaRichiesta.ID, riga.DatiAggiuntivi)
                End If
            Next
        End If

    End Sub

    <Obsolete("Usare SaveRigaRichiestaDatiAggiuntivi()")> _
    Private Sub MergeRigaRichiestaDatiAggiuntivi(ByVal ticket As Guid,
                                                 ByVal idOrdineTestata As Guid,
                                                 ByVal idRigaRichiesta As Guid,
                                                 ByVal datiAggiuntivi As QueueTypes.DatiAggiuntiviType)

        DiagnosticsHelper.WriteDiagnostics("RichiestaAdapter.MergeRigaRichiestaDatiAggiuntivi()")

        '
        ' Modifica (insert/update) dei dati aggiuntivi persistenti
        '
        If datiAggiuntivi IsNot Nothing Then
            For Each item As QueueTypes.DatoNomeValoreType In datiAggiuntivi
                If String.IsNullOrEmpty(item.TipoDato) Then
                    Throw New OrderEntryArgumentNullException("TipoDato")
                End If

                '
                ' Get del dato aggiuntivo
                '
                Dim datoAggiuntivo As OrdiniDS.RigaRichiestaDatoAggiuntivoRow = GetRigaRichiestaDatoAggiuntivoByIDDatoAggiuntivo(idRigaRichiesta, item.Id)

                If datoAggiuntivo Is Nothing Then
                    MsgOrdiniRigheRichiesteDatiAggiuntiviInsert(IDTicketInserimento:=ticket,
                                                                IDRigaRichiesta:=idRigaRichiesta,
                                                                IDDatoAggiuntivo:=item.Id,
                                                                Nome:=item.Nome,
                                                                TipoDato:=item.TipoDato,
                                                                TipoContenuto:=item.TipoContenuto,
                                                                ValoreDato:=item.ValoreDato,
                                                                ParametroSpecifico:=False,
                                                                Persistente:=False)
                Else
                    MsgOrdiniRigheRichiesteDatiAggiuntiviUpdate(ID:=datoAggiuntivo.ID,
                                                                IDTicketModifica:=ticket,
                                                                Nome:=item.Nome,
                                                                TipoDato:=item.TipoDato,
                                                                TipoContenuto:=item.TipoContenuto,
                                                                ValoreDato:=item.ValoreDato,
                                                                ParametroSpecifico:=False,
                                                                Persistente:=False)
                End If

            Next
        End If

    End Sub

    Private Sub SaveRigaRichiestaDatiAggiuntivi(ByVal ticket As Guid,
                                             ByVal idOrdineTestata As Guid,
                                             ByVal idRigaRichiesta As Guid,
                                             ByVal datiAggiuntivi As QueueTypes.DatiAggiuntiviType)

        DiagnosticsHelper.WriteDiagnostics("RichiestaAdapter.SaveRigaRichiestaDatiAggiuntivi()")

        ' DELETE dei dati aggiuntivi della riga
        MsgOrdiniRigheRichiesteDatiAggiuntiviDeleteByIDRigaRichiesta(idRigaRichiesta)

        ' Modifica (insert/update) dei dati aggiuntivi persistenti
        If datiAggiuntivi IsNot Nothing Then
            For Each item As QueueTypes.DatoNomeValoreType In datiAggiuntivi

                ' Controlla tipo dato
                If String.IsNullOrEmpty(item.TipoDato) Then
                    Throw New OrderEntryArgumentNullException("TipoDato")
                End If

                ' Aggiungo i dato aggiuntivo
                MsgOrdiniRigheRichiesteDatiAggiuntiviInsert(IDTicketInserimento:=ticket,
                                            IDRigaRichiesta:=idRigaRichiesta,
                                            IDDatoAggiuntivo:=item.Id,
                                            Nome:=item.Nome,
                                            TipoDato:=item.TipoDato,
                                            TipoContenuto:=item.TipoContenuto,
                                            ValoreDato:=item.ValoreDato,
                                            ParametroSpecifico:=False,
                                            Persistente:=False)
            Next
        End If
    End Sub

#End Region

#Region "Versione DB"

    Private Sub Versioning(ByVal ticket As Guid, ByVal idOrdineTestata As Guid, ByVal statoOrderEntry As String, data? As DateTime)
        DiagnosticsHelper.WriteDiagnostics("RichiestaAdapter.Versioning()")

        '
        ' VERSIONING dell'ordine
        '
        MsgOrdiniVersioniInsert(ticket, idOrdineTestata, statoOrderEntry.ToString, data)

    End Sub

    Public Function IsModified(ByRef richiesta As OrdiniDS.TestataRow) As Boolean

        DiagnosticsHelper.WriteDiagnostics("RichiestaAdapter.IsModified()")

        If Not richiesta.IsDatiRollbackNull() Then
            ' se ci sono dei dati di roolback è una variazione
            Return True
        Else
            Return False
        End If

    End Function


#End Region

#Region "Rollback applicativo asincrono"

    Private Function GetRichiestaByDatiRollback(ByVal datiRollback As String) As OrdiniTestate
        DiagnosticsHelper.WriteDiagnostics("RichiestaAdapter.GetRichiestaByDatiRollback()")

        ' Load dei dati di rollback
        Dim root As XElement = XElement.Parse(datiRollback)

        ' Testata
        Dim testata As New OrdiniTestate()
        testata.FillInstance(root)

        ' Testata dati aggiuntivi
        Dim testataDatiAggiuntivi As New EntitySet(Of OrdiniTestateDatiAggiuntivi)
        For Each datoAggiuntivo As XElement In (From datiAggiuntivi In root.<TestataDatiAggiuntivi>.<DatoAggiuntivo>
                                                Select datiAggiuntivi)

            Dim da As New OrdiniTestateDatiAggiuntivi()
            da.FillInstance(datoAggiuntivo)
            testataDatiAggiuntivi.Add(da)
        Next
        ' Add dati aggiuntivi
        testata.OrdiniTestateDatiAggiuntivis = testataDatiAggiuntivi

        ' Righe richieste
        Dim righeRichieste As New EntitySet(Of OrdiniRigheRichieste)
        For Each riga As XElement In (From righe In root.<RigheRichieste>.<RigaRichiesta>
                                      Select righe)

            ' Dati aggiuntivi
            Dim rigaRichiestaDatiAggiuntivi As New EntitySet(Of OrdiniRigheRichiesteDatiAggiuntivi)
            For Each datoAggiuntivo As XElement In (From datiAggiuntivi In riga.<RigaRichiestaDatiAggiuntivi>.<DatoAggiuntivo>
                                                    Select datiAggiuntivi)

                Dim da As New OrdiniRigheRichiesteDatiAggiuntivi()
                da.FillInstance(datoAggiuntivo)
                rigaRichiestaDatiAggiuntivi.Add(da)
            Next

            Dim rigaRichiesta As New OrdiniRigheRichieste()
            rigaRichiesta.FillInstance(riga)
            rigaRichiesta.OrdiniRigheRichiesteDatiAggiuntivis = rigaRichiestaDatiAggiuntivi
            righeRichieste.Add(rigaRichiesta)
        Next
        ' Add righe richieste
        testata.OrdiniRigheRichiestes = righeRichieste

        ' Return
        Return testata

    End Function

    Public Sub Rollback(ByRef richiesta As OrdiniDS.TestataRow)
        DiagnosticsHelper.WriteDiagnostics("RichiestaAdapter.Rollback()")

        Dim obj As OrdiniTestate = Nothing
        If Not richiesta.IsDatiRollbackNull() Then
            obj = GetRichiestaByDatiRollback(richiesta.DatiRollback)
        End If

        If obj Is Nothing Then
            Exit Sub
        End If

        ' Elimino: dati aggiuntivi di testata, righe richieste, dati aggiuntivi di riga, versione
        MsgRollbackOrdiniDeleteAll(richiesta.ID, richiesta.Data)

        ' Insert dati aggiuntivi di testata
        For Each item As OrdiniTestateDatiAggiuntivi In obj.OrdiniTestateDatiAggiuntivis
            MsgRollbackOrdiniTestateDatiAggiuntiviInsert(ID:=item.ID,
                                                         DataInserimento:=item.DataInserimento,
                                                         DataModifica:=item.DataModifica,
                                                         IDTicketInserimento:=item.IDTicketInserimento,
                                                         IDTicketModifica:=item.IDTicketModifica,
                                                         IDOrdineTestata:=item.IDOrdineTestata,
                                                         IDDatoAggiuntivo:=item.IDDatoAggiuntivo,
                                                         Nome:=item.Nome,
                                                         TipoDato:=item.TipoDato,
                                                         TipoContenuto:=item.TipoContenuto,
                                                         ValoreDato:=item.ValoreDato,
                                                         ValoreDatoVarchar:=item.ValoreDatoVarchar,
                                                         ValoreDatoXml:=GetFirstNodeToString(item.ValoreDatoXml),
                                                         ParametroSpecifico:=item.ParametroSpecifico,
                                                         Persistente:=item.Persistente)
        Next

        ' Insert righe richieste
        For Each item As OrdiniRigheRichieste In obj.OrdiniRigheRichiestes
            MsgRollbackOrdiniRigheRichiesteInsert(ID:=item.ID,
                                                  DataInserimento:=item.DataInserimento,
                                                  DataModifica:=item.DataModifica,
                                                  IDTicketInserimento:=item.IDTicketInserimento,
                                                  IDTicketModifica:=item.IDTicketModifica,
                                                  IDOrdineTestata:=item.IDOrdineTestata,
                                                  StatoOrderEntry:=item.StatoOrderEntry,
                                                  DataModificaStato:=item.DataModificaStato,
                                                  IDPrestazione:=item.IDPrestazione,
                                                  IDSistemaErogante:=item.IDSistemaErogante,
                                                  IDRigaOrderEntry:=item.IDRigaOrderEntry,
                                                  IDRigaRichiedente:=item.IDRigaRichiedente,
                                                  IDRigaErogante:=item.IDRigaErogante,
                                                  IDRichiestaErogante:=item.IDRichiestaErogante,
                                                  StatoRichiedente:=GetFirstNodeToString(item.StatoRichiedente),
                                                  Consensi:=item.Consensi.TryParseString())

            ' Insert dati aggiutivi di riga
            For Each innerItem As OrdiniRigheRichiesteDatiAggiuntivi In item.OrdiniRigheRichiesteDatiAggiuntivis
                MsgRollbackOrdiniRigheRichiesteDatiAggiuntiviInsert(ID:=innerItem.ID,
                                                                    DataInserimento:=innerItem.DataInserimento,
                                                                    DataModifica:=innerItem.DataModifica,
                                                                    IDTicketInserimento:=innerItem.IDTicketInserimento,
                                                                    IDTicketModifica:=innerItem.IDTicketModifica,
                                                                    IDRigaRichiesta:=innerItem.IDRigaRichiesta,
                                                                    IDDatoAggiuntivo:=innerItem.IDDatoAggiuntivo,
                                                                    Nome:=innerItem.Nome,
                                                                    TipoDato:=innerItem.TipoDato,
                                                                    TipoContenuto:=innerItem.TipoContenuto,
                                                                    ValoreDato:=innerItem.ValoreDato,
                                                                    ValoreDatoVarchar:=innerItem.ValoreDatoVarchar,
                                                                    ValoreDatoXml:=GetFirstNodeToString(innerItem.ValoreDatoXml),
                                                                    ParametroSpecifico:=innerItem.ParametroSpecifico,
                                                                    Persistente:=innerItem.Persistente)
            Next
        Next

        ' Update testata
        MsgRollbackOrdiniTestateUpdate(ID:=obj.ID,
                                       DataInserimento:=obj.DataInserimento,
                                       DataModifica:=obj.DataModifica,
                                       IDTicketInserimento:=obj.IDTicketInserimento,
                                       IDTicketModifica:=obj.IDTicketModifica,
                                       Anno:=obj.Anno,
                                       Numero:=obj.Numero,
                                       IDUnitaOperativaRichiedente:=obj.IDUnitaOperativaRichiedente,
                                       IDSistemaRichiedente:=obj.IDSistemaRichiedente,
                                       NumeroNosologico:=obj.NumeroNosologico,
                                       IDRichiestaRichiedente:=obj.IDRichiestaRichiedente,
                                       DataRichiesta:=obj.DataRichiesta,
                                       StatoOrderEntry:=obj.StatoOrderEntry,
                                       SottoStatoOrderEntry:=obj.SottoStatoOrderEntry,
                                       StatoRisposta:=obj.StatoRisposta,
                                       DataModificaStato:=obj.DataModificaStato,
                                       StatoRichiedente:=GetFirstNodeToString(obj.StatoRichiedente),
                                       Data:=obj.Data,
                                       Operatore:=GetFirstNodeToString(obj.Operatore),
                                       Priorita:=GetFirstNodeToString(obj.Priorita),
                                       TipoEpisodio:=GetFirstNodeToString(obj.TipoEpisodio),
                                       AnagraficaCodice:=obj.AnagraficaCodice,
                                       AnagraficaNome:=obj.AnagraficaNome,
                                       PazienteIdRichiedente:=obj.PazienteIdRichiedente,
                                       PazienteIdSac:=obj.PazienteIdSac,
                                       PazienteRegime:=obj.PazienteRegime,
                                       PazienteCognome:=obj.PazienteCognome,
                                       PazienteNome:=obj.PazienteNome,
                                       PazienteDataNascita:=obj.PazienteDataNascita,
                                       PazienteSesso:=obj.PazienteSesso,
                                       PazienteCodiceFiscale:=obj.PazienteCodiceFiscale,
                                       Paziente:=GetFirstNodeToString(obj.Paziente),
                                       Consensi:=GetFirstNodeToString(obj.Consensi),
                                       Note:=obj.Note,
                                       Regime:=GetFirstNodeToString(obj.Regime),
                                       DataPrenotazione:=obj.DataPrenotazione,
                                       StatoValidazione:=obj.StatoValidazione,
                                       Validazione:=GetFirstNodeToString(obj.Validazione),
                                       StatoTransazione:=obj.StatoTransazione,
                                       DataTransazione:=obj.DataTransazione)

    End Sub


#End Region

#Region "Utilita"

    Private Function ConcatIDs(items As List(Of Guid)) As String
        DiagnosticsHelper.WriteDiagnostics("RichiestaAdapter.ConcatIDs()")

        Dim sb As New StringBuilder()

        For Each item In items
            sb.Append(item.ToString())
            sb.Append(",")
        Next
        sb.Remove(sb.Length - 1, 1)

        Return sb.ToString()

    End Function

    Private Function GetFirstNodeToString(node As Xml.Linq.XElement) As String

        If node IsNot Nothing AndAlso node.HasElements Then
            Return node.FirstNode.ToString()
        Else
            Return Nothing
        End If

    End Function

#End Region

End Class