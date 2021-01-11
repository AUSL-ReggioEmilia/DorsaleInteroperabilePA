Imports System.Web
Imports System.Web.Services
Imports System.Web.SessionState

Public Class Redirector
	Implements System.Web.IHttpHandler, IRequiresSessionState

	''' <summary>
	''' Url usato come fallback in caso di errore o indirizzo di redirezione assente
	''' </summary>
	Public Shared Property FallbackUrl As String = "~"

	Public Class Target_Type
		Friend Const SessionKey As String = "Redirector_Target"

		Public Sub New()

		End Sub

		''' <summary>
		''' Imposta l'indirizzo di destinazione della redirezione
		''' </summary>
		Public Sub New(Url As String, ForceRefresh As Boolean)
			Me.Url = Url
			Me.ForceRefresh = ForceRefresh
		End Sub

		''' <summary>
		''' Indirizzo di redirezione
		''' </summary>
		Public Property Url As String = ""

		''' <summary>
		''' Forzare il refresh dei dati
		''' </summary>
		Public Property ForceRefresh As Boolean = False

		''' <summary>
		''' La pagina è stata caricata da una redirezione
		''' </summary>
		Public Property Redirected As Boolean = False

	End Class


	Public Shared Property Target As Target_Type
		Get
			Dim oObj = HttpContext.Current.Session(Target_Type.SessionKey)
			If TypeOf oObj Is Target_Type Then
				Return DirectCast(oObj, Target_Type)
			Else
				Return Nothing
			End If
		End Get
		Set(value As Target_Type)
			HttpContext.Current.Session(Target_Type.SessionKey) = value
		End Set
	End Property


	Public Shared Sub SetTarget(Url As String, ForceRefresh As Boolean)
		Target = New Target_Type(Url, ForceRefresh)
	End Sub

	Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest

		Try
			Dim oObj = HttpContext.Current.Session(Target_Type.SessionKey)
			'SetTarget(Nothing)

			If Not TypeOf oObj Is Target_Type Then RedirectToFallbackUrl(context)

			Dim oTarget As Target_Type = DirectCast(oObj, Target_Type)
			If String.IsNullOrEmpty(oTarget.Url) Then RedirectToFallbackUrl(context)

			oTarget.Redirected = True
			Redirector.Target = oTarget

			context.Response.Redirect(oTarget.Url, False)
			context.ApplicationInstance.CompleteRequest()


		Catch ex As Exception
			Utility.TraceWriteLine("Exception in Redirector.ashx\ProcessRequest : " & ex.Message)
			'redirect alla home
			RedirectToFallbackUrl(context)
		End Try

	End Sub

	''' <summary>
	''' Controlla se l'url passato è il target della redirezione impostata, inoltre setta l'oggetto Target in uscita
	''' </summary>
	Public Shared Function IsRedirectTarget(Url As String) As Boolean

		Dim mTarget As Target_Type = Redirector.Target
		If mTarget Is Nothing Then Return False
		If String.IsNullOrEmpty(mTarget.Url) Then Return False

		Return (String.Compare(mTarget.Url, Url, True) = 0)

	End Function



	Private Sub RedirectToFallbackUrl(ByVal context As HttpContext)

		'pulisco il target visto che c'è stato un errore
		Target = Nothing
		context.Response.Redirect(FallbackUrl, False)
		context.ApplicationInstance.CompleteRequest()

	End Sub


	ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
		Get
			Return False
		End Get
	End Property

End Class