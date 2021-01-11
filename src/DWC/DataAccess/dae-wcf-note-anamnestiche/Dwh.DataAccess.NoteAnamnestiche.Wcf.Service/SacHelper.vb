Imports System.Data
Imports Dwh.DataAccess.Wcf.Types.NoteAnamnestiche

Public Class SacHelper

    ''' <summary>
    ''' CERCA O INSERIECE IL PAZIENTE, RITORNA IL SUO ID IN IDPaziente
    ''' </summary>
    Public Shared Function PazientiOutputCercaAggancioPaziente(NotaAnamnestica As NotaAnamnesticaType) As Guid
        Dim guidIDPaziente As Guid = Guid.Empty
        '
        ' VALORIZZO ALCUNI PARAMETRI PER LA STORED PROCEDURE
        '
        '
        ' Impostazione di anagrafica e codiceanagrafica per la ricerca
        '
        'TODO: verificare se la gestione del nome dell'anagrafica di ricerca è corretta (nei referti avevamo fatto una SP che restituisce il nome dell'anagrafica di ricerca)
        Dim ProvenienzaDiRicerca As String = Nothing
        Dim IdProvenienzaDiRicerca As String = Nothing
        If Not NotaAnamnestica.Paziente Is Nothing Then
            If Not String.IsNullOrEmpty(NotaAnamnestica.Paziente.NomeAnagrafica) Then
                ProvenienzaDiRicerca = NotaAnamnestica.Paziente.NomeAnagrafica 'uso il nome dell'anagrafica
            End If
            If Not String.IsNullOrEmpty(NotaAnamnestica.Paziente.CodiceAnagrafica) Then
                IdProvenienzaDiRicerca = NotaAnamnestica.Paziente.CodiceAnagrafica 'uso il codice dell'anagrafica
            End If
        End If
        '
        ' La proveniena di inserimento è determinata dall'utente con cui la DAE si collega al SAC (vedi stringa di connessione: dovrebbe essere SAC_DWC)
        '
        Dim IdProvenienzaDiInserimento As String = Guid.NewGuid().ToString 'per il codice anagrafica in caso di inserimento genero un nuovo GUID
        Dim Tessera As String = NotaAnamnestica.Paziente.TesseraSanitaria
        Dim Cognome As String = NotaAnamnestica.Paziente.Cognome
        Dim Nome As String = NotaAnamnestica.Paziente.Nome
        Dim DataNascita As DateTime? = NotaAnamnestica.Paziente.DataNascita
        Dim Sesso As String = Nothing
        Dim ComuneNascitaCodice As String = Nothing
        Dim NazionalitaCodice As String = Nothing
        Dim CodiceFiscale As String = NotaAnamnestica.Paziente.CodiceFiscale
        '-- Dati di residenza
        Dim ComuneResCodice As String = Nothing
        Dim SubComuneRes As String = Nothing
        Dim IndirizzoRes As String = Nothing
        Dim LocalitaRes As String = Nothing
        Dim CapRes As String = Nothing
        '-- Dati di domicilio
        Dim ComuneDomCodice As String = Nothing
        Dim SubComuneDom As String = Nothing
        Dim IndirizzoDom As String = Nothing
        Dim LocalitaDom As String = Nothing
        Dim CapDom As String = Nothing
        '-- Altri dati
        Dim IndirizzoRecapito As String = Nothing
        Dim LocalitaRecapito As String = Nothing
        Dim Telefono1 As String = Nothing
        Dim Telefono2 As String = Nothing
        Dim Telefono3 As String = Nothing
        Dim oConn As New SqlClient.SqlConnection(My.Settings.SACConnectionString)
        Try
            If Not String.IsNullOrEmpty(NotaAnamnestica.Paziente.ComuneNascitaCodice) Then
                ComuneNascitaCodice = NotaAnamnestica.Paziente.ComuneNascitaCodice
            End If
            '
            ' Apertura connessione SENZA transazione
            '
            Try
                oConn.Open()
            Catch ex As Exception
                Throw New Exception(String.Concat("DAE NoteAnamnestiche: ", ERRORE_APERTURA_CONNESSIONE, vbCrLf, "Database SAC", vbCrLf, ex.Message))
            End Try
            '
            '
            '
            Using ta As New DataSetSACTableAdapters.PazientiOutputCercaAggancioPazienteTableAdapter(oConn)
                Dim dt = ta.GetData(ProvenienzaDiRicerca, IdProvenienzaDiRicerca, IdProvenienzaDiInserimento, Tessera, Cognome, Nome, DataNascita, Sesso, ComuneNascitaCodice, NazionalitaCodice, CodiceFiscale, ComuneResCodice, SubComuneRes, IndirizzoRes, LocalitaRes, CapRes, ComuneDomCodice, SubComuneDom, IndirizzoDom, LocalitaDom, CapDom, IndirizzoRecapito, LocalitaRecapito, Telefono1, Telefono2, Telefono3)
                If dt.Count = 0 Then
                    'Come nella DAE dei Referti in questo caso si passa idPaziente=”00000000-0000-0000-0000-000000000000”
                    guidIDPaziente = Guid.Empty ' questo viene passato all'esterno ByRef
                    Dim sMsg As String = String.Concat("DAE NoteAnamnestiche: mancano i dati anagrafici minimi per associare la nota anamnestica al paziente.", vbCrLf, NotaAnamnestica.Descrizione)
                    sMsg = String.Concat(sMsg, vbCrLf,
                                         String.Format("L'IdPaziente verrà valorizzato con '{0}'. Il processamento della nota anamnestica continua!.", guidIDPaziente.ToString)
                                         )
                    Log.WriteWarning(sMsg) 'questo lo scrivo anche nell'event log come warning
                    Log.TraceWriteLine(sMsg, TraceLevel.Warning.ToString, TraceLevel.Warning.ToString)
                Else
                    guidIDPaziente = dt(0).Id
                End If
            End Using

        Catch ex As CustomException
            ' LE CustomException PASSANO AL CHIAMANTE
            Throw

        Catch ex As Exception
            If ex.Message.ToUpper.Contains("PARAMETRI DI INSERIMENTO NON VALIDI") Then
                '
                ' Gestisco l'eccezione generata dalla SP "PazientiOutputCercaAggancioPaziente"
                '
                Dim sErrMsg As String = String.Concat("DAE NoteAnamnestiche: errore PazientiOutputCercaAggancioPaziente.", vbCrLf, NotaAnamnestica.Descrizione, vbCrLf, ex.Message)
                Throw New CustomException(sErrMsg, ErrorCodes.ErroreSAC) 'L'orchestrazione verrà sospesa
            Else
                '
                ' Tutti gli altri errori passano al chiamante
                '
                Throw
            End If
        Finally
            If oConn IsNot Nothing AndAlso oConn.State = ConnectionState.Open Then
                oConn.Close()
            End If
        End Try
        '
        ' Restituisco
        '
        Return guidIDPaziente
    End Function


End Class
