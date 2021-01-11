Imports System
Imports System.Web.UI
Imports DI.OrderEntry.Services
Imports System.Web.Services
Imports System.ComponentModel
Imports DI.PortalUser2.Data
Imports System.Web
Imports System.Configuration
Imports System.Collections.Generic

Namespace DI.OrderEntry.User

    Public Class Login
        Inherits Page

        Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load

            If Not IsPostBack Then

                NomeLabel.Text = Me.User.Identity.Name
            End If
        End Sub

        <WebMethod()>
        <DataObjectMethod(DataObjectMethodType.Select)>
        Public Shared Function GetLookupAziende() As Dictionary(Of String, String)

            Return LookupManager.GetAziende()
        End Function

        <WebMethod()>
        <DataObjectMethod(DataObjectMethodType.Select)>
        Public Shared Function GeLookupUnitaOperative(azienda As String) As Dictionary(Of String, String)

            Return LookupManager.GetUnitaOperative(azienda)
        End Function

        <WebMethod()>
        Public Shared Sub Login(codiceAzienda As String, codiceUnitaOperativa As String)
            Try

                UserDataManager.GetUserData()

            Catch ex As Exception

                ExceptionsManager.TraceException(ex)

				Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)

                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)

                Throw
            End Try
        End Sub

        Public Shared Function GetToken() As TokenAccessoType

            Using webService As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")

				Dim request = New CreaTokenAccessoDelegaRequest(My.User.Name, DI.Common.Utility.GetAziendaRichiedente, My.Settings.SistemaRichiedente)

				Return webService.CreaTokenAccessoDelega(request).CreaTokenAccessoDelegaResult
            End Using
        End Function

        Public Shared Function GetTokentest() As TokenAccessoType

            'Using webService As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")

            '    Dim richiesta = New OrdineType()

            '    'se il campo IdGuidOrderEntry non è valorizzato l'ordine sarà aggiunto, 
            '    'altrimenti l'ordine corrispondente all'id specificato sarà sovrascritto
            '    richiesta.IdGuidOrderEntry = "7784D9F3-20E4-4A07-A6D5-36DFF4D55575"


            '    richiesta.DataRichiesta = DateTime.Now
            '    richiesta.IdRichiestaOrderEntry = String.Empty
            '    richiesta.Regime = New RegimeType() With {.Codice = RegimeEnum.AMB}
            '    richiesta.Priorita = New PrioritaType() With {.Codice = PrioritaEnum.O}

            '    richiesta.SistemaRichiedente = New SistemaType() With {
            '                                                           .Azienda = New CodiceDescrizioneType() With {.Codice = "ASMN"},
            '                                                           .Sistema = New CodiceDescrizioneType() With {.Codice = "PortaleRichiesta"}
            '                                                           }

            '    richiesta.UnitaOperativaRichiedente = New StrutturaType() With
            '                                                          {
            '                                                           .Azienda = New CodiceDescrizioneType() With {.Codice = "ASMN"},
            '                                                           .UnitaOperativa = New CodiceDescrizioneType() With {.Codice = "181"}
            '                                                          }

            '    richiesta.Paziente = New PazienteType() With {
            '                                                  .IdSac = "F4D55575-20E4-4A07-A6D5-7784D9F336DF",
            '                                                  .Cognome = "Prova",
            '                                                  .Nome = "Prova",
            '                                                  .CodiceFiscale = "PRVPRV28B82B180L",
            '                                                  .DataNascita = DateTime.Parse("28/02/1982"),
            '                                                  .Sesso = "M"
            '                                                 }

            '    richiesta.RigheRichieste = New RigheRichiesteType()


            '    richiesta.RigheRichieste.Add(New RigaRichiestaType() With {
            '             .Prestazione = New PrestazioneType() With {
            '                        .Id = String.Empty,
            '                        .Codice = "01"
            '                                                       },
            '             .SistemaErogante = New SistemaType() With {
            '                        .Azienda = New CodiceDescrizioneType() With {.Codice = "ASMN"},
            '                        .Sistema = New CodiceDescrizioneType() With {.Codice = "GST"}
            '                                                       }
            '                                                              })


            '    Dim request = New CancellaOrdinePerIdGuidRequest(token, "7784D9F3-20E4-4A07-A6D5-36DFF4D55575")

            '    Dim result = webService.CancellaOrdinePerIdGuid(request).CancellaOrdinePerIdGuidResult
            'End Using

            'Using webService As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")

            '    Dim request = New CancellaProfiloUtentePerIdRequest(tokenAccesso:=, "7784D9F3-20E4-4A07-A6D5-36DFF4D55575")

            '    webService.CancellaProfiloUtentePerId(request)
            'End Using



            'Using webService As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")

            '    'Dim request = New CercaPrestazioniProfiliUtentePerCodiceODescrizioneRequest(token, "ASMN", "PortaleRichiesta", "ASMN", "LIS-CNM", "sangue")

            '    'Dim prestazioni = webService.CercaPrestazioniProfiliUtentePerCodiceODescrizione(request).CercaPrestazioniProfiliUtentePerCodiceODescrizioneResult

            '    Dim profilo As New ProfiloUtenteType()

            '    profilo.Descrizione = "Nuovo Profilo"

            '    profilo.Prestazioni = New ProfiloUtentePrestazioniType()
            '    profilo.Prestazioni.Add(New ProfiloUtentePrestazioneType() With {.Id = "541059A6-A3F4-43FC-B574-BCFAAA9D7C00"})

            '    Dim request = New AggiungiOppureModificaProfiloUtenteRequest(token, profilo)

            '    Dim profiloUtente = webService.AggiungiOppureModificaProfiloUtente(request).AggiungiOppureModificaProfiloUtenteResult

            'End Using
            Return Nothing
        End Function

        Private Sub TestOrdine()

            'Step:
            'Creazione Token
            'Ricerca Prestazioni
            'Creazione Ordine e Inserimento Prestazioni          
            'Inoltro

            Using webService As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")

                'Creazione Token
                Dim tokenRequest = New CreaTokenAccessoRequest("ASMN", "SISRIC")

                Dim token = webService.CreaTokenAccesso(tokenRequest).CreaTokenAccessoResult

                'Ricerca Prestazioni
                Dim prestazioniRequest = New CercaPrestazioniPerSistemaEroganteRequest(token, RegimeEnum.AMB, PrioritaEnum.O, "ASMN", "181", "ASMN", "SISRIC", "ASMN", "LIS-CNM", Nothing)

                Dim prestazioni = webService.CercaPrestazioniPerSistemaErogante(prestazioniRequest).CercaPrestazioniPerSistemaEroganteResult

                If prestazioni Is Nothing OrElse prestazioni.Count = 0 Then
                    Return
                End If

                'Creazione Ordine
                Dim richiesta = New OrdineType()

                richiesta.DataRichiesta = DateTime.Now
                richiesta.IdRichiestaOrderEntry = String.Empty
				richiesta.Regime = New RegimeType() With {.Codice = RegimeEnum.AMB.ToString}
				richiesta.Priorita = New PrioritaType() With {.Codice = PrioritaEnum.O.ToString}

                richiesta.SistemaRichiedente = New SistemaType() With {
                         .Azienda = New CodiceDescrizioneType() With {.Codice = "ASMN"},
                         .Sistema = New CodiceDescrizioneType() With {.Codice = "SISRIC"}
                                                                      }
                richiesta.UnitaOperativaRichiedente = New StrutturaType() With {
                         .Azienda = New CodiceDescrizioneType() With {.Codice = "ASMN"},
                         .UnitaOperativa = New CodiceDescrizioneType() With {.Codice = "181"}
                                                                                }
                richiesta.Paziente = New PazienteType() With {
                         .IdSac = "F4D55575-20E4-4A07-A6D5-7784D9F336DF",
                         .Cognome = "Prova",
                         .Nome = "Prova",
                         .CodiceFiscale = "PRVPRV28B82B180L",
                         .DataNascita = DateTime.Parse("28/02/1982"),
                         .Sesso = "M"
                                                             }
                richiesta.RigheRichieste = New RigheRichiesteType()

                ''ogni prestazione trovata nella ricerca precedente viene inserita nell'ordine
                For Each prestazione In prestazioni

                    richiesta.RigheRichieste.Add(
                        New RigaRichiestaType() With {
                           .Prestazione = New PrestazioneType() With {
                                        .Id = prestazione.Id,
                                        .Codice = prestazione.Codice
                                                                     },
                           .SistemaErogante = New SistemaType() With {
                                         .Azienda = New CodiceDescrizioneType() With {.Codice = prestazione.SistemaErogante.Azienda.Codice},
                                         .Sistema = New CodiceDescrizioneType() With {.Codice = prestazione.SistemaErogante.Sistema.Codice}
                                                                         }
                                                     })
                Next

                Dim ordineRequest = New AggiungiOppureModificaOrdineRequest(token, richiesta)

                Dim ordine = webService.AggiungiOppureModificaOrdine(ordineRequest).AggiungiOppureModificaOrdineResult

                ''se lo stato è valido l'ordine può essere inoltrato
                If ordine.StatoValidazione.Stato = StatoValidazioneEnum.AA Then

                    'Inoltro
                    Dim inoltraRequest = New InoltraOrdinePerIdGuidRequest(token, ordine.Ordine.IdGuidOrderEntry)

                    Dim stato = webService.InoltraOrdinePerIdGuid(inoltraRequest)
                End If
            End Using
        End Sub

        Private Sub TestOrdine2()

            'Step:
            'Creazione Token
            'Ricerca Prestazioni
            'Creazione Ordine e Inserimento Prestazioni          
            'Inoltro

            Using webService As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")

                'Creazione Token
                Dim tokenRequest = New CreaTokenAccessoRequest("ASMN", "SISRIC")

                Dim token = webService.CreaTokenAccesso(tokenRequest).CreaTokenAccessoResult

                'Ricerca Prestazioni
				Dim prestazioniRequest = New CercaPrestazioniPerSistemaEroganteRequest(token, RegimeEnum.AMB, PrioritaEnum.O, "ASMN", "181", "ASMN", "SISRIC", "ASMN", "LIS-CNM", Nothing)

                Dim prestazioni = webService.CercaPrestazioniPerSistemaErogante(prestazioniRequest).CercaPrestazioniPerSistemaEroganteResult

                If prestazioni Is Nothing OrElse prestazioni.Count = 0 Then
                    Return
                End If

                'Creazione Ordine
                Dim richiesta = New OrdineType()

                richiesta.DataRichiesta = DateTime.Now
                richiesta.IdRichiestaOrderEntry = String.Empty
				richiesta.Regime = New RegimeType() With {.Codice = RegimeEnum.AMB.ToString}
				richiesta.Priorita = New PrioritaType() With {.Codice = PrioritaEnum.O.ToString}

                richiesta.SistemaRichiedente = New SistemaType() With {
                         .Azienda = New CodiceDescrizioneType() With {.Codice = "ASMN"},
                         .Sistema = New CodiceDescrizioneType() With {.Codice = "SISRIC"}
                                                                      }
                richiesta.UnitaOperativaRichiedente = New StrutturaType() With {
                         .Azienda = New CodiceDescrizioneType() With {.Codice = "ASMN"},
                         .UnitaOperativa = New CodiceDescrizioneType() With {.Codice = "181"}
                                                                                }
                richiesta.Paziente = New PazienteType() With {
                         .IdSac = "F4D55575-20E4-4A07-A6D5-7784D9F336DF",
                         .Cognome = "Prova",
                         .Nome = "Prova",
                         .CodiceFiscale = "PRVPRV28B82B180L",
                         .DataNascita = DateTime.Parse("28/02/1982"),
                         .Sesso = "M"
                                                             }
                richiesta.RigheRichieste = New RigheRichiesteType()

                ''ogni prestazione trovata nella ricerca precedente viene inserita nell'ordine
                For Each prestazione In prestazioni

                    richiesta.RigheRichieste.Add(
                        New RigaRichiestaType() With {
                           .Prestazione = New PrestazioneType() With {
                                        .Id = prestazione.Id,
                                        .Codice = prestazione.Codice
                                                                     },
                           .SistemaErogante = New SistemaType() With {
                                         .Azienda = New CodiceDescrizioneType() With {.Codice = prestazione.SistemaErogante.Azienda.Codice},
                                         .Sistema = New CodiceDescrizioneType() With {.Codice = prestazione.SistemaErogante.Sistema.Codice}
                                                                         }
                                                     })
                Next

                Dim ordineRequest = New AggiungiOppureModificaOrdineRequest(token, richiesta)

                Dim ordine = webService.AggiungiOppureModificaOrdine(ordineRequest).AggiungiOppureModificaOrdineResult

                ''se lo stato è valido l'ordine può essere inoltrato
                If ordine.StatoValidazione.Stato = StatoValidazioneEnum.AA Then

                    'Inoltro
                    Dim inoltraRequest = New InoltraOrdinePerIdGuidRequest(token, ordine.Ordine.IdGuidOrderEntry)

                    Dim stato = webService.InoltraOrdinePerIdGuid(inoltraRequest)
                End If
            End Using
        End Sub
    End Class

End Namespace