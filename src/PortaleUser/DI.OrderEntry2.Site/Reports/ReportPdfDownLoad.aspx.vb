Imports System
Imports System.Web.UI
Imports System.Web

Namespace DI.OrderEntry.User

    Public Class ReportPdfDownLoad
        Inherits Page

        Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load

            Dim idOrdine = Request("idOrdine")

            Dim numeroOrdine As String = String.Empty

            Dim stato As DI.OrderEntry.Services.StatoType = ReportUtility.GetOrdine(idOrdine)

            If stato Is Nothing Then
                Response.Redirect(Request.UrlReferrer.ToString)
            End If

            numeroOrdine = stato.Ordine.IdRichiestaOrderEntry
            numeroOrdine = numeroOrdine.Replace("/", "-")

            Dim basePdfByte() As Byte = ReportUtility.GeneraReportOrdine(stato)
            Dim extension As String = "pdf"
            Response.Buffer = True
            Response.ContentType = "application/pdf"
            Response.Charset = ""

            Response.AddHeader("content-disposition", "attachment ; filename=" & numeroOrdine & "." + extension)
            'Response.AddHeader("content-disposition", "inline; filename=" & idOrdine & "." + extension)
            Response.AddHeader("content-length", basePdfByte.Length.ToString())
            Response.BinaryWrite(basePdfByte)
            Response.Flush()
            Response.End()
        End Sub

    End Class

End Namespace