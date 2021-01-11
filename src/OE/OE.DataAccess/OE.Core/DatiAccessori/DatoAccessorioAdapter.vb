Imports System.Data.SqlClient

Imports Msg = OE.Core.Schemas.Msg

#If CONFIG = "Release 1.2" Or CONFIG = "Debug 1.2" Then
'Versione 1.2
Imports Wcf = OE.Core.Schemas.Wcf12
#Else
'Versione 1.0 e 1.1
Imports Wcf = OE.Core.Schemas.Wcf
#End If

Public Class DatoAccessorioAdapter
    Implements IDisposable

#Region " Constructors "

    Private _bCanDisposeConnection As Boolean = False
    Private _connection As SqlConnection = Nothing
    Private _transaction As SqlTransaction = Nothing

    Public ReadOnly Property Connection As System.Data.SqlClient.SqlConnection
        Get
            Return _connection
        End Get
    End Property

    Public ReadOnly Property Transaction As System.Data.SqlClient.SqlTransaction
        Get
            Return _transaction
        End Get
    End Property

    Public Sub New()
        MyBase.New()

        DiagnosticsHelper.WriteDiagnostics("DatoAccessorioAdapter.New()")
    End Sub

    Public Sub New(ByVal connectionString As String)
        MyBase.New()

        DiagnosticsHelper.WriteDiagnostics("DatoAccessorioAdapter.New(connectionString)")
        Me.SetConnection(connectionString)

    End Sub

    Public Sub New(ByVal connection As SqlClient.SqlConnection)
        MyBase.New()

        DiagnosticsHelper.WriteDiagnostics("DatoAccessorioAdapter.New(connection)")
        SetConnection(connection, Nothing)

    End Sub

    Public Sub New(ByVal connection As SqlConnection, ByVal transaction As SqlTransaction)
        MyBase.New()

        DiagnosticsHelper.WriteDiagnostics("DatoAccessorioAdapter.New(connection)")
        SetConnection(connection, transaction)

    End Sub

    Public Sub SetConnection(ByVal connectionString As String)

        ' Setto di fare il dispose
        If _connection Is Nothing Then
            _bCanDisposeConnection = True
            _connection = New SqlClient.SqlConnection(connectionString)
        End If

    End Sub

    Public Sub SetConnection(ByVal connection As SqlConnection, ByVal transaction As SqlTransaction)

        ' Setto no il dispose
        If _connection Is Nothing Then
            _bCanDisposeConnection = False
            _connection = connection
            _transaction = transaction
        End If

    End Sub

    Public Sub BeginTransaction(ByVal isolationLevel As IsolationLevel)

        DiagnosticsHelper.WriteDiagnostics("DatoAccessorioAdapter.BeginTransaction()")

        If _connection.State = ConnectionState.Closed Then
            Throw New Exception("Errore durante DatoAccessorioAdapter.BeginTransaction(). La connessione al database è chiusa!")
        End If

        If _transaction Is Nothing Then
            _transaction = _connection.BeginTransaction(isolationLevel)
        End If

    End Sub

    Public Sub Commit()

        DiagnosticsHelper.WriteDiagnostics("DatoAccessorioAdapter.Commit()")

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

        DiagnosticsHelper.WriteDiagnostics("DatoAccessorioAdapter.Rollback()")

        If _transaction IsNot Nothing Then
            Try
                _transaction.Rollback()
            Finally
                _transaction.Dispose()
            End Try

            _transaction = Nothing
        End If
    End Sub

#End Region

#Region "IDisposable Support"
    Private disposedValue As Boolean ' To detect redundant calls

    ' IDisposable
    Protected Overridable Sub Dispose(disposing As Boolean)
        If Not Me.disposedValue Then
            If disposing Then

                ' Rilascia le connessioni attive
                DiagnosticsHelper.WriteDiagnostics("DatoAccessorioAdapter.Dispose()")

                If _connection IsNot Nothing AndAlso _bCanDisposeConnection Then
                    Try
                        If _connection.State = ConnectionState.Open Then
                            _connection.Close()
                        End If
                    Finally
                        _connection.Dispose()
                    End Try

                    _connection = Nothing
                    _transaction = Nothing
                End If
            End If

        End If
        Me.disposedValue = True
    End Sub

    Public Sub Dispose() Implements IDisposable.Dispose
        ' Do not change this code.  Put cleanup code in Dispose(ByVal disposing As Boolean) above.
        Dispose(True)
        GC.SuppressFinalize(Me)
    End Sub
#End Region


    Public Function GetDatiAccessoriByIdPrestazione(ByVal id As Guid, Utente As String,
                                            idUnitaOperativa As Guid, idSistemaRichiedente As Guid,
                                            dataoraRichiesta As DateTime,
                                            codiceRegime As String, codicePriorita As String) As Wcf.WsTypes.DatiAccessoriType
        '
        ' 2017-03-08 Nuovo gestione ENNUPLE
        '
        DiagnosticsHelper.WriteDiagnostics("DatoAccessorioAdapter.GetDatiAccessoriByIdPrestazione()")

        If Guid.Equals(id, Guid.Empty) Then
            Throw New OrderEntryArgumentNullException("id")
        End If

        Dim result As Wcf.WsTypes.DatiAccessoriType = Nothing

        Using ta As New DatiAccessoriDSTableAdapters.DatiAccessoriTableAdapter()
            ta.Connection = Connection
            ta.Transaction = Transaction

            'Tutti dati accessori della prestzione
            'dbo.CoreDatiAccessoriListByIDsPrestazioni4
            '
            Dim dt As DatiAccessoriDS.DatiAccessoriDataTable = ta.GetDataByIDsPrestazioni(id.ToString, Utente, idUnitaOperativa, idSistemaRichiedente,
                                                                                          dataoraRichiesta, codiceRegime, codicePriorita)
            result = dt.ToDatiAccessoriType()
        End Using

        Return result

    End Function

    Public Function GetDatiAccessoriByIdPrestazioni(ByVal idArray() As Guid, Utente As String,
                                            idUnitaOperativa As Guid, idSistemaRichiedente As Guid,
                                            dataoraRichiesta As DateTime,
                                            codiceRegime As String, codicePriorita As String) As Wcf.WsTypes.DatiAccessoriType
        '
        ' 2018-08-29 Nuovo per leggere tutti i dati di tutte le prestazioni di un profilo
        '               Da usare nel metodo GetPrestazioniErogabiliByProfilo()
        '               Usato da GetPrestazioneErogabileByID() -> OttieniPrestazionePerId()
        '
        '
        DiagnosticsHelper.WriteDiagnostics("DatoAccessorioAdapter.GetDatiAccessoriByIdPrestazioni()")

        If idArray Is Nothing OrElse idArray.Length = 0 Then
            Throw New OrderEntryArgumentNullException("idArray()")
        End If
        '
        ' Compone il parametro con array separato da virgola
        '
        Dim result As Wcf.WsTypes.DatiAccessoriType = Nothing
        Dim sListId As String = String.Join(", ", idArray)

        Using ta As New DatiAccessoriDSTableAdapters.DatiAccessoriTableAdapter()
            ta.Connection = Connection
            ta.Transaction = Transaction

            'Tutti dati accessori della prestzione
            'dbo.CoreDatiAccessoriListByIDsPrestazioni4
            '
            Dim dt As DatiAccessoriDS.DatiAccessoriDataTable = ta.GetDataByIDsPrestazioni(sListId, Utente, idUnitaOperativa, idSistemaRichiedente,
                                                                                          dataoraRichiesta, codiceRegime, codicePriorita)
            result = dt.ToDatiAccessoriType()
        End Using

        Return result

    End Function

    Public Enum tipoDatoEnum
        Domande = 0
        SoloDefault = 1
        SoloSistema = 2
        SoloConNomeDatoAggiuntivo = 3
    End Enum

    Public Function GetDatiAccessoriListaByIdPrestazioni(ByVal ids As String, filtroTipoDato As tipoDatoEnum, Utente As String,
                                            idUnitaOperativa As Guid, idSistemaRichiedente As Guid,
                                            dataoraRichiesta As DateTime,
                                            codiceRegime As String, codicePriorita As String) As Wcf.WsTypes.DatiAccessoriListaType
        'Legge i dati accessori compilare con i valori dei DEFAULT
        '
        ' 2017-03-08 Nuovo gestione ENNUPLE
        '
        DiagnosticsHelper.WriteDiagnostics("DatoAccessorioAdapter.GetDatiAccessoriByIdPrestazioni()")

        If String.IsNullOrEmpty(ids) Then
            Return Nothing
        End If

        Dim result As Wcf.WsTypes.DatiAccessoriListaType

        Using ta As New DatiAccessoriDSTableAdapters.DatiAccessoriTableAdapter()
            ta.Connection = Connection
            ta.Transaction = Transaction

            'Tutti i dati accessori delle prestazioni
            'dbo.CoreDatiAccessoriListByIDsPrestazioni4
            '
            Dim dt As DatiAccessoriDS.DatiAccessoriDataTable = ta.GetDataByIDsPrestazioni(ids, Utente, idUnitaOperativa, idSistemaRichiedente,
                                                                                          dataoraRichiesta, codiceRegime, codicePriorita)
            result = GetDatiAccessoriLista(dt, filtroTipoDato)
        End Using

        Return result

    End Function

    Public Function GetDatiAccessoriListaByIdPrestazioni(ByVal ids As String, Utente As String,
                                            idUnitaOperativa As Guid, idSistemaRichiedente As Guid,
                                            dataoraRichiesta As DateTime,
                                            codiceRegime As String, codicePriorita As String) As Wcf.WsTypes.DatiAccessoriListaType
        'Legge i dati accessori compilare con i valori dei DEFAULT
        '
        ' 2017-03-08 Nuovo gestione ENNUPLE
        '
        DiagnosticsHelper.WriteDiagnostics("DatoAccessorioAdapter.GetDatiAccessoriByIdPrestazioni()")

        If String.IsNullOrEmpty(ids) Then
            Throw New OrderEntryArgumentNullException("ids")
        End If

        Dim result As Wcf.WsTypes.DatiAccessoriListaType

        Using ta As New DatiAccessoriDSTableAdapters.DatiAccessoriTableAdapter()
            ta.Connection = Connection
            ta.Transaction = Transaction

            'Tutti i dati accessori delle prestazioni
            'dbo.CoreDatiAccessoriListByIDsPrestazioni4
            '
            Dim dt As DatiAccessoriDS.DatiAccessoriDataTable = ta.GetDataByIDsPrestazioni(ids, Utente, idUnitaOperativa, idSistemaRichiedente,
                                                                                          dataoraRichiesta, codiceRegime, codicePriorita)
            result = GetDatiAccessoriLista(dt, tipoDatoEnum.Domande)
        End Using

        Return result

    End Function

    Public Function GetDatiAccessoriListaByIdGuidOrdine(ByVal id As Guid, Utente As String,
                                            idUnitaOperativa As Guid, idSistemaRichiedente As Guid,
                                            dataoraRichiesta As DateTime,
                                            codiceRegime As String, codicePriorita As String) As Wcf.WsTypes.DatiAccessoriListaType

        'Legge i dati accessori compilare con i valori dei DEFAULT
        '
        ' 2017-03-08 Nuovo gestione ENNUPLE
        '
        DiagnosticsHelper.WriteDiagnostics("DatoAccessorioAdapter.GetDatiAccessoriByIDRichiesta()")

        If Guid.Equals(id, Guid.Empty) Then
            Throw New OrderEntryArgumentNullException("id")
        End If

        Dim result As Wcf.WsTypes.DatiAccessoriListaType

        Using ta As New DatiAccessoriDSTableAdapters.DatiAccessoriTableAdapter()
            ta.Connection = Connection
            ta.Transaction = Transaction

            'Tutti i dati accessori dell'ordine
            'dbo.CoreDatiAccessoriListByIDRichiesta4
            '
            Dim dt As DatiAccessoriDS.DatiAccessoriDataTable = ta.GetDataByIDRichiesta(id, Utente, idUnitaOperativa, idSistemaRichiedente,
                                                                                        dataoraRichiesta, codiceRegime, codicePriorita)
            result = GetDatiAccessoriLista(dt, tipoDatoEnum.Domande)
        End Using

        Return result

    End Function

    Private Function GetDatiAccessoriLista(ByVal dt As DatiAccessoriDS.DatiAccessoriDataTable, filtroTipoDato As tipoDatoEnum) As Wcf.WsTypes.DatiAccessoriListaType

        DiagnosticsHelper.WriteDiagnostics("DatoAccessorioAdapter.GetDatiAccessori()")

        Dim result As New Wcf.WsTypes.DatiAccessoriListaType()

        If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then

            ' Adapter per dati prestazioni
            Using adapterPrestazione As New PrestazioneAdapter(Me.Connection.ConnectionString)

                For Each row As DatiAccessoriDS.DatiAccessoriRow In dt

                    'Controllo il tipo di dato richiesto
                    If Not IsTipoDatoAccessorio(row, filtroTipoDato) Then
                        Continue For
                    End If

                    ' Se ho già inserito il dato accessorio, salto
                    Dim sCodiceDatoAccessorio = row.Codice.ToUpper
                    Dim datoAccessorioFound = result.Find(Function(e) e.DatoAccessorio.Codice.ToUpper = sCodiceDatoAccessorio)

                    If filtroTipoDato = tipoDatoEnum.SoloSistema Then
                        'Consento duplicazione DatoAccessorio
                        datoAccessorioFound = Nothing
                    End If

                    If datoAccessorioFound Is Nothing Then

                        'Creo nuovo dato accessorio
                        Dim item As New Wcf.WsTypes.DatoAccessorioListaType

                        item.DatoAccessorio = row.ToDatoAccessorioType()
                        item.ValoreDato = If(row.IsValoreDefaultNull, Nothing, row.ValoreDefault)

                        ' Creo e popolo il nodo prestazioni
                        item.Prestazioni = New Wcf.WsTypes.PrestazioniListaType()

                        ' Seleziono tutte le prestazioni che referenziano questo dato accessorio
                        Dim prestazioni As DataRow()
                        If filtroTipoDato = tipoDatoEnum.SoloSistema Then
                            'Solo la corrente riga
                            prestazioni = dt.Select(String.Format("IDPrestazione = '{0}' AND Codice = '{1}'", row.IDPrestazione, row.Codice))
                        Else
                            'Raggruppo tutte le prestazioni
                            prestazioni = dt.Select(String.Format("Codice = '{0}'", row.Codice))
                        End If

                        If prestazioni IsNot Nothing Then
                            For Each p In prestazioni
                                Dim prestazione As DatiAccessoriDS.DatiAccessoriRow = TryCast(p, DatiAccessoriDS.DatiAccessoriRow)

                                'Controllo il tipo di dato richiesto
                                If Not IsTipoDatoAccessorio(prestazione, filtroTipoDato) Then
                                    Continue For
                                End If

                                'Controllo se prestazione e Id valido
                                If prestazione IsNot Nothing AndAlso Not prestazione.IsIDPrestazioneNull Then

                                    'Se ho già inserito la prestazione, non aggiungo
                                    Dim sIdPrestazione As String = prestazione.IDPrestazione.ToString.ToUpper
                                    If item.Prestazioni.Find(Function(e) e.Id.ToUpper = sIdPrestazione) Is Nothing Then

                                        Dim prestazioneLista As Wcf.WsTypes.PrestazioneListaType = Nothing
                                        prestazioneLista = adapterPrestazione.GetPrestazioneListaType(prestazione.IDPrestazione)

                                        item.Prestazioni.Add(prestazioneLista)
                                    End If
                                End If
                            Next
                        End If

                        If row.DatoAccessorioRichiesta = 0 Then
                            item.DatoAccessorioRichiesta = False
                        Else
                            item.DatoAccessorioRichiesta = True
                        End If

                        ' Add item
                        result.Add(item)

                    End If  'già inserito 
                Next

            End Using       'adapterPrestazione

        End If

        Return result

    End Function

    Private Function IsTipoDatoAccessorio(row As DatiAccessoriDS.DatiAccessoriRow, filtroTipoDato As tipoDatoEnum) As Boolean

        Dim ret As Boolean = False

        'Controllo il tipo di dato richiesto
        Select Case filtroTipoDato
            Case tipoDatoEnum.SoloConNomeDatoAggiuntivo
                If row.IsNomeDatoAggiuntivoNull Then
                    'se non ha il Nome di uscita salta e non ritorna il DatoAccessorio
                    Return False
                End If

            Case tipoDatoEnum.SoloDefault
                If (Not row.IsSistemaNull AndAlso row.Sistema = True) OrElse row.IsValoreDefaultNull Then
                    'se di sistema salta e non ritorna il DatoAccessorio
                    Return False
                End If

            Case tipoDatoEnum.SoloSistema
                If row.IsSistemaNull OrElse row.Sistema = False Then
                    'se NON  di sistema salta e non ritorna il DatoAccessorio
                    Return False
                End If

            Case Else 'tipoDatoEnum.Domande
                If Not row.IsSistemaNull AndAlso row.Sistema = True Then
                    'se di sistema salta e non ritorna il DatoAccessorio
                    Return False
                End If

        End Select

        Return True

    End Function


    Public Function GetDatiAccessoriValoriDefaultByIdPrestazioni(ByVal ids As String, Utente As String,
                                            idUnitaOperativa As Guid, idSistemaRichiedente As Guid,
                                            dataoraRichiesta As DateTime,
                                            codiceRegime As String, codicePriorita As String) As Wcf.WsTypes.DatiAccessoriValoriType

        'Legge i valori dei DEFAULT dei dati accessori
        '
        ' 2017-03-08 Nuovo gestione ENNUPLE
        '
        DiagnosticsHelper.WriteDiagnostics("DatoAccessorioAdapter.GetDatiAccessoriValoriDefaultByIdPrestazioni()")

        If String.IsNullOrEmpty(ids) Then
            Throw New OrderEntryArgumentNullException("ids")
        End If

        Using ta As New DatiAccessoriDSTableAdapters.DatiAccessoriTableAdapter()
            ta.Connection = Connection
            ta.Transaction = Transaction

            'Tutti i dati accessori di default delle prestazioni
            'dbo.CoreDatiAccessoriListByIDsPrestazioni4
            '
            Dim dt As DatiAccessoriDS.DatiAccessoriDataTable = ta.GetDataByIDsPrestazioni(ids, Utente, idUnitaOperativa, idSistemaRichiedente,
                                                                                            dataoraRichiesta, codiceRegime, codicePriorita)
            Return GetDatiAccessoriValoriDefault(dt, False)
        End Using

    End Function

    Public Function GetDatiAccessoriValoriDefaultByIdGuidOrdine(ByVal id As Guid, Utente As String,
                                            idUnitaOperativa As Guid, idSistemaRichiedente As Guid,
                                            dataoraRichiesta As DateTime,
                                            codiceRegime As String, codicePriorita As String) As Wcf.WsTypes.DatiAccessoriValoriType

        'Legge i valori dei DEFAULT dei dati accessori
        '
        ' 2017-03-08 Nuovo gestione ENNUPLE
        '
        DiagnosticsHelper.WriteDiagnostics("DatoAccessorioAdapter.GetDatiAccessoriValoriDefaultByIdGuidOrdine()")

        If Guid.Equals(id, Guid.Empty) Then
            Throw New OrderEntryArgumentNullException("id")
        End If

        Using ta As New DatiAccessoriDSTableAdapters.DatiAccessoriTableAdapter()
            ta.Connection = Connection
            ta.Transaction = Transaction

            'Tutti i dati accessori di default dell'ordine
            'dbo.CoreDatiAccessoriListByIDsPrestazioni4
            '
            Dim dt As DatiAccessoriDS.DatiAccessoriDataTable = ta.GetDataByIDRichiesta(id, Utente, idUnitaOperativa, idSistemaRichiedente,
                                                                                        dataoraRichiesta, codiceRegime, codicePriorita)
            Return GetDatiAccessoriValoriDefault(dt, False)
        End Using

    End Function

    Public Function GetDatiAccessoriValoriSistemaByIdPrestazioni(ByVal ids As String, Utente As String,
                                            idUnitaOperativa As Guid, idSistemaRichiedente As Guid,
                                            dataoraRichiesta As DateTime,
                                            codiceRegime As String, codicePriorita As String) As Wcf.WsTypes.DatiAccessoriValoriType

        'Legge i valori dei DEFAULT dei dati accessori
        '
        ' 2017-03-08 Nuovo gestione ENNUPLE
        '
        DiagnosticsHelper.WriteDiagnostics("DatoAccessorioAdapter.GetDatiAccessoriValoriDefaultByIdPrestazioni()")

        If String.IsNullOrEmpty(ids) Then
            Throw New OrderEntryArgumentNullException("ids")
        End If

        Using ta As New DatiAccessoriDSTableAdapters.DatiAccessoriTableAdapter()
            ta.Connection = Connection
            ta.Transaction = Transaction

            'Tutti i dati accessori di default delle prestazioni
            Dim dt As DatiAccessoriDS.DatiAccessoriDataTable = ta.GetDataByIDsPrestazioni(ids, Utente, idUnitaOperativa, idSistemaRichiedente,
                                                                                            dataoraRichiesta, codiceRegime, codicePriorita)
            Return GetDatiAccessoriValoriDefault(dt, True)
        End Using

    End Function

    Public Function GetDatiAccessoriValoriSistemaByIdGuidOrdine(ByVal id As Guid, Utente As String,
                                            idUnitaOperativa As Guid, idSistemaRichiedente As Guid,
                                            dataoraRichiesta As DateTime,
                                            codiceRegime As String, codicePriorita As String) As Wcf.WsTypes.DatiAccessoriValoriType

        'Legge i valori di SISTREMA dei dati accessori

        DiagnosticsHelper.WriteDiagnostics("DatoAccessorioAdapter.GetDatiAccessoriValoriSistemaByIdGuidOrdine()")

        If Guid.Equals(id, Guid.Empty) Then
            Throw New OrderEntryArgumentNullException("id")
        End If

        Using ta As New DatiAccessoriDSTableAdapters.DatiAccessoriTableAdapter()
            ta.Connection = Connection
            ta.Transaction = Transaction

            'Tutti i dati accessori di default dell'ordine
            'dbo.CoreDatiAccessoriListByIDRichiesta4
            '
            Dim dt As DatiAccessoriDS.DatiAccessoriDataTable = ta.GetDataByIDRichiesta(id, Utente, idUnitaOperativa, idSistemaRichiedente,
                                                                                        dataoraRichiesta, codiceRegime, codicePriorita)
            Return GetDatiAccessoriValoriDefault(dt, True)
        End Using

    End Function

    Private Function GetDatiAccessoriValoriDefault(ByVal dt As DatiAccessoriDS.DatiAccessoriDataTable, filtroSistema As Boolean) As Wcf.WsTypes.DatiAccessoriValoriType

        DiagnosticsHelper.WriteDiagnostics("DatoAccessorioAdapter.GetDatiAccessoriValoriDefault()")

        Dim result As New Wcf.WsTypes.DatiAccessoriValoriType()

        If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then

            ' Adapter per dati prestazioni
            Using adapterPrestazione As New PrestazioneAdapter(Me.Connection.ConnectionString)

                For Each row As DatiAccessoriDS.DatiAccessoriRow In dt

                    If filtroSistema Then
                        If row.IsSistemaNull OrElse row.Sistema = False Then
                            'se NON di sistema salta e non ritorna il DatoAccessorio
                            Continue For
                        End If
                    Else
                        If Not row.IsSistemaNull AndAlso row.Sistema = True Then
                            'se di sistema salta e non ritorna il DatoAccessorio
                            Continue For
                        End If
                    End If

                    'Solo i valori di default
                    If Not row.IsValoreDefaultNull Then
                        Dim sCodice As String = row.Codice

                        'Controllo che non sia già nella lista
                        If result.Find(Function(e) e.Codice.ToUpper = sCodice.ToUpper) Is Nothing Then

                            'Creo nuovo dato accessorio
                            Dim item As New Wcf.WsTypes.DatoAccessorioValoreType With {.Codice = sCodice, _
                                                                                      .ValoreDato = row.ValoreDefault}
                            'Valorizzo ordinamneto
                            If Not row.IsOrdinamentoNull Then
                                item.internal_Ordinamento = row.Ordinamento
                            End If

                            ' Add item
                            result.Add(item)
                        End If
                    End If
                Next
            End Using       'adapterPrestazione
        End If

        Return result

    End Function


    Public Function GetDatiAccessoriByCheck(ByVal idOrdineTestata As Guid, Utente As String,
                                            idUnitaOperativa As Guid, idSistemaRichiedente As Guid,
                                            dataoraRichiesta As DateTime,
                                            codiceRegime As String, codicePriorita As String) As DatiAccessoriDS.DatiAccessoriByCheckDataTable
        '
        ' 2017-02-28 Nuovo gestione ENNUPLE
        '
        DiagnosticsHelper.WriteDiagnostics("DatoAccessorioAdapter.GetDatiAccessoriByCheck()")

        If Guid.Equals(idOrdineTestata, Guid.Empty) Then
            Throw New OrderEntryArgumentNullException("idOrdineTestata")
        End If

        Dim dt As DatiAccessoriDS.DatiAccessoriByCheckDataTable = Nothing

        Using ta As New DatiAccessoriDSTableAdapters.DatiAccessoriByCheckTableAdapter()
            ta.Connection = Connection
            ta.Transaction = Transaction
            '
            ' dbo.CoreDatiAccessoriListByCheck3
            '
            dt = ta.GetData(idOrdineTestata, Utente, idUnitaOperativa, idSistemaRichiedente,
                                              dataoraRichiesta, codiceRegime, codicePriorita)
        End Using

        Return dt

    End Function


    Public Function GetDatiAccessoriByIdPrestazioni(ByVal ids As String, Utente As String,
                                            idUnitaOperativa As Guid, idSistemaRichiedente As Guid,
                                            dataoraRichiesta As DateTime,
                                            codiceRegime As String, codicePriorita As String) As DatiAccessoriDS.DatiAccessoriDataTable
        '
        'Legge i dati accessori compilare con i valori dei DEFAULT
        '
        DiagnosticsHelper.WriteDiagnostics("DatoAccessorioAdapter.GetDatiAccessoriByIdPrestazioni()")

        If String.IsNullOrEmpty(ids) Then
            Throw New OrderEntryArgumentNullException("ids")
        End If

        Dim result As DatiAccessoriDS.DatiAccessoriDataTable

        Using ta As New DatiAccessoriDSTableAdapters.DatiAccessoriTableAdapter()
            ta.Connection = Connection
            ta.Transaction = Transaction

            'Tutti i dati accessori delle prestazioni
            'dbo.CoreDatiAccessoriListByIDsPrestazioni4
            '
            result = ta.GetDataByIDsPrestazioni(ids, Utente, idUnitaOperativa, idSistemaRichiedente,
                                                dataoraRichiesta, codiceRegime, codicePriorita)
        End Using

        Return result

    End Function


    Public Function GetByCodice(ByVal codice As String) As DatiAccessoriDS.DatoAccessorioRow
        '
        ' TODO: Chiamata spesso e la tabella cambia poco, valutare una cache
        ' TODO: valutare anche una lista di codici in unica chiamata
        '
        DiagnosticsHelper.WriteDiagnostics("DatoAccessorioAdapter.GetByCodice()")

        If String.IsNullOrEmpty(codice) Then
            Throw New OrderEntryArgumentNullException("codice")
        End If

        Dim row As DatiAccessoriDS.DatoAccessorioRow = Nothing

        Using ta As New DatiAccessoriDSTableAdapters.DatoAccessorioTableAdapter()
            ta.Connection = Connection
            ta.Transaction = Transaction
            '
            ' dbo.CoreDatiAccessoriSelect2
            '
            Dim dt As DatiAccessoriDS.DatoAccessorioDataTable = ta.GetData(codice)
            If dt.Rows.Count > 0 Then
                row = dt.First()
            End If
        End Using

        Return row

    End Function


    Public Shared Function ProcessaDatiAccessoriStatoValidazioneRiga(datiAccessori() As DatiAccessoriDS.DatiAccessoriByCheckRow, datiAccessoriValore As Wcf.WsTypes.DatiAccessoriValoriType) As String
        '
        ' TODO: Pianidicare LA RIMOZIONE, anche del TableAdapter
        '
        ' Verifico i dati accessori
        Dim writeHeader As Boolean = False

        If datiAccessori.Count > 0 Then
            Dim message As New Text.StringBuilder()

            'Non usare row.ValoreDato, row.ValoreDatoVarchar, row.ValoreDatoXml perchè sono letti dal DB che non è
            '   ancora sato aggiornato!

            For Each row As DatiAccessoriDS.DatiAccessoriByCheckRow In datiAccessori
                '
                ' Controllo se obbligatorio
                '
                If Not row.IsObbligatorioNull AndAlso row.Obbligatorio Then

                    ' Cerco valore tra i dati accessori passati
                    Dim valoreDato As String = datiAccessoriValore.GetValoreByCodice(row.Codice)
                    If String.IsNullOrEmpty(valoreDato) Then

                        ' Aggiungo intestazione
                        If Not writeHeader Then
                            message.AppendLine("Dati accessori obbligatori non valorizzati:")
                            writeHeader = True
                        End If

                        'Messaggio di errore
                        message.AppendLine(String.Format("-- {0}", row.Etichetta))
                    End If
                End If
            Next

            writeHeader = False

            For Each row As DatiAccessoriDS.DatiAccessoriByCheckRow In datiAccessori
                '
                ' Controllo Regex
                '
                If Not row.IsValidazioneRegexNull AndAlso Not String.IsNullOrEmpty(row.ValidazioneRegex) Then
                    Dim regexCheck As New Text.RegularExpressions.Regex(row.ValidazioneRegex)
                    Dim bRegexResult As Boolean = True

                    ' Cerco valore tra i dati accessori passati
                    Dim valoreDato As String = datiAccessoriValore.GetValoreByCodice(row.Codice)
                    If Not String.IsNullOrEmpty(valoreDato) Then

                        ' eseguo REGEX
                        bRegexResult = regexCheck.IsMatch(valoreDato)
                    End If

                    If Not bRegexResult Then
                        ' Aggiungo intestazione
                        If Not writeHeader Then
                            message.AppendLine("Dati accessori con valori non corretti:")
                            writeHeader = True
                        End If

                        'Messaggio di errore
                        Dim sValidazioneMessaggio As String = If(row.IsValidazioneMessaggioNull, String.Empty, row.ValidazioneMessaggio)
                        message.AppendLine(String.Format("-- {0}: {1}", row.Etichetta, sValidazioneMessaggio))
                    End If
                End If
            Next

            If message.Length > 0 Then
                Return message.ToString.Trim
            Else
                Return Nothing
            End If
        Else
            Return Nothing
        End If

    End Function


    Public Shared Function ProcessaDatiAccessoriStatoValidazioneRiga(datiAccessori As IEnumerable(Of DatiAccessoriDS.DatiAccessoriRow), datiAccessoriValore As Wcf.WsTypes.DatiAccessoriValoriType) As String

        ' Verifico i dati accessori
        Dim writeHeader As Boolean = False

        If datiAccessori.Count > 0 Then
            Dim message As New Text.StringBuilder()

            'Non usare row.ValoreDato, row.ValoreDatoVarchar, row.ValoreDatoXml perchè sono letti dal DB che non è
            '   ancora sato aggiornato!

            For Each row As DatiAccessoriDS.DatiAccessoriRow In datiAccessori
                '
                ' Controllo se obbligatorio
                '
                If Not row.IsObbligatorioNull AndAlso row.Obbligatorio Then

                    ' Cerco valore tra i dati accessori passati
                    Dim valoreDato As String = datiAccessoriValore.GetValoreByCodice(row.Codice)
                    If String.IsNullOrEmpty(valoreDato) Then

                        ' Aggiungo intestazione
                        If Not writeHeader Then
                            message.AppendLine("Dati accessori obbligatori non valorizzati:")
                            writeHeader = True
                        End If

                        'Messaggio di errore
                        message.AppendLine(String.Format("-- {0}", row.Etichetta))
                    End If
                End If
            Next

            writeHeader = False

            For Each row As DatiAccessoriDS.DatiAccessoriRow In datiAccessori
                '
                ' Controllo Regex
                '
                If Not row.IsValidazioneRegexNull AndAlso Not String.IsNullOrEmpty(row.ValidazioneRegex) Then
                    Dim regexCheck As New Text.RegularExpressions.Regex(row.ValidazioneRegex)
                    Dim bRegexResult As Boolean = True

                    ' Cerco valore tra i dati accessori passati
                    Dim valoreDato As String = datiAccessoriValore.GetValoreByCodice(row.Codice)
                    If Not String.IsNullOrEmpty(valoreDato) Then

                        ' eseguo REGEX
                        bRegexResult = regexCheck.IsMatch(valoreDato)
                    End If

                    If Not bRegexResult Then
                        ' Aggiungo intestazione
                        If Not writeHeader Then
                            message.AppendLine("Dati accessori con valori non corretti:")
                            writeHeader = True
                        End If

                        'Messaggio di errore
                        Dim sValidazioneMessaggio As String = If(row.IsValidazioneMessaggioNull, String.Empty, row.ValidazioneMessaggio)
                        message.AppendLine(String.Format("-- {0}: {1}", row.Etichetta, sValidazioneMessaggio))
                    End If
                End If
            Next

            If message.Length > 0 Then
                Return message.ToString.Trim
            Else
                Return Nothing
            End If
        Else
            Return Nothing
        End If

    End Function


End Class