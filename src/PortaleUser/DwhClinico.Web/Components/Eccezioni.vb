Imports DwhClinico.Data

Public Class WsException
    Inherits ApplicationException

    Public Codice As String
    Public Descrizione As String

    Public Sub New(ByVal Message As String, ByVal Codice As String, Descrizione As String)
        MyBase.New(GetUserMessage(Message, Codice, Descrizione))
    End Sub

    ''' <summary>
    ''' Restituisce il messaggio da scrivere nell'event viewer.
    ''' </summary>
    ''' <returns></returns>
    Public Function GetEventLogMessage() As String
        Dim sErrore As String = String.Empty
        sErrore = String.Concat("UserName: ", HttpContext.Current.User.Identity.Name, vbCrLf, "Codice Errore= ", Me.Codice, vbCrLf, "Descrizione= ", Me.Descrizione)
        sErrore = sErrore & vbCrLf & Utility.FormatException(Me)
        Return sErrore
    End Function


    ''' <summary>
    ''' Restituisce il messaggio da mostrare all'utente.
    ''' </summary>
    ''' <param name="Message"></param>
    ''' <param name="Codice"></param>
    ''' <param name="Descrizione"></param>
    ''' <returns></returns>
    Private Shared Function GetUserMessage(Message As String, Codice As String, Descrizione As String) As String

        Dim sErrore As String = Message

        If String.IsNullOrEmpty(Message) Then
            sErrore = "Errore durante l'operazione di ricerca dei dati!"
        End If

        If Not String.IsNullOrEmpty(Codice) Then
            Dim iCodice As Integer = CInt(Codice)

            If iCodice >= 10 And iCodice <= 99 Then
                sErrore = "Il sistema è momentaneamente impegnato, le chiediamo di riprovare."
                If iCodice = 12 Then
                    sErrore = sErrore & " Modificare eventualmente i parametri di filtro."
                End If
            End If

            If iCodice = 1001 Then
                sErrore = Descrizione
            End If
        End If

        Return sErrore
    End Function
End Class

Public Class WsDwhException
    Inherits WsException

    Public ExtraData As WcfDwhClinico.ErroreType

    Public Sub New(ByVal Message As String, ByVal ExtraData As WcfDwhClinico.ErroreType)

        MyBase.New(Message, ExtraData.Codice, ExtraData.Descrizione)
        Me.ExtraData = ExtraData

        Me.Codice = ExtraData.Codice
        Me.Descrizione = ExtraData.Descrizione
    End Sub
End Class

Public Class WsSacException
    Inherits WsException

    Public ExtraData As WcfSacRoleManager.ErroreType

    Public Sub New(ByVal Message As String, ByVal ExtraData As WcfSacRoleManager.ErroreType)

        MyBase.New(Message, ExtraData.Codice, ExtraData.Descrizione)
        Me.ExtraData = ExtraData

        Me.Codice = ExtraData.Codice
        Me.Descrizione = ExtraData.Descrizione
    End Sub
End Class

Public Class HelperDataSourceException

    ''' <summary>
    ''' Gestisce le eccezioni delle ObjectDataSource
    ''' </summary>
    ''' <param name="Ex"></param>
    ''' <returns></returns>
    Public Shared Function GetObjectDataSourceExceptionMessage(Ex As Exception) As String
        Dim messaggioErrore As String = String.Empty

        'Controllo se l'eccezione è vuota.
        If Ex IsNot Nothing Then
            'Se non è vuota imposto un messaggio di default.
            messaggioErrore = "Errore durante l'operazione di ricerca dei dati!"

            'Testo se l'innerException è valorizzata
            If Ex.InnerException IsNot Nothing Then

                'Testo il tipo di errore. Se è di tipo WsDwhException allora il messaggio per l'utente è contenuto dentro Message
                If TypeOf Ex.InnerException Is WsDwhException Then
                    Dim wsDwhException As WsDwhException = DirectCast(Ex.InnerException, WsDwhException)

                    If wsDwhException IsNot Nothing AndAlso wsDwhException.ExtraData IsNot Nothing Then
                        ' compongo errore da scrivere nel log
                        Logging.WriteError(Nothing, wsDwhException.GetEventLogMessage())

                        'Ottengo il messaggio d'errore per l'utente
                        messaggioErrore = wsDwhException.Message
                    End If
                End If

            Else
                'Scrivo nell'event viewer.
                Logging.WriteError(Nothing, Ex.Message)
            End If
        End If

        Return messaggioErrore
    End Function

End Class

