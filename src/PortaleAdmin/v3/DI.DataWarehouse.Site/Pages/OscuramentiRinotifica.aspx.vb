Imports System
Imports System.Data
Imports System.Web.UI.WebControls
Imports DI.DataWarehouse.Admin.Data

Public Class OscuramentiRinotifica
    Inherits System.Web.UI.Page

#Region "Property"
    Public Property IdOscuramento() As Guid
        Get
            Return Me.ViewState("IdOscuramento")
        End Get
        Set(ByVal value As Guid)
            Me.ViewState("IdOscuramento") = value
        End Set
    End Property
#End Region

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Try
            'CONTROLLO SE GLI ID SONO VALORIZZATI E SE SONO GUID VALIDI
            Dim sIdOscuramento As String = Request.QueryString("Id")
            If String.IsNullOrEmpty(sIdOscuramento) Then
                Throw New Exception("Il paramentro 'Id' è obbligatorio.")
            Else
                If Not Guid.TryParse(sIdOscuramento, Me.IdOscuramento) Then
                    Throw New Exception("Il paramentro 'Id' non è un guid valido.")
                End If
            End If

            'VERIFICO CHE IdOld SIA UN GUID VALIDO
            Dim sIdVecchioOscuramento As String = Request.QueryString("IdOld")
            Dim gIdVecchioOscuramento As Guid
            If Not String.IsNullOrEmpty(sIdVecchioOscuramento) AndAlso Not Guid.TryParse(sIdVecchioOscuramento, gIdVecchioOscuramento) Then
                Throw New Exception("Il paramentro 'IdOld' non è un guid valido.")
            End If

            'SE IdOld NON E' VALORIZZATO NASCONDO TUTTE LE INFORMAZIONI RIGUARDO AL VECCHIO OSCURAMENTO.
            If String.IsNullOrEmpty(sIdVecchioOscuramento) Then
                divRefertiOscuramentoOld.Visible = False
                divEventiOscuramentoOld.Visible = False
                fvVecchioOscuramento.Visible = False
            End If
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub

    Private Sub btnAnnulla_Click(sender As Object, e As EventArgs) Handles btnAnnulla.Click, btnAnnullaTop.Click
        Try
            'ESEGUO UN REDIRECT ALLA PAGINA DI LISTA.
            redirectToHome()
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub

    Private Sub btnOk_Click(sender As Object, e As EventArgs) Handles btnOk.Click, btnOkTop.Click
        Try
            '1) SALVO I REFERTI E GLI EVENTI NELLE RISPETTIVE CODE.
            '2) COMPLETO L'INSERIMENTO DELL'OSCURAMENTO (IMPOSTO IdCorrelazione = NULL e stato = 'Completato')
            Using ta As New OscuramentiDataSetTableAdapters.QueriesTableAdapter
                ta.OscuramentiRinotificaSole(Me.IdOscuramento)
            End Using

            'TORNO ALLA PAGINA INIZIALE.
            redirectToHome()
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub

    Private Sub redirectToHome()
        Try
            Response.Redirect("~/Pages/OscuramentiLista.aspx", False)
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub

#Region "MarkupFunction"
    ''' <summary>
    ''' RESTITUISCE IL TITOLO DELLA PAGINA
    ''' </summary>
    ''' <param name="sCodiceOscuramento"></param>
    ''' <returns></returns>
    Protected Function GetTitle(ByVal sCodiceOscuramento As String) As String
        Dim sReturn As String = "Rinotifica Oscuramento"

        Try
            If Not String.IsNullOrEmpty(sCodiceOscuramento) Then
                sReturn = "Rinotifica Oscuramento: " & sCodiceOscuramento
            End If
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
            Return String.Empty
        End Try

        Return sReturn
    End Function

    ''' <summary>
    ''' OTTIENE LA DESCRIZIONE DELL'OSCURAMENTO
    ''' </summary>
    ''' <param name="RowView"></param>
    ''' <returns></returns>
    Protected Function GetDescrizioneRow(RowView As System.Data.DataRowView) As String
        Try
            Dim oRow As DataRow = RowView.Row
            Select Case CType(oRow("TipoOscuramento"), Byte)
                Case 1 ' azienda erogante & nosologico
                    Return String.Format("Azienda Erogante: {0} <br /> Numero Nosologico {1}", oRow("AziendaErogante"), oRow("NumeroNosologico"))

                Case 3 ' Numero Referto (& sistema) (& azienda)
                    Return String.Format("Numero Referto: {0} <br /> Sistema Erogante: {1} <br /> Azienda Erogante: {2}", oRow("NumeroReferto"), oRow("SistemaErogante"), oRow("AziendaErogante"))

                Case 4 ' Numero Prenotazione (& sistema) (& azienda)
                    Return String.Format("Numero Prenotazione: {0} <br /> Sistema Erogante: {1} <br /> Azienda Erogante: {2}", oRow("NumeroPrenotazione"), oRow("SistemaErogante"), oRow("AziendaErogante"))

                Case 5 ' id order entry (& sistema) (& azienda)
                    Return String.Format("Id Order Entry: {0} <br /> Sistema Erogante: {1} <br /> Azienda Erogante: {2}", oRow("IdOrderEntry"), oRow("SistemaErogante"), oRow("AziendaErogante"))

                Case 9 ' IdEsternoReferto
                    Return String.Format("IdEsterno: {0}", oRow("IdEsternoReferto"))
                Case Else
                    Return String.Empty
            End Select
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
            Return String.Empty
        End Try
    End Function

    ''' <summary>
    ''' OTTIENE LA "DESCRIZIONE" DEL REFERTO (SISTEMA@AZIENDA-REPARTO
    ''' </summary>
    ''' <param name="oDataRowView"></param>
    ''' <returns></returns>
    Protected Function GetRefertoDescrizione(oDataRowView As DataRowView) As String
        Dim sReturn As String = String.Empty
        Try
            Dim oRefertoRow As OscuramentiDataSet.OscuramentiRefertiOttieniRow = CType(oDataRowView.Row, OscuramentiDataSet.OscuramentiRefertiOttieniRow)
            sReturn = String.Format("{0}@{1}-{2}", oRefertoRow.SistemaErogante, oRefertoRow.AziendaErogante, oRefertoRow.RepartoErogante)
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
        Return sReturn
    End Function

    Protected Function GetAziendaSistemaRepartoDescrizione(ByVal Azienda As Object, ByVal Sistema As Object, ByVal Reparto As Object) As String
        Try
            Return String.Format("{0}@{1}-{2}", Sistema, Azienda, Reparto)
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
            Return String.Empty
        End Try
    End Function


    Protected Function GetDettaglioRicoveroUrl(ByVal oDataRowView As DataRowView) As String
        Try
            Dim sReturn As String = "~\Pages\RicoveriDettaglio.aspx?IdRicovero={0}&AziendaErogante={1}&NumeroNosologico={2}"
            Dim oRow As OscuramentiDataSet.OscuramentiEventiOttieniRow = CType(oDataRowView.Row, OscuramentiDataSet.OscuramentiEventiOttieniRow)
            If Not oRow Is Nothing Then
                Dim dt As OscuramentiDataSet.RicoveroOttieniIdByAziendaNosologicoDataTable
                Using ta As New OscuramentiDataSetTableAdapters.RicoveroOttieniIdByAziendaNosologicoTableAdapter
                    dt = ta.GetData(oRow.AziendaErogante, oRow.NumeroNosologico)
                End Using
                If Not dt Is Nothing AndAlso dt.Rows.Count > 0 Then
                    Dim gIdRicovero As Guid = dt(0).Id
                    sReturn = String.Format(sReturn, gIdRicovero, oRow.AziendaErogante, oRow.NumeroNosologico)
                End If
            End If
            Return sReturn
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
            Return Nothing
        End Try
    End Function
#End Region

#Region "ObjectDataSource"
    Private Sub OdsDettaglioOscuramento_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles OdsDettaglioOscuramento.Selected
        Try
            If Not ObjectDataSource_TrapError(e, LabelError) Then
                If Not e.ReturnValue Is Nothing Then
                    Dim oDataTable As OscuramentiDataSet.OscuramentiDataTable = CType(e.ReturnValue, OscuramentiDataSet.OscuramentiDataTable)
                    If Not oDataTable Is Nothing AndAlso oDataTable.Rows.Count > 0 Then
                        Dim oRow As OscuramentiDataSet.OscuramentiRow = CType(oDataTable.Rows(0), OscuramentiDataSet.OscuramentiRow)
                        If Not oRow Is Nothing Then
                            'VALORIZZO IL TITOLO DELLA PAGINA OTTENENDO IL CODICE DELL'OSCURAMENTO.
                            lblTitle.Text = String.Format("Rinotifica Oscuramento {0}", oRow.CodiceOscuramento)
                        End If
                    End If
                End If
            End If
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub

    ''' <summary>
    ''' TRAPPO GLI ERRORE CAUSATI DALL'OBJECT DATA SOURCE.
    ''' </summary>
    ''' <param name="sender"></param>
    ''' <param name="e"></param>

    Private Sub ods_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsReferti.Selected, odsRefertiVecchioOscuramento.Selected, odsEventi.Selected, odsEventiVecchioOscuramento.Selected, odsVecchioOscuramento.Selected
        ObjectDataSource_TrapError(e, LabelError)
    End Sub

    Private Sub odsEventiVecchioOscuramento_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsEventiVecchioOscuramento.Selecting
        Try
            Dim sIdOld As String = Request.QueryString("IdOld")
            If String.IsNullOrEmpty(sIdOld) Then
                e.Cancel = True
            Else
                e.InputParameters("IdOscuramento") = sIdOld
            End If
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub

    Private Sub odsRefertiVecchioOscuramento_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsRefertiVecchioOscuramento.Selecting
        Try
            Dim sIdOld As String = Request.QueryString("IdOld")
            If String.IsNullOrEmpty(sIdOld) Then
                e.Cancel = True
            Else
                e.InputParameters("IdOscuramento") = sIdOld
            End If
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub

#End Region
End Class