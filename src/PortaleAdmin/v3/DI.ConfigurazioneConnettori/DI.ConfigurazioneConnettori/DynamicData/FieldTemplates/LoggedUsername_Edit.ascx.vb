Imports System.ComponentModel.DataAnnotations
Imports System.Web.DynamicData
Imports System.Web

''' <summary>
''' Label in readonly che mostra il nome dell'utente correntmente loggato
''' </summary>
Class LoggedUsername_Edit
	Inherits FieldTemplateUserControl

	Public Overrides ReadOnly Property DataControl As Control
		Get
			Return Literal2
		End Get
	End Property

	Protected Overrides Sub ExtractValues(ByVal dictionary As IOrderedDictionary)
		If My.User.IsAuthenticated Then
			dictionary(Column.Name) = My.User.Name
		Else
			dictionary(Column.Name) = Nothing
		End If

	End Sub

End Class
