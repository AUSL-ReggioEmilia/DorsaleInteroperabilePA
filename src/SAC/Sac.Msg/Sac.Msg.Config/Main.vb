
Public Class Main
    Inherits System.Windows.Forms.Form

    Private moConfig As New DataAccess.Config

#Region " Windows Form Designer generated code "

    Public Sub New()
        MyBase.New()

        'This call is required by the Windows Form Designer.
        InitializeComponent()

        'Add any initialization after the InitializeComponent() call

    End Sub

    'Form overrides dispose to clean up the component list.
    Protected Overloads Overrides Sub Dispose(ByVal disposing As Boolean)
        If disposing Then
            If Not (components Is Nothing) Then
                components.Dispose()
            End If
        End If
        MyBase.Dispose(disposing)
    End Sub

    'Required by the Windows Form Designer
    Private components As System.ComponentModel.IContainer

    'NOTE: The following procedure is required by the Windows Form Designer
    'It can be modified using the Windows Form Designer.  
    'Do not modify it using the code editor.
    Friend WithEvents lblConnectionString As System.Windows.Forms.Label
    Friend WithEvents txtConnectionString As System.Windows.Forms.TextBox
    Friend WithEvents chkLogInformation As System.Windows.Forms.CheckBox
    Friend WithEvents chkLogWarning As System.Windows.Forms.CheckBox
    Friend WithEvents chkLogError As System.Windows.Forms.CheckBox
    Friend WithEvents txtLogSourceName As System.Windows.Forms.TextBox
    Friend WithEvents Label1 As System.Windows.Forms.Label
    Friend WithEvents cmdOK As System.Windows.Forms.Button
    Friend WithEvents cmdCancel As System.Windows.Forms.Button
    Friend WithEvents Label2 As System.Windows.Forms.Label
    Friend WithEvents lblSyncLevel As System.Windows.Forms.Label
    Friend WithEvents cmbIsolationLevel As System.Windows.Forms.ComboBox
    Friend WithEvents cmbSyncLevel As System.Windows.Forms.ComboBox
    Friend WithEvents numSyncTimOut As System.Windows.Forms.NumericUpDown
    Friend WithEvents Label3 As System.Windows.Forms.Label
    <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()
        Me.lblConnectionString = New System.Windows.Forms.Label
        Me.txtConnectionString = New System.Windows.Forms.TextBox
        Me.chkLogInformation = New System.Windows.Forms.CheckBox
        Me.chkLogWarning = New System.Windows.Forms.CheckBox
        Me.chkLogError = New System.Windows.Forms.CheckBox
        Me.txtLogSourceName = New System.Windows.Forms.TextBox
        Me.Label1 = New System.Windows.Forms.Label
        Me.cmdOK = New System.Windows.Forms.Button
        Me.cmdCancel = New System.Windows.Forms.Button
        Me.Label2 = New System.Windows.Forms.Label
        Me.lblSyncLevel = New System.Windows.Forms.Label
        Me.cmbIsolationLevel = New System.Windows.Forms.ComboBox
        Me.cmbSyncLevel = New System.Windows.Forms.ComboBox
        Me.numSyncTimOut = New System.Windows.Forms.NumericUpDown
        Me.Label3 = New System.Windows.Forms.Label
        CType(Me.numSyncTimOut, System.ComponentModel.ISupportInitialize).BeginInit()
        Me.SuspendLayout()
        '
        'lblConnectionString
        '
        Me.lblConnectionString.Location = New System.Drawing.Point(12, 20)
        Me.lblConnectionString.Name = "lblConnectionString"
        Me.lblConnectionString.Size = New System.Drawing.Size(96, 16)
        Me.lblConnectionString.TabIndex = 0
        Me.lblConnectionString.Text = "Connection String"
        '
        'txtConnectionString
        '
        Me.txtConnectionString.Location = New System.Drawing.Point(116, 16)
        Me.txtConnectionString.Name = "txtConnectionString"
        Me.txtConnectionString.Size = New System.Drawing.Size(336, 20)
        Me.txtConnectionString.TabIndex = 1
        '
        'chkLogInformation
        '
        Me.chkLogInformation.Location = New System.Drawing.Point(108, 168)
        Me.chkLogInformation.Name = "chkLogInformation"
        Me.chkLogInformation.Size = New System.Drawing.Size(104, 24)
        Me.chkLogInformation.TabIndex = 2
        Me.chkLogInformation.Text = "Log Information"
        '
        'chkLogWarning
        '
        Me.chkLogWarning.Location = New System.Drawing.Point(232, 168)
        Me.chkLogWarning.Name = "chkLogWarning"
        Me.chkLogWarning.Size = New System.Drawing.Size(104, 24)
        Me.chkLogWarning.TabIndex = 3
        Me.chkLogWarning.Text = "Log Warning"
        '
        'chkLogError
        '
        Me.chkLogError.Location = New System.Drawing.Point(348, 168)
        Me.chkLogError.Name = "chkLogError"
        Me.chkLogError.Size = New System.Drawing.Size(104, 24)
        Me.chkLogError.TabIndex = 4
        Me.chkLogError.Text = "Log Error"
        '
        'txtLogSourceName
        '
        Me.txtLogSourceName.Location = New System.Drawing.Point(116, 136)
        Me.txtLogSourceName.Name = "txtLogSourceName"
        Me.txtLogSourceName.Size = New System.Drawing.Size(336, 20)
        Me.txtLogSourceName.TabIndex = 6
        '
        'Label1
        '
        Me.Label1.Location = New System.Drawing.Point(12, 140)
        Me.Label1.Name = "Label1"
        Me.Label1.Size = New System.Drawing.Size(96, 16)
        Me.Label1.TabIndex = 5
        Me.Label1.Text = "Log Source name"
        '
        'cmdOK
        '
        Me.cmdOK.Location = New System.Drawing.Point(288, 216)
        Me.cmdOK.Name = "cmdOK"
        Me.cmdOK.Size = New System.Drawing.Size(76, 24)
        Me.cmdOK.TabIndex = 7
        Me.cmdOK.Text = "Conferma"
        '
        'cmdCancel
        '
        Me.cmdCancel.Location = New System.Drawing.Point(376, 216)
        Me.cmdCancel.Name = "cmdCancel"
        Me.cmdCancel.Size = New System.Drawing.Size(76, 24)
        Me.cmdCancel.TabIndex = 8
        Me.cmdCancel.Text = "Annulla"
        '
        'Label2
        '
        Me.Label2.Location = New System.Drawing.Point(12, 52)
        Me.Label2.Name = "Label2"
        Me.Label2.Size = New System.Drawing.Size(96, 16)
        Me.Label2.TabIndex = 9
        Me.Label2.Text = "Isolation Level"
        '
        'lblSyncLevel
        '
        Me.lblSyncLevel.Location = New System.Drawing.Point(12, 80)
        Me.lblSyncLevel.Name = "lblSyncLevel"
        Me.lblSyncLevel.Size = New System.Drawing.Size(96, 16)
        Me.lblSyncLevel.TabIndex = 11
        Me.lblSyncLevel.Text = "Sync Level"
        '
        'cmbIsolationLevel
        '
        Me.cmbIsolationLevel.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList
        Me.cmbIsolationLevel.Items.AddRange(New Object() {"Chaos", "ReadCommitted", "ReadUncommitted", "RepeatableRead", "Serializable"})
        Me.cmbIsolationLevel.Location = New System.Drawing.Point(116, 48)
        Me.cmbIsolationLevel.Name = "cmbIsolationLevel"
        Me.cmbIsolationLevel.Size = New System.Drawing.Size(204, 21)
        Me.cmbIsolationLevel.TabIndex = 12
        '
        'cmbSyncLevel
        '
        Me.cmbSyncLevel.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList
        Me.cmbSyncLevel.Items.AddRange(New Object() {"Servizio", "Record"})
        Me.cmbSyncLevel.Location = New System.Drawing.Point(116, 76)
        Me.cmbSyncLevel.Name = "cmbSyncLevel"
        Me.cmbSyncLevel.Size = New System.Drawing.Size(204, 21)
        Me.cmbSyncLevel.TabIndex = 13
        '
        'numSyncTimOut
        '
        Me.numSyncTimOut.Increment = New Decimal(New Integer() {10, 0, 0, 0})
        Me.numSyncTimOut.Location = New System.Drawing.Point(116, 108)
        Me.numSyncTimOut.Maximum = New Decimal(New Integer() {1000, 0, 0, 0})
        Me.numSyncTimOut.Minimum = New Decimal(New Integer() {10, 0, 0, 0})
        Me.numSyncTimOut.Name = "numSyncTimOut"
        Me.numSyncTimOut.Size = New System.Drawing.Size(92, 20)
        Me.numSyncTimOut.TabIndex = 14
        Me.numSyncTimOut.Value = New Decimal(New Integer() {10, 0, 0, 0})
        '
        'Label3
        '
        Me.Label3.Location = New System.Drawing.Point(12, 112)
        Me.Label3.Name = "Label3"
        Me.Label3.Size = New System.Drawing.Size(96, 16)
        Me.Label3.TabIndex = 15
        Me.Label3.Text = "Sync TimeOut"
        '
        'RegConfig
        '
        Me.AutoScaleBaseSize = New System.Drawing.Size(5, 13)
        Me.ClientSize = New System.Drawing.Size(472, 252)
        Me.Controls.Add(Me.Label3)
        Me.Controls.Add(Me.numSyncTimOut)
        Me.Controls.Add(Me.cmbSyncLevel)
        Me.Controls.Add(Me.cmbIsolationLevel)
        Me.Controls.Add(Me.lblSyncLevel)
        Me.Controls.Add(Me.Label2)
        Me.Controls.Add(Me.cmdCancel)
        Me.Controls.Add(Me.cmdOK)
        Me.Controls.Add(Me.txtLogSourceName)
        Me.Controls.Add(Me.Label1)
        Me.Controls.Add(Me.chkLogError)
        Me.Controls.Add(Me.chkLogWarning)
        Me.Controls.Add(Me.chkLogInformation)
        Me.Controls.Add(Me.txtConnectionString)
        Me.Controls.Add(Me.lblConnectionString)
        Me.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog
        Me.Name = "RegConfig"
        Me.Text = "SAC Config Msg"
        CType(Me.numSyncTimOut, System.ComponentModel.ISupportInitialize).EndInit()
        Me.ResumeLayout(False)
        Me.PerformLayout()

    End Sub

#End Region

    Private Sub RegConfig_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load

        Try
            '
            ' Legge configurazione
            '
            txtConnectionString.Text = moConfig.ConnectionString
            cmbIsolationLevel.Text = moConfig.DatabaseIsolationLevel
            cmbSyncLevel.Text = moConfig.ApplicationSyncLevel
            numSyncTimOut.Value = moConfig.ApplicationSyncTimeout \ 1000

            txtLogSourceName.Text = moConfig.LogSource
            chkLogInformation.Checked = moConfig.LogInformation
            chkLogWarning.Checked = moConfig.LogWarning
            chkLogError.Checked = moConfig.LogError

        Catch ex As Exception
            '
            ' Error
            '
            MsgBox(ex.Message, MsgBoxStyle.Exclamation)

        End Try

    End Sub

    Private Sub cmdOK_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdOK.Click

        Try
            '
            ' Salva configurazione
            '

            moConfig.ConnectionString = txtConnectionString.Text
            moConfig.DatabaseIsolationLevel = cmbIsolationLevel.Text
            moConfig.ApplicationSyncLevel = cmbSyncLevel.Text
            moConfig.ApplicationSyncTimeout = CType(numSyncTimOut.Value, Integer) * 1000

            moConfig.LogSource = txtLogSourceName.Text

            moConfig.LogInformation = chkLogInformation.Checked
            moConfig.LogWarning = chkLogWarning.Checked
            moConfig.LogError = chkLogError.Checked

            moConfig.Save()

            Me.Close()

        Catch ex As Exception
            '
            ' Error
            '
            MsgBox(ex.Message, MsgBoxStyle.Exclamation)

        End Try

    End Sub

    Private Sub cmdCancel_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdCancel.Click
        Me.Close()
    End Sub

End Class
