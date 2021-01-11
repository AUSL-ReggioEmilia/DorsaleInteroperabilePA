Imports System.Web
Imports System.Web.UI.HtmlControls
Imports System
Imports DI.Common
Imports System.Diagnostics
Imports System.Web.UI.WebControls
Imports System.Drawing
Imports DI.Sac.Admin.Data
Imports DI.Sac.Admin.Data.PazientiDataSet
Imports System.Data
Imports System.Linq
Imports DI.PortalAdmin.Data

Namespace DI.Sac.Admin

    Partial Public Class PazientiListaMerge
        Inherits System.Web.UI.Page

        Private Shared ReadOnly _ClassName As String = String.Concat("Gestione.", System.Reflection.MethodBase.GetCurrentMethod().ReflectedType.Name)
        Private _idPazienteFuso As String

        Private formMaster As HtmlForm

        Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load

            _idPazienteFuso = Request.Params("idPazienteFuso")

            If Not Page.IsPostBack Then

                If SiteMap.CurrentNode IsNot Nothing Then
                    SiteMap.CurrentNode.ParentNode.ReadOnly = False
                    SiteMap.CurrentNode.ParentNode.Url = String.Concat(SiteMap.CurrentNode.ParentNode.Url.Split("?")(0), "?id=", _idPazienteFuso)
                End If

                ' Crea una variabile di Cache per gestire la cache del ObjectDatasource                
                If Cache("PazientiGestioneListaMerge") Is Nothing Then Cache("PazientiGestioneListaMerge") = DateTime.Now()
            End If

            If Master.TryFindControl(Of HtmlForm)("form1", formMaster) Then
                formMaster.DefaultFocus = CognomeTextBox.ClientID
                formMaster.DefaultButton = RicercaButton.UniqueID
            End If
        End Sub

        Protected Sub btnRicerca_Click(ByVal sender As Object, ByVal e As EventArgs) Handles RicercaButton.Click

            Cache("PazientiGestioneListaMerge") = DateTime.Now()
            PazientiGridView.DataBind()

            '
            '2020-07-02 Kyrylo: Traccia Operazioni
            '
            Dim oTracciaOp As New TracciaOperazioniManager(Global_asax.ConnectionStringPortalAdmin)
            oTracciaOp.TracciaOperazione(PortalsNames.Sac, Page.AppRelativeVirtualPath, "Ricerca anagrafica", pannelloFiltri, New Guid(_idPazienteFuso))

        End Sub

        Protected Sub PazientiListaObjectDataSource_Selecting(ByVal sender As Object, ByVal e As ObjectDataSourceSelectingEventArgs) Handles PazientiListaObjectDataSource.Selecting

            If Not GetRicercaIsValid() Then e.Cancel = True

            If Me.ProvenienzaDropDownList.SelectedValue.Length = 0 Then

                e.InputParameters("Provenienza") = Nothing
            End If

            If OccultatoRadioButtonList.SelectedValue.Length = 0 Then
                e.InputParameters("Occultato") = Nothing
            Else
                e.InputParameters("Occultato") = CType(OccultatoRadioButtonList.SelectedValue, Boolean)
            End If
        End Sub

        Protected Sub PazientiListaObjectDataSource_Selected(ByVal sender As Object, ByVal e As ObjectDataSourceStatusEventArgs) Handles PazientiListaObjectDataSource.Selected

            Dim table As PazientiGestioneListaDataTable = e.ReturnValue

            Dim rows = From row In table Select row Where String.Equals(row.Id.ToString(), _idPazienteFuso, StringComparison.CurrentCultureIgnoreCase)

            If rows.Count = 1 Then
                table.RemovePazientiGestioneListaRow(rows(0))
            End If

            If e.Exception IsNot Nothing Then

                ExceptionsManager.TraceException(e.Exception)
                LabelError.Visible = True
                LabelError.Text = MessageHelper.GetGridViewMessage(TypeGridViewError.CaricamentoDati)
                e.ExceptionHandled = True
            End If
        End Sub

        Protected Function GetRicercaIsValid() As Boolean

            If Not CognomeTextBox.Text.Length = 0 OrElse _
                    Not NomeTextBox.Text.Length = 0 OrElse _
                    Not CodiceFiscaleTextBox.Text.Length = 0 OrElse _
                    Not IdSacTextBox.Text.Length = 0 OrElse _
                    Not AnnoNascitaTextBox.Text.Length = 0 OrElse _
                    Not StatoDropDownList.SelectedValue.Length = 0 Then

                Return True
            Else
                Return False
            End If
        End Function

        Protected Sub gvPazienti_RowDataBound(ByVal sender As Object, ByVal e As GridViewRowEventArgs) Handles PazientiGridView.RowDataBound

            'Dim id As String = DirectCast(DirectCast(e.Row.DataItem, DataRowView).Row, PazientiGestioneListaRow).Id.ToString()

            'If String.Equals(id, _idPazienteFuso, StringComparison.CurrentCultureIgnoreCase) Then
            '    e.Row.Visible = False
            'End If

            If e.Row.RowType = DataControlRowType.DataRow Then

                Dim stato = DirectCast(e.Row.DataItem("Disattivato"), Byte)

                Select Case stato

                    Case 0 'Attivo
                        e.Row.BackColor = Color.LightGreen

                    Case 1 'Fuso
                        e.Row.BackColor = Color.FromArgb(250, 140, 140) '#FA8C8C

                    Case Else 'Cancellato
                        e.Row.BackColor = Color.LightBlue
                End Select
            End If
        End Sub

    End Class

End Namespace