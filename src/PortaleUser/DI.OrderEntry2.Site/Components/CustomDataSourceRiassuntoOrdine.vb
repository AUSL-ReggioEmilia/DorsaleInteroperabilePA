Imports System.Collections.Generic
Imports System.ComponentModel
Imports System.Linq
Imports CustomDataSource
Imports DI.OrderEntry.Services
Imports DI.OrderEntry.User
Imports DI.PortalUser2.Data

Namespace DI.OrderEntry.User


    Public Class PrestazioniErogate
        Inherits CacheDataSource(Of List(Of PrestazioneErogata))

        Public Function GetData(IdRichiesta As String) As List(Of PrestazioneErogata)
            Dim prestazioni As New List(Of PrestazioneErogata)

            Try
                '
                ' nuovo metodo:
                '

                'Controllo se la lista è già in cache.
                prestazioni = Me.CacheData '

                'se reparti è null allora rieseguo la query.
                If prestazioni Is Nothing Then

                    Dim ds As New RiassuntoOrdineMethods
                    Dim oDatiAggiuntivi As New Dictionary(Of String, DatoAggiuntivoVisualizzazioneType)
                    oDatiAggiuntivi = ds.OttieniDatiAggiuntiviRichiesta(IdRichiesta)

                    Dim userData = UserDataManager.GetUserData()

                    Using webService As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")

                        Dim request = New OttieniOrdinePerIdGuidRequest(userData.Token, IdRichiesta)
                        Dim response = webService.OttieniOrdinePerIdGuid(request)

                        Dim OrdineResult = response.OttieniOrdinePerIdGuidResult

                        Dim righeErogate = New List(Of RigaErogataType)()

                        If OrdineResult.Erogati Is Nothing Then
                            OrdineResult.Erogati = New TestateErogateType()
                        End If

                        For Each testataErogante In OrdineResult.Erogati

                            If testataErogante.RigheErogate Is Nothing Then
                                testataErogante.RigheErogate = New RigheErogateType()
                            End If

                            righeErogate.AddRange(testataErogante.RigheErogate.ToArray())
                        Next

                        prestazioni = (From riga In OrdineResult.Ordine.RigheRichieste
                                       Order By riga.SistemaErogante.Azienda.Codice, riga.SistemaErogante.Sistema.Codice, riga.Prestazione.Codice
                                       Select New PrestazioneErogata With
                               {
                               .Id = riga.Prestazione.Id,
                               .Codice = riga.Prestazione.Codice,
                               .Descrizione = If(String.IsNullOrEmpty(riga.Prestazione.Descrizione), "-", riga.Prestazione.Descrizione),
                               .SistemaErogante = String.Format("{0}-{1}", riga.SistemaErogante.Azienda.Codice, riga.SistemaErogante.Sistema.Codice),
                               .DataPrenotazioneErogante = CType(Nothing, Date?),
                               .Valido = If(OrdineResult.StatoValidazione IsNot Nothing AndAlso OrdineResult.StatoValidazione.Righe IsNot Nothing, OrdineResult.StatoValidazione.Righe.Where(Function(e) e.Index = (OrdineResult.Ordine.RigheRichieste.IndexOf(riga) + 1)).First().Stato = StatoValidazioneEnum.AA, Nothing),
                               .DescrizioneStatoValidazione = If(OrdineResult.StatoValidazione IsNot Nothing AndAlso OrdineResult.StatoValidazione.Righe IsNot Nothing, OrdineResult.StatoValidazione.Righe.Where(Function(e) e.Index = (OrdineResult.Ordine.RigheRichieste.IndexOf(riga) + 1)).First().Descrizione, OrdineResult.StatoValidazione.Descrizione),
                               .DatiAccessoriRichiesta = FiltraDatiAggiuntivi(oDatiAggiuntivi, riga.DatiAggiuntivi),
                               .DatiAccessoriErogato = (From rigaErogata In righeErogate
                                                        Where riga.Prestazione.Codice = rigaErogata.Prestazione.Codice
                                                        Select FiltraDatiAggiuntivi(oDatiAggiuntivi, rigaErogata.DatiAggiuntivi)).ToList,
                              .DatiAccessoriTestataErogato = (From dato In OrdineResult.Erogati
                                                              Where dato.SistemaErogante.Sistema.Codice = riga.SistemaErogante.Sistema.Codice And dato.DatiAggiuntivi IsNot Nothing And dato.DatiAggiuntivi.ToList.Count > 0
                                                              Select FiltraDatiAggiuntivi(oDatiAggiuntivi, dato.DatiAggiuntivi)).ToList(),
                              .DatiPersistentiTestataErogato = (From dato In OrdineResult.Erogati
                                                                Where dato.SistemaErogante.Sistema.Codice = riga.SistemaErogante.Sistema.Codice And dato.DatiPersistenti IsNot Nothing And dato.DatiPersistenti.ToList.Count > 0
                                                                Select FiltraDatiPersistenti(oDatiAggiuntivi, dato.DatiPersistenti)).ToList(),
                               .Tipo = CType(riga.PrestazioneTipo, Integer),
                               .SoloErogato = False,
                               .DescrizioneStato = OrdineResult.DescrizioneStato.ToString,
                               .CodiceOperazioneRigaRichiesta = riga.OperazioneOrderEntry.ToString,
                               .DescrizioneOperazioneRigaRichiesta = LookupManager.GetDescrizioneStatoRigaRichiedente(riga.OperazioneOrderEntry),
                               .CodiceStatoErogante = (From rigaErogata In righeErogate
                                                       Where riga.Prestazione.Codice = rigaErogata.Prestazione.Codice
                                                       Select rigaErogata.StatoOrderEntry).FirstOrDefault().ToString(),
                                .StatoErogante = (From rigaErogata In righeErogate
                                                  Where riga.Prestazione.Codice = rigaErogata.Prestazione.Codice
                                                  Select LookupManager.GetDescrizioneStatoRigaErogante(rigaErogata.StatoOrderEntry)).FirstOrDefault(),
                                .DataPianificata = (From rigaErogata In righeErogate
                                                    Where riga.Prestazione.Codice = rigaErogata.Prestazione.Codice
                                                    Select rigaErogata.DataPianificata).FirstOrDefault()
                               }).ToList()


                        If righeErogate.Count > 0 Then

                            For Each testataErogante In OrdineResult.Erogati

                                For Each rigaErogata In testataErogante.RigheErogate

                                    Dim codicePrestazione = rigaErogata.Prestazione.Codice

                                    Dim rows = (From rigaRichiesta In OrdineResult.Ordine.RigheRichieste
                                                Where rigaRichiesta.Prestazione.Codice = codicePrestazione).ToArray()

                                    If rows.Length > 0 Then
                                        Continue For
                                    End If

                                    Dim azienda = testataErogante.SistemaErogante.Azienda.Codice
                                    Dim sistema = testataErogante.SistemaErogante.Sistema.Codice

                                    'System.InvalidCastException  Unable to cast object of type 'DI.OrderEntry.Services.DatiAggiuntiviType' to type 'System.Collections.Generic.IEnumerable`1[DI.OrderEntry.Services.DatiAggiuntiviType]'.   
                                    'at DI.OrderEntry.User.RiassuntoOrdineMethods.GetRichiesta(String id) in C:\Progetti\Commessa - DI\DI\PortaleUser\DI.OrderEntry.Site\Pages\AjaxWebMethods\RiassuntoOrdineMethods.aspx.vb:line 239 

                                    Dim prestazioneErogata As New PrestazioneErogata With
                                          {
                                          .Id = rigaErogata.Prestazione.Id,
                                          .Codice = rigaErogata.Prestazione.Codice,
                                          .Descrizione = If(String.IsNullOrEmpty(rigaErogata.Prestazione.Descrizione), "-", rigaErogata.Prestazione.Descrizione),
                                          .SistemaErogante = String.Format("{0}-{1}", azienda, sistema),
                                          .DataPrenotazioneErogante = testataErogante.DataPrenotazione,
                                          .Valido = True,
                                          .DescrizioneStatoValidazione = "",
                                          .DatiAccessoriRichiesta = New DatiAggiuntiviType,
                                          .DatiAccessoriErogato = CreaListaConUnElemento(Of DatiAggiuntiviType)(FiltraDatiAggiuntivi(oDatiAggiuntivi, rigaErogata.DatiAggiuntivi)),
                                          .DatiAccessoriTestataErogato = CreaListaConUnElemento(Of DatiAggiuntiviType)(FiltraDatiAggiuntivi(oDatiAggiuntivi, testataErogante.DatiAggiuntivi)),
                                          .DatiPersistentiTestataErogato = CreaListaConUnElemento(Of DatiPersistentiType)(FiltraDatiPersistenti(oDatiAggiuntivi, testataErogante.DatiPersistenti)),
                                          .Tipo = -1,
                                          .SoloErogato = True,
                                          .DescrizioneStato = String.Empty,
                                          .CodiceOperazioneRigaRichiesta = String.Empty,
                                          .DescrizioneOperazioneRigaRichiesta = String.Empty,
                                          .CodiceStatoErogante = rigaErogata.StatoOrderEntry.ToString(),
                                          .StatoErogante = LookupManager.GetDescrizioneStatoRigaErogante(rigaErogata.StatoOrderEntry),
                                          .DataPianificata = rigaErogata.DataPianificata
                                          }

                                    prestazioni.Add(prestazioneErogata)
                                Next
                            Next
                        End If

                        'compilazione dati ripetibili
                        Dim domandeDatiAccessori = webService.OttieniDatiAccessoriPerIdGuid(New OttieniDatiAccessoriPerIdGuidRequest(userData.Token, IdRichiesta)).OttieniDatiAccessoriPerIdGuidResult

                        For Each prestazione In prestazioni
                            '
                            'Dati Accessori Prestazioni Richiesta
                            '
                            Utility.NormalizzaDatiAccessori(prestazione.DatiAccessoriRichiesta, domandeDatiAccessori)
                            '
                            'Dati Accessori Prestazioni Erogato
                            '
                            Utility.NormalizzaDatiAccessori(prestazione.DatiAccessoriErogato, domandeDatiAccessori)
                            '
                            'Dati Accessori Testata Erogato
                            '
                            Utility.NormalizzaDatiAccessori(prestazione.DatiAccessoriTestataErogato, domandeDatiAccessori)
                            '
                            'Dati Persistenti Testata Erogato
                            '
                            Utility.NormalizzaDatiPersistenti(prestazione.DatiPersistentiTestataErogato, domandeDatiAccessori)
                        Next

                        Me.CacheData = prestazioni
                    End Using

                End If
            Catch ex As Exception
                ExceptionsManager.TraceException(ex)
                Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
            End Try

            Return prestazioni
        End Function

        Public Shared Function FiltraDatiAggiuntivi(DatiValidi As Dictionary(Of String, DatoAggiuntivoVisualizzazioneType), DatiDaRipulire As DatiAggiuntiviType) As DatiAggiuntiviType
            Try
                Dim listaDati As New DatiAggiuntiviType()

                If DatiDaRipulire Is Nothing Then Return listaDati

                Dim DatiNonVisibili As New List(Of String)

                For Each Dato In DatiDaRipulire

                    Dim sNome = Dato.Nome.ToUpper

                    'MODIFICA Leo 2019/12/06: corretta la mancata visualizzazione dei dati accessori
                    'caso dati aggiuntivi
                    'i dati accessori non vengono filtrati poichè li voglio tutti in visualizzazione!
                    If Dato.DatoAccessorio Is Nothing Then

                        Dim DatoValido As DatoAggiuntivoVisualizzazioneType = Nothing
                        DatiValidi.TryGetValue(sNome, DatoValido)

                        If DatoValido Is Nothing OrElse DatoValido.Visibile = False Then
                            DatiNonVisibili.Add(sNome)

                        ElseIf Not String.IsNullOrEmpty(DatoValido.Descrizione) Then

                            If Dato.DatoAccessorio Is Nothing Then
                                Dato.DatoAccessorio = New DatoAccessorioType
                                Dato.DatoAccessorio.Codice = sNome
                                Dato.DatoAccessorio.Tipo = TipoDatoAccessorioEnum.TextBox
                                Dato.DatoAccessorio.Etichetta = DatoValido.Descrizione
                            End If

                        End If
                    End If
                Next

                For Each Dato In DatiNonVisibili
                    Dim sNome = Dato
                    DatiDaRipulire.RemoveAll(Function(d) d.Nome.Equals(sNome, StringComparison.InvariantCultureIgnoreCase))
                Next

            Catch ex As Exception
                ExceptionsManager.TraceException(ex)
                Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
            End Try

            Return DatiDaRipulire
        End Function

        'TODO: se non serve eliminare il parametro RelazioneId
        Private Shared Function FiltraDatiPersistenti(DatiValidi As Dictionary(Of String, DatoAggiuntivoVisualizzazioneType), DatiDaRipulire As DatiPersistentiType) As DatiPersistentiType
            Try

                If DatiDaRipulire Is Nothing Then Return Nothing
                If DatiValidi Is Nothing Then Return DatiDaRipulire

                Dim DatiNonVisibili As New List(Of String)

                For Each Dato In DatiDaRipulire

                    Dim sNome = Dato.Nome.ToUpper

                    Dim DatoValido As DatoAggiuntivoVisualizzazioneType = Nothing
                    DatiValidi.TryGetValue(sNome, DatoValido)

                    If DatoValido Is Nothing OrElse DatoValido.Visibile = False Then
                        DatiNonVisibili.Add(sNome)

                    ElseIf Not String.IsNullOrEmpty(DatoValido.Descrizione) Then

                        If Dato.DatoAccessorio Is Nothing Then
                            Dato.DatoAccessorio = New DatoAccessorioType
                            Dato.DatoAccessorio.Codice = sNome
                            Dato.DatoAccessorio.Tipo = TipoDatoAccessorioEnum.TextBox
                        End If

                        Dato.DatoAccessorio.Etichetta = DatoValido.Descrizione

                    End If
                Next

                For Each Dato In DatiNonVisibili
                    Dim sNome = Dato
                    DatiDaRipulire.RemoveAll(Function(d) d.Nome.Equals(sNome, StringComparison.InvariantCultureIgnoreCase))
                Next

            Catch ex As Exception
                ExceptionsManager.TraceException(ex)
                Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
            End Try

            Return DatiDaRipulire
        End Function

        Private Shared Function CreaListaConUnElemento(Of X)(singleElement As X) As List(Of X)

            Dim lista As New List(Of X)
            lista.Add(singleElement)
            Return lista

        End Function
    End Class

    Public Class RiassuntoOrdineMethods

        'Modifica Leo 2019/12/10 Rimozione cache

        ''' <summary>
        ''' Legge dal nuovo metodo la lista dei dati aggiuntivi
        ''' </summary>
        Public Function OttieniDatiAggiuntiviRichiesta(IdRichiesta As String) As Dictionary(Of String, DatoAggiuntivoVisualizzazioneType)
            Dim dic As New Dictionary(Of String, DatoAggiuntivoVisualizzazioneType)
            Try

                Dim userData = UserDataManager.GetUserData()
                Using webService As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")
                    Dim request = New OttieniDatiAggiuntiviVisualizzazionePerIdGuidRequest(userData.Token, IdRichiesta)
                    Dim response = webService.OttieniDatiAggiuntiviVisualizzazionePerIdGuid(request)
                    For Each Dato In response.OttieniDatiAggiuntiviVisualizzazionePerIdGuidResult
                        If Not dic.ContainsKey(Dato.Nome.ToUpper) Then
                            dic.Add(Dato.Nome.ToUpper, Dato)
                        End If
                    Next
                End Using

            Catch ex As Exception
                ExceptionsManager.TraceException(ex)
                Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
                Throw
            End Try

            Return dic
        End Function


        ''' <summary>
        ''' Ottiene i dati aggiuntivi di testata dell'ordine
        ''' </summary>
        ''' <param name="IdRichiesta"></param>
        ''' <returns></returns>
        <DataObjectMethod(DataObjectMethodType.Select)>
        Public Shared Function DatiAggiuntiviOrdineErogato(IdRichiesta As String) As DatiAggiuntiviType
            Dim datiAggiuntivi As New DatiAggiuntiviType
            Try
                '
                ' nuovo metodo:
                '

                Dim ds As New RiassuntoOrdineMethods
                Dim oDatiAggiuntivi = ds.OttieniDatiAggiuntiviRichiesta(IdRichiesta)

                Dim userData = UserDataManager.GetUserData()

                Using webService As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")

                    Dim request = New OttieniOrdinePerIdGuidRequest(userData.Token, IdRichiesta)
                    Dim response = webService.OttieniOrdinePerIdGuid(request)

                    Dim OrdineResult = response.OttieniOrdinePerIdGuidResult

                    Dim righeErogate = New List(Of RigaErogataType)()

                    If OrdineResult.Erogati Is Nothing Then
                        OrdineResult.Erogati = New TestateErogateType()
                    End If

                    For Each testataErogante In OrdineResult.Erogati
                        If testataErogante.RigheErogate Is Nothing Then
                            testataErogante.RigheErogate = New RigheErogateType()
                        End If

                        righeErogate.AddRange(testataErogante.RigheErogate.ToArray())
                    Next

                    datiAggiuntivi = PrestazioniErogate.FiltraDatiAggiuntivi(oDatiAggiuntivi, OrdineResult.Ordine.DatiAggiuntivi)

                    'compilazione dati ripetibili
                    Dim domandeDatiAccessori = webService.OttieniDatiAccessoriPerIdGuid(New OttieniDatiAccessoriPerIdGuidRequest(userData.Token, IdRichiesta)).OttieniDatiAccessoriPerIdGuidResult

                    Utility.NormalizzaDatiAccessori(datiAggiuntivi, domandeDatiAccessori)
                End Using
            Catch ex As Exception
                ExceptionsManager.TraceException(ex)
                Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
            End Try

            Return datiAggiuntivi
        End Function

        ''' <summary>
        ''' Ottiene i dati aggiuntivi di un sistema
        ''' </summary>
        ''' <param name="IdRichiesta"></param>
        ''' <param name="SistemaErogante"></param>
        ''' <returns></returns>
        <DataObjectMethod(DataObjectMethodType.Select)>
        Public Shared Function DatiAggiuntiviSistemaErogante(IdRichiesta As String, SistemaErogante As String) As List(Of DatoNomeValoreType)
            Dim datiAggiuntivi As New List(Of DatoNomeValoreType)

            Try
                Dim ods As New PrestazioniErogate()
                Dim prestazioni As List(Of PrestazioneErogata) = ods.GetData(IdRichiesta)

                Dim prestazioniFiltrate As List(Of PrestazioneErogata) = (From prest In prestazioni Where prest.SistemaErogante = SistemaErogante Select prest).ToList

                If prestazioniFiltrate IsNot Nothing AndAlso prestazioniFiltrate.Count > 0 Then
                    Dim prestazione As PrestazioneErogata = prestazioniFiltrate.First

                    If prestazione.DatiAccessoriTestataErogato IsNot Nothing AndAlso prestazione.DatiAccessoriTestataErogato.Count > 0 Then
                        datiAggiuntivi.AddRange(prestazione.DatiAccessoriTestataErogato.First.ToList())
                    End If

                    If prestazione.DatiPersistentiTestataErogato IsNot Nothing AndAlso prestazione.DatiPersistentiTestataErogato.Count > 0 Then
                        datiAggiuntivi.AddRange(prestazione.DatiPersistentiTestataErogato.First.ToList())
                    End If
                End If
            Catch ex As Exception
                ExceptionsManager.TraceException(ex)
                Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
            End Try

            Return datiAggiuntivi
        End Function

        ''' <summary>
        ''' Ottiene i dati aggiuntivi di una prestazione erogata
        ''' </summary>
        ''' <param name="IdRichiesta"></param>
        ''' <param name="IdPrestazione"></param>
        ''' <returns></returns>
        <DataObjectMethod(DataObjectMethodType.Select)>
        Public Function DatiAggiuntiviPrestazione(IdRichiesta As String, IdPrestazione As String) As List(Of DatoNomeValoreType)

            Dim datiAggiuntivi As New List(Of DatoNomeValoreType)

            Try
                If Not String.IsNullOrEmpty(IdRichiesta) AndAlso Not String.IsNullOrEmpty(IdPrestazione) Then
                    Dim ods As New PrestazioniErogate()
                    Dim prestazioni As List(Of PrestazioneErogata) = ods.GetData(IdRichiesta)

                    Dim prestazioniFiltrate As List(Of PrestazioneErogata) = (From prest In prestazioni Where prest.Id.ToUpper = IdPrestazione.ToUpper Select prest).ToList

                    If prestazioniFiltrate IsNot Nothing AndAlso prestazioniFiltrate.Count > 0 Then
                        Dim prestazione As PrestazioneErogata = prestazioniFiltrate.First

                        If prestazione.DatiAccessoriErogato IsNot Nothing AndAlso prestazione.DatiAccessoriErogato.Count > 0 Then
                            datiAggiuntivi.AddRange(prestazione.DatiAccessoriErogato.First().ToList())
                        End If

                        If prestazione.DatiAccessoriRichiesta IsNot Nothing AndAlso prestazione.DatiAccessoriRichiesta.Count > 0 Then
                            datiAggiuntivi.AddRange(prestazione.DatiAccessoriRichiesta.ToList())
                        End If
                    End If
                End If

            Catch ex As Exception
                ExceptionsManager.TraceException(ex)
                Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
            End Try

            Return datiAggiuntivi
        End Function


    End Class

    Public Class PrestazioneErogata
        Inherits Prestazione

        Public Property DataPrenotazioneErogante As Date?
        Public Property DatiAccessoriRichiesta As DatiAggiuntiviType
        Public Property DatiAccessoriErogato As List(Of DatiAggiuntiviType)
        Public Property DatiAccessoriTestataErogato As List(Of DatiAggiuntiviType)
        Public Property DatiPersistentiTestataErogato As List(Of DatiPersistentiType)
        Public Property SoloErogato As Boolean
        Public Property DescrizioneStato As String
        Public Property CodiceOperazioneRigaRichiesta As String
        Public Property DescrizioneOperazioneRigaRichiesta As String
        Public Property CodiceStatoErogante As String
        Public Property StatoErogante As String
        Public Property DataPianificata As Date?
    End Class

    Public Class RichiestaErogata
        Public Property Progressivo As String
        Public Property Stato As String
        Public Property DataRichiesta As String
        Public Property DataPrenotazione As String
        Public Property NumeroNosologico As String
        Public Property Priorita As String
        Public Property Regime As String
        Public Property UnitaOperativa As String
        Public Property Valido As Boolean
        Public Property DescrizioneStatoValidazione As String
        Public Property Cancellabile As Boolean?
        Public Property DatiAccessori As DatiAggiuntiviType
        Public Property Prestazioni As List(Of PrestazioneErogata)
    End Class

End Namespace
