Imports System
Imports System.Web.UI.WebControls
Imports DI.PortalAdmin.Data
Imports System.Collections
Imports DI.DataWarehouse.Admin.Data

Namespace DI.DataWarehouse.Admin

	Public Class RefertiRiassociazioneLista
		Inherits System.Web.UI.Page

		Private ReadOnly msPAGEKEY As String = Page.GetType().BaseType.FullName
		Dim mbObjectDataSource_CancelSelect As Boolean = True

		Private Sub Page_PreRenderComplete(sender As Object, e As System.EventArgs) Handles Me.PreRenderComplete
			Try
				RefertiGridView.EmptyDataText = ""
				Me.Form.DefaultButton = Me.SearchButton.UniqueID
				If Not Page.IsPostBack Then
					FilterHelper.Restore(filterPanel, msPAGEKEY)
					If AziendaDropDownList.SelectedValue.Trim <> String.Empty Then
						'se nei filtri salvati trovo l'azienda, carico la sua lista di sistemi eroganti
						SistemaEroganteDropDownList.DataBind()
						'ripeto il caricamento del contenuto della dropdown
						FilterHelper.Restore(SistemaEroganteDropDownList, msPAGEKEY)
					End If

				End If

				IdSACTextBox.Enabled = Not chkRefertiOrfani.Checked

			Catch ex As Exception
				Dim sMessage As String = Utility.TrapError(ex, True)
				Utility.ShowErrorLabel(LabelError, sMessage)
			End Try
		End Sub

		Protected Function GetHTML_Paziente(Nome, Cognome, ComuneNascita, ProvinciaNascita, DataNascita, CodiceFiscale, Provenienza, IdProvenienza) As String
			Try
				Dim str As String = String.Concat("<b>", Utility.IsNull(Nome, ""), " ", Utility.IsNull(Cognome, ""), "</b>")

				If ComuneNascita IsNot DBNull.Value OrElse DataNascita IsNot DBNull.Value Then
					str = String.Concat(str, "<br/>Nato&nbsp;")
				End If
				If (ComuneNascita IsNot DBNull.Value) Then
					str = String.Concat(str, "a:&nbsp;", ComuneNascita)
				End If
				If (ProvinciaNascita IsNot DBNull.Value) Then
					str = String.Concat(str, "&nbsp;(", ProvinciaNascita, ")")
				End If
				If (ComuneNascita IsNot DBNull.Value OrElse ProvinciaNascita IsNot DBNull.Value) Then
					str = String.Concat(str, "<br/>")
				End If
				If (DataNascita IsNot DBNull.Value AndAlso TypeOf DataNascita Is Date) Then
					str = String.Concat(str, "il:&nbsp;", DirectCast(DataNascita, Date).ToShortDateString())
				End If
				If (CodiceFiscale IsNot DBNull.Value) Then
					str = String.Concat(str, "<br/>C.F.:&nbsp;", CodiceFiscale)
				End If
				If (Provenienza IsNot DBNull.Value) Then
					str = String.Concat(str, "<br/>Provenienza:&nbsp;", Provenienza)
					If (IdProvenienza IsNot DBNull.Value) Then
						str = String.Concat(str, "(", IdProvenienza, ")")
					End If
				End If

				Return str
			Catch ex As Exception
				Dim sMessage As String = Utility.TrapError(ex, True)
				Utility.ShowErrorLabel(LabelError, sMessage)
				Return String.Concat("<b>", Utility.IsNull(Nome, "-"), " ", Utility.IsNull(Cognome, "-"), "</b>")
			End Try
		End Function


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

		Private Sub SearchButton_Click(sender As Object, e As System.EventArgs) Handles SearchButton.Click
			Try
				If ValidateFilters() Then
					mbObjectDataSource_CancelSelect = False
					'Cache.Remove(RefertiListaObjectDataSource.CacheKeyDependency)
					Cache(RefertiListaObjectDataSource.CacheKeyDependency) = DateTime.Now
					If RefertiGridView.SortExpression = "" Then
						RefertiGridView.Sort("DataModifica", SortDirection.Ascending)
					End If
					RefertiGridView.DataBind()

					'
					'2020-07-03 Kyrylo: Traccia Operazioni
					'
					Dim oTracciaOp As New TracciaOperazioniManager(Global_asax.ConnectionStringPortalAdmin)
					oTracciaOp.TracciaOperazione(PortalsNames.DwhClinico, Page.AppRelativeVirtualPath, "Ricerca referto", filterPanel, Nothing)

				End If

			Catch ex As Exception
				Dim sMessage As String = Utility.TrapError(ex, True)
				Utility.ShowErrorLabel(LabelError, sMessage)
			End Try
		End Sub

		Private Sub RefertiListaObjectDataSource_ObjectCreated(sender As Object, e As System.Web.UI.WebControls.ObjectDataSourceEventArgs) Handles RefertiListaObjectDataSource.ObjectCreated
			Try
				'IMPOSTO IL TIMEOUT MASSIMO
				Dim ta = DirectCast(e.ObjectInstance, RefertiDataSetTableAdapters.RiassociazioneRefertiListaTableAdapter)
				ta.CommandTimeout(My.Settings.CommandTimeoutMAX)
			Catch ex As Exception
				Dim sMessage As String = Utility.TrapError(ex, True)
				Utility.ShowErrorLabel(LabelError, sMessage)
			End Try
		End Sub

		Private Sub RefertiListaObjectDataSource_Selecting(ByVal sender As Object, ByVal e As ObjectDataSourceSelectingEventArgs) Handles RefertiListaObjectDataSource.Selecting
			Try
				If mbObjectDataSource_CancelSelect OrElse Not ValidateFilters() Then
					e.Cancel = True
				Else
					RefertiGridView.EmptyDataText = "Nessun risultato!"
					'FIX PER LE CONVERSIONI DI TIPO DI ALCUNI PARAMETRI
					e.InputParameters(Constants.IdReferto) = Utility.StringEmptyDBNullToNothing(IdRefertoTextBox.Text)
					e.InputParameters(Constants.IdPaziente) = Utility.StringEmptyDBNullToNothing(IdSACTextBox.Text)
					FixCultureIndependentDate(e.InputParameters, "dataModificaDAL")
					FixCultureIndependentDate(e.InputParameters, "dataModificaAL")
					FixCultureIndependentDate(e.InputParameters, "dataReferto")

					'log dell'operazione di ricerca 
					Dim text = "Lista Referti Riassociazione|Parametri: "
					For Each item As DictionaryEntry In e.InputParameters
						If item.Value IsNot Nothing Then
							text &= item.Key & "=" & item.Value.ToString() & "; "
						End If
					Next
					DataAdapterManager.PortalAdminDataAdapterManager.TracciaAccessi(User.Identity.Name, PortalsNames.DwhClinico, text)

				End If

			Catch ex As Exception
				Dim sMessage As String = Utility.TrapError(ex, True)
				Utility.ShowErrorLabel(LabelError, sMessage)
			End Try
		End Sub

		Private Sub FixCultureIndependentDate(InputParameters As System.Collections.Specialized.IOrderedDictionary, Key As Object)
			Try
				If InputParameters(Key) IsNot Nothing Then
					Dim sDate As String = InputParameters(Key).ToString()
					InputParameters(Key) = DateTime.Parse(sDate)
				End If
			Catch
				'niente...
			End Try
		End Sub

		Private Sub ObjectDataSource_Selected(sender As Object, e As ObjectDataSourceStatusEventArgs) Handles RefertiListaObjectDataSource.Selected
			If Not ObjectDataSource_TrapError(sender, e) Then
				'se la ricerca non ha prodotto errore salvo i filtri
				FilterHelper.SaveInSession(filterPanel, msPAGEKEY)
			End If
		End Sub

		Private Sub RefertiGridView_Load(sender As Object, e As System.EventArgs) Handles RefertiGridView.Load
			'
			' NASCONDO LA COLONNA DATI ANADRAFICI SAC SE SI VOGLIONO VEDERE SOLO I REFERTI ORFANI
			Try
				For Each col As DataControlField In RefertiGridView.Columns
					If col.HeaderText = "Dati anagrafici SAC" Then
						col.Visible = Not chkRefertiOrfani.Checked
						Exit For
					End If
				Next
			Catch ex As Exception
				Dim sMessage As String = Utility.TrapError(ex, True)
				Utility.ShowErrorLabel(LabelError, sMessage)
			End Try
		End Sub

		Private Sub RefertiGridView_Sorting(sender As Object, e As System.Web.UI.WebControls.GridViewSortEventArgs) Handles RefertiGridView.Sorting
			mbObjectDataSource_CancelSelect = False
		End Sub

		Private Sub RefertiGridView_PageIndexChanging(sender As Object, e As System.Web.UI.WebControls.GridViewPageEventArgs) Handles RefertiGridView.PageIndexChanging
			mbObjectDataSource_CancelSelect = False
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

			'ricerca valida se questi filtri sono valorizzati
			If IdRefertoTextBox.Text.Length > 0 Or _
			 IdEsternoTextBox.Text.Length > 0 Or _
			 (IdSACTextBox.Enabled And IdSACTextBox.Text.Length > 0) Or _
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
				Dim sMsgFilter As String = "Per effettuare la ricerca compilare una delle combinazioni di filtri come indicato."
				Utility.ShowErrorLabel(LabelError, sMsgFilter)
			End If

			Return bOK

		End Function

		Private Sub AziendaDropDownList_DataBound(sender As Object, e As System.EventArgs) Handles AziendaDropDownList.DataBound
			AziendaDropDownList.Items.Insert(0, "")
		End Sub

		Private Sub SistemaEroganteDropDownList_DataBound(sender As Object, e As System.EventArgs) Handles SistemaEroganteDropDownList.DataBound
			SistemaEroganteDropDownList.Items.Insert(0, "")
		End Sub

		Private Sub chkRefertiOrfani_CheckedChanged(sender As Object, e As System.EventArgs) Handles chkRefertiOrfani.CheckedChanged
			IdSACTextBox.Enabled = Not chkRefertiOrfani.Checked
		End Sub

		Protected Sub ClearFiltersButton_Click(sender As Object, e As EventArgs) Handles ClearFiltersButton.Click
			Try
				'FilterHelper.Clear(filterPanel, msPAGEKEY)
				Me.Clear(filterPanel, msPAGEKEY)
				chkRefertiOrfani.Checked = True
			Catch ex As Exception
				Dim sMessage As String = Utility.TrapError(ex, True)
				Utility.ShowErrorLabel(LabelError, sMessage)
			End Try
		End Sub


		Private Sub Clear(parent As System.Web.UI.Control, UniqueKey As String)
			For Each child As System.Web.UI.Control In parent.Controls

				Clear(child, UniqueKey)
				If child.ID Is Nothing Then Continue For
				System.Web.HttpContext.Current.Session.Remove(UniqueKey & child.ID)

				'If TypeOf child Is TextBox Then
				'	TryCast(child, TextBox).Text = String.Empty

				'ElseIf TypeOf child Is CheckBox Then
				'	TryCast(child, CheckBox).Checked = False

				'ElseIf TypeOf child Is DropDownList Then
				'	Try
				'		Dim ddlChild = TryCast(child, DropDownList)
				'		If ddlChild.Items.Count > 0 Then
				'			ddlChild.ClearSelection()
				'			'se presente cerco un elemento con value o text vuoto
				'			Dim itm As ListItem = ddlChild.Items.FindByValue("")
				'			If itm Is Nothing Then itm = ddlChild.Items.FindByText("")
				'			'altrimenti seleziono il primo in lista
				'			If itm Is Nothing Then itm = ddlChild.Items(0)
				'			itm.Selected = True
				'		End If
				'	Catch
				'	End Try

				'ElseIf TypeOf child Is RadioButtonList Then
				'	Try
				'		TryCast(child, RadioButtonList).ClearSelection()
				'	Catch
				'	End Try

				'End If
			Next

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