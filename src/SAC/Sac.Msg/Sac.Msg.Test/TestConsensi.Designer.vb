<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Class TestConsensi
    Inherits System.Windows.Forms.Form

    'Form overrides dispose to clean up the component list.
    <System.Diagnostics.DebuggerNonUserCode()> _
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
    <System.Diagnostics.DebuggerStepThrough()> _
    Private Sub InitializeComponent()
        Me.lstResult = New System.Windows.Forms.ListBox()
        Me.btnProcConsenso = New System.Windows.Forms.Button()
        Me.cmbTipo = New System.Windows.Forms.ComboBox()
        Me.Label1 = New System.Windows.Forms.Label()
        Me.txtResult = New System.Windows.Forms.TextBox()
        Me.btnUtentiAck = New System.Windows.Forms.Button()
        Me.txtXmlFile = New System.Windows.Forms.TextBox()
        Me.btnLoadXml = New System.Windows.Forms.Button()
        Me.Label6 = New System.Windows.Forms.Label()
        Me.OpenFileDialog1 = New System.Windows.Forms.OpenFileDialog()
        Me.txtPazienteIdProvenienza = New System.Windows.Forms.TextBox()
        Me.Label5 = New System.Windows.Forms.Label()
        Me.Label4 = New System.Windows.Forms.Label()
        Me.chkStato = New System.Windows.Forms.CheckBox()
        Me.txtPazienteProvenienza = New System.Windows.Forms.TextBox()
        Me.Label3 = New System.Windows.Forms.Label()
        Me.txtUtente = New System.Windows.Forms.TextBox()
        Me.Label2 = New System.Windows.Forms.Label()
        Me.SuspendLayout()
        '
        'lstResult
        '
        Me.lstResult.Anchor = CType(((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Left) _
            Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.lstResult.FormattingEnabled = True
        Me.lstResult.Location = New System.Drawing.Point(12, 12)
        Me.lstResult.Name = "lstResult"
        Me.lstResult.Size = New System.Drawing.Size(488, 160)
        Me.lstResult.TabIndex = 0
        '
        'btnProcConsenso
        '
        Me.btnProcConsenso.Location = New System.Drawing.Point(384, 241)
        Me.btnProcConsenso.Name = "btnProcConsenso"
        Me.btnProcConsenso.Size = New System.Drawing.Size(116, 23)
        Me.btnProcConsenso.TabIndex = 1
        Me.btnProcConsenso.Text = "Processa Consenso"
        Me.btnProcConsenso.UseVisualStyleBackColor = True
        '
        'cmbTipo
        '
        Me.cmbTipo.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList
        Me.cmbTipo.FormattingEnabled = True
        Me.cmbTipo.Items.AddRange(New Object() {"Inserimento"})
        Me.cmbTipo.Location = New System.Drawing.Point(101, 188)
        Me.cmbTipo.Name = "cmbTipo"
        Me.cmbTipo.Size = New System.Drawing.Size(121, 21)
        Me.cmbTipo.TabIndex = 2
        '
        'Label1
        '
        Me.Label1.AutoSize = True
        Me.Label1.Location = New System.Drawing.Point(12, 191)
        Me.Label1.Name = "Label1"
        Me.Label1.Size = New System.Drawing.Size(75, 13)
        Me.Label1.TabIndex = 3
        Me.Label1.Text = "Tipo messagio"
        '
        'txtResult
        '
        Me.txtResult.Anchor = CType((((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Bottom) _
            Or System.Windows.Forms.AnchorStyles.Left) _
            Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.txtResult.Location = New System.Drawing.Point(15, 342)
        Me.txtResult.Multiline = True
        Me.txtResult.Name = "txtResult"
        Me.txtResult.ReadOnly = True
        Me.txtResult.ScrollBars = System.Windows.Forms.ScrollBars.Vertical
        Me.txtResult.Size = New System.Drawing.Size(485, 226)
        Me.txtResult.TabIndex = 10
        '
        'btnUtentiAck
        '
        Me.btnUtentiAck.Enabled = False
        Me.btnUtentiAck.Location = New System.Drawing.Point(384, 267)
        Me.btnUtentiAck.Name = "btnUtentiAck"
        Me.btnUtentiAck.Size = New System.Drawing.Size(116, 23)
        Me.btnUtentiAck.TabIndex = 11
        Me.btnUtentiAck.Text = "Utenti ACK"
        Me.btnUtentiAck.UseVisualStyleBackColor = True
        '
        'txtXmlFile
        '
        Me.txtXmlFile.Location = New System.Drawing.Point(69, 217)
        Me.txtXmlFile.Name = "txtXmlFile"
        Me.txtXmlFile.Size = New System.Drawing.Size(309, 20)
        Me.txtXmlFile.TabIndex = 16
        '
        'btnLoadXml
        '
        Me.btnLoadXml.Location = New System.Drawing.Point(384, 215)
        Me.btnLoadXml.Name = "btnLoadXml"
        Me.btnLoadXml.Size = New System.Drawing.Size(116, 23)
        Me.btnLoadXml.TabIndex = 17
        Me.btnLoadXml.Text = "Load XML"
        Me.btnLoadXml.UseVisualStyleBackColor = True
        '
        'Label6
        '
        Me.Label6.AutoSize = True
        Me.Label6.Location = New System.Drawing.Point(15, 220)
        Me.Label6.Name = "Label6"
        Me.Label6.Size = New System.Drawing.Size(48, 13)
        Me.Label6.TabIndex = 18
        Me.Label6.Text = "XML File"
        '
        'OpenFileDialog1
        '
        Me.OpenFileDialog1.FileName = "OpenFileDialog1"
        Me.OpenFileDialog1.Filter = "xml files (*.xml)|*.xml"
        '
        'txtPazienteIdProvenienza
        '
        Me.txtPazienteIdProvenienza.Location = New System.Drawing.Point(141, 295)
        Me.txtPazienteIdProvenienza.Name = "txtPazienteIdProvenienza"
        Me.txtPazienteIdProvenienza.Size = New System.Drawing.Size(237, 20)
        Me.txtPazienteIdProvenienza.TabIndex = 26
        '
        'Label5
        '
        Me.Label5.AutoSize = True
        Me.Label5.Location = New System.Drawing.Point(12, 298)
        Me.Label5.Name = "Label5"
        Me.Label5.Size = New System.Drawing.Size(119, 13)
        Me.Label5.TabIndex = 25
        Me.Label5.Text = "Paziente IdProvenienza"
        '
        'Label4
        '
        Me.Label4.AutoSize = True
        Me.Label4.Location = New System.Drawing.Point(12, 322)
        Me.Label4.Name = "Label4"
        Me.Label4.Size = New System.Drawing.Size(32, 13)
        Me.Label4.TabIndex = 24
        Me.Label4.Text = "Stato"
        '
        'chkStato
        '
        Me.chkStato.AutoSize = True
        Me.chkStato.Location = New System.Drawing.Point(144, 322)
        Me.chkStato.Name = "chkStato"
        Me.chkStato.Size = New System.Drawing.Size(15, 14)
        Me.chkStato.TabIndex = 23
        Me.chkStato.UseVisualStyleBackColor = True
        '
        'txtPazienteProvenienza
        '
        Me.txtPazienteProvenienza.Location = New System.Drawing.Point(141, 269)
        Me.txtPazienteProvenienza.Name = "txtPazienteProvenienza"
        Me.txtPazienteProvenienza.Size = New System.Drawing.Size(237, 20)
        Me.txtPazienteProvenienza.TabIndex = 22
        '
        'Label3
        '
        Me.Label3.AutoSize = True
        Me.Label3.Location = New System.Drawing.Point(12, 272)
        Me.Label3.Name = "Label3"
        Me.Label3.Size = New System.Drawing.Size(110, 13)
        Me.Label3.TabIndex = 21
        Me.Label3.Text = "Paziente Provenienza"
        '
        'txtUtente
        '
        Me.txtUtente.Location = New System.Drawing.Point(141, 243)
        Me.txtUtente.Name = "txtUtente"
        Me.txtUtente.Size = New System.Drawing.Size(237, 20)
        Me.txtUtente.TabIndex = 20
        Me.txtUtente.Text = "dbo"
        '
        'Label2
        '
        Me.Label2.AutoSize = True
        Me.Label2.Location = New System.Drawing.Point(15, 246)
        Me.Label2.Name = "Label2"
        Me.Label2.Size = New System.Drawing.Size(39, 13)
        Me.Label2.TabIndex = 19
        Me.Label2.Text = "Utente"
        '
        'TestConsensi
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(6.0!, 13.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.ClientSize = New System.Drawing.Size(512, 580)
        Me.Controls.Add(Me.txtPazienteIdProvenienza)
        Me.Controls.Add(Me.Label5)
        Me.Controls.Add(Me.Label4)
        Me.Controls.Add(Me.chkStato)
        Me.Controls.Add(Me.txtPazienteProvenienza)
        Me.Controls.Add(Me.Label3)
        Me.Controls.Add(Me.txtUtente)
        Me.Controls.Add(Me.Label2)
        Me.Controls.Add(Me.Label6)
        Me.Controls.Add(Me.btnLoadXml)
        Me.Controls.Add(Me.txtXmlFile)
        Me.Controls.Add(Me.btnUtentiAck)
        Me.Controls.Add(Me.txtResult)
        Me.Controls.Add(Me.Label1)
        Me.Controls.Add(Me.cmbTipo)
        Me.Controls.Add(Me.btnProcConsenso)
        Me.Controls.Add(Me.lstResult)
        Me.Name = "TestConsensi"
        Me.Text = "Form1"
        Me.ResumeLayout(False)
        Me.PerformLayout()

    End Sub
    Friend WithEvents lstResult As System.Windows.Forms.ListBox
    Friend WithEvents btnProcConsenso As System.Windows.Forms.Button
    Friend WithEvents cmbTipo As System.Windows.Forms.ComboBox
    Friend WithEvents Label1 As System.Windows.Forms.Label
    Friend WithEvents txtResult As System.Windows.Forms.TextBox
    Friend WithEvents btnUtentiAck As System.Windows.Forms.Button
    Friend WithEvents txtXmlFile As System.Windows.Forms.TextBox
    Friend WithEvents btnLoadXml As System.Windows.Forms.Button
    Friend WithEvents Label6 As System.Windows.Forms.Label
    Friend WithEvents OpenFileDialog1 As System.Windows.Forms.OpenFileDialog
    Friend WithEvents txtPazienteIdProvenienza As System.Windows.Forms.TextBox
    Friend WithEvents Label5 As System.Windows.Forms.Label
    Friend WithEvents Label4 As System.Windows.Forms.Label
    Friend WithEvents chkStato As System.Windows.Forms.CheckBox
    Friend WithEvents txtPazienteProvenienza As System.Windows.Forms.TextBox
    Friend WithEvents Label3 As System.Windows.Forms.Label
    Friend WithEvents txtUtente As System.Windows.Forms.TextBox
    Friend WithEvents Label2 As System.Windows.Forms.Label

End Class
