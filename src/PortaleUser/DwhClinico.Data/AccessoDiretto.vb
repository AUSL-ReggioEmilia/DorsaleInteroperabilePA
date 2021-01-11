<System.ComponentModel.DataObject(True)>
Public Class AccessoDiretto

    Public Function GetIdPazienteByNosologicoAzienda(ByVal NumeroNosologico As String, ByVal AziendaErogante As String) As Guid
        Using taGetIdPaziente As New AccessoDirettoDataSetTableAdapters.GetIdPazienteTableAdapter
            '
            ' Connessione
            '
            taGetIdPaziente.Connection = SqlConnection
            '
            ' Ricerca i dati e torna una tabella
            '
            Dim dt As AccessoDirettoDataSet.GetIdPazienteDataTable
            dt = taGetIdPaziente.GetDataByNosologicoAzienda(NumeroNosologico, AziendaErogante)
            If dt.Rows.Count > 0 Then
                If dt(0).IsIdPazienteNull Then
                    Return Nothing
                Else
                    Return dt(0).IdPaziente
                End If
            End If
            Return Nothing
        End Using
    End Function

    Public Function GetIdPazienteByNumeroPrenotazione(ByVal NumeroPrenotazione As String) As Guid
        Using taGetIdPaziente As New AccessoDirettoDataSetTableAdapters.GetIdPazienteTableAdapter
            '
            ' Connessione
            '
            taGetIdPaziente.Connection = SqlConnection
            '
            ' Ricerca i dati e torna una tabella
            '
            Dim dt As AccessoDirettoDataSet.GetIdPazienteDataTable
            dt = taGetIdPaziente.GetDataByNumeroPrenotazione(NumeroPrenotazione)
            If dt.Rows.Count > 0 Then
                If dt(0).IsIdPazienteNull Then
                    Return Nothing
                Else
                    Return dt(0).IdPaziente
                End If
            End If
            Return Nothing
        End Using
    End Function

    Public Function GetIdPazienteByIdOrderEntry(ByVal IdOrderEntry As String) As Guid
        Using taGetIdPaziente As New AccessoDirettoDataSetTableAdapters.GetIdPazienteTableAdapter
            '
            ' Connessione
            '
            taGetIdPaziente.Connection = SqlConnection
            '
            ' Ricerca i dati e torna una tabella
            '
            Dim dt As AccessoDirettoDataSet.GetIdPazienteDataTable
            dt = taGetIdPaziente.GetDataByIdOrderEntry(IdOrderEntry)
            If dt.Rows.Count > 0 Then
                If dt(0).IsIdPazienteNull Then
                    Return Nothing
                Else
                    Return dt(0).IdPaziente
                End If
            End If
            Return Nothing
        End Using
    End Function

End Class
