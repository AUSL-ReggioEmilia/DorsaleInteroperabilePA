Imports System
Imports System.Data
Imports System.Web
Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports DI.DataWarehouse.Admin.Data.BackEndDataSet
Imports DI.DataWarehouse.Admin.Data.BackEndDataSetTableAdapters

Namespace DI.DataWarehouse.Admin

    Partial Class TipiRefertoDettaglio
        Inherits Page

        Private mPageId As String = Me.GetType().Name
        Private Const BACKPAGE As String = "TipiRefertoLista.aspx"
        Private MimeTypeValidi As String() = {"image/x-png", "image/png"}
        Private Const MaxFileSizeKB As Integer = 20

        ''' <summary>
        ''' Property in viewstate per conservare l'icona corrente / nuova
        ''' </summary>
        Private Property mImageBytes As Byte()
            Get
                Return Me.ViewState("mImageBytes")
            End Get
            Set(value As Byte())
                Me.ViewState("mImageBytes") = value
            End Set
        End Property

        Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

            Try
                If Request.QueryString(Constants.Id) Is Nothing Then
                    '
                    ' PASSO IN MODALITÀ INSERIMENTO
                    '
                    FormViewDettaglio.ChangeMode(FormViewMode.Insert)
                    labelTitolo.Text = "Inserimento Tipo Referto"
                    'IL PULSANTE SALVA DEVE INVOCARE IL METODO INSERT
                    Dim button As Button = FormViewDettaglio.FindControl("butSalva")
                    If button IsNot Nothing Then button.CommandName = "Insert"
                    button = FormViewDettaglio.FindControl("butElimina")
                    If button IsNot Nothing Then button.Visible = False
                Else
                    labelTitolo.Text = "Dettaglio Tipo Referto"
                    FormViewDettaglio.ChangeMode(FormViewMode.Edit)
                End If

                'SE SONO DI RITORNO DALLA PAGINA DI UPLOAD RECUPERO I VALORI DIGITATI NELLE TEXTBOX
                If Upload.UploadSuccessFully Or Upload.UploadCanceled Then
                    FilterHelper.Restore(FormViewDettaglio, mPageId)
                    cmbAziendaErogante.SelectedValue = HttpContext.Current.Session(cmbAziendaErogante.ID & "_" & mPageId)
                    ddlSistemaErogante.SelectedValue = HttpContext.Current.Session(ddlSistemaErogante.ID & "_" & mPageId)
                End If
            Catch ex As Exception
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                Utility.ShowErrorLabel(LabelError, sErrorMessage)
            End Try
        End Sub


        Private Sub Page_PreRenderComplete(sender As Object, e As EventArgs) Handles Me.PreRenderComplete
            Try
                '
                ' SE È STATA CARICATA UN'IMMAGINE NE MOSTRO L'ANTEPRIMA 
                ' PRIMA ANCORA DI AVERLA SALVATA SU DB
                '
                If Upload.UploadSuccessFully Then
                    '
                    'SALVO LA NUOVA ICONA NEL VIEWSTATE, SE OCCORRE PRIMA LA CONVERTO IN PNG					
                    '
                    Dim bMimeTypeOk = Array.Exists(MimeTypeValidi, Function(element)
                                                                       Return element.Equals(Upload.HttpPostedFile.ContentType, StringComparison.InvariantCultureIgnoreCase)
                                                                   End Function)
                    Try
                        If Not bMimeTypeOk Then
                            Dim bmpPostedImage = New Drawing.Bitmap(Upload.HttpPostedFile.InputStream)
                            mImageBytes = ConvertBitmapToPNGBytes(bmpPostedImage)
                        Else
                            mImageBytes = Upload.HttpPostedFileBytes
                        End If
                    Catch ex As Exception
                        Utility.ShowErrorLabel(LabelError, "Errore di conversione file, verificare che il file scelto sia un'immagine valida.")
                        mImageBytes = Nothing
                    End Try
                End If

                If mImageBytes IsNot Nothing AndAlso mImageBytes.Length > 0 Then
                    Dim imgIcona As Image = FormViewDettaglio.FindControl("imgIcona")
                    'TESTO IL NOTHING PERCHÈ L'EVENTO SCATTA ANCHE DOPO POSTBACK TASTO ELIMINA
                    If imgIcona IsNot Nothing Then
                        Dim base64String = Convert.ToBase64String(mImageBytes, 0, mImageBytes.Length)
                        'RENDERING DELL'ICONA DIRETTAMENTE IN BASE64 
                        imgIcona.ImageUrl = "data:image/png;base64," & base64String
                    End If
                End If

            Catch ex As Exception
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                Utility.ShowErrorLabel(LabelError, sErrorMessage)
            End Try

        End Sub

        Private Sub FormViewDettaglio_Init(sender As Object, e As EventArgs) Handles FormViewDettaglio.Init
            '
            ' RIUSO L'EditItemTemplate ANCHE PER L'INSERIMENTO
            '
            FormViewDettaglio.InsertItemTemplate = FormViewDettaglio.EditItemTemplate
        End Sub


        Private Sub FormViewDettaglio_ItemUpdated(sender As Object, e As System.Web.UI.WebControls.FormViewUpdatedEventArgs) Handles FormViewDettaglio.ItemUpdated
            e.KeepInEditMode = True
        End Sub

        Private Sub FormViewDettaglio_ItemInserted(sender As Object, e As System.Web.UI.WebControls.FormViewInsertedEventArgs) Handles FormViewDettaglio.ItemInserted
            e.KeepInInsertMode = True
        End Sub

        Protected Sub FormViewDettaglio_ItemCommand(sender As Object, e As FormViewCommandEventArgs) Handles FormViewDettaglio.ItemCommand
            Try
                Select Case e.CommandName.ToUpper
                    Case "UPLOAD"
                        FilterHelper.SaveInSession(FormViewDettaglio, mPageId)

                        HttpContext.Current.Session.Add(cmbAziendaErogante.ID & "_" & mPageId, cmbAziendaErogante.SelectedValue)
                        HttpContext.Current.Session.Add(ddlSistemaErogante.ID & "_" & mPageId, ddlSistemaErogante.SelectedValue)

                        Dim urlUploadPage As String = Me.ResolveUrl("~/Pages/FileUpload.aspx")
                        Dim returnUrl As String = Me.Request.RawUrl 'percorso virtuale completo di querystring
                        Dim Extensions = "Immagini (*.jpg;*.jpeg;*.gif;*.png)|*.jpg;*.jpeg;*.gif;*.png|"
                        Dim PageInfo = String.Format("Dimensione massima: {0}KB", MaxFileSizeKB)
                        Upload.NavigateToUploadPage(urlUploadPage, "Caricamento file immagine per icona tipo referto", PageInfo, returnUrl, MaxFileSizeKB, Extensions, "")

                    Case "CANCEL"
                        Response.Redirect(BACKPAGE, False)

                End Select

            Catch ex As Exception
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                Utility.ShowErrorLabel(LabelError, sErrorMessage)
            End Try
        End Sub


        Private Sub ods_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsDettaglio.Selected
            Try
                Dim tab = DirectCast(e.ReturnValue, TipiRefertoDataTable)
                If tab.Count = 1 Then
                    mImageBytes = tab(0).Icona

                    If Not String.IsNullOrEmpty(tab(0).SistemaErogante) Then
                        ddlSistemaErogante.SelectedValue = tab(0).SistemaErogante
                    End If

                    If Not String.IsNullOrEmpty(tab(0).AziendaErogante) Then
                        cmbAziendaErogante.SelectedValue = tab(0).AziendaErogante
                    End If
                End If
            Catch ex As Exception
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                Utility.ShowErrorLabel(LabelError, sErrorMessage)
            End Try
        End Sub

        Private Sub ods_HaSalvato(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles odsDettaglio.Updated, odsDettaglio.Deleted, odsDettaglio.Inserted
            If Not ObjectDataSource_TrapError(sender, e) Then
                Response.Redirect(BACKPAGE, False)
            End If
        End Sub

        Private Sub odsDettaglio_Updating(sender As Object, e As ObjectDataSourceMethodEventArgs) Handles odsDettaglio.Updating, odsDettaglio.Inserting
            Try

                ' Se si proviene dalla pagina di upload salvo i dati nel dataset/datatable                
                If mImageBytes IsNot Nothing AndAlso mImageBytes.Length > 0 Then
                    e.InputParameters("Icona") = mImageBytes
                Else
                    e.Cancel = True
                    Utility.ShowErrorLabel(LabelError, "Selezionare un file immagine per l'icona.")
                End If

                'Setto i parametri "AziendaErogante" e "SistemaErogante" dell'objectDataSource.
                e.InputParameters("AziendaErogante") = cmbAziendaErogante.SelectedValue
                e.InputParameters("SistemaErogante") = ddlSistemaErogante.SelectedValue
            Catch ex As Exception
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                Utility.ShowErrorLabel(LabelError, sErrorMessage)
            End Try
        End Sub

#Region "Metodi Shared acceduti dall'esterno"

        ''' <summary>
        ''' RECUPERA L'ICONA PER IL TIPO REFERTO; FUNZIONE CHIAMATA DALL'HANDLER IMAGEHANDLER.ASHX
        ''' </summary>
        ''' <param name="ID"></param>
        ''' <returns></returns>
        Public Shared Function GetImageFromDB(ID As String) As Byte()
            Try
                Using ta As New TipiRefertoTableAdapter
                    Dim dt = ta.GetDataById(New Guid(ID))
                    If dt.Count = 0 Then
                        Return Nothing
                    Else
                        Return dt(0).Icona
                    End If
                End Using

            Catch ex As Exception
                GestioneErrori.TrapError(ex)
                Return Nothing
            End Try
        End Function

#End Region

#Region "Funzioni"

        ''' <summary>
        ''' Gestisce gli errori del ObjectDataSource in maniera pulita
        ''' </summary>
        ''' <returns>True se si è verificato un errore</returns>
        Private Function ObjectDataSource_TrapError(ods As ObjectDataSourceView, e As ObjectDataSourceStatusEventArgs) As Boolean
            Try
                If e.Exception IsNot Nothing AndAlso e.Exception.InnerException IsNot Nothing Then
                    Utility.ShowErrorLabel(LabelError, GestioneErrori.TrapError(e.Exception.InnerException))
                    e.ExceptionHandled = True
                    Return True
                Else
                    Return False
                End If
            Catch ex As Exception
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                Utility.ShowErrorLabel(LabelError, sErrorMessage)
                Return True
            End Try

        End Function

        Private Function ConvertBitmapToPNGBytes(bmp As Drawing.Bitmap) As Byte()
            Dim byteArray As Byte() = New Byte(-1) {}
            Using stream As New IO.MemoryStream()
                bmp.Save(stream, Drawing.Imaging.ImageFormat.Png)
                stream.Close()
                byteArray = stream.ToArray()
            End Using
            Return byteArray
        End Function

        Private Sub FormViewDettaglio_ItemInserting(sender As Object, e As FormViewInsertEventArgs) Handles FormViewDettaglio.ItemInserting
            Try
                If Not ValidaFiltri() Then
                    e.Cancel = True
                End If
            Catch ex As Exception
                'TRAPPO L'ERRORE.
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                Utility.ShowErrorLabel(LabelError, sErrorMessage)
            End Try
        End Sub
#End Region

        Private Function ValidaFiltri() As Boolean
            Dim bReturn As Boolean = True
            Try
                'OTTENGO LE TEXTBOX DELLA FORMVIEW DA VALIDARE
                Dim txtOrdinamento As TextBox = CType(FormViewDettaglio.FindControl("txtOrdinamento"), TextBox)
                ' Dim cmbAzienda As DropDownList = CType(FormViewDettaglio.FindControl("cmbAziendaErogante"), DropDownList)

                If String.IsNullOrEmpty(txtOrdinamento.Text) Then
                    Throw New ApplicationException("Il campo 'ordinamento' è obbligatorio.")
                End If

                If String.IsNullOrEmpty(cmbAziendaErogante.SelectedValue) Then
                    Throw New ApplicationException("Selezionare una Azienda Erogante.")
                End If
            Catch ex As ApplicationException
                bReturn = False

                'NON TRAPPO L'ERRORE MA MOSTRO IL MESSAGGIO.
                LabelError.Visible = True
                LabelError.Text = ex.Message
            Catch ex As Exception
                bReturn = False

                'TRAPPO L'ERRORE.
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                Utility.ShowErrorLabel(LabelError, sErrorMessage)
            End Try

            Return bReturn
        End Function

        Private Sub FormViewDettaglio_ItemUpdating(sender As Object, e As FormViewUpdateEventArgs) Handles FormViewDettaglio.ItemUpdating
            Try
                If Not ValidaFiltri() Then
                    e.Cancel = True
                End If
            Catch ex As Exception
                'TRAPPO L'ERRORE.
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                Utility.ShowErrorLabel(LabelError, sErrorMessage)
            End Try
        End Sub

        Private Sub FormViewDettaglio_DataBound(sender As Object, e As EventArgs) Handles FormViewDettaglio.DataBound
            Try
                'casto sender a FormView.
                Dim fv As FormView = CType(sender, FormView)
                'testo se fv non è vuoto.
                If fv IsNot Nothing Then
                    'ottengo i DataItem dalla FormView e testo se non è vuoto.
                    If fv.DataItem IsNot Nothing Then
                        'ottengo la TipiRefertoRow dal DataRowView.
                        Dim dv As DataRowView = CType(fv.DataItem, DataRowView)
                        Dim row As Data.BackEndDataSet.TipiRefertoRow = CType(dv.Row, Data.BackEndDataSet.TipiRefertoRow)
                        'testo se la row è vuota.
                        If row IsNot Nothing Then
                            'ottengo l'aziendaErogate.
                            Dim sAziendaErogante As String = CType(row.AziendaErogante, String)
                            Dim sSistemaErogante As String = CType(row.SistemaErogante, String) 'SE SONO QUI CI DEVE ESSERE PERCHÈ È UN CAMPO OBBLIGATORIO.
                            'Setto il selectedValue della combo cmbAziendaErogante.

                            '
                            'Modifica Leo 2020-07-22: Eseguo il databind prima di impostare il valore selezionato perchè altrimenti 
                            '                         la comboAziendaErogante è vuota e non funziona il .SelectedValue
                            '
                            cmbAziendaErogante.DataBind()

                            'Imposto il valore precedente come valore selezionato
                            cmbAziendaErogante.SelectedValue = sAziendaErogante.ToUpper
                            'Eseguo il bind della combo "ddlSistemaErogante" solo dopo aver selezionato l'azienda erogante.
                            'In questo modo vengono mostrati nella ddlSistemaErogante solo i sistemi collegati alla azienda selezionata.
                            ddlSistemaErogante.DataBind()
                            'se sSistemaErogante esiste nella lista degli item della ddlSistemaErogante allora seleziono l'item corretto.
                            If Not ddlSistemaErogante.Items.FindByValue(sSistemaErogante.ToUpper) Is Nothing Then
                                ddlSistemaErogante.SelectedValue = sSistemaErogante.ToUpper
                            End If
                        End If
                    End If
                End If
            Catch ex As Exception
                'TRAPPO L'ERRORE.
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                Utility.ShowErrorLabel(LabelError, sErrorMessage)
            End Try
        End Sub

        Private Sub cmbAziendaErogante_SelectedIndexChanged(sender As Object, e As EventArgs) Handles cmbAziendaErogante.SelectedIndexChanged
            Try
                'quando seleziono un item nella combo delle aziende svuoto la combo dei sistemi eroganti e la ricarico.
                ddlSistemaErogante.Items.Clear()
                ddlSistemaErogante.DataBind()
            Catch ex As Exception
                'TRAPPO L'ERRORE.
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                Utility.ShowErrorLabel(LabelError, sErrorMessage)
            End Try
        End Sub

        Private Sub odsSistemiEroganti_Selecting(sender As Object, e As ObjectDataSourceSelectingEventArgs) Handles odsSistemiEroganti.Selecting
            Try
                'setto il parametro AziendaErogante dell'objectDataSource
                e.InputParameters("AziendaErogante") = cmbAziendaErogante.SelectedValue
            Catch ex As Exception
                'TRAPPO L'ERRORE.
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                Utility.ShowErrorLabel(LabelError, sErrorMessage)
            End Try
        End Sub

        Private Sub ddlSistemaErogante_DataBinding(sender As Object, e As EventArgs) Handles ddlSistemaErogante.DataBinding
            Try
                Dim ddlSistemaErogante As DropDownList = CType(sender, DropDownList)
                '
                ' AGGIUNGO IL SISTEMA EROGANTE VUOTO SOLO IN MODALITÀ INSERIMENTO
                '
                If Request.QueryString(Constants.Id) Is Nothing Then
                    ddlSistemaErogante.Items.Insert(0, New ListItem("", ""))
                End If
                '
                ' AGGIUNGO IL SISTEMA EROGANTE <Altro>  solo se non è già presente nella combo.
                '
                If ddlSistemaErogante.Items.FindByValue("Altro") Is Nothing Then
                    ddlSistemaErogante.Items.Add(New ListItem("<Altro>", "Altro"))
                End If

            Catch ex As Exception
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                Utility.ShowErrorLabel(LabelError, sErrorMessage)
            End Try
        End Sub

        Private Sub ddlSistemaErogante_DataBound(sender As Object, e As EventArgs) Handles ddlSistemaErogante.DataBound
            Try
                '
                ' RIMUOVO IL SISTEMA ADT CHE NON DOVREBBE COMPARIRE
                '
                Dim ddlSistemaErogante As DropDownList = CType(sender, DropDownList)
                Dim item = ddlSistemaErogante.Items.FindByValue("ADT")
                If item IsNot Nothing Then
                    ddlSistemaErogante.Items.Remove(item)
                End If
            Catch ex As Exception
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                Utility.ShowErrorLabel(LabelError, sErrorMessage)
            End Try
        End Sub

        Private Sub cmbAziendaErogante_PreRender(sender As Object, e As EventArgs) Handles cmbAziendaErogante.PreRender
            Try
                Dim listItem As New ListItem With {.Text = "", .Value = ""}
                If cmbAziendaErogante.Items.IndexOf(listItem) = -1 Then
                    cmbAziendaErogante.Items.Insert(0, listItem)
                End If
            Catch ex As Exception
                Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
                Utility.ShowErrorLabel(LabelError, sErrorMessage)
            End Try
        End Sub
    End Class
End Namespace