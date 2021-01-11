Imports System
Imports System.Web.UI
Imports System.Web
Imports System.Web.UI.WebControls

Public Class RefertoImport
    Inherits System.Web.UI.Page

    Private gvCancelSelect = True
    Private mIdRefertoImportato As Guid

    Private Sub RefertoImport_Load(sender As Object, e As EventArgs) Handles Me.Load
        Try
            If Not Page.IsPostBack Then
                If Not My.Settings.ToolRefertoImport_Abilitato Then
                    MainContainer.Visible = False
                    Throw New ApplicationException("L'accesso alla pagina non è consentito!")
                End If
                tblDettaglioreferto.Visible = False
            End If
        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(lblError, sMessage)
        End Try
    End Sub

    Private Sub btnImporta_Click(sender As Object, e As EventArgs) Handles btnImporta.Click
        Try
            Dim httpPostedfile As HttpPostedFile = InputFile.PostedFile
            '
            ' Eseguo verifiche
            '
            If httpPostedfile.ContentLength = 0 Then
                Throw New ApplicationException("Impossibile caricare il file!<BR>La dimensione del file è 0 Byte.<BR>Verificare il percorso del file.")
            End If
            If httpPostedfile.ContentType.ToUpper <> "TEXT/XML" Then
                Throw New ApplicationException("Il file non è un XML!")
            End If
            '
            ' Carico un buffer con i byte dell'httpPostedfile e ottengo la stringa XML
            '
            Dim buffer(httpPostedfile.ContentLength - 1) As Byte
            httpPostedfile.InputStream.Read(buffer, 0, httpPostedfile.ContentLength)
            Dim sXmlReferto As String = System.Text.Encoding.UTF8.GetString(buffer)
            '
            ' Importo il referto nel database
            '
            Dim functionJS As String = "alert('Il referto è stato importato!');"
            Dim guidPazienteAssociato As Guid = Nothing
            Using oTa As New ToolsDataSetTableAdapters.RefertoImportTableAdapter
                Dim oDt As ToolsDataSet.RefertoImportDataTable = oTa.GetDataByXmlReferto(sXmlReferto)
                If Not oDt Is Nothing AndAlso oDt.Rows.Count > 0 Then
                    Dim oRow As ToolsDataSet.RefertoImportRow = oDt(0)
                    '
                    ' Memorizzo l'Id del referto
                    '
                    mIdRefertoImportato = oRow.IdReferto
                    '
                    ' Verifico che l'IdPazienteAssociato non sia l'anonimo
                    '
                    If oRow.IsIdPazienteSacAssociatoNull Or oRow.IdPazienteSacAssociato = Nothing Then
                        functionJS = "alert('Il referto è stato importato, ma è stato agganciato al paziente anonimo!');"
                    End If
                End If
            End Using
            '
            ' Imposto a false la variabile gvCancelSelect in modo da eseguire la query dell'ObjectDataSource.
            ' Eseguo il bind del form view
            '
            gvCancelSelect = False
            FormView.DataBind()
            tblDettaglioreferto.Visible = True
            hlAccessoDirettoReferto.NavigateUrl = GetUrlAccessoDirettoReferto(mIdRefertoImportato)
            '
            ' Messaggio per l'utente
            '
            ScriptManager.RegisterStartupScript(Page, Page.GetType, "btnImporta_Click", functionJS, True)

        Catch ex As Exception
            tblDettaglioreferto.Visible = False
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(lblError, sMessage)
        End Try
    End Sub



#Region "ObjectDataSource"
    Private Sub odsReferto_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsReferto.Selected
        '
        'Gestisco eventuali errori.
        '
        GestioneErrori.ObjectDataSource_TrapError(e, lblError)
    End Sub

    Private Sub odsReferto_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsReferto.Selecting
        Try
            '
            'Cancello la query se gvCancelSelect è true.
            '
            If gvCancelSelect Then
                e.Cancel = True
                Exit Sub
            End If
            '
            ' Passo l'Id del referto all'object data source
            '
            e.InputParameters("IdReferto") = mIdRefertoImportato

        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(lblError, sMessage)
        End Try
    End Sub
#End Region


    Private Function GetUrlAccessoDirettoReferto(oIdReferto As Guid) As String
        Dim sResult As String = String.Empty
        Try
            'Compongo l'url per visualizzare il dettaglio del referto sull'accesso diretto.
            sResult = String.Format(My.Settings.RefertoUrl, oIdReferto.ToString)
        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(lblError, sMessage)
        End Try
        '
        'restituisco
        '
        Return sResult
    End Function

End Class