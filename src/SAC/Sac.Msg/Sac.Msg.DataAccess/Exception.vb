Public Class DataAccessException
    Inherits Exception

    Public ErrorCode As Integer
    Public ErrorService As String

    Public Sub New()
    End Sub

    Public Sub New(ByVal Message As String)
        MyBase.New(Message)
    End Sub

    Public Sub New(ByVal Message As String, ByVal ErrorCode As Integer)
        MyBase.New(Message)
        Me.ErrorCode = ErrorCode
    End Sub

    Public Sub New(ByVal Message As String, ByVal ErrorCode As Integer, ByVal ErrorService As String)
        MyBase.New(Message)
        Me.ErrorCode = ErrorCode
        Me.ErrorService = ErrorService
    End Sub
End Class

Public Class DataSequenzaException
    Inherits DataAccessException
    '
    ' Errore di data sequenza!
    '
    Public Sub New()
        MyBase.New(String.Format(My.Resources.ExceptionDataSequenza, "record"))
        Me.ErrorCode = 1
    End Sub

    Public Sub New(ByVal Servizio As String)
        MyBase.New(String.Format(My.Resources.ExceptionDataSequenza, Servizio))
        Me.ErrorCode = 1
        Me.ErrorService = Servizio
    End Sub

End Class

Public Class DatiNonTrovatiException
    Inherits DataAccessException
    '
    ' I dati del servizio non sono state trovati
    '
    Public Sub New()
        MyBase.New(String.Format(My.Resources.ExceptionDatiNonTrovati, "record"))
        Me.ErrorCode = 2
    End Sub

    Public Sub New(ByVal Servizio As String)
        MyBase.New(String.Format(My.Resources.ExceptionDatiNonTrovati, Servizio))
        Me.ErrorCode = 2
    End Sub

    Public Sub New(ByVal Servizio As String, ByVal Message As String)
        MyBase.New(Message)
        Me.ErrorCode = 2
    End Sub

End Class

Public Class DatiGiaPresentiException
    Inherits DataAccessException
    '
    ' Il dato è gia nel database
    '
    Public Sub New()
        MyBase.New(String.Format(My.Resources.ExceptionDatiGiaPresenti, "record"))
        Me.ErrorCode = 3
    End Sub

    Public Sub New(ByVal Servizio As String)
        MyBase.New(String.Format(My.Resources.ExceptionDatiGiaPresenti, Servizio))
        Me.ErrorCode = 3
        Me.ErrorService = Servizio
    End Sub
End Class

Public Class DatiRowCountZeroException
    Inherits DataAccessException
    '
    ' La query non ha tornato record variati ROWCOUNT=0
    '
    Public Sub New()
        MyBase.New(My.Resources.ExceptionRowCountZero)
        Me.ErrorCode = 4
    End Sub

    Public Sub New(ByVal Servizio As String)
        MyBase.New(String.Format(My.Resources.ExceptionRowCountZero, Servizio))
        Me.ErrorCode = 4
        Me.ErrorService = Servizio
    End Sub
End Class

Public Class CancellatoVirtualmenteException
    Inherits DataAccessException
    '
    ' La query non ha tornato record variati ROWCOUNT=0
    '
    Public Sub New()
        MyBase.New(String.Format(My.Resources.ExceptionCancellatoVirtualmente, "record"))
        Me.ErrorCode = 5
    End Sub

    Public Sub New(ByVal Servizio As String)
        MyBase.New(String.Format(My.Resources.ExceptionCancellatoVirtualmente, Servizio))
        Me.ErrorCode = 5
        Me.ErrorService = Servizio
    End Sub
End Class

Public Class SincronizzazioneException
    Inherits DataAccessException

    Public SyncKey As String
    '
    ' La sincronizzazione non è stata acquisita
    '
    Public Sub New(ByVal Servizio As String, ByVal SyncKey As String)
        MyBase.New(String.Format(My.Resources.ExceptionSincronizzazione, Servizio, SyncKey))
        Me.ErrorCode = 6
        Me.ErrorService = Servizio
        Me.SyncKey = SyncKey
    End Sub
End Class

Public Class DatiInconsistentiException
    Inherits DataAccessException

    Public ErrorDescription As String
    '
    ' La sincronizzazione non è stata acquisita
    '
    Public Sub New(ByVal Servizio As String, ByVal Messaggio As String)
        MyBase.New(String.Format(My.Resources.ExceptionDatiInconsistenti, Servizio, Messaggio))
        Me.ErrorCode = 7
        Me.ErrorService = Servizio
        Me.ErrorDescription = Messaggio
    End Sub
End Class

Public Class SinonimoException
    Inherits DataAccessException
    '
    ' Errore di sinomo non modificabile!
    '
    Public Sub New()
        MyBase.New(String.Format(My.Resources.ExceptionSinonimo, "record"))
        Me.ErrorCode = 8
    End Sub

    Public Sub New(ByVal Servizio As String)
        MyBase.New(String.Format(My.Resources.ExceptionSinonimo, Servizio))
        Me.ErrorCode = 8
        Me.ErrorService = Servizio
    End Sub

    Public Sub New(ByVal Servizio As String, ByVal Message As String)
        MyBase.New(Message)
        Me.ErrorCode = 8
        Me.ErrorService = Servizio
    End Sub

End Class

Public Class IncoerenzaIstatException
    Inherits Exception

    Public Sub New(ByVal Message As String)
        MyBase.New(Message)
    End Sub

End Class

