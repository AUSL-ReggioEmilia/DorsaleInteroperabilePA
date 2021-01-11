<ServiceContract(Namespace:="http://schemas.progel.it/WCF/OE/StatoRichiedenteGenerico/1.0")> _
Public Interface IService

    <OperationContract()> _
    Sub ListenData(ByVal value As RichiedenteGenericoTypes.StatoType)

End Interface

