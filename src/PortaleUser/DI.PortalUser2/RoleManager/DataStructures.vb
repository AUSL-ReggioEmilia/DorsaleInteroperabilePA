Imports System
Imports System.Collections.Generic

Namespace DI.PortalUser2.RoleManager

    Public Class Ruolo
        Public Property Codice As String = String.Empty
        Public Property Descrizione As String = String.Empty
    End Class

    Public Class Sistema
        Public Property Codice As String = String.Empty
        Public Property CodiceAzienda As String = String.Empty
        Public Property Descrizione As String = String.Empty
        Public Property Erogante As Boolean = False
        Public Property Richiedente As Boolean = False
    End Class

    Public Class UnitaOperativa
        Public Property Codice As String = String.Empty
        Public Property CodiceAzienda As String = String.Empty
        Public Property Descrizione As String = String.Empty

        Public Property Regimi As List(Of Regime) = Nothing
    End Class


    Public Class Regime
        Public Property Codice As String = String.Empty
        Public Property Descrizione As String = String.Empty
    End Class

    '''' <summary>
    '''' Racchiude la lista di Sistemi, Unità operative e Accessi attribuiti all'utente corrente
    '''' </summary>
    'Public Class ContestoUtente
    '    Public Property Sistemi As WcfSacRoleManager.SistemiListaType
    '    Public Property UnitaOperative As WcfSacRoleManager.UnitaOperativeListaType
    '    Public Property Accessi As WcfSacRoleManager.AccessiListaType
    'End Class

    Public Class Utente
        Public Property IdUtente As Guid = Guid.Empty
        Public Property Utente As String = String.Empty
        Public Property Descrizione As String = String.Empty
        Public Property Cognome As String = String.Empty
        Public Property Nome As String = String.Empty
        Public Property CodiceFiscale As String = String.Empty
        Public Property Matricola As String = String.Empty
        Public Property Email As String = String.Empty
        Public Property Attivo As Boolean = False
        Public Property NomeCompleto As String = String.Empty
    End Class

End Namespace

