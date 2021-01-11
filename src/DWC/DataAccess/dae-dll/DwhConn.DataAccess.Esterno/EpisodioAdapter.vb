Friend Class EpisodioAdapter
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
    Friend WithEvents sqlcmdExtRefertiEsiste As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcnnDwhClinico As System.Data.SqlClient.SqlConnection
    Friend WithEvents sqlcmdExtPazienteEsiste As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtRefertiRimuovi As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtPazienteModifica As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtPazienteDipAssociaRiferimenti As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtPazienteDipAssocia As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtPazienteAggiungi As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtPrestazioniEsiste As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtPrestazioniAggiungi As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtPrestazioniRimuovi As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtPrestazioniModifica As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtAllegatiModifica As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtAllegatiAggiungi As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtAllegatiRimuovi As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtAllegatiEsiste As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtPazienteDipEsiste As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtPazienteRimuovi As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtPazienteAggiungi3 As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtRefertiBeforeProcess As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtRefertiAfterProcess As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdRefertiRiferimentiAggiungi As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtPazienteLookUpNomeAnagraficaDiRicerca As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtRefertiAggiungi3 As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtRefertiModifica3 As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtRefertiGetIdPaziente As System.Data.SqlClient.SqlCommand
    Friend WithEvents SqlCmdExtRefertiGeneraAnteprima As System.Data.SqlClient.SqlCommand
    Friend WithEvents SqlCmdExtTranscodificaRegimi As System.Data.SqlClient.SqlCommand
    Friend WithEvents SqlCmdExtTranscodificaPriorita As System.Data.SqlClient.SqlCommand
    Friend WithEvents SqlCmdExtLogAutoPrefix As System.Data.SqlClient.SqlCommand
    Friend WithEvents SqlCmdExtAziendeErogantiLista As System.Data.SqlClient.SqlCommand
    Friend WithEvents SqlCmdExtSistemiErogantiLista As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdExtRefertiDataModifica As System.Data.SqlClient.SqlCommand
    <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()
        Me.sqlcmdExtRefertiEsiste = New System.Data.SqlClient.SqlCommand()
        Me.sqlcnnDwhClinico = New System.Data.SqlClient.SqlConnection()
        Me.sqlcmdExtPazienteEsiste = New System.Data.SqlClient.SqlCommand()
        Me.sqlcmdExtRefertiRimuovi = New System.Data.SqlClient.SqlCommand()
        Me.sqlcmdExtPazienteModifica = New System.Data.SqlClient.SqlCommand()
        Me.sqlcmdExtPazienteDipAssociaRiferimenti = New System.Data.SqlClient.SqlCommand()
        Me.sqlcmdExtPazienteDipAssocia = New System.Data.SqlClient.SqlCommand()
        Me.sqlcmdExtPazienteAggiungi = New System.Data.SqlClient.SqlCommand()
        Me.sqlcmdExtPrestazioniEsiste = New System.Data.SqlClient.SqlCommand()
        Me.sqlcmdExtPrestazioniAggiungi = New System.Data.SqlClient.SqlCommand()
        Me.sqlcmdExtPrestazioniRimuovi = New System.Data.SqlClient.SqlCommand()
        Me.sqlcmdExtPrestazioniModifica = New System.Data.SqlClient.SqlCommand()
        Me.sqlcmdExtAllegatiModifica = New System.Data.SqlClient.SqlCommand()
        Me.sqlcmdExtAllegatiAggiungi = New System.Data.SqlClient.SqlCommand()
        Me.sqlcmdExtAllegatiRimuovi = New System.Data.SqlClient.SqlCommand()
        Me.sqlcmdExtAllegatiEsiste = New System.Data.SqlClient.SqlCommand()
        Me.sqlcmdExtPazienteDipEsiste = New System.Data.SqlClient.SqlCommand()
        Me.sqlcmdExtPazienteRimuovi = New System.Data.SqlClient.SqlCommand()
        Me.sqlcmdExtRefertiDataModifica = New System.Data.SqlClient.SqlCommand()
        Me.sqlcmdExtPazienteAggiungi3 = New System.Data.SqlClient.SqlCommand()
        Me.sqlcmdExtRefertiBeforeProcess = New System.Data.SqlClient.SqlCommand()
        Me.sqlcmdExtRefertiAfterProcess = New System.Data.SqlClient.SqlCommand()
        Me.sqlcmdRefertiRiferimentiAggiungi = New System.Data.SqlClient.SqlCommand()
        Me.sqlcmdExtPazienteLookUpNomeAnagraficaDiRicerca = New System.Data.SqlClient.SqlCommand()
        Me.sqlcmdExtRefertiAggiungi3 = New System.Data.SqlClient.SqlCommand()
        Me.sqlcmdExtRefertiModifica3 = New System.Data.SqlClient.SqlCommand()
        Me.sqlcmdExtRefertiGetIdPaziente = New System.Data.SqlClient.SqlCommand()
        Me.SqlCmdExtRefertiGeneraAnteprima = New System.Data.SqlClient.SqlCommand()
        Me.SqlCmdExtTranscodificaRegimi = New System.Data.SqlClient.SqlCommand()
        Me.SqlCmdExtTranscodificaPriorita = New System.Data.SqlClient.SqlCommand()
        Me.SqlCmdExtLogAutoPrefix = New System.Data.SqlClient.SqlCommand()
        Me.SqlCmdExtAziendeErogantiLista = New System.Data.SqlClient.SqlCommand()
        Me.SqlCmdExtSistemiErogantiLista = New System.Data.SqlClient.SqlCommand()
        '
        'sqlcmdExtRefertiEsiste
        '
        Me.sqlcmdExtRefertiEsiste.CommandText = "dbo.[ExtRefertiEsiste2]"
        Me.sqlcmdExtRefertiEsiste.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtRefertiEsiste.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtRefertiEsiste.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@IdEsterno", System.Data.SqlDbType.VarChar, 64)})
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
        'sqlcmdExtRefertiRimuovi
        '
        Me.sqlcmdExtRefertiRimuovi.CommandText = "dbo.[ExtRefertiRimuovi]"
        Me.sqlcmdExtRefertiRimuovi.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtRefertiRimuovi.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtRefertiRimuovi.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@IdEsterno", System.Data.SqlDbType.VarChar, 64)})
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
        'sqlcmdExtPrestazioniEsiste
        '
        Me.sqlcmdExtPrestazioniEsiste.CommandText = "dbo.[ExtPrestazioniEsiste]"
        Me.sqlcmdExtPrestazioniEsiste.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtPrestazioniEsiste.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtPrestazioniEsiste.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@IdEsternoReferto", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@IdEsterno", System.Data.SqlDbType.VarChar, 64)})
        '
        'sqlcmdExtPrestazioniAggiungi
        '
        Me.sqlcmdExtPrestazioniAggiungi.CommandText = "dbo.[ExtPrestazioniAggiungi2]"
        Me.sqlcmdExtPrestazioniAggiungi.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtPrestazioniAggiungi.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtPrestazioniAggiungi.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@IdEsternoReferto", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@IdEsterno", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@DataErogazione", System.Data.SqlDbType.DateTime, 8), New System.Data.SqlClient.SqlParameter("@PrestazioneCodice", System.Data.SqlDbType.VarChar, 12), New System.Data.SqlClient.SqlParameter("@PrestazioneDescrizione", System.Data.SqlDbType.VarChar, 150), New System.Data.SqlClient.SqlParameter("@PrestazionePosizione", System.Data.SqlDbType.Int, 4), New System.Data.SqlClient.SqlParameter("@SezioneCodice", System.Data.SqlDbType.VarChar, 12), New System.Data.SqlClient.SqlParameter("@SezioneDescrizione", System.Data.SqlDbType.VarChar, 255), New System.Data.SqlClient.SqlParameter("@SezionePosizione", System.Data.SqlDbType.Int, 4), New System.Data.SqlClient.SqlParameter("@GravitaCodice", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@GravitaDescrizione", System.Data.SqlDbType.VarChar, 128), New System.Data.SqlClient.SqlParameter("@Quantita", System.Data.SqlDbType.VarChar, 128), New System.Data.SqlClient.SqlParameter("@Risultato", System.Data.SqlDbType.VarChar, 256), New System.Data.SqlClient.SqlParameter("@ValoriRiferimento", System.Data.SqlDbType.VarChar, 256), New System.Data.SqlClient.SqlParameter("@PrestazioneCommenti", System.Data.SqlDbType.VarChar, 2048), New System.Data.SqlClient.SqlParameter("@XmlAttributi", System.Data.SqlDbType.VarChar, 2147483647)})
        '
        'sqlcmdExtPrestazioniRimuovi
        '
        Me.sqlcmdExtPrestazioniRimuovi.CommandText = "dbo.[ExtPrestazioniRimuovi]"
        Me.sqlcmdExtPrestazioniRimuovi.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtPrestazioniRimuovi.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtPrestazioniRimuovi.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@IdEsternoReferto", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@IdEsterno", System.Data.SqlDbType.VarChar, 64)})
        '
        'sqlcmdExtPrestazioniModifica
        '
        Me.sqlcmdExtPrestazioniModifica.CommandText = "dbo.[ExtPrestazioniModifica2]"
        Me.sqlcmdExtPrestazioniModifica.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtPrestazioniModifica.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtPrestazioniModifica.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@IdEsternoReferto", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@IdEsterno", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@DataErogazione", System.Data.SqlDbType.DateTime, 8), New System.Data.SqlClient.SqlParameter("@PrestazioneCodice", System.Data.SqlDbType.VarChar, 12), New System.Data.SqlClient.SqlParameter("@PrestazioneDescrizione", System.Data.SqlDbType.VarChar, 150), New System.Data.SqlClient.SqlParameter("@PrestazionePosizione", System.Data.SqlDbType.Int, 4), New System.Data.SqlClient.SqlParameter("@SezioneCodice", System.Data.SqlDbType.VarChar, 12), New System.Data.SqlClient.SqlParameter("@SezioneDescrizione", System.Data.SqlDbType.VarChar, 255), New System.Data.SqlClient.SqlParameter("@SezionePosizione", System.Data.SqlDbType.Int, 4), New System.Data.SqlClient.SqlParameter("@GravitaCodice", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@GravitaDescrizione", System.Data.SqlDbType.VarChar, 128), New System.Data.SqlClient.SqlParameter("@Quantita", System.Data.SqlDbType.VarChar, 128), New System.Data.SqlClient.SqlParameter("@Risultato", System.Data.SqlDbType.VarChar, 256), New System.Data.SqlClient.SqlParameter("@ValoriRiferimento", System.Data.SqlDbType.VarChar, 256), New System.Data.SqlClient.SqlParameter("@PrestazioneCommenti", System.Data.SqlDbType.VarChar, 2048), New System.Data.SqlClient.SqlParameter("@XmlAttributi", System.Data.SqlDbType.VarChar, 2147483647)})
        '
        'sqlcmdExtAllegatiModifica
        '
        Me.sqlcmdExtAllegatiModifica.CommandText = "dbo.[ExtAllegatiModifica]"
        Me.sqlcmdExtAllegatiModifica.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtAllegatiModifica.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtAllegatiModifica.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@IdEsternoReferto", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@IdEsterno", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@DataFile", System.Data.SqlDbType.DateTime, 8), New System.Data.SqlClient.SqlParameter("@NomeFile", System.Data.SqlDbType.VarChar, 255), New System.Data.SqlClient.SqlParameter("@Descrizione", System.Data.SqlDbType.VarChar, 255), New System.Data.SqlClient.SqlParameter("@Posizione", System.Data.SqlDbType.Int, 4), New System.Data.SqlClient.SqlParameter("@StatoCodice", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@StatoDescrizione", System.Data.SqlDbType.VarChar, 128), New System.Data.SqlClient.SqlParameter("@MimeType", System.Data.SqlDbType.VarChar, 50), New System.Data.SqlClient.SqlParameter("@MimeData", System.Data.SqlDbType.VarBinary, 2147483647), New System.Data.SqlClient.SqlParameter("@XmlAttributi", System.Data.SqlDbType.VarChar, 2147483647)})
        '
        'sqlcmdExtAllegatiAggiungi
        '
        Me.sqlcmdExtAllegatiAggiungi.CommandText = "dbo.[ExtAllegatiAggiungi]"
        Me.sqlcmdExtAllegatiAggiungi.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtAllegatiAggiungi.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtAllegatiAggiungi.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@IdEsternoReferto", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@IdEsterno", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@DataFile", System.Data.SqlDbType.DateTime, 8), New System.Data.SqlClient.SqlParameter("@NomeFile", System.Data.SqlDbType.VarChar, 255), New System.Data.SqlClient.SqlParameter("@Descrizione", System.Data.SqlDbType.VarChar, 255), New System.Data.SqlClient.SqlParameter("@Posizione", System.Data.SqlDbType.Int, 4), New System.Data.SqlClient.SqlParameter("@StatoCodice", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@StatoDescrizione", System.Data.SqlDbType.VarChar, 128), New System.Data.SqlClient.SqlParameter("@MimeType", System.Data.SqlDbType.VarChar, 50), New System.Data.SqlClient.SqlParameter("@MimeData", System.Data.SqlDbType.VarBinary, 2147483647), New System.Data.SqlClient.SqlParameter("@XmlAttributi", System.Data.SqlDbType.VarChar, 2147483647)})
        '
        'sqlcmdExtAllegatiRimuovi
        '
        Me.sqlcmdExtAllegatiRimuovi.CommandText = "dbo.[ExtAllegatiRimuovi]"
        Me.sqlcmdExtAllegatiRimuovi.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtAllegatiRimuovi.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtAllegatiRimuovi.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@IdEsternoReferto", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@IdEsterno", System.Data.SqlDbType.VarChar, 64)})
        '
        'sqlcmdExtAllegatiEsiste
        '
        Me.sqlcmdExtAllegatiEsiste.CommandText = "dbo.[ExtAllegatiEsiste]"
        Me.sqlcmdExtAllegatiEsiste.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtAllegatiEsiste.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtAllegatiEsiste.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@IdEsternoReferto", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@IdEsterno", System.Data.SqlDbType.VarChar, 64)})
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
        'sqlcmdExtRefertiDataModifica
        '
        Me.sqlcmdExtRefertiDataModifica.CommandText = "dbo.[ExtRefertiDataModifica]"
        Me.sqlcmdExtRefertiDataModifica.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtRefertiDataModifica.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtRefertiDataModifica.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@IdEsterno", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@DataModificaEsterno", System.Data.SqlDbType.DateTime, 8)})
        '
        'sqlcmdExtPazienteAggiungi3
        '
        Me.sqlcmdExtPazienteAggiungi3.CommandText = "dbo.[ExtPazienteAggiungi3]"
        Me.sqlcmdExtPazienteAggiungi3.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtPazienteAggiungi3.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtPazienteAggiungi3.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@IdEsterno", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@AziendaErogante", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@SistemaErogante", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@RepartoErogante", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@IdAnagrafica", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@Sesso", System.Data.SqlDbType.VarChar, 1), New System.Data.SqlClient.SqlParameter("@Cognome", System.Data.SqlDbType.VarChar, 50), New System.Data.SqlClient.SqlParameter("@Nome", System.Data.SqlDbType.VarChar, 50), New System.Data.SqlClient.SqlParameter("@CodiceFiscale", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@DataNascita", System.Data.SqlDbType.DateTime, 8), New System.Data.SqlClient.SqlParameter("@LuogoNascita", System.Data.SqlDbType.VarChar, 80)})
        '
        'sqlcmdExtRefertiBeforeProcess
        '
        Me.sqlcmdExtRefertiBeforeProcess.CommandText = "dbo.[ExtRefertiBeforeProcess]"
        Me.sqlcmdExtRefertiBeforeProcess.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtRefertiBeforeProcess.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtRefertiBeforeProcess.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@IdEsterno", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@Operazione", System.Data.SqlDbType.SmallInt, 2), New System.Data.SqlClient.SqlParameter("@ImportazioneStorica", System.Data.SqlDbType.Bit, 1)})
        '
        'sqlcmdExtRefertiAfterProcess
        '
        Me.sqlcmdExtRefertiAfterProcess.CommandText = "dbo.[ExtRefertiAfterProcess]"
        Me.sqlcmdExtRefertiAfterProcess.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtRefertiAfterProcess.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtRefertiAfterProcess.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@IdEsterno", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@Operazione", System.Data.SqlDbType.SmallInt, 2), New System.Data.SqlClient.SqlParameter("@ImportazioneStorica", System.Data.SqlDbType.Bit, 1)})
        '
        'sqlcmdRefertiRiferimentiAggiungi
        '
        Me.sqlcmdRefertiRiferimentiAggiungi.CommandText = "dbo.[ExtRefertiRiferimentiAggiungi]"
        Me.sqlcmdRefertiRiferimentiAggiungi.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdRefertiRiferimentiAggiungi.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdRefertiRiferimentiAggiungi.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@IdEsterno", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@IdEsternoPrecedente", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@DataModificaEsterno", System.Data.SqlDbType.DateTime, 8)})
        '
        'sqlcmdExtPazienteLookUpNomeAnagraficaDiRicerca
        '
        Me.sqlcmdExtPazienteLookUpNomeAnagraficaDiRicerca.CommandText = "dbo.[ExtPazienteLookUpNomeAnagraficaDiRicerca]"
        Me.sqlcmdExtPazienteLookUpNomeAnagraficaDiRicerca.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtPazienteLookUpNomeAnagraficaDiRicerca.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtPazienteLookUpNomeAnagraficaDiRicerca.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@NomeAnagrafica", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@AziendaErogante", System.Data.SqlDbType.VarChar, 16)})
        '
        'sqlcmdExtRefertiAggiungi3
        '
        Me.sqlcmdExtRefertiAggiungi3.CommandText = "dbo.[ExtRefertiAggiungi3]"
        Me.sqlcmdExtRefertiAggiungi3.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtRefertiAggiungi3.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtRefertiAggiungi3.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@IdEsterno", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@IdPaziente", System.Data.SqlDbType.UniqueIdentifier, 16), New System.Data.SqlClient.SqlParameter("@AziendaErogante", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@SistemaErogante", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@RepartoErogante", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@SezioneErogante", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@SpecialitaErogante", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@DataReferto", System.Data.SqlDbType.DateTime, 8), New System.Data.SqlClient.SqlParameter("@NumeroReferto", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@NumeroPrenotazione", System.Data.SqlDbType.VarChar, 32), New System.Data.SqlClient.SqlParameter("@NumeroNosologico", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@PrioritaCodice", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@PrioritaDescr", System.Data.SqlDbType.VarChar, 128), New System.Data.SqlClient.SqlParameter("@StatoRichiestaCodice", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@StatoRichiestaDescr", System.Data.SqlDbType.VarChar, 128), New System.Data.SqlClient.SqlParameter("@TipoRichiestaCodice", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@TipoRichiestaDescr", System.Data.SqlDbType.VarChar, 128), New System.Data.SqlClient.SqlParameter("@RepartoRichiedenteCodice", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@RepartoRichiedenteDescr", System.Data.SqlDbType.VarChar, 128), New System.Data.SqlClient.SqlParameter("@MedicoRefertanteCodice", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@MedicoRefertanteDescr", System.Data.SqlDbType.VarChar, 128), New System.Data.SqlClient.SqlParameter("@XmlAttributi", System.Data.SqlDbType.Text, 2147483647)})
        '
        'sqlcmdExtRefertiModifica3
        '
        Me.sqlcmdExtRefertiModifica3.CommandText = "dbo.[ExtRefertiModifica3]"
        Me.sqlcmdExtRefertiModifica3.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtRefertiModifica3.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtRefertiModifica3.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@IdEsterno", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@IdPaziente", System.Data.SqlDbType.UniqueIdentifier, 16), New System.Data.SqlClient.SqlParameter("@AziendaErogante", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@SistemaErogante", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@RepartoErogante", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@SezioneErogante", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@SpecialitaErogante", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@DataReferto", System.Data.SqlDbType.DateTime, 8), New System.Data.SqlClient.SqlParameter("@NumeroReferto", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@NumeroPrenotazione", System.Data.SqlDbType.VarChar, 32), New System.Data.SqlClient.SqlParameter("@NumeroNosologico", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@PrioritaCodice", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@PrioritaDescr", System.Data.SqlDbType.VarChar, 128), New System.Data.SqlClient.SqlParameter("@StatoRichiestaCodice", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@StatoRichiestaDescr", System.Data.SqlDbType.VarChar, 128), New System.Data.SqlClient.SqlParameter("@TipoRichiestaCodice", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@TipoRichiestaDescr", System.Data.SqlDbType.VarChar, 128), New System.Data.SqlClient.SqlParameter("@RepartoRichiedenteCodice", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@RepartoRichiedenteDescr", System.Data.SqlDbType.VarChar, 128), New System.Data.SqlClient.SqlParameter("@MedicoRefertanteCodice", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@MedicoRefertanteDescr", System.Data.SqlDbType.VarChar, 128), New System.Data.SqlClient.SqlParameter("@XmlAttributi", System.Data.SqlDbType.Text, 2147483647)})
        '
        'sqlcmdExtRefertiGetIdPaziente
        '
        Me.sqlcmdExtRefertiGetIdPaziente.CommandText = "dbo.[ExtRefertiGetIdPaziente]"
        Me.sqlcmdExtRefertiGetIdPaziente.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdExtRefertiGetIdPaziente.Connection = Me.sqlcnnDwhClinico
        Me.sqlcmdExtRefertiGetIdPaziente.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@IdEsterno", System.Data.SqlDbType.VarChar, 64)})
        '
        'SqlCmdExtRefertiGeneraAnteprima
        '
        Me.SqlCmdExtRefertiGeneraAnteprima.CommandText = "dbo.[ExtRefertiGeneraAnteprima]"
        Me.SqlCmdExtRefertiGeneraAnteprima.CommandType = System.Data.CommandType.StoredProcedure
        Me.SqlCmdExtRefertiGeneraAnteprima.Connection = Me.sqlcnnDwhClinico
        Me.SqlCmdExtRefertiGeneraAnteprima.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@AziendaErogante", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@SistemaErogante", System.Data.SqlDbType.VarChar, 16)})
        '
        'SqlCmdExtTranscodificaRegimi
        '
        Me.SqlCmdExtTranscodificaRegimi.CommandText = "dbo.[ExtTranscodificaRegimi]"
        Me.SqlCmdExtTranscodificaRegimi.CommandType = System.Data.CommandType.StoredProcedure
        Me.SqlCmdExtTranscodificaRegimi.Connection = Me.sqlcnnDwhClinico
        Me.SqlCmdExtTranscodificaRegimi.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@AziendaErogante", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@SistemaErogante", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@CodiceEsterno", System.Data.SqlDbType.VarChar, 16)})
        '
        'SqlCmdExtTranscodificaPriorita
        '
        Me.SqlCmdExtTranscodificaPriorita.CommandText = "dbo.[ExtTranscodificaPriorita]"
        Me.SqlCmdExtTranscodificaPriorita.CommandType = System.Data.CommandType.StoredProcedure
        Me.SqlCmdExtTranscodificaPriorita.Connection = Me.sqlcnnDwhClinico
        Me.SqlCmdExtTranscodificaPriorita.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@AziendaErogante", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@SistemaErogante", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@CodiceEsterno", System.Data.SqlDbType.VarChar, 16)})
        '
        'SqlCmdExtLogAutoPrefix
        '
        Me.SqlCmdExtLogAutoPrefix.CommandText = "dbo.[ExtLogAutoprefix]"
        Me.SqlCmdExtLogAutoPrefix.CommandType = System.Data.CommandType.StoredProcedure
        Me.SqlCmdExtLogAutoPrefix.Connection = Me.sqlcnnDwhClinico
        Me.SqlCmdExtLogAutoPrefix.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@AziendaErogante", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@SistemaErogante", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@RepartoErogante", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@IdEsterno", System.Data.SqlDbType.VarChar, 64)})
        '
        'SqlCmdExtAziendeErogantiLista
        '
        Me.SqlCmdExtAziendeErogantiLista.CommandText = "dbo.[ExtAziendeErogantiLista]"
        Me.SqlCmdExtAziendeErogantiLista.CommandType = System.Data.CommandType.StoredProcedure
        Me.SqlCmdExtAziendeErogantiLista.Connection = Me.sqlcnnDwhClinico
        Me.SqlCmdExtAziendeErogantiLista.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing)})
        '
        'SqlCmdExtSistemiErogantiLista
        '
        Me.SqlCmdExtSistemiErogantiLista.CommandText = "dbo.[ExtSistemiErogantiLista]"
        Me.SqlCmdExtSistemiErogantiLista.CommandType = System.Data.CommandType.StoredProcedure
        Me.SqlCmdExtSistemiErogantiLista.Connection = Me.sqlcnnDwhClinico
        Me.SqlCmdExtSistemiErogantiLista.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing)})

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

    Public Function AllegatiAddNew(ByVal IdEsternoReferto As String, _
                                    ByVal IdEsternoAllegato As String, _
                                    ByVal DataFile As DateTime, _
                                    ByVal NomeFile As String, _
                                    ByVal Descrizione As String, _
                                    ByVal Posizione As Short, _
                                    ByVal StatoCodice As String, _
                                    ByVal StatoDescrizione As String, _
                                    ByVal MimeType As String, _
                                    ByVal MimeData As Byte(), _
                                    ByVal XmlAttributi As String) As Boolean
        '
        ' Verifiche dei parametri
        '
        If IdEsternoReferto IsNot Nothing AndAlso IdEsternoReferto.Length = 0 Then
            Throw New System.Exception("Manca il parametro IdEsterno del referto!")
        End If

        If IdEsternoAllegato IsNot Nothing AndAlso IdEsternoAllegato.Length = 0 Then
            Throw New System.Exception("Manca il parametro IdEsterno dell'allegato!")
        End If
        '
        ' Esegue la SP
        '
        With sqlcmdExtAllegatiAggiungi
            .Parameters("@IdEsternoReferto").Value = IdEsternoReferto
            .Parameters("@IdEsterno").Value = IdEsternoAllegato
            .Parameters("@DataFile").Value = SqlUtil.ParseDatetime(DataFile)
            .Parameters("@NomeFile").Value = NomeFile
            .Parameters("@Descrizione").Value = Descrizione
            .Parameters("@Posizione").Value = Posizione
            .Parameters("@StatoCodice").Value = StatoCodice
            .Parameters("@StatoDescrizione").Value = StatoDescrizione
            .Parameters("@MimeType").Value = MimeType
            .Parameters("@MimeData").Value = MimeData
            .Parameters("@XmlAttributi").Value = SqlUtil.StringEmptyToDbNull(XmlAttributi)

            If Not moSqlTransact Is Nothing Then
                .Transaction = moSqlTransact
            End If

            Dim vScalar As Object = .ExecuteScalar()

            Dim vRetVal As Object = .Parameters("@RETURN_VALUE").Value
            If (vRetVal Is Nothing) OrElse IsDBNull(vRetVal) OrElse (CType(vRetVal, Integer) <> 0) Then
                Throw New System.Exception("Errore durante Exec SP ExtAllegatiAggiungi(); SQL error: " & vRetVal.ToString())
            Else
                '
                ' Ritorna boolean
                '
                If (Not vScalar Is Nothing) AndAlso (Not IsDBNull(vScalar)) Then
                    Return CType(vScalar, Integer) > 0
                Else
                    Throw New System.Exception("Errore durante Exec SP ExtAllegatiAggiungi(); Paziente non trovato!")
                End If
            End If
        End With

    End Function

    Public Function AllegatiUpdate(ByVal IdEsternoReferto As String, _
                                    ByVal IdEsternoAllegato As String, _
                                    ByVal DataFile As DateTime, _
                                    ByVal NomeFile As String, _
                                    ByVal Descrizione As String, _
                                    ByVal Posizione As Short, _
                                    ByVal StatoCodice As String, _
                                    ByVal StatoDescrizione As String, _
                                    ByVal MimeType As String, _
                                    ByVal MimeData As Byte(), _
                                    ByVal XmlAttributi As String) As Boolean
        '
        ' Verifiche dei parametri
        '
        If IdEsternoReferto IsNot Nothing AndAlso IdEsternoReferto.Length = 0 Then
            Throw New System.Exception("Manca il parametro IdEsterno del referto!")
        End If

        If IdEsternoAllegato IsNot Nothing AndAlso IdEsternoAllegato.Length = 0 Then
            Throw New System.Exception("Manca il parametro IdEsterno dell'allegato!")
        End If
        '
        ' Esegue la SP
        '
        With sqlcmdExtAllegatiModifica
            .Parameters("@IdEsternoReferto").Value = IdEsternoReferto
            .Parameters("@IdEsterno").Value = IdEsternoAllegato
            .Parameters("@DataFile").Value = SqlUtil.ParseDatetime(DataFile)
            .Parameters("@NomeFile").Value = NomeFile
            .Parameters("@Descrizione").Value = Descrizione
            .Parameters("@Posizione").Value = Posizione
            .Parameters("@StatoCodice").Value = StatoCodice
            .Parameters("@StatoDescrizione").Value = StatoDescrizione
            .Parameters("@MimeType").Value = MimeType
            .Parameters("@MimeData").Value = MimeData
            .Parameters("@XmlAttributi").Value = SqlUtil.StringEmptyToDbNull(XmlAttributi)

            If Not moSqlTransact Is Nothing Then
                .Transaction = moSqlTransact
            End If

            Dim vScalar As Object = .ExecuteScalar()

            Dim vRetVal As Object = .Parameters("@RETURN_VALUE").Value
            If (vRetVal Is Nothing) OrElse IsDBNull(vRetVal) OrElse (CType(vRetVal, Integer) <> 0) Then
                Throw New System.Exception("Errore durante Exec SP ExtAllegatiModifica(); SQL error: " & vRetVal.ToString())
            Else
                '
                ' Ritorna boolean
                '
                If (Not vScalar Is Nothing) AndAlso (Not IsDBNull(vScalar)) Then
                    Return CType(vScalar, Integer) > 0
                Else
                    Throw New System.Exception("Errore durante Exec SP ExtAllegatiModifica(); Paziente non trovato!")
                End If
            End If
        End With

    End Function

    Public Function AllegatiContains(ByVal IdEsternoReferto As String, _
                                        ByVal IdEsternoAllegato As String) As Boolean
        '
        ' Verifiche dei parametri
        '
        If IdEsternoReferto IsNot Nothing AndAlso IdEsternoReferto.Length = 0 Then
            Throw New System.Exception("Manca il parametro IdEsterno del referto!")
        End If

        If IdEsternoAllegato IsNot Nothing AndAlso IdEsternoAllegato.Length = 0 Then
            Throw New System.Exception("Manca il parametro IdEsterno dell ' allegato!")
        End If
        '
        ' Esegue la SP
        '
        With sqlcmdExtAllegatiEsiste
            .Parameters("@IdEsternoReferto").Value = IdEsternoReferto
            .Parameters("@IdEsterno").Value = IdEsternoAllegato

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
                Throw New System.Exception("Errore durante Exec SP ExtAllegatiEsiste(); SQL error: " & vRet.ToString())
            End If
        End With

    End Function

    Public Function AllegatiRemove(ByVal IdEsternoReferto As String, _
                                    ByVal IdEsternoAllegato As String) As Boolean
        '
        ' Verifiche dei parametri
        '
        If IdEsternoReferto IsNot Nothing AndAlso IdEsternoReferto.Length = 0 Then
            Throw New System.Exception("Manca il parametro IdEsterno del referto!")
        End If
        '
        ' Esegue la SP
        '
        With sqlcmdExtAllegatiRimuovi
            .Parameters("@IdEsternoReferto").Value = IdEsternoReferto
            .Parameters("@IdEsterno").Value = IIf(IdEsternoAllegato.Length > 0, IdEsternoAllegato, DBNull.Value)

            If Not moSqlTransact Is Nothing Then
                .Transaction = moSqlTransact
            End If

            Dim vScalar As Object = .ExecuteScalar()

            Dim vRet As Object = .Parameters("@RETURN_VALUE").Value
            If (Not vRet Is Nothing) AndAlso (Not IsDBNull(vRet)) AndAlso (CType(vRet, Integer) <> 0) Then
                Throw New System.Exception("Errore durante Exec SP ExtAllegatiRimuovi(); SQL error: " & vRet.ToString())
            Else
                '
                ' Ritorna boolean
                '
                If (Not vScalar Is Nothing) AndAlso (Not IsDBNull(vScalar)) Then
                    Return CType(vScalar, Integer) > 0
                Else
                    Throw New System.Exception("Errore durante Exec SP ExtAllegatiRimuovi(); Paziente non trovato!")
                End If
            End If
        End With

    End Function

    Public Function PrestazioniAddNew(ByVal IdEsternoReferto As String, _
                                        ByVal IdEsternoPrestazione As String, _
                                        ByVal DataErogazione As Date, _
                                        ByVal PrestazioneCodice As String, _
                                        ByVal PrestazioneDescrizione As String, _
                                        ByVal PrestazionePosizione As Short, _
                                        ByVal SezioneCodice As String, _
                                        ByVal SezioneDescrizione As String, _
                                        ByVal SezionePosizione As Short, _
                                        ByVal GravitaCodice As String, _
                                        ByVal GravitaDescrizione As String, _
                                        ByVal Quantita As String, _
                                        ByVal Risultato As String, _
                                        ByVal ValoriRiferimento As String, _
                                        ByVal PrestazioneCommenti As String, _
                                        ByVal XmlAttributi As String) As Boolean
        '
        ' Verifiche dei parametri
        '
        If IdEsternoReferto IsNot Nothing AndAlso IdEsternoReferto.Length = 0 Then
            Throw New System.Exception("Manca il parametro IdEsterno del referto!")
        End If

        If IdEsternoPrestazione IsNot Nothing AndAlso IdEsternoPrestazione.Length = 0 Then
            Throw New System.Exception("Manca il parametro IdEsterno della prestazione!")
        End If
        '
        ' Esegue la SP
        '
        With sqlcmdExtPrestazioniAggiungi
            .Parameters("@IdEsternoReferto").Value = IdEsternoReferto
            .Parameters("@IdEsterno").Value = IdEsternoPrestazione
            .Parameters("@DataErogazione").Value = SqlUtil.ParseDatetime(DataErogazione)
            .Parameters("@PrestazioneCodice").Value = PrestazioneCodice
            .Parameters("@PrestazioneDescrizione").Value = PrestazioneDescrizione
            .Parameters("@PrestazionePosizione").Value = PrestazionePosizione
            .Parameters("@SezioneCodice").Value = SezioneCodice
            .Parameters("@SezioneDescrizione").Value = SezioneDescrizione
            .Parameters("@SezionePosizione").Value = SezionePosizione
            .Parameters("@GravitaCodice").Value = GravitaCodice
            .Parameters("@GravitaDescrizione").Value = GravitaDescrizione
            .Parameters("@Quantita").Value = Quantita
            .Parameters("@Risultato").Value = Risultato
            .Parameters("@ValoriRiferimento").Value = ValoriRiferimento
            .Parameters("@PrestazioneCommenti").Value = PrestazioneCommenti
            .Parameters("@XmlAttributi").Value = SqlUtil.StringEmptyToDbNull(XmlAttributi)

            If Not moSqlTransact Is Nothing Then
                .Transaction = moSqlTransact
            End If

            Dim vScalar As Object = .ExecuteScalar()

            Dim vRetVal As Object = .Parameters("@RETURN_VALUE").Value
            If (vRetVal Is Nothing) OrElse IsDBNull(vRetVal) OrElse (CType(vRetVal, Integer) <> 0) Then
                Throw New System.Exception("Errore durante Exec SP ExtPrestazioniAggiungi(); SQL error: " & vRetVal.ToString())
            Else
                '
                ' Ritorna boolean
                '
                If (Not vScalar Is Nothing) AndAlso (Not IsDBNull(vScalar)) Then
                    Return CType(vScalar, Integer) > 0
                Else
                    Throw New System.Exception("Errore durante Exec SP ExtPrestazioniAggiungi(); Referto non trovato!")
                End If
            End If
        End With

    End Function

    Public Function PrestazioniUpdate(ByVal IdEsternoReferto As String, _
                            ByVal IdEsternoPrestazione As String, _
                            ByVal DataErogazione As Date, _
                            ByVal PrestazioneCodice As String, _
                            ByVal PrestazioneDescrizione As String, _
                            ByVal PrestazionePosizione As Short, _
                            ByVal SezioneCodice As String, _
                            ByVal SezioneDescrizione As String, _
                            ByVal SezionePosizione As Short, _
                            ByVal GravitaCodice As String, _
                            ByVal GravitaDescrizione As String, _
                            ByVal Quantita As String, _
                            ByVal Risultato As String, _
                            ByVal ValoriRiferimento As String, _
                            ByVal PrestazioneCommenti As String, _
                            ByVal XmlAttributi As String) As Boolean
        '
        ' Verifiche dei parametri
        '
        If IdEsternoReferto IsNot Nothing AndAlso IdEsternoReferto.Length = 0 Then
            Throw New System.Exception("Manca il parametro IdEsterno del referto!")
        End If

        If IdEsternoPrestazione IsNot Nothing AndAlso IdEsternoPrestazione.Length = 0 Then
            Throw New System.Exception("Manca il parametro IdEsterno della prestazione!")
        End If
        '
        ' Esegue la SP
        '
        With sqlcmdExtPrestazioniModifica
            .Parameters("@IdEsternoReferto").Value = IdEsternoReferto
            .Parameters("@IdEsterno").Value = IdEsternoPrestazione
            .Parameters("@DataErogazione").Value = SqlUtil.ParseDatetime(DataErogazione)
            .Parameters("@PrestazioneCodice").Value = PrestazioneCodice
            .Parameters("@PrestazioneDescrizione").Value = PrestazioneDescrizione
            .Parameters("@PrestazionePosizione").Value = PrestazionePosizione
            .Parameters("@SezioneCodice").Value = SezioneCodice
            .Parameters("@SezioneDescrizione").Value = SezioneDescrizione
            .Parameters("@SezionePosizione").Value = SezionePosizione
            .Parameters("@GravitaCodice").Value = GravitaCodice
            .Parameters("@GravitaDescrizione").Value = GravitaDescrizione
            .Parameters("@Quantita").Value = Quantita
            .Parameters("@Risultato").Value = Risultato
            .Parameters("@ValoriRiferimento").Value = ValoriRiferimento
            .Parameters("@PrestazioneCommenti").Value = PrestazioneCommenti
            .Parameters("@XmlAttributi").Value = SqlUtil.StringEmptyToDbNull(XmlAttributi)

            If Not moSqlTransact Is Nothing Then
                .Transaction = moSqlTransact
            End If

            Dim vScalar As Object = .ExecuteScalar()

            Dim vRetVal As Object = .Parameters("@RETURN_VALUE").Value
            If (vRetVal Is Nothing) OrElse IsDBNull(vRetVal) OrElse (CType(vRetVal, Integer) <> 0) Then
                Throw New System.Exception("Errore durante Exec SP ExtPrestazioniModifica(); SQL error: " & vRetVal.ToString())
            Else
                '
                ' Ritorna boolean
                '
                If (Not vScalar Is Nothing) AndAlso (Not IsDBNull(vScalar)) Then
                    Return CType(vScalar, Integer) > 0
                Else
                    Throw New System.Exception("Errore durante Exec SP ExtPrestazioniModifica(); Referto non trovato!")
                End If
            End If
        End With

    End Function

    Public Function PrestazioniContains(ByVal IdEsternoReferto As String, _
                                ByVal IdEsternoPrestazione As String) As Boolean

        '
        ' Verifiche dei parametri
        '
        If IdEsternoReferto IsNot Nothing AndAlso IdEsternoReferto.Length = 0 Then
            Throw New System.Exception("Manca il parametro IdEsterno del referto!")
        End If

        If IdEsternoPrestazione IsNot Nothing AndAlso IdEsternoPrestazione.Length = 0 Then
            Throw New System.Exception("Manca il parametro IdEsterno della prestazione!")
        End If
        '
        ' Esegue la SP
        '
        With sqlcmdExtPrestazioniEsiste
            .Parameters("@IdEsternoReferto").Value = IdEsternoReferto
            .Parameters("@IdEsterno").Value = IdEsternoPrestazione

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
                    Throw New System.Exception("Errore durante Exec SP ExtPrestazioniEsiste(); Referto non trovato!")
                End If
            Else
                Throw New System.Exception("Errore durante Exec SP ExtPrestazioniEsiste(); SQL error: " & vRet.ToString())
            End If
        End With

    End Function

    Public Function PrestazioniRemove(ByVal IdEsternoReferto As String, _
                            ByVal IdEsternoPrestazione As String) As Boolean
        '
        ' Verifiche dei parametri
        '
        If IdEsternoReferto IsNot Nothing AndAlso IdEsternoReferto.Length = 0 Then
            Throw New System.Exception("Manca il parametro IdEsterno del referto!")
        End If
        '
        ' Esegue la SP
        '
        With sqlcmdExtPrestazioniRimuovi
            .Parameters("@IdEsternoReferto").Value = IdEsternoReferto
            .Parameters("@IdEsterno").Value = IIf(IdEsternoPrestazione.Length > 0, IdEsternoPrestazione, DBNull.Value)

            If Not moSqlTransact Is Nothing Then
                .Transaction = moSqlTransact
            End If

            Dim vScalar As Object = .ExecuteScalar()

            Dim vRet As Object = .Parameters("@RETURN_VALUE").Value
            If (Not vRet Is Nothing) AndAlso (Not IsDBNull(vRet)) AndAlso (CType(vRet, Integer) <> 0) Then
                Throw New System.Exception("Errore durante Exec SP ExtPrestazioniRimuovi(); SQL error: " & vRet.ToString())
            Else
                '
                ' Ritorna boolean
                '
                If (Not vScalar Is Nothing) AndAlso (Not IsDBNull(vScalar)) Then
                    Return CType(vScalar, Integer) > 0
                Else
                    Throw New System.Exception("Errore durante Exec SP ExtPrestazioniRimuovi(); Referto non trovato!")
                End If
            End If
        End With

    End Function

    Public Function RefertiAddNew(ByVal IdEsternoReferto As String, _
                          ByVal IdPaziente As Guid, _
                          ByVal AziendaErogante As String, _
                          ByVal SistemaErogante As String, _
                          ByVal RepartoErogante As String, _
                          ByVal SezioneErogante As String, _
                          ByVal SpecialitaErogante As String, _
                          ByVal DataReferto As Date, _
                          ByVal NumeroReferto As String, _
                          ByVal NumeroPrenotazione As String, _
                          ByVal NumeroNosologico As String, _
                          ByVal PrioritaCodice As String, _
                          ByVal PrioritaDescrizione As String, _
                          ByVal StatoRichiestaCodice As String, _
                          ByVal StatoRichiestaDescrizione As String, _
                          ByVal TipoRichiestaCodice As String, _
                          ByVal TipoRichiestaDescrizione As String, _
                          ByVal RepartoRichiedenteCodice As String, _
                          ByVal RepartoRichiedenteDescrizione As String, _
                          ByVal MedicoRefertanteCodice As String, _
                          ByVal MedicoRefertanteDescrizione As String, _
                          ByVal XmlAttributi As String) As Boolean
        '
        ' Verifiche dei parametri
        '
        If String.IsNullOrEmpty(IdEsternoReferto) Then
            Throw New System.Exception("Manca il parametro IdEsterno del referto!")
        End If
        'Non verifico se IdPaziente = Nothing poichè posso passare l'Id nullo
        'If IdPaziente = Nothing Then
        '    Throw New System.Exception("Manca il parametro IdPaziente del referto!")
        'End If
        '
        ' Inserisco il referto
        '
        With sqlcmdExtRefertiAggiungi3
            .Parameters("@IdEsterno").Value = IdEsternoReferto
            .Parameters("@IdPaziente").Value = IdPaziente
            .Parameters("@AziendaErogante").Value = AziendaErogante
            .Parameters("@SistemaErogante").Value = SistemaErogante
            .Parameters("@RepartoErogante").Value = RepartoErogante
            .Parameters("@SezioneErogante").Value = SezioneErogante
            .Parameters("@SpecialitaErogante").Value = SpecialitaErogante
            .Parameters("@DataReferto").Value = SqlUtil.ParseDatetime(DataReferto)
            .Parameters("@NumeroReferto").Value = NumeroReferto
            .Parameters("@NumeroPrenotazione").Value = NumeroPrenotazione
            .Parameters("@NumeroNosologico").Value = NumeroNosologico
            .Parameters("@PrioritaCodice").Value = PrioritaCodice
            .Parameters("@PrioritaDescr").Value = PrioritaDescrizione
            .Parameters("@StatoRichiestaCodice").Value = StatoRichiestaCodice
            .Parameters("@StatoRichiestaDescr").Value = StatoRichiestaDescrizione
            .Parameters("@TipoRichiestaCodice").Value = TipoRichiestaCodice
            .Parameters("@TipoRichiestaDescr").Value = TipoRichiestaDescrizione
            .Parameters("@RepartoRichiedenteCodice").Value = RepartoRichiedenteCodice
            .Parameters("@RepartoRichiedenteDescr").Value = RepartoRichiedenteDescrizione
            .Parameters("@MedicoRefertanteCodice").Value = MedicoRefertanteCodice
            .Parameters("@MedicoRefertanteDescr").Value = MedicoRefertanteDescrizione
            .Parameters("@XmlAttributi").Value = SqlUtil.StringEmptyToDbNull(XmlAttributi)

            If Not moSqlTransact Is Nothing Then
                .Transaction = moSqlTransact
            End If

            Dim vScalar As Object = .ExecuteScalar()

            Dim vRetVal As Object = .Parameters("@RETURN_VALUE").Value
            If (vRetVal Is Nothing) OrElse IsDBNull(vRetVal) OrElse (CType(vRetVal, Integer) <> 0) Then
                Throw New System.Exception("Errore durante Exec SP ExtRefertiAggiungi3(); SQL error: " & vRetVal.ToString())
            Else
                '
                ' Ritorna boolean
                '
                If (Not vScalar Is Nothing) AndAlso (Not IsDBNull(vScalar)) Then
                    Return CType(vScalar, Integer) > 0
                Else
                    Throw New System.Exception("Errore durante Exec SP ExtRefertiAggiungi3()!")
                End If
            End If
        End With

    End Function

    Public Function RefertiUpdate(ByVal IdEsternoReferto As String, _
                            ByVal IdPaziente As Guid, _
                            ByVal AziendaErogante As String, _
                            ByVal SistemaErogante As String, _
                            ByVal RepartoErogante As String, _
                            ByVal SezioneErogante As String, _
                            ByVal SpecialitaErogante As String, _
                            ByVal DataReferto As Date, _
                            ByVal NumeroReferto As String, _
                            ByVal NumeroPrenotazione As String, _
                            ByVal NumeroNosologico As String, _
                            ByVal PrioritaCodice As String, _
                            ByVal PrioritaDescrizione As String, _
                            ByVal StatoRichiestaCodice As String, _
                            ByVal StatoRichiestaDescrizione As String, _
                            ByVal TipoRichiestaCodice As String, _
                            ByVal TipoRichiestaDescrizione As String, _
                            ByVal RepartoRichiedenteCodice As String, _
                            ByVal RepartoRichiedenteDescrizione As String, _
                            ByVal MedicoRefertanteCodice As String, _
                            ByVal MedicoRefertanteDescrizione As String, _
                            ByVal XmlAttributi As String) As Boolean
        '
        ' Verifiche dei parametri
        '
        If String.IsNullOrEmpty(IdEsternoReferto) Then
            Throw New System.Exception("Manca il parametro IdEsterno del referto!")
        End If
        'Non verifico se IdPaziente = Nothing poichè posso passare l'Id nullo
        'If IdPaziente = Nothing Then
        '    Throw New System.Exception("Manca il parametro IdPaziente del referto!")
        'End If
        '
        ' Inserisco il referto
        '
        With sqlcmdExtRefertiModifica3
            .Parameters("@IdEsterno").Value = IdEsternoReferto
            .Parameters("@IdPaziente").Value = IdPaziente
            .Parameters("@AziendaErogante").Value = AziendaErogante
            .Parameters("@SistemaErogante").Value = SistemaErogante
            .Parameters("@RepartoErogante").Value = RepartoErogante
            .Parameters("@SezioneErogante").Value = SezioneErogante
            .Parameters("@SpecialitaErogante").Value = SpecialitaErogante
            .Parameters("@DataReferto").Value = SqlUtil.ParseDatetime(DataReferto)
            .Parameters("@NumeroReferto").Value = NumeroReferto
            .Parameters("@NumeroPrenotazione").Value = NumeroPrenotazione
            .Parameters("@NumeroNosologico").Value = NumeroNosologico
            .Parameters("@PrioritaCodice").Value = PrioritaCodice
            .Parameters("@PrioritaDescr").Value = PrioritaDescrizione
            .Parameters("@StatoRichiestaCodice").Value = StatoRichiestaCodice
            .Parameters("@StatoRichiestaDescr").Value = StatoRichiestaDescrizione
            .Parameters("@TipoRichiestaCodice").Value = TipoRichiestaCodice
            .Parameters("@TipoRichiestaDescr").Value = TipoRichiestaDescrizione
            .Parameters("@RepartoRichiedenteCodice").Value = RepartoRichiedenteCodice
            .Parameters("@RepartoRichiedenteDescr").Value = RepartoRichiedenteDescrizione
            .Parameters("@MedicoRefertanteCodice").Value = MedicoRefertanteCodice
            .Parameters("@MedicoRefertanteDescr").Value = MedicoRefertanteDescrizione
            .Parameters("@XmlAttributi").Value = SqlUtil.StringEmptyToDbNull(XmlAttributi)

            If Not moSqlTransact Is Nothing Then
                .Transaction = moSqlTransact
            End If

            Dim vScalar As Object = .ExecuteScalar()

            Dim vRetVal As Object = .Parameters("@RETURN_VALUE").Value
            If (vRetVal Is Nothing) OrElse IsDBNull(vRetVal) OrElse (CType(vRetVal, Integer) <> 0) Then
                Throw New System.Exception("Errore durante Exec SP ExtRefertiModifica3(); SQL error: " & vRetVal.ToString())
            Else
                '
                ' Ritorna boolean
                '
                If (Not vScalar Is Nothing) AndAlso (Not IsDBNull(vScalar)) Then
                    Return CType(vScalar, Integer) > 0
                Else
                    Throw New System.Exception("Errore durante Exec SP ExtRefertiModifica3()!")
                End If
            End If
        End With

    End Function


    Public Function RefertiDataModificaUpdate(ByVal IdEsternoReferto As String, _
                        ByVal DataModificaEsterno As Date) As Boolean
        '
        ' Verifiche dei parametri
        '
        If IdEsternoReferto IsNot Nothing AndAlso IdEsternoReferto.Length = 0 Then
            Throw New System.Exception("Manca il parametro IdEsterno del referto!")
        End If
        '
        ' Modifico il referto
        '
        With sqlcmdExtRefertiDataModifica
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

    Public Function RefertiContains(ByVal IdEsternoReferto As String) As Date
        '
        ' Verifiche dei parametri
        '
        If IdEsternoReferto IsNot Nothing AndAlso IdEsternoReferto.Length = 0 Then
            Throw New System.Exception("Manca il parametro IdEsterno del referto!")
        End If
        '
        ' Esegue la SP
        '
        With sqlcmdExtRefertiEsiste
            .Parameters("@IdEsterno").Value = IdEsternoReferto

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
                Throw New System.Exception("Errore durante Exec SP ExtRefertiEsiste(); SQL error: " & vRet.ToString())
            End If
        End With

    End Function

    Public Function RefertiRemove(ByVal IdEsternoReferto As String) As Boolean
        '
        ' Verifiche dei parametri
        '
        If IdEsternoReferto IsNot Nothing AndAlso IdEsternoReferto.Length = 0 Then
            Throw New System.Exception("Manca il parametro IdEsterno del referto!")
        End If
        '
        ' Esegue la SP
        '
        With sqlcmdExtRefertiRimuovi
            .Parameters("@IdEsterno").Value = IdEsternoReferto

            If Not moSqlTransact Is Nothing Then
                .Transaction = moSqlTransact
            End If

            Dim vScalar As Object = .ExecuteScalar()

            Dim vRet As Object = .Parameters("@RETURN_VALUE").Value
            If (vRet Is Nothing) OrElse IsDBNull(vRet) OrElse (CType(vRet, Integer) <> 0) Then
                Throw New System.Exception("Errore durante Exec SP ExtRefertiRimuovi(); SQL error: " & vRet.ToString())
            Else
                '
                ' Ritorna boolean
                '
                If (Not vScalar Is Nothing) AndAlso (Not IsDBNull(vScalar)) Then
                    Return CType(vScalar, Integer) > 0
                Else
                    Throw New System.Exception("Errore durante Exec SP ExtRefertiRimuovi(); Paziente non trovato!")
                End If
            End If
        End With

    End Function

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
        ' Esegue la SP
        '
        With sqlcmdExtPazienteAggiungi3
            .Parameters("@IdEsterno").Value = SqlUtil.StringEmptyToDbNull(IdEsternoPaziente)
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
                    Return vScalar.ToString 'è l'IdEsterno del paziente trovato nel processo di Join
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
                    Return vScalar.ToString 'contiene l'IdEsterno del paziente trovato durante il processo di join
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




    Public Function RefertiAfterProcess(ByVal IdEsternoReferto As String, ByVal Operazione As ConnectorV2.TipoMessaggio, ByVal ImportazioneStorica As Boolean) As Boolean
        '
        ' Verifiche dei parametri
        '
        If IdEsternoReferto IsNot Nothing AndAlso IdEsternoReferto.Length = 0 Then
            Throw New System.Exception("Manca il parametro IdEsterno del referto!")
        End If

        '
        ' Chiamo la stored procedure
        '
        With sqlcmdExtRefertiAfterProcess
            .Parameters("@IdEsterno").Value = IdEsternoReferto
            .Parameters("@Operazione").Value = Operazione
            .Parameters("@ImportazioneStorica").Value = ImportazioneStorica

            If Not moSqlTransact Is Nothing Then
                .Transaction = moSqlTransact
            End If

            Dim vScalar As Object = .ExecuteScalar()

            Dim vRetVal As Object = .Parameters("@RETURN_VALUE").Value
            If (vRetVal Is Nothing) OrElse IsDBNull(vRetVal) OrElse (CType(vRetVal, Integer) <> 0) Then
                Throw New System.Exception("Errore durante Exec SP ExtRefertiAfterProcess(); SQL error: " & vRetVal.ToString())
            Else
                '
                ' Ritorna boolean
                '
                If (Not vScalar Is Nothing) AndAlso (Not IsDBNull(vScalar)) Then
                    Return CType(vScalar, Integer) > 0
                Else
                    Throw New System.Exception("Errore durante Exec SP ExtRefertiAfterProcess()!")
                End If
            End If
        End With

    End Function

    Public Function RefertiBeforeProcess(ByVal IdEsternoReferto As String, ByVal Operazione As ConnectorV2.TipoMessaggio, ByVal ImportazioneStorica As Boolean) As Boolean
        '
        ' Verifiche dei parametri
        '
        If IdEsternoReferto IsNot Nothing AndAlso IdEsternoReferto.Length = 0 Then
            Throw New System.Exception("Manca il parametro IdEsterno del referto!")
        End If
        '
        ' Chiamo la stored procedure
        '
        With sqlcmdExtRefertiBeforeProcess
            .Parameters("@IdEsterno").Value = IdEsternoReferto
            .Parameters("@Operazione").Value = Operazione
            .Parameters("@ImportazioneStorica").Value = ImportazioneStorica

            If Not moSqlTransact Is Nothing Then
                .Transaction = moSqlTransact
            End If

            Dim vScalar As Object = .ExecuteScalar()

            Dim vRetVal As Object = .Parameters("@RETURN_VALUE").Value
            If (vRetVal Is Nothing) OrElse IsDBNull(vRetVal) OrElse (CType(vRetVal, Integer) <> 0) Then
                Throw New System.Exception("Errore durante Exec SP ExtRefertiBeforeProcess(); SQL error: " & vRetVal.ToString())
            Else
                '
                ' Ritorna boolean
                '
                If (Not vScalar Is Nothing) AndAlso (Not IsDBNull(vScalar)) Then
                    Return CType(vScalar, Integer) > 0
                Else
                    Throw New System.Exception("Errore durante Exec SP ExtRefertiBeforeProcess()!")
                End If
            End If
        End With

    End Function


    Public Function RefertiRiferimentiAggiungi(ByVal IdEsternoReferto As String, ByVal IdEsternoRefertoPrecedente As String, ByVal DataSequenza As DateTime) As Boolean
        '
        ' Verifiche dei parametri
        '
        If String.IsNullOrEmpty(IdEsternoReferto) Then
            Throw New System.Exception("Manca il parametro IdEsternoReferto!")
        End If
        If DataSequenza = Nothing Then
            Throw New System.Exception("Manca il parametro DataSequenza!")
        End If
        Dim bRetVal As Boolean = True
        '
        ' Se è valorizzato IdEsternoRefertoVecchio...
        '
        If Not String.IsNullOrEmpty(IdEsternoRefertoPrecedente) Then
            '
            ' ...chiamo la stored procedure
            '
            With sqlcmdRefertiRiferimentiAggiungi
                .Parameters("@IdEsterno").Value = IdEsternoReferto
                .Parameters("@IdEsternoPrecedente").Value = IdEsternoRefertoPrecedente
                .Parameters("@DataModificaEsterno").Value = DataSequenza
                '
                ' Il metodo che usa questa funzione non dovrebbe usare la transazione...
                '
                If Not moSqlTransact Is Nothing Then
                    .Transaction = moSqlTransact
                End If

                Dim vScalar As Object = .ExecuteScalar()

                Dim vRetVal As Object = .Parameters("@RETURN_VALUE").Value
                If (vRetVal Is Nothing) OrElse IsDBNull(vRetVal) OrElse (CType(vRetVal, Integer) <> 0) Then
                    Throw New System.Exception("Errore durante Exec SP ExtRefertiRiferimentiAggiungi(); SQL error: " & vRetVal.ToString())
                Else
                    '
                    ' Ritorna boolean
                    '
                    If (Not vScalar Is Nothing) AndAlso (Not IsDBNull(vScalar)) Then
                        bRetVal = CType(vScalar, Integer) > 0
                    Else
                        Throw New System.Exception("Errore durante Exec SP ExtRefertiRiferimentiAggiungi()!")
                    End If
                End If
            End With
        End If
        '
        ' 
        '
        Return bRetVal
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



    Public Function RefertiGetIdPaziente(ByVal IdEsternoReferto As String) As Guid
        '
        ' Verifiche dei parametri
        '
        If IdEsternoReferto IsNot Nothing AndAlso IdEsternoReferto.Length = 0 Then
            Throw New System.Exception("Manca il parametro IdEsterno del referto!")
        End If
        With sqlcmdExtRefertiGetIdPaziente
            .Parameters("@IdEsterno").Value = IdEsternoReferto

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
                    Return CType(vScalar, Guid)
                Else
                    Throw New System.Exception("Errore durante Exec SP ExtRefertiGetIdPaziente(); IdPaziente non trovato!")
                End If
            Else
                Throw New System.Exception("Errore durante Exec SP ExtRefertiGetIdPaziente(); SQL error: " & vRetVal.ToString())
            End If
        End With

    End Function



    Public Function RefertiGeneraAnteprima(ByVal AziendaErogante As String, SistemaErogante As String) As Boolean
        '
        ' Verifiche dei parametri
        '
        If String.IsNullOrEmpty(AziendaErogante) Then
            Throw New System.Exception("Manca il parametro AziendaErogante del referto!")
        End If
        If String.IsNullOrEmpty(SistemaErogante) Then
            Throw New System.Exception("Manca il parametro AziendaErogante del referto!")
        End If

        '
        ' Chiamo la stored procedure
        '
        With SqlCmdExtRefertiGeneraAnteprima
            .Parameters("@AziendaErogante").Value = AziendaErogante
            .Parameters("@SistemaErogante").Value = SistemaErogante

            If Not moSqlTransact Is Nothing Then
                .Transaction = moSqlTransact
            End If

            Dim vScalar As Object = .ExecuteScalar()

            '
            ' Ritorna boolean
            '
            If (Not vScalar Is Nothing) AndAlso (Not IsDBNull(vScalar)) Then
                Return CType(vScalar, Boolean)
            Else
                Return False
            End If

        End With

    End Function




    ''' <summary>
    ''' Usato per la transcodifica dei regimi e priorita
    ''' </summary>
    ''' <remarks></remarks>
    Public Class CodiceDescrizioneType
        Public Codice As String
        Public Descrizione As String

        Public Sub New()
        End Sub

        Public Sub New(ByVal Codice As String, ByVal Descrizione As String)
            Me.Codice = Codice
            Me.Descrizione = Descrizione
        End Sub
    End Class

    Public Function TranscodificaRegimi(ByVal AziendaErogante As String, ByVal SistemaErogante As String, ByVal CodiceEsterno As String) As CodiceDescrizioneType
        Dim oRetCodiceDescrizione As CodiceDescrizioneType = Nothing
        Dim oReader As System.Data.SqlClient.SqlDataReader = Nothing
        Try
            '
            ' Verifiche dei parametri
            '
            If String.IsNullOrEmpty(AziendaErogante) Then
                Throw New System.Exception("Il parametro AziendaErogante è obbligatorio!")
            End If
            If String.IsNullOrEmpty(SistemaErogante) Then
                Throw New System.Exception("Il parametro SistemaErogante è obbligatorio!")
            End If

            '
            ' Chiamo la stored procedure
            '
            With SqlCmdExtTranscodificaRegimi
                .Parameters("@AziendaErogante").Value = AziendaErogante
                .Parameters("@SistemaErogante").Value = SistemaErogante
                .Parameters("@CodiceEsterno").Value = CodiceEsterno

                If Not moSqlTransact Is Nothing Then
                    .Transaction = moSqlTransact
                End If


                oReader = .ExecuteReader()
                If oReader.HasRows() Then
                    If oReader.Read() Then
                        'Leggo la prima riga (al massimo ce ne è una!)
                        oRetCodiceDescrizione = New CodiceDescrizioneType(CType(oReader.Item("Codice"), String), CType(oReader.Item("Descrizione"), String))
                    End If
                End If

            End With
            '
            ' Restituisco codice/descrizione
            '
            Return oRetCodiceDescrizione

        Catch ex As Exception
            Throw New System.Exception("Errore durante Exec SP ExtTranscodificaRegimi()!" & vbCrLf & ex.Message)
        Finally
            If Not oReader Is Nothing Then
                oReader.Close()
            End If
        End Try

    End Function


    Public Function TranscodificaPriorita(ByVal AziendaErogante As String, ByVal SistemaErogante As String, ByVal CodiceEsterno As String) As CodiceDescrizioneType
        Dim oRetCodiceDescrizione As CodiceDescrizioneType = Nothing
        Dim oReader As System.Data.SqlClient.SqlDataReader = Nothing
        Try
            '
            ' Verifiche dei parametri
            '
            If String.IsNullOrEmpty(AziendaErogante) Then
                Throw New System.Exception("Il parametro AziendaErogante è obbligatorio!")
            End If
            If String.IsNullOrEmpty(SistemaErogante) Then
                Throw New System.Exception("Il parametro SistemaErogante è obbligatorio!")
            End If

            '
            ' Chiamo la stored procedure
            '
            With SqlCmdExtTranscodificaPriorita
                .Parameters("@AziendaErogante").Value = AziendaErogante
                .Parameters("@SistemaErogante").Value = SistemaErogante
                .Parameters("@CodiceEsterno").Value = CodiceEsterno

                If Not moSqlTransact Is Nothing Then
                    .Transaction = moSqlTransact
                End If

                oReader = .ExecuteReader()
                If oReader.HasRows() Then
                    If oReader.Read() Then
                        'Leggo la prima riga (al massimo ce ne è una!)
                        oRetCodiceDescrizione = New CodiceDescrizioneType(CType(oReader.Item("Codice"), String), CType(oReader.Item("Descrizione"), String))
                    End If
                End If

            End With
            '
            ' Restituisco codice/descrizione
            '
            Return oRetCodiceDescrizione

        Catch ex As Exception
            Throw New System.Exception("Errore durante Exec SP ExtTranscodificaRegimi()!" & vbCrLf & ex.Message)
        Finally
            If Not oReader Is Nothing Then
                oReader.Close()
            End If
        End Try

    End Function

    '
    ' MODIFICA ETTORE 2019-02-25: nuova funzione pe la lettura della lista delle aziende eroganti
    ' Eseguita fuori dalla transazione 
    '
    Public Function AziendeErogantiLista() As System.Collections.Generic.List(Of String)
        Dim oRet As New System.Collections.Generic.List(Of String)
        Dim oReader As System.Data.SqlClient.SqlDataReader = Nothing
        Try

            '
            ' Chiamo la stored procedure
            '
            With SqlCmdExtAziendeErogantiLista
                If Not moSqlTransact Is Nothing Then
                    .Transaction = moSqlTransact
                End If
                '
                ' Eseguo la SP
                '
                oReader = .ExecuteReader()
                If oReader.HasRows() Then
                    Do While oReader.Read
                        oRet.Add(CType(oReader.Item("AziendaErogante"), String))
                    Loop
                Else
                    Throw New System.Exception("Non sono state trovate Aziende Eroganti nella tabella SistemiEroganti.")
                End If
            End With
            '
            '
            '
            Return oRet
        Catch ex As Exception
            Throw New System.Exception("Errore durante Exec SP AziendeErogantiLista()!" & vbCrLf & ex.Message)
        Finally
            If Not oReader Is Nothing Then
                oReader.Close()
            End If
        End Try

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



    '
    ' MODIFICA ETTORE 2020-03-02: nuova funzione pe la lettura dei sistemi eroganti
    ' Eseguita fuori dalla transazione 
    ' Usata anche per i ricoveri
    '
    Public Function SistemiErogantiLista() As DataTable
        Dim oRet As New DataTable
        Dim oReader As System.Data.SqlClient.SqlDataReader = Nothing
        Try
            '
            ' Chiamo la stored procedure
            '
            With SqlCmdExtSistemiErogantiLista
                If Not moSqlTransact Is Nothing Then
                    .Transaction = moSqlTransact
                End If
                '
                ' Eseguo la SP
                '
                oReader = .ExecuteReader()
                If oReader.HasRows() Then
                    'Carico la datatable
                    oRet.Load(oReader)
                Else
                    Throw New System.Exception("Non sono stati trovati Sistemi Eroganti nella tabella SistemiEroganti.")
                End If
            End With
            '
            '
            '
            Return oRet
        Catch ex As Exception
            Throw New System.Exception("Errore durante Exec SP SistemiErogantiLista()!" & vbCrLf & ex.Message)
        Finally
            If Not oReader Is Nothing Then
                oReader.Close()
            End If
        End Try

    End Function

End Class
