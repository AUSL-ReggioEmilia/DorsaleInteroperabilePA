<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()>
Partial Class Main
    Inherits System.Windows.Forms.Form

    'Form overrides dispose to clean up the component list.
    <System.Diagnostics.DebuggerNonUserCode()>
    Protected Overrides Sub Dispose(ByVal disposing As Boolean)
        Try
            If disposing AndAlso components IsNot Nothing Then
                components.Dispose()
            End If
        Finally
            MyBase.Dispose(disposing)
        End Try
    End Sub

    'Required by the Windows Form Designer
    Private components As System.ComponentModel.IContainer

    'NOTE: The following procedure is required by the Windows Form Designer
    'It can be modified using the Windows Form Designer.  
    'Do not modify it using the code editor.
    <System.Diagnostics.DebuggerStepThrough()>
    Private Sub InitializeComponent()
        Me.lstResult = New System.Windows.Forms.ListBox()
        Me.OpenFileDialog1 = New System.Windows.Forms.OpenFileDialog()
        Me.TabMain = New System.Windows.Forms.TabControl()
        Me.Tab2 = New System.Windows.Forms.TabPage()
        Me.btnTab2_ProcMsgPaziente_WCF = New System.Windows.Forms.Button()
        Me.Label12 = New System.Windows.Forms.Label()
        Me.txtTab2_DataSequenza = New System.Windows.Forms.TextBox()
        Me.Label11 = New System.Windows.Forms.Label()
        Me.txtTab2_Result = New System.Windows.Forms.TextBox()
        Me.cmbTab2_Tipo = New System.Windows.Forms.ComboBox()
        Me.Label8 = New System.Windows.Forms.Label()
        Me.Label7 = New System.Windows.Forms.Label()
        Me.txtTab2_XmlPaziente = New System.Windows.Forms.TextBox()
        Me.TabConsensoXML = New System.Windows.Forms.TabPage()
        Me.btnTabConsensoXML_ProcMsgConsensoWcf = New System.Windows.Forms.Button()
        Me.txtTabConsensoXML_Result = New System.Windows.Forms.TextBox()
        Me.Label14 = New System.Windows.Forms.Label()
        Me.txtTabConsensoXML_DataSequenza = New System.Windows.Forms.TextBox()
        Me.Label10 = New System.Windows.Forms.Label()
        Me.cmbTabConsensoXML_Tipo = New System.Windows.Forms.ComboBox()
        Me.Label13 = New System.Windows.Forms.Label()
        Me.txtTabConsensoXML_XmlConsenso = New System.Windows.Forms.TextBox()
        Me.Label9 = New System.Windows.Forms.Label()
        Me.TabPageDettaglio = New System.Windows.Forms.TabPage()
        Me.cmdFindByIdPazinte_WCF = New System.Windows.Forms.Button()
        Me.lbldPaziente = New System.Windows.Forms.Label()
        Me.txtIdPaziente = New System.Windows.Forms.TextBox()
        Me.Label15 = New System.Windows.Forms.Label()
        Me.txtDettaglioXML = New System.Windows.Forms.TextBox()
        Me.TabPageLista = New System.Windows.Forms.TabPage()
        Me.txtTabListaPaz_XmlResult = New System.Windows.Forms.TextBox()
        Me.Label16 = New System.Windows.Forms.Label()
        Me.cmbTabListaPaz_Sesso = New System.Windows.Forms.ComboBox()
        Me.cmbTabListaPaz_Ordinamento = New System.Windows.Forms.ComboBox()
        Me.lblTabListaPaz_Sesso = New System.Windows.Forms.Label()
        Me.txtTabListaPaz_CodiceFiscale = New System.Windows.Forms.TextBox()
        Me.lblTabListaPaz_CodiceFiscale = New System.Windows.Forms.Label()
        Me.Label17 = New System.Windows.Forms.Label()
        Me.txtTabListaPaz_DataNascita = New System.Windows.Forms.TextBox()
        Me.lblTabListaPaz_DataNascita = New System.Windows.Forms.Label()
        Me.txtTabListaPaz_Nome = New System.Windows.Forms.TextBox()
        Me.lblTabListaPaz_Nome = New System.Windows.Forms.Label()
        Me.txtTabListaPaz_Cognome = New System.Windows.Forms.TextBox()
        Me.lblTabListaPaz_Cognome = New System.Windows.Forms.Label()
        Me.chkTabListaPaz_RestituisciConsensi = New System.Windows.Forms.CheckBox()
        Me.chkTabListaPaz_RestituisciEsenzioni = New System.Windows.Forms.CheckBox()
        Me.chkTabListaPaz_RestituisciSinonimi = New System.Windows.Forms.CheckBox()
        Me.txtTabListaPaz_IdPaziente = New System.Windows.Forms.TextBox()
        Me.lblTabListaPaz_IdPaziente = New System.Windows.Forms.Label()
        Me.lblTabListaPaz_Ordinamento = New System.Windows.Forms.Label()
        Me.txtTabListaPaz_MaxRecord = New System.Windows.Forms.TextBox()
        Me.lblTabListaPaz_MaxRecord = New System.Windows.Forms.Label()
        Me.btnTabListaPazCerca = New System.Windows.Forms.Button()
        Me.lblVersioneDll = New System.Windows.Forms.Label()
        Me.btn_Tab2_GetFile = New System.Windows.Forms.Button()
        Me.btnTabConsensoXML_GetFile = New System.Windows.Forms.Button()
        Me.TabMain.SuspendLayout()
        Me.Tab2.SuspendLayout()
        Me.TabConsensoXML.SuspendLayout()
        Me.TabPageDettaglio.SuspendLayout()
        Me.TabPageLista.SuspendLayout()
        Me.SuspendLayout()
        '
        'lstResult
        '
        Me.lstResult.Anchor = CType(((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Left) _
            Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.lstResult.FormattingEnabled = True
        Me.lstResult.Location = New System.Drawing.Point(12, 25)
        Me.lstResult.Name = "lstResult"
        Me.lstResult.Size = New System.Drawing.Size(523, 69)
        Me.lstResult.TabIndex = 0
        '
        'OpenFileDialog1
        '
        Me.OpenFileDialog1.FileName = "OpenFileDialog1"
        Me.OpenFileDialog1.Filter = "xml files (*.xml)|*.xml"
        '
        'TabMain
        '
        Me.TabMain.Anchor = CType((((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Bottom) _
            Or System.Windows.Forms.AnchorStyles.Left) _
            Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.TabMain.Controls.Add(Me.Tab2)
        Me.TabMain.Controls.Add(Me.TabConsensoXML)
        Me.TabMain.Controls.Add(Me.TabPageDettaglio)
        Me.TabMain.Controls.Add(Me.TabPageLista)
        Me.TabMain.Location = New System.Drawing.Point(12, 100)
        Me.TabMain.Name = "TabMain"
        Me.TabMain.SelectedIndex = 0
        Me.TabMain.Size = New System.Drawing.Size(529, 488)
        Me.TabMain.TabIndex = 24
        '
        'Tab2
        '
        Me.Tab2.Controls.Add(Me.btn_Tab2_GetFile)
        Me.Tab2.Controls.Add(Me.btnTab2_ProcMsgPaziente_WCF)
        Me.Tab2.Controls.Add(Me.Label12)
        Me.Tab2.Controls.Add(Me.txtTab2_DataSequenza)
        Me.Tab2.Controls.Add(Me.Label11)
        Me.Tab2.Controls.Add(Me.txtTab2_Result)
        Me.Tab2.Controls.Add(Me.cmbTab2_Tipo)
        Me.Tab2.Controls.Add(Me.Label8)
        Me.Tab2.Controls.Add(Me.Label7)
        Me.Tab2.Controls.Add(Me.txtTab2_XmlPaziente)
        Me.Tab2.Location = New System.Drawing.Point(4, 22)
        Me.Tab2.Name = "Tab2"
        Me.Tab2.Size = New System.Drawing.Size(521, 462)
        Me.Tab2.TabIndex = 1
        Me.Tab2.Text = "Messaggio Paziente (XML)"
        Me.Tab2.UseVisualStyleBackColor = True
        '
        'btnTab2_ProcMsgPaziente_WCF
        '
        Me.btnTab2_ProcMsgPaziente_WCF.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Left), System.Windows.Forms.AnchorStyles)
        Me.btnTab2_ProcMsgPaziente_WCF.Location = New System.Drawing.Point(294, 248)
        Me.btnTab2_ProcMsgPaziente_WCF.Name = "btnTab2_ProcMsgPaziente_WCF"
        Me.btnTab2_ProcMsgPaziente_WCF.Size = New System.Drawing.Size(211, 23)
        Me.btnTab2_ProcMsgPaziente_WCF.TabIndex = 34
        Me.btnTab2_ProcMsgPaziente_WCF.Text = "Processa Messaggio Paziente"
        Me.btnTab2_ProcMsgPaziente_WCF.UseVisualStyleBackColor = True
        '
        'Label12
        '
        Me.Label12.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Left), System.Windows.Forms.AnchorStyles)
        Me.Label12.AutoSize = True
        Me.Label12.Location = New System.Drawing.Point(8, 269)
        Me.Label12.Name = "Label12"
        Me.Label12.Size = New System.Drawing.Size(65, 13)
        Me.Label12.TabIndex = 33
        Me.Label12.Text = "XML Result:"
        '
        'txtTab2_DataSequenza
        '
        Me.txtTab2_DataSequenza.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Left), System.Windows.Forms.AnchorStyles)
        Me.txtTab2_DataSequenza.Location = New System.Drawing.Point(352, 221)
        Me.txtTab2_DataSequenza.Name = "txtTab2_DataSequenza"
        Me.txtTab2_DataSequenza.Size = New System.Drawing.Size(153, 20)
        Me.txtTab2_DataSequenza.TabIndex = 30
        '
        'Label11
        '
        Me.Label11.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Left), System.Windows.Forms.AnchorStyles)
        Me.Label11.AutoSize = True
        Me.Label11.Location = New System.Drawing.Point(267, 224)
        Me.Label11.Name = "Label11"
        Me.Label11.Size = New System.Drawing.Size(79, 13)
        Me.Label11.TabIndex = 26
        Me.Label11.Text = "Data sequenza"
        '
        'txtTab2_Result
        '
        Me.txtTab2_Result.Anchor = CType(((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Left) _
            Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.txtTab2_Result.Location = New System.Drawing.Point(8, 286)
        Me.txtTab2_Result.Multiline = True
        Me.txtTab2_Result.Name = "txtTab2_Result"
        Me.txtTab2_Result.ReadOnly = True
        Me.txtTab2_Result.ScrollBars = System.Windows.Forms.ScrollBars.Both
        Me.txtTab2_Result.Size = New System.Drawing.Size(497, 161)
        Me.txtTab2_Result.TabIndex = 32
        '
        'cmbTab2_Tipo
        '
        Me.cmbTab2_Tipo.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Left), System.Windows.Forms.AnchorStyles)
        Me.cmbTab2_Tipo.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList
        Me.cmbTab2_Tipo.FormattingEnabled = True
        Me.cmbTab2_Tipo.Items.AddRange(New Object() {"Aggiornamento", "Cancellazione", "Fusione"})
        Me.cmbTab2_Tipo.Location = New System.Drawing.Point(93, 221)
        Me.cmbTab2_Tipo.Name = "cmbTab2_Tipo"
        Me.cmbTab2_Tipo.Size = New System.Drawing.Size(163, 21)
        Me.cmbTab2_Tipo.TabIndex = 27
        '
        'Label8
        '
        Me.Label8.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Left), System.Windows.Forms.AnchorStyles)
        Me.Label8.AutoSize = True
        Me.Label8.Location = New System.Drawing.Point(8, 224)
        Me.Label8.Name = "Label8"
        Me.Label8.Size = New System.Drawing.Size(75, 13)
        Me.Label8.TabIndex = 23
        Me.Label8.Text = "Tipo messagio"
        '
        'Label7
        '
        Me.Label7.AutoSize = True
        Me.Label7.Location = New System.Drawing.Point(5, 7)
        Me.Label7.Name = "Label7"
        Me.Label7.Size = New System.Drawing.Size(102, 13)
        Me.Label7.TabIndex = 22
        Me.Label7.Text = "Xml paziente (input):"
        '
        'txtTab2_XmlPaziente
        '
        Me.txtTab2_XmlPaziente.Anchor = CType((((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Bottom) _
            Or System.Windows.Forms.AnchorStyles.Left) _
            Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.txtTab2_XmlPaziente.Location = New System.Drawing.Point(8, 22)
        Me.txtTab2_XmlPaziente.Multiline = True
        Me.txtTab2_XmlPaziente.Name = "txtTab2_XmlPaziente"
        Me.txtTab2_XmlPaziente.ScrollBars = System.Windows.Forms.ScrollBars.Both
        Me.txtTab2_XmlPaziente.Size = New System.Drawing.Size(472, 188)
        Me.txtTab2_XmlPaziente.TabIndex = 11
        '
        'TabConsensoXML
        '
        Me.TabConsensoXML.Controls.Add(Me.btnTabConsensoXML_GetFile)
        Me.TabConsensoXML.Controls.Add(Me.btnTabConsensoXML_ProcMsgConsensoWcf)
        Me.TabConsensoXML.Controls.Add(Me.txtTabConsensoXML_Result)
        Me.TabConsensoXML.Controls.Add(Me.Label14)
        Me.TabConsensoXML.Controls.Add(Me.txtTabConsensoXML_DataSequenza)
        Me.TabConsensoXML.Controls.Add(Me.Label10)
        Me.TabConsensoXML.Controls.Add(Me.cmbTabConsensoXML_Tipo)
        Me.TabConsensoXML.Controls.Add(Me.Label13)
        Me.TabConsensoXML.Controls.Add(Me.txtTabConsensoXML_XmlConsenso)
        Me.TabConsensoXML.Controls.Add(Me.Label9)
        Me.TabConsensoXML.Location = New System.Drawing.Point(4, 22)
        Me.TabConsensoXML.Name = "TabConsensoXML"
        Me.TabConsensoXML.Size = New System.Drawing.Size(521, 462)
        Me.TabConsensoXML.TabIndex = 2
        Me.TabConsensoXML.Text = "Messaggio Consenso (XML)"
        Me.TabConsensoXML.UseVisualStyleBackColor = True
        '
        'btnTabConsensoXML_ProcMsgConsensoWcf
        '
        Me.btnTabConsensoXML_ProcMsgConsensoWcf.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Left), System.Windows.Forms.AnchorStyles)
        Me.btnTabConsensoXML_ProcMsgConsensoWcf.Location = New System.Drawing.Point(302, 259)
        Me.btnTabConsensoXML_ProcMsgConsensoWcf.Name = "btnTabConsensoXML_ProcMsgConsensoWcf"
        Me.btnTabConsensoXML_ProcMsgConsensoWcf.Size = New System.Drawing.Size(200, 23)
        Me.btnTabConsensoXML_ProcMsgConsensoWcf.TabIndex = 38
        Me.btnTabConsensoXML_ProcMsgConsensoWcf.Text = "Processa Messaggio Consenso"
        Me.btnTabConsensoXML_ProcMsgConsensoWcf.UseVisualStyleBackColor = True
        '
        'txtTabConsensoXML_Result
        '
        Me.txtTabConsensoXML_Result.Anchor = CType(((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Left) _
            Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.txtTabConsensoXML_Result.Location = New System.Drawing.Point(8, 306)
        Me.txtTabConsensoXML_Result.Multiline = True
        Me.txtTabConsensoXML_Result.Name = "txtTabConsensoXML_Result"
        Me.txtTabConsensoXML_Result.ReadOnly = True
        Me.txtTabConsensoXML_Result.ScrollBars = System.Windows.Forms.ScrollBars.Both
        Me.txtTabConsensoXML_Result.Size = New System.Drawing.Size(489, 147)
        Me.txtTabConsensoXML_Result.TabIndex = 37
        '
        'Label14
        '
        Me.Label14.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Left), System.Windows.Forms.AnchorStyles)
        Me.Label14.AutoSize = True
        Me.Label14.Location = New System.Drawing.Point(8, 290)
        Me.Label14.Name = "Label14"
        Me.Label14.Size = New System.Drawing.Size(65, 13)
        Me.Label14.TabIndex = 36
        Me.Label14.Text = "XML Result:"
        '
        'txtTabConsensoXML_DataSequenza
        '
        Me.txtTabConsensoXML_DataSequenza.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Left), System.Windows.Forms.AnchorStyles)
        Me.txtTabConsensoXML_DataSequenza.Location = New System.Drawing.Point(349, 232)
        Me.txtTabConsensoXML_DataSequenza.Name = "txtTabConsensoXML_DataSequenza"
        Me.txtTabConsensoXML_DataSequenza.Size = New System.Drawing.Size(153, 20)
        Me.txtTabConsensoXML_DataSequenza.TabIndex = 34
        '
        'Label10
        '
        Me.Label10.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Left), System.Windows.Forms.AnchorStyles)
        Me.Label10.AutoSize = True
        Me.Label10.Location = New System.Drawing.Point(264, 235)
        Me.Label10.Name = "Label10"
        Me.Label10.Size = New System.Drawing.Size(79, 13)
        Me.Label10.TabIndex = 32
        Me.Label10.Text = "Data sequenza"
        '
        'cmbTabConsensoXML_Tipo
        '
        Me.cmbTabConsensoXML_Tipo.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Left), System.Windows.Forms.AnchorStyles)
        Me.cmbTabConsensoXML_Tipo.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList
        Me.cmbTabConsensoXML_Tipo.FormattingEnabled = True
        Me.cmbTabConsensoXML_Tipo.Items.AddRange(New Object() {"Inserimento"})
        Me.cmbTabConsensoXML_Tipo.Location = New System.Drawing.Point(93, 232)
        Me.cmbTabConsensoXML_Tipo.Name = "cmbTabConsensoXML_Tipo"
        Me.cmbTabConsensoXML_Tipo.Size = New System.Drawing.Size(163, 21)
        Me.cmbTabConsensoXML_Tipo.TabIndex = 33
        '
        'Label13
        '
        Me.Label13.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Left), System.Windows.Forms.AnchorStyles)
        Me.Label13.AutoSize = True
        Me.Label13.Location = New System.Drawing.Point(8, 235)
        Me.Label13.Name = "Label13"
        Me.Label13.Size = New System.Drawing.Size(75, 13)
        Me.Label13.TabIndex = 31
        Me.Label13.Text = "Tipo messagio"
        '
        'txtTabConsensoXML_XmlConsenso
        '
        Me.txtTabConsensoXML_XmlConsenso.Anchor = CType((((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Bottom) _
            Or System.Windows.Forms.AnchorStyles.Left) _
            Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.txtTabConsensoXML_XmlConsenso.Location = New System.Drawing.Point(8, 22)
        Me.txtTabConsensoXML_XmlConsenso.Multiline = True
        Me.txtTabConsensoXML_XmlConsenso.Name = "txtTabConsensoXML_XmlConsenso"
        Me.txtTabConsensoXML_XmlConsenso.ScrollBars = System.Windows.Forms.ScrollBars.Both
        Me.txtTabConsensoXML_XmlConsenso.Size = New System.Drawing.Size(472, 204)
        Me.txtTabConsensoXML_XmlConsenso.TabIndex = 24
        '
        'Label9
        '
        Me.Label9.AutoSize = True
        Me.Label9.Location = New System.Drawing.Point(5, 6)
        Me.Label9.Name = "Label9"
        Me.Label9.Size = New System.Drawing.Size(108, 13)
        Me.Label9.TabIndex = 23
        Me.Label9.Text = "Xml consenso (input):"
        '
        'TabPageDettaglio
        '
        Me.TabPageDettaglio.Controls.Add(Me.cmdFindByIdPazinte_WCF)
        Me.TabPageDettaglio.Controls.Add(Me.lbldPaziente)
        Me.TabPageDettaglio.Controls.Add(Me.txtIdPaziente)
        Me.TabPageDettaglio.Controls.Add(Me.Label15)
        Me.TabPageDettaglio.Controls.Add(Me.txtDettaglioXML)
        Me.TabPageDettaglio.Location = New System.Drawing.Point(4, 22)
        Me.TabPageDettaglio.Name = "TabPageDettaglio"
        Me.TabPageDettaglio.Padding = New System.Windows.Forms.Padding(3)
        Me.TabPageDettaglio.Size = New System.Drawing.Size(521, 462)
        Me.TabPageDettaglio.TabIndex = 3
        Me.TabPageDettaglio.Text = "Dettaglio Paziente"
        Me.TabPageDettaglio.UseVisualStyleBackColor = True
        '
        'cmdFindByIdPazinte_WCF
        '
        Me.cmdFindByIdPazinte_WCF.Location = New System.Drawing.Point(370, 39)
        Me.cmdFindByIdPazinte_WCF.Name = "cmdFindByIdPazinte_WCF"
        Me.cmdFindByIdPazinte_WCF.Size = New System.Drawing.Size(112, 23)
        Me.cmdFindByIdPazinte_WCF.TabIndex = 39
        Me.cmdFindByIdPazinte_WCF.Text = "Cerca"
        Me.cmdFindByIdPazinte_WCF.UseVisualStyleBackColor = True
        '
        'lbldPaziente
        '
        Me.lbldPaziente.AutoSize = True
        Me.lbldPaziente.Location = New System.Drawing.Point(15, 16)
        Me.lbldPaziente.Name = "lbldPaziente"
        Me.lbldPaziente.Size = New System.Drawing.Size(57, 13)
        Me.lbldPaziente.TabIndex = 37
        Me.lbldPaziente.Text = "IdPaziente"
        '
        'txtIdPaziente
        '
        Me.txtIdPaziente.Location = New System.Drawing.Point(92, 13)
        Me.txtIdPaziente.Name = "txtIdPaziente"
        Me.txtIdPaziente.Size = New System.Drawing.Size(407, 20)
        Me.txtIdPaziente.TabIndex = 36
        Me.txtIdPaziente.Text = "6D268E1B-DF15-4199-BC0B-206D97319DF4"
        '
        'Label15
        '
        Me.Label15.AutoSize = True
        Me.Label15.Location = New System.Drawing.Point(15, 70)
        Me.Label15.Name = "Label15"
        Me.Label15.Size = New System.Drawing.Size(65, 13)
        Me.Label15.TabIndex = 35
        Me.Label15.Text = "XML Result:"
        '
        'txtDettaglioXML
        '
        Me.txtDettaglioXML.Anchor = CType((((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Bottom) _
            Or System.Windows.Forms.AnchorStyles.Left) _
            Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.txtDettaglioXML.Location = New System.Drawing.Point(12, 86)
        Me.txtDettaglioXML.Multiline = True
        Me.txtDettaglioXML.Name = "txtDettaglioXML"
        Me.txtDettaglioXML.ReadOnly = True
        Me.txtDettaglioXML.ScrollBars = System.Windows.Forms.ScrollBars.Both
        Me.txtDettaglioXML.Size = New System.Drawing.Size(489, 367)
        Me.txtDettaglioXML.TabIndex = 34
        '
        'TabPageLista
        '
        Me.TabPageLista.Controls.Add(Me.txtTabListaPaz_XmlResult)
        Me.TabPageLista.Controls.Add(Me.Label16)
        Me.TabPageLista.Controls.Add(Me.cmbTabListaPaz_Sesso)
        Me.TabPageLista.Controls.Add(Me.cmbTabListaPaz_Ordinamento)
        Me.TabPageLista.Controls.Add(Me.lblTabListaPaz_Sesso)
        Me.TabPageLista.Controls.Add(Me.txtTabListaPaz_CodiceFiscale)
        Me.TabPageLista.Controls.Add(Me.lblTabListaPaz_CodiceFiscale)
        Me.TabPageLista.Controls.Add(Me.Label17)
        Me.TabPageLista.Controls.Add(Me.txtTabListaPaz_DataNascita)
        Me.TabPageLista.Controls.Add(Me.lblTabListaPaz_DataNascita)
        Me.TabPageLista.Controls.Add(Me.txtTabListaPaz_Nome)
        Me.TabPageLista.Controls.Add(Me.lblTabListaPaz_Nome)
        Me.TabPageLista.Controls.Add(Me.txtTabListaPaz_Cognome)
        Me.TabPageLista.Controls.Add(Me.lblTabListaPaz_Cognome)
        Me.TabPageLista.Controls.Add(Me.chkTabListaPaz_RestituisciConsensi)
        Me.TabPageLista.Controls.Add(Me.chkTabListaPaz_RestituisciEsenzioni)
        Me.TabPageLista.Controls.Add(Me.chkTabListaPaz_RestituisciSinonimi)
        Me.TabPageLista.Controls.Add(Me.txtTabListaPaz_IdPaziente)
        Me.TabPageLista.Controls.Add(Me.lblTabListaPaz_IdPaziente)
        Me.TabPageLista.Controls.Add(Me.lblTabListaPaz_Ordinamento)
        Me.TabPageLista.Controls.Add(Me.txtTabListaPaz_MaxRecord)
        Me.TabPageLista.Controls.Add(Me.lblTabListaPaz_MaxRecord)
        Me.TabPageLista.Controls.Add(Me.btnTabListaPazCerca)
        Me.TabPageLista.Location = New System.Drawing.Point(4, 22)
        Me.TabPageLista.Name = "TabPageLista"
        Me.TabPageLista.Size = New System.Drawing.Size(521, 462)
        Me.TabPageLista.TabIndex = 4
        Me.TabPageLista.Text = "Lista Pazienti"
        Me.TabPageLista.UseVisualStyleBackColor = True
        '
        'txtTabListaPaz_XmlResult
        '
        Me.txtTabListaPaz_XmlResult.Anchor = CType((((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Bottom) _
            Or System.Windows.Forms.AnchorStyles.Left) _
            Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.txtTabListaPaz_XmlResult.Location = New System.Drawing.Point(14, 220)
        Me.txtTabListaPaz_XmlResult.Multiline = True
        Me.txtTabListaPaz_XmlResult.Name = "txtTabListaPaz_XmlResult"
        Me.txtTabListaPaz_XmlResult.ReadOnly = True
        Me.txtTabListaPaz_XmlResult.ScrollBars = System.Windows.Forms.ScrollBars.Both
        Me.txtTabListaPaz_XmlResult.Size = New System.Drawing.Size(495, 234)
        Me.txtTabListaPaz_XmlResult.TabIndex = 37
        '
        'Label16
        '
        Me.Label16.AutoSize = True
        Me.Label16.Location = New System.Drawing.Point(16, 204)
        Me.Label16.Name = "Label16"
        Me.Label16.Size = New System.Drawing.Size(65, 13)
        Me.Label16.TabIndex = 36
        Me.Label16.Text = "XML Result:"
        '
        'cmbTabListaPaz_Sesso
        '
        Me.cmbTabListaPaz_Sesso.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList
        Me.cmbTabListaPaz_Sesso.FormattingEnabled = True
        Me.cmbTabListaPaz_Sesso.Items.AddRange(New Object() {"", "M", "F"})
        Me.cmbTabListaPaz_Sesso.Location = New System.Drawing.Point(309, 154)
        Me.cmbTabListaPaz_Sesso.Name = "cmbTabListaPaz_Sesso"
        Me.cmbTabListaPaz_Sesso.Size = New System.Drawing.Size(54, 21)
        Me.cmbTabListaPaz_Sesso.TabIndex = 22
        '
        'cmbTabListaPaz_Ordinamento
        '
        Me.cmbTabListaPaz_Ordinamento.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList
        Me.cmbTabListaPaz_Ordinamento.FormattingEnabled = True
        Me.cmbTabListaPaz_Ordinamento.Items.AddRange(New Object() {"Cognome", "Nome", "CodiceFiscale", "Sesso"})
        Me.cmbTabListaPaz_Ordinamento.Location = New System.Drawing.Point(285, 9)
        Me.cmbTabListaPaz_Ordinamento.Name = "cmbTabListaPaz_Ordinamento"
        Me.cmbTabListaPaz_Ordinamento.Size = New System.Drawing.Size(157, 21)
        Me.cmbTabListaPaz_Ordinamento.TabIndex = 21
        '
        'lblTabListaPaz_Sesso
        '
        Me.lblTabListaPaz_Sesso.AutoSize = True
        Me.lblTabListaPaz_Sesso.Location = New System.Drawing.Point(265, 157)
        Me.lblTabListaPaz_Sesso.Name = "lblTabListaPaz_Sesso"
        Me.lblTabListaPaz_Sesso.Size = New System.Drawing.Size(36, 13)
        Me.lblTabListaPaz_Sesso.TabIndex = 19
        Me.lblTabListaPaz_Sesso.Text = "Sesso"
        '
        'txtTabListaPaz_CodiceFiscale
        '
        Me.txtTabListaPaz_CodiceFiscale.Location = New System.Drawing.Point(89, 154)
        Me.txtTabListaPaz_CodiceFiscale.Name = "txtTabListaPaz_CodiceFiscale"
        Me.txtTabListaPaz_CodiceFiscale.Size = New System.Drawing.Size(168, 20)
        Me.txtTabListaPaz_CodiceFiscale.TabIndex = 18
        '
        'lblTabListaPaz_CodiceFiscale
        '
        Me.lblTabListaPaz_CodiceFiscale.AutoSize = True
        Me.lblTabListaPaz_CodiceFiscale.Location = New System.Drawing.Point(14, 157)
        Me.lblTabListaPaz_CodiceFiscale.Name = "lblTabListaPaz_CodiceFiscale"
        Me.lblTabListaPaz_CodiceFiscale.Size = New System.Drawing.Size(73, 13)
        Me.lblTabListaPaz_CodiceFiscale.TabIndex = 17
        Me.lblTabListaPaz_CodiceFiscale.Text = "Codice fiscale"
        '
        'Label17
        '
        Me.Label17.AutoSize = True
        Me.Label17.Location = New System.Drawing.Point(205, 130)
        Me.Label17.Name = "Label17"
        Me.Label17.Size = New System.Drawing.Size(69, 13)
        Me.Label17.TabIndex = 16
        Me.Label17.Text = "(yyyy-MM-dd)"
        '
        'txtTabListaPaz_DataNascita
        '
        Me.txtTabListaPaz_DataNascita.Location = New System.Drawing.Point(89, 127)
        Me.txtTabListaPaz_DataNascita.Name = "txtTabListaPaz_DataNascita"
        Me.txtTabListaPaz_DataNascita.Size = New System.Drawing.Size(110, 20)
        Me.txtTabListaPaz_DataNascita.TabIndex = 15
        '
        'lblTabListaPaz_DataNascita
        '
        Me.lblTabListaPaz_DataNascita.AutoSize = True
        Me.lblTabListaPaz_DataNascita.Location = New System.Drawing.Point(14, 130)
        Me.lblTabListaPaz_DataNascita.Name = "lblTabListaPaz_DataNascita"
        Me.lblTabListaPaz_DataNascita.Size = New System.Drawing.Size(67, 13)
        Me.lblTabListaPaz_DataNascita.TabIndex = 14
        Me.lblTabListaPaz_DataNascita.Text = "Data nascita"
        '
        'txtTabListaPaz_Nome
        '
        Me.txtTabListaPaz_Nome.Location = New System.Drawing.Point(309, 101)
        Me.txtTabListaPaz_Nome.Name = "txtTabListaPaz_Nome"
        Me.txtTabListaPaz_Nome.Size = New System.Drawing.Size(168, 20)
        Me.txtTabListaPaz_Nome.TabIndex = 13
        Me.txtTabListaPaz_Nome.Text = "Giorgio"
        '
        'lblTabListaPaz_Nome
        '
        Me.lblTabListaPaz_Nome.AutoSize = True
        Me.lblTabListaPaz_Nome.Location = New System.Drawing.Point(269, 104)
        Me.lblTabListaPaz_Nome.Name = "lblTabListaPaz_Nome"
        Me.lblTabListaPaz_Nome.Size = New System.Drawing.Size(35, 13)
        Me.lblTabListaPaz_Nome.TabIndex = 12
        Me.lblTabListaPaz_Nome.Text = "Nome"
        '
        'txtTabListaPaz_Cognome
        '
        Me.txtTabListaPaz_Cognome.Location = New System.Drawing.Point(89, 101)
        Me.txtTabListaPaz_Cognome.Name = "txtTabListaPaz_Cognome"
        Me.txtTabListaPaz_Cognome.Size = New System.Drawing.Size(168, 20)
        Me.txtTabListaPaz_Cognome.TabIndex = 11
        Me.txtTabListaPaz_Cognome.Text = "Campani"
        '
        'lblTabListaPaz_Cognome
        '
        Me.lblTabListaPaz_Cognome.AutoSize = True
        Me.lblTabListaPaz_Cognome.Location = New System.Drawing.Point(14, 104)
        Me.lblTabListaPaz_Cognome.Name = "lblTabListaPaz_Cognome"
        Me.lblTabListaPaz_Cognome.Size = New System.Drawing.Size(52, 13)
        Me.lblTabListaPaz_Cognome.TabIndex = 10
        Me.lblTabListaPaz_Cognome.Text = "Cognome"
        '
        'chkTabListaPaz_RestituisciConsensi
        '
        Me.chkTabListaPaz_RestituisciConsensi.AutoSize = True
        Me.chkTabListaPaz_RestituisciConsensi.Location = New System.Drawing.Point(274, 41)
        Me.chkTabListaPaz_RestituisciConsensi.Name = "chkTabListaPaz_RestituisciConsensi"
        Me.chkTabListaPaz_RestituisciConsensi.Size = New System.Drawing.Size(120, 17)
        Me.chkTabListaPaz_RestituisciConsensi.TabIndex = 9
        Me.chkTabListaPaz_RestituisciConsensi.Text = "Restituisci Consensi"
        Me.chkTabListaPaz_RestituisciConsensi.UseVisualStyleBackColor = True
        '
        'chkTabListaPaz_RestituisciEsenzioni
        '
        Me.chkTabListaPaz_RestituisciEsenzioni.AutoSize = True
        Me.chkTabListaPaz_RestituisciEsenzioni.Location = New System.Drawing.Point(143, 41)
        Me.chkTabListaPaz_RestituisciEsenzioni.Name = "chkTabListaPaz_RestituisciEsenzioni"
        Me.chkTabListaPaz_RestituisciEsenzioni.Size = New System.Drawing.Size(122, 17)
        Me.chkTabListaPaz_RestituisciEsenzioni.TabIndex = 8
        Me.chkTabListaPaz_RestituisciEsenzioni.Text = "Restituisci Esenzioni"
        Me.chkTabListaPaz_RestituisciEsenzioni.UseVisualStyleBackColor = True
        '
        'chkTabListaPaz_RestituisciSinonimi
        '
        Me.chkTabListaPaz_RestituisciSinonimi.AutoSize = True
        Me.chkTabListaPaz_RestituisciSinonimi.Checked = True
        Me.chkTabListaPaz_RestituisciSinonimi.CheckState = System.Windows.Forms.CheckState.Checked
        Me.chkTabListaPaz_RestituisciSinonimi.Location = New System.Drawing.Point(17, 41)
        Me.chkTabListaPaz_RestituisciSinonimi.Name = "chkTabListaPaz_RestituisciSinonimi"
        Me.chkTabListaPaz_RestituisciSinonimi.Size = New System.Drawing.Size(116, 17)
        Me.chkTabListaPaz_RestituisciSinonimi.TabIndex = 7
        Me.chkTabListaPaz_RestituisciSinonimi.Text = "Restituisci Sinonimi"
        Me.chkTabListaPaz_RestituisciSinonimi.UseVisualStyleBackColor = True
        '
        'txtTabListaPaz_IdPaziente
        '
        Me.txtTabListaPaz_IdPaziente.Location = New System.Drawing.Point(89, 75)
        Me.txtTabListaPaz_IdPaziente.Name = "txtTabListaPaz_IdPaziente"
        Me.txtTabListaPaz_IdPaziente.Size = New System.Drawing.Size(297, 20)
        Me.txtTabListaPaz_IdPaziente.TabIndex = 6
        Me.txtTabListaPaz_IdPaziente.Text = "6D268E1B-DF15-4199-BC0B-206D97319DF4"
        '
        'lblTabListaPaz_IdPaziente
        '
        Me.lblTabListaPaz_IdPaziente.AutoSize = True
        Me.lblTabListaPaz_IdPaziente.Location = New System.Drawing.Point(14, 78)
        Me.lblTabListaPaz_IdPaziente.Name = "lblTabListaPaz_IdPaziente"
        Me.lblTabListaPaz_IdPaziente.Size = New System.Drawing.Size(57, 13)
        Me.lblTabListaPaz_IdPaziente.TabIndex = 5
        Me.lblTabListaPaz_IdPaziente.Text = "IdPaziente"
        '
        'lblTabListaPaz_Ordinamento
        '
        Me.lblTabListaPaz_Ordinamento.AutoSize = True
        Me.lblTabListaPaz_Ordinamento.Location = New System.Drawing.Point(211, 13)
        Me.lblTabListaPaz_Ordinamento.Name = "lblTabListaPaz_Ordinamento"
        Me.lblTabListaPaz_Ordinamento.Size = New System.Drawing.Size(67, 13)
        Me.lblTabListaPaz_Ordinamento.TabIndex = 3
        Me.lblTabListaPaz_Ordinamento.Text = "Ordinamento"
        '
        'txtTabListaPaz_MaxRecord
        '
        Me.txtTabListaPaz_MaxRecord.Location = New System.Drawing.Point(99, 10)
        Me.txtTabListaPaz_MaxRecord.Name = "txtTabListaPaz_MaxRecord"
        Me.txtTabListaPaz_MaxRecord.Size = New System.Drawing.Size(100, 20)
        Me.txtTabListaPaz_MaxRecord.TabIndex = 2
        Me.txtTabListaPaz_MaxRecord.Text = "100"
        '
        'lblTabListaPaz_MaxRecord
        '
        Me.lblTabListaPaz_MaxRecord.AutoSize = True
        Me.lblTabListaPaz_MaxRecord.Location = New System.Drawing.Point(14, 13)
        Me.lblTabListaPaz_MaxRecord.Name = "lblTabListaPaz_MaxRecord"
        Me.lblTabListaPaz_MaxRecord.Size = New System.Drawing.Size(65, 13)
        Me.lblTabListaPaz_MaxRecord.TabIndex = 1
        Me.lblTabListaPaz_MaxRecord.Text = "Max Record"
        '
        'btnTabListaPazCerca
        '
        Me.btnTabListaPazCerca.Location = New System.Drawing.Point(422, 182)
        Me.btnTabListaPazCerca.Name = "btnTabListaPazCerca"
        Me.btnTabListaPazCerca.Size = New System.Drawing.Size(75, 23)
        Me.btnTabListaPazCerca.TabIndex = 0
        Me.btnTabListaPazCerca.Text = "Cerca (WCF)"
        Me.btnTabListaPazCerca.UseVisualStyleBackColor = True
        '
        'lblVersioneDll
        '
        Me.lblVersioneDll.AutoSize = True
        Me.lblVersioneDll.Location = New System.Drawing.Point(12, 6)
        Me.lblVersioneDll.Name = "lblVersioneDll"
        Me.lblVersioneDll.Size = New System.Drawing.Size(63, 13)
        Me.lblVersioneDll.TabIndex = 25
        Me.lblVersioneDll.Text = "Versione Dll"
        '
        'btn_Tab2_GetFile
        '
        Me.btn_Tab2_GetFile.Location = New System.Drawing.Point(486, 22)
        Me.btn_Tab2_GetFile.Name = "btn_Tab2_GetFile"
        Me.btn_Tab2_GetFile.Size = New System.Drawing.Size(25, 23)
        Me.btn_Tab2_GetFile.TabIndex = 35
        Me.btn_Tab2_GetFile.Text = "..."
        Me.btn_Tab2_GetFile.UseVisualStyleBackColor = True
        '
        'btnTabConsensoXML_GetFile
        '
        Me.btnTabConsensoXML_GetFile.Location = New System.Drawing.Point(486, 22)
        Me.btnTabConsensoXML_GetFile.Name = "btnTabConsensoXML_GetFile"
        Me.btnTabConsensoXML_GetFile.Size = New System.Drawing.Size(25, 23)
        Me.btnTabConsensoXML_GetFile.TabIndex = 39
        Me.btnTabConsensoXML_GetFile.Text = "..."
        Me.btnTabConsensoXML_GetFile.UseVisualStyleBackColor = True
        '
        'Main
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(6.0!, 13.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.ClientSize = New System.Drawing.Size(547, 603)
        Me.Controls.Add(Me.lblVersioneDll)
        Me.Controls.Add(Me.TabMain)
        Me.Controls.Add(Me.lstResult)
        Me.Name = "Main"
        Me.Text = "Test DAE WCF"
        Me.TabMain.ResumeLayout(False)
        Me.Tab2.ResumeLayout(False)
        Me.Tab2.PerformLayout()
        Me.TabConsensoXML.ResumeLayout(False)
        Me.TabConsensoXML.PerformLayout()
        Me.TabPageDettaglio.ResumeLayout(False)
        Me.TabPageDettaglio.PerformLayout()
        Me.TabPageLista.ResumeLayout(False)
        Me.TabPageLista.PerformLayout()
        Me.ResumeLayout(False)
        Me.PerformLayout()

    End Sub
    Friend WithEvents lstResult As System.Windows.Forms.ListBox
    Friend WithEvents OpenFileDialog1 As System.Windows.Forms.OpenFileDialog
    Friend WithEvents TabMain As System.Windows.Forms.TabControl
    Friend WithEvents Tab2 As System.Windows.Forms.TabPage
    Friend WithEvents Label7 As System.Windows.Forms.Label
    Friend WithEvents txtTab2_XmlPaziente As System.Windows.Forms.TextBox
    Friend WithEvents Label8 As System.Windows.Forms.Label
    Friend WithEvents Label11 As System.Windows.Forms.Label
    Friend WithEvents cmbTab2_Tipo As System.Windows.Forms.ComboBox
    Friend WithEvents txtTab2_DataSequenza As System.Windows.Forms.TextBox
    Friend WithEvents Label12 As System.Windows.Forms.Label
    Friend WithEvents txtTab2_Result As System.Windows.Forms.TextBox
    Friend WithEvents lblVersioneDll As System.Windows.Forms.Label
    Friend WithEvents TabConsensoXML As System.Windows.Forms.TabPage
    Friend WithEvents txtTabConsensoXML_Result As System.Windows.Forms.TextBox
    Friend WithEvents Label14 As System.Windows.Forms.Label
    Friend WithEvents txtTabConsensoXML_DataSequenza As System.Windows.Forms.TextBox
    Friend WithEvents Label10 As System.Windows.Forms.Label
    Friend WithEvents cmbTabConsensoXML_Tipo As System.Windows.Forms.ComboBox
    Friend WithEvents Label13 As System.Windows.Forms.Label
    Friend WithEvents txtTabConsensoXML_XmlConsenso As System.Windows.Forms.TextBox
    Friend WithEvents Label9 As System.Windows.Forms.Label
    Friend WithEvents TabPageDettaglio As System.Windows.Forms.TabPage
    Friend WithEvents Label15 As System.Windows.Forms.Label
    Friend WithEvents txtDettaglioXML As System.Windows.Forms.TextBox
    Friend WithEvents lbldPaziente As System.Windows.Forms.Label
    Friend WithEvents txtIdPaziente As System.Windows.Forms.TextBox
    Friend WithEvents btnTab2_ProcMsgPaziente_WCF As Button
    Friend WithEvents cmdFindByIdPazinte_WCF As Button
    Friend WithEvents TabPageLista As TabPage
    Friend WithEvents txtTabListaPaz_Nome As TextBox
    Friend WithEvents lblTabListaPaz_Nome As Label
    Friend WithEvents txtTabListaPaz_Cognome As TextBox
    Friend WithEvents lblTabListaPaz_Cognome As Label
    Friend WithEvents chkTabListaPaz_RestituisciConsensi As CheckBox
    Friend WithEvents chkTabListaPaz_RestituisciEsenzioni As CheckBox
    Friend WithEvents chkTabListaPaz_RestituisciSinonimi As CheckBox
    Friend WithEvents txtTabListaPaz_IdPaziente As TextBox
    Friend WithEvents lblTabListaPaz_IdPaziente As Label
    Friend WithEvents lblTabListaPaz_Ordinamento As Label
    Friend WithEvents txtTabListaPaz_MaxRecord As TextBox
    Friend WithEvents lblTabListaPaz_MaxRecord As Label
    Friend WithEvents btnTabListaPazCerca As Button
    Friend WithEvents Label17 As Label
    Friend WithEvents txtTabListaPaz_DataNascita As TextBox
    Friend WithEvents lblTabListaPaz_DataNascita As Label
    Friend WithEvents lblTabListaPaz_Sesso As Label
    Friend WithEvents txtTabListaPaz_CodiceFiscale As TextBox
    Friend WithEvents lblTabListaPaz_CodiceFiscale As Label
    Friend WithEvents cmbTabListaPaz_Ordinamento As ComboBox
    Friend WithEvents cmbTabListaPaz_Sesso As ComboBox
    Friend WithEvents txtTabListaPaz_XmlResult As TextBox
    Friend WithEvents Label16 As Label
    Friend WithEvents btnTabConsensoXML_ProcMsgConsensoWcf As Button
    Friend WithEvents btn_Tab2_GetFile As Button
    Friend WithEvents btnTabConsensoXML_GetFile As Button
End Class
