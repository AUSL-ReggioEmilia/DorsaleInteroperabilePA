Imports System
Imports System.Web.UI.WebControls
Imports DI.Sac.Admin

Public Class PazientiIncoerenzaISTATLista
    Inherits System.Web.UI.Page

    Private mbodsIncoerenzeIstat_CancelSelect As Boolean = False
    Private Const FILTERKEY As String = "PazientiIncoerenzaIstat"

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Try
            If Not Page.IsPostBack Then
                txtFiltriDataDal.Text = DateTime.Now.ToShortDateString
                ddlFiltriTop.Items.Clear()
                ddlFiltriTop.Items.Add(New ListItem("100", "100"))
                ddlFiltriTop.Items.Add(New ListItem("500", "500"))
                ddlFiltriTop.Items.Add(New ListItem("1000", "1000"))
                ddlFiltriTop.Items(0).Selected = True
            End If
        Catch ex As Exception

            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            If Not String.IsNullOrEmpty(sErrorMessage) Then
                LabelError.Visible = True
                LabelError.Text = sErrorMessage
            End If

        End Try
    End Sub

    Private Sub Page_PreRenderComplete(sender As Object, e As System.EventArgs) Handles Me.PreRenderComplete
        Try
            If Not Page.IsPostBack Then
                FilterHelper.Restore(pannelloFiltri, FILTERKEY)
                ImpostaFiltriDataSource()
            End If
        Catch ex As Exception

            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            If Not String.IsNullOrEmpty(sErrorMessage) Then
                LabelError.Visible = True
                LabelError.Text = sErrorMessage
            End If
        End Try
    End Sub


    Private Sub odsIncoerenzeIstat_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsIncoerenzeIstat.Selecting
        Try
            'eseguo la ricerca solo se i filtri sono a posto
            e.Cancel = mbodsIncoerenzeIstat_CancelSelect
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            If Not String.IsNullOrEmpty(sErrorMessage) Then
                LabelError.Visible = True
                LabelError.Text = sErrorMessage
            End If
        End Try
    End Sub

    Private Sub odsIncoerenzeIstat_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsIncoerenzeIstat.Selected
        Try
            If e.Exception IsNot Nothing Then
                ExceptionsManager.TraceException(e.Exception)
                LabelError.Visible = True
                LabelError.Text = MessageHelper.GetGridViewMessage(TypeGridViewError.CaricamentoDati)
                e.ExceptionHandled = True
            End If
        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            If Not String.IsNullOrEmpty(sErrorMessage) Then
                LabelError.Visible = True
                LabelError.Text = sErrorMessage
            End If
            mbodsIncoerenzeIstat_CancelSelect = True
        End Try
    End Sub

    Protected Sub RicercaButton_Click(sender As Object, e As EventArgs) Handles RicercaButton.Click

        Try
            LabelError.Visible = False

            If ValidazioneFiltri() Then
                ImpostaFiltriDataSource()
                FilterHelper.SaveInSession(pannelloFiltri, FILTERKEY)
                Cache("CacheIncoerenzeIstat") = New Object
                'tento il rebind
                gvIncoerenzeIstat.DataBind()
                gvIncoerenzeIstat.PageIndex = 0
            End If

        Catch ex As Exception
            Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
            If Not String.IsNullOrEmpty(sErrorMessage) Then
                LabelError.Visible = True
                LabelError.Text = sErrorMessage
            End If
        End Try

    End Sub

    Private Sub ImpostaFiltriDataSource()

        Dim dtDal As Object = Nothing
        Dim dtAl As Object = Nothing

        If txtFiltriDataDal.Text.Length > 0 Then
            DateTime.TryParse(txtFiltriDataDal.Text, dtDal)
        End If
        odsIncoerenzeIstat.SelectParameters("DataInserimentoDal").DefaultValue = dtDal

        If txtFiltriDataAl.Text.Length > 0 Then
            DateTime.TryParse(txtFiltriDataAl.Text, dtAl)
            'aggiungo un giorno perchè la data viene passata con orario 00:00
            dtAl = CDate(dtAl).AddDays(1)
        End If
        odsIncoerenzeIstat.SelectParameters("DataInserimentoAl").DefaultValue = dtAl

        odsIncoerenzeIstat.SelectParameters("Provenienza").DefaultValue = If(ddlFiltriProvenienza.SelectedIndex > 0, ddlFiltriProvenienza.SelectedValue, Nothing)
        odsIncoerenzeIstat.SelectParameters("IdProvenienza").DefaultValue = If(txtFiltriIDProvenienza.Text.Length > 0, txtFiltriIDProvenienza.Text, Nothing)

        If txtFiltriCodIstat.Text.Length > 0 Then
            txtFiltriCodIstat.Text = txtFiltriCodIstat.Text.PadLeft(6, "0"c)
            odsIncoerenzeIstat.SelectParameters("CodiceIstat").DefaultValue = txtFiltriCodIstat.Text
        Else
            odsIncoerenzeIstat.SelectParameters("CodiceIstat").DefaultValue = Nothing
        End If

        odsIncoerenzeIstat.SelectParameters("Top").DefaultValue = ddlFiltriTop.SelectedValue
    End Sub

    Protected Function ValidazioneFiltri() As Boolean
        Dim dtDal As Object = Nothing
        Dim dtAl As Object = Nothing
        Dim bValidazione As Boolean = True
        Dim sMess As String = ""

        'If Not (txtFiltriDataDal.Text.Length > 0 OrElse
        '       txtFiltriDataAl.Text.Length > 0 OrElse
        '       ddlFiltriProvenienza.SelectedIndex > 0 OrElse
        '       txtFiltriIDProvenienza.Text.Length > 0 OrElse
        '       txtFiltriCodIstat.Text.Length > 0) Then
        '    sMess = sMess & "Valorizzare almeno uno dei filtri." & "<br/>"
        '    bValidazione = False
        'End If


        If txtFiltriDataDal.Text.Trim.Length = 0 Then
            sMess = sMess & "Fornire una Data Dal." & "<br/>"
            bValidazione = False
        End If

        If txtFiltriDataDal.Text.Length > 0 AndAlso Not DateTime.TryParse(txtFiltriDataDal.Text, dtDal) Then
            sMess = sMess & "Data Dal non valida." & "<br/>"
            bValidazione = False
        End If

        If txtFiltriDataAl.Text.Length > 0 AndAlso Not DateTime.TryParse(txtFiltriDataAl.Text, dtAl) Then
            sMess = sMess & "Data Al non valida." & "<br/>"
            bValidazione = False
        End If

        LabelError.Visible = sMess.Length > 0
        LabelError.Text = sMess
        mbodsIncoerenzeIstat_CancelSelect = Not bValidazione
        Return bValidazione

    End Function
End Class