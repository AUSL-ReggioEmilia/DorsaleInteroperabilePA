Imports System

Public Class DownloadNotaAnamnesticaContenuto
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Try
            Dim idNota As String = Request.QueryString(DI.DataWarehouse.Admin.Constants.PAR_ID_NOTA_ANAMNESTICA)
            If Not String.IsNullOrEmpty(idNota) Then

                Dim dt As NoteAnamnesticheDataSet.NotaAnamnesticaOttieniDataTable = Nothing
                Dim oRow As NoteAnamnesticheDataSet.NotaAnamnesticaOttieniRow = Nothing

                Using ta As New NoteAnamnesticheDataSetTableAdapters.NotaAnamnesticaOttieniTableAdapter
                    dt = ta.GetData(New Guid(idNota))
                    If Not dt Is Nothing AndAlso dt.Rows.Count > 0 Then
                        oRow = dt.Rows(0)
                    End If
                End Using

                If Not oRow Is Nothing Then
                    '
                    ' Determino l'estensione del file in base al mime/type (TipoContenuto)
                    '
                    Dim sFileExtension As String = String.Empty
                    Dim sTipoContenuto As String = oRow.TipoContenuto.ToUpper
                    Select Case sTipoContenuto
                        Case "TEXT/PLAIN"
                            sFileExtension = "txt"
                        Case "TEXT/RTF"
                            sFileExtension = "rtf"
                        Case "TEXT/HTML"
                            sFileExtension = "html"
                        Case Else
                            sFileExtension = String.Empty
                    End Select
                    ' Toglie directory dal nome
                    '
                    Dim oFileInfo As System.IO.FileInfo
                    oFileInfo = New System.IO.FileInfo(String.Concat("NotaAnamnestica_", oRow.Id.ToString, ".", sFileExtension))
                    Dim sFileName As String = oFileInfo.Name()

                        '
                        ' Scrivo il contenuto binario
                        '
                        Response.Expires = 0
                        Response.Clear()
                        Response.BufferOutput = True
                        Response.ContentType = oRow.TipoContenuto
                        Response.AddHeader("content-disposition", "attachment; filename=" & sFileName)
                        Response.BinaryWrite(oRow.Contenuto)
                    End If
                End If
        Catch ex As Exception
            Call Response.Write(FormatError(ex.Message))
            Utility.TrapError(ex, True)
        End Try
    End Sub

    Private Function FormatError(ByVal sMsg As String) As String
        Return String.Format("<div style=""color: red; font-weight: bold; font-size: 11px; font-family: verdana, helvetica, arial, sans-serif;"">{0}</div>", sMsg)
    End Function
End Class