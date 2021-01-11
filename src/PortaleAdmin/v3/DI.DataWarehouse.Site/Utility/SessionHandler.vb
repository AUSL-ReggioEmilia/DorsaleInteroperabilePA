Imports System.Collections
Imports System.Collections.Generic
Imports System.Data
Imports System.Web

Public Class SessionHandler

    Private Const KEY_LISTA_REFERTI_NOTIFICA As String = "KEY_LISTA_REFERTI_NOTIFICA"
    Private Const KEY_LISTA_RICOVERI_NOTIFICA As String = "KEY_LISTA_RICOVERI_NOTIFICA"

    Private Const KEY_LISTA_REFERTI_NOTIFICATI As String = "KEY_LISTA_REFERTI_NOTIFICATI"
    Private Const KEY_LISTA_RICOVERI_NOTIFICATI As String = "KEY_LISTA_RICOVERI_NOTIFICATI"



    Public Shared Property listaReferti As DataTable
        '
        ' AGGIUNGE IN SESSIONE LA LISTA DEI REFERTI DA RINOTIFICARE
        '
        Get
            Return CType(HttpContext.Current.Session(KEY_LISTA_REFERTI_NOTIFICA), System.Data.DataTable)
        End Get
        Set(value As DataTable)
            HttpContext.Current.Session(KEY_LISTA_REFERTI_NOTIFICA) = value
        End Set
    End Property

    Public Shared Property listaRicoveri As DataTable
        '
        ' AGGIUNGE IN SESSIONE LA LISTA DEI REFERTI DA RINOTIFICARE
        '
        Get
            Return CType(HttpContext.Current.Session(KEY_LISTA_RICOVERI_NOTIFICA), System.Data.DataTable)
        End Get
        Set(value As DataTable)
            HttpContext.Current.Session(KEY_LISTA_RICOVERI_NOTIFICA) = value
        End Set
    End Property

    Public Shared Property listaRefertiNotificati As List(Of RefertoNotificato)
        '
        ' AGGIUNGE IN SESSIONE LA LISTA DEI REFERTI EFFETTIVAMENTE RINOTIFICATI.
        '
        Get
            Return CType(HttpContext.Current.Session(KEY_LISTA_REFERTI_NOTIFICATI), List(Of RefertoNotificato))
        End Get
        Set(value As List(Of RefertoNotificato))
            HttpContext.Current.Session(KEY_LISTA_REFERTI_NOTIFICATI) = value
        End Set
    End Property

    Public Shared Property listaRicoveriNotificati As List(Of RicoveroNotificato)
        '
        ' AGGIUNGE IN SESSIONE LA LISTA DEI REFERTI EFFETTIVAMENTE RINOTIFICATI.
        '
        Get
            Return CType(HttpContext.Current.Session(KEY_LISTA_RICOVERI_NOTIFICATI), List(Of RicoveroNotificato))
        End Get
        Set(value As List(Of RicoveroNotificato))
            HttpContext.Current.Session(KEY_LISTA_RICOVERI_NOTIFICATI) = value
        End Set
    End Property



End Class


Public Class RicoveroNotificato
    Public Property Id() As String
    Public Property AziendaErogante() As String
    Public Property NumeroNosologico() As String
    Public Property StatoNotifica() As String
    Public Property Eccezione() As String

End Class

Public Class RefertoNotificato
    Public Property Id() As String
    Public Property StatoNotifica() As String
    Public Property Eccezione() As String
End Class