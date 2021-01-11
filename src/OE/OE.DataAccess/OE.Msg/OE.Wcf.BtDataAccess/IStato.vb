Imports System.ServiceModel
Imports System.Xml
Imports OE.Core.Schemas.Msg.StatoParameterTypes
Imports OE.Core.Schemas.Msg.StatoReturnTypes
Imports OE.Core.Schemas.Msg.QueueTypes

<ServiceContract(Namespace:="http://schemas.progel.it/OE/WCF/DataAccess/Stato")> _
Public Interface IStato

    <OperationContract(Name:="ProcessaMessaggio"), _
        FaultContract(GetType(StatoFault))> _
    Function ProcessaMessaggio(ByVal value As StatoParameter) As StatoReturn

End Interface

<DataContract()> _
Public Class StatoFault
    Private _message As String

    Public Sub New(ByVal message As String)
        _message = message
    End Sub

    Public Sub New(ByVal ex As Exception)
        _message = ex.Message

        If ex.InnerException IsNot Nothing Then
            _message = _message & "; " & ex.InnerException.ToString
        End If

    End Sub

    <DataMember()> _
    Public Property Message() As String
        Get
            Return _message
        End Get
        Set(ByVal value As String)
            _message = value
        End Set
    End Property
End Class