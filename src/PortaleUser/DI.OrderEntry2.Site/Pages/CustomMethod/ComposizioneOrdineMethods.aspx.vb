Imports System
Imports System.Web.UI
Imports System.ServiceModel
Imports DI.PortalUser2.Data
Imports System.Web
Imports System.Configuration
Imports DI.OrderEntry.Services
Imports System.Web.Services
Imports System.Linq
Imports System.Collections.Generic
Imports System.Data.SqlTypes
Imports System.ComponentModel
Imports System.Web.UI.WebControls
Imports System.IO
Imports DI.OrderEntry.User.Data

Namespace DI.OrderEntry.User

    Public Class ComposizioneOrdineMethods
        Inherits Page

#Region "Metodi Ricerca Prestazioni"
        '<DataObjectMethod(DataObjectMethodType.Select)>
        'Public Shared Function GetListaPrestazioniRecentiPerUO(uo As String, codiceDescrizione As String, regime As String, priorita As String) As List(Of PrestazioneListaType)
        '    Try
        '        Dim userData = UserDataManager.GetUserData()
        '        Dim listaPrestazioni As New List(Of PrestazioneListaType)
        '        Using webService As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")

        '            Dim request = New CercaPrestazioniPerUnitaOperativaRequest(userData.Token, Utility.StringToEnum(Of RegimeEnum)(regime), Utility.StringToEnum(Of PrioritaEnum)(priorita), uo.Split("-")(0), uo.Substring(uo.IndexOf("-") + 1), DI.Common.Utility.GetAziendaRichiedente, My.Settings.SistemaRichiedente, Nothing, Nothing, codiceDescrizione)

        '            Dim response = webService.CercaPrestazioniPerUnitaOperativa(request)

        '            Dim prestazioni = response.CercaPrestazioniPerUnitaOperativaResult

        '            If prestazioni Is Nothing Then
        '                Return Nothing
        '            End If

        '            If prestazioni IsNot Nothing AndAlso prestazioni.Count > 0 Then
        '                listaPrestazioni = (From prestazione
        '                                    In prestazioni.Take(110)
        '                                    Order By prestazione.Descrizione
        '                                    Select prestazione
        '                                    ).ToList()
        '            End If

        '            Return listaPrestazioni
        '        End Using
        '    Catch ex As FaultException(Of DataFault)

        '        Throw New Exception(ex.Detail.Message)
        '    Catch ex As Exception

        '        ExceptionsManager.TraceException(ex)

        '        Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)

        '        portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)

        '        Throw
        '    End Try
        'End Function

        '<DataObjectMethod(DataObjectMethodType.Select)>
        'Public Shared Function GetListaPrestazioniRecentiPerPaziente(uo As String, idPaziente As String, codiceDescrizione As String, regime As String, priorita As String) As List(Of PrestazioneListaType)
        '    Try

        '        Dim userData = UserDataManager.GetUserData()
        '        Dim listaPrestazioni As New List(Of PrestazioneListaType)
        '        Using webService As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")

        '            Dim request = New CercaPrestazioniPerPazienteRequest(userData.Token, Utility.StringToEnum(Of RegimeEnum)(regime), Utility.StringToEnum(Of PrioritaEnum)(priorita), uo.Split("-")(0), uo.Substring(uo.IndexOf("-") + 1), DI.Common.Utility.GetAziendaRichiedente, My.Settings.SistemaRichiedente, Nothing, Nothing, idPaziente, codiceDescrizione)

        '            Dim response = webService.CercaPrestazioniPerPaziente(request)

        '            Dim prestazioni = response.CercaPrestazioniPerPazienteResult

        '            If prestazioni Is Nothing Then
        '                Return Nothing
        '            End If

        '            If prestazioni IsNot Nothing AndAlso prestazioni.Count > 0 Then
        '                listaPrestazioni = (From prestazione
        '                                    In prestazioni.Take(110)
        '                                    Order By prestazione.Descrizione
        '                                    Select prestazione
        '                                    ).ToList()
        '            End If

        '            Return listaPrestazioni
        '        End Using
        '    Catch ex As FaultException(Of DataFault)

        '        Throw New Exception(ex.Detail.Message)
        '    Catch ex As Exception

        '        ExceptionsManager.TraceException(ex)

        '        Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)

        '        portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)

        '        Throw
        '    End Try
        'End Function

        '<DataObjectMethod(DataObjectMethodType.Select)>
        'Public Shared Function GetListaPrestazioniPerErogante(uo As String, aziendaErogante As String, sistemaErogante As String, codiceDescrizione As String, regime As String, priorita As String) As List(Of PrestazioneListaType)
        '    Try
        '        Dim userData = UserDataManager.GetUserData()

        '        Dim listaPrestazioni As New List(Of PrestazioneListaType)
        '        Dim prestazioni As PrestazioniListaType

        '        Using webService As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")
        '            If Not String.IsNullOrEmpty(sistemaErogante) Then
        '                'ricerca sul singolo sistema erogante
        '                Dim request = New CercaPrestazioniPerSistemaEroganteRequest(userData.Token, Utility.StringToEnum(Of RegimeEnum)(regime), Utility.StringToEnum(Of PrioritaEnum)(priorita), uo.Split("-")(0), uo.Substring(uo.IndexOf("-") + 1), DI.Common.Utility.GetAziendaRichiedente, My.Settings.SistemaRichiedente, aziendaErogante, sistemaErogante, codiceDescrizione)
        '                Dim response = webService.CercaPrestazioniPerSistemaErogante(request)
        '                prestazioni = response.CercaPrestazioniPerSistemaEroganteResult
        '            Else
        '                'ricerca per tutti i sistemi eroganti
        '                Dim request = New CercaPrestazioniPerCodiceODescrizioneRequest(userData.Token, Utility.StringToEnum(Of RegimeEnum)(regime), Utility.StringToEnum(Of PrioritaEnum)(priorita), uo.Split("-")(0), uo.Substring(uo.IndexOf("-") + 1), DI.Common.Utility.GetAziendaRichiedente, My.Settings.SistemaRichiedente, aziendaErogante, sistemaErogante, codiceDescrizione)
        '                Dim response = webService.CercaPrestazioniPerCodiceODescrizione(request)
        '                prestazioni = response.CercaPrestazioniPerCodiceODescrizioneResult
        '            End If
        '        End Using


        '        If prestazioni IsNot Nothing AndAlso prestazioni.Count > 0 Then
        '            listaPrestazioni = (From prestazione
        '                                In prestazioni.Take(110)
        '                                Order By prestazione.Descrizione
        '                                Select prestazione
        '                                ).ToList()
        '        End If

        '        Return listaPrestazioni
        '    Catch ex As FaultException(Of DataFault)

        '        Throw New Exception(ex.Detail.Message)
        '    Catch ex As Exception

        '        ExceptionsManager.TraceException(ex)

        '        Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)

        '        portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)

        '        Throw
        '    End Try
        'End Function
#End Region

        '<WebMethod()> <DataObjectMethod(DataObjectMethodType.Select)>
        'Public Shared Function GetListaPrestazioniPerGruppi2(regime As String, priorita As String, uo As String, idGruppo As String, descrizione As String) As List(Of PrestazioneListaType)
        '    Try
        '        Dim userData = UserDataManager.GetUserData()

        '        Using webService As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")

        '            Dim request = New CercaPrestazioniPerGruppoPrestazioniRequest(userData.Token, Utility.StringToEnum(Of RegimeEnum)(regime), Utility.StringToEnum(Of PrioritaEnum)(priorita), uo.Split("-")(0), uo.Substring(uo.IndexOf("-") + 1), DI.Common.Utility.GetAziendaRichiedente, My.Settings.SistemaRichiedente, Nothing, Nothing, idGruppo, descrizione)

        '            Dim response = webService.CercaPrestazioniPerGruppoPrestazioni(request)

        '            Dim prestazioni = response.CercaPrestazioniPerGruppoPrestazioniResult

        '            Dim listaPrestazioni As New List(Of PrestazioneListaType)
        '            If prestazioni IsNot Nothing AndAlso prestazioni.Count > 0 Then
        '                listaPrestazioni = (From prestazione
        '                                    In prestazioni.Take(110)
        '                                    Order By prestazione.Descrizione
        '                                    Select prestazione
        '                                    ).ToList()
        '            End If

        '            Return listaPrestazioni
        '        End Using
        '    Catch ex As FaultException(Of DataFault)

        '        Throw New Exception(ex.Detail.Message)
        '    Catch ex As Exception

        '        ExceptionsManager.TraceException(ex)

        '        Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)

        '        portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)

        '        Throw
        '    End Try

        'End Function

        '<DataObjectMethod(DataObjectMethodType.Select)>
        'Public Shared Function GetPrestazione(uo As String, aziendaSistemaEroganteCodicePrestazione As String, regime As String, priorita As String) As Object
        '    Try
        '        Dim userData = UserDataManager.GetUserData()

        '        Using webService As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")

        '            Dim azienda = aziendaSistemaEroganteCodicePrestazione.Split("+")(0)
        '            Dim codiceSistema = aziendaSistemaEroganteCodicePrestazione.Split("+")(1)
        '            Dim codicePrestazione = aziendaSistemaEroganteCodicePrestazione.Split("+")(2)

        '            Dim request = New CercaPrestazioniPerCodiceODescrizioneRequest(userData.Token, Utility.StringToEnum(Of RegimeEnum)(regime), Utility.StringToEnum(Of PrioritaEnum)(priorita), uo.Split("-")(0), uo.Substring(uo.IndexOf("-") + 1), DI.Common.Utility.GetAziendaRichiedente, My.Settings.SistemaRichiedente, azienda, codiceSistema, codicePrestazione)

        '            Dim response = webService.CercaPrestazioniPerCodiceODescrizione(request).CercaPrestazioniPerCodiceODescrizioneResult

        '            If response Is Nothing OrElse response.Count = 0 Then
        '                Return Nothing
        '            End If

        '            ' il metodo CercaPrestazioniPerCodiceODescrizioneRequest esegue una ricerca per like, ora cerco quelle uguali.
        '            Dim prestazioni = response.Where(Function(e) String.Compare(e.Codice, codicePrestazione, True) = 0)

        '            If prestazioni.Count = 0 Then
        '                Return Nothing
        '            End If

        '            Dim prestazione = prestazioni.First

        '            Return New With {
        '             .Id = prestazione.Id,
        '             .Codice = prestazione.Codice,
        '             .Descrizione = prestazione.Descrizione,
        '             .CodiceErogante = String.Format("{0}-{1}", prestazione.SistemaErogante.Azienda.Codice, prestazione.SistemaErogante.Sistema.Codice),
        '             .SistemaErogante = String.Format("{0}-{1}", prestazione.SistemaErogante.Azienda.Codice, If(String.IsNullOrEmpty(prestazione.SistemaErogante.Sistema.Descrizione), prestazione.SistemaErogante.Sistema.Codice, prestazione.SistemaErogante.Sistema.Descrizione)),
        '             .Valido = True
        '             }
        '        End Using
        '    Catch ex As FaultException(Of DataFault)

        '        Throw New Exception(ex.Detail.Message)
        '    Catch ex As Exception

        '        ExceptionsManager.TraceException(ex)

        '        Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)

        '        portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)

        '        Return Nothing
        '    End Try
        'End Function
    End Class

End Namespace


