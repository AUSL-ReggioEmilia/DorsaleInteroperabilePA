Public Class AnteprimaPazienti

    ''' <summary>
    ''' Imposta il ricalcolo per l'anteprima referti
    ''' </summary>
    ''' <param name="IdPaziente"></param>
    ''' <remarks></remarks>
    Public Sub RefertiCalcolaAnteprimaPaziente(ByVal IdPaziente As Nullable(Of Guid))
        Try
            Using ota As New AnteprimaPazientiDataSetTableAdapters.QueriesTableAdapter(My.Config.ConnectionString)
                ota.ExtRefertiCalcolaAnteprimaPaziente(IdPaziente)
            End Using
        Catch ex As Exception
            Dim sMsgWarning As String = String.Format("Si è verificato un errore durante la richiesta di aggiornamanto dell'""anteprima referti"" per il paziente {0}.", IdPaziente) & _
                                        vbCrLf & _
                                        ex.Message
            LogEvent.WriteWarning(sMsgWarning)
        End Try
    End Sub

    ''' <summary>
    ''' Imposta il ricalcolo per l'anteprima ricoveri
    ''' </summary>
    ''' <param name="IdPaziente"></param>
    ''' <remarks></remarks>
    Public Sub EventiCalcolaAnteprimaPaziente(ByVal IdPaziente As Guid)
        Try
            Using ota As New AnteprimaPazientiDataSetTableAdapters.QueriesTableAdapter(My.Config.ConnectionString)
                ota.ExtEventiCalcolaAnteprimaPaziente(IdPaziente)
            End Using
        Catch ex As Exception
            Dim sMsgWarning As String = String.Format("Si è verificato un errore durante la richiesta di aggiornamanto dell'""anteprima ricoveri"" per il paziente {0}.", IdPaziente) & _
                                        vbCrLf & _
                                        ex.Message
            LogEvent.WriteWarning(sMsgWarning)
        End Try
    End Sub

End Class
