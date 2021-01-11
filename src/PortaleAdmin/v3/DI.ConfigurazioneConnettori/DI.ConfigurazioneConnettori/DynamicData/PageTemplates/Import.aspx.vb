Imports System.Web.DynamicData
Imports System.IO
Imports System.Data.Linq
Imports System.ComponentModel
Imports System.Data

Class Import
	Inherits Page

	Protected metaTable As MetaTable
	Protected dataTable As ITable

	Public Property dtFoglioExcel As DataTable
		Get
			Return DirectCast(ViewState("dtFoglioExcel"), DataTable)
		End Get
		Set(ByVal value As DataTable)
			ViewState("dtFoglioExcel") = value
		End Set
	End Property


	Private Sub Page_Init(sender As Object, e As EventArgs) Handles Me.Init
		Try
			metaTable = DynamicDataRouteHandler.GetRequestMetaTable(Context)
			'dcRead e tabRead sono usate per leggere da Database
			Dim dcRead As DataContext
			dcRead = CType(metaTable.CreateContext, DataContext)
			dcRead.ObjectTrackingEnabled = False
			dataTable = dcRead.GetTable(metaTable.EntityType)

			'
			'CONTROLLO PRESENZA ATTRIBUTO ExcelImport
			'
			Dim attrExcelImport = Attribute.GetCustomAttribute(metaTable.RootEntityType, GetType(ExcelImport))
			If attrExcelImport Is Nothing Then
				Response.Redirect(metaTable.ListActionPath, False)
			End If

		Catch ex As Exception
			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Master.ShowAlert(sErrorMessage)
		End Try
	End Sub

	Private Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
		Try
			If Not Page.IsPostBack Then
				'
				' PRIMO LOAD DELLA PAGINA: MOSTRO IL MODAL FILE UPLOAD
				'
				ScriptManager.RegisterStartupScript(Page, Page.GetType(), "Mod", "$('#ModalFileUpload').modal('show');", True)
			Else
				'
				' POSTBACK DOPO FILE UPLOAD: TRASFORMO IL FILE EXCEL E LO SALVO NEL VIEWSTATE
				'
				If InputFile.PostedFile.ContentLength > 0 Then
#If DEBUG Then
					Threading.Thread.Sleep(5000)
#End If
					Dim stream = InputFile.PostedFile.InputStream
					dtFoglioExcel = Excel.ExcelToDataTable(stream, metaTable.Name)
					'CONTROLLI DI VALIDITÀ

					' --- NON HA PIÙ SENSO
					'If dtFoglioExcel.Columns.Count <> metaTable.Columns.Count Then
					'	Throw New ApplicationException(String.Format("Il numero di colonne presenti ({0}) è diverso da quanto atteso ({1}).", dtFoglioExcel.Columns.Count, metaTable.Columns.Count))
					'End If

					If dtFoglioExcel.Rows.Count = 0 Then
						Throw New ApplicationException("Impossibile importare un file vuoto.")
					End If
					'VERIFICO RIGA PER RIGA SE È GIÀ PRESENTE SU DB
					SetRowstate(dtFoglioExcel)
				End If
			End If

			If TypeOf dtFoglioExcel Is DataTable Then
				GridView1.DataSource = dtFoglioExcel
				GridView1.DataBind()
			End If

		Catch ex As Exception
			'
			' GESTIONE ERRORI PER IL CARICAMENTO DEL FILE
			'
			Dim sMsg As String

			If ex.Message = "Row number or column number cannot be zero" Then
				sMsg = "Impossibile importare un file vuoto."
			ElseIf TypeOf ex Is System.IO.EndOfStreamException Then
				sMsg = "Errore nel contenuto del file."
			ElseIf TypeOf ex Is Aspose.Cells.CellsException Then
				Select Case CType(ex, Aspose.Cells.CellsException).Code
					Case Aspose.Cells.ExceptionType.FileFormat
						sMsg = "Errore nel contenuto del file."
					Case Aspose.Cells.ExceptionType.InvalidData
						sMsg = "Errore nel contenuto del file: " & ex.Message
					Case Else
						sMsg = GestioneErrori.TrapError(ex)
				End Select
			Else
				sMsg = GestioneErrori.TrapError(ex)
			End If

			Master.ShowAlert(sMsg)
			dtFoglioExcel = Nothing

		Finally

			panFooter.Visible = TypeOf dtFoglioExcel Is DataTable

		End Try
	End Sub

	Private Sub butConferma_Click(sender As Object, e As EventArgs) Handles butConferma.Click
		Try
			Dim dcWrite = CType(metaTable.CreateContext, System.Data.Linq.DataContext)
			Dim tabWrite = dcWrite.GetTable(metaTable.EntityType)

			For Each dr As DataRow In dtFoglioExcel.Rows
				'CREO UN NUOVO OGGETTO NEL QUALE COPIO I DATI DALLA DATAROW
				Dim oEntity = Activator.CreateInstance(metaTable.RootEntityType)
				Excel.DataRowToEntity(dr, oEntity)
				Dim oOldRow = dataTable.FindFirst(oEntity)
				If oOldRow IsNot Nothing Then
					'UPDATE
					tabWrite.Attach(oEntity, oOldRow)
				Else
					'INSERT
					tabWrite.InsertOnSubmit(oEntity)
				End If
			Next
			dcWrite.SubmitChanges(Data.Linq.ConflictMode.ContinueOnConflict)

			Response.Redirect(metaTable.ListActionPath)

		Catch ex As Exception
			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Master.ShowAlert(sErrorMessage)
		End Try
	End Sub


	Private Sub GridView1_RowDataBound(sender As Object, e As GridViewRowEventArgs) Handles GridView1.RowDataBound
		Try
			If e.Row.RowType = DataControlRowType.DataRow Then
				If CType(e.Row.DataItem, DataRowView).Row.RowState = DataRowState.Added Then
					'INSERT
					e.Row.CssClass += "list-group-item-success"
				ElseIf CType(e.Row.DataItem, DataRowView).Row.RowState = DataRowState.Modified Then
					'UPDATE
					e.Row.CssClass += "list-group-item-warning"
				End If
			End If
		Catch ex As Exception
			'NON BLOCCO L'ESECUZIONE PER PROBLEMI SULLA SINGOLA RIGA
		End Try
	End Sub

	''' <summary>
	''' SALVA NELLO STATO DELLA DATAROW LA PRESENZA O MENO DELLA STESSA RIGA SU DB,
	''' VERRÀ POI USATO PER LA COLORAZIONE DELLA RIGA IN GRID
	''' </summary>
	Private Sub SetRowstate(dt As DataTable)

		For Each dr As DataRow In dt.Rows
			'CREO UN NUOVO OGGETTO NEL QUALE COPIO I DATI DALLA DATAROW
			Dim oEntity = Activator.CreateInstance(metaTable.RootEntityType)
			Excel.DataRowToEntity(dr, oEntity)
			'CERCO SE LA STESSA RIGA ESISTE SU DB
			If dataTable.Contains(oEntity) Then
				'UPDATE
				dr.AcceptChanges()
				dr.SetModified()
			Else
				'INSERT
				dr.AcceptChanges()
				dr.SetAdded()
			End If
		Next
	End Sub
End Class

