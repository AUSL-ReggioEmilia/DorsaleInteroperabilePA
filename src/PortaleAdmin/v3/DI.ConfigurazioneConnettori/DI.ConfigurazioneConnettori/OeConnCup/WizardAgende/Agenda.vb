Imports System.ComponentModel

Namespace OeConnCup.WizardAgende

    <Serializable>
    Public Class Agenda

        Public Property CodiceAgendaCup As String
        Public Property DescrizioneAgendaCup As String
        Public Property TranscodificaCodiceAgendaCup As String
        Public Property StrutturaErogante As String
        Public Property DescrizioneStrutturaErogante As String
        Public Property CodiceSistemaErogante As String
        Public Property CodiceAziendaErogante As String
        Public Property MultiErogante As Boolean? = False

        Public Property IsAlreadyExisting As Boolean = False
        Public Property Prestazioni As New List(Of Prestazione)

        Public Shared Widening Operator CType(agendaCup As DiffAgendeCup) As Agenda

            'Converto l'agenda da DiffAgendeCup a Agenda
            Return New Agenda() With
                {
                .IsAlreadyExisting = False, 'Mi salvo che l'agenda non esiste ancora (devo inserirla)
                .CodiceAgendaCup = agendaCup.CodiceAgendaCup,
                .DescrizioneAgendaCup = agendaCup.DescrizioneAgendaCup,
                .TranscodificaCodiceAgendaCup = agendaCup.CodiceAgendaCup 'Campo precompilato con CodiceAgendaCup
            }

        End Operator

        Public Shared Widening Operator CType(agendaEsistente As TranscodificaAgendaCupStrutturaErogante) As Agenda

            'Converto l'agenda da TranscodificaAgendaCupStrutturaErogante a Agenda
            Return New Agenda() With
                {
                .IsAlreadyExisting = True, 'Mi salvo che l'agenda esiste (non la devo inserire)
                .CodiceAgendaCup = agendaEsistente.CodiceAgendaCup,
                .DescrizioneAgendaCup = agendaEsistente.DescrizioneAgendaCup,
                .TranscodificaCodiceAgendaCup = agendaEsistente.TranscodificaCodiceAgendaCup,
                .StrutturaErogante = agendaEsistente.StrutturaErogante,
                .DescrizioneStrutturaErogante = agendaEsistente.DescrizioneStrutturaErogante,
                .CodiceSistemaErogante = agendaEsistente.CodiceSistemaErogante,
                .CodiceAziendaErogante = agendaEsistente.CodiceAziendaErogante,
                .MultiErogante = agendaEsistente.MultiErogante
            }
        End Operator

        Public Shared Widening Operator CType(agenda As Agenda) As TranscodificaAgendaCupStrutturaErogante

            'Converto l'agenda da DiffAgendeCup a Agenda
            Return New TranscodificaAgendaCupStrutturaErogante() With
                {
                .CodiceAgendaCup = agenda.CodiceAgendaCup,
                .DescrizioneAgendaCup = agenda.DescrizioneAgendaCup,
                .TranscodificaCodiceAgendaCup = agenda.TranscodificaCodiceAgendaCup,
                .StrutturaErogante = agenda.StrutturaErogante,
                .DescrizioneStrutturaErogante = agenda.DescrizioneStrutturaErogante,
                .CodiceSistemaErogante = agenda.CodiceSistemaErogante,
                .CodiceAziendaErogante = agenda.CodiceAziendaErogante,
                .MultiErogante = CType(IIf(agenda.MultiErogante.HasValue, agenda.MultiErogante.Value, False), Boolean)
            }
        End Operator

    End Class

End Namespace
