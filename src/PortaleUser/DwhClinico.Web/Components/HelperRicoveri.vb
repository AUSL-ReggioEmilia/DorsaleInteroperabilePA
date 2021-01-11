Public Class HelperRicoveri
    ''' <summary>
    ''' Logica per determinare se un paziente è ricoverato
    ''' </summary>
    ''' <param name="StatoEpisodio"></param>
    ''' <returns></returns>
    Public Shared Function IsEpisodioAperto(StatoEpisodio As String) As Boolean
        Dim bRet As Boolean = True
        If String.Compare(StatoEpisodio, "DIMISSIONE", True) = 0 Then
            bRet = False
        ElseIf String.Compare(StatoEpisodio, "CHIUSURA", True) = 0 Then
            bRet = False
        End If
        Return bRet
    End Function

    ''' <summary>
    ''' Restituisce l'icona associata al ricovero
    ''' </summary>
    ''' <param name="sTipoEpisodioRicovero"></param>
    ''' <returns></returns>
    Public Shared Function GetHtmlImgTipoEpisodioRicovero(ByVal sTipoEpisodioRicovero As String) As String
        Dim strHtml As String = String.Empty
        Select Case sTipoEpisodioRicovero.ToUpper
            Case "O" 'Ricovero Ordinario
                strHtml = "<img src='" & VirtualPathUtility.ToAbsolute("~/images/RicoveroOrdinario.gif") & "' alt='Ricovero ordinario' border=0>"
            Case "D" 'Day Hospital
                strHtml = "<img src='" & VirtualPathUtility.ToAbsolute("~/images/RicoveroDH.gif") & "' alt='Ricovero Day Hospital' border=0>"
            Case "S" 'Day Service
                strHtml = "<img src='" & VirtualPathUtility.ToAbsolute("~/images/RicoveroDS.gif") & "' alt='Ricovero Day Service' border=0>"
            Case "P" 'Pronto Soccorso
                strHtml = "<img src='" & VirtualPathUtility.ToAbsolute("~/images/RicoveroPS.gif") & "' alt='Episodio di Pronto Soccorso' border=0>"
            Case "B" 'OBI
                strHtml = "<img src='" & VirtualPathUtility.ToAbsolute("~/images/RicoveroOBI.gif") & "' alt='OBI' border=0>"
        End Select
        Return strHtml
    End Function

End Class
