using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.HttpsPolicy;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using DI.BiztalkMonitor.DataAccess;
using Microsoft.AspNetCore.Server.IISIntegration;
using System.Globalization;
using Blazorise;
using Blazorise.Bootstrap;
using Blazorise.Icons.FontAwesome;
using Microsoft.ApplicationInsights.Extensibility;

namespace DI.BiztalkMonitor.Site
{
    public class Startup
    {
        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        public IConfiguration Configuration { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        // For more information on how to configure your application, visit https://go.microsoft.com/fwlink/?LinkID=398940
        public void ConfigureServices(IServiceCollection services)
        {
            services.AddRazorPages();
            services.AddServerSideBlazor();
            services.AddControllers().AddXmlSerializerFormatters();
            services.AddHttpContextAccessor();

            //DB Service
            services.AddSingleton<IDBRepository, DBRepository>();

            // --------------------------------------
            // BLAZORISE
            // https://github.com/stsrki/blazorise
            // --------------------------------------
            services.AddBlazorise(options =>
            {
                options.ChangeTextOnKeyPress = true; // optional
            })
            .AddBootstrapProviders()
            .AddFontAwesomeIcons();


            // ** SESSION STATE
            // Scoped means for the current unit-of-work
            services.AddScoped<State.ScopedState>();

            // ** APPLICATION STATE
            // Singleton usually means for all users
            services.AddSingleton<State.AppState>();


            // --------------------------------------
            // SERVICE APPLICATION INSIGHTS
            // --------------------------------------
            // Aggiungo servizio di Application Insights (utilizzo un inizializzatore personalizzato 
            // per gestire la proprietà "Cloud.RoleName"
            services.AddApplicationInsightsTelemetry();
            services.AddSingleton<ITelemetryInitializer, MyTelemetryInitializer>();


            //Windows Authentication
            services.AddAuthentication(IISDefaults.AuthenticationScheme);

        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }
            else
            {
                app.UseExceptionHandler("/Error");
                // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
                app.UseHsts();
            }

            // BLAZORISE
            app.ApplicationServices
                .UseBootstrapProviders()
                .UseFontAwesomeIcons();

            app.UseHttpsRedirection();
            app.UseStaticFiles();

            app.UseRouting();

            app.UseEndpoints(endpoints =>
            {
                endpoints.MapControllers();
                endpoints.MapBlazorHub();
                endpoints.MapFallbackToPage("/_Host");
            });

            // Imposta la culture in italiano
            CultureInfo cultureInfo = new CultureInfo("it-IT", false);
            CultureInfo.DefaultThreadCurrentCulture = cultureInfo;
            CultureInfo.DefaultThreadCurrentUICulture = cultureInfo;

        }
    }
}
