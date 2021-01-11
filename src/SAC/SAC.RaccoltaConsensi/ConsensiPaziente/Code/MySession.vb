''' <summary>
''' Gestione delle variabili di sessione
''' </summary>
Module MySession

	Private Const KEY_ISACCESSODIRETTO = "ISACCESSODIRETTO"
	Private Const KEY_CONSENSIURL = "KEY_CONSENSIURL"

	' attributi attualmente presenti su DB (per il minore)
	Private Const KEY_PREF_ATTRIB_DB = "ATTRIB_DB_"
	'attributi inseriti dall'utente nella pagina DatiTutore.aspx
	Private Const KEY_PREF_ATTRIB_INSERITI = "ATTRIB_INS_"
	Private Const KEY_DETTAGLIO_UTENTE = "KEY_DETTAGLIO_UTENTE"
    Private Const KEY_NEGA_CONSENSO = "KEY_NEGA_CONSENSO"

    ''' <summary>
    ''' True se l'applicazione è stata invocata tramite parametri IDPAziente o Codice Fiscale
    ''' </summary>
    Public Property IsAccessoDiretto() As Boolean
		Get
			Return HttpContext.Current.Session(KEY_ISACCESSODIRETTO)
		End Get
		Set(ByVal value As Boolean)
			HttpContext.Current.Session(KEY_ISACCESSODIRETTO) = value
		End Set
	End Property

	Public Property ConsensiUrl() As String
		Get
			Return HttpContext.Current.Session(KEY_CONSENSIURL)
		End Get
		Set(ByVal value As String)
			HttpContext.Current.Session(KEY_CONSENSIURL) = value
		End Set
	End Property

	Public Property PazienteAttributiDB(IdPaziente As String) As Object
		Get
			Return HttpContext.Current.Session(KEY_PREF_ATTRIB_DB & IdPaziente)
		End Get
		Set(ByVal value As Object)
			HttpContext.Current.Session(KEY_PREF_ATTRIB_DB & IdPaziente) = value
		End Set
	End Property

	Public Property PazienteAttributiInseriti(IdPaziente As String) As Object
		Get
			Return HttpContext.Current.Session(KEY_PREF_ATTRIB_INSERITI & IdPaziente)
		End Get
		Set(ByVal value As Object)
			HttpContext.Current.Session(KEY_PREF_ATTRIB_INSERITI & IdPaziente) = value
		End Set
	End Property

	Public Property DettaglioUtente() As Object
		Get
			Return HttpContext.Current.Session(KEY_DETTAGLIO_UTENTE)
		End Get
		Set(ByVal value As Object)
			HttpContext.Current.Session(KEY_DETTAGLIO_UTENTE) = value
		End Set
	End Property


    Public Property InserimentoConsensoNegato As Boolean?
        Get
            If HttpContext.Current.Session(KEY_NEGA_CONSENSO) Is Nothing Then
                Dim bValue As Boolean?
                Return bValue
            End If
            Return CType(HttpContext.Current.Session(KEY_NEGA_CONSENSO), Boolean)
        End Get
        Set(value As Boolean?)
            HttpContext.Current.Session(KEY_NEGA_CONSENSO) = value
        End Set
    End Property
End Module
