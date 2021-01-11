<System.ComponentModel.DataObject(True)>
Public Class Pazienti


    ' utilizzata nello UserControl ucTestataPaziente per ottenere la lista degli ultimi accessi ai dati di un paziente.
    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select)>
    Public Function GetDataPazientiAccessiLista(ByVal IdPaziente As Guid) As PazientiDataset.FevsPazientiAccessiListaDataTable
        Const COMMAND_TIMEOUT As Integer = 120 'secondi
        Dim dtLista As PazientiDataset.FevsPazientiAccessiListaDataTable = Nothing
        Using ta As New PazientiDatasetTableAdapters.FevsPazientiAccessiListaTableAdapter(COMMAND_TIMEOUT)
            '
            ' Connessione
            '
            ta.Connection = SqlConnection
            dtLista = ta.GetData(IdPaziente)
        End Using
        '
        ' Ritorna
        '
        Return dtLista

    End Function



#Region "Patient Summary"
    ''' <summary>
    ''' Da chiamare per ottenere lo stato del Patient summary (se valido e se presente il PDF)
    ''' </summary>
    ''' <param name="IdPaziente"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Function GetPatientSummaryStato(ByVal IdPaziente As Guid) As PazientiDataset.FevsPazientiPatientSummaryStatoDataTable
        Using ta As New PazientiDatasetTableAdapters.FevsPazientiPatientSummaryStatoTableAdapter
            ta.Connection = SqlConnection
            Return ta.GetData(IdPaziente)
        End Using
    End Function

    ''' <summary>
    ''' Da chiamare per ottenere i dati relativi al patient summary
    ''' </summary>
    ''' <param name="IdPaziente"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Function PatientSummaryOttieni(ByVal IdPaziente As Guid) As PazientiDataset.FevsPazientiPatientSummaryOttieniDataTable
        Using ta As New PazientiDatasetTableAdapters.FevsPazientiPatientSummaryOttieniTableAdapter
            ta.Connection = SqlConnection
            Return ta.GetData(IdPaziente)
        End Using
    End Function

    ''' <summary>
    ''' Da chiamare per aggiornare i dati del patient summary del paziente
    ''' </summary>
    ''' <param name="IdPaziente"></param>
    ''' <param name="Pdf"></param>
    ''' <param name="Errore"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Function PatientSummaryAggiorna(ByVal IdPaziente As Guid, ByVal Pdf As Byte(), ByVal Errore As String) As PazientiDataset.FevsPazientiPatientSummaryAggiornaDataTable
        Using ta As New PazientiDatasetTableAdapters.FevsPazientiPatientSummaryAggiornaTableAdapter
            ta.Connection = SqlConnection
            Return ta.GetData(IdPaziente, Pdf, Errore)
        End Using
    End Function

#End Region


    ''' <summary>
    ''' MODIFICA ETTORE 2015-06-05: SOSTITUISCE L'EQUIVALENTE FUNZIONE NEL DATAMANAGER.VB
    ''' </summary>
    ''' <param name="IdPazientiBase">Il paziente da cancellare logicamente</param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Function CancellazionePazienteAggiungi(ByVal IdPazientiBase As Guid, ByVal Utente As String) As Boolean
        '
        ' Questa funzione scrive il paziente cancellato nella tabella dei pazienti cancellati
        '
        Dim dt As PazientiCancellaDataset.CancellazionePazienteAggiungiDataTable = Nothing
        Using ta As New PazientiCancellaDatasetTableAdapters.CancellazionePazienteAggiungiTableAdapter
            ta.Connection = SqlConnection
            dt = ta.GetData(IdPazientiBase, Utente)
            If Not dt Is Nothing AndAlso dt.Rows.Count > 0 Then
                Return True
            End If
        End Using
        Return False
    End Function

End Class
