Public Class ImportAgendePrestazioniLhaCup
    Inherits System.Web.UI.Page

    Private msIdAgenda As String

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Try
            msIdAgenda = Request.QueryString("IdAgenda")

            If Not Page.IsPostBack Then

            End If
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            'Master.ShowAlert(sErrorMessage)
        End Try
    End Sub

    Private Sub butAnnulla_Click(sender As Object, e As EventArgs) Handles butAnnulla.Click, butAnnulla2.Click
        Try
            Response.Redirect("~/Default.aspx")
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            'Master.ShowAlert(sErrorMessage)
        End Try
    End Sub

    Private Sub butImporta_Click(sender As Object, e As EventArgs) Handles butImporta.Click, butImporta2.Click
        Dim oControl As Control = Nothing

        Dim sCodiceAgendaCup As String = Nothing
        Dim sDescrizioneAgendaCup As String = Nothing
        Dim sTranscodificaCodiceAgendaCup As String = Nothing
        Dim sStrutturaErogante As String = Nothing
        Dim sDescrizioneStrutturaErogante As String = Nothing
        Dim sCodiceSistemaErogante As String = Nothing
        Dim sCodiceAziendaErogante As String = Nothing
        Dim bMultiErogante As Boolean = Nothing
        Try
            'Aggiorno la tabella delle Agende
            Using taAgenda As New ImportazioneLhaCupDataSetTableAdapters.LHAAgendeTableAdapter

                Dim oFormView As FormView = CType(FormView1, FormView)

                oControl = oFormView.FindControl("CodiceAgendaCupTextBox")
                sCodiceAgendaCup = CType(oControl, TextBox).Text

                oControl = oFormView.FindControl("DescrizioneAgendaCupTextBox")
                sDescrizioneAgendaCup = CType(oControl, TextBox).Text

                oControl = oFormView.FindControl("TranscodificaCodiceAgendaCupTextBox")
                sTranscodificaCodiceAgendaCup = CType(oControl, TextBox).Text

                oControl = oFormView.FindControl("StrutturaEroganteTextBox")
                sStrutturaErogante = CType(oControl, TextBox).Text

                oControl = oFormView.FindControl("DescrizioneStrutturaEroganteTextBox")
                sDescrizioneStrutturaErogante = CType(oControl, TextBox).Text

                oControl = oFormView.FindControl("CodiceSistemaEroganteTextBox")
                sCodiceSistemaErogante = CType(oControl, TextBox).Text


                oControl = oFormView.FindControl("CodiceAziendaEroganteTextBox")
                sCodiceAziendaErogante = CType(oControl, TextBox).Text

                oControl = oFormView.FindControl("MultiEroganteCheckBox")
                bMultiErogante = CType(oControl, CheckBox).Checked

                Dim oDataTableAgenda As New ImportazioneLhaCupDataSet.LHAAgendeDataTable
                Dim oRow As ImportazioneLhaCupDataSet.LHAAgendeRow = oDataTableAgenda.AddLHAAgendeRow(sCodiceAgendaCup, sDescrizioneAgendaCup, sTranscodificaCodiceAgendaCup,
                                                                                sStrutturaErogante, sDescrizioneStrutturaErogante, sCodiceSistemaErogante,
                                                                                sCodiceAziendaErogante, bMultiErogante)
                taAgenda.Update(oRow)

            End Using

            'Inserisco le prestazioni associate all'agenda corrente
            Using taPrestazioni As New ImportazioneLhaCupDataSetTableAdapters.LHAAgendePrestazioniTableAdapter

                If Not GridViewListaPrestazioni Is Nothing Then
                    If GridViewListaPrestazioni.Rows.Count > 0 Then
                        For Each oGridRow As GridViewRow In GridViewListaPrestazioni.Rows

                            'Questa è la riga del database che popola la GridView
                            Dim oDataRow As ImportazioneLhaCupDataSet.LHAAgendePrestazioniRow = CType(oGridRow.DataItem, ImportazioneLhaCupDataSet.LHAAgendePrestazioniRow)

                            taPrestazioni.Update(oDataRow)

                        Next
                    End If
                End If
            End Using



        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            'Master.ShowAlert(sErrorMessage)
        End Try
    End Sub

    'Private Sub FormView1_ItemCommand(sender As Object, e As FormViewCommandEventArgs) Handles FormView1.ItemCommand
    '    Try
    '        If e.CommandName.ToUpper = "IMPORTA" Then
    '            'Aggiorno la riga dell'azienda nella tabella "TranscodificaAgendaCupStrutturaErogante"
    '            Dim oFormView As FormView = CType(sender, FormView)

    '            Dim o = oFormView.FindControl("CodiceAgendaCupTextBox")
    '        End If
    '    Catch ex As Exception

    '    End Try
    'End Sub


    Protected Function GetAgendaDescrizione() As String
        'TODO: GetAgendaDescrizione() non mostra l'agenda nella form!!!
        Return msIdAgenda
    End Function
End Class