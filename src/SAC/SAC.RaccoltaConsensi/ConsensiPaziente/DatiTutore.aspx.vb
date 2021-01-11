Imports Wcf.SacPazienti
Imports Wcf.SacConsensi

Public Class DatiTutore
	Inherits System.Web.UI.Page

	Dim mIdPaziente As String
	Dim mTipoConsenso As Integer

	Private Sub Page_Load(sender As Object, e As System.EventArgs) Handles Me.Load
		Try
			If Master.ErroreCaricamento Then
				Response.Redirect("Default.aspx", False)
			End If

			' Id e Tipo SONO PARAMETRI OBBLIGATORI
			If String.IsNullOrEmpty(Request.QueryString("Id")) Then
				Response.Redirect("Default.aspx", False)
			End If
			mIdPaziente = Request.QueryString("Id")

			If String.IsNullOrEmpty(Request.QueryString("Tipo")) Then
				Response.Redirect("Consensi.aspx?Id=" & mIdPaziente, False)
			End If
			mTipoConsenso = Request.QueryString("Tipo")

			txtCognome.Focus()
			Form.DefaultButton = butSalva.UniqueID

			If Not Page.IsPostBack Then

				' MOSTRO I DATI DEL TUTORE EVENTUALMENTE PRESENTE SU UN CONSENSO
				' NB: IL TIPO È SacPazienti.AttributoType() PERCHÈ PROVIENE DAL WS SACPAZIENTI
				Dim oAttributi As Wcf.SacPazienti.AttributoType() = MySession.PazienteAttributiDB(mIdPaziente)
				If oAttributi IsNot Nothing Then
					For Each oAtt In oAttributi
						Select Case oAtt.Nome
							Case AUTORIZZATORE_NOME
								txtNome.Text = oAtt.Valore

							Case AUTORIZZATORE_COGNOME
								txtCognome.Text = oAtt.Valore

							Case AUTORIZZATORE_DATANASCITA
								Dim dtNascita As Date
								If DateTime.TryParse(oAtt.Valore, dtNascita) Then
									txtDataNascita.Text = String.Format(FORMAT_DATA_ITALIANA, dtNascita)
								End If

							Case AUTORIZZATORE_LUOGONASCITA
								txtLuogoNascita.Text = oAtt.Valore

							Case AUTORIZZATORE_RELAZIONEMINORE
								ddlRelazione.SelectedValue = oAtt.Valore
						End Select
					Next
				End If
			End If

		Catch ex As Exception
			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Master.ShowErrorLabel(sErrorMessage)
		End Try
	End Sub


	Protected Sub butSalva_Click(sender As Object, e As EventArgs) Handles butSalva.Click
		Try
			' CONTROLLI PRELIMINARI
			Dim dtNascita As Date
			If Not DateTime.TryParse(txtDataNascita.Text.Trim, dtNascita) Then
				ReqDataNascita.IsValid = False
				Exit Sub
			End If

			' SALVO LE GENERALITÀ IN UN OGGETTO SacConsensi.AttributiType 
			Dim oAttributi As New Wcf.SacConsensi.AttributiType

			Dim oAttrib = New Wcf.SacConsensi.AttributoType() With {.Nome = AUTORIZZATORE_NOME, .Valore = txtNome.Text.Trim}
			oAttributi.Add(oAttrib)

			oAttrib = New Wcf.SacConsensi.AttributoType() With {.Nome = AUTORIZZATORE_COGNOME, .Valore = txtCognome.Text.Trim}
			oAttributi.Add(oAttrib)

			oAttrib = New Wcf.SacConsensi.AttributoType() With {.Nome = AUTORIZZATORE_DATANASCITA, .Valore = String.Format(FORMAT_DATA_DB, dtNascita)}
			oAttributi.Add(oAttrib)

			oAttrib = New Wcf.SacConsensi.AttributoType() With {.Nome = AUTORIZZATORE_LUOGONASCITA, .Valore = txtLuogoNascita.Text.Trim}
			oAttributi.Add(oAttrib)

			oAttrib = New Wcf.SacConsensi.AttributoType() With {.Nome = AUTORIZZATORE_RELAZIONEMINORE, .Valore = ddlRelazione.SelectedValue}
			oAttributi.Add(oAttrib)

			' LO SALVO IN SESSION
			MySession.PazienteAttributiInseriti(mIdPaziente) = oAttributi

			' RITORNO AL CHIAMANTE CHE PROCEDERÀ CON L'INSERIMENTO TRAMITE WS
			Response.Redirect("Consensi.aspx?Id=" & mIdPaziente & "&Tipo=" & mTipoConsenso, False)

		Catch ex As Exception
			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Master.ShowErrorLabel(sErrorMessage)
		End Try

	End Sub

	Private Sub butAnnulla_Click(sender As Object, e As System.EventArgs) Handles butAnnulla.Click
		Try
			Response.Redirect(MySession.ConsensiUrl, False)
		Catch ex As Exception
			Dim sErrorMessage As String = GestioneErrori.TrapError(ex)
			Master.ShowErrorLabel(sErrorMessage)
		End Try
	End Sub
End Class