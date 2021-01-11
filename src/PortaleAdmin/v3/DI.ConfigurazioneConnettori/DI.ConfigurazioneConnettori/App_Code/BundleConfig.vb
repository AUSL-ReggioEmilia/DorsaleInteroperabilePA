Imports System.Web.Optimization

Public Class BundleConfig
	' For more information on Bundling, visit http://go.microsoft.com/fwlink/?LinkID=303951
	Public Shared Sub RegisterBundles(ByVal bundles As BundleCollection)

		' Use the Development version of Modernizr to develop with and learn from. Then, when you’re
		' ready for production, use the build tool at http://modernizr.com to pick only the tests you need
		bundles.Add(New ScriptBundle("~/bundles/modernizr").Include(
						"~/Scripts/modernizr-*"))

		ScriptManager.ScriptResourceMapping.AddDefinition("respond", New ScriptResourceDefinition() With {
				.Path = "~/Scripts/respond.min.js",
				.DebugPath = "~/Scripts/respond.js"})

	End Sub
End Class
