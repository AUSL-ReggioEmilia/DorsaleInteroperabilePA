Imports System.Web.UI
Imports System
Imports System.Web.UI.WebControls
Imports DI.PortalAdmin.Data
Imports System.Configuration
Imports System.Linq
Imports System.Data
Imports DI.Common
Imports System.Collections.Generic
Imports System.Web.Services
Imports System.IO
Imports System.Xml.Linq

Namespace DI.PortalAdmin.Home


    Public Class ArchivioModifiche
        Inherits Page

        Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load

            BindGrid()
        End Sub

        Protected Sub BindGrid()

            Dim portalDam As New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)

            Me.ArchivioGridView.DataSource = portalDam.GetArchivioModifiche(Me.PortalNameDropDownList.SelectedValue, If(Me.TableNameTextBox.Text.Length > 0, Me.TableNameTextBox.Text, Nothing))
            Me.ArchivioGridView.DataBind()
        End Sub

        Protected Sub ArchivioGridView_Sorting(sender As Object, e As GridViewSortEventArgs) Handles ArchivioGridView.Sorting

            Dim dataSource As List(Of ArchivioModificheListaResult) = Me.ArchivioGridView.DataSource

            If ViewState("SortExpression") = Nothing Then
                ViewState("SortExpression") = "Desc"
            Else
                ViewState("SortExpression") = If(ViewState("SortExpression").ToString() = "Desc", "Asc", "Desc")
            End If

            Dim reverse As Boolean = ViewState("SortExpression").ToString() = "Desc"

            dataSource.Sort(New SortableComparer(Of ArchivioModificheListaResult)(e.SortExpression, reverse))

            Me.ArchivioGridView.DataSource = dataSource
            Me.ArchivioGridView.DataBind()
        End Sub

        <WebMethod()> _
        Public Shared Function CaricaDettaglioModifiche(id As Integer) As List(Of Dictionary(Of String, String))

            Dim portalDam As New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)

            Return Utility.GetListFromDataTable(ElaboraDettaglio(portalDam.GetDettaglioArchivioModifiche(id)))
        End Function

        Private Shared Function ElaboraDettaglio(dettaglio As ArchivioModificheDettaglioResult) As DataTable

            Dim dettaglioDataTable As New DataTable()

            If dettaglio.Valore_Prima IsNot Nothing Then

                dettaglioDataTable.Merge(XmlToDataTable(dettaglio.Valore_Prima))
            End If

            If dettaglio.Valore_Dopo IsNot Nothing Then

                dettaglioDataTable.Merge(XmlToDataTable(dettaglio.Valore_Dopo))
            End If

            ' 1 cancellazione
            ' 2 inserimento
            ' 3/4 update

            Dim tipo As Integer
            If dettaglioDataTable.Rows.Count = 2 Then
                tipo = 3
            Else
                tipo = dettaglioDataTable.Rows(0)("__$operation")
            End If

            Dim newTable As New DataTable()
            newTable.Columns.Add("Campo", GetType(String))
            newTable.Columns.Add("Valore (prima)", GetType(String))
            newTable.Columns.Add("Valore (dopo)", GetType(String))

            For Each column As DataColumn In dettaglioDataTable.Columns

                If column.ColumnName = "__$start_lsn" OrElse
                    column.ColumnName = "__$end_lsn" OrElse
                    column.ColumnName = "__$seqval" OrElse
                    column.ColumnName = "__$operation" OrElse
                    column.ColumnName = "__$update_mask" Then

                    Continue For
                End If

                Dim newRow As DataRow = newTable.NewRow()
                newRow("Campo") = column.ColumnName

                Select Case tipo

                    Case 1
                        newRow("Valore (prima)") = dettaglioDataTable.Rows(0)(column.ColumnName)

                    Case 2
                        newRow("Valore (dopo)") = dettaglioDataTable.Rows(0)(column.ColumnName)

                    Case Else
                        newRow("Valore (prima)") = dettaglioDataTable.Rows(0)(column.ColumnName)
                        newRow("Valore (dopo)") = dettaglioDataTable.Rows(1)(column.ColumnName)
                End Select

                newTable.Rows.Add(newRow)
            Next

            Return newTable
        End Function

        Public Shared Function XmlToDataTable(xml As XElement) As DataTable

            Dim ds As New DataSet()
            ds.ReadXml(New StringReader(xml.ToString()))
            Return ds.Tables(0)
        End Function


    End Class

End Namespace