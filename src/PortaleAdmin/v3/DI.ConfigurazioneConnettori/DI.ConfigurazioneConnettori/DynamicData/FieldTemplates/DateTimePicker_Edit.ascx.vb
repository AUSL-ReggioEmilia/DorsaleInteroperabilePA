Imports System.Web.DynamicData

Partial Class DateTimePicker_EditField
    Inherits System.Web.DynamicData.FieldTemplateUserControl


    Public Overrides ReadOnly Property DataControl() As Control
        Get
            Return TextBox1
        End Get
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs)
        TextBox1.MaxLength = Column.MaxLength
        If (Column.MaxLength < 20) Then
            TextBox1.Columns = Column.MaxLength
        End If
        TextBox1.ToolTip = Column.Description
        SetUpValidator(RequiredFieldValidator1)
        SetUpValidator(RegularExpressionValidator1)
        SetUpValidator(DynamicValidator1)

        SetUpValidator(RequiredFieldValidator2)
        SetUpValidator(RegularExpressionValidator2)
        SetUpValidator(DynamicValidator2)
    End Sub

    Protected Overrides Sub ExtractValues(ByVal dictionary As IOrderedDictionary)

        '
        ' Ottengo data e ora dalle TextBox
        '
        Dim data As String = TextBox1.Text
        Dim ora As String = TextBox2.Text
        '
        ' Eseguo un replace della stringa per ottenere un orario nel formato hh:mm e non hh.mm
        '
        ora = Replace(ora, ".", ":")
        '
        ' Compongo il valore da restituire unendo data e ora
        '
        dictionary(Column.Name) = ConvertEditedValue(String.Format("{0} {1}", data, ora))
    End Sub

    Protected Overrides Sub OnDataBinding(ByVal e As EventArgs)
        MyBase.OnDataBinding(e)
        Dim data As String = String.Empty
        Dim ora As String = String.Empty
        '
        ' Ottengo il valore da inserire nella textbox.
        ' val sarà valorizzato solo se siamo in edit.
        '
        Dim val As Object = FieldValue

        '
        ' Se val e sVal non sono vuoti allora ottengo data e ora.
        '
        If val IsNot Nothing Then
            Dim sVal As String = val.ToString
            If Not String.IsNullOrEmpty(val.ToString()) Then
                data = sVal.Substring(0, 10)

                '
                ' Prendo solo 5 caratteri ovvero ore e minuti.
                '
                ora = sVal.Substring(11, 5)
                '
                ' Eseguo un replace della stringa per ottenere un orario nel formato hh:mm e non hh.mm
                '
                ora = Replace(ora, ".", ":")

                TextBox1.Text = data
                TextBox2.Text = ora
            End If
        End If
    End Sub

End Class
