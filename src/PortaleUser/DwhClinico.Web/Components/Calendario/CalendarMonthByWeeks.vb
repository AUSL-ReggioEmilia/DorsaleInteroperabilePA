Public Class CalendarMonthByWeeks
    Public Property Rows As New List(Of CalendarWeek) '7

    Public Sub New()
        For i As Integer = 0 To 6
            Rows.Add(New CalendarWeek() With {.ColWeek1 = New CalendarDay(), .ColWeek2 = New CalendarDay(), .ColWeek3 = New CalendarDay(), .ColWeek4 = New CalendarDay(), .ColWeek5 = New CalendarDay(), .ColWeek6 = New CalendarDay})
        Next
    End Sub

    Public Sub SetMatrix(x As Integer, y As Integer, value As CalendarDay)
        Dim yCalendaryWeek As CalendarWeek = Rows(y)

        ' x (Colonne - SETTIMANE) -> da 0 a 5
        ' y (Righe - Rows - GIORNI) -> da 0 a 6

        If y >= 5 Then
            value.Festivo = True
        End If

        ' Inverto le coordinate
        Select Case x

            Case 0 : yCalendaryWeek.ColWeek1 = value
            Case 1 : yCalendaryWeek.ColWeek2 = value
            Case 2 : yCalendaryWeek.ColWeek3 = value
            Case 3 : yCalendaryWeek.ColWeek4 = value
            Case 4 : yCalendaryWeek.ColWeek5 = value
            Case 5 : yCalendaryWeek.ColWeek6 = value


        End Select

    End Sub

    Public Sub SetLinear(n As Integer, value As CalendarDay)

        ' n -> da 0 a 34
        ' x = n/7 -> posizione del giorno nella settimana
        ' y = n%7 -> giorno, es: lunedi. quindi è il primo della settimana(riga) ( y = 1)

        Dim x As Integer = n \ 7
        Dim y As Integer = n Mod (7)

        Me.SetMatrix(x, y, value)

    End Sub
End Class
