Imports System
Imports System.Web.UI
Imports System.Web.UI.WebControls

Public Class LogAggancioPaziente
    Inherits System.Web.UI.Page

#Region "Property di pagina"
    Private ReadOnly msPAGEKEY As String = Page.GetType().BaseType.FullName

    Private gvCancelSelect = True

    'Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

    'End Sub

    Private Sub LogAggancioPaziente_PreRenderComplete(sender As Object, e As EventArgs) Handles Me.PreRenderComplete
        Try
            '
            'Setta il pulsante di default.
            '
            Me.Form.DefaultButton = Me.SearchButton.UniqueID
            If Not Page.IsPostBack Then
                '
                'Ricarica i filtri prendendoli dalla sessione.
                '
                FilterHelper.Restore(filterPanel, msPAGEKEY)

                '
                ' Inizializzo txtDataDal (solo vuota)
                '

                If String.IsNullOrEmpty(txtDataDal.Text) Then
                    txtDataDal.Text = Date.Now.Date.AddMonths(-1).ToString("dd/MM/yyyy")
                End If
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

#End Region

#Region "ObjectDataSource"
    Private Sub odsMain_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsMain.Selected
        '
        'Gestisco eventuali errori.
        '
        GestioneErrori.ObjectDataSource_TrapError(e, lblError)
    End Sub

    Private Sub odsMain_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsMain.Selecting
        Try
            '
            'Cancello la query se gvCancelSelect è true.
            '
            If gvCancelSelect Then
                e.Cancel = True
                Exit Sub
            End If
            '
            ' Passo il numero max di record da restituire
            '
            Dim iMaxRow As Integer = CType(ddlMaxRow.SelectedValue, Integer)
            e.InputParameters("MaxRow") = iMaxRow
            '
            ' Passo i campi Data: sono già stati validati
            '
            If Not String.IsNullOrEmpty(txtDataDal.Text) Then
                e.InputParameters("DataDal") = CType(txtDataDal.Text, DateTime)
            End If

            If Not String.IsNullOrEmpty(txtDataAl.Text) Then
                e.InputParameters("DataAl") = CType(txtDataDal.Text, DateTime)
            End If
            '
            '
            '
            Dim sddlOggetti_SelectedValue As String = ddlOggetti.SelectedValue
            If String.IsNullOrEmpty(sddlOggetti_SelectedValue) OrElse sddlOggetti_SelectedValue.ToUpper = "TUTTI" Then
                sddlOggetti_SelectedValue = Nothing
            End If
            e.InputParameters("Oggetto") = sddlOggetti_SelectedValue

        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(lblError, sMessage)
        End Try
    End Sub
#End Region


#Region "Filtri"
    Private Sub SearchButton_Click(sender As Object, e As EventArgs) Handles SearchButton.Click
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
                gvMain.DataBind()
            End If
        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(lblError, sMessage)
        End Try
    End Sub

    ''' <summary>
    ''' Verifica se i valori dei filtri sono impostati correttamente.
    ''' </summary>
    ''' <returns></returns>
    Private Function ValidateFilters() As Boolean
        Dim result As Boolean = True

        If String.IsNullOrEmpty(txtDataDal.Text) Then
            Utility.ShowErrorLabel(lblError, "Il campo 'Data Dal' è obbligatorio.")
            result = False
        End If

        '
        ' Verifico se txtDataDal.Text contiene una data valida.
        '
        If Not String.IsNullOrEmpty(txtDataDal.Text) AndAlso Not Utility.SQLTypes.IsValidDateTime(txtDataDal.Text) Then
            Utility.ShowErrorLabel(lblError, "Il campo 'Data Dal' non contiene una data valida.")
            result = False
        End If

        '
        ' Verifico se txtDataAl.Text contiene una data valida.
        '
        If Not String.IsNullOrEmpty(txtDataAl.Text) AndAlso Not Utility.SQLTypes.IsValidDateTime(txtDataAl.Text) Then
            Utility.ShowErrorLabel(lblError, "Il campo 'Data Al' non contiene una data valida.")
            result = False
        End If
        '
        '
        '
        Return result
    End Function


    Protected Sub ClearFiltersButton_Click(sender As Object, e As EventArgs) Handles ClearFiltersButton.Click
        Try
            FilterHelper.Clear(filterPanel, msPAGEKEY)
        Catch ex As Exception
            Dim sMessage As String = Utility.TrapError(ex, True)
            Utility.ShowErrorLabel(lblError, sMessage)
        End Try
    End Sub
#End Region



End Class