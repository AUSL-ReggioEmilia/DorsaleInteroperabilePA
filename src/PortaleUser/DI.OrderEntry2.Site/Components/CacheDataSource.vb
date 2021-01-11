Imports System.ComponentModel
Imports System.Web.Caching
Public Class CacheDataSource(Of T)
	Public Sub New()

        'Modifica Leo 2019/12/10: Controllo e correzione Cache su etichette
        'Durata della cache in secondi!
        CacheDuration = 300
        CacheDataKey = OriginalCacheDatakey

	End Sub

	Public ReadOnly Property OriginalCacheDatakey As String
		Get
            '
            ' Per costruire la key sfrutto anche l'HashCode dell'Url.
            '
            Dim sPath As String = HttpContext.Current.Request.Url.GetHashCode.ToString

            Return String.Format("{0}_{1}_{2}", HttpContext.Current.User.Identity.Name,
											sPath.ToUpper,
										   GetType(T).Name)
		End Get
	End Property

    Public Overridable Property CacheDuration As Integer
    Public Property CacheDataKey As String

    Public Sub ClearCache()
		'
		' Vuota la cache
		'
		Me.CacheData = Nothing

	End Sub

	Public Property CacheData As T
		Get
			Dim oData As Object = HttpContext.Current.Cache.Item(CacheDataKey)
			If oData IsNot Nothing Then
				'
				' Cast as T
				'
				If TypeOf oData Is T Then
					Return CType(oData, T)
				Else
					Return Nothing
				End If
			Else
				Return Nothing
			End If

		End Get
		Set(value As T)
			'
			' Vuota, salva in cache
			'
			If value Is Nothing Then
				HttpContext.Current.Cache.Remove(CacheDataKey)
			Else
                HttpContext.Current.Cache.Insert(CacheDataKey, value, Nothing,
                                             DateTime.UtcNow.AddSeconds(CacheDuration),
                                             Cache.NoSlidingExpiration)
            End If
		End Set

	End Property


End Class