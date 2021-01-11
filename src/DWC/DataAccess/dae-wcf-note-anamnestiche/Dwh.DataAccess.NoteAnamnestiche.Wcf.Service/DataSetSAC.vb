Imports System.Data

Partial Class DataSetSAC
End Class

Namespace DataSetSACTableAdapters

    Partial Public Class PazientiOutputCercaAggancioPazienteTableAdapter

        Public Sub New(Conn As SqlClient.SqlConnection, Optional Trans As SqlClient.SqlTransaction = Nothing)
            MyBase.New()

            For Each QueryCommand In Me.CommandCollection
                QueryCommand.Connection = Conn
                If Trans IsNot Nothing Then
                    QueryCommand.Transaction = Trans
                End If
            Next
        End Sub
    End Class

End Namespace
