Imports System.Linq.Expressions
Imports System.Reflection

Class Search
	Inherits QueryableFilterUserControl
	Public Overrides Function GetQueryable(source As IQueryable) As IQueryable

		If Column.TypeCode <> TypeCode.[String] Then
			Return source
		End If

		Dim searchString As String = TextBox1.Text
		Dim searchFilter As ConstantExpression = Expression.Constant(searchString)
		Dim parameter As ParameterExpression = Expression.Parameter(source.ElementType)
		Dim prop As MemberExpression = Expression.[Property](parameter, Me.Column.Name)

		If Nullable.GetUnderlyingType(prop.Type) IsNot Nothing Then
			prop = Expression.[Property](prop, "Value")
		End If
		Dim method As MethodInfo = GetType([String]).GetMethod("Contains", New Type() {GetType([String])})
		Dim containsMethodExp = Expression.[Call](prop, method, searchFilter)
		Dim containsLambda = Expression.Lambda(containsMethodExp, parameter)
		Dim resultExpression = Expression.[Call](GetType(Queryable), "Where", New Type() {source.ElementType}, source.Expression, Expression.Quote(containsLambda))

		Return source.Provider.CreateQuery(resultExpression)

	End Function

	Protected Sub Button1_Click(sender As Object, e As EventArgs)
		OnFilterChanged()
	End Sub


End Class
