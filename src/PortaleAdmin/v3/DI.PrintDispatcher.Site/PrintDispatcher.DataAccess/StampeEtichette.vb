Partial Class StampeEtichette

End Class

Namespace StampeEtichetteTableAdapters
    
    Partial Public Class WsStampeEtichetteTableAdapter

        Public Sub New(ByVal ConnectionString As String)
            MyBase.New()
            Me.Connection.ConnectionString = ConnectionString
        End Sub

    End Class

    'Partial Public Class QueriesTableAdapter

    '    Public Sub New(ByVal ConnectionString As String)
    '        MyBase.New()

    '        For Each Command As System.Data.IDbCommand In Me.CommandCollection()
    '            Command.Connection.ConnectionString = ConnectionString
    '        Next
    '    End Sub

    'End Class


    Partial Public Class WsStampeEtichetteRePrintTableAdapter

        Public Sub New(ByVal ConnectionString As String)
            MyBase.New()
            Me.Connection.ConnectionString = ConnectionString
        End Sub

    End Class


    'WsStampeEtichette2TableAdapter
    Partial Public Class WsStampeEtichette2TableAdapter

        Public Sub New(ByVal ConnectionString As String)
            MyBase.New()
            Me.Connection.ConnectionString = ConnectionString
        End Sub

    End Class


    Partial Public Class WsStampeEtichetteDocumentTableAdapter
        Public Sub New(ByVal ConnectionString As String)
            MyBase.New()
            Me.Connection.ConnectionString = ConnectionString
        End Sub

    End Class


    Partial Public Class WsStampeEtichettePrintOnComputerTableAdapter
        Public Sub New(ByVal ConnectionString As String)
            MyBase.New()
            Me.Connection.ConnectionString = ConnectionString
        End Sub

    End Class

End Namespace


