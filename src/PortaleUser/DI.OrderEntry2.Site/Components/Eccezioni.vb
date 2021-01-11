Public Class CustomException(Of T)
    Inherits Exception

    Public ExtraData As T

    Public Sub New()
    End Sub

    Public Sub New(ByVal Message As String, ByVal ExtraData As T)
        MyBase.New(Message)
        Me.ExtraData = ExtraData
    End Sub

End Class

Public Class ErrorMessage
    Public Shared Function GetUserMessage(customException As CustomException(Of WcfDwhClinico.ErroreType)) As String
        Dim sErrore As String = "Errore durante l'operazione di ricerca dei dati!"
        If Not customException Is Nothing AndAlso Not customException.ExtraData Is Nothing Then
            If Not String.IsNullOrEmpty(customException.ExtraData.Codice) Then
                Dim iCodice As Integer = CInt(customException.ExtraData.Codice)
                If iCodice >= 10 And iCodice <= 99 Then
                    sErrore = "Il sistema è momentaneamente impegnato, le chiediamo di riprovare."
                    If iCodice = 12 Then
                        sErrore = sErrore & " Modificare eventualmente i parametri di filtro."
                    End If
                End If
            End If
        End If
        Return sErrore
    End Function

    Public Shared Function GetEventLogMessage(customException As CustomException(Of WcfDwhClinico.ErroreType)) As String
        Dim sErrore As String = String.Empty
        If Not customException Is Nothing AndAlso Not customException.ExtraData Is Nothing Then
            sErrore = String.Concat("UserName: ", HttpContext.Current.User.Identity.Name, vbCrLf, "Codice Errore= ", customException.ExtraData.Codice, vbCrLf, "Descrizione= ", customException.ExtraData.Descrizione)
            sErrore = sErrore & vbCrLf & Utility.FormatException(customException)
        End If
        Return sErrore
    End Function

End Class

