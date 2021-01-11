Imports System
Imports System.IO
Imports System.Text
Imports System.Web
Imports System.Xml

Public Class Download
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Dim bInLine As Boolean = False

        If Request.QueryString("M") = "VIEW" Then
            bInLine = True
        End If

        Using ta As New LogModificheTableAdapters.LogModificheCercaTableAdapter
            Dim odt As LogModifiche.LogModificheCercaDataTable = ta.GetDataBy(Request.QueryString("ID"))
            If odt IsNot Nothing AndAlso odt.Rows.Count > 0 Then
                Dim orow As LogModifiche.LogModificheCercaRow = odt.Rows(0)
                If Not orow Is Nothing Then
                    Dim xmlDoc As New Xml.XmlDocument
                    xmlDoc.LoadXml(orow.XmlModifica)
                    Dim arrayBytes As Byte() = Text.Encoding.Default.GetBytes(xmlDoc.OuterXml)

                    ResponseWrite_File("text/xml", "Dettaglio.xml", arrayBytes, bInLine)
                End If
            End If
        End Using
    End Sub

    Private Sub ResponseWrite_File(ContentType As String, FileName As String, barrFile As Byte(), InLine As Boolean)

        Response.Clear()
        Response.ClearContent()
        Response.ClearHeaders()
        Response.Charset = ""

        'HttpCacheability 
        ' Public: per specificare che la risposta può essere memorizzata nella cache 
        '         dai client e non da cache condivise (server proxy).
        'Response.Cache.SetCacheability(HttpCacheability.Public)
        'Response.Cache.SetExpires(DateTime.Now.AddHours(1))

        Response.Cache.SetCacheability(HttpCacheability.NoCache)
        Response.Cache.SetExpires(DateTime.Now)

        ' Stop Caching in Firefox
        Response.Cache.SetNoStore()

        Response.BufferOutput = True
        Response.ContentType = ContentType
        If InLine Then
            Response.AddHeader("content-disposition", "inline; filename=" & FileName)
        Else
            Response.AddHeader("content-disposition", "attachment; filename=" & FileName)
        End If
        Response.AddHeader("Content-Length", barrFile.Length.ToString())
        Response.AddHeader("Content-Description", FileName)
        Response.ContentEncoding = System.Text.Encoding.UTF8
        Response.BinaryWrite(barrFile)
        Response.Flush()
        Response.End()

    End Sub

End Class