using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace OrderEntryPlanner.Components
{
    using Microsoft.ApplicationInsights.Channel;
    using Microsoft.ApplicationInsights.Extensibility;
    namespace CustomInitializer.Telemetry
    {
        public class MyTelemetryInitializer : ITelemetryInitializer
        {

            public static string InstrumentationKey = Properties.Settings.Default.InstrumentationKey;
            public static string RoleName = "OePlanner-User";

            public void Initialize(ITelemetry telemetry)
            {
                if (string.IsNullOrEmpty(telemetry.Context.Cloud.RoleName))
                {
                    //set custom role name here
                    telemetry.Context.Cloud.RoleName = RoleName;
                    telemetry.Context.InstrumentationKey = InstrumentationKey;
                }
            }
        }
    }

}