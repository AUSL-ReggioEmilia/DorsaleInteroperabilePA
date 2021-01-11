Partial Class AnteprimaPazientiDataSet
End Class


Namespace AnteprimaPazientiDataSetTableAdapters

    Partial Public Class QueriesTableAdapter

        Public Sub New(ByVal ConnectionString As String)
            MyBase.New()
            For Each cmdQuery As SqlClient.SqlCommand In Me.CommandCollection
                cmdQuery.Connection.ConnectionString = ConnectionString
            Next
        End Sub

    End Class

End Namespace
