Friend Class ConsensiAdapter
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

            'This call is required by the Component Designer.
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
    Friend WithEvents sqlcnnDwhClinico As System.Data.SqlClient.SqlConnection
    Friend WithEvents sqlcmdExtAnagraficaEsiste As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtAnagraficaRiferimento As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtAnagraficaConsensiAggiorna As System.Data.SqlClient.SqlCommand
    <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()
        Me.sqlcnnDwhClinico = New System.Data.SqlClient.SqlConnection
        Me.sqlcmdExtAnagraficaConsensiAggiorna = New System.Data.SqlClient.SqlCommand
        Me.sqlcmdExtAnagraficaEsiste = New System.Data.SqlClient.SqlCommand
        Me.sqlcmdExtAnagraficaRiferimento = New System.Data.SqlClient.SqlCommand
        '
        'sqlcnnDwhClinico
        '
        Me.sqlcnnDwhClinico.ConnectionString = "Data Source=tatooine;Initial Catalog=AuslAsmnRe_DwhClinico;Integrated Security=Tr" & _
            "ue"
        Me.sqlcnnDwhClinico.FireInfoMessageEventOnUserErrors = False
        '
        'sqlcmdExtAnagraficaConsensiAggiorna
        '
        Me.sqlcmdExtAnagraficaConsensiAggiorna.CommandText = "dbo.[ExtAnagraficaConsensiAggiorna]"
        Me.sqlcmdExtAnagraficaConsensiAggiorna.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtAnagraficaConsensiAggiorna.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtAnagraficaConsensiAggiorna.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@IdEsterno", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@Tipo", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@Stato", System.Data.SqlDbType.Bit, 1), New System.Data.SqlClient.SqlParameter("@DataStato", System.Data.SqlDbType.DateTime, 8)})
        '
        'sqlcmdExtAnagraficaEsiste
        '
        Me.sqlcmdExtAnagraficaEsiste.CommandText = "dbo.[ExtAnagraficaEsiste]"
        Me.sqlcmdExtAnagraficaEsiste.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtAnagraficaEsiste.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtAnagraficaEsiste.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@IdEsterno", System.Data.SqlDbType.VarChar, 64)})
        '
        'sqlcmdExtAnagraficaRiferimento
        '
        Me.sqlcmdExtAnagraficaRiferimento.CommandText = "dbo.[ExtAnagraficaRiferimento]"
        Me.sqlcmdExtAnagraficaRiferimento.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtAnagraficaRiferimento.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtAnagraficaRiferimento.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@Anagrafica", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@IdAnagrafica", System.Data.SqlDbType.VarChar, 64)})

    End Sub

#End Region

    Dim moSqlTransact As SqlClient.SqlTransaction

    Public Sub TransactionBegin(ByVal IsolationLevel As System.data.IsolationLevel)
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
        End Try

    End Sub

    Public Sub ConsensoAggiorna(ByVal IdEsternoPaziente As String, _
                            ByVal Tipo As String, _
                            ByVal Stato As Boolean, _
                            ByVal DataStato As DateTime)
        '
        ' Verifiche dei parametri
        '
        If IdEsternoPaziente Is Nothing OrElse IdEsternoPaziente.Length = 0 Then
            Throw New System.Exception("Consenso.ConsensoAggiorna(). Manca il parametro IdEsterno del paziente!")
        End If
        '
        ' Esegue SP
        '
        With sqlcmdExtAnagraficaConsensiAggiorna
            .Parameters("@IdEsterno").Value = IdEsternoPaziente
            .Parameters("@Tipo").Value = Tipo
            .Parameters("@Stato").Value = Stato
            .Parameters("@DataStato").Value = DataStato

            If Not moSqlTransact Is Nothing Then
                .Transaction = moSqlTransact
            End If

            Dim vScalar As Object = .ExecuteScalar()

            Dim vRetVal As Object = .Parameters("@RETURN_VALUE").Value
            If (vRetVal Is Nothing) OrElse IsDBNull(vRetVal) OrElse (CType(vRetVal, Integer) <> 0) Then
                Throw New System.Exception("SQL error : " & vRetVal.ToString() & vbCrLf & "sqlcmdExtAnagraficaConsensiAggiorna")
            Else
                '
                ' Controllo risultato
                '
                If (Not vScalar Is Nothing) AndAlso (Not IsDBNull(vScalar)) Then
                    If CType(vScalar, Integer) = 0 Then
                        Throw New System.Exception("Nessun concenso aggiornato!" & vbCrLf & "sqlcmdExtAnagraficaConsensiAggiorna=0")
                    End If
                Else
                    Throw New System.Exception("Nessun concenso aggiornato!" & vbCrLf & "sqlcmdExtAnagraficaConsensiAggiorna=NULL.")
                End If
            End If
        End With

    End Sub

    Public Function AnagraficaEsiste(ByVal IdEsternoPaziente As String) As Boolean
        '
        ' Verifiche dei parametri
        '
        If IdEsternoPaziente Is Nothing OrElse IdEsternoPaziente.Length = 0 Then
            Throw New System.Exception("Consenso.AnagraficaEsiste(). Manca il parametro IdEsterno del paziente!")
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

            Dim vRetVal As Object = .Parameters("@RETURN_VALUE").Value
            If (vRetVal Is Nothing) OrElse IsDBNull(vRetVal) OrElse (CType(vRetVal, Integer) <> 0) Then
                Throw New System.Exception("SQL error : " & vRetVal.ToString() & vbCrLf & "AnagraficaEsiste")
            Else
                '
                ' Ritorna boolean
                '
                If (Not vScalar Is Nothing) AndAlso (Not IsDBNull(vScalar)) Then
                    Return (vScalar.ToString.Length > 0)
                Else
                    Return False
                End If
            End If
        End With

    End Function

    Public Function AnagraficaRiferimento(ByVal Anagrafica As String, ByVal IdAnagrafica As String) As String
        '
        ' Verifiche dei parametri
        '
        If Anagrafica Is Nothing OrElse Anagrafica.Length = 0 Then
            Throw New System.Exception("Consenso.AnagraficaRiferimento(). Manca il parametro Anagrafica!")
        End If

        If IdAnagrafica Is Nothing OrElse IdAnagrafica.Length = 0 Then
            Throw New System.Exception("Consenso.AnagraficaRiferimento(). Manca il parametro IdAnagrafica!")
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

            Dim vRetVal As Object = .Parameters("@RETURN_VALUE").Value
            If (vRetVal Is Nothing) OrElse IsDBNull(vRetVal) OrElse (CType(vRetVal, Integer) <> 0) Then
                Throw New System.Exception("SQL error : " & vRetVal.ToString() & vbCrLf & "AnagraficaRiferimento")
            Else
                '
                ' Ritorna boolean
                '
                If (Not vScalar Is Nothing) AndAlso (Not IsDBNull(vScalar)) Then
                    Return vScalar.ToString
                Else
                    Return Nothing
                End If
            End If
        End With

    End Function

End Class

