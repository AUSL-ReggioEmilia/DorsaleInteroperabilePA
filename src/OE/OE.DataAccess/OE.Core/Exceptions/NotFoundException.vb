Public Class OrderEntryNotFoundException
    Inherits OrderEntryBaseException

    Public Sub New(ByVal oggetto As String, ByVal valore As String)
        MyBase.New(String.Format(My.Resources.NotFoundException, oggetto, valore))
        Me.ExceptionType = OrderEntryExceptionType.NotFoundException
    End Sub

End Class