using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace DI.BiztalkMonitor.Site.State
{
    public class ScopedState
    {
        private IConfiguration _config;
        private MessaggiScartatiFilterState _messaggiScartatiFilterState;


        public ScopedState(IConfiguration config)
        {
            _config = config;
            _messaggiScartatiFilterState = new MessaggiScartatiFilterState();

        }

        public MessaggiScartatiFilterState Messaggi { get => _messaggiScartatiFilterState; }

    }
}
