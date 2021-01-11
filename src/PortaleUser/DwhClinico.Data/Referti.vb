Imports System.web

<System.ComponentModel.DataObject(True)>
Public Class Referti

    ''' <summary>
    ''' NUOVA: sostituisce quella fatta con l'adapter in DataManager.vb 
    ''' </summary>
    ''' <param name="IdReferto"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Function RefertoStiliDisponibili(ByVal IdReferto As Guid) As RefertiDataSet.RefertoStiliDisponibiliDataTable
        Using ta As New RefertiDataSetTableAdapters.RefertoStiliDisponibiliTableAdapter
            ta.Connection = SqlConnection
            Return ta.GetData(IdReferto)
        End Using
    End Function

    ''' <summary>
    ''' Crea il record di oscuramento e comanda il ricalcolo dell'anteprima
    ''' </summary>
    ''' <param name="Idreferto"></param>
    ''' <remarks></remarks>
    Public Sub CancellazioneRefertoDettaglioUpdate(ByVal IdReferto As Guid, ByVal Account As String)
        Using ta As New RefertiCancellaDatasetTableAdapters.FevsCancellazioneRefertoAggiornaTableAdapter
            ta.Connection = SqlConnection
            '
            ' Crea il record di oscuramento e comanda il ricalcolo dell'anteprima
            '
            ta.GetData(IdReferto, Account)
        End Using
    End Sub

    Public Function AggiungiNote(ByVal IdReferti As Guid,
                                    ByVal Utente As String,
                                    ByVal Note As String) As RefertiDataSet.FevsRefertiNoteAggiungiDataTable
        '
        ' Controllo il tipo data
        '
        Dim taRefertiNoteAggiungi As New RefertiDataSetTableAdapters.FevsRefertiNoteAggiungiTableAdapter
        taRefertiNoteAggiungi.Connection = SqlConnection

        Return taRefertiNoteAggiungi.GetData(IdReferti, Utente, Note)

    End Function

    Public Function CancellaNote(ByVal IdNote As Guid) As RefertiDataSet.FevsRefertiNoteCancellaDataTable
        '
        ' Controllo il tipo data
        '
        Dim taRefertiNoteCancella As New RefertiDataSetTableAdapters.FevsRefertiNoteCancellaTableAdapter
        taRefertiNoteCancella.Connection = SqlConnection

        Return taRefertiNoteCancella.GetData(IdNote)

    End Function

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select)>
    Public Function GetDataRefertiNoteLista(ByVal IdReferto As Guid) As RefertiDataSet.FevsRefertiNoteListaDataTable

        If IdReferto <> Guid.Empty Then
            '
            ' Ricerca i dati e restituisce una datatable
            '
            Dim taNoteReferti As New RefertiDataSetTableAdapters.FevsRefertiNoteListaTableAdapter

            taNoteReferti.Connection = SqlConnection
            Return taNoteReferti.GetData(IdReferto)
        Else
            Return Nothing
        End If

    End Function

End Class
