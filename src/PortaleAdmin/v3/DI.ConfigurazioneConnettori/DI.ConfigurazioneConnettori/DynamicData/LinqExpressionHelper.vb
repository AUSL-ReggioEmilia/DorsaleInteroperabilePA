Imports System.Collections.Generic
Imports System.Diagnostics
Imports System.Globalization
Imports System.Linq
Imports System.Linq.Expressions
Imports System.Web.DynamicData

Namespace CustomFilters
	Public Enum QueryType
		Contains
		StartsWith
		EndsWith
	End Enum

	Public NotInheritable Class LinqExpressionHelper
		Private Sub New()
		End Sub
		Public Shared Function BuildSingleItemQuery(query As IQueryable, metaTable As MetaTable, primaryKeyValues As String()) As MethodCallExpression
			' Items.Where(row => row.ID == 1)
			Dim whereCall = BuildItemsQuery(query, metaTable, metaTable.PrimaryKeyColumns, primaryKeyValues)
			' Items.Where(row => row.ID == 1).Single()
			Dim singleCall = Expression.[Call](GetType(Queryable), "Single", New Type() {metaTable.EntityType}, whereCall)

			Return singleCall
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

		Public Shared Function BuildWhereQuery(query As IQueryable, metaTable As MetaTable, column As MetaColumn, value As String) As MethodCallExpression
			' row
			Dim rowParam = Expression.Parameter(metaTable.EntityType, column.Name)
			' row.ID == 1
			Dim whereBody = BuildWhereBodyFragment(rowParam, column, value)
			' row => row.ID == 1
			Dim whereLambda = Expression.Lambda(whereBody, rowParam)
			' Items.Where(row => row.ID == 1)
			Dim whereCall = Expression.[Call](GetType(Queryable), "Where", New Type() {metaTable.EntityType}, query.Expression, whereLambda)

			Return whereCall
		End Function

		Public Shared Function BuildCustomQuery(query As IQueryable, metaTable As MetaTable, column As MetaColumn, value As String, queryType As QueryType) As MethodCallExpression
			' row
			Dim rowParam = Expression.Parameter(metaTable.EntityType, metaTable.Name)

			' row.DisplayName
			Dim [property] = Expression.[Property](rowParam, column.Name)

			' "prefix"
			Dim constant = Expression.Constant(value)

			' row.DisplayName.StartsWith("prefix")
			Dim startsWithCall = Expression.[Call]([property], GetType(String).GetMethod(queryType.ToString(), New Type() {GetType(String)}), constant)

			' row => row.DisplayName.StartsWith("prefix")
			Dim whereLambda = Expression.Lambda(startsWithCall, rowParam)

			' Customers.Where(row => row.DisplayName.StartsWith("prefix"))
			Dim whereCall = Expression.[Call](GetType(Queryable), "Where", New Type() {metaTable.EntityType}, query.Expression, whereLambda)

			Return whereCall
		End Function

		'public static MethodCallExpression BuildCustomQuery(IQueryable query, MetaTable metaTable, MetaColumn column, string value)
		'{
		'    // row
		'    var rowParam = Expression.Parameter(metaTable.EntityType, metaTable.Name);

		'    // row.DisplayName
		'    var property = Expression.Property(rowParam, column.Name);

		'    // "prefix"
		'    var constant = Expression.Constant(value);

		'    // row.DisplayName.StartsWith("prefix")
		'    var startsWithCall = Expression.Call(property, typeof(string).GetMethod("Contains", new Type[] { typeof(string) }), constant);

		'    // row => row.DisplayName.StartsWith("prefix")
		'    var whereLambda = Expression.Lambda(startsWithCall, rowParam);

		'    // Customers.Where(row => row.DisplayName.StartsWith("prefix"))
		'    var whereCall = Expression.Call(typeof(Queryable), "Where", new Type[] { metaTable.EntityType }, query.Expression, whereLambda);

		'    return whereCall;
		'}

		'public static MethodCallExpression BuildStartsWithQuery(IQueryable query, MetaTable metaTable, MetaColumn column, string value)
		'{
		'    // row
		'    var rowParam = Expression.Parameter(metaTable.EntityType, metaTable.Name);

		'    // row.DisplayName
		'    var property = Expression.Property(rowParam, column.Name);

		'    // "prefix"
		'    var constant = Expression.Constant(value);

		'    // row.DisplayName.StartsWith("prefix")
		'    var startsWithCall = Expression.Call(property, typeof(string).GetMethod("StartsWith", new Type[] { typeof(string) }), constant);

		'    // row => row.DisplayName.StartsWith("prefix")
		'    var whereLambda = Expression.Lambda(startsWithCall, rowParam);

		'    // Customers.Where(row => row.DisplayName.StartsWith("prefix"))
		'    var whereCall = Expression.Call(typeof(Queryable), "Where", new Type[] { metaTable.EntityType }, query.Expression, whereLambda);

		'    return whereCall;
		'}

		' public static MethodCallExpression BuildEndsWithQuery(IQueryable query, MetaTable metaTable, MetaColumn column, string value)
		'{
		'    // row
		'    var rowParam = Expression.Parameter(metaTable.EntityType, metaTable.Name);

		'    // row.DisplayName
		'    var property = Expression.Property(rowParam, column.Name);

		'    // "prefix"
		'    var constant = Expression.Constant(value);

		'    // row.DisplayName.StartsWith("prefix")
		'    var startsWithCall = Expression.Call(property, typeof(string).GetMethod("EndsWith", new Type[] { typeof(string) }), constant);

		'    // row => row.DisplayName.StartsWith("prefix")
		'    var whereLambda = Expression.Lambda(startsWithCall, rowParam);

		'    // Customers.Where(row => row.DisplayName.StartsWith("prefix"))
		'    var whereCall = Expression.Call(typeof(Queryable), "Where", new Type[] { metaTable.EntityType }, query.Expression, whereLambda);

		'    return whereCall;
		'}

		Public Shared Function BuildWhereBody(parameter As ParameterExpression, columns As IList(Of MetaColumn), values As String()) As BinaryExpression
			Debug.Assert(columns.Count = values.Length)
			Debug.Assert(columns.Count > 0)

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
End Namespace
