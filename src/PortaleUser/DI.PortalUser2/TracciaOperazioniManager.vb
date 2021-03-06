﻿Imports System.Web
Imports System.Web.UI
Imports System.Web.UI.WebControls

Public Class TracciaOperazioniManager

    Private _connectionString As String = String.Empty

    Public Sub New(ByVal connectionString As String)
        _connectionString = connectionString
    End Sub

    ''' <summary>
    ''' Traccia l'operazione sul DB. UNICA FUNZIONE CENTRALIZZATA --> Controllare se c'è un overload con i parametri più adatti
    ''' </summary>
    ''' <param name="nomePortale"></param>
    ''' <param name="operazione"></param>
    ''' <param name="datiXML"></param>
    ''' <param name="idPaziente"></param>
    ''' <param name="idRiferimento"></param>
    ''' <param name="nomeRiferimento"></param>
    Public Sub TracciaOperazione(nomePortale As String,
                                        pagina As String,
                                        operazione As String,
                                        idPaziente As Guid?,
                                        Optional datiXML As XElement = Nothing,
                                        Optional idRiferimento As String = Nothing,
                                        Optional nomeRiferimento As String = Nothing
                                        )

        Dim user As CurrentUser = GetCurrentUser()
        Try
            Using ta As New TracciaOperazioniDataSetTableAdapter_Custom(_connectionString)
                ta.TracciaOperazioni(DateTime.Now, nomePortale, pagina, user.HostAddress, user.HostName, user.UserName, operazione,
                                     datiXML?.ToString(), idPaziente, idRiferimento, nomeRiferimento)
            End Using

        Catch ex As Exception
            Throw ex
        End Try

    End Sub

    ''' <summary>
    ''' Traccia operazioni di ricerca nelle liste sul DB. Estrapola i filtri usati dal control pannelloFiltri
    ''' </summary>
    ''' <param name="nomePortale"></param>
    ''' <param name="operazione"></param>
    ''' <param name="contenitoreFiltri">Passare il control pannelloFiltri</param>
    ''' <param name="idPaziente"></param>
    ''' <param name="idRiferimento"></param>
    ''' <param name="nomeRiferimento"></param>
    Public Sub TracciaOperazione(nomePortale As String,
                                        pagina As String,
                                        operazione As String,
                                        contenitoreFiltri As Control,
                                        idPaziente As Guid?,
                                        Optional idRiferimento As String = Nothing,
                                        Optional nomeRiferimento As String = Nothing
                                        )

        TracciaOperazione(nomePortale, pagina, operazione, idPaziente,
                          CreateFilterParametersXML(contenitoreFiltri), idRiferimento, nomeRiferimento)

    End Sub

    ' Ottiene i parametri usati nel filtro e li formatta in un XML
    Private Function CreateFilterParametersXML(filtriControl As Control) As XElement

        ' Dichiaro l'XML che conterrà tuti i parametri dei filtri
        Dim datiXML As XElement = New XElement("Parametri")

        ' Ottengo la stringa contenente i filtri concatenati
        Dim sParameters = GetFilterParameters(filtriControl).TrimEnd("|")

        If Not String.IsNullOrEmpty(sParameters) Then

            ' Ottengo la lista dei filtri (coppia Nome:Valore) dalla stringa
            Dim parametersList As List(Of String) = sParameters.Split("|").ToList()


            ' Ricavo il nome del filtro e il suo valore per poi scriverlo nel XML
            For Each filter As String In parametersList

                Dim index As Integer = filter.IndexOf(":")
                If Not index = 0 Then
                    Dim name = filter.Substring(0, index)
                    Dim value = filter.Substring(index + 1)

                    ' Creo il nodo da aggiungere con gli attributi
                    Dim node As XElement = CreateNodeWithAttributes("Parametro", "Nome", name, "Valore", value)

                    ' Aggiungo il nodo al XML
                    datiXML.Add(node)
                End If

            Next
        End If

        If datiXML.HasElements Then
            Return datiXML
        Else
            ' Se non ci sono elementi ritorno Nothing
            Return Nothing
        End If

    End Function

    ' Ottiene dal controllo i campi dei filtri
    Private Function GetFilterParameters(currentControl As Control, Optional sRet As String = "") As String

        ' Se il controllo ha un ID 
        If currentControl.ID IsNot Nothing Then

            ' Ottengo i filtri utilizzati. Come nome viene usato l'ID del filtro senza la parola chiave dell'elemento (es. Textbox)
            Select Case currentControl.GetType()

                Case GetType(TextBox)
                    ' Aggiungo il filtro solo se non vuoto
                    If Not String.IsNullOrEmpty(TryCast(currentControl, TextBox).Text) Then
                        sRet &= $"{GetCleanName(currentControl.ID)}:{TryCast(currentControl, TextBox).Text}|"
                    End If

                Case GetType(CheckBox)
                    sRet &= $"{GetCleanName(currentControl.ID)}:{TryCast(currentControl, CheckBox).Checked}|"

                Case GetType(DropDownList)
                    ' Aggiungo il filtro solo se non vuoto
                    If Not String.IsNullOrEmpty(TryCast(currentControl, DropDownList).SelectedItem.Text) Then
                        sRet &= $"{GetCleanName(currentControl.ID)}:{TryCast(currentControl, DropDownList).SelectedItem.Text}|"
                    End If

                Case GetType(RadioButtonList)
                    sRet &= $"{GetCleanName(currentControl.ID)}:{TryCast(currentControl, RadioButtonList).SelectedItem.Text}|"
            End Select
        End If

        For Each child As Control In currentControl.Controls

            ' Chiamo la funzione ricorsivamente per ottenere il figlio più interno, che è il controllo cercato
            sRet = GetFilterParameters(child, sRet)
        Next

        Return sRet
    End Function

    ' Ottiene il nome del filtro rimuovendo il nome del tipo di input dall'id (Es. NomeTextBox --> Nome)
    Private Function GetCleanName(idName As String)

        Dim name As String

        name = idName.Replace("TextBox", "").Replace("txt", "").Replace("DropDownList", "").Replace("ddl", "").Replace("cmb", "").Replace("CheckBox", "").Replace("chk", "").Replace("RadioButtonList", "").Replace("rbl", "")

        Return name
    End Function

    ' Crea un nodo XML con gli atributi keyName=key e valueName=Value
    Private Function CreateNodeWithAttributes(nodeName As String, keyName As String, key As String, valueName As String, value As String) As XElement

        Dim node As XElement = New XElement(nodeName)
        node.SetAttributeValue(keyName, key)
        node.SetAttributeValue(valueName, value)

        Return node
    End Function

    Private Function GetCurrentUser() As CurrentUser
        '
        ' Ritorna l'utente corrente (senza il dominio) --> default "ANONINMO"
        '
        Dim sUserName As String = "ANONIMO"
        Dim user As CurrentUser

        If HttpContext.Current?.User?.Identity?.IsAuthenticated IsNot Nothing Then

            If HttpContext.Current.User.Identity.IsAuthenticated Then
                sUserName = HttpContext.Current.User.Identity.Name
            End If

        End If

        user.UserName = sUserName

        user.HostName = GetUserHostName()    'questa restituisce il nome e se non riesce l'indirizzo IP
        user.HostAddress = HttpContext.Current.Request.UserHostAddress

        Return user
    End Function

    Private Function GetUserHostName() As String
        Dim sHostName As String = Nothing
        Dim sessHostName As String = "-HOST_NAME-"
        '
        ' Controllo se l'host name è in sessione.
        ' Se non c'è ottengo l'host name con la funzione "_GetUserHostName()" e poi la salvo in sessione
        ' Altrimenti restituisco la variabile di sessione
        '
        If HttpContext.Current.Session(sessHostName) Is Nothing Then
            sHostName = _GetUserHostName()
            HttpContext.Current.Session(sessHostName) = sHostName
        Else
            sHostName = CType(HttpContext.Current.Session(sessHostName), String)
        End If
        Return sHostName

    End Function

    Private Function _GetUserHostName() As String
        Dim oNetIp As System.Net.IPHostEntry = Nothing
        Dim sRemoteAddr As String = HttpContext.Current.Request.ServerVariables("HTTP_X_FORWARDED_FOR")

        '
        ' Controllo se sRemoteAddr è vuota. Se è vuota allora uso la ServerVariabiles "remote_addr"
        '
        If String.IsNullOrEmpty(sRemoteAddr) Then
            sRemoteAddr = HttpContext.Current.Request.ServerVariables("remote_addr")
        End If

        Try
            oNetIp = System.Net.Dns.GetHostEntry(sRemoteAddr)
        Catch ex As Exception
            'Restituisco l'indirizzo IP
            Return sRemoteAddr
        End Try

        Dim sHostName As String = sRemoteAddr
        Try
            sHostName = oNetIp.HostName
        Catch ex As Exception
            'Se errore restituisco comunque indirizzo IP 
        End Try

        Return sHostName

    End Function

End Class
