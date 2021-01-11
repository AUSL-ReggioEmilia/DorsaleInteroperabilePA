<System.ComponentModel.DataObject(True)> _
Public Class DataManager

    Inherits System.ComponentModel.Component

#Region " Component Designer generated code "
    Public Sub New(ByVal Container As System.ComponentModel.IContainer)
        MyClass.New()

        'Required for Windows.Forms Class Composition Designer support
        Container.Add(Me)
    End Sub

    Public Sub New()
        MyBase.New()

        'This call is required by the Component Designer.
        InitializeComponent()

        'Add any initialization after the InitializeComponent() call

    End Sub

    'Component overrides dispose to clean up the component list.
    Protected Overloads Overrides Sub Dispose(ByVal disposing As Boolean)
        If disposing Then
            If Not (components Is Nothing) Then
                components.Dispose()
            End If
        End If
        MyBase.Dispose(disposing)
    End Sub

    'Required by the Component Designer
    Private components As System.ComponentModel.IContainer
    Friend WithEvents SqlConnection As System.Data.SqlClient.SqlConnection


    Private Sub InitializeComponent()
        Dim configurationAppSettings As System.Configuration.AppSettingsReader = New System.Configuration.AppSettingsReader()
        Me.SqlConnection = New System.Data.SqlClient.SqlConnection()
        '
        'SqlConnection
        '
        Me.SqlConnection.ConnectionString = CType(configurationAppSettings.GetValue("sqlconnMain.ConnectionString", GetType(String)), String)
        Me.SqlConnection.FireInfoMessageEventOnUserErrors = False

    End Sub
#End Region

    Public ReadOnly Property Connection() As System.Data.SqlClient.SqlConnection
        '
        ' Restituisce la connessione usata dalla classe
        '
        Get
            Return SqlConnection
        End Get
    End Property

    Private Sub SetTransaction(ByRef oDataAdapter As System.Data.SqlClient.SqlDataAdapter, ByVal oTransaction As System.Data.SqlClient.SqlTransaction)
        '
        ' Imposta la transazione negli SqlCommand del DataAdapter
        '
        With oDataAdapter
            If Not .SelectCommand Is Nothing Then
                .SelectCommand.Transaction = oTransaction
            End If
            If Not .InsertCommand Is Nothing Then
                .InsertCommand.Transaction = oTransaction
            End If
            If Not .DeleteCommand Is Nothing Then
                .DeleteCommand.Transaction = oTransaction
            End If
            If Not .UpdateCommand Is Nothing Then
                .UpdateCommand.Transaction = oTransaction
            End If
        End With
    End Sub

End Class
