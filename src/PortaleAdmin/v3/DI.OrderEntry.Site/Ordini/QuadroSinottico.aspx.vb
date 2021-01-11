Imports System
Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports System.Data
Imports DI.OrderEntry.Admin.Data.Ordini
Imports DI.OrderEntry.Admin.Data.OrdiniTableAdapters
Imports DI.OrderEntry.Admin.Data
Imports DI.Common
Imports System.Web.Services
Imports System.Collections.Generic
Imports System.Web
Imports DI.PortalAdmin.Data
Imports System.Configuration


Namespace DI.OrderEntry.Admin

    Public Class QuadroSinottico
        Inherits Page

        Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load

        End Sub

        <WebMethod()> _
        Public Shared Function GetSinotticoData(dataDa As String) As List(Of Dictionary(Of String, String))

            Dim data = DateTime.Now.AddDays(-7)

            Try
                DateTime.TryParse(dataDa, data)

                'Return Utility.GetListFromDataTable(DataAdapterManager.GetSinottico(data))
                'MODIFICA ETTORE 2019-03-25: usato altra funzione per discriminare le SP da eseguire in base alla selezione dell'utente
                Return Utility.GetListFromDataTable(DataAdapterManager.GetSinottico2(data))

            Catch ex As Exception

                ExceptionsManager.TraceException(ex)

                Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)

                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)

                Throw
            Finally
                DataAdapterManager.PortalAdminDataAdapterManager.TracciaAccessi(HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry, "Sinottico| DataDa: " & data.ToString("d"))
            End Try
        End Function

        <WebMethod()> _
        Public Shared Function GetSinotticoDettaglioData(sistema As String, dataDa As String) As List(Of Dictionary(Of String, String))
            Try
                Dim data = DateTime.Now.AddDays(-7)

                DateTime.TryParse(dataDa, data)

                'Return Utility.GetListFromDataTable(DataAdapterManager.GetSinotticoDettaglio(sistema, data))
                'MODIFICA ETTORE 2019-03-25: usato altra funzione per discriminare le SP da eseguire in base alla selezione dell'utente
                Return Utility.GetListFromDataTable(DataAdapterManager.GetSinotticoDettaglio2(sistema, data))

            Catch ex As Exception

                ExceptionsManager.TraceException(ex)

                Dim portal = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)

                portal.TracciaErrori(ex, HttpContext.Current.User.Identity.Name, PortalsNames.OrderEntry)

                Throw
            End Try
        End Function

    End Class

End Namespace