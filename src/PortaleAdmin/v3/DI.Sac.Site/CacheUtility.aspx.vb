Imports System
Imports System.Collections.Generic
Imports System.Web.UI

Public Class CacheUtility
    Inherits Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load

        Me.CacheLabel.Text = "Elementi in cache: " & Cache.Count

        Me.CacheGridView.DataSource = GetCacheElements()
        Me.CacheGridView.DataBind()
    End Sub

    Protected Sub CacheButton_Click(sender As Object, e As EventArgs)  Handles CacheButton.Click

        Dim cacheElements = GetCacheElements()

        For Each element As KeyValuePair(Of String, String) In cacheElements

            Cache.Remove(element.Key)
        Next

        Me.CacheLabel.Text = "Elementi in cache: " & Cache.Count

        Me.CacheGridView.DataSource = GetCacheElements()
        Me.CacheGridView.DataBind()
    End Sub

    Private Function GetCacheElements() As Dictionary(Of String, String)

        Dim result As New Dictionary(Of String, String)()

        Dim enumerator = Cache.GetEnumerator()

        While enumerator.MoveNext()

            result.Add(enumerator.Key.ToString(), enumerator.Value.ToString())
        End While

        Return result
    End Function


End Class