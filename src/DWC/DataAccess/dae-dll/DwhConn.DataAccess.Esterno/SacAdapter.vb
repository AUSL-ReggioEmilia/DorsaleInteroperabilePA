Friend Class SacAdapter
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
        sqlcnnSAC.ConnectionString = ""

    End Sub

    Public Sub ConnectionOpen(ByVal ConnectionString As String)
        '
        ' Apro connessione
        '
        sqlcnnSAC.ConnectionString = ConnectionString
        sqlcnnSAC.Open()

    End Sub

    'Component overrides dispose to clean up the component list.
    Protected Overloads Overrides Sub Dispose(ByVal disposing As Boolean)
        If disposing Then
            '
            ' Chiude connessione se aperta
            '
            With sqlcnnSAC
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
    Friend WithEvents sqlcmdPazientiOutputCercaFuzzyOrAggiunge As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdTranscodificaUnitaOperativaDaSistemaACentrale As System.Data.SqlClient.SqlCommand
    Friend WithEvents sqlcmdPazientiOutputCercaAggancioPaziente As System.Data.SqlClient.SqlCommand

    'NOTE: The following procedure is required by the Component Designer
    'It can be modified using the Component Designer.
    'Do not modify it using the code editor.
    Friend WithEvents sqlcnnSAC As System.Data.SqlClient.SqlConnection
    <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()
        Me.sqlcnnSAC = New System.Data.SqlClient.SqlConnection()
        Me.sqlcmdPazientiOutputCercaFuzzyOrAggiunge = New System.Data.SqlClient.SqlCommand()
        Me.sqlcmdTranscodificaUnitaOperativaDaSistemaACentrale = New System.Data.SqlClient.SqlCommand()
        Me.sqlcmdPazientiOutputCercaAggancioPaziente = New System.Data.SqlClient.SqlCommand()
        '
        'sqlcnnSAC
        '
        Me.sqlcnnSAC.ConnectionString = "Data Source=CORUSCANT;Initial Catalog=Asmn_SAC;Integrated Security=True"
        Me.sqlcnnSAC.FireInfoMessageEventOnUserErrors = False
        '
        'sqlcmdPazientiOutputCercaFuzzyOrAggiunge
        '
        Me.sqlcmdPazientiOutputCercaFuzzyOrAggiunge.CommandText = "dbo.[PazientiOutputCercaFuzzyOrAggiunge]"
        Me.sqlcmdPazientiOutputCercaFuzzyOrAggiunge.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdPazientiOutputCercaFuzzyOrAggiunge.Connection = Me.sqlcnnSAC
        Me.sqlcmdPazientiOutputCercaFuzzyOrAggiunge.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@ProvenienzaDiRicerca", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@IdProvenienzaDiRicerca", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@IdProvenienzaDiInserimento", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@Tessera", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@Cognome", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@Nome", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@DataNascita", System.Data.SqlDbType.DateTime, 8), New System.Data.SqlClient.SqlParameter("@Sesso", System.Data.SqlDbType.VarChar, 1), New System.Data.SqlClient.SqlParameter("@ComuneNascitaCodice", System.Data.SqlDbType.VarChar, 6), New System.Data.SqlClient.SqlParameter("@NazionalitaCodice", System.Data.SqlDbType.VarChar, 3), New System.Data.SqlClient.SqlParameter("@CodiceFiscale", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@ComuneResCodice", System.Data.SqlDbType.VarChar, 6), New System.Data.SqlClient.SqlParameter("@SubComuneRes", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@IndirizzoRes", System.Data.SqlDbType.VarChar, 256), New System.Data.SqlClient.SqlParameter("@LocalitaRes", System.Data.SqlDbType.VarChar, 128), New System.Data.SqlClient.SqlParameter("@CapRes", System.Data.SqlDbType.VarChar, 8), New System.Data.SqlClient.SqlParameter("@ComuneDomCodice", System.Data.SqlDbType.VarChar, 6), New System.Data.SqlClient.SqlParameter("@SubComuneDom", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@IndirizzoDom", System.Data.SqlDbType.VarChar, 256), New System.Data.SqlClient.SqlParameter("@LocalitaDom", System.Data.SqlDbType.VarChar, 128), New System.Data.SqlClient.SqlParameter("@CapDom", System.Data.SqlDbType.VarChar, 8), New System.Data.SqlClient.SqlParameter("@IndirizzoRecapito", System.Data.SqlDbType.VarChar, 256), New System.Data.SqlClient.SqlParameter("@LocalitaRecapito", System.Data.SqlDbType.VarChar, 128), New System.Data.SqlClient.SqlParameter("@Telefono1", System.Data.SqlDbType.VarChar, 20), New System.Data.SqlClient.SqlParameter("@Telefono2", System.Data.SqlDbType.VarChar, 20), New System.Data.SqlClient.SqlParameter("@Telefono3", System.Data.SqlDbType.VarChar, 20)})
        '
        'sqlcmdTranscodificaUnitaOperativaDaSistemaACentrale
        '
        Me.sqlcmdTranscodificaUnitaOperativaDaSistemaACentrale.CommandText = "organigramma_da.TranscodificaUnitaOperativaDaSistemaACentrale"
        Me.sqlcmdTranscodificaUnitaOperativaDaSistemaACentrale.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdTranscodificaUnitaOperativaDaSistemaACentrale.Connection = Me.sqlcnnSAC
        Me.sqlcmdTranscodificaUnitaOperativaDaSistemaACentrale.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@SistemaAzienda", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@SistemaCodice", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@UnitaOperativaAzienda", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@UnitaOperativaCodice", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@UnitaOperativaDescrizione", System.Data.SqlDbType.VarChar, 128), New System.Data.SqlClient.SqlParameter("@UoTransAzienda", System.Data.SqlDbType.VarChar, 16, System.Data.ParameterDirection.Output, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@UoTransCodice", System.Data.SqlDbType.VarChar, 16, System.Data.ParameterDirection.Output, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@UoTransDescrizione", System.Data.SqlDbType.VarChar, 128, System.Data.ParameterDirection.Output, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing)})
        '
        'sqlcmdPazientiOutputCercaAggancioPaziente
        '
        Me.sqlcmdPazientiOutputCercaAggancioPaziente.CommandText = "dbo.PazientiOutputCercaAggancioPaziente"
        Me.sqlcmdPazientiOutputCercaAggancioPaziente.CommandType = System.Data.CommandType.StoredProcedure
        Me.sqlcmdPazientiOutputCercaAggancioPaziente.Connection = Me.sqlcnnSAC
        Me.sqlcmdPazientiOutputCercaAggancioPaziente.Parameters.AddRange(New System.Data.SqlClient.SqlParameter() {New System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, False, CType(0, Byte), CType(0, Byte), "", System.Data.DataRowVersion.Current, Nothing), New System.Data.SqlClient.SqlParameter("@ProvenienzaDiRicerca", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@IdProvenienzaDiRicerca", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@IdProvenienzaDiInserimento", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@Tessera", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@Cognome", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@Nome", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@DataNascita", System.Data.SqlDbType.DateTime, 8), New System.Data.SqlClient.SqlParameter("@Sesso", System.Data.SqlDbType.VarChar, 1), New System.Data.SqlClient.SqlParameter("@ComuneNascitaCodice", System.Data.SqlDbType.VarChar, 6), New System.Data.SqlClient.SqlParameter("@NazionalitaCodice", System.Data.SqlDbType.VarChar, 3), New System.Data.SqlClient.SqlParameter("@CodiceFiscale", System.Data.SqlDbType.VarChar, 16), New System.Data.SqlClient.SqlParameter("@ComuneResCodice", System.Data.SqlDbType.VarChar, 6), New System.Data.SqlClient.SqlParameter("@SubComuneRes", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@IndirizzoRes", System.Data.SqlDbType.VarChar, 256), New System.Data.SqlClient.SqlParameter("@LocalitaRes", System.Data.SqlDbType.VarChar, 128), New System.Data.SqlClient.SqlParameter("@CapRes", System.Data.SqlDbType.VarChar, 8), New System.Data.SqlClient.SqlParameter("@ComuneDomCodice", System.Data.SqlDbType.VarChar, 6), New System.Data.SqlClient.SqlParameter("@SubComuneDom", System.Data.SqlDbType.VarChar, 64), New System.Data.SqlClient.SqlParameter("@IndirizzoDom", System.Data.SqlDbType.VarChar, 256), New System.Data.SqlClient.SqlParameter("@LocalitaDom", System.Data.SqlDbType.VarChar, 128), New System.Data.SqlClient.SqlParameter("@CapDom", System.Data.SqlDbType.VarChar, 8), New System.Data.SqlClient.SqlParameter("@IndirizzoRecapito", System.Data.SqlDbType.VarChar, 256), New System.Data.SqlClient.SqlParameter("@LocalitaRecapito", System.Data.SqlDbType.VarChar, 128), New System.Data.SqlClient.SqlParameter("@Telefono1", System.Data.SqlDbType.VarChar, 20), New System.Data.SqlClient.SqlParameter("@Telefono2", System.Data.SqlDbType.VarChar, 20), New System.Data.SqlClient.SqlParameter("@Telefono3", System.Data.SqlDbType.VarChar, 20)})

    End Sub

#End Region

    ''' <summary>
    ''' Questa funzione restituisce sempre l'IdPaziente padre per qualsiasi tipo di match.
    ''' </summary>
    ''' <param name="NomeAnagraficaCentraleDiRicerca"></param>
    ''' <param name="CodiceAnagraficaCentraleDiRicerca"></param>
    ''' <param name="CodiceAnagraficaCentraleDiInserimento"></param>
    ''' <param name="CodiceSanitario"></param>
    ''' <param name="Cognome"></param>
    ''' <param name="Nome"></param>
    ''' <param name="DataNascita"></param>
    ''' <param name="Sesso"></param>
    ''' <param name="CodiceFiscale"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Function PazientiCercaFuzzyOrAggiunge(ByVal NomeAnagraficaCentraleDiRicerca As String, _
                                                 ByVal CodiceAnagraficaCentraleDiRicerca As String, _
                                                 ByVal CodiceAnagraficaCentraleDiInserimento As String, _
                                                 ByVal CodiceSanitario As String, _
                                                 ByVal Cognome As String, _
                                                 ByVal Nome As String, _
                                                 ByVal DataNascita As DateTime, _
                                                 ByVal Sesso As String, _
                                                 ByVal CodiceFiscale As String) As Guid

        Dim IdPaziente As Guid = Nothing
        Dim oReader As System.Data.SqlClient.SqlDataReader = Nothing
        Try
            '
            ' Eseguo il command
            '
            With sqlcmdPazientiOutputCercaFuzzyOrAggiunge
                .Parameters("@ProvenienzaDiRicerca").Value = NomeAnagraficaCentraleDiRicerca
                .Parameters("@IdProvenienzaDiRicerca").Value = CodiceAnagraficaCentraleDiRicerca
                .Parameters("@IdProvenienzaDiInserimento").Value = CodiceAnagraficaCentraleDiInserimento
                .Parameters("@Tessera").Value = CodiceSanitario
                .Parameters("@Cognome").Value = Cognome
                .Parameters("@Nome").Value = Nome
                'Converte '1753-01-01' in DbNull
                .Parameters("@DataNascita").Value = SqlUtil.ParseDatetime(DataNascita)
                .Parameters("@Sesso").Value = Sesso
                .Parameters("@CodiceFiscale").Value = CodiceFiscale
                '
                ' tutti nulli i restanti parametri
                '
                .Parameters("@ComuneNascitaCodice").Value = DBNull.Value
                .Parameters("@NazionalitaCodice").Value = DBNull.Value
                .Parameters("@ComuneResCodice").Value = DBNull.Value
                .Parameters("@SubComuneRes").Value = DBNull.Value
                .Parameters("@IndirizzoRes").Value = DBNull.Value
                .Parameters("@LocalitaRes").Value = DBNull.Value
                .Parameters("@CapRes").Value = DBNull.Value
                .Parameters("@ComuneDomCodice").Value = DBNull.Value
                .Parameters("@SubComuneDom").Value = DBNull.Value
                .Parameters("@IndirizzoDom").Value = DBNull.Value
                .Parameters("@LocalitaDom").Value = DBNull.Value
                .Parameters("@CapDom").Value = DBNull.Value
                .Parameters("@IndirizzoRecapito").Value = DBNull.Value
                .Parameters("@LocalitaRecapito").Value = DBNull.Value
                .Parameters("@Telefono1").Value = DBNull.Value
                .Parameters("@Telefono2").Value = DBNull.Value
                .Parameters("@Telefono3").Value = DBNull.Value
                '
                ' Esequo la query
                '
                oReader = .ExecuteReader()
                If oReader.HasRows() Then
                    If oReader.Read() Then
                        IdPaziente = CType(oReader.Item("Id"), Guid)
                    End If
                End If

            End With
        Catch ex As Exception
            '
            ' Se i parametri non sono corretti per l'inserimento vado avanti 
            ' aggancerò il referto/evento con il guid nothing
            ' Questo è il comportamento della ExtPazientiAggiungi3()
            '
            ' Solo se il messaggio di errore contiene questa stringa raise dell'errore
            '
            If Not ex.Message.ToUpper.Contains("PARAMETRI DI INSERIMENTO NON VALIDI") Then
                Throw ex
            End If
        Finally
            If Not oReader Is Nothing Then
                oReader.Close()
            End If
        End Try
        '
        ' Restituisco l'IdPaziente SAC
        '
        Return IdPaziente

    End Function

    ''' <summary>
    ''' Questa funzione restituisce l'IdPaziente esattamente trovato per [NomeAnagraficaCentraleDiRicerca, CodiceAnagraficaCentraleDiRicerca] a prescindere dal suo stato attivo/fuso; se il match avviene fuzzy restituisce il padre.
    ''' </summary>
    ''' <param name="NomeAnagraficaCentraleDiRicerca"></param>
    ''' <param name="CodiceAnagraficaCentraleDiRicerca"></param>
    ''' <param name="CodiceAnagraficaCentraleDiInserimento"></param>
    ''' <param name="CodiceSanitario"></param>
    ''' <param name="Cognome"></param>
    ''' <param name="Nome"></param>
    ''' <param name="DataNascita"></param>
    ''' <param name="Sesso"></param>
    ''' <param name="CodiceFiscale"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Function PazientiCercaAggancioPaziente(ByVal NomeAnagraficaCentraleDiRicerca As String, _
                                                    ByVal CodiceAnagraficaCentraleDiRicerca As String, _
                                                    ByVal CodiceAnagraficaCentraleDiInserimento As String, _
                                                    ByVal CodiceSanitario As String, _
                                                    ByVal Cognome As String, _
                                                    ByVal Nome As String, _
                                                    ByVal DataNascita As DateTime, _
                                                    ByVal Sesso As String, _
                                                    ByVal CodiceFiscale As String) As Guid

        Dim IdPaziente As Guid = Nothing
        Dim oReader As System.Data.SqlClient.SqlDataReader = Nothing
        Try
            '
            ' Eseguo il command
            '
            With sqlcmdPazientiOutputCercaAggancioPaziente
                .Parameters("@ProvenienzaDiRicerca").Value = NomeAnagraficaCentraleDiRicerca
                .Parameters("@IdProvenienzaDiRicerca").Value = CodiceAnagraficaCentraleDiRicerca
                .Parameters("@IdProvenienzaDiInserimento").Value = CodiceAnagraficaCentraleDiInserimento
                .Parameters("@Tessera").Value = CodiceSanitario
                .Parameters("@Cognome").Value = Cognome
                .Parameters("@Nome").Value = Nome
                'Converte '1753-01-01' in DbNull
                .Parameters("@DataNascita").Value = SqlUtil.ParseDatetime(DataNascita)
                .Parameters("@Sesso").Value = Sesso
                .Parameters("@CodiceFiscale").Value = CodiceFiscale
                '
                ' tutti nulli i restanti parametri
                '
                .Parameters("@ComuneNascitaCodice").Value = DBNull.Value
                .Parameters("@NazionalitaCodice").Value = DBNull.Value
                .Parameters("@ComuneResCodice").Value = DBNull.Value
                .Parameters("@SubComuneRes").Value = DBNull.Value
                .Parameters("@IndirizzoRes").Value = DBNull.Value
                .Parameters("@LocalitaRes").Value = DBNull.Value
                .Parameters("@CapRes").Value = DBNull.Value
                .Parameters("@ComuneDomCodice").Value = DBNull.Value
                .Parameters("@SubComuneDom").Value = DBNull.Value
                .Parameters("@IndirizzoDom").Value = DBNull.Value
                .Parameters("@LocalitaDom").Value = DBNull.Value
                .Parameters("@CapDom").Value = DBNull.Value
                .Parameters("@IndirizzoRecapito").Value = DBNull.Value
                .Parameters("@LocalitaRecapito").Value = DBNull.Value
                .Parameters("@Telefono1").Value = DBNull.Value
                .Parameters("@Telefono2").Value = DBNull.Value
                .Parameters("@Telefono3").Value = DBNull.Value
                '
                ' Esequo la query
                '
                oReader = .ExecuteReader()
                If oReader.HasRows() Then
                    If oReader.Read() Then
                        IdPaziente = CType(oReader.Item("Id"), Guid)
                    End If
                End If

            End With
        Catch ex As Exception
            '
            ' Se i parametri non sono corretti per l'inserimento vado avanti 
            ' aggancerò il referto/evento con il guid nothing
            ' Questo è il comportamento della ExtPazientiAggiungi3()
            '
            ' Solo se il messaggio di errore contiene questa stringa raise dell'errore
            '
            If Not ex.Message.ToUpper.Contains("PARAMETRI DI INSERIMENTO NON VALIDI") Then
                Throw ex
            End If
        Finally
            If Not oReader Is Nothing Then
                oReader.Close()
            End If
        End Try
        '
        ' Restituisco l'IdPaziente SAC
        '
        Return IdPaziente

    End Function




    ''' <summary>
    ''' Il metodo transcodifica i codici UO-ESTERNI in quelli CENTRALI(SAC)
    ''' </summary>
    ''' <param name="SistemaAzienda"></param>
    ''' <param name="SistemaCodice"></param>
    ''' <param name="UnitaOperativaAzienda"></param>
    ''' <param name="UnitaOperativaCodice"></param>
    ''' <param name="UnitaOperativaDescrizione"></param>
    ''' <param name="UoTransAzienda">codice azienda transcodificata</param>
    ''' <param name="UoTransCodice">codice UO transcodificato</param>
    ''' <param name="UoTransDescrizione">descrizione UO transcodificata</param>
    ''' <remarks></remarks>
    Public Sub TranscodificaUnitaOperativaDaSistemaACentrale( _
                                               ByVal SistemaAzienda As String, _
                                               ByVal SistemaCodice As String, _
                                               ByVal UnitaOperativaAzienda As String, _
                                               ByVal UnitaOperativaCodice As String, _
                                               ByVal UnitaOperativaDescrizione As String, _
                                               ByRef UoTransAzienda As String, _
                                               ByRef UoTransCodice As String, _
                                               ByRef UoTransDescrizione As String)

        Try
            '
            ' Eseguo il command
            '
            With sqlcmdTranscodificaUnitaOperativaDaSistemaACentrale
                .Parameters("@SistemaAzienda").Value = SistemaAzienda
                .Parameters("@SistemaCodice").Value = SistemaCodice
                .Parameters("@UnitaOperativaAzienda").Value = UnitaOperativaAzienda
                .Parameters("@UnitaOperativaCodice").Value = UnitaOperativaCodice
                .Parameters("@UnitaOperativaDescrizione").Value = UnitaOperativaDescrizione
                '
                ' Esequo la query
                '
                .ExecuteScalar()
                '
                ' I dati di output si trovano nei parametri di output
                '
                UoTransAzienda = DirectCast(.Parameters("@UoTransAzienda").Value, String)
                UoTransCodice = DirectCast(.Parameters("@UoTransCodice").Value, String)
                UoTransDescrizione = DirectCast(.Parameters("@UoTransDescrizione").Value, String)

            End With
        Catch
            '
            ' Se errore throw dell'eccezione
            '
            Throw
        End Try

    End Sub


End Class
