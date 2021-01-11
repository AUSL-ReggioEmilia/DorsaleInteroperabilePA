Imports System.Data.SqlClient
Imports System.Xml
Imports System.ServiceModel

Imports Msg = OE.Core.Schemas.Msg

#If CONFIG = "Release 1.2" Or CONFIG = "Debug 1.2" Then
'Versione 1.2
Imports Wcf = OE.Core.Schemas.Wcf12
#Else
'Versione 1.0 e 1.1
Imports Wcf = OE.Core.Schemas.Wcf
#End If

Public Class MessaggioAdapter
    Inherits MessaggiDSTableAdapters.CommandsAdapter
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

        DiagnosticsHelper.WriteDiagnostics("MessaggioAdapter.SetCommandsConnection()")

        For Each commands As IDbCommand In MyBase.CommandCollection

            If _connection IsNot Nothing AndAlso _connection.State = ConnectionState.Closed Then
                _connection.Open()
            End If

            ' Imposto tutti i commands sulla stessa connessione
            commands.Connection = _connection
        Next
    End Sub

    Public Sub BeginTransaction(ByVal isolationLevel As IsolationLevel) Implements IAdapter.BeginTransaction

        DiagnosticsHelper.WriteDiagnostics("MessaggioAdapter.BeginTransaction()")

        If _connection.State = ConnectionState.Closed Then

            Throw New Exception("Errore durante MessaggioAdapter.BeginTransaction(). La connessione al database è chiusa!")
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

        DiagnosticsHelper.WriteDiagnostics("MessaggioAdapter.Commit()")

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

        DiagnosticsHelper.WriteDiagnostics("MessaggioAdapter.Rollback()")

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

        DiagnosticsHelper.WriteDiagnostics("MessaggioAdapter.Disposed()")

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

        DiagnosticsHelper.WriteDiagnostics("MessaggioAdapter.New()")

        If _connection Is Nothing Then
            _bCanDisposeConnection = True
            _connection = New SqlClient.SqlConnection(connectionString)
        End If

        ' Imposto tutti i commands sulla stessa connessione
        SetCommandsConnection()
    End Sub

    Public Sub New(ByVal connection As SqlConnection, ByVal transaction As SqlTransaction, ByVal isolationLevel As IsolationLevel)
        MyBase.New()

        DiagnosticsHelper.WriteDiagnostics("MessaggioAdapter.New()")

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

    <System.Runtime.Serialization.DataContractAttribute()>
    Public Enum Stato As Byte

        <System.Runtime.Serialization.EnumMemberAttribute()>
        Inserito = 0

        <System.Runtime.Serialization.EnumMemberAttribute()>
        Processato = 1

        <System.Runtime.Serialization.EnumMemberAttribute()>
        Errore = 2
    End Enum

    <System.Runtime.Serialization.DataContractAttribute()>
    Public Enum TipoStato As Byte

        <System.Runtime.Serialization.EnumMemberAttribute()>
        RR = 0

        <System.Runtime.Serialization.EnumMemberAttribute()>
        OSU = 1

        <System.Runtime.Serialization.EnumMemberAttribute()>
        [Null] = 2
    End Enum

    Private Function GetMessaggioRichiestaByID(ByVal id As Guid) As MessaggiDS.MessaggioRichiestaRow

        DiagnosticsHelper.WriteDiagnostics("MessaggioAdapter.GetRichiestaByID()")

        Dim row As MessaggiDS.MessaggioRichiestaRow = Nothing

        Using ta As New MessaggiDSTableAdapters.MessaggioRichiestaTableAdapter()
            ta.Connection = Connection
            ta.Transaction = Transaction

            Dim dt As MessaggiDS.MessaggioRichiestaDataTable = ta.GetDataByID(id)
            If dt.Rows.Count > 0 Then
                row = dt.First()
            End If
        End Using

        Return row
    End Function

    Public Function GetMessaggiRichiestaByIdOrdineTestata(ByVal id As Guid) As MessaggiDS.MessaggioRichiestaDataTable

        DiagnosticsHelper.WriteDiagnostics("MessaggioAdapter.GetRichiestaByIdOrdineTestata()")

        Dim dt As MessaggiDS.MessaggioRichiestaDataTable = Nothing

        Using ta As New MessaggiDSTableAdapters.MessaggioRichiestaTableAdapter()
            ta.Connection = Connection
            ta.Transaction = Transaction

            dt = ta.GetDataIdOrdineTestata(id)
        End Using

        Return dt
    End Function

    Private Function GetMessaggioStatoByID(ByVal id As Guid) As MessaggiDS.MessaggioStatoRow

        DiagnosticsHelper.WriteDiagnostics("MessaggioAdapter.GetStatoByID()")

        Dim row As MessaggiDS.MessaggioStatoRow = Nothing

        Using ta As New MessaggiDSTableAdapters.MessaggioStatoTableAdapter()
            ta.Connection = Connection
            ta.Transaction = Transaction

            Dim dt As MessaggiDS.MessaggioStatoDataTable = ta.GetDataByID(id)
            If dt.Rows.Count > 0 Then
                row = dt.First()
            End If
        End Using

        Return row
    End Function

    Public Function GetMessaggiStatoByIdOrdineErogatoTestata(ByVal id As Guid) As MessaggiDS.MessaggioStatoDataTable

        DiagnosticsHelper.WriteDiagnostics("MessaggioAdapter.GetStatoByIdOrdineErogatoTestata()")

        Dim dt As MessaggiDS.MessaggioStatoDataTable = Nothing

        Using ta As New MessaggiDSTableAdapters.MessaggioStatoTableAdapter()
            ta.Connection = Connection
            ta.Transaction = Transaction

            dt = ta.GetDataByIdOrdineErogatoTestata(id)
        End Using

        Return dt
    End Function


    Public Function MessaggioOrdineInsert(ticket As Guid, obj As Wcf.WsTypes.OrdineType,
                                                          stato As MessaggioAdapter.Stato,
                                                          statoOrderEntry As String,
                                                          Optional idOrdineTestata As Nullable(Of Guid) = Nothing,
                                                          Optional fault As RichiestaFault = Nothing,
                                                          Optional dettaglioErrore As String = Nothing) As Nullable(Of Guid)

        DiagnosticsHelper.WriteDiagnostics("MessaggioAdapter.MessaggioOrdineInsert()")

        Dim id As Nullable(Of Guid)

        Try
            ' Cerco sistema richiedente
            Dim sistemaRichiedente As OrganigrammaDS.SistemaRow = Nothing
            Dim IdSistemaRichiedente As Guid = Nothing

            Using adapter As New OrganigrammaAdapter(ConfigurationHelper.ConnectionString)
                '
                ' Cerco per sistema + azienda (codice)
                '
                sistemaRichiedente = adapter.GetSistemaByCodice(obj.SistemaRichiedente.Sistema.Codice, obj.SistemaRichiedente.Azienda.Codice)
                If sistemaRichiedente IsNot Nothing Then
                    '
                    ' Id del sistema
                    '
                    IdSistemaRichiedente = sistemaRichiedente.ID
                End If
            End Using

            ' Fault
            Dim faultXML As String = Nothing
            Try
                If fault IsNot Nothing Then
                    faultXML = DataContractSerializerHelper.GetXML(fault)
                End If
            Catch
            End Try

            CoreMessaggiRichiesteInsert3(IDTicketInserimento:=ticket,
                                         IDOrdineTestata:=idOrdineTestata,
                                         IDSistemaRichiedente:=IdSistemaRichiedente,
                                         IDRichiestaRichiedente:=obj.IdRichiestaRichiedente,
                                         Messaggio:=DataContractSerializerHelper.GetXML(obj),
                                         Stato:=stato,
                                         StatoOrderEntry:=statoOrderEntry,
                                         Fault:=faultXML,
                                         DettaglioErrore:=dettaglioErrore,
                                         ID:=id)

            Return id
        Catch ex As Exception

            DiagnosticsHelper.WriteWarning(ex)
        End Try
    End Function

    Public Function MessaggioOrdineInsert(ticket As Guid, obj As Msg.RichiestaParameterTypes.RichiestaParameter,
                                                        stato As MessaggioAdapter.Stato,
                                                        statoOrderEntry As String,
                                                        idOrdineTestata As Nullable(Of Guid),
                                                        fault As RichiestaFault,
                                                        dettaglioErrore As String) As Nullable(Of Guid)

        DiagnosticsHelper.WriteDiagnostics("MessaggioAdapter.MessaggioOrdineInsert()")

        Dim id As Nullable(Of Guid)

        Try
            ' Cerco sistema richiedente
            Dim sistemaRichiedente As OrganigrammaDS.SistemaRow = Nothing
            Dim IdSistemaRichiedente As Guid = Nothing

            Dim testataRichiesta = obj.RichiestaQueue.Testata

            Using adapter As New OrganigrammaAdapter(ConfigurationHelper.ConnectionString)
                '
                ' Cerco per sistema + azienda (codice)
                '
                sistemaRichiedente = adapter.GetSistemaByCodice(testataRichiesta.SistemaRichiedente.Sistema.Codice, testataRichiesta.SistemaRichiedente.Azienda.Codice)
                If sistemaRichiedente IsNot Nothing Then
                    '
                    ' Id del sistema
                    '
                    IdSistemaRichiedente = sistemaRichiedente.ID
                End If
            End Using

            ' Fault
            Dim faultXML As String = Nothing
            Try
                If fault IsNot Nothing Then
                    faultXML = DataContractSerializerHelper.GetXML(fault)
                End If
            Catch
            End Try

            CoreMessaggiRichiesteInsert3(IDTicketInserimento:=ticket,
                                         IDOrdineTestata:=idOrdineTestata,
                                         IDSistemaRichiedente:=IdSistemaRichiedente,
                                         IDRichiestaRichiedente:=testataRichiesta.IdRichiestaRichiedente,
                                         Messaggio:=DataContractSerializerHelper.GetXML(obj),
                                         Stato:=stato,
                                         StatoOrderEntry:=statoOrderEntry,
                                         Fault:=faultXML,
                                         DettaglioErrore:=dettaglioErrore,
                                         ID:=id)
            Return id
        Catch ex As Exception

            DiagnosticsHelper.WriteWarning(ex)
        End Try
    End Function

    Public Sub MessaggioOrdineUpdate(ticket As Guid, ByVal id As Nullable(Of Guid), stato As MessaggioAdapter.Stato,
                                     Optional idOrdineTestata As Nullable(Of Guid) = Nothing,
                                     Optional fault As RichiestaFault = Nothing,
                                     Optional dettaglioErrore As String = Nothing)

        DiagnosticsHelper.WriteDiagnostics("MessaggioAdapter.MessaggioOrdineUpdate()")

        Try
            Dim faultXML As String = Nothing
            Try
                If fault IsNot Nothing Then
                    faultXML = DataContractSerializerHelper.GetXML(fault)
                End If
            Catch
            End Try

            CoreMessaggiRichiesteUpdateByID2(IDTicketModifica:=ticket,
                                             ID:=id,
                                             IDOrdineTestata:=idOrdineTestata,
                                             Stato:=stato,
                                             Fault:=faultXML,
                                             DettaglioErrore:=dettaglioErrore)
        Catch ex As Exception

            DiagnosticsHelper.WriteWarning(ex)
        End Try
    End Sub


    Public Function MessaggioStatoInsert(ticket As Guid, obj As Msg.StatoParameterTypes.StatoParameter,
                                                         stato As Byte,
                                                         statoOrderEntry As String,
                                                         tipoStato As String) As Nullable(Of Guid)

        DiagnosticsHelper.WriteDiagnostics("MessaggioAdapter.MessaggioStatoInsert()")

        Dim id As Nullable(Of Guid)

        Try
            Dim idSistemaRichiedente As Nullable(Of Guid) = Nothing
            '
            ' Se specificato cerco il sistema richedente
            '
            Dim objSistema As Msg.QueueTypes.SistemaType = obj.StatoQueue.Testata.SistemaRichiedente

            If objSistema IsNot Nothing AndAlso
                    Not String.IsNullOrEmpty(objSistema.Azienda.Codice) AndAlso
                    Not String.IsNullOrEmpty(objSistema.Sistema.Codice) Then

                Using adapter As New OrganigrammaAdapter(ConfigurationHelper.ConnectionString)
                    '
                    ' Cerca per sistema + azienda (codice)
                    '
                    Dim sistemaRichiedente As OrganigrammaDS.SistemaRow = Nothing
                    sistemaRichiedente = adapter.GetSistemaByCodice(objSistema.Sistema.Codice, objSistema.Azienda.Codice)
                    If sistemaRichiedente IsNot Nothing Then
                        '
                        ' Id del sistema
                        '
                        idSistemaRichiedente = sistemaRichiedente.ID
                    End If
                End Using
            End If

            CoreMessaggiStatiInsert2(IDTicketInserimento:=ticket,
                                     IDSistemaRichiedente:=idSistemaRichiedente,
                                     IDRichiestaRichiedente:=obj.StatoQueue.Testata.IdRichiestaRichiedente,
                                     Messaggio:=DataContractSerializerHelper.GetXML(obj),
                                     Stato:=stato,
                                     StatoOrderEntry:=statoOrderEntry,
                                     TipoStato:=tipoStato,
                                     ID:=id)

            Return id
        Catch ex As Exception

            DiagnosticsHelper.WriteWarning(ex)
        End Try
    End Function

    Public Sub MessaggioStatoUpdate(ticket As Guid, id As Nullable(Of Guid),
                                                    stato As MessaggioAdapter.Stato,
                                                    idOrdineErogatoTestata As Nullable(Of Guid),
                                                    fault As StatoFault,
                                                    dettaglioErrore As String)

        DiagnosticsHelper.WriteDiagnostics("MessaggioAdapter.MessaggioStatoUpdate()")

        Try

            ' Fault
            Dim faultXML As String = Nothing
            Try
                If fault IsNot Nothing Then
                    faultXML = DataContractSerializerHelper.GetXML(fault)
                End If
            Catch
            End Try

            CoreMessaggiStatiUpdateByID2(IDTicketModifica:=ticket,
                                         ID:=id,
                                         IDOrdineErogatoTestata:=idOrdineErogatoTestata,
                                         Stato:=stato,
                                         Fault:=faultXML,
                                         DettaglioErrore:=dettaglioErrore)
        Catch ex As Exception

            DiagnosticsHelper.WriteWarning(ex)
        End Try
    End Sub


    Public Function MessaggioOrdineInsert(ticket As Guid, obj As Wcf.WsTypes.RigaRichiestaType,
                                                          stato As MessaggioAdapter.Stato,
                                                          statoOrderEntry As String,
                                                          Optional idOrdineTestata As Nullable(Of Guid) = Nothing,
                                                          Optional fault As RichiestaFault = Nothing,
                                                          Optional dettaglioErrore As String = Nothing) As Nullable(Of Guid)

        DiagnosticsHelper.WriteDiagnostics("MessaggioAdapter.MessaggioOrdineInsert()")

        Dim id As Nullable(Of Guid)

        Try
            ' Fault
            Dim faultXML As String = Nothing
            Try
                If fault IsNot Nothing Then
                    faultXML = DataContractSerializerHelper.GetXML(fault)
                End If
            Catch
            End Try

            CoreMessaggiRichiesteInsert3(IDTicketInserimento:=ticket,
                                         IDOrdineTestata:=idOrdineTestata,
                                         IDSistemaRichiedente:=Nothing,
                                         IDRichiestaRichiedente:=Nothing,
                                         Messaggio:=DataContractSerializerHelper.GetXML(obj),
                                         Stato:=stato,
                                         StatoOrderEntry:=statoOrderEntry,
                                         Fault:=faultXML,
                                         DettaglioErrore:=dettaglioErrore,
                                         ID:=id)

            Return id
        Catch ex As Exception

            DiagnosticsHelper.WriteWarning(ex)
        End Try
    End Function


End Class