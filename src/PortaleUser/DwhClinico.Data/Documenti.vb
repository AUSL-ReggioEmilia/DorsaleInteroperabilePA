Public Class Documenti
    ''' <summary>
    ''' Restituisce info sul documento associato al sistema erogante
    ''' </summary>
    ''' <param name="AziendaErogante"></param>
    ''' <param name="SistemaErogante"></param>
    ''' <returns></returns>
    ''' <remarks>Usata in Referti\RefertiDettaglio.aspx</remarks>
    Public Function GetDataSistemiErogantiDocumenti(ByVal AziendaErogante As String, ByVal SistemaErogante As String) As DocumentiDataSet.FevsSistemiErogantiDocumentiDataTable
        Using ta As New DocumentiDataSetTableAdapters.FevsSistemiErogantiDocumentiTableAdapter
            ta.Connection = SqlConnection
            Return ta.GetData(AziendaErogante, SistemaErogante)
        End Using
    End Function

    ''' <summary>
    ''' Restituisce la data tabel contenente le info sul singolo documento per visualizzarlo nel browser
    ''' </summary>
    ''' <param name="IdDocumento"></param>
    ''' <returns></returns>
    ''' <remarks>Usata in DwhClinico.Web\DocumentViewer.ashx (anche se segna 0 references)</remarks>
    Public Function GetDataSistemiErogantiDocumento(ByVal IdDocumento As Guid) As DocumentiDataSet.FevsGetDocumentoSistemiErogantiDataTable
        Using ta As New DocumentiDataSetTableAdapters.FevsGetDocumentoSistemiErogantiTableAdapter
            ta.Connection = SqlConnection
            Return ta.GetData(IdDocumento)
        End Using
    End Function

End Class
