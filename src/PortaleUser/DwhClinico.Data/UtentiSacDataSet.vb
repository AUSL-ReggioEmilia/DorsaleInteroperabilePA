Partial Class UtentiSacDataSet
End Class

Namespace UtentiSacDataSetTableAdapters

    Partial Public Class UtentiTableAdapter

        Public Sub New(ByVal ConnectionString As String)
            MyBase.New()
            Me.ClearBeforeFill = True

            For Each cmdQuery As SqlClient.SqlCommand In Me.CommandCollection
                cmdQuery.Connection = New SqlClient.SqlConnection(ConnectionString)
            Next
        End Sub

    End Class
End Namespace

