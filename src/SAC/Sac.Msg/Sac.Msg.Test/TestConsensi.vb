Imports Asmn.Sac.Msg.DataAccess
Imports System.IO
Imports System.Xml

Public Class TestConsensi

    Private Sub TestConsensi_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        txtUtente.Text = My.User.Name
    End Sub

    Private Sub btnProcConsenso_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnProcConsenso.Click

        Dim consensi As New Consensi()
        Dim consenso As Consenso = Nothing

        If Not String.IsNullOrEmpty(txtXmlFile.Text) Then
            If Not File.Exists(txtXmlFile.Text) Then
                Throw New FileNotFoundException(String.Format("Il file {0} non esiste!", txtXmlFile.Text))
            End If
            '
            ' Read XML File
            '
            Dim doc As New XmlDocument()
            doc.Load(txtXmlFile.Text)
            '
            ' Deserialize
            '
            consenso = SerializerHelper(Of Consenso).Deserialize(doc.OuterXml)

        Else
            consenso = New Consenso()
            '
            ' Creo consenso
            '
            'consenso.Utente = txtUtente.Text
            'consenso.PazienteProvenienza = txtPazienteProvenienza.Text
            'consenso.PazienteIdProvenienza = txtPazienteIdProvenienza.Text
            'consenso.IdTipo = 1
            consenso.Id = "809_20110516000000_1"
            consenso.Tipo = "SOLE-LIVELLO1"
            consenso.DataStato = New DateTime(2011, 5, 16, 0, 0, 0)
            consenso.Stato = chkStato.Checked
            consenso.OperatoreId = "SSIS"
            'consenso.OperatoreCognome = ""
            'consenso.OperatoreNome = ""
            'consenso.OperatoreComputer = "FRANCESCOP-PC"
            consenso.PazienteIdProvenienza = "129940853C"
            consenso.PazienteProvenienza = "SVILUPPO"
            consenso.PazienteCodiceFiscale = "GZZLVC45A59H223S"
            consenso.PazienteCognome = "AGUZZOLI"
            consenso.PazienteNome = "LODOVICA"
            consenso.PazienteDataNascita = New DateTime(1945, 1, 19)
            consenso.PazienteTesseraSanitaria = "2653087"
            consenso.PazienteComuneNascitaCodice = "035033"
            consenso.PazienteNazionalitaCodice = "100"
        End If

        '
        ' Creo Messaggio
        '
        Dim oMessaggio As New MessaggioConsenso()
        oMessaggio.DataSequenza = DateTime.Now()
        oMessaggio.Utente = txtUtente.Text
        oMessaggio.Consenso = consenso
        '
        ' Tipo
        '
        Dim nTipo As Consensi.MessaggioTipo
        Select Case cmbTipo.Text
            Case "Inserimento" : nTipo = Consensi.MessaggioTipo.Insert
            Case Else : nTipo = Consensi.MessaggioTipo.Insert
        End Select

        Dim oRet As RispostaConsenso

        Try
            oRet = consensi.ProcessaMessaggio(nTipo, oMessaggio)
            If oRet.Id.Length > 0 Then
                '
                ' Completato
                '
                lstResult.Items.Add("Esecuzione ProcessaMessaggio completata; Id=" & oRet.Id)
                txtResult.Text = GenericSerialize(Of RispostaConsenso).Serialize(oRet)
                '
                ' Serialize > string > Deserialize > object
                '
                Dim sSerialize As String = RispostaConsenso.Serialize(oRet)
                Dim oSerialize As RispostaConsenso = RispostaConsenso.Deserialize(sSerialize)

            Else
                '
                ' Abortito
                '
                lstResult.Items.Add("Esecuzione ProcessaMessaggio annullata!")
            End If

        Catch ex As Exception
            lstResult.Items.Add("Errore durante l'esecuzione di ProcessaMessaggio; " & ex.Message)
        End Try

    End Sub

    Private Sub lstResult_Enter(ByVal sender As Object, ByVal e As System.EventArgs) Handles lstResult.Enter

        If lstResult.SelectedItem IsNot Nothing Then
            MsgBox(lstResult.SelectedItem.ToString)
        End If

    End Sub

    Private Sub lstResult_MouseDoubleClick(ByVal sender As Object, ByVal e As System.Windows.Forms.MouseEventArgs) Handles lstResult.MouseDoubleClick

        If lstResult.SelectedItem IsNot Nothing Then
            MsgBox(lstResult.SelectedItem.ToString)
        End If

    End Sub

    Private Sub btnUtentiAck_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnUtentiAck.Click

        Dim daConsensi As New Consensi
        Dim oRet As RispostaUtentiAck

        Try
            oRet = daConsensi.UtentiAck(txtUtente.Text)
            If oRet IsNot Nothing Then
                '
                ' Completato
                '
                lstResult.Items.Add("Esecuzione UtentiAck completata!")
                txtResult.Text = GenericSerialize(Of RispostaUtentiAck).Serialize(oRet)
            Else
                '
                ' Abortito
                '
                lstResult.Items.Add("Esecuzione UtentiAck annullata!")
            End If

        Catch ex As Exception
            lstResult.Items.Add("Errore durante l'esecuzione di UtentiAck; " & ex.Message)
        End Try

    End Sub

    Private Sub btnLoadXml_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnLoadXml.Click
        Me.OpenFileDialog1.Title = "Selezionare il file xml di richiesta"

        If OpenFileDialog1.ShowDialog() = DialogResult.OK Then
            txtXmlFile.Text = OpenFileDialog1.FileName
        Else
            Exit Sub
        End If
    End Sub

End Class