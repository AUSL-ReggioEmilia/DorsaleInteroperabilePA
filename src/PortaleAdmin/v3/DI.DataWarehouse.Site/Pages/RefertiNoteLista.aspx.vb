Imports System
Imports System.Data
Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports DI.DataWarehouse.Admin.Data
Imports System.Collections
Imports DI.PortalAdmin.Data

Namespace DI.DataWarehouse.Admin

    Partial Class RefertiNoteLista
        Inherits Page

        Private _pageId As String
        Private _cancelSelectOperation As Boolean = False

        Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load
            Try
                _pageId = Me.GetType().Name

                If Not IsPostBack Then
                    LoadFilterValues()
                    ExecuteSearch()
                End If

            Catch ex As Exception
                Dim sMessage As String = Utility.TrapError(ex, True)
                Utility.ShowErrorLabel(LabelError, sMessage)
            End Try
        End Sub

        Protected Sub CercaButton_Click(ByVal sender As Object, ByVal e As EventArgs) Handles CercaButton.Click

            ExecuteSearch()

        End Sub

        Protected Sub DataSourceMain_Selected(ByVal sender As Object, ByVal e As ObjectDataSourceStatusEventArgs) Handles DataSourceMain.Selected

			If Not ObjectDataSource_TrapError(sender, e) AndAlso DirectCast(e.ReturnValue, DataTable).Rows.Count = 0 Then
				If IsPostBack Then
					NoRecordFoundLabel.Text = "Non è stato trovato nessun record."
				End If
			End If
        End Sub

        Protected Sub DataSourceMain_Selecting(ByVal sender As Object, ByVal e As ObjectDataSourceSelectingEventArgs) Handles DataSourceMain.Selecting
            Try
                If _cancelSelectOperation Then
                    e.Cancel = True
                Else
                    Dim text = "Lista Note|Parametri: "
                    For Each item As DictionaryEntry In e.InputParameters
                        If item.Value IsNot Nothing Then
                            text &= item.Key & "=" & item.Value.ToString() & "; "
                        End If
                    Next
                    DataAdapterManager.PortalAdminDataAdapterManager.TracciaAccessi(User.Identity.Name, PortalsNames.DwhClinico, text)
                End If
            Catch ex As Exception
                Dim sMessage As String = Utility.TrapError(ex, True)
                Utility.ShowErrorLabel(LabelError, sMessage)
            End Try
        End Sub

        Private Sub ExecuteSearch()
            Try
                If ValidateFiltersValue() Then
                    SetSelectParameters()
                    GridViewMain.DataBind()
                    SaveFilterValues()
                Else
                    _cancelSelectOperation = True
                End If
            Catch ex As Exception
                Dim sMessage As String = Utility.TrapError(ex, True)
                Utility.ShowErrorLabel(LabelError, sMessage)
            End Try
        End Sub

        Private Sub LoadFilterValues()
            NosologicoTextBox.Text = CStr(Me.Session(_pageId & NosologicoTextBox.ID))
            NumeroRefertoTextBox.Text = CStr(Me.Session(_pageId & NumeroRefertoTextBox.ID))
            DataDalTextBox.Text = CStr(Me.Session(_pageId & DataDalTextBox.ID))
            DataAlTextBox.Text = CStr(Me.Session(_pageId & DataAlTextBox.ID))
            VisualizzaNoteCancellateCheckBox.Checked = CBool(Me.Session(_pageId & VisualizzaNoteCancellateCheckBox.ID))
        End Sub

        Private Sub SaveFilterValues()
            Me.Session(_pageId & NosologicoTextBox.ID) = NosologicoTextBox.Text
            Me.Session(_pageId & NumeroRefertoTextBox.ID) = NumeroRefertoTextBox.Text
            Me.Session(_pageId & DataDalTextBox.ID) = DataDalTextBox.Text
            Me.Session(_pageId & DataAlTextBox.ID) = DataAlTextBox.Text
            Me.Session(_pageId & VisualizzaNoteCancellateCheckBox.ID) = VisualizzaNoteCancellateCheckBox.Checked
        End Sub

        Private Function ValidateFiltersValue() As Boolean

            Dim message = String.Empty
            Dim isValid = True

            If NosologicoTextBox.Text.Length = 0 AndAlso NumeroRefertoTextBox.Text.Length = 0 AndAlso _
                DataDalTextBox.Text.Length = 0 AndAlso DataAlTextBox.Text.Length = 0 Then

                message = "Almeno uno dei parametri 'Nosologico', 'Numero Referto', 'Data dal', 'Data al' deve essere valorizzato."
                isValid = False
            Else
                Dim parsedData As DateTime

                If DataDalTextBox.Text.Length > 0 AndAlso Not DateTime.TryParse(DataDalTextBox.Text, parsedData) Then

                    message &= Environment.NewLine & "Il valore 'Dal' non è una data corretta!"
                    isValid = False
                End If

                If DataAlTextBox.Text.Length > 0 AndAlso Not Date.TryParse(DataAlTextBox.Text, parsedData) Then

                    message &= Environment.NewLine & "Il valore 'Al' non è una data corretta!"
                    isValid = False
                End If
            End If

            If IsPostBack Then
                LabelError.Text = message
            End If

            Return isValid
        End Function

        Private Sub SetSelectParameters()

            DataSourceMain.SelectParameters("NumeroReferto").DefaultValue = NumeroRefertoTextBox.Text
            DataSourceMain.SelectParameters("NumeroNosologico").DefaultValue = NosologicoTextBox.Text

            DataSourceMain.SelectParameters("DataDal").DefaultValue = Nothing
            DataSourceMain.SelectParameters("DataAl").DefaultValue = Nothing

            If DataDalTextBox.Text.Length > 0 Then
                DataSourceMain.SelectParameters("DataDal").DefaultValue = DataDalTextBox.Text
            End If

            If DataAlTextBox.Text.Length > 0 Then
                DataSourceMain.SelectParameters("DataAl").DefaultValue = DataAlTextBox.Text
            End If

            DataSourceMain.SelectParameters("VisualizzaNoteCancellate").DefaultValue = VisualizzaNoteCancellateCheckBox.Checked.ToString()
        End Sub


#Region "Funzioni"

		''' <summary>
		''' Gestisce gli errori del ObjectDataSource in maniera pulita
		''' </summary>
		''' <returns>True se si è verificato un errore</returns>
		Private Function ObjectDataSource_TrapError(ods As ObjectDataSourceView, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) As Boolean
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


#End Region

    End Class

End Namespace