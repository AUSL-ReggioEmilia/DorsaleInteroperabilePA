<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Class Form1
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
        Me.TextBoxResult = New System.Windows.Forms.TextBox()
        Me.TextBoxXml = New System.Windows.Forms.TextBox()
        Me.ButtonSend = New System.Windows.Forms.Button()
        Me.SuspendLayout()
        '
        'TextBoxResult
        '
        Me.TextBoxResult.Anchor = CType(((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Left) _
            Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.TextBoxResult.Location = New System.Drawing.Point(12, 248)
        Me.TextBoxResult.Name = "TextBoxResult"
        Me.TextBoxResult.ReadOnly = True
        Me.TextBoxResult.Size = New System.Drawing.Size(353, 20)
        Me.TextBoxResult.TabIndex = 9
        '
        'TextBoxXml
        '
        Me.TextBoxXml.Anchor = CType((((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Bottom) _
            Or System.Windows.Forms.AnchorStyles.Left) _
            Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.TextBoxXml.Location = New System.Drawing.Point(12, 12)
        Me.TextBoxXml.Multiline = True
        Me.TextBoxXml.Name = "TextBoxXml"
        Me.TextBoxXml.ScrollBars = System.Windows.Forms.ScrollBars.Both
        Me.TextBoxXml.Size = New System.Drawing.Size(434, 230)
        Me.TextBoxXml.TabIndex = 8
        '
        'ButtonSend
        '
        Me.ButtonSend.Anchor = CType((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.ButtonSend.Location = New System.Drawing.Point(371, 248)
        Me.ButtonSend.Name = "ButtonSend"
        Me.ButtonSend.Size = New System.Drawing.Size(75, 23)
        Me.ButtonSend.TabIndex = 7
        Me.ButtonSend.Text = "Send"
        Me.ButtonSend.UseVisualStyleBackColor = True
        '
        'Form1
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(6.0!, 13.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.ClientSize = New System.Drawing.Size(458, 283)
        Me.Controls.Add(Me.TextBoxResult)
        Me.Controls.Add(Me.TextBoxXml)
        Me.Controls.Add(Me.ButtonSend)
        Me.Name = "Form1"
        Me.Text = "Send Stato"
        Me.ResumeLayout(False)
        Me.PerformLayout()

    End Sub
    Friend WithEvents TextBoxResult As System.Windows.Forms.TextBox
    Friend WithEvents TextBoxXml As System.Windows.Forms.TextBox
    Friend WithEvents ButtonSend As System.Windows.Forms.Button

End Class
