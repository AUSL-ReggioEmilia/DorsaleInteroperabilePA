Public Class CalendarDay
    Public Property Numero As Integer
    Public Property ToolTip As String
    Public Property Rank As Integer
    Public Property Giorno As Date
    Public Property Festivo As Boolean
    Public Property Escluso As Boolean
    Public Property TipoEpisodio As String = "" ' assegnamento necessario


    Public ReadOnly Property Text() As String
        Get
            ' Serve per rendere cliccabili solo i giorni in cui ci sono referti (Rank > 0) oppure se all'interno di un ricovero (episodio). 
            ' Per lo scopo si usa &nbsp; serve per redere cliccabile una cella anche se non ha un Rank.

            If String.IsNullOrEmpty(Me.TipoEpisodio) Then

                If Me.Rank > 0 Then
                    Return IIf(Me.Numero = 0, "", Numero.ToString)
                Else
                    Return ""
                End If
            Else
                If Me.Rank > 0 Then
                    Return IIf(Me.Numero = 0, "", Numero.ToString)
                Else
                    Return "&nbsp;"
                End If
            End If

        End Get
    End Property

    Public ReadOnly Property ClasseCss() As String
        Get
            ' In base al Rank vengono assegnate le classi per il colore dello sfondo del panel (giorno del calendario)
            Dim cssClass As String = ImpostaClasseRank()

            ' In base al TipoEpisodio viene aggiunta la classe relativa al colore del bordo del panel (giorno del calendario)
            cssClass += ImpostaClasseTipoEpisodio()

            ' Infine viene restituito l'insieme delle classi assegante sotto forma di stringa
            Return cssClass
        End Get
    End Property

    Private ReadOnly Property ImpostaClasseRank() As String
        Get
            Dim cssClassBase As String = "calendar-panel"
            Dim cssClass As String = ""

            If Me.Numero = 0 Then Return cssClassBase

            If Me.Escluso Then Return cssClassBase & " calendar-rank-escluso"

            If Me.Rank = 1 Then
                cssClass = cssClassBase & " calendar-rank1"

            ElseIf Me.Festivo Then
                cssClass = cssClassBase & " calendar-rank-default-weekend"
            Else
                cssClass = cssClassBase & " calendar-rank-default"
            End If

            Return cssClass
        End Get
    End Property

    Private ReadOnly Property ImpostaClasseTipoEpisodio() As String
        Get
            Dim cssClass As String = ""

            Select Case Me.TipoEpisodio
                Case "P" : cssClass += " calendar-panel-border1"
                Case "B" : cssClass += " calendar-panel-border1"
                Case "O" : cssClass += " calendar-panel-border2"
                Case "D" : cssClass += " calendar-panel-border3"
                Case "S" : cssClass += " calendar-panel-border3"
                Case "A" : cssClass += " calendar-panel-border4"
                Case "" : cssClass += ""
                Case Else
                    ' nel caso in cui ci sia un codicie non codificato con un colore, viene attribuito il colore di "A" --> "Altro"
                    If Me.Rank <> 0 Then
                        cssClass += " calendar-panel-border4"
                    End If
            End Select

            Return cssClass
        End Get
    End Property
End Class
