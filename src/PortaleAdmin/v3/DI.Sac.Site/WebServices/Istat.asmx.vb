Imports System.Web.Services
Imports System.Web.Services.Protocols
Imports System.ComponentModel
Imports AjaxControlToolkit
Imports System
Imports System.Collections.Specialized
Imports DI.Common.Controls
Imports System.Collections.Generic
Imports DI.Sac.Admin.Data.PazientiDataSet
Imports DI.Sac.Admin.Data.PazientiDataSetTableAdapters

Namespace DI.Sac.Admin.WebServices


    ' To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line.
    <System.Web.Script.Services.ScriptService()> _
    <System.Web.Services.WebService(Namespace:="http://tempuri.org/")> _
    <System.Web.Services.WebServiceBinding(ConformsTo:=WsiProfiles.BasicProfile1_1)> _
    <ToolboxItem(False)> _
    Public Class Istat
        Inherits System.Web.Services.WebService

        Private Shared ReadOnly _ClassName As String = System.Reflection.MethodBase.GetCurrentMethod().ReflectedType.Name


        Public Sub New()

        End Sub

        <WebMethod(CacheDuration:=120)> _
        Public Function GetProvinceIstat(ByVal knownCategoryValues As String, ByVal category As String) As CascadingDropDownNameValue()
            Try
                Dim values As New List(Of CascadingDropDownNameValue)
                Using adapter As New ComboProvinceTableAdapter

                    Dim provinceTable As ComboProvinceDataTable = adapter.GetData(Nothing)

                    For Each row As ComboProvinceRow In provinceTable

                        values.Add(New CascadingDropDownNameValue(row.Nome, row.Codice))
                    Next
                End Using

                Return values.ToArray()
            Catch ex As Exception
                ExceptionsManager.TraceException(ex)
                Return Nothing
            End Try
        End Function

        <WebMethod(CacheDuration:=120)> _
        Public Function GetComuniIstat(ByVal knownCategoryValues As String, ByVal category As String) As CascadingDropDownNameValue()
            Try
                Dim kv As StringDictionary = CascadingDropDown.ParseKnownCategoryValuesString(knownCategoryValues)
                If Not kv.ContainsKey("Province") Then Return Nothing

                Dim values As New List(Of CascadingDropDownNameValue)()

                Dim codiceProvincia As String = kv("Province")
                Using adapter As New ComboComuniTableAdapter()

                    Dim comuniTable As ComboComuniDataTable = adapter.GetData(codiceProvincia)

                    For Each row As ComboComuniRow In comuniTable

                        values.Add(New CascadingDropDownNameValue(row.Nome, row.Codice))
                    Next
                End Using

                Return values.ToArray()
            Catch ex As Exception
                ExceptionsManager.TraceException(ex)
                Return Nothing
            End Try
        End Function

        <WebMethod(CacheDuration:=120)> _
        Public Function GetAslIstat(ByVal knownCategoryValues As String, ByVal category As String) As CascadingDropDownNameValue()

            Try
                Dim kv As StringDictionary = CascadingDropDown.ParseKnownCategoryValuesString(knownCategoryValues)
                If Not kv.ContainsKey("Comuni") Then Return Nothing

                Dim values As New List(Of CascadingDropDownNameValue)

                Dim codiceComune As String = kv("Comuni")
                Using adapter As New ComboAslTableAdapter()

                    Dim aslTable As ComboAslDataTable = adapter.GetData(codiceComune)

                    For Each row As ComboAslRow In aslTable

                        values.Add(New CascadingDropDownNameValue(row.Nome, row.Codice))
                    Next
                End Using

                Return values.ToArray()
            Catch ex As Exception
                ExceptionsManager.TraceException(ex)
                Return Nothing
            End Try
        End Function

    End Class

End Namespace