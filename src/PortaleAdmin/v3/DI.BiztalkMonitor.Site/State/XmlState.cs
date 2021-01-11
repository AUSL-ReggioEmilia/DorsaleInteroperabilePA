using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Xml.Linq;

namespace DI.BiztalkMonitor.Site.State
{
    public class XmlState
    {
        public XmlDictionary<string, XElement> XmlDictionary { get; set; } = new XmlDictionary<string, XElement>();
        public string Separatore { get => "&"; }

    }

    public class XmlDictionary<Tkey, XElement> : Dictionary<Tkey, XElement>
    {
        /// <summary>
        /// Aggiunge un elemento solo se non esiste già
        /// </summary>
        /// <param name="id"></param>
        /// <param name="xml"></param>
        public new void Add(Tkey id, XElement xml)
        {
            lock (this)
            {
                if (!this.ContainsKey(id))
                    // Usa l'add della classe base del dictionary
                    base.Add(id, xml);
            }
        }

        /// <summary>
        /// Rimuove un elemento solo se esiste già
        /// </summary>
        /// <param name="id"></param>
        public new void Remove(Tkey id)
        {
            lock (this)
            {
                if (this.ContainsKey(id))
                    // Usa il remove della classe base del dictionary
                    base.Remove(id);
            }
        }
    }
}
