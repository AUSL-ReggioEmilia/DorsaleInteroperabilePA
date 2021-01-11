Module Utility
    Public Const ATTRIB_CONSENSO_GENERICO_MODIFY = "ATTRIB@CONSENSO_GENERICO_MODIFY" 'Permette la gestione anche del consenso generico

    Public Const sess_dati_ultimo_accesso As String = "sess_dati_ultimo_accesso"
    Public Const sess_user_name As String = "sess_user_name"
    Public Const sess_write_dati_accesso As String = "sess_write_dati_accesso"
    Public Const sess_ricerca_avanzata As String = "sess_ricerca_avanzata"

    Private Const SESS_HOST_NAME As String = "-HOST_NAME-"

    Public Function GetAssemblyVersion() As String
        '
        ' Legge versione della DLL
        '
        Try
            Return String.Format("Ver: {0}", System.Reflection.Assembly.GetExecutingAssembly.GetName.Version.ToString())
        Catch
            Return String.Empty
        End Try
    End Function

    Public Function GetUserHostName() As String
        Dim sHostName As String = Nothing

        '
        ' Controllo se l'host name è in sessione.
        ' Se non c'è ottengo l'host name con la funzione "_GetUserHostName()" e poi la salvo in sessione
        ' Altrimenti restituisco la variabile di sessione
        '
        If HttpContext.Current.Session(SESS_HOST_NAME) Is Nothing Then
            sHostName = _GetUserHostName()
            HttpContext.Current.Session(SESS_HOST_NAME) = sHostName
        Else
            sHostName = CType(HttpContext.Current.Session(SESS_HOST_NAME), String)
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

    ''' <summary>
    ''' Funzione per navigare alla pagina di errore
    ''' </summary>
    Public Sub NavigateToErrorPage(errorCode As ErrorPage.ErrorCode, description As String, endResponse As Boolean)
        Try
            Dim absoluteUri As String = HttpContext.Current.Request.Url.AbsoluteUri.ToString().ToLower()
            If (Not absoluteUri.Contains("errorpage")) Then
                ErrorPage.SetErrorDescription(errorCode, description)
                HttpContext.Current.Response.Redirect("~/ErrorPage.aspx", endResponse)
            End If
        Catch ex As Exception
            GestioneErrori.TrapError(ex)
            Throw
        End Try
    End Sub


    ''' <summary>
    ''' Restituisce l'url relativo all'application. Utile per trovare l'URL relativo a folder e pagine
    ''' </summary>
    Public Function GetApplicationPath() As String
        Return HttpContext.Current.Request.ApplicationPath.TrimEnd("/") & "/"
    End Function

#Region "Gestione Errori"

    ''' <summary>
    ''' Gestisce gli errori del ObjectDataSource in maniera pulita
    ''' </summary>
    ''' <returns>True se si è verificato un errore</returns>
    Public Function ObjectDataSource_TrapError(e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs, MasterPage As Site) As Boolean
        Try
            If e.Exception IsNot Nothing AndAlso e.Exception.InnerException IsNot Nothing Then
                MasterPage.ShowErrorLabel(GestioneErrori.TrapError(e.Exception.InnerException))
                e.ExceptionHandled = True
                Return True
            Else
                Return False
            End If
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            MasterPage.ShowErrorLabel(sErrorMessage)
            Return True
        End Try

    End Function

#End Region


    ''' <summary>
    ''' Se l'oggetto è Nothing restituisce NullString
    ''' </summary>
    <System.Runtime.CompilerServices.Extension()>
    Public Function NullSafeToString(Of T)(this As T, Optional NullString As String = "") As String
        If this Is Nothing Then
            Return NullString
        End If
        Return this.ToString()
    End Function


    ''' <summary>
    ''' Ritorna DefaultValue se Value è NULL, altrimenti Value
    ''' </summary>
    Public Function IsNull(Of T)(ByVal Value As T, ByVal DefaultValue As T) As T
        If Value Is Nothing OrElse Convert.IsDBNull(Value) Then
            Return DefaultValue
        Else
            Return Value
        End If
    End Function


    ''' <summary>
    ''' Calcolo dell'età partendo dalla Data di Nascita fino a una Data di Riferimento
    ''' </summary>
    Public Function CalcolaEtà(DataNascita As Date, DataRiferimento As Date) As Integer
        Dim Età As Integer = DataRiferimento.Year - DataNascita.Year
        If DataNascita > DataRiferimento.AddYears(-Età) Then
            Età -= 1
        End If
        Return Età
    End Function


End Module
