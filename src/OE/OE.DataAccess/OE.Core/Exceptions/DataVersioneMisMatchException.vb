Public Class OrderEntryDataVersioneMismatchException
    Inherits OrderEntryBaseException

    Public Sub New(ByVal datiRichiesta As String, ByVal datiStato As String)
        MyBase.New(String.Format(My.Resources.DataVersioneMismatch, datiRichiesta, datiStato))
        Me.ExceptionType = OrderEntryExceptionType.DataVersioneMismatch
    End Sub

End Class