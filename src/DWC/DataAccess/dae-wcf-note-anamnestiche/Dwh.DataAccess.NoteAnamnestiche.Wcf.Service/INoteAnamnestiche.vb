Imports Dwh.DataAccess.Wcf.Types.NoteAnamnestiche

<ServiceContract(Namespace:="http://schemas.progel.it/BT/DWH/DataAccess/NoteAnamnestiche/1.0")>
Public Interface INoteAnamnestiche

    <OperationContract(Name:="Processa")>
    Function Processa(ByVal NotaAnamnestica As NotaAnamnesticaParameter) As NotaAnamnesticaReturn

End Interface

