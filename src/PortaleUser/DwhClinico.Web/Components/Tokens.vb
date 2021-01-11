Public Class Tokens

    Public Shared Function GetToken(CodiceRuolo As String) As WcfDwhClinico.TokenType
        Dim oTokenReturn As WcfDwhClinico.TokenReturn = Nothing
        Dim oToken As WcfDwhClinico.TokenType = Nothing
        oToken = SessionHandler.Token

        '
        'BUG FIX - SimoneB,26/04/2017
        'Cambiando il ruolo nel portale OE e tornando sul DWH veniva preso il token dalla sessione, valorizzato con il ruolo precedente
        'Testo se il codiceRuolo contenuto nel token è uguale a quello passato alla funzione. Se sono diversi allora rigenero il token
        '
        If oToken IsNot Nothing Then
            If oToken.CodiceRuolo.ToUpper <> CodiceRuolo.ToUpper Then
                oToken = Nothing
            End If
        End If

        '
        'Se oToken è nothing allora lo creo
        '
        If oToken Is Nothing Then
            Dim sCurrentUser As String = HttpContext.Current.User.Identity.Name.ToUpper

            Using oWcf As New WcfDwhClinico.ServiceClient
                Call Utility.SetWcfDwhClinicoCredential(oWcf)

                Try

                    oTokenReturn = oWcf.CreaTokenAccessoDelega(CodiceRuolo, sCurrentUser)

                    If oTokenReturn.Errore IsNot Nothing Then
                        'TODO: verificare cosa succede se si verifica un errore
                        Throw New Exception(oTokenReturn.Errore.Descrizione)
                    End If
                    '
                    ' Salvo il token nella session
                    '
                    SessionHandler.Token = oTokenReturn.Token
                    oToken = oTokenReturn.Token
                Catch ex As Exception
                    Throw New ApplicationException(String.Format("Si è verificato un errore durante la generazione del token: {0}", ex.Message))
                End Try

            End Using
        End If
        Return oToken
    End Function


End Class
