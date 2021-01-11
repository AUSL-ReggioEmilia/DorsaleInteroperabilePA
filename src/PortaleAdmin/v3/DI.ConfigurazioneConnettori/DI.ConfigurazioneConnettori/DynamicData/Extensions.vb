
Imports System.Linq.Expressions

Public Module ExtensionMethods

#Region "Attribute methods"
	''' <summary>
	''' Get the attribute or a default instance of the attribute
	''' if the Table attribute do not contain the attribute
	''' </summary>
	''' <typeparam name="T">Attribute type</typeparam>
	''' <param name="table">
	''' Table to search for the attribute on.
	''' </param>
	''' <returns>
	''' The found attribute or a default 
	''' instance of the attribute of type T
	''' </returns>
	<Runtime.CompilerServices.Extension>
	Public Function GetAttributeOrDefault(Of T As {Attribute, New})(table As MetaTable) As T
		Return table.Attributes.OfType(Of T)().DefaultIfEmpty(New T()).FirstOrDefault()
	End Function

	''' <summary>
	''' Get the attribute of type T or null if not found
	''' </summary>
	''' <typeparam name="T">
	''' Attribute type
	''' </typeparam>
	''' <param name="table">
	''' Table to search for the attribute on.
	''' </param>
	''' <returns>
	''' Returns the attribute T or null
	''' </returns>
	<System.Runtime.CompilerServices.Extension>
	Public Function GetAttributet(Of T As Attribute)(table As MetaTable) As T
		Return table.Attributes.OfType(Of T)().FirstOrDefault()
	End Function

	''' <summary>
	''' Get the attribute or a default instance of the attribute
	''' if the Column attribute do not contain the attribute
	''' </summary>
	''' <typeparam name="T">
	''' Attribute type
	''' </typeparam>
	''' <param name="column">
	''' Column to search for the attribute on.
	''' </param>
	''' <returns>
	''' The found attribute or a default 
	''' instance of the attribute of type T
	''' </returns>
	<System.Runtime.CompilerServices.Extension>
	Public Function GetAttributeOrDefault(Of T As {Attribute, New})(column As MetaColumn) As T
		Return column.Attributes.OfType(Of T)().DefaultIfEmpty(New T()).FirstOrDefault()
	End Function

	''' <summary>
	''' Get the attribute of type T or null if not found
	''' </summary>
	''' <typeparam name="T">Attribute type</typeparam>
	''' <param name="column">Column to search for the attribute on.</param>
	''' <returns>Returns the attribute T or null</returns>
	<System.Runtime.CompilerServices.Extension>
	Public Function GetAttribute(Of T As Attribute)(column As MetaColumn) As T
		Return column.Attributes.OfType(Of T)().FirstOrDefault()
	End Function
#End Region


	<Runtime.CompilerServices.Extension>
	Public Function BuildSingleItemQuery(query As IQueryable, metaTable As MetaTable, primaryKeyValues As String()) As MethodCallExpression
		' Items.Where(row => row.ID == 1)
		Dim whereCall = ExpressionHelper.BuildItemsQuery(query, metaTable, metaTable.PrimaryKeyColumns, primaryKeyValues)
		' Items.Where(row => row.ID == 1).Single()
		Dim singleCall = Expression.[Call](GetType(Queryable), "Single", New Type() {metaTable.EntityType}, whereCall)

		Return singleCall
	End Function

End Module