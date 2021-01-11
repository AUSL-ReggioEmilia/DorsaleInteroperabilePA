Imports System.ComponentModel
Imports System.Linq.Expressions

Partial Public Class DateRangeFilter
	Inherits System.Web.DynamicData.QueryableFilterUserControl

	Public ReadOnly Property DateFrom As String
		Get
			Return txbFrom.Text
		End Get
	End Property

	Public ReadOnly Property DateTo As String
		Get
			Return txbTo.Text
		End Get
	End Property

	Public Overrides ReadOnly Property FilterControl As Control
		Get
			Return txbFrom
		End Get
	End Property

	Protected Sub Page_Init(sender As Object, e As EventArgs)
		'txbFrom.ToolTip = Me.AppRelativeVirtualPath.GetFileNameTitle()
		'txbTo.ToolTip = Me.AppRelativeVirtualPath.GetFileNameTitle()
	End Sub


	Public Overrides Function GetQueryable(source As IQueryable) As IQueryable
		If [String].IsNullOrEmpty(DateFrom) AndAlso [String].IsNullOrEmpty(DateTo) Then
			Return source
		End If

		If Not txbFromDateValidator.IsValid Then Return source
		If Not txbToDateValidator.IsValid Then Return source

		Dim parameterExpression As ParameterExpression = Expression.Parameter(source.ElementType, "item")
		Dim body As Expression = BuildQueryBody(parameterExpression)

		Dim lambda As LambdaExpression = Expression.Lambda(body, parameterExpression)
		Dim whereCall As MethodCallExpression = Expression.[Call](GetType(Queryable), "Where", New Type() {source.ElementType}, source.Expression, Expression.Quote(lambda))
		Return source.Provider.CreateQuery(whereCall)
	End Function

	Private Function BuildQueryBody(parameterExpression As ParameterExpression) As Expression
		Dim propertyExpression As Expression = ExpressionHelper.GetValue(ExpressionHelper.CreatePropertyExpression(parameterExpression, Column.Name))
		'Dim converter As TypeConverter = TypeDescriptor.GetConverter(Column.ColumnType)

		Dim dDateFrom As Date
		If [String].IsNullOrEmpty(DateFrom) Then
			dDateFrom = CDate(SqlTypes.SqlDateTime.MinValue)
		Else
			dDateFrom = CDate(DateFrom)
		End If

		Dim dDateTo As Date
		If [String].IsNullOrEmpty(DateTo) Then
			dDateTo = CDate(SqlTypes.SqlDateTime.MaxValue)
		Else
			dDateTo = CDate(DateTo)
		End If

		Dim minimumComparison As BinaryExpression = BuildCompareExpression(propertyExpression, dDateFrom, AddressOf Expression.GreaterThanOrEqual)
		Dim maximumComparison As BinaryExpression = BuildCompareExpression(propertyExpression, dDateTo, AddressOf Expression.LessThanOrEqual)

		Return Expression.[AndAlso](minimumComparison, maximumComparison)
	End Function

	Private Function BuildCompareExpression(propertyExpression As Expression, value As Object, comparisonFunction As Func(Of Expression, Expression, BinaryExpression)) As BinaryExpression
		Dim valueExpression As ConstantExpression = Expression.Constant(value)
		Dim comparison As BinaryExpression = comparisonFunction(propertyExpression, valueExpression)
		Return comparison
	End Function

	Protected Sub Button1_Click(sender As Object, e As EventArgs)
		OnFilterChanged()
	End Sub

End Class
