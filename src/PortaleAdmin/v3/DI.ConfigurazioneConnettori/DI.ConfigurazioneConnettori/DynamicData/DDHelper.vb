Imports System.Collections.Generic
Imports System.Linq
Imports System.Web
Imports System.Linq.Expressions
Imports System.ComponentModel
Imports System.Globalization
Imports System.Web.DynamicData

Public Class DDHelper

	''' <summary>
	''' Descrizione completa + nome della tabella
	''' </summary>
	Public Shared Function GetTableFullName(table As MetaTable) As String
		Return $"Connettori / {table.DisplayName.Replace("/", " / ")}"
	End Function
End Class

Public NotInheritable Class ExpressionHelper
	Private Sub New()
	End Sub
	Public Shared Function GetValue(exp As Expression) As Expression
		Dim realType As Type = GetUnderlyingType(exp.Type)
		If realType = exp.Type Then
			Return exp
		End If

		Return Expression.Convert(exp, realType)
	End Function

	Private Shared Function RemoveNullableFromType(type As Type) As Type
		Return If(Nullable.GetUnderlyingType(type), type)
	End Function

	Public Shared Function GetUnderlyingType(type As Type) As Type
		Return RemoveNullableFromType(type)
	End Function

	Public Shared Function Join(expressions As IEnumerable(Of Expression), joinFunction As Func(Of Expression, Expression, Expression)) As Expression
		Dim result As Expression = Nothing
		For Each e As Expression In expressions
			If e Is Nothing Then
				Continue For
			End If

			If result Is Nothing Then
				result = e
			Else
				result = joinFunction(result, e)
			End If
		Next
		Return result
	End Function

	Public Shared Function CreatePropertyExpression(parameterExpression As Expression, propertyName As String) As Expression
		Dim propExpression As Expression = Nothing
		Dim props As String() = propertyName.Split("."c)
		For Each p In props
			If propExpression Is Nothing Then
				propExpression = Expression.PropertyOrField(parameterExpression, p)
			Else
				propExpression = Expression.PropertyOrField(propExpression, p)
			End If
		Next
		Return propExpression
	End Function

	Private Shared Function TypeAllowsNull(type As Type) As Boolean
		Return Nullable.GetUnderlyingType(type) IsNot Nothing OrElse Not type.IsValueType
	End Function

	Public Shared Function ChangeType(value As Object, type As Type) As Object
		If type Is Nothing Then
			Throw New ArgumentNullException("type")
		End If

		If value Is Nothing Then
			If TypeAllowsNull(type) Then
				Return Nothing
			End If
			Return Convert.ChangeType(value, type, CultureInfo.CurrentCulture)
		End If

		If value.[GetType]() = type Then
			Return value
		End If

		type = RemoveNullableFromType(type)

		Dim converter As TypeConverter = TypeDescriptor.GetConverter(type)
		If converter.CanConvertFrom(value.[GetType]()) Then
			Return converter.ConvertFrom(value)
		End If

		Dim otherConverter As TypeConverter = TypeDescriptor.GetConverter(value.[GetType]())
		If otherConverter.CanConvertTo(type) Then
			Return otherConverter.ConvertTo(value, type)
		End If

		Throw New InvalidOperationException([String].Format("Cannot convert type '{0}' to '{1}'", value.[GetType](), type))
	End Function

	Public Shared Function BuildItemsQuery(query As IQueryable, metaTable As MetaTable, columns As IList(Of MetaColumn), values As String()) As MethodCallExpression
		' row
		Dim rowParam = Expression.Parameter(metaTable.EntityType, "row")
		' row.ID == 1
		Dim whereBody = BuildWhereBody(rowParam, columns, values)
		' row => row.ID == 1
		Dim whereLambda = Expression.Lambda(whereBody, rowParam)
		' Items.Where(row => row.ID == 1)
		Dim whereCall = Expression.[Call](GetType(Queryable), "Where", New Type() {metaTable.EntityType}, query.Expression, whereLambda)

		Return whereCall
	End Function

	Public Shared Function BuildWhereBody(parameter As ParameterExpression, columns As IList(Of MetaColumn), values As String()) As BinaryExpression
		' row.ID == 1
		Dim whereBody = BuildWhereBodyFragment(parameter, columns(0), values(0))
		For i As Integer = 1 To values.Length - 1
			' row.ID == 1 && row.ID2 == 2
			whereBody = Expression.[AndAlso](whereBody, BuildWhereBodyFragment(parameter, columns(i), values(i)))
		Next

		Return whereBody
	End Function

	Private Shared Function BuildWhereBodyFragment(parameter As ParameterExpression, column As MetaColumn, value As String) As BinaryExpression
		' row.ID
		Dim [property] = Expression.[Property](parameter, column.Name)
		' row.ID == 1
		Return Expression.Equal([property], Expression.Constant(ChangeValueType(column, value)))
	End Function

	Private Shared Function ChangeValueType(column As MetaColumn, value As String) As Object
		If column.ColumnType = GetType(Guid) Then
			Return New Guid(value)
		Else
			Return Convert.ChangeType(value, column.TypeCode, CultureInfo.InvariantCulture)
		End If
	End Function
End Class
