using System;
using System.Globalization;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Logging.ApplicationInsights;
using Microsoft.Extensions.Logging.Console;

namespace DI.BiztalkMonitor.Site
{
    public class Program
    {
        public static void Main(string[] args)
        {
            CreateHostBuilder(args).Build().Run();
        }

        public static IHostBuilder CreateHostBuilder(string[] args) =>
            Host.CreateDefaultBuilder(args)
                .ConfigureWebHostDefaults(webBuilder =>
                {
                    webBuilder.UseStaticWebAssets();
                    webBuilder.UseStartup<Startup>();
                })
                .ConfigureLogging((hostingContext, builder) =>
                {
                    // Enable console logging
                    builder.AddConsole();

                    // Apply filters to configure LogLevel Trace or above is sent to
                    //Application Insights for all categories minumun Information or more.
                    builder.AddFilter<ApplicationInsightsLoggerProvider>("", LogLevel.Information);

                    // Console for all categories minumun Debug or more.
                    builder.AddFilter<ConsoleLoggerProvider>("", LogLevel.Debug);

                    //Log EventViewer con Source
                    builder.AddEventLog(EventLogSettings => EventLogSettings.SourceName = AppDomain.CurrentDomain.FriendlyName);

                });
    }
}
