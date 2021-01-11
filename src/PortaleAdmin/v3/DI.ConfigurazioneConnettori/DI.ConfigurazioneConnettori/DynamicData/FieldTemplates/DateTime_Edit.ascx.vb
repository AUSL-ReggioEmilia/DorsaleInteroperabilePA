﻿Imports System.ComponentModel.DataAnnotations
Imports System.Web.DynamicData
Imports System.Web

Class DateTime_EditField
    Inherits FieldTemplateUserControl

    Private Shared DefaultDateAttribute As DataTypeAttribute = New DataTypeAttribute(DataType.DateTime)
    
    Public Overrides ReadOnly Property DataControl As Control
        Get
            Return TextBox1
        End Get
    End Property
    
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs)
        TextBox1.ToolTip = Column.Description
        SetUpValidator(RequiredFieldValidator1)
        'SetUpValidator(RegularExpressionValidator2)
        SetUpValidator(RegularExpressionValidator1)
        SetUpValidator(DynamicValidator1)
        SetUpCustomValidator(DateValidator)

		If Me.Column.DataFormatString = "{0:d}" Then
			'PREDISPONGO LA TEXTBOX PER DATA SENZA ORA
			TextBox1.Attributes.Item("placeholder") = "es: 22/11/1996"
			TextBox1.MaxLength = 10
			RegularExpressionValidator1.ErrorMessage = String.Format("Il campo {0} non è nel formato corretto: inserire una data nel formato <strong>gg/mm/aaaa</strong>", Column.DisplayName)
		Else
			RegularExpressionValidator1.ErrorMessage = String.Format("Il campo {0} non è nel formato corretto: inserire una data nel formato <strong>gg/mm/aaaa</strong> oppure <strong>gg/mm/aaaa hh:mm</strong>", Column.DisplayName)
		End If
	End Sub


	Private Sub SetUpCustomValidator(ByVal validator As CustomValidator)
        If Column.DataTypeAttribute IsNot Nothing Then
            Select Case (Column.DataTypeAttribute.DataType)
                Case DataType.Date,
                     DataType.DateTime,
                     DataType.Time
    
                    validator.Enabled = True
                    DateValidator.ErrorMessage = HttpUtility.HtmlEncode(Column.DataTypeAttribute.FormatErrorMessage(Column.DisplayName))
            End Select
        ElseIf Column.ColumnType.Equals(GetType(DateTime)) Then
            validator.Enabled = True
            DateValidator.ErrorMessage = HttpUtility.HtmlEncode(DefaultDateAttribute.FormatErrorMessage(Column.DisplayName))
        End If
    End Sub
    
    Protected Sub DateValidator_ServerValidate(ByVal source As Object, ByVal args As ServerValidateEventArgs)
        Dim dummyResult As DateTime
        args.IsValid = DateTime.TryParse(args.Value, dummyResult)
    End Sub
    
    Protected Overrides Sub ExtractValues(ByVal dictionary As IOrderedDictionary)
        dictionary(Column.Name) = ConvertEditedValue(TextBox1.Text)
    End Sub
    
End Class
