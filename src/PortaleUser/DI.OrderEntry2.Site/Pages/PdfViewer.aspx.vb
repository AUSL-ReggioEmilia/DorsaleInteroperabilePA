Imports System
Imports System.Web.UI
Imports System.Web

Namespace DI.OrderEntry.User

    Public Class PdfViewer
        Inherits Page

        Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load

            Dim hash = Request("id")
            Dim base64 = Cache(hash)
            Dim base64Byte() As Byte = Convert.FromBase64String(base64)

            Response.Buffer = True
            Response.ContentType = "application/pdf"
            Response.Charset = ""

            Response.AddHeader("content-disposition", "inline; filename=etichetta.pdf")
            Response.AddHeader("content-length", base64Byte.Length.ToString())
            Response.BinaryWrite(base64Byte)
            Response.Flush()
            Response.End()
        End Sub

    End Class

End Namespace