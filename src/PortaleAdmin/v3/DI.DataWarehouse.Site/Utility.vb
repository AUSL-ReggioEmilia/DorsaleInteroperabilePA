Imports System
Imports System.Web
Imports System.Configuration
Imports System.Data.SqlTypes
Imports System.Runtime.CompilerServices

Public NotInheritable Class Utility

#Region "OSCURAMENTI"
    Public Shared OscuramentoModificato As String = "Modificato"
    Public Shared OscuramentoInserito As String = "Inserito"
    Public Shared OscuramentiStatiInattivi As String() = {OscuramentoModificato, OscuramentoInserito}
    Public Shared OscuramentoCompletato As String = "Completato"
    'Dim OscuramentiStatiAttivi As String() = {"Modificato", "Inserito"}

#End Region






    ''' <summary>
    ''' Da utilizzare nella pagina navigata per aggiungere i parametri di query string all'url associato al ramo del tree cosi da poter navigare all'indietro tramite il menù di navigazione orizzontale
    ''' </summary>
    ''' <param name="oSiteMapNode">Normalmente uguale a SiteMap.CurrentNode</param>
    ''' <param name="sQueryString">L'intero query string da aggiungere all'url</param>
    ''' <remarks></remarks>
    Public Shared Sub SetSiteMapNodeQueryString(oSiteMapNode As SiteMapNode, sQueryString As String)
        Try
            If oSiteMapNode IsNot Nothing Then
                oSiteMapNode.ReadOnly = False
                sQueryString = sQueryString.TrimStart("?")
                sQueryString = String.Concat("?", sQueryString)
                oSiteMapNode.Url = String.Concat(oSiteMapNode.Url.Split("?")(0), sQueryString)
            End If
        Catch
        End Try
    End Sub


    ''' <summary>
    ''' Mostra il Testo passato nella Label e la rende visibile
    ''' </summary>
    ''' <param name="Label">Label da mostrare</param>
    ''' <param name="Text">Testo da visualizzare</param>
    ''' <remarks></remarks>
    Public Shared Sub ShowErrorLabel(Label As UI.WebControls.Label, Text As String)

        Label.Text = Text
        Label.Visible = Text.Length > 0

    End Sub

    ''' <summary>
    ''' Gestione errori con LOG sia su Eventlog che su server SQL
    ''' </summary>
    ''' <param name="exception">Eccezione</param>
    ''' <param name="Log_To_DB">Attivare la scrittura su server SQL</param>
    ''' <returns>Stringa da visualizzare in interfaccia grafica</returns>
    Public Shared Function TrapError(Exception As Exception, Log_To_DB As Boolean) As String

        'Log su Event log e ricavo un messaggio comprensibile
        Dim sRet As String = GestioneErrori.TrapError(Exception)

        'eventualmente loggo anche su SQL
        If Log_To_DB Then
            Try
                Dim portal = New DI.PortalAdmin.Data.PortalDataAdapterManager(ConfigurationManager.ConnectionStrings("AuslAsmnRe_PortalAdminConnectionString").ConnectionString)
                portal.TracciaErrori(Exception, HttpContext.Current.User.Identity.Name, DI.PortalAdmin.Data.PortalsNames.DwhClinico)
            Catch ex As Exception
                GestioneErrori.TrapError(ex)
            End Try
        End If
        Return sRet

    End Function


    ''' <summary>
    ''' Utilità per la validazione dei tipi dato SQL
    ''' </summary>
    ''' <remarks></remarks>
    Public Class SQLTypes

        Public Shared Function IsValidGuid(candidate As String)
            Try
                SqlGuid.Parse(candidate)
                Return True
            Catch 'ex As Exception
                Return False
            End Try
        End Function

        Public Shared Function IsValidDateTime(candidate As String)
            Try
                Dim dt As DateTime = DateTime.Parse(candidate)
                'formato SortableDateTime: "2008-03-09T16:05:07" 
                SqlDateTime.Parse(String.Format("{0:s}", dt))
                Return True
            Catch 'ex As Exception
                Return False
            End Try
        End Function

    End Class



#Region "Conversioni"

    ''' <summary>
    ''' Ritorna Nothing se Value è NULL o stringa vuota, altrimenti Value
    ''' </summary>
    Public Shared Function StringEmptyDBNullToNothing(Value As Object) As String
        If Value Is DBNull.Value OrElse String.IsNullOrEmpty(Value) Then
            Return Nothing
        Else
            Return Value
        End If
    End Function

    ''' <summary>
    ''' Ritorna DefaultValue se Value è NULL, altrimenti Value
    ''' </summary>
    Public Shared Function IsNull(Of T)(ByVal Value As T, ByVal DefaultValue As T) As T
        If Value Is Nothing OrElse Convert.IsDBNull(Value) Then
            Return DefaultValue
        Else
            Return Value
        End If
    End Function

    ''' <summary>
    ''' Ritorna Nothing se Value è Null, altrimenti Value convertito nel tipo scelto
    ''' Utilizzo: GetNullable(Of String)(Value)
    ''' </summary>
    Public Shared Function GetNullable(Of T)(Value As Object) As T
        If Convert.IsDBNull(Value) Then
            Return Nothing
        Else
            Return CType(Value, T)
        End If
    End Function


#End Region

End Class

Module Extensions

    ''' <summary>
    ''' Aggiunge o modifica il parametro passato alla querystring della pagina
    ''' </summary>
    ''' <param name="page"></param>
    ''' <param name="Name">Nome parametro</param>
    ''' <param name="Value">Valore</param>
    ''' <returns>L'intero URL completo di querystring modificata</returns>
    <System.Runtime.CompilerServices.Extension>
    Public Function ModifyQueryStringParameter(page As UI.Page, Name As String, Value As String) As String

        Dim nameValues = System.Web.HttpUtility.ParseQueryString(page.Request.QueryString.ToString())
        nameValues.[Set](Name, Value)
        Return String.Concat(page.Request.Url.AbsolutePath, "?", nameValues.ToString())

    End Function


End Module

Module GlobalObject

    Public gObjNotificaRefertiSynclock As Object = New Object

    Public gObjNotificaRicoveriSynclock As Object = New Object

End Module



