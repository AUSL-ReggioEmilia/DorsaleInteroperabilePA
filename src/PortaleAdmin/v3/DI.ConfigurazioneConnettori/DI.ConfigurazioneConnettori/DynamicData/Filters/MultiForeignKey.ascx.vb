Imports System.Linq.Expressions

Partial Public Class MultiForeignKey
    Inherits QueryableFilterUserControl
    Private _selectedValues As List(Of String)

    Private Shadows ReadOnly Property Column As MetaForeignKeyColumn
        Get
            Return DirectCast(MyBase.Column, MetaForeignKeyColumn)
        End Get
    End Property

    Public Overrides ReadOnly Property FilterControl As Control
        Get
            Return CheckBoxList1
        End Get
    End Property

    Private ReadOnly Property SelectedValues() As List(Of String)
        Get
            If _selectedValues Is Nothing Then
                _selectedValues = New List(Of String)()
                For Each item As ListItem In CheckBoxList1.Items
                    If item.Selected Then
                        _selectedValues.Add(item.Value)
                    End If
                Next
            End If
            Return _selectedValues
        End Get
    End Property


    Protected Sub Page_Init(sender As Object, e As EventArgs)
        AddHandler Page.LoadComplete, New EventHandler(AddressOf Page_LoadComplete)

        If Not Page.IsPostBack Then
            'CheckBoxList1.Items.Add("Seleziona tutti")
            PopulateListControl(CheckBoxList1)
            For Each item As ListItem In CheckBoxList1.Items
                item.Selected = True
            Next
        End If
    End Sub

    Protected Sub Page_Load(sender As Object, e As EventArgs)

        Dim dropdownElementsList As List(Of ListItem) = CheckBoxList1.Items.Cast(Of ListItem)().ToList()

        If Not Page.IsPostBack Then
            BtnSelezionaTutti.Text = "Deseleziona tutti"
        Else
            If dropdownElementsList.Any(Function(x) Not x.Selected) Then
                BtnSelezionaTutti.Text = "Seleziona tutti"
            End If
        End If


    End Sub

    Private Sub BtnSelezionaTutti_Click(sender As Object, e As EventArgs) Handles BtnSelezionaTutti.Click

        Dim dropdownElementsList As List(Of ListItem) = CheckBoxList1.Items.Cast(Of ListItem)().ToList()

        If dropdownElementsList.Any(Function(x) Not x.Selected) Then
            'Seleziono tutti gli elementi
            For Each item As ListItem In CheckBoxList1.Items
                item.Selected = True
            Next
            BtnSelezionaTutti.Text = "Deseleziona tutti"
        Else
            'Deseleziono tutti gli elementi
            For Each item As ListItem In CheckBoxList1.Items
                item.Selected = False
            Next
            BtnSelezionaTutti.Text = "Seleziona tutti"
        End If

    End Sub

    Private Sub Page_LoadComplete(sender As Object, e As EventArgs)
        Dim sb As New StringBuilder()
        For Each value As String In SelectedValues
            sb.Append(value)
        Next
        Dim hashCode As Integer = sb.ToString().GetHashCode()
        Dim oldHashCode As System.Nullable(Of Integer) = DirectCast(ViewState("hashCode"), System.Nullable(Of Integer))
        If oldHashCode Is Nothing OrElse oldHashCode <> hashCode Then
            ViewState("hashCode") = hashCode
            OnFilterChanged()
        End If
    End Sub

    Public Overrides Function GetQueryable(source As IQueryable) As IQueryable
        Dim selectedValues__1 As List(Of String) = SelectedValues

        Dim parameterExpression As ParameterExpression = Expression.Parameter(source.ElementType, "item")
        Dim body As Expression = BuildQueryBody(parameterExpression, selectedValues__1)

        Dim lambda As LambdaExpression = Expression.Lambda(body, parameterExpression)
        Dim whereCall As MethodCallExpression = Expression.[Call](GetType(Queryable), "Where", New Type() {source.ElementType}, source.Expression, Expression.Quote(lambda))
        Return source.Provider.CreateQuery(whereCall)
    End Function

    Private Function BuildQueryBody(parameterExpression As ParameterExpression, selectedValues As List(Of String)) As Expression
        If selectedValues.Count = 0 Then
            ' If no subexpressions were contributed, return a false contstant expression to prevent
            ' anything from showing up

            Return Expression.Constant(False)
        Else
            Dim orFragments As New List(Of Expression)()

            For Each serializedValue As String In selectedValues
                Dim dict As New Dictionary(Of String, Object)()
                Column.ExtractForeignKey(dict, serializedValue)

                Dim andFragments As New List(Of Expression)()
                For Each entry In dict
                    Dim [property] As Expression = ExpressionHelper.CreatePropertyExpression(parameterExpression, entry.Key)
                    Dim value As Object = Convert.ChangeType(entry.Value, ExpressionHelper.GetUnderlyingType([property].Type))
                    Dim equalsExpression As Expression = Expression.Equal([property], Expression.Constant(value, [property].Type))

                    andFragments.Add(equalsExpression)
                Next
                Dim expr = ExpressionHelper.Join(andFragments, AddressOf Expression.AndAlso)
                orFragments.Add(expr)
            Next

            Return ExpressionHelper.Join(orFragments, AddressOf Expression.OrElse)
        End If
    End Function

End Class
