Imports System.Threading

Public Class ConsensiQueriesTransaction
    Inherits ConsensiDataSetTableAdapters.QueriesTableAdapter

    Dim moTransaction As Data.SqlClient.SqlTransaction
    Dim moConnection As Data.SqlClient.SqlConnection

    Public Function ConsensiMsgBaseInsert2(ByVal Utente As String, _
                                           ByVal IdPaziente As Guid, _
                                           ByVal MetodoAssociazione As String, _
                                           ByVal Consenso As Consenso) As Object

        Dim oRetBaseInsert As Object = Me.ConsensiMsgBaseInsert( _
                                Utente _
                              , Consenso.Id _
                              , IdPaziente _
                              , Consenso.Tipo _
                              , Consenso.DataStato _
                              , Consenso.Stato _
                              , Consenso.OperatoreId _
                              , Consenso.OperatoreCognome _
                              , Consenso.OperatoreNome _
                              , Consenso.OperatoreComputer _
                              , Consenso.PazienteProvenienza _
                              , Consenso.PazienteIdProvenienza _
                              , Consenso.PazienteCognome _
                              , Consenso.PazienteNome _
                              , Consenso.PazienteCodiceFiscale _
                              , Consenso.PazienteDataNascita _
                              , Consenso.PazienteComuneNascitaCodice _
                              , Consenso.PazienteNazionalitaCodice _
                              , Consenso.PazienteTesseraSanitaria _
                              , MetodoAssociazione)

        Return oRetBaseInsert

    End Function

    Public Function ConsensiMsgBaseUpdate2(ByVal Utente As String, _
                                           ByVal IdConsenso As Guid, _
                                           ByVal IdPaziente As Guid, _
                                           ByVal MetodoAssociazione As String, _
                                           ByVal Consenso As Consenso) As Object

        Dim oRetBaseUpdate As Object = Me.ConsensiMsgBaseUpdate( _
                                Utente _
                              , IdConsenso _
                              , Consenso.Id _
                              , IdPaziente _
                              , Consenso.Tipo _
                              , Consenso.DataStato _
                              , Consenso.Stato _
                              , Consenso.OperatoreId _
                              , Consenso.OperatoreCognome _
                              , Consenso.OperatoreNome _
                              , Consenso.OperatoreComputer _
                              , Consenso.PazienteProvenienza _
                              , Consenso.PazienteIdProvenienza _
                              , Consenso.PazienteCognome _
                              , Consenso.PazienteNome _
                              , Consenso.PazienteCodiceFiscale _
                              , Consenso.PazienteDataNascita _
                              , Consenso.PazienteComuneNascitaCodice _
                              , Consenso.PazienteNazionalitaCodice _
                              , Consenso.PazienteTesseraSanitaria _
                              , MetodoAssociazione)

        Return oRetBaseUpdate

    End Function

    Public Function ConsensiMsgPazienteInsert2(ByVal Utente As String, _
                                           ByVal DataSequenza As DateTime, _
                                           ByVal Paziente As Paziente) As Object

        Dim oRetBaseInsert As Object = Me.ConsensiMsgPazienteInsert( _
                                Utente _
                              , Paziente.Provenienza _
                              , Paziente.Id _
                              , DataSequenza _
                              , Paziente.Tessera _
                              , Paziente.Cognome _
                              , Paziente.Nome _
                              , Paziente.DataNascita _
                              , Paziente.Sesso _
                              , Paziente.ComuneNascitaCodice _
                              , Paziente.NazionalitaCodice _
                              , Paziente.CodiceFiscale _
                              , Paziente.DatiAnamnestici _
                              , Paziente.MantenimentoPediatra _
                              , Paziente.CapoFamiglia _
                              , Paziente.Indigenza _
                              , Paziente.CodiceTerminazione _
                              , Paziente.DescrizioneTerminazione _
                              , Paziente.ComuneResCodice _
                              , Paziente.SubComuneRes _
                              , Paziente.IndirizzoRes _
                              , Paziente.LocalitaRes _
                              , Paziente.CapRes _
                              , Paziente.DataDecorrenzaRes _
                              , Paziente.ComuneAslResCodice _
                              , Paziente.CodiceAslRes _
                              , Paziente.RegioneResCodice _
                              , Paziente.ComuneDomCodice _
                              , Paziente.SubComuneDom _
                              , Paziente.IndirizzoDom _
                              , Paziente.LocalitaDom _
                              , Paziente.CapDom _
                              , Paziente.PosizioneAss _
                              , Paziente.RegioneAssCodice _
                              , Paziente.ComuneAslAssCodice _
                              , Paziente.CodiceAslAss _
                              , Paziente.DataInizioAss _
                              , Paziente.DataScadenzaAss _
                              , Paziente.DataTerminazioneAss _
                              , Paziente.DistrettoAmm _
                              , Paziente.DistrettoTer _
                              , Paziente.Ambito _
                              , Paziente.CodiceMedicoDiBase _
                              , Paziente.CodiceFiscaleMedicoDiBase _
                              , Paziente.CognomeNomeMedicoDiBase _
                              , Paziente.DistrettoMedicoDiBase _
                              , Paziente.DataSceltaMedicoDiBase _
                              , Paziente.ComuneRecapitoCodice _
                              , Paziente.IndirizzoRecapito _
                              , Paziente.LocalitaRecapito _
                              , Paziente.Telefono1 _
                              , Paziente.Telefono2 _
                              , Paziente.Telefono3 _
                              , Paziente.CodiceSTP _
                              , Paziente.DataInizioSTP _
                              , Paziente.DataFineSTP _
                              , Paziente.MotivoAnnulloSTP)

        Return oRetBaseInsert

    End Function

    Public Sub OpenConnection(ByVal ConnectionString As String)

        For Each oCommand As IDbCommand In MyBase.CommandCollection
            '
            ' Se necessario creo la connessione
            '
            If moConnection Is Nothing Then
                '
                ' Creo e apro
                '
                moConnection = New SqlClient.SqlConnection(ConnectionString)
                moConnection.Open()
            End If
            '
            ' Setto su tutti i command stessa connesione e transazione
            '
            oCommand.Connection = moConnection
        Next

    End Sub

    Public Sub BeginTransaction(ByVal il As Data.IsolationLevel)
        '
        ' Controllo se la connessione è aperta
        '
        If moConnection.State = ConnectionState.Closed Then
            '
            ' Errore
            '
            Throw New ApplicationException("Errore durante BeginTransaction()!. La connessione al database è chiusa.")
        End If

        For Each oCommand As IDbCommand In MyBase.CommandCollection
            '
            ' Se necessario inizio la transazione
            '
            If moTransaction Is Nothing Then
                moTransaction = moConnection.BeginTransaction(il)
            End If
            '
            ' Setto su tutti i command stessa connesione e transazione
            '
            oCommand.Transaction = moTransaction
        Next

    End Sub

    Public ReadOnly Property Transaction() As Data.SqlClient.SqlTransaction
        Get
            Return moTransaction
        End Get
    End Property

    Public ReadOnly Property Connection() As Data.SqlClient.SqlConnection
        Get
            Return moConnection
        End Get
    End Property

    Public Sub Commit()

        If moTransaction IsNot Nothing Then
            Try
                moTransaction.Commit()
            Finally
                moTransaction.Dispose()
            End Try

            moTransaction = Nothing
        End If

    End Sub

    Public Sub Rollback()

        If moTransaction IsNot Nothing Then
            Try
                moTransaction.Rollback()
            Finally
                moTransaction.Dispose()
            End Try

            moTransaction = Nothing
        End If

    End Sub

    Private Sub QueriesTransaction_Disposed(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Disposed
        '
        ' Chiudo connessione
        '
        If moConnection IsNot Nothing Then
            Try
                If moConnection.State = ConnectionState.Open Then
                    moConnection.Close()
                End If
            Finally
                moConnection.Dispose()
            End Try

            moConnection = Nothing
        End If

    End Sub

End Class

<Serializable()>
Public Class Consensi
    Public Enum MessaggioTipo
        Insert = 0
    End Enum

    Private Enum TipoRicercaPaziente
        ByIdProvenienzaPaziente
        ByCodiceFiscalePaziente
    End Enum

    Public Function ProcessaMessaggioAggiungi(ByVal Messaggio As MessaggioConsenso) As RispostaConsenso
        Return ProcessaMessaggio(MessaggioTipo.Insert, Messaggio)
    End Function

    Public Function ProcessaMessaggio(ByVal Tipo As MessaggioTipo,
                                      ByVal Messaggio As MessaggioConsenso) As RispostaConsenso

        Dim tipoRicercaPaziente As Nullable(Of TipoRicercaPaziente)

        '
        ' Verifico parametri
        '
        If String.IsNullOrEmpty(Messaggio.Utente) Then
            '
            ' Esce con eccezione
            '
            Throw New ArgumentNullException("Consenso.Utente", "Il campo Consenso.Utente è vuoto!")
        End If

        '
        ' Verifico i parametri di ricerca del paziente
        '
        If (String.IsNullOrEmpty(Messaggio.Consenso.PazienteProvenienza) OrElse String.IsNullOrEmpty(Messaggio.Consenso.PazienteIdProvenienza)) AndAlso
            String.IsNullOrEmpty(Messaggio.Consenso.PazienteCodiceFiscale) Then
            '
            ' Esce con eccezione
            '
            Throw New ArgumentNullException("", "Dati paziente mancanti!")
        End If

        '
        ' Verifico la validità dell'IdProvenienza del paziente
        '
        If Not String.IsNullOrEmpty(Messaggio.Consenso.PazienteIdProvenienza) AndAlso
            String.Compare(Guid.Empty.ToString(), Messaggio.Consenso.PazienteIdProvenienza, True) = 0 Then
            '
            ' Esce con eccezione
            '
            Throw New ArgumentNullException("Consenso.PazienteIdProvenienza", "PazienteIdProvenienza paziente non valido!")
        End If

        Dim taQuery As ConsensiQueriesTransaction = Nothing
        Dim drProprieta As ConsensiDataSet.ConsensoProprietaRow
        Dim oRetPazienteId As Object = Nothing

        '
        ' Se vuoto creo l'Id (IdProvenienza-->Id)
        '
        If String.IsNullOrEmpty(Messaggio.Consenso.Id) Then
            Messaggio.Consenso.Id = Guid.NewGuid().ToString()
        End If
        '
        ' Se PazienteDataNascita è DateTime.MinValue
        '
        If Messaggio.Consenso.PazienteDataNascita.Equals(DateTime.MinValue) Then
            Messaggio.Consenso.PazienteDataNascita = Nothing
        End If

        Try
            ' QueriesTableAdapter con transazioni
            taQuery = New ConsensiQueriesTransaction()
            taQuery.OpenConnection(ConfigSingleton.ConnectionString)
            taQuery.BeginTransaction(ConfigSingleton.DatabaseIsolationLevel)

            ' Cerco il paziente
            If Not String.IsNullOrEmpty(Messaggio.Consenso.PazienteProvenienza) AndAlso
                Not String.IsNullOrEmpty(Messaggio.Consenso.PazienteIdProvenienza) Then

                ' By Provenienza/IdProvenienza
                tipoRicercaPaziente = Consensi.TipoRicercaPaziente.ByIdProvenienzaPaziente
                oRetPazienteId = taQuery.ConsensiMsgCercaByIdProvenienzaPaziente(Messaggio.Consenso.PazienteProvenienza,
                                                                                 Messaggio.Consenso.PazienteIdProvenienza,
                                                                                 Messaggio.Utente)

            ElseIf Not String.IsNullOrEmpty(Messaggio.Consenso.PazienteCodiceFiscale) Then

                ' By CodiceFiscale
                tipoRicercaPaziente = Consensi.TipoRicercaPaziente.ByCodiceFiscalePaziente
                oRetPazienteId = taQuery.ConsensiMsgCercaByCodiceFiscalePaziente(Messaggio.Consenso.PazienteCodiceFiscale,
                                                                                 Messaggio.Utente)
            End If

            ' Se non trovo il paziente lo creo
            If oRetPazienteId Is Nothing Then
                Dim paziente As New Paziente()
                With paziente
                    .Provenienza = Messaggio.Consenso.PazienteProvenienza
                    .Id = Messaggio.Consenso.PazienteIdProvenienza
                    .Cognome = Messaggio.Consenso.PazienteCognome
                    .Nome = Messaggio.Consenso.PazienteNome
                    .CodiceFiscale = Messaggio.Consenso.PazienteCodiceFiscale
                    .DataNascita = Messaggio.Consenso.PazienteDataNascita
                    .ComuneNascitaCodice = Messaggio.Consenso.PazienteComuneNascitaCodice
                    .NazionalitaCodice = Messaggio.Consenso.PazienteNazionalitaCodice
                    .Tessera = Messaggio.Consenso.PazienteTesseraSanitaria
                End With
                '
                ' Modifica Ettore 2014-03-21: normalizzazione dei codici ISTAT
                '
                Call Istat.NormalizzazioneCodiciIstat(paziente)
                '
                ' Instanzio la classe Istat
                '
                Dim oIstat As New Istat(Messaggio.Utente, paziente, ConfigSingleton.ConnectionString)
                '
                ' MODIFICA ETTORE 2014-03-21: Fuori dalla transazione verifico coerenza Istat; se trovata incoerenza viene generata eccezione "IncoerenzaIstatException"
                '
                Dim iIstatErrorCode As Integer = oIstat.VerificaCodiciIstat()
                If iIstatErrorCode <> 0 Then
                    If iIstatErrorCode <> 0 Then
                        '
                        ' Loggo l'incoerenza Istat nel database
                        '
                        oIstat.IncoerenzaIstatInsert("Msg-Consensi")
                        '
                        ' Genero eccezione
                        '
                        Dim sIstatErrorMsg As String = oIstat.BuildIstatErrorMessage() & vbCrLf & "Durante l'inserimento dell'anagrafica."
                        Throw New IncoerenzaIstatException(sIstatErrorMsg)
                    End If
                End If


                ' Inserisco il paziente
                Dim oRetBaseInsert As Object = taQuery.ConsensiMsgPazienteInsert2(Messaggio.Utente, Messaggio.DataSequenza, paziente)

                ' Leggo il paziente inserito
                If tipoRicercaPaziente = Consensi.TipoRicercaPaziente.ByIdProvenienzaPaziente Then

                    oRetPazienteId = taQuery.ConsensiMsgCercaByIdProvenienzaPaziente(Messaggio.Consenso.PazienteProvenienza,
                                                                                     Messaggio.Consenso.PazienteIdProvenienza,
                                                                                     Messaggio.Utente)

                ElseIf tipoRicercaPaziente = Consensi.TipoRicercaPaziente.ByCodiceFiscalePaziente Then

                    oRetPazienteId = taQuery.ConsensiMsgCercaByCodiceFiscalePaziente(Messaggio.Consenso.PazienteCodiceFiscale, Messaggio.Utente)
                End If

            End If

            ' Se non trovo il paziente associo il consenso al paziente anonimo (ID = 00000000-0000-0000-0000-000000000000)
            If oRetPazienteId Is Nothing Then
                oRetPazienteId = Guid.Empty
            End If

            ' Carico proprietà del consenso
            drProprieta = GetConsensiProprieta(taQuery.Connection, taQuery.Transaction, Messaggio.Utente, Messaggio.Consenso.Id)

            If drProprieta Is Nothing Then

                ' Aggiungo il consenso
                Dim oRetBaseInsert As Object = taQuery.ConsensiMsgBaseInsert2(Messaggio.Utente,
                                                                              CType(oRetPazienteId, Guid),
                                                                              String.Concat("Msg.", tipoRicercaPaziente.ToString()),
                                                                              Messaggio.Consenso)
                ' Controllo risultato della query
                If oRetBaseInsert Is Nothing OrElse CType(oRetBaseInsert, Integer) = 0 Then
                    Throw New DatiRowCountZeroException("consenso (insert)")
                End If

            Else

                ' Aggiorno il consenso
                Dim oRetBaseUpdate As Object = taQuery.ConsensiMsgBaseUpdate2(Messaggio.Utente,
                                                                              drProprieta.Id,
                                                                              CType(oRetPazienteId, Guid),
                                                                              String.Concat("Msg.", tipoRicercaPaziente.ToString()),
                                                                              Messaggio.Consenso)
                ' Controllo risultato della query
                If oRetBaseUpdate Is Nothing OrElse CType(oRetBaseUpdate, Integer) = 0 Then
                    Throw New DatiRowCountZeroException("consenso (update)")
                End If
            End If

            ' Commit dei dati
            taQuery.Commit()

            'Se il metodo è chiamato dalla WCF non restituisco la risposta
            Return Nothing


        Catch ex As IncoerenzaIstatException
            If taQuery IsNot Nothing Then
                taQuery.Rollback()
            End If

            Dim sErrMsg As String = String.Concat("Errore incoerenza istat durante Consensi.ProcessaMessaggio(). Utente=", Messaggio.Utente, "; IdProvenienza=", Messaggio.Consenso.PazienteIdProvenienza)

            ' Restituisce errore all'orchestrazione
            Throw New ApplicationException(String.Concat(sErrMsg, vbCrLf, ex.Message), ex)

        Catch ex As Data.SqlClient.SqlException
            Dim sErrMsg As String = String.Concat("Errore SqlClient durante Consensi.ProcessaMessaggio(). Utente=", Messaggio.Utente, "; IdProvenienza=", Messaggio.Consenso.PazienteIdProvenienza)
            '
            ' Rollback dei dati
            '
            If taQuery IsNot Nothing Then
                taQuery.Rollback()
            End If
            '
            ' Ritorna errore
            '
            Throw New ApplicationException(String.Concat(sErrMsg, vbCrLf, ex.Message), ex)

        Catch ex As DataAccessException

            Dim sErrMsg As String = String.Concat("Errore DataAccess durante Consensi.ProcessaMessaggio(). Utente=", Messaggio.Utente, "; IdProvenienza=", Messaggio.Consenso.PazienteIdProvenienza)
            '
            ' Rollback dei dati
            '
            If taQuery IsNot Nothing Then
                taQuery.Rollback()
            End If
            '
            ' Ritorna errore
            '
            Throw New ApplicationException(String.Concat(sErrMsg, vbCrLf, ex.Message), ex)

        Catch ex As Exception

            Dim sErrMsg As String = String.Concat("Errore generico durante Consensi.ProcessaMessaggio(). Utente=", Messaggio.Utente, "; IdProvenienza=", Messaggio.Consenso.PazienteIdProvenienza)
            '
            ' Rollback dei dati
            '
            If taQuery IsNot Nothing Then
                taQuery.Rollback()
            End If
            '
            ' Ritorna Exception
            '
            Throw New ApplicationException(String.Concat(sErrMsg, vbCrLf, ex.Message), ex)

        Finally
            '
            ' Rilascio
            '
            If taQuery IsNot Nothing Then
                taQuery.Dispose()
            End If

        End Try

    End Function


    Private Function GetConsensiProprieta(ByVal CurrConnection As Data.SqlClient.SqlConnection,
                                          ByVal CurrTransaction As Data.SqlClient.SqlTransaction,
                                          ByVal Utente As String, ByVal IdProvenienza As String) As ConsensiDataSet.ConsensoProprietaRow

        'dtBase.Columns("Id").DataType = System.Type.GetType("System.String")

        Dim dtProprieta As ConsensiDataSet.ConsensoProprietaDataTable
        Dim drProprieta As ConsensiDataSet.ConsensoProprietaRow = Nothing
        '
        ' Creo TableAdapters
        '
        Using taProprieta As New ConsensiDataSetTableAdapters.ConsensoProprietaTableAdapter()
            taProprieta.Connection = CurrConnection
            taProprieta.Transaction = CurrTransaction

            '
            ' Legge nuovo ID se non c'è la riga (addnew)
            '
            If drProprieta Is Nothing Then
                dtProprieta = taProprieta.GetData(Utente, IdProvenienza)
                If dtProprieta.Count = 1 Then
                    drProprieta = dtProprieta.Item(0)

                ElseIf dtProprieta.Count > 1 Then

                    Dim sMsg As String = String.Format("E' stato trovato più di un consenso attivo! Utente={0}, IdProvenienza={1}.",
                                                       Utente, IdProvenienza)
                    Throw New DatiInconsistentiException("consensi", sMsg)
                End If
            End If
            '
            ' Ritorna il paziente
            '
            Return drProprieta

        End Using

    End Function


    Private Sub WriteTrace(ByVal message As String)
        System.Diagnostics.Debug.WriteLine(String.Concat("[Sac.Msg.DataAccess] - ", message))
        System.Diagnostics.Trace.WriteLine(String.Concat("[Sac.Msg.DataAccess] - ", message))
    End Sub



End Class