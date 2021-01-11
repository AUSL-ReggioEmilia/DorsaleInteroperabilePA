Imports System.Linq.Expressions
Imports System.Reflection

Class Search
    Inherits QueryableFilterUserControl

    Private Shadows ReadOnly Property Column As MetaColumn
        Get
            Return CType(MyBase.Column, MetaColumn)
        End Get
    End Property

    ''' <summary>
    ''' Crea una sessionKey da usare per salvare in sessione i valori di filtro
    ''' </summary>
    ''' <returns></returns>
    Private ReadOnly Property SessionKey() As String
        Get
            Dim TableName = DynamicDataRouteHandler.GetRequestMetaTable(Context)
            Return String.Format("sessionKey:{0}_{1}", Column.Name.ToString(), TableName.DisplayName & TableName.EntityType.FullName.ToString())
        End Get
    End Property

    Public Overrides Function GetQueryable(source As IQueryable) As IQueryable

		If Column.TypeCode <> TypeCode.[String] Then
			Return source
		End If

		If TextBox1.Text.Length = 0 Then
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

    Protected Sub Button1_Click(sender As Object, e As EventArgs) Handles Button1.Click
        'Salvo in sessione il valore della dropdownlist
        HttpContext.Current.Session.Add(Me.SessionKey, TextBox1.Text)

        OnFilterChanged()
    End Sub

    Private Sub Search_Init(sender As Object, e As EventArgs) Handles Me.Init
        'Se il valore in sessione è valorizzato allora valorizzo InitialValue
        If Not HttpContext.Current.Session(Me.SessionKey) Is Nothing Then
            TextBox1.Text = HttpContext.Current.Session(Me.SessionKey).ToString()
        End If
    End Sub

    Public Overrides ReadOnly Property FilterControl As Control
        Get
            Return TextBox1
        End Get
    End Property

End Class
