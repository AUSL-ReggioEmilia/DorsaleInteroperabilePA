Imports System.Web.UI
Imports System.Web.Services
Imports System.Collections.Generic
Imports DI.PortalUser2.Data
Imports System.ServiceModel
Imports DI.OrderEntry.Services
Imports System.ComponentModel

Namespace DI.OrderEntry.User

    Public Class ProfiliUtenteMethods
        Inherits Page

        Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load

        End Sub

        '<WebMethod()>
        'Public Shared Function GetLookupSistemiEroganti() As Dictionary(Of String, String)

        '    Return LookupManager.GetSistemiEroganti()
        'End Function

        '<WebMethod()>
        'Public Shared Function GetProfili(codiceDescrizione As String) As Dictionary(Of String, Object)

        '    Dim list = New Dictionary(Of String, Object)()

        '    Try
        '        Dim userData = UserDataManager.GetUserData()

        '        Using webService As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")

        '            If codiceDescrizione.Length = 0 Then
        '                codiceDescrizione = Nothing
        '            End If

        '            Dim request = New CercaProfiliUtentePerCodiceODescrizioneRequest(userData.Token, codiceDescrizione)

        '            Dim response = webService.CercaProfiliUtentePerCodiceODescrizione(request)

        '            Dim result = response.CercaProfiliUtentePerCodiceODescrizioneResult

        '            If result Is Nothing Then
        '                Return Nothing
        '            End If

        '            For Each profilo In result

        '                list.Add(profilo.Id.ToString(), New With {.Codice = profilo.Codice, .Descrizione = profilo.Descrizione})
        '            Next

        '            Return list
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

        '<WebMethod()>
        'Public Shared Function GetPrestazioni(idProfilo As String) As Dictionary(Of String, Object)

        '    Dim list = New Dictionary(Of String, Object)()

        '    Try
        '        Dim userData = UserDataManager.GetUserData()

        '        Using webService As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")

        '            Dim request = New OttieniProfiloUtentePerIdRequest(userData.Token, idProfilo)

        '            Dim response = webService.OttieniProfiloUtentePerId(request)

        '            Dim result = response.OttieniProfiloUtentePerIdResult

        '            If result Is Nothing Then
        '                Return Nothing
        '            End If

        '            For Each row In result.Prestazioni

        '                Dim prestazione = New With {.Id = row.Id, .Codice = row.Codice, .Descrizione = row.Descrizione, .SistemaErogante = String.Format("{0}-{1}", row.SistemaErogante.Azienda.Codice, row.SistemaErogante.Sistema.Codice)}

        '                list.Add(row.Id.ToString(), prestazione)
        '            Next

        '            Return If(list.Count = 0, Nothing, list)
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

        '<WebMethod()>
        'Public Shared Function GetListaPrestazioni(descrizione As String, erogante As String) As Dictionary(Of String, Object)

        '    If Not String.IsNullOrEmpty(descrizione) Then
        '        descrizione = HttpUtility.UrlDecode(descrizione)
        '    Else
        '        descrizione = Nothing
        '    End If

        '    Dim list = New Dictionary(Of String, Object)()

        '    Dim azienda = erogante.Split("-")(0)
        '    Dim sistema = erogante.Substring(erogante.IndexOf("-") + 1)

        '    Try
        '        Dim userData = UserDataManager.GetUserData()

        '        Using webService As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")

        '            Dim request = New CercaPrestazioniProfiliUtentePerCodiceODescrizioneRequest(userData.Token, DI.Common.Utility.GetAziendaRichiedente, My.Settings.SistemaRichiedente, azienda, sistema, descrizione)

        '            Dim response = webService.CercaPrestazioniProfiliUtentePerCodiceODescrizione(request)

        '            Dim result = response.CercaPrestazioniProfiliUtentePerCodiceODescrizioneResult

        '            If result Is Nothing Then
        '                Return Nothing
        '            End If

        '            For Each row In result

        '                Dim prestazione = New With {.Id = row.Id, .Codice = row.Codice, .Descrizione = If(String.IsNullOrEmpty(row.Descrizione), String.Empty, row.Descrizione), .SistemaErogante = String.Format("{0}-{1}", row.SistemaErogante.Azienda.Codice, row.SistemaErogante.Sistema.Codice)}

        '                list.Add(row.Id.ToString(), prestazione)
        '            Next

        '            Return If(list.Count = 0, Nothing, list)
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

        '<WebMethod()>
        'Public Shared Function UpdateProfilo(idProfilo As String, descrizione As String) As String
        '    Try
        '        Dim userData = UserDataManager.GetUserData()

        '        Using webService As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")

        '            If Not String.IsNullOrEmpty(descrizione) Then
        '                descrizione = HttpUtility.UrlDecode(descrizione)
        '            End If

        '            Dim profilo As ProfiloUtenteType
        '            If String.IsNullOrEmpty(idProfilo) Then

        '                profilo = New ProfiloUtenteType()

        '                profilo.Prestazioni = New ProfiloUtentePrestazioniType()
        '            Else
        '                profilo = webService.OttieniProfiloUtentePerId(New OttieniProfiloUtentePerIdRequest(userData.Token, idProfilo)).OttieniProfiloUtentePerIdResult
        '            End If

        '            profilo.Descrizione = descrizione

        '            Dim request = New AggiungiOppureModificaProfiloUtenteRequest(userData.Token, profilo)

        '            Dim response = webService.AggiungiOppureModificaProfiloUtente(request)

        '            Dim result = response.AggiungiOppureModificaProfiloUtenteResult

        '            If result Is Nothing Then
        '                Return Nothing
        '            End If

        '            Return result.Id
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

        '<WebMethod()>
        'Public Shared Function DeleteProfilo(idProfilo As String) As String
        '    Try
        '        Dim userData = UserDataManager.GetUserData()

        '        Using webService As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")

        '            Dim request = New CancellaProfiloUtentePerIdRequest(userData.Token, idProfilo)

        '            Dim response = webService.CancellaProfiloUtentePerId(request)

        '            Return "Ok"
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

        <WebMethod()>
        Public Shared Function DeletePrestazioneDaProfilo(idProfilo As String, idPrestazioni As String) As String
            Try
                Dim userData = UserDataManager.GetUserData()

                Using webService As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")

                    Dim profilo = webService.OttieniProfiloUtentePerId(New OttieniProfiloUtentePerIdRequest(userData.Token, idProfilo)).OttieniProfiloUtentePerIdResult

                    Dim ids = idPrestazioni.Split(";"c)

                    profilo.Prestazioni.RemoveAll(Function(e) Array.IndexOf(ids, e.Id) > -1)

                    Dim request = New AggiungiOppureModificaProfiloUtenteRequest(userData.Token, profilo)

                    Dim response = webService.AggiungiOppureModificaProfiloUtente(request)

                    Dim result = response.AggiungiOppureModificaProfiloUtenteResult

                    If result Is Nothing Then
                        Return Nothing
                    End If

                    Return "Ok"
                End Using
            Catch ex As FaultException(Of DataFault)

                Throw New Exception(ex.Detail.Message)
            Catch ex As Exception

                ExceptionsManager.TraceException(ex)

                Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)

                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)

                Return Nothing
            End Try
        End Function

        ''' <summary>
        ''' 
        ''' </summary>
        ''' <param name="idProfilo"></param>
        ''' <param name="idPrestazioni">Elenco di idPrestazione concatenati da ";"</param>
        ''' <returns></returns>
        ''' <remarks></remarks>
        <WebMethod()>
        Public Shared Function InsertPrestazioniInProfilo(idProfilo As String, idPrestazioni As String) As String
            Try
                Dim userData = UserDataManager.GetUserData()

                Using webService As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")

                    Dim profilo = webService.OttieniProfiloUtentePerId(New OttieniProfiloUtentePerIdRequest(userData.Token, idProfilo)).OttieniProfiloUtentePerIdResult

                    For Each idPrestazione In idPrestazioni.Split(";"c)

                        profilo.Prestazioni.Add(New ProfiloUtentePrestazioneType() With {.Id = idPrestazione})
                    Next

                    Dim request = New AggiungiOppureModificaProfiloUtenteRequest(userData.Token, profilo)

                    Dim response = webService.AggiungiOppureModificaProfiloUtente(request)

                    Dim result = response.AggiungiOppureModificaProfiloUtenteResult

                    If result Is Nothing Then
                        Return Nothing
                    End If

                    Return "Ok"
                End Using
            Catch ex As FaultException(Of DataFault)

                Throw New Exception(ex.Detail.Message)
            Catch ex As Exception

                ExceptionsManager.TraceException(ex)

                Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)

                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)

                Return Nothing
            End Try
        End Function

    End Class

    <DataObject(True)>
    Public Class Profili

        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetData(codiceDescrizione As String) As ProfiliUtenteListaType

            Dim result As ProfiliUtenteListaType

            Try
                Dim userData = UserDataManager.GetUserData()

                Using webService As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")

                    If codiceDescrizione.Length = 0 Then
                        codiceDescrizione = Nothing
                    End If

                    Dim request = New CercaProfiliUtentePerCodiceODescrizioneRequest(userData.Token, codiceDescrizione)

                    Dim response = webService.CercaProfiliUtentePerCodiceODescrizione(request)

                    result = response.CercaProfiliUtentePerCodiceODescrizioneResult
                End Using

                Return result
            Catch ex As FaultException(Of DataFault)

                Throw New Exception(ex.Detail.Message)
            Catch ex As Exception

                ExceptionsManager.TraceException(ex)

                Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)

                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)

                Return Nothing
            End Try
        End Function


        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Shared Function GetDataPrestazioni(idProfilo As String) As ProfiloUtenteType

            Dim result As ProfiloUtenteType

            Try
                Dim userData = UserDataManager.GetUserData()

                Using webService As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")

                    Dim request = New OttieniProfiloUtentePerIdRequest(userData.Token, idProfilo)

                    Dim response = webService.OttieniProfiloUtentePerId(request)

                    result = response.OttieniProfiloUtentePerIdResult

                    'For Each row In result.Prestazioni

                    '    Dim prestazione = New With {.Id = row.Id, .Codice = row.Codice, .Descrizione = row.Descrizione, .SistemaErogante = String.Format("{0}-{1}", row.SistemaErogante.Azienda.Codice, row.SistemaErogante.Sistema.Codice)}

                    '    list.Add(row.Id.ToString(), prestazione)
                    'Next
                End Using

                Return result
            Catch ex As FaultException(Of DataFault)

                Throw New Exception(ex.Detail.Message)
            Catch ex As Exception

                ExceptionsManager.TraceException(ex)

                Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)

                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)

                Return Nothing
            End Try
        End Function

    End Class

End Namespace