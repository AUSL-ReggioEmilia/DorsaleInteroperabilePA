Public Class SessionHandler
	Private Const KEY_TOKEN As String = "TOKEN_WCF_DWH"
	Private Const KEY_TOKEN_PER_BYPASS_OSCURAMENTI As String = "TOKEN_WCF_DWH_PER_BYPASS_CONSENSO"
	Private Const KEY_UNITA_OPERATIVE_ASSENTE As String = "KEY_UNITA_OPERATIVE_ASSENTE"
	Private Const KEY_FROM_STAMPA_ORDINE As String = "KEY_FROM_STAMPA_ORDINE"
	Private Const KEY_UNITAOPERATIVA As String = "KEY_UNITAOPERATIVA"
	Private Const KEY_TIPORICOVERO As String = "KEY_TIPORICOVERO"
	Private Const KEY_STATOEPISODIO As String = "KEY_STATOEPISODIO"
	Private Const KEY_ENTRYPOINTACCESSODIRETTO As String = "KEY_ENTRYPOINTACCESSODIRETTO"
    Private Const KEY_ACCESSODIRETTO_SHOWHEADER As String = "ACCESSODIRETTO_SHOWHEADER"
    Private Const KEY_ACCESSODIRETTO_SHOWPANNELLOPAZIENTE As String = "ACCESSODIRETTO_SHOWPANNELLOPAZIENTE"


#Region "TOKENS"
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
	''' Property che salva in sessione il token per il by pass degli oscuramenti
	''' </summary>
	''' <returns></returns>
	Public Shared Property TokenPerByPassOscuramenti As WcfDwhClinico.TokenType
		Get
			Dim oData As Object = HttpContext.Current.Session.Item(KEY_TOKEN_PER_BYPASS_OSCURAMENTI)
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
				HttpContext.Current.Session.Remove(KEY_TOKEN_PER_BYPASS_OSCURAMENTI)
			Else
				HttpContext.Current.Session.Add(KEY_TOKEN_PER_BYPASS_OSCURAMENTI, value)
			End If
		End Set
	End Property

#End Region

#Region "AccessoDiretto"
	Public Shared Property EntryPointAccessoDiretto As String
		Get
			Return CType(HttpContext.Current.Session.Item(KEY_ENTRYPOINTACCESSODIRETTO), String)
		End Get
		Set(value As String)
			HttpContext.Current.Session.Add(KEY_ENTRYPOINTACCESSODIRETTO, value)
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

    '10/12/19 Kyrylo: Controllo la presenza del parametro ShowPannelloPaziente nell'URL per gestirne la visualizzazione
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

#Region "AccessoStandard"

    Public Shared Property UnitàOperativeAssenti As Boolean
		Get
			Return CType(HttpContext.Current.Session.Item(KEY_UNITA_OPERATIVE_ASSENTE), Boolean)
		End Get
		Set(value As Boolean)
			HttpContext.Current.Session.Add(KEY_UNITA_OPERATIVE_ASSENTE, value)
		End Set
	End Property




	'
	'Indica che sono stato nella pagina di stampa dell'ordine a seguito del click sul bottone "inoltra e stampa ordine" nella pagina di conferma inoltro.
	'Questo per evitare che venga eseguito un redirect alla pagina di conferma inoltro quando torno indietro dalla pagina di stampa dell'ordine
	'( avviene perchè nel codice viene salvata la pagina precedente e viene eseguito un redirect; ma tornando "indietro" alla pagina di conferma dell'ordine vengono generati errori lato client)
	'
	Public Shared Property FromStampaOrdine As Boolean
		Get
			Return CType(HttpContext.Current.Session.Item(KEY_FROM_STAMPA_ORDINE), Boolean)
		End Get
		Set(value As Boolean)
			HttpContext.Current.Session.Add(KEY_FROM_STAMPA_ORDINE, value)
		End Set
	End Property

#End Region

End Class
