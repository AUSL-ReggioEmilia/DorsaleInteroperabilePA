Imports System
Imports System.Web.UI

Imports DI.DataWarehouse.Admin.Data.BackEndDataSet
Imports DI.DataWarehouse.Admin.Data.RefertiStiliDataSet
Imports DI.DataWarehouse.Admin.Data

Namespace DI.DataWarehouse.Admin

    Partial Class StiliDettaglio
        Inherits Page

        Protected _stiliDettaglioDataTable As RefertiStiliDataSet

        Private _id As String
        Private _pageId As String

        Enum TabType
            Generale = 0
        End Enum

        Private Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles MyBase.Load
            Try
                _stiliDettaglioDataTable = New RefertiStiliDataSet()
                If Not IsPostBack Then
                    _pageId = Guid.NewGuid.ToString()
                    ViewState(Constants.PageId) = _pageId
                    _id = Request.QueryString(Constants.Id)
                    If Not String.IsNullOrEmpty(_id) Then
                        '
                        ' Sono in modifica
                        '
                        DataAdapterManager.RefertiStiliFill(_stiliDettaglioDataTable, New Guid(_id))
                    Else
                        '
                        ' Sono in inserimento
                        '
                        Dim row As RefertiStiliRow = _stiliDettaglioDataTable.RefertiStili.NewRefertiStiliRow()
                        '
                        ' Creo un nuovo guid per la PK e metto i default per i campi obbligatori 
                        '  
                        row.Id = Guid.NewGuid()
                        row.Abilitato = True
                        '
                        ' Bisogna impostare inizialmente tali valori poichè non sono nullabili 
                        '
                        row.ShowAllegatoRTF = False
                        row.ShowLinkDocumentoPdf = False

                        _stiliDettaglioDataTable.RefertiStili.BeginLoadData()
                        _stiliDettaglioDataTable.RefertiStili.AddRefertiStiliRow(row)
                        '
                        ' Aggiorno la var. PK
                        '
                        _id = row.Id.ToString
                    End If

                    Session(_pageId & "_" & Constants.DataSet) = _stiliDettaglioDataTable
                    If Request.UrlReferrer IsNot Nothing Then
                        ViewState(Constants.UrlReturn) = Request.UrlReferrer.AbsoluteUri.ToString()
                    End If
                Else
                    _pageId = CStr(ViewState(Constants.PageId))
                    _stiliDettaglioDataTable = DirectCast(Session(_pageId & "_" & Constants.DataSet), RefertiStiliDataSet)
                    _id = _stiliDettaglioDataTable.RefertiStili(0).Id.ToString
                End If
                '
                ' Aggiorno prop. degli user controls
                '
                StiliGenerale.Dataset = _stiliDettaglioDataTable
                If Not IsPostBack Then
                    RefreshTab(TabType.Generale)
                End If
                EliminaButton.Attributes("onclick") = "return confirm('Confermi la cancellazione dello stile?');"

            Catch ex As Exception
                Dim sMessage As String = Utility.TrapError(ex, True)
                Utility.ShowErrorLabel(LabelError, sMessage)
            End Try
        End Sub

        Private Sub RefreshTab(ByVal tabType As TabType)
            Try
                If Not String.IsNullOrEmpty(_id) AndAlso tabType = TabType.Generale Then
                    StiliGenerale.PageDataBind()
                End If
                CommitData()
                If tabType = TabType.Generale Then
                    StiliGenerale.Visible = True
                End If
            Catch ex As Exception
                Dim sMessage As String = Utility.TrapError(ex, True)
                Utility.ShowErrorLabel(LabelError, sMessage)
            End Try
        End Sub

        Private Sub EliminaButton_Click(ByVal sender As Object, ByVal e As EventArgs) Handles EliminaButton.Click
            Try
                Dim objRow As RefertiStiliRow = _stiliDettaglioDataTable.RefertiStili(0)
                objRow.Delete()
                DataAdapterManager.RefertiStiliUpdate(_stiliDettaglioDataTable)
                ReturnToList()
            Catch ex As Exception
                Dim sMessage As String = Utility.TrapError(ex, True)
                Utility.ShowErrorLabel(LabelError, sMessage)
            End Try
        End Sub

        Private Sub CommitData()
            Try
                If StiliGenerale.Visible Then
                    StiliGenerale.Commit()
                End If
            Catch ex As ApplicationException
                Utility.ShowErrorLabel(LabelError, ex.Message)
            Catch ex As Exception
                Dim sMessage As String = Utility.TrapError(ex, True)
                Utility.ShowErrorLabel(LabelError, sMessage)
            End Try
        End Sub

        Private Sub ReturnToList()
            Try
                Dim url As String = ViewState(Constants.UrlReturn) & ""
                If Not String.IsNullOrEmpty(url) Then
                    Session.Remove(_pageId & "_" & Constants.DataSet)
                    Response.Redirect(url, False)
                End If
            Catch ex As Exception
                Dim sMessage As String = Utility.TrapError(ex, True)
                Utility.ShowErrorLabel(LabelError, sMessage)
            End Try
        End Sub

        Private Function SaveDataset() As Boolean
            Try
                CommitData()

                ''
                ''Se il tipo selezionato è 1( Interno WS2) allora almeno xsltrighe deve essere valorizzato???.
                ''
                'If _stiliDettaglioDataTable.RefertiStili(0).Tipo = Constants.COMBO_TIPO_INTERNO_WS2_ITEM_VALUE Then
                '    If _stiliDettaglioDataTable.RefertiStili(0).IsXsltRigheNull OrElse String.IsNullOrEmpty(_stiliDettaglioDataTable.RefertiStili(0).XsltRighe) Then
                '        Throw New ApplicationException("Se il campo 'Tipo' è 'Interno' allora almeno il campo 'XsltRighe' deve essere valorizzato.")
                '    End If
                'End If

                If _stiliDettaglioDataTable.RefertiStili(0).Tipo = Constants.COMBO_TIPO_INTERNO_WS2_ITEM_VALUE OrElse
                       _stiliDettaglioDataTable.RefertiStili(0).Tipo = Constants.COMBO_TIPO_INTERNO_WS3_ITEM_VALUE Then
                    If Not String.IsNullOrEmpty(_stiliDettaglioDataTable.RefertiStili(0).XsltAllegatoXml) Then
                        If String.IsNullOrEmpty(_stiliDettaglioDataTable.RefertiStili(0).NomeFileAllegatoXml) Then
                            Throw New ApplicationException("Se il campo 'Tipo' è 'InternoWs2'/'InternoWs3' e il campo 'XsltAllegatoXml' è valorizzato il campo 'NomeFileAllegatoXml' è obbligatorio.")
                        End If
                    End If
                End If

                _stiliDettaglioDataTable.RefertiStili.EndLoadData()
                DataAdapterManager.RefertiStiliUpdate(_stiliDettaglioDataTable)
                Return True
            Catch ex As ApplicationException
                Utility.ShowErrorLabel(LabelError, ex.Message)
                Return False
            Catch ex As Exception
                Dim sMessage As String = Utility.TrapError(ex, True)
                Utility.ShowErrorLabel(LabelError, sMessage)
                Return False
            End Try
        End Function

        Private Sub cmdGenerale_Click(ByVal sender As Object, ByVal e As EventArgs)
            RefreshTab(TabType.Generale)
        End Sub

        Private Sub RitornaButton_Click(ByVal sender As Object, ByVal e As EventArgs) Handles RitornaButton.Click
            ReturnToList()
        End Sub

        Private Sub OkButton_Click(ByVal sender As Object, ByVal e As EventArgs) Handles OkButton.Click
            If SaveDataset() Then
                ReturnToList()
            End If
        End Sub

        Protected Sub ApplicaButton_Click(sender As Object, e As EventArgs) Handles ApplicaButton.Click
            SaveDataset()
        End Sub

        Private Sub StiliGenerale_AbortTransaction(sender As Object, e As System.EventArgs) Handles StiliGenerale.AbortTransaction
            Dim sMessage As String = "AbortTransaction"
            Utility.ShowErrorLabel(LabelError, sMessage)
        End Sub


        Private Sub StiliGenerale_Error(sender As Object, e As System.EventArgs) Handles StiliGenerale.Error
            Dim sMessage As String = "Errore Generico"
            Utility.ShowErrorLabel(LabelError, sMessage)
        End Sub
    End Class

End Namespace