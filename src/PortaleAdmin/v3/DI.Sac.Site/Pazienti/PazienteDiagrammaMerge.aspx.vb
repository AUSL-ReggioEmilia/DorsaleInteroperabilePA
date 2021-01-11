Imports System.Web
Imports System
Imports System.Web.UI.HtmlControls
Imports System.Web.UI.WebControls
Imports System.Diagnostics
Imports DI.Sac.Admin.Data.PazientiDataSet
Imports DI.Sac.Admin.Data.PazientiDataSetTableAdapters
Imports DI.PortalAdmin.Data

Namespace DI.Sac.Admin

    Partial Public Class PazienteDiagrammaMerge
        Inherits System.Web.UI.Page

        Private _idPaziente As String

        Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load

            _idPaziente = Request.Params("id")

            If Not Page.IsPostBack Then

                ' Set della proprietà url del CurrentNode.ParentNode con l'id del paziente fuso                
                If SiteMap.CurrentNode IsNot Nothing Then
                    SiteMap.CurrentNode.ParentNode.ReadOnly = False
                    SiteMap.CurrentNode.ParentNode.Url = String.Concat(SiteMap.CurrentNode.ParentNode.Url.Split("?")(0), "?id=", _idPaziente)
                End If

                Try
                    ' Paziente corrente
                    Using adapter As New PazientiGestioneTableAdapter()
                        PazienteCorrente = adapter.GetData(New Guid(_idPaziente))
                    End Using

                    ' Paziente root della gerarchia di fusione
                    Using adapter As New PazientiMergeTableAdapter()
                        PazienteRoot = adapter.GetDataRootById(PazienteCorrente(0).Id)
                    End Using

                    '
                    '2020-07-02 Kyrylo: Traccia Operazioni
                    '
                    Dim oTracciaOp As New TracciaOperazioniManager(Global_asax.ConnectionStringPortalAdmin)
                    oTracciaOp.TracciaOperazione(PortalsNames.Sac, Page.AppRelativeVirtualPath, "Visualizzato diagramma fusioni", New Guid(_idPaziente))


                Catch ex As Exception
                    ExceptionsManager.TraceException(ex)
                    LabelError.Visible = True
                    LabelError.Text = MessageHelper.GetGridViewMessage(TypeGridViewError.CaricamentoDati)
                End Try
            End If

            ' Renderizzo il diagramma
            If PazienteRoot IsNot Nothing Then
                Dim tableResult As HtmlTable = WriteDiagram(PazienteRoot.Rows(0), True)
                divDiagram.Controls.Add(tableResult)
            End If
        End Sub

        Private Function GetArrowPanel() As HtmlImage

            Dim imageArrow = New HtmlImage()

            imageArrow.Src = "../Images/arrow_up.png"
            imageArrow.Alt = ""
            imageArrow.Border = 0

            Return imageArrow
        End Function

        Private Function WriteNode(ByVal row As PazientiMergeRow, ByVal isRoot As Boolean) As HtmlGenericControl

            Dim cssClass As String = String.Empty
            Dim backgroundColor As String = String.Empty
            Dim mainContainerResult As New HtmlGenericControl("div")
            Dim extraPanel As HtmlGenericControl = Nothing

            ' Stile bordo            
            If isRoot Then
                cssClass = "DiagramRoot"
                extraPanel = Nothing
            Else
                cssClass = "DiagramChild"
                extraPanel = New HtmlGenericControl("div")
                extraPanel.Controls.Add(GetArrowPanel)
            End If

            ' Stile paziente corrente            
            If Guid.Equals(row.IdPazienteFuso, PazienteCorrente(0).Id) Then

                backgroundColor = "#FFEDA4"
                ' ATTENZIONE: PRIMA SI POTEVA ESEGUIRE IL DEMERGE SOLO PER ANAGRAFICHE FIGLIE DELLA ROOT
                ' Se il paziente corrente è stato fuso nel paziente root abilito la cancellazione                
                'If Guid.Equals(row.IdPaziente, PazienteRoot(0).IdPaziente) AndAlso Not isRoot Then
                '
                '   MODIFICA ETTORE: 2017-09-07: DEMERGE per qualsiasi anagrafica figlia.
                '   Attenzione è stata modificata la SP PazientiUIMergeDelete (ora fa uso della PazientiBaseMerge)
                '
                ' Solo se il paziente fuso non è la ROOT visualizzo il link per il DEMERGE
                If Not Guid.Equals(row.IdPazienteFuso, PazienteRoot(0).IdPaziente) AndAlso Not isRoot Then

                    Dim span As New HtmlGenericControl("span")

                    Dim linkButton = New LinkButton()
                    linkButton.OnClientClick = "return confirm('Procedere con l\'eliminazione della fusione?');"
                    linkButton.Text = "<br /><img src='../Images/delete.gif' alt='Elimina Fusione' class='toolbar-img'/>Elimina Fusione"

                    AddHandler linkButton.Click, AddressOf EliminaFusione

                    span.Controls.Add(linkButton)

                    extraPanel = New HtmlGenericControl("div")
                    extraPanel.Controls.Add(GetArrowPanel)
                    extraPanel.Controls.Add(span)
                End If
            End If

            Dim provenienza As String = row.Provenienza
            Dim idProvenienza As String = row.IdProvenienza
            Dim cognome As String = String.Empty
            Dim nome As String = String.Empty
            Dim dataNascita As String = "-"
            Dim codiceFiscale As String = "-"

            If Not row.IsCognomeNull() Then cognome = row.Cognome
            If Not row.IsNomeNull() Then nome = row.Nome
            If Not row.IsDataNascitaNull() Then dataNascita = row.DataNascita.ToShortDateString()
            If Not row.IsCodiceFiscaleNull() Then codiceFiscale = row.CodiceFiscale

            Dim ContentPanel As New HtmlGenericControl("div")

            ContentPanel.Attributes.Add("class", cssClass)
            ContentPanel.Style.Add("background-color", backgroundColor)
            ContentPanel.InnerHtml = "<p><a href='PazienteDettaglio.aspx?id=" & row.IdPazienteFuso.ToString() & "'>" &
                                                   cognome & " " & nome & "</a></p>" &
                                                   "<p>Provenienza: <b>" & provenienza & " (" & idProvenienza & ")</b>" &
                                                   "<br />Data Nascita: " & dataNascita &
                                                   "<br />Codice Fiscale: " & codiceFiscale & "</p>"

            If extraPanel IsNot Nothing Then
                mainContainerResult.Controls.Add(extraPanel)
            End If

            mainContainerResult.Controls.Add(ContentPanel)

            Return mainContainerResult
        End Function

        Private Function WriteDiagram(ByVal row As PazientiMergeRow, ByVal isRoot As Boolean) As HtmlTable

            Dim children As New PazientiMergeDataTable()

            Using adapter As New PazientiMergeTableAdapter()
                adapter.Fill(children, row.IdPazienteFuso)
            End Using

            Dim table As New HtmlTable()
            Dim tr As New HtmlTableRow()
            Dim td As New HtmlTableCell()

            td.Align = "center"
            td.VAlign = "top"
            td.Style.Add("padding-left", "12px")
            td.Style.Add("padding-bottom", "2px")

            ' Add nodo corrente           
            td.Controls.Add(WriteNode(row, isRoot))
            tr.Controls.Add(td)
            table.Controls.Add(tr)

            ' Colspan (colspan sulla td del genitore con valore uguale al num. figli)            
            Dim numeroFigli As Integer = children.Rows.Count
            If numeroFigli > 1 Then
                td.ColSpan = numeroFigli
                td.Style.Add("border-bottom", "solid 1px #009900")
                td.Controls.Add(GetArrowPanel)
            End If

            ' Add nuova riga figli            
            tr = New HtmlTableRow()

            ' Ciclo le righe figlio            
            For Each child As PazientiMergeRow In children

                td = New HtmlTableCell()

                td.Align = "center"
                td.VAlign = "top"

                td.Controls.Add(WriteDiagram(child, False))
                tr.Controls.Add(td)
            Next

            table.Controls.Add(tr)

            Return table
        End Function

        Protected Sub EliminaFusione(ByVal sender As Object, ByVal e As EventArgs)
            Try
                ' Eliminazione fusioni/sinonimi                
                Dim idPaziente As Guid = PazienteRoot(0).IdPaziente
                Dim idPazienteFuso As Guid = PazienteCorrente(0).Id

                ' Eseguo il demerge
                Using adapter As New PazientiMergeTableAdapter()
                    adapter.PazientiMergeDelete2(idPaziente, idPazienteFuso, User.Identity.Name)
                    ' 
                    ' Ora la SP PazientiMergeDelete2 sistema i campi Disattivato e DataDisattivazione
                    ' Unica differenza da prima non pone a GETDATE() la DataModifica del record staccato 
                    ' cosi il record non viene considerato dalla BatchMerge e l'operatore ha il tempo di fonderlo 
                    ' nella posizione che desidera...
                    '
                End Using

                Cache("PazientiGestioneLista") = DateTime.Now()

                Response.Redirect(String.Concat("PazienteDettaglio.aspx?id=", _idPaziente), False)

            Catch ex As Exception
                ExceptionsManager.TraceException(ex)
                LabelError.Visible = True
                LabelError.Text = MessageHelper.GetGridViewMessage(TypeGridViewError.Aggiornamento)
            End Try
        End Sub

        ''' <summary>
        ''' Serializza nel ViewState il paziente corrente
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Private Property PazienteCorrente() As PazientiGestioneDataTable
            Get
                Dim o As Object = ViewState("PazienteCorrente")
                If o Is Nothing Then Return Nothing Else Return DirectCast(o, PazientiGestioneDataTable)
            End Get
            Set(ByVal Value As PazientiGestioneDataTable)
                ViewState("PazienteCorrente") = Value
            End Set
        End Property

        ''' <summary>
        ''' Serializza nel ViewState il paziente root della gerarchia di fusione
        ''' </summary>
        ''' <value></value>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Private Property PazienteRoot() As PazientiMergeDataTable
            Get
                Dim o As Object = ViewState("PazienteRoot")
                If o Is Nothing Then Return Nothing Else Return DirectCast(o, PazientiMergeDataTable)
            End Get
            Set(ByVal Value As PazientiMergeDataTable)
                ViewState("PazienteRoot") = Value
            End Set
        End Property

    End Class
End Namespace