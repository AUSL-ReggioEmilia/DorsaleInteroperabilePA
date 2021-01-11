Imports System.ComponentModel
Imports System.Linq.Expressions

Partial Public Class DateFilter
	Inherits System.Web.DynamicData.QueryableFilterUserControl

	Public ReadOnly Property sDate As String
		Get
			Return txtDate.Text
		End Get
	End Property

    Public Overrides ReadOnly Property FilterControl As Control
        Get
            Return txtDate
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

    Protected Sub Page_Init(sender As Object, e As EventArgs)
        'Se il valore in sessione è valorizzato allora valorizzo InitialValue
        If Not HttpContext.Current.Session(Me.SessionKey) Is Nothing Then
            txtDate.Text = HttpContext.Current.Session(Me.SessionKey).ToString()
        End If
    End Sub

    Public Overrides Function GetQueryable(source As IQueryable) As IQueryable

		If String.IsNullOrEmpty(sDate) Then Return source
		If Not txtDateValidator.IsValid Then Return source
		Dim dDate As Date
		If Not Date.TryParse(sDate, dDate) Then Return source

		Return ApplyEqualityFilter(source, Column.Name, dDate)

	End Function

    Protected Sub Button1_Click(sender As Object, e As EventArgs) Handles Button1.Click
        'Salvo in sessione il valore della dropdownlist
        HttpContext.Current.Session.Add(Me.SessionKey, txtDate.Text)

        OnFilterChanged()
    End Sub

End Class
