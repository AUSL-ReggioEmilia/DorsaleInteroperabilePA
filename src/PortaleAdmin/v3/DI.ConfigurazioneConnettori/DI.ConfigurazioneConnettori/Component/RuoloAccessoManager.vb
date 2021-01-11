Public Class RuoloAccessoManager

    Shared Sub Initiliaze()

        'Leggo dal database la lista dei ruoli

        Dim db As New DiAdminPortalDataContext

        Dim dtsource = db.ConfigurazioneConnettoriRuolis()
        Dim listRuoli As List(Of ConfigurazioneConnettoriRuoli) = dtsource.ToList()

        'Scrivo nell'application la lista dei Ruoli
        HttpContext.Current.Application(NameOf(RuoloAccessoManager)) = listRuoli

    End Sub

    Shared Function IsInRole(nome As String) As Boolean

        Dim listRuoli As List(Of ConfigurazioneConnettoriRuoli) =
            CType(HttpContext.Current.Application(NameOf(RuoloAccessoManager)), List(Of ConfigurazioneConnettoriRuoli))

        Dim ruolo As ConfigurazioneConnettoriRuoli = listRuoli.Where(Function(x) x.Ruolo = nome).FirstOrDefault

        If ruolo IsNot Nothing Then
            Dim claims As String = ruolo.Claims

            Dim listClaims As List(Of String) = claims.Split(";"c).ToList()

            For Each claim As String In listClaims

                If HttpContext.Current.User.IsInRole(claim) Then
                    Return True
                End If

            Next

            'Non appartiene a nessun ruolo
            Return False

        Else
            'Non appartiene a nessun ruolo
            Return False
        End If

    End Function

    Shared Function IsInRole(attrRuoloAccesso As RuoloAccesso) As Boolean

        If attrRuoloAccesso Is Nothing Then
            Return IsInRole("Default")
        Else
            Return IsInRole(attrRuoloAccesso.Nome)
        End If

    End Function

End Class