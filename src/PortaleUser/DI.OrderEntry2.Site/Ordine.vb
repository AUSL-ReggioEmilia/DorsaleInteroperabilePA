Imports DI.OrderEntry.User
Imports DI.OrderEntry.Services
Imports System.ServiceModel
Imports System.Linq
Imports DI.PortalUser2.Data
Imports System.Collections.Generic
Imports System.Web.UI.WebControls
Imports System.Text

''' <summary>
''' Metodi convidisi per la gestione dei dati dell'ordine
''' </summary>
''' <remarks></remarks>
Public Class Ordine

    ''' <summary>
    ''' Estrae dall'ordine gli eventuali messaggi di errore di validazione
    ''' </summary>
    Public Shared Function GetMessaggiValidazione(IdRichiesta As String) As List(Of String)
        Dim oRet As New List(Of String)

        Try
            Using webService As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")
                Dim userData = UserDataManager.GetUserData()
                Dim request = New OttieniOrdinePerIdGuidRequest(userData.Token, IdRichiesta)
                Dim response = webService.OttieniOrdinePerIdGuid(request)
                Dim result = response.OttieniOrdinePerIdGuidResult

                If result Is Nothing OrElse result.Ordine.RigheRichieste Is Nothing OrElse result.Ordine.RigheRichieste.Count = 0 Then
                    Return oRet
                End If

                If Not String.IsNullOrEmpty(result.StatoValidazione.Descrizione) Then
                    oRet.Add(result.StatoValidazione.Descrizione)
                End If

                For i As Integer = 0 To result.StatoValidazione.Righe.Count - 1

                    Dim descPrestazione = result.Ordine.RigheRichieste(i).Prestazione.Descrizione
                    Dim descValidazione = result.StatoValidazione.Righe(i).Descrizione
                    If Not String.IsNullOrEmpty(descValidazione) Then
                        oRet.Add(descPrestazione)
                        oRet.Add(descValidazione)
                    End If
                Next

            End Using

            Return oRet

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
    ''' Restituisce gli errori di validazione dei dati accessori
    ''' </summary>
    ''' <param name="IdRichiesta"></param>
    ''' <returns></returns>
    Public Shared Function GetMessaggiValidazione2(IdRichiesta As String) As String
        Dim sbScript As New StringBuilder

        Try
            Using webService As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")
                Dim userData = UserDataManager.GetUserData()
                Dim request = New OttieniOrdinePerIdGuidRequest(userData.Token, IdRichiesta)
                Dim response = webService.OttieniOrdinePerIdGuid(request)
                Dim result = response.OttieniOrdinePerIdGuidResult

                If result Is Nothing OrElse result.Ordine.RigheRichieste Is Nothing OrElse result.Ordine.RigheRichieste.Count = 0 Then
                    Return sbScript.ToString
                End If

                If Not String.IsNullOrEmpty(result.StatoValidazione.Descrizione) Then
                    sbScript.AppendLine("<div class='row'><div class='col-sm-12 h4 text-danger'>" & result.StatoValidazione.Descrizione & "<hr/></div></div>")
                End If

                For i As Integer = 0 To result.StatoValidazione.Righe.Count - 1
                    Dim descPrestazione = result.Ordine.RigheRichieste(i).Prestazione.Descrizione
                    Dim descValidazione = result.StatoValidazione.Righe(i).Descrizione

                    If Not String.IsNullOrEmpty(descValidazione) Then
                        sbScript.AppendLine("<div class='row'><div class='col-sm-12'><div class='panel panel-default'><div class='panel-heading text-uppercase'>Prestazione &nbsp; <strong>" & descPrestazione & "</strong></div><div class='panel-body'>")
                        sbScript.AppendLine("<p>" & descValidazione & " </p></div></div></div></div>")
                    End If
                Next
            End Using

            Return sbScript.ToString

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
