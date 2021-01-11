Imports System.Linq.Expressions

Class BooleanFilter
    Inherits QueryableFilterUserControl

    Private Const NullValueString As String = "[null]"

    Public Overrides ReadOnly Property FilterControl As Control
        Get
            Return DropDownList1
        End Get
    End Property

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


    Protected Sub Page_Init(ByVal sender As Object, ByVal e As EventArgs)
        If Not Column.ColumnType.Equals(GetType(System.Boolean)) Then
            Throw New InvalidOperationException(String.Format("A boolean filter was loaded for column '{0}' but the column has an incompatible type '{1}'.", Column.Name, Column.ColumnType))
        End If
        If Not Page.IsPostBack Then
			DropDownList1.Items.Add(New ListItem("Tutti", String.Empty))
			If Not Column.IsRequired Then
				DropDownList1.Items.Add(New ListItem("[Non impostato]", NullValueString))
			End If
			DropDownList1.Items.Add(New ListItem("Vero", Boolean.TrueString))
			DropDownList1.Items.Add(New ListItem("Falso", Boolean.FalseString))
            ' Set the initial value if there is one
            Dim initialValue As String = DefaultValue


            'Se il valore in sessione è valorizzato allora valorizzo InitialValue
            If Not HttpContext.Current.Session(Me.SessionKey) Is Nothing Then
                initialValue = HttpContext.Current.Session(Me.SessionKey).ToString()
            End If

            If Not String.IsNullOrEmpty(initialValue) Then
                DropDownList1.SelectedValue = initialValue
            End If
        End If
    End Sub
    
    Public Overrides Function GetQueryable(ByVal source As IQueryable) As IQueryable
        Dim selectedValue As String = DropDownList1.SelectedValue
        If String.IsNullOrEmpty(selectedValue) Then
            Return source
        End If
        Dim value As Object = selectedValue
        If (selectedValue = NullValueString) Then
            value = Nothing
        End If
        If DefaultValues IsNot Nothing Then
            DefaultValues(Column.Name) = value
        End If
        Return ApplyEqualityFilter(source, Column.Name, value)
    End Function

    Protected Sub DropDownList1_SelectedIndexChanged(ByVal sender As Object, ByVal e As EventArgs)
        'Salvo in sessione il valore della dropdownlist
        HttpContext.Current.Session.Add(Me.SessionKey, DropDownList1.SelectedValue)

        OnFilterChanged()
    End Sub

End Class
