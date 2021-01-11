using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Optimization;
using System.Web.UI;

namespace OrderEntryPlanner
{
	public class BundleConfig
	{
		//For more information on Bundling, visit https://go.microsoft.com/fwlink/?LinkID=303951
		public static void RegisterBundles(BundleCollection bundles)
		{
            //Jquery
            ScriptManager.ScriptResourceMapping.AddDefinition("jquery", new ScriptResourceDefinition()
            {
                Path = "~/node_modules/jquery/dist/jquery.min.js",
                DebugPath = "~/node_modules/jquery/dist/jquery.min.js"
            });

            //moment
            ScriptManager.ScriptResourceMapping.AddDefinition("moment", new ScriptResourceDefinition()
            {
                Path = "~/node_modules/moment/min/moment.min.js",
                DebugPath = "~/node_modules/moment/min/moment.min.js",
            });

            //moment-it
            ScriptManager.ScriptResourceMapping.AddDefinition("moment-it", new ScriptResourceDefinition()
            {
                Path = "~/node_modules/moment/locale/it.js",
                DebugPath = "~/node_modules/moment/locale/it.js",
            });


            //bootstrap
            ScriptManager.ScriptResourceMapping.AddDefinition("fullcalendar", new ScriptResourceDefinition()
            {
                Path = "~/node_modules/fullcalendar/dist/fullcalendar.min.js",
                DebugPath = "~/node_modules/fullcalendar/dist/fullcalendar.min.js",
            });

            //bootstrap
            ScriptManager.ScriptResourceMapping.AddDefinition("fullcalendarlocale", new ScriptResourceDefinition()
            {
                Path = "~/node_modules/fullcalendar/dist/locale/it.js",
                DebugPath = "~/node_modules/fullcalendar/dist/locale/it.js",
            });


            //bootstrap
            ScriptManager.ScriptResourceMapping.AddDefinition("bootstrap", new ScriptResourceDefinition()
            {
                Path = "~/node_modules/bootstrap/dist/js/bootstrap.min.js",
                DebugPath = "~/node_modules/bootstrap/dist/js/bootstrap.min.js",
            });

            //bootstrap
            ScriptManager.ScriptResourceMapping.AddDefinition("bundle", new ScriptResourceDefinition()
            {
                Path = "~/wwwroot/js/main.bundle.js",
                DebugPath = "~/wwwroot/js/main.bundle.js",
            });
        }
	}
}