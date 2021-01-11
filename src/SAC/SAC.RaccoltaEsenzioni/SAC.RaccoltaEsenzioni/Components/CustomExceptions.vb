''' <summary>
''' Classe usata per la gestione delle custom exception generate dalle chiamate ai WCF
''' </summary>
Public Class CustomDataSourceException
    Inherits Exception

    ''' <summary>
    ''' Codice dell'eccezione
    ''' </summary>
    Public CodiceCustomException As Integer

    ''' <summary>
    ''' Descrizione dell'eccezione
    ''' </summary>
    Public DescrizioneCustomException As String

    Public Sub New()
    End Sub

    Public Sub New(ByVal Message As String, ByVal Codice As String, ByVal Descrizione As String)
        MyBase.New(Message)
        Me.CodiceCustomException = Codice
        Me.DescrizioneCustomException = Descrizione
    End Sub

    ''' <summary>
    ''' Restituisce il messaggio d'errore
    ''' </summary>
    ''' <param name="CustomException"></param>
    ''' <returns></returns>
    Public Shared Function GetUserMessage(CustomException As CustomDataSourceException) As String
        Dim sErrore As String = "Errore durante l'operazione di ricerca dei dati!"
        If Not CustomException Is Nothing Then
            If Not String.IsNullOrEmpty(CustomException.CodiceCustomException) Then
                Dim iCodice As Integer = CInt(CustomException.CodiceCustomException)
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

    ''' <summary>
    ''' Restituisce il messaggio da scrivere nell'eventviewer
    ''' </summary>
    ''' <param name="customException"></param>
    ''' <returns></returns>
    Public Shared Function GetEventLogMessage(customException As CustomDataSourceException) As String
        Dim sErrore As String = String.Empty
        If Not customException Is Nothing Then
            sErrore = String.Concat("UserName: ", HttpContext.Current.User.Identity.Name, vbCrLf, "Codice Errore= ", customException.CodiceCustomException, vbCrLf, "Descrizione= ", customException.DescrizioneCustomException)
            sErrore = sErrore & vbCrLf & Utility.FormatException(customException)
        End If
        Return sErrore
    End Function

    ''' <summary>
    ''' Trappa gli errori dei WCF
    ''' </summary>
    ''' <param name="ex"></param>
    ''' <returns></returns>
    Public Shared Function TrapError(ex As Exception) As String
        'Dichiaro l'oggetto da restituire.
        Dim messaggioErrore As String = String.Empty

        'testo se ex non è vuoto.
        If ex IsNot Nothing Then
            'creo il messaggio d'errore.
            messaggioErrore = "Errore durante l'operazione di ricerca dei dati!"
            If TypeOf ex Is CustomDataSourceException Then
                '
                'compongo errore da scrivere nel log
                '
                Logging.WriteError(Nothing, CustomDataSourceException.GetEventLogMessage(ex))

                '
                ' compongo errore per l'utente
                '
                messaggioErrore = CustomDataSourceException.GetUserMessage(ex)
            ElseIf TypeOf ex.InnerException Is CustomDataSourceException Then
                '
                'compongo errore da scrivere nel log
                '
                Logging.WriteError(Nothing, CustomDataSourceException.GetEventLogMessage(ex.InnerException))

                '
                ' compongo errore per l'utente
                '
                messaggioErrore = CustomDataSourceException.GetUserMessage(ex.InnerException)
            Else
                messaggioErrore = GestioneErrori.TrapError(ex)
            End If
        End If

        Return messaggioErrore
    End Function

End Class


