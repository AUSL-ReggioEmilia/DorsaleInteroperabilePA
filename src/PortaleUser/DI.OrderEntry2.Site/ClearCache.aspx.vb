Imports System
Imports System.Web.Caching
Imports System.Web

Public Class ClearCache
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load

    End Sub

    Protected Sub PulisciCacheButton_Click(sender As Object, e As EventArgs) Handles PulisciCacheButton.Click

        'Cache.Remove("lookupData")
        Dim _lookupDataName = My.User.Name & "_lookupData"
        HttpRuntime.Cache.Remove(_lookupDataName)

    End Sub
End Class