Friend Class EventoAdapter
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
    Friend WithEvents sqlcmdExtEventiEsiste As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcnnDwhClinico As System.Data.SqlClient.SqlConnection
    Friend WithEvents sqlcmdExtPazienteEsiste As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtEventiRimuovi As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtEventiModifica As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtPazienteModifica As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtPazienteDipAssociaRiferimenti As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtPazienteDipAssocia As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtPazienteAggiungi As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtEventiAggiungi As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtPazienteDipEsiste As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtPazienteRimuovi As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtEventiRicoveroRimuovi As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtEventiRicoveroFondi As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtEventiRicoveroAnnulla As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtEventiRicoveroRiapri As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtEventiRicoveroConsolida As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtRicoveriRimuovi As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtRicoveriDataModifica As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtRicoveriEsiste As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtRicoveriAggiungi As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtRicoveriModifica As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtPazienteAggiungi3 As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtEventiBeforeProcess As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtEventiAfterProcess As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtPazienteLookUpNomeAnagraficaDiRicerca As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtEventiAggiungi3 As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtEventiModifica3 As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtRicoveriAggiungi3 As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtRicoveriModifica3 As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtEventiListaAttesaChiusuraLista As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtEventiListaAttesaRiaperturaLista As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtEventiListaAttesaSpostamentoAnagrafico As System.Data.SqlClient.SqlCommand
    Friend WithEvents SqlCmdExtLogAutoPrefix As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtEventiRicoveroConsolidaRicovero2 As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtEventiRicoveroConsolidaPrenotazione As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtEventiDataModifica As System.Data.SqlClient.SqlCommand

    <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()
        Me.sqlcmdExtEventiEsiste = New System.Data.SqlClient.SqlCommand()
        Me.sqlcnnDwhClinico = New System.Data.SqlClient.SqlConnection()
        Me.sqlcmdExtPazienteEsiste = New System.Data.SqlClient.SqlCommand()
        Me.sqlcmdExtEventiRimuovi = New System.Data.SqlClient.SqlCommand()
        Me.sqlcmdExtEventiModifica = New System.Data.SqlClient.SqlCommand()
        Me.sqlcmdExtPazienteModifica = New System.Data.SqlClient.SqlCommand()
        Me.sqlcmdExtPazienteDipAssociaRiferimenti = New System.Data.SqlClient.SqlCommand()
        Me.sqlcmdExtPazienteDipAssocia = New System.Data.SqlClient.SqlCommand()
        Me.sqlcmdExtPazienteAggiungi = New System.Data.SqlClient.SqlCommand()
        Me.sqlcmdExtEventiAggiungi = New System.Data.SqlClient.SqlCommand()
        Me.sqlcmdExtPazienteDipEsiste = New System.Data.SqlClient.SqlCommand()
        Me.sqlcmdExtPazienteRimuovi = New System.Data.SqlClient.SqlCommand()
        Me.sqlcmdExtEventiDataModifica = New System.Data.SqlClient.SqlCommand()
        Me.sqlcmdExtEventiRicoveroRimuovi = New System.Data.SqlClient.SqlCommand()
        Me.sqlcmdExtEventiRicoveroFondi = New System.Data.SqlClient.SqlCommand()
        Me.sqlcmdExtEventiRicoveroAnnulla = New System.Data.SqlClient.SqlCommand()
        Me.sqlcmdExtEventiRicoveroRiapri = New System.Data.SqlClient.SqlCommand()
        Me.sqlcmdExtEventiRicoveroConsolida = New System.Data.SqlClient.SqlCommand()
        Me.sqlcmdExtRicoveriRimuovi = New System.Data.SqlClient.SqlCommand()
        Me.sqlcmdExtRicoveriDataModifica = New System.Data.SqlClient.SqlCommand()
        Me.sqlcmdExtRicoveriEsiste = New System.Data.SqlClient.SqlCommand()
        Me.sqlcmdExtRicoveriAggiungi = New System.Data.SqlClient.SqlCommand()
        Me.sqlcmdExtRicoveriModifica = New System.Data.SqlClient.SqlCommand()
        Me.sqlcmdExtPazienteAggiungi3 = New System.Data.SqlClient.SqlCommand()
        Me.sqlcmdExtEventiBeforeProcess = New System.Data.SqlClient.SqlCommand()
        Me.sqlcmdExtEventiAfterProcess = New System.Data.SqlClient.SqlCommand()
        Me.sqlcmdExtPazienteLookUpNomeAnagraficaDiRicerca = New System.Data.SqlClient.SqlCommand()
        Me.sqlcmdExtEventiAggiungi3 = New System.Data.SqlClient.SqlCommand()
        Me.sqlcmdExtEventiModifica3 = New System.Data.SqlClient.SqlCommand()
        Me.sqlcmdExtRicoveriAggiungi3 = New System.Data.SqlClient.SqlCommand()
        Me.sqlcmdExtRicoveriModifica3 = New System.Data.SqlClient.SqlCommand()
        Me.sqlcmdExtEventiListaAttesaChiusuraLista = New System.Data.SqlClient.SqlCommand()
        Me.sqlcmdExtEventiListaAttesaRiaperturaLista = New System.Data.SqlClient.SqlCommand()
        Me.sqlcmdExtEventiListaAttesaSpostamentoAnagrafico = New System.Data.SqlClient.SqlCommand()
        Me.SqlCmdExtLogAutoPrefix = New System.Data.SqlClient.SqlCommand()
        Me.sqlcmdExtEventiRicoveroConsolidaRicovero2 = New System.Data.SqlClient.SqlCommand()
        Me.sqlcmdExtEventiRicoveroConsolidaPrenotazione = New System.Data.SqlClient.SqlCommand()
        '
        'sqlcmdExtEventiEsiste
        '
        Me.sqlcmdExtEventiEsiste.CommandText = "dbo.[ExtEventiEsiste]"
        Me.sqlcmdExtEventiEsiste.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtEventiEsiste.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtEventiEsiste.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@IdEsterno", System.Data.SqlDbType.VarChar, 64)})
        '
        'sqlcnnDwhClinico
        '
        Me.sqlcnnDwhClinico.ConnectionString = "Data Source=ALDERAAN;Initial Catalog=AuslAsmnRe_DwhClinicoV3;Integrated Security=" & _
    "True"
        Me.sqlcnnDwhClinico.FireInfoMessageEventOnUserErrors = False
        '
        'sqlcmdExtPazienteEsiste
        '
        Me.sqlcmdExtPazienteEsiste.CommandText = "dbo.[ExtPazienteEsiste2]"
        Me.sqlcmdExtPazienteEsiste.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtPazienteEsiste.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtPazienteEsiste.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@IdEsterno", System.Data.SqlDbType.VarChar, 64)})
        '
        'sqlcmdExtEventiRimuovi
        '
        Me.sqlcmdExtEventiRimuovi.CommandText = "dbo.[ExtEventiRimuovi]"
        Me.sqlcmdExtEventiRimuovi.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtEventiRimuovi.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtEventiRimuovi.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@IdEsterno", System.Data.SqlDbType.VarChar, 64)})
        '
        'sqlcmdExtEventiModifica
        '
        Me.sqlcmdExtEventiModifica.CommandText = "dbo.[ExtEventiModifica]"
        Me.sqlcmdExtEventiModifica.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtEventiModifica.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtEventiModifica.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@IdEsterno", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@IdEsternoPaziente", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@AziendaErogante", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@SistemaErogante", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@RepartoErogante", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@DataEvento", System.Data.SqlDbType.DateTime, 8), New System.Data.SqlClient.SqlParameter("@NumeroNosologico", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@TipoEventoCodice", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@TipoEventoDescr", System.Data.SqlDbType.VarChar, 128), New System.Data.SqlClient.SqlParameter("@TipoEpisodio", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@TipoEpisodioDescr", System.Data.SqlDbType.VarChar, 128), New System.Data.SqlClient.SqlParameter("@RepartoCodice", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@RepartoDescr", System.Data.SqlDbType.VarChar, 128), New System.Data.SqlClient.SqlParameter("@Diagnosi", System.Data.SqlDbType.VarChar, 1024), New System.Data.SqlClient.SqlParameter("@XmlAttributi", System.Data.SqlDbType.Text, 2147483647)})
        '
        'sqlcmdExtPazienteModifica
        '
        Me.sqlcmdExtPazienteModifica.CommandText = "dbo.[ExtPazienteModifica2]"
        Me.sqlcmdExtPazienteModifica.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtPazienteModifica.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtPazienteModifica.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@IdEsterno", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@AziendaErogante", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@SistemaErogante", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@RepartoErogante", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@CodiceSanitario", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@Sesso", System.Data.SqlDbType.VarChar, 1), New System.Data.SqlClient.SqlParameter("@Cognome", System.Data.SqlDbType.VarChar, 50), New System.Data.SqlClient.SqlParameter("@Nome", System.Data.SqlDbType.VarChar, 50), New System.Data.SqlClient.SqlParameter("@CodiceFiscale", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@DataNascita", System.Data.SqlDbType.DateTime, 8), New System.Data.SqlClient.SqlParameter("@LuogoNascita", System.Data.SqlDbType.VarChar, 80), New System.Data.SqlClient.SqlParameter("@DatiAnamnestici", System.Data.SqlDbType.VarChar, 8000), New System.Data.SqlClient.SqlParameter("@XmlAttributi", System.Data.SqlDbType.VarChar, 2147483647)})
        '
        'sqlcmdExtPazienteDipAssociaRiferimenti
        '
        Me.sqlcmdExtPazienteDipAssociaRiferimenti.CommandText = "dbo.[ExtPazienteDipAssociaRiferimenti]"
        Me.sqlcmdExtPazienteDipAssociaRiferimenti.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtPazienteDipAssociaRiferimenti.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtPazienteDipAssociaRiferimenti.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@IdEsterno", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@Anagrafice", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@IdAnagrafice", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@AziendaErogante", System.Data.SqlDbType.VarChar, 16)})
        '
        'sqlcmdExtPazienteDipAssocia
        '
        Me.sqlcmdExtPazienteDipAssocia.CommandText = "dbo.[ExtPazienteDipAssocia2]"
        Me.sqlcmdExtPazienteDipAssocia.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtPazienteDipAssocia.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtPazienteDipAssocia.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@IdEsterno", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@Nome", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@Cognome", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@CodiceFiscale", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@CodiceSanitario", System.Data.SqlDbType.VarChar, 12), New System.Data.SqlClient.SqlParameter("@DataNascita", System.Data.SqlDbType.DateTime, 8)})
        '
        'sqlcmdExtPazienteAggiungi
        '
        Me.sqlcmdExtPazienteAggiungi.CommandText = "dbo.[ExtPazienteAggiungi2]"
        Me.sqlcmdExtPazienteAggiungi.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtPazienteAggiungi.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtPazienteAggiungi.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@IdEsterno", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@AziendaErogante", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@SistemaErogante", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@RepartoErogante", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@CodiceSanitario", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@Sesso", System.Data.SqlDbType.VarChar, 1), New System.Data.SqlClient.SqlParameter("@Cognome", System.Data.SqlDbType.VarChar, 50), New System.Data.SqlClient.SqlParameter("@Nome", System.Data.SqlDbType.VarChar, 50), New System.Data.SqlClient.SqlParameter("@CodiceFiscale", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@DataNascita", System.Data.SqlDbType.DateTime, 8), New System.Data.SqlClient.SqlParameter("@LuogoNascita", System.Data.SqlDbType.VarChar, 80), New System.Data.SqlClient.SqlParameter("@DatiAnamnestici", System.Data.SqlDbType.VarChar, 8000), New System.Data.SqlClient.SqlParameter("@XmlAttributi", System.Data.SqlDbType.VarChar, 2147483647)})
        '
        'sqlcmdExtEventiAggiungi
        '
        Me.sqlcmdExtEventiAggiungi.CommandText = "dbo.[ExtEventiAggiungi]"
        Me.sqlcmdExtEventiAggiungi.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtEventiAggiungi.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtEventiAggiungi.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@IdEsterno", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@IdEsternoPaziente", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@AziendaErogante", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@SistemaErogante", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@RepartoErogante", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@DataEvento", System.Data.SqlDbType.DateTime, 8), New System.Data.SqlClient.SqlParameter("@NumeroNosologico", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@TipoEventoCodice", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@TipoEventoDescr", System.Data.SqlDbType.VarChar, 128), New System.Data.SqlClient.SqlParameter("@TipoEpisodio", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@TipoEpisodioDescr", System.Data.SqlDbType.VarChar, 128), New System.Data.SqlClient.SqlParameter("@RepartoCodice", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@RepartoDescr", System.Data.SqlDbType.VarChar, 128), New System.Data.SqlClient.SqlParameter("@Diagnosi", System.Data.SqlDbType.VarChar, 1024), New System.Data.SqlClient.SqlParameter("@XmlAttributi", System.Data.SqlDbType.Text, 2147483647)})
        '
        'sqlcmdExtPazienteDipEsiste
        '
        Me.sqlcmdExtPazienteDipEsiste.CommandText = "dbo.[ExtPazienteDipEsiste2]"
        Me.sqlcmdExtPazienteDipEsiste.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtPazienteDipEsiste.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtPazienteDipEsiste.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@IdEsterno", System.Data.SqlDbType.VarChar, 64)})
        '
        'sqlcmdExtPazienteRimuovi
        '
        Me.sqlcmdExtPazienteRimuovi.CommandText = "dbo.[ExtPazienteRimuovi2]"
        Me.sqlcmdExtPazienteRimuovi.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtPazienteRimuovi.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtPazienteRimuovi.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@IdEsterno", System.Data.SqlDbType.VarChar, 64)})
        '
        'sqlcmdExtEventiDataModifica
        '
        Me.sqlcmdExtEventiDataModifica.CommandText = "dbo.[ExtEventiDataModifica]"
        Me.sqlcmdExtEventiDataModifica.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtEventiDataModifica.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtEventiDataModifica.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@IdEsterno", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@DataModificaEsterno", System.Data.SqlDbType.DateTime, 8)})
        '
        'sqlcmdExtEventiRicoveroRimuovi
        '
        Me.sqlcmdExtEventiRicoveroRimuovi.CommandText = "dbo.[ExtEventiRicoveroRimuovi]"
        Me.sqlcmdExtEventiRicoveroRimuovi.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtEventiRicoveroRimuovi.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtEventiRicoveroRimuovi.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@IdEsterno", System.Data.SqlDbType.VarChar, 64)})
        '
        'sqlcmdExtEventiRicoveroFondi
        '
        Me.sqlcmdExtEventiRicoveroFondi.CommandText = "dbo.[ExtEventiRicoveroFondi]"
        Me.sqlcmdExtEventiRicoveroFondi.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtEventiRicoveroFondi.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtEventiRicoveroFondi.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@IdEsterno", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@XmlAttributi", System.Data.SqlDbType.Text, 2147483647)})
        '
        'sqlcmdExtEventiRicoveroAnnulla
        '
        Me.sqlcmdExtEventiRicoveroAnnulla.CommandText = "dbo.[ExtEventiRicoveroAnnulla]"
        Me.sqlcmdExtEventiRicoveroAnnulla.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtEventiRicoveroAnnulla.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtEventiRicoveroAnnulla.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@IdEsterno", System.Data.SqlDbType.VarChar, 64)})
        '
        'sqlcmdExtEventiRicoveroRiapri
        '
        Me.sqlcmdExtEventiRicoveroRiapri.CommandText = "dbo.[ExtEventiRicoveroRiapri]"
        Me.sqlcmdExtEventiRicoveroRiapri.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtEventiRicoveroRiapri.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtEventiRicoveroRiapri.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@IdEsterno", System.Data.SqlDbType.VarChar, 64)})
        '
        'sqlcmdExtEventiRicoveroConsolida
        '
        Me.sqlcmdExtEventiRicoveroConsolida.CommandText = "dbo.[ExtEventiRicoveroConsolida]"
        Me.sqlcmdExtEventiRicoveroConsolida.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtEventiRicoveroConsolida.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtEventiRicoveroConsolida.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@IdEsterno", System.Data.SqlDbType.VarChar, 64)})
        '
        'sqlcmdExtRicoveriRimuovi
        '
        Me.sqlcmdExtRicoveriRimuovi.CommandText = "dbo.[ExtRicoveriRimuovi]"
        Me.sqlcmdExtRicoveriRimuovi.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtRicoveriRimuovi.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtRicoveriRimuovi.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@IdEsterno", System.Data.SqlDbType.VarChar, 64)})
        '
        'sqlcmdExtRicoveriDataModifica
        '
        Me.sqlcmdExtRicoveriDataModifica.CommandText = "dbo.[ExtRicoveriDataModifica]"
        Me.sqlcmdExtRicoveriDataModifica.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtRicoveriDataModifica.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtRicoveriDataModifica.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@IdEsterno", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@DataModificaEsterno", System.Data.SqlDbType.DateTime, 8)})
        '
        'sqlcmdExtRicoveriEsiste
        '
        Me.sqlcmdExtRicoveriEsiste.CommandText = "dbo.[ExtRicoveriEsiste]"
        Me.sqlcmdExtRicoveriEsiste.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtRicoveriEsiste.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtRicoveriEsiste.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@IdEsterno", System.Data.SqlDbType.VarChar, 64)})
        '
        'sqlcmdExtRicoveriAggiungi
        '
        Me.sqlcmdExtRicoveriAggiungi.CommandText = "dbo.[ExtRicoveriAggiungi]"
        Me.sqlcmdExtRicoveriAggiungi.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtRicoveriAggiungi.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtRicoveriAggiungi.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@IdEsterno", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@IdEsternoPaziente", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@StatoCodice", System.Data.SqlDbType.TinyInt, 4), New System.Data.SqlClient.SqlParameter("@NumeroNosologico", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@AziendaErogante", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@SistemaErogante", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@RepartoErogante", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@OspedaleCodice", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@OspedaleDescr", System.Data.SqlDbType.VarChar, 128), New System.Data.SqlClient.SqlParameter("@TipoRicoveroCodice", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@TipoRicoveroDescr", System.Data.SqlDbType.VarChar, 128), New System.Data.SqlClient.SqlParameter("@Diagnosi", System.Data.SqlDbType.VarChar, 1024), New System.Data.SqlClient.SqlParameter("@DataAccettazione", System.Data.SqlDbType.DateTime, 8), New System.Data.SqlClient.SqlParameter("@RepartoAccettazioneCodice", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@RepartoAccettazioneDescr", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@DataTrasferimento", System.Data.SqlDbType.DateTime, 8), New System.Data.SqlClient.SqlParameter("@RepartoCodice", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@RepartoDescr", System.Data.SqlDbType.VarChar, 128), New System.Data.SqlClient.SqlParameter("@SettoreCodice", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@SettoreDescr", System.Data.SqlDbType.VarChar, 128), New System.Data.SqlClient.SqlParameter("@LettoCodice", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@DataDimissione", System.Data.SqlDbType.DateTime, 8), New System.Data.SqlClient.SqlParameter("@XmlAttributi", System.Data.SqlDbType.Text, 2147483647)})
        '
        'sqlcmdExtRicoveriModifica
        '
        Me.sqlcmdExtRicoveriModifica.CommandText = "dbo.[ExtRicoveriModifica]"
        Me.sqlcmdExtRicoveriModifica.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtRicoveriModifica.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtRicoveriModifica.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@IdEsterno", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@IdEsternoPaziente", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@StatoCodice", System.Data.SqlDbType.Int, 4), New System.Data.SqlClient.SqlParameter("@NumeroNosologico", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@AziendaErogante", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@SistemaErogante", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@RepartoErogante", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@OspedaleCodice", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@OspedaleDescr", System.Data.SqlDbType.VarChar, 128), New System.Data.SqlClient.SqlParameter("@TipoRicoveroCodice", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@TipoRicoveroDescr", System.Data.SqlDbType.VarChar, 128), New System.Data.SqlClient.SqlParameter("@Diagnosi", System.Data.SqlDbType.VarChar, 1024), New System.Data.SqlClient.SqlParameter("@DataAccettazione", System.Data.SqlDbType.DateTime, 8), New System.Data.SqlClient.SqlParameter("@RepartoAccettazioneCodice", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@RepartoAccettazioneDescr", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@DataTrasferimento", System.Data.SqlDbType.DateTime, 8), New System.Data.SqlClient.SqlParameter("@RepartoCodice", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@RepartoDescr", System.Data.SqlDbType.VarChar, 128), New System.Data.SqlClient.SqlParameter("@SettoreCodice", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@SettoreDescr", System.Data.SqlDbType.VarChar, 128), New System.Data.SqlClient.SqlParameter("@LettoCodice", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@DataDimissione", System.Data.SqlDbType.DateTime, 8), New System.Data.SqlClient.SqlParameter("@XmlAttributi", System.Data.SqlDbType.Text, 2147483647)})
        '
        'sqlcmdExtPazienteAggiungi3
        '
        Me.sqlcmdExtPazienteAggiungi3.CommandText = "dbo.[ExtPazienteAggiungi3]"
        Me.sqlcmdExtPazienteAggiungi3.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtPazienteAggiungi3.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtPazienteAggiungi3.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@IdEsterno", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@AziendaErogante", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@SistemaErogante", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@RepartoErogante", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@IdAnagrafica", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@Sesso", System.Data.SqlDbType.VarChar, 1), New System.Data.SqlClient.SqlParameter("@Cognome", System.Data.SqlDbType.VarChar, 50), New System.Data.SqlClient.SqlParameter("@Nome", System.Data.SqlDbType.VarChar, 50), New System.Data.SqlClient.SqlParameter("@CodiceFiscale", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@DataNascita", System.Data.SqlDbType.DateTime, 8), New System.Data.SqlClient.SqlParameter("@LuogoNascita", System.Data.SqlDbType.VarChar, 80)})
        '
        'sqlcmdExtEventiBeforeProcess
        '
        Me.sqlcmdExtEventiBeforeProcess.CommandText = "dbo.[ExtEventiBeforeProcess]"
        Me.sqlcmdExtEventiBeforeProcess.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtEventiBeforeProcess.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtEventiBeforeProcess.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@IdEsterno", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@Operazione", System.Data.SqlDbType.SmallInt, 2)})
        '
        'sqlcmdExtEventiAfterProcess
        '
        Me.sqlcmdExtEventiAfterProcess.CommandText = "dbo.[ExtEventiAfterProcess]"
        Me.sqlcmdExtEventiAfterProcess.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtEventiAfterProcess.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtEventiAfterProcess.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@IdEsterno", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@Operazione", System.Data.SqlDbType.SmallInt, 2)})
        '
        'sqlcmdExtPazienteLookUpNomeAnagraficaDiRicerca
        '
        Me.sqlcmdExtPazienteLookUpNomeAnagraficaDiRicerca.CommandText = "dbo.[ExtPazienteLookUpNomeAnagraficaDiRicerca]"
        Me.sqlcmdExtPazienteLookUpNomeAnagraficaDiRicerca.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtPazienteLookUpNomeAnagraficaDiRicerca.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtPazienteLookUpNomeAnagraficaDiRicerca.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@NomeAnagrafica", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@AziendaErogante", System.Data.SqlDbType.VarChar, 16)})
        '
        'sqlcmdExtEventiAggiungi3
        '
        Me.sqlcmdExtEventiAggiungi3.CommandText = "dbo.[ExtEventiAggiungi3]"
        Me.sqlcmdExtEventiAggiungi3.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtEventiAggiungi3.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtEventiAggiungi3.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@IdEsterno", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@IdPaziente", System.Data.SqlDbType.UniqueIdentifier, 16), New System.Data.SqlClient.SqlParameter("@AziendaErogante", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@SistemaErogante", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@RepartoErogante", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@DataEvento", System.Data.SqlDbType.DateTime, 8), New System.Data.SqlClient.SqlParameter("@NumeroNosologico", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@TipoEventoCodice", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@TipoEventoDescr", System.Data.SqlDbType.VarChar, 128), New System.Data.SqlClient.SqlParameter("@TipoEpisodio", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@TipoEpisodioDescr", System.Data.SqlDbType.VarChar, 128), New System.Data.SqlClient.SqlParameter("@RepartoCodice", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@RepartoDescr", System.Data.SqlDbType.VarChar, 128), New System.Data.SqlClient.SqlParameter("@Diagnosi", System.Data.SqlDbType.VarChar, 1024), New System.Data.SqlClient.SqlParameter("@XmlAttributi", System.Data.SqlDbType.Text, 2147483647)})
        '
        'sqlcmdExtEventiModifica3
        '
        Me.sqlcmdExtEventiModifica3.CommandText = "dbo.[ExtEventiModifica3]"
        Me.sqlcmdExtEventiModifica3.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtEventiModifica3.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtEventiModifica3.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@IdEsterno", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@IdPaziente", System.Data.SqlDbType.UniqueIdentifier, 16), New System.Data.SqlClient.SqlParameter("@AziendaErogante", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@SistemaErogante", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@RepartoErogante", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@DataEvento", System.Data.SqlDbType.DateTime, 8), New System.Data.SqlClient.SqlParameter("@NumeroNosologico", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@TipoEventoCodice", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@TipoEventoDescr", System.Data.SqlDbType.VarChar, 128), New System.Data.SqlClient.SqlParameter("@TipoEpisodio", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@TipoEpisodioDescr", System.Data.SqlDbType.VarChar, 128), New System.Data.SqlClient.SqlParameter("@RepartoCodice", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@RepartoDescr", System.Data.SqlDbType.VarChar, 128), New System.Data.SqlClient.SqlParameter("@Diagnosi", System.Data.SqlDbType.VarChar, 1024), New System.Data.SqlClient.SqlParameter("@XmlAttributi", System.Data.SqlDbType.Text, 2147483647)})
        '
        'sqlcmdExtRicoveriAggiungi3
        '
        Me.sqlcmdExtRicoveriAggiungi3.CommandText = "dbo.[ExtRicoveriAggiungi3]"
        Me.sqlcmdExtRicoveriAggiungi3.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtRicoveriAggiungi3.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtRicoveriAggiungi3.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@IdEsterno", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@IdPaziente", System.Data.SqlDbType.UniqueIdentifier, 16), New System.Data.SqlClient.SqlParameter("@StatoCodice", System.Data.SqlDbType.TinyInt, 1), New System.Data.SqlClient.SqlParameter("@NumeroNosologico", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@AziendaErogante", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@SistemaErogante", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@RepartoErogante", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@OspedaleCodice", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@OspedaleDescr", System.Data.SqlDbType.VarChar, 128), New System.Data.SqlClient.SqlParameter("@TipoRicoveroCodice", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@TipoRicoveroDescr", System.Data.SqlDbType.VarChar, 128), New System.Data.SqlClient.SqlParameter("@Diagnosi", System.Data.SqlDbType.VarChar, 1024), New System.Data.SqlClient.SqlParameter("@DataAccettazione", System.Data.SqlDbType.DateTime, 8), New System.Data.SqlClient.SqlParameter("@RepartoAccettazioneCodice", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@RepartoAccettazioneDescr", System.Data.SqlDbType.VarChar, 128), New System.Data.SqlClient.SqlParameter("@DataTrasferimento", System.Data.SqlDbType.DateTime, 8), New System.Data.SqlClient.SqlParameter("@RepartoCodice", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@RepartoDescr", System.Data.SqlDbType.VarChar, 128), New System.Data.SqlClient.SqlParameter("@SettoreCodice", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@SettoreDescr", System.Data.SqlDbType.VarChar, 128), New System.Data.SqlClient.SqlParameter("@LettoCodice", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@DataDimissione", System.Data.SqlDbType.DateTime, 8), New System.Data.SqlClient.SqlParameter("@XmlAttributi", System.Data.SqlDbType.Text, 2147483647)})
        '
        'sqlcmdExtRicoveriModifica3
        '
        Me.sqlcmdExtRicoveriModifica3.CommandText = "dbo.[ExtRicoveriModifica3]"
        Me.sqlcmdExtRicoveriModifica3.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtRicoveriModifica3.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtRicoveriModifica3.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@IdEsterno", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@IdPaziente", System.Data.SqlDbType.UniqueIdentifier, 16), New System.Data.SqlClient.SqlParameter("@StatoCodice", System.Data.SqlDbType.TinyInt, 1), New System.Data.SqlClient.SqlParameter("@NumeroNosologico", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@AziendaErogante", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@SistemaErogante", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@RepartoErogante", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@OspedaleCodice", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@OspedaleDescr", System.Data.SqlDbType.VarChar, 128), New System.Data.SqlClient.SqlParameter("@TipoRicoveroCodice", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@TipoRicoveroDescr", System.Data.SqlDbType.VarChar, 128), New System.Data.SqlClient.SqlParameter("@Diagnosi", System.Data.SqlDbType.VarChar, 1024), New System.Data.SqlClient.SqlParameter("@DataAccettazione", System.Data.SqlDbType.DateTime, 8), New System.Data.SqlClient.SqlParameter("@RepartoAccettazioneCodice", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@RepartoAccettazioneDescr", System.Data.SqlDbType.VarChar, 128), New System.Data.SqlClient.SqlParameter("@DataTrasferimento", System.Data.SqlDbType.DateTime, 8), New System.Data.SqlClient.SqlParameter("@RepartoCodice", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@RepartoDescr", System.Data.SqlDbType.VarChar, 128), New System.Data.SqlClient.SqlParameter("@SettoreCodice", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@SettoreDescr", System.Data.SqlDbType.VarChar, 128), New System.Data.SqlClient.SqlParameter("@LettoCodice", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@DataDimissione", System.Data.SqlDbType.DateTime, 8), New System.Data.SqlClient.SqlParameter("@XmlAttributi", System.Data.SqlDbType.Text, 2147483647)})
        '
        'sqlcmdExtEventiListaAttesaChiusuraLista
        '
        Me.sqlcmdExtEventiListaAttesaChiusuraLista.CommandText = "dbo.[ExtEventiListaAttesaChiusuraLista]"
        Me.sqlcmdExtEventiListaAttesaChiusuraLista.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtEventiListaAttesaChiusuraLista.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtEventiListaAttesaChiusuraLista.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@IdEsterno", System.Data.SqlDbType.VarChar, 64)})
        '
        'sqlcmdExtEventiListaAttesaRiaperturaLista
        '
        Me.sqlcmdExtEventiListaAttesaRiaperturaLista.CommandText = "dbo.[ExtEventiListaAttesaRiaperturaLista]"
        Me.sqlcmdExtEventiListaAttesaRiaperturaLista.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtEventiListaAttesaRiaperturaLista.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtEventiListaAttesaRiaperturaLista.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@IdEsterno", System.Data.SqlDbType.VarChar, 64)})
        '
        'sqlcmdExtEventiListaAttesaSpostamentoAnagrafico
        '
        Me.sqlcmdExtEventiListaAttesaSpostamentoAnagrafico.CommandText = "dbo.[ExtEventiListaAttesaSpostamentoAnagrafico]"
        Me.sqlcmdExtEventiListaAttesaSpostamentoAnagrafico.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtEventiListaAttesaSpostamentoAnagrafico.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtEventiListaAttesaSpostamentoAnagrafico.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@IdEsterno", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@XmlAttributi", System.Data.SqlDbType.Text, 2147483647)})
        '
        'SqlCmdExtLogAutoPrefix
        '
        Me.SqlCmdExtLogAutoPrefix.CommandText = "dbo.[ExtLogAutoprefix]"
        Me.SqlCmdExtLogAutoPrefix.CommandType = System.Data.CommandType.StoredProcedure
        Me.SqlCmdExtLogAutoPrefix.Connection = Me.sqlcnnDwhClinico
        Me.SqlCmdExtLogAutoPrefix.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@AziendaErogante", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@SistemaErogante", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@RepartoErogante", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@IdEsterno", System.Data.SqlDbType.VarChar, 64)})
        '
        'sqlcmdExtEventiRicoveroConsolidaRicovero2
        '
        Me.sqlcmdExtEventiRicoveroConsolidaRicovero2.CommandText = "dbo.[ExtEventiRicoveroConsolidaRicovero2]"
        Me.sqlcmdExtEventiRicoveroConsolidaRicovero2.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtEventiRicoveroConsolidaRicovero2.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtEventiRicoveroConsolidaRicovero2.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@AziendaErogante", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@NumeroNosologico", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@RicoveroEsiste", System.Data.SqlDbType.Bit), New System.Data.SqlClient.SqlParameter("@TipoEventoCodice", System.Data.SqlDbType.VarChar, 16)})
        '
        'sqlcmdExtEventiRicoveroConsolidaPrenotazione
        '
        Me.sqlcmdExtEventiRicoveroConsolidaPrenotazione.CommandText = "dbo.[ExtEventiRicoveroConsolidaPrenotazione2]"
        Me.sqlcmdExtEventiRicoveroConsolidaPrenotazione.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtEventiRicoveroConsolidaPrenotazione.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtEventiRicoveroConsolidaPrenotazione.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@AziendaErogante", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@NumeroNosologico", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@RicoveroEsiste", System.Data.SqlDbType.Bit), New System.Data.SqlClient.SqlParameter("@IdEsternoEvento", System.Data.SqlDbType.VarChar, 64)})

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

#Region " Eventi (generici)"

    Public Function EventiAddNew(ByVal IdEsternoEvento As String, _
                        ByVal IdPaziente As Guid, _
                        ByVal AziendaErogante As String, _
                        ByVal SistemaErogante As String, _
                        ByVal RepartoErogante As String, _
                        ByVal DataEvento As Date, _
                        ByVal NumeroNosologico As String, _
                        ByVal TipoEventoCodice As String, _
                        ByVal TipoEventoDescrizione As String, _
                        ByVal TipoEpisodio As String, _
                        ByVal TipoEpisodioDescrizione As String, _
                        ByVal RepartoCodice As String, _
                        ByVal RepartoDescrizione As String, _
                        ByVal Diagnosi As String, _
                        ByVal XmlAttributi As String) As Boolean
        '
        ' Verifiche dei parametri
        '
        If IdEsternoEvento IsNot Nothing AndAlso IdEsternoEvento.Length = 0 Then
            Throw New System.Exception("Manca il parametro IdEsterno dell'evento!")
        End If
        'Non verifico se IdPaziente = Nothing poichè posso passare l'Id nullo
        'If IdPaziente = Nothing Then
        '    Throw New System.Exception("Manca il parametro IdPaziente del referto!")
        'End If
        '
        ' Inserisco il referto
        '
        With sqlcmdExtEventiAggiungi3
            .Parameters("@IdEsterno").Value = IdEsternoEvento
            .Parameters("@IdPaziente").Value = IdPaziente
            .Parameters("@AziendaErogante").Value = AziendaErogante
            .Parameters("@SistemaErogante").Value = SistemaErogante
            .Parameters("@RepartoErogante").Value = RepartoErogante
            .Parameters("@DataEvento").Value = SqlUtil.ParseDatetime(DataEvento)
            .Parameters("@NumeroNosologico").Value = NumeroNosologico
            .Parameters("@TipoEventoCodice").Value = TipoEventoCodice
            .Parameters("@TipoEventoDescr").Value = TipoEventoDescrizione
            .Parameters("@TipoEpisodio").Value = TipoEpisodio
            .Parameters("@TipoEpisodioDescr").Value = TipoEpisodioDescrizione
            .Parameters("@RepartoCodice").Value = RepartoCodice
            .Parameters("@RepartoDescr").Value = RepartoDescrizione
            .Parameters("@Diagnosi").Value = Diagnosi
            .Parameters("@XmlAttributi").Value = XmlAttributi

            If Not moSqlTransact Is Nothing Then
                .Transaction = moSqlTransact
            End If

            Dim vScalar As Object = .ExecuteScalar()

            Dim vRetVal As Object = .Parameters("@RETURN_VALUE").Value
            If (vRetVal Is Nothing) OrElse IsDBNull(vRetVal) OrElse (CType(vRetVal, Integer) <> 0) Then
                Throw New System.Exception("Errore durante Exec SP ExtEventiAggiungi3(); SQL error: " & vRetVal.ToString())
            Else
                '
                ' Ritorna boolean
                '
                If (Not vScalar Is Nothing) AndAlso (Not IsDBNull(vScalar)) Then
                    Return CType(vScalar, Integer) > 0
                Else
                    Throw New System.Exception("Errore durante Exec SP ExtEventiAggiungi3()!")
                End If
            End If
        End With

    End Function

    Public Function EventiUpdate(ByVal IdEsternoEvento As String, _
                           ByVal IdPaziente As Guid, _
                           ByVal AziendaErogante As String, _
                           ByVal SistemaErogante As String, _
                           ByVal RepartoErogante As String, _
                           ByVal DataEvento As Date, _
                           ByVal NumeroNosologico As String, _
                           ByVal TipoEventoCodice As String, _
                           ByVal TipoEventoDescrizione As String, _
                           ByVal TipoEpisodio As String, _
                           ByVal TipoEpisodioDescrizione As String, _
                           ByVal RepartoCodice As String, _
                           ByVal RepartoDescrizione As String, _
                           ByVal Diagnosi As String, _
                           ByVal XmlAttributi As String) As Boolean
        '
        ' Verifiche dei parametri
        '
        If IdEsternoEvento IsNot Nothing AndAlso IdEsternoEvento.Length = 0 Then
            Throw New System.Exception("Manca il parametro IdEsterno dell'evento!")
        End If

        'Non verifico se IdPaziente = Nothing poichè posso passare l'Id nullo
        'If IdPaziente = Nothing Then
        '    Throw New System.Exception("Manca il parametro IdPaziente del referto!")
        'End If
        '
        ' Inserisco il referto
        '
        With sqlcmdExtEventiModifica3
            .Parameters("@IdEsterno").Value = IdEsternoEvento
            .Parameters("@IdPaziente").Value = IdPaziente
            .Parameters("@AziendaErogante").Value = AziendaErogante
            .Parameters("@SistemaErogante").Value = SistemaErogante
            .Parameters("@RepartoErogante").Value = RepartoErogante
            .Parameters("@DataEvento").Value = SqlUtil.ParseDatetime(DataEvento)
            .Parameters("@NumeroNosologico").Value = NumeroNosologico
            .Parameters("@TipoEventoCodice").Value = TipoEventoCodice
            .Parameters("@TipoEventoDescr").Value = TipoEventoDescrizione
            .Parameters("@TipoEpisodio").Value = TipoEpisodio
            .Parameters("@TipoEpisodioDescr").Value = TipoEpisodioDescrizione
            .Parameters("@RepartoCodice").Value = RepartoCodice
            .Parameters("@RepartoDescr").Value = RepartoDescrizione
            .Parameters("@Diagnosi").Value = Diagnosi
            .Parameters("@XmlAttributi").Value = XmlAttributi


            If Not moSqlTransact Is Nothing Then
                .Transaction = moSqlTransact
            End If

            Dim vScalar As Object = .ExecuteScalar()

            Dim vRetVal As Object = .Parameters("@RETURN_VALUE").Value
            If (vRetVal Is Nothing) OrElse IsDBNull(vRetVal) OrElse (CType(vRetVal, Integer) <> 0) Then
                Throw New System.Exception("Errore durante Exec SP ExtEventiModifica3(); SQL error: " & vRetVal.ToString())
            Else
                '
                ' Ritorna boolean
                '
                If (Not vScalar Is Nothing) AndAlso (Not IsDBNull(vScalar)) Then
                    Return CType(vScalar, Integer) > 0
                Else
                    Throw New System.Exception("Errore durante Exec SP ExtEventiModifica3()!")
                End If
            End If
        End With

    End Function

    Public Function EventiDataModificaUpdate(ByVal IdEsternoReferto As String, _
                        ByVal DataModificaEsterno As Date) As Boolean
        '
        ' Verifiche dei parametri
        '
        If IdEsternoReferto IsNot Nothing AndAlso IdEsternoReferto.Length = 0 Then
            Throw New System.Exception("Manca il parametro IdEsterno dell'evento!")
        End If
        '
        ' Modifico il referto
        '
        With sqlcmdExtEventiDataModifica
            .Parameters("@IdEsterno").Value = IdEsternoReferto
            .Parameters("@DataModificaEsterno").Value = DataModificaEsterno

            If Not moSqlTransact Is Nothing Then
                .Transaction = moSqlTransact
            End If

            Dim vScalar As Object = .ExecuteScalar()

            Dim vRetVal As Object = .Parameters("@RETURN_VALUE").Value
            If (vRetVal Is Nothing) OrElse IsDBNull(vRetVal) OrElse (CType(vRetVal, Integer) <> 0) Then
                Throw New System.Exception("Errore durante Exec SP ExtRefertiDataModifica(); SQL error: " & vRetVal.ToString())
            Else
                '
                ' Ritorna boolean
                '
                If (Not vScalar Is Nothing) AndAlso (Not IsDBNull(vScalar)) Then
                    Return CType(vScalar, Integer) > 0
                Else
                    Throw New System.Exception("Errore durante Exec SP ExtRefertiDataModifica(); Referto non trovato!")
                End If
            End If
        End With

    End Function

    Public Function EventiContains(ByVal IdEsternoEvento As String) As Date
        '
        ' Verifiche dei parametri
        '
        If IdEsternoEvento IsNot Nothing AndAlso IdEsternoEvento.Length = 0 Then
            Throw New System.Exception("Manca il parametro IdEsterno dell'evento!")
        End If
        '
        ' Esegue la SP
        '
        With sqlcmdExtEventiEsiste
            .Parameters("@IdEsterno").Value = IdEsternoEvento

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
                    '
                    ' Ritorna la data di modifica esterna
                    '
                    Return CType(vScalar, Date)
                Else
                    Return Nothing
                End If
            Else
                Throw New System.Exception("Errore durante Exec SP ExtEventiEsiste(); SQL error: " & vRet.ToString())
            End If
        End With

    End Function

    Public Function EventiRemove(ByVal IdEsternoEvento As String) As Boolean
        '
        ' Verifiche dei parametri
        '
        If IdEsternoEvento IsNot Nothing AndAlso IdEsternoEvento.Length = 0 Then
            Throw New System.Exception("Manca il parametro IdEsterno dell'evento!")
        End If
        '
        ' Esegue la SP
        '
        With sqlcmdExtEventiRimuovi
            .Parameters("@IdEsterno").Value = IdEsternoEvento

            If Not moSqlTransact Is Nothing Then
                .Transaction = moSqlTransact
            End If

            Dim vScalar As Object = .ExecuteScalar()

            Dim vRet As Object = .Parameters("@RETURN_VALUE").Value
            If (vRet Is Nothing) OrElse IsDBNull(vRet) OrElse (CType(vRet, Integer) <> 0) Then
                Throw New System.Exception("Errore durante Exec SP ExtEventiRimuovi(); SQL error: " & vRet.ToString())
            Else
                '
                ' Ritorna boolean
                '
                If (Not vScalar Is Nothing) AndAlso (Not IsDBNull(vScalar)) Then
                    Return CType(vScalar, Integer) > 0
                Else
                    Throw New System.Exception("Errore durante Exec SP ExtEventiRimuovi()!")
                End If
            End If
        End With

    End Function

#End Region

#Region " Eventi ADT (Ricoveri): Esecuzione di Azioni "

    Public Function EventiRicoveroAnnulla(ByVal IdEsternoEvento As String, ByRef iWarningCode As Integer) As Boolean
        iWarningCode = 0
        '
        ' Verifiche dei parametri
        '
        If IdEsternoEvento IsNot Nothing AndAlso IdEsternoEvento.Length = 0 Then
            Throw New System.Exception("Manca il parametro IdEsterno dell'evento!")
        End If
        '
        ' Esegue la SP
        '
        With sqlcmdExtEventiRicoveroAnnulla
            .Parameters("@IdEsterno").Value = IdEsternoEvento

            If Not moSqlTransact Is Nothing Then
                .Transaction = moSqlTransact
            End If

            Dim vScalar As Object = .ExecuteScalar()

            Dim vRet As Object = .Parameters("@RETURN_VALUE").Value
            If (vRet Is Nothing) OrElse IsDBNull(vRet) OrElse (CType(vRet, Integer) <> 0) Then
                If CType(vRet, Integer) = 1004 Then 'iWarningCode
                    iWarningCode = 1004
                    Return True
                Else
                    Throw New System.Exception("Errore durante Exec SP ExtEventiRicoveroAnnulla(); SQL error: " & vRet.ToString())
                End If
            Else
                '
                ' Ritorna boolean
                '
                If (Not vScalar Is Nothing) AndAlso (Not IsDBNull(vScalar)) Then
                    Return CType(vScalar, Integer) > 0
                Else
                    Throw New System.Exception("Errore durante Exec SP ExtEventiRicoveroAnnulla(); Nosologico non trovato!")
                End If
            End If
        End With

    End Function

    Public Function EventiRicoveroRiapri(ByVal IdEsternoEvento As String, ByRef iWarningCode As Integer) As Boolean
        iWarningCode = 0
        '
        ' Verifiche dei parametri
        '
        If IdEsternoEvento IsNot Nothing AndAlso IdEsternoEvento.Length = 0 Then
            Throw New System.Exception("Manca il parametro IdEsterno dell'evento!")
        End If
        '
        ' Esegue la SP
        '
        With sqlcmdExtEventiRicoveroRiapri
            .Parameters("@IdEsterno").Value = IdEsternoEvento

            If Not moSqlTransact Is Nothing Then
                .Transaction = moSqlTransact
            End If

            Dim vScalar As Object = .ExecuteScalar()

            Dim vRet As Object = .Parameters("@RETURN_VALUE").Value
            If (vRet Is Nothing) OrElse IsDBNull(vRet) OrElse (CType(vRet, Integer) <> 0) Then
                If CType(vRet, Integer) = 1004 Then 'iWarningCode
                    iWarningCode = 1004
                    Return True
                Else
                    Throw New System.Exception("Errore durante Exec SP ExtEventiRicoveroRiapri(); SQL error: " & vRet.ToString())
                End If
            Else
                '
                ' Ritorna boolean
                '
                If (Not vScalar Is Nothing) AndAlso (Not IsDBNull(vScalar)) Then
                    Return CType(vScalar, Integer) > 0
                Else
                    Throw New System.Exception("Errore durante Exec SP ExtEventiRicoveroRiapri(); Evento non trovato!")
                End If
            End If
        End With

    End Function

    Public Function EventiRicoveroRimuovi(ByVal IdEsternoEvento As String, ByRef iWarningCode As Integer) As Boolean
        iWarningCode = 0
        '
        ' Verifiche dei parametri
        '
        If IdEsternoEvento IsNot Nothing AndAlso IdEsternoEvento.Length = 0 Then
            Throw New System.Exception("Manca il parametro IdEsterno dell'evento!")
        End If
        '
        ' Esegue la SP
        '
        With sqlcmdExtEventiRicoveroRimuovi
            .Parameters("@IdEsterno").Value = IdEsternoEvento

            If Not moSqlTransact Is Nothing Then
                .Transaction = moSqlTransact
            End If

            Dim vScalar As Object = .ExecuteScalar()

            Dim vRet As Object = .Parameters("@RETURN_VALUE").Value
            If (vRet Is Nothing) OrElse IsDBNull(vRet) OrElse (CType(vRet, Integer) <> 0) Then
                If CType(vRet, Integer) = 1004 Then 'iWarningCode
                    iWarningCode = 1004
                    Return True
                Else
                    Throw New System.Exception("Errore durante Exec SP ExtEventiRicoveroRimuovi(); SQL error: " & vRet.ToString())
                End If
            Else
                '
                ' Ritorna boolean
                '
                If (Not vScalar Is Nothing) AndAlso (Not IsDBNull(vScalar)) Then
                    Return CType(vScalar, Integer) > 0
                Else
                    Throw New System.Exception("Errore durante Exec SP ExtEventiRicoveroRimuovi(); Nosologico non trovato!")
                End If
            End If
        End With

    End Function

    Public Function EventiRicoveroFondi(ByVal IdEsternoEvento As String, ByVal XmlAttributiPazienteFuso As String, ByRef iWarningCode As Integer) As Boolean
        iWarningCode = 0
        '
        ' Verifiche dei parametri
        '
        If IdEsternoEvento IsNot Nothing AndAlso IdEsternoEvento.Length = 0 Then
            Throw New System.Exception("Manca il parametro IdEsterno dell'evento!")
        End If

        If XmlAttributiPazienteFuso IsNot Nothing AndAlso XmlAttributiPazienteFuso.Length = 0 Then
            Throw New System.Exception("Manca il parametro XmlAttributiPazienteFuso!")
        End If
        '
        ' Esegue la SP
        '
        With sqlcmdExtEventiRicoveroFondi
            .Parameters("@IdEsterno").Value = IdEsternoEvento
            .Parameters("@XmlAttributi").Value = XmlAttributiPazienteFuso

            If Not moSqlTransact Is Nothing Then
                .Transaction = moSqlTransact
            End If

            Dim vScalar As Object = .ExecuteScalar()

            Dim vRet As Object = .Parameters("@RETURN_VALUE").Value
            If (vRet Is Nothing) OrElse IsDBNull(vRet) OrElse (CType(vRet, Integer) <> 0) Then
                If CType(vRet, Integer) = 1004 Then 'iWarningCode
                    iWarningCode = 1004
                    Return True
                Else
                    Throw New System.Exception("Errore durante Exec SP ExtEventiRicoveroFondi(); SQL error: " & vRet.ToString())
                End If
            Else
                '
                ' Ritorna boolean
                '
                If (Not vScalar Is Nothing) AndAlso (Not IsDBNull(vScalar)) Then
                    Return CType(vScalar, Integer) > 0
                Else
                    Throw New System.Exception("Errore durante Exec SP ExtEventiRicoveroFondi(); Nosologico non trovato!")
                End If
            End If
        End With

    End Function

    Public Function EventiRicoveroConsolida(ByVal IdEsternoEvento As String) As Boolean
        '-----------------------------------------------------------------------------
        ' Consolidamento eventi A,T,D per trattare i casi di eventi elaborati 
        ' in successione cronologica sbagliata
        '-----------------------------------------------------------------------------
        '
        ' Verifiche dei parametri
        '
        If IdEsternoEvento IsNot Nothing AndAlso IdEsternoEvento.Length = 0 Then
            Throw New System.Exception("Manca il parametro IdEsterno dell'evento!")
        End If
        '
        ' Esegue la SP
        '
        With sqlcmdExtEventiRicoveroConsolida
            .Parameters("@IdEsterno").Value = IdEsternoEvento

            If Not moSqlTransact Is Nothing Then
                .Transaction = moSqlTransact
            End If

            Dim vScalar As Object = .ExecuteScalar()

            Dim vRet As Object = .Parameters("@RETURN_VALUE").Value
            If (vRet Is Nothing) OrElse IsDBNull(vRet) OrElse (CType(vRet, Integer) <> 0) Then
                Throw New System.Exception("Errore durante Exec SP ExtEventiRicoverConsolida(); SQL error: " & vRet.ToString())
            Else
                '
                ' Ritorna boolean
                '
                If (Not vScalar Is Nothing) AndAlso (Not IsDBNull(vScalar)) Then
                    Return CType(vScalar, Integer) > 0
                Else
                    Throw New System.Exception("Errore durante Exec SP ExtEventiRicoveroConsolida()!")
                End If
            End If
        End With

    End Function

#End Region

#Region " Paziente "

    Public Function PazientiAddNew3(ByVal IdEsternoPaziente As String, _
                           ByVal AziendaErogante As String, _
                           ByVal SistemaErogante As String, _
                           ByVal RepartoErogante As String, _
                           ByVal Cognome As String, _
                           ByVal Nome As String, _
                           ByVal Sesso As String, _
                           ByVal DataNascita As Date, _
                           ByVal LuogoNascita As String, _
                           ByVal CodiceFiscale As String, _
                           ByVal IdAnagrafica As String) As Boolean
        '
        ' Verifiche dei parametri
        '
        If IdEsternoPaziente IsNot Nothing AndAlso IdEsternoPaziente.Length = 0 Then
            Throw New System.Exception("Manca il parametro IdEsterno del paziente!")
        End If
        '
        ' Esegue la SP
        '
        With sqlcmdExtPazienteAggiungi3
            .Parameters("@IdEsterno").Value = IdEsternoPaziente
            .Parameters("@AziendaErogante").Value = AziendaErogante
            .Parameters("@SistemaErogante").Value = SistemaErogante
            .Parameters("@RepartoErogante").Value = RepartoErogante
            .Parameters("@IdAnagrafica").Value = SqlUtil.StringEmptyToDbNull(IdAnagrafica)
            .Parameters("@Sesso").Value = Sesso
            .Parameters("@Cognome").Value = Cognome
            .Parameters("@Nome").Value = Nome
            .Parameters("@CodiceFiscale").Value = CodiceFiscale
            .Parameters("@DataNascita").Value = SqlUtil.ParseDatetime(DataNascita)
            .Parameters("@LuogoNascita").Value = LuogoNascita

            If Not moSqlTransact Is Nothing Then
                .Transaction = moSqlTransact
            End If

            Dim vScalar As Object = .ExecuteScalar()

            Dim vRetVal As Object = .Parameters("@RETURN_VALUE").Value
            If (vRetVal Is Nothing) OrElse IsDBNull(vRetVal) OrElse (CType(vRetVal, Integer) <> 0) Then
                Throw New System.Exception("Errore durante Exec SP ExtPazienteAggiungi3(); SQL error: " & vRetVal.ToString())
            Else
                '
                ' Ritorna boolean
                '
                If (Not vScalar Is Nothing) AndAlso (Not IsDBNull(vScalar)) Then
                    Return CType(vScalar, Integer) > 0
                Else
                    Throw New System.Exception("Errore durante Exec SP ExtPazienteAggiungi3(); Paziente non trovato!")
                End If
            End If
        End With

    End Function

    Public Function PazientiUpdate(ByVal IdEsternoPaziente As String, _
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
        If IdEsternoPaziente IsNot Nothing AndAlso IdEsternoPaziente.Length = 0 Then
            Throw New System.Exception("Manca il parametro IdEsterno del paziente!")
        End If
        '
        ' Esegue la SP
        '
        With sqlcmdExtPazienteModifica
            .Parameters("@IdEsterno").Value = IdEsternoPaziente
            .Parameters("@AziendaErogante").Value = AziendaErogante
            .Parameters("@SistemaErogante").Value = SistemaErogante
            .Parameters("@RepartoErogante").Value = RepartoErogante
            .Parameters("@CodiceSanitario").Value = CodiceSanitario
            .Parameters("@Sesso").Value = Sesso
            .Parameters("@Cognome").Value = Cognome
            .Parameters("@Nome").Value = Nome
            .Parameters("@CodiceFiscale").Value = CodiceFiscale
            .Parameters("@DataNascita").Value = SqlUtil.ParseDatetime(DataNascita)
            .Parameters("@LuogoNascita").Value = LuogoNascita
            .Parameters("@DatiAnamnestici").Value = DatiAnamnestici
            .Parameters("@XmlAttributi").Value = SqlUtil.StringEmptyToDbNull(XmlAttributi)

            If Not moSqlTransact Is Nothing Then
                .Transaction = moSqlTransact
            End If

            Dim vScalar As Object = .ExecuteScalar()

            Dim vRetVal As Object = .Parameters("@RETURN_VALUE").Value
            If (vRetVal Is Nothing) OrElse IsDBNull(vRetVal) OrElse (CType(vRetVal, Integer) <> 0) Then
                Throw New System.Exception("Errore durante Exec SP ExtPazienteModifica(); SQL error: " & vRetVal.ToString())
            Else
                '
                ' Ritorna boolean
                '
                If (Not vScalar Is Nothing) AndAlso (Not IsDBNull(vScalar)) Then
                    Return CType(vScalar, Integer) > 0
                Else
                    Throw New System.Exception("Errore durante Exec SP ExtPazienteModifica(); Paziente non trovato!")
                End If
            End If
        End With

    End Function

    Public Function PazientiJoinFuzzy(ByVal Cognome As String, _
                                    ByVal Nome As String, _
                                    ByVal DataNascita As Date, _
                                    ByVal LuogoNascita As String, _
                                    ByVal CodiceFiscale As String, _
                                    ByVal CodiceSanitario As String, _
                                    ByVal IdEsternoPaziente As String) As String
        '
        ' Verifiche dei parametri
        '
        'If IdEsternoPaziente IsNot Nothing AndAlso IdEsternoPaziente.Length = 0 Then
        '    Throw New System.Exception("Manca il parametro IdEsterno del paziente!")
        'End If

        '
        ' Esegue SP
        '
        With sqlcmdExtPazienteDipAssocia
            .Parameters("@Nome").Value = Nome
            .Parameters("@Cognome").Value = Cognome
            .Parameters("@CodiceFiscale").Value = CodiceFiscale
            .Parameters("@CodiceSanitario").Value = CodiceSanitario
            .Parameters("@DataNascita").Value = SqlUtil.ParseDatetime(DataNascita)
            .Parameters("@IdEsterno").Value = IdEsternoPaziente

            If Not moSqlTransact Is Nothing Then
                .Transaction = moSqlTransact
            End If

            Dim vScalar As Object = .ExecuteScalar()

            Dim vRetVal As Object = .Parameters("@RETURN_VALUE").Value
            If (Not vRetVal Is Nothing) AndAlso (Not IsDBNull(vRetVal)) AndAlso (CType(vRetVal, Integer) = 0) Then
                '
                ' Ritorna boolean
                '
                If (Not vScalar Is Nothing) AndAlso (Not IsDBNull(vScalar)) Then
                    Return vScalar.ToString
                Else
                    Return String.Empty
                End If
            Else
                Throw New System.Exception("Errore durante Exec SP ExtPazienteDipAssocia(); SQL error: " & vRetVal.ToString())
            End If
        End With

    End Function

    Public Function PazientiJoinByCode(ByVal CodiceAnagraficaCentrale As String, _
                        ByVal NomeAnagraficaCentrale As String, _
                        ByVal IdEsternoPaziente As String, ByVal AziendaErogante As String) As String
        '
        ' Verifiche dei parametri
        '
        If CodiceAnagraficaCentrale IsNot Nothing AndAlso CodiceAnagraficaCentrale.Length = 0 Then
            Throw New System.Exception("Manca il parametro CodiceAnagraficaCentrale!")
        End If

        If NomeAnagraficaCentrale IsNot Nothing AndAlso NomeAnagraficaCentrale.Length = 0 Then
            Throw New System.Exception("Manca il parametro NomeAnagraficaCentrale!")
        End If

        '    If IdEsternoPaziente IsNot Nothing AndAlso IdEsternoPaziente.Length = 0 Then
        '        Throw New System.Exception("Manca il parametro IdEsterno del paziente!")
        '    End If

        If String.IsNullOrEmpty(AziendaErogante) Then
            Throw New System.Exception("Manca il parametro AziendaErogante!")
        End If

        '
        ' Esegue SP
        '
        With sqlcmdExtPazienteDipAssociaRiferimenti
            .Parameters("@IdEsterno").Value = IdEsternoPaziente
            .Parameters("@Anagrafice").Value = NomeAnagraficaCentrale
            .Parameters("@IdAnagrafice").Value = CodiceAnagraficaCentrale
            .Parameters("@AziendaErogante").Value = AziendaErogante

            If Not moSqlTransact Is Nothing Then
                .Transaction = moSqlTransact
            End If

            Dim vScalar As Object = .ExecuteScalar()

            Dim vRetVal As Object = .Parameters("@RETURN_VALUE").Value
            If (Not vRetVal Is Nothing) AndAlso (Not IsDBNull(vRetVal)) AndAlso (CType(vRetVal, Integer) = 0) Then
                '
                ' Ritorna boolean
                '
                If (Not vScalar Is Nothing) AndAlso (Not IsDBNull(vScalar)) Then
                    Return vScalar.ToString
                Else
                    Return String.Empty
                End If
            Else
                Throw New System.Exception("Errore durante Exec SP ExtPazienteDipAssociaRiferimenti(); SQL error: " & vRetVal.ToString())
            End If
        End With

    End Function

    Public Function PazientiJoinContains(ByVal IdEsternoPaziente As String) As Boolean
        '
        ' Verifiche dei parametri
        '
        If IdEsternoPaziente IsNot Nothing AndAlso IdEsternoPaziente.Length = 0 Then
            Throw New System.Exception("Manca il parametro IdEsterno del paziente!")
        End If
        '
        ' Esegue SP
        '
        With sqlcmdExtPazienteDipEsiste
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
                    Return (vScalar.ToString.Length > 0)
                Else
                    Return False
                End If
            Else
                Throw New System.Exception("Errore durante Exec SP ExtPazienteDipEsiste(); SQL error: " & vRet.ToString())
            End If
        End With

    End Function

    Public Function PazientiContains(ByVal IdEsternoPaziente As String) As Boolean
        '
        ' Verifiche dei parametri
        '
        If IdEsternoPaziente IsNot Nothing AndAlso IdEsternoPaziente.Length = 0 Then
            Throw New System.Exception("Manca il parametro IdEsterno del paziente!")
        End If
        '
        ' Esegue SP
        '
        With sqlcmdExtPazienteEsiste
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
                    Return (vScalar.ToString.Length > 0)
                Else
                    Return False
                End If
            Else
                Throw New System.Exception("Errore durante Exec SP ExtPazienteEsiste(); SQL error: " & vRet.ToString())
            End If
        End With

    End Function

    Public Function PazientiRemove(ByVal IdEsternoPaziente As String) As Boolean

        '
        ' Verifiche dei parametri
        '
        If IdEsternoPaziente IsNot Nothing AndAlso IdEsternoPaziente.Length = 0 Then
            Throw New System.Exception("Manca il parametro IdEsterno del paziente!")
        End If
        '
        ' Esegue SP
        '
        With sqlcmdExtPazienteRimuovi
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
                    Throw New System.Exception("Errore durante Exec SP ExtPazienteRimuovi(); Paziente non trovato!")
                End If
            Else
                Throw New System.Exception("Errore durante Exec SP ExtPazienteRimuovi(); SQL error: " & vRet.ToString())
            End If
        End With

    End Function

#End Region





#Region " Ricoveri "

    'Public Function RicoveriAddNew(ByVal IdEsternoRicovero As String, _
    '                        ByVal IdEsternoPaziente As String, _
    '                        ByVal StatoCodice As Integer, _
    '                        ByVal NumeroNosologico As String, _
    '                        ByVal AziendaErogante As String, _
    '                        ByVal SistemaErogante As String, _
    '                        ByVal RepartoErogante As String, _
    '                        ByVal OspedaleCodice As String, _
    '                        ByVal OspedaleDescrizione As String, _
    '                        ByVal TipoRicoveroCodice As String, _
    '                        ByVal TipoRicoveroDescrizione As String, _
    '                        ByVal Diagnosi As String, _
    '                        ByVal DataAccettazione As Date, _
    '                        ByVal RepartoAccettazioneCodice As String, _
    '                        ByVal RepartoAccettazioneDescrizione As String, _
    '                        ByVal DataTrasferimento As Date, _
    '                        ByVal RepartoCodice As String, _
    '                        ByVal RepartoDescrizione As String, _
    '                        ByVal SettoreCodice As String, _
    '                        ByVal SettoreDescrizione As String, _
    '                        ByVal LettoCodice As String, _
    '                        ByVal DataDimissione As Date, _
    '                        ByVal XmlAttributi As String) As Boolean
    '    '
    '    ' Verifiche dei parametri
    '    '
    '    If IdEsternoRicovero IsNot Nothing AndAlso IdEsternoRicovero.Length = 0 Then
    '        Throw New System.Exception("Manca il parametro IdEsterno del ricovero!")
    '    End If

    '    If IdEsternoPaziente IsNot Nothing AndAlso IdEsternoPaziente.Length = 0 Then
    '        Throw New System.Exception("Manca il parametro IdEsterno del paziente!")
    '    End If
    '    '
    '    ' Inserisco il referto
    '    '
    '    With sqlcmdExtRicoveriAggiungi
    '        .Parameters("@IdEsterno").Value = IdEsternoRicovero
    '        .Parameters("@IdEsternoPaziente").Value = IdEsternoPaziente
    '        .Parameters("@StatoCodice").Value = StatoCodice
    '        .Parameters("@NumeroNosologico").Value = NumeroNosologico
    '        .Parameters("@AziendaErogante").Value = AziendaErogante
    '        .Parameters("@SistemaErogante").Value = SistemaErogante
    '        .Parameters("@RepartoErogante").Value = RepartoErogante
    '        .Parameters("@OspedaleCodice").Value = OspedaleCodice
    '        .Parameters("@OspedaleDescr").Value = OspedaleDescrizione
    '        .Parameters("@TipoRicoveroCodice").Value = TipoRicoveroCodice
    '        .Parameters("@TipoRicoveroDescr").Value = TipoRicoveroDescrizione
    '        .Parameters("@Diagnosi").Value = Diagnosi
    '        .Parameters("@DataAccettazione").Value = SqlUtil.ParseDatetime(DataAccettazione)
    '        .Parameters("@RepartoAccettazioneCodice").Value = RepartoAccettazioneCodice
    '        .Parameters("@RepartoAccettazioneDescr").Value = RepartoAccettazioneDescrizione
    '        .Parameters("@DataTrasferimento").Value = SqlUtil.ParseDatetime(DataTrasferimento)
    '        .Parameters("@RepartoCodice").Value = RepartoCodice
    '        .Parameters("@RepartoDescr").Value = RepartoDescrizione
    '        .Parameters("@SettoreCodice").Value = SettoreCodice
    '        .Parameters("@SettoreDescr").Value = SettoreDescrizione
    '        .Parameters("@LettoCodice").Value = LettoCodice
    '        .Parameters("@DataDimissione").Value = SqlUtil.ParseDatetime(DataDimissione)
    '        .Parameters("@XmlAttributi").Value = SqlUtil.StringEmptyToDbNull(XmlAttributi)

    '        If Not moSqlTransact Is Nothing Then
    '            .Transaction = moSqlTransact
    '        End If

    '        Dim vScalar As Object = .ExecuteScalar()

    '        Dim vRetVal As Object = .Parameters("@RETURN_VALUE").Value
    '        If (vRetVal Is Nothing) OrElse IsDBNull(vRetVal) OrElse (CType(vRetVal, Integer) <> 0) Then
    '            Throw New System.Exception("Errore durante Exec SP ExtRicoveriAggiungi(); SQL error: " & vRetVal.ToString())
    '        Else
    '            '
    '            ' Ritorna boolean
    '            '
    '            If (Not vScalar Is Nothing) AndAlso (Not IsDBNull(vScalar)) Then
    '                Return CType(vScalar, Integer) > 0
    '            Else
    '                Throw New System.Exception("Errore durante Exec SP ExtRicoveriAggiungi(); Paziente non trovato!")
    '            End If
    '        End If
    '    End With

    'End Function

    'Public Function RicoveriUpdate(ByVal IdEsternoRicovero As String, _
    '                        ByVal IdEsternoPaziente As String, _
    '                        ByVal StatoCodice As Integer, _
    '                        ByVal NumeroNosologico As String, _
    '                        ByVal AziendaErogante As String, _
    '                        ByVal SistemaErogante As String, _
    '                        ByVal RepartoErogante As String, _
    '                        ByVal OspedaleCodice As String, _
    '                        ByVal OspedaleDescrizione As String, _
    '                        ByVal TipoRicoveroCodice As String, _
    '                        ByVal TipoRicoveroDescrizione As String, _
    '                        ByVal Diagnosi As String, _
    '                        ByVal DataAccettazione As Date, _
    '                        ByVal RepartoAccettazioneCodice As String, _
    '                        ByVal RepartoAccettazioneDescrizione As String, _
    '                        ByVal DataTrasferimento As Date, _
    '                        ByVal RepartoCodice As String, _
    '                        ByVal RepartoDescrizione As String, _
    '                        ByVal SettoreCodice As String, _
    '                        ByVal SettoreDescrizione As String, _
    '                        ByVal LettoCodice As String, _
    '                        ByVal DataDimissione As Date, _
    '                        ByVal XmlAttributi As String) As Boolean
    '    '
    '    ' Verifiche dei parametri
    '    '
    '    If IdEsternoRicovero IsNot Nothing AndAlso IdEsternoRicovero.Length = 0 Then
    '        Throw New System.Exception("Manca il parametro IdEsterno del ricovero!")
    '    End If

    '    If IdEsternoPaziente IsNot Nothing AndAlso IdEsternoPaziente.Length = 0 Then
    '        Throw New System.Exception("Manca il parametro IdEsterno del paziente!")
    '    End If
    '    '
    '    ' Inserisco il referto
    '    '
    '    With sqlcmdExtRicoveriModifica
    '        .Parameters("@IdEsterno").Value = IdEsternoRicovero
    '        .Parameters("@IdEsternoPaziente").Value = IdEsternoPaziente
    '        .Parameters("@StatoCodice").Value = StatoCodice
    '        .Parameters("@NumeroNosologico").Value = NumeroNosologico
    '        .Parameters("@AziendaErogante").Value = AziendaErogante
    '        .Parameters("@SistemaErogante").Value = SistemaErogante
    '        .Parameters("@RepartoErogante").Value = RepartoErogante
    '        .Parameters("@OspedaleCodice").Value = OspedaleCodice
    '        .Parameters("@OspedaleDescr").Value = OspedaleDescrizione
    '        .Parameters("@TipoRicoveroCodice").Value = TipoRicoveroCodice
    '        .Parameters("@TipoRicoveroDescr").Value = TipoRicoveroDescrizione
    '        .Parameters("@Diagnosi").Value = Diagnosi
    '        .Parameters("@DataAccettazione").Value = SqlUtil.ParseDatetime(DataAccettazione)
    '        .Parameters("@RepartoAccettazioneCodice").Value = RepartoAccettazioneCodice
    '        .Parameters("@RepartoAccettazioneDescr").Value = RepartoAccettazioneDescrizione
    '        .Parameters("@DataTrasferimento").Value = SqlUtil.ParseDatetime(DataTrasferimento)
    '        .Parameters("@RepartoCodice").Value = RepartoCodice
    '        .Parameters("@RepartoDescr").Value = RepartoDescrizione
    '        .Parameters("@SettoreCodice").Value = SettoreCodice
    '        .Parameters("@SettoreDescr").Value = SettoreDescrizione
    '        .Parameters("@LettoCodice").Value = LettoCodice
    '        .Parameters("@DataDimissione").Value = SqlUtil.ParseDatetime(DataDimissione)
    '        .Parameters("@XmlAttributi").Value = SqlUtil.StringEmptyToDbNull(XmlAttributi)

    '        If Not moSqlTransact Is Nothing Then
    '            .Transaction = moSqlTransact
    '        End If

    '        Dim vScalar As Object = .ExecuteScalar()

    '        Dim vRetVal As Object = .Parameters("@RETURN_VALUE").Value
    '        If (vRetVal Is Nothing) OrElse IsDBNull(vRetVal) OrElse (CType(vRetVal, Integer) <> 0) Then
    '            Throw New System.Exception("Errore durante Exec SP ExtRicoveriModifica(); SQL error: " & vRetVal.ToString())
    '        Else
    '            '
    '            ' Ritorna boolean
    '            '
    '            If (Not vScalar Is Nothing) AndAlso (Not IsDBNull(vScalar)) Then
    '                Return CType(vScalar, Integer) > 0
    '            Else
    '                Throw New System.Exception("Errore durante Exec SP ExtRicoveriModifica(); Paziente non trovato!")
    '            End If
    '        End If
    '    End With

    'End Function

    Public Function RicoveriAddNew(ByVal IdEsternoRicovero As String, _
                          ByVal IdPaziente As Guid, _
                          ByVal StatoCodice As Integer, _
                          ByVal NumeroNosologico As String, _
                          ByVal AziendaErogante As String, _
                          ByVal SistemaErogante As String, _
                          ByVal RepartoErogante As String, _
                          ByVal OspedaleCodice As String, _
                          ByVal OspedaleDescrizione As String, _
                          ByVal TipoRicoveroCodice As String, _
                          ByVal TipoRicoveroDescrizione As String, _
                          ByVal Diagnosi As String, _
                          ByVal DataAccettazione As Date, _
                          ByVal RepartoAccettazioneCodice As String, _
                          ByVal RepartoAccettazioneDescrizione As String, _
                          ByVal DataTrasferimento As Date, _
                          ByVal RepartoCodice As String, _
                          ByVal RepartoDescrizione As String, _
                          ByVal SettoreCodice As String, _
                          ByVal SettoreDescrizione As String, _
                          ByVal LettoCodice As String, _
                          ByVal DataDimissione As Date, _
                          ByVal XmlAttributi As String) As Boolean
        '
        ' Verifiche dei parametri
        '
        If IdEsternoRicovero IsNot Nothing AndAlso IdEsternoRicovero.Length = 0 Then
            Throw New System.Exception("Manca il parametro IdEsterno del ricovero!")
        End If

        'Non verifico se IdPaziente = Nothing poichè posso passare l'Id nullo
        'If IdPaziente = Nothing Then
        '    Throw New System.Exception("Manca il parametro IdPaziente del referto!")
        'End If
        '
        ' Inserisco il referto
        '
        With sqlcmdExtRicoveriAggiungi3
            .Parameters("@IdEsterno").Value = IdEsternoRicovero
            .Parameters("@IdPaziente").Value = IdPaziente
            .Parameters("@StatoCodice").Value = StatoCodice
            .Parameters("@NumeroNosologico").Value = NumeroNosologico
            .Parameters("@AziendaErogante").Value = AziendaErogante
            .Parameters("@SistemaErogante").Value = SistemaErogante
            .Parameters("@RepartoErogante").Value = RepartoErogante
            .Parameters("@OspedaleCodice").Value = OspedaleCodice
            .Parameters("@OspedaleDescr").Value = OspedaleDescrizione
            .Parameters("@TipoRicoveroCodice").Value = TipoRicoveroCodice
            .Parameters("@TipoRicoveroDescr").Value = TipoRicoveroDescrizione
            .Parameters("@Diagnosi").Value = Diagnosi
            .Parameters("@DataAccettazione").Value = SqlUtil.ParseDatetime(DataAccettazione)
            .Parameters("@RepartoAccettazioneCodice").Value = RepartoAccettazioneCodice
            .Parameters("@RepartoAccettazioneDescr").Value = RepartoAccettazioneDescrizione
            .Parameters("@DataTrasferimento").Value = SqlUtil.ParseDatetime(DataTrasferimento)
            .Parameters("@RepartoCodice").Value = RepartoCodice
            .Parameters("@RepartoDescr").Value = RepartoDescrizione
            .Parameters("@SettoreCodice").Value = SettoreCodice
            .Parameters("@SettoreDescr").Value = SettoreDescrizione
            .Parameters("@LettoCodice").Value = LettoCodice
            .Parameters("@DataDimissione").Value = SqlUtil.ParseDatetime(DataDimissione)
            .Parameters("@XmlAttributi").Value = SqlUtil.StringEmptyToDbNull(XmlAttributi)

            If Not moSqlTransact Is Nothing Then
                .Transaction = moSqlTransact
            End If

            Dim vScalar As Object = .ExecuteScalar()

            Dim vRetVal As Object = .Parameters("@RETURN_VALUE").Value
            If (vRetVal Is Nothing) OrElse IsDBNull(vRetVal) OrElse (CType(vRetVal, Integer) <> 0) Then
                Throw New System.Exception("Errore durante Exec SP ExtRicoveriAggiungi(); SQL error: " & vRetVal.ToString())
            Else
                '
                ' Ritorna boolean
                '
                If (Not vScalar Is Nothing) AndAlso (Not IsDBNull(vScalar)) Then
                    Return CType(vScalar, Integer) > 0
                Else
                    Throw New System.Exception("Errore durante Exec SP ExtRicoveriAggiungi3()!")
                End If
            End If
        End With

    End Function

    Public Function RicoveriUpdate(ByVal IdEsternoRicovero As String, _
                            ByVal IdPaziente As Guid, _
                            ByVal StatoCodice As Integer, _
                            ByVal NumeroNosologico As String, _
                            ByVal AziendaErogante As String, _
                            ByVal SistemaErogante As String, _
                            ByVal RepartoErogante As String, _
                            ByVal OspedaleCodice As String, _
                            ByVal OspedaleDescrizione As String, _
                            ByVal TipoRicoveroCodice As String, _
                            ByVal TipoRicoveroDescrizione As String, _
                            ByVal Diagnosi As String, _
                            ByVal DataAccettazione As Date, _
                            ByVal RepartoAccettazioneCodice As String, _
                            ByVal RepartoAccettazioneDescrizione As String, _
                            ByVal DataTrasferimento As Date, _
                            ByVal RepartoCodice As String, _
                            ByVal RepartoDescrizione As String, _
                            ByVal SettoreCodice As String, _
                            ByVal SettoreDescrizione As String, _
                            ByVal LettoCodice As String, _
                            ByVal DataDimissione As Date, _
                            ByVal XmlAttributi As String) As Boolean
        '
        ' Verifiche dei parametri
        '
        If IdEsternoRicovero IsNot Nothing AndAlso IdEsternoRicovero.Length = 0 Then
            Throw New System.Exception("Manca il parametro IdEsterno del ricovero!")
        End If

        'Non verifico se IdPaziente = Nothing poichè posso passare l'Id nullo
        'If IdPaziente = Nothing Then
        '    Throw New System.Exception("Manca il parametro IdPaziente del referto!")
        'End If
        '
        ' Inserisco il referto
        '
        With sqlcmdExtRicoveriModifica3
            .Parameters("@IdEsterno").Value = IdEsternoRicovero
            .Parameters("@IdPaziente").Value = IdPaziente
            .Parameters("@StatoCodice").Value = StatoCodice
            .Parameters("@NumeroNosologico").Value = NumeroNosologico
            .Parameters("@AziendaErogante").Value = AziendaErogante
            .Parameters("@SistemaErogante").Value = SistemaErogante
            .Parameters("@RepartoErogante").Value = RepartoErogante
            .Parameters("@OspedaleCodice").Value = OspedaleCodice
            .Parameters("@OspedaleDescr").Value = OspedaleDescrizione
            .Parameters("@TipoRicoveroCodice").Value = TipoRicoveroCodice
            .Parameters("@TipoRicoveroDescr").Value = TipoRicoveroDescrizione
            .Parameters("@Diagnosi").Value = Diagnosi
            .Parameters("@DataAccettazione").Value = SqlUtil.ParseDatetime(DataAccettazione)
            .Parameters("@RepartoAccettazioneCodice").Value = RepartoAccettazioneCodice
            .Parameters("@RepartoAccettazioneDescr").Value = RepartoAccettazioneDescrizione
            .Parameters("@DataTrasferimento").Value = SqlUtil.ParseDatetime(DataTrasferimento)
            .Parameters("@RepartoCodice").Value = RepartoCodice
            .Parameters("@RepartoDescr").Value = RepartoDescrizione
            .Parameters("@SettoreCodice").Value = SettoreCodice
            .Parameters("@SettoreDescr").Value = SettoreDescrizione
            .Parameters("@LettoCodice").Value = LettoCodice
            .Parameters("@DataDimissione").Value = SqlUtil.ParseDatetime(DataDimissione)
            .Parameters("@XmlAttributi").Value = SqlUtil.StringEmptyToDbNull(XmlAttributi)

            If Not moSqlTransact Is Nothing Then
                .Transaction = moSqlTransact
            End If

            Dim vScalar As Object = .ExecuteScalar()

            Dim vRetVal As Object = .Parameters("@RETURN_VALUE").Value
            If (vRetVal Is Nothing) OrElse IsDBNull(vRetVal) OrElse (CType(vRetVal, Integer) <> 0) Then
                Throw New System.Exception("Errore durante Exec SP ExtRicoveriModifica3(); SQL error: " & vRetVal.ToString())
            Else
                '
                ' Ritorna boolean
                '
                If (Not vScalar Is Nothing) AndAlso (Not IsDBNull(vScalar)) Then
                    Return CType(vScalar, Integer) > 0
                Else
                    Throw New System.Exception("Errore durante Exec SP ExtRicoveriModifica3()!")
                End If
            End If
        End With

    End Function

    Public Function RicoveriDataModificaUpdate(ByVal IdEsternoRicovero As String, _
                        ByVal DataModificaEsterno As Date) As Boolean
        '
        ' Verifiche dei parametri
        '
        If IdEsternoRicovero IsNot Nothing AndAlso IdEsternoRicovero.Length = 0 Then
            Throw New System.Exception("Manca il parametro IdEsterno del ricovero!")
        End If
        '
        ' Modifico il referto
        '
        With sqlcmdExtRicoveriDataModifica
            .Parameters("@IdEsterno").Value = IdEsternoRicovero
            .Parameters("@DataModificaEsterno").Value = DataModificaEsterno

            If Not moSqlTransact Is Nothing Then
                .Transaction = moSqlTransact
            End If

            Dim vScalar As Object = .ExecuteScalar()

            Dim vRetVal As Object = .Parameters("@RETURN_VALUE").Value
            If (vRetVal Is Nothing) OrElse IsDBNull(vRetVal) OrElse (CType(vRetVal, Integer) <> 0) Then
                Throw New System.Exception("Errore durante Exec SP ExtRicoveriDataModifica(); SQL error: " & vRetVal.ToString())
            Else
                '
                ' Ritorna boolean
                '
                If (Not vScalar Is Nothing) AndAlso (Not IsDBNull(vScalar)) Then
                    Return CType(vScalar, Integer) > 0
                Else
                    Throw New System.Exception("Errore durante Exec SP ExtRicoveriDataModifica(); Ricovero non trovato!")
                End If
            End If
        End With

    End Function

    Public Function RicoveriContains(ByVal IdEsternoRicovero As String) As Date
        '
        ' Verifiche dei parametri
        '
        If IdEsternoRicovero IsNot Nothing AndAlso IdEsternoRicovero.Length = 0 Then
            Throw New System.Exception("Manca il parametro IdEsterno del ricovero!")
        End If
        '
        ' Esegue la SP
        '
        With sqlcmdExtRicoveriEsiste
            .Parameters("@IdEsterno").Value = IdEsternoRicovero

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
                    '
                    ' Ritorna la data di modifica esterna
                    '
                    Return CType(vScalar, Date)
                Else
                    Return Nothing
                End If
            Else
                Throw New System.Exception("Errore durante Exec SP ExtRicoveriEsiste(); SQL error: " & vRet.ToString())
            End If
        End With

    End Function

    Public Function RicoveriRemove(ByVal IdEsternoRicovero As String) As Boolean
        '
        ' Verifiche dei parametri
        '
        If IdEsternoRicovero IsNot Nothing AndAlso IdEsternoRicovero.Length = 0 Then
            Throw New System.Exception("Manca il parametro IdEsterno del ricovero!")
        End If
        '
        ' Esegue la SP
        '
        With sqlcmdExtRicoveriRimuovi
            .Parameters("@IdEsterno").Value = IdEsternoRicovero

            If Not moSqlTransact Is Nothing Then
                .Transaction = moSqlTransact
            End If

            Dim vScalar As Object = .ExecuteScalar()

            Dim vRet As Object = .Parameters("@RETURN_VALUE").Value
            If (vRet Is Nothing) OrElse IsDBNull(vRet) OrElse (CType(vRet, Integer) <> 0) Then
                Throw New System.Exception("Errore durante Exec SP ExtRicoveriRimuovi(); SQL error: " & vRet.ToString())
            Else
                '
                ' Ritorna boolean
                '
                If (Not vScalar Is Nothing) AndAlso (Not IsDBNull(vScalar)) Then
                    Return CType(vScalar, Integer) > 0
                Else
                    Throw New System.Exception("Errore durante Exec SP ExtRicoveriRimuovi()!")
                End If
            End If
        End With

    End Function

#End Region

#Region " Dati del ricovero da eventi per Azienda, Nosologico "

    'Public Function RicoveroFromEventiADT(ByVal NumeroNosologico As String, _
    '                        ByVal AziendaErogante As String, ByVal IdEsternoEvento As String) As DataTable
    '    Dim oReader As SqlDataReader = Nothing
    '    Dim oDataTable As DataTable = Nothing
    '    Try

    '        '
    '        ' Verifiche dei parametri
    '        '
    '        If NumeroNosologico IsNot Nothing AndAlso NumeroNosologico.Length = 0 Then
    '            Throw New System.Exception("Manca il parametro NumeroNosologico!")
    '        End If

    '        If AziendaErogante IsNot Nothing AndAlso AziendaErogante.Length = 0 Then
    '            Throw New System.Exception("Manca il parametro AziendaErogante!")
    '        End If

    '        If IdEsternoEvento IsNot Nothing AndAlso IdEsternoEvento.Length = 0 Then
    '            Throw New System.Exception("Manca il parametro IdEsternoEvento!")
    '        End If

    '        '
    '        ' Inserisco il referto
    '        '
    '        With sqlcmdExtEventiRicoveroConsolidaRicovero
    '            .Parameters("@NumeroNosologico").Value = NumeroNosologico
    '            .Parameters("@AziendaErogante").Value = AziendaErogante
    '            .Parameters("@IdEsternoEvento").Value = IdEsternoEvento

    '            If Not moSqlTransact Is Nothing Then
    '                .Transaction = moSqlTransact
    '            End If

    '            oReader = .ExecuteReader()
    '            '
    '            ' ATTENZIONE: usando .ExecuteReader() ho a disposizione il valore di @RETURN_VALUE solo dopo avere letto il reader
    '            ' Se il reader è vuoto vado avanti: il chiamante controllerà se la data table è valorizzata
    '            '
    '            If Not oReader Is Nothing Then
    '                If oReader.HasRows Then
    '                    oDataTable = New DataTable("Ricovero")
    '                    oDataTable.Load(oReader)
    '                End If
    '            End If
    '            '
    '            ' Ora posso leggere il parametro @RETURN_VALUE
    '            '
    '            Dim vRetVal As Object = .Parameters("@RETURN_VALUE").Value
    '            If (vRetVal Is Nothing) OrElse IsDBNull(vRetVal) Then
    '                'Questo è un errore di programmazione
    '                Throw New System.Exception("Errore nella SP ExtEventiRicoveroConsolidaRicovero(): la SP deve terminare con RETURN 0 se tutto ok o RETURN 1 se si è verificato un errore!")
    '            ElseIf CType(vRetVal, Integer) <> 0 Then
    '                Throw New System.Exception("Errore durante Exec SP ExtEventiRicoveroConsolidaRicovero(); SQL error: " & vRetVal.ToString())
    '            End If

    '        End With
    '    Catch
    '        Throw
    '    Finally
    '        If Not oReader Is Nothing Then
    '            oReader.Close()
    '        End If
    '    End Try
    '    '
    '    ' Restituisco nothing o la datatable
    '    '
    '    Return oDataTable
    'End Function



    Public Function EventiConsolidaRicovero(
                    ByVal NumeroNosologico As String, _
                    ByVal AziendaErogante As String, _
                    ByVal RicoveroEsiste As Boolean, _
                    ByVal TipoEventoCodice As String) As DataTable
        Dim oReader As SqlDataReader = Nothing
        Dim oDataTable As DataTable = Nothing
        Try

            '
            ' Verifiche dei parametri
            '
            If NumeroNosologico IsNot Nothing AndAlso NumeroNosologico.Length = 0 Then
                Throw New System.Exception("Manca il parametro NumeroNosologico!")
            End If

            If AziendaErogante IsNot Nothing AndAlso AziendaErogante.Length = 0 Then
                Throw New System.Exception("Manca il parametro AziendaErogante!")
            End If

            If TipoEventoCodice IsNot Nothing AndAlso TipoEventoCodice.Length = 0 Then
                Throw New System.Exception("Manca il parametro TipoEventoCodice!")
            End If

            '
            ' Inserisco il referto
            '
            With sqlcmdExtEventiRicoveroConsolidaRicovero2
                .Parameters("@NumeroNosologico").Value = NumeroNosologico
                .Parameters("@AziendaErogante").Value = AziendaErogante
                .Parameters("@RicoveroEsiste").Value = RicoveroEsiste
                .Parameters("@TipoEventoCodice").Value = TipoEventoCodice

                If Not moSqlTransact Is Nothing Then
                    .Transaction = moSqlTransact
                End If

                oReader = .ExecuteReader()
                '
                ' ATTENZIONE: usando .ExecuteReader() ho a disposizione il valore di @RETURN_VALUE solo dopo avere letto il reader
                ' Se il reader è vuoto vado avanti: il chiamante controllerà se la data table è valorizzata
                ' Non usare oReader.HasRow() per testare se ci sono record perchè eventuali eccezioni vengono fired dall'operazione di lettura
                '
                oDataTable = New DataTable("Ricovero")
                oDataTable.Load(oReader)
                '
                oReader.Close()
                '
                ' Ora posso leggere il parametro @RETURN_VALUE
                '
                Dim vRetVal As Object = .Parameters("@RETURN_VALUE").Value
                If (vRetVal Is Nothing) OrElse IsDBNull(vRetVal) Then
                    'Questo è un errore di programmazione
                    Throw New System.Exception("Errore nella SP ExtEventiRicoveroConsolidaRicovero2(): la SP deve terminare con RETURN 0 se tutto ok o RETURN 1 se si è verificato un errore!")
                ElseIf CType(vRetVal, Integer) <> 0 Then
                    Throw New System.Exception("Errore durante Exec SP ExtEventiRicoveroConsolidaRicovero2(); SQL error: " & vRetVal.ToString())
                End If

            End With
        Catch
            Throw
        Finally
            If Not oReader Is Nothing Then
                If Not oReader.IsClosed Then 'controllo se già chiuso
                    oReader.Close()
                End If
            End If
        End Try
        '
        ' Restituisco nothing o la datatable
        '
        Return oDataTable
    End Function



    Public Function EventiConsolidaPrenotazione(
                           ByVal NumeroNosologico As String, _
                           ByVal AziendaErogante As String, _
                           ByVal RicoveroEsiste As Boolean, _
                           ByVal IdEsternoEvento As String) As DataTable
        Dim oReader As SqlDataReader = Nothing
        Dim oDataTable As DataTable = Nothing
        Try

            '
            ' Verifiche dei parametri
            '
            If NumeroNosologico IsNot Nothing AndAlso NumeroNosologico.Length = 0 Then
                Throw New System.Exception("Manca il parametro NumeroNosologico!")
            End If

            If AziendaErogante IsNot Nothing AndAlso AziendaErogante.Length = 0 Then
                Throw New System.Exception("Manca il parametro AziendaErogante!")
            End If

            If IdEsternoEvento IsNot Nothing AndAlso IdEsternoEvento.Length = 0 Then
                Throw New System.Exception("Manca il parametro IdEsternoEvento!")
            End If

            '
            ' Inserisco il referto
            '
            With sqlcmdExtEventiRicoveroConsolidaPrenotazione
                .Parameters("@NumeroNosologico").Value = NumeroNosologico
                .Parameters("@AziendaErogante").Value = AziendaErogante
                .Parameters("@RicoveroEsiste").Value = RicoveroEsiste
                .Parameters("@IdEsternoEvento").Value = IdEsternoEvento

                If Not moSqlTransact Is Nothing Then
                    .Transaction = moSqlTransact
                End If

                oReader = .ExecuteReader()
                '
                ' ATTENZIONE: usando .ExecuteReader() ho a disposizione il valore di @RETURN_VALUE solo dopo avere letto il reader
                ' Se il reader è vuoto vado avanti: il chiamante controllerà se la data table è valorizzata
                ' Non usare oReader.HasRow() per testare se ci sono record perchè eventuali eccezioni vengono fired dall'operazione di lettura
                '
                oDataTable = New DataTable("Prenotazione")
                oDataTable.Load(oReader)
                '
                oReader.Close()
                '
                ' Ora posso leggere il parametro @RETURN_VALUE
                '
                Dim vRetVal As Object = .Parameters("@RETURN_VALUE").Value
                If (vRetVal Is Nothing) OrElse IsDBNull(vRetVal) Then
                    'Questo è un errore di programmazione
                    Throw New System.Exception("Errore nella SP ExtEventiRicoveroConsolidaPrenotazione2(): la SP deve terminare con RETURN 0 se tutto ok o RETURN 1 se si è verificato un errore!")
                ElseIf CType(vRetVal, Integer) <> 0 Then
                    Throw New System.Exception("Errore durante Exec SP ExtEventiRicoveroConsolidaPrenotazione2(); SQL error: " & vRetVal.ToString())
                End If

            End With
        Catch
            Throw
        Finally
            If Not oReader Is Nothing Then
                If Not oReader.IsClosed Then 'controllo se già chiuso
                    oReader.Close()
                End If
            End If
        End Try
        '
        ' Restituisco nothing o la datatable
        '
        Return oDataTable
    End Function

    

#End Region



    Public Function EventiBeforeProcess(ByVal IdEsternoEvento As String, ByVal Operazione As ConnectorV2.TipoMessaggioEvento) As Boolean
        '
        ' Verifiche dei parametri
        '
        If IdEsternoEvento IsNot Nothing AndAlso IdEsternoEvento.Length = 0 Then
            Throw New System.Exception("Manca il parametro IdEsterno dell'evento!")
        End If
        '
        ' Esecuzione della stored procedure
        '
        With sqlcmdExtEventiBeforeProcess
            .Parameters("@IdEsterno").Value = IdEsternoEvento
            .Parameters("@Operazione").Value = Operazione

            If Not moSqlTransact Is Nothing Then
                .Transaction = moSqlTransact
            End If

            Dim vScalar As Object = .ExecuteScalar()

            Dim vRetVal As Object = .Parameters("@RETURN_VALUE").Value
            If (vRetVal Is Nothing) OrElse IsDBNull(vRetVal) OrElse (CType(vRetVal, Integer) <> 0) Then
                Throw New System.Exception("Errore durante Exec SP ExtEventiBeforeProcess(); SQL error: " & vRetVal.ToString())
            Else
                '
                ' Ritorna boolean
                '
                If (Not vScalar Is Nothing) AndAlso (Not IsDBNull(vScalar)) Then
                    Return CType(vScalar, Integer) > 0
                Else
                    Throw New System.Exception("Errore durante Exec SP ExtEventiBeforeProcess()!")
                End If
            End If
        End With
    End Function

    Public Function EventiAfterProcess(ByVal IdEsternoEvento As String, ByVal Operazione As ConnectorV2.TipoMessaggioEvento) As Boolean
        '
        ' Verifiche dei parametri
        '
        If IdEsternoEvento IsNot Nothing AndAlso IdEsternoEvento.Length = 0 Then
            Throw New System.Exception("Manca il parametro IdEsterno dell'evento!")
        End If
        '
        ' Esecuzione della stored procedure
        '
        With sqlcmdExtEventiAfterProcess
            .Parameters("@IdEsterno").Value = IdEsternoEvento
            .Parameters("@Operazione").Value = Operazione

            If Not moSqlTransact Is Nothing Then
                .Transaction = moSqlTransact
            End If

            Dim vScalar As Object = .ExecuteScalar()

            Dim vRetVal As Object = .Parameters("@RETURN_VALUE").Value
            If (vRetVal Is Nothing) OrElse IsDBNull(vRetVal) OrElse (CType(vRetVal, Integer) <> 0) Then
                Throw New System.Exception("Errore durante Exec SP ExtEventiAfterProcess(); SQL error: " & vRetVal.ToString())
            Else
                '
                ' Ritorna boolean
                '
                If (Not vScalar Is Nothing) AndAlso (Not IsDBNull(vScalar)) Then
                    Return CType(vScalar, Integer) > 0
                Else
                    Throw New System.Exception("Errore durante Exec SP ExtEventiAfterProcess()!")
                End If
            End If
        End With
    End Function


    Public Function PazientiLookUpNomeAnagraficaDiRicerca(ByVal NomeAnagraficaCentrale As String, _
                            ByVal AziendaErogante As String) As String
        '-----------------------------------------------------------------------------------------
        ' Verifiche dei parametri: nessuna verifica!
        ' In generale NomeAnagraficaCentrale può essere vuoto...
        ' La DataAccess verifica già che AziendaErogante sia valorizzato correttamente
        '-----------------------------------------------------------------------------------------
        '
        ' Esegue SP
        '
        With sqlcmdExtPazienteLookUpNomeAnagraficaDiRicerca
            .Parameters("@NomeAnagrafica").Value = NomeAnagraficaCentrale
            .Parameters("@AziendaErogante").Value = AziendaErogante

            If Not moSqlTransact Is Nothing Then
                .Transaction = moSqlTransact
            End If

            Dim vScalar As Object = .ExecuteScalar()

            Dim vRetVal As Object = .Parameters("@RETURN_VALUE").Value
            If (Not vRetVal Is Nothing) AndAlso (Not IsDBNull(vRetVal)) AndAlso (CType(vRetVal, Integer) = 0) Then
                '
                ' Leggo il ritorno
                '
                If (Not vScalar Is Nothing) AndAlso (Not IsDBNull(vScalar)) Then
                    Return vScalar.ToString 'contiene il nome dell'anagrafica centrale da utilizzare in fase di ricerca
                Else
                    Return String.Empty
                End If
            Else
                Throw New System.Exception("Errore durante Exec SP PazientiLookUpNomeAnagraficaDiRicerca(); SQL error: " & vRetVal.ToString())
            End If
        End With

    End Function


    Public Function EventiListaAttesaChiusuraLista(ByVal IdEsternoEvento As String) As Boolean
        '
        ' Verifiche dei parametri
        '
        If IdEsternoEvento IsNot Nothing AndAlso IdEsternoEvento.Length = 0 Then
            Throw New System.Exception("Manca il parametro IdEsterno dell'evento!")
        End If
        '
        ' Esegue la SP
        '
        With sqlcmdExtEventiListaAttesaChiusuraLista
            .Parameters("@IdEsterno").Value = IdEsternoEvento

            If Not moSqlTransact Is Nothing Then
                .Transaction = moSqlTransact
            End If

            Dim vScalar As Object = .ExecuteScalar()

            Dim vRetVal As Object = .Parameters("@RETURN_VALUE").Value
            If (vRetVal Is Nothing) OrElse IsDBNull(vRetVal) OrElse (CType(vRetVal, Integer) <> 0) Then
                Throw New System.Exception("Errore durante Exec SP EventiListaAttesaChiusuraLista(); SQL error: " & vRetVal.ToString())
            Else
                '
                ' Ritorna boolean
                '
                If (Not vScalar Is Nothing) AndAlso (Not IsDBNull(vScalar)) Then
                    Return CType(vScalar, Integer) > 0
                Else
                    Throw New System.Exception("Errore durante Exec SP EventiListaAttesaChiusuraLista()!")
                End If
            End If
        End With

    End Function

    Public Function EventiListaAttesaRiaperturaLista(ByVal IdEsternoEvento As String) As Boolean
        '
        ' Verifiche dei parametri
        '
        If IdEsternoEvento IsNot Nothing AndAlso IdEsternoEvento.Length = 0 Then
            Throw New System.Exception("Manca il parametro IdEsterno dell'evento!")
        End If
        '
        ' Esegue la SP
        '
        With sqlcmdExtEventiListaAttesaRiaperturaLista
            .Parameters("@IdEsterno").Value = IdEsternoEvento

            If Not moSqlTransact Is Nothing Then
                .Transaction = moSqlTransact
            End If

            Dim vScalar As Object = .ExecuteScalar()

            Dim vRetVal As Object = .Parameters("@RETURN_VALUE").Value
            If (vRetVal Is Nothing) OrElse IsDBNull(vRetVal) OrElse (CType(vRetVal, Integer) <> 0) Then
                Throw New System.Exception("Errore durante Exec SP EventiListaAttesaRiaperturaLista(); SQL error: " & vRetVal.ToString())
            Else
                '
                ' Ritorna boolean
                '
                If (Not vScalar Is Nothing) AndAlso (Not IsDBNull(vScalar)) Then
                    Return CType(vScalar, Integer) > 0
                Else
                    Throw New System.Exception("Errore durante Exec SP EventiListaAttesaRiaperturaLista()!")
                End If
            End If
        End With

    End Function


    Public Function EventiListaAttesaSpostamentoAnagrafico(ByVal IdEsternoEvento As String, ByVal XmlAttributi As String) As Boolean
        '
        ' Verifiche dei parametri
        '
        If IdEsternoEvento IsNot Nothing AndAlso IdEsternoEvento.Length = 0 Then
            Throw New System.Exception("Manca il parametro IdEsterno dell'evento!")
        End If

        If XmlAttributi IsNot Nothing AndAlso XmlAttributi.Length = 0 Then
            Throw New System.Exception("Manca il parametro XmlAttributi!")
        End If
        '
        ' Esegue la SP
        '
        With sqlcmdExtEventiListaAttesaSpostamentoAnagrafico
            .Parameters("@IdEsterno").Value = IdEsternoEvento
            .Parameters("@XmlAttributi").Value = XmlAttributi

            If Not moSqlTransact Is Nothing Then
                .Transaction = moSqlTransact
            End If

            Dim vScalar As Object = .ExecuteScalar()

            Dim vRet As Object = .Parameters("@RETURN_VALUE").Value
            If (vRet Is Nothing) OrElse IsDBNull(vRet) OrElse (CType(vRet, Integer) <> 0) Then
                Throw New System.Exception("Errore durante Exec SP ExtEventiListaAttesaSpostamentoAnagrafico(); SQL error: " & vRet.ToString())
            Else
                '
                ' Ritorna boolean
                '
                If (Not vScalar Is Nothing) AndAlso (Not IsDBNull(vScalar)) Then
                    Return CType(vScalar, Integer) > 0
                Else
                    Throw New System.Exception("Errore durante Exec SP ExtEventiListaAttesaSpostamentoAnagrafico()!")
                End If
            End If
        End With
    End Function


    Public Function LogAutoPrefixAdd(ByVal AziendaErogante As String, ByVal SistemaErogante As String, ByVal Repartoerogante As String, IdEsterno As String) As Boolean
        Dim bRetVal As Boolean
        '
        ' Verifiche dei parametri
        '
        If String.IsNullOrEmpty(AziendaErogante) Then
            Throw New System.Exception("Il parametro AziendaErogante è obbligatorio!")
        End If
        If String.IsNullOrEmpty(SistemaErogante) Then
            Throw New System.Exception("Il parametro SistemaErogante è obbligatorio!")
        End If
        If String.IsNullOrEmpty(IdEsterno) Then
            Throw New System.Exception("Il parametro IdEsterno è obbligatorio!")
        End If
        '
        ' Chiamo la stored procedure
        '
        With SqlCmdExtLogAutoPrefix
            .Parameters("@AziendaErogante").Value = AziendaErogante
            .Parameters("@SistemaErogante").Value = SistemaErogante
            .Parameters("@Repartoerogante").Value = Repartoerogante
            .Parameters("@IdEsterno").Value = IdEsterno
            '
            ' Il metodo che usa questa funzione non dovrebbe usare la transazione...
            '
            If Not moSqlTransact Is Nothing Then
                .Transaction = moSqlTransact
            End If

            Dim vScalar As Object = .ExecuteScalar()

            Dim vRetVal As Object = .Parameters("@RETURN_VALUE").Value
            If (vRetVal Is Nothing) OrElse IsDBNull(vRetVal) OrElse (CType(vRetVal, Integer) <> 0) Then
                Throw New System.Exception("Errore durante Exec SP LogAutoPrefixAdd(); SQL error: " & vRetVal.ToString())
            Else
                '
                ' Ritorna boolean
                '
                If (Not vScalar Is Nothing) AndAlso (Not IsDBNull(vScalar)) Then
                    bRetVal = CType(vScalar, Integer) > 0
                Else
                    Throw New System.Exception("Errore durante Exec SP LogAutoPrefixAdd()!")
                End If
            End If
        End With
        '
        ' 
        '
        Return bRetVal
    End Function

End Class
