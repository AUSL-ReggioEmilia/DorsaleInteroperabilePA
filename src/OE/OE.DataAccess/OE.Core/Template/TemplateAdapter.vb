Imports System.Data.SqlClient

#If CONFIG = "Release 1.2" Or CONFIG = "Debug 1.2" Then
'Versione 1.2
Imports Wcf = OE.Core.Schemas.Wcf12
#Else
'Versione 1.0 e 1.1
Imports Wcf = OE.Core.Schemas.Wcf
#End If

Public Class TemplateAdapter
    Inherits TemplateDSTableAdapters.CommandsAdapter
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

        DiagnosticsHelper.WriteDiagnostics("TemplateAdapter.SetCommandsConnection()")

        For Each commands As IDbCommand In MyBase.CommandCollection

            If _connection IsNot Nothing AndAlso _connection.State = ConnectionState.Closed Then
                _connection.Open()
            End If

            ' Imposto tutti i commands sulla stessa connessione
            commands.Connection = _connection
        Next
    End Sub

    Public Sub BeginTransaction(ByVal isolationLevel As IsolationLevel) Implements IAdapter.BeginTransaction

        DiagnosticsHelper.WriteDiagnostics("TemplateAdapter.BeginTransaction()")

        If _connection.State = ConnectionState.Closed Then

            Throw New Exception("Errore durante TemplateAdapter.BeginTransaction(). La connessione al database è chiusa!")
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

        DiagnosticsHelper.WriteDiagnostics("TemplateAdapter.Commit()")

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

        DiagnosticsHelper.WriteDiagnostics("TemplateAdapter.Rollback()")

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

        DiagnosticsHelper.WriteDiagnostics("TemplateAdapter.Disposed()")

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

    Public Sub New()
        Throw New NotImplementedException()
    End Sub

    Public Sub New(ByVal connectionString As String)
        MyBase.New()

        DiagnosticsHelper.WriteDiagnostics("TemplateAdapter.New()")

        If _connection Is Nothing Then
            _bCanDisposeConnection = True
            _connection = New SqlClient.SqlConnection(connectionString)
        End If

        ' Imposto tutti i commands sulla stessa connessione
        SetCommandsConnection()
    End Sub

    Public Sub New(ByVal connection As SqlConnection, ByVal transaction As SqlTransaction, ByVal isolationLevel As IsolationLevel)
        MyBase.New()

        DiagnosticsHelper.WriteDiagnostics("TemplateAdapter.New()")

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

    Public Function GetProfiliByCodiceOrDescrizione(utente As String, idUnitaOperativa As Guid?, idSistemaRichiedente As Guid?,
                                                    codiceRegime As String, codicePriorita As String, idStato As Byte?, _
                                                    tipi As String, valore As String) As Wcf.WsTypes.PrestazioniListaType

        DiagnosticsHelper.WriteDiagnostics("TemplateAdapter.GetProfiliByCodiceOrDescrizione()")

        'Converto empty in nothing
        If idUnitaOperativa.HasValue AndAlso idUnitaOperativa = Guid.Empty Then idUnitaOperativa = Nothing
        If idSistemaRichiedente.HasValue AndAlso idSistemaRichiedente = Guid.Empty Then idSistemaRichiedente = Nothing

        Dim result As Wcf.WsTypes.PrestazioniListaType = Nothing

        Using ta As New TemplateDSTableAdapters.ProfiliTableAdapter()
            ta.Connection = Connection
            ta.Transaction = Transaction

            Dim dt As TemplateDS.ProfiliDataTable = ta.GetDataByCodiceDescrizione(utente, idUnitaOperativa, idSistemaRichiedente, codiceRegime, codicePriorita, idStato, tipi, valore)
            If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
                'Ritorno la lista
                result = dt.ToPrestazioniListaType()
            End If
        End Using

        Return result

    End Function

    Public Function GetPrestazioniErogabiliProfiliByCodiceOrDescrizione(utente As String, idSistemaRichiedente As Guid?, idSistemaErogante As Guid?, _
                                                                        valore As String) As Wcf.WsTypes.PrestazioniListaType

        ' Questo metodo è usato per cercare le prestazioni da usare in un profiloUtente
        ' Non dovrebbe valutare le ennuple completamente per poter comporre il profilo anche fuori contesto
        DiagnosticsHelper.WriteDiagnostics("TemplateAdapter.GetPrestazioniErogabiliProfiliByCodiceOrDescrizione()")

        'Converto empty in nothing
        If idSistemaRichiedente.HasValue AndAlso idSistemaRichiedente = Guid.Empty Then idSistemaRichiedente = Nothing
        If idSistemaErogante.HasValue AndAlso idSistemaErogante = Guid.Empty Then idSistemaErogante = Nothing

        Dim result As Wcf.WsTypes.PrestazioniListaType = Nothing

        Using ta As New TemplateDSTableAdapters.PrestazioniErogabiliProfiliTableAdapter()
            ta.Connection = Connection
            ta.Transaction = Transaction

            Dim dt As TemplateDS.PrestazioniErogabiliProfiliDataTable = ta.GetDataByCodiceDescrizione(utente, idSistemaRichiedente, idSistemaErogante, valore)
            If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
                result = New Wcf.WsTypes.PrestazioniListaType()

                For Each row In dt
                    'Crea item PrestazioneListaType
                    Dim item As New Wcf.WsTypes.PrestazioneListaType() With {
                               .Id = row.ID.ToString().ToUpper(),
                                .Codice = row.Codice,
                                .Descrizione = If(row.IsDescrizioneNull(), Nothing, row.Descrizione)}

                    'Setto il sistema e tipo
                    If row.Tipo <> Wcf.WsTypes.TipoPrestazioneErogabileEnum.Prestazione Then
                        'Se profilo decodifico tipo e il sistema è vuoto
                        item.Tipo = DirectCast([Enum].Parse(GetType(Wcf.WsTypes.TipoPrestazioneErogabileEnum), row.Tipo.ToString()),  _
                            Wcf.WsTypes.TipoPrestazioneErogabileEnum)

                        item.SistemaErogante = New Wcf.BaseTypes.SistemaType() With {
                                        .Azienda = New Wcf.BaseTypes.CodiceDescrizioneType() With {.Codice = ""},
                                        .Sistema = New Wcf.BaseTypes.CodiceDescrizioneType() With {.Codice = ""}
                                        }

                    Else
                        'E' una prestazione
                        item.Tipo = Wcf.WsTypes.TipoPrestazioneErogabileEnum.Prestazione

                        item.SistemaErogante = New Wcf.BaseTypes.SistemaType() With {
                                        .Azienda = New Wcf.BaseTypes.CodiceDescrizioneType() With {
                                                    .Codice = row.CodiceAzienda,
                                                    .Descrizione = If(row.IsDescrizioneAziendaNull(), Nothing, row.DescrizioneAzienda)},
                                        .Sistema = New Wcf.BaseTypes.CodiceDescrizioneType() With {
                                                    .Codice = row.CodiceSistema,
                                                    .Descrizione = If(row.IsDescrizioneSistemaNull(), Nothing, row.DescrizioneSistema)}
                                        }
                    End If

                    'Aggiunge
                    result.Add(item)
                Next
            End If
        End Using

        Return result

    End Function


    Public Function Elabora(token As Wcf.WsTypes.TokenAccessoType, obj As Wcf.WsTypes.ProfiloUtenteType) As Wcf.WsTypes.ProfiloUtenteType

        DiagnosticsHelper.WriteDiagnostics("TemplateAdapter.Elabora()")

        Dim row As TemplateDS.ProfiloUtenteRow = Nothing

        ' Cerco per codice o per IdGuid
        If Not String.IsNullOrEmpty(obj.Codice) Then
            row = GetProfiloUtenteRowByCodice(obj.Codice, token.Utente)

        ElseIf Not String.IsNullOrEmpty(obj.Id) Then
            row = GetProfiloUtenteRowById(New Guid(obj.Id))
        End If

        'Se esiste update altrimenti insert
        If row Is Nothing Then
            row = Insert(obj.Descrizione, token.Utente)
        Else
            'Il campo codice non è modificabile
            obj.Codice = row.Codice

            row = Update(obj.Codice, obj.Descrizione, token.Utente)
        End If

        If row Is Nothing Then
            'Errore
            Throw New OrderEntryNotFoundException("Profilo utente.", String.Format("Descrizione={0}, Utente={1}", obj.Descrizione, token.Utente))
        End If

        'Cancello tutte le prestazioni del profilo 
        WsPrestazioniProfiliDelete(row.ID)

        ' Per eventuali lookup
        Using adapterPrestazione As New PrestazioneAdapter(Connection.ConnectionString)

            'Aggiungo le nuove
            For Each Prestazione In obj.Prestazioni
                Dim IdPrestazione As Guid

                ' Se non c'è IdGuid cerco per Codice + SistemaErogante
                If String.IsNullOrEmpty(Prestazione.Id) Then
                    IdPrestazione = adapterPrestazione.GetBySistemaErogante(Prestazione.Codice, _
                                                            Prestazione.SistemaErogante.Azienda.Codice, _
                                                            Prestazione.SistemaErogante.Sistema.Codice).ID
                Else
                    IdPrestazione = New Guid(Prestazione.Id)
                End If

                WsPrestazioniProfiliInsert(row.ID, IdPrestazione)
            Next
        End Using

        'Creo ProfiloUtenteType da ritornare
        Dim modello As New Wcf.WsTypes.ProfiloUtenteType() With {
                                        .Id = row.ID.ToString().ToUpper(),
                                        .Codice = row.Codice,
                                        .Descrizione = If(row.IsDescrizioneNull(), String.Empty, row.Descrizione),
                                        .Prestazioni = GetProfiloUtentePrestazioniType(row.ID)
                                    }

        Return modello

    End Function

    Public Function GetProfiliUtenteByCodiceOrDescrizione(utente As String, valore As String) As Wcf.WsTypes.ProfiliUtenteListaType

        DiagnosticsHelper.WriteDiagnostics("TemplateAdapter.GetProfiliUtenteByCodiceOrDescrizione()")

        Dim result As Wcf.WsTypes.ProfiliUtenteListaType = Nothing

        Using ta As New TemplateDSTableAdapters.ProfiliUtenteTableAdapter()
            ta.Connection = Connection
            ta.Transaction = Transaction

            Dim dt As TemplateDS.ProfiliUtenteDataTable = ta.GetData(valore, utente)
            If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
                result = dt.ToProfiliUtenteListaType()
            End If
        End Using

        Return result
    End Function

    Public Function GetProfiloUtentePrestazioniType(idProfilo As Guid) As Wcf.WsTypes.ProfiloUtentePrestazioniType

        DiagnosticsHelper.WriteDiagnostics("TemplateAdapter.GetProfiloUtentePrestazioniType()")

        Dim result As Wcf.WsTypes.ProfiloUtentePrestazioniType

        Using ta As New TemplateDSTableAdapters.PrestazioniProfiliTableAdapter()
            ta.Connection = Connection
            ta.Transaction = Transaction

            Dim dt As TemplateDS.PrestazioniProfiliDataTable = ta.GetData(idProfilo)

            If dt IsNot Nothing AndAlso dt.Count > 0 Then
                result = dt.ToProfiloUtentePrestazioniType
            Else
                result = New Wcf.WsTypes.ProfiloUtentePrestazioniType
            End If
        End Using

        Return result

    End Function

    Public Function GetProfiloUtenteByCodice(codice As String, utente As String) As Wcf.WsTypes.ProfiloUtenteType

        DiagnosticsHelper.WriteDiagnostics("TemplateAdapter.GetProfiloUtenteById()")

        Dim row As TemplateDS.ProfiloUtenteRow = GetProfiloUtenteRowByCodice(codice, utente)
        If row IsNot Nothing Then
            Return row.ToProfiloUtenteType(GetProfiloUtentePrestazioniType(row.ID))
        Else
            Return Nothing
        End If

    End Function

    Private Function GetProfiloUtenteRowByCodice(codice As String, utente As String) As TemplateDS.ProfiloUtenteRow

        DiagnosticsHelper.WriteDiagnostics("TemplateAdapter.GetProfiloUtenteRowByCodice()")

        Dim row As TemplateDS.ProfiloUtenteRow = Nothing

        Using ta As New TemplateDSTableAdapters.ProfiloUtenteTableAdapter()
            ta.Connection = Connection
            ta.Transaction = Transaction

            Dim dt As TemplateDS.ProfiloUtenteDataTable = ta.GetData(codice, utente)

            If dt.Rows.Count > 0 Then
                row = dt.First()
            End If
        End Using

        Return row
    End Function

    Public Function GetProfiloUtenteById(id As Guid) As Wcf.WsTypes.ProfiloUtenteType

        DiagnosticsHelper.WriteDiagnostics("TemplateAdapter.GetProfiloUtenteById()")

        Dim row = GetProfiloUtenteRowById(id)

        Return New Wcf.WsTypes.ProfiloUtenteType() With {
                            .Id = row.ID.ToString().ToUpper(),
                            .Codice = row.Codice,
                            .Descrizione = If(row.IsDescrizioneNull(), Nothing, row.Descrizione),
                            .Prestazioni = GetProfiloUtentePrestazioniType(row.ID)
                            }

    End Function

    Private Function GetProfiloUtenteRowById(id As Guid) As TemplateDS.ProfiloUtenteRow

        DiagnosticsHelper.WriteDiagnostics("TemplateAdapter.GetProfiloUtenteRowById()")

        Using ta As New TemplateDSTableAdapters.ProfiloUtenteTableAdapter()
            ta.Connection = Connection
            ta.Transaction = Transaction

            Dim dt As TemplateDS.ProfiloUtenteDataTable = ta.GetDataById(id)

            If dt.Rows.Count > 0 Then
                Return dt.First()
            Else
                Return Nothing
            End If
        End Using

    End Function


    Private Function Insert(descrizione As String, utenteInserimento As String) As TemplateDS.ProfiloUtenteRow

        DiagnosticsHelper.WriteDiagnostics("TemplateAdapter.Insert()")

        Dim codice As String = Nothing

        WsProfiloUtenteInsert(descrizione, utenteInserimento, codice)

        Return GetProfiloUtenteRowByCodice(codice, utenteInserimento)
    End Function

    Private Function Update(codice As String, descrizione As String, utenteModifica As String) As TemplateDS.ProfiloUtenteRow

        DiagnosticsHelper.WriteDiagnostics("TemplateAdapter.Update()")

        WsProfiloUtenteUpdate(codice, descrizione, utenteModifica)

        Return GetProfiloUtenteRowByCodice(codice, utenteModifica)
    End Function

    Public Sub DeleteProfiloUtenteById(id As Guid, utenteModifica As String)

        DiagnosticsHelper.WriteDiagnostics("TemplateAdapter.DeleteProfiloUtenteById()")

        WsProfiloUtenteDelete(id, utenteModifica)
    End Sub

End Class
