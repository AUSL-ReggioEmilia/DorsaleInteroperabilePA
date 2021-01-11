using DI.BiztalkMonitor.Site.State;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Xml.Linq;

namespace DI.BiztalkMonitor.Site.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [Produces("application/xml")]
    public class XmlController : ControllerBase
    {
        private readonly ILogger<XmlController> _logger;
        private readonly AppState _appState;

        public XmlController(ILogger<XmlController> logger, AppState appState)
        {
            _logger = logger;
            _appState = appState;
        }

        [HttpGet("{id}")]
        public XElement Get(String id)
        {
            if (!String.IsNullOrEmpty(id))
            {
                // Leggo il messaggio dal dictionary
                XElement messaggio = _appState.Xml.XmlDictionary[id];
                // Rimuovo il messaggio appena letto dal dictionary
                _appState.Xml.XmlDictionary.Remove(id);

                if (messaggio != null)
                {
                    return messaggio;
                }
            }
            return null;
        }
    }
}
