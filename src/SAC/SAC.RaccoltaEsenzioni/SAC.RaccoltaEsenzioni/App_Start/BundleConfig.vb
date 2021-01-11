Imports System.Collections.Generic
Imports System.Linq
Imports System.Web
Imports System.Web.Optimization

Public Class BundleConfig
    ' For more information on Bundling, visit https://go.microsoft.com/fwlink/?LinkID=303951
    Public Shared Sub RegisterBundles(ByVal bundles As BundleCollection)
        ' Use the Development version of Modernizr to develop with and learn from. Then, when you’re
        ' ready for production, use the build tool at https://modernizr.com to pick only the tests you need
        ScriptManager.ScriptResourceMapping.AddDefinition("respond", New ScriptResourceDefinition() With {
                .Path = "~/Scripts/respond.min.js",
                .DebugPath = "~/Scripts/respond.js"})

        ScriptManager.ScriptResourceMapping.AddDefinition("bootstrap", New ScriptResourceDefinition() With {
        .Path = "~/Scripts/bootstrap.min.js",
        .DebugPath = "~/Scripts/bootstrap.js"})

        ScriptManager.ScriptResourceMapping.AddDefinition("bootstrap", New ScriptResourceDefinition() With {
         .Path = "~/Scripts/bootstrap.min.js",
        .DebugPath = "~/Scripts/bootstrap.js"})

        Dim sJqueryVer As String = "1.10.2"

        ScriptManager.ScriptResourceMapping.AddDefinition("jquery", New ScriptResourceDefinition() With {
                .Path = String.Format("~/Scripts/jquery-{0}.min.js", sJqueryVer),
                .DebugPath = String.Format("~/Scripts/jquery-{0}.js", sJqueryVer),
                .CdnSupportsSecureConnection = False,
                .LoadSuccessExpression = "window.jQuery"})

        Dim sModernVer As String = "2.6.2"

        ScriptManager.ScriptResourceMapping.AddDefinition("modernizr", New ScriptResourceDefinition() With {
                .Path = String.Format("~/Scripts/modernizr-{0}.js", sModernVer),
                .DebugPath = String.Format("~/Scripts/modernizr-{0}.js", sModernVer)})

        'Imposto "Reflection.Assembly.GetExecutingAssembly.GetName.Version.ToString" 
        'per permettere al browser di scaricare la nuova versione dei css dopo un aggionramento.
        ScriptManager.ScriptResourceMapping.AddDefinition("master", New ScriptResourceDefinition() With {
        .Path = String.Format("~/Scripts/CustomCss/master.js?{0}", Utility.GetAssemblyVersion()),
        .DebugPath = String.Format("~/Scripts/CustomCss/master.js?{0}", Utility.GetAssemblyVersion())})

        ScriptManager.ScriptResourceMapping.AddDefinition("moment", New ScriptResourceDefinition() With {
              .Path = "~/Scripts/moment.min.js",
              .DebugPath = "~/Scripts/moment.js"})

        ScriptManager.ScriptResourceMapping.AddDefinition("momentLocales", New ScriptResourceDefinition() With {
          .Path = "~/Scripts/moment-with-locales.min.js",
          .DebugPath = "~/Scripts/moment-with-locales.js"})

        ScriptManager.ScriptResourceMapping.AddDefinition("datetimepicker", New ScriptResourceDefinition() With {
          .Path = "~/Scripts/bootstrap-datetimepicker.min.js",
          .DebugPath = "~/Scripts/bootstrap-datetimepicker.js"})
    End Sub
End Class
