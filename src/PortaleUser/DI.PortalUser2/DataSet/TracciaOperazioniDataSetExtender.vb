Imports TracciaOperazioniDataSetTableAdapters

Public Class TracciaOperazioniDataSetTableAdapter_Custom
    Inherits QueriesTableAdapter

    Public Sub New()

        Throw New NotImplementedException("Usare il metodo Public Sub New(ByVal ConnectionString As String)")

    End Sub

    Public Sub New(ByVal connectionString As String)
        MyBase.New()
        Try

            For Each item In CommandCollection
                item.Connection.ConnectionString = connectionString
            Next

        Catch
            Throw
        End Try
    End Sub

End Class
