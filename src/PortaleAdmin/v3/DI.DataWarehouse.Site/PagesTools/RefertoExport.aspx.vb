Imports System
Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports System.Xml.Linq
Imports DI.DataWarehouse.Admin
Imports DI.PortalAdmin.Data

Public Class RefertoExport
    Inherits System.Web.UI.Page

#Region "Property di pagina"
    Private ReadOnly msPAGEKEY As String = Page.GetType().BaseType.FullName
    Private gvCancelSelect = True

#End Region
    Private Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        Try
            '
            'Setta il pulsante di default.
            '
            Me.Form.DefaultButton = Me.btnCerca.UniqueID
            If Not Page.IsPostBack Then
                If Not My.Settings.ToolRefertoExport_Abilitato Then
                    MainContainer.Visible = False
                    Throw New ApplicationException("L'accesso alla pagina non è consentito!")
                End If
                '
                'Ricarica i filtri prendendoli dalla sessione.
                '
                FilterHelper.Restore(filterPanel, msPAGEKEY)
                tblRefertoDaEsportare.Visible = False
            End If
            '
            ' Setto a FALSE gvCancelSelect in modo da NON eseguire la select dell'object data source.
            '
            gvCancelSelect = True

        Catch ex As Exception
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
            Dim sIdReferto As String = txtIdReferto.Text
            e.InputParameters("IdReferto") = sIdReferto

        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(lblError, sMessage)
        End Try
    End Sub
#End Region

    Private Sub btnCerca_Click(sender As Object, e As EventArgs) Handles btnCerca.Click
        Try
            '
            'Eseguo il bind dei dati solo se i filtri impostati sono validi.
            '
            If ValidateFilters() Then
                '
                'Salvo i filtri in sessione.
                '
                FilterHelper.SaveInSession(filterPanel, msPAGEKEY)
                '
                'Imposto a false la variabile gvCancelSelect in modo da eseguire la query dell'ObjectDataSource.
                '
                gvCancelSelect = False
                '
                'Eseguo il bind dei dati.
                '
                FormView.DataBind()
                '
                ' Rendo visibile la tabella che contiene la FormView e il pulsante btnEsporta
                '
                tblRefertoDaEsportare.Visible = True

                '
                '2020-07-06 Kyrylo: Traccia Operazioni
                '
                Dim oTracciaOp As New TracciaOperazioniManager(Global_asax.ConnectionStringPortalAdmin)
                oTracciaOp.TracciaOperazione(PortalsNames.DwhClinico, Page.AppRelativeVirtualPath, "Ricerca referto", filterPanel, Nothing)


            End If
        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(lblError, sMessage)
        End Try
    End Sub

    Private Sub btnEsporta_Click(sender As Object, e As EventArgs) Handles btnEsporta.Click
        Dim sXmlreferto As String = String.Empty
        Try
            Dim guidIdReferto As Guid = New Guid(txtIdReferto.Text)
            '
            ' Eseguo la SP che compone l'xml del referto
            '
            Dim oDt As ToolsDataSet.RefertoExportDataTable = Nothing
            Using oTa As New ToolsDataSetTableAdapters.RefertoExportTableAdapter
                oDt = oTa.GetDataByIdReferto(guidIdReferto)
                If Not oDt Is Nothing AndAlso oDt.Rows.Count > 0 Then
                    sXmlreferto = oDt(0).XmlReferto
                End If
            End Using

            If Not String.IsNullOrEmpty(sXmlreferto) Then
                Response.Clear()
                Response.Buffer = True
                Dim sfileName As String = String.Concat("Referto_", txtIdReferto.Text, ".xml")
                Response.AddHeader("content-disposition", "attachment;filename=" & sfileName)
                Response.ContentType = "text/xml"
                Response.Write(sXmlreferto)
                Response.Flush()
                '
                '2020-07-03 Kyrylo: Traccia Operazioni
                '
                Dim refertoXML As XElement = XElement.Parse(sXmlreferto)
                Dim sIdPaziente As String = refertoXML.Element("IdPaziente")
                Dim oTracciaOp As New TracciaOperazioniManager(Global_asax.ConnectionStringPortalAdmin)
                oTracciaOp.TracciaOperazione(PortalsNames.DwhClinico, Page.AppRelativeVirtualPath, "Esportazione referto", New Guid(sIdPaziente), Nothing, guidIdReferto.ToString(), "IdReferto")


                Response.[End]()

            End If

        Catch ex As Exception
            tblRefertoDaEsportare.Visible = False
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(lblError, sMessage)
        End Try
    End Sub

#Region "Filtri"

    ''' <summary>
    ''' Verifica se i valori dei filtri sono impostati correttamente.
    ''' </summary>
    ''' <returns></returns>
    Private Function ValidateFilters() As Boolean
        Dim result As Boolean = True

        If String.IsNullOrEmpty(txtIdReferto.Text) Then
            Utility.ShowErrorLabel(lblError, "Il parametro 'IdReferto' è obbligatorio.")
            result = False
        End If
        '
        '
        '
        Return result
    End Function


#End Region

End Class