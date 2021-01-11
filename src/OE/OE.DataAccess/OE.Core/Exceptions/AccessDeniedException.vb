Public Class OrderEntryAccessDeniedException
    Inherits OrderEntryBaseException

    Public Sub New(ByVal user As String, ByVal detail As String)
        MyBase.New(String.Format(My.Resources.AccessDeniedException, user, detail))
        Me.ExceptionType = OrderEntryExceptionType.AccessDeniedException
    End Sub

End Class