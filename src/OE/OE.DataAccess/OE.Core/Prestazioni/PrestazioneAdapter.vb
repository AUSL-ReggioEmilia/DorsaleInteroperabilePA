Imports System.Data.SqlClient

Imports Msg = OE.Core.Schemas.Msg

#If CONFIG = "Release 1.2" Or CONFIG = "Debug 1.2" Then
'Versione 1.2
Imports Wcf = OE.Core.Schemas.Wcf12
#Else
'Versione 1.0 e 1.1
Imports Wcf = OE.Core.Schemas.Wcf
#End If

Public Class PrestazioneAdapter
    Inherits PrestazioniDSTableAdapters.CommandsAdapter
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

        DiagnosticsHelper.WriteDiagnostics("PrestazioneAdapter.SetCommandsConnection()")

        For Each commands As IDbCommand In MyBase.CommandCollection

            If _connection IsNot Nothing AndAlso _connection.State = ConnectionState.Closed Then
                _connection.Open()
            End If

            ' Imposto tutti i commands sulla stessa connessione
            commands.Connection = _connection
        Next
    End Sub

    Public Sub BeginTransaction(ByVal isolationLevel As IsolationLevel) Implements IAdapter.BeginTransaction

        DiagnosticsHelper.WriteDiagnostics("PrestazioneAdapter.BeginTransaction()")

        If _connection.State = ConnectionState.Closed Then

            Throw New Exception("Errore durante PrestazioneAdapter.BeginTransaction(). La connessione al database è chiusa!")
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

        DiagnosticsHelper.WriteDiagnostics("PrestazioneAdapter.Commit()")

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

        DiagnosticsHelper.WriteDiagnostics("PrestazioneAdapter.Rollback()")

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

        DiagnosticsHelper.WriteDiagnostics("PrestazioneAdapter.Disposed()")

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

        DiagnosticsHelper.WriteDiagnostics("PrestazioneAdapter.New()")

        If _connection Is Nothing Then
            _bCanDisposeConnection = True
            _connection = New SqlClient.SqlConnection(connectionString)
        End If

        ' Imposto tutti i commands sulla stessa connessione
        SetCommandsConnection()
    End Sub

    Public Sub New(ByVal connection As SqlConnection, ByVal transaction As SqlTransaction, ByVal isolationLevel As IsolationLevel)
        MyBase.New()

        DiagnosticsHelper.WriteDiagnostics("PrestazioneAdapter.New()")

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

#Region "Prestazioni Lista profili"

    Public Function GetPrestazioneListaType(ByVal id As Guid) As Wcf.WsTypes.PrestazioneListaType
        DiagnosticsHelper.WriteDiagnostics("PrestazioneAdapter.GetPrestazioneListaType()")

        Dim result As Wcf.WsTypes.PrestazioneListaType = Nothing

        Using ta As New PrestazioniDSTableAdapters.PrestazioneTableAdapter()
            ta.Connection = Connection
            ta.Transaction = Transaction

            ' Cerco le prestazione
            Dim dt As PrestazioniDS.PrestazioneDataTable = ta.GetDataByID(id)
            If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
                'Ritorna il primo
                result = dt.First.ToPrestazioneListaType
            End If
        End Using

        Return result

    End Function

    Public Function GetPrestazioniByCodiceOrDescrizione(utente As String, idUnitaOperativa As Guid?, idSistemaRichiedente As Guid?,
                                                        idSistemaErogante As Guid?, codiceRegime As String, codicePriorita As String,
                                                        idStato As Byte?, valore As String) As Wcf.WsTypes.PrestazioniListaType

        DiagnosticsHelper.WriteDiagnostics("PrestazioneAdapter.GetPrestazioniByCodiceOrDescrizione()")

        Dim result As Wcf.WsTypes.PrestazioniListaType = Nothing

        'Converto empty in nothing
        If idUnitaOperativa.HasValue AndAlso idUnitaOperativa = Guid.Empty Then idUnitaOperativa = Nothing
        If idSistemaRichiedente.HasValue AndAlso idSistemaRichiedente = Guid.Empty Then idSistemaRichiedente = Nothing
        If idSistemaErogante.HasValue AndAlso idSistemaErogante = Guid.Empty Then idSistemaErogante = Nothing

        Using ta As New PrestazioniDSTableAdapters.PrestazioniTableAdapter()
            ta.Connection = Connection
            ta.Transaction = Transaction

            ' Cerco le prestazioni
            Dim dt As PrestazioniDS.PrestazioniDataTable = ta.GetDataByCodiceDescrizione(utente, idUnitaOperativa, idSistemaRichiedente, _
                                                                                        idSistemaErogante, codiceRegime, codicePriorita, _
                                                                                        idStato, valore)
            If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
                ' Creo la lista
                result = dt.ToPrestazioniListaType
            End If
        End Using

        Return result
    End Function

    Public Function GetPrestazioniByCodiceDescrizioneAndSistemaErogante(utente As String, idUnitaOperativa As Guid?, idSistemaRichiedente As Guid?, _
                                                                        idSistemaErogante As Guid?, codiceRegime As String, codicePriorita As String, _
                                                                        idStato As Byte?, valore As String) As Wcf.WsTypes.PrestazioniListaType

        DiagnosticsHelper.WriteDiagnostics("PrestazioneAdapter.GetPrestazioniByCodiceDescrizioneAndSistemaErogante()")

        Dim result As Wcf.WsTypes.PrestazioniListaType = Nothing

        'Converto empty in nothing
        If idUnitaOperativa.HasValue AndAlso idUnitaOperativa = Guid.Empty Then idUnitaOperativa = Nothing
        If idSistemaRichiedente.HasValue AndAlso idSistemaRichiedente = Guid.Empty Then idSistemaRichiedente = Nothing
        If idSistemaErogante.HasValue AndAlso idSistemaErogante = Guid.Empty Then idSistemaErogante = Nothing

        Using ta As New PrestazioniDSTableAdapters.PrestazioniTableAdapter()
            ta.Connection = Connection
            ta.Transaction = Transaction

            ' Cerco le prestazioni
            Dim dt As PrestazioniDS.PrestazioniDataTable = ta.GetDataBySistemaErogante(utente, idUnitaOperativa, idSistemaRichiedente, _
                                                                                        idSistemaErogante, codiceRegime, codicePriorita, _
                                                                                        idStato, valore)
            If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
                ' Creo la lista
                result = dt.ToPrestazioniListaType
            End If
        End Using

        Return result
    End Function

    Public Function GetPrestazioniByCodiceDescrizioneAndUnitaOperativa(utente As String, idUnitaOperativa As Guid?, idSistemaRichiedente As Guid?, _
                                                                       idSistemaErogante As Guid?, codiceRegime As String, codicePriorita As String, _
                                                                       idStato As Byte?, valore As String) As Wcf.WsTypes.PrestazioniListaType

        DiagnosticsHelper.WriteDiagnostics("PrestazioneAdapter.GetPrestazioniByCodiceDescrizioneAndUnitaOperativa()")

        Dim result As Wcf.WsTypes.PrestazioniListaType = Nothing

        'Converto empty in nothing
        If idUnitaOperativa.HasValue AndAlso idUnitaOperativa = Guid.Empty Then idUnitaOperativa = Nothing
        If idSistemaRichiedente.HasValue AndAlso idSistemaRichiedente = Guid.Empty Then idSistemaRichiedente = Nothing
        If idSistemaErogante.HasValue AndAlso idSistemaErogante = Guid.Empty Then idSistemaErogante = Nothing

        Using ta As New PrestazioniDSTableAdapters.PrestazioniTableAdapter()
            ta.Connection = Connection
            ta.Transaction = Transaction
            '
            ' Cerco le prestazioni
            '
            Dim dt As PrestazioniDS.PrestazioniDataTable = ta.GetDataByUnitaOperativa(utente, idUnitaOperativa, idSistemaRichiedente, _
                                                                                    idSistemaErogante, codiceRegime, codicePriorita, _
                                                                                    idStato, valore)
            If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
                ' Creo la lista
                result = dt.ToPrestazioniListaType
            End If
        End Using

        Return result
    End Function

    Public Function GetPrestazioniByPaziente(utente As String, idUnitaOperativa As Guid?, idSistemaRichiedente As Guid?, _
                                             idSistemaErogante As Guid?, codiceRegime As String, codicePriorita As String, _
                                             idStato As Byte?, idPaziente As Guid, valore As String) As Wcf.WsTypes.PrestazioniListaType

        DiagnosticsHelper.WriteDiagnostics("PrestazioneAdapter.GetPrestazioniByPaziente()")

        If Guid.Equals(idPaziente, Guid.Empty) Then
            Throw New OrderEntryArgumentNullException("idPaziente")
        End If

        Dim result As Wcf.WsTypes.PrestazioniListaType = Nothing

        'Converto empty in nothing
        If idUnitaOperativa.HasValue AndAlso idUnitaOperativa = Guid.Empty Then idUnitaOperativa = Nothing
        If idSistemaRichiedente.HasValue AndAlso idSistemaRichiedente = Guid.Empty Then idSistemaRichiedente = Nothing
        If idSistemaErogante.HasValue AndAlso idSistemaErogante = Guid.Empty Then idSistemaErogante = Nothing

        Using ta As New PrestazioniDSTableAdapters.PrestazioniTableAdapter()
            ta.Connection = Connection
            ta.Transaction = Transaction

            ' Cerco le prestazioni
            Dim dt As PrestazioniDS.PrestazioniDataTable = ta.GetDataByPaziente(utente, idUnitaOperativa, idSistemaRichiedente, idSistemaErogante, _
                                                                                codiceRegime, codicePriorita, idStato, idPaziente, valore)
            If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
                ' Creo la lista
                result = dt.ToPrestazioniListaType
            End If
        End Using

        Return result

    End Function

    Public Function GetPrestazioniByGruppoPrestazioni(utente As String, idUnitaOperativa As Guid?, idSistemaRichiedente As Guid?,
                                        idSistemaErogante As Guid?, codiceRegime As String, codicePriorita As String,
                                        idStato As Byte?, idGruppoPrestazioni As Guid?, valore As String) As Wcf.WsTypes.PrestazioniListaType

        DiagnosticsHelper.WriteDiagnostics("PrestazioneAdapter.GetPrestazioniByCodiceOrDescrizione()")

        Dim result As Wcf.WsTypes.PrestazioniListaType = Nothing

        'Converto empty in nothing
        If idUnitaOperativa.HasValue AndAlso idUnitaOperativa = Guid.Empty Then idUnitaOperativa = Nothing
        If idSistemaRichiedente.HasValue AndAlso idSistemaRichiedente = Guid.Empty Then idSistemaRichiedente = Nothing
        If idSistemaErogante.HasValue AndAlso idSistemaErogante = Guid.Empty Then idSistemaErogante = Nothing

        Using ta As New PrestazioniDSTableAdapters.PrestazioniTableAdapter()
            ta.Connection = Connection
            ta.Transaction = Transaction

            ' Cerco le prestazioni
            Dim dt As PrestazioniDS.PrestazioniDataTable = ta.GetDataByIdGruppo(utente, idUnitaOperativa, idSistemaRichiedente, _
                                                                                idSistemaErogante, codiceRegime, codicePriorita, _
                                                                                idStato, idGruppoPrestazioni, valore)
            If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
                ' Creo la lista
                result = dt.ToPrestazioniListaType
            End If
        End Using

        Return result
    End Function


#End Region

#Region "Prestazioni Check"

    Public Function GetPrestazioniCheckByIds(ids As String, utente As String, _
                                            idUnitaOperativa As Guid?, idSistemaRichiedente As Guid?,
                                            codiceRegime As String, codicePriorita As String, _
                                            accesso As Wcf.BaseTypes.TipoAccessoEnum) As List(Of PrestazioniDS.PrestazioniCheckRow)

        DiagnosticsHelper.WriteDiagnostics("PrestazioneAdapter.GetPrestazioniCheckByIds()")

        If String.IsNullOrEmpty(ids) Then
            Throw New OrderEntryArgumentNullException("ids")
        End If

        If String.IsNullOrEmpty(utente) Then
            Throw New OrderEntryArgumentNullException("utente")
        End If

        Dim result As List(Of PrestazioniDS.PrestazioniCheckRow) = Nothing

        Using ta As New PrestazioniDSTableAdapters.PrestazioniCheckTableAdapter()
            ta.Connection = Connection
            ta.Transaction = Transaction

            Dim dt As PrestazioniDS.PrestazioniCheckDataTable = ta.GetDataByIds(ids, utente, idUnitaOperativa, idSistemaRichiedente, codiceRegime, codicePriorita, accesso.ToString)
            If dt.Rows.Count > 0 Then
                result = New List(Of PrestazioniDS.PrestazioniCheckRow)
                result.AddRange(dt.Rows.Cast(Of PrestazioniDS.PrestazioniCheckRow))
            End If
        End Using

        Return result
    End Function

#End Region

#Region "Prestazioni gerarchia profili"

    Public Function GetPrestazioniErogabiliGerarchiaByIDProfilo(ByVal idProfilo As Guid, Utente As String,
                                            idUnitaOperativa As Guid, idSistemaRichiedente As Guid,
                                            dataoraRichiesta As DateTime,
                                            codiceRegime As String, codicePriorita As String) As Wcf.WsTypes.PrestazioniErogabiliType

        'Ritorna tutta la gerarchia dei profili
        DiagnosticsHelper.WriteDiagnostics("PrestazioneAdapter.GetPrestazioniErogabiliGerarchiaByIDProfilo()")

        Dim result As Wcf.WsTypes.PrestazioniErogabiliType = Nothing

        Using ta As New PrestazioniDSTableAdapters.PrestazioneTableAdapter()
            ta.Connection = Connection
            ta.Transaction = Transaction
            '
            ' Cerco prestazioni
            '
            Dim dt As PrestazioniDS.PrestazioneDataTable = ta.GetDataByIdProfilo(idProfilo)
            If dt.Rows.Count > 0 Then

                Using adapterDatoAccessorio As New DatoAccessorioAdapter(Me.Connection.ConnectionString)
                    '
                    ' Creo lista
                    '
                    result = New Wcf.WsTypes.PrestazioniErogabiliType()

                    For Each row In dt
                        '
                        ' Controllo tutte le righe
                        '
                        Dim datiAccessori As Wcf.WsTypes.DatiAccessoriType = Nothing
                        datiAccessori = adapterDatoAccessorio.GetDatiAccessoriByIdPrestazione(row.ID, Utente, idUnitaOperativa, idSistemaRichiedente,
                                                                                              dataoraRichiesta, codiceRegime, codicePriorita)
                        If datiAccessori Is Nothing Then
                            datiAccessori = New Wcf.WsTypes.DatiAccessoriType()
                        End If

                        Dim prestazioniProfilo As Wcf.WsTypes.PrestazioniErogabiliType = Nothing
                        If row.Tipo <> Wcf.WsTypes.TipoPrestazioneErogabileEnum.Prestazione Then
                            prestazioniProfilo = GetPrestazioniErogabiliByProfilo(row.ID, Utente, idUnitaOperativa, idSistemaRichiedente,
                                                                                  dataoraRichiesta, codiceRegime, codicePriorita)
                        End If
                        '
                        ' Aggiungo alla lista
                        '
                        result.Add(row.ToPrestazioneErogabiliType(prestazioniProfilo, datiAccessori))
                    Next
                End Using ' DatoAccessorioAdapter

            End If
        End Using ' PrestazioniTableAdapter

        Return result

    End Function

#End Region

#Region "Prestazioni e profili con accessi"

    Public Function GetPrestazioniErogabiliByIDs(ByVal ids As String, Utente As String,
                                            idUnitaOperativa As Guid, idSistemaRichiedente As Guid,
                                            dataoraRichiesta As DateTime,
                                            codiceRegime As String, codicePriorita As String) As Wcf.WsTypes.PrestazioniErogabiliType

        DiagnosticsHelper.WriteDiagnostics("PrestazioneAdapter.GetPrestazioni()")

        If String.IsNullOrEmpty(ids) Then
            Throw New OrderEntryArgumentNullException("ids")
        End If

        Dim result As Wcf.WsTypes.PrestazioniErogabiliType = Nothing

        Using ta As New PrestazioniDSTableAdapters.PrestazioneTableAdapter()
            ta.Connection = Connection
            ta.Transaction = Transaction
            '
            ' Cerco prestazioni
            '
            Dim dt As PrestazioniDS.PrestazioneDataTable = ta.GetDataByIDs(ids)
            If dt.Rows.Count > 0 Then
                ' Creo lista
                result = New Wcf.WsTypes.PrestazioniErogabiliType()

                Using adapterDatoAccessorio As New DatoAccessorioAdapter(Me.Connection.ConnectionString)
                    For Each row In dt
                        '
                        ' Dati accessori, se è un profilo sarà il distinct
                        '
                        Dim datiAccessori As Wcf.WsTypes.DatiAccessoriType = Nothing
                        datiAccessori = adapterDatoAccessorio.GetDatiAccessoriByIdPrestazione(row.ID, Utente, idUnitaOperativa, idSistemaRichiedente,
                                                                                              dataoraRichiesta, codiceRegime, codicePriorita)
                        If datiAccessori Is Nothing Then
                            '
                            ' Se non ci sono, almeno la lista vuota
                            '
                            datiAccessori = New Wcf.WsTypes.DatiAccessoriType()
                        End If
                        '
                        ' Se un profilo cerco le prestazioni
                        '
                        Dim prestazioniErogabili As Wcf.WsTypes.PrestazioniErogabiliType = Nothing
                        If row.Tipo <> Wcf.WsTypes.TipoPrestazioneErogabileEnum.Prestazione Then
                            prestazioniErogabili = GetPrestazioniErogabiliByProfilo(row.ID, Utente, idUnitaOperativa, idSistemaRichiedente,
                                                                                    dataoraRichiesta, codiceRegime, codicePriorita)
                        End If
                        '
                        ' Creo Type PrestazioneErogabile e aggiungo alla lista
                        '
                        result.Add(row.ToPrestazioneErogabiliType(prestazioniErogabili, datiAccessori))
                    Next
                End Using 'adapterDatoAccessorio

            End If
        End Using ' PrestazioniTableAdapter

        Return result
    End Function

    Public Function GetPrestazioneErogabileByID(ByVal id As Guid, Utente As String,
                                            idUnitaOperativa As Guid, idSistemaRichiedente As Guid,
                                            dataoraRichiesta As DateTime,
                                            codiceRegime As String, codicePriorita As String) As Wcf.WsTypes.PrestazioneErogabileType

        DiagnosticsHelper.WriteDiagnostics("PrestazioneAdapter.GetErogabileByID()")

        Dim result As Wcf.WsTypes.PrestazioneErogabileType = Nothing

        Using ta As New PrestazioniDSTableAdapters.PrestazioneTableAdapter()
            ta.Connection = Connection
            ta.Transaction = Transaction

            Dim dt As PrestazioniDS.PrestazioneDataTable = ta.GetDataByID(id)
            If dt.Rows.Count > 0 Then
                Dim row As PrestazioniDS.PrestazioneRow = dt.First()
                '
                ' Dati accessori, se è un profilo sarà il distinct
                '
                Dim datiAccessori As Wcf.WsTypes.DatiAccessoriType = Nothing

                Using adapter As New DatoAccessorioAdapter(Me.Connection.ConnectionString)

                    datiAccessori = adapter.GetDatiAccessoriByIdPrestazione(row.ID, Utente, idUnitaOperativa, idSistemaRichiedente,
                                                                            dataoraRichiesta, codiceRegime, codicePriorita)
                    If datiAccessori Is Nothing Then
                        '
                        ' Se non ci sono, almeno la lista vuota
                        '
                        datiAccessori = New Wcf.WsTypes.DatiAccessoriType()
                    End If
                End Using
                '
                ' Se un profilo cerco le prestazioni
                '
                Dim prestazioniErogabili As Wcf.WsTypes.PrestazioniErogabiliType = Nothing
                If row.Tipo <> Wcf.WsTypes.TipoPrestazioneErogabileEnum.Prestazione Then
                    prestazioniErogabili = GetPrestazioniErogabiliByProfilo(row.ID, Utente, idUnitaOperativa, idSistemaRichiedente,
                                                                            dataoraRichiesta, codiceRegime, codicePriorita)
                End If
                '
                ' Creo Type PrestazioneErogabile e aggiungo alla lista
                '
                result = row.ToPrestazioneErogabiliType(prestazioniErogabili, datiAccessori)
            End If
        End Using

        Return result
    End Function

    Public Function GetPrestazioneErogabileByCodice(ByVal codice As String, idSistemaErogante As Guid, Utente As String,
                                            idUnitaOperativa As Guid, idSistemaRichiedente As Guid,
                                            dataoraRichiesta As DateTime,
                                            codiceRegime As String, codicePriorita As String) As Wcf.WsTypes.PrestazioneErogabileType

        DiagnosticsHelper.WriteDiagnostics("PrestazioneAdapter.GetErogabileByCodice()")

        If String.IsNullOrEmpty(codice) Then
            Throw New OrderEntryArgumentNullException("codice")
        End If

        Dim result As Wcf.WsTypes.PrestazioneErogabileType = Nothing

        Using ta As New PrestazioniDSTableAdapters.PrestazioneTableAdapter()
            ta.Connection = Connection
            ta.Transaction = Transaction

            Dim dt As PrestazioniDS.PrestazioneDataTable = ta.GetDataBySistemaErogante(codice, idSistemaErogante)
            If dt.Rows.Count > 0 Then
                Dim row As PrestazioniDS.PrestazioneRow = dt.First()
                '
                ' Dati accessori, se è un profilo sarà il distinct
                '
                Dim datiAccessori As Wcf.WsTypes.DatiAccessoriType = Nothing

                Using adapter As New DatoAccessorioAdapter(Me.Connection.ConnectionString)
                    datiAccessori = adapter.GetDatiAccessoriByIdPrestazione(row.ID, Utente, idUnitaOperativa, idSistemaRichiedente,
                                                                            dataoraRichiesta, codiceRegime, codicePriorita)
                    If datiAccessori Is Nothing Then
                        '
                        ' Se non ci sono, almeno la lista vuota
                        '
                        datiAccessori = New Wcf.WsTypes.DatiAccessoriType()
                    End If
                End Using
                '
                ' Se un profilo cerco le prestazioni
                '
                Dim prestazioniErogabili As Wcf.WsTypes.PrestazioniErogabiliType = Nothing
                If row.Tipo <> Wcf.WsTypes.TipoPrestazioneErogabileEnum.Prestazione Then
                    prestazioniErogabili = GetPrestazioniErogabiliByProfilo(row.ID, Utente, idUnitaOperativa, idSistemaRichiedente,
                                                                            dataoraRichiesta, codiceRegime, codicePriorita)
                End If
                '
                ' Creo Type PrestazioneErogabile e aggiungo alla lista
                '
                result = row.ToPrestazioneErogabiliType(prestazioniErogabili, datiAccessori)
            End If
        End Using

        Return result
    End Function

    Private Function GetPrestazioniErogabiliByProfilo(idProfilo As Guid, Utente As String,
                                                        idUnitaOperativa As Guid, idSistemaRichiedente As Guid,
                                                        dataoraRichiesta As DateTime,
                                                        codiceRegime As String, codicePriorita As String) As Wcf.WsTypes.PrestazioniErogabiliType
        '
        'RECURSIVA per gestire profili di profili
        'Ritorna le prestazioni del profilo senza gerarchia dei sottoprofili
        ' 2018-08-28: Migliorate le prestazioni. Rimossa query su SQL durante il loop
        '               Cerca tutti i dati accessori con una unica query
        '
        DiagnosticsHelper.WriteDiagnostics("PrestazioneAdapter.GetPrestazioniErogabiliByProfilo()")

        Dim result As Wcf.WsTypes.PrestazioniErogabiliType = Nothing
        Dim datiAccessoriAll As Wcf.WsTypes.DatiAccessoriType = Nothing

        Using ta As New PrestazioniDSTableAdapters.PrestazioniProfiliTableAdapter()
            ta.Connection = Connection
            ta.Transaction = Transaction

            ' Cerca le prestazioni
            Dim dt As PrestazioniDS.PrestazioniProfiliDataTable = ta.GetData(idProfilo)
            If dt.Rows.Count > 0 Then
                '
                ' Crea lista
                '
                result = New Wcf.WsTypes.PrestazioniErogabiliType()

                Using adapterDatoAccessorio As New DatoAccessorioAdapter(Me.Connection.ConnectionString)
                    '
                    ' Array di ID per cercare i dati acessori di tutte le prestazioni
                    '
                    Dim arrayIds() As Guid = dt.AsEnumerable().Select(Function(e) e.ID).ToArray
                    datiAccessoriAll = adapterDatoAccessorio.GetDatiAccessoriByIdPrestazioni(arrayIds, Utente, idUnitaOperativa, idSistemaRichiedente,
                                                                                                dataoraRichiesta, codiceRegime, codicePriorita)
                End Using
                '
                ' Tutte le righe
                '
                For Each row In dt
                    '
                    ' 2018-08-28 Cerco nella lista di tutti invece di una query specifica per Id
                    '
                    Dim datiAccessori As Wcf.WsTypes.DatiAccessoriType = New Wcf.WsTypes.DatiAccessoriType()
                    datiAccessori.AddRange(datiAccessoriAll.Where(Function(e) e.internal_IdPrestazione = row.ID))
                    '
                    ' Se è un profilo cerca recursivo
                    '
                    Dim prestazioniErogabili As Wcf.WsTypes.PrestazioniErogabiliType = Nothing
                    If row.Tipo <> Wcf.WsTypes.TipoPrestazioneErogabileEnum.Prestazione Then
                        prestazioniErogabili = GetPrestazioniErogabiliByProfilo(row.ID, Utente, idUnitaOperativa, idSistemaRichiedente,
                                                                                dataoraRichiesta, codiceRegime, codicePriorita)
                    End If

                    'Aggiungo al risultato
                    result.Add(row.ToPrestazioneErogabiliType(prestazioniErogabili, datiAccessori))
                Next
            End If
        End Using

        Return result

    End Function

#End Region

#Region "Gruppi di prestazioni"

    Public Function GetGruppiPrestazioniByDescrizione(utente As String, idUnitaOperativa As Guid?, idSistemaRichiedente As Guid?, _
                                                    codiceRegime As String, codicePriorita As String, idStato As Byte?,
                                                    valore As String) As Wcf.WsTypes.GruppiPrestazioniListaType

        DiagnosticsHelper.WriteDiagnostics("PrestazioneAdapter.GetGruppiPrestazioniByDescrizione()")

        'Converto empty in nothing
        If idUnitaOperativa.HasValue AndAlso idUnitaOperativa = Guid.Empty Then idUnitaOperativa = Nothing
        If idSistemaRichiedente.HasValue AndAlso idSistemaRichiedente = Guid.Empty Then idSistemaRichiedente = Nothing

        Dim result As Wcf.WsTypes.GruppiPrestazioniListaType = Nothing

        Using ta As New PrestazioniDSTableAdapters.GruppiPrestazioniListaTableAdapter
            ta.Connection = Connection
            ta.Transaction = Transaction
            '
            ' Cerco i gruppi di prestazioni
            '
            Dim dt As PrestazioniDS.GruppiPrestazioniListaDataTable = ta.GetDataByDescrizione(utente, idUnitaOperativa, idSistemaRichiedente, _
                                                                                        codiceRegime, codicePriorita, idStato, valore)
            If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
                ' Creo la lista
                result = dt.ToGruppiPrestazioniListaType
            End If
        End Using

        Return result

    End Function

    Public Function GetGruppoPrestazioniByID(utente As String, idUnitaOperativa As Guid?, idSistemaRichiedente As Guid?, idSistemaErogante As Guid?,
                                            codiceRegime As String, codicePriorita As String, idStato As Byte?,
                                            idGruppoPrestazioni As Guid, valore As String) As Wcf.WsTypes.GruppoPrestazioniType

        DiagnosticsHelper.WriteDiagnostics("PrestazioneAdapter.GetGruppoPrestazioniByID()")

        'Converto empty in nothing
        If idUnitaOperativa.HasValue AndAlso idUnitaOperativa = Guid.Empty Then idUnitaOperativa = Nothing
        If idSistemaRichiedente.HasValue AndAlso idSistemaRichiedente = Guid.Empty Then idSistemaRichiedente = Nothing
        If idSistemaErogante.HasValue AndAlso idSistemaErogante = Guid.Empty Then idSistemaErogante = Nothing

        Dim ret As Wcf.WsTypes.GruppoPrestazioniType = Nothing

        Using ta As New PrestazioniDSTableAdapters.GruppiPrestazioniListaTableAdapter
            ta.Connection = Connection
            ta.Transaction = Transaction

            Dim dt As PrestazioniDS.GruppiPrestazioniListaDataTable = ta.GetDataByIdGruppo(utente, idUnitaOperativa, idSistemaRichiedente, _
                                                    codiceRegime, codicePriorita, idStato, idGruppoPrestazioni)
            If dt.Rows.Count > 0 Then
                Dim row As PrestazioniDS.GruppiPrestazioniListaRow
                row = dt.First

                'Creo root del gruppo
                ret = row.ToGruppoPrestazioniType

                'Lista delle prestazioni del gruppo
                ret.Prestazioni = GetPrestazioniByGruppoPrestazioni(utente, idUnitaOperativa, idSistemaRichiedente, _
                                                    idSistemaErogante, codiceRegime, codicePriorita, idStato, _
                                                    idGruppoPrestazioni, valore)
            End If
        End Using

        Return ret

    End Function

#End Region


#Region "Prestazione select"

    Public Function GetByID(ByVal id As Guid) As PrestazioniDS.PrestazioneRow
        DiagnosticsHelper.WriteDiagnostics("PrestazioneAdapter.GetByID()")

        Dim row As PrestazioniDS.PrestazioneRow = Nothing

        Using ta As New PrestazioniDSTableAdapters.PrestazioneTableAdapter()
            ta.Connection = Connection
            ta.Transaction = Transaction

            Dim dt As PrestazioniDS.PrestazioneDataTable = ta.GetDataByID(id)
            If dt.Rows.Count > 0 Then
                row = dt.First()
            End If
        End Using

        Return row
    End Function

    Public Function GetBySistemaErogante(ByVal codice As String, ByVal idSistemaErogante As Guid) As PrestazioniDS.PrestazioneRow
        DiagnosticsHelper.WriteDiagnostics("PrestazioneAdapter.GetBySistemaErogante()")

        If String.IsNullOrEmpty(codice) Then
            Throw New OrderEntryArgumentNullException("codice")
        End If

        Dim row As PrestazioniDS.PrestazioneRow = Nothing

        Using ta As New PrestazioniDSTableAdapters.PrestazioneTableAdapter()
            ta.Connection = Connection
            ta.Transaction = Transaction

            Dim dt As PrestazioniDS.PrestazioneDataTable = ta.GetDataBySistemaErogante(codice, idSistemaErogante)
            If dt.Rows.Count > 0 Then
                row = dt.First()
            End If
        End Using

        Return row
    End Function

    Public Function GetBySistemaErogante(ByVal codice As String, ByVal codiceAziendaErogante As String, ByVal codiceSistemaErogante As String) As PrestazioniDS.PrestazioneRow
        DiagnosticsHelper.WriteDiagnostics("PrestazioneAdapter.GetBySistemaErogante()")

        If String.IsNullOrEmpty(codice) Then
            Throw New OrderEntryArgumentNullException("codice")
        End If
        '
        ' Get del sistema erogante 
        '
        Dim SistemaEroganteId As Guid

        If String.IsNullOrEmpty(codiceAziendaErogante) AndAlso String.IsNullOrEmpty(codiceSistemaErogante) Then
            'se vuoto torno 0000-00000000-
            SistemaEroganteId = Guid.Empty
        Else
            'se vuoto torno 0000-00000000-
            Dim rowSistemaErogante As OrganigrammaDS.SistemaRow = Nothing

            Using adapter As New OrganigrammaAdapter(Me.Connection.ConnectionString)
                rowSistemaErogante = adapter.GetSistemaByCodice(codiceSistemaErogante, codiceAziendaErogante)
            End Using

            If rowSistemaErogante Is Nothing Then
                '
                ' Errore
                '
                Dim reason As String = String.Format("Il sistema erogante {0}@{1} non è codificato nell'order entry.", _
                                                                                                codiceAziendaErogante, _
                                                                                                codiceSistemaErogante)
                Throw New OrderEntryNotFoundException("Sistema erogante", reason)
            End If

            SistemaEroganteId = rowSistemaErogante.ID
        End If
        '
        ' Get prestazione 
        '
        Dim row As PrestazioniDS.PrestazioneRow = Nothing

        Using ta As New PrestazioniDSTableAdapters.PrestazioneTableAdapter()
            ta.Connection = Connection
            ta.Transaction = Transaction

            Dim dt As PrestazioniDS.PrestazioneDataTable = ta.GetDataBySistemaErogante(codice, SistemaEroganteId)
            If dt.Rows.Count > 0 Then
                row = dt.First()
            End If
        End Using

        Return row

    End Function

    Public Function GetByIDs(ByVal ids() As Guid) As List(Of PrestazioniDS.PrestazioneRow)
        DiagnosticsHelper.WriteDiagnostics("PrestazioneAdapter.GetByIDs()")

        Dim rows As List(Of PrestazioniDS.PrestazioneRow) = Nothing

        'Concateno ID
        Dim sbID As New Text.StringBuilder()
        For Each id In ids
            If sbID.Length > 0 Then
                sbID.Append(",")
            End If
            sbID.Append(id.ToString.ToUpper)
        Next

        ' Query prestazioni se il parametro è compilato
        If sbID.Length > 0 Then
            Using ta As New PrestazioniDSTableAdapters.PrestazioneTableAdapter()
                ta.Connection = Connection
                ta.Transaction = Transaction

                Dim dt As PrestazioniDS.PrestazioneDataTable = ta.GetDataByIDs(sbID.ToString)
                If dt.Rows.Count > 0 Then

                    rows = New List(Of PrestazioniDS.PrestazioneRow)
                    rows.AddRange(dt.Rows.Cast(Of PrestazioniDS.PrestazioneRow))
                End If
            End Using
        End If

        Return rows

    End Function

    Public Function GetByIDsAndCodiceSinonimo(ByVal ids() As String) As List(Of PrestazioniDS.PrestazioneRow)
        DiagnosticsHelper.WriteDiagnostics("PrestazioneAdapter.GetByIDs()")

        Dim rows As List(Of PrestazioniDS.PrestazioneRow) = Nothing

        'Concateno ID
        Dim sbID As New Text.StringBuilder()
        For Each id In ids
            If Not String.IsNullOrEmpty(id) Then
                If sbID.Length > 0 Then
                    sbID.Append(",")
                End If
                sbID.Append(id)
            End If
        Next

        ' Query prestazioni se il parametro è compilato
        If sbID.Length > 0 Then
            Using ta As New PrestazioniDSTableAdapters.PrestazioneTableAdapter()
                ta.Connection = Connection
                ta.Transaction = Transaction

                Dim dt As PrestazioniDS.PrestazioneDataTable = ta.GetDataByIDsAndCodiceSinonimo(sbID.ToString)
                If dt.Rows.Count > 0 Then

                    rows = New List(Of PrestazioniDS.PrestazioneRow)
                    rows.AddRange(dt.Rows.Cast(Of PrestazioniDS.PrestazioneRow))
                End If
            End Using
        End If

        Return rows

    End Function

    Public Function GetByIDGruppo(ByVal id As Guid) As List(Of PrestazioniDS.PrestazioneRow)
        DiagnosticsHelper.WriteDiagnostics("PrestazioneAdapter.GetByIDGruppo()")

        Dim rows As List(Of PrestazioniDS.PrestazioneRow) = Nothing

        ' Query prestazioni se il parametro è compilato
        Using ta As New PrestazioniDSTableAdapters.PrestazioneTableAdapter()
            ta.Connection = Connection
            ta.Transaction = Transaction

            Dim dt As PrestazioniDS.PrestazioneDataTable = ta.GetDataByIdGruppo(id)
            If dt.Rows.Count > 0 Then

                rows = New List(Of PrestazioniDS.PrestazioneRow)
                rows.AddRange(dt.Rows.Cast(Of PrestazioniDS.PrestazioneRow))
            End If
        End Using

        Return rows

    End Function

#End Region

#Region "Consolida inserisce e update"

    Public Function Consolida(ByVal ticket As Guid, ByVal idSistemaErogante As Guid, _
                         ByRef obj As Msg.QueueTypes.PrestazioneType, ByVal forceUpdate As Boolean) As PrestazioniDS.PrestazioneRow

        DiagnosticsHelper.WriteDiagnostics("PrestazioneAdapter.Consolida()")

        Dim prestazione As PrestazioniDS.PrestazioneRow = GetBySistemaErogante(obj.Codice, idSistemaErogante)
        If prestazione Is Nothing AndAlso ConfigurationHelper.AutoSyncPrestazioni Then
            '
            ' Crea se non c'è
            '
            prestazione = Insert(ticket, idSistemaErogante, obj)
        End If
        '
        ' Aggiorna i dati se vuoto
        '
        If obj IsNot Nothing AndAlso String.IsNullOrEmpty(obj.Descrizione) Then

            If prestazione IsNot Nothing AndAlso Not prestazione.IsDescrizioneNull() Then
                obj.Descrizione = prestazione.Descrizione
            End If
        End If

        Return prestazione

    End Function

    Public Sub Consolida(ByVal ticket As Guid, ByVal idSistemaErogante As Guid, ByRef obj As Wcf.BaseTypes.PrestazioneType)

        DiagnosticsHelper.WriteDiagnostics("PrestazioneAdapter.Consolida()")

        If obj IsNot Nothing AndAlso String.IsNullOrEmpty(obj.Descrizione) Then
            Dim prestazione As PrestazioniDS.PrestazioneRow = GetBySistemaErogante(obj.Codice, idSistemaErogante)
            '
            ' Aggiorna i dati
            '
            If prestazione IsNot Nothing AndAlso Not prestazione.IsDescrizioneNull() Then
                obj.Descrizione = prestazione.Descrizione
            End If
        End If

    End Sub

    Public Function Consolida(ByVal ticket As Guid, ByVal sistemaErogante As Wcf.BaseTypes.SistemaType, ByRef prestazione As Wcf.BaseTypes.PrestazioneType) As PrestazioniDS.PrestazioneRow

        'TODO: da testare e valutare l'impatto
        DiagnosticsHelper.WriteDiagnostics("PrestazioneAdapter.Consolida()")
        Dim row As PrestazioniDS.PrestazioneRow = Nothing

        If prestazione IsNot Nothing Then


            'Cerca per ID
            If Not String.IsNullOrEmpty(prestazione.Id) Then
                row = GetByID(New Guid(prestazione.Id))
            End If

            'Cerca per Codice
            If row Is Nothing Then
                row = GetBySistemaErogante(prestazione.Codice, sistemaErogante.Azienda.Codice,
                                                            sistemaErogante.Sistema.Codice)
            End If

            If row IsNot Nothing Then
                'Aggiorno
                prestazione.Id = row.ID.ToString.ToUpper
                prestazione.Codice = row.Codice

                'Compilo la descrizione se vuota
                If String.IsNullOrEmpty(prestazione.Descrizione) AndAlso Not row.IsDescrizioneNull() Then
                    prestazione.Descrizione = row.Descrizione
                End If
            End If
        End If

        Return row

    End Function


    Private Function Insert(ByVal ticket As Guid, ByVal idSistemaErogante As Guid, ByVal obj As Msg.QueueTypes.PrestazioneType) As PrestazioniDS.PrestazioneRow

        DiagnosticsHelper.WriteDiagnostics("PrestazioneAdapter.Insert()")

        ' Default: Il tipo di prestazione è 0 (prestazione)
        Dim tipo As Nullable(Of Byte) = 0

        CorePrestazioniInsert(ticket, obj.Codice, obj.Descrizione, tipo, idSistemaErogante)

        Return GetBySistemaErogante(obj.Codice, idSistemaErogante)
    End Function

    Private Function Insert(ByVal ticket As Guid, ByVal idSistemaErogante As Guid, ByVal obj As Wcf.BaseTypes.PrestazioneType) As PrestazioniDS.PrestazioneRow

        DiagnosticsHelper.WriteDiagnostics("PrestazioneAdapter.Insert()")

        ' Default: Il tipo di prestazione è 0 (prestazione)
        Dim tipo As Nullable(Of Byte) = 0

        CorePrestazioniInsert(ticket, obj.Codice, obj.Descrizione, tipo, idSistemaErogante)

        Return GetBySistemaErogante(obj.Codice, idSistemaErogante)
    End Function

    Private Function Update(ByVal ticket As Guid, ByVal idSistemaErogante As Guid, ByVal obj As Msg.QueueTypes.PrestazioneType) As PrestazioniDS.PrestazioneRow

        DiagnosticsHelper.WriteDiagnostics("PrestazioneAdapter.Update()")

        CorePrestazioniUpdate(obj.Codice, ticket, obj.Descrizione, idSistemaErogante)

        Return GetBySistemaErogante(obj.Codice, idSistemaErogante)
    End Function

    Private Function Update(ByVal ticket As Guid, ByVal idSistemaErogante As Guid, ByVal obj As Wcf.BaseTypes.PrestazioneType) As PrestazioniDS.PrestazioneRow

        DiagnosticsHelper.WriteDiagnostics("PrestazioneAdapter.Update()")

        CorePrestazioniUpdate(obj.Codice, ticket, obj.Descrizione, idSistemaErogante)

        Return GetBySistemaErogante(obj.Codice, idSistemaErogante)
    End Function

#End Region

End Class