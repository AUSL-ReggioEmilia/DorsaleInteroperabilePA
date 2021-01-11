Public Class Allegati

    ''' <summary>
    ''' Restituisce l'elenco degli allegati di un referto
    ''' </summary>
    ''' <param name="IdReferto"></param>
    ''' <param name="MimeType">Può essere nothing</param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Function AllegatiRefertoLista(ByVal IdReferto As Guid, ByVal MimeType As String) As AllegatiDataSet.FevsAllegatiRefertoDataTable
        Dim ta As New AllegatiDataSetTableAdapters.FevsAllegatiRefertoTableAdapter
        ta.Connection = SqlConnection
        Dim oAllegati As AllegatiDataSet.FevsAllegatiRefertoDataTable = ta.GetData(IdReferto, MimeType)
        '
        ' Filtro quei record che non hanno i dati binary bel campo MimeData
        '
        For Each oAllegato As AllegatiDataSet.FevsAllegatiRefertoRow In oAllegati
            If oAllegato.IsMimeDataNull OrElse oAllegato.MimeData.GetLength(0) = 0 Then
                oAllegato.Delete()
            End If
        Next
        oAllegati.AcceptChanges()
        '
        '
        '
        Return oAllegati
    End Function

    ''' <summary>
    ''' Spostata dal DataManager.VB
    ''' </summary>
    ''' <param name="IdAllegato"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Function ApreAllegatoFill(ByVal IdAllegato As Guid) As AllegatiDataSet.FevsApreAllegatoContentDataTable
        Dim oAllegato As AllegatiDataSet.FevsApreAllegatoContentDataTable = Nothing
        Using ta As New AllegatiDataSetTableAdapters.FevsApreAllegatoContentTableAdapter
            ta.Connection = SqlConnection
            oAllegato = ta.GetData(IdAllegato)
        End Using
        Return oAllegato
    End Function

End Class
