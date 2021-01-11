Imports System.Diagnostics
Imports System
Imports System.Web
Imports System.Reflection
Imports DI.Sac.Admin.Data.PazientiDataSetTableAdapters
Imports DI.Sac.Admin.Data.PazientiDataSet
Imports System.Web.UI
Imports DI.PortalAdmin.Data

Namespace DI.Sac.Admin

    Partial Public Class PazienteMerge
        Inherits Page

        Private Shared ReadOnly _className As String = String.Concat("Gestione.", MethodBase.GetCurrentMethod().ReflectedType.Name)
        Private _idPaziente As String
        Private _idPazienteFuso As String

        Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load

            _idPaziente = Request.Params("idPaziente")
            _idPazienteFuso = Request.Params("idPazienteFuso")

            If Not Page.IsPostBack Then

                ' Set della proprietà url del CurrentNode.ParentNode con l'id del paziente fuso
                If Not SiteMap.CurrentNode Is Nothing Then
                    Call Utility.SetSiteMapNodeQueryString(SiteMap.CurrentNode.ParentNode, String.Format("id={0}", _idPazienteFuso))
                End If

                ' Controllo che l'id paziente e l'id paziente fuso siano diversi
                If String.IsNullOrEmpty(_idPaziente) OrElse String.IsNullOrEmpty(_idPazienteFuso) OrElse _idPaziente.Equals(_idPazienteFuso) Then

                    btnUpdate.Enabled = False
                    txtNote.Enabled = False
                    LabelError.Visible = True
                    LabelError.Text = "Il paziente sorgente non puo' essere uguale al paziente di destinazione!"
                Else
                    ' Recupero riga corrente del paziente di destinazione                    
                    Using adapter As New PazientiGestioneTableAdapter()

                        Dim oDataTable As PazientiGestioneDataTable = adapter.GetData(New Guid(_idPaziente))
                        Dim oRow As PazientiGestioneRow = oDataTable(0)

                        If oRow.Disattivato > 0 Then

                            ' La riga risulta essere non attiva, disabilito il merge                            
                            btnUpdate.Enabled = False
                            txtNote.Enabled = False
                            LabelError.Visible = True
                            LabelError.Text = "Il paziente di destinazione non è attivo!"
                        End If
                    End Using
                End If
            End If
        End Sub

        Protected Sub btnUpdate_Click(ByVal sender As Object, ByVal e As EventArgs) Handles btnUpdate.Click
            Try
                '
                ' Recupero riga corrente del paziente fuso
                '
                Dim oRow As PazientiGestioneRow

                Using adapter = New PazientiGestioneTableAdapter()

                    oRow = adapter.GetData(New Guid(_idPazienteFuso))(0)
                End Using

                ' Merge
                Dim idPaziente As Guid = New Guid(_idPaziente)
                Dim idPazienteFuso As Guid = New Guid(_idPazienteFuso)
                Dim note As String

                If txtNote.Text.Length > 0 Then note = txtNote.Text Else note = Nothing

                Using adapter As New PazientiMergeTableAdapter()
                    adapter.PazientiMergeInsert(idPaziente, idPazienteFuso, oRow.Provenienza, oRow.IdProvenienza, note, User.Identity.Name)
                End Using

                Cache("PazientiGestioneLista") = DateTime.Now()

                '
                '2020-07-06 Kyrylo: Traccia Operazioni
                '
                Dim oTracciaOp As New TracciaOperazioniManager(Global_asax.ConnectionStringPortalAdmin)
                oTracciaOp.TracciaOperazione(PortalsNames.Sac, Page.AppRelativeVirtualPath, "Effettuata fusione anagrafica", idPazienteFuso.ToString(), idPaziente.ToString(), idPaziente)

                Response.Redirect(String.Concat("PazienteDiagrammaMerge.aspx?id=", idPazienteFuso.ToString()), False)
            Catch ex As Exception
                ExceptionsManager.TraceException(ex)
                LabelError.Visible = True
                LabelError.Text = MessageHelper.GetGridViewMessage(TypeGridViewError.Aggiornamento)
            End Try
        End Sub

        Protected Sub btnCancel_Click(ByVal sender As Object, ByVal e As EventArgs) Handles btnCancel.Click
            Response.Redirect("~/Pazienti/PazienteDettaglio.aspx?id=" & _idPazienteFuso)
        End Sub

    End Class

End Namespace