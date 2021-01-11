Public Class OrderEntryAmbiguousException
    Inherits OrderEntryBaseException

    Public Sub New(ByVal message As String)
        MyBase.New(String.Format(My.Resources.AmbiguousException, message))
        Me.ExceptionType = OrderEntryExceptionType.AmbiguousException
    End Sub

End Class