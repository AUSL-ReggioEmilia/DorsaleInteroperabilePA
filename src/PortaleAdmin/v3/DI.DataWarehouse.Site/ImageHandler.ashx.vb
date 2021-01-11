Imports System.Web

Namespace DI.DataWarehouse.Admin

	''' <summary>
	''' Questo HTTP Handler fa da tramite per leggere un'immagine salvata su DB, l'immagine restituita viene scritta nella response 
	''' nel context corrente 
	''' </summary>
	Public Class ImageHandler
		Implements System.Web.IHttpHandler

		Private Sub IHttpHandler_ProcessRequest(context As HttpContext) Implements IHttpHandler.ProcessRequest

			Dim resourcetype As String = context.Request.QueryString("resourcetype")
			Dim id As String = context.Request.QueryString("id")

			If resourcetype IsNot Nothing And id IsNot Nothing Then

				Dim file As Byte() = Nothing

				Select Case resourcetype.ToLower
					Case "tiporeferto"
						context.Response.ContentType = "image/png"
						file = TipiRefertoDettaglio.GetImageFromDB(id)
				End Select

				If file Is Nothing Then
					ImageNotFound(context)
				Else
					context.Response.Buffer = True
					context.Response.BinaryWrite(file)
				End If

			End If
		End Sub

		Private Sub ImageNotFound(context As HttpContext)
			'Dim img = System.Drawing.Image.FromFile("~\Images\ImageNotFound.png")
			'Dim str As MemoryStream = New MemoryStream()

			context.Response.Redirect("~/Images/ImageNotFound.png")

		End Sub
		ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
			Get
				Return False
			End Get
		End Property


	End Class

End Namespace

