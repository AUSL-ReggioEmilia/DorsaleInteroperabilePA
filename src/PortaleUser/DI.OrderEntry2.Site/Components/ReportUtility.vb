Imports System
Imports System.Globalization
Imports DI.OrderEntry.Services
Imports System.Linq
Imports System.Collections.Generic
Imports Microsoft.Reporting.WebForms
Imports System.IO
Imports DI.PortalUser2.Data
Imports System.Text
Imports DI.OrderEntry.User

Public Class ReportUtility

    Public Shared Function GetOrdine(idOrdine As String) As DI.OrderEntry.Services.StatoType
        '
        'Prendo lo stato
        '
        Dim stato As DI.OrderEntry.Services.StatoType

        Dim userData = DI.OrderEntry.User.UserDataManager.GetUserData()

        Using webService As New OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1")

            Dim request = New OttieniOrdinePerIdGuidRequest(userData.Token, idOrdine)

            Dim response = webService.OttieniOrdinePerIdGuid(request)

            stato = response.OttieniOrdinePerIdGuidResult

            If stato Is Nothing Then
                Return Nothing
            End If

            Return stato

        End Using
    End Function

    ''' <summary>
    ''' Genera report Ordine
    ''' </summary>
    ''' <param name="stato"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Function GeneraReportOrdine(ByVal stato As DI.OrderEntry.Services.StatoType) As Byte()


        Dim footerParameter As String = stato.Ordine.Paziente.Nome & " " & stato.Ordine.Paziente.Cognome & " - " & stato.Ordine.Paziente.DataNascita & " - " & stato.Ordine.Paziente.ComuneNascita & " - " & stato.Ordine.NumeroNosologico
        Dim headerParameter As String = stato.Ordine.UnitaOperativaRichiedente.Azienda.Descrizione & Environment.NewLine _
                                        & stato.Ordine.UnitaOperativaRichiedente.UnitaOperativa.Descrizione & Environment.NewLine

        Dim parameters(1) As ReportParameter
        parameters(0) = New ReportParameter("foot", footerParameter)
        parameters(1) = New ReportParameter("head", headerParameter)

        '
        'Prendo i dati di testata dell'ordine
        '
        Dim testataRichiestaDataTable As OrdineDataSet.TestataRichiestaDataTable = GetTestataRichiestaResultToDataTable(stato)
        '
        'Prendo la lista di prestazioni in base allo stato
        '
        Dim righeRichiesteDataTable As OrdineDataSet.RigheRichiesteDataTable = GetRigheRichiesteResultToDataTable(stato)
        '
        '
        '
        Dim dataSources As New List(Of ReportDataSource)()
        dataSources.Add(New ReportDataSource("RigheRichiesteDataSet", righeRichiesteDataTable.ToArray))
        dataSources.Add(New ReportDataSource("TestataRichiestaDataSet", testataRichiestaDataTable.ToArray))

        Dim serverPath As String = Web.HttpContext.Current.Server.MapPath("~/")
        Dim reportPath As String = serverPath & "Reports\Ordine.rdlc"

        Return GeneraReport(reportPath, parameters, dataSources)

        'HttpContext.Current.Response.Clear()
        'HttpContext.Current.Response.WriteFile(reportFileName)

    End Function

    Public Shared Function GeneraReport(ByVal reportPath As String, ByVal parameters() As ReportParameter, ByVal dataSources As List(Of ReportDataSource)) As Byte()

        Try
            Using report As New LocalReport()
                report.ReportPath = reportPath

                For Each dataSource As ReportDataSource In dataSources
                    report.DataSources.Add(dataSource)
                Next

                If parameters IsNot Nothing Then
                    report.SetParameters(parameters)
                End If

                Dim warnings As Warning()
                Dim streamIds As String()
                Dim mimeType As String = ""
                Dim encoding As String = ""
                Dim extension As String = ""
                Dim deviceInfo As String = "<DeviceInfo><OutputFormat>PDF</OutputFormat></DeviceInfo>"

                Dim bytes As Byte() = report.Render("PDF", deviceInfo, mimeType, encoding, extension, streamIds, warnings)

                'Dim reportFileName As String = String.Format("{0}\{1}.pdf", Utility.GetTempDirectory("CartellaMedica\PDF"), Guid.NewGuid())

                'Using fileStream As New FileStream(reportFileName, FileMode.Create)
                '    fileStream.Write(bytes, 0, bytes.Length)
                'End Using

                Return bytes
            End Using

        Catch ex As Exception

            DI.OrderEntry.User.ExceptionsManager.TraceException(ex)

            Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)

            portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)

            Return Nothing
        End Try
    End Function

    ''' <summary>
    ''' Crea una cartella di file temporanei 
    ''' </summary>
    ''' <param name="directoryName"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Function GetTempDirectory(ByVal directoryName As String) As String

        Dim directoryPath As String = Path.Combine(Path.GetTempPath(), directoryName)

        If Not Directory.Exists(directoryPath) Then
            Directory.CreateDirectory(directoryPath)
        End If

        Return directoryPath
    End Function

    Public Shared Function GetTestataRichiestaResultToDataTable(ByVal stato As StatoType) As OrdineDataSet.TestataRichiestaDataTable
        Try
            Dim testataRichiestaDataTable As New OrdineDataSet.TestataRichiestaDataTable

            If Not stato Is Nothing AndAlso Not stato.Ordine Is Nothing Then

                Dim testataRichiestaRow As OrdineDataSet.TestataRichiestaRow = testataRichiestaDataTable.NewTestataRichiestaRow

                testataRichiestaRow.Nome = stato.Ordine.Paziente.Nome
                testataRichiestaRow.Cognome = stato.Ordine.Paziente.Cognome
                testataRichiestaRow.DataNascita = stato.Ordine.Paziente.DataNascita
                testataRichiestaRow.LuogoNascita = If(stato.Ordine.Paziente.ComuneNascita Is Nothing OrElse String.IsNullOrEmpty(stato.Ordine.Paziente.ComuneNascita), String.Empty, stato.Ordine.Paziente.ComuneNascita)
                testataRichiestaRow.CodiceFiscale = stato.Ordine.Paziente.CodiceFiscale
                testataRichiestaRow.Sesso = If(stato.Ordine.Paziente.Sesso Is Nothing OrElse String.IsNullOrEmpty(stato.Ordine.Paziente.Sesso), "-", stato.Ordine.Paziente.Sesso)

                testataRichiestaRow.MedicoCurante = String.Empty
                testataRichiestaRow.NumeroEpisodio = If(stato.Ordine.NumeroNosologico Is Nothing OrElse String.IsNullOrEmpty(stato.Ordine.NumeroNosologico), String.Empty, stato.Ordine.NumeroNosologico)
                testataRichiestaRow.InfoRicovero = Utility.GetInfoRicovero(stato.Ordine.UnitaOperativaRichiedente.Azienda.Codice, stato.Ordine.NumeroNosologico)
                testataRichiestaRow.NumeroOrdine = stato.Ordine.IdRichiestaOrderEntry

                testataRichiestaRow.AnteprimaPrestazioni = stato.Ordine.AnteprimaPrestazioni

                testataRichiestaRow.StrutturaRichiedente = stato.Ordine.SistemaRichiedente.Azienda.Descrizione & " - " & stato.Ordine.SistemaRichiedente.Sistema.Descrizione
                testataRichiestaRow.UnitaOperativaRichiedente = stato.Ordine.UnitaOperativaRichiedente.Azienda.Codice & " - " & stato.Ordine.UnitaOperativaRichiedente.UnitaOperativa.Descrizione

                testataRichiestaRow.Regime = stato.Ordine.Regime.Descrizione
                testataRichiestaRow.Priorita = stato.Ordine.Priorita.Descrizione
                testataRichiestaRow.DataPrenotazione = If(stato.Ordine.DataPrenotazione IsNot Nothing AndAlso stato.Ordine.DataPrenotazione.HasValue, stato.Ordine.DataPrenotazione.ToString, String.Empty)
                testataRichiestaRow.DataRichiesta = stato.Ordine.DataRichiesta

                Dim cognome As String = If(stato.Ordine.Operatore IsNot Nothing AndAlso stato.Ordine.Operatore.Cognome IsNot Nothing, stato.Ordine.Operatore.Cognome, String.Empty)
                Dim nome As String = If(stato.Ordine.Operatore IsNot Nothing AndAlso stato.Ordine.Operatore.Nome IsNot Nothing, stato.Ordine.Operatore.Nome, String.Empty)
                testataRichiestaRow.Operatore = cognome & " " & nome
                '
                'Dati Accessori Testata Richiesta
                '
                Dim datiAccessoriTestataRichiestaValori As New StringBuilder

                If stato.Ordine.DatiAggiuntivi IsNot Nothing AndAlso stato.Ordine.DatiAggiuntivi.Count > 0 Then

                    For Each dato In stato.Ordine.DatiAggiuntivi

                        If dato.DatoAccessorio Is Nothing Then

                            Dim codice = dato.Nome.Split("_")(0)

                            'Dim datoAccessorio = datiAccossoriLista.Where(Function(e) e.DatoAccessorio.Codice = codice).First

                            'If datoAccessorio IsNot Nothing AndAlso datoAccessorio.DatoAccessorio IsNot Nothing Then
                            '    dato.DatoAccessorio = datoAccessorio.DatoAccessorio
                            'Else

                            Dim datoAccessorioType As New DatoAccessorioType
                            datoAccessorioType.Etichetta = dato.Nome
                            dato.DatoAccessorio = datoAccessorioType

                            'End If

                        End If
                    Next

                    For Each datoAccessorio As DatoNomeValoreType In stato.Ordine.DatiAggiuntivi
                        datiAccessoriTestataRichiestaValori.Append(GetDatoAccessorioValore(datoAccessorio))
                    Next

                End If

                testataRichiestaRow.DatiAccessoriTestataRichiesta = datiAccessoriTestataRichiestaValori.ToString
                testataRichiestaRow.StatoDescrizioneStato = stato.DescrizioneStato

                'Modifica Leo 2019/12/12: risolta l'eccezione generata se StatoValidazioneDescrizione è DBNULL
                If Not String.IsNullOrEmpty(stato.StatoValidazione.Descrizione) Then
                    testataRichiestaRow.StatoValidazioneDescrizione = stato.StatoValidazione.Descrizione
                Else
                    testataRichiestaRow.StatoValidazioneDescrizione = ""
                End If

                testataRichiestaRow.StatoValidazioneStato = stato.StatoValidazione.Stato
                testataRichiestaDataTable.AddTestataRichiestaRow(testataRichiestaRow)
            End If

            Return testataRichiestaDataTable

        Catch ex As Exception
            DI.OrderEntry.User.ExceptionsManager.TraceException(ex)
            Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
            portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
            Return Nothing
        End Try

    End Function

    Private Shared Function GetDatoAccessorioValore(ByVal datoAccessorio As DatoNomeValoreType) As String

        Dim datoAccessorioValori As New StringBuilder
        Dim valori = datoAccessorio.DatoAccessorio.Valori
        Dim codiceDescrizione = New Dictionary(Of String, String)()

        If Not String.IsNullOrEmpty(valori) Then

            Dim valoriCombo = valori.Split(New String() {"§;"}, StringSplitOptions.None)

            For Each elemento In valoriCombo

                Dim split = elemento.Split(New String() {"#;"}, StringSplitOptions.None)

                If split.Length > 1 Then

                    codiceDescrizione.Add(split(0), split(1))
                Else
                    codiceDescrizione.Add(split(0), split(0))
                End If
            Next

            Dim splitData As String() = Nothing

            'Modifica Leo 2019-11-29
            'provo a splittare per §;
            'dopo l'inoltro il sigma(§;) viene convertito dai WS in ; 
            'valutare se è corretto continuare ad usare il separatore §;
            'se controllando negli storici lo utilizziamo solo noi possiamo facilmente cambiarlo

            If datoAccessorio.ValoreDato.Contains("§;") Then
                splitData = datoAccessorio.ValoreDato.Split(New String() {"§;"}, StringSplitOptions.None)
            Else
                splitData = datoAccessorio.ValoreDato.Split(New String() {";"}, StringSplitOptions.None)
            End If

            If splitData.Length = 1 AndAlso codiceDescrizione.ContainsKey(datoAccessorio.ValoreDato) Then

                'datiAccessoriValori.Append(codiceDescrizione(datoAccessorio.ValoreDato))
                datoAccessorioValori.Append(datoAccessorio.DatoAccessorio.Etichetta & ": " & codiceDescrizione(datoAccessorio.ValoreDato) & "; " & vbCrLf)

            Else
                Dim descriptions = From value In splitData
                                   Where (codiceDescrizione.ContainsKey(value))
                                   Select codiceDescrizione(value)

                'datiAccessoriValori.Append(String.Join(", ", descriptions.ToArray()))
                datoAccessorioValori.Append(datoAccessorio.DatoAccessorio.Etichetta & ": " & String.Join(", ", descriptions.ToArray()) & "; " & vbCrLf)
            End If
        Else
            'datiAccessoriValori.Append(datoAccessorio.ValoreDato)
            Dim valore As String = GetFormattedValueFromDataType(datoAccessorio.ValoreDato, GetDataTypeFromControlType(datoAccessorio.DatoAccessorio)) 'GetValoreDatoAggiuntivo(domandaCorrente.DatoAccessorio.Codice, domandaCorrente.DatoAccessorioRichiesta, domandaCorrente.DatoAccessorio.Ripetibile)
            datoAccessorioValori.Append(datoAccessorio.DatoAccessorio.Etichetta & ": " & valore & "; " & vbCrLf)

        End If

        Return datoAccessorioValori.ToString

    End Function

    Public Shared Function GetDataTypeFromControlType(ByVal dato As DatoAccessorioType) As String

        Select Case dato.Tipo

            Case TipoDatoAccessorioEnum.DateBox

                Return "date"

            Case TipoDatoAccessorioEnum.DateTimeBox

                Return "datetime"

            Case TipoDatoAccessorioEnum.TimeBox

                Return "time"

            Case TipoDatoAccessorioEnum.FloatBox

                Return "float"

            Case TipoDatoAccessorioEnum.NumberBox

                Return "integer"

            Case Else

                Return "string"
        End Select
    End Function

    Public Shared Function GetFormattedValueFromDataType(ByVal value As String, ByVal dataType As String) As String

        Try
            If String.IsNullOrEmpty(value) Then
                Return value
            End If

            Select Case dataType

                Case "date"
                    Return DateTime.Parse(value, CultureInfo.InvariantCulture).ToString("dd/MM/yyyy", New CultureInfo("it-IT")).Replace("."c, ":"c)

                Case "datetime"
                    Return DateTime.Parse(value, CultureInfo.InvariantCulture).ToString("dd/MM/yyyy HH:mm:ss", New CultureInfo("it-IT")).Replace("."c, ":"c)

                Case "time"
                    Return DateTime.Parse(value, CultureInfo.InvariantCulture).ToString("HH:mm:ss", New CultureInfo("it-IT")).Replace("."c, ":"c)

                Case "float"
                    Return value.Replace("."c, ","c)

                Case Else
                    Return value

            End Select

        Catch ex As Exception
            DI.OrderEntry.User.ExceptionsManager.TraceException(ex)
            Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)
            portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)
            Return Nothing
        End Try

    End Function

    Public Shared Function GetRigheRichiesteResultToDataTable(ByVal stato As StatoType) As OrdineDataSet.RigheRichiesteDataTable
        Try
            Dim righeRichiesteDataTable As New OrdineDataSet.RigheRichiesteDataTable
            If Not stato Is Nothing AndAlso Not stato.Ordine Is Nothing AndAlso Not stato.Ordine.RigheRichieste Is Nothing AndAlso stato.Ordine.RigheRichieste.Count > 0 Then
                If stato.Erogati Is Nothing Then
                    stato.Erogati = New TestateErogateType()
                End If

                '
                'Gestione righe richieste e corrispondenti righe erogate
                '
                Dim righeRichieste As List(Of RigaRichiestaType)
                righeRichieste = stato.Ordine.RigheRichieste.ToList
                righeRichieste.Reverse()

                For Each rigaRichiesta As RigaRichiestaType In righeRichieste

                    Dim righeRichiesteRow As OrdineDataSet.RigheRichiesteRow
                    righeRichiesteRow = righeRichiesteDataTable.NewRigheRichiesteRow

                    righeRichiesteRow.Id = rigaRichiesta.Prestazione.Id
                    righeRichiesteRow.Codice = rigaRichiesta.Prestazione.Codice
                    righeRichiesteRow.Descrizione = rigaRichiesta.Prestazione.Descrizione
                    righeRichiesteRow.Erogante = String.Format("{0} - {1}", rigaRichiesta.SistemaErogante.Azienda.Codice, rigaRichiesta.SistemaErogante.Sistema.Descrizione)
                    righeRichiesteRow.AziendaEroganteCodice = rigaRichiesta.SistemaErogante.Azienda.Codice
                    righeRichiesteRow.AziendaEroganteDescrizione = rigaRichiesta.SistemaErogante.Azienda.Descrizione
                    righeRichiesteRow.SistemaEroganteCodice = rigaRichiesta.SistemaErogante.Sistema.Codice
                    righeRichiesteRow.SistemaEroganteDescrizione = rigaRichiesta.SistemaErogante.Sistema.Descrizione
                    righeRichiesteRow.Validita = If(stato.StatoValidazione IsNot Nothing AndAlso stato.StatoValidazione.Righe IsNot Nothing, stato.StatoValidazione.Righe.Where(Function(e) e.Index = (stato.Ordine.RigheRichieste.IndexOf(rigaRichiesta) + 1)).First().Stato = StatoValidazioneEnum.AA, False)
                    'composizioneOrdinePrestazioniInseriterow.Tipo = rigaRichiesta.PrestazioneTipo.ToString

                    Select Case rigaRichiesta.PrestazioneTipo

                        Case TipoPrestazioneErogabileEnum.Prestazione
                            'Prestazione
                            righeRichiesteRow.Tipo = "Prestazione"

                        Case TipoPrestazioneErogabileEnum.ProfiloBlindato
                            'Profilo non scomponibile
                            righeRichiesteRow.Tipo = "Profilo"

                        Case TipoPrestazioneErogabileEnum.ProfiloScomponibile
                            'Profilo  scomponibile
                            righeRichiesteRow.Tipo = "Profilo scomponibile"

                        Case TipoPrestazioneErogabileEnum.ProfiloUtente
                            'Profilo utente
                            righeRichiesteRow.Tipo = "Profilo utente"

                        Case Else
                            righeRichiesteRow.Tipo = String.Empty

                    End Select

                    righeRichiesteRow.DatiAccessoriTestataRichiesta = String.Empty
                    righeRichiesteRow.DatiAccessoriPrestazioneRichiesta = String.Empty
                    righeRichiesteRow.StatoErogante = String.Empty
                    righeRichiesteRow.StatoErogante = stato.DescrizioneStato.ToString
                    Dim datiAccessoriPrestazioniRichiestaValori As New StringBuilder
                    Dim datiAccessoriTestataRichiestaValori As New StringBuilder

                    '
                    'Dati Accessori Testata Richiesta
                    '
                    If stato.Ordine.DatiAggiuntivi IsNot Nothing Then

                        For Each dato In stato.Ordine.DatiAggiuntivi

                            If dato.DatoAccessorio Is Nothing Then

                                Dim codice = dato.Nome.Split("_")(0)
                                Dim datoAccessorioType As New DatoAccessorioType
                                datoAccessorioType.Etichetta = dato.Nome
                                dato.DatoAccessorio = datoAccessorioType

                                'End If

                            End If
                        Next

                        For Each datoAccessorio As DatoNomeValoreType In stato.Ordine.DatiAggiuntivi
                            datiAccessoriTestataRichiestaValori.Append(GetDatoAccessorioValore(datoAccessorio))
                        Next

                    End If

                    righeRichiesteRow.DatiAccessoriTestataRichiesta = datiAccessoriTestataRichiestaValori.ToString
                    '
                    'Dati Accessori Riga Richiesta
                    '
                    If rigaRichiesta.DatiAggiuntivi IsNot Nothing Then
                        For Each dato In rigaRichiesta.DatiAggiuntivi
                            If dato.DatoAccessorio Is Nothing Then
                                Dim codice = dato.Nome.Split("_")(0)
                                'Dim datoAccessorio = datiAccossoriLista.Where(Function(e) e.DatoAccessorio.Codice = codice).First

                                'If datoAccessorio IsNot Nothing AndAlso datoAccessorio.DatoAccessorio IsNot Nothing Then
                                '    dato.DatoAccessorio = datoAccessorio.DatoAccessorio
                                'Else

                                Dim datoAccessorioType As New DatoAccessorioType
                                datoAccessorioType.Etichetta = dato.Nome
                                dato.DatoAccessorio = datoAccessorioType

                                'End If
                            End If
                        Next

                        For Each datoAccessorio As DatoNomeValoreType In rigaRichiesta.DatiAggiuntivi
                            datiAccessoriPrestazioniRichiestaValori.Append(GetDatoAccessorioValore(datoAccessorio))
                        Next
                    End If

                    righeRichiesteRow.DatiAccessoriPrestazioneRichiesta = datiAccessoriPrestazioniRichiestaValori.ToString

                    'End If

                    righeRichiesteRow.DatiAccessoriTestataErogato = String.Empty
                    righeRichiesteRow.DatiAccessoriPrestazioneErogato = String.Empty
                    righeRichiesteRow.DatiPersistentiTestataErogato = String.Empty
                    righeRichiesteDataTable.AddRigheRichiesteRow(righeRichiesteRow)
                Next

                '
                'Gestione righe erogate ma non richieste
                '(per gli eroganti che restituiscono codici prestazione diversi da quelli richiesti)
                '
                If Not stato.Erogati Is Nothing Then
                    For Each testataErogata As TestataErogatoType In stato.Erogati
                        If Not testataErogata.RigheErogate Is Nothing Then
                            For Each rigaErogata As RigaErogataType In testataErogata.RigheErogate

                                Dim codicePrestazione = rigaErogata.Prestazione.Codice

                                Dim rows = (From rigaRichiesta In stato.Ordine.RigheRichieste
                                            Where rigaRichiesta.Prestazione.Codice = codicePrestazione And rigaRichiesta.SistemaErogante.Azienda.Codice = testataErogata.SistemaErogante.Azienda.Codice And rigaRichiesta.SistemaErogante.Sistema.Codice = testataErogata.SistemaErogante.Sistema.Codice).ToArray()

                                If rows.Length > 0 Then
                                    Continue For
                                End If

                                Dim datiAccessoriTestataErogatoValori As New StringBuilder
                                Dim datiAccessoririgaErogataValori As New StringBuilder
                                Dim datiPersistentiTestataErogatoValori As New StringBuilder

                                Dim composizioneOrdinePrestazioniErogateRow As OrdineDataSet.RigheRichiesteRow
                                composizioneOrdinePrestazioniErogateRow = righeRichiesteDataTable.NewRigheRichiesteRow

                                composizioneOrdinePrestazioniErogateRow.Id = rigaErogata.Prestazione.Id
                                composizioneOrdinePrestazioniErogateRow.Codice = rigaErogata.Prestazione.Codice
                                composizioneOrdinePrestazioniErogateRow.Descrizione = If(String.IsNullOrEmpty(rigaErogata.Prestazione.Descrizione), rigaErogata.Prestazione.Codice, rigaErogata.Prestazione.Descrizione)
                                composizioneOrdinePrestazioniErogateRow.AziendaEroganteCodice = testataErogata.SistemaErogante.Azienda.Codice
                                composizioneOrdinePrestazioniErogateRow.AziendaEroganteDescrizione = If(String.IsNullOrEmpty(testataErogata.SistemaErogante.Azienda.Descrizione), testataErogata.SistemaErogante.Azienda.Codice, testataErogata.SistemaErogante.Azienda.Descrizione)
                                composizioneOrdinePrestazioniErogateRow.SistemaEroganteCodice = testataErogata.SistemaErogante.Sistema.Codice
                                composizioneOrdinePrestazioniErogateRow.SistemaEroganteDescrizione = If(String.IsNullOrEmpty(testataErogata.SistemaErogante.Sistema.Descrizione), testataErogata.SistemaErogante.Sistema.Codice, testataErogata.SistemaErogante.Sistema.Descrizione)
                                composizioneOrdinePrestazioniErogateRow.Tipo = String.Empty
                                composizioneOrdinePrestazioniErogateRow.Erogante = String.Format("{0} - {1}", testataErogata.SistemaErogante.Azienda.Codice, testataErogata.SistemaErogante.Sistema.Descrizione)
                                composizioneOrdinePrestazioniErogateRow.Validita = True
                                composizioneOrdinePrestazioniErogateRow.DatiAccessoriTestataRichiesta = String.Empty
                                composizioneOrdinePrestazioniErogateRow.DatiAccessoriPrestazioneRichiesta = String.Empty

                                composizioneOrdinePrestazioniErogateRow.DatiAccessoriTestataErogato = String.Empty
                                composizioneOrdinePrestazioniErogateRow.DatiAccessoriPrestazioneErogato = String.Empty
                                composizioneOrdinePrestazioniErogateRow.DatiPersistentiTestataErogato = String.Empty

                                '
                                'Testata Erogato
                                '
                                'Dati Accessori
                                For Each dato In testataErogata.DatiAggiuntivi

                                    If dato.DatoAccessorio Is Nothing Then

                                        Dim codice = dato.Nome.Split("_")(0)

                                        'Dim datoAccessorio = datiAccossoriLista.Where(Function(e) e.DatoAccessorio.Codice = codice).FirstOrDefault

                                        'If datoAccessorio IsNot Nothing AndAlso datoAccessorio.DatoAccessorio IsNot Nothing Then
                                        '    dato.DatoAccessorio = datoAccessorio.DatoAccessorio
                                        'Else

                                        Dim datoAccessorioType As New DatoAccessorioType
                                        datoAccessorioType.Etichetta = dato.Nome
                                        dato.DatoAccessorio = datoAccessorioType

                                        'End If

                                    End If
                                Next

                                For Each datoAccessorio As DatoNomeValoreType In testataErogata.DatiAggiuntivi

                                    datiAccessoriTestataErogatoValori.Append(GetDatoAccessorioValore(datoAccessorio))

                                Next

                                composizioneOrdinePrestazioniErogateRow.DatiAccessoriTestataErogato = datiAccessoriTestataErogatoValori.ToString

                                'Dati Persistenti
                                If Not testataErogata.DatiPersistenti Is Nothing Then

                                    For Each dato In testataErogata.DatiPersistenti

                                        If dato.DatoAccessorio Is Nothing Then

                                            Dim codice = dato.Nome.Split("_")(0)

                                            'Dim datoAccessorio = datiAccossoriLista.Where(Function(e) e.DatoAccessorio.Codice = codice).FirstOrDefault

                                            'If datoAccessorio IsNot Nothing AndAlso datoAccessorio.DatoAccessorio IsNot Nothing Then
                                            '    dato.DatoAccessorio = datoAccessorio.DatoAccessorio
                                            'Else

                                            Dim datoAccessorioType As New DatoAccessorioType
                                            datoAccessorioType.Etichetta = dato.Nome
                                            dato.DatoAccessorio = datoAccessorioType

                                            'End If

                                        End If
                                    Next

                                    For Each datoAccessorio As DatoNomeValoreType In testataErogata.DatiPersistenti
                                        datiPersistentiTestataErogatoValori.Append(GetDatoAccessorioValore(datoAccessorio))
                                    Next

                                    composizioneOrdinePrestazioniErogateRow.DatiPersistentiTestataErogato = datiPersistentiTestataErogatoValori.ToString

                                    If Not rigaErogata.DatiAggiuntivi Is Nothing Then

                                        For Each dato In rigaErogata.DatiAggiuntivi

                                            If dato.DatoAccessorio Is Nothing Then

                                                Dim codice = dato.Nome.Split("_")(0)

                                                'Dim datoAccessorio = datiAccossoriLista.Where(Function(e) e.DatoAccessorio.Codice = codice).FirstOrDefault

                                                'If datoAccessorio IsNot Nothing AndAlso datoAccessorio.DatoAccessorio IsNot Nothing Then
                                                '    dato.DatoAccessorio = datoAccessorio.DatoAccessorio
                                                'Else

                                                Dim datoAccessorioType As New DatoAccessorioType
                                                datoAccessorioType.Etichetta = dato.Nome
                                                dato.DatoAccessorio = datoAccessorioType

                                                'End If

                                            End If

                                        Next

                                        For Each datoAccessorio As DatoNomeValoreType In rigaErogata.DatiAggiuntivi

                                            datiAccessoririgaErogataValori.Append(GetDatoAccessorioValore(datoAccessorio))
                                        Next

                                        composizioneOrdinePrestazioniErogateRow.DatiAccessoriPrestazioneErogato = datiAccessoririgaErogataValori.ToString
                                    End If
                                End If

                                Dim statoErogante As String = String.Empty
                                statoErogante = GetDescrizioneStatoRigaErogante(rigaErogata.StatoOrderEntry)

                                If String.IsNullOrEmpty(statoErogante) AndAlso Not String.IsNullOrEmpty(testataErogata.StatoOrderEntry) Then
                                    statoErogante = testataErogata.StatoOrderEntry
                                End If

                                composizioneOrdinePrestazioniErogateRow.StatoErogante = statoErogante

                                righeRichiesteDataTable.AddRigheRichiesteRow(composizioneOrdinePrestazioniErogateRow)

                            Next
                        End If
                    Next

                End If

            End If

            Return righeRichiesteDataTable

        Catch ex As Exception

            DI.OrderEntry.User.ExceptionsManager.TraceException(ex)

            Dim portal = New PortalDataAdapterManager(Global_asax.ConnectionStringPortalUser)

            portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)

            Return Nothing
        End Try

    End Function

    Private Shared Function GetDescrizioneStatoRigaErogante(ByVal codice As StatoRigaErogataOrderEntryEnum) As String

        Select Case codice

            Case StatoRigaErogataOrderEntryEnum.CA
                Return "Cancellata"

            Case StatoRigaErogataOrderEntryEnum.CM
                Return "Erogata"

            Case StatoRigaErogataOrderEntryEnum.IC
                Return "In carico"

            Case StatoRigaErogataOrderEntryEnum.IP
                Return "Programmata"

            Case Else
                Return String.Empty
        End Select
    End Function
End Class
