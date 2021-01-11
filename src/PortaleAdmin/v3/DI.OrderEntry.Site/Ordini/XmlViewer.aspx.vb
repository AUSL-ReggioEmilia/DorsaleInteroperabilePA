Imports System
Imports System.Web.UI
Imports DI.Common
Imports DI.OrderEntry.Admin.Data.Ordini
Imports DI.OrderEntry.Admin.Data

Namespace DI.OrderEntry.Admin

    Public Class XmlViewer
        Inherits Page

        Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load

            Dim idString = Request("id")
            Dim id As Guid

            If String.IsNullOrEmpty(idString) OrElse Not Utility.TryParseStringToGuid(idString, id) Then
                Return
            End If

            Dim dataTable As New UiTrackingSelectDataTable()

            DataAdapterManager.Fill(dataTable, id)

            If dataTable.Count = 0 OrElse dataTable(0).IsMessaggioNull() OrElse dataTable(0).Messaggio.Length = 0 Then
                Return
            End If

            Response.ClearContent()
            Response.ClearHeaders()
            Response.ContentType = "application/xml"
            Response.Write(dataTable(0).Messaggio)
            Response.Flush()
            Response.Close()

            Me.Title = "Messaggio originale (id:" + idString + ")"
        End Sub

    End Class

End Namespace