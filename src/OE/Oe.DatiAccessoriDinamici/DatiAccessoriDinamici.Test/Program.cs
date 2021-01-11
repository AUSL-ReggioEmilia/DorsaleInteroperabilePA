using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Serialization;

namespace DatiAccessoriDinamici.Test
{
    class Program
    {
        static void Main(string[] args)
        {
            if (args.Length == 2)
            {
                String sFileName = args[0];
                if (File.Exists(sFileName))
                {
                    String sMessage = File.ReadAllText(sFileName);
                    
                    ServiceOttieneInvoke(sMessage, args[1]);

                    Console.WriteLine("Premi un tasto per uscire!");
                    Console.ReadKey();
                }
                else
                {
                    Console.WriteLine("Errore: il file non esiste!");
                }
            }
            else
            {
                Console.WriteLine("USO di DatiAccessoriDinamici.Test.exe:");
                Console.WriteLine("Nome del file");
                Console.WriteLine("URL da invocare");
                Console.WriteLine("DatiAccessoriDinamici.Test.exe OttieneParameter.xml URL");
            }
        }


        static void ServiceOttieneInvoke(String sMessageParam, string URL)
        {
            ServiceReference.ServiceClient oService = new ServiceReference.ServiceClient("BasicHttpBinding_IService", URL);

            ServiceReference.OttieneParameter oParam = null;
            ServiceReference.OttieneReturn oReturn = null;

            try
            {
                String sMessageReturn = "";
                //
                // Print in console
                //
                Console.WriteLine($"URL: {URL}");
                Console.WriteLine("Param:");
                Console.WriteLine(sMessageParam);
                //
                // Deserializzo string in OBJECT class
                //
                Encoding oEnc = Encoding.UTF8;
                Byte[] baMessage = oEnc.GetBytes(sMessageParam);

                using (MemoryStream oStreamParam  = new MemoryStream(baMessage))
                {
                    XmlSerializer oSerializerParam = new XmlSerializer(typeof(ServiceReference.OttieneParameter));
                    oParam = (ServiceReference.OttieneParameter)oSerializerParam.Deserialize(oStreamParam);
                }

                oService.Open();
                oReturn = oService.Ottiene(oParam);

                //
                // Serializzo OBJECT class in string
                //
                using (MemoryStream oStreamReturn = new MemoryStream())
                {
                    XmlSerializer oSerializerReturn = new XmlSerializer(typeof(ServiceReference.OttieneReturn));
                    oSerializerReturn.Serialize(oStreamReturn, oReturn);

                    oStreamReturn.Position = 0;
                    Byte[] baMessaggioReturn = oStreamReturn.ToArray();
                    sMessageReturn = Encoding.UTF8.GetString(baMessaggioReturn);
                }
                //
                // Print in console
                //
                Console.WriteLine("Return:");
                Console.WriteLine(sMessageReturn);

            }
            catch (Exception ex)
            {
                Console.WriteLine($"Errore : {ex}");
            }
            finally
            {
                oService.Close();
            }

        }

    }
}
