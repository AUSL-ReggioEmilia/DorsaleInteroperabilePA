using System;
using System.Collections.Generic;
using System.Text;
using System.Xml.Linq;

namespace DI.BiztalkMonitor.DataAccess.Models
{
    public class MessaggioXMLPageModel
    {
        public string NameSpace { get; set; }
        public string Numero { get; set; }
        public XElement Messaggio { get; set; }
        public double DimensioneKB { get => (Messaggio.ToString().Length)/1024.0; }
    }
}
