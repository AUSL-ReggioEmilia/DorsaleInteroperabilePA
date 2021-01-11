'
' Solo per generare gli schemi
'
#If DEBUG Then

<Serializable()> _
Public Class MessaggioAnagrafica
    Public IdEsternoPaziente As String
    Public AziendaErogante As String
    Public SistemaErogante As String
    Public RepartoErogante As String
    Public Cognome As String
    Public Nome As String
    Public Sesso As String
    Public DataNascita As String
    Public LuogoNascita As String
    Public CodiceFiscale As String
    Public CodiceSanitario As String
    Public DatiAnamnestici As String
    Public Attributi() As ConnectorV2.Attributo
    Public Riferimenti() As ConnectorV2.Riferimento
End Class

<Serializable()> _
Public Class MessaggioConsenso
    Public IdEsterno As String
    Public AziendaErogante As String
    Public SistemaErogante As String
    Public Data As String
    Public Abilitato As Boolean
    Public Tipo As String
    Public AccountUtente As String
    Public NomeUtente As String
    Public Paziente As ConnectorV2.Paziente
End Class

<Serializable()> _
Public Class MessaggioEpisodio
    Public Paziente As ConnectorV2.Paziente
    Public Referto As ConnectorV2.Referto
    Public Prestazioni() As ConnectorV2.Prestazione
    Public Allegati() As ConnectorV2.Allegato
    Public StileVisualizzazione As String
    Public DatiSoloPerCercare As Boolean
End Class

  <Serializable()> _
    Public Class MessaggioEvento
        Public Paziente As ConnectorV2.Paziente
        Public Evento As ConnectorV2.Evento
    End Class

#End If
