using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Xml.Linq;

namespace DI.BiztalkMonitor.Site.State
{
    public class AppState
    {

        private IConfiguration _config;
        private XmlState _xmlState;


        public AppState(IConfiguration config)
        {
            _config = config;
            _xmlState = new XmlState();
        }

        public XmlState Xml { get => _xmlState; }
    }
}
