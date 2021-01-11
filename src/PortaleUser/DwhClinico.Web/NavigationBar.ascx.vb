Imports DwhClinico.Web
Imports DwhClinico.Web.Utility

Partial Class NavigationBar
    Inherits AbstractBarraNavigazione
    '
    ' Variabili private della classe
    '
    Private mobjColl As Collections.ArrayList
    Private mstrCurrentText As String

    Public Overrides ReadOnly Property NavBarList() As Collections.ArrayList

        Get
            '
            ' Se la variabili locale è nothing cerco nelle Session
            '
            If IsNothing(mobjColl) Then
                Dim strUsername As String = HttpContext.Current.User.Identity.Name
                Dim strSessName As String = PAR_BARRA_NAVIGAZIONE & "_" & strUsername

                mobjColl = CType(HttpContext.Current.Application.Item(strSessName), ArrayList)
            End If

            Return mobjColl
        End Get

    End Property

    Public Overrides Sub SetCurrentItem(ByVal rsText As String, ByVal rsNavigateURL As String)
        '
        ' Aggiunge un elemento alla collezione se non esiste già
        '
        Dim objListItem, objListItemEx As ListItem
        Dim i As Integer
        Dim sKey As String
        Dim boolAddItem As Boolean
        Dim objColl As Collections.ArrayList = Me.NavBarList

        Try
            boolAddItem = True
            '
            ' Salvo il testo in una variabile di classe
            ' per poi riprenderlo
            '
            mstrCurrentText = rsText
            '
            ' se rsNavigateURL="" -> URL della pagina corrente
            '
            If Len(rsNavigateURL) = 0 Then
                rsNavigateURL = GetThisURL()
            End If
            objListItem = New ListItem(rsText, rsNavigateURL)

            If objColl Is Nothing Then
                '
                ' Aggiungo l'item appena create
                '
                objColl = New Collections.ArrayList
                objColl.Add(objListItem)
            Else
                '
                ' Controllo che non esista; se esiste lo sovrascrivo
                '
                For i = 0 To objColl.Count - 1
                    objListItemEx = CType(objColl.Item(i), ListItem)
                    sKey = objListItemEx.Text
                    If sKey.ToUpper = rsText.ToUpper Then
                        boolAddItem = False
                        '
                        ' lo sostituisco
                        '
                        objListItemEx.Value = rsNavigateURL
                    End If
                Next
                If boolAddItem Then
                    objColl.Add(objListItem)
                End If
            End If
            '
            ' ...e risalvo nella Session l'oggetto
            '
            Dim strUsername As String = HttpContext.Current.User.Identity.Name
            Dim strSessName As String = PAR_BARRA_NAVIGAZIONE & "_" & strUsername

            HttpContext.Current.Application.Item(strSessName) = objColl
            '
            ' Eseguo il bind della pagina con i dati
            '
            Call PageDataBind(rsText)

        Catch ex As Exception
            '
            ' Errore
            '
            Throw ex
        End Try

    End Sub

    Public Overrides Sub ClearAll()
        '
        ' Vuota la collezione
        '
        Try
            Dim strUsername As String = HttpContext.Current.User.Identity.Name
            Dim strSessName As String = Utility.PAR_BARRA_NAVIGAZIONE & "_" & strUsername

            HttpContext.Current.Application.Remove(strSessName)
            mobjColl = Nothing

        Catch ex As Exception
            '
            ' Errore
            '
        End Try

    End Sub

    Protected Function GetHtmlLink(ByVal robjListItem As Object) As String
        '
        ' Ritorna HTML per disegnare il link della barra di navigazione
        '
        Dim oListItemLink As ListItem = CType(robjListItem, ListItem)

        Dim strClass As String = "PageNavBarItemNormal"
        Dim strText As String = oListItemLink.Text
        Dim strValue As String = oListItemLink.Value

        If Not IsNothing(mstrCurrentText) AndAlso mstrCurrentText.Length > 0 Then
            '
            ' Se è il testo corrente lo stile cambia
            '
            If mstrCurrentText.ToUpper = strText.ToUpper Then
                strClass = "PageNavBarItemSelected"
                strValue = ""
            End If
        End If

        If strValue.Length = 0 Then
            Return "<a class='" & strClass & "' >" & strText & "</a>"
        Else
            Return "<a class='" & strClass & "' href='" & strValue & "'>" & strText & "</a>"
        End If

    End Function

    Private Sub PageDataBind(ByVal rstrCurrentItemText As String)
        '
        ' Eseguo il bind della pagina con intCount dati
        '
        Dim objColl As Collections.ArrayList = Me.NavBarList
        Dim intCount, intNumItems As Integer
        Dim strKey As String
        Dim objListItem As ListItem

        If Not IsNothing(objColl) Then
            '
            ' Elimino gli items successivi al corrente
            '
            For intCount = 0 To objColl.Count - 1
                '
                ' Prendo l'item
                '
                objListItem = CType(objColl.Item(intCount), ListItem)
                strKey = objListItem.Text
                If strKey.ToUpper = rstrCurrentItemText.ToUpper Then
                    '
                    ' Numero ultimo elemento visualizzato
                    '
                    intNumItems = intCount + 1
                    Exit For
                End If
            Next
            '
            ' Rimuovo da intNumItems in avanti
            '
            Do While intNumItems < objColl.Count
                objColl.RemoveAt(intNumItems)
            Loop
            '
            ' Eseguo il bind
            '
            dlLinkNav.DataSource = objColl
            dlLinkNav.DataBind()
        End If

    End Sub

    Private Function GetThisURL() As String
        '
        ' Ritorna l'URL corrente
        '
        Return HttpContext.Current.Request.Url.AbsoluteUri.ToString

    End Function

End Class
