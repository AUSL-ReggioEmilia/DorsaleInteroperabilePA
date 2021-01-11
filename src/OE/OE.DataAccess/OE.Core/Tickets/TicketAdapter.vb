Imports System.Data.SqlClient
Imports System.Security.Principal
Imports System.ServiceModel

Public Class TicketAdapter
    Inherits TicketsDSTableAdapters.CommandsAdapter

#Region " IAdapter "

    Private _bCanDisposeConnection As Boolean = False
    Private _connection As SqlConnection = Nothing
    Private _transaction As SqlTransaction = Nothing

    Public ReadOnly Property Transaction As SqlTransaction
        Get
            Return _transaction
        End Get
    End Property

    Public ReadOnly Property Connection As SqlConnection
        Get
            Return _connection
        End Get
    End Property

    Private Sub SetCommandsConnection()

        DiagnosticsHelper.WriteDiagnostics("TicketAdapter.SetCommandsConnection()")

        For Each commands As IDbCommand In MyBase.CommandCollection

            If _connection IsNot Nothing AndAlso _connection.State = ConnectionState.Closed Then
                _connection.Open()
            End If

            ' Imposto tutti i commands sulla stessa connessione
            commands.Connection = _connection
        Next

    End Sub

    Public Sub BeginTransaction(ByVal isolationLevel As IsolationLevel)

        DiagnosticsHelper.WriteDiagnostics("TicketAdapter.BeginTransaction()")

        If _connection.State = ConnectionState.Closed Then

            Throw New Exception("Errore durante TicketAdapter.BeginTransaction(). La connessione al database è chiusa!")
        End If

        For Each commands As IDbCommand In MyBase.CommandCollection

            If _transaction Is Nothing Then
                _transaction = _connection.BeginTransaction(isolationLevel)
            End If

            ' Imposto tutti i commands sulla stessa transazione
            commands.Transaction = _transaction
        Next

    End Sub

    Public Sub Commit()

        DiagnosticsHelper.WriteDiagnostics("TicketAdapter.Commit()")

        If _transaction IsNot Nothing Then
            Try
                _transaction.Commit()
            Finally
                _transaction.Dispose()
            End Try

            _transaction = Nothing
        End If

    End Sub

    Public Sub Rollback()

        DiagnosticsHelper.WriteDiagnostics("TicketAdapter.Rollback()")

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

        DiagnosticsHelper.WriteDiagnostics("TicketAdapter.Disposed()")

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

        DiagnosticsHelper.WriteDiagnostics("TicketAdapter.New()")

        If _connection Is Nothing Then
            _bCanDisposeConnection = True
            _connection = New SqlClient.SqlConnection(connectionString)
        End If

        ' Imposto tutti i commands sulla stessa connessione
        SetCommandsConnection()
    End Sub

#End Region

    Public Shared Function GetWindowsIdentityName() As String

        If ServiceSecurityContext.Current Is Nothing Then

            ' Nessun ServiceSecurityContext, uso WindowsIdentity
            Dim userName As String = WindowsIdentity.GetCurrent.Name

            If String.IsNullOrEmpty(userName) Then
                Dim reason = "Impossibile creare il contesto di sicurezza per l'utente corrente. Contattare l'amministratore di sistema."
                Throw New FaultException(Of TokenFault)(New TokenFault(reason, ErrorCode.UnauthorizedAccess), reason)
            End If

            Return userName
        Else
            ' Cerco nel contesto di WCF
            Return ServiceSecurityContext.Current.WindowsIdentity.Name
        End If

    End Function

    Public Shared Function GetClientPcName() As String

        If OperationContext.Current Is Nothing Then

            ' Nessun OperationContext, uso il nome del server
            Dim computerName As String = My.Computer.Name

            If String.IsNullOrEmpty(computerName) Then
                Dim reason = "Impossibile ottenere OperationContext. Contattare l'amministratore di sistema."
                Throw New FaultException(Of TokenFault)(New TokenFault(reason, ErrorCode.UnauthorizedAccess), reason)
            End If

            Return computerName
        Else
            ' Cerco nel contesto di WCF
            Dim messagePropertyRemoteEndpoint As Channels.RemoteEndpointMessageProperty
            Dim sRemoteEndpoint = Channels.RemoteEndpointMessageProperty.Name

            messagePropertyRemoteEndpoint = TryCast(OperationContext.Current.IncomingMessageProperties(sRemoteEndpoint), Channels.RemoteEndpointMessageProperty)
            If messagePropertyRemoteEndpoint IsNot Nothing Then

                'Se localhost torna il server
                Dim sIpAddress As String = messagePropertyRemoteEndpoint.Address

                Try
                    Dim computerName As String = Net.Dns.GetHostEntry(sIpAddress).HostName
                    If String.IsNullOrEmpty(computerName) Then
                        Return sIpAddress
                    Else
                        Return computerName
                    End If

                Catch ex As Exception
                    Return sIpAddress
                End Try

            Else
                Return Nothing
            End If
        End If

    End Function


    Public Function GetTicketId(ByVal utenteDelegato As String, ByVal ttl As Integer) As Guid

        Try
            Dim ticket As TicketsDS.TicketRow = GetTicketRow(utenteDelegato, ttl)
            If ticket IsNot Nothing Then
                Return ticket.ID
            Else
                Return Nothing
            End If

        Catch ex As Exception
            Throw
        End Try

    End Function

    Public Function GetTicketRow(ByVal utenteDelegato As String, ByVal ttl As Integer) As TicketsDS.TicketRow

        DiagnosticsHelper.WriteDiagnostics(String.Format("TicketAdapter.GetTicketRow(). Utente: {0};", utenteDelegato))

        Dim ticket As TicketsDS.TicketRow = Nothing
        '
        ' Cerco Identity di chi accede al servizio
        '
        Dim identity As String = GetWindowsIdentityName()

        ' Get proprietà utente
        Dim utente As TicketsDS.UtenteRow = GetUtente(identity)
        If utente Is Nothing Then
            Throw New OrderEntryAccessDeniedException(identity, "L'utente non è abilitato.")
        End If

        ' Controllo se l'utente (identity) ha l'obbligo di delega
        If (String.IsNullOrEmpty(utenteDelegato) OrElse String.Compare(utenteDelegato, identity, True) = 0) AndAlso utente.Delega = 2 Then

            Throw New OrderEntryAccessDeniedException(identity, "L'utente ha l'obbligo di delega ma non è stato specificato il delegato.")
        End If

        ' Controllo se l'utente delegato è codificato
        If String.Compare(utenteDelegato, identity, False) <> 0 Then

            Dim delegato As TicketsDS.UtenteRow = GetUtente(utenteDelegato)
            If delegato Is Nothing Then

                'Controllo se creo in automatico
                If ConfigurationHelper.AutoSyncUtentiDelegati Then

                    delegato = CreaUtenteDelegato(utenteDelegato)
                    If delegato Is Nothing Then
                        DiagnosticsHelper.WriteDiagnostics(String.Format("Errore durante la inserimento dell'utente delegato: {0};", utenteDelegato))
                        Throw New OrderEntryAccessDeniedException(utenteDelegato, "Errore durante la inserimento dell'utente delegato.")
                    End If
                Else
                    Throw New OrderEntryAccessDeniedException(utenteDelegato, "L'utente delegato abilitato.")
                End If
            End If
        End If
        '
        ' Creo il ticket
        '
        If Not String.IsNullOrEmpty(utenteDelegato) AndAlso (String.Compare(utenteDelegato, identity, False) <> 0) Then

            ' Se utenteDelegato <> identity
            If utente.Delega = 0 Then

                ' Se delega è = 0 il risultato sarà un AccessDenied
                Throw New OrderEntryAccessDeniedException(identity, "L'utente non può delegare.")

            ElseIf utente.Delega = 1 OrElse utente.Delega = 2 Then

                ' Se delega è = 1 o = 2 creo una nuova identity
                ticket = CreateTicket(utente.ID, utenteDelegato, ttl)
            End If
        Else

            ' Se utenteDelegato = identity
            ticket = CreateTicket(utente.ID, utenteDelegato, ttl)
        End If

        Return ticket

    End Function

    Public Function GetSystemTicketRow(ByVal utenteDelegato As String, ByVal ttl As Integer) As TicketsDS.TicketRow
        '
        ' Creo un ticket system per le operazioni amministrative da OrderEntryAdmin
        '
        DiagnosticsHelper.WriteDiagnostics(String.Format("TicketAdapter.GetSystemTicketRow(). Utente: {0};", utenteDelegato))

        'Controllo parametri
        If String.IsNullOrEmpty(utenteDelegato) Then
            Throw New ArgumentException("Il parametro non può essere vuoto", "utenteDelegato")
        End If

        ' Cerco utente delegato 
        Dim delegato As TicketsDS.UtenteRow = GetUtente(utenteDelegato)
        If delegato Is Nothing Then

            ' Se non trovo creo
            delegato = CreaUtenteDelegato(utenteDelegato)
            If delegato Is Nothing Then
                DiagnosticsHelper.WriteDiagnostics(String.Format("Errore durante la inserimento dell'utente delegato: {0};", utenteDelegato))
                Throw New OrderEntryAccessDeniedException(utenteDelegato, "Errore durante la inserimento dell'utente delegato.")
            End If
        End If
        '
        ' Creo il ticket
        '
        Dim idUtente As New Guid("00000000-0000-0000-0000-000000000000")

        Dim ticket As TicketsDS.TicketRow = Nothing
        ticket = CreateTicket(idUtente, delegato.Utente, ttl)

        Return ticket

    End Function


    Public Function IsValid(ByVal ticket As Guid) As Boolean
        DiagnosticsHelper.WriteDiagnostics(String.Format("TicketAdapter.IsValid(). Ticket: {0};", ticket.ToString()))

        Dim bValid As Boolean? = Nothing

        CoreTicketsIsValid(ticket, bValid)

        If bValid IsNot Nothing AndAlso bValid.HasValue Then
            Return bValid.Value
        Else
            Return False
        End If

    End Function

    Private Function GetTicketCurrent(ByVal idUtente As Guid, ByVal userName As String) As TicketsDS.TicketRow

        DiagnosticsHelper.WriteDiagnostics(String.Format("TicketAdapter.GetProprietaTicket(). IDUtente: {0}; UserName: {1};", idUtente.ToString(), userName))

        Dim row As TicketsDS.TicketRow = Nothing

        Using ta As New TicketsDSTableAdapters.TicketTableAdapter()
            ta.Connection = Connection
            ta.Transaction = Transaction

            Dim dt = ta.GetDataIfValid(idUtente, userName)
            If dt.Rows.Count > 0 Then
                row = dt.First()
            End If
        End Using

        Return row

    End Function

    Private Function GetTicketByID(ByVal id As Guid) As TicketsDS.TicketRow

        DiagnosticsHelper.WriteDiagnostics(String.Format("TicketAdapter.GetProprietaTicketByID(). ID: {0}", id.ToString()))

        Dim row As TicketsDS.TicketRow = Nothing

        Using ta As New TicketsDSTableAdapters.TicketTableAdapter()
            ta.Connection = Connection
            ta.Transaction = Transaction

            Dim dt As TicketsDS.TicketDataTable = ta.GetDataByID(id)
            If dt.Rows.Count > 0 Then
                row = dt.First()
            End If
        End Using

        Return row

    End Function


    Private Function GetUtente(ByVal utente As String) As TicketsDS.UtenteRow

        DiagnosticsHelper.WriteDiagnostics(String.Format("TicketAdapter.GetProprietaUtente(). Utente: {0}", utente))

        Dim row As TicketsDS.UtenteRow = Nothing

        Using ta As New TicketsDSTableAdapters.UtenteTableAdapter
            ta.Connection = Connection
            ta.Transaction = Transaction

            Dim dt As TicketsDS.UtenteDataTable = ta.GetData(utente)
            If dt.Rows.Count > 0 Then

                row = dt.First()
            End If
        End Using

        Return row

    End Function

    Private Function CreaUtenteDelegato(ByVal utente As String) As TicketsDS.UtenteRow

        DiagnosticsHelper.WriteDiagnostics(String.Format("TicketAdapter.GetProprietaUtente(). Utente: {0}", utente))

        Using ta As New TicketAdapter(Connection.ConnectionString)
            ' Nuovo utente
            ta.CoreUtentiInsert(utente, "Creato dal CORE", True, 0)

            ' Ritorno l'utente inserito
            Return GetUtente(utente)
        End Using

    End Function

    Private Function CreateTicket(ByVal idUtente As Guid, ByVal utenteDelegato As String, ByVal ttl As Integer) As TicketsDS.TicketRow

        DiagnosticsHelper.WriteDiagnostics(String.Format("TicketAdapter.CreateTicket(). IDUtente: {0}; Utente: {1}; TTL: {2};", _
                                                         idUtente.ToString(), utenteDelegato, ttl.ToString()))

        'Cerca se il Ticket è ancora valido
        Dim row As TicketsDS.TicketRow = GetTicketCurrent(idUtente, utenteDelegato)

        ' Se il ticket non esiste o e se è scaduto lo creo
        If row Is Nothing Then

            Dim idTicket As Guid?
            CoreTicketsInsert(idUtente, utenteDelegato, ttl, idTicket)

            If idTicket IsNot Nothing AndAlso idTicket.HasValue Then
                row = GetTicketByID(idTicket.Value)
            End If
        End If

        Return row

    End Function

    Public Function GetEnnupleAccessiCheck(ByVal utente As String, idSistemaErogante As Nullable(Of Guid), idStato As Nullable(Of Byte)) As TicketsDS.EnnupleAccessiCheckRow

        DiagnosticsHelper.WriteDiagnostics("TicketAdapter.GetEnnupleAccessiCheck()")

        Dim row As TicketsDS.EnnupleAccessiCheckRow = Nothing

        Using ta As New TicketsDSTableAdapters.EnnupleAccessiCheckTableAdapter()
            ta.Connection = Connection
            ta.Transaction = Transaction

            Dim dt As TicketsDS.EnnupleAccessiCheckDataTable = ta.GetData(utente, idSistemaErogante, idStato)
            If dt.Rows.Count > 0 Then
                row = dt.First()
            End If
        End Using

        Return row

    End Function

    Public Function GetEnnupleAccessiCheck(ByVal utente As String, codiceSistemaErogante As String, _
                                           codiceAziendaSistemaErogante As String, idStato As Nullable(Of Byte)) As TicketsDS.EnnupleAccessiCheckRow

        DiagnosticsHelper.WriteDiagnostics("TicketAdapter.GetEnnupleAccessiCheck()")

        ' Cerco il sistema erogante
        Dim sistema As OrganigrammaDS.SistemaRow = Nothing
        sistema = My.CacheSistemi.TryFindByCodice(codiceSistemaErogante, codiceAziendaSistemaErogante)

        If sistema Is Nothing Then
            ' Se non trovato cerco su DB
            Using adapter As New OrganigrammaAdapter(Connection.ConnectionString)
                sistema = adapter.GetSistemaByCodice(codiceSistemaErogante, codiceAziendaSistemaErogante)
            End Using

            If sistema Is Nothing Then
                'Non trovato
                Dim reason = String.Format("Il sistema erogante {0} non è codificato nell'order entry.", _
                                           String.Concat(codiceSistemaErogante, "@", codiceAziendaSistemaErogante))
                Throw New ApplicationException(reason)
            End If
        End If

        ' Cerco ennupla di accesso
        Dim row As TicketsDS.EnnupleAccessiCheckRow = Nothing
        Return GetEnnupleAccessiCheck(utente, sistema.ID, idStato)

        Return row

    End Function


End Class