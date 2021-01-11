Imports System.Runtime.Serialization
'<Assembly: System.Runtime.Serialization.ContractNamespaceAttribute("http://schemas.progel.it/OE/ServiceFault/1.1", ClrNamespace:="ServiceFault"),
'Assembly: System.Runtime.Serialization.ContractNamespaceAttribute("http://schemas.progel.it/OE/DataFault/1.1", ClrNamespace:="DataFault"),
'Assembly: System.Runtime.Serialization.ContractNamespaceAttribute("http://schemas.progel.it/OE/ArgumentFault/1.1", ClrNamespace:="ArgumentFault"),
'Assembly: System.Runtime.Serialization.ContractNamespaceAttribute("http://schemas.progel.it/OE/TokenFault/1.1", ClrNamespace:="TokenFault"),
'Assembly: System.Runtime.Serialization.ContractNamespaceAttribute("http://schemas.progel.it/OE/ErrorCode/1.1", ClrNamespace:="ErrorCode")> 

<DataContract(Name:="ErrorCode")>
Public Enum ErrorCode As Integer
    <EnumMember()> UnauthorizedAccess = 1
    <EnumMember()> InternalService = 21
    <EnumMember()> DataRequestArgumentNull = 31
    <EnumMember()> DataRequestDuplicateObject = 32
    <EnumMember()> DataRequestNotFoundObject = 33
    <EnumMember()> DataRequestProcess = 34
    <EnumMember()> NotImplemented = 41
    <EnumMember()> ArgumentNull = 42
    <EnumMember()> ArgumentOutOfRange = 43
    <EnumMember()> ArgumentFormat = 44
End Enum

<DataContract(Name:="ServiceFault")>
Public Class ServiceFault

    Private _message As String
    Private _code As Integer

    Public Sub New(message As String)
        _message = message
        _code = ErrorCode.InternalService
    End Sub

    Public Sub New(message As String, code As ErrorCode)
        _message = message
        _code = code
    End Sub

    Public Sub New(ex As Exception)
        _message = DiagnosticsHelper.FormatException(ex)
        _code = ErrorCode.InternalService
    End Sub

    Public Sub New(ex As Exception, code As ErrorCode)
        _message = DiagnosticsHelper.FormatException(ex)
        _code = code
    End Sub

    <DataMember()>
    Public Property Message As String
        Get
            Return _message
        End Get
        Set(value As String)
            _message = value
        End Set
    End Property

    <DataMember()>
    Public Property Code As Integer
        Get
            Return _code
        End Get
        Set(value As Integer)
            _code = value
        End Set
    End Property

    Public Overrides Function ToString() As String

        Dim Code As String
        Try
            Code = [Enum].GetName(GetType(ErrorCode), Me.Code)
        Catch ex As Exception
            Code = "non trovato"
        End Try

        Return String.Concat("Message: ", Me.Message, "; Code: ", Code)

    End Function

End Class

<DataContract(Name:="DataFault")>
Public Class DataFault

    Private _message As String
    Private _data As Dictionary(Of String, String)
    Private _code As Integer

    Public Sub New(message As String)
        _message = message
        _code = ErrorCode.InternalService
    End Sub

    Public Sub New(message As String, code As ErrorCode)
        _message = message
        _code = code
    End Sub

    Public Sub New(message As String, data As Dictionary(Of String, String), code As ErrorCode)
        _message = message
        _data = data
        _code = code
    End Sub

    Public Sub New(ex As Exception)
        _message = DiagnosticsHelper.FormatException(ex)
        _code = ErrorCode.InternalService
        _data = CopyDataEx(ex.Data)

    End Sub

    Public Sub New(ex As Exception, code As ErrorCode)
        _message = DiagnosticsHelper.FormatException(ex)
        _code = code
        _data = CopyDataEx(ex.Data)
    End Sub

    Public Sub New(ex As Exception, data As Dictionary(Of String, String), code As ErrorCode)
        _message = DiagnosticsHelper.FormatException(ex)
        _data = data
        _code = code
    End Sub


    <DataMember()>
    Public Property Message As String
        Get
            Return _message
        End Get
        Set(value As String)
            _message = value
        End Set
    End Property

    <DataMember()>
    Public Property Data As Dictionary(Of String, String)
        Get
            Return _data
        End Get
        Set(value As Dictionary(Of String, String))
            _data = value
        End Set
    End Property

    <DataMember()>
    Public Property Code As Integer
        Get
            Return _code
        End Get
        Set(value As Integer)
            _code = value
        End Set
    End Property

    Private Function CopyDataEx(exData As Collections.IDictionary) As Dictionary(Of String, String)

        Dim dicData As Dictionary(Of String, String) = Nothing

        Dim i As Integer = 0
        If exData IsNot Nothing AndAlso exData.Count > 0 Then
            '
            ' Creo e popolo
            '
            dicData = New Dictionary(Of String, String)
            For Each d In exData
                dicData.Add(String.Format("K_{0}", i), d.ToString)
                i += 1
            Next
        End If

        Return dicData

    End Function

    Public Overrides Function ToString() As String

        Dim Code As String
        Try
            Code = [Enum].GetName(GetType(ErrorCode), Me.Code)
        Catch ex As Exception
            Code = "non trovato"
        End Try

        Return String.Concat("Message: ", Me.Message, "; Code: ", Code)

    End Function

End Class

<DataContract(Name:="ArgumentFault")>
Public Class ArgumentFault

    Private _message As String
    Private _code As Integer

    Public Sub New(message As String)
        _message = message
        _code = ErrorCode.InternalService
    End Sub

    Public Sub New(message As String, code As ErrorCode)
        _message = message
        _code = code
    End Sub

    Public Sub New(ex As Exception)
        _message = DiagnosticsHelper.FormatException(ex)
        _code = ErrorCode.InternalService
    End Sub

    Public Sub New(ex As Exception, code As ErrorCode)
        _message = DiagnosticsHelper.FormatException(ex)
        _code = code
    End Sub

    <DataMember()>
    Public Property Message As String
        Get
            Return _message
        End Get
        Set(value As String)
            _message = value
        End Set
    End Property

    <DataMember()>
    Public Property Code As Integer
        Get
            Return _code
        End Get
        Set(value As Integer)
            _code = value
        End Set
    End Property

    Public Overrides Function ToString() As String

        Dim Code As String
        Try
            Code = [Enum].GetName(GetType(ErrorCode), Me.Code)
        Catch ex As Exception
            Code = "non trovato"
        End Try

        Return String.Concat("Message: ", Me.Message, "; Code: ", Code)

    End Function

End Class

<DataContract(Name:="TokenFault")>
Public Class TokenFault

    Private _message As String
    Private _code As Integer

    Public Sub New(message As String)
        _message = message
        _code = ErrorCode.InternalService
    End Sub

    Public Sub New(message As String, code As ErrorCode)
        _message = message
        _code = code
    End Sub

    Public Sub New(ex As Exception)
        _message = DiagnosticsHelper.FormatException(ex)
        _code = ErrorCode.InternalService
    End Sub

    Public Sub New(ex As Exception, code As ErrorCode)
        _message = DiagnosticsHelper.FormatException(ex)
        _code = code
    End Sub

    <DataMember()>
    Public Property Message As String
        Get
            Return _message
        End Get
        Set(value As String)
            _message = value
        End Set
    End Property

    <DataMember()>
    Public Property Code As Integer
        Get
            Return _code
        End Get
        Set(value As Integer)
            _code = value
        End Set
    End Property

    Public Overrides Function ToString() As String

        Dim Code As String
        Try
            Code = [Enum].GetName(GetType(ErrorCode), Me.Code)
        Catch ex As Exception
            Code = "non trovato"
        End Try

        Return String.Concat("Message: ", Me.Message, "; Code: ", Code)

    End Function

End Class
