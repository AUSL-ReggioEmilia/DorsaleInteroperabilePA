Partial Class ConfigurazioniDataSet
End Class



Namespace ConfigurazioniDataSetTableAdapters

    Partial Public Class ConfigurazioniOttieniBySessioneTableAdapter

        Public Sub New(ByVal ConnectionString As String)
            MyBase.New()

            For Each cmdQuery As SqlClient.SqlCommand In Me.CommandCollection
                cmdQuery.Connection.ConnectionString = ConnectionString
            Next
        End Sub

    End Class

    Partial Public Class ConfigurazioneMenuListaTableAdapter

        Public Sub New(ByVal ConnectionString As String)
            MyBase.New()

            For Each cmdQuery As SqlClient.SqlCommand In Me.CommandCollection
                cmdQuery.Connection.ConnectionString = ConnectionString
            Next
        End Sub

    End Class

End Namespace