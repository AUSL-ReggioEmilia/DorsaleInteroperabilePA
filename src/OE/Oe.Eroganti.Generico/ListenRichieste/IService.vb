<ServiceContract(Namespace:="http://schemas.progel.it/WCF/OE/RichiestaEroganteGenerico/1.0")> _
Public Interface IService

    <OperationContract()> _
    Sub ListenData(ByVal value As EroganteGenericoTypes.RichiestaType)

End Interface