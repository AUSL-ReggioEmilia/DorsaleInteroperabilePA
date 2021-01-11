Imports System.Data

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

    Partial Public Class ListaReportTableAdapter

        Public Sub New(ByVal ConnectionString As String)
            MyBase.New()

            For Each cmdQuery As SqlClient.SqlCommand In Me.CommandCollection
                cmdQuery.Connection.ConnectionString = ConnectionString
            Next
        End Sub

    End Class

    Partial Public Class ConfigurazioneMenuLista1TableAdapter

        Public Sub New(ByVal ConnectionString As String)
            MyBase.New()

            For Each cmdQuery As SqlClient.SqlCommand In Me.CommandCollection
                cmdQuery.Connection.ConnectionString = ConnectionString
            Next
        End Sub

    End Class

End Namespace