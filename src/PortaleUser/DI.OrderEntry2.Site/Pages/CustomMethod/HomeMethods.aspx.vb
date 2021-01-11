Imports System
Imports System.ComponentModel
Imports System.Web.UI
Imports System.Web.Services
Imports System.Linq
Imports System.Collections.Generic
Imports System.ServiceModel
Imports DI.PortalUser2.Data

Namespace DI.OrderEntry.User

    Public Class HomeMethods
        Inherits Page

        <WebMethod()>
        Public Shared Function GetInfoRicovero(azienda As String, nosologico As String) As String
            Try
                Dim infoRicovero = DettaglioPaziente.GetDatiRicoveroByNosologicoAzienda(nosologico, azienda)

                If infoRicovero Is Nothing Then
                    Return String.Empty
                Else
                    'prendo l'ultimo evento in ordine cronologico che ha valorizzato il reparto codice
                    'Dim RepartoDesc = (From ric In infoRicovero.RicoveroEventi
                    ' Where Not String.IsNullOrEmpty(ric.RepartoRicoveroCodice)
                    ' Order By ric.DataEvento
                    ').Last.RepartoRicoveroDescr

                    Dim RepartoDesc As String = Nothing

                    If infoRicovero.StrutturaConclusione IsNot Nothing Then
                        RepartoDesc = infoRicovero.StrutturaConclusione.Descrizione
                    ElseIf infoRicovero.StrutturaUltimoEvento IsNot Nothing Then
                        RepartoDesc = infoRicovero.StrutturaUltimoEvento.Descrizione
                    End If

                    'TODO: rivedere la logica di lista accettazione "LA", andare a cercare fra gli attributi...
                    'Se repartoDesc è vuota non verrà valorizzata la descrizione del  reparto di ricovero nel pannello paziente.
                    Return String.Format("{3} <b>{0}</b> il {1:d}<br />({2})", RepartoDesc,
                  If(infoRicovero.DataConclusione.HasValue, infoRicovero.DataConclusione.Value, If(infoRicovero.DataApertura.HasValue, infoRicovero.DataApertura.Value, Nothing)),
                  infoRicovero.NumeroNosologico,
                  If(infoRicovero.DataConclusione.HasValue, "Dimesso da", If(infoRicovero.NumeroNosologico.StartsWith("LA"), "Prenotato in", "Ricoverato in")))
                End If
            Catch ex As CustomException(Of WcfDwhClinico.ErroreType)
                '
                ' Eseguito solo se l'errore è restituito dalla chiamata al metodo del ws.
                '
                ExceptionsManager.TraceException(ex)
                Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)

                Return Nothing
            Catch ex As Exception
                ExceptionsManager.TraceException(ex)
                Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
                Return Nothing
            End Try

        End Function

    End Class

End Namespace