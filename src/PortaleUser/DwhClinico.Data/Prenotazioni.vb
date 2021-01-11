Public Class Prenotazioni
    '
    ' Testata con i dati della Prenotazione
    ' Usa la stessa SP che restituisce la testata del ricovero cioè "FevsRicoveroTestata"
    ' Solo table adapter/data table sono stati rinominati "FevsPrenotazioneTestataDataTable e "FevsPrenotazioneTestataTableAdapter
    ' IdPrenotazione è un Id della tabella Ricoveri
    '
    Public Function PrenotazioneTestata(ByVal IdPrenotazione As Guid) As PrenotazioniDataSet.FevsPrenotazioneTestataDataTable
        Dim ta As New PrenotazioniDataSetTableAdapters.FevsPrenotazioneTestataTableAdapter
        ta.Connection = SqlConnection
        Return ta.GetData(IdPrenotazione)
    End Function
    '
    ' ATTENZIONE: IdPrenotazione è un Id della tabella Ricoveri
    '
    Public Function GetPrenotazioneDettaglio(ByVal IdPrenotazione As Guid) As Data.PrenotazioniDataSet.FevsPrenotazioniDettaglioDataTable

        Dim oIdPrenotazione As System.Nullable(Of Guid) = Nothing
        Try
            If IdPrenotazione <> Guid.Empty Then
                '
                ' Imposto Id del paziente
                '
                oIdPrenotazione = IdPrenotazione
                '
                ' Eseguo la query
                '
                Using ta As New PrenotazioniDataSetTableAdapters.FevsPrenotazioniDettaglioTableAdapter
                    ta.Connection = SqlConnection
                    Dim oDataTable As PrenotazioniDataSet.FevsPrenotazioniDettaglioDataTable
                    oDataTable = ta.GetData(oIdPrenotazione)
                    Return oDataTable
                End Using
            Else
                Throw New Exception("Il parametro IdPrenotazione è obbligatorio.")
            End If

        Catch ex As Exception
            Logging.WriteError(ex, "Si è verificato un errore durante la lettura dei dati in GetPrenotazioneDettaglio()")
            Throw ex
        End Try
        '
        ' Se sono qui si è verificato un errore
        '
        Return Nothing

    End Function


End Class
