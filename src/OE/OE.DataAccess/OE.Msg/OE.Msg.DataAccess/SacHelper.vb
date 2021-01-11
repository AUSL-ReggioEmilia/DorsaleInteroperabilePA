Imports System.Net
Imports OE.Core
Imports OE.Core.Schemas.Msg
Imports System.ServiceModel

Public NotInheritable Class SacHelper

    Private Const DATO_AGG_TIPO_STRING As String = "xs:string"
    Private Const PREFIX_NO_TRANS As String = "U@"

    Private Const UO_RICHIEDENTE_CODICE = "UnitaOperativaRichiedenteCodice"
    Private Const UO_RICHIEDENTE_DESC = "UnitaOperativaRichiedenteDescrizione"

    Private Const UO_CENTRALE_CODICE = "UnitaOperativaCentraleCodice"
    Private Const UO_CENTRALE_DESC = "UnitaOperativaCentraleDescrizione"


    Public Shared Function GetEntryPoinyTranscodifiche() As SAC.Transcodifiche.TranscodificheClient

        DiagnosticsHelper.WriteDiagnostics("SacHelper.GetEntryPoinyTranscodifiche()")

        Dim oService As New SAC.Transcodifiche.TranscodificheClient
        If oService IsNot Nothing Then

            ' Verifica il tipo di binding
            Dim b = TryCast(oService.ChannelFactory.Endpoint.Binding, BasicHttpBinding)
            If b IsNot Nothing Then

                'Configurazione di accesso
                Dim Configuration As ConfigurationSettings = ConfigurationHelper.ConfigurationSettings

                ' basicBinding, SOAP 1.1
                If Not String.IsNullOrEmpty(Configuration.WsUserName) Then
                    '
                    ' Attenzione dipende anche dalla configurazione del WS (file web.config)
                    '<security mode="Transport">
                    '	<transport clientCredentialType="Basic"/>
                    '</security>
                    '
                    ' OPPURE
                    '
                    ' Attenzione dipende anche dalla configurazione del WS (file web.config)
                    '<security mode="Transport">
                    '	<transport clientCredentialType="Windows"/>
                    '</security>
                    '
                    Dim cc = b.Security.Transport.ClientCredentialType
                    If cc = HttpClientCredentialType.Basic Then
                        '
                        ' Autenticazione BASIC
                        '
                        If String.IsNullOrEmpty(Configuration.WsDomain) Then
                            oService.ClientCredentials.UserName.UserName = Configuration.WsUserName
                        Else
                            oService.ClientCredentials.UserName.UserName = String.Concat(Configuration.WsDomain, "\", Configuration.WsUserName)
                        End If
                        oService.ClientCredentials.UserName.Password = Configuration.WsPassword

                    ElseIf cc = HttpClientCredentialType.Windows Then
                        '
                        ' Autenticazione WINDOWS
                        '
                        oService.ClientCredentials.Windows.ClientCredential = New Net.NetworkCredential(Configuration.WsUserName, _
                                                                                                        Configuration.WsPassword, _
                                                                                                        Configuration.WsDomain)
                    End If

                    b.UseDefaultWebProxy = False
                Else
                    '
                    ' Integrata con l'utente AppPool del service IIS
                    '
                    b.UseDefaultWebProxy = True
                End If

            End If
        End If

        Return oService

    End Function

    Public Shared Sub TranscodificaUnitaOperativaIngresso(ByRef richiesta As QueueTypes.RichiestaQueueType)
        '
        ' Transcodifica i dati della UO in ingresso (dati del richiedente) verso il CORE
        '
        DiagnosticsHelper.WriteDiagnostics("SacHelper.TranscodificaUnitaOperativaIngresso()")

        'Configurazione di accesso
        Dim Configuration As ConfigurationSettings = ConfigurationHelper.ConfigurationSettings

        DiagnosticsHelper.WriteDiagnostics(DataContractSerializerHelper.GetXML(Configuration))

        'Controllo se attivato
        If Not Configuration.TranscodificaAttiva Then
            Exit Sub
        End If

        'Controllo i dati
        If richiesta.Testata Is Nothing Then
            ' Mancano i dati minimi
            Exit Sub
        End If

        Dim testataRichiesta As QueueTypes.TestataRichiestaType = richiesta.Testata

        'Controllo i dati
        If testataRichiesta.UnitaOperativaRichiedente Is Nothing OrElse testataRichiesta.SistemaRichiedente Is Nothing Then
            ' Mancano i dati minimi
            Exit Sub
        End If

        If testataRichiesta.UnitaOperativaRichiedente.UnitaOperativa.Codice.StartsWith(PREFIX_NO_TRANS) Then
            'Già codice centrale non transcodifico
            Exit Sub
        End If

        'Rimuove backup nei dati aggiuntivi
        UnitaOperativaBackupRichiedenteClean(testataRichiesta)

        'Transcodifica Unità Operativa
        Using clientTrans As SAC.Transcodifiche.TranscodificheClient = GetEntryPoinyTranscodifiche()
            ' Compilo i parametri del WS SAC
            Dim sistema As New SAC.Transcodifiche.SistemaType With {.Azienda = testataRichiesta.SistemaRichiedente.Azienda.Codice, _
                                                                    .Codice = testataRichiesta.SistemaRichiedente.Sistema.Codice}

            Dim unitaOperativa As New SAC.Transcodifiche.UnitaOperativaType With {.Azienda = testataRichiesta.UnitaOperativaRichiedente.Azienda.Codice, _
                                                                                  .Codice = testataRichiesta.UnitaOperativaRichiedente.UnitaOperativa.Codice, _
                                                                                  .Descrizione = testataRichiesta.UnitaOperativaRichiedente.UnitaOperativa.Descrizione}
            'Eseguo transcodifica
            Dim unitaOperativaTrans As SAC.Transcodifiche.UnitaOperativaType
            unitaOperativaTrans = clientTrans.TranscodificaUnitaOperativaDaSistemaACentrale(sistema, unitaOperativa)

            'Controllo se modificato
            If testataRichiesta.UnitaOperativaRichiedente.Azienda.Codice <> unitaOperativaTrans.Azienda OrElse _
                                            testataRichiesta.UnitaOperativaRichiedente.UnitaOperativa.Codice <> unitaOperativaTrans.Codice OrElse _
                                            testataRichiesta.UnitaOperativaRichiedente.UnitaOperativa.Descrizione <> unitaOperativaTrans.Descrizione Then

                'Salvo UO esterna nei dati aggiuntivi
                UnitaOperativaBackupRichiedenteAggiungi(testataRichiesta)

                'Sostituisco UO nella richiesta
                testataRichiesta.UnitaOperativaRichiedente.UnitaOperativa.Codice = unitaOperativaTrans.Codice
                testataRichiesta.UnitaOperativaRichiedente.UnitaOperativa.Descrizione = unitaOperativaTrans.Descrizione

                If testataRichiesta.UnitaOperativaRichiedente.Azienda.Codice <> unitaOperativaTrans.Azienda Then
                    'Modifico anche l'azienda
                    testataRichiesta.UnitaOperativaRichiedente.Azienda.Codice = unitaOperativaTrans.Azienda
                    testataRichiesta.UnitaOperativaRichiedente.Azienda.Descrizione = Nothing
                End If
            End If
        End Using

    End Sub

    Public Shared Sub TranscodificaUnitaOperativaUscita(ByRef richiesteQueue As RichiestaReturnTypes.RichiesteQueueType)
        '
        ' Transcodifica i dati della UO in uscita (dati del CORE) verso l'erogante
        ' Le righe devo essere tutte dello stesso erogante (già split in caso di multisettore)
        DiagnosticsHelper.WriteDiagnostics("SacHelper.TranscodificaUnitaOperativaUscita()")

        'Configurazione di accesso
        Dim Configuration As ConfigurationSettings = ConfigurationHelper.ConfigurationSettings

        DiagnosticsHelper.WriteDiagnostics(DataContractSerializerHelper.GetXML(Configuration))

        'Controllo se attivato
        If Not Configuration.TranscodificaAttiva Then
            Exit Sub
        End If

        'Controllo i dati
        If richiesteQueue Is Nothing OrElse richiesteQueue.Count = 0 Then
            ' Mancano i dati minimi
            Exit Sub
        End If

        'Transcodifica Unità Operativa
        Using clientTrans As SAC.Transcodifiche.TranscodificheClient = GetEntryPoinyTranscodifiche()

            'Su tutte le richieste
            For Each richiestaReturn As QueueTypes.RichiestaQueueType In richiesteQueue
                Dim testataRichiesta As QueueTypes.TestataRichiestaType = richiestaReturn.Testata

                'Controllo i dati
                If testataRichiesta.UnitaOperativaRichiedente Is Nothing OrElse testataRichiesta.RigheRichieste Is Nothing OrElse _
                                                                    testataRichiesta.RigheRichieste.Count = 0 Then
                    ' Mancano i dati minimi
                    Continue For
                End If

                Dim sAzienda As String = testataRichiesta.RigheRichieste.First.SistemaErogante.Azienda.Codice
                Dim sSistema As String = testataRichiesta.RigheRichieste.First.SistemaErogante.Sistema.Codice
                If Not testataRichiesta.RigheRichieste.TrueForAll(Function(e) e.SistemaErogante.Azienda.Codice = sAzienda AndAlso e.SistemaErogante.Sistema.Codice = sSistema) Then
                    ' Di sistemi eroganti diversi
                    Continue For
                End If

                If testataRichiesta.UnitaOperativaRichiedente.UnitaOperativa.Codice.StartsWith(PREFIX_NO_TRANS) Then
                    'Già codice centrale non transcodifico
                    Continue For
                End If

                ' Compilo i parametri del WS SAC
                Dim sistema As New SAC.Transcodifiche.SistemaType With {.Azienda = sAzienda, _
                                                                        .Codice = sSistema}

                Dim unitaOperativa As New SAC.Transcodifiche.UnitaOperativaType With {.Azienda = testataRichiesta.UnitaOperativaRichiedente.Azienda.Codice, _
                                                                                      .Codice = testataRichiesta.UnitaOperativaRichiedente.UnitaOperativa.Codice, _
                                                                                      .Descrizione = testataRichiesta.UnitaOperativaRichiedente.UnitaOperativa.Descrizione}
                'Eseguo transcodifica
                Dim unitaOperativaTrans As SAC.Transcodifiche.UnitaOperativaType
                unitaOperativaTrans = clientTrans.TranscodificaUnitaOperativaDaCentraleASistema(sistema, unitaOperativa)

                'Controllo se modificato
                If testataRichiesta.UnitaOperativaRichiedente.Azienda.Codice <> unitaOperativaTrans.Azienda OrElse _
                                                testataRichiesta.UnitaOperativaRichiedente.UnitaOperativa.Codice <> unitaOperativaTrans.Codice OrElse _
                                                testataRichiesta.UnitaOperativaRichiedente.UnitaOperativa.Descrizione <> unitaOperativaTrans.Descrizione Then

                    'Sostituisco UO nella richiesta
                    testataRichiesta.UnitaOperativaRichiedente.UnitaOperativa.Codice = unitaOperativaTrans.Codice
                    testataRichiesta.UnitaOperativaRichiedente.UnitaOperativa.Descrizione = unitaOperativaTrans.Descrizione

                    If testataRichiesta.UnitaOperativaRichiedente.Azienda.Codice <> unitaOperativaTrans.Azienda Then
                        'Modifico anche l'azienda
                        testataRichiesta.UnitaOperativaRichiedente.Azienda.Codice = unitaOperativaTrans.Azienda
                        testataRichiesta.UnitaOperativaRichiedente.Azienda.Descrizione = Nothing
                    End If
                End If
            Next

        End Using

    End Sub


    Private Shared Sub UnitaOperativaBackupRichiedenteAggiungi(testataRichiesta As QueueTypes.TestataRichiestaType)

        'Salvo UO esterna nei dati aggiuntivi
        Dim datoAggUoCodice As New QueueTypes.DatoNomeValoreType With {.Nome = UO_RICHIEDENTE_CODICE, _
                                                                    .TipoDato = DATO_AGG_TIPO_STRING, _
                                                                    .ValoreDato = testataRichiesta.UnitaOperativaRichiedente.UnitaOperativa.Codice}
        Dim datoAggUoDescrizione As New QueueTypes.DatoNomeValoreType With {.Nome = UO_RICHIEDENTE_DESC, _
                                                                    .TipoDato = DATO_AGG_TIPO_STRING, _
                                                                    .ValoreDato = testataRichiesta.UnitaOperativaRichiedente.UnitaOperativa.Descrizione & ""}

        If testataRichiesta.DatiAggiuntivi Is Nothing Then
            testataRichiesta.DatiAggiuntivi = New QueueTypes.DatiAggiuntiviType
        End If
        testataRichiesta.DatiAggiuntivi.Add(datoAggUoCodice)
        testataRichiesta.DatiAggiuntivi.Add(datoAggUoDescrizione)

    End Sub

    Private Shared Sub UnitaOperativaBackupCentraleAggiungi(testataRichiesta As QueueTypes.TestataRichiestaType)

        'Salvo UO centrale nei dati aggiuntivi
        Dim datoAggUoCodice As New QueueTypes.DatoNomeValoreType With {.Nome = UO_CENTRALE_CODICE, _
                                                                    .TipoDato = DATO_AGG_TIPO_STRING, _
                                                                    .ValoreDato = testataRichiesta.UnitaOperativaRichiedente.UnitaOperativa.Codice}
        Dim datoAggUoDescrizione As New QueueTypes.DatoNomeValoreType With {.Nome = UO_CENTRALE_DESC, _
                                                                    .TipoDato = DATO_AGG_TIPO_STRING, _
                                                                    .ValoreDato = testataRichiesta.UnitaOperativaRichiedente.UnitaOperativa.Descrizione & ""}

        If testataRichiesta.DatiAggiuntivi Is Nothing Then
            testataRichiesta.DatiAggiuntivi = New QueueTypes.DatiAggiuntiviType
        End If
        testataRichiesta.DatiAggiuntivi.Add(datoAggUoCodice)
        testataRichiesta.DatiAggiuntivi.Add(datoAggUoDescrizione)

    End Sub

    Private Shared Sub UnitaOperativaBackupRichiedenteClean(testataRichiesta As QueueTypes.TestataRichiestaType)

        If testataRichiesta IsNot Nothing AndAlso testataRichiesta.DatiAggiuntivi IsNot Nothing Then
            testataRichiesta.DatiAggiuntivi.RemoveAll(Function(e) e.Nome = UO_RICHIEDENTE_CODICE OrElse e.Nome = UO_RICHIEDENTE_DESC)
        End If

    End Sub

    Private Shared Sub UnitaOperativaBackupCentraleClean(testataRichiesta As QueueTypes.TestataRichiestaType)

        If testataRichiesta IsNot Nothing AndAlso testataRichiesta.DatiAggiuntivi IsNot Nothing Then
            testataRichiesta.DatiAggiuntivi.RemoveAll(Function(e) e.Nome = UO_CENTRALE_CODICE OrElse e.Nome = UO_CENTRALE_DESC)
        End If

    End Sub

End Class