Imports System.Text
Imports System

Namespace DI.Sac.Admin

    Public NotInheritable Class MessageHelper

        Private Sub New()
        End Sub

        Private Const ContattaAmministratore As String = "Contattare l'amministratore del sistema."

        ''' <summary>
        ''' Ritorna un messaggio di errore da visualizzare in un controllo GridView
        ''' </summary>
        ''' <param name="TypeGridViewError"></param>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public Shared Function GetGridViewMessage(ByVal typeGridViewError As TypeGridViewError) As String          

            Select Case typeGridViewError

                Case typeGridViewError.CaricamentoDati

                    Return String.Concat("Errore durante l'operazione di ", typeGridViewError.ToString().Replace("CaricamentoDati", "Caricamento Dati").ToLower() _
                        , ". ", ContattaAmministratore)

                Case typeGridViewError.ElaborazionePagina

                    Return String.Concat("Errore durante l'operazione di ", typeGridViewError.ToString().Replace("ElaborazionePagina", "Elaborazione Pagina").ToLower() _
                        , ". ", ContattaAmministratore)

                Case Else
                    Return String.Concat("Errore durante l'operazione di ", typeGridViewError.ToString().ToLower(), ". ", ContattaAmministratore)
            End Select
        End Function

        ''' <summary>
        ''' Ritorna un messaggio di errore generico
        ''' </summary>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public Shared Function GetGenericMessage() As String
            Return "Errore dell'applicazione, operazione interrota. " & ContattaAmministratore
        End Function

    End Class

End Namespace