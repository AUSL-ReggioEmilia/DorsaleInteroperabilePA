Imports DwhClinico.Data
Public Class ApreDocumento
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Dim sContestoApplicativo As String = String.Empty
        Dim sCodiceFiscaleMedico As String = String.Empty
        Dim sCodiceFiscalePaziente As String = String.Empty
        Dim sCodiceDocumento As String = String.Empty
        Try
            sContestoApplicativo = Request.QueryString("ContestoApplicativo")
            sCodiceFiscaleMedico = Request.QueryString("CodiceFiscaleMedico")
            sCodiceFiscalePaziente = Request.QueryString("CodiceFiscalePaziente")
            sCodiceDocumento = Request.QueryString("CodiceDocumento")

            If String.IsNullOrEmpty(sCodiceDocumento) OrElse String.IsNullOrEmpty(sCodiceFiscaleMedico) OrElse String.IsNullOrEmpty(sCodiceFiscalePaziente) OrElse String.IsNullOrEmpty(sContestoApplicativo) Then
                Response.Write("I parametri 'ContestoApplicativo', CodiceFiscaleMedico', CodiceFiscalePaziente' e 'CodiceDocumento' sono obbligatori.")
                Exit Sub
            End If

            '
            'Apro il documento ottenendo il pdf dalla function GetDocumento di FSE
            '
            Dim oFse As New FSE.FseDocumentoOttieni
            Dim oDocumento As FSENamespace.Models.Documento = oFse.GetDocumento(sCodiceDocumento, sContestoApplicativo, sCodiceFiscalePaziente, sCodiceFiscaleMedico)

            If Not oDocumento Is Nothing AndAlso Not oDocumento.Contenuto Is Nothing AndAlso oDocumento.Contenuto.Length > 0 Then

                ' Toglie directory dal nome
                '
                Dim oFileInfo As System.IO.FileInfo
                oFileInfo = New System.IO.FileInfo(sCodiceDocumento)
                Dim sFileName As String = oFileInfo.Name()
                '
                ' Scrivo il contenuto binario
                '
                Response.Expires = 0
                Response.Clear()
                Response.BufferOutput = True
                Response.ContentType = oDocumento.MimeType
                Response.AddHeader("content-disposition", "inline; filename=" & sFileName)
                Response.BinaryWrite(oDocumento.Contenuto)
            End If

        Catch ex As Exception
            Call Response.Write(FormatError("Si è verificato un errore durante la visualizzazione del documento."))
            Logging.WriteError(ex, Me.GetType.Name)
        End Try
    End Sub

    Private Function FormatError(ByVal sMsg As String) As String
        Return String.Format("<div style=""color: red; font-weight: bold; font-size: 11px; font-family: verdana, helvetica, arial, sans-serif;"">{0}</div>", sMsg)
    End Function
End Class