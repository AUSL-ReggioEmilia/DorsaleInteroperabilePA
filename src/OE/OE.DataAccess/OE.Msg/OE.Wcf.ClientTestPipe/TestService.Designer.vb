<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Class TestService
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
        Me.TextBoxInput = New System.Windows.Forms.TextBox()
        Me.TextBoxOutput = New System.Windows.Forms.TextBox()
        Me.ButtonRichiesta = New System.Windows.Forms.Button()
        Me.ButtonStato = New System.Windows.Forms.Button()
        Me.TextBoxUriRichiesta = New System.Windows.Forms.TextBox()
        Me.ButtonDesRic = New System.Windows.Forms.Button()
        Me.ButtonDesStato = New System.Windows.Forms.Button()
        Me.LabelUrlRichiesta = New System.Windows.Forms.Label()
        Me.Label1 = New System.Windows.Forms.Label()
        Me.TextBoxIdOrderEntry = New System.Windows.Forms.TextBox()
        Me.LabelUrlStato = New System.Windows.Forms.Label()
        Me.TextBoxUriStato = New System.Windows.Forms.TextBox()
        Me.ButtonOrdine = New System.Windows.Forms.Button()
        Me.Label2 = New System.Windows.Forms.Label()
        Me.TextBoxUriOrdine = New System.Windows.Forms.TextBox()
        Me.ButtonDesStatoAA = New System.Windows.Forms.Button()
        Me.TextBoxIdRichiesta = New System.Windows.Forms.TextBox()
        Me.Label3 = New System.Windows.Forms.Label()
        Me.ButtonDesRic2 = New System.Windows.Forms.Button()
        Me.ButtonDesStatoSE = New System.Windows.Forms.Button()
        Me.ButtonDesStatoInc = New System.Windows.Forms.Button()
        Me.GroupBox1 = New System.Windows.Forms.GroupBox()
        Me.GroupBox2 = New System.Windows.Forms.GroupBox()
        Me.GroupBox1.SuspendLayout()
        Me.GroupBox2.SuspendLayout()
        Me.SuspendLayout()
        '
        'TextBoxInput
        '
        Me.TextBoxInput.Anchor = CType(((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Left) _
            Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.TextBoxInput.Location = New System.Drawing.Point(8, 87)
        Me.TextBoxInput.Multiline = True
        Me.TextBoxInput.Name = "TextBoxInput"
        Me.TextBoxInput.ScrollBars = System.Windows.Forms.ScrollBars.Both
        Me.TextBoxInput.Size = New System.Drawing.Size(538, 162)
        Me.TextBoxInput.TabIndex = 0
        '
        'TextBoxOutput
        '
        Me.TextBoxOutput.Anchor = CType((((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Bottom) _
            Or System.Windows.Forms.AnchorStyles.Left) _
            Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.TextBoxOutput.Location = New System.Drawing.Point(8, 284)
        Me.TextBoxOutput.Multiline = True
        Me.TextBoxOutput.Name = "TextBoxOutput"
        Me.TextBoxOutput.ReadOnly = True
        Me.TextBoxOutput.ScrollBars = System.Windows.Forms.ScrollBars.Both
        Me.TextBoxOutput.Size = New System.Drawing.Size(538, 106)
        Me.TextBoxOutput.TabIndex = 1
        '
        'ButtonRichiesta
        '
        Me.ButtonRichiesta.Location = New System.Drawing.Point(399, 22)
        Me.ButtonRichiesta.Name = "ButtonRichiesta"
        Me.ButtonRichiesta.Size = New System.Drawing.Size(116, 23)
        Me.ButtonRichiesta.TabIndex = 2
        Me.ButtonRichiesta.Text = "Invia Richiesta ->"
        Me.ButtonRichiesta.UseVisualStyleBackColor = True
        '
        'ButtonStato
        '
        Me.ButtonStato.Location = New System.Drawing.Point(397, 19)
        Me.ButtonStato.Name = "ButtonStato"
        Me.ButtonStato.Size = New System.Drawing.Size(116, 23)
        Me.ButtonStato.TabIndex = 3
        Me.ButtonStato.Text = "Invia Stato ->"
        Me.ButtonStato.UseVisualStyleBackColor = True
        '
        'TextBoxUriRichiesta
        '
        Me.TextBoxUriRichiesta.Location = New System.Drawing.Point(110, 8)
        Me.TextBoxUriRichiesta.Name = "TextBoxUriRichiesta"
        Me.TextBoxUriRichiesta.Size = New System.Drawing.Size(434, 20)
        Me.TextBoxUriRichiesta.TabIndex = 4
        '
        'ButtonDesRic
        '
        Me.ButtonDesRic.Location = New System.Drawing.Point(12, 22)
        Me.ButtonDesRic.Name = "ButtonDesRic"
        Me.ButtonDesRic.Size = New System.Drawing.Size(77, 23)
        Me.ButtonDesRic.TabIndex = 5
        Me.ButtonDesRic.Text = "Crea Ric 1 riga"
        Me.ButtonDesRic.UseVisualStyleBackColor = True
        '
        'ButtonDesStato
        '
        Me.ButtonDesStato.Location = New System.Drawing.Point(186, 19)
        Me.ButtonDesStato.Name = "ButtonDesStato"
        Me.ButtonDesStato.Size = New System.Drawing.Size(101, 23)
        Me.ButtonDesStato.TabIndex = 6
        Me.ButtonDesStato.Text = "OSU completo"
        Me.ButtonDesStato.UseVisualStyleBackColor = True
        '
        'LabelUrlRichiesta
        '
        Me.LabelUrlRichiesta.AutoSize = True
        Me.LabelUrlRichiesta.Location = New System.Drawing.Point(12, 11)
        Me.LabelUrlRichiesta.Name = "LabelUrlRichiesta"
        Me.LabelUrlRichiesta.Size = New System.Drawing.Size(71, 13)
        Me.LabelUrlRichiesta.TabIndex = 10
        Me.LabelUrlRichiesta.Text = "URL richiesta"
        '
        'Label1
        '
        Me.Label1.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.Label1.AutoSize = True
        Me.Label1.Location = New System.Drawing.Point(245, 258)
        Me.Label1.Name = "Label1"
        Me.Label1.Size = New System.Drawing.Size(66, 13)
        Me.Label1.TabIndex = 11
        Me.Label1.Text = "IdOrderEntry"
        '
        'TextBoxIdOrderEntry
        '
        Me.TextBoxIdOrderEntry.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.TextBoxIdOrderEntry.Location = New System.Drawing.Point(310, 255)
        Me.TextBoxIdOrderEntry.Name = "TextBoxIdOrderEntry"
        Me.TextBoxIdOrderEntry.Size = New System.Drawing.Size(175, 20)
        Me.TextBoxIdOrderEntry.TabIndex = 12
        '
        'LabelUrlStato
        '
        Me.LabelUrlStato.AutoSize = True
        Me.LabelUrlStato.Location = New System.Drawing.Point(12, 37)
        Me.LabelUrlStato.Name = "LabelUrlStato"
        Me.LabelUrlStato.Size = New System.Drawing.Size(55, 13)
        Me.LabelUrlStato.TabIndex = 14
        Me.LabelUrlStato.Text = "URL stato"
        '
        'TextBoxUriStato
        '
        Me.TextBoxUriStato.Location = New System.Drawing.Point(110, 34)
        Me.TextBoxUriStato.Name = "TextBoxUriStato"
        Me.TextBoxUriStato.Size = New System.Drawing.Size(434, 20)
        Me.TextBoxUriStato.TabIndex = 13
        '
        'ButtonOrdine
        '
        Me.ButtonOrdine.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.ButtonOrdine.Location = New System.Drawing.Point(491, 253)
        Me.ButtonOrdine.Name = "ButtonOrdine"
        Me.ButtonOrdine.Size = New System.Drawing.Size(53, 23)
        Me.ButtonOrdine.TabIndex = 15
        Me.ButtonOrdine.Text = "Legge"
        Me.ButtonOrdine.UseVisualStyleBackColor = True
        '
        'Label2
        '
        Me.Label2.AutoSize = True
        Me.Label2.Location = New System.Drawing.Point(12, 64)
        Me.Label2.Name = "Label2"
        Me.Label2.Size = New System.Drawing.Size(61, 13)
        Me.Label2.TabIndex = 17
        Me.Label2.Text = "URL ordine"
        '
        'TextBoxUriOrdine
        '
        Me.TextBoxUriOrdine.Location = New System.Drawing.Point(110, 61)
        Me.TextBoxUriOrdine.Name = "TextBoxUriOrdine"
        Me.TextBoxUriOrdine.Size = New System.Drawing.Size(434, 20)
        Me.TextBoxUriOrdine.TabIndex = 16
        '
        'ButtonDesStatoAA
        '
        Me.ButtonDesStatoAA.Location = New System.Drawing.Point(10, 19)
        Me.ButtonDesStatoAA.Name = "ButtonDesStatoAA"
        Me.ButtonDesStatoAA.Size = New System.Drawing.Size(42, 23)
        Me.ButtonDesStatoAA.TabIndex = 18
        Me.ButtonDesStatoAA.Text = "AA"
        Me.ButtonDesStatoAA.UseVisualStyleBackColor = True
        '
        'TextBoxIdRichiesta
        '
        Me.TextBoxIdRichiesta.Location = New System.Drawing.Point(81, 255)
        Me.TextBoxIdRichiesta.Name = "TextBoxIdRichiesta"
        Me.TextBoxIdRichiesta.Size = New System.Drawing.Size(158, 20)
        Me.TextBoxIdRichiesta.TabIndex = 20
        '
        'Label3
        '
        Me.Label3.AutoSize = True
        Me.Label3.Location = New System.Drawing.Point(9, 258)
        Me.Label3.Name = "Label3"
        Me.Label3.Size = New System.Drawing.Size(60, 13)
        Me.Label3.TabIndex = 19
        Me.Label3.Text = "IdRichiesta"
        '
        'ButtonDesRic2
        '
        Me.ButtonDesRic2.Location = New System.Drawing.Point(95, 22)
        Me.ButtonDesRic2.Name = "ButtonDesRic2"
        Me.ButtonDesRic2.Size = New System.Drawing.Size(107, 23)
        Me.ButtonDesRic2.TabIndex = 21
        Me.ButtonDesRic2.Text = "Crea Ric 2 righe"
        Me.ButtonDesRic2.UseVisualStyleBackColor = True
        '
        'ButtonDesStatoSE
        '
        Me.ButtonDesStatoSE.Location = New System.Drawing.Point(58, 19)
        Me.ButtonDesStatoSE.Name = "ButtonDesStatoSE"
        Me.ButtonDesStatoSE.Size = New System.Drawing.Size(42, 23)
        Me.ButtonDesStatoSE.TabIndex = 22
        Me.ButtonDesStatoSE.Text = "SE"
        Me.ButtonDesStatoSE.UseVisualStyleBackColor = True
        '
        'ButtonDesStatoInc
        '
        Me.ButtonDesStatoInc.Location = New System.Drawing.Point(107, 19)
        Me.ButtonDesStatoInc.Name = "ButtonDesStatoInc"
        Me.ButtonDesStatoInc.Size = New System.Drawing.Size(73, 23)
        Me.ButtonDesStatoInc.TabIndex = 23
        Me.ButtonDesStatoInc.Text = "OSU inc."
        Me.ButtonDesStatoInc.UseVisualStyleBackColor = True
        '
        'GroupBox1
        '
        Me.GroupBox1.Anchor = CType(((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Left) _
            Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.GroupBox1.Controls.Add(Me.ButtonRichiesta)
        Me.GroupBox1.Controls.Add(Me.ButtonDesRic)
        Me.GroupBox1.Controls.Add(Me.ButtonDesRic2)
        Me.GroupBox1.Location = New System.Drawing.Point(8, 396)
        Me.GroupBox1.Name = "GroupBox1"
        Me.GroupBox1.Size = New System.Drawing.Size(534, 59)
        Me.GroupBox1.TabIndex = 24
        Me.GroupBox1.TabStop = False
        Me.GroupBox1.Text = "Compone richiesta"
        '
        'GroupBox2
        '
        Me.GroupBox2.Anchor = CType(((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Left) _
            Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.GroupBox2.Controls.Add(Me.ButtonDesStato)
        Me.GroupBox2.Controls.Add(Me.ButtonStato)
        Me.GroupBox2.Controls.Add(Me.ButtonDesStatoInc)
        Me.GroupBox2.Controls.Add(Me.ButtonDesStatoAA)
        Me.GroupBox2.Controls.Add(Me.ButtonDesStatoSE)
        Me.GroupBox2.Location = New System.Drawing.Point(8, 461)
        Me.GroupBox2.Name = "GroupBox2"
        Me.GroupBox2.Size = New System.Drawing.Size(532, 55)
        Me.GroupBox2.TabIndex = 25
        Me.GroupBox2.TabStop = False
        Me.GroupBox2.Text = "Compone stato"
        '
        'TestService
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(6.0!, 13.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.ClientSize = New System.Drawing.Size(554, 521)
        Me.Controls.Add(Me.GroupBox2)
        Me.Controls.Add(Me.GroupBox1)
        Me.Controls.Add(Me.TextBoxIdRichiesta)
        Me.Controls.Add(Me.Label3)
        Me.Controls.Add(Me.Label2)
        Me.Controls.Add(Me.TextBoxUriOrdine)
        Me.Controls.Add(Me.ButtonOrdine)
        Me.Controls.Add(Me.LabelUrlStato)
        Me.Controls.Add(Me.TextBoxUriStato)
        Me.Controls.Add(Me.TextBoxIdOrderEntry)
        Me.Controls.Add(Me.Label1)
        Me.Controls.Add(Me.LabelUrlRichiesta)
        Me.Controls.Add(Me.TextBoxUriRichiesta)
        Me.Controls.Add(Me.TextBoxOutput)
        Me.Controls.Add(Me.TextBoxInput)
        Me.Name = "TestService"
        Me.Text = "Test WCF client OE.WCF.DataAccess (pipe)"
        Me.GroupBox1.ResumeLayout(False)
        Me.GroupBox2.ResumeLayout(False)
        Me.ResumeLayout(False)
        Me.PerformLayout()

    End Sub
    Friend WithEvents TextBoxInput As System.Windows.Forms.TextBox
    Friend WithEvents TextBoxOutput As System.Windows.Forms.TextBox
    Friend WithEvents ButtonRichiesta As System.Windows.Forms.Button
    Friend WithEvents ButtonStato As System.Windows.Forms.Button
    Friend WithEvents TextBoxUriRichiesta As System.Windows.Forms.TextBox
    Friend WithEvents ButtonDesRic As System.Windows.Forms.Button
    Friend WithEvents ButtonDesStato As System.Windows.Forms.Button
    Friend WithEvents LabelUrlRichiesta As System.Windows.Forms.Label
    Friend WithEvents Label1 As System.Windows.Forms.Label
    Friend WithEvents TextBoxIdOrderEntry As System.Windows.Forms.TextBox
    Friend WithEvents LabelUrlStato As System.Windows.Forms.Label
    Friend WithEvents TextBoxUriStato As System.Windows.Forms.TextBox
    Friend WithEvents ButtonOrdine As System.Windows.Forms.Button
    Friend WithEvents Label2 As System.Windows.Forms.Label
    Friend WithEvents TextBoxUriOrdine As System.Windows.Forms.TextBox
    Friend WithEvents ButtonDesStatoAA As Button
    Friend WithEvents TextBoxIdRichiesta As TextBox
    Friend WithEvents Label3 As Label
    Friend WithEvents ButtonDesRic2 As Button
    Friend WithEvents ButtonDesStatoSE As Button
    Friend WithEvents ButtonDesStatoInc As Button
    Friend WithEvents GroupBox1 As GroupBox
    Friend WithEvents GroupBox2 As GroupBox
End Class
