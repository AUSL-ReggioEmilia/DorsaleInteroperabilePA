Imports System
Imports System.Linq
Imports System.Web.UI
Imports System.Data

Imports System.Web.UI.WebControls
Imports System.Data.SqlTypes
Imports System.Web.Services
Imports System.Text
Imports System.Web

'Imports DI.Common
Imports DI.PortalAdmin.Data
Imports System.Collections
Imports DI.DataWarehouse.Admin.Data
Imports System.Configuration
Imports System.Collections.Generic
Imports DI.DataWarehouse.Admin.Data.BackEndDataSet

Namespace DI.DataWarehouse.Admin

    Public Class AbbonamentiStampeDettaglio
        Inherits Page

        Private Const PageSessionIdPrefix As String = "AbbonamentiStampeDettaglio_"

        <WebMethod()>
        Public Shared Function CaricaDettaglio(ByVal id As Object) As Object
            Try
                Dim idGuid = New Guid(id.ToString())

                Dim table = DataAdapterManager.GetStampeSottoscrizioniDettaglio(idGuid)

                If table.Count = 0 Then
                    Throw New Exception("Id non presente")
                End If

                Dim row = table(0)
                Dim reparti = DataAdapterManager.GetRepartiRichiedentiStampeSottoscrizioni(idGuid)

                Return New With {.Account = row.Account,
                                 .DataFine = row.DataFine.ToString("dd/MM/yyyy"),
                                 .IdStato = row.IdStato,
                                 .Stato = row.Stato,
                                 .IdTipoReferto = row.IdTipoReferti,
                                 .IdTipoAbbonamento = row.IdTipoSottoscrizione,
                                 .ServerDiStampa = row.ServerDiStampa,
                                 .Stampante = row.Stampante,
                                 .Nome = row.Nome,
                                 .Descrizione = row.Descrizione,
                                 .StampaConfidenziali = row.StampaConfidenziali,
                                 .StampaOscurati = row.StampaOscurati,
                                 .NumeroCopie = row.NumeroCopie,
                                 .RepartiRichiedenti = (From reparto In reparti
                                                        Select New With {.Id = reparto.IdReparto.ToString(),
                                                                         .Azienda = reparto.AziendaErogante,
                                                                         .Sistema = reparto.SistemaErogante,
                                                                         .Codice = reparto.RepartoRichiedenteCodice,
                                                                         .Descrizione = reparto.RepartoRichiedenteDescrizione
                                                        })
                                }
            Catch ex As Exception

                Dim sMessage As String = Utility.TrapError(ex, True)

                'Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalUserConnectionString").ConnectionString)
                'portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.DwhClinico)

                Return Nothing
            End Try
        End Function

        <WebMethod()>
        Public Shared Function GeLookupTipiReferti() As Dictionary(Of String, String)
            Try
                Dim lookup = DataAdapterManager.GetLookupTipiReferti()

                Dim requestedLookup = From tipo In lookup
                                      Select New With {.Id = tipo.Id, .Descrizione = tipo.Descrizione}

                Return requestedLookup.ToDictionary(Of String, String)(Function(kv) kv.Id, Function(kv) kv.Descrizione)

            Catch ex As Exception
                Dim sMessage As String = Utility.TrapError(ex, True)
                Return Nothing
            End Try
        End Function

        <WebMethod()>
        Public Shared Function GeLookupTipiAbbonamento() As Dictionary(Of String, String)
            Try
                Dim lookup = DataAdapterManager.GetLookupTipiAbbonamenti()

                Dim requestedLookup = From tipo In lookup
                                          Select New With {.Id = tipo.Id, .Descrizione = tipo.Descrizione}

                Return requestedLookup.ToDictionary(Of String, String)(Function(kv) kv.Id, Function(kv) kv.Descrizione)
            Catch ex As Exception
                Dim sMessage As String = Utility.TrapError(ex, True)
                Return Nothing
            End Try
        End Function

        <WebMethod()>
        Public Shared Function GeLookupAziende() As Dictionary(Of String, String)
            Try
                Dim lookup = DataAdapterManager.GetLookupAziendeEroganti()

                Dim requestedLookup = From azienda In lookup
                                      Select New With {.Codice = azienda.Codice,
                                                       .Descrizione = azienda.Descrizione}

                Return requestedLookup.ToDictionary(Of String, String)(Function(kv) kv.Codice, Function(kv) kv.Descrizione)
            Catch ex As Exception
                Dim sMessage As String = Utility.TrapError(ex, True)
                Return Nothing
            End Try
        End Function

        <WebMethod()>
        Public Shared Function GeLookupSistemi(codiceAzienda As String) As Dictionary(Of String, String)
            Try
                Dim lookup = DataAdapterManager.GetLookupSistemiEroganti(codiceAzienda)

                Dim requestedLookup = From sistema In lookup
                                      Select New With {.Codice = sistema.Codice,
                                                       .Descrizione = sistema.Descrizione}

                Return requestedLookup.ToDictionary(Of String, String)(Function(kv) kv.Codice, Function(kv) kv.Descrizione)
            Catch ex As Exception
                Dim sMessage As String = Utility.TrapError(ex, True)
                Return Nothing
            End Try
        End Function

        <WebMethod()>
        Public Shared Function CancellaSottoscrizione(id As String) As String
            Try
                DataAdapterManager.DeleteSottoscrizione(New Guid(id))

                Return "ok"
            Catch ex As Exception

                Dim sMessage As String = Utility.TrapError(ex, True)

                'Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)
                'portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.DwhClinico)

                Return "error"
            End Try
        End Function

        <WebMethod()>
        Public Shared Function CambiaStatoAttivazioneSottoscrizione(id As String) As String
            Try
                DataAdapterManager.ChangeActivationState(New Guid(id))

                Return "ok"
            Catch ex As Exception

                Dim sMessage As String = Utility.TrapError(ex, True)

                'Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)
                'portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.DwhClinico)

                Return "error"
            End Try
        End Function

        <WebMethod()>
        Public Shared Function RimuoviReparti(ByVal idSottoscrizione As String, listaId As String) As String
            Try
                If Not String.IsNullOrEmpty(listaId) Then
                    listaId = HttpUtility.UrlDecode(listaId)
                End If

                For Each idSistema In listaId.Split(";"c)
                    DataAdapterManager.RemoveSistemaFromSottoscrizione(New Guid(idSottoscrizione), New Guid(idSistema))
                Next

                Return "ok"

            Catch ex As Exception

                Dim sMessage As String = Utility.TrapError(ex, True)

                'Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)
                'portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.DwhClinico)

                Return "error"
            End Try
        End Function

        <WebMethod()>
        Public Shared Function Salva(ByVal idSottoscrizione As String, dataFine As String,
                                           idTipoReferto As Integer, serverDiStampa As String, stampante As String,
                                           nome As String, descrizione As String, listaIdReparti As String, stampaConfidenziali As Object, stampaOscurati As Object, numeroCopie As Integer) As Object
            Try
                Dim testata
                Dim newRow As StampeSottoscrizioniDettaglioRow
                Dim guidSottoscrizione As Guid

                If String.IsNullOrEmpty(idSottoscrizione) Then

                    testata = New StampeSottoscrizioniDettaglioDataTable()
                    newRow = testata.NewStampeSottoscrizioniDettaglioRow()

                    guidSottoscrizione = Guid.NewGuid()
                    newRow.Id = guidSottoscrizione
                    newRow.IdTipoSottoscrizione = 1 'Admin
                    newRow.IdStato = 3 'DISATTIVA
                    newRow.NumeroCopie = 1 'inizializzo a 1 il numero di copie
                Else
                    guidSottoscrizione = New Guid(idSottoscrizione)

                    testata = DataAdapterManager.GetStampeSottoscrizioniDettaglio(guidSottoscrizione)
                    newRow = testata(0)
                End If

                newRow.Account = HttpContext.Current.User.Identity.Name
                newRow.DataFine = DateTime.Parse(dataFine)
                newRow.IdTipoReferti = idTipoReferto

                newRow.ServerDiStampa = HttpUtility.UrlDecode(serverDiStampa)
                newRow.Stampante = HttpUtility.UrlDecode(stampante)
                newRow.Nome = HttpUtility.UrlDecode(nome)
                newRow.Descrizione = HttpUtility.HtmlDecode(HttpUtility.UrlDecode(descrizione))
                newRow.StampaConfidenziali = CType(stampaConfidenziali, Boolean)
                newRow.StampaOscurati = CType(stampaOscurati, Boolean)
                'Valorizzo il numero di copie con l'input dell'utente
                newRow.NumeroCopie = numeroCopie

                If String.IsNullOrEmpty(idSottoscrizione) Then

                    testata.AddStampeSottoscrizioniDettaglioRow(newRow)
                Else
                    testata.AcceptChanges()
                    newRow.SetModified()
                End If

                DataAdapterManager.Update(testata)

                Return newRow.Id

            Catch ex As Exception

                Dim sMessage As String = Utility.TrapError(ex, True)

                'Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)
                'portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.DwhClinico)

                Return "error"
            End Try
        End Function

        <WebMethod()>
        Public Shared Function AggiungiReparti(ByVal idSottoscrizione As String, listaId As String) As Object
            Try
                If Not String.IsNullOrEmpty(listaId) Then
                    listaId = HttpUtility.UrlDecode(listaId)
                End If

                For Each idSistema In listaId.Split(";"c)
                    DataAdapterManager.AddSistemaToSottoscrizione(New Guid(idSottoscrizione), New Guid(idSistema))
                Next

                Return "ok"

            Catch ex As Exception

                Dim sMessage As String = Utility.TrapError(ex, True)

                'Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)
                'portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.DwhClinico)

                Return "error"
            End Try
        End Function

        <WebMethod()>
        Public Shared Function CercaReparti(ByVal azienda As String, sistema As String, descrizione As String) As Object
            Try
                Dim reparti = DataAdapterManager.SearchReparti(HttpUtility.UrlDecode(azienda), HttpUtility.UrlDecode(sistema), HttpUtility.UrlDecode(descrizione))

                Return From reparto In reparti
                       Select New With
                                    {
                                        .Id = reparto.Id,
                                        .Azienda = reparto.AziendaErogante,
                                        .Sistema = reparto.SistemaErogante,
                                        .Codice = reparto.RepartoRichiedenteCodice,
                                        .Descrizione = reparto.RepartoRichiedenteDescrizione
                                    }
            Catch ex As Exception

                Dim sMessage As String = Utility.TrapError(ex, True)

                'Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)
                'portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.DwhClinico)

                Return Nothing
            End Try
        End Function
    End Class

End Namespace