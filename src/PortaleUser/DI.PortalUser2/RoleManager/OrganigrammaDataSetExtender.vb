Imports OrganigrammaDataSetTableAdapters

Public Class RegimiOttieniPerUnitaOperativaTableAdapter_Custom
    Inherits RegimiOttieniPerUnitaOperativaTableAdapter

    Public Sub New()
        MyBase.New()
        MyBase.Connection.ConnectionString = ""
    End Sub

    Public Sub New(ByVal ConnectionString As String)
        MyBase.New()
        MyBase.Connection.ConnectionString = ConnectionString
    End Sub

    Public Property ConnectionString() As String
        Get
            Return MyBase.Connection.ConnectionString
        End Get
        Set(ByVal value As String)
            MyBase.Connection.ConnectionString = value
        End Set
    End Property
End Class


