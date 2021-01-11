using DatiAccessoriDinamici.Service.ContractTypes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.ServiceModel;
using System.Text;

namespace DatiAccessoriDinamici.Service
{
    [ServiceBehavior(Namespace = "http://schemas.progel.it/WCF/OE/DatiAccessoriDinamici/1.0")]
    public class Service : IService
    {
        public OttieneReturn Ottiene(OttieneParameter contesto)
        {
            OttieneReturn ret = new OttieneReturn();

            string sDatoAccessorioCodice = contesto?.DatoAccessorio?.Codice;

            try
            {
                ValoriType valori = new ValoriType();
                valori.Add(new ValoreType() { Codice = "1", Descrizione = $"Uno - {sDatoAccessorioCodice}" });
                valori.Add(new ValoreType() { Codice = "2", Descrizione = $"Due - {sDatoAccessorioCodice}" });
                valori.Add(new ValoreType() { Codice = "3", Descrizione = $"Tre - {sDatoAccessorioCodice}" });
                valori.Add(new ValoreType() { Codice = "4", Descrizione = $"Quattro - {sDatoAccessorioCodice}" });
                valori.Add(new ValoreType() { Codice = "5", Descrizione = $"Cinque - {sDatoAccessorioCodice}" });

                ret.Valori = valori;
                ret.Errore = new ErroreType() { Codice = "AA"};
            }
            catch (Exception ex)
            {
                ret.Errore = new ErroreType() { Codice = "AE", Descrizione = ex.Message};
            }

            return ret;
        }
    }
}
