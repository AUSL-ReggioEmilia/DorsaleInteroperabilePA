Imports Asmn.Sac.Msg.DataAccess
Imports Sac.Msg.Wcf
Imports System.IO
Imports System.Xml

Public Class Main



    Private Sub lstResult_Enter(ByVal sender As Object, ByVal e As System.EventArgs) Handles lstResult.Enter
        Call ShowResultItem()
    End Sub

    Private Sub lstResult_MouseDoubleClick(ByVal sender As Object, ByVal e As System.Windows.Forms.MouseEventArgs) Handles lstResult.MouseDoubleClick
        Call ShowResultItem()
    End Sub

    Private Sub ShowResultItem()
        If lstResult.SelectedItem IsNot Nothing Then
            Dim sMsg As String = lstResult.SelectedItem.ToString
            sMsg = Replace(sMsg, vbCrLf, " ")
            MsgBox(sMsg)
        End If
    End Sub


    Private Sub Main_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        'Me.txtTab2_Utente.Text = My.User.Name
        lblVersioneDll.Text = GetDllVersion()

        'Seleziono il primo elemento della combo
        cmbTabListaPaz_Ordinamento.SelectedIndex = 0
    End Sub

    Private Function GetDllVersion() As String
        Try
            '
            ' Legge versione della DLL
            '
            Dim oTypeConnV2 As Type = GetType(DataAccess.Pazienti)
            Dim oAssConnV2 As Reflection.Assembly = oTypeConnV2.Assembly

            Dim oAssVers() As Object = oAssConnV2.GetCustomAttributes(GetType(Reflection.AssemblyFileVersionAttribute), True)
            Dim oAssVerInfo As Reflection.AssemblyFileVersionAttribute = CType(oAssVers(0), Reflection.AssemblyFileVersionAttribute)

            Return String.Format("Ver DLL:{0}, da GAC={1}", oAssVerInfo.Version, oAssConnV2.GlobalAssemblyCache)

        Catch ex As Exception
            MsgBox("Errore durante GetDllVersion():" & vbCrLf & ex.Message)
            Return "Errore versione Dll!"
        End Try

    End Function


#Region "Consensi XML"
    Private Sub btnTabConsensoXML_ProcMsgConsensoWcf_Click(sender As Object, e As EventArgs) Handles btnTabConsensoXML_ProcMsgConsensoWcf.Click
        Dim messaggio As SacWcfServiceReferenceConsensi.MessaggioConsensoParameter = Nothing
        Dim oConsensi As New SacWcfServiceReferenceConsensi.ConsensiClient

        'Dim consensi As New Consensi()
        'Dim messaggio As MessaggioConsenso = Nothing

        Try
            If Not String.IsNullOrEmpty(txtTabConsensoXML_XmlConsenso.Text) Then

                ' Read XML
                Dim doc As New XmlDocument()
                doc.LoadXml(txtTabConsensoXML_XmlConsenso.Text)

                ' Deserialize
                messaggio = SerializerHelper(Of SacWcfServiceReferenceConsensi.MessaggioConsensoParameter).Deserialize(doc.OuterXml)
            Else

                MessageBox.Show("Inserire l'Xml del consenso.", Me.Text, MessageBoxButtons.OK, MessageBoxIcon.Exclamation)
                Exit Sub
            End If

            Dim sDataSeq As String = txtTabConsensoXML_DataSequenza.Text
            If sDataSeq.Length = 0 Then
                messaggio.DataSequenza = Date.Now
            Else
                messaggio.DataSequenza = Date.Parse(sDataSeq)
            End If

            ' Tipo
            Dim nTipo As SacWcfServiceReferenceConsensi.MessaggioConsensoTipoEnum
            Select Case cmbTabConsensoXML_Tipo.Text
                Case "Inserimento" : nTipo = SacWcfServiceReferenceConsensi.MessaggioConsensoTipoEnum.Insert
                Case Else : nTipo = SacWcfServiceReferenceConsensi.MessaggioConsensoTipoEnum.Insert
            End Select

            Dim oRet As SacWcfServiceReferenceConsensi.MessaggioConsensoReturn = oConsensi.ProcessaMessaggio(nTipo, messaggio)
            If Not oRet Is Nothing Then
                'Nella risposta c'è solo eventuale nodo errore
                If Not oRet.Errore Is Nothing Then
                    If String.IsNullOrEmpty(oRet.Errore.Codice) Then
                        'Deve sempre essere valorizzato il codice di errore, se no è un errore nel WCF
                        Throw New Exception("Il codice di errore è nullo e la classe Errore non è nothing!!")
                    Else
                        'lstResult.Items.Add(String.Concat(oRet.Errore.Codice, ": ", oRet.Errore.Descrizione))
                        txtTabConsensoXML_Result.Text = GenericSerialize(Of SacWcfServiceReferenceConsensi.MessaggioConsensoReturn).Serialize(oRet)
                        MsgBox("Esecuzione ProcessaMessaggio completata. Verificare il nodo errore!", MsgBoxStyle.Exclamation)
                    End If
                Else
                    'Se Il nodo errore non è valorizzato allora tutto OK!
                    'lstResult.Items.Add("Esecuzione ProcessaMessaggio completata.")
                    txtTabConsensoXML_Result.Text = "Esecuzione ProcessaMessaggio completata (Il metodo WCF non restituisce il consenso creato/aggiornato)."
                    MsgBox("Esecuzione ProcessaMessaggio completata!", MsgBoxStyle.Information)
                End If
            Else
                txtTabConsensoXML_Result.Text = "Test.oConsensi.ProcessaMessaggio() ha restituito nothing!"
                'Throw New Exception("Test.oPaz.ProcessaMessaggio() ha restituito nothing!")
                MsgBox("Test.oConsensi.ProcessaMessaggio() ha restituito nothing!", MsgBoxStyle.Critical)
            End If

        Catch ex As Exception

            Dim sErrMsg As String = "Errore durante l'esecuzione di ProcessaMessaggio:" & vbCrLf & FormatException(ex)
            MsgBox(sErrMsg, MsgBoxStyle.Critical)

        End Try
    End Sub
#End Region


    Private Sub btnTab2_ProcMsgPaziente_WCF_Click(sender As Object, e As EventArgs) Handles btnTab2_ProcMsgPaziente_WCF.Click
        Dim messaggio As SacWcfServiceReference.MessaggioPazienteParameter = Nothing
        Dim oPaz As New SacWcfServiceReference.PazientiClient
        Try
            ''****************************************
            '' PER VEDERE COME DEVE ESSERE FATTO L'XML
            ''****************************************
            'Dim oTemp As New SacWcfServiceReference.MessaggioPazienteParameter
            'oTemp.DataSequenza = Date.Now

            'oTemp.Paziente = New SacWcfServiceReference.PazienteType
            'oTemp.Paziente.Cognome = "pipoo"


            'oTemp.Paziente.Attributi = New SacWcfServiceReference.AttributiType
            'Dim oAttr1 As SacWcfServiceReference.AttributoType = New SacWcfServiceReference.AttributoType
            'oAttr1.Nome = "AAAA_NOME"
            'oAttr1.Valore = "AAAAA"
            'oTemp.Paziente.Attributi.Add(oAttr1)

            'Dim oAttr2 As SacWcfServiceReference.AttributoType = New SacWcfServiceReference.AttributoType
            'oAttr2.Nome = "MantenimentoPediatra"
            'oAttr2.Valore = "true"
            'oTemp.Paziente.Attributi.Add(oAttr2)

            'Dim oAttr3 As SacWcfServiceReference.AttributoType = New SacWcfServiceReference.AttributoType
            'oAttr3.Nome = "Indigenza"
            'oAttr3.Valore = "true"
            'oTemp.Paziente.Attributi.Add(oAttr3)


            'Dim oAttr4 As SacWcfServiceReference.AttributoType = New SacWcfServiceReference.AttributoType
            'oAttr4.Nome = "Capofamiglia"
            'oAttr4.Valore = "true"
            'oTemp.Paziente.Attributi.Add(oAttr4)


            'Dim oEsen As SacWcfServiceReference.EsenzioneType = New SacWcfServiceReference.EsenzioneType
            'oEsen.AttributoEsenzioneDiagnosi = "aaa"
            'oEsen.CodiceDiagnosi = "XXX"
            'oEsen.CodiceEsenzione = "YYY"
            'oEsen.CodiceTestoEsenzione = "testo esenzione"
            'oEsen.DataFineValidita = Now
            'oEsen.DataInizioValidita = Now
            'oEsen.DecodificaEsenzioneDiagnosi = "decodifica"
            'oEsen.NumeroAutorizzazioneEsenzione = "NumeroAutorizzazioneEsenzione"
            'oEsen.NoteAggiuntive = "NoteAggiuntive"
            'oEsen.Patologica = False

            'oTemp.Esenzioni = New SacWcfServiceReference.EsenzioniType
            'oTemp.Esenzioni.Add(oEsen)
            'Dim s As String = SerializerHelper(Of SacWcfServiceReference.MessaggioPazienteParameter).Serialize(oTemp)
            ''****************************************



            If String.IsNullOrEmpty(cmbTab2_Tipo.Text) Then
                MessageBox.Show("Selezionare il tipo di messaggio!", Me.Text, MessageBoxButtons.OK, MessageBoxIcon.Exclamation)
                Exit Sub
            End If
            If Not String.IsNullOrEmpty(txtTab2_XmlPaziente.Text) Then

                ' Read XML
                Dim doc As New XmlDocument()
                doc.LoadXml(txtTab2_XmlPaziente.Text)
                ' Deserialize
                messaggio = SerializerHelper(Of SacWcfServiceReference.MessaggioPazienteParameter).Deserialize(doc.OuterXml)

                ''ALTRO MODO PER FARE DESERIALIZZAZIONE
                'Dim oEnc As System.Text.Encoding = System.Text.Encoding.UTF8
                'Dim baMessage As Byte() = oEnc.GetBytes(txtTab2_XmlPaziente.Text)
                'Using oStream As IO.MemoryStream = New IO.MemoryStream(baMessage)
                '    Dim oSerializer As System.Xml.Serialization.XmlSerializer = New System.Xml.Serialization.XmlSerializer(GetType(SacWcfServiceReference.MessaggioPazienteParameter))
                '    messaggio = TryCast(oSerializer.Deserialize(oStream), SacWcfServiceReference.MessaggioPazienteParameter)
                'End Using

            Else

                MessageBox.Show("Inserire l'Xml del paziente.", Me.Text, MessageBoxButtons.OK, MessageBoxIcon.Exclamation)
                Exit Sub
            End If
            '
            ' Cancello risultato XML precedente
            '
            txtTab2_Result.Text = String.Empty

            Dim sDataSeq As String = txtTab2_DataSequenza.Text
            If sDataSeq.Length = 0 Then
                messaggio.DataSequenza = Date.Now
            Else
                messaggio.DataSequenza = Date.Parse(sDataSeq)
            End If

            ' Tipo
            Dim nTipo As SacWcfServiceReference.MessaggioPazienteTipoEnum

            Select Case cmbTab2_Tipo.Text
                Case "Aggiornamento" : nTipo = SacWcfServiceReference.MessaggioPazienteTipoEnum.Modify
                Case "Cancellazione" : nTipo = SacWcfServiceReference.MessaggioPazienteTipoEnum.Delete
                Case "Fusione" : nTipo = SacWcfServiceReference.MessaggioPazienteTipoEnum.Merge
                Case Else : nTipo = SacWcfServiceReference.MessaggioPazienteTipoEnum.Modify
            End Select
            '
            ' Imposto le credenziali
            '
            Dim sUser As String = My.Settings.WcfUserName
            Dim sPassword As String = My.Settings.WcfPassword
            Call Utility.SetWCFCredentials(oPaz.ChannelFactory.Endpoint.Binding, oPaz.ClientCredentials, sUser, sPassword)
            '
            '
            '
            Dim oRet As SacWcfServiceReference.MessaggioPazienteReturn
            oRet = oPaz.ProcessaMessaggio(nTipo, messaggio)
            '
            ' Controllo se vi sono errori
            '
            If Not oRet Is Nothing Then

                If Not oRet.Errore Is Nothing Then
                    If String.IsNullOrEmpty(oRet.Errore.Codice) Then
                        'Deve sempre essere valorizzato il codice di errore, se no è un errore nel WCF
                        Throw New Exception("Il codice di errore è nullo e la classe Errore non è nothing!!")
                    Else
                        'lstResult.Items.Add(String.Concat(oRet.Errore.Codice, ": ", oRet.Errore.Descrizione))
                        txtTab2_Result.Text = GenericSerialize(Of SacWcfServiceReference.MessaggioPazienteReturn).Serialize(oRet)
                        MsgBox("Esecuzione ProcessaMessaggio completata. Verificare il nodo errore!", MsgBoxStyle.Exclamation)
                    End If
                Else

                    If (Not oRet.Paziente Is Nothing) AndAlso (Not String.IsNullOrEmpty(oRet.Paziente.IdSac)) Then
                        ' Completato
                        'lstResult.Items.Add("Esecuzione ProcessaMessaggio completata; IdSac=" & oRet.Paziente.IdSac)
                        txtTab2_Result.Text = GenericSerialize(Of SacWcfServiceReference.MessaggioPazienteReturn).Serialize(oRet)
                        MsgBox("Esecuzione ProcessaMessaggio completata; IdSac=" & oRet.Paziente.IdSac, MsgBoxStyle.Information)

                    Else

                        ' Abortito
                        'lstResult.Items.Add("Esecuzione ProcessaMessaggio annullata!")
                        MsgBox("Esecuzione ProcessaMessaggio annullata!", MsgBoxStyle.Exclamation)
                    End If

                End If
            Else
                txtTab2_Result.Text = "Test.oPaz.ProcessaMessaggio() ha restituito nothing!"
                'Throw New Exception("Test.oPaz.ProcessaMessaggio() ha restituito nothing!")
                MsgBox("Test.oPaz.ProcessaMessaggio() ha restituito nothing!", MsgBoxStyle.Critical)
            End If

        Catch ex As Exception
            txtTab2_Result.Text = String.Empty

            Dim sErrMsg As String = "Errore durante l'esecuzione di ProcessaMessaggio:" & vbCrLf & FormatException(ex)
            MsgBox(sErrMsg, MsgBoxStyle.Critical)

        End Try
    End Sub

    Private Function FormatException(oEx As Exception) As String
        Dim sRet As String = String.Empty
        Dim x As Exception = oEx
        While Not x.InnerException Is Nothing
            sRet = sRet & x.Message & vbCrLf
            x = x.InnerException
        End While
        Return sRet.TrimEnd(vbCrLf.ToCharArray)
    End Function


    Private Sub cmdFindByIdPazinte_WCF_Click(sender As Object, e As EventArgs) Handles cmdFindByIdPazinte_WCF.Click
        Dim oPaz As New SacWcfServiceReference.PazientiClient
        Dim oRet As SacWcfServiceReference.DettaglioPazienteReturn
        Try
            '
            ' Imposto le credenziali
            '
            Dim sUser As String = My.Settings.WcfUserName
            Dim sPassword As String = My.Settings.WcfPassword
            Call Utility.SetWCFCredentials(oPaz.ChannelFactory.Endpoint.Binding, oPaz.ClientCredentials, sUser, sPassword)
            '
            ' Chiamo il metodo della WCF
            '

            'Verifico che sia un guid: se non va in errore
            Dim oGuid As Guid = New Guid(txtIdPaziente.Text)

            oRet = oPaz.DettaglioPaziente(txtIdPaziente.Text)

            txtDettaglioXML.Text = GenericSerialize(Of SacWcfServiceReference.DettaglioPazienteReturn).Serialize(oRet)

        Catch ex As Exception
            MsgBox(ex.Message)

        End Try
    End Sub

    Private Sub btnTabListaPazCerca_Click(sender As Object, e As EventArgs) Handles btnTabListaPazCerca.Click
        Dim oPaz As New SacWcfServiceReference.PazientiClient
        Dim oRet As SacWcfServiceReference.ListaPazientiReturn
        Dim iMaxRecords As Integer = 0
        Dim oIdPaziente As Nullable(Of Guid) = Nothing
        Dim sCognome As String = Nothing
        Dim sNome As String = Nothing
        Dim oDataNascita As DateTime?
        Dim sCodiceFiscale As String = Nothing
        Dim sSesso As String = Nothing
        Try
            '
            ' Verifico i parametri
            '
            If String.IsNullOrEmpty(txtTabListaPaz_MaxRecord.Text) Then
                Call MsgBox("Il campo 'MaxRecord' non può essere vuoto!", MsgBoxStyle.Critical)
                Exit Sub
            Else
                iMaxRecords = CInt(txtTabListaPaz_MaxRecord.Text)
            End If

            If String.IsNullOrEmpty(txtTabListaPaz_IdPaziente.Text) AndAlso
                String.IsNullOrEmpty(txtTabListaPaz_Cognome.Text) Then
                Call MsgBox("O 'IdPaziente' o 'Cognome' devono essere valorizzati!", MsgBoxStyle.Critical)
                Exit Sub
            End If

            Dim sIdPaziente As String = Trim(txtTabListaPaz_IdPaziente.Text)

            'Verifico che sia un guid: se non lo è va in errore
            If Not String.IsNullOrEmpty(sIdPaziente) Then
                Dim oGuid As Guid = New Guid(sIdPaziente)
            End If

            '
            ' Converto da ComboOrdinamento a PazientiSortOrderEnum
            '
            Dim iOrderEnum As SacWcfServiceReference.PazientiSortOrderEnum = SacWcfServiceReference.PazientiSortOrderEnum.Cognome
            Dim sOrdinamento As String = cmbTabListaPaz_Ordinamento.SelectedItem.ToString
            sOrdinamento = sOrdinamento.ToUpper
            Select Case sOrdinamento
                Case "COGNOME"
                    iOrderEnum = SacWcfServiceReference.PazientiSortOrderEnum.Cognome
                Case "NOME"
                    iOrderEnum = SacWcfServiceReference.PazientiSortOrderEnum.Nome
                Case "CODICEFISCALE"
                    iOrderEnum = SacWcfServiceReference.PazientiSortOrderEnum.CodiceFiscale
                Case "SESSO"
                    iOrderEnum = SacWcfServiceReference.PazientiSortOrderEnum.Sesso
            End Select

            sCognome = Trim(txtTabListaPaz_Cognome.Text)
            sNome = Trim(txtTabListaPaz_Nome.Text)

            If Not String.IsNullOrEmpty(txtTabListaPaz_DataNascita.Text) Then
                oDataNascita = Convert.ToDateTime(txtTabListaPaz_DataNascita.Text)
            End If

            sCodiceFiscale = Trim(txtTabListaPaz_CodiceFiscale.Text)
            If String.IsNullOrEmpty(sCodiceFiscale) Then sCodiceFiscale = Nothing

            sSesso = cmbTabListaPaz_Sesso.SelectedText
            If String.IsNullOrEmpty(sSesso) Then sSesso = Nothing

            '
            ' Imposto le credenziali
            '
            Dim sUser As String = My.Settings.WcfUserName
            Dim sPassword As String = My.Settings.WcfPassword
            Call Utility.SetWCFCredentials(oPaz.ChannelFactory.Endpoint.Binding, oPaz.ClientCredentials, sUser, sPassword)
            '
            ' Chiamo il metodo della WCF
            '
            oRet = oPaz.ListaPazientiByGeneralita(iMaxRecords, iOrderEnum,
                        chkTabListaPaz_RestituisciSinonimi.Checked, chkTabListaPaz_RestituisciEsenzioni.Checked, chkTabListaPaz_RestituisciConsensi.Checked,
                        sIdPaziente, sCognome, sNome, oDataNascita, sCodiceFiscale, sSesso)

            txtTabListaPaz_XmlResult.Text = GenericSerialize(Of SacWcfServiceReference.ListaPazientiReturn).Serialize(oRet)

        Catch ex As Exception
            MsgBox(ex.Message)

        End Try
    End Sub



    Private Function GetFilePath(ByVal sInitialDirectory As String) As String
        Dim sFileName As String = String.Empty
        If Not String.IsNullOrEmpty(sInitialDirectory) Then
            OpenFileDialog1.InitialDirectory = sInitialDirectory
        End If
        If OpenFileDialog1.ShowDialog() = System.Windows.Forms.DialogResult.OK Then
            sFileName = OpenFileDialog1.FileName
        End If
        Return sFileName
    End Function


    Private Sub LoadTextBoxPazienteWithXML()
        Dim sStartApplicationPath As String = Application.StartupPath()
        Dim sInitialDirectory As String = IO.Path.Combine(sStartApplicationPath, "XML Text Pazienti")

        Dim sFileName As String = GetFilePath(sInitialDirectory)
        If Not String.IsNullOrEmpty(sFileName) Then
            '
            ' Leggo il file e lo visualizzo nella textbox
            '
            txtTab2_XmlPaziente.Text = IO.File.ReadAllText(sFileName)
        End If
    End Sub


    Private Sub LoadTextBoxWithXML(ByVal oTextBox As TextBox, sInitFolder As String)
        Dim sStartApplicationPath As String = Application.StartupPath()
        Dim sInitialDirectory As String = IO.Path.Combine(sStartApplicationPath, sInitFolder)

        Dim sFileName As String = GetFilePath(sInitialDirectory)
        If Not String.IsNullOrEmpty(sFileName) Then
            '
            ' Leggo il file e lo visualizzo nella textbox
            '
            oTextBox.Text = IO.File.ReadAllText(sFileName)
        End If
    End Sub


    Private Sub btn_Tab2_GetFile_Click(sender As Object, e As EventArgs) Handles btn_Tab2_GetFile.Click
        Call LoadTextBoxWithXML(txtTab2_XmlPaziente, "XML Text Pazienti")
    End Sub

    Private Sub btnTabConsensoXML_GetFile_Click(sender As Object, e As EventArgs) Handles btnTabConsensoXML_GetFile.Click
        Call LoadTextBoxWithXML(txtTabConsensoXML_XmlConsenso, "XML Text Consensi")
    End Sub
End Class
