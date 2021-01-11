Namespace OeConnCup.WizardAgende

    <Serializable>
    Public Class Prestazione

        Public Property StrutturaErogante As String
        Public Property CodiceAgendaCup As String
        Public Property IdPrestazioneErogante As String
        Public Property IdPrestazioneCup As String
        Public Property SpecialitaEsameCup As String
        Public Property Descrizione As String

        Public Shared Widening Operator CType(prestazione As DiffPrestazioniCup) As Prestazione

            Dim specialitaEsame As String = prestazione.SpecialitaEsameCup
            Dim idPrestazioneCup As String = prestazione.IdPrestazioneCup.TrimStart("0"c)

            Dim idPrestazioneErogante As String = $"{specialitaEsame}{idPrestazioneCup}"

            Return New Prestazione With
            {
            .StrutturaErogante = prestazione.StrutturaErogante,
            .CodiceAgendaCup = prestazione.CodiceAgendaCup,
            .IdPrestazioneErogante = idPrestazioneErogante,
            .IdPrestazioneCup = prestazione.IdPrestazioneCup,
            .SpecialitaEsameCup = prestazione.SpecialitaEsameCup,
            .Descrizione = prestazione.Descrizione
            }

        End Operator

        Public Shared Widening Operator CType(prestazione As Prestazione) As TranscodificaAttributiPrestazioniCupErogante
            Return New TranscodificaAttributiPrestazioniCupErogante With
            {
            .StrutturaErogante = prestazione.StrutturaErogante,
            .IdPrestazioneCup = prestazione.IdPrestazioneCup,
            .IdPrestazioneErogante = prestazione.IdPrestazioneErogante,
            .Nome = "",
            .Codice = "",
            .Posizione = 0,
            .Descrizione = prestazione.Descrizione,
            .TipoDato = Nothing,
            .TipoContenuto = Nothing,
            .SpecialitaEsameCup = prestazione.SpecialitaEsameCup
            }
        End Operator

    End Class

End Namespace
