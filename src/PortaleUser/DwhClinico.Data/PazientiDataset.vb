Partial Class PazientiDataset
End Class

Namespace PazientiDatasetTableAdapters

    Partial Public Class FevsPazientiAccessiListaTableAdapter

        Public Sub New(ByVal CommandTimeout As Integer)
            MyBase.New()
            Me.ClearBeforeFill = True

            For Each cmdQuery As SqlClient.SqlCommand In Me.CommandCollection
                cmdQuery.CommandTimeout = CommandTimeout
            Next
        End Sub

    End Class

End Namespace
