Public Class CalendarMonth
    Public Property Nome As String
    Public Property NumeroMese As Integer
    Public Property NumeroAnno As Integer
    Public Property Giorni As New List(Of CalendarDay)

    Public Function FirstDay() As Date
        Return New DateTime(Me.NumeroAnno, Me.NumeroMese, 1)
    End Function

End Class
