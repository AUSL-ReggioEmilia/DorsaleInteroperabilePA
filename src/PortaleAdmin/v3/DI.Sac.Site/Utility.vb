Imports System
Imports System.Data.SqlTypes
Imports System.Web
Imports DI.Sac.Admin
Imports Microsoft.VisualBasic.Constants


Public Class Utility

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
    ''' Funzione per scrivere nel trace (si visualizza con DebugView)
    ''' </summary>
    ''' <remarks></remarks>
    Public Shared Sub TraceWriteLine(sMessage As String)
        System.Diagnostics.Trace.WriteLine(String.Concat("SAC-ADMIN: ", sMessage))
    End Sub


#Region " Funzioni generiche per la cache "

    Public Class MyCache

        Public Shared Sub Write(sKey As String, value As Object, iSecToLive As Integer)
            If iSecToLive <= 0 Then iSecToLive = 60
            HttpContext.Current.Cache.Add(sKey, value, Nothing, System.DateTime.Now.AddSeconds(iSecToLive), Caching.Cache.NoSlidingExpiration, Caching.CacheItemPriority.Normal, Nothing)
        End Sub

        Public Shared Function Read(sKey As String) As Object
            Return HttpContext.Current.Cache(sKey)
        End Function

        Public Shared Sub Remove(sKey As String)
            HttpContext.Current.Cache.Remove(sKey)
        End Sub

    End Class

#End Region


    ''' <summary>
    ''' Ricava la data di decesso dal codice di terminazione e dalla data di terminazione
    ''' </summary>
    ''' <param name="oCodiceTerminazione"></param>
    ''' <param name="oDataTerminazione"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Function GetDataDecesso(oCodiceTerminazione As Object, oDataTerminazione As Object) As String
        If Not (oCodiceTerminazione Is System.DBNull.Value) Then
            If oCodiceTerminazione & "" = "4" Then
                If Not (oDataTerminazione Is System.DBNull.Value) Then
                    Return CType(oDataTerminazione, System.DateTime).ToShortDateString()
                End If
            End If
        End If
        Return Nothing
    End Function

#Region "Gestione Errori"


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


#End Region

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


#Region "Parsing campo XML degli attributi"

    Public Const ATTRIBUTO_AUTORIZZATORE_NOME = "AutorizzatoreMinoreNome"
    Public Const ATTRIBUTO_AUTORIZZATORE_COGNOME = "AutorizzatoreMinoreCognome"
    Public Const ATTRIBUTO_AUTORIZZATORE_DATANASCITA = "AutorizzatoreMinoreDataNascita"
    Public Const ATTRIBUTO_AUTORIZZATORE_LUOGONASCITA = "AutorizzatoreMinoreLuogoNascita"
    Public Const ATTRIBUTO_AUTORIZZATORE_RELAZIONEMINORE = "AutorizzatoreMinoreRelazione"

    Public Shared Function ShowAttributi(oAttributi As Object) As String
        Dim sRet As String = String.Empty
        If Not oAttributi Is DBNull.Value Then
            Dim sAttributi As String = DirectCast(oAttributi, String)
            Dim oXml As System.Xml.Linq.XDocument = System.Xml.Linq.XDocument.Parse(sAttributi)
            Dim query As System.Collections.Generic.IEnumerable(Of System.Xml.Linq.XElement) = From p In oXml.Root.Elements("Attributo")
            If query.Count > 0 Then
                Dim oSb As New Text.StringBuilder
                For Each oAttributo As System.Xml.Linq.XElement In query
                    Dim sNomeAttributo As String = oAttributo.@Nome

                    Dim sValoreAttributo As String = oAttributo.@Valore
                    If String.Compare(sNomeAttributo, ATTRIBUTO_AUTORIZZATORE_DATANASCITA, True) = 0 Then
                        Dim dDataNascita As Date = Nothing
                        If Date.TryParse(sValoreAttributo, dDataNascita) Then
                            oSb.Append(sNomeAttributo) : oSb.Append(": ") : oSb.Append(dDataNascita.ToString("d")) : oSb.Append("<br/>")
                        End If
                    Else
                        oSb.Append(sNomeAttributo) : oSb.Append(": ") : oSb.Append(sValoreAttributo) : oSb.Append("<br/>")
                    End If
                Next
                sRet = oSb.ToString
            End If
        End If
        '
        ' Restituisco
        '
        Return sRet
    End Function

    Public Shared Function ShowAttributiAutorizzatoreMinore(oAttributi As Object) As String
        Dim sRet As String = String.Empty
        If Not oAttributi Is DBNull.Value Then

            Dim sAttributi As String = DirectCast(oAttributi, String)
            Dim oXml As System.Xml.Linq.XDocument = System.Xml.Linq.XDocument.Parse(sAttributi)
            'Leggo solo gli attributi che iniziano con "AutorizzatoreMinore"
            Dim query As System.Collections.Generic.IEnumerable(Of System.Xml.Linq.XElement) = From p In oXml.Root.Elements("Attributo") Where p.@Nome.StartsWith("AutorizzatoreMinore", StringComparison.CurrentCultureIgnoreCase)
            If query.Count > 0 Then
                Dim oSb As New Text.StringBuilder
                For Each oAttributo As System.Xml.Linq.XElement In query
                    Dim sNomeAttributo As String = oAttributo.@Nome
                    Dim sValoreAttributo As String = oAttributo.@Valore
                    If String.Compare(sNomeAttributo, ATTRIBUTO_AUTORIZZATORE_DATANASCITA, True) = 0 Then
                        Dim dDataNascita As Date = Nothing
                        If Date.TryParse(sValoreAttributo, dDataNascita) Then
                            'Rimuovo il testo "AutorizzatoreMinore"
                            sNomeAttributo = sNomeAttributo.Remove(0, 19)
                            oSb.Append(sNomeAttributo) : oSb.Append(": ") : oSb.Append(dDataNascita.ToString("d")) : oSb.Append("<br/>")
                        End If
                    Else
                        'Rimuovo il testo "AutorizzatoreMinore"
                        sNomeAttributo = sNomeAttributo.Remove(0, 19)
                        oSb.Append(sNomeAttributo) : oSb.Append(": ") : oSb.Append(sValoreAttributo) : oSb.Append("<br/>")
                    End If
                Next
                sRet = oSb.ToString
            End If
        End If
        '
        ' Restituisco
        '
        Return sRet

    End Function

#End Region

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
