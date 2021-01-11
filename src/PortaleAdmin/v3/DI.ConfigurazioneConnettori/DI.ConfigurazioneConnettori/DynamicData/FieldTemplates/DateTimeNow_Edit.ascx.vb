Imports System.ComponentModel.DataAnnotations
Imports System.Web.DynamicData
Imports System.Web

''' <summary>
''' Label in readonly che mostra la data e ora correnti
''' </summary>
Class DateTimeNow_Edit
	Inherits FieldTemplateUserControl

	Public Overrides ReadOnly Property DataControl As Control
		Get
			Return Literal2
		End Get
	End Property

	Protected Overrides Sub ExtractValues(ByVal dictionary As IOrderedDictionary)
		dictionary(Column.Name) = DateTime.Now
	End Sub

End Class
