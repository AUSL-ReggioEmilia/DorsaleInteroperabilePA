Partial Class EtichettePrenotazioniDataSet
End Class

Namespace EtichettePrenotazioniDataSetTableAdapters

    Partial Public Class WsJobEtichettePrenotazioniListTableAdapter
        Public Sub New(ByVal ConnectionString As String)
            MyBase.New()
            Me.Connection.ConnectionString = ConnectionString
        End Sub
    End Class

    Partial Public Class WsJobEtichettePrenotazioniSelectTableAdapter
        Public Sub New(ByVal ConnectionString As String)
            MyBase.New()
            Me.Connection.ConnectionString = ConnectionString
        End Sub
    End Class


    Partial Public Class QueriesTableAdapter
        Public Sub New(ByVal ConnectionString As String)
            MyBase.New()
            For Each Command As System.Data.IDbCommand In Me.CommandCollection()
                Command.Connection.ConnectionString = ConnectionString
            Next
        End Sub
    End Class

    Partial Public Class WsJobEtichettePrenotazioniAgendeListTableAdapter
        Public Sub New(ByVal ConnectionString As String)
            MyBase.New()
            Me.Connection.ConnectionString = ConnectionString
        End Sub
    End Class

    Partial Public Class WsJobEtichettePrenotazioniPrintReportTableAdapter
        Public Sub New(ByVal ConnectionString As String)
            MyBase.New()
            Me.Connection.ConnectionString = ConnectionString
        End Sub
    End Class

    Partial Public Class WsRuoliEtichettePrenotazioniListTableAdapter
        Public Sub New(ByVal ConnectionString As String)
            MyBase.New()
            Me.Connection.ConnectionString = ConnectionString
        End Sub
    End Class


End Namespace