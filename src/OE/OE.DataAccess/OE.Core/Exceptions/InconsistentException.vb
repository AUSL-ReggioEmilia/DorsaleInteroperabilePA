
#If CONFIG = "Release 1.2" Or CONFIG = "Debug 1.2" Then
'Versione 1.2
Imports Wcf = OE.Core.Schemas.Wcf12
#Else
'Versione 1.0 e 1.1
Imports Wcf = OE.Core.Schemas.Wcf
#End If

Public Class OrderEntryInconsistentException
    Inherits OrderEntryBaseException

    Public Sub New(message As String)
        MyBase.New(message)
        Me.ExceptionType = OrderEntryExceptionType.InconsistentException

    End Sub


    Public Sub New(ByVal statoValidazioneValue As Wcf.WsTypes.StatoValidazioneType, message As String)
        MyBase.New(message)

        Me.ExceptionType = OrderEntryExceptionType.InconsistentException
        Me.StatoValidazione = statoValidazioneValue

    End Sub

    Public Sub New(ByVal statoValidazioneValue As Wcf.WsTypes.StatoValidazioneType)
        MyBase.New()

        Me.ExceptionType = OrderEntryExceptionType.InconsistentException
        Me.StatoValidazione = statoValidazioneValue

    End Sub

    Public StatoValidazione As Wcf.WsTypes.StatoValidazioneType

    Public Overrides ReadOnly Property Message As String
        Get
            Dim sb As New Text.StringBuilder

            'Aggiunge messaggio
            If String.IsNullOrEmpty(MyBase.Message) Then
                sb.AppendLine(MyBase.Message)
            End If

            'Aggiunge descrizione dello stato
            If StatoValidazione IsNot Nothing Then

                sb.AppendLine(StatoValidazione.Descrizione)

                'Descrizioni delle righe
                If StatoValidazione.Righe IsNot Nothing Then
                    For Each r In StatoValidazione.Righe
                        If r.Stato <> Wcf.WsTypes.StatoValidazioneEnum.AA Then
                            sb.AppendLine(r.Descrizione)
                        End If
                    Next
                End If
            End If

            Return sb.ToString
        End Get
    End Property

End Class