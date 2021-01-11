using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Optimization;
using System.Web.UI;

namespace DI.OrderEntryPlanner.Site2
{
    public class BundleConfig
    {
        // For more information on Bundling, visit https://go.microsoft.com/fwlink/?LinkID=303951
        public static void RegisterBundles(BundleCollection bundles)
        {
            bundles.Add(new ScriptBundle("~/bundles/WebFormsJs").Include(
                            "~/Scripts/WebForms/WebForms.js",
                            "~/Scripts/WebForms/WebUIValidation.js",
                            "~/Scripts/WebForms/MenuStandards.js",
                            "~/Scripts/WebForms/Focus.js",
                            "~/Scripts/WebForms/GridView.js",
                            "~/Scripts/WebForms/DetailsView.js",
                            "~/Scripts/WebForms/TreeView.js",
                            "~/Scripts/WebForms/WebParts.js"));

            // Order is very important for these files to work, they have explicit dependencies
            bundles.Add(new ScriptBundle("~/bundles/MsAjaxJs").Include(
                    "~/Scripts/WebForms/MsAjax/MicrosoftAjax.js",
                    "~/Scripts/WebForms/MsAjax/MicrosoftAjaxApplicationServices.js",
                    "~/Scripts/WebForms/MsAjax/MicrosoftAjaxTimer.js",
                    "~/Scripts/WebForms/MsAjax/MicrosoftAjaxWebForms.js"));

            // Use the Development version of Modernizr to develop with and learn from. Then, when you’re
            // ready for production, use the build tool at https://modernizr.com to pick only the tests you need
            bundles.Add(new ScriptBundle("~/bundles/modernizr").Include(
                            "~/Scripts/modernizr-*"));

            //Jquery
            ScriptManager.ScriptResourceMapping.AddDefinition("jquery", new ScriptResourceDefinition()
            {
                Path = "~/Scripts/jquery-3.4.1.min.js",
                DebugPath = "~/Scripts/jquery-3.4.1.js",
            });

            //moment
            ScriptManager.ScriptResourceMapping.AddDefinition("moment", new ScriptResourceDefinition()
            {
                Path = "~/Scripts/moment.min.js",
                DebugPath = "~/Scripts/moment.js",
            });

            //moment-it
            ScriptManager.ScriptResourceMapping.AddDefinition("moment-it", new ScriptResourceDefinition()
            {
                Path = "~/Scripts/moment-with-locales.min.js",
                DebugPath = "~/Scripts/moment-with-locales.js",
            });


            //fullcalendar
            ScriptManager.ScriptResourceMapping.AddDefinition("fullcalendar", new ScriptResourceDefinition()
            {
                Path = "~/Scripts/fullcalendar.min.js",
                DebugPath = "~/Scripts/fullcalendar.js",
            });

            //fullcalendar locale
            ScriptManager.ScriptResourceMapping.AddDefinition("fullcalendarlocale-it", new ScriptResourceDefinition()
            {
                Path = "~/Scripts/locale/it.js",
            });


            //bootstrap
            ScriptManager.ScriptResourceMapping.AddDefinition("bootstrap", new ScriptResourceDefinition()
            {
                Path = "~/Scripts/bootstrap.min.js",
                DebugPath = "~/Scripts/bootstrap.js",
            });

            //bootstrap-datetimepicker
            ScriptManager.ScriptResourceMapping.AddDefinition("bootstrap-datetimepicker", new ScriptResourceDefinition()
            {
                Path = "~/Scripts/bootstrap-datetimepicker.min.js",
                DebugPath = "~/Scripts/bootstrap-datetimepicker.js",
            });
        }
    }
}