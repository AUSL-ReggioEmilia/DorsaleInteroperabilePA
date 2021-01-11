Imports System
Imports System.Web.UI
Imports System.Data
Imports System.Web.UI.WebControls
Imports System.Web
Imports DI.PortalAdmin.Data
Imports System.Collections
Imports DI.DataWarehouse.Admin.Data

Namespace DI.DataWarehouse.Admin

    Public Class RefertiLista
        Inherits Page

		Private ReadOnly msPAGEKEY As String = Page.GetType().BaseType.FullName
        'Dim mbObjectDataSource_CancelSelect As Boolean = True
        Dim btnSearchClicked As Boolean = False


		Private Sub Page_PreRenderComplete(sender As Object, e As System.EventArgs) Handles Me.PreRenderComplete
			Try
				RefertiGridView.EmptyDataText = ""
				Me.Form.DefaultButton = Me.SearchButton.UniqueID
				If Not Page.IsPostBack Then
					FilterHelper.Restore(filterPanel, msPAGEKEY)
					If AziendaDropDownList.SelectedValue.Trim <> String.Empty Then
						'se nei filtri salvati trovoa l'azienda, carico la sua lista sistemi eroganti
						SistemaEroganteDropDownList.DataBind()
						'ripeto il caricamento del contenuto della dropdown
						FilterHelper.Restore(SistemaEroganteDropDownList, msPAGEKEY)
						SetFilterValue()
					End If
				End If
			Catch ex As Exception
				Dim sMessage As String = Utility.TrapError(ex, True)
				Utility.ShowErrorLabel(LabelError, sMessage)
			End Try
		End Sub

		Protected Function GetSacPazienteUrl(ByVal id As Object) As String

			If id IsNot DBNull.Value Then
				Return String.Format(My.Settings.PazienteSacUrl, id)
			Else
				Return String.Empty
			End If
		End Function

		Protected Function GetDettaglioRefertoTestataUrl(ByVal idReferto As Object) As String

			If idReferto IsNot DBNull.Value Then
				Return String.Format(My.Settings.RefertoDettaglioTestataUrl, idReferto)
			Else
				Return String.Empty
			End If
		End Function

		Private Sub RefertiListaObjectDataSource_ObjectCreated(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceEventArgs) Handles RefertiListaObjectDataSource.ObjectCreated
			Try
				'IMPOSTO IL TIMEOUT MASSIMO
				Dim ta = DirectCast(e.ObjectInstance, BackEndDataSetTableAdapters.BeRefertiListaTableAdapter)
				ta.CommandTimeout(My.Settings.CommandTimeoutMAX)
			Catch ex As Exception
				Dim sMessage As String = Utility.TrapError(ex, True)
				Utility.ShowErrorLabel(LabelError, sMessage)
			End Try
		End Sub

		Private Sub ObjectDataSource_Selecting(ByVal sender As Object, ByVal e As ObjectDataSourceSelectingEventArgs) Handles RefertiListaObjectDataSource.Selecting
            Try
                'e.Cancel = mbObjectDataSource_CancelSelect

                If ValidateFilters() Then
                    Dim text = "Lista Referti|Parametri: "
                    For Each item As DictionaryEntry In e.InputParameters
                        If item.Value IsNot Nothing Then
                            text &= item.Key & "=" & item.Value.ToString() & "; "
                        End If
                    Next
                    DataAdapterManager.PortalAdminDataAdapterManager.TracciaAccessi(User.Identity.Name, PortalsNames.DwhClinico, text)
                Else
                    e.Cancel = True
                End If
            Catch ex As Exception
                Dim sMessage As String = Utility.TrapError(ex, True)
				Utility.ShowErrorLabel(LabelError, sMessage)
			End Try
		End Sub

		Private Sub ObjectDataSource_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles RefertiListaObjectDataSource.Selected
			If Not ObjectDataSource_TrapError(sender, e) Then
				'se la ricerca non ha prodotto errore salvo i filtri
				FilterHelper.SaveInSession(filterPanel, msPAGEKEY)
			End If
		End Sub

		Private Sub RefertiListaObjectDataSource_Deleting(sender As Object, e As ObjectDataSourceMethodEventArgs) Handles RefertiListaObjectDataSource.Deleting
			'
			'2020-07-07 Kyrylo: Traccia Operazioni
			'
			Dim oTracciaOp As New TracciaOperazioniManager(Global_asax.ConnectionStringPortalAdmin)
			oTracciaOp.TracciaOperazione(PortalsNames.DwhClinico, Page.AppRelativeVirtualPath, "Cancellato referto", idPaziente:=Nothing, Nothing, e.InputParameters("Id").ToString(), "IdReferto")

		End Sub

		Private Sub RefertiListaObjectDataSource_Deleted(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles RefertiListaObjectDataSource.Deleted
			'
			' ESITO DELLA CANCELLAZIONE REFERTO
			'
			If Not ObjectDataSource_TrapError(sender, e) Then

				Dim iEsito = CInt(e.OutputParameters("Esito"))
				Dim sMsg = ""
				Select Case iEsito
					Case 0
						sMsg = "Referto Cancellato."
					Case 1
						sMsg = "Impossibile cancellare un Referto non eliminabile."
					Case 2
						sMsg = "Errore durante il tentativo di eliminazione Referto. Contattare un amministratore."
				End Select

				Page.ClientScript.RegisterStartupScript(Me.GetType, "msg", "alert('" & sMsg & "');", True)

			End If
		End Sub

        Protected Sub RefertiGridView_RowDataBound(ByVal sender As Object, ByVal e As GridViewRowEventArgs) Handles RefertiGridView.RowDataBound
			Try
				If (e.Row.RowType = DataControlRowType.Header) Then
					Dim cellIndex = -1
					For Each field As DataControlField In RefertiGridView.Columns
						e.Row.Cells(RefertiGridView.Columns.IndexOf(field)).CssClass = "GridHeader"
						If field.SortExpression = RefertiGridView.SortExpression AndAlso RefertiGridView.SortExpression.Length > 0 Then
							cellIndex = RefertiGridView.Columns.IndexOf(field)
						End If
					Next
					If cellIndex > -1 Then
						e.Row.Cells(cellIndex).CssClass = If(RefertiGridView.SortDirection = SortDirection.Ascending, "GridHeaderSortAsc", "GridHeaderSortDesc")
					End If
				End If
			Catch ex As Exception
				Dim sMessage As String = Utility.TrapError(ex, True)
				Utility.ShowErrorLabel(LabelError, sMessage)
			End Try
		End Sub
		Private Sub RefertiGridView_RowCommand(sender As Object, e As GridViewCommandEventArgs) Handles RefertiGridView.RowCommand
			Try
				If e.CommandName = "RinotificaReferto" Then
					Using da = New RefertiDataSetTableAdapters.QueriesTableAdapter
						Dim iRowNum As Integer = Integer.Parse(e.CommandArgument)
						Dim gIdReferto = RefertiGridView.DataKeys(iRowNum).Values("Id")
						da.BeRefertiNotificaById(gIdReferto)
						'
						'2020-07-07 Kyrylo: Traccia Operazioni
						'
						Dim oTracciaOp As New TracciaOperazioniManager(Global_asax.ConnectionStringPortalAdmin)
						oTracciaOp.TracciaOperazione(PortalsNames.DwhClinico, Page.AppRelativeVirtualPath, "Rinotificato referto", idPaziente:=Nothing, Nothing, gIdReferto.ToString(), "IdReferto")

					End Using
					Page.ClientScript.RegisterStartupScript(Me.GetType, "msg", "alert('Notifica accodata.');", True)


				End If

			Catch ex As Exception
				Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
				Utility.ShowErrorLabel(LabelError, sErrorMessage)
			End Try
		End Sub

        'Private Sub RefertiGridView_Sorting(sender As Object, e As System.Web.UI.WebControls.GridViewSortEventArgs) Handles RefertiGridView.Sorting
        '	Try
        '		mbObjectDataSource_CancelSelect = False
        '		e.Cancel = mbObjectDataSource_CancelSelect
        '	Catch ex As Exception
        '		Dim sMessage As String = Utility.TrapError(ex, True)
        '		Utility.ShowErrorLabel(LabelError, sMessage)
        '	End Try
        'End Sub


        Private Sub SearchButton_Click(sender As Object, e As System.EventArgs) Handles SearchButton.Click
            Try
                btnSearchClicked = True
                FilterHelper.SaveInSession(filterPanel, msPAGEKEY)

                'Invalido la cache
                If Not String.IsNullOrEmpty(RefertiListaObjectDataSource.CacheKeyDependency) Then
                    HttpContext.Current.Cache(RefertiListaObjectDataSource.CacheKeyDependency) = New Object
                End If



                RefertiGridView.EmptyDataText = "Nessun risultato!"


				'
				'2020-07-03 Kyrylo: Traccia Operazioni
				'
				Dim oTracciaOp As New TracciaOperazioniManager(Global_asax.ConnectionStringPortalAdmin)
				oTracciaOp.TracciaOperazione(PortalsNames.DwhClinico, Page.AppRelativeVirtualPath, "Ricerca referto", filterPanel, Nothing)



				'Bind della griglia
				If SetFilterValue() Then
                    RefertiGridView.DataBind()
                End If

            Catch ex As Exception
                Dim sMessage As String = Utility.TrapError(ex, True)
				Utility.ShowErrorLabel(LabelError, sMessage)
			End Try
		End Sub

		Private Function ValidateFilters() As Boolean

			If IdRefertoTextBox.Text.Length > 0 AndAlso
			 Not Utility.SQLTypes.IsValidGuid(IdRefertoTextBox.Text) Then
				Utility.ShowErrorLabel(LabelError, "Il campo ID Referto non contiene un GUID valido.")
				Return False
			End If

			If IdSACTextBox.Text.Length > 0 AndAlso
				Not Utility.SQLTypes.IsValidGuid(IdSACTextBox.Text) Then
				Utility.ShowErrorLabel(LabelError, "Il campo ID SAC non contiene un GUID valido.")
				Return False
			End If

			If DataModificaDALTextBox.Text.Length > 0 AndAlso
				Not Utility.SQLTypes.IsValidDateTime(DataModificaDALTextBox.Text) Then
				Utility.ShowErrorLabel(LabelError, "Il campo Data Modifica Dal non contiene una data valida.")
				Return False
			End If

			If DataModificaALTextBox.Text.Length > 0 AndAlso
			 Not Utility.SQLTypes.IsValidDateTime(DataModificaALTextBox.Text) Then
				Utility.ShowErrorLabel(LabelError, "Il campo Data Modifica Al non contiene una data valida.")
				Return False
			End If

			If DataRefertoTextBox.Text.Length > 0 AndAlso
				Not Utility.SQLTypes.IsValidDateTime(DataRefertoTextBox.Text) Then
				Utility.ShowErrorLabel(LabelError, "Il campo Data Referto non contiene una data valida.")
				Return False
			End If

			If DataNascitaTextBox.Text.Length > 0 AndAlso
			  Not Utility.SQLTypes.IsValidDateTime(DataNascitaTextBox.Text) Then
				Utility.ShowErrorLabel(LabelError, "Il campo Data di Nascita non contiene una data valida.")
				Return False
			End If


			'ricerca valida se questi filtri sono valorizzati
			If IdRefertoTextBox.Text.Length > 0 Or _
			 IdEsternoTextBox.Text.Length > 0 Or _
			 IdSACTextBox.Text.Length > 0 Or _
			 NosologicoTextBox.Text.Length > 0 Or _
			 NumeroPrenotazioneTextBox.Text.Length > 0 Or _
			 NumeroRefertoTextBox.Text.Length > 0 Then
				Return True
			End If

			'test delle altre combinazioni di filtro
			Dim bOK As Boolean = ((Not String.IsNullOrEmpty(AziendaDropDownList.SelectedItem.Value) And _
					Not String.IsNullOrEmpty(SistemaEroganteDropDownList.SelectedItem.Value)) _
				And (DataModificaDALTextBox.Text.Length > 0 Or DataRefertoTextBox.Text.Length > 0))

            If Not bOK Then
                If btnSearchClicked Then
                    Dim sMsgFilter As String = "Per effettuare la ricerca compilare una delle combinazioni di filtri come indicato."
                    Utility.ShowErrorLabel(LabelError, sMsgFilter)
                End If
            End If

                Return bOK

		End Function

		Private Function SetFilterValue() As Boolean
			Try
				RefertiListaObjectDataSource.SelectParameters("idReferto").DefaultValue = IdRefertoTextBox.Text
				RefertiListaObjectDataSource.SelectParameters("idEsterno").DefaultValue = IdEsternoTextBox.Text
				RefertiListaObjectDataSource.SelectParameters("idPaziente").DefaultValue = IdSACTextBox.Text
				RefertiListaObjectDataSource.SelectParameters("dataModificaDAL").DefaultValue = DataModificaDALTextBox.Text

				Dim sDataModificaAL As String = DataModificaALTextBox.Text.Trim
				Try
					'NEL CASO DI [DATA MODIFICA AL] CON ORARIO 00:00:00 IMPOSTO 23:59:59 PER INCLUDERE TUTTA LA GIORNATA
					If sDataModificaAL.Length > 0 Then
						Dim dt As DateTime
						If DateTime.TryParse(sDataModificaAL, dt) Then
							If dt.Hour = 0 AndAlso dt.Minute = 0 AndAlso dt.Second = 0 Then
								'{0:s} è un SortableDateTime : "2015-03-09T16:05:07"
								sDataModificaAL = String.Format("{0:s}", New DateTime(dt.Year, dt.Month, dt.Day, 23, 59, 59, 999))
							End If
						End If
					End If
				Catch
					'nulla da fare
				End Try

				RefertiListaObjectDataSource.SelectParameters("dataModificaAL").DefaultValue = sDataModificaAL
				RefertiListaObjectDataSource.SelectParameters("aziendaErogante").DefaultValue = AziendaDropDownList.SelectedValue
				RefertiListaObjectDataSource.SelectParameters("sistemaErogante").DefaultValue = SistemaEroganteDropDownList.SelectedValue
				RefertiListaObjectDataSource.SelectParameters("repartoErogante").DefaultValue = RepartoEroganteTextBox.Text
				RefertiListaObjectDataSource.SelectParameters("dataReferto").DefaultValue = DataRefertoTextBox.Text
				RefertiListaObjectDataSource.SelectParameters("numeroReferto").DefaultValue = NumeroRefertoTextBox.Text
				RefertiListaObjectDataSource.SelectParameters("numeroNosologico").DefaultValue = NosologicoTextBox.Text
				RefertiListaObjectDataSource.SelectParameters("numeroPrenotazione").DefaultValue = NumeroPrenotazioneTextBox.Text

				RefertiListaObjectDataSource.SelectParameters("Cognome").DefaultValue = CognomeTextBox.Text
				RefertiListaObjectDataSource.SelectParameters("Nome").DefaultValue = NomeTextBox.Text
				RefertiListaObjectDataSource.SelectParameters("CodiceFiscale").DefaultValue = CodFiscTextBox.Text
				RefertiListaObjectDataSource.SelectParameters("DataNascita").DefaultValue = DataNascitaTextBox.Text
				RefertiListaObjectDataSource.SelectParameters("MaxRow").DefaultValue = LimitaRisDropDownList.SelectedValue

				Return True
			Catch ex As Exception
				Dim sMessage As String = Utility.TrapError(ex, True)
				Utility.ShowErrorLabel(LabelError, sMessage)
				Return False
			End Try
		End Function

		Private Sub AziendaDropDownList_DataBound(sender As Object, e As System.EventArgs) Handles AziendaDropDownList.DataBound
			AziendaDropDownList.Items.Insert(0, "")
		End Sub

		Private Sub SistemaEroganteDropDownList_DataBound(sender As Object, e As System.EventArgs) Handles SistemaEroganteDropDownList.DataBound
			SistemaEroganteDropDownList.Items.Insert(0, "")
		End Sub

		Protected Sub ClearFiltersButton_Click(sender As Object, e As EventArgs) Handles ClearFiltersButton.Click
			Try
				'mbObjectDataSource_CancelSelect = True
				FilterHelper.Clear(filterPanel, msPAGEKEY)
				'forzo la pulizia del contenuto della grid
				RefertiGridView.Columns.Clear()

			Catch ex As Exception
				Dim sMessage As String = Utility.TrapError(ex, True)
				Utility.ShowErrorLabel(LabelError, sMessage)
			End Try
		End Sub

		Protected Sub GridView1_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs) Handles RefertiGridView.RowDataBound
			If e.Row.RowType = DataControlRowType.DataRow Then
				Dim rw As DataRowView = e.Row.DataItem
				Dim oRow As DI.DataWarehouse.Admin.Data.BackEndDataSet.BeRefertiListaRow = rw.Row
				If Not oRow.IsCodiceOscuramentoNull Then
					e.Row.CssClass = "StileRefertoOscurato"
				End If
			End If
		End Sub


#Region "Funzioni"

		''' <summary>
		''' Gestisce gli errori del ObjectDataSource in maniera pulita
		''' </summary>
		''' <returns>True se si è verificato un errore</returns>
		Private Function ObjectDataSource_TrapError(ods As ObjectDataSourceView, e As System.Web.UI.WebControls.ObjectDataSourceStatusEventArgs) As Boolean
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

#End Region

	End Class
End Namespace