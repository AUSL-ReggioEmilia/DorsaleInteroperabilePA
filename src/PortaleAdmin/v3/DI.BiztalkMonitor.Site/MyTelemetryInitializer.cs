using Microsoft.ApplicationInsights.Channel;
using Microsoft.ApplicationInsights.Extensibility;
using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace DI.BiztalkMonitor.Site
{
    public class MyTelemetryInitializer : ITelemetryInitializer
    {
        //
        // Telemetry configurator
        //
        private readonly String _instrumentationKey;
        private readonly String _appName;
        private readonly String _sessionId;
        private readonly IConfigurationSection _configApplicationInsights;

        public MyTelemetryInitializer(IConfiguration configuration)
        {
            //
            // Read Config Section
            //
            _configApplicationInsights = configuration?.GetSection("ApplicationInsights");
            //
            // Read Config Value
            //
            _instrumentationKey = _configApplicationInsights?.GetValue<String>("InstrumentationKey");
            //
            // Automatic properties
            //
            _appName = AppDomain.CurrentDomain.FriendlyName;
            _sessionId = Guid.NewGuid().ToString();
        }

        public void Initialize(ITelemetry telemetry)
        {
            if (!String.IsNullOrEmpty(_instrumentationKey))
                telemetry.Context.InstrumentationKey = _instrumentationKey;

            //set custom role name here
            //
            if (string.IsNullOrEmpty(telemetry.Context.Cloud.RoleName) && !String.IsNullOrEmpty(_appName))
                telemetry.Context.Cloud.RoleName = _appName;

            if (!String.IsNullOrEmpty(_sessionId))
                telemetry.Context.Session.Id = _sessionId;
        }
    }
}
