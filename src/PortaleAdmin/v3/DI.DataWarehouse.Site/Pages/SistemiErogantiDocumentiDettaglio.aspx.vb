Imports System
Imports System.Data.SqlClient
Imports System.Web.UI
Imports DI.DataWarehouse.Admin.Data
Imports System.Web.UI.WebControls
Imports System.Web
Imports System.IO
Imports DI.DataWarehouse.Admin.Data.BackEndDataSet

Namespace DI.DataWarehouse.Admin

    Partial Class SistemiErogantiDocumentiDettaglio
        Inherits Page

        Protected _mainDataSet As New DI.DataWarehouse.Admin.Data.BackEndDataSet
        Private _idDocumento As String

        ' Uso un valore costante perchè quando si ritorna dall'upload voglio ottenere il dataset precedente        
        Private _pageId As String = "{3F10A087-5C8D-4d10-8FD9-D7947B372964}"

#Region "Registrazione script lato client"

        Protected Overrides Sub OnPreRender(ByVal e As EventArgs)

            If Not Page.ClientScript.IsClientScriptBlockRegistered(Me.GetType.Name) Then
                Dim clientCode As String = Constants.JSOpenWindowFunction() & Environment.NewLine
                Page.ClientScript.RegisterClientScriptBlock(GetType(Page), Me.GetType.Name, Constants.JSBuildScript(clientCode))
            End If

        End Sub

#End Region

        Private Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles MyBase.Load
            Try
                If Not IsPostBack Then
                    ViewDocumentLink.Visible = False
                    If Request.UrlReferrer IsNot Nothing Then
                        ViewState(Constants.UrlReturn) = Me.ResolveUrl("~/Pages/SistemiErogantiDocumentiLista.aspx")
                    End If

                    _idDocumento = Request.QueryString(Constants.Id)
                    If Not String.IsNullOrEmpty(_idDocumento) Then
                        DataAdapterManager.SistemiErogantiDocumentiDettaglio(New Guid(_idDocumento), _mainDataSet)
                    Else
                        If Session(_pageId & "_" & Constants.DataSet) IsNot Nothing Then
                            _mainDataSet = DirectCast(Session(_pageId & "_" & Constants.DataSet), DI.DataWarehouse.Admin.Data.BackEndDataSet)
                        Else
                            '
                            ' E' la prima volta che entro nella pagina e sono in inserimento -> aggiungo una riga
                            '
                            _mainDataSet.SistemiErogantiDocumentiDettaglio.Clear()
                            _mainDataSet.SistemiErogantiDocumentiDettaglio.ContenutoColumn.ReadOnly = False

                            Dim newRow As SistemiErogantiDocumentiDettaglioRow = _mainDataSet.SistemiErogantiDocumentiDettaglio.NewSistemiErogantiDocumentiDettaglioRow()

                            newRow.Id = Guid.NewGuid()
                            newRow.IdSistemaErogante = Guid.NewGuid()
                            newRow.SetContenutoNull()
                            newRow.Nome = ""
                            newRow.Estensione = ""
                            newRow.Dimensione = 0
                            newRow.ContentType = ""

                            _mainDataSet.SistemiErogantiDocumentiDettaglio.AddSistemiErogantiDocumentiDettaglioRow(newRow)
                        End If
                    End If

                    If _mainDataSet.SistemiErogantiDocumentiDettaglio(0).Id <> Guid.Empty Then
                        ViewDocumentLink.NavigateUrl = GetViewerUrl(_mainDataSet.SistemiErogantiDocumentiDettaglio(0).Id)
                        ViewDocumentLink.Visible = True
                    End If

                    ' Se si proviene dalla pagina di upload salvo i dati nel dataset/datatable                
                    If Upload.UploadSuccessFully Then
                        LoadDataFromUpload(_mainDataSet.SistemiErogantiDocumentiDettaglio, Upload.HttpPostedFile)
                    End If

                    Session(_pageId & "_" & Constants.DataSet) = _mainDataSet

                    Me.DataBind()

                    Dim id As String = _mainDataSet.SistemiErogantiDocumentiDettaglio(0).IdSistemaErogante.ToString()

                    Try
                        Dim listItem As ListItem = SistemaEroganteDropDownList.Items.FindByValue(id.ToUpper())
                        SistemaEroganteDropDownList.SelectedIndex = SistemaEroganteDropDownList.Items.IndexOf(listItem)
                    Catch
                    End Try
                Else
                    _mainDataSet = DirectCast(Session(_pageId & "_" & Constants.DataSet), DI.DataWarehouse.Admin.Data.BackEndDataSet)
                End If

                ' I pulsanti sono abilitati solo se siamo in Modifica o l'utente è ritornato dalla pagina di upload
                Dim buttonEnabled As Boolean = NomeTextBox.Text.Length > 0
                OkButton.Enabled = buttonEnabled
                SalvaButton.Enabled = buttonEnabled
                EliminaButton.Enabled = buttonEnabled

                EliminaButton.Attributes.Item("onclick") = "return confirm('Confermi la cancellazione del record?');"

            Catch ex As Exception
                Dim sMessage As String = Utility.TrapError(ex, True)
                Utility.ShowErrorLabel(LabelError, sMessage)
            End Try
        End Sub

        Private Sub EliminaButton_Click(ByVal sender As Object, ByVal e As EventArgs) Handles EliminaButton.Click
            Try
                DataAdapterManager.SistemiErogantiDocumentiRimuovi(_mainDataSet.SistemiErogantiDocumentiDettaglio(0).Id)
                ReturnToList()
            Catch ex As Exception
                Dim sMessage As String = Utility.TrapError(ex, True)
                Utility.ShowErrorLabel(LabelError, sMessage)
            End Try
        End Sub

        Private Sub RitornaButton_Click(ByVal sender As Object, ByVal e As EventArgs) Handles RitornaButton.Click
            ReturnToList()
        End Sub

        Private Sub OkButton_Click(ByVal sender As Object, ByVal e As EventArgs) Handles OkButton.Click

            If SaveDataset() Then
                ReturnToList()
            End If
        End Sub

        Private Sub SalvaButton_Click(ByVal sender As Object, ByVal e As EventArgs) Handles SalvaButton.Click

            If SaveDataset() Then
                ViewDocumentLink.NavigateUrl = GetViewerUrl(_mainDataSet.SistemiErogantiDocumentiDettaglio(0).Id)
                ViewDocumentLink.Visible = True
            End If
        End Sub

        Private Sub Commit()

            _mainDataSet.SistemiErogantiDocumentiDettaglio(0).IdSistemaErogante = New Guid(SistemaEroganteDropDownList.SelectedValue)

        End Sub

        Private Function SaveDataset() As Boolean
            Try
                Commit()
                DataAdapterManager.SistemiErogantiDocumentiAggiorna(_mainDataSet)
                Return True

            Catch ex As SqlException

                Dim message As String

                Select Case ex.Number
                    Case 2627
                        message = String.Format("Errore di chiave univoca. Esiste già un record associato al sistema erogante '{0}'", SistemaEroganteDropDownList.SelectedItem.Text)
                    Case 547
                        message = "Errore di integrità referenziale. Il record è in uso in altre tabelle."
                    Case Else
                        Throw
                End Select

                Utility.ShowErrorLabel(LabelError, String.Format("Si è verificato un errore durante il salvataggio dei dati:<br />{0}", message))
                Return False

            End Try
        End Function

        Private Sub ReturnToList()

            Dim url As String = ViewState(Constants.UrlReturn) & ""
            If Not String.IsNullOrEmpty(url) Then
                Session.Remove(_pageId & "_" & Constants.DataSet)
                Response.Redirect(Me.ResolveUrl(url))
            End If
        End Sub

        Protected Sub UploadButton_Click(ByVal sender As Object, ByVal e As EventArgs) Handles UploadButton.Click
            Try
                Commit()
                Session(_pageId & "_" & Constants.DataSet) = _mainDataSet

                Dim urlUploadPage As String = Me.ResolveUrl("~/Pages/FileUpload.aspx")

                Dim returnUrl As String = Me.Request.Url.LocalPath
                Dim maxFileSize As Integer = 0 ' nessun limite
                Upload.NavigateToUploadPage(urlUploadPage, "Upload documenti Sistemi Eroganti", Nothing, returnUrl, maxFileSize, "", "")

            Catch ex As Exception
                Dim sMessage As String = Utility.TrapError(ex, True)
                Utility.ShowErrorLabel(LabelError, sMessage)
            End Try
        End Sub

#Region "Funzioni usate nella parte HTML"

        Protected Function GetFileName(ByVal nome As Object, ByVal estensione As Object) As String

            If nome IsNot Nothing AndAlso nome.length > 0 AndAlso estensione IsNot Nothing AndAlso estensione.length > 0 Then

                Return nome & "." & estensione
            Else
                Return String.Empty
            End If
        End Function

#End Region

#Region "Caricamento dei dati provenienti dall'upload "

        ''' <summary>
        ''' Scrive nella data table i dati di upload
        ''' </summary>
        ''' <param name="table"></param>
        ''' <param name="httpPostedFile"></param>
        ''' <remarks></remarks>
        Private Sub LoadDataFromUpload(ByVal table As SistemiErogantiDocumentiDettaglioDataTable, ByVal httpPostedFile As HttpPostedFile)

            Dim row As SistemiErogantiDocumentiDettaglioRow = table(0)

            Dim document As Byte()

            row.Nome = Path.GetFileNameWithoutExtension(httpPostedFile.FileName)
            row.Estensione = Path.GetExtension(httpPostedFile.FileName).TrimStart("."c)
            row.ContentType = httpPostedFile.ContentType

            Dim fileSize As Integer = httpPostedFile.ContentLength
            ReDim document(fileSize)
            httpPostedFile.InputStream.Read(document, 0, fileSize)

            ' La sp che legge il dettaglio potrebbe restituire un campo readonly             
            row.Table.Columns(table.ContenutoColumn.ColumnName).ReadOnly = False
            row.Contenuto = document
            row.Dimensione = fileSize
        End Sub

#End Region

        Protected Function GetViewerUrl(ByVal idDocumento As Guid) As String

            Return String.Format("{0}?{1}={2}&{3}={4}", Me.ResolveUrl("~/DocumentViewer.ashx"), Constants.IdDocument, idDocumento.ToString, Constants.DocumentTableName, "SistemiErogantiDocumenti")           
        End Function

    End Class

End Namespace