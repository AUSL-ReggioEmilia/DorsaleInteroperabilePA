<System.ComponentModel.DataObject(True)> _
Public Class Utenti

    Public Function AggiungiTracciaAccessi(IdUtente As Nullable(Of Guid), ByVal DomainName As String,
                                                ByVal AccountName As String,
                                                ByVal Cognome As String,
                                                ByVal Nome As String,
                                                ByVal NomeHost As String,
                                                ByVal IpHost As String,
                                                ByVal Operazione As String,
                                                ByVal IdPazienti As Nullable(Of Guid),
                                                ByVal IdReferti As Nullable(Of Guid),
                                                ByVal IdRicoveri As Nullable(Of Guid),
                                                ByVal IdEventi As Nullable(Of Guid),
                                                ByVal RuoloUtenteCodice As String,
                                                ByVal RuoloUtenteDescrizione As String,
                                                ByVal MotivoAccesso As String,
                                                ByVal Note As String,
                                                ByVal NumeroRecord As Nullable(Of Integer),
                                                ByVal ConsensoPaziente As String,
                                                ByVal IdNotaAnamnestica As Nullable(Of Guid)
                                                ) As UtentiDataSet.FevsTracciaAccessiAggiungiDataTable

        Using ta As New UtentiDataSetTableAdapters.FevsTracciaAccessiAggiungiTableAdapter
            ta.Connection = SqlConnection
            '
            ' IdPazienti non è valorizzato lo imposto a '00000000-0000-0000-0000-000000000000'
            '
            If Not IdPazienti.HasValue Then
                IdPazienti = Guid.Empty
            End If
            '
            ' Controllo che uno solo sia valorizzato fra IdReferti, IdRicoveri, IdEventi
            '
            Dim iCounter As Integer = 0
            If IdReferti.HasValue Then iCounter = iCounter + 1
            If IdRicoveri.HasValue Then iCounter = iCounter + 1
            If IdEventi.HasValue Then iCounter = iCounter + 1
            If iCounter > 1 Then
                Throw New Exception("AggiungiTracciaAccessi. Solo uno fra i parametri IdReferti, IdRicoveri, IdEventi deve essere valorizzato!")
            End If
            '
            '
            '
            Return ta.GetData(IdUtente, DomainName, AccountName, Cognome, Nome, NomeHost, IpHost, Operazione, IdPazienti, IdReferti, IdRicoveri, IdEventi, RuoloUtenteCodice, RuoloUtenteDescrizione, MotivoAccesso, Note, NumeroRecord, ConsensoPaziente, IdNotaAnamnestica)

        End Using
        Return Nothing
    End Function

End Class

