Imports DwhClinico.Data

Public Class DocumentoViewer
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Try
            Dim sCodiceFiscalePaziente As String = Me.Request.QueryString("CodiceFiscalePaziente")
            Dim sCodiceFiscaleMedico As String = Me.Request.QueryString("CodiceFiscaleMedico")
            Dim sTipoAccesso As String = Me.Request.QueryString("TipoAccesso")
            Dim sCodiceDocumento As String = Me.Request.QueryString("CodiceDocumento")
            Dim sTipoDocumento As String = Me.Request.QueryString("TipoDocumento")
            Dim sNaturaDocumento As String = Me.Request.QueryString("NaturaDocumento")

            ' Recupero dalla sessione il Token che ho valorizzato nella pagina Documento
            Dim token As WcfDwhClinico.TokenType = Session("Token")

            '
            ' Valorizzo comunque il codice fiscale del medico 
            '
            If String.IsNullOrEmpty(sCodiceFiscaleMedico) Then
                sCodiceFiscaleMedico = Utility.CODICE_FISCALE_NULLO
            End If

            If String.IsNullOrEmpty(sCodiceDocumento) OrElse String.IsNullOrEmpty(sCodiceFiscalePaziente) OrElse String.IsNullOrEmpty(sTipoAccesso) Then
                Response.Write(FormatError("I parametri 'TipoAccesso', 'CodiceFiscalePaziente' e 'CodiceDocumento' sono obbligatori."))
                Exit Sub
            End If

            Dim oFse As New FseDataSource.FseDocumentoOttieni
            Dim oDocumento As WcfDwhClinico.DocumentoType = oFse.GetData(token, sCodiceDocumento, sTipoAccesso, sTipoDocumento, sNaturaDocumento, sCodiceFiscalePaziente, sCodiceFiscaleMedico)

            If oDocumento IsNot Nothing AndAlso oDocumento.Contenuto IsNot Nothing AndAlso oDocumento.Contenuto.Length > 0 Then
                ' Toglie directory dal nome
                '
                Dim oFileInfo As System.IO.FileInfo
                oFileInfo = New System.IO.FileInfo(String.Format("Documento_{0}", sCodiceDocumento))
                Dim sFileName As String = oFileInfo.Name()
                '
                ' Scrivo il contenuto binario
                '
                Response.Expires = 0
                Response.Clear()
                Response.BufferOutput = True
                Response.ContentType = "Application/Pdf"
                Response.AddHeader("content-disposition", "inline; filename=" & sFileName)
                Response.BinaryWrite(oDocumento.Contenuto)
            Else
                Response.Write(FormatError("Per questo documento non esiste il PDF!"))
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