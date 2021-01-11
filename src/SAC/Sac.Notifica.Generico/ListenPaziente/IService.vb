<ServiceContract(Namespace:="http://schemas.progel.it/WCF/Sac/NotificaPazienteType/2.0")> _
Public Interface IService

    <OperationContract()> _
    Sub ListenData(ByVal value As NotificaPazienteTypes.SoapPazienteType)

End Interface

