Imports System.Data.SqlClient
Imports OE.Core
Imports OE.Core.Schemas.Msg
Imports OE.Core.Schemas.Msg.QueueTypes

Friend Class StatoAdapter
    Inherits StatoDSTableAdapters.CommandsAdapter
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
        DiagnosticsHelper.WriteDiagnostics("StatoAdapter.SetCommandsConnection()")

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
        DiagnosticsHelper.WriteDiagnostics("StatoAdapter.BeginTransaction()")

        '
        ' Controllo se la connessione è aperta
        '
        If _connection.State = ConnectionState.Closed Then
            '
            ' Genero l'eccezione
            '
            Throw New Exception("Errore durante StatoAdapter.BeginTransaction(). La connessione al database è chiusa!")
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
        DiagnosticsHelper.WriteDiagnostics("StatoAdapter.Commit()")

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
        DiagnosticsHelper.WriteDiagnostics("StatoAdapter.Rollback()")

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
        DiagnosticsHelper.WriteDiagnostics("StatoAdapter.Disposed()")

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

        DiagnosticsHelper.WriteDiagnostics("StatoAdapter.New()")
        '
        ' Creo la connessione
        '
        If _connection Is Nothing Then
            _bCanDisposeConnection = True
            _connection = New SqlClient.SqlConnection(connectionString)
        End If
        '
        ' Setto su tutti i command sulla stessa connesione
        '
        SetCommandsConnection()

    End Sub

    Public Sub New(ByVal connection As SqlConnection, ByVal transaction As SqlTransaction, ByVal isolationLevel As IsolationLevel)
        MyBase.New()

        DiagnosticsHelper.WriteDiagnostics("StatoAdapter.New()")

        'Imposto connection e setto da non DISPOSE
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

#Region "Testata erogato"

    Private Function GetTestataById(ByVal Id As Guid) As StatoDS.TestataRow
        DiagnosticsHelper.WriteDiagnostics("StatoAdapter.GetTestataById()")

        Dim row As StatoDS.TestataRow = Nothing

        Using ta As New StatoDSTableAdapters.TestataTableAdapter()
            ta.Connection = Me._connection
            ta.Transaction = Me._transaction

            Dim dt As StatoDS.TestataDataTable = ta.GetDataByID(Id)
            If dt.Rows.Count > 0 Then
                row = dt.First
            End If
        End Using

        Return row

    End Function


    Private Function GetTestataByProtocolloIDSplit(ByVal anno As Integer, ByVal numero As Integer, idSplit As Byte?) As StatoDS.TestataRow
        DiagnosticsHelper.WriteDiagnostics("StatoAdapter.GetTestataByProtocolloIDSplit()")

        Dim row As StatoDS.TestataRow = Nothing

        Using ta As New StatoDSTableAdapters.TestataTableAdapter()
            ta.Connection = Me._connection
            ta.Transaction = Me._transaction

            Dim dt As StatoDS.TestataDataTable = ta.GetDataByProtocolloIDSplit(anno, numero, idSplit)
            If dt.Rows.Count > 0 Then
                row = dt.First()
            End If
        End Using

        Return row

    End Function

    Private Function GetTestateByProtocollo(ByVal anno As Integer, ByVal numero As Integer) As List(Of StatoDS.TestataRow)
        DiagnosticsHelper.WriteDiagnostics("StatoAdapter.GetTestateByProtocollo()")

        Dim rows As List(Of StatoDS.TestataRow) = Nothing

        Using ta As New StatoDSTableAdapters.TestataTableAdapter()
            ta.Connection = Me._connection
            ta.Transaction = Me._transaction

            Dim dt As StatoDS.TestataDataTable = ta.GetDataByProtocollo(anno, numero)
            If dt.Rows.Count > 0 Then
                rows = New List(Of StatoDS.TestataRow)
                rows.AddRange(dt.Rows.Cast(Of StatoDS.TestataRow))
            End If
        End Using

        Return rows

    End Function

    Private Function GetTestataByProtocolloOrdineSistemaErogante(ByVal anno As Integer, ByVal numero As Integer, idSistemaErogante As Guid) As StatoDS.TestataRow
        DiagnosticsHelper.WriteDiagnostics("StatoAdapter.GetTestataByProtocolloOrdineSistemaErogante()")

        Dim row As StatoDS.TestataRow = Nothing

        If Not Guid.Equals(idSistemaErogante, Guid.Empty) Then
            '
            ' Cerca testata
            '
            Using ta As New StatoDSTableAdapters.TestataTableAdapter()
                ta.Connection = Me._connection
                ta.Transaction = Me._transaction

                Dim dt As StatoDS.TestataDataTable = ta.GetDataByProtocolloOrdineSistemaErogante(anno, numero, idSistemaErogante)
                If dt.Rows.Count > 0 Then
                    row = dt.First()
                End If
            End Using
        End If

        Return row

    End Function

    Private Function GetTestataByIdTestataSistemaErogante(ByVal IdOrdineTestata As Guid, idSistemaErogante As Guid) As StatoDS.TestataRow
        DiagnosticsHelper.WriteDiagnostics("StatoAdapter.GetTestataByIdTestataSistemaErogante()")

        Dim row As StatoDS.TestataRow = Nothing

        If Not Guid.Equals(idSistemaErogante, Guid.Empty) Then
            '
            ' Cerca testata
            '
            Using ta As New StatoDSTableAdapters.TestataTableAdapter()
                ta.Connection = Me._connection
                ta.Transaction = Me._transaction

                Dim dt As StatoDS.TestataDataTable = ta.GetDataBySistemaEroganteIdOrdineTestata(idSistemaErogante, IdOrdineTestata)
                If dt.Rows.Count > 0 Then
                    row = dt.First()
                End If
            End Using
        End If

        Return row

    End Function

    Private Function GetTestata(ByVal testataStato As QueueTypes.TestataStatoType,
                            ByVal idSistemaErogante As Nullable(Of Guid),
                            ByVal testataRichiesta As OrdiniDS.TestataRow) As StatoDS.TestataRow

        DiagnosticsHelper.WriteDiagnostics("StatoAdapter.GetTestata()")

        ' Controllo parametri
        If testataStato Is Nothing Then
            Return Nothing
        End If

        If testataRichiesta Is Nothing Then
            Return Nothing
        End If

        Dim idRichiestaOrderEntry As String = testataStato.IdRichiestaOrderEntry
        '
        ' Cerco testa dell'erogante per @Split, 
        '
        Dim testataErogata As StatoDS.TestataRow = Nothing
        '
        ' 1. Cerco la testata erogata per IdSplit (@progressivo)
        '
        If Not String.IsNullOrEmpty(idRichiestaOrderEntry) AndAlso idRichiestaOrderEntry.Contains("@") Then

            Dim tmp As String() = idRichiestaOrderEntry.Split("@"c)
            Dim nSplit As Byte

            If Byte.TryParse(tmp(1), nSplit) Then
                testataErogata = GetTestataByProtocolloIDSplit(testataRichiesta.Anno, testataRichiesta.Numero, nSplit)
            End If
        End If
        '
        ' 2. Cerco la testata erogata per Anno + Numero + SistemaErogante
        '
        If (testataErogata Is Nothing) AndAlso idSistemaErogante.HasValue Then
            testataErogata = GetTestataByProtocolloOrdineSistemaErogante(testataRichiesta.Anno, testataRichiesta.Numero, idSistemaErogante.Value)
        End If
        '
        ' 3. Prendo la prima occorrenza trovata
        '
        '2018-11-09 Aggiunto controllo se IdSistemaErogante NULL (AndAlso Not idSistemaErogante.HasValue)
        '2019-01-16 Rimosso controllo se IdSistemaErogante NULL.
        '       Sistemi virtuali (LIB e RIS) inviano OSU da un SE diverso (LAB_0 | LAB_9) e se la testata è
        '       già presente DEVONO usarla a prescindere dal SE dichiarato.
        '       Altra soluzione potrebbe essere di configurare un SE alias per ricondurlo alla testata corretta
        '       Oppure da OSU non autocreare-SE e quindi considerarlo NULLO
        '
        If (testataErogata Is Nothing) Then

            Dim testateErogata As List(Of StatoDS.TestataRow) = GetTestateByProtocollo(testataRichiesta.Anno, testataRichiesta.Numero)
            If testateErogata IsNot Nothing AndAlso testateErogata.Count > 0 Then
                '
                '2018-11-09 Precedenza al IDSplit NULL
                '
                testataErogata = testateErogata.OrderBy(Function(e) If(e.IsIDSplitNull, 1, e.IDSplit)).First
            End If
        End If

        ' Return
        Return testataErogata

    End Function

    Private Function GetTestataDatoPersistenteByIDDatoAggiuntivo(ByVal idOrdineTestata As Guid,
                                                                ByVal idDatoAggiuntivo As String) As StatoDS.TestataDatoAggiuntivoRow

        DiagnosticsHelper.WriteDiagnostics("StatoAdapter.GetTestataDatoPersistenteByIDDatoAggiuntivo()")

        If Guid.Equals(idOrdineTestata, Guid.Empty) Then
            Throw New OrderEntryArgumentNullException("idOrdineTestata")
        End If

        Dim row As StatoDS.TestataDatoAggiuntivoRow = Nothing

        If Not String.IsNullOrEmpty(idDatoAggiuntivo) Then

            Using ta As New StatoDSTableAdapters.TestataDatoAggiuntivoTableAdapter()
                ta.Connection = Me._connection
                ta.Transaction = Me._transaction

                Dim dt As StatoDS.TestataDatoAggiuntivoDataTable = ta.GetDataByIDDatoAggiuntivo(idOrdineTestata, idDatoAggiuntivo, True)
                If dt.Rows.Count > 0 Then
                    row = dt.First
                End If
            End Using
        End If

        Return row

    End Function

    Private Function GetTestataDatiAggiuntivoByIDOrdineErogatoTestata(ByVal idOrdineErogatoTestata As Guid) As List(Of StatoDS.TestataDatoAggiuntivoRow)

        DiagnosticsHelper.WriteDiagnostics("StatoAdapter.GetTestataDatiAggiuntivoByIDOrdineErogatoTestata()")

        If Guid.Equals(idOrdineErogatoTestata, Guid.Empty) Then
            Throw New OrderEntryArgumentNullException("idOrdineErogatoTestata")
        End If

        Dim rows As List(Of StatoDS.TestataDatoAggiuntivoRow) = Nothing

        Using ta As New StatoDSTableAdapters.TestataDatoAggiuntivoTableAdapter()
            ta.Connection = Me._connection
            ta.Transaction = Me._transaction

            Dim dt As StatoDS.TestataDatoAggiuntivoDataTable = ta.GetDataByIdOrdineErogatoTestata(idOrdineErogatoTestata)
            If dt.Rows.Count > 0 Then
                rows = New List(Of StatoDS.TestataDatoAggiuntivoRow)
                rows.AddRange(dt.Rows.Cast(Of StatoDS.TestataDatoAggiuntivoRow))
            End If
        End Using

        Return rows

    End Function

#End Region

#Region "Righe erogate"

    Private Function GetRigaErogata(ByVal idOrdineErogatoTestata As Guid,
                                    ByVal idRigaRichiedente As String,
                                    ByVal idRigaErogante As String) As StatoDS.RigaErogataRow

        DiagnosticsHelper.WriteDiagnostics("StatoAdapter.GetRigaErogata()")

        If Guid.Equals(idOrdineErogatoTestata, Guid.Empty) Then
            Throw New OrderEntryArgumentNullException("idOrdineErogatoTestata")
        End If

        If String.IsNullOrEmpty(idRigaRichiedente) AndAlso String.IsNullOrEmpty(idRigaErogante) Then
            Return Nothing
        End If

        Dim row As StatoDS.RigaErogataRow = Nothing

        Using ta As New StatoDSTableAdapters.RigaErogataTableAdapter()
            ta.Connection = Me._connection
            ta.Transaction = Me._transaction

            Dim dt As StatoDS.RigaErogataDataTable = Nothing

            If Not String.IsNullOrEmpty(idRigaRichiedente) Then
                dt = ta.GetDataByRigaRichiedente(idOrdineErogatoTestata, idRigaRichiedente)
            ElseIf Not String.IsNullOrEmpty(idRigaErogante) Then
                dt = ta.GetDataByRigaErogante(idOrdineErogatoTestata, idRigaErogante)
            End If

            If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
                row = dt.First()
            End If
        End Using

        Return row

    End Function

    Private Function GetRigheErogate(ByVal idOrdineErogatoTestata As Guid) As StatoDS.RigaErogataDataTable

        DiagnosticsHelper.WriteDiagnostics("StatoAdapter.GetRigheErogate()")

        If Guid.Equals(idOrdineErogatoTestata, Guid.Empty) Then
            Throw New OrderEntryArgumentNullException("idOrdineErogatoTestata")
        End If

        Dim dt As StatoDS.RigaErogataDataTable = Nothing

        Using ta As New StatoDSTableAdapters.RigaErogataTableAdapter()
            ta.Connection = Me._connection
            ta.Transaction = Me._transaction

            dt = ta.GetData(idOrdineErogatoTestata)
        End Using

        Return dt

    End Function

    Private Function GetRigaErogataDatoAggiuntivoByIDDatoAggiuntivo(ByVal idRigaErogata As Guid,
                                                                    ByVal idDatoAggiuntivo As String) As StatoDS.RigaErogataDatoAggiuntivoRow

        DiagnosticsHelper.WriteDiagnostics("StatoAdapter.GetRigaErogataDatoAggiuntivoByIDDatoAggiuntivo()")

        If Guid.Equals(idRigaErogata, Guid.Empty) Then
            Throw New OrderEntryArgumentNullException("idRigaErogata")
        End If

        Dim row As StatoDS.RigaErogataDatoAggiuntivoRow = Nothing

        If Not String.IsNullOrEmpty(idDatoAggiuntivo) Then
            '
            ' Cerca per idDatoAggiuntivo
            '
            Using ta As New StatoDSTableAdapters.RigaErogataDatoAggiuntivoTableAdapter()
                ta.Connection = Me._connection
                ta.Transaction = Me._transaction

                Dim dt As StatoDS.RigaErogataDatoAggiuntivoDataTable =
                    ta.GetDataByIDDatoAggiuntivo(idRigaErogata, idDatoAggiuntivo)

                If dt.Rows.Count > 0 Then
                    row = dt.First()
                End If
            End Using
        End If

        Return row

    End Function

    Private Function GetRigaErogataDatiAggiuntivoByIDDatoAggiuntivo(ByVal idRigaErogata As Guid) As List(Of StatoDS.RigaErogataDatoAggiuntivoRow)

        DiagnosticsHelper.WriteDiagnostics("StatoAdapter.GetRigaErogataDatiAggiuntivoByIDDatoAggiuntivo()")

        If Guid.Equals(idRigaErogata, Guid.Empty) Then
            Throw New OrderEntryArgumentNullException("idRigaErogata")
        End If

        Dim rows As List(Of StatoDS.RigaErogataDatoAggiuntivoRow) = Nothing
        '
        ' Cerca per idDatoAggiuntivo
        '
        Using ta As New StatoDSTableAdapters.RigaErogataDatoAggiuntivoTableAdapter()
            ta.Connection = Me._connection
            ta.Transaction = Me._transaction

            Dim dt As StatoDS.RigaErogataDatoAggiuntivoDataTable = ta.GetDataByIDRigaErogata(idRigaErogata)
            If dt.Rows.Count > 0 Then
                rows = New List(Of StatoDS.RigaErogataDatoAggiuntivoRow)
                rows.AddRange(dt.Rows.Cast(Of StatoDS.RigaErogataDatoAggiuntivoRow))
            End If
        End Using

        Return rows

    End Function

    Private Function GetRigheErogateDatiAggiuntivoByIdOrdineErogatoTestata(ByVal IdOrdineErogatoTestata As Guid, IdDatoAggiuntivo As String) As List(Of StatoDS.RigaErogataDatoAggiuntivoRow)

        DiagnosticsHelper.WriteDiagnostics("StatoAdapter.GetRigheErogateDatiAggiuntivoByIdOrdineErogatoTestata()")

        If Guid.Equals(IdOrdineErogatoTestata, Guid.Empty) Then
            Throw New OrderEntryArgumentNullException("IdOrdineErogatoTestata")
        End If

        Dim rows As List(Of StatoDS.RigaErogataDatoAggiuntivoRow) = Nothing
        '
        ' Cerca per idDatoAggiuntivo
        '
        Using ta As New StatoDSTableAdapters.RigaErogataDatoAggiuntivoTableAdapter()
            ta.Connection = Me._connection
            ta.Transaction = Me._transaction

            Dim dt As StatoDS.RigaErogataDatoAggiuntivoDataTable = ta.GetDataByIdOrdineErogatoTestata(IdOrdineErogatoTestata, IdDatoAggiuntivo)
            If dt.Rows.Count > 0 Then
                rows = New List(Of StatoDS.RigaErogataDatoAggiuntivoRow)
                rows.AddRange(dt.Rows.Cast(Of StatoDS.RigaErogataDatoAggiuntivoRow))
            End If
        End Using

        Return rows

    End Function

#End Region

#Region "Consolida processa legge"

    Private Sub ConsolidaStato(ByRef obj As QueueTypes.TestataStatoType, ByVal testataRow As StatoDS.TestataRow)
        DiagnosticsHelper.WriteDiagnostics("StatoAdapter.ConsolidaStato()")

        ' Consolido la testata

        If testataRow IsNot Nothing AndAlso obj IsNot Nothing Then

            ' Se manca IdRichiestaOrderEntry lo compongo
            If String.IsNullOrEmpty(obj.IdRichiestaOrderEntry) Then
                obj.IdRichiestaOrderEntry = String.Concat(testataRow.Anno, "/", testataRow.Numero)
            End If

            ' Consolido il sistema richiedente, se null, prendendo il dato dal db
            If obj.SistemaRichiedente Is Nothing Then

                Using organigrammaAdapter As New OrganigrammaAdapter(Me.Connection.ConnectionString)

                    Dim sistema As OrganigrammaDS.SistemaRow = organigrammaAdapter.GetSistemaByID(testataRow.IDSistemaRichiedente)
                    If sistema IsNot Nothing Then
                        obj.SistemaRichiedente = sistema.ToSistemaType
                    End If
                End Using
            End If

            If String.IsNullOrEmpty(obj.IdRichiestaRichiedente) Then
                obj.IdRichiestaRichiedente = testataRow.IDRichiestaRichiedente
            End If

            If String.IsNullOrEmpty(obj.StatoOrderEntry) Then
                obj.StatoOrderEntry = If(testataRow.IsStatoOrderEntryNull, Nothing, testataRow.StatoOrderEntry)
            End If
        End If

    End Sub

    Public Function Elabora(ByVal ticket As Guid, ByVal obj As QueueTypes.StatoQueueType,
                            ByRef SendOSU As Boolean) As Guid?
        '
        ' Elabora il messaggio OSU o RR e aggiornai dati sul DB
        ' Se ritorna l'ID della testata dell'ordine, significa che il messaggo di OSU sarà da inviare nella coda di output
        '    altrimenti sarà solo processato. Il messaggi di OSU sarà poi riletto dal DB prima di essere inviato.
        '
        ' 2016-08-22 - Nessuan risposta RR ma convertire in OSU con queste regole:
        '   Inoltro        AA      -> genero OSU (Inotrato)
        '   Inoltro        AE o AR -> genero OSU (Errato)
        '   Inoltro        SE      -> genero OSU (SE)
        '   Cancallazione  AA      -> genero OSU (CA)
        '   Modifica       AE o AR -> nussuno OSU
        '   Cancellazione  AE o AR -> nussuno OSU
        '
        DiagnosticsHelper.WriteDiagnostics("StatoAdapter.Elabora()")

        'Praram OUTPUT Setto per default che OSU è da inviare
        SendOSU = True

        Dim bRichiestaMDoCA As Boolean = False
        Dim bOsuModificato As Boolean = False

        ' Non usa la transazione per evitare deadlock con il flusso RICHIESTRE e con i WS in lettura
        Using richiestaAdapter As New RichiestaAdapter(Me.Connection.ConnectionString)

            ' Consolido sistema erogante
            Dim sistemaErogante As OrganigrammaDS.SistemaRow
            Dim sistemaRichiedente As OrganigrammaDS.SistemaRow

            Dim idSistemaRichiedente As Nullable(Of Guid) = Nothing

            Using organigrammaAdapter As New OrganigrammaAdapter(Me.Connection.ConnectionString)

                ' Consolido sistema erogante
                sistemaErogante = organigrammaAdapter.ConsolidaSistema(obj.Testata.SistemaErogante, True, False)

                If sistemaErogante Is Nothing Then
                    Throw New OrderEntryNotFoundException("Sistema erogante riga erogata non trovato.",
                                  String.Format("Sistema={0}, Azienda={1}",
                                                obj.Testata.SistemaErogante.Sistema.Codice, obj.Testata.SistemaErogante.Azienda.Codice))

                End If

                ' Consolido sistema richiedente se c'è
                If obj.Testata.SistemaRichiedente IsNot Nothing AndAlso
                        Not String.IsNullOrEmpty(obj.Testata.SistemaRichiedente.Azienda.Codice) AndAlso
                        Not String.IsNullOrEmpty(obj.Testata.SistemaRichiedente.Sistema.Codice) Then

                    sistemaRichiedente = organigrammaAdapter.ConsolidaSistema(obj.Testata.SistemaRichiedente, True, False)
                    If sistemaRichiedente IsNot Nothing Then
                        idSistemaRichiedente = sistemaRichiedente.ID
                    End If
                End If
            End Using

            ' Conrollo se esiste la testata d'ordine (richiesta)
            Dim idOrdineTestata As Nullable(Of Guid)
            Dim richiesta As OrdiniDS.TestataRow = richiestaAdapter.GetTestata(obj.Testata.IdRichiestaOrderEntry,
                                                                               idSistemaRichiedente,
                                                                               obj.Testata.IdRichiestaRichiedente)
            If richiesta IsNot Nothing Then
                idOrdineTestata = richiesta.ID
            Else
                '
                ' Nessun ordine non salvo lo stato
                '
                Return Nothing
            End If

            '------------------------------------------------------------------------------
            ' Elaboro testata erogante

            ' Controllo se esiste la testata d'ordine erogato
            Dim testata As StatoDS.TestataRow = GetTestata(obj.Testata, sistemaErogante.ID, richiesta)
            '
            ' Se il messaggio è RR, controllo di versione tramite le date
            '
            If obj.TipoStato = QueueTypes.TipoStatoType.RR Then
                If Not richiesta.IsDataNull() AndAlso obj.Testata.Data IsNot Nothing Then

                    Dim dtDataRichiesta As DateTime = richiesta.Data
                    If dtDataRichiesta.Subtract(obj.Testata.Data.Value).TotalSeconds > 1 Then
                        ' mismatch
                        Throw New OrderEntryDataVersioneMismatchException(String.Concat("Numero Ordine OE = ", richiesta.Anno, "/", richiesta.Numero, " - Data = ", richiesta.Data),
                                                                          String.Concat("Data = ", obj.Testata.Data))
                    End If
                End If
            End If

            ' Get stato o.e. via TipoStato
            Dim statoOrderEntry As String = Nothing
            Dim sottoStatoOrderEntry As String = Nothing
            Dim statoRisposta As String = Nothing

            StatoHelper.GetStatiTestataStato(obj, testata, richiesta, statoOrderEntry, sottoStatoOrderEntry, statoRisposta)

            If testata Is Nothing Then
                '
                ' Normalmente è già stata creata durante la richiesta
                '
                '
                ' TODO: Non gestisce bene ID SPLIT lo lascia NULL
                '
                InsertTestata(ticket,
                                idOrdineTestata,
                                idSistemaRichiedente,
                                sistemaErogante.ID,
                                statoOrderEntry,
                                sottoStatoOrderEntry,
                                statoRisposta,
                                obj.Testata,
                                Nothing)

                testata = GetTestata(obj.Testata, sistemaErogante.ID, richiesta)

                ' 2018-11-09
                ' Se non ho dati notifico
                '
                bRichiestaMDoCA = True
                bOsuModificato = True

            Else
                ' 2018-11-09
                ' Controlla se è arrivata un messaggio richiesta dopo l'ultimo stato
                '
                If Not bRichiestaMDoCA Then

                    If Not richiesta.IsDataNull() AndAlso Not testata.IsDataNull() Then
                        Dim dtDataUltimaRichiesta As DateTime = richiesta.Data
                        Dim dtDataUltimoStato As DateTime = testata.Data

                        If dtDataUltimaRichiesta.Subtract(dtDataUltimoStato).TotalSeconds > 1 Then
                            bRichiestaMDoCA = True
                        End If
                    Else
                        bRichiestaMDoCA = False
                    End If

                End If

                ' 2018-11-09
                ' Controlla modifica a RR
                '
                If Not bRichiestaMDoCA AndAlso obj.TipoStato = QueueTypes.TipoStatoType.RR Then

                    If testata.IsStatoRispostaNull() Then
                        '
                        ' Ultimo StatoRisposta NULL
                        '
                        bRichiestaMDoCA = True

                    ElseIf testata.StatoRisposta <> obj.Testata.StatoOrderEntry.ToString Then
                        '
                        ' Ultmo StatoRisposta diverso
                        '
                        bRichiestaMDoCA = True

                    ElseIf Not testata.IsDataNull() AndAlso obj.Testata.Data.HasValue Then
                        '
                        ' Data STATO del MSG > della data su DB
                        '
                        Dim dtDataStato As DateTime = obj.Testata.Data.Value
                        Dim dtDataUltimoStato As DateTime = testata.Data

                        If dtDataStato.Subtract(dtDataUltimoStato).TotalSeconds > 1 Then
                            bRichiestaMDoCA = True
                        End If

                    ElseIf richiesta.StatoOrderEntry = OperazioneTestataRichiestaOrderEntryEnum.CA.ToString Then
                        '
                        ' Era un a cancellazione (Per compatibilità, da valutare)
                        '
                        bRichiestaMDoCA = True
                    End If

                End If
                '
                ' Valutazione se OSU con modifiche alla testata
                '
                If Not bOsuModificato AndAlso obj.TipoStato = QueueTypes.TipoStatoType.OSU Then

                    bOsuModificato = CompareTestataOSU(obj, testata)
                End If

                'Salva la vecchia versione e Aggiorna i nuovi dati
                Versioning(ticket, testata.ID, If(testata.IsStatoOrderEntryNull, Nothing, testata.StatoOrderEntry))

                UpdateTestata(ticket,
                                testata.ID,
                                testata.IDOrdineTestata,
                                idSistemaRichiedente,
                                sistemaErogante.ID,
                                statoOrderEntry,
                                sottoStatoOrderEntry,
                                statoRisposta,
                                testata,
                                obj.TipoStato,
                                obj.Testata)
            End If

            If testata Is Nothing Then
                Throw New OrderEntryNotFoundException("Testata ordine erogato non trovato.",
                                                      String.Format("IdRichiestaOrderEntry={0}, CodiceSistemaErogante={1}",
                                                                    obj.Testata.IdRichiestaOrderEntry, obj.Testata.SistemaErogante.Sistema.Codice))
            End If

            'Se RR di tipo AA, cancello i dati persistenti prima di salvare i nuovi
            If obj.TipoStato = QueueTypes.TipoStatoType.RR AndAlso statoRisposta = StatiOrderEntry.Risposta.AA.ToString Then

                ' Delete dei dati persistenti
                MsgOrdiniErogatiTestateDatiPersistentiDeleteByIDOrdineErogato(idOrdineTestata)
            End If

            ' Save dei dati aggiuntivi e Merge dati persistenti
            SaveTestataDatiAggiuntivi(ticket, testata.ID, obj.Testata.DatiAggiuntivi, obj.TipoOperazione)
            MergeTestataDatiPersistenti(ticket, testata.ID, obj.Testata.DatiPersistenti, obj.TipoOperazione)

            '------------------------------------------------------------------------------
            ' Elaboro righe erogate

            ' Se il TipoStato è RR (Richiesta Risposta) controllo se errore per rollback
            ' Se il TipoStato è OSU (Order Status Update) aggiorno testata
            If obj.TipoStato = QueueTypes.TipoStatoType.RR Then

                ' Se c'è lo statoRisposta aggiorno testato richiesta ed erogati
                If Not String.IsNullOrEmpty(statoRisposta) Then

                    ' Se la richiesta è in uno stato o.e. uguale a CA e se sto elaborando un RR con stato o.e. uguale AA marco le righe erogate come CA
                    If statoRisposta = StatiOrderEntry.Risposta.AA.ToString AndAlso
                                                    (richiesta IsNot Nothing AndAlso
                                                     richiesta.StatoOrderEntry = OperazioneTestataRichiestaOrderEntryEnum.CA.ToString) Then
                        ' righe erogate set a CA
                        MsgOrdiniRigheErogateUpdateStatoByIDOrdineErogato(ticket, testata.ID, StatoRigaErogataOrderEntryEnum.CA.ToString(), DateTime.Now)

                        ' Calcolo data di modifica
                        Dim dataModificaStato As Nullable(Of DateTime) = GetDataModficaStatoTestata(StatoTestataErogatoOrderEntryEnum.CA.ToString(), testata)

                        ' Aggiorno stato testata erogata (se statoOrderEntry è NULL calcola lo stato sulle righe erogate)
                        MsgOrdiniErogatiTestateStatusUpdate(ticket, testata.ID, StatoTestataErogatoOrderEntryEnum.CA.ToString(), dataModificaStato)
                    End If

                    ' La richiesta risposta non contiene errori elimino i dati di rollback
                    ' Rimosso cancellazione DeleteRollback per problemi di LOCK. Gestire la rimozione dei dati in modalità batch

                    ' Rollback della richiesta se la richiesta risposta contiene errore
                    If (statoRisposta = StatiOrderEntry.Risposta.AE.ToString _
                                         OrElse statoRisposta = StatiOrderEntry.Risposta.AR.ToString) Then

                        If richiesta IsNot Nothing Then
                            richiestaAdapter.Rollback(richiesta)
                        End If
                    End If

                    ' Ritorno nello stato lo STATO RISPOSTA (AE o AR), invece che lo stato OE
                    obj.Testata.StatoOrderEntry = statoRisposta
                End If

            ElseIf obj.TipoStato = QueueTypes.TipoStatoType.OSU Then

                '---------------------------------------------------
                ' Spostato dentro a IF OSU il 23/08/2016
                ' Prima il controllo delle righe anche in RR, non dovrebbe servire

                'La lista delle righe correnti sul DB
                Dim dtRigheErogateCorrenti As StatoDS.RigaErogataDataTable = GetRigheErogate(testata.ID)

                ' Valutazione se OSU con modifiche alle righe
                If Not bOsuModificato Then

                    'Tutti i dati aggiuntivi di tutte le righe di tipo CORE_DataPianificata (ID=00000001-0000-0000-0000-111111111111)
                    Dim daDataPianificata As List(Of StatoDS.RigaErogataDatoAggiuntivoRow)
                    daDataPianificata = GetRigheErogateDatiAggiuntivoByIdOrdineErogatoTestata(testata.ID, DatiAggiuntivi.ID_DATA_PIANIFICATA)

                    bOsuModificato = CompareRigheOSU(obj, dtRigheErogateCorrenti, daDataPianificata)
                End If

                ' Merge righe erogate sul DB e Consolida dati (obj.Testata.RigheErogate)
                Dim adrRigheErogateNuove As StatoDS.RigaErogataRow()

                adrRigheErogateNuove = MergeRigheErogate(ticket, testata.ID, sistemaErogante.ID, obj.Testata.RigheErogate, obj.TipoOperazione, obj.TipoStato, dtRigheErogateCorrenti)
                If adrRigheErogateNuove IsNot Nothing Then

                    ' Ricalcolo lo statoOrderEntry della testata erogata
                    statoOrderEntry = StatoHelper.GetStatoOrderEntryTestataStato(statoOrderEntry, adrRigheErogateNuove)
                End If

                ' Spostato dentro a IF OSU il 23/08/2016
                '---------------------------------------------------

                ' Calcolo data di modifica
                Dim dataModificaStato As Nullable(Of DateTime) = GetDataModficaStatoTestata(statoOrderEntry, testata)

                ' Aggiorno stato testata erogata (se statoOrderEntry è NULL calcola lo stato sulle righe erogate)
                MsgOrdiniErogatiTestateStatusUpdate(ticket, testata.ID, statoOrderEntry, dataModificaStato)

                ' Se vuoto valorizzo con campo calcolato
                If String.IsNullOrEmpty(obj.Testata.StatoOrderEntry) Then
                    obj.Testata.StatoOrderEntry = statoOrderEntry
                End If
            End If

            ' Consolido lo stato, per compatibilità ma non dovrebbe servire visto che rileggiamo dal DB
            ConsolidaStato(obj.Testata, testata)

            '-------------------------------------------------------------------------------
            ' Controllo se inviare il messaggio OSU nella coda

            ' SE Risposta RR controllo se OSU da inviare
            If obj.TipoStato = QueueTypes.TipoStatoType.RR Then

                ' Se OPERARIONE richiesta è Modifica oppure CA
                If bRichiestaMDoCA Then

                    ' Se ERRORE durante RR nello StatoOrderEntry c'è AE o AR
                    If (obj.Testata.StatoOrderEntry = StatiOrderEntry.Risposta.AE.ToString _
                            OrElse obj.Testata.StatoOrderEntry = StatiOrderEntry.Risposta.AR.ToString) Then

                        'Non invio l'OSU in output se ERRORE di modifica
                        SendOSU = False
                    Else
                        SendOSU = True
                    End If
                Else
                    ' Non invio l'OSU in output
                    SendOSU = False
                End If

            ElseIf obj.TipoStato = QueueTypes.TipoStatoType.OSU Then
                '
                ' Messaggio Osu, controllo se inviare
                '
                If bOsuModificato Then
                    '
                    ' Ci sono variazioni significative
                    '
                    SendOSU = True

                ElseIf bRichiestaMDoCA Then
                    '
                    ' Possibile arrivo di richiesta il primo osu è da reinviare
                    '
                    SendOSU = True
                Else
                    '
                    ' Non invio l'OSU in output
                    '
                    SendOSU = False
                End If

            End If

            Return testata.ID

        End Using

    End Function

    Public Function Legge(ByVal idRichiestaOrderEntry As String) As List(Of QueueTypes.TestataStatoType)

        DiagnosticsHelper.WriteDiagnostics("StatoAdapter.Legge()")

        Dim returnType As List(Of QueueTypes.TestataStatoType) = Nothing
        Dim testateRow As List(Of StatoDS.TestataRow) = Nothing

        ' Cerco la testata dell'ordine
        If Not String.IsNullOrEmpty(idRichiestaOrderEntry) AndAlso idRichiestaOrderEntry.Contains("/") Then

            Dim protocollo As String() = idRichiestaOrderEntry.Split("/"c)
            Dim anno, numero As Integer

            If Integer.TryParse(protocollo(0), anno) AndAlso Integer.TryParse(protocollo(1), numero) Then
                ' Cerco per Anno e Numero
                testateRow = GetTestateByProtocollo(anno, numero)
            End If
        End If

        'Se ci sono le leggo tutte
        If testateRow IsNot Nothing AndAlso testateRow.Count > 0 Then

            'Crea nodo per i dati da ritornare delle testate
            returnType = New List(Of QueueTypes.TestataStatoType)

            For Each testataRow As StatoDS.TestataRow In testateRow
                '
                ' 2019-01-21 In errore serializzazione se manca Codice Stato Erogante
                '           Succede se non è ancora arrivato ne un RR ne un OSU
                '               Corretta FUNCTION [dbo].[GetMsgDescrizioneStatoRichiesta]
                '               Corretta FUNCTION [dbo].[GetMsgDescrizioneStatoErogato]
                '
                Dim testataStato As QueueTypes.TestataStatoType
                testataStato = GetTestataStatoType(testataRow)

                'Aggiungo al return
                returnType.Add(testataStato)
            Next
        End If

        Return returnType

    End Function


    Public Function LeggeTestataStato(ByVal idOrdineErogatoTestata As Guid) As QueueTypes.TestataStatoType

        DiagnosticsHelper.WriteDiagnostics("StatoAdapter.LeggeTestataStato()")

        Dim testataStato As QueueTypes.TestataStatoType
        Dim testataRow As StatoDS.TestataRow = GetTestataById(idOrdineErogatoTestata)

        testataStato = GetTestataStatoType(testataRow)
        Return testataStato

    End Function


    Private Function GetTestataStatoType(ByVal TestataRow As StatoDS.TestataRow) As QueueTypes.TestataStatoType

        Dim idOrdineErogatoTestata As Guid = TestataRow.ID

        'Leggo dati aggiuntivi e persistenti della testata
        Dim testataDatiAggiuntiviRow As List(Of StatoDS.TestataDatoAggiuntivoRow)
        testataDatiAggiuntiviRow = GetTestataDatiAggiuntivoByIDOrdineErogatoTestata(idOrdineErogatoTestata)

        'Creo nodo dati aggiuntivi
        Dim testataDatiAggiuntivi As QueueTypes.DatiAggiuntiviType = Nothing
        Dim testataDatiPersistenti As QueueTypes.DatiPersistentiType = Nothing

        If testataDatiAggiuntiviRow IsNot Nothing AndAlso testataDatiAggiuntiviRow.Count > 0 Then
            testataDatiAggiuntivi = testataDatiAggiuntiviRow.ToTestataDatiAggiuntiviType
            testataDatiPersistenti = testataDatiAggiuntiviRow.ToTestataDatiPersistentiType
        End If

        'Creo nodo testata
        Dim testataStato As QueueTypes.TestataStatoType
        testataStato = TestataRow.ToTestataStatoType(testataDatiAggiuntivi, testataDatiPersistenti)

        ' Cerco le righe dell'ordine
        Dim dtRigheErogate As StatoDS.RigaErogataDataTable
        dtRigheErogate = GetRigheErogate(idOrdineErogatoTestata)

        If dtRigheErogate IsNot Nothing AndAlso dtRigheErogate.Count > 0 Then
            'Creo nodo righe richieste
            testataStato.RigheErogate = New QueueTypes.RigheErogateType

            For Each rigaErogataRow In dtRigheErogate

                'Leggo dati aggiuntivi della riga
                Dim rigaErogataDatiAggiuntiviRow As List(Of StatoDS.RigaErogataDatoAggiuntivoRow)
                rigaErogataDatiAggiuntiviRow = GetRigaErogataDatiAggiuntivoByIDDatoAggiuntivo(rigaErogataRow.ID)

                'Creo nodo dati aggiuntivi
                Dim rigaErogataDatiAggiuntivi As QueueTypes.DatiAggiuntiviType = Nothing

                If rigaErogataDatiAggiuntiviRow IsNot Nothing AndAlso rigaErogataDatiAggiuntiviRow.Count > 0 Then
                    rigaErogataDatiAggiuntivi = rigaErogataDatiAggiuntiviRow.ToRigaErogataDatiAggiuntiviType
                End If

                'Creo il nodo della riga e aggiungo
                Dim rigaErogata = rigaErogataRow.ToRigaErogataType(rigaErogataDatiAggiuntivi)
                testataStato.RigheErogate.Add(rigaErogata)
            Next
        End If

        Return testataStato

    End Function


    Public Function LeggeSistemaEroganteIdSplit(ByVal idRichiestaOrderEntry As String) As Dictionary(Of Guid, Byte?)

        DiagnosticsHelper.WriteDiagnostics("StatoAdapter.LeggeSistemaEroganteIdSplit()")

        Dim result As Dictionary(Of Guid, Byte?) = Nothing

        Dim testateRow As List(Of StatoDS.TestataRow) = Nothing

        ' Cerco le testata dell'ordine
        If Not String.IsNullOrEmpty(idRichiestaOrderEntry) AndAlso idRichiestaOrderEntry.Contains("/") Then

            Dim protocollo As String() = idRichiestaOrderEntry.Split("/"c)
            Dim anno, numero As Integer

            If Integer.TryParse(protocollo(0), anno) AndAlso Integer.TryParse(protocollo(1), numero) Then
                ' Cerco per Anno e Numero
                testateRow = GetTestateByProtocollo(anno, numero)
            End If
        End If

        'Se ci sono le leggo tutte
        If testateRow IsNot Nothing AndAlso testateRow.Count > 0 Then

            result = New Dictionary(Of Guid, Byte?)
            For Each rowTestata In testateRow

                If rowTestata.IsIDSplitNull Then
                    result.Add(rowTestata.IDSistemaErogante, Nothing)
                Else
                    result.Add(rowTestata.IDSistemaErogante, rowTestata.IDSplit)
                End If
            Next

        End If

        Return result

    End Function


#End Region

#Region "Testata erogato DB"

    Public Sub PreparaTestata(ByVal ticket As Guid,
                              ByVal idOrdinteTestata As Guid,
                              ByVal idSistemaRichiedente As Guid,
                              ByVal idRichiestaRichiedente As String,
                              ByVal idSistemaErogante As Guid,
                              ByVal idSplit As Byte?)

        DiagnosticsHelper.WriteDiagnostics("StatoAdapter.ElaboraTestata()")

        Dim testata As StatoDS.TestataRow = Nothing

        testata = GetTestataByIdTestataSistemaErogante(idOrdinteTestata, idSistemaErogante)
        If testata Is Nothing Then
            '
            ' Creo testa erogato se non esiste
            '
            InsertTestata(ticket,
                            idOrdinteTestata,
                            idSistemaRichiedente,
                            idRichiestaRichiedente,
                            idSistemaErogante,
                            idSplit)
        End If

    End Sub

    Private Sub InsertTestata(ByVal ticket As Guid,
                                   ByVal idOrdineTestata As Nullable(Of Guid),
                                   ByVal idSistemaRichiedente As Nullable(Of Guid),
                                   ByVal idRichiestaRichiedente As String,
                                   ByVal idSistemaErogante As Guid,
                                   ByRef idSplit As Byte?)

        DiagnosticsHelper.WriteDiagnostics("StatoAdapter.InsertTestata()")

        MsgOrdiniErogatiTestateInsert(IDTicketInserimento:=ticket,
                                      IDOrdineTestata:=idOrdineTestata,
                                      IDSistemaRichiedente:=idSistemaRichiedente,
                                      IDRichiestaRichiedente:=idRichiestaRichiedente,
                                      IDSistemaErogante:=idSistemaErogante,
                                      IDRichiestaErogante:=Nothing,
                                      StatoOrderEntry:=Nothing,
                                      SottoStatoOrderEntry:=Nothing,
                                      StatoRisposta:=Nothing,
                                      DataModificaStato:=Nothing,
                                      StatoErogante:=Nothing,
                                      Data:=Nothing,
                                      Operatore:=Nothing,
                                      AnagraficaCodice:=Nothing,
                                      AnagraficaNome:=Nothing,
                                      PazienteIdRichiedente:=Nothing,
                                      PazienteIdSac:=Nothing,
                                      PazienteCognome:=Nothing,
                                      PazienteNome:=Nothing,
                                      PazienteDataNascita:=Nothing,
                                      PazienteSesso:=Nothing,
                                      PazienteCodiceFiscale:=Nothing,
                                      Paziente:=Nothing,
                                      Consensi:=Nothing,
                                      Note:=Nothing,
                                      DataPrenotazione:=Nothing,
                                      IDSplit:=idSplit)

    End Sub

    Private Sub InsertTestata(ByVal ticket As Guid,
                                   ByVal idOrdineTestata As Nullable(Of Guid),
                                   ByVal idSistemaRichiedente As Nullable(Of Guid),
                                   ByVal idSistemaErogante As Guid,
                                   ByVal statoOrderEntry As String,
                                   ByVal sottoStatoOrderEntry As String,
                                   ByVal statoRisposta As String,
                                   ByVal obj As QueueTypes.TestataStatoType,
                                   ByRef idSplit As Byte?)

        DiagnosticsHelper.WriteDiagnostics("StatoAdapter.InsertTestata()")

        ' Calcolo la data modifica stato
        Dim dataModificaStato As Nullable(Of DateTime) = Nothing
        If Not String.IsNullOrEmpty(statoOrderEntry) Then
            dataModificaStato = DateTime.Now
        End If

        ' Valori XML
        Dim statoErogante As String = DataContractSerializerHelper.GetXML(obj.StatoErogante)
        Dim operatore As String = DataContractSerializerHelper.GetXML(obj.Operatore)
        Dim pazienteXML As String = DataContractSerializerHelper.GetXML(obj.Paziente)
        Dim consensi As String = DataContractSerializerHelper.GetXML(obj.Consensi)

        Dim paziente As QueueTypes.PazienteType = obj.Paziente.GetInstance
        Dim idSac As Nullable(Of Guid) = paziente.IdSac.ParseGuid("Paziente.IdSac")

        'Nello schema di BT dataPrenotazione non è nillable e potrebbe arrivare la data minima invece di NOTHING
        Dim dataPrenotazione As DateTime? = Nothing
        If obj.DataPrenotazione.HasValue Then
            If DateDiff(DateInterval.Day, DateTime.MinValue, obj.DataPrenotazione.Value) <> 0 Then
                dataPrenotazione = obj.DataPrenotazione
            End If
        End If

        MsgOrdiniErogatiTestateInsert(IDTicketInserimento:=ticket,
                                      IDOrdineTestata:=idOrdineTestata,
                                      IDSistemaRichiedente:=idSistemaRichiedente,
                                      IDRichiestaRichiedente:=obj.IdRichiestaRichiedente,
                                      IDSistemaErogante:=idSistemaErogante,
                                      IDRichiestaErogante:=obj.IdRichiestaErogante,
                                      StatoOrderEntry:=statoOrderEntry,
                                      SottoStatoOrderEntry:=sottoStatoOrderEntry,
                                      StatoRisposta:=statoRisposta,
                                      DataModificaStato:=dataModificaStato,
                                      StatoErogante:=statoErogante,
                                      Data:=obj.Data,
                                      Operatore:=operatore,
                                      AnagraficaCodice:=paziente.AnagraficaCodice,
                                      AnagraficaNome:=paziente.AnagraficaNome,
                                      PazienteIdRichiedente:=paziente.IdRichiedente,
                                      PazienteIdSac:=idSac,
                                      PazienteCognome:=paziente.Cognome,
                                      PazienteNome:=paziente.Nome,
                                      PazienteDataNascita:=paziente.DataNascita,
                                      PazienteSesso:=paziente.Sesso,
                                      PazienteCodiceFiscale:=paziente.CodiceFiscale,
                                      Paziente:=pazienteXML,
                                      Consensi:=consensi,
                                      Note:=obj.Note,
                                      DataPrenotazione:=dataPrenotazione,
                                      IDSplit:=idSplit)


    End Sub


    Private Sub UpdateTestata(ByVal ticket As Guid, testata As StatoDS.TestataRow,
                                    ByVal idOrdineTestata As Guid,
                                    ByVal idSistemaRichiedente As Guid,
                                    ByVal idRichiestaRichiedente As String,
                                    ByVal idSistemaErogante As Guid)

        DiagnosticsHelper.WriteDiagnostics("StatoAdapter.UpdateTestata(ticket, testata)")

        MsgOrdiniErogatiTestateUpdate(ID:=testata.ID,
                                      IDTicketModifica:=ticket,
                                      IDOrdineTestata:=idOrdineTestata,
                                      IDSistemaRichiedente:=idSistemaRichiedente,
                                      IDRichiestaRichiedente:=idRichiestaRichiedente,
                                      IDSistemaErogante:=idSistemaErogante,
                                      IDRichiestaErogante:=testata.IDRichiestaErogante,
                                      StatoOrderEntry:=testata.StatoOrderEntry,
                                      SottoStatoOrderEntry:=testata.SottoStatoOrderEntry,
                                      StatoRisposta:=testata.StatoRisposta,
                                      DataModificaStato:=testata.DataModificaStato,
                                      StatoErogante:=testata.StatoErogante,
                                      Data:=testata.Data,
                                      Operatore:=testata.Operatore,
                                      AnagraficaCodice:=testata.AnagraficaCodice,
                                      AnagraficaNome:=testata.AnagraficaNome,
                                      PazienteIdRichiedente:=testata.PazienteIdRichiedente,
                                      PazienteIdSac:=testata.PazienteIdSac,
                                      PazienteCognome:=testata.PazienteCognome,
                                      PazienteNome:=testata.PazienteNome,
                                      PazienteDataNascita:=testata.PazienteDataNascita,
                                      PazienteSesso:=testata.PazienteSesso,
                                      PazienteCodiceFiscale:=testata.PazienteCodiceFiscale,
                                      Paziente:=testata.Paziente,
                                      Consensi:=testata.Consensi,
                                      Note:=testata.Note,
                                      DataPrenotazione:=testata.DataPrenotazione)

    End Sub

    Private Sub UpdateTestata(ByVal ticket As Guid,
                                   ByVal id As Guid,
                                   ByVal idOrdineTestata As Nullable(Of Guid),
                                   ByVal idSistemaRichiedente As Nullable(Of Guid),
                                   ByVal idSistemaErogante As Guid,
                                   ByVal statoOrderEntry As String,
                                   ByVal sottoStatoOrderEntry As String,
                                   ByVal statoRisposta As String,
                                   ByVal testata As StatoDS.TestataRow,
                                   ByVal tipoStato As QueueTypes.TipoStatoType,
                                   ByVal obj As QueueTypes.TestataStatoType)

        DiagnosticsHelper.WriteDiagnostics("StatoAdapter.UpdateTestata(ticket)")

        ' Calcolo la data modifica stato
        Dim dataModificaStato As Nullable(Of DateTime) = GetDataModficaStatoTestata(statoOrderEntry, testata)

        ' Valori XML
        Dim statoErogante As String = DataContractSerializerHelper.GetXML(obj.StatoErogante)
        Dim operatore As String = DataContractSerializerHelper.GetXML(obj.Operatore)
        Dim pazienteXML As String = DataContractSerializerHelper.GetXML(obj.Paziente)
        Dim consensi As String = DataContractSerializerHelper.GetXML(obj.Consensi)

        Dim paziente As QueueTypes.PazienteType = obj.Paziente.GetInstance
        Dim idSac As Nullable(Of Guid) = paziente.IdSac.ParseGuid("Paziente.IdSac")

        'Nello schema di BT dataPrenotazione non è nillable e potrebbe arrivare la data minima invece di NOTHING
        Dim dataPrenotazione As DateTime? = Nothing
        If obj.DataPrenotazione.HasValue Then
            If DateDiff(DateInterval.Day, DateTime.MinValue, obj.DataPrenotazione.Value) <> 0 Then
                dataPrenotazione = obj.DataPrenotazione
            End If
        End If

        ' Merge IdRichiestaErogante
        Dim idRichiestaErogante As String = Nothing

        ' Se il tipoStato = RR e Stato = AA, AR o AE (<>SE) non faccio il merge
        If tipoStato = QueueTypes.TipoStatoType.RR AndAlso obj.StatoOrderEntry <> QueueTypes.StatoTestataErogatoOrderEntryEnum.SE.ToString Then

            'Sovrascrivo IDRichiestaErogante anche se vuoto
            idRichiestaErogante = If(String.IsNullOrEmpty(obj.IdRichiestaErogante), Nothing, obj.IdRichiestaErogante)
        Else
            If String.IsNullOrEmpty(obj.IdRichiestaErogante) Then

                ' Dato da erogante è vuoto, uso quello del DB se c'è
                idRichiestaErogante = If(testata.IsIDRichiestaEroganteNull(), Nothing, testata.IDRichiestaErogante)
            Else
                ' Setto dato da erogante
                idRichiestaErogante = obj.IdRichiestaErogante
            End If
        End If

        MsgOrdiniErogatiTestateUpdate(ID:=id,
                                      IDTicketModifica:=ticket,
                                      IDOrdineTestata:=idOrdineTestata,
                                      IDSistemaRichiedente:=idSistemaRichiedente,
                                      IDRichiestaRichiedente:=obj.IdRichiestaRichiedente,
                                      IDSistemaErogante:=idSistemaErogante,
                                      IDRichiestaErogante:=idRichiestaErogante,
                                      StatoOrderEntry:=statoOrderEntry,
                                      SottoStatoOrderEntry:=sottoStatoOrderEntry,
                                      StatoRisposta:=statoRisposta,
                                      DataModificaStato:=dataModificaStato,
                                      StatoErogante:=statoErogante,
                                      Data:=obj.Data,
                                      Operatore:=operatore,
                                      AnagraficaCodice:=paziente.AnagraficaCodice,
                                      AnagraficaNome:=paziente.AnagraficaNome,
                                      PazienteIdRichiedente:=paziente.IdRichiedente,
                                      PazienteIdSac:=idSac,
                                      PazienteCognome:=paziente.Cognome,
                                      PazienteNome:=paziente.Nome,
                                      PazienteDataNascita:=paziente.DataNascita,
                                      PazienteSesso:=paziente.Sesso,
                                      PazienteCodiceFiscale:=paziente.CodiceFiscale,
                                      Paziente:=pazienteXML,
                                      Consensi:=consensi,
                                      Note:=obj.Note,
                                      DataPrenotazione:=dataPrenotazione)

        '
        ' Aggiorno con dati calcolati
        '
        If dataModificaStato.HasValue Then
            testata.DataModificaStato = dataModificaStato.Value
        Else
            testata.SetDataPrenotazioneNull()
        End If

        If dataPrenotazione.HasValue Then
            testata.DataPrenotazione = dataPrenotazione.Value
        Else
            testata.SetDataPrenotazioneNull()
        End If

        If Not String.IsNullOrEmpty(idRichiestaErogante) Then
            testata.IDRichiestaErogante = idRichiestaErogante
        Else
            testata.SetIDRichiestaEroganteNull()
        End If

    End Sub


    Private Sub SaveTestataDatiAggiuntivi(ByVal ticket As Guid,
                                    ByVal idOrdineTestata As Guid,
                                    ByVal datiAggiuntivi As QueueTypes.DatiAggiuntiviType,
                                    ByVal tipoOperazione As QueueTypes.TipoOperazioneType)

        DiagnosticsHelper.WriteDiagnostics("StatoAdapter.SaveTestataDatiAggiuntivi()")

        ' Delete dei dati aggiuntivi non persistenti
        MsgOrdiniErogatiTestateDatiAggiuntiviDeleteByIDOrdineErogato(idOrdineTestata)

        ' Modifica (insert/update) dei dati aggiuntivi
        If datiAggiuntivi IsNot Nothing Then
            For Each item As QueueTypes.DatoNomeValoreType In datiAggiuntivi

                ' Controlla tipo dato
                If String.IsNullOrEmpty(item.TipoDato) Then
                    Throw New OrderEntryArgumentNullException("TipoDato")
                End If

                MsgOrdiniErogatiTestateDatiAggiuntiviInsert(IDTicketInserimento:=ticket,
                                            IDOrdineErogatoTestata:=idOrdineTestata,
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
                                                ByVal datiPersistenti As QueueTypes.DatiPersistentiType,
                                                ByVal tipoOperazione As QueueTypes.TipoOperazioneType)

        DiagnosticsHelper.WriteDiagnostics("StatoAdapter.MergeTestataDatiPersistenti()")

        ' Modifica (insert/update) dei dati aggiuntivi persistenti
        If datiPersistenti IsNot Nothing Then
            For Each item As QueueTypes.DatoNomeValoreType In datiPersistenti

                ' Controlla tipo dato
                If String.IsNullOrEmpty(item.TipoDato) Then
                    Throw New OrderEntryArgumentNullException("TipoDato")
                End If

                ' Cerco il dato aggiuntivo
                Dim datoAggiuntivo As StatoDS.TestataDatoAggiuntivoRow = GetTestataDatoPersistenteByIDDatoAggiuntivo(idOrdineTestata, item.Id)
                If datoAggiuntivo Is Nothing Then

                    DiagnosticsHelper.WriteDiagnostics("StatoAdapter.MergeTestataDatiAggiuntiviPersistenti() -> MsgOrdiniErogatiTestateDatiAggiuntiviInsert")

                    MsgOrdiniErogatiTestateDatiAggiuntiviInsert(IDTicketInserimento:=ticket,
                                                                IDOrdineErogatoTestata:=idOrdineTestata,
                                                                IDDatoAggiuntivo:=item.Id,
                                                                Nome:=item.Nome,
                                                                TipoDato:=item.TipoDato,
                                                                TipoContenuto:=item.TipoContenuto,
                                                                ValoreDato:=item.ValoreDato,
                                                                ParametroSpecifico:=False,
                                                                Persistente:=True)
                Else
                    DiagnosticsHelper.WriteDiagnostics("StatoAdapter.MergeTestataDatiAggiuntiviPersistenti() -> MsgOrdiniErogatiTestateDatiAggiuntiviUpdate")

                    MsgOrdiniErogatiTestateDatiAggiuntiviUpdate(ID:=datoAggiuntivo.ID,
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

#End Region

#Region "Righe erogate DB"


    Private Function MergeRigheErogate(ByVal ticket As Guid,
                                  ByVal idOrdineTestata As Guid,
                                  ByVal idSistemaErogante As Guid,
                                  ByVal righeErogate As QueueTypes.RigheErogateType,
                                  ByVal tipoOperazione As QueueTypes.TipoOperazioneType,
                                  ByVal tipoStato As QueueTypes.TipoStatoType,
                                  ByVal righeErogateCorrenti As StatoDS.RigaErogataDataTable) As StatoDS.RigaErogataRow()

        DiagnosticsHelper.WriteDiagnostics("StatoAdapter.UpdateRigheErogate()")

        ' La lista righeErogateCorrenti e' passata perchè serve anche all'esterno per comparare le righe per determinare se invare OSU
        ' Qui è usata solo in caso di Incrementale


        Dim righeErogateRow As New Generic.List(Of StatoDS.RigaErogataRow)
        Dim bIncrementale As Boolean
        '
        ' Controllo se incrementale. RR è sempre incrementale. OSU solo se TipoOperazione
        '
        If tipoOperazione = QueueTypes.TipoOperazioneType.Completo AndAlso tipoStato = QueueTypes.TipoStatoType.OSU Then
            bIncrementale = False
            '
            ' Delete dei dati aggiuntivi
            '
            MsgOrdiniRigheErogateDatiAggiuntiviDeleteByIDOrdineErogato(idOrdineTestata)
            '
            ' Delete delle righe erogate
            '
            MsgOrdiniRigheErogateDeleteByIDOrdineErogato(idOrdineTestata)
        Else
            bIncrementale = True
            '
            ' Incrementale
        End If

        If righeErogate IsNot Nothing AndAlso righeErogate.Count > 0 Then

            Using prestazioneAdapter As New PrestazioneAdapter(Me.Connection, Me.Transaction, ConfigurationHelper.TransactionIsolationLevel)
                '
                ' Modifica (insert/update) delle righe erogate
                '
                For Each riga As QueueTypes.RigaErogataType In righeErogate

                    Dim prestazione As PrestazioniDS.PrestazioneRow
                    '
                    ' Consolido la prestazione
                    '
                    prestazione = prestazioneAdapter.Consolida(ticket, idSistemaErogante, riga.Prestazione, False)
                    If prestazione Is Nothing Then

                        Throw New OrderEntryNotFoundException("Prestazione.",
                                           String.Format("idSistemaErogante={0}, Codice={1}",
                                                        idSistemaErogante, riga.Prestazione.Codice))
                    End If
                    '
                    ' Se vuoto setto l'id riga richiedente al valore del codice prestazione
                    '
                    If String.IsNullOrEmpty(riga.IdRigaRichiedente) And String.IsNullOrEmpty(riga.IdRigaErogante) Then
                        riga.IdRigaRichiedente = riga.Prestazione.Codice
                    End If
                    '
                    ' Controllo se esiste la riga erogata
                    '
                    Dim rigaErogata As StatoDS.RigaErogataRow = Nothing

                    If Not bIncrementale Then
                        '
                        ' Se è completo le righe sono state cancellate, le reinserisco
                        '
                        rigaErogata = InsertRigaErogata(ticket, idOrdineTestata, prestazione.ID, riga)
                        If rigaErogata Is Nothing Then
                            Throw New OrderEntryNotFoundException("Riga erogata.",
                                                                   String.Format("IdOrdineTestata={0}, IdRigaRichiedente={1}, IdRigaErogante={2}",
                                                                                 idOrdineTestata, riga.IdRigaRichiedente, riga.IdRigaErogante))
                        End If

                        ' Save dei dati aggiuntivi
                        SaveRigaErogataDatiAggiuntivi(ticket, idOrdineTestata, rigaErogata.ID, riga.DatiAggiuntivi)

                        ' Aggiungo alla lista mi serve per calcolare lo stato
                        righeErogateRow.Add(rigaErogata)
                    Else
                        '
                        ' Incrementale. Controllo se c'è la riga nel DB per IdRigaRichiedente o IdRigaErogante
                        '
                        Dim sQueryRow As String = Nothing

                        If Not String.IsNullOrEmpty(riga.IdRigaRichiedente) Then
                            sQueryRow = String.Format("IDRigaRichiedente='{0}'", riga.IdRigaRichiedente)

                        ElseIf Not String.IsNullOrEmpty(riga.IdRigaErogante) Then
                            sQueryRow = String.Format("IDRigaErogante='{0}'", riga.IdRigaErogante)
                        End If
                        If Not String.IsNullOrEmpty(sQueryRow) Then

                            Dim rowsQuery() As Data.DataRow = righeErogateCorrenti.Select(sQueryRow)
                            If rowsQuery IsNot Nothing AndAlso rowsQuery.Count > 0 Then
                                'Se c'è prende la prima
                                rigaErogata = TryCast(rowsQuery.First, StatoDS.RigaErogataRow)
                            End If
                        End If
                        '
                        ' Controlla se Incrementale e Operazione Riga rimuovo
                        '
                        If riga.TipoOperazione = TipoRigaOperazioneType.Rimuove AndAlso rigaErogata IsNot Nothing Then
                            '
                            ' Se esiste la cancello
                            '
                            MsgOrdiniRigheErogateDelete(rigaErogata.ID)
                            '
                            ' Rimuovo da righe che ritornerò
                            '
                            righeErogateCorrenti.RemoveRigaErogataRow(rigaErogata)
                        Else
                            '
                            ' Non è TipoOperazione=rimuove-riga, inserisco o modifico
                            '
                            If rigaErogata Is Nothing Then
                                rigaErogata = InsertRigaErogata(ticket, idOrdineTestata, prestazione.ID, riga)
                            Else
                                rigaErogata = UpdateRigaErogata(ticket, rigaErogata, idOrdineTestata, prestazione.ID, riga)
                            End If

                            If rigaErogata Is Nothing Then
                                Throw New OrderEntryNotFoundException("Riga erogata.",
                                                                       String.Format("IdOrdineTestata={0}, IdRigaRichiedente={1}, IdRigaErogante={2}",
                                                                                     idOrdineTestata, riga.IdRigaRichiedente, riga.IdRigaErogante))
                            Else
                                '
                                ' Aggiorno la righe che ritornerò
                                '
                                righeErogateCorrenti.Merge(rigaErogata.Table)
                            End If

                            ' Delete dei dati aggiuntivi della riga
                            MsgOrdiniRigheErogateDatiAggiuntiviDeleteByIDRigaErogata(rigaErogata.ID)

                            ' Save dei dati aggiuntivi
                            SaveRigaErogataDatiAggiuntivi(ticket, idOrdineTestata, rigaErogata.ID, riga.DatiAggiuntivi)
                        End If
                    End If
                Next riga
            End Using
        End If

        If Not bIncrementale Then
            ' Ritorno le righe erogate processate 
            If righeErogateRow IsNot Nothing AndAlso righeErogateRow.Count > 0 Then
                Return righeErogateRow.ToArray
            Else
                Return Nothing
            End If
        Else
            'Ritorno le righe erogate del DB
            If righeErogateCorrenti IsNot Nothing AndAlso righeErogateCorrenti.Count > 0 Then
                Return righeErogateCorrenti.ToArray
            Else
                Return Nothing
            End If
        End If

    End Function

    Private Function InsertRigaErogata(ByVal ticket As Guid,
                                       ByVal idOrdineTestata As Guid,
                                       ByVal idPrestazione As Guid,
                                       ByVal obj As QueueTypes.RigaErogataType) As StatoDS.RigaErogataRow

        DiagnosticsHelper.WriteDiagnostics("StatoAdapter.InsertRigaErogata()")

        '
        ' Valori XML
        '
        Dim statoErogante As String = DataContractSerializerHelper.GetXML(obj.StatoErogante)
        Dim operatore As String = DataContractSerializerHelper.GetXML(obj.Operatore)
        Dim consensi As String = DataContractSerializerHelper.GetXML(obj.Consensi)

        MsgOrdiniRigheErogateInsert(IDTicketInserimento:=ticket,
                                    IDOrdineErogatoTestata:=idOrdineTestata,
                                    StatoOrderEntry:=obj.StatoOrderEntry,
                                    IDPrestazione:=idPrestazione,
                                    IDRigaRichiedente:=obj.IdRigaRichiedente,
                                    IDRigaErogante:=obj.IdRigaErogante,
                                    StatoErogante:=statoErogante,
                                    Data:=obj.Data,
                                    Operatore:=operatore,
                                    Consensi:=consensi)
        '
        ' Return
        '
        Return GetRigaErogata(idOrdineTestata, obj.IdRigaRichiedente, obj.IdRigaErogante)

    End Function

    Private Function UpdateRigaErogata(ByVal ticket As Guid,
                                       ByVal rigaCorrente As StatoDS.RigaErogataRow,
                                       ByVal idOrdineTestata As Guid,
                                       ByVal idPrestazione As Guid,
                                       ByVal obj As QueueTypes.RigaErogataType) As StatoDS.RigaErogataRow

        DiagnosticsHelper.WriteDiagnostics("StatoAdapter.UpdateRigaErogata()")
        '
        ' Calcolo la data modifica stato
        '
        Dim dataModificaStato As Nullable(Of DateTime) = Nothing

        ' Se cambiato lo stato aggiorno la data
        If rigaCorrente.StatoOrderEntry <> obj.StatoOrderEntry Then
            dataModificaStato = DateTime.Now
        Else
            If Not rigaCorrente.IsDataModificaStatoNull() Then
                dataModificaStato = rigaCorrente.DataModificaStato
            End If
        End If
        '
        ' Valori XML
        '
        Dim statoErogante As String = DataContractSerializerHelper.GetXML(obj.StatoErogante)
        Dim operatore As String = DataContractSerializerHelper.GetXML(obj.Operatore)
        Dim consensi As String = DataContractSerializerHelper.GetXML(obj.Consensi)

        MsgOrdiniRigheErogateUpdate(IDTicketModifica:=ticket,
                                    ID:=rigaCorrente.ID,
                                    StatoOrderEntry:=obj.StatoOrderEntry,
                                    DataModificaStato:=dataModificaStato,
                                    IDPrestazione:=idPrestazione,
                                    IDRigaErogante:=obj.IdRigaErogante,
                                    StatoErogante:=statoErogante,
                                    Data:=obj.Data,
                                    Operatore:=operatore,
                                    Consensi:=consensi)
        '
        ' Return
        '
        Return GetRigaErogata(idOrdineTestata, obj.IdRigaRichiedente, obj.IdRigaErogante)

    End Function

    <Obsolete("Usare SaveRigaErogataDatiAggiuntivi()!")> _
    Private Sub MergeRigaErogataDatiAggiuntivi(ByVal ticket As Guid,
                                               ByVal idOrdineTestata As Guid,
                                               ByVal idRigaErogata As Guid,
                                               ByVal datiAggiuntivi As QueueTypes.DatiAggiuntiviType)

        DiagnosticsHelper.WriteDiagnostics("StatoAdapter.MergeRigaErogataDatiAggiuntivi()")

        '
        ' Modifica (insert/update) dei dati aggiuntivi persistenti
        '
        If datiAggiuntivi IsNot Nothing Then
            For Each item As QueueTypes.DatoNomeValoreType In datiAggiuntivi
                If String.IsNullOrEmpty(item.TipoDato) Then
                    Throw New OrderEntryArgumentNullException("TipoDato")
                End If

                '
                ' Cerco il dato aggiuntivo
                '
                Dim datoAggiuntivo As StatoDS.RigaErogataDatoAggiuntivoRow = GetRigaErogataDatoAggiuntivoByIDDatoAggiuntivo(idRigaErogata, item.Id)

                If datoAggiuntivo Is Nothing Then
                    MsgOrdiniRigheErogateDatiAggiuntiviInsert(IDTicketInserimento:=ticket,
                                                              IDRigaErogata:=idRigaErogata,
                                                              IDDatoAggiuntivo:=item.Id,
                                                              Nome:=item.Nome,
                                                              TipoDato:=item.TipoDato,
                                                              TipoContenuto:=item.TipoContenuto,
                                                              ValoreDato:=item.ValoreDato,
                                                              ParametroSpecifico:=False,
                                                              Persistente:=False)
                Else
                    MsgOrdiniRigheErogateDatiAggiuntiviUpdate(ID:=datoAggiuntivo.ID,
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

    Private Sub SaveRigaErogataDatiAggiuntivi(ByVal ticket As Guid,
                                            ByVal idOrdineTestata As Guid,
                                            ByVal idRigaErogata As Guid,
                                            ByVal datiAggiuntivi As QueueTypes.DatiAggiuntiviType)

        DiagnosticsHelper.WriteDiagnostics("StatoAdapter.SaveRigaErogataDatiAggiuntivi()")

        ' Delete dei dati aggiuntivi non persistenti della riga
        MsgOrdiniRigheErogateDatiAggiuntiviDeleteByIDRigaErogata(idRigaErogata)

        ' Modifica (insert/update) dei dati aggiuntivi persistenti
        If datiAggiuntivi IsNot Nothing Then
            For Each item As QueueTypes.DatoNomeValoreType In datiAggiuntivi

                ' Controlla tipo dato
                If String.IsNullOrEmpty(item.TipoDato) Then
                    Throw New OrderEntryArgumentNullException("TipoDato")
                End If

                ' Aggiungo il dato aggiuntivo
                MsgOrdiniRigheErogateDatiAggiuntiviInsert(IDTicketInserimento:=ticket,
                                          IDRigaErogata:=idRigaErogata,
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

#Region "Versione erogato DB"

    Private Sub Versioning(ByVal ticket As Guid, ByVal idOrdineErogatoTestata As Guid, ByVal statoOrderEntry As String)
        DiagnosticsHelper.WriteDiagnostics("StatoAdapter.Versioning()")

        MsgOrdiniErogatiVersioniInsert(ticket, idOrdineErogatoTestata, statoOrderEntry)
    End Sub

#End Region

#Region "Utilita"

    Private Function GetDataModficaStatoTestata(statoOrderEntry As String, testata As StatoDS.TestataRow) As DateTime?
        DiagnosticsHelper.WriteDiagnostics("StatoAdapter.GetDataModficaStatoTestata()")

        Dim dataModificaStato As Nullable(Of DateTime) = Nothing

        If Not String.IsNullOrEmpty(statoOrderEntry) And testata IsNot Nothing Then

            If testata.IsStatoOrderEntryNull() Then
                dataModificaStato = DateTime.Now
            Else
                '
                ' Se stato è diverso aggiorno data di modifica
                '
                If testata.StatoOrderEntry <> statoOrderEntry Then
                    dataModificaStato = DateTime.Now
                Else
                    If Not testata.IsDataModificaStatoNull() Then
                        dataModificaStato = testata.DataModificaStato
                    End If
                End If
            End If
        End If

        Return dataModificaStato
    End Function

    Private Function CompareTestataOSU(statoQueue As QueueTypes.StatoQueueType, testata As StatoDS.TestataRow) As Boolean

        DiagnosticsHelper.WriteDiagnostics("StatoAdapter.CompareOSU()")

        ' Prima la DataPrenotazione
        If Not testata.IsDataPrenotazioneNull AndAlso statoQueue.Testata.DataPrenotazione.HasValue Then
            If Math.Truncate(testata.DataPrenotazione.Subtract(statoQueue.Testata.DataPrenotazione.Value).TotalSeconds) <> 0 Then
                ' Data diversa
                Return True
            End If

        ElseIf testata.IsDataPrenotazioneNull AndAlso statoQueue.Testata.DataPrenotazione.HasValue Then
            ' DB null ma obj con valore
            Return True

        ElseIf Not testata.IsDataPrenotazioneNull AndAlso Not statoQueue.Testata.DataPrenotazione.HasValue Then
            ' DB con valore ma obj null
            Return True
        End If

        ' Poi lo StatoOrderEntry
        If Not testata.IsStatoOrderEntryNull AndAlso Not String.IsNullOrEmpty(statoQueue.Testata.StatoOrderEntry) Then
            If String.Compare(testata.StatoOrderEntry, statoQueue.Testata.StatoOrderEntry, True) <> 0 Then
                ' Dato diverso
                Return True
            End If

        ElseIf testata.IsStatoOrderEntryNull AndAlso Not String.IsNullOrEmpty(statoQueue.Testata.StatoOrderEntry) Then
            ' DB null ma obj con valore
            Return True

        ElseIf Not testata.IsStatoOrderEntryNull AndAlso String.IsNullOrEmpty(statoQueue.Testata.StatoOrderEntry) Then
            ' DB con valore ma obj null
            Return True
        End If

        Return False

    End Function

    Private Function CompareRigheOSU(statoQueue As QueueTypes.StatoQueueType,
                                    TableRigheErogateCorrenti As StatoDS.RigaErogataDataTable,
                                    DatiAggiuntiviDataPianificata As List(Of StatoDS.RigaErogataDatoAggiuntivoRow)) As Boolean
        '
        ' Compara le righe tra la versioni letta dal DB e quella dell'XML del messaggio
        '
        DiagnosticsHelper.WriteDiagnostics("StatoAdapter.CompareOSU()")

        ' ----------------------------------------------
        ' Comparazione delle righe

        If statoQueue.TipoOperazione = TipoOperazioneType.Completo Then

            If TableRigheErogateCorrenti Is Nothing AndAlso statoQueue.Testata.RigheErogate Is Nothing Then
                ' Entrambi vuoti sono uguali
                Return False

            ElseIf TableRigheErogateCorrenti IsNot Nothing AndAlso statoQueue.Testata.RigheErogate Is Nothing Then
                ' Correnti con valore ma nuove null
                Return True

            ElseIf TableRigheErogateCorrenti Is Nothing AndAlso statoQueue.Testata.RigheErogate IsNot Nothing Then
                ' Correnti null ma nuove con valore
                Return True
            End If

            If TableRigheErogateCorrenti.Count <> statoQueue.Testata.RigheErogate.Count Then
                'Numero di elementi diversi
                Return True
            End If

        Else
            'Incrementale

            If statoQueue.Testata.RigheErogate Is Nothing OrElse statoQueue.Testata.RigheErogate.Count = 0 Then
                ' Nuove righe vuote o 0 sono uguali
                Return False
            End If
        End If

        '-----------------------------------------------------------------
        'Comparazione delle righe da aggiornare
        ' Se incrementale valuta solo le nuove, se completo le valuta tutte
        '
        If statoQueue.Testata.RigheErogate.Count > 0 Then
            For Each objRigaNuova As RigaErogataType In statoQueue.Testata.RigheErogate

                Dim drRigaCorrente As StatoDS.RigaErogataRow = Nothing
                Dim sQueryRow As String = Nothing

                ' Cerco la riga per IDRigaRichiedente oppure IDRigaErogante oppure CodicePrestazione
                If Not String.IsNullOrEmpty(objRigaNuova.IdRigaRichiedente) Then
                    sQueryRow = String.Format("IDRigaRichiedente='{0}'", objRigaNuova.IdRigaRichiedente)

                ElseIf Not String.IsNullOrEmpty(objRigaNuova.IdRigaErogante) Then
                    sQueryRow = String.Format("IDRigaErogante='{0}'", objRigaNuova.IdRigaErogante)
                Else
                    sQueryRow = String.Format("CodicePrestazione='{0}'", objRigaNuova.Prestazione.Codice)
                End If

                'Se c'è prende la prima
                Dim rowsQuery() As Data.DataRow = TableRigheErogateCorrenti.Select(sQueryRow)
                drRigaCorrente = TryCast(rowsQuery.FirstOrDefault, StatoDS.RigaErogataRow)
                If drRigaCorrente IsNot Nothing Then

                    ' Poi lo StatoOrderEntry
                    If Not String.IsNullOrEmpty(drRigaCorrente.StatoOrderEntry) AndAlso Not String.IsNullOrEmpty(objRigaNuova.StatoOrderEntry) Then
                        If String.Compare(drRigaCorrente.StatoOrderEntry, objRigaNuova.StatoOrderEntry, True) <> 0 Then
                            ' Dato diverso
                            Return True
                        End If

                    ElseIf String.IsNullOrEmpty(drRigaCorrente.StatoOrderEntry) AndAlso Not String.IsNullOrEmpty(objRigaNuova.StatoOrderEntry) Then
                        ' DB null ma obj con valore
                        Return True

                    ElseIf Not String.IsNullOrEmpty(drRigaCorrente.StatoOrderEntry) AndAlso String.IsNullOrEmpty(objRigaNuova.StatoOrderEntry) Then
                        ' DB con valore ma obj null
                        Return True
                    End If

                    '-----------------------------------------------------------------
                    'Valutazione datapianificata nei dati aggiuntivi
                    Dim dtPianificataCorrente As DateTime = DateTime.MinValue
                    Dim dtPianificataNuova As DateTime = DateTime.MinValue

                    If DatiAggiuntiviDataPianificata IsNot Nothing Then
                        ' Cerco dataPianificata Corrente
                        Dim IdRigaErogante As Guid = drRigaCorrente.ID
                        Dim oDataPianificataCorrente = DatiAggiuntiviDataPianificata.FirstOrDefault(Function(e) e.IDRigaErogata = IdRigaErogante)
                        If oDataPianificataCorrente IsNot Nothing Then

                            'Se trovato prova il parsing della data altrimenti MinData
                            DateTime.TryParse(oDataPianificataCorrente.ValoreDato.ToString, dtPianificataCorrente)
                        End If
                    End If

                    If objRigaNuova.DatiAggiuntivi IsNot Nothing Then
                        ' Cerco dataPianificata Corrente
                        Dim oDataPianificataNuova = objRigaNuova.DatiAggiuntivi.FirstOrDefault(Function(e) e.Id = DatiAggiuntivi.ID_DATA_PIANIFICATA)
                        If oDataPianificataNuova IsNot Nothing Then

                            'Se trovato prova il parsing della data altrimenti MinData
                            DateTime.TryParse(oDataPianificataNuova.ValoreDato, dtPianificataNuova)
                        End If
                    End If

                    ' Poi la Data Pianificata
                    If dtPianificataCorrente > DateTime.MinValue AndAlso dtPianificataNuova > DateTime.MinValue Then
                        If Math.Truncate(dtPianificataCorrente.Subtract(dtPianificataNuova).TotalSeconds) <> 0 Then
                            ' Data diversa
                            Return True
                        End If

                    ElseIf dtPianificataCorrente = DateTime.MinValue AndAlso dtPianificataNuova > DateTime.MinValue Then
                        ' DB null ma obj con valore
                        Return True

                    ElseIf dtPianificataCorrente > DateTime.MinValue AndAlso dtPianificataNuova = DateTime.MinValue Then
                        ' DB con valore ma obj null
                        Return True
                    End If

                Else
                    ' Non trovata
                    Return True
                End If
            Next
        End If

        Return False

    End Function


#End Region

End Class