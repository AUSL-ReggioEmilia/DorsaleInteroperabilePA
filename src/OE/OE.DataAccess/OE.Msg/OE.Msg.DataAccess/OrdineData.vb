Imports System.Threading
Imports System.Xml
Imports OE.Core
Imports OE.Core.Schemas.Msg
Imports OE.Core.Schemas.Msg.QueueTypes

<Serializable()>
<CLSCompliant(True)>
Public Class OrdineData

    Public Sub New()
    End Sub

    Public Function OrdinePerIdOrderEntry(ByVal value As String, ByVal settings As ConfigurationSettings) As OrdineReturnTypes.OrdineReturn

        Try
            '######################################################
            ' Prima cosa da fare Initialize(settings)
            '######################################################

            ' Init Custom settings
            ConfigurationHelper.Initialize(settings)

            ' Trace
            DiagnosticsHelper.WriteDiagnostics("OrdineData.OrdinePerIdOrderEntry()")
            DiagnosticsHelper.WriteDiagnostics("--InitAdapters")

            Dim Ordine As New OrdineReturnTypes.OrdineReturn
            '
            ' Legge richiesta e stati
            '
            Using taRichiesta = New RichiestaAdapter(ConfigurationHelper.ConnectionString)
                Ordine.Richiesta = taRichiesta.Legge(value)
            End Using

            Using taStato = New StatoAdapter(ConfigurationHelper.ConnectionString)

                ' Legge gli stati
                Dim listStati As List(Of QueueTypes.TestataStatoType) = taStato.Legge(value)
                If listStati IsNot Nothing AndAlso listStati.Count > 0 Then

                    'Aggiunge al risultato
                    Ordine.Stati = New OrdineReturnTypes.StatiType
                    Ordine.Stati.AddRange(listStati)
                End If
            End Using

            'Completato
            Ordine.Esito = New CodiceDescrizioneType() With {.Codice = "AA"}

            Return Ordine

        Catch ex As Exception

            ' Ritorna errore
            Throw

        End Try

    End Function

End Class
