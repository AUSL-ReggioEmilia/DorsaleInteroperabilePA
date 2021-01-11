<System.ComponentModel.DataObject(True)> _
Public Class Enumerazioni

    <System.ComponentModel.DataObjectMethod(ComponentModel.DataObjectMethodType.Select)>
    Public Function GetMotiviAccesso() As EnumerazioniDataset.FevsMotiviAccessoListaDataTable
        Using ta As New EnumerazioniDatasetTableAdapters.FevsMotiviAccessoListaTableAdapter
            ta.Connection = SqlConnection
            Return ta.GetData()
        End Using
        Return Nothing
    End Function

End Class
