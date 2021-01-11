''' <summary>
''' Dictionary condiviso fra tutti i thread ad accesso thread safe.
''' Contiene i lockobject da usare nel blocco synclock
''' </summary>
Public Class ConcurrentDictionary
    Private Shared Dic As New Dictionary(Of String, Object)

    ''' <summary>
    ''' Ottiene il lockobject per la chiave passata, se non esiste lo crea.
    ''' </summary>
    Public Shared Function GetLockobject(ByVal Key As String) As Object
        Key = Key.ToUpper
        SyncLock Dic
            If Not Dic.Keys.Contains(Key) Then
                Dic.Add(Key, New Object)
            End If
            Return Dic.Item(Key)
        End SyncLock
    End Function

    ''' <summary>
    ''' Rimuove il lockobject dal dictionary
    ''' </summary>
    Public Shared Sub Remove(ByVal Key As String)
        Key = Key.ToUpper
        SyncLock Dic
            ' NON OCCORRE TESTARE LA PRESENZA DELLA CHIAVE
            Dic.Remove(Key)
        End SyncLock
    End Sub

End Class
