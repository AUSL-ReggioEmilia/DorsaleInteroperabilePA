Imports System
Imports System.Web.UI.WebControls
Imports DI.DataWarehouse.Admin

Public Class SistemiAbilitatiDettaglio
    Inherits System.Web.UI.Page


    Private mPageId As String = Me.GetType().Name
    Private Const BACKPAGE As String = "MMGSistemiAbilitatiLista.aspx"

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Try
            If Request.QueryString(Constants.Id) Is Nothing Then
                '
                ' PASSO IN MODALITÀ INSERIMENTO
                '
                FormViewDettaglio.ChangeMode(FormViewMode.Insert)
                labelTitolo.Text = "Abilitazione Sistema"
                'IL PULSANTE SALVA DEVE INVOCARE IL METODO INSERT
                Dim button As Button = FormViewDettaglio.FindControl("butSalva")
                If button IsNot Nothing Then button.CommandName = "Insert"
                button = FormViewDettaglio.FindControl("butElimina")
                If button IsNot Nothing Then button.Visible = False
            Else
                labelTitolo.Text = "Dettaglio Sistema abilitato"
                FormViewDettaglio.ChangeMode(FormViewMode.Edit)
            End If

            'SE SONO DI RITORNO DALLA PAGINA DI UPLOAD RECUPERO I VALORI DIGITATI NELLE TEXTBOX
            If Upload.UploadSuccessFully Or Upload.UploadCanceled Then
                FilterHelper.Restore(FormViewDettaglio, mPageId)
            End If
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub

    'Protected Sub ddlSistemaErogante_DataBinding(sender As Object, e As EventArgs)
    '    Try
    '        Dim ddlSistemaErogante As DropDownList = FormViewDettaglio.FindControl("ddlSistemaErogante")
    '        '
    '        ' AGGIUNGO IL SISTEMA EROGANTE VUOTO SOLO IN MODALITÀ INSERIMENTO
    '        '
    '        If Request.QueryString(Constants.Id) Is Nothing Then
    '            ddlSistemaErogante.Items.Insert(0, New ListItem("", ""))
    '        End If
    '        '
    '        ' AGGIUNGO IL SISTEMA EROGANTE <Altro> 
    '        '
    '        ddlSistemaErogante.Items.Add(New ListItem("<Altro>", "Altro"))

    '    Catch ex As Exception
    '        Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
    '        Utility.ShowErrorLabel(LabelError, sErrorMessage)
    '    End Try
    'End Sub

    'Protected Sub ddlSistemaErogante_DataBound(sender As Object, e As EventArgs)
    '    Try

    '        RIMUOVO IL SISTEMA ADT CHE NON DOVREBBE COMPARIRE
    '         VA FATTO???
    '        Dim ddlSistemaErogante As DropDownList = FormViewDettaglio.FindControl("ddlSistemaErogante")
    '        Dim item = ddlSistemaErogante.Items.FindByValue("ADT")
    '        If item IsNot Nothing Then
    '            ddlSistemaErogante.Items.Remove(item)
    '        End If

    '    Catch ex As Exception
    '        Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
    '        Utility.ShowErrorLabel(LabelError, sErrorMessage)
    '    End Try
    'End Sub

    Private Sub FormViewDettaglio_Init(sender As Object, e As EventArgs) Handles FormViewDettaglio.Init
        '
        ' RIUSO L'EditItemTemplate ANCHE PER L'INSERIMENTO
        '
        FormViewDettaglio.InsertItemTemplate = FormViewDettaglio.EditItemTemplate
    End Sub

    Private Sub FormViewDettaglio_ItemUpdated(sender As Object, e As System.Web.UI.WebControls.FormViewUpdatedEventArgs) Handles FormViewDettaglio.ItemUpdated
        e.KeepInEditMode = True
    End Sub

    Protected Sub FormViewDettaglio_ItemCommand(sender As Object, e As FormViewCommandEventArgs) Handles FormViewDettaglio.ItemCommand
        Try
            Select Case e.CommandName.ToUpper
                Case "CANCEL"
                    Response.Redirect(BACKPAGE, False)
            End Select

        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
        End Try
    End Sub

    Private Sub ods_HaSalvato(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsDettaglio.Updated, odsDettaglio.Deleted, odsDettaglio.Inserted
        If Not ObjectDataSource_TrapError(sender, e) Then
            Response.Redirect(BACKPAGE, False)
        End If
    End Sub

#Region "Funzioni"

    ''' <summary>
    ''' Gestisce gli errori del ObjectDataSource in maniera pulita
    ''' </summary>
    ''' <returns>True se si è verificato un errore</returns>
    Private Function ObjectDataSource_TrapError(ods As ObjectDataSourceView, e As ObjectDataSourceStatusEventArgs) As Boolean
        Try
            If e.Exception IsNot Nothing AndAlso e.Exception.InnerException IsNot Nothing Then
                Utility.ShowErrorLabel(LabelError, GestioneErrori.TrapError(e.Exception.InnerException))
                e.ExceptionHandled = True
                Return True
            Else
                Return False
            End If
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            Utility.ShowErrorLabel(LabelError, sErrorMessage)
            Return True
        End Try

    End Function

    Private Function ConvertBitmapToPNGBytes(bmp As Drawing.Bitmap) As Byte()
        Dim byteArray As Byte() = New Byte(-1) {}
        Using stream As New IO.MemoryStream()
            bmp.Save(stream, Drawing.Imaging.ImageFormat.Png)
            stream.Close()
            byteArray = stream.ToArray()
        End Using
        Return byteArray
    End Function

#End Region
End Class