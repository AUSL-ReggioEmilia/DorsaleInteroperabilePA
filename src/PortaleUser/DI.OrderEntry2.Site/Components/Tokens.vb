Public Class Tokens

    Public Shared Function GetToken(CodiceRuolo As String) As WcfDwhClinico.TokenType
        Dim oTokenReturn As WcfDwhClinico.TokenReturn = Nothing
        Dim oToken As WcfDwhClinico.TokenType = Nothing
        oToken = SessionHandler.Token

        '
        'BUG FIX - SimoneB,26/04/2017
        'Cambiando il ruolo nel portale DWH e tornando sul OE veniva preso il token dalla sessione, valorizzato con il ruolo precedente
        'Testo se il codiceRuolo contenuto nel token è uguale a quello passato alla funzione. Se sono diversi allora rigenero il token
        '
        If oToken IsNot Nothing Then
            If oToken.CodiceRuolo.ToUpper <> CodiceRuolo.ToUpper Then
                oToken = Nothing
            End If
        End If

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

    ''' <summary>
    ''' Funzione che restituisce il Token usato per popolare la lista dei pazienti ricoverati
    ''' Questo metodo genera un token usando le setting ByPassOscuramenti_Ruolo e ByPassOscuramenti_Utente in modo da bypassare gli oscuramenti
    ''' </summary>
    ''' <returns></returns>
    Public Shared Function GetTokenPerByPassOscuramenti() As WcfDwhClinico.TokenType
        'Ottengo il codiceRuolo e L'utente per bypassare gli oscuramenti
        Dim sCodiceRuolo As String = My.Settings.ByPassOscuramenti_Ruolo
        Dim sUtente As String = My.Settings.ByPassOscuramenti_Utente

        'Se le setting sono vuote allora restituisco nothing
        If String.IsNullOrEmpty(sCodiceRuolo) OrElse String.IsNullOrEmpty(sUtente) Then
            Return Nothing
        End If

        Dim oTokenReturn As WcfDwhClinico.TokenReturn = Nothing
        Dim oToken As WcfDwhClinico.TokenType = Nothing
        oToken = SessionHandler.TokenPerByPassOscuramenti

        '
        'Cambiando il ruolo nel portale DWH e tornando sul OE veniva preso il token dalla sessione, valorizzato con il ruolo precedente
        'Testo se il codiceRuolo contenuto nel token è uguale a quello passato alla funzione. Se sono diversi allora rigenero il token
        '
        If oToken IsNot Nothing Then
            If oToken.CodiceRuolo.ToUpper <> sCodiceRuolo Then
                oToken = Nothing
            End If
        End If

        If oToken Is Nothing Then

            Using oWcf As New WcfDwhClinico.ServiceClient
                Call Utility.SetWcfDwhClinicoCredential(oWcf)

                Try

                    oTokenReturn = oWcf.CreaTokenAccessoDelega(sCodiceRuolo, sUtente)

                    If oTokenReturn.Errore IsNot Nothing Then
                        Throw New Exception(oTokenReturn.Errore.Descrizione)
                    End If
                    '
                    ' Salvo il token nella session
                    '
                    SessionHandler.TokenPerByPassOscuramenti = oTokenReturn.Token
                    oToken = oTokenReturn.Token
                Catch ex As Exception
                    Throw New ApplicationException(String.Format("Si è verificato un errore durante la generazione del token: {0}", ex.Message))
                End Try
            End Using
        End If
        Return oToken
    End Function

End Class

