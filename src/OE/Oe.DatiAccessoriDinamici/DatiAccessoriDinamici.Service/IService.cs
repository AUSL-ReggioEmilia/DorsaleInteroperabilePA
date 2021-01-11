using DatiAccessoriDinamici.Service.ContractTypes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.ServiceModel;
using System.Text;

namespace DatiAccessoriDinamici.Service
{
    [ServiceContract(Namespace = "http://schemas.progel.it/WCF/OE/DatiAccessoriDinamici/1.0")]
    public interface IService
    {
        [OperationContract]
        OttieneReturn Ottiene(OttieneParameter contesto);
    }

    // Use a data contract as illustrated in the sample below to add composite types to service operations.
    // You can add XSD files into the project. After building the project, you can directly use the data types defined there, with the namespace "DatiAccessoriDinamici.Service.ContractType".
}
