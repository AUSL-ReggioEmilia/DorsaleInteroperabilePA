Imports System
Imports System.Web.UI
Imports System.Net
Imports System.Security.Principal
Imports DI.OrderEntry.DwhNewsServiceReference
Imports System.Xml
Imports DI.PortalUser2.Data

Namespace DI.PortalUser.Home

    Public Class HomePage
        Inherits Page

        Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load
            Try
                LoadDwhNews()
            Catch ex As Exception
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                If Not String.IsNullOrEmpty(sErrorMessage) Then
                    divErrorMessage.Visible = True
                    LabelError.Text = sErrorMessage
                End If
                Call SetDetailVisible(False)
            End Try
        End Sub

        Private Sub LoadDwhNews()

            '*******************************************************************************************
            ' Per non visualizzare le News Wss basta porre in configurazione 
            ' DwhNewsLists.ListName = "" OPPURE DwhNewsLists.Lists = ""
            '*******************************************************************************************
            '
            ' Se DwhNewsLists.Impersonificate=False, DwhNewsLists.User=""
            ' --> connessione integrata al webservice con l'utente dell'application pool
            '       (che deve essere un reader della lista e delle immagini wss)
            '
            ' Se DwhNewsLists.Impersonificate=True, DwhNewsLists.User=""
            ' --> connessione integrata al webservice con l'utente correntemente loggato
            '       (che deve essere un reader della lista e delle immagini wss)
            '
            ' Se DwhNewsLists.User <> "" (per qualsiasi valore di DwhNewsLists.Impersonificate)
            ' --> connessione basic al webservice (nessuna impersonificazione)
            '       (DwhNewsLists.User deve essere un reader della lista e delle immagini wss)
            '
            ' ATTENZIONE: Le immagini usate nella lista WSS devono essere accedute da tutti gli utenti: 
            '             l'accesso alle immagini viene fatto dalla pagina HTML composta dalla 
            '             trasformazione XSLT
            '   
            Dim impersonationContext As WindowsImpersonationContext = Nothing

            Try
                Dim nomeLista As String = My.Settings.DwhNewsListName 'In produzione deve essere il GUID della Lista

                ''tblDwhNews.Visible = False

                If nomeLista.Length > 0 Then
                    '
                    ' Imposto il titolo della lista delle news
                    '
                    lblNewsTitle.Text = My.Settings.DwhNewsTitle
                    '
                    ' Numero max di righe da visualizzare
                    '
                    Dim numeroMassimoRighe As Integer = My.Settings.DwhNewsMaxRowsNumber
                    '
                    ' Utente e password
                    '
                    Dim user As String = My.Settings.DwhNewsUser
                    Dim password As String = My.Settings.DwhNewsPassword
                    '
                    ' Impersonificazione
                    '
                    Dim impersonate As Boolean = My.Settings.DwhNewsImpersonate
                    If impersonate AndAlso user.Length = 0 Then
                        impersonationContext = WindowsIdentity.GetCurrent().Impersonate()
                    End If

                    Dim webService As New DI.OrderEntry.DwhNewsServiceReference.ListsSoapClient()

                    Call SetDwhNewsWsCredential(webService, user, password)

                    Dim xmlDoc As New XmlDocument()
                    Dim query As XmlElement = xmlDoc.CreateElement("Query")
                    Dim viewFields As XmlElement = xmlDoc.CreateElement("ViewFields")
                    Dim queryOptions As XmlElement = xmlDoc.CreateElement("QueryOptions")

                    query.InnerXml = String.Empty
                    queryOptions.InnerXml = String.Empty
                    viewFields.InnerXml = String.Empty

                    Dim xQuery As XElement
                    Using reader As New XmlNodeReader(query)
                        xQuery = XElement.Load(reader)
                    End Using

                    Dim xViewFields As XElement
                    Using reader As New XmlNodeReader(viewFields)
                        xViewFields = XElement.Load(reader)
                    End Using

                    Dim xQueryOptions As XElement
                    Using reader As New XmlNodeReader(queryOptions)
                        xQueryOptions = XElement.Load(reader)
                    End Using

                    Dim xNode As XNode = webService.GetListItems(nomeLista, String.Empty, xQuery, xViewFields, numeroMassimoRighe, xQueryOptions, Nothing)

                    If xNode IsNot Nothing Then

                        Dim doc As New XmlDocument()
                        Using reader = xNode.CreateReader()
                            doc.Load(reader)
                        End Using

                        Dim xmlNode As XmlNode = doc.DocumentElement
                        '
                        ' Attenzione: i nodi da elaborare sono quelli con tag <z:row ... />
                        '
                        If xmlNode.SelectNodes("/*/*/*").Count > 0 Then
                            '
                            ' Elaboro per aggiungere ulteriori dati utilizzati dalla trasformazione XSLT                        
                            '
                            Dim urlDetail As String = My.Settings.DwhNewsUrlDetail

                            For Each node As XmlNode In xmlNode.SelectNodes("/*/*/*")

                                If urlDetail.Length > 0 Then

                                    Dim attributeId As XmlAttribute = node.Attributes("ows_ID")
                                    If attributeId IsNot Nothing Then
                                        '
                                        ' Compongo l'url al dettaglio                                    '
                                        '
                                        Dim attribute As XmlAttribute = node.OwnerDocument.CreateAttribute("UrlDetail")
                                        attribute.Value = String.Format(urlDetail, attributeId.Value)
                                        node.Attributes.Append(attribute)
                                    End If
                                End If
                            Next
                        End If
                        '
                        ' Applico la trasformazione XSLT all'XML restituito dal web service                    
                        '
                        Me.DwhNews.XPathNavigator = doc.CreateNavigator()
                        Me.DwhNews.TransformSource = "~/Styles/WssNews.xsl"
                    End If
                End If
            Catch ex As Exception
                Call GestioneErrori.WriteException(ex)
                divErrorMessage.Visible = True
                LabelError.Text = "Si è verificato un errore durante la visualizzazione delle news del DwhClinico. Contattare l'amministratore"
                ' Nascondo il contenitore delle news
                DivNews.Visible = False
                '
                ' Scrivo l'errore nel database
                '
                Dim portalAdminDataAdapterManager = New PortalDataAdapterManager(ConfigurationManager.ConnectionStrings(Utility.PORTAL_USER_CONNECTION_STRING).ConnectionString)
                portalAdminDataAdapterManager.TracciaErrori(ex, User.Identity.Name, PortalsNames.Home)

            Finally
                If impersonationContext IsNot Nothing Then
                    impersonationContext.Undo()
                    impersonationContext.Dispose()
                End If
            End Try
        End Sub


        ''' <summary>
        ''' Da usare in caso di errore per nascondere le componenti della pagina
        ''' </summary>
        ''' <param name="bVisible"></param>
        ''' <remarks></remarks>
        Private Sub SetDetailVisible(bVisible As Boolean)
            DivNews.Visible = bVisible
        End Sub


        ''' <summary>
        ''' Impostazioni delle credenziali del web service delle news del Dwh
        ''' </summary>
        ''' <param name="oWs"></param>
        ''' <param name="sUser"></param>
        ''' <param name="sPassword"></param>
        ''' <remarks></remarks>
        Private Sub SetDwhNewsWsCredential(ByVal oWs As DI.OrderEntry.DwhNewsServiceReference.ListsSoapClient, sUser As String, sPassword As String)
            '
            ' Se User="" e Password="" -> authenticazione integrata altrimenti Basic
            '
            Utility.SetWCFCredentials(oWs.ChannelFactory.Endpoint.Binding, oWs.ClientCredentials, sUser, sPassword)
        End Sub


    End Class

End Namespace