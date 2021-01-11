<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Class frmMain
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
		Me.components = New System.ComponentModel.Container()
		Dim resources As System.ComponentModel.ComponentResourceManager = New System.ComponentModel.ComponentResourceManager(GetType(frmMain))
		Me.ToolStrip1 = New System.Windows.Forms.ToolStrip()
		Me.butInvoca = New System.Windows.Forms.ToolStripButton()
		Me.butPulisci = New System.Windows.Forms.ToolStripButton()
		Me.lblSpacer = New System.Windows.Forms.ToolStripLabel()
		Me.ddlEndpoint = New System.Windows.Forms.ToolStripDropDownButton()
		Me.butConfigurazione = New System.Windows.Forms.ToolStripDropDownButton()
		Me.ImageList1 = New System.Windows.Forms.ImageList(Me.components)
		Me.SplitContainer1 = New System.Windows.Forms.SplitContainer()
		Me.Label4 = New System.Windows.Forms.Label()
		Me.txtRequest = New System.Windows.Forms.TextBox()
		Me.lstMetodi = New System.Windows.Forms.ListBox()
		Me.Label1 = New System.Windows.Forms.Label()
		Me.PropertyGridConfig = New System.Windows.Forms.PropertyGrid()
		Me.panWait = New System.Windows.Forms.Panel()
		Me.panWaitInner = New System.Windows.Forms.Panel()
		Me.txtResponse = New System.Windows.Forms.TextBox()
		Me.lblResponse = New System.Windows.Forms.Label()
		Me.ToolStrip1.SuspendLayout()
		Me.SplitContainer1.Panel1.SuspendLayout()
		Me.SplitContainer1.Panel2.SuspendLayout()
		Me.SplitContainer1.SuspendLayout()
		Me.panWait.SuspendLayout()
		Me.SuspendLayout()
		'
		'ToolStrip1
		'
		Me.ToolStrip1.AllowMerge = False
		Me.ToolStrip1.AutoSize = False
		Me.ToolStrip1.CanOverflow = False
		Me.ToolStrip1.Font = New System.Drawing.Font("Segoe UI", 9.75!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
		Me.ToolStrip1.Items.AddRange(New System.Windows.Forms.ToolStripItem() {Me.butInvoca, Me.butPulisci, Me.lblSpacer, Me.ddlEndpoint, Me.butConfigurazione})
		Me.ToolStrip1.Location = New System.Drawing.Point(0, 0)
		Me.ToolStrip1.Name = "ToolStrip1"
		Me.ToolStrip1.Padding = New System.Windows.Forms.Padding(0)
		Me.ToolStrip1.Size = New System.Drawing.Size(705, 48)
		Me.ToolStrip1.TabIndex = 3
		Me.ToolStrip1.Text = "ToolStrip1"
		'
		'butInvoca
		'
		Me.butInvoca.Image = CType(resources.GetObject("butInvoca.Image"), System.Drawing.Image)
		Me.butInvoca.ImageScaling = System.Windows.Forms.ToolStripItemImageScaling.None
		Me.butInvoca.ImageTransparentColor = System.Drawing.Color.Magenta
		Me.butInvoca.Name = "butInvoca"
		Me.butInvoca.Overflow = System.Windows.Forms.ToolStripItemOverflow.Never
		Me.butInvoca.Size = New System.Drawing.Size(81, 45)
		Me.butInvoca.Text = "Invoca"
		'
		'butPulisci
		'
		Me.butPulisci.Image = CType(resources.GetObject("butPulisci.Image"), System.Drawing.Image)
		Me.butPulisci.ImageScaling = System.Windows.Forms.ToolStripItemImageScaling.None
		Me.butPulisci.ImageTransparentColor = System.Drawing.Color.Magenta
		Me.butPulisci.Name = "butPulisci"
		Me.butPulisci.Overflow = System.Windows.Forms.ToolStripItemOverflow.Never
		Me.butPulisci.Size = New System.Drawing.Size(79, 45)
		Me.butPulisci.Text = "Pulisci"
		'
		'lblSpacer
		'
		Me.lblSpacer.AutoSize = False
		Me.lblSpacer.AutoToolTip = True
		Me.lblSpacer.Enabled = False
		Me.lblSpacer.Name = "lblSpacer"
		Me.lblSpacer.Overflow = System.Windows.Forms.ToolStripItemOverflow.Never
		Me.lblSpacer.Size = New System.Drawing.Size(300, 0)
		'
		'ddlEndpoint
		'
		Me.ddlEndpoint.Image = CType(resources.GetObject("ddlEndpoint.Image"), System.Drawing.Image)
		Me.ddlEndpoint.ImageScaling = System.Windows.Forms.ToolStripItemImageScaling.None
		Me.ddlEndpoint.ImageTransparentColor = System.Drawing.Color.Magenta
		Me.ddlEndpoint.Name = "ddlEndpoint"
		Me.ddlEndpoint.Overflow = System.Windows.Forms.ToolStripItemOverflow.Never
		Me.ddlEndpoint.Size = New System.Drawing.Size(105, 45)
		Me.ddlEndpoint.Text = "Endpoint"
		'
		'butConfigurazione
		'
		Me.butConfigurazione.Image = CType(resources.GetObject("butConfigurazione.Image"), System.Drawing.Image)
		Me.butConfigurazione.ImageScaling = System.Windows.Forms.ToolStripItemImageScaling.None
		Me.butConfigurazione.ImageTransparentColor = System.Drawing.Color.Magenta
		Me.butConfigurazione.Name = "butConfigurazione"
		Me.butConfigurazione.Overflow = System.Windows.Forms.ToolStripItemOverflow.Never
		Me.butConfigurazione.Size = New System.Drawing.Size(127, 45)
		Me.butConfigurazione.Text = "Impostazioni"
		'
		'ImageList1
		'
		Me.ImageList1.ColorDepth = System.Windows.Forms.ColorDepth.Depth8Bit
		Me.ImageList1.ImageSize = New System.Drawing.Size(16, 16)
		Me.ImageList1.TransparentColor = System.Drawing.Color.Transparent
		'
		'SplitContainer1
		'
		Me.SplitContainer1.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D
		Me.SplitContainer1.Dock = System.Windows.Forms.DockStyle.Fill
		Me.SplitContainer1.Location = New System.Drawing.Point(0, 48)
		Me.SplitContainer1.Name = "SplitContainer1"
		Me.SplitContainer1.Orientation = System.Windows.Forms.Orientation.Horizontal
		'
		'SplitContainer1.Panel1
		'
		Me.SplitContainer1.Panel1.Controls.Add(Me.Label4)
		Me.SplitContainer1.Panel1.Controls.Add(Me.txtRequest)
		Me.SplitContainer1.Panel1.Controls.Add(Me.lstMetodi)
		Me.SplitContainer1.Panel1.Controls.Add(Me.Label1)
		Me.SplitContainer1.Panel1.Controls.Add(Me.PropertyGridConfig)
		'
		'SplitContainer1.Panel2
		'
		Me.SplitContainer1.Panel2.Controls.Add(Me.panWait)
		Me.SplitContainer1.Panel2.Controls.Add(Me.txtResponse)
		Me.SplitContainer1.Panel2.Controls.Add(Me.lblResponse)
		Me.SplitContainer1.Size = New System.Drawing.Size(705, 604)
		Me.SplitContainer1.SplitterDistance = 270
		Me.SplitContainer1.SplitterIncrement = 5
		Me.SplitContainer1.SplitterWidth = 5
		Me.SplitContainer1.TabIndex = 12
		'
		'Label4
		'
		Me.Label4.AutoSize = True
		Me.Label4.Font = New System.Drawing.Font("Segoe UI", 10.0!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
		Me.Label4.Location = New System.Drawing.Point(191, 4)
		Me.Label4.Name = "Label4"
		Me.Label4.Size = New System.Drawing.Size(58, 19)
		Me.Label4.TabIndex = 12
		Me.Label4.Text = "Request"
		'
		'txtRequest
		'
		Me.txtRequest.Anchor = CType((((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Bottom) _
			Or System.Windows.Forms.AnchorStyles.Left) _
			Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
		Me.txtRequest.Font = New System.Drawing.Font("Segoe UI", 9.75!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
		Me.txtRequest.Location = New System.Drawing.Point(194, 24)
		Me.txtRequest.MaxLength = 10000000
		Me.txtRequest.Multiline = True
		Me.txtRequest.Name = "txtRequest"
		Me.txtRequest.ScrollBars = System.Windows.Forms.ScrollBars.Both
		Me.txtRequest.Size = New System.Drawing.Size(508, 241)
		Me.txtRequest.TabIndex = 11
		'
		'lstMetodi
		'
		Me.lstMetodi.Anchor = CType(((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Bottom) _
			Or System.Windows.Forms.AnchorStyles.Left), System.Windows.Forms.AnchorStyles)
		Me.lstMetodi.Font = New System.Drawing.Font("Segoe UI", 9.75!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
		Me.lstMetodi.FormattingEnabled = True
		Me.lstMetodi.IntegralHeight = False
		Me.lstMetodi.ItemHeight = 17
		Me.lstMetodi.Location = New System.Drawing.Point(0, 24)
		Me.lstMetodi.Name = "lstMetodi"
		Me.lstMetodi.Size = New System.Drawing.Size(188, 241)
		Me.lstMetodi.TabIndex = 9
		'
		'Label1
		'
		Me.Label1.AutoSize = True
		Me.Label1.Font = New System.Drawing.Font("Segoe UI", 10.0!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
		Me.Label1.Location = New System.Drawing.Point(1, 4)
		Me.Label1.Name = "Label1"
		Me.Label1.Size = New System.Drawing.Size(58, 19)
		Me.Label1.TabIndex = 10
		Me.Label1.Text = "Metodo"
		'
		'PropertyGridConfig
		'
		Me.PropertyGridConfig.CategoryForeColor = System.Drawing.SystemColors.InactiveCaptionText
		Me.PropertyGridConfig.CommandsVisibleIfAvailable = False
		Me.PropertyGridConfig.Font = New System.Drawing.Font("Segoe UI", 9.75!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
		Me.PropertyGridConfig.HelpVisible = False
		Me.PropertyGridConfig.Location = New System.Drawing.Point(320, 50)
		Me.PropertyGridConfig.Margin = New System.Windows.Forms.Padding(5)
		Me.PropertyGridConfig.Name = "PropertyGridConfig"
		Me.PropertyGridConfig.Size = New System.Drawing.Size(350, 185)
		Me.PropertyGridConfig.TabIndex = 0
		Me.PropertyGridConfig.ToolbarVisible = False
		Me.PropertyGridConfig.Visible = False
		'
		'panWait
		'
		Me.panWait.Anchor = System.Windows.Forms.AnchorStyles.None
		Me.panWait.BackColor = System.Drawing.Color.LightGreen
		Me.panWait.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch
		Me.panWait.Controls.Add(Me.panWaitInner)
		Me.panWait.ForeColor = System.Drawing.Color.White
		Me.panWait.Location = New System.Drawing.Point(287, 104)
		Me.panWait.Name = "panWait"
		Me.panWait.Size = New System.Drawing.Size(127, 117)
		Me.panWait.TabIndex = 14
		Me.panWait.Visible = False
		'
		'panWaitInner
		'
		Me.panWaitInner.Anchor = System.Windows.Forms.AnchorStyles.Top
		Me.panWaitInner.BackColor = System.Drawing.SystemColors.Window
		Me.panWaitInner.BackgroundImage = CType(resources.GetObject("panWaitInner.BackgroundImage"), System.Drawing.Image)
		Me.panWaitInner.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Center
		Me.panWaitInner.ForeColor = System.Drawing.Color.White
		Me.panWaitInner.Location = New System.Drawing.Point(5, 5)
		Me.panWaitInner.Name = "panWaitInner"
		Me.panWaitInner.Size = New System.Drawing.Size(117, 107)
		Me.panWaitInner.TabIndex = 11
		'
		'txtResponse
		'
		Me.txtResponse.Dock = System.Windows.Forms.DockStyle.Fill
		Me.txtResponse.Font = New System.Drawing.Font("Segoe UI", 9.75!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
		Me.txtResponse.Location = New System.Drawing.Point(0, 25)
		Me.txtResponse.Margin = New System.Windows.Forms.Padding(0)
		Me.txtResponse.MaxLength = 10000000
		Me.txtResponse.Multiline = True
		Me.txtResponse.Name = "txtResponse"
		Me.txtResponse.ReadOnly = True
		Me.txtResponse.ScrollBars = System.Windows.Forms.ScrollBars.Both
		Me.txtResponse.Size = New System.Drawing.Size(701, 300)
		Me.txtResponse.TabIndex = 13
		'
		'lblResponse
		'
		Me.lblResponse.AutoSize = True
		Me.lblResponse.Dock = System.Windows.Forms.DockStyle.Top
		Me.lblResponse.Font = New System.Drawing.Font("Segoe UI", 10.0!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
		Me.lblResponse.Location = New System.Drawing.Point(0, 0)
		Me.lblResponse.Name = "lblResponse"
		Me.lblResponse.Padding = New System.Windows.Forms.Padding(0, 3, 0, 3)
		Me.lblResponse.Size = New System.Drawing.Size(67, 25)
		Me.lblResponse.TabIndex = 12
		Me.lblResponse.Text = "Response"
		'
		'frmMain
		'
		Me.AutoScaleDimensions = New System.Drawing.SizeF(6.0!, 13.0!)
		Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
		Me.ClientSize = New System.Drawing.Size(705, 652)
		Me.Controls.Add(Me.SplitContainer1)
		Me.Controls.Add(Me.ToolStrip1)
		Me.MinimumSize = New System.Drawing.Size(500, 500)
		Me.Name = "frmMain"
		Me.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen
		Me.Text = "Tester per webservices WCF"
		Me.ToolStrip1.ResumeLayout(False)
		Me.ToolStrip1.PerformLayout()
		Me.SplitContainer1.Panel1.ResumeLayout(False)
		Me.SplitContainer1.Panel1.PerformLayout()
		Me.SplitContainer1.Panel2.ResumeLayout(False)
		Me.SplitContainer1.Panel2.PerformLayout()
		Me.SplitContainer1.ResumeLayout(False)
		Me.panWait.ResumeLayout(False)
		Me.ResumeLayout(False)

	End Sub
	Friend WithEvents ToolStrip1 As System.Windows.Forms.ToolStrip
	Friend WithEvents butInvoca As System.Windows.Forms.ToolStripButton
	Friend WithEvents ImageList1 As System.Windows.Forms.ImageList
	Friend WithEvents butPulisci As System.Windows.Forms.ToolStripButton
	Friend WithEvents SplitContainer1 As System.Windows.Forms.SplitContainer
	Friend WithEvents Label4 As System.Windows.Forms.Label
	Friend WithEvents txtRequest As System.Windows.Forms.TextBox
	Friend WithEvents Label1 As System.Windows.Forms.Label
	Friend WithEvents lstMetodi As System.Windows.Forms.ListBox
	Friend WithEvents panWait As System.Windows.Forms.Panel
	Friend WithEvents panWaitInner As System.Windows.Forms.Panel
	Friend WithEvents txtResponse As System.Windows.Forms.TextBox
	Friend WithEvents lblResponse As System.Windows.Forms.Label
	Friend WithEvents ddlEndpoint As System.Windows.Forms.ToolStripDropDownButton
	Friend WithEvents lblSpacer As System.Windows.Forms.ToolStripLabel
	Friend WithEvents PropertyGridConfig As System.Windows.Forms.PropertyGrid
	Friend WithEvents butConfigurazione As System.Windows.Forms.ToolStripDropDownButton

End Class
