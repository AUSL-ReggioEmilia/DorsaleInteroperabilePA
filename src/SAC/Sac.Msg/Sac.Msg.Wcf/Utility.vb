Public Class Utility

    Public Shared Function GetIsolationLevel() As Data.IsolationLevel
        '
        ' Restituisce il livello di transazione da usare
        '
        Try
            Select Case My.Settings.DataBaseIsolationLevel.ToUpper
                Case "CHAOS"
                    Return IsolationLevel.Chaos

                Case "READCOMMITTED"
                    Return IsolationLevel.ReadCommitted

                Case "READUNCOMMITTED"
                    Return IsolationLevel.ReadUncommitted

                Case "REPEATABLEREAD"
                    Return IsolationLevel.RepeatableRead

                Case "SERIALIZABLE"
                    Return IsolationLevel.Serializable

                Case Else
                    Return IsolationLevel.ReadCommitted

            End Select

        Catch ex As Exception
            Return IsolationLevel.ReadCommitted
        End Try

    End Function

    Public Shared Function GetAttributoByNome(ByVal Nome As String, oAttributi As sac.bt.paziente.schema.dataaccess.AttributiType) As sac.bt.paziente.schema.dataaccess.AttributoType
        Dim oRet As sac.bt.paziente.schema.dataaccess.AttributoType = Nothing
        For Each oItem As sac.bt.paziente.schema.dataaccess.AttributoType In oAttributi
            If String.Compare(oItem.Nome, Nome) = 0 Then
                Return oItem
            End If
        Next
        Return oRet
    End Function
End Class
