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
        Me.ButtonDesRic = New System.Windows.Forms.Button()
        Me.ButtonDesStato = New System.Windows.Forms.Button()
        Me.Label1 = New System.Windows.Forms.Label()
        Me.TextBoxIdOrderEntry = New System.Windows.Forms.TextBox()
        Me.ButtonOrdine = New System.Windows.Forms.Button()
        Me.ComboBoxDesRic = New System.Windows.Forms.ComboBox()
        Me.LabelOperazione = New System.Windows.Forms.Label()
        Me.LabelStato = New System.Windows.Forms.Label()
        Me.ComboBoxDesStato = New System.Windows.Forms.ComboBox()
        Me.TextBoxIdRichiestaRichiedente = New System.Windows.Forms.TextBox()
        Me.Label2 = New System.Windows.Forms.Label()
        Me.TextBoxDataPrenotazione = New System.Windows.Forms.TextBox()
        Me.Label3 = New System.Windows.Forms.Label()
        Me.CheckBoxDataPianificata = New System.Windows.Forms.CheckBox()
        Me.CheckBoxIncrementale = New System.Windows.Forms.CheckBox()
        Me.SuspendLayout()
        '
        'TextBoxInput
        '
        Me.TextBoxInput.Anchor = CType(((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Left) _
            Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.TextBoxInput.Location = New System.Drawing.Point(8, 36)
        Me.TextBoxInput.Multiline = True
        Me.TextBoxInput.Name = "TextBoxInput"
        Me.TextBoxInput.ScrollBars = System.Windows.Forms.ScrollBars.Both
        Me.TextBoxInput.Size = New System.Drawing.Size(679, 213)
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
        Me.TextBoxOutput.Size = New System.Drawing.Size(679, 176)
        Me.TextBoxOutput.TabIndex = 1
        '
        'ButtonRichiesta
        '
        Me.ButtonRichiesta.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.ButtonRichiesta.Location = New System.Drawing.Point(564, 476)
        Me.ButtonRichiesta.Name = "ButtonRichiesta"
        Me.ButtonRichiesta.Size = New System.Drawing.Size(119, 23)
        Me.ButtonRichiesta.TabIndex = 2
        Me.ButtonRichiesta.Text = "Invia Richiesta"
        Me.ButtonRichiesta.UseVisualStyleBackColor = True
        '
        'ButtonStato
        '
        Me.ButtonStato.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.ButtonStato.Location = New System.Drawing.Point(564, 505)
        Me.ButtonStato.Name = "ButtonStato"
        Me.ButtonStato.Size = New System.Drawing.Size(119, 23)
        Me.ButtonStato.TabIndex = 3
        Me.ButtonStato.Text = "Invia Stato"
        Me.ButtonStato.UseVisualStyleBackColor = True
        '
        'ButtonDesRic
        '
        Me.ButtonDesRic.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Left), System.Windows.Forms.AnchorStyles)
        Me.ButtonDesRic.Location = New System.Drawing.Point(205, 476)
        Me.ButtonDesRic.Name = "ButtonDesRic"
        Me.ButtonDesRic.Size = New System.Drawing.Size(113, 23)
        Me.ButtonDesRic.TabIndex = 5
        Me.ButtonDesRic.Text = "Crea Richiesta"
        Me.ButtonDesRic.UseVisualStyleBackColor = True
        '
        'ButtonDesStato
        '
        Me.ButtonDesStato.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Left), System.Windows.Forms.AnchorStyles)
        Me.ButtonDesStato.Location = New System.Drawing.Point(205, 506)
        Me.ButtonDesStato.Name = "ButtonDesStato"
        Me.ButtonDesStato.Size = New System.Drawing.Size(113, 23)
        Me.ButtonDesStato.TabIndex = 6
        Me.ButtonDesStato.Text = "Crea Stato"
        Me.ButtonDesStato.UseVisualStyleBackColor = True
        '
        'Label1
        '
        Me.Label1.AutoSize = True
        Me.Label1.Location = New System.Drawing.Point(9, 259)
        Me.Label1.Name = "Label1"
        Me.Label1.Size = New System.Drawing.Size(66, 13)
        Me.Label1.TabIndex = 11
        Me.Label1.Text = "IdOrderEntry"
        '
        'TextBoxIdOrderEntry
        '
        Me.TextBoxIdOrderEntry.Location = New System.Drawing.Point(132, 256)
        Me.TextBoxIdOrderEntry.Name = "TextBoxIdOrderEntry"
        Me.TextBoxIdOrderEntry.Size = New System.Drawing.Size(168, 20)
        Me.TextBoxIdOrderEntry.TabIndex = 12
        '
        'ButtonOrdine
        '
        Me.ButtonOrdine.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.ButtonOrdine.Location = New System.Drawing.Point(564, 254)
        Me.ButtonOrdine.Name = "ButtonOrdine"
        Me.ButtonOrdine.Size = New System.Drawing.Size(123, 23)
        Me.ButtonOrdine.TabIndex = 13
        Me.ButtonOrdine.Text = "Leggi Ordine"
        Me.ButtonOrdine.UseVisualStyleBackColor = True
        '
        'ComboBoxDesRic
        '
        Me.ComboBoxDesRic.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Left), System.Windows.Forms.AnchorStyles)
        Me.ComboBoxDesRic.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList
        Me.ComboBoxDesRic.FormattingEnabled = True
        Me.ComboBoxDesRic.Items.AddRange(New Object() {"SR", "HD", "CA"})
        Me.ComboBoxDesRic.Location = New System.Drawing.Point(78, 478)
        Me.ComboBoxDesRic.Name = "ComboBoxDesRic"
        Me.ComboBoxDesRic.Size = New System.Drawing.Size(121, 21)
        Me.ComboBoxDesRic.TabIndex = 15
        '
        'LabelOperazione
        '
        Me.LabelOperazione.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Left), System.Windows.Forms.AnchorStyles)
        Me.LabelOperazione.AutoSize = True
        Me.LabelOperazione.Location = New System.Drawing.Point(11, 482)
        Me.LabelOperazione.Name = "LabelOperazione"
        Me.LabelOperazione.Size = New System.Drawing.Size(61, 13)
        Me.LabelOperazione.TabIndex = 16
        Me.LabelOperazione.Text = "Operazione"
        '
        'LabelStato
        '
        Me.LabelStato.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Left), System.Windows.Forms.AnchorStyles)
        Me.LabelStato.AutoSize = True
        Me.LabelStato.Location = New System.Drawing.Point(11, 511)
        Me.LabelStato.Name = "LabelStato"
        Me.LabelStato.Size = New System.Drawing.Size(32, 13)
        Me.LabelStato.TabIndex = 17
        Me.LabelStato.Text = "Stato"
        '
        'ComboBoxDesStato
        '
        Me.ComboBoxDesStato.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Left), System.Windows.Forms.AnchorStyles)
        Me.ComboBoxDesStato.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList
        Me.ComboBoxDesStato.FormattingEnabled = True
        Me.ComboBoxDesStato.Items.AddRange(New Object() {"RR AA", "RR AE", "RR AR", "RR SE", "OSU IC", "OSU IP", "OSU CM", "OSU CA"})
        Me.ComboBoxDesStato.Location = New System.Drawing.Point(78, 508)
        Me.ComboBoxDesStato.Name = "ComboBoxDesStato"
        Me.ComboBoxDesStato.Size = New System.Drawing.Size(121, 21)
        Me.ComboBoxDesStato.TabIndex = 18
        '
        'TextBoxIdRichiestaRichiedente
        '
        Me.TextBoxIdRichiestaRichiedente.Location = New System.Drawing.Point(132, 10)
        Me.TextBoxIdRichiestaRichiedente.Name = "TextBoxIdRichiestaRichiedente"
        Me.TextBoxIdRichiestaRichiedente.Size = New System.Drawing.Size(168, 20)
        Me.TextBoxIdRichiestaRichiedente.TabIndex = 20
        '
        'Label2
        '
        Me.Label2.AutoSize = True
        Me.Label2.Location = New System.Drawing.Point(9, 13)
        Me.Label2.Name = "Label2"
        Me.Label2.Size = New System.Drawing.Size(117, 13)
        Me.Label2.TabIndex = 19
        Me.Label2.Text = "IdRichiestaRichiedente"
        '
        'TextBoxDataPrenotazione
        '
        Me.TextBoxDataPrenotazione.Location = New System.Drawing.Point(457, 10)
        Me.TextBoxDataPrenotazione.Name = "TextBoxDataPrenotazione"
        Me.TextBoxDataPrenotazione.Size = New System.Drawing.Size(205, 20)
        Me.TextBoxDataPrenotazione.TabIndex = 22
        '
        'Label3
        '
        Me.Label3.AutoSize = True
        Me.Label3.Location = New System.Drawing.Point(359, 13)
        Me.Label3.Name = "Label3"
        Me.Label3.Size = New System.Drawing.Size(92, 13)
        Me.Label3.TabIndex = 21
        Me.Label3.Text = "DataPrenotazione"
        '
        'CheckBoxDataPianificata
        '
        Me.CheckBoxDataPianificata.AutoSize = True
        Me.CheckBoxDataPianificata.Location = New System.Drawing.Point(325, 510)
        Me.CheckBoxDataPianificata.Name = "CheckBoxDataPianificata"
        Me.CheckBoxDataPianificata.Size = New System.Drawing.Size(101, 17)
        Me.CheckBoxDataPianificata.TabIndex = 23
        Me.CheckBoxDataPianificata.Text = "Data Pianificata"
        Me.CheckBoxDataPianificata.UseVisualStyleBackColor = True
        '
        'CheckBoxIncrementale
        '
        Me.CheckBoxIncrementale.AutoSize = True
        Me.CheckBoxIncrementale.Location = New System.Drawing.Point(432, 510)
        Me.CheckBoxIncrementale.Name = "CheckBoxIncrementale"
        Me.CheckBoxIncrementale.Size = New System.Drawing.Size(87, 17)
        Me.CheckBoxIncrementale.TabIndex = 24
        Me.CheckBoxIncrementale.Text = "Incrementale"
        Me.CheckBoxIncrementale.UseVisualStyleBackColor = True
        '
        'TestService
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(6.0!, 13.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.ClientSize = New System.Drawing.Size(695, 541)
        Me.Controls.Add(Me.CheckBoxIncrementale)
        Me.Controls.Add(Me.CheckBoxDataPianificata)
        Me.Controls.Add(Me.TextBoxDataPrenotazione)
        Me.Controls.Add(Me.Label3)
        Me.Controls.Add(Me.TextBoxIdRichiestaRichiedente)
        Me.Controls.Add(Me.Label2)
        Me.Controls.Add(Me.ComboBoxDesStato)
        Me.Controls.Add(Me.LabelStato)
        Me.Controls.Add(Me.LabelOperazione)
        Me.Controls.Add(Me.ComboBoxDesRic)
        Me.Controls.Add(Me.ButtonOrdine)
        Me.Controls.Add(Me.TextBoxIdOrderEntry)
        Me.Controls.Add(Me.Label1)
        Me.Controls.Add(Me.ButtonDesStato)
        Me.Controls.Add(Me.ButtonDesRic)
        Me.Controls.Add(Me.ButtonStato)
        Me.Controls.Add(Me.ButtonRichiesta)
        Me.Controls.Add(Me.TextBoxOutput)
        Me.Controls.Add(Me.TextBoxInput)
        Me.Name = "TestService"
        Me.Text = "Test OE.Msg.DataAccess (usare il test ClientTestPipe anche in debug)"
        Me.ResumeLayout(False)
        Me.PerformLayout()

    End Sub
    Friend WithEvents TextBoxInput As System.Windows.Forms.TextBox
    Friend WithEvents TextBoxOutput As System.Windows.Forms.TextBox
    Friend WithEvents ButtonRichiesta As System.Windows.Forms.Button
    Friend WithEvents ButtonStato As System.Windows.Forms.Button
    Friend WithEvents ButtonDesRic As System.Windows.Forms.Button
    Friend WithEvents ButtonDesStato As System.Windows.Forms.Button
    Friend WithEvents Label1 As System.Windows.Forms.Label
    Friend WithEvents TextBoxIdOrderEntry As System.Windows.Forms.TextBox
    Friend WithEvents ButtonOrdine As System.Windows.Forms.Button
    Friend WithEvents ComboBoxDesRic As ComboBox
    Friend WithEvents LabelOperazione As Label
    Friend WithEvents LabelStato As Label
    Friend WithEvents ComboBoxDesStato As ComboBox
    Friend WithEvents TextBoxIdRichiestaRichiedente As TextBox
    Friend WithEvents Label2 As Label
    Friend WithEvents TextBoxDataPrenotazione As TextBox
    Friend WithEvents Label3 As Label
    Friend WithEvents CheckBoxDataPianificata As CheckBox
    Friend WithEvents CheckBoxIncrementale As CheckBox
End Class
