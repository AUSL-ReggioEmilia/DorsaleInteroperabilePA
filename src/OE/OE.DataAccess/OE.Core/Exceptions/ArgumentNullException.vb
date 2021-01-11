Public Class OrderEntryArgumentNullException
    Inherits OrderEntryBaseException

    Public Sub New(ByVal paramName As String)
        MyBase.New(String.Format(My.Resources.ArgumentNullException, paramName))
        Me.ExceptionType = OrderEntryExceptionType.ArgumentNullException
    End Sub

End Class