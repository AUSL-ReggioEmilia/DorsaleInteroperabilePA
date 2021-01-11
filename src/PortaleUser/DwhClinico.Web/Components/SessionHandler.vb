''' <summary>
''' CLASSE PER LA GESTIONE DI TUTTE LE VARIABILI DI SESSIONE.
''' </summary>
''' 
Public Class SessionHandler

#Region "ConstAccessoStandard"
    Private Const KEY_HIDDEN_ALERT As String = "KEY_HIDDEN_ALERT"
    Private Const KEY_TOKEN As String = "TOKEN_WCF_DWH"
    Private Const KEY_IDPAZIENTE As String = "IDPAZIENTE_WCF_DWH"
    Private Const KEY_IDREFERTO As String = "IDREFERTO_WCF_DWH"
    Private Const KEY_CANCELLA_CACHE As String = "KEY_CANCELLA_CACHE"
    Private Const KEY_CONSENSO_INSERITO As String = "KEY_CONSENSO_INSERITO"
    Public Const SESS_MOTIVO_ACCESSO As String = "MotivoAccesso"
    Public Const SESS_MOTIVO_ACCESSO_NOTE As String = "MotivoAccessoNote"
    Private Const KEY_FSE_BACK_URL As String = "KEY_FSE_BACK_URL"
#End Region

#Region "ConstAccessoDiretto"
    Private Const KEY_ACCESSO_DIRETTO_VALIDA_SESSIONE As String = "ACCESSO_DIRETTO_VALIDA_SESSIONE"
    Private Const KEY_ACCESSO_DIRETTO_CANCELLA_CACHE As String = "KEY_ACCESSO_DIRETTO_CANCELLA_CACHE"
    Private Const KEY_ACCESSO_DIRETTO_CONSENSO_INSERITO As String = "KEY_ACCESSO_DIRETTO_CONSENSO_INSERITO"
    Private Const KEY_ACCESSODIRETTO_IDREFERTO As String = "KEY_ACCESSODIRETTO_IDREFERTO"
    Private Const KEY_ACCESSODIRETTO_URL_REFERTI As String = "ACCESSODIRETTO_URL_REFERTI"
    Private Const KEY_ACCESSODIRETTO_URL_PAZIENTI As String = "ACCESSODIRETTO_URL_PAZIENTI"
    Private Const KEY_ACCESSODIRETTO_SHOWHEADER As String = "ACCESSODIRETTO_SHOWHEADER"
    Private Const KEY_ACCESSODIRETTO_SHOWPANNELLOPAZIENTE As String = "ACCESSODIRETTO_SHOWPANNELLOPAZIENTE"
#End Region

#Region "PropertyAccessoStandard"
    ''' <summary>
    ''' PROPERTY CHE INDICA SE L'ALERT PRESENTE NELLA HOME PAGE( Default.aspx) E' GIA' STATO VISUALIZZATO.
    ''' </summary>
    ''' <returns></returns>
    Public Shared Property HideHomeAlert As Boolean
        Get
            Return CType(HttpContext.Current.Session(KEY_HIDDEN_ALERT), Boolean)
        End Get
        Set(value As Boolean)
            If String.IsNullOrEmpty(value) Then
                HttpContext.Current.Session.Remove(KEY_HIDDEN_ALERT)
            Else
                HttpContext.Current.Session(KEY_HIDDEN_ALERT) = value
            End If
        End Set
    End Property

    ''' <summary>
    ''' SALVA IN SESSSIONE IL TOKEN UTILIZZATO PER LE CHIAMATE AI WS3 DEL DWH.
    ''' </summary>
    ''' <returns></returns>
    Public Shared Property Token As WcfDwhClinico.TokenType
        Get
            Dim oData As Object = HttpContext.Current.Session.Item(KEY_TOKEN)
            If oData Is Nothing OrElse TypeOf oData IsNot WcfDwhClinico.TokenType Then
                Return Nothing
            Else
                Return CType(oData, WcfDwhClinico.TokenType)
            End If
        End Get
        Set(value As WcfDwhClinico.TokenType)
            '
            ' Vuota, salva in Sessione
            '
            If value Is Nothing Then
                HttpContext.Current.Session.Remove(KEY_TOKEN)
            Else
                HttpContext.Current.Session.Add(KEY_TOKEN, value)
            End If
        End Set

    End Property

    ''' <summary>
    ''' SALVA IN SESSIONE IL MOTIVO DI ACCESSO SELEZIONATO NELLA HOME PAGE.
    ''' </summary>
    ''' <returns></returns>
    Public Shared Property MotivoAccesso As ListItem
        Get
            Return CType(HttpContext.Current.Session(SESS_MOTIVO_ACCESSO), ListItem)
        End Get
        Set(value As ListItem)
            HttpContext.Current.Session(SESS_MOTIVO_ACCESSO) = value
        End Set
    End Property

    ''' <summary>
    ''' SALVA IN SESSIONE LE NOTE DEL MOTIVO DI ACCESSO.
    ''' </summary>
    ''' <returns></returns>
    Public Shared Property MotivoAccessoNote As String
        Get
            Return CType(HttpContext.Current.Session(SESS_MOTIVO_ACCESSO_NOTE), String)
        End Get
        Set(value As String)
            If String.IsNullOrEmpty(value) Then
                HttpContext.Current.Session.Remove(SESS_MOTIVO_ACCESSO_NOTE)
            Else
                HttpContext.Current.Session(SESS_MOTIVO_ACCESSO_NOTE) = value
            End If
        End Set
    End Property

    ''' <summary>
    ''' SALVA IN SESSIONE L'ID DEL REFERTO.
    ''' </summary>
    ''' <returns></returns>
    Public Shared Property IdReferto As String
        Get
            Dim sIdReferto As String = CType(HttpContext.Current.Session.Item(KEY_IDREFERTO), String)
            If String.IsNullOrEmpty(sIdReferto) Then
                Return Nothing
            Else
                Return sIdReferto
            End If
        End Get
        Set(value As String)
            If String.IsNullOrEmpty(value) Then
                HttpContext.Current.Items.Remove(KEY_IDREFERTO)
            Else
                HttpContext.Current.Session.Add(KEY_IDREFERTO, value)
            End If
        End Set
    End Property

    ''' <summary>
    ''' SALVO IN SESSIONE L'URL ALLA LISTA DEI REFERTI.
    ''' </summary>
    ''' <returns></returns>
    Public Shared Property ListaRefertiUrl As String
        '
        ' Salvo l'url della pagina dei referti per valorizzare il link del bottone che naviga dalla pagina RefertiDettaglio.aspx alla pagina RefertiListaPaziente.aspx
        '
        Get
            Return CType(HttpContext.Current.Session.Item("ListaRefertiUrl"), String)
        End Get
        Set(value As String)
            HttpContext.Current.Session.Item("ListaRefertiUrl") = value
        End Set
    End Property

    Public Shared Property CancellaCache As Boolean
        Get
            Return CType(HttpContext.Current.Session.Item(KEY_CANCELLA_CACHE), Boolean)

        End Get
        Set(value As Boolean)
            If String.IsNullOrEmpty(value) Then
                HttpContext.Current.Session.Remove(KEY_CANCELLA_CACHE)
            Else
                HttpContext.Current.Session.Add(KEY_CANCELLA_CACHE, value)
            End If
        End Set
    End Property

    Public Shared Property ConsensoInserito As Boolean
        '
        ' Variabile per memorizzare se ho già inserito il consenso per evitare di acquisire più volte il consenso nel caso si navighi con la history 
        '
        Get
            Return CType(HttpContext.Current.Session.Item(KEY_CONSENSO_INSERITO), Boolean)
        End Get
        Set(value As Boolean)
            HttpContext.Current.Session.Add(KEY_CONSENSO_INSERITO, value)
        End Set
    End Property

    Public Shared Property ValidaSessioneAccessoStandard() As Nullable(Of Boolean)
        Get
            Return CType(HttpContext.Current.Session.Item("IsSessioneAttiva"), Nullable(Of Boolean))
        End Get
        Set(ByVal value As Nullable(Of Boolean))
            HttpContext.Current.Session.Item("IsSessioneAttiva") = value
        End Set
    End Property
#End Region

#Region "Accesso Diretto"

    Public Shared Property AccessoDirettoUrlPazienti As String
        Get
            Return CType(HttpContext.Current.Session.Item(KEY_ACCESSODIRETTO_URL_PAZIENTI), String)
        End Get
        Set(value As String)
            HttpContext.Current.Session.Item(KEY_ACCESSODIRETTO_URL_PAZIENTI) = value
        End Set
    End Property

    Public Shared Property AccessoDirettoUrlReferti As String
        Get
            Return CType(HttpContext.Current.Session.Item(KEY_ACCESSODIRETTO_URL_REFERTI), String)
        End Get
        Set(value As String)
            HttpContext.Current.Session.Item(KEY_ACCESSODIRETTO_URL_REFERTI) = value
        End Set
    End Property

    Public Shared Property ValidaSessioneAccessoDiretto As Boolean
        '
        ' Viene utilizzato nell'AccessoDiretto per verificare la validità della sessione
        '
        Get
            Return CType(HttpContext.Current.Session.Item(KEY_ACCESSO_DIRETTO_VALIDA_SESSIONE), Boolean)
        End Get
        Set(value As Boolean)
            HttpContext.Current.Session.Item(KEY_ACCESSO_DIRETTO_VALIDA_SESSIONE) = value
        End Set
    End Property

    Public Shared Property AccessoDirettoListaRefertiUrl As String
        '
        ' Salvo l'url della pagina dei referti per valorizzare il link del bottone che naviga dalla pagina Referto.aspx alla pagina Referti.aspx
        '
        Get
            Return CType(HttpContext.Current.Session.Item("AccessoDirettoListaRefertiUrl"), String)
        End Get
        Set(value As String)
            HttpContext.Current.Session.Item("AccessoDirettoListaRefertiUrl") = value
        End Set
    End Property

    Public Shared Property AccessoDirettoRefertoUrl As String
        '
        ' Salvo l'url della pagina dei referti per valorizzare il link del bottone che naviga dalla pagina RefertiAllegati.aspx alla pagina Referto.aspx
        '
        Get
            Return CType(HttpContext.Current.Session.Item("AccessoDirettoRefertoUrl"), String)
        End Get
        Set(value As String)
            HttpContext.Current.Session.Item("AccessoDirettoRefertoUrl") = value
        End Set
    End Property

    Public Shared Sub InvalidaCacheTestataPaziente(idPaziente As Guid)
        '
        ' Invalida la cache dell'ObjectDataSource usato per la creazione della testata del paziente
        '
        Dim dsTestataPaziente As New CustomDataSource.PazienteOttieniPerId
        dsTestataPaziente.ClearCache(idPaziente)
        '
        ' Resetto i dati in sessione del dettaglio paziente SAC
        '
        SacDettaglioPaziente.Session(idPaziente) = Nothing
    End Sub

    Public Shared Property AccessoDirettoCancellaCache As Boolean
        Get
            Dim sIdPaziente As Boolean = CType(HttpContext.Current.Session.Item(KEY_ACCESSO_DIRETTO_CANCELLA_CACHE), Boolean)

            Return sIdPaziente
        End Get
        Set(value As Boolean)
            If String.IsNullOrEmpty(value) Then
                HttpContext.Current.Items.Remove(KEY_ACCESSO_DIRETTO_CANCELLA_CACHE)
            Else
                HttpContext.Current.Session.Add(KEY_ACCESSO_DIRETTO_CANCELLA_CACHE, value)
            End If
        End Set
    End Property

    Public Shared Property AccessoDirettoConsensoInserito As Boolean
        '
        ' Variabile per memorizzare se ho già inserito il consenso per evitare di acquisire più volte il consenso nel caso si navighi con la history 
        '
        Get
            Return CType(HttpContext.Current.Session.Item(KEY_ACCESSO_DIRETTO_CONSENSO_INSERITO), Boolean)
        End Get
        Set(value As Boolean)
            HttpContext.Current.Session.Add(KEY_ACCESSO_DIRETTO_CONSENSO_INSERITO, value)
        End Set
    End Property

    ''' <summary>
    ''' PROPERTY CHE INDICA SE L'HEADER DELLA MASTERPAGE(AccessoDiretto.master) DEBBA ESSERE NASCOSTO O NO.
    ''' </summary>
    ''' <returns></returns>
    Public Shared Property ShowHeader As Boolean
        Get
            Dim ret As Boolean = True
            If Not String.IsNullOrEmpty(HttpContext.Current.Session(KEY_ACCESSODIRETTO_SHOWHEADER)) Then
                ret = CType(HttpContext.Current.Session(KEY_ACCESSODIRETTO_SHOWHEADER), Boolean)
            End If
            Return ret
        End Get
        Set(value As Boolean)
            If String.IsNullOrEmpty(value) Then
                HttpContext.Current.Session.Remove(KEY_ACCESSODIRETTO_SHOWHEADER)
            Else
                HttpContext.Current.Session(KEY_ACCESSODIRETTO_SHOWHEADER) = value
            End If
        End Set
    End Property

    ''' <summary>
    ''' PROPERTY CHE INDICA SE USERPANEL DELLA MASTERPAGE(AccessoDiretto.master) DEBBA ESSERE NASCOSTO O NO.
    ''' </summary>
    ''' <returns></returns>
    Public Shared Property ShowPannelloPaziente As Boolean
        Get
            Dim ret As Boolean = True
            If Not String.IsNullOrEmpty(HttpContext.Current.Session(KEY_ACCESSODIRETTO_SHOWPANNELLOPAZIENTE)) Then
                ret = CType(HttpContext.Current.Session(KEY_ACCESSODIRETTO_SHOWPANNELLOPAZIENTE), Boolean)
            End If
            Return ret
        End Get
        Set(value As Boolean)
            If String.IsNullOrEmpty(value) Then
                HttpContext.Current.Session.Remove(KEY_ACCESSODIRETTO_SHOWPANNELLOPAZIENTE)
            Else
                HttpContext.Current.Session(KEY_ACCESSODIRETTO_SHOWPANNELLOPAZIENTE) = value
            End If
        End Set
    End Property

#End Region

End Class
