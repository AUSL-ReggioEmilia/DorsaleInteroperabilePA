Friend Class AnagraficaAdapter
    Inherits System.ComponentModel.Component

#Region " Component Designer generated code "

    Public Sub New(ByVal Container As System.ComponentModel.IContainer)
        MyClass.New()

        'Required for Windows.Forms Class Composition Designer support
        Container.Add(Me)
    End Sub

    Public Sub New()
        MyBase.New()

        'This call is required by the Component Designer.
        InitializeComponent()
        '
        ' Evito di usare la scrin connectio dello sviluppo
        '
        sqlcnnDwhClinico.ConnectionString = ""

    End Sub

    Public Sub ConnectionOpen(ByVal ConnectionString As String)
        '
        ' Apro connessione
        '
        sqlcnnDwhClinico.ConnectionString = ConnectionString
        sqlcnnDwhClinico.Open()

    End Sub

    'Component overrides dispose to clean up the component list.
    Protected Overloads Overrides Sub Dispose(ByVal disposing As Boolean)
        If disposing Then
            '
            ' Chiude connessione se aperta
            '
            With sqlcnnDwhClinico
                If .State <> ConnectionState.Closed Then
                    .Close()
                End If
            End With

            If Not (components Is Nothing) Then
                components.Dispose()
            End If
        End If
        MyBase.Dispose(disposing)
    End Sub

    'Required by the Component Designer
    Private components As System.ComponentModel.IContainer

    'NOTE: The following procedure is required by the Component Designer
    'It can be modified using the Component Designer.
    'Do not modify it using the code editor.
    Friend WithEvents sqlcmdExtAnagraficaAggiungi As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcnnDwhClinico As System.Data.SqlClient.SqlConnection
    Friend WithEvents sqlcmdExtAnagraficaEsiste As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtAnagraficaRiferimentiModifica As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtAnagraficaRiferimentiEsiste As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtAnagraficaRiferimentiAggiungi As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtAnagraficaRimuovi As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtAnagraficaModifica As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtAnagraficaRiferimento As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtAnagraficaFondi As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtAnagraficaIsAnagrafica As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtAnagraficaRiferimentiRimuovi As System.Data.SqlClient.SqlCommand
    <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()
        Me.sqlcmdExtAnagraficaAggiungi = New System.Data.SqlClient.SqlCommand
        Me.sqlcnnDwhClinico = New System.Data.SqlClient.SqlConnection
        Me.sqlcmdExtAnagraficaEsiste = New System.Data.SqlClient.SqlCommand
        Me.sqlcmdExtAnagraficaRiferimentiModifica = New System.Data.SqlClient.SqlCommand
        Me.sqlcmdExtAnagraficaRiferimentiEsiste = New System.Data.SqlClient.SqlCommand
        Me.sqlcmdExtAnagraficaRiferimentiAggiungi = New System.Data.SqlClient.SqlCommand
        Me.sqlcmdExtAnagraficaRimuovi = New System.Data.SqlClient.SqlCommand
        Me.sqlcmdExtAnagraficaModifica = New System.Data.SqlClient.SqlCommand
        Me.sqlcmdExtAnagraficaRiferimentiRimuovi = New System.Data.SqlClient.SqlCommand
        Me.sqlcmdExtAnagraficaRiferimento = New System.Data.SqlClient.SqlCommand
        Me.sqlcmdExtAnagraficaFondi = New System.Data.SqlClient.SqlCommand
        Me.sqlcmdExtAnagraficaIsAnagrafica = New System.Data.SqlClient.SqlCommand
        '
        'sqlcmdExtAnagraficaAggiungi
        '
        Me.sqlcmdExtAnagraficaAggiungi.CommandText = "dbo.[ExtAnagraficaAggiungi2]"
        Me.sqlcmdExtAnagraficaAggiungi.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtAnagraficaAggiungi.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtAnagraficaAggiungi.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@IdEsterno", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@DataModificaEsterno", System.Data.SqlDbType.DateTime, 8), New System.Data.SqlClient.SqlParameter("@AziendaErogante", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@SistemaErogante", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@RepartoErogante", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@CodiceSanitario", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@Sesso", System.Data.SqlDbType.VarChar, 1), New System.Data.SqlClient.SqlParameter("@Cognome", System.Data.SqlDbType.VarChar, 50), New System.Data.SqlClient.SqlParameter("@Nome", System.Data.SqlDbType.VarChar, 50), New System.Data.SqlClient.SqlParameter("@CodiceFiscale", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@DataNascita", System.Data.SqlDbType.DateTime, 8), New System.Data.SqlClient.SqlParameter("@LuogoNascita", System.Data.SqlDbType.VarChar, 80), New System.Data.SqlClient.SqlParameter("@DatiAnamnestici", System.Data.SqlDbType.VarChar, 8000), New System.Data.SqlClient.SqlParameter("@XmlAttributi", System.Data.SqlDbType.VarChar, 2147483647)})
        '
        'sqlcnnDwhClinico
        '
        Me.sqlcnnDwhClinico.ConnectionString = "Data Source=tatooine;Initial Catalog=AuslAsmnRe_DwhClinico;Integrated Security=Tr" & _
            "ue"
        Me.sqlcnnDwhClinico.FireInfoMessageEventOnUserErrors = False
        '
        'sqlcmdExtAnagraficaEsiste
        '
        Me.sqlcmdExtAnagraficaEsiste.CommandText = "dbo.[ExtAnagraficaEsiste]"
        Me.sqlcmdExtAnagraficaEsiste.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtAnagraficaEsiste.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtAnagraficaEsiste.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@IdEsterno", System.Data.SqlDbType.VarChar, 64)})
        '
        'sqlcmdExtAnagraficaRiferimentiModifica
        '
        Me.sqlcmdExtAnagraficaRiferimentiModifica.CommandText = "dbo.[ExtAnagraficaRiferimentiModifica]"
        Me.sqlcmdExtAnagraficaRiferimentiModifica.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtAnagraficaRiferimentiModifica.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtAnagraficaRiferimentiModifica.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@IdEsterno", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@Anagrafica", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@IdAnagrafica", System.Data.SqlDbType.VarChar, 64)})
        '
        'sqlcmdExtAnagraficaRiferimentiEsiste
        '
        Me.sqlcmdExtAnagraficaRiferimentiEsiste.CommandText = "dbo.[ExtAnagraficaRiferimentiEsiste]"
        Me.sqlcmdExtAnagraficaRiferimentiEsiste.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtAnagraficaRiferimentiEsiste.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtAnagraficaRiferimentiEsiste.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@IdEsterno", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@Anagrafica", System.Data.SqlDbType.VarChar, 16)})
        '
        'sqlcmdExtAnagraficaRiferimentiAggiungi
        '
        Me.sqlcmdExtAnagraficaRiferimentiAggiungi.CommandText = "dbo.[ExtAnagraficaRiferimentiAggiungi]"
        Me.sqlcmdExtAnagraficaRiferimentiAggiungi.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtAnagraficaRiferimentiAggiungi.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtAnagraficaRiferimentiAggiungi.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@IdEsterno", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@Anagrafica", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@IdAnagrafica", System.Data.SqlDbType.VarChar, 64)})
        '
        'sqlcmdExtAnagraficaRimuovi
        '
        Me.sqlcmdExtAnagraficaRimuovi.CommandText = "dbo.[ExtAnagraficaRimuovi]"
        Me.sqlcmdExtAnagraficaRimuovi.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtAnagraficaRimuovi.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtAnagraficaRimuovi.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@IdEsterno", System.Data.SqlDbType.VarChar, 64)})
        '
        'sqlcmdExtAnagraficaModifica
        '
        Me.sqlcmdExtAnagraficaModifica.CommandText = "dbo.[ExtAnagraficaModifica2]"
        Me.sqlcmdExtAnagraficaModifica.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtAnagraficaModifica.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtAnagraficaModifica.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@IdEsterno", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@DataModificaEsterno", System.Data.SqlDbType.DateTime, 8), New System.Data.SqlClient.SqlParameter("@AziendaErogante", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@SistemaErogante", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@RepartoErogante", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@CodiceSanitario", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@Sesso", System.Data.SqlDbType.VarChar, 1), New System.Data.SqlClient.SqlParameter("@Cognome", System.Data.SqlDbType.VarChar, 50), New System.Data.SqlClient.SqlParameter("@Nome", System.Data.SqlDbType.VarChar, 50), New System.Data.SqlClient.SqlParameter("@CodiceFiscale", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@DataNascita", System.Data.SqlDbType.DateTime, 8), New System.Data.SqlClient.SqlParameter("@LuogoNascita", System.Data.SqlDbType.VarChar, 80), New System.Data.SqlClient.SqlParameter("@DatiAnamnestici", System.Data.SqlDbType.VarChar, 8000), New System.Data.SqlClient.SqlParameter("@XmlAttributi", System.Data.SqlDbType.VarChar, 2147483647)})
        '
        'sqlcmdExtAnagraficaRiferimentiRimuovi
        '
        Me.sqlcmdExtAnagraficaRiferimentiRimuovi.CommandText = "dbo.[ExtAnagraficaRiferimentiRimuovi]"
        Me.sqlcmdExtAnagraficaRiferimentiRimuovi.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtAnagraficaRiferimentiRimuovi.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtAnagraficaRiferimentiRimuovi.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@IdEsterno", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@Anagrafica", System.Data.SqlDbType.VarChar, 16)})
        '
        'sqlcmdExtAnagraficaRiferimento
        '
        Me.sqlcmdExtAnagraficaRiferimento.CommandText = "dbo.[ExtAnagraficaRiferimento]"
        Me.sqlcmdExtAnagraficaRiferimento.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtAnagraficaRiferimento.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtAnagraficaRiferimento.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@Anagrafica", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@IdAnagrafica", System.Data.SqlDbType.VarChar, 64)})
        '
        'sqlcmdExtAnagraficaFondi
        '
        Me.sqlcmdExtAnagraficaFondi.CommandText = "dbo.[ExtAnagraficaFondi]"
        Me.sqlcmdExtAnagraficaFondi.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtAnagraficaFondi.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtAnagraficaFondi.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@IdEsterno", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@IdEsternoFuso", System.Data.SqlDbType.VarChar, 64)})
        '
        'sqlcmdExtAnagraficaIsAnagrafica
        '
        Me.sqlcmdExtAnagraficaIsAnagrafica.CommandText = "dbo.[ExtAnagraficaIsAnagrafica]"
        Me.sqlcmdExtAnagraficaIsAnagrafica.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtAnagraficaIsAnagrafica.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtAnagraficaIsAnagrafica.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@IdEsterno", System.Data.SqlDbType.VarChar, 64)})

    End Sub

#End Region

    Dim moSqlTransact As SqlClient.SqlTransaction

    Public Sub TransactionBegin(ByVal IsolationLevel As System.Data.IsolationLevel)
        '
        ' Inizio transazioni
        '
        moSqlTransact = sqlcnnDwhClinico.BeginTransaction(IsolationLevel)

    End Sub

    Public Sub TransactionCommit()
        '
        ' Commit transazioni
        '
        If (Not moSqlTransact Is Nothing) AndAlso (moSqlTransact.Connection.State <> ConnectionState.Closed) Then
            moSqlTransact.Commit()
        End If

    End Sub

    Public Sub TransactionRoolback()
        '
        ' Roolback transazioni
        '
        Try
            If (Not moSqlTransact Is Nothing) AndAlso (moSqlTransact.Connection.State <> ConnectionState.Closed) Then
                moSqlTransact.Rollback()
            End If
        Catch ex As Exception
            LogEvent.WriteError(ex, "Errore durante EpisodioAdapter.Rollback()!")
        End Try

    End Sub

    Public Function AddNew(ByVal IdEsternoPaziente As String, _
                            ByVal DataModificaEsterno As Date, _
                            ByVal AziendaErogante As String, _
                            ByVal SistemaErogante As String, _
                            ByVal RepartoErogante As String, _
                            ByVal Cognome As String, _
                            ByVal Nome As String, _
                            ByVal Sesso As String, _
                            ByVal DataNascita As Date, _
                            ByVal LuogoNascita As String, _
                            ByVal CodiceFiscale As String, _
                            ByVal CodiceSanitario As String, _
                            ByVal DatiAnamnestici As String, _
                            ByVal XmlAttributi As String) As Boolean
        '
        ' Verifiche dei parametri
        '
        If IdEsternoPaziente Is Nothing OrElse IdEsternoPaziente.Length = 0 Then
            Throw New System.Exception("Anagrafica.AddNew(). Manca il parametro IdEsterno dell'anagrafica!")
        End If
        '
        ' Esegue la SP
        '
        With sqlcmdExtAnagraficaAggiungi
            .Parameters("@IdEsterno").Value = IdEsternoPaziente
            .Parameters("@DataModificaEsterno").Value = DataModificaEsterno
            .Parameters("@AziendaErogante").Value = AziendaErogante
            .Parameters("@SistemaErogante").Value = SistemaErogante
            .Parameters("@RepartoErogante").Value = RepartoErogante
            .Parameters("@CodiceSanitario").Value = CodiceSanitario
            .Parameters("@Sesso").Value = Sesso
            .Parameters("@Cognome").Value = Cognome
            .Parameters("@Nome").Value = Nome
            .Parameters("@CodiceFiscale").Value = CodiceFiscale
            .Parameters("@DataNascita").Value = DataNascita
            .Parameters("@LuogoNascita").Value = LuogoNascita
            .Parameters("@DatiAnamnestici").Value = DatiAnamnestici
            .Parameters("@XmlAttributi").Value = SqlUtil.StringEmptyToDbNull(XmlAttributi)

            If Not moSqlTransact Is Nothing Then
                .Transaction = moSqlTransact
            End If

            Dim vScalar As Object = .ExecuteScalar()

            Dim vRetVal As Object = .Parameters("@RETURN_VALUE").Value
            If (vRetVal Is Nothing) OrElse IsDBNull(vRetVal) OrElse (CType(vRetVal, Integer) <> 0) Then
                Throw New System.Exception("Errore durante Exec SP ExtAnagraficaAggiungi(); SQL error: " & vRetVal.ToString())
            Else
                '
                ' Ritorna boolean
                '
                If (Not vScalar Is Nothing) AndAlso (Not IsDBNull(vScalar)) Then
                    Return CType(vScalar, Integer) > 0
                Else
                    Throw New System.Exception("Errore durante Exec SP ExtAnagraficaAggiungi(); Risultato vuoto!")
                End If
            End If
        End With

    End Function

    Public Function Update(ByVal IdEsternoPaziente As String, _
                        ByVal DataModificaEsterno As Date, _
                        ByVal AziendaErogante As String, _
                        ByVal SistemaErogante As String, _
                        ByVal RepartoErogante As String, _
                        ByVal Cognome As String, _
                        ByVal Nome As String, _
                        ByVal Sesso As String, _
                        ByVal DataNascita As Date, _
                        ByVal LuogoNascita As String, _
                        ByVal CodiceFiscale As String, _
                        ByVal CodiceSanitario As String, _
                        ByVal DatiAnamnestici As String, _
                        ByVal XmlAttributi As String) As Boolean
        '
        ' Verifiche dei parametri
        '
        If IdEsternoPaziente Is Nothing OrElse IdEsternoPaziente.Length = 0 Then
            Throw New System.Exception("Anagrafica.Update(). Manca il parametro IdEsterno del paziente!")
        End If
        '
        ' Esegue la SP
        '
        With sqlcmdExtAnagraficaModifica
            .Parameters("@IdEsterno").Value = IdEsternoPaziente
            .Parameters("@DataModificaEsterno").Value = DataModificaEsterno
            .Parameters("@AziendaErogante").Value = AziendaErogante
            .Parameters("@SistemaErogante").Value = SistemaErogante
            .Parameters("@RepartoErogante").Value = RepartoErogante
            .Parameters("@CodiceSanitario").Value = CodiceSanitario
            .Parameters("@Sesso").Value = Sesso
            .Parameters("@Cognome").Value = Cognome
            .Parameters("@Nome").Value = Nome
            .Parameters("@CodiceFiscale").Value = CodiceFiscale
            .Parameters("@DataNascita").Value = DataNascita
            .Parameters("@LuogoNascita").Value = LuogoNascita
            .Parameters("@DatiAnamnestici").Value = DatiAnamnestici
            .Parameters("@XmlAttributi").Value = SqlUtil.StringEmptyToDbNull(XmlAttributi)

            If Not moSqlTransact Is Nothing Then
                .Transaction = moSqlTransact
            End If

            Dim vScalar As Object = .ExecuteScalar()

            Dim vRetVal As Object = .Parameters("@RETURN_VALUE").Value
            If (vRetVal Is Nothing) OrElse IsDBNull(vRetVal) OrElse (CType(vRetVal, Integer) <> 0) Then
                Throw New System.Exception("Errore durante Exec SP ExtAnagraficaModifica(); SQL error: " & vRetVal.ToString())
            Else
                '
                ' Ritorna boolean
                '
                If (Not vScalar Is Nothing) AndAlso (Not IsDBNull(vScalar)) Then
                    Return CType(vScalar, Integer) > 0
                Else
                    Throw New System.Exception("Errore durante Exec SP ExtAnagraficaModifica(); Risultato vuoto!")
                End If
            End If
        End With

    End Function

    Public Function Contains(ByVal IdEsternoPaziente As String) As Date
        '
        ' Verifiche dei parametri
        '
        If IdEsternoPaziente Is Nothing OrElse IdEsternoPaziente.Length = 0 Then
            Throw New System.Exception("Anagrafica.Contains(). Manca il parametro IdEsterno del paziente!")
        End If
        '
        ' Esegue SP
        '
        With sqlcmdExtAnagraficaEsiste
            .Parameters("@IdEsterno").Value = IdEsternoPaziente

            If Not moSqlTransact Is Nothing Then
                .Transaction = moSqlTransact
            End If

            Dim vScalar As Object = .ExecuteScalar()

            Dim vRet As Object = .Parameters("@RETURN_VALUE").Value
            If (Not vRet Is Nothing) AndAlso (Not IsDBNull(vRet)) AndAlso (CType(vRet, Integer) = 0) Then
                '
                ' Nessun errore
                '
                If (Not vScalar Is Nothing) AndAlso (Not IsDBNull(vScalar)) Then
                    '
                    ' Ritorna la data di modifica esterna
                    '
                    Return CType(vScalar, Date)
                Else
                    Return Nothing
                End If
            Else
                Throw New System.Exception("Errore durante Exec SP ExtAnagraficaEsiste(); SQL error: " & vRet.ToString())
            End If
        End With

    End Function

    Public Function Merge(ByVal IdEsternoPaziente As String, ByVal IdEsternoPazienteFuso As String) As Boolean
        '
        ' Verifiche dei parametri
        '
        If IdEsternoPaziente Is Nothing OrElse IdEsternoPaziente.Length = 0 Then
            Throw New System.Exception("Anagrafica.Remove(). Manca il parametro IdEsterno del paziente!")
        End If
        If IdEsternoPazienteFuso Is Nothing OrElse IdEsternoPazienteFuso.Length = 0 Then
            Throw New System.Exception("Anagrafica.Remove(). Manca il parametro IdEsternoPazienteFuso del paziente!")
        End If
        '
        ' Esegue SP
        '
        With sqlcmdExtAnagraficaFondi
            .Parameters("@IdEsterno").Value = IdEsternoPaziente
            .Parameters("@IdEsternoFuso").Value = IdEsternoPazienteFuso

            If Not moSqlTransact Is Nothing Then
                .Transaction = moSqlTransact
            End If

            Dim vScalar As Object = .ExecuteScalar()

            Dim vRet As Object = .Parameters("@RETURN_VALUE").Value
            If (Not vRet Is Nothing) AndAlso (Not IsDBNull(vRet)) AndAlso (CType(vRet, Integer) = 0) Then
                '
                ' Ritorna boolean
                '
                If (Not vScalar Is Nothing) AndAlso (Not IsDBNull(vScalar)) Then
                    Return CType(vScalar, Integer) > 0
                Else
                    Throw New System.Exception("Errore durante Exec SP ExtAnagraficaFondi(); Risultato vuoto!")
                End If
            Else
                Throw New System.Exception("Errore durante Exec SP ExtAnagraficaFondi(); SQL error: " & vRet.ToString())
            End If
        End With

    End Function

    Public Function Remove(ByVal IdEsternoPaziente As String) As Boolean
        '
        ' Verifiche dei parametri
        '
        If IdEsternoPaziente Is Nothing OrElse IdEsternoPaziente.Length = 0 Then
            Throw New System.Exception("Anagrafica.Remove(). Manca il parametro IdEsterno del paziente!")
        End If
        '
        ' Esegue SP
        '
        With sqlcmdExtAnagraficaRimuovi
            .Parameters("@IdEsterno").Value = IdEsternoPaziente

            If Not moSqlTransact Is Nothing Then
                .Transaction = moSqlTransact
            End If

            Dim vScalar As Object = .ExecuteScalar()

            Dim vRet As Object = .Parameters("@RETURN_VALUE").Value
            If (Not vRet Is Nothing) AndAlso (Not IsDBNull(vRet)) AndAlso (CType(vRet, Integer) = 0) Then
                '
                ' Ritorna boolean
                '
                If (Not vScalar Is Nothing) AndAlso (Not IsDBNull(vScalar)) Then
                    Return CType(vScalar, Integer) > 0
                Else
                    Throw New System.Exception("Errore durante Exec SP ExtAnagraficaRimuovi(); Risultato vuoto!")
                End If
            Else
                Throw New System.Exception("Errore durante Exec SP ExtAnagraficaRimuovi(); SQL error: " & vRet.ToString())
            End If
        End With

    End Function

    Public Function ReferenceAddNew(ByVal IdEsternoPaziente As String, _
                            ByVal Anagrafica As String, _
                            ByVal IdAnagrafica As String) As Boolean
        '
        ' Verifiche dei parametri
        '
        If IdEsternoPaziente Is Nothing OrElse IdEsternoPaziente.Length = 0 Then
            Throw New System.Exception("Anagrafica.ReferenceAddNew(). Manca il parametro IdEsterno del paziente!")
        End If
        If Anagrafica Is Nothing OrElse Anagrafica.Length = 0 Then
            Throw New System.Exception("Anagrafica.ReferenceAddNew(). Manca il parametro Anagrafica!")
        End If
        If IdAnagrafica Is Nothing OrElse IdAnagrafica.Length = 0 Then
            Throw New System.Exception("Anagrafica.ReferenceAddNew(). Manca il parametro IdAnagrafica!")
        End If
        '
        ' Esegue SP
        '
        With sqlcmdExtAnagraficaRiferimentiAggiungi
            .Parameters("@IdEsterno").Value = IdEsternoPaziente
            .Parameters("@Anagrafica").Value = Anagrafica
            .Parameters("@IdAnagrafica").Value = IdAnagrafica

            If Not moSqlTransact Is Nothing Then
                .Transaction = moSqlTransact
            End If

            Dim vScalar As Object = .ExecuteScalar()

            Dim vRetVal As Object = .Parameters("@RETURN_VALUE").Value
            If (vRetVal Is Nothing) OrElse IsDBNull(vRetVal) OrElse (CType(vRetVal, Integer) <> 0) Then
                Throw New System.Exception("Errore durante Exec SP ExtAnagraficaRiferimentiAggiungi(); SQL error: " & vRetVal.ToString())
            Else
                '
                ' Ritorna boolean
                '
                If (Not vScalar Is Nothing) AndAlso (Not IsDBNull(vScalar)) Then
                    Return CType(vScalar, Integer) > 0
                Else
                    Throw New System.Exception("Errore durante Exec SP ExtAnagraficaRiferimentiAggiungi(); Risultato vuoto!")
                End If
            End If
        End With

    End Function

    Public Function ReferenceUpdate(ByVal IdEsternoPaziente As String, _
                        ByVal Anagrafica As String, _
                        ByVal IdAnagrafica As String) As Boolean
        '
        ' Verifiche dei parametri
        '
        If IdEsternoPaziente Is Nothing OrElse IdEsternoPaziente.Length = 0 Then
            Throw New System.Exception("Anagrafica.ReferenceUpdate(). Manca il parametro IdEsterno del paziente!")
        End If
        If Anagrafica Is Nothing OrElse Anagrafica.Length = 0 Then
            Throw New System.Exception("Anagrafica.ReferenceUpdate(). Manca il parametro Anagrafica!")
        End If
        If IdAnagrafica Is Nothing OrElse IdAnagrafica.Length = 0 Then
            Throw New System.Exception("Anagrafica.ReferenceUpdate(). Manca il parametro IdAnagrafica!")
        End If
        '
        ' Esegue SP
        '
        With sqlcmdExtAnagraficaRiferimentiModifica
            .Parameters("@IdEsterno").Value = IdEsternoPaziente
            .Parameters("@Anagrafica").Value = Anagrafica
            .Parameters("@IdAnagrafica").Value = IdAnagrafica

            If Not moSqlTransact Is Nothing Then
                .Transaction = moSqlTransact
            End If

            Dim vScalar As Object = .ExecuteScalar()

            Dim vRetVal As Object = .Parameters("@RETURN_VALUE").Value
            If (vRetVal Is Nothing) OrElse IsDBNull(vRetVal) OrElse (CType(vRetVal, Integer) <> 0) Then
                Throw New System.Exception("Errore durante Exec SP ExtAnagraficaRiferimentiModifica(); SQL error: " & vRetVal.ToString())
            Else
                '
                ' Ritorna boolean
                '
                If (Not vScalar Is Nothing) AndAlso (Not IsDBNull(vScalar)) Then
                    Return CType(vScalar, Integer) > 0
                Else
                    Throw New System.Exception("Errore durante Exec SP ExtAnagraficaRiferimentiModifica(); Risultato vuoto!")
                End If
            End If
        End With

    End Function

    Public Function ReferenceContains(ByVal IdEsternoPaziente As String, _
                                ByVal Anagrafica As String) As Boolean
        '
        ' Verifiche dei parametri
        '
        If IdEsternoPaziente.Length = 0 Then
            Throw New System.Exception("Anagrafica.ReferenceContains(). Manca il parametro IdEsterno del paziente!")
        End If
        If Anagrafica.Length = 0 Then
            Throw New System.Exception("Anagrafica.ReferenceContains(). Manca il parametro Anagrafica!")
        End If
        '
        ' Esegue SP
        '
        With sqlcmdExtAnagraficaRiferimentiEsiste
            .Parameters("@IdEsterno").Value = IdEsternoPaziente
            .Parameters("@Anagrafica").Value = Anagrafica

            If Not moSqlTransact Is Nothing Then
                .Transaction = moSqlTransact
            End If

            Dim vScalar As Object = .ExecuteScalar()

            Dim vRet As Object = .Parameters("@RETURN_VALUE").Value
            If (Not vRet Is Nothing) AndAlso (Not IsDBNull(vRet)) AndAlso (CType(vRet, Integer) = 0) Then
                '
                ' Ritorna boolean
                '
                If (Not vScalar Is Nothing) AndAlso (Not IsDBNull(vScalar)) Then
                    Return (vScalar.ToString.Length > 0)
                Else
                    Return False
                End If
            Else
                Throw New System.Exception("Errore durante Exec SP ExtAnagraficaRiferimentiEsiste(); SQL error: " & vRet.ToString())
            End If
        End With

    End Function

    Public Function ReferenceRemove(ByVal IdEsternoPaziente As String, _
                            ByVal Anagrafica As String) As Boolean
        '
        ' Verifiche dei parametri
        '
        If IdEsternoPaziente Is Nothing OrElse IdEsternoPaziente.Length = 0 Then
            Throw New System.Exception("Anagrafica.ReferenceRemove(). Manca il parametro IdEsterno del paziente!")
        End If
        '
        ' Esegue SP
        '
        With sqlcmdExtAnagraficaRiferimentiRimuovi
            .Parameters("@IdEsterno").Value = IdEsternoPaziente
            If Anagrafica IsNot Nothing AndAlso Anagrafica.Length > 0 Then
                .Parameters("@Anagrafica").Value = Anagrafica
            End If

            If Not moSqlTransact Is Nothing Then
                .Transaction = moSqlTransact
            End If

            Dim vScalar As Object = .ExecuteScalar()

            Dim vRet As Object = .Parameters("@RETURN_VALUE").Value
            If (Not vRet Is Nothing) AndAlso (Not IsDBNull(vRet)) AndAlso (CType(vRet, Integer) = 0) Then
                '
                ' Ritorna boolean
                '
                If (Not vScalar Is Nothing) AndAlso (Not IsDBNull(vScalar)) Then
                    Return CType(vScalar, Integer) > 0
                Else
                    Throw New System.Exception("Errore durante Exec SP ExtAnagraficaRiferimentiRimuovi(); Risultato vuoto!")
                End If
            Else
                Throw New System.Exception("Errore durante Exec SP ExtAnagraficaRiferimentiRimuovi(); SQL error: " & vRet.ToString())
            End If
        End With

    End Function

    Public Function Reference(ByVal Anagrafica As String, _
                                ByVal IdAnagrafica As String) As String
        '
        ' Verifiche dei parametri
        '
        If IdAnagrafica Is Nothing OrElse IdAnagrafica.Length = 0 Then
            Throw New System.Exception("Anagrafica.Reference). Manca il parametro IdAnagrafica!")
        End If
        If Anagrafica Is Nothing OrElse Anagrafica.Length = 0 Then
            Throw New System.Exception("Anagrafica.Reference(). Manca il parametro Anagrafica!")
        End If
        '
        ' Esegue SP
        '
        With sqlcmdExtAnagraficaRiferimento
            .Parameters("@Anagrafica").Value = Anagrafica
            .Parameters("@IdAnagrafica").Value = IdAnagrafica

            If Not moSqlTransact Is Nothing Then
                .Transaction = moSqlTransact
            End If

            Dim vScalar As Object = .ExecuteScalar()

            Dim vRet As Object = .Parameters("@RETURN_VALUE").Value
            If (Not vRet Is Nothing) AndAlso (Not IsDBNull(vRet)) AndAlso (CType(vRet, Integer) = 0) Then
                '
                ' Ritorna IdEsterno
                '
                If (Not vScalar Is Nothing) AndAlso (Not IsDBNull(vScalar)) Then
                    Return vScalar.ToString
                Else
                    Return Nothing
                End If
            Else
                Throw New System.Exception("Errore durante Exec SP ExtAnagraficaRiferimento(); SQL error: " & vRet.ToString())
            End If
        End With

    End Function

    ''' <summary>
    ''' Indica se all'IdEsternoPaziente corrisponde un record dell'anagrafico
    ''' </summary>
    ''' <param name="IdEsternoPaziente"></param>
    ''' <returns>True se esiste un record per l'IdEsterno</returns>
    ''' <remarks></remarks>
    Public Function IsAnagrafica(ByVal IdEsternoPaziente As String) As Boolean
        '
        ' Verifiche dei parametri
        '
        If IdEsternoPaziente Is Nothing OrElse IdEsternoPaziente.Length = 0 Then
            Throw New System.Exception("Anagrafica.IsAnagrafica(). Manca il parametro IdEsterno del paziente!")
        End If
        '
        ' Esegue SP
        '
        With sqlcmdExtAnagraficaIsAnagrafica
            .Parameters("@IdEsterno").Value = IdEsternoPaziente

            If Not moSqlTransact Is Nothing Then
                .Transaction = moSqlTransact
            End If

            Dim vScalar As Object = .ExecuteScalar()

            Dim vRet As Object = .Parameters("@RETURN_VALUE").Value
            If (Not vRet Is Nothing) AndAlso (Not IsDBNull(vRet)) AndAlso (CType(vRet, Integer) = 0) Then
                '
                ' Nessun errore
                '
                If (Not vScalar Is Nothing) AndAlso (Not IsDBNull(vScalar)) Then
                    '
                    ' Ritorna true se l'id esterno corrisponde ad un record nella tab PazientiBase
                    '
                    Return CType(vScalar, Boolean)
                Else
                    Return Nothing
                End If
            Else
                Throw New System.Exception("Errore durante Exec SP ExtAnagraficaIsAnagrafica(); SQL error: " & vRet.ToString())
            End If
        End With
    End Function
End Class
