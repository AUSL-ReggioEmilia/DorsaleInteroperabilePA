Public Class OrderEntryInvalidRequestException
    Inherits OrderEntryBaseException

    Public Sub New(ByVal user As String, ByVal detail As String)
        MyBase.New(String.Format(My.Resources.InvalidRequestException, user, detail))
        Me.ExceptionType = OrderEntryExceptionType.InvalidRequestException
    End Sub

End Class