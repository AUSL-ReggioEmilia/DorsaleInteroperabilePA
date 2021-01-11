Imports System
Imports System.Web.UI
Imports System.Web

Namespace DI.OrderEntry.User

    Public Class ReportPdfViewer
        Inherits Page

        Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load

            Dim idOrdine = Request.QueryString("idOrdine")


            If Not String.IsNullOrEmpty(idOrdine) Then
                Dim stato As DI.OrderEntry.Services.StatoType = ReportUtility.GetOrdine(idOrdine)

                If stato IsNot Nothing Then
                    'Response.Redirect(Request.UrlReferrer.ToString)


                    Dim basePdfByte() As Byte = ReportUtility.GeneraReportOrdine(stato)


                    If basePdfByte IsNot Nothing Then
                        Dim extension As String = "pdf"
                        Response.Buffer = True
                        Response.ContentType = "application/pdf"
                        Response.Charset = ""

                        'Response.AddHeader("content-disposition", "attachment ; filename=" & idOrdine & "." + extension)
                        Response.AddHeader("content-disposition", "inline; filename=" & idOrdine & "." + extension)
                        Response.AddHeader("content-length", basePdfByte.Length.ToString())
                        Response.BinaryWrite(basePdfByte)
                        Response.Flush()
                        Response.End()
                    Else
                        lblTest.Text = "Pdf non valorizzato"
                    End If
                Else
                    lblTest.Text = "Stato Ordine non valorizzato"
                End If
            Else
                lblTest.Text = "Id Ordine non valorizzato"
            End If
        End Sub

    End Class

End Namespace