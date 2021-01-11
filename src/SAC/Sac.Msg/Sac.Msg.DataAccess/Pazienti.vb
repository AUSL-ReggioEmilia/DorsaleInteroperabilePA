Imports System.Threading
Imports System.Data.SqlClient

Public Class QueriesTransaction
    Inherits PazientiDataSetTableAdapters.QueriesTableAdapter

    Dim moTransaction As Data.SqlClient.SqlTransaction
    Dim moConnection As Data.SqlClient.SqlConnection

    Public Function PazientiMsgBaseInsert2(ByVal Utente As String,
                                           ByVal DataSequenza As DateTime,
                                           ByVal Paziente As Paziente) As Object

        Dim oRetBaseInsert As Object = Me.PazientiMsgBaseInsert(
                                Utente _
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
                              , Paziente.MotivoAnnulloSTP _
                              , Paziente.Attributi)

        Return oRetBaseInsert

    End Function

    Public Function PazientiMsgBaseUpdate2(ByVal Utente As String,
                                           ByVal DataSequenza As DateTime,
                                           ByVal Paziente As Paziente) As Object

        Dim oRetBaseUpdate As Object = Me.PazientiMsgBaseUpdate(
                                Utente _
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
                              , Paziente.MotivoAnnulloSTP _
                              , Paziente.Attributi)

        Return oRetBaseUpdate

    End Function

    Public Function PazientiMsgEsenzioniAdd2(ByVal Utente As String, _
                                             ByVal IdProvenienza As String, _
                                             ByVal Esenzione As PazienteEsenzione) As Object

        Dim oRetEsenzioniAdd As Object = Me.PazientiMsgEsenzioniAdd( _
                            Utente, IdProvenienza _
                            , Esenzione.CodiceEsenzione _
                            , Esenzione.CodiceDiagnosi _
                            , Esenzione.Patologica _
                            , Esenzione.DataInizioValidita _
                            , Esenzione.DataFineValidita _
                            , Esenzione.NumeroAutorizzazioneEsenzione _
                            , Esenzione.NoteAggiuntive _
                            , Esenzione.CodiceTestoEsenzione _
                            , Esenzione.TestoEsenzione _
                            , Esenzione.DecodificaEsenzioneDiagnosi _
                            , Esenzione.AttributoEsenzioneDiagnosi)

        Return oRetEsenzioniAdd

    End Function

    Public Function GetPesoPaziente(ByVal proprieta As PazientiDataSet.PazienteProprietaRow) As Integer
        If proprieta Is Nothing Then Return 0

        Dim cognome As String = Nothing
        Dim nome As String = Nothing
        Dim dataNascita As Nullable(Of DateTime) = Nothing
        Dim sesso As String = Nothing
        Dim comuneNascitaCodice As String = Nothing
        Dim tessera As String = Nothing

        If Not proprieta.IsCognomeNull() Then cognome = proprieta.Cognome
        If Not proprieta.IsNomeNull() Then nome = proprieta.Nome
        If Not proprieta.IsDataNascitaNull() Then dataNascita = proprieta.DataNascita
        If Not proprieta.IsSessoNull() Then sesso = proprieta.Sesso
        If Not proprieta.IsComuneNascitaCodiceNull() Then comuneNascitaCodice = proprieta.ComuneNascitaCodice
        If Not proprieta.IsTesseraNull() Then tessera = proprieta.Tessera

        Return CType(Me.PazientiMsgPesoPazienteSelect(cognome, nome, dataNascita, sesso, comuneNascitaCodice, tessera), Integer)
    End Function

    Public Function GetPermessoFusioneByLivelloAttendibilita(ByVal livelloAttendibilita As Byte) As Boolean
        Return CType(Me.PazientiMsgPermessoFusioneByLivelloAttendibilita(livelloAttendibilita), Boolean)
    End Function

    Public Function GetPermessoFusioneByProvenienza(ByVal provenienza As String) As Boolean
        Return CType(Me.PazientiMsgPermessoFusioneByProvenienza(provenienza), Boolean)
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
Public Class Pazienti
    '--------------------------------------------------------------------------
    Public Enum SortOrder As Integer
        Cognome = 1
        Nome = 2
        CodiceFiscale = 4
        Sesso = 5
    End Enum

    Public Enum MessaggioTipo
        Modify = 0
        Delete = 1
        Merge = 2
    End Enum


    ''' <summary>
    ''' Questo il nuovo metodo public invocato dal WCF per ottenere il dettaglio paziente
    ''' </summary>
    ''' <param name="IdPaziente"></param>
    ''' <returns></returns>
    Public Function DettaglioPazienteWcf(ByVal IdPaziente As Guid) As RispostaDettaglioPazienteWCF
        '
        ' Verifico parametri
        '
        If IdPaziente = Guid.Empty Then
            '
            ' Esce con eccezione: il WCF scrive l'errore
            '
            Throw New ArgumentNullException("IdPaziente", "Il campo è vuoto!")
        End If

        Try
            Dim oRisposta As RispostaDettaglioPazienteWCF
            Dim sqlConn As New SqlConnection(ConfigSingleton.ConnectionString)
            Dim oDtPaz As PazientiDataSet.PazienteDettaglioDataTable = Nothing
            oRisposta = CreateDettaglioPazienteWCF(sqlConn, Nothing, IdPaziente, Nothing, oDtPaz)
            '
            ' Modifico gli attributi del paziente per aggiungere i campi di testata del record paziente 
            '
            oRisposta.Paziente.Attributi = CreaAttributiEx(oRisposta.Paziente, oDtPaz).ToXml
            '
            ' Ritorno
            '
            Return oRisposta

        Catch ex As SqlException
            '
            ' Ritorna errore: il WCF scrive nell'event log
            '
            Throw New ApplicationException("Errore SqlClient durante Pazienti.DettaglioPaziente(). " & ex.Message, ex)

        Catch ex As Exception
            '
            ' Ritorna Exception: il WCF scrive nell'event log
            '
            Throw New ApplicationException("Errore generico durante Pazienti.DettaglioPaziente(). " & ex.Message, ex)

        End Try
    End Function


    'MODIFICA ETTORE 2018-07-30: nuova funzione chiamata dalla WCF per ottenere la lista dei pazienti
    Public Function ListaPazientiByGeneralitaWcf(ByVal MaxRecord As Integer,
                                                ByVal SortOrder As SortOrder,
                                                ByVal RestituisciSinonimi As Boolean,
                                                ByVal RestituisciEsenzioni As Boolean,
                                                ByVal RestituisciConsensi As Boolean,
                                                ByVal IdPaziente As Guid?,
                                                ByVal Cognome As String,
                                                ByVal Nome As String,
                                                ByVal DataNascita As DateTime?,
                                                ByVal CodiceFiscale As String,
                                                ByVal Sesso As String) As RispostaListaPazientiWcf

        Try
            '
            ' Verifico parametri
            '
            If Not IdPaziente.HasValue And
            String.IsNullOrEmpty(Cognome) And
            String.IsNullOrEmpty(Nome) And
            Not DataNascita.HasValue And
            String.IsNullOrEmpty(CodiceFiscale) And
            String.IsNullOrEmpty(Sesso) Then
                '
                ' Esce con eccezione
                '
                Throw New ArgumentNullException()
            End If

            Dim oRisposta As RispostaListaPazientiWcf
            Dim sqlConn As New SqlConnection(ConfigSingleton.ConnectionString)


            Dim dtPazienti As PazientiDataSet.PazientiBaseByGeneralita2DataTable = Nothing
            '
            ' Leggo la testata
            '
            Using taPazienti = New PazientiDataSetTableAdapters.PazientiBaseByGeneralita2TableAdapter
                taPazienti.Connection = sqlConn
                taPazienti.Transaction = Nothing
                dtPazienti = taPazienti.GetData(MaxRecord, SortOrder, IdPaziente, Cognome, Nome, DataNascita, CodiceFiscale, Sesso)
            End Using
            '
            ' Calcolo per ogni record tutti i figli e compongo la risposta
            '
            oRisposta = CreateListaPazientiWcf(sqlConn, Nothing, dtPazienti, RestituisciSinonimi, RestituisciEsenzioni, RestituisciConsensi)
            '
            ' Restituisco
            '
            Return oRisposta

        Catch ex As SqlException
            '
            ' Restituisce errore: il WCF lo scrive in event log
            '
            Throw New ApplicationException("Errore SqlClient durante Pazienti.ListaPazientiByGeneralitaWcf(). " & ex.Message, ex)

        Catch ex As Exception
            '
            ' Ritorna Exception
            '
            Throw New ApplicationException("Errore generico durante Pazienti.ListaPazientiByGeneralitaWcf(). " & ex.Message, ex)

        End Try
    End Function

    Private Function CreateListaPazientiWcf(ByVal CurrConnection As SqlConnection,
                                         ByVal CurrTransaction As SqlTransaction,
                                         ByVal dtPazienti As PazientiDataSet.PazientiBaseByGeneralita2DataTable,
                                         ByVal bRestituisciSinonimi As Boolean, ByVal bRestituisciEsenzioni As Boolean,
                                         ByVal bRestituisciConsensi As Boolean) As RispostaListaPazientiWcf

        Dim oPazienti() As PazienteLista = Nothing
        Dim oSinonimi() As PazienteSinonimo = Nothing
        Dim oEsenzioni() As PazienteEsenzioneOut = Nothing
        Dim oConsensi() As PazienteConsensoOut = Nothing

        If dtPazienti.Rows.Count > 0 Then
            '
            ' Creo elemento paziente
            '
            Dim glPazienti As New Generic.List(Of PazienteLista)
            glPazienti.Capacity = dtPazienti.Count
            '
            ' Per ogni riga della data table dei pazienti
            '
            For Each row As PazientiDataSet.PazientiBaseByGeneralita2Row In dtPazienti
                ' Se devo restituire i sinonimi
                If bRestituisciSinonimi Then
                    oSinonimi = GetSinonimi(CurrConnection, CurrTransaction, row.Id, Nothing)
                End If
                If bRestituisciEsenzioni Then
                    oEsenzioni = GetPazienteEsenzioni(CurrConnection, CurrTransaction, row.Id)
                End If
                If bRestituisciConsensi Then
                    oConsensi = GetPazienteConsensi(CurrConnection, CurrTransaction, row.Id)
                End If
                '
                ' Creo il nodo PazienteLista 
                '
                Dim oPazienteLista As PazienteLista = CreatePazienteLista(row, oSinonimi, oEsenzioni, oConsensi)
                '
                ' Lo aggiungo all'array
                '
                glPazienti.Add(oPazienteLista)
            Next
            '
            ' Converto da ArrayList in array tipizzato
            '
            oPazienti = glPazienti.ToArray

        End If

        '
        ' Creo ritorno
        '
        Return New RispostaListaPazientiWcf(oPazienti)

    End Function


    Private Function CreatePazienteLista(ByVal dr As PazientiDataSet.PazientiBaseByGeneralita2Row, oSinonimi() As PazienteSinonimo, oEsenzioni() As PazienteEsenzioneOut, oConsensi() As PazienteConsensoOut) As PazienteLista
        ' Mi assicuro che le stringhe che sono dei GUID siamo formattate maiuscolo
        Dim sIdSac As String = dr.Id.ToString.ToUpper()
        Dim sProvenienza As String = dr.Provenienza
        Dim sIdProvenienza As String = dr.IdProvenienza
        Dim iLivelloAttendibilita As Integer = dr.LivelloAttendibilita

        'Terminazione
        Dim sCodiceTerminazione As String = Nothing
        If Not dr.IsCodiceTerminazioneNull() Then sCodiceTerminazione = dr.CodiceTerminazione

        Dim sDescrizioneTerminazione As String = Nothing
        If Not dr.IsDescrizioneTerminazioneNull() Then sDescrizioneTerminazione = dr.DescrizioneTerminazione

        'Generalità
        Dim sCodiceFiscale As String = Nothing
        If Not dr.IsCodiceFiscaleNull() Then sCodiceFiscale = dr.CodiceFiscale

        Dim sCognome As String = Nothing
        If Not dr.IsCognomeNull() Then sCognome = dr.Cognome

        Dim sNome As String = Nothing
        If Not dr.IsNomeNull() Then sNome = dr.Nome

        Dim oDataNascita As DateTime? = Nothing
        If Not dr.IsDataNascitaNull() Then oDataNascita = dr.DataNascita

        Dim sSesso As String = Nothing
        If Not dr.IsSessoNull() Then sSesso = dr.Sesso

        Dim sTessera As String = Nothing
        If Not dr.IsTesseraNull Then sTessera = dr.Tessera

        Dim sComuneNascitaCodice As String = Nothing
        If Not dr.IsComuneNascitaCodiceNull Then sComuneNascitaCodice = dr.ComuneNascitaCodice

        Dim sComuneNascitaNome As String = Nothing
        If Not dr.IsComuneNascitaNomeNull Then sComuneNascitaNome = dr.ComuneNascitaNome

        Dim sNazionalitaCodice As String = Nothing
        If Not dr.IsNazionalitaCodiceNull Then sNazionalitaCodice = dr.NazionalitaCodice

        Dim sNazionalitaNome As String = Nothing
        If Not dr.IsNazionalitaNomeNull Then sNazionalitaNome = dr.NazionalitaNome

        Dim oDataDecesso As DateTime? = Nothing
        If Not dr.IsDataDecessoNull Then oDataDecesso = dr.DataDecesso

        'Dati di residenza
        Dim sComuneResCodice As String = Nothing
        If Not dr.IsComuneResCodiceNull Then sComuneResCodice = dr.ComuneResCodice

        Dim sComuneResNome As String = Nothing
        If Not dr.IsComuneResNomeNull Then sComuneResNome = dr.ComuneResNome

        Dim sIndirizzoRes As String = Nothing
        If Not dr.IsIndirizzoResNull Then sIndirizzoRes = dr.IndirizzoRes

        Dim sLocalitaRes As String = Nothing
        If Not dr.IsLocalitaResNull Then sLocalitaRes = dr.LocalitaRes

        Dim sCapRes As String = Nothing
        If Not dr.IsCapResNull Then sCapRes = dr.CapRes

        Dim oDataDecorrenzaRes As DateTime?
        If Not dr.IsDataDecorrenzaResNull Then oDataDecorrenzaRes = dr.DataDecorrenzaRes

        'Dati di domicilio
        Dim sComuneDomCodice As String = Nothing
        If Not dr.IsComuneDomCodiceNull Then sComuneDomCodice = dr.ComuneDomCodice

        Dim sComuneDomNome As String = Nothing
        If Not dr.IsComuneDomNomeNull Then sComuneDomNome = dr.ComuneDomNome

        Dim sIndirizzoDom As String = Nothing
        If Not dr.IsIndirizzoDomNull Then sIndirizzoDom = dr.IndirizzoDom

        Dim sLocalitaDom As String = Nothing
        If Not dr.IsLocalitaDomNull Then sLocalitaDom = dr.LocalitaDom

        Dim sCapDom As String = Nothing
        If Not dr.IsCapDomNull Then sCapDom = dr.CapDom

        'Dati di recapito
        Dim sComuneRecapitoCodice As String = Nothing
        If Not dr.IsComuneRecapitoCodiceNull Then sComuneRecapitoCodice = dr.ComuneRecapitoCodice

        Dim sComuneRecapitoNome As String = Nothing
        If Not dr.IsComuneRecapitoNomeNull Then sComuneRecapitoNome = dr.ComuneRecapitoNome

        Dim sIndirizzoRecapito As String = Nothing
        If Not dr.IsIndirizzoRecapitoNull Then sIndirizzoRecapito = dr.IndirizzoRecapito

        Dim sLocalitaRecapito As String = Nothing
        If Not dr.IsLocalitaRecapitoNull Then sLocalitaRecapito = dr.LocalitaRecapito

        Dim sTelefono1 As String = Nothing
        If Not dr.IsTelefono1Null Then sTelefono1 = dr.Telefono1

        Dim sTelefono2 As String = Nothing
        If Not dr.IsTelefono2Null Then sTelefono2 = dr.Telefono2

        Dim sTelefono3 As String = Nothing
        If Not dr.IsTelefono3Null Then sTelefono3 = dr.Telefono3

        'Dati di STP
        Dim sCodiceStp As String = Nothing
        If Not dr.IsCodiceSTPNull Then sCodiceStp = dr.CodiceSTP

        Dim oDataInizioStp As DateTime?
        If Not dr.IsDataInizioSTPNull Then oDataInizioStp = dr.DataInizioSTP

        Dim oDataFineStp As DateTime?
        If Not dr.IsDataFineSTPNull Then oDataFineStp = dr.DataFineSTP

        Dim sMotivoAnnulloStp As String = Nothing
        If Not dr.IsMotivoAnnulloSTPNull Then sMotivoAnnulloStp = dr.MotivoAnnulloSTP

        'Dati Assistito
        Dim iPosizioneAss As Byte? = Nothing
        If Not dr.IsPosizioneAssNull Then iPosizioneAss = dr.PosizioneAss

        Dim oDataInizioAss As DateTime?
        If Not dr.IsDataInizioAssNull Then oDataInizioAss = dr.DataInizioAss

        Dim oDataScadenzaAss As DateTime?
        If Not dr.IsDataScadenzaAssNull Then oDataScadenzaAss = dr.DataScadenzaAss

        Dim oDataTerminazioneAss As DateTime?
        If Not dr.IsDataTerminazioneAssNull Then oDataTerminazioneAss = dr.DataTerminazioneAss

        'Dati USL Residenza
        Dim sCodiceAslRes As String = Nothing
        If Not dr.IsCodiceAslResNull Then sCodiceAslRes = dr.CodiceAslRes

        Dim sRegioneResCodice As String = Nothing
        If Not dr.IsRegioneResCodiceNull Then sRegioneResCodice = dr.RegioneResCodice

        Dim sComuneAslResCodice As String = Nothing
        If Not dr.IsComuneAslResCodiceNull Then sComuneAslResCodice = dr.ComuneAslResCodice

        'Dati USL Assistenza
        Dim sCodiceAslAss As String = Nothing
        If Not dr.IsCodiceAslAssNull Then sCodiceAslAss = dr.CodiceAslAss

        Dim sRegioneAssCodice As String = Nothing
        If Not dr.IsRegioneAssCodiceNull Then sRegioneAssCodice = dr.RegioneAssCodice

        Dim sComuneAslAssCodice As String = Nothing
        If Not dr.IsComuneAslAssCodiceNull Then sComuneAslAssCodice = dr.ComuneAslAssCodice

        'Dati Medico di base
        Dim sCodiceMedicoDiBase As String = Nothing
        If Not dr.IsCodiceMedicoDiBaseNull Then sCodiceMedicoDiBase = dr.CodiceMedicoDiBase.ToString

        Dim sCodiceFiscaleMedicoDiBase As String = Nothing
        If Not dr.IsCodiceFiscaleMedicoDiBaseNull Then sCodiceFiscaleMedicoDiBase = dr.CodiceFiscaleMedicoDiBase

        Dim sCognomeNomeMedicoDiBase As String = Nothing
        If Not dr.IsCognomeNomeMedicoDiBaseNull Then sCognomeNomeMedicoDiBase = dr.CognomeNomeMedicoDiBase

        Dim sDistrettoMedicoDiBase As String = Nothing
        If Not dr.IsDistrettoMedicoDiBaseNull Then sDistrettoMedicoDiBase = dr.DistrettoMedicoDiBase

        Dim oDataSceltaMedicoDiBase As DateTime?
        If Not dr.IsDataSceltaMedicoDiBaseNull Then oDataSceltaMedicoDiBase = dr.DataSceltaMedicoDiBase


        Dim sSubComuneRes As String = Nothing
        If Not dr.IsSubComuneResNull Then sSubComuneRes = dr.SubComuneRes

        Dim sAslResNome As String = Nothing
        If Not dr.IsAslResNomeNull Then sAslResNome = dr.AslResNome

        Dim sRegioneResNome As String = Nothing
        If Not dr.IsRegioneResNomeNull Then sRegioneResNome = dr.RegioneResNome

        Dim sSubComuneDom As String = Nothing
        If Not dr.IsSubComuneDomNull Then sSubComuneDom = dr.SubComuneDom

        Dim sRegioneAssNome As String = Nothing
        If Not dr.IsRegioneAssNomeNull Then sRegioneAssNome = dr.RegioneAssNome

        Dim sAslAssNome As String = Nothing
        If Not dr.IsAslAssNomeNull Then sAslAssNome = dr.AslAssNome

        Dim sDistrettoAmm As String = Nothing
        If Not dr.IsDistrettoAmmNull Then sDistrettoAmm = dr.DistrettoAmm

        Dim sDistrettoTer As String = Nothing
        If Not dr.IsDistrettoTerNull Then sDistrettoTer = dr.DistrettoTer

        Dim sAmbito As String = Nothing
        If Not dr.IsAmbitoNull Then sAmbito = dr.Ambito


        ''MODIFICA ETTORE WCF 2018-07-26: Per passare la striga XML degli attributi
        Dim sAttributi As String = Nothing
        If Not dr.IsAttributiNull Then sAttributi = dr.Attributi
        '
        ' Creo il paziente
        '
        Dim oPaziente As New PazienteLista(sIdSac, sProvenienza, sIdProvenienza, iLivelloAttendibilita,
                                        sCodiceTerminazione, sDescrizioneTerminazione,
                                        sCodiceFiscale, sCognome, sNome, oDataNascita, sSesso, sTessera,
                                        sComuneNascitaCodice, sComuneNascitaNome, sNazionalitaCodice, sNazionalitaNome, oDataDecesso,
                                        sComuneResCodice, sComuneResNome, sIndirizzoRes, sLocalitaRes, sCapRes, oDataDecorrenzaRes,
                                        sComuneDomCodice, sComuneDomNome, sIndirizzoDom, sLocalitaDom, sCapDom,
                                        sComuneRecapitoCodice, sComuneRecapitoNome, sIndirizzoRecapito, sLocalitaRecapito,
                                        sTelefono1, sTelefono2, sTelefono3,
                                        sCodiceStp, oDataInizioStp, oDataFineStp, sMotivoAnnulloStp,
                                        iPosizioneAss, oDataInizioAss, oDataScadenzaAss, oDataTerminazioneAss,
                                        sCodiceAslRes, sRegioneResCodice, sComuneAslResCodice,
                                        sCodiceAslAss, sRegioneAssCodice, sComuneAslAssCodice,
                                        sCodiceMedicoDiBase, sCodiceFiscaleMedicoDiBase, sCognomeNomeMedicoDiBase, sDistrettoMedicoDiBase, oDataSceltaMedicoDiBase,
                                        sSubComuneRes,
                                        sAslResNome,
                                        sRegioneResNome,
                                        sSubComuneDom,
                                        sRegioneAssNome,
                                        sAslAssNome,
                                        sDistrettoAmm,
                                        sDistrettoTer,
                                        sAmbito,
                                        sAttributi,
                                        oSinonimi,
                                        oEsenzioni,
                                        oConsensi)
        '
        '
        '
        Return oPaziente
    End Function



    'Private Class RetUtentiAck
    '    Public Ingresso As IngressoAck
    '    Public Notifiche() As NotificaAck
    'End Class

    'Private Function CreateUtentiAck(ByVal Utente As String) As Pazienti.RetUtentiAck

    '    Try
    '        '
    '        ' Creo TableAdapters
    '        '
    '        Using taUtentiAck = New PazientiDataSetTableAdapters.UtentiAckTableAdapter
    '            taUtentiAck.Connection.ConnectionString = ConfigSingleton.ConnectionString
    '            '
    '            ' Carico dati uteti applicativi per ack 
    '            '
    '            Dim dtUtentiAck As PazientiDataSet.UtentiAckDataTable
    '            dtUtentiAck = taUtentiAck.GetData(Utente)
    '            If dtUtentiAck IsNot Nothing AndAlso dtUtentiAck.Count > 0 Then
    '                '
    '                ' Creo messsaggio di ritorno
    '                '
    '                Dim glNotificheAck As New Generic.List(Of NotificaAck)
    '                Dim drUtentiAck As PazientiDataSet.UtentiAckRow
    '                Dim oUtentiAck As New Pazienti.RetUtentiAck

    '                For Each drUtentiAck In dtUtentiAck
    '                    If drUtentiAck.Utente = Utente And drUtentiAck.IngressoAck Then
    '                        '
    '                        ' Creo nodo per ACK di ingresso
    '                        '
    '                        oUtentiAck.Ingresso = New IngressoAck(drUtentiAck.Utente,
    '                                                                drUtentiAck.IngressoAck,
    '                                                                drUtentiAck.IngressoAckUrl _
    '                                                                , "", "")
    '                    End If

    '                    If drUtentiAck.NotificheAck Then
    '                        '
    '                        ' Creo nodo per ogni utente ACK di uscita
    '                        '
    '                        Dim oNotificheAck = New NotificaAck(drUtentiAck.Utente,
    '                                        drUtentiAck.NotificheAck,
    '                                        drUtentiAck.NotificheUrl _
    '                                        , "", "")

    '                        glNotificheAck.Add(oNotificheAck)
    '                    End If

    '                Next
    '                '
    '                ' Converto da ArrayList in array tipizzato
    '                '
    '                oUtentiAck.Notifiche = glNotificheAck.ToArray
    '                '
    '                ' Ritorna
    '                '
    '                Return oUtentiAck
    '            Else
    '                '
    '                ' Ritorna vuoto
    '                '
    '                Return New RetUtentiAck
    '            End If

    '        End Using

    '    Catch ex As DataAccessException
    '        Throw ex

    '    Catch ex As Exception
    '        Throw New ArgumentException("Errore durante CreateUtentiAck()!", ex)

    '    End Try

    'End Function

    Private Function GetPazientiProprieta(ByVal CurrConnection As Data.SqlClient.SqlConnection,
                                          ByVal CurrTransaction As Data.SqlClient.SqlTransaction,
                                          ByVal Utente As String, ByVal IdProvenienza As String) As PazientiDataSet.PazienteProprietaRow

        Dim dtProprieta As PazientiDataSet.PazienteProprietaDataTable
        Dim drProprieta As PazientiDataSet.PazienteProprietaRow = Nothing
        '
        ' Creo TableAdapters
        '
        Try

            Using taProprieta = New PazientiDataSetTableAdapters.PazienteProprietaTableAdapter
                taProprieta.Connection = CurrConnection
                taProprieta.Transaction = CurrTransaction
                '
                ' Legge nuovo ID se non c'è la riga (addnew)
                '
                If drProprieta Is Nothing Then
                    dtProprieta = taProprieta.GetData(Utente, IdProvenienza)
                    If dtProprieta.Count > 0 Then
                        drProprieta = dtProprieta.Item(0)
                    End If
                End If
                '
                ' Ritorna il paziente
                '
                Return drProprieta

            End Using

        Catch ex As DataAccessException
            Throw ex

        Catch ex As Exception
            Throw New ArgumentException("Errore durante GetPazientiProprieta()!", ex)

        End Try

    End Function


    ''' <summary>
    ''' Questa restituisce sempre i dati del record richiesto a prescrindere dal fatto che sia attivo o fuso
    ''' </summary>
    ''' <param name="CurrConnection"></param>
    ''' <param name="CurrTransaction"></param>
    ''' <param name="Utente"></param>
    ''' <param name="IdProvenienza"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Private Function GetPazientiProprieta3(ByVal CurrConnection As Data.SqlClient.SqlConnection,
                                                          ByVal CurrTransaction As Data.SqlClient.SqlTransaction,
                                                          ByVal Utente As String, ByVal IdProvenienza As String) As PazientiDataSet.PazienteProprietaRow

        Dim dtProprieta As PazientiDataSet.PazienteProprietaDataTable
        Dim drProprieta As PazientiDataSet.PazienteProprietaRow = Nothing

        Try
            '
            ' Creo TableAdapters
            '
            Using taProprieta = New PazientiDataSetTableAdapters.PazienteProprietaTableAdapter
                taProprieta.Connection = CurrConnection
                taProprieta.Transaction = CurrTransaction
                '
                ' Legge la riga
                '
                If drProprieta Is Nothing Then
                    dtProprieta = taProprieta.GetData3(Utente, IdProvenienza)
                    If dtProprieta.Count > 0 Then
                        drProprieta = dtProprieta.Item(0)
                    End If
                End If
                '
                ' Restituisce il record 
                '
                Return drProprieta

            End Using

        Catch ex As DataAccessException
            Throw ex

        Catch ex As Exception
            Throw New ArgumentException("Errore durante GetPazientiProprieta3()!", ex)

        End Try

    End Function


    Private Function GetCandidatoFusioneAutomaticaOttieni(ByVal CurrConnection As Data.SqlClient.SqlConnection,
                                                     ByVal CurrTransaction As Data.SqlClient.SqlTransaction,
                                                     ByVal utente As String,
                                                     ByVal idProvenienza As String,
                                                     ByVal codiceFiscale As String,
                                                     ByVal Cognome As String,
                                                     ByVal Nome As String,
                                                     ByVal LivelloAttendibilita As Byte?) As PazientiDataSet.PazienteProprietaRow

        Dim dtProprieta As PazientiDataSet.PazienteProprietaDataTable
        Dim drProprieta As PazientiDataSet.PazienteProprietaRow = Nothing

        Try
            '
            ' Creo TableAdapters
            '
            Using taProprieta = New PazientiDataSetTableAdapters.PazienteProprietaTableAdapter()
                taProprieta.Connection = CurrConnection
                taProprieta.Transaction = CurrTransaction
                '
                ' Legge la riga
                '
                If drProprieta Is Nothing Then
                    dtProprieta = taProprieta.GetDataCandidatoFusioneAutomatica(utente, idProvenienza, codiceFiscale, Cognome, Nome, LivelloAttendibilita)
                    If dtProprieta.Count > 0 Then
                        drProprieta = dtProprieta.Item(0)
                    End If
                End If
                '
                ' Ritorna il paziente
                '
                Return drProprieta

            End Using

        Catch ex As Exception
            Throw New ArgumentException("Errore durante GetCandidatoFusioneAutomaticaOttieni()!", ex)
        End Try

    End Function


    ''' <summary>
    ''' Usata nel metodo public DettaglioPaziente della vecchia DataAccess
    ''' </summary>
    ''' <param name="CurrConnection"></param>
    ''' <param name="CurrTransaction"></param>
    ''' <param name="IdPaziente"></param>
    ''' <param name="IdPazienteFuso"></param>
    ''' <returns></returns>
    Private Function CreateDettaglioPaziente(ByVal CurrConnection As SqlConnection,
                                             ByVal CurrTransaction As SqlTransaction,
                                             ByVal IdPaziente As Guid, ByVal IdPazienteFuso As Guid?) As RispostaDettaglioPaziente

        Dim sIdAziendale As String = Nothing
        Dim oPaziente As Paziente = Nothing
        Dim oSinonimi() As PazienteSinonimo = Nothing
        Dim oEsenzioni() As PazienteEsenzione = Nothing
        '
        ' Creo TableAdapters
        '
        Using taBase = New PazientiDataSetTableAdapters.PazienteBaseTableAdapter
            taBase.Connection = CurrConnection
            taBase.Transaction = CurrTransaction
            '
            ' Carico dati paziente (Padre)
            '
            Dim dtBase As PazientiDataSet.PazienteBaseDataTable
            dtBase = taBase.GetData(IdPaziente)
            If dtBase IsNot Nothing AndAlso dtBase.Count > 0 Then
                '
                ' Sestemo nomi dei campi per il bind sulla classe
                '
                dtBase.IdColumn.ColumnName = "IdAnagrafica"
                dtBase.IdProvenienzaColumn.ColumnName = "Id"
                '
                ' Prendo la riga
                '
                Dim drBase As PazientiDataSet.PazienteBaseRow = dtBase(0)
                '
                ' Id Aziendale
                ' Modifica Ettore 2013-01-29: mi assicuro una stringa rappresentante un guid sia sempre formattata in maiuscolo
                sIdAziendale = drBase.Id.ToString().ToUpper()
                '
                ' Creo Paziente
                '
                oPaziente = GenericSerialize(Of Paziente).ReadDataRow(drBase, New Paziente)
            Else
                '
                ' Errore non trovato
                '
                Throw New DatiNonTrovatiException("pazienti")
            End If
        End Using

        '
        ' Sinonimi
        '
        Dim glSinonimi As New Generic.List(Of PazienteSinonimo)

        ' Sinonimi con provenienza SAC (il paziente fuso in testa)
        Dim dtSacSinonimi As PazientiDataSet.PazientiSinonimiByIdPazienteDataTable
        Dim rowSacSinonimi As PazientiDataSet.PazientiSinonimiByIdPazienteRow
        dtSacSinonimi = GetSinonimiByIdPaziente(CurrConnection, CurrTransaction, IdPaziente)

        If IdPazienteFuso.HasValue AndAlso Not Guid.Equals(IdPaziente, IdPazienteFuso) Then
            glSinonimi.Add(New PazienteSinonimo("SAC", IdPazienteFuso.ToString().ToUpper()))
        End If

        For Each rowSacSinonimi In dtSacSinonimi
            Dim item As New PazienteSinonimo("SAC", rowSacSinonimi.IdPazienteFuso.ToString().ToUpper())
            If Not glSinonimi.Contains(item) Then
                glSinonimi.Add(item)
            End If
        Next

        ' Sinonimi paziente
        Dim dtSinonimi As PazientiDataSet.PazienteSinominiDataTable
        Dim rowSinonimi As PazientiDataSet.PazienteSinominiRow
        dtSinonimi = GetSinonimi(CurrConnection, CurrTransaction, IdPaziente)

        For Each rowSinonimi In dtSinonimi
            Dim oSinonimo = New PazienteSinonimo(rowSinonimi.Provenienza, rowSinonimi.IdProvenienza)
            glSinonimi.Add(oSinonimo)
        Next

        ' Converto da ArrayList in array tipizzato
        oSinonimi = glSinonimi.ToArray

        Using taEsenzioni = New PazientiDataSetTableAdapters.PazienteEsenzioniTableAdapter
            taEsenzioni.Connection = CurrConnection
            taEsenzioni.Transaction = CurrTransaction

            '
            ' Carico dati esenzioni paziente
            '
            Dim dtEsenzioni As PazientiDataSet.PazienteEsenzioniDataTable
            dtEsenzioni = taEsenzioni.GetData(IdPaziente)
            If dtEsenzioni IsNot Nothing AndAlso dtEsenzioni.Count > 0 Then
                '
                ' Creo elemento esenzioni
                '
                Dim glEsenzioni As New Generic.List(Of PazienteEsenzione)
                glEsenzioni.Capacity = dtEsenzioni.Count

                Dim drEsenzioni As PazientiDataSet.PazienteEsenzioniRow

                For Each drEsenzioni In dtEsenzioni
                    '
                    ' Creo nodo per ogni utente ACK di uscita
                    '
                    Dim oEsenzione As PazienteEsenzione
                    oEsenzione = GenericSerialize(Of PazienteEsenzione).ReadDataRow(drEsenzioni, New PazienteEsenzione)

                    glEsenzioni.Add(oEsenzione)
                Next
                '
                ' Converto da ArrayList in array tipizzato
                '
                oEsenzioni = glEsenzioni.ToArray
            End If
        End Using
        '
        ' Creo ritorno
        '
        Return New RispostaDettaglioPaziente(sIdAziendale, oPaziente, oEsenzioni, oSinonimi)

    End Function

    ''' <summary>
    ''' 
    ''' </summary>
    ''' <param name="CurrConnection"></param>
    ''' <param name="CurrTransaction"></param>
    ''' <param name="IdPaziente"></param>
    ''' <param name="IdPazienteFuso"></param>
    ''' <param name="oDtPaz">Usata per avere tutti i dati di testata all'esterno cosi da popolare iil Nodo Paziente.Attributi con tutti valori che non sono in testata</param>
    ''' <returns></returns>
    Private Function CreateDettaglioPazienteWCF(ByVal CurrConnection As SqlConnection,
                                             ByVal CurrTransaction As SqlTransaction,
                                             ByVal IdPaziente As Guid, ByVal IdPazienteFuso As Guid?, ByRef oDtPaz As PazientiDataSet.PazienteDettaglioDataTable) As RispostaDettaglioPazienteWCF
        Dim oPaziente As PazienteOut = Nothing
        Dim oSinonimi() As PazienteSinonimo = Nothing
        Dim oEsenzioni() As PazienteEsenzioneOut = Nothing
        Dim oConsensi() As PazienteConsensoOut = Nothing

        '
        ' Record paziente: uso la nuova SP che restituisce gli stessi dati di WS2.Pazienti2ById
        '
        Dim oDtPaziente As PazientiDataSet.PazienteDettaglioDataTable = GetPazienteDettaglio(CurrConnection, CurrTransaction, IdPaziente)
        If oDtPaziente Is Nothing OrElse oDtPaziente.Rows.Count = 0 Then
            ' Errore non trovato
            Throw New DatiNonTrovatiException("pazienti")
        End If
        'Passo all'esterno la data table 
        oDtPaz = oDtPaziente

        ' Creo PazienteOut
        oPaziente = oDtPaziente(0).ToPazienteOutput

        '
        ' Sinonimi
        '
        oSinonimi = GetSinonimi(CurrConnection, CurrTransaction, IdPaziente, IdPazienteFuso)
        '
        ' Leggo le Esenzioni
        '
        oEsenzioni = GetPazienteEsenzioni(CurrConnection, CurrTransaction, IdPaziente)
        '
        ' Leggo i consensi
        '
        oConsensi = GetPazienteConsensi(CurrConnection, CurrTransaction, IdPaziente)
        '
        ' Creo ritorno
        '
        Return New RispostaDettaglioPazienteWCF(oPaziente, oEsenzioni, oSinonimi, oConsensi)

    End Function


    Private Function GetPazienteEsenzioni(ByVal CurrConnection As SqlConnection, ByVal CurrTransaction As SqlTransaction, IdPaziente As Guid) As PazienteEsenzioneOut()
        Dim oEsenzioni() As PazienteEsenzioneOut = Nothing
        Using taEsenzioni = New PazientiDataSetTableAdapters.PazienteEsenzioniTableAdapter
            taEsenzioni.Connection = CurrConnection
            taEsenzioni.Transaction = CurrTransaction
            '
            ' Carico dati esenzioni paziente
            '
            Dim dtEsenzioni As PazientiDataSet.PazienteEsenzioniDataTable
            dtEsenzioni = taEsenzioni.GetData(IdPaziente)
            If dtEsenzioni IsNot Nothing AndAlso dtEsenzioni.Count > 0 Then
                '
                ' Creo elemento esenzioni
                '
                Dim glEsenzioni As New Generic.List(Of PazienteEsenzioneOut)
                glEsenzioni.Capacity = dtEsenzioni.Count

                Dim drEsenzioni As PazientiDataSet.PazienteEsenzioniRow
                For Each drEsenzioni In dtEsenzioni
                    '
                    ' Creo nodo per ogni utente ACK di uscita
                    '
                    Dim oEsenzione As PazienteEsenzioneOut = PazienteEsenzioniRowToPazientiEsenzioniOut(drEsenzioni)
                    glEsenzioni.Add(oEsenzione)
                Next
                '
                ' Converto da ArrayList in array tipizzato
                '
                oEsenzioni = glEsenzioni.ToArray
            End If
        End Using
        '
        '
        '
        Return oEsenzioni
    End Function

    Private Function GetPazienteConsensi(ByVal CurrConnection As SqlConnection, ByVal CurrTransaction As SqlTransaction, ByVal IdPaziente As Guid) As PazienteConsensoOut()
        Dim oConsensi As PazienteConsensoOut() = Nothing
        Using taConsensi = New PazientiDataSetTableAdapters.PazienteConsensiTableAdapter
            taConsensi.Connection = CurrConnection
            taConsensi.Transaction = CurrTransaction
            Dim dtConsensi As PazientiDataSet.PazienteConsensiDataTable = taConsensi.GetData(IdPaziente)
            If dtConsensi IsNot Nothing AndAlso dtConsensi.Count > 0 Then
                Dim glConsensi As New Generic.List(Of PazienteConsensoOut)
                glConsensi.Capacity = dtConsensi.Count
                For Each dr As PazientiDataSet.PazienteConsensiRow In dtConsensi
                    Dim oConsenso As PazienteConsensoOut = PazienteConsensiRowToPazientiEsenzioniOut(dr)
                    glConsensi.Add(oConsenso)
                Next
                '
                ' Converto da ArrayList in array tipizzato
                '
                oConsensi = glConsensi.ToArray
            End If
        End Using
        '
        '
        '
        Return oConsensi
    End Function


    Private Function PazienteEsenzioniRowToPazientiEsenzioniOut(ByVal dr As PazientiDataSet.PazienteEsenzioniRow) As PazienteEsenzioneOut

        Dim sCodiceEsenzione As String = Nothing
        If Not dr.IsCodiceEsenzioneNull() Then sCodiceEsenzione = dr.CodiceEsenzione

        Dim sCodiceDiagnosi As String = Nothing
        If Not dr.IsCodiceDiagnosiNull() Then sCodiceDiagnosi = dr.CodiceDiagnosi


        Dim bPatologica As Boolean = False 'questo non è nullabile nello schema di output
        If Not dr.IsPatologicaNull() Then bPatologica = dr.Patologica

        Dim oDataInizioValidita As DateTime?
        If Not dr.IsDataInizioValiditaNull() Then oDataInizioValidita = dr.DataInizioValidita

        Dim oDataFineValidita As DateTime?
        If Not dr.IsDataFineValiditaNull() Then oDataFineValidita = dr.DataFineValidita

        Dim sNumeroAutorizzazioneEsenzione As String = Nothing
        If Not dr.IsNumeroAutorizzazioneEsenzioneNull() Then sNumeroAutorizzazioneEsenzione = dr.NumeroAutorizzazioneEsenzione

        Dim sNoteAggiuntive As String = Nothing
        If Not dr.IsNoteAggiuntiveNull() Then sNoteAggiuntive = dr.NoteAggiuntive

        Dim sCodiceTestoEsenzione As String = Nothing
        If Not dr.IsCodiceTestoEsenzioneNull() Then sCodiceTestoEsenzione = dr.CodiceTestoEsenzione

        Dim sTestoEsenzione As String = Nothing
        If Not dr.IsTestoEsenzioneNull() Then sTestoEsenzione = dr.TestoEsenzione

        Dim sDecodificaEsenzioneDiagnosi As String = Nothing
        If Not dr.IsDecodificaEsenzioneDiagnosiNull() Then sDecodificaEsenzioneDiagnosi = dr.DecodificaEsenzioneDiagnosi

        Dim sAttributoEsenzioneDiagnosi As String = Nothing
        If Not dr.IsAttributoEsenzioneDiagnosiNull() Then sAttributoEsenzioneDiagnosi = dr.AttributoEsenzioneDiagnosi

        Dim sProvenienza As String = dr.Provenienza

        Dim sOperatoreId As String = Nothing
        If Not dr.IsOperatoreIdNull() Then sOperatoreId = dr.OperatoreId

        Dim sOperatoreCognome As String = Nothing
        If Not dr.IsOperatoreCognomeNull() Then sOperatoreCognome = dr.OperatoreCognome

        Dim sOperatoreNome As String = Nothing
        If Not dr.IsOperatoreNomeNull() Then sOperatoreNome = dr.OperatoreNome

        Dim sOperatoreComputer As String = Nothing
        If Not dr.IsOperatoreComputerNull() Then sOperatoreComputer = dr.OperatoreComputer

        Dim oEsenzione = New PazienteEsenzioneOut(sCodiceEsenzione, sCodiceDiagnosi, bPatologica, oDataInizioValidita, oDataFineValidita,
                                                sNumeroAutorizzazioneEsenzione, sNoteAggiuntive, sCodiceTestoEsenzione, sTestoEsenzione,
                                                sDecodificaEsenzioneDiagnosi, sAttributoEsenzioneDiagnosi,
                                                sProvenienza, sOperatoreId, sOperatoreCognome, sOperatoreNome, sOperatoreComputer)
        '
        '
        '
        Return oEsenzione
    End Function

    Private Function PazienteConsensiRowToPazientiEsenzioniOut(ByVal dr As PazientiDataSet.PazienteConsensiRow) As PazienteConsensoOut


        Dim sProvenienza As String = dr.Provenienza
        Dim sIdProvenienza As String = dr.IdProvenienza
        Dim sTipo As String = Nothing
        If Not dr.IsTipoNull Then sTipo = dr.Tipo

        Dim bStato As Boolean = dr.Stato
        Dim oDataStato As DateTime = dr.DataStato

        Dim sOperatoreId As String = Nothing
        If Not dr.IsOperatoreIdNull Then sOperatoreId = dr.OperatoreId

        Dim sOperatoreCognome As String = Nothing
        If Not dr.IsOperatoreCognomeNull Then sOperatoreCognome = dr.OperatoreCognome

        Dim sOperatoreNome As String = Nothing
        If Not dr.IsOperatoreNomeNull Then sOperatoreNome = dr.OperatoreNome

        Dim sOperatoreComputer As String = Nothing
        If Not dr.IsOperatoreComputerNull Then sOperatoreComputer = dr.OperatoreComputer

        Dim oConsenso As New PazienteConsensoOut(sProvenienza, sIdProvenienza, sTipo, bStato, oDataStato,
                                                 sOperatoreId, sOperatoreCognome, sOperatoreNome, sOperatoreComputer)
        '
        ' 
        '
        Return oConsenso

    End Function


    Private Function CreateListaPazienti(ByVal CurrConnection As SqlConnection,
                                         ByVal CurrTransaction As SqlTransaction,
                                         ByVal dtPazienti As PazientiDataSet.PazientiBaseByGeneralitaDataTable) As RispostaListaPazienti

        Dim oPazienti() As PazienteHL7 = Nothing
        Dim oSinonimi() As PazienteSinonimo = Nothing

        If dtPazienti.Rows.Count > 0 Then
            '
            ' Creo elemento paziente
            '
            Dim glPazienti As New Generic.List(Of PazienteHL7)
            glPazienti.Capacity = dtPazienti.Count

            For Each row As PazientiDataSet.PazientiBaseByGeneralitaRow In dtPazienti
                '
                ' Carico dati sinonimi paziente
                '
                Using taSinonimi As New PazientiDataSetTableAdapters.PazienteSinominiTableAdapter()
                    taSinonimi.Connection = CurrConnection
                    taSinonimi.Transaction = CurrTransaction

                    '
                    ' Carico dati sinonimi paziente
                    '
                    Dim dtSinonimi As PazientiDataSet.PazienteSinominiDataTable = taSinonimi.GetData(row.Id)
                    If dtSinonimi IsNot Nothing AndAlso dtSinonimi.Count > 0 Then
                        '
                        ' Creo elemento sinonimi
                        '
                        Dim glSinonimi As New Generic.List(Of PazienteSinonimo)
                        glSinonimi.Capacity = dtSinonimi.Count

                        For Each drSinonimi As PazientiDataSet.PazienteSinominiRow In dtSinonimi
                            '
                            ' Creo nodo per ogni utente ACK di uscita
                            '
                            Dim oSinonimo = New PazienteSinonimo(drSinonimi.Provenienza, drSinonimi.IdProvenienza)
                            glSinonimi.Add(oSinonimo)
                        Next

                        '
                        ' Sinonimi con provenienza SAC
                        '
                        Dim dtSacSinonimi As PazientiDataSet.PazientiSinonimiByIdPazienteDataTable
                        dtSacSinonimi = GetSinonimiByIdPaziente(CurrConnection, CurrTransaction, row.Id)

                        For Each rowSacSinonimi As PazientiDataSet.PazientiSinonimiByIdPazienteRow In dtSacSinonimi
                            glSinonimi.Add(New PazienteSinonimo("SAC", rowSacSinonimi.IdPazienteFuso.ToString().ToUpper()))
                        Next

                        '
                        ' Converto da ArrayList in array tipizzato
                        '
                        oSinonimi = glSinonimi.ToArray

                    End If

                End Using
                '
                ' Aggiungo il paziente alla collection
                ' Modifica Ettore 2012-01-29: mi assicuro he l'Id del paziente passto come stringa sia formattato maiuscolo
                glPazienti.Add(New PazienteHL7(row.Id.ToString().ToUpper(),
                                               row.Provenienza,
                                               row.IdProvenienza,
                                               If(row.IsTesseraNull, Nothing, row.Tessera),
                                               If(row.IsCognomeNull, Nothing, row.Cognome),
                                               If(row.IsNomeNull, Nothing, row.Nome),
                                               If(row.IsDataNascitaNull, Nothing, row.DataNascita),
                                               If(row.IsSessoNull, Nothing, row.Sesso),
                                               If(row.IsCodiceFiscaleNull, Nothing, row.CodiceFiscale),
                                               If(row.IsComuneNascitaCodiceNull, Nothing, row.ComuneNascitaCodice),
                                               If(row.IsComuneNascitaNomeNull, Nothing, row.ComuneNascitaNome),
                                               If(row.IsNazionalitaCodiceNull, Nothing, row.NazionalitaCodice),
                                               If(row.IsNazionalitaNomeNull, Nothing, row.NazionalitaNome),
                                               If(row.IsIndirizzoResNull, Nothing, row.IndirizzoRes),
                                               If(row.IsLocalitaResNull, Nothing, row.LocalitaRes),
                                               If(row.IsCapResNull, Nothing, row.CapRes),
                                               If(row.IsComuneResCodiceNull, Nothing, row.ComuneResCodice),
                                               If(row.IsComuneResNomeNull, Nothing, row.ComuneResNome),
                                               If(row.IsIndirizzoDomNull, Nothing, row.IndirizzoDom),
                                               If(row.IsLocalitaDomNull, Nothing, row.LocalitaDom),
                                               If(row.IsCapDomNull, Nothing, row.CapDom),
                                               If(row.IsComuneDomCodiceNull, Nothing, row.ComuneDomCodice),
                                               If(row.IsComuneDomNomeNull, Nothing, row.ComuneDomNome),
                                               If(row.IsTelefono1Null, Nothing, row.Telefono1),
                                               If(row.IsTelefono2Null, Nothing, row.Telefono2),
                                               Nothing, Nothing, Nothing, Nothing, Nothing, Nothing, Nothing,
                                               oSinonimi))
            Next
            '
            ' Converto da ArrayList in array tipizzato
            '
            oPazienti = glPazienti.ToArray

        End If

        '
        ' Creo ritorno
        '
        Return New RispostaListaPazienti(oPazienti)

    End Function

    Private Function GetSinonimiByIdPaziente(ByVal CurrConnection As SqlConnection,
                                             ByVal CurrTransaction As SqlTransaction,
                                             ByVal IdPaziente As Guid) As PazientiDataSet.PazientiSinonimiByIdPazienteDataTable
        '
        ' GetData
        '
        Using ta As New PazientiDataSetTableAdapters.PazientiSinonimiByIdPazienteTableAdapter()
            ta.Connection = CurrConnection
            ta.Transaction = CurrTransaction
            Return ta.GetData(IdPaziente)
        End Using

    End Function

    Private Function GetSinonimi(ByVal CurrConnection As SqlConnection,
                                 ByVal CurrTransaction As SqlTransaction,
                                 ByVal IdPaziente As Guid) As PazientiDataSet.PazienteSinominiDataTable
        '
        ' GetData
        '
        Using ta As New PazientiDataSetTableAdapters.PazienteSinominiTableAdapter()
            ta.Connection = CurrConnection
            ta.Transaction = CurrTransaction
            Return ta.GetData(IdPaziente)
        End Using

    End Function

    Private Sub WriteTrace(ByVal message As String)
        System.Diagnostics.Debug.WriteLine(String.Concat("[Sac.Msg.DataAccess] - ", message))
        System.Diagnostics.Trace.WriteLine(String.Concat("[Sac.Msg.DataAccess] - ", message))
    End Sub


#Region "Nuove funzioni per soluzione errore fusione"

    ''' <summary>
    ''' Restituisce i dati del paziente/anagrafica cercato per IdProvenienza (la provenienza viene derivata dal parametro Utente)
    ''' </summary>
    ''' <param name="CurrConnection"></param>
    ''' <param name="CurrTransaction"></param>
    ''' <param name="Utente"></param>
    ''' <param name="IdProvenienza"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Private Function GetPazientiProprietaExByIdProvenienza(ByVal CurrConnection As Data.SqlClient.SqlConnection,
                                                              ByVal CurrTransaction As Data.SqlClient.SqlTransaction,
                                                              ByVal Utente As String, ByVal IdProvenienza As String) As PazientiDataSet.PazienteProprietaExRow

        Dim dtProprieta As PazientiDataSet.PazienteProprietaExDataTable
        Dim drProprieta As PazientiDataSet.PazienteProprietaExRow = Nothing

        Try
            '
            ' Creo TableAdapters
            '
            Using taProprieta = New PazientiDataSetTableAdapters.PazienteProprietaExTableAdapter
                taProprieta.Connection = CurrConnection
                taProprieta.Transaction = CurrTransaction
                '
                ' Legge la riga
                '
                If drProprieta Is Nothing Then
                    dtProprieta = taProprieta.GetDataByIdProvenienza(Utente, IdProvenienza)
                    If dtProprieta.Count > 0 Then
                        drProprieta = dtProprieta.Item(0)
                    End If
                End If
                '
                ' Ritorna il paziente
                '
                Return drProprieta

            End Using

        Catch ex As DataAccessException
            Throw ex

        Catch ex As Exception
            Throw New ArgumentException("Errore durante GetPazientiProprietaExByIdProvenienza()!", ex)

        End Try

    End Function





    ''' <summary>
    ''' NUOVA VERSIONE
    ''' </summary>
    ''' <param name="Tipo"></param>
    ''' <param name="Messaggio"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Function ProcessaMessaggio(ByVal Tipo As MessaggioTipo, ByVal Messaggio As MessaggioPaziente) As RispostaPaziente
        ' Verifico parametri
        If Messaggio.Utente Is Nothing OrElse Messaggio.Utente.Length = 0 Then
            Throw New ArgumentNullException("Il campo Messaggio.Utente è vuoto!")
        End If

        If (Messaggio.Paziente Is Nothing) OrElse (Messaggio.Paziente.Id Is Nothing) OrElse (Messaggio.Paziente.Id.Length = 0) Then
            Throw New ArgumentNullException("Il campo Paziente.Id è vuoto!")
        End If

        'MODIFICA ETTORE 2016-01-27: controllo in caso di merge che sia presente la parte <Fusione>
        If Tipo = MessaggioTipo.Merge Then
            If (Messaggio.Fusione Is Nothing) OrElse (Messaggio.Fusione.Id Is Nothing) OrElse (Messaggio.Fusione.Id.Length = 0) Then
                Throw New ArgumentNullException("Il campo Fusione.Id è vuoto!")
            End If
        End If

        If String.IsNullOrEmpty(Messaggio.Paziente.CodiceFiscale) Then
            Throw New ArgumentNullException("Il campo Paziente.CodiceFiscale è vuoto!")
        End If
        Dim taQuery As QueriesTransaction = Nothing
        Dim drProprieta As PazientiDataSet.PazienteProprietaRow = Nothing
        Dim drProprietaDestinazione As PazientiDataSet.PazienteProprietaRow = Nothing
        Dim oRetPazienteId As Object = Nothing
        Dim iIstatErrorCode As Integer = 0 'nessun errore
        Dim sIstatErrorSource As String = "Msg-Pazienti"
        Dim sMsgTipoOperazione As String = String.Empty
        Dim oRispostaPaziente As RispostaPaziente = Nothing
        Try
            ' MODIFICA ETTORE 2014-03-18: Normalizzazione dei codici istat (la devo fare prima perchè modifica i dati del Messaggio)
            Call Istat.NormalizzazioneCodiciIstat(Messaggio.Paziente)

            Select Case Tipo
                Case MessaggioTipo.Modify
                    sMsgTipoOperazione = "Aggiornamento" 'Inserimento/Modifica
                    oRispostaPaziente = _OnPazienteModify(taQuery, Messaggio)
                Case MessaggioTipo.Merge
                    sMsgTipoOperazione = "Fusione"
                    oRispostaPaziente = _OnPazienteMerge(taQuery, Messaggio)
                Case MessaggioTipo.Delete
                    sMsgTipoOperazione = "Cancellazione"
                    oRispostaPaziente = _OnPazienteDelete(taQuery, Messaggio)
            End Select

            '
            '
            '
            Return oRispostaPaziente

        Catch ex As IncoerenzaIstatException
            If taQuery IsNot Nothing Then
                taQuery.Rollback()
            End If
            Dim sErrMsg As String = String.Format("Errore incoerenza istat durante Pazienti.ProcessaMessaggio(). Operazione={0} Utente={1} IdProvenienza={2}", sMsgTipoOperazione, Messaggio.Utente, Messaggio.Paziente.Id)
            Throw New ApplicationException(String.Concat(sErrMsg, vbCrLf, ex.Message), ex)

        Catch ex As SinonimoException
            '
            ' Questa eccezione ha il compito di fare terminare l'orchestrazione e viene generata quando non è possibile eseguire una fusione
            ' Perchè questo accada bisogna che il messaggio di errore contenga la parola "sinonimo" MINUSCOLA.
            ' Nessun rollback dei dati
            '
            Dim sMsg As String = String.Format("Pazienti.ProcessaMessaggio(). Utente='{0}', IdProvenienza='{1}', DataSequenza='{2}'.", Messaggio.Utente, Messaggio.Paziente.Id, Messaggio.DataSequenza)

            ' Ritorna errore, workaround perchè sarebbe corretto preparare un messaggio di risposta
            Throw New ApplicationException(String.Concat(sMsg, vbCrLf, ex.Message), ex)

        Catch ex As DataSequenzaException
            Dim sMsg As String = "Errore di Data Sequenza."
            ' Rollback dei dati
            If taQuery IsNot Nothing Then
                taQuery.Rollback()
            End If
            Throw New ApplicationException(String.Concat(sMsg, vbCrLf, ex.Message), ex)

        Catch ex As Data.SqlClient.SqlException
            Dim sErrMsg As String = String.Concat("Errore SqlClient durante Pazienti.ProcessaMessaggio(). Utente=", Messaggio.Utente, "; IdProvenienza=", Messaggio.Paziente.Id)
            ' Rollback dei dati
            If taQuery IsNot Nothing Then
                taQuery.Rollback()
            End If
            Throw New ApplicationException(String.Concat(sErrMsg, vbCrLf, ex.Message), ex)

        Catch ex As DataAccessException
            Dim sErrMsg As String = String.Concat("Errore DataAccess durante Pazienti.ProcessaMessaggio(). Utente=", Messaggio.Utente, "; IdProvenienza=", Messaggio.Paziente.Id)
            ' Rollback dei dati
            If taQuery IsNot Nothing Then
                taQuery.Rollback()
            End If
            Throw New ApplicationException(String.Concat(sErrMsg, vbCrLf, ex.Message), ex)

        Catch ex As Exception
            Dim sInnerExceptionMessage As String = String.Empty
            Dim sInnerExceptionStackTrace As String = String.Empty
            If Not ex.InnerException Is Nothing Then
                sInnerExceptionMessage = ex.InnerException.Message
                sInnerExceptionStackTrace = ex.InnerException.StackTrace
            End If
            Dim sErrMsg As String = String.Concat("Errore generico durante Pazienti.ProcessaMessaggio(). Utente=", Messaggio.Utente, "; IdProvenienza=", Messaggio.Paziente.Id, " " &
                                                  vbCrLf, "InnerException: ", sInnerExceptionMessage &
                                                  vbCrLf, "StackTrace: ", sInnerExceptionStackTrace)
            ' Rollback dei dati
            If taQuery IsNot Nothing Then
                taQuery.Rollback()
            End If
            Throw New ApplicationException(String.Concat(sErrMsg, vbCrLf, ex.Message), ex)

        Finally
            ' Rilascio
            If taQuery IsNot Nothing Then
                taQuery.Dispose()
            End If
        End Try

    End Function

    ''' <summary>
    ''' Funzione per eseguire il merge mandatario
    ''' </summary>
    ''' <param name="taQuery"></param>
    ''' <param name="Messaggio">Il messaggio da processare</param>
    ''' <returns>L'id del vincente</returns>
    ''' <remarks></remarks>
    Private Function _MergeMandatario(taQuery As QueriesTransaction, ByVal Messaggio As MessaggioPaziente, ByRef oIdVittima As Nullable(Of Guid)) As Nullable(Of Guid)
        '*****************************************************
        ' ORCHESTRAZIONE
        '*****************************************************
        ' Nel messaggio di partenza di LHA <Paziente><Fusione> il nodo Paziente è l'attivo(padre/vincente), il nodo Fusione contiene l'anagrafica da fondere (figlia)
        ' Nell'orchestrazione in caso di fusione vengono eseguite le seguenti operazioni:
        ' 1) Viene chiamata la DAE per aggiornare i dati del nodo <Paziente> del messaggio LHA (l'attivo/padre) 
        ' 2) Dopo 3 minuti l'orchestrazione compone un messaggio scambiando i dati del nodo <Paziente> con i dati del nodo <Fusione> del messaggio LHA:
        '       Alla DAE arriva quindi un messaggio in cui il nodo <Paziente> contiene l'anagrafica da fondere
        ' 3) La DAE quindi legge i dati del figlio dal nodo Paziente, e i dati del padre (vincente) dal nodo Fusione
        Dim bInserimentoInTabellaDiLog As Boolean = False
        Dim sMotivoMancataFusione As String = String.Empty
        Dim oIdVincente As Nullable(Of Guid) = Nothing
        '
        ' Ricavo informazioni sulle due posizioni
        '
        Dim sIdProvenienzaVincente As String = Messaggio.Fusione.Id
        Dim sIdProvenienzaVittima As String = Messaggio.Paziente.Id

        Dim sMsgErr0 As String = String.Format("La richiesta dell'utente {0} di fondere l'anagrafica {1} (vittima) nell'anagrafica {2} (vincente) non è stata eseguita.", Messaggio.Utente, sIdProvenienzaVittima, sIdProvenienzaVincente)
        '
        ' Cerco i dati dell'anagrafica vincente e verifico che esista
        ' 
        Dim drVincente As PazientiDataSet.PazienteProprietaExRow = GetPazientiProprietaExByIdProvenienza(taQuery.Connection, taQuery.Transaction, Messaggio.Utente, sIdProvenienzaVincente)
        If drVincente Is Nothing Then
            Dim sMsg As String = sMsgErr0 & vbCrLf & "Motivo: Il record dell'anagrafica vincente non esiste."
            Throw New Exception(sMsg)
        End If
        '
        ' Cerco i dati dell'anagrafica vittima e verifico che esista
        '
        Dim drVittima As PazientiDataSet.PazienteProprietaExRow = GetPazientiProprietaExByIdProvenienza(taQuery.Connection, taQuery.Transaction, Messaggio.Utente, sIdProvenienzaVittima)
        If drVittima Is Nothing Then
            Dim sMsg As String = sMsgErr0 & vbCrLf & "Motivo: Il record dell'anagrafica vittima non esiste."
            Throw New Exception(sMsg)
        End If
        'Passo all'esterno l'id della vittima
        oIdVittima = drVittima.Id
        '
        ' 
        '
        Dim bVittimaAttiva As Boolean = drVittima.IsIdPazienteRootNull
        Dim bVincenteAttiva As Boolean = drVincente.IsIdPazienteRootNull
        '
        ' Analizzo le possibili combinazioni vittima/vincente che posso gestire
        '
        If bVittimaAttiva AndAlso bVincenteAttiva Then
            '---------------------------------------------------------------------------------------------
            ' La vittima è attiva, il vincente è attivo 
            '---------------------------------------------------------------------------------------------
            ' Caso normale di fusione
            ' Le due anagrafiche hanno la stessa provenienza quindi verifico solo il livello di attendibilità
            If drVincente.LivelloAttendibilita < drVittima.LivelloAttendibilita Then
                '
                ' MODIFICA ETTORE 2016-01-26: controllo sul livello di attendibilità
                ' Non posso fare la fusione: il livello di attendibilità del vincente è minore di quello della vittima
                ' Inserimento in tabella di log e proseguo
                '
                sMotivoMancataFusione = sMsgErr0 & vbCrLf &
                        "Stato: vittima attiva, vincente attivo (non è sinonimo). Motivo: il livello attendibilità del vincente è minore del livello attendibilità della vittima"
                bInserimentoInTabellaDiLog = True

            Else
                oIdVincente = drVincente.Id
                Dim oRetBaseMerge As Object = taQuery.PazientiMsgBaseMerge(drVincente.Id,
                                                                            drVittima.Id,
                                                                            drVittima.Provenienza,
                                                                            drVittima.IdProvenienza,
                                                                            0, "Merge Automatico elaborato da Sac.Msg.DataAccess!",
                                                                            Messaggio.Utente,
                                                                            False)
                If oRetBaseMerge Is Nothing OrElse CType(oRetBaseMerge, Integer) = 0 Then
                    Dim sMsg As String = sMsgErr0 & vbCrLf & "Motivo: si è verificato un errore in PazientiMsgBaseMerge."
                    Throw New Exception(sMsg)
                End If
                '
                ' MODIFICA ETTORE 2016-05-26: L'inserimento del record di notifica viene eseguito dalla data access e non all'interno della SP di merge
                '
                taQuery.PazientiNotificheAdd(drVincente.Id, 0, Messaggio.Utente, drVittima.Id)

            End If

        ElseIf bVittimaAttiva AndAlso (Not bVincenteAttiva) Then
            If drVincente.IdPazienteRoot <> drVittima.Id Then
                '---------------------------------------------------------------------------------------------
                ' La vittima è attiva e il vincente è già fuso e il padre del vincente non è la vittima
                '---------------------------------------------------------------------------------------------
                '   Vittima
                '       |-AAAAA                    
                '
                '   BBBBB
                '   | -Vincente
                '---------------------------------------------------------------------------------------------
                ' Fondo la vittima nel padre del vincente drVincente.IdPazientePadre: Vittima -> BBBB (altrimenti dovrei inserire in tabella di log)
                ' QUESTO NON E' CORRETTISSIMO MA FA PRATICAMENTE QUELLO CHE FA IL BATCH SCHEDULATO
                '
                ' MODIFICA ETTORE 2016-01-26: controllo sul livello di attendibilità e della provenienza (nel caso di LHA) della root del vincente
                ' Visto che si vuole fondere la vittima nella root del vincente, la fusione si può fare solo se:
                '   1) il livello di attendibilita della root del vincente deve essere maggiore o uguale a quello della vittima
                '   2) Nel caso di LHA la provenienza della vittima deve essere uguale alla provenienza della root del vincente (una anagrafica LHA si può fondere solo in una anagrafica LHA)
                '
                If drVincente.LivelloAttendibilitaPazienteRoot < drVittima.LivelloAttendibilita Then
                    '
                    ' MODIFICA ETTORE 2016-01-26: controllo sul livello di attendibilità
                    ' Non posso fare la fusione: il livello di attendibilità del vincente è minore di quello della vittima
                    ' Inserimento in tabella di log e proseguo
                    '
                    sMotivoMancataFusione = sMsgErr0 & vbCrLf &
                            String.Format("Stato: La vittima è attiva, il vincente è fuso (sinonimo). Motivo: il livello di attendibilità della root del vincente ({0}) è minore del livello attendibilità della vittima", drVincente.IdPazienteRoot)
                    bInserimentoInTabellaDiLog = True

                    'ATTENZIONE: devo controllare la provenienza del padre del vincente
                ElseIf (String.Compare(drVittima.Provenienza, "LHA", True) = 0) AndAlso (String.Compare(drVincente.ProvenienzaPazienteRoot, "LHA", True) <> 0) Then
                    '
                    ' MODIFICA ETTORE 2016-01-26: controllo sulla provenienza
                    ' Non posso fare la fusione: se provnienza LHA posso fondere solo in una anagrafica LHA
                    ' Inserimento in tabella di log e proseguo
                    '
                    sMotivoMancataFusione = sMsgErr0 & vbCrLf &
                            String.Format("Stato: La vittima è attiva, il vincente è fuso (sinonimo). Motivo: la provenienza della root del vincente ({0}) è diversa dalla provenienza della vittima (LHA).", drVincente.IdPazienteRoot)
                    bInserimentoInTabellaDiLog = True

                Else
                    'Posso fondere
                    oIdVincente = drVincente.IdPazienteRoot
                    Dim oRetBaseMerge As Object = taQuery.PazientiMsgBaseMerge(drVincente.IdPazienteRoot,
                                                                                drVittima.Id,
                                                                                drVittima.Provenienza,
                                                                                drVittima.IdProvenienza,
                                                                                0, "Merge Automatico elaborato da Sac.Msg.DataAccess!",
                                                                                Messaggio.Utente,
                                                                                False)
                    If oRetBaseMerge Is Nothing OrElse CType(oRetBaseMerge, Integer) = 0 Then
                        Dim sMsg As String = sMsgErr0 & vbCrLf & "Motivo: si è verificato un errore in PazientiMsgBaseMerge."
                        Throw New Exception(sMsg)
                    End If
                    '
                    ' MODIFICA ETTORE 2016-05-26: L'inserimento del record di notifica viene eseguito dalla data access e non all'interno della SP di merge
                    '
                    taQuery.PazientiNotificheAdd(drVincente.IdPazienteRoot, 0, Messaggio.Utente, drVittima.Id)

                End If
            Else
                '---------------------------------------------------------------------------------------------
                ' La vittima è attiva, il vincente è fuso e il padre del vincente è la vittima
                '---------------------------------------------------------------------------------------------
                '   Vittima
                '       | -Vincente
                '---------------------------------------------------------------------------------------------
                'Inserimento in tabella di log e proseguo
                sMotivoMancataFusione = sMsgErr0 & vbCrLf & String.Format("Stato: La vittima è attiva, il vincente è fuso (sinonimo). Motivo: il vincente è fuso nell'anagrafica {0} e la root del vincente è la vittima", drVincente.IdPazienteRoot)
                bInserimentoInTabellaDiLog = True
            End If

        ElseIf (Not bVittimaAttiva) AndAlso bVincenteAttiva Then
            '---------------------------------------------------------------------------------------------
            ' La vittima è fusa e il vincente è attivo
            '---------------------------------------------------------------------------------------------
            If drVittima.IdPazienteRoot = drVincente.Id Then
                '---------------------------------------------------------------------------------------------
                '   Vincente
                '       | XXX
                '           | -Vittima
                '---------------------------------------------------------------------------------------------
                'La fusione richiesta è già presente, siamo a posto
                oIdVincente = drVincente.Id
            Else
                'La vittima è già fusa in una altra anagrafica
                'Inserimento in tabella di log e proseguo
                sMotivoMancataFusione = sMsgErr0 & vbCrLf & String.Format("Stato: La vittima è fusa (sinonimo), il vincente è attivo. Motivo: La vittima è già fusa nell'anagrafica {0}", drVittima.IdPazienteRoot)
                bInserimentoInTabellaDiLog = True
            End If

        ElseIf (Not bVittimaAttiva) AndAlso (Not bVincenteAttiva) Then
            '---------------------------------------------------------------------------------------------
            ' La vittima è fusa e il vincente è fuso
            '---------------------------------------------------------------------------------------------
            ' Se fanno parte della stessa catena di fusione proseguo altrimenti inserimento in tabella di log e proseguo
            If drVincente.IdPazienteRoot = drVittima.IdPazienteRoot Then
                oIdVincente = drVincente.IdPazienteRoot
                'Fanno parte della stesa catena di fusione
                '
                ' YYYY
                '   |-Vincente
                '   |-Vittima
                '
                'Non faccio niente e proseguo
            Else
                'NON fanno parte della stesa catena di fusione
                'Inserimento in tabella di log e proseguo
                sMotivoMancataFusione = sMsgErr0 & vbCrLf & String.Format("Motivo: La vittima è già fusa (sinonimo) nell'anagrafica {0} e il vincente è già fuso (sinonimo) nell'anagrafica {1}", drVittima.IdPazienteRoot, drVincente.IdPazienteRoot)
                bInserimentoInTabellaDiLog = True
            End If
        End If
        '
        ' Eseguo inserimento in tabella di log PazientiFusioniLog
        '
        If bInserimentoInTabellaDiLog Then

            Dim dVincenteDataNascita As Nullable(Of DateTime) = Nothing
            If (Not drVincente.IsDataNascitaNull) Then dVincenteDataNascita = drVincente.DataNascita

            Dim dVittimaDataNascita As Nullable(Of DateTime) = Nothing
            If (Not drVittima.IsDataNascitaNull) Then dVittimaDataNascita = drVittima.DataNascita

            taQuery.PazientiMsgPazientiFusioniLogInsert(Messaggio.Utente,
                                                        drVincente.Id, drVincente.Provenienza, drVincente.IdProvenienza, drVincente.Cognome, drVincente.Nome, dVincenteDataNascita, drVincente.CodiceFiscale,
                                                        drVittima.Id, drVittima.Provenienza, drVittima.IdProvenienza, drVittima.Cognome, drVittima.Nome, dVittimaDataNascita, drVittima.CodiceFiscale,
                                                        sMotivoMancataFusione)
            '
            ' Dopo eseguirò un throw quindi mi assicuro di fare il commit (posso avere eseguito un inserimento o unam modifica prima, cosi tali aggiornamenti entrano nel database)
            '
            taQuery.Commit()

            '
            ' ATTENZIONE: Dopo avere scritto in tabella di log delle fusioni genero una eccezione contenente la parola "sinonimo" in minuscolo: questo causerà la terminazione dell'orchestrazione
            ' Mi assicuro che la parola "sinonimo" sia sempre presente
            If Not sMotivoMancataFusione.Contains("sinonimo") Then
                sMotivoMancataFusione = "Errore creazione sinonimo (fusione) - " & sMotivoMancataFusione
            End If
            Throw New SinonimoException("paziente", sMotivoMancataFusione)
        End If
        '
        ' Restituisco il vincente
        '
        Return oIdVincente
    End Function


    Private Function _OnPazienteModify(ByRef taQuery As QueriesTransaction, ByVal Messaggio As MessaggioPaziente) As RispostaPaziente
        Dim bPazienteFuso As Boolean = False
        Dim oRispostaPaziente As RispostaPaziente = Nothing
        '------------------------------------------------------------------------------------------------------------------
        ' FUORI DALLA TRANSAZIONE
        '------------------------------------------------------------------------------------------------------------------
        Dim oIstat As New Istat(Messaggio.Utente, Messaggio.Paziente, ConfigSingleton.ConnectionString)
        Dim sIstatErrorSource As String = "Msg-Pazienti"
        Dim iIstatErrorCode As Integer = oIstat.VerificaCodiciIstat()
        If iIstatErrorCode <> 0 Then
            ' Loggo l'incoerenza Istat nel database
            oIstat.IncoerenzaIstatInsert(sIstatErrorSource)
            Dim sIstatErrorMsg As String = oIstat.BuildIstatErrorMessage() & vbCrLf & "Durante l'aggiornamento/creazione dell'anagrafica."
            '
            ' Eseguo subito throw dell'eccezione tanto non posso ne inserire ne aggiornare
            '
            Throw New IncoerenzaIstatException(sIstatErrorMsg)
        End If
        '
        '
        '
#If DEBUG Then
        If Not taQuery Is Nothing Then Throw New Exception("OnPazienteModify: taQuery deve essere creato all'interno della funzione OnPazienteModify")
#End If
        '
        ' APRO CONNESSIONE E TRANSAZIONE
        '
        taQuery = New QueriesTransaction
        taQuery.OpenConnection(ConfigSingleton.ConnectionString)
        taQuery.BeginTransaction(ConfigSingleton.DatabaseIsolationLevel)

        ' Verifico se il paziente esiste e se manca lo inserisco
        '
        Dim drProprieta As PazientiDataSet.PazienteProprietaRow = GetPazientiProprieta(taQuery.Connection, taQuery.Transaction, Messaggio.Utente, Messaggio.Paziente.Id)
        If drProprieta Is Nothing Then
            drProprieta = _InserimentoPaziente(taQuery, Messaggio)
        Else
            Dim drProprietaFuso As PazientiDataSet.PazienteProprietaRow = Nothing
            bPazienteFuso = CBool(drProprieta.Sinonimo <> 0)
            '
            ' Verifico prima la data di sequenza
            '
            If bPazienteFuso Then
                ' L'anagrafica del messaggio è fusa: il record restituito in drProprietà è il suo padre. Eseguo ulterioriore query per trovare l'anagrafica del messaggio
                ' tramite la GetPazientiProprieta3() che restituisce il record cercato per idProvenienza (attivo o fuso)
                drProprietaFuso = GetPazientiProprieta3(taQuery.Connection, taQuery.Transaction, Messaggio.Utente, Messaggio.Paziente.Id)
                If drProprietaFuso.DataSequenza > Messaggio.DataSequenza Then
                    Throw New DataSequenzaException(String.Concat("paziente (Utente=", Messaggio.Utente, "; IdProvenienza=", Messaggio.Paziente.Id, ")"))
                End If
            Else
                ' L'anagrafica del messaggio è attiva: posso confrontare la data sequenza del messaggio con la data sequenza del record restituito
                ' In UPDATE del record controllo data sequenza
                If drProprieta.DataSequenza > Messaggio.DataSequenza Then
                    Throw New DataSequenzaException(String.Concat("paziente (Utente=", Messaggio.Utente, "; IdProvenienza=", Messaggio.Paziente.Id, ")"))
                End If
            End If

            '
            ' Aggiorno il paziente sia se attivo o fuso
            '
            Call _AggiornamentoPaziente(taQuery, Messaggio)
            '
            ' Se è un fuso
            '
            If bPazienteFuso Then
                '
                ' Verifico se la data decesso dell'anagrafica del Messaggio è diversa da quella presente nel database
                '
                Dim oDataDecessoFuso As DateTime = Nothing
                Dim oDataDecessoMessaggio As DateTime = Nothing

                oDataDecessoMessaggio = GetDataDecesso(Messaggio)
                If Not drProprietaFuso.IsDataDecessoNull Then oDataDecessoFuso = drProprietaFuso.DataDecesso

                If (oDataDecessoFuso <> oDataDecessoMessaggio) Then
                    '
                    ' Se la DataDecesso sul record è diversa da quella del messaggio notifico l'anagrafica padre
                    ' drProprieta.Id contiene già il paziente attivo (L'anagrafica corrente [Utente,IdProvenienza] in questo caso è FUSA )
                    '
                    taQuery.PazientiNotificheAdd(drProprieta.Id, 7, Messaggio.Utente, Nothing)
                End If

                '
                ' COMMIT: e throw eccezione per sospendere l'orchestrazione
                ' E' corretto nel caso in cui si aggiorni un fuso sospendere l'orchestrazione? Si, perchè non si vuole notificare all'esterno modifiche sui fusi (RICHIESTA DI FORACCHIA)
                taQuery.Commit()
                Dim sIdProvenienza As String = Messaggio.Paziente.Id 'questa è la provenienza della posizione che è sinonimo
                '
                ' ATTENZIONE: Il testo di questo messaggio deve contenere la parola "sinonimo" affinchè l'orchestrazione venga terminata
                '
                Dim sErrMessage As String = String.Format("L'aggiornamento del paziente (sinonimo) con IdProvenienza={0} Utente={1} è avvenuto con successo.", sIdProvenienza, Messaggio.Utente)
                Throw New SinonimoException("paziente", sErrMessage)
            End If
        End If
        '
        ' MODIFICA ETTORE 2016-05-26: L'inserimento del record di notifica viene eseguito dalla data access e non all'interno delle SP di insert/update
        ' Questa la devo fare perchè il messaggio all'orchestrazione è un messaggio di modifica 
        '
        taQuery.PazientiNotificheAdd(drProprieta.Id, 0, Messaggio.Utente, Nothing)
        '
        ' Esecuzione del merge automatico
        '
        Dim idPazienteFusoAlVolo As Nullable(Of Guid) = _MergeAutomatico(taQuery, Messaggio, drProprieta)
        '
        ' COMMIT: a questo punto ho eseguito tutte le operazioni eseguo il commit
        '
        taQuery.Commit()
        '
        ' Devo rileggere i dati e preparare la risposta paziente
        ' Questa rilegge i dati e nel caso di paziente fuso restituisce il padre
        ' Vecchia versione che restituisce sempre il padre delle fusione
        ' drProprieta = GetPazientiProprieta(taQuery.Connection, taQuery.Transaction, Messaggio.Utente, Messaggio.Paziente.Id)
        '
        ' MODIFICA ETTORE 2016-02-22: 
        ' Questa legge sempre il record con provenienza Messaggio.Paziente.Id associato all'utente corrente, attivo o fuso che sia
        ' (quindi in caso di fusione al volo di A->B questa restituisce sempre A)
        ' 
        drProprieta = GetPazientiProprieta3(taQuery.Connection, taQuery.Transaction, Messaggio.Utente, Messaggio.Paziente.Id)
        '
        ' MODIFICA ETTORE 2016-02-22: restituisco sempre il paziente di cui si è richiesto l'aggiornamento, anche in caso di fusione al volo
        ' oRispostaPaziente = _GetRispostaPaziente2(taQuery.Connection, taQuery.Transaction,
        '                                                                MessaggioTipo.Modify, Messaggio, idPazienteFusoAlVolo,
        '                                                                drProprieta, Nothing) 'L'ultimo parametro drProprietaDestinazione serve solo in caso di merge
        '
        oRispostaPaziente = _GetRispostaPaziente2(taQuery.Connection, taQuery.Transaction,
                                                                        MessaggioTipo.Modify, Messaggio,
                                                                        drProprieta.Id, Nothing) 'L'ultimo parametro serve solo in caso di merge

        Return oRispostaPaziente
    End Function

    Private Function _OnPazienteMerge(ByRef taQuery As QueriesTransaction, ByVal Messaggio As MessaggioPaziente) As RispostaPaziente
        '
        ' Il paziente in Messaggio.Paziente è il paziente da fondere cioè la vittima, il paziente in Messaggio.Fusione è il vincente della fusione cioè il padre
        ' Se il paziente vincente della fusione manca non posso eseguire la fusione
        '
        Dim oRispostaPaziente As RispostaPaziente = Nothing
        '------------------------------------------------------------------------------------------------------------------
        ' FUORI DALLA TRANSAZIONE: ma non eseguo subito throw dell'errore, solo se devo inserire
        '------------------------------------------------------------------------------------------------------------------
        Dim oIstat As New Istat(Messaggio.Utente, Messaggio.Paziente, ConfigSingleton.ConnectionString)
        Dim sIstatErrorSource As String = "Msg-Pazienti"
        Dim iIstatErrorCode As Integer = oIstat.VerificaCodiciIstat()
        Dim sIstatErrorMsg As String = String.Empty
        If iIstatErrorCode <> 0 Then
            ' Loggo l'incoerenza Istat nel database: se devo inserire o aggiornare eseguiro throw eccezione IncoerenzaIstatException
            oIstat.IncoerenzaIstatInsert(sIstatErrorSource)
            sIstatErrorMsg = oIstat.BuildIstatErrorMessage() & vbCrLf & "OnPazienteMerge: Durante l'aggiornamento/creazione dell'anagrafica da fondere."
        End If
        '
        '
        '
#If DEBUG Then
        If Not taQuery Is Nothing Then Throw New Exception("OnPazienteMerge: taQuery deve essere creato all'interno della funzione OnPazienteMerge")
#End If
        '
        ' APRO CONNESSIONE E TRANSAZIONE
        '
        taQuery = New QueriesTransaction
        taQuery.OpenConnection(ConfigSingleton.ConnectionString)
        taQuery.BeginTransaction(ConfigSingleton.DatabaseIsolationLevel)
        '
        ' Verifico se il paziente (vittima) esiste e se manca lo inserisco
        '
        Dim drProprieta As PazientiDataSet.PazienteProprietaRow = GetPazientiProprieta(taQuery.Connection, taQuery.Transaction, Messaggio.Utente, Messaggio.Paziente.Id)
        If drProprieta Is Nothing Then
            If iIstatErrorCode = 0 Then
                drProprieta = _InserimentoPaziente(taQuery, Messaggio)
            Else
                Throw New IncoerenzaIstatException(sIstatErrorMsg)
            End If
        Else
            'MODIFICA ETTORE: 2018-10-09: NON AGGIORNO MAI IL FUSO PERCHE' NON HO TUTTI I DATI A DISPOSIZIONE NEL NODO FUSIONE
        End If
        '
        ' MODIFICA ETTORE 2016-05-26:
        ' Questo inserimento di notifica non va fatta perchè ciò che si notificherà all'anagrafica è il messaggio di fusione che viene inserito nella funzione _MergeMandatario
        ' taQuery.PazientiNotificheAdd(drProprieta.Id, 0, Messaggio.Utente, Nothing)
        '
        ' Esecuzione della fusione
        '
        ' MODIFICA ETTORE 2018-10-01: prendo l'Id della vittima della fusione dalla funzione _MergeMandatario() e lo uso nella _GetRispostaPaziente2() 
        ' per evitare problema di costruzione messaggio di fusione errato a seguito di fusione già eseguita (stesso messaggio di fusione inviato due volte)
        ' causato dal fatto che GetPazientiProprieta() restituisce sempre l'attivo, quindi se Anagrafica1 è già fusa in Anagrafica2, GetPazientiProprieta() restituisce i dati di Anagrafica2
        ' e il codice successivo non sarebbe corretto.
        Dim oIdVittima As Nullable(Of Guid) = Nothing
        Dim oIdVIncente As Nullable(Of Guid) = _MergeMandatario(taQuery, Messaggio, oIdVittima)
        '
        ' COMMIT della transazione
        '
        taQuery.Commit()
        '
        ' idPazienteFusoAlVolo è nothing in caso di MERGE mandatario
        ' NON DEVO ASSOLUTAMENTE RILEGGERE i dati e preparare la risposta paziente altrimenti la funzione mi da il padre della fusione appena fatta
        ' 
        oRispostaPaziente = _GetRispostaPaziente2(taQuery.Connection, taQuery.Transaction,
                                                                        MessaggioTipo.Merge, Messaggio,
                                                                        oIdVittima, oIdVIncente) 'L'ultimo parametro serve solo in caso di merge

        Return oRispostaPaziente

    End Function

    Private Function _OnPazienteDelete(ByRef taQuery As QueriesTransaction, ByVal Messaggio As MessaggioPaziente) As RispostaPaziente
        Dim oRispostaPaziente As RispostaPaziente = Nothing
        Dim bPazienteFuso As Boolean = False
        '
        '
        '
#If DEBUG Then
        If Not taQuery Is Nothing Then Throw New Exception("OnPazienteDelete: taQuery deve essere creato all'interno della funzione OnPazienteDelete")
#End If
        '
        ' APRO CONNESSIONE E TRANSAZIONE
        '
        taQuery = New QueriesTransaction
        taQuery.OpenConnection(ConfigSingleton.ConnectionString)
        taQuery.BeginTransaction(ConfigSingleton.DatabaseIsolationLevel)
        '
        ' Verifico se il paziente esiste e se manca non eseguo nessuna cancellazione
        '
        Dim drProprieta As PazientiDataSet.PazienteProprietaRow = GetPazientiProprieta(taQuery.Connection, taQuery.Transaction, Messaggio.Utente, Messaggio.Paziente.Id)
        If drProprieta Is Nothing Then
            '
            ' L'anagrafica manca segnalo errore
            ' 
            Throw New DatiNonTrovatiException("paziente")
        Else
            '
            ' L'anagrafica esiste
            '
            bPazienteFuso = CBool(drProprieta.Sinonimo <> 0)
            '
            ' Aggiorno comunque il paziente: per i fusi non aggiorno le esenzioni
            ' Non posso eseguire l'aggiornamento...non so quali fra tutti i dati sono compilati e inoltre la successiva operazione di delete causerebbe "Errore data sequenza"
            ' Call _AggiornamentoPaziente(taQuery, Messaggio, Not bPazienteFuso)
            '
            If Not bPazienteFuso Then
                '
                ' Eseguo la cancellazione logica
                ' 
                '2018-05-28: MODIFICA ETTORE: non cancelliamo più le esenzioni in caso di CANCELLAZIONE LOGICA del record Paziente
                'Dim oRetEsenzioniRemove As Object = taQuery.PazientiMsgEsenzioniRemove(Messaggio.Utente, Messaggio.Paziente.Id)

                Dim oRetBaseDelete As Object = taQuery.PazientiMsgBaseDelete(Messaggio.Utente, Messaggio.Paziente.Id, Messaggio.DataSequenza)
                ' Controllo risultato della query
                If oRetBaseDelete Is Nothing OrElse CType(oRetBaseDelete, Integer) = 0 Then
                    Throw New DatiRowCountZeroException("paziente (delete)")
                End If
                'Commit della cancellazione
                taQuery.Commit()
            Else
                taQuery.Commit()
                '
                ' Segnalo che non posso cancellare il paziente
                '
                Dim sProvenienza As String = drProprieta.Provenienza
                Dim sIdProvenienza As String = Messaggio.Paziente.Id 'questa è la provenienza della posizione che è fusa
                '
                ' ATTENZIONE: Il testo di questo messaggio deve contenere la parola "sinonimo" affinchè l'orchestrazione venga terminata
                '
                Dim sErrMessage As String = String.Format("La cancellazione del paziente con IdProvenienza={0} Provenienza={1} non è stata eseguita poichè trattandosi di un paziente fuso(sinonimo) non può essere cancellato; l'orchestrazione è stata sospesa solo a fini di debug.", sIdProvenienza, sProvenienza)
                Throw New SinonimoException("paziente", sErrMessage)
            End If
        End If
        '
        ' MODIFICA ETTORE 2016-05-26: L'inserimento del record di notifica viene eseguito dalla data access e non all'interno delle SP di delete
        '
        taQuery.PazientiNotificheAdd(drProprieta.Id, 0, Messaggio.Utente, Nothing)
        '
        ' Costruisco la risposta con i dati del paziente prima della cancellazione
        '
        oRispostaPaziente = _GetRispostaPaziente2(taQuery.Connection, taQuery.Transaction,
                                                MessaggioTipo.Delete, Messaggio,
                                                drProprieta.Id, Nothing) 'L'ultimo parametro serve solo in caso di merge
        '
        '
        '
        Return oRispostaPaziente

    End Function

    Private Function _InserimentoPaziente(ByRef taquery As QueriesTransaction, ByVal Messaggio As MessaggioPaziente) As PazientiDataSet.PazienteProprietaRow
        '
        ' Inserisco
        '
        Dim oRetBaseInsert As Object = taquery.PazientiMsgBaseInsert2(Messaggio.Utente, Messaggio.DataSequenza, Messaggio.Paziente)
        If oRetBaseInsert Is Nothing OrElse CType(oRetBaseInsert, Integer) = 0 Then
            Throw New DatiRowCountZeroException("paziente (insert)")
        End If
        '
        ' Aggiungo le esenzioni se ce ne sono
        '
        Call _AggiungiEsenzioni(taquery, Messaggio)
        '
        ' Leggo il paziente inserito
        '
        Return GetPazientiProprieta(taquery.Connection, taquery.Transaction, Messaggio.Utente, Messaggio.Paziente.Id)
    End Function

    Private Sub _AggiornamentoPaziente(ByRef taQuery As QueriesTransaction, ByVal Messaggio As MessaggioPaziente)
        '
        ' Aggiorno
        ' ATTENZIONE: nella versione precedente se paziente fuso si aggiornava solo il record della tabella Pazienti e non le esenzioni
        ' MODIFICA ETTORE 2015-11-06: E' stato deciso con Sandro di aggiornare comunque le esenzioni
        '
        Dim oRetBaseUpdate As Object = taQuery.PazientiMsgBaseUpdate2(Messaggio.Utente, Messaggio.DataSequenza, Messaggio.Paziente)
        If oRetBaseUpdate Is Nothing OrElse CType(oRetBaseUpdate, Integer) = 0 Then
            Throw New DatiRowCountZeroException("paziente (update)")
        End If

        ' Rimuovo le esenzioni e poi le aggiungo
        Dim oRetEsenzioniRemove As Object = taQuery.PazientiMsgEsenzioniRemove(Messaggio.Utente, Messaggio.Paziente.Id)
        'Aggiungo le esenzioni se ce ne sono
        Call _AggiungiEsenzioni(taQuery, Messaggio)

    End Sub


    Private Sub _AggiungiEsenzioni(ByRef taQuery As QueriesTransaction, ByVal Messaggio As MessaggioPaziente)
        '
        ' Solo se ho delle esenzioni
        '
        If Messaggio.Esenzioni IsNot Nothing Then
            For Each oEsenzione In Messaggio.Esenzioni
                ' Aggiungo singola esenzione
                Dim oRetEsenzioniAdd As Object = taQuery.PazientiMsgEsenzioniAdd2(Messaggio.Utente, Messaggio.Paziente.Id, oEsenzione)
                ' Controllo risultato della query
                If oRetEsenzioniAdd Is Nothing OrElse CType(oRetEsenzioniAdd, Integer) = 0 Then
                    Throw New DatiRowCountZeroException("esenzione-paziente (add)")
                End If
            Next
        End If
    End Sub

    Private Function _MergeAutomatico(ByRef taquery As QueriesTransaction, ByVal Messaggio As MessaggioPaziente, ByVal drProprieta As PazientiDataSet.PazienteProprietaRow) As Nullable(Of Guid)
        Dim drProprietaDestinazione As PazientiDataSet.PazienteProprietaRow = Nothing
        '
        ' MODIFICA ETTORE: 2019-10-21: memorizzo il livello di attendibilita dell'anagrafica sottoposta a update/insert
        '                               per la quale deve essere eseguito eventuale merge automatico
        '
        Dim iLivelloAttendibilita As Byte = drProprieta.LivelloAttendibilita
        '
        ' Merge Automatico DA Eseguire solo in caso di MessaggioTipo.Modify
        '
        Dim idPazienteFusoAlVolo As Nullable(Of Guid) = Nothing
        ' Trace
        WriteTrace("Carico le proprietà del paziente di destinazione.")

        ' Carico proprietà destinazione per il merge automatico (Cerco per Codice Fiscale, Cognome, Nome)
        If (Not String.IsNullOrEmpty(Messaggio.Paziente.CodiceFiscale)) AndAlso
            (Not String.IsNullOrEmpty(Messaggio.Paziente.Cognome)) AndAlso
             (Not String.IsNullOrEmpty(Messaggio.Paziente.Nome)) Then

            ' MODIFICA ETTORE 2019-10-22: uso nuova funzione che usa nuova SP
            drProprietaDestinazione = GetCandidatoFusioneAutomaticaOttieni(taquery.Connection, taquery.Transaction,
                                                                          Messaggio.Utente, Messaggio.Paziente.Id,
                                                                          Messaggio.Paziente.CodiceFiscale,
                                                                         Messaggio.Paziente.Cognome,
                                                                        Messaggio.Paziente.Nome,
                                                                        iLivelloAttendibilita)

        End If


        ' Permesso di fusione per livello di attendibilità massimo
        If drProprietaDestinazione IsNot Nothing Then
            '
            ' MODIFICA ETTORE 2019-10-22: la nuova SP usata da GetCandidatoFusioneAutomaticaOttieni() in base alla configurazione
            ' può restituire una anagrafica con stesso livello di attendibilità del chiamante (se esiste) oppure non la restituirà mai
            '
            ' Se i livelli di attendibilità del paziente sottomesso e del paziente di destinazione
            ' sono uguali determino il paziente padre della fusione calcolando i pesi dei relativi
            ' attributi compilati dei due pazienti
            '
            If drProprietaDestinazione.LivelloAttendibilita = drProprieta.LivelloAttendibilita Then
                Dim pesoPaziente As Integer = taquery.GetPesoPaziente(drProprieta)
                Dim pesoPazienteDestinazione As Integer = taquery.GetPesoPaziente(drProprietaDestinazione)

                If pesoPazienteDestinazione >= pesoPaziente Then
                    drProprietaDestinazione.LivelloAttendibilita = 1
                    drProprieta.LivelloAttendibilita = 0
                ElseIf pesoPazienteDestinazione < pesoPaziente Then
                    drProprietaDestinazione.LivelloAttendibilita = 0
                    drProprieta.LivelloAttendibilita = 1
                End If
            End If

            ' Merge
            If drProprietaDestinazione.LivelloAttendibilita > drProprieta.LivelloAttendibilita AndAlso
                                        taquery.GetPermessoFusioneByLivelloAttendibilita(drProprieta.LivelloAttendibilita) AndAlso
                                        taquery.GetPermessoFusioneByProvenienza(drProprieta.Provenienza) Then
                '
                ' Merge del paziente sottomesso verso un paziente già esistente
                ' ***********************************************************************************
                ' *** questo avviene quando il paziente sottomesso ha un livello di attendibilità
                ' *** inferiore al livello di attendibilità del paziente di destinazione
                '
                idPazienteFusoAlVolo = drProprieta.Id

                Dim oRetBaseMerge As Object
                oRetBaseMerge = taquery.PazientiMsgBaseMerge(drProprietaDestinazione.Id,
                                                             drProprieta.Id,
                                                             drProprieta.Provenienza,
                                                             drProprieta.IdProvenienza,
                                                             1, "Merge Automatico elaborato da Sac.Msg.DataAccess!",
                                                             Messaggio.Utente,
                                                             True)

                ' introdotto il 2011-09-12, notifica di merge
                ' MODIFICA ETTORE 2016-02-22: passo sia il paziente padre che il paziente fuso
                taquery.PazientiNotificheAdd(drProprietaDestinazione.Id, 4, Messaggio.Utente, idPazienteFusoAlVolo)

                ' Controllo risultato della query
                If oRetBaseMerge Is Nothing OrElse CType(oRetBaseMerge, Integer) = 0 Then
                    Throw New DatiRowCountZeroException("paziente (merge)")
                End If

                ' Merge avvenuto, rileggo le proprietà del paziente sorgente - LA FACCIO FUORI
                'drProprieta = GetPazientiProprieta(taquery.Connection, taquery.Transaction, Messaggio.Utente, Messaggio.Paziente.Id)

            ElseIf drProprietaDestinazione.LivelloAttendibilita < drProprieta.LivelloAttendibilita AndAlso
                                taquery.GetPermessoFusioneByLivelloAttendibilita(drProprietaDestinazione.LivelloAttendibilita) AndAlso
                                taquery.GetPermessoFusioneByProvenienza(drProprietaDestinazione.Provenienza) Then
                '
                ' Merge del paziente di destinazione verso il paziente sottomesso
                ' ***********************************************************************************
                ' *** questo avviene quando il paziente sottomesso ha un livello di attendibilità
                ' *** maggiore al livello di attendibilità del paziente di destinazione
                '
                idPazienteFusoAlVolo = drProprietaDestinazione.Id

                Dim oRetBaseMerge As Object
                oRetBaseMerge = taquery.PazientiMsgBaseMerge(drProprieta.Id,
                                                             drProprietaDestinazione.Id,
                                                             drProprietaDestinazione.Provenienza,
                                                             drProprietaDestinazione.IdProvenienza,
                                                             1, "Merge Automatico elaborato da Sac.Msg.DataAccess!",
                                                             Messaggio.Utente,
                                                             True)

                ' introdotto il 2011-09-12, notifica di merge
                ' MODIFICA ETTORE 2016-02-22: passo sia il paziente padre che il paziente fuso
                taquery.PazientiNotificheAdd(drProprieta.Id, 4, Messaggio.Utente, idPazienteFusoAlVolo)

                ' Controllo risultato della query
                If oRetBaseMerge Is Nothing OrElse CType(oRetBaseMerge, Integer) = 0 Then
                    Throw New DatiRowCountZeroException("paziente (merge)")
                End If

                ' Merge avvenuto, rileggo le proprietà del paziente sorgente - LA FACCIO FUORI
                'drProprieta = GetPazientiProprieta(taquery.Connection, taquery.Transaction, Messaggio.Utente, Messaggio.Paziente.Id)
            End If
        End If
        '
        ' Può rimanere nothing
        '
        Return idPazienteFusoAlVolo
    End Function


    ''' <summary>
    ''' 
    ''' </summary>
    ''' <param name="CurrConnection"></param>
    ''' <param name="CurrTransaction"></param>
    ''' <param name="Tipo"></param>
    ''' <param name="Messaggio"></param>
    ''' <param name="IdPaziente">Il paziente da aggiornare o il figlio in caso di fusione</param>
    ''' <param name="IdPazienteVincente">Il vincente della fusione</param>
    ''' <returns></returns>
    Private Function _GetRispostaPaziente2(ByVal CurrConnection As Data.SqlClient.SqlConnection,
                                            ByVal CurrTransaction As Data.SqlClient.SqlTransaction,
                                            ByVal Tipo As MessaggioTipo, ByVal Messaggio As MessaggioPaziente,
                                            ByVal IdPaziente As Nullable(Of Guid),
                                            ByRef IdPazienteVincente As Nullable(Of Guid)) As RispostaPaziente
        Try
            Dim oDtPaz As PazientiDataSet.PazienteDettaglioDataTable = Nothing

            Dim oDettaglioPaziente As RispostaDettaglioPazienteWCF = Nothing
            Dim oRispostaPaziente As RispostaPaziente = Nothing
            Dim oPazienteFuso As PazienteFusoOut = Nothing

            Dim IdPazienteRisposta As Guid
            If Tipo = MessaggioTipo.Merge Then
                If Not IdPaziente.HasValue Then
                    'Nel caso di MERGE la vittima è nel nodo Paziente
                    Dim sErrMsg As String = String.Format("_GetRispostaPaziente2(): Non è stato valorizzato l'Id dell'anagrafica figlia Utente={0} IdProvenienza={1}", Messaggio.Utente, Messaggio.Paziente.Id)
                    Throw New Exception(sErrMsg)
                End If
                If Not IdPazienteVincente.HasValue Then
                    'Nel caso di MERGE il padre è nel nodo Fusione
                    Dim sErrMsg As String = String.Format("_GetRispostaPaziente2(): Non è stato valorizzato durante Merge l'Id dell'anagrafica padre Utente={0} IdProvenienza={1}", Messaggio.Utente, Messaggio.Fusione.Id)
                    Throw New Exception(sErrMsg)
                End If
                ' Imposto l'id del paziente della risposta con il vincente della fusione
                IdPazienteRisposta = IdPazienteVincente.Value
            Else
                If Not IdPaziente.HasValue Then
                    Dim sErrMsg As String = String.Format("_GetRispostaPaziente2(): Non è stato valorizzato l'Id dell'anagrafica Utente={0} IdProvenienza={1}", Messaggio.Utente, Messaggio.Paziente.Id)
                    Throw New Exception(sErrMsg)
                End If
                ' Imposto l'id del paziente che è stato aggiornato
                IdPazienteRisposta = IdPaziente.Value
            End If


            Dim sIdMessaggio As String = Guid.NewGuid().ToString ' L'IdMessaggio è un GUID
            Dim iAzione As Integer = GetAzioneFromTipo(Tipo)

            ' Dettaglio Paziente
            If Tipo = MessaggioTipo.Merge Then
                'Fusione: IdVincente=IdPazienteRisposta, IdFuso=IdPazienteVittima.Value
                'Trovo i dati di dettaglio del paziente attivo (passo anche il fuso per metterlo come primo nei sinonimi)
                oDettaglioPaziente = CreateDettaglioPazienteWCF(CurrConnection, CurrTransaction, IdPazienteRisposta, IdPaziente.Value, oDtPaz)
                'Trovo i dati di dettaglio del paziente fuso e valorizzo il nodo fusione
                oPazienteFuso = New PazienteFusoOut()
                ' Eseguo la query
                Dim oDtPazFuso As PazientiDataSet.PazienteDettaglioDataTable = GetPazienteDettaglio(CurrConnection, CurrTransaction, IdPaziente.Value)
                If oDtPazFuso Is Nothing OrElse oDtPazFuso.Rows.Count = 0 Then
                    Throw New Exception(String.Format("_GetRispostaPaziente2(): Impossibile ricavare i dati dell'anagrafica fusa Utente={0} IdProvenienza={1}", Messaggio.Utente, Messaggio.Paziente.Id))
                End If
                ' Converto la row del database nell'oggetto PazienteFusoOut con i dati letti da database
                oPazienteFuso = oDtPazFuso.ToPazienteFusoOut
                '
                ' oFusione.Attributi: Crea la lista con attributi da database + campi di testata e la converto in XML 
                ' Devo passare la datatable del paziente fuso
                '
                oPazienteFuso.Attributi = CreaAttributiEx(oPazienteFuso, oDtPazFuso).ToXml

            ElseIf Tipo = MessaggioTipo.Modify Then
                'Inserimento/aggiornamento
                'Trovo i dati di dettaglio del paziente attivo
                oDettaglioPaziente = CreateDettaglioPazienteWCF(CurrConnection, CurrTransaction, IdPazienteRisposta, Nothing, oDtPaz)

            ElseIf Tipo = MessaggioTipo.Delete Then
                'MODIFICA ETTORE 2015-12-14: In caso di cancellazione eseguo lo stesso codice eseguito in Inserimento/Aggiornamento
                'Risolve il problema della mancata notifica degli eventi di cancellazione (l'orchestrazione non notifica se mancano i dati del paziente)
                oDettaglioPaziente = CreateDettaglioPazienteWCF(CurrConnection, CurrTransaction, IdPazienteRisposta, Nothing, oDtPaz)
            Else
                'Non dovrebbe mai passare di qui!
                Throw New Exception("_GetRispostaPaziente2(): TipoMessaggio non valido: i valori permessi sono Modify=0, Delete=1, Merge=2")
            End If

            If oDettaglioPaziente IsNot Nothing Then
                '
                ' oDettaglioPaziente.Paziente.Attributi: creo la lista con attributi da database + campi di testata e la converto in XML 
                '
                oDettaglioPaziente.Paziente.Attributi = CreaAttributiEx(oDettaglioPaziente.Paziente, oDtPaz).ToXml
                '
                ' Creo la risposta paziente
                '
                oRispostaPaziente = New RispostaPaziente(sIdMessaggio _
                                                         , Messaggio.DataSequenza _
                                                         , iAzione _
                                                         , oDettaglioPaziente.Paziente _
                                                         , oDettaglioPaziente.Esenzioni _
                                                         , oDettaglioPaziente.Sinonimi _
                                                         , oDettaglioPaziente.Consensi _
                                                         , oPazienteFuso)


            Else
                Throw New Exception(String.Format("_GetRispostaPaziente2(): Il 'DettaglioPaziente' per l'anagrafica Utente={0} IdProvenienza={1} è NOTHING.", Messaggio.Utente, Messaggio.Paziente.Id))
                'oRispostaPaziente = New RispostaPaziente(sIdMessaggio _
                '                                         , Messaggio.DataSequenza _
                '                                         , iAzione _
                '                                         , Nothing _
                '                                         , Nothing _
                '                                         , Nothing _
                '                                         , Nothing _
                '                                         , Nothing)
            End If

            ' Ritorna risposta
            Return oRispostaPaziente

        Catch ex As Exception
            Throw New Exception("Errore durante GetRispostaPaziente()", ex)
        End Try

    End Function


#End Region

    Private Function GetDataDecesso(ByVal Messaggio As MessaggioPaziente) As DateTime
        Dim oRet As DateTime = Nothing
        If Messaggio.Paziente.CodiceTerminazione = "4" AndAlso Messaggio.Paziente.DataTerminazioneAss.HasValue Then
            oRet = Messaggio.Paziente.DataTerminazioneAss.Value
        End If
        Return oRet
    End Function

    Private Function GetAzioneFromTipo(ByVal Tipo As MessaggioTipo) As Integer
        'Questo lookup è identico a quello della orchestrazione che usava la DLL
        Dim iRet As Integer = 0
        Select Case Tipo
            Case MessaggioTipo.Modify
                iRet = 1
            Case MessaggioTipo.Delete
                iRet = 2
            Case MessaggioTipo.Merge
                iRet = 3
            Case Else
                iRet = 0
        End Select
        '
        ' Restituisco
        '
        Return iRet
    End Function


    ''' <summary>
    ''' Da usare per popolare il nodo fusione
    ''' </summary>
    ''' <param name="CurrConnection"></param>
    ''' <param name="CurrTransaction"></param>
    ''' <param name="Id"></param>
    ''' <returns></returns>
    Private Function GetPazienteDettaglio(ByVal CurrConnection As Data.SqlClient.SqlConnection,
                                          ByVal CurrTransaction As Data.SqlClient.SqlTransaction,
                                          ByVal Id As Guid) As PazientiDataSet.PazienteDettaglioDataTable
        Dim dt As PazientiDataSet.PazienteDettaglioDataTable = Nothing
        '
        ' Creo TableAdapters
        '
        Try
            Using ta = New PazientiDataSetTableAdapters.PazienteDettaglioTableAdapter
                ta.Connection = CurrConnection
                ta.Transaction = CurrTransaction
                dt = ta.GetData(Id)
            End Using
            '
            ' Restituisce il dettaglio del paziente
            '
            Return dt
        Catch ex As DataAccessException
            Throw ex

        Catch ex As Exception
            Throw New ArgumentException("Errore durante GetPazienteDettaglio()!", ex)

        End Try

    End Function

    ''' <summary>
    ''' Restituisce la lista dei sinonimi del paziente. In caso di fusione valorizzando IdPazienteFuso il suo sinonimo viene messo come primo della lista
    ''' </summary>
    ''' <param name="CurrConnection"></param>
    ''' <param name="CurrTransaction"></param>
    ''' <param name="IdPaziente"></param>
    ''' <param name="IdPazienteFuso"></param>
    ''' <returns></returns>
    Private Function GetSinonimi(ByVal CurrConnection As SqlConnection, ByVal CurrTransaction As SqlTransaction, ByVal IdPaziente As Guid, ByVal IdPazienteFuso As Guid?) As PazienteSinonimo()
        '
        ' Sinonimi
        '
        Dim oListSinonimi As New Generic.List(Of PazienteSinonimo)

        '--------------------------------------------------------------------------------------------------
        ' Sinonimi con provenienza SAC (il paziente fuso in testa se IdPazienteFuso <> Nothing)
        '--------------------------------------------------------------------------------------------------
        If IdPazienteFuso.HasValue AndAlso Not Guid.Equals(IdPaziente, IdPazienteFuso) Then
            oListSinonimi.Add(New PazienteSinonimo("SAC", IdPazienteFuso.ToString().ToUpper()))
        End If

        Dim dtSacSinonimi As PazientiDataSet.PazientiSinonimiByIdPazienteDataTable
        Dim rowSacSinonimi As PazientiDataSet.PazientiSinonimiByIdPazienteRow
        dtSacSinonimi = GetSinonimiByIdPaziente(CurrConnection, CurrTransaction, IdPaziente)
        '
        ' Aggiungo i sinonimi di tipo [SAC,IdSac]
        '
        For Each rowSacSinonimi In dtSacSinonimi
            Dim item As New PazienteSinonimo("SAC", rowSacSinonimi.IdPazienteFuso.ToString().ToUpper())
            If Not oListSinonimi.Contains(item) Then
                oListSinonimi.Add(item)
            End If
        Next
        '--------------------------------------------------------------------------------------------------

        '--------------------------------------------------------------------------------------------------
        ' Aggiungo i sinonimi di tipo [Provenienza,IdProvenienza]
        '--------------------------------------------------------------------------------------------------
        Dim dtSinonimi As PazientiDataSet.PazienteSinominiDataTable
        Dim rowSinonimi As PazientiDataSet.PazienteSinominiRow
        dtSinonimi = GetSinonimi(CurrConnection, CurrTransaction, IdPaziente)
        For Each rowSinonimi In dtSinonimi
            Dim oSinonimo = New PazienteSinonimo(rowSinonimi.Provenienza, rowSinonimi.IdProvenienza)
            oListSinonimi.Add(oSinonimo)
        Next
        '--------------------------------------------------------------------------------------------------
        '
        ' Converto da ArrayList in array tipizzato e restituisco
        '
        Return oListSinonimi.ToArray
    End Function


    ''' <summary>
    ''' Restituisce una lista di oggetti attributo a partire dalle colonne di oDt e dalla lista di esclusione
    ''' </summary>
    ''' <param name="oAttributi"></param>
    ''' <param name="oDt"></param>
    ''' <param name="oListNameToExclude"></param>
    ''' <returns></returns>
    Private Function BuildListaAttributi(ByVal oAttributi As System.Collections.Generic.List(Of Attributo), ByVal oDt As PazientiDataSet.PazienteDettaglioDataTable, ByVal oListNameToExclude As System.Collections.Generic.List(Of String)) As System.Collections.Generic.List(Of Attributo)

        Dim oRow As PazientiDataSet.PazienteDettaglioRow = oDt(0)
        '
        ' Aggiungo sempre di non usare il campo Paziente.Attributi
        '
        If Not oListNameToExclude.Contains("ATTRIBUTI") Then
            oListNameToExclude.Add("ATTRIBUTI")
        End If

        For Each column As DataColumn In oDt.Columns

            'Escludo i campi NULL
            If Not oRow(column).Equals(DBNull.Value) Then

                Dim sNomeColonna As String = column.ColumnName

                If Not oListNameToExclude.Contains(sNomeColonna.ToUpper) Then
                    Dim sNomeAttributo As String = sNomeColonna
                    Dim sValoreAttributo As String = String.Empty

                    Dim t As Type = oRow(column).GetType()

                    If t.Equals(GetType(String)) Then 'Varchar
                        sValoreAttributo = oRow(column).ToString

                    ElseIf t.Equals(GetType(Guid)) Then 'Uniqueidentifier
                        sValoreAttributo = oRow(column).ToString.ToUpper

                    ElseIf t.Equals(GetType(Byte)) Then 'Tinyint
                        sValoreAttributo = oRow(column).ToString

                    ElseIf t.Equals(GetType(Integer)) Then 'Int
                        sValoreAttributo = oRow(column).ToString

                    ElseIf t.Equals(GetType(DateTime)) Then 'DateTime
                        sValoreAttributo = System.Xml.XmlConvert.ToString(CType(oRow(column), DateTime), Xml.XmlDateTimeSerializationMode.Local)

                    ElseIf t.Equals(GetType(Boolean)) Then 'Bit
                        sValoreAttributo = oRow(column).ToString

                    Else
                        'Caso Tipo non gestito: non faccio nulla
                        sValoreAttributo = String.Empty
                    End If
                    '
                    ' Se sValoreAttributo è vuoto non aggiungo l'attributo alla lista degli attributi
                    ' sNomeAttributo è sempre valorizzato
                    '
                    If Not String.IsNullOrEmpty(sValoreAttributo) Then
                        oAttributi.Add(New Attributo(sNomeAttributo, sValoreAttributo))
                    End If
                End If
            End If
        Next
        '
        '
        '
        Return oAttributi
    End Function

    ''' <summary>
    ''' Aggiunge come attributi i campi di testata che non sono mappati nella classe PazienteFusoOut
    ''' </summary>
    ''' <param name="oPazienteFuso"></param>
    ''' <param name="oDt">I dati del record di dettaglio letto dal database</param>
    ''' <returns>La lista di attributi estesa: sAttributiOriginali + attributi creati dalle colonne di oDt che non sono già mappati nella classe "Fusione"</returns>
    Private Function CreaAttributiEx(ByVal oPazienteFuso As PazienteFusoOut, ByVal oDt As PazientiDataSet.PazienteDettaglioDataTable) As System.Collections.Generic.List(Of Attributo)
        Dim oListAttributi As New System.Collections.Generic.List(Of Attributo)
        '
        ' Aggiungo prima gli "attributi" già presenti nella classe "Fusione"
        '
        If Not String.IsNullOrEmpty(oPazienteFuso.Attributi) Then
            oListAttributi = oPazienteFuso.Attributi.ToListAttributi '=oDt(0).Attributi.ToAttributi
        End If
        '
        ' Creo una lista di esclusione con i nomi dei campi che non devo aggiungere agli attributi (perchè già presenti in testata nel nodo Fusione)
        '
        Dim oListExclude As New System.Collections.Generic.List(Of String)
        oListExclude.Add("ID")
        oListExclude.Add("PROVENIENZA")
        oListExclude.Add("IDPROVENIENZA")
        oListExclude.Add("CODICEFISCALE")
        oListExclude.Add("COGNOME")
        oListExclude.Add("NOME")
        oListExclude.Add("DATANASCITA")
        oListExclude.Add("SESSO")
        oListExclude.Add("TESSERA")
        oListExclude.Add("COMUNENASCITACODICE")
        oListExclude.Add("COMUNENASCITANOME")
        oListExclude.Add("NAZIONALITACODICE")
        oListExclude.Add("NAZIONALITANOME")
        oListExclude.Add("ATTRIBUTI")
        '
        ' Aggiungo i campi di testata alla lista di attributi
        '
        oListAttributi = BuildListaAttributi(oListAttributi, oDt, oListExclude)
        '
        '
        '
        Return oListAttributi
    End Function


    ''' <summary>
    ''' Aggiunge come attributi i campi di testata che non sono mappati nella classe PazienteOut
    ''' </summary>
    ''' <param name="oPaziente"></param>
    ''' <param name="oDt">I dati del record di dettaglio letto dal database</param>
    ''' <returns>La lista di attributi estesa: sAttributiOriginali + attributi creati dalle colonne di oDt che non sono già mappati nella testata della classe "PazienteOut"</returns>
    Private Function CreaAttributiEx(ByVal oPaziente As PazienteOut, ByVal oDt As PazientiDataSet.PazienteDettaglioDataTable) As System.Collections.Generic.List(Of Attributo)
        Dim oListAttributi As New System.Collections.Generic.List(Of Attributo)
        '
        ' Aggiungo prima gli "attributi paziente" letti da database
        '
        If Not String.IsNullOrEmpty(oPaziente.Attributi) Then
            oListAttributi = oPaziente.Attributi.ToListAttributi
        End If
        '
        ' Creo una lista di esclusione con i nomi dei campi che non devo aggiungere agli attributi (perchè già presenti in testata nel nodo Fusione)
        '
        Dim oListExclude As New System.Collections.Generic.List(Of String)
        oListExclude.Add("ID")
        oListExclude.Add("PROVENIENZA")
        oListExclude.Add("IDPROVENIENZA")
        oListExclude.Add("LIVELLOATTENDIBILITA")
        oListExclude.Add("CODICETERMINAZIONE")
        oListExclude.Add("DESCRIZIONETERMINAZIONE")
        oListExclude.Add("CODICEFISCALE")
        oListExclude.Add("COGNOME")
        oListExclude.Add("NOME")
        oListExclude.Add("DATANASCITA")
        oListExclude.Add("SESSO")
        oListExclude.Add("TESSERA")
        oListExclude.Add("COMUNENASCITACODICE")
        oListExclude.Add("COMUNENASCITANOME")
        oListExclude.Add("NAZIONALITACODICE")
        oListExclude.Add("NAZIONALITANOME")
        oListExclude.Add("DATADECESSO")
        oListExclude.Add("COMUNERESCODICE")
        oListExclude.Add("COMUNERESNOME")
        oListExclude.Add("INDIRIZZORES")
        oListExclude.Add("LOCALITARES")
        oListExclude.Add("CAPRES")
        oListExclude.Add("DATADECORRENZARES")
        oListExclude.Add("COMUNEDOMCODICE")
        oListExclude.Add("COMUNEDOMNOME")
        oListExclude.Add("INDIRIZZODOM")
        oListExclude.Add("LOCALITADOM")
        oListExclude.Add("CAPDOM")
        oListExclude.Add("COMUNERECAPITOCODICE")
        oListExclude.Add("COMUNERECAPITONOME")
        oListExclude.Add("INDIRIZZORECAPITO")
        oListExclude.Add("LOCALITARECAPITO")
        oListExclude.Add("TELEFONO1")
        oListExclude.Add("TELEFONO2")
        oListExclude.Add("TELEFONO3")
        oListExclude.Add("CODICESTP")
        oListExclude.Add("DATAINIZIOSTP")
        oListExclude.Add("DATAFINESTP")
        oListExclude.Add("MOTIVOANNULLOSTP")
        oListExclude.Add("POSIZIONEASS")
        oListExclude.Add("DATAINIZIOASS")
        oListExclude.Add("DATASCADENZAASS")
        oListExclude.Add("DATATERMINAZIONEASS")
        oListExclude.Add("CODICEASLRES")
        oListExclude.Add("REGIONERESCODICE")
        oListExclude.Add("COMUNEASLRESCODICE")
        oListExclude.Add("CODICEASLASS")
        oListExclude.Add("REGIONEASSCODICE")
        oListExclude.Add("COMUNEASLASSCODICE")
        oListExclude.Add("CODICEMEDICODIBASE")
        oListExclude.Add("CODICEFISCALEMEDICODIBASE")
        oListExclude.Add("COGNOMENOMEMEDICODIBASE")
        oListExclude.Add("DISTRETTOMEDICODIBASE")
        oListExclude.Add("DATASCELTAMEDICODIBASE")
        oListExclude.Add("SUBCOMUNERES")
        oListExclude.Add("ASLRESNOME")
        oListExclude.Add("REGIONERESNOME")
        oListExclude.Add("SUBCOMUNEDOM")
        oListExclude.Add("REGIONEASSNOME")
        oListExclude.Add("ASLASSNOME")
        oListExclude.Add("DISTRETTOAMM")
        oListExclude.Add("DISTRETTOTER")
        oListExclude.Add("AMBITO")
        oListExclude.Add("ATTRIBUTI")
        '
        ' Aggiungo i campi di testata alla lista di attributi
        '
        oListAttributi = BuildListaAttributi(oListAttributi, oDt, oListExclude)
        '
        '
        '
        Return oListAttributi
    End Function

End Class

