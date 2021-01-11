Public Class Istat
    Private msComuneNascitaCodice As String = String.Empty
    Private msComuneResCodice As String = String.Empty
    Private msComuneDomCodice As String = String.Empty
    Private msComuneRecapitoCodice As String = String.Empty
    Private mdDataNascita As DateTime? = Nothing
    Private msUtente As String = String.Empty
    Private msIdProvenienza As String = String.Empty
    Private miIstatErrorCode As Integer = 0 'nessun errore
    Private StringConnection As String = String.Empty


    ''' <summary>
    ''' 
    ''' </summary>
    ''' <param name="Utente"></param>
    ''' <param name="Paziente"></param>
    ''' <remarks></remarks>
    Public Sub New(ByVal Utente As String, ByVal Paziente As DataAccess.Paziente, ByVal StringConnection As String)
        '
        ' Inizializzo le variabili che mi interessano
        '
        msUtente = Utente
        msIdProvenienza = Paziente.Id & String.Empty
        msComuneNascitaCodice = Paziente.ComuneNascitaCodice & String.Empty
        msComuneResCodice = Paziente.ComuneResCodice & String.Empty
        msComuneDomCodice = Paziente.ComuneDomCodice & String.Empty
        msComuneRecapitoCodice = Paziente.ComuneRecapitoCodice & String.Empty ' per ora questo non viene verificato dalla SP
        mdDataNascita = Paziente.DataNascita

        Me.StringConnection = StringConnection
    End Sub

    ''' <summary>
    ''' Verifica la coerenza dei codici istat dei comuni
    ''' </summary>
    ''' <returns>Codice di errore</returns>
    ''' <remarks></remarks>
    Public Function VerificaCodiciIstat() As Integer
        '
        ' Verifico i codici ISTAT
        '

        Using ota As New IstatDataSetTableAdapters.IstatMsgIncoerenzaIstatVerificaTableAdapter
            ota.Connection = New System.Data.SqlClient.SqlConnection(Me.StringConnection)
            '
            ' Eseguo la verifica istat
            '
            Using dt As DataAccess.IstatDataSet.IstatMsgIncoerenzaIstatVerificaDataTable = ota.GetData(msUtente, msComuneNascitaCodice, msComuneResCodice, msComuneDomCodice, msComuneRecapitoCodice, mdDataNascita)
                '
                ' La SP restituisce i seguenti codici di errore:
                ' 0: OK
                ' 5000: codice comune nascita non valido
                ' 5001: codice comune residenza non valido
                ' 5002: codice comune domicilio non valido
                ' 5003: codice comune recapito non valido
                '
                If Not dt Is Nothing AndAlso dt.Rows.Count > 0 Then
                    miIstatErrorCode = dt(0).ERROR_CODE
                End If
            End Using
        End Using
        '
        ' Restituisco il codice di errore
        '
        Return miIstatErrorCode
    End Function

    Public Function BuildIstatErrorMessage() As String
        Dim sRet As String = String.Empty
        Select Case miIstatErrorCode
            Case 0
                sRet = String.Empty
            Case 5000
                sRet = String.Format("Errore di incoerenza istat su comune {0}. Codice comune '{1}'.", "nascita", msComuneNascitaCodice)
            Case 5001
                sRet = String.Format("Errore di incoerenza istat su comune {0}. Codice comune '{1}'.", "residenza", msComuneResCodice)
            Case 5002
                sRet = String.Format("Errore di incoerenza istat su comune {0}. Codice comune '{1}'.", "domicilio", msComuneDomCodice)
            Case 5003
                sRet = String.Format("Errore di incoerenza istat su comune {0}. Codice comune '{1}'.", "recapito", msComuneRecapitoCodice)
            Case Else
                'codice di errore sconosciuto scrivo il numero restituito dalla Stored Procedure
                sRet = String.Format("Errore di incoerenza istat: codice di errore {0}.", miIstatErrorCode)
        End Select
        '
        ' Restituisco il messaggio di errore 
        '
        Return sRet
    End Function

    Public Sub IncoerenzaIstatInsert(sGeneratoDa As String)
        'sGeneratoDa = MSG Paziente, MSG Consensi
        Dim sCodiceComune As String = String.Empty
        Dim sTipoComune As String = String.Empty
        Select Case miIstatErrorCode
            Case 5000
                sCodiceComune = msComuneNascitaCodice
                sTipoComune = ("nascita")
            Case 5001
                sCodiceComune = msComuneResCodice
                sTipoComune = "residenza"
            Case 5002
                sCodiceComune = msComuneDomCodice
                sTipoComune = "domicilio"
            Case 5003
                sCodiceComune = msComuneRecapitoCodice
                sTipoComune = "recapito"
            Case Else
                'codice di errore sconosciuto scrivo il numero restituito dalla Stored Procedure
                sCodiceComune = String.Empty
                sTipoComune = String.Empty
        End Select
        '
        ' Ora inserisco nel datatabase il record di log
        '
        Using ota As New IstatDataSetTableAdapters.IstatMsgIncoerenzaIstatInsertTableAdapter
            ota.Connection = New System.Data.SqlClient.SqlConnection(Me.StringConnection)
            '
            ' Eseguo l'inserimento
            '
            Call ota.GetData(msUtente, msIdProvenienza, sCodiceComune, sGeneratoDa, String.Format("Comune {0} incoerente", sTipoComune))
        End Using
    End Sub


    ''' <summary>
    ''' Normalizza i codici Istat dei comuni eseguendo il corretto padding di "0" a sinistra
    ''' </summary>
    ''' <param name="Paziente"></param>
    ''' <remarks></remarks>
    Public Shared Sub NormalizzazioneCodiciIstat(Paziente As DataAccess.Paziente)
        '
        ' Normalizzo i codici dei comuni
        '
        Paziente.ComuneNascitaCodice = NormalizzaCodiceIstatComune(Paziente.ComuneNascitaCodice)
        Paziente.ComuneResCodice = NormalizzaCodiceIstatComune(Paziente.ComuneResCodice)
        Paziente.ComuneDomCodice = NormalizzaCodiceIstatComune(Paziente.ComuneDomCodice)
        Paziente.ComuneRecapitoCodice = NormalizzaCodiceIstatComune(Paziente.ComuneRecapitoCodice)
        '
        ' Di seguito potrei normalizzare altri codici istat
        '
    End Sub

    ''' <summary>
    ''' Esegue padding di zeri a sinistra e rimuove i "999" all'inizio
    ''' </summary>
    ''' <param name="Codice"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Private Shared Function NormalizzaCodiceIstatComune(ByVal Codice As String) As String
        Dim sRet As String = Codice
        Try
            ' FONDAMENTALE: Lo trasformo eventualmente in stringa vuota
            sRet = sRet & ""
            ' Padding di "0" a sinistra. Deve essere di sei caratteri al max
            sRet = sRet.PadLeft(6, "0"c)
            ' Ora il codice è sempre di 6 caratteri
            ' Rimuovo eventuali "999" all'inizio e rifaccio il padding
            If sRet.Substring(0, 3) = "999" Then
                'Prendo gli ultimi 3
                sRet = sRet.Substring(3, 3)
                sRet = sRet.PadLeft(6, "0"c)
            End If
            '
            ' Restituisco
            '
            Return sRet
        Catch ex As Exception
            LogEvent.WriteError(ex, String.Format("Errore durante normalizzazione del codice istat comune '{0}'. Il processamento dell'anagrafica continua.", Codice))
            Return Codice
        End Try
    End Function



End Class
