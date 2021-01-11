Public Class Ricoveri
    '
    ' Testata con i dati del paziente
    '
    Public Function RicoveroTestataPaziente(ByVal IdRicovero As Guid) As RicoveriDataSet.FevsRicoveroTestataPazienteDataTable
        Dim ta As New RicoveriDataSetTableAdapters.FevsRicoveroTestataPazienteTableAdapter
        ta.Connection = SqlConnection
        Return ta.GetData(IdRicovero)
    End Function

    '
    ' Testata con i dati del ricovero
    '
    Public Function RicoveroTestata(ByVal IdRicovero As Guid) As RicoveriDataSet.FevsRicoveroTestataDataTable
        Dim ta As New RicoveriDataSetTableAdapters.FevsRicoveroTestataTableAdapter
        ta.Connection = SqlConnection
        Return ta.GetData(IdRicovero)
    End Function

    Public Function GetRicoveroEventiLista(ByVal IdRicovero As Guid,
                                            ByVal DataEventoDal As String) As Data.RicoveriDataSet.FevsRicoveroPazienteEventiListaDataTable
        Dim oIdRicovero As System.Nullable(Of Guid) = Nothing
        Dim oDataEvento As System.Nullable(Of Date) = Nothing
        Try
            If IdRicovero <> Guid.Empty Then
                '
                ' Imposto Id del paziente
                '
                oIdRicovero = IdRicovero
                '
                ' Imposto la data dell'evento
                '
                If Not IsNothing(DataEventoDal) AndAlso DataEventoDal.Length > 0 Then
                    Try
                        oDataEvento = Date.Parse(CStr(DataEventoDal), Threading.Thread.CurrentThread.CurrentCulture)
                    Catch
                        oDataEvento = Nothing
                    End Try
                End If
                '
                ' Eseguo la query
                '
                Using ta As RicoveriDataSetTableAdapters.FevsRicoveroPazienteEventiListaTableAdapter = New RicoveriDataSetTableAdapters.FevsRicoveroPazienteEventiListaTableAdapter
                    ta.Connection = SqlConnection
                    Dim oDataTable As RicoveriDataSet.FevsRicoveroPazienteEventiListaDataTable
                    oDataTable = ta.GetData(oIdRicovero, oDataEvento)
                    Return oDataTable
                End Using
            Else
                Throw New Exception("Il parametro IdRicovero è obbligatorio.")
            End If

        Catch ex As Exception
            Logging.WriteError(ex, "Si è verificato un errore durante la lettura dei dati in Data.Eventi.GetRicoveroEventiLista()")
            Throw ex
        End Try
        '
        ' Se sono qui si è verificato un errore
        '
        Return Nothing

    End Function

    Public Function GetRicoveriPazienteLista(ByVal IdPaziente As Guid, ByVal sAziendaErogante As String, ByVal DataEpisodio As String) As Data.RicoveriDataSet.FevsRicoveriPazienteListaDataTable
        Dim oIdPaziente As System.Nullable(Of Guid) = Nothing
        Dim oDataEpisodio As System.Nullable(Of Date) = Nothing
        Try
            If IdPaziente <> Guid.Empty Then
                '
                ' Imposto Id del paziente
                '
                oIdPaziente = IdPaziente
                '
                ' Imposto la data dell'evento
                '
                If Not IsNothing(DataEpisodio) AndAlso DataEpisodio.Length > 0 Then
                    Try
                        oDataEpisodio = Date.Parse(CStr(DataEpisodio), Threading.Thread.CurrentThread.CurrentCulture)
                    Catch
                        oDataEpisodio = Nothing
                    End Try
                End If
                If String.IsNullOrEmpty(sAziendaErogante) Then
                    sAziendaErogante = Nothing
                End If
                '
                ' Eseguo la query
                '
                Using ta As RicoveriDataSetTableAdapters.FevsRicoveriPazienteListaTableAdapter = New RicoveriDataSetTableAdapters.FevsRicoveriPazienteListaTableAdapter
                    ta.Connection = SqlConnection
                    Dim oDataTable As RicoveriDataSet.FevsRicoveriPazienteListaDataTable
                    oDataTable = ta.GetData(oIdPaziente, sAziendaErogante, oDataEpisodio)
                    Return oDataTable
                End Using
            Else
                Throw New Exception("Il parametro IdPaziente è obbligatorio.")
            End If

        Catch ex As Exception
            Logging.WriteError(ex, "Si è verificato un errore durante la lettura dei dati in Data.Eventi.GetPazientiRicoveriLista()")
            Throw ex
        End Try
        '
        ' Se sono qui si è verificato un errore
        '
        Return Nothing

    End Function

    Public Function GetRicoveroPazienteEventoDettaglio(ByVal IdEventi As Guid) As DwhClinico.Data.RicoveriDataSet.FevsRicoveroPazienteEventoDettaglioDataTable

        Dim oIdEventi As System.Nullable(Of Guid) = Nothing
        Dim oDataEpisodio As System.Nullable(Of Date) = Nothing
        Try
            If IdEventi <> Guid.Empty Then
                '
                ' Imposto Id del paziente
                '
                oIdEventi = IdEventi
                '
                ' Eseguo la query
                '
                Using ta As RicoveriDataSetTableAdapters.FevsRicoveroPazienteEventoDettaglioTableAdapter = New RicoveriDataSetTableAdapters.FevsRicoveroPazienteEventoDettaglioTableAdapter
                    ta.Connection = SqlConnection
                    Dim oDataTable As RicoveriDataSet.FevsRicoveroPazienteEventoDettaglioDataTable
                    oDataTable = ta.GetData(IdEventi)
                    Return oDataTable
                End Using
            Else
                Throw New Exception("Il parametro IdEventi è obbligatorio.")
            End If

        Catch ex As Exception
            Logging.WriteError(ex, "Si è verificato un errore durante la lettura dei dati in Data.Eventi.GetRicoveroPazienteDettaglio()")
            Throw ex
        End Try
        '
        ' Se sono qui si è verificato un errore
        '
        Return Nothing


    End Function

    Public Function GetRicoveroPazienteInfo(ByVal IdPaziente As Guid) As Data.RicoveriDataSet.FevsRicoveroPazienteInfoDataTable
        Dim oIdPaziente As System.Nullable(Of Guid) = Nothing
        Dim oDataEpisodio As System.Nullable(Of Date) = Nothing
        Try
            If IdPaziente = Guid.Empty Then
                Throw New Exception("Il parametro IdPaziente è obbligatorio.")
            End If
            '
            ' Imposto Id del paziente
            '
            oIdPaziente = IdPaziente
            '
            ' Eseguo la query
            '
            Using ta As RicoveriDataSetTableAdapters.FevsRicoveroPazienteInfoTableAdapter = New RicoveriDataSetTableAdapters.FevsRicoveroPazienteInfoTableAdapter
                ta.Connection = SqlConnection
                Dim oDataTable As RicoveriDataSet.FevsRicoveroPazienteInfoDataTable
                oDataTable = ta.GetData(oIdPaziente)
                Return oDataTable
            End Using

        Catch ex As Exception
            Logging.WriteError(ex, "Si è verificato un errore durante la lettura dei dati in Data.Eventi.GetRicoveroPazienteInfo()")
            Throw ex
        End Try
        '
        ' Se sono qui si è verificato un errore
        '
        Return Nothing

    End Function

End Class
