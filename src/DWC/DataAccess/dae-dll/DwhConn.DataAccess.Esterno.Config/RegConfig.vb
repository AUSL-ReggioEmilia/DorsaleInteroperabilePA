Imports DwhConn.DataAccess
Imports System.Reflection

Public Class RegConfig
    Inherits System.Windows.Forms.Form

    Private moConfig As New Esterno.RegConfig

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
    Friend WithEvents cmdOK As System.Windows.Forms.Button
    Friend WithEvents cmdCancel As System.Windows.Forms.Button
    Friend WithEvents lblIsolationLevel As System.Windows.Forms.Label
    Friend WithEvents lblSyncLevel As System.Windows.Forms.Label
    Friend WithEvents cmbIsolationLevel As System.Windows.Forms.ComboBox
    Friend WithEvents cmbSyncLevel As System.Windows.Forms.ComboBox
    Friend WithEvents numSyncTimOut As System.Windows.Forms.NumericUpDown
    Friend WithEvents txtConnectionSac As System.Windows.Forms.TextBox
    Friend WithEvents lblConnectionSAC As System.Windows.Forms.Label
    Friend WithEvents lblDllVersion As System.Windows.Forms.Label
    Friend WithEvents lblConnectionErrorNumRetry As System.Windows.Forms.Label
    Friend WithEvents txtConnectionErrorNumRetry As System.Windows.Forms.TextBox
    Friend WithEvents txtConnectionErrorDelayRetry As System.Windows.Forms.TextBox
    Friend WithEvents lblConnectionErrorDelayRetry As System.Windows.Forms.Label
    Friend WithEvents txtCommandTimeoutDelayRetry As System.Windows.Forms.TextBox
    Friend WithEvents lblCommandTimeoutDelayRetry As System.Windows.Forms.Label
    Friend WithEvents txtCommandTimeoutNumRetry As System.Windows.Forms.TextBox
    Friend WithEvents lblCommandTimeoutNumRetry As System.Windows.Forms.Label
    Friend WithEvents GroupBoxConnectionError As System.Windows.Forms.GroupBox
    Friend WithEvents GroupBoxCommandTimeout As System.Windows.Forms.GroupBox
    Friend WithEvents lblTranscodificaUoReferti As System.Windows.Forms.Label
    Friend WithEvents chkTranscodificaUoReferti As System.Windows.Forms.CheckBox
    Friend WithEvents GroupBoxLogSource As System.Windows.Forms.GroupBox
    Friend WithEvents lblLogSourceName As System.Windows.Forms.Label
    Friend WithEvents GroupBoxTranscodifiche As System.Windows.Forms.GroupBox
    Friend WithEvents GroupBoxDeadLock As System.Windows.Forms.GroupBox
    Friend WithEvents lblDeadLockDelayRetry As System.Windows.Forms.Label
    Friend WithEvents lblDeadLockNumRetry As System.Windows.Forms.Label
    Friend WithEvents txtDeadLockDelayRetry As System.Windows.Forms.TextBox
    Friend WithEvents txtDeadLockNumRetry As System.Windows.Forms.TextBox
    Friend WithEvents GroupBoxAllegati As System.Windows.Forms.GroupBox
    Friend WithEvents txtMaxTotalSizeAllegati As System.Windows.Forms.TextBox
    Friend WithEvents lblMaxTotalSizeAllegati As System.Windows.Forms.Label
    Friend WithEvents lblSyncTimeout As System.Windows.Forms.Label
    <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()
        Me.lblConnectionString = New System.Windows.Forms.Label()
        Me.txtConnectionString = New System.Windows.Forms.TextBox()
        Me.chkLogInformation = New System.Windows.Forms.CheckBox()
        Me.chkLogWarning = New System.Windows.Forms.CheckBox()
        Me.chkLogError = New System.Windows.Forms.CheckBox()
        Me.txtLogSourceName = New System.Windows.Forms.TextBox()
        Me.cmdOK = New System.Windows.Forms.Button()
        Me.cmdCancel = New System.Windows.Forms.Button()
        Me.lblIsolationLevel = New System.Windows.Forms.Label()
        Me.lblSyncLevel = New System.Windows.Forms.Label()
        Me.cmbIsolationLevel = New System.Windows.Forms.ComboBox()
        Me.cmbSyncLevel = New System.Windows.Forms.ComboBox()
        Me.numSyncTimOut = New System.Windows.Forms.NumericUpDown()
        Me.lblSyncTimeout = New System.Windows.Forms.Label()
        Me.txtConnectionSac = New System.Windows.Forms.TextBox()
        Me.lblConnectionSAC = New System.Windows.Forms.Label()
        Me.lblDllVersion = New System.Windows.Forms.Label()
        Me.lblConnectionErrorNumRetry = New System.Windows.Forms.Label()
        Me.txtConnectionErrorNumRetry = New System.Windows.Forms.TextBox()
        Me.txtConnectionErrorDelayRetry = New System.Windows.Forms.TextBox()
        Me.lblConnectionErrorDelayRetry = New System.Windows.Forms.Label()
        Me.txtCommandTimeoutDelayRetry = New System.Windows.Forms.TextBox()
        Me.lblCommandTimeoutDelayRetry = New System.Windows.Forms.Label()
        Me.txtCommandTimeoutNumRetry = New System.Windows.Forms.TextBox()
        Me.lblCommandTimeoutNumRetry = New System.Windows.Forms.Label()
        Me.GroupBoxConnectionError = New System.Windows.Forms.GroupBox()
        Me.GroupBoxCommandTimeout = New System.Windows.Forms.GroupBox()
        Me.lblTranscodificaUoReferti = New System.Windows.Forms.Label()
        Me.chkTranscodificaUoReferti = New System.Windows.Forms.CheckBox()
        Me.GroupBoxLogSource = New System.Windows.Forms.GroupBox()
        Me.lblLogSourceName = New System.Windows.Forms.Label()
        Me.GroupBoxTranscodifiche = New System.Windows.Forms.GroupBox()
        Me.GroupBoxDeadLock = New System.Windows.Forms.GroupBox()
        Me.lblDeadLockDelayRetry = New System.Windows.Forms.Label()
        Me.lblDeadLockNumRetry = New System.Windows.Forms.Label()
        Me.txtDeadLockDelayRetry = New System.Windows.Forms.TextBox()
        Me.txtDeadLockNumRetry = New System.Windows.Forms.TextBox()
        Me.GroupBoxAllegati = New System.Windows.Forms.GroupBox()
        Me.txtMaxTotalSizeAllegati = New System.Windows.Forms.TextBox()
        Me.lblMaxTotalSizeAllegati = New System.Windows.Forms.Label()
        CType(Me.numSyncTimOut, System.ComponentModel.ISupportInitialize).BeginInit()
        Me.GroupBoxConnectionError.SuspendLayout()
        Me.GroupBoxCommandTimeout.SuspendLayout()
        Me.GroupBoxLogSource.SuspendLayout()
        Me.GroupBoxTranscodifiche.SuspendLayout()
        Me.GroupBoxDeadLock.SuspendLayout()
        Me.GroupBoxAllegati.SuspendLayout()
        Me.SuspendLayout()
        '
        'lblConnectionString
        '
        Me.lblConnectionString.Location = New System.Drawing.Point(12, 20)
        Me.lblConnectionString.Name = "lblConnectionString"
        Me.lblConnectionString.Size = New System.Drawing.Size(96, 16)
        Me.lblConnectionString.TabIndex = 0
        Me.lblConnectionString.Text = "Connection Unito"
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
        Me.chkLogInformation.Location = New System.Drawing.Point(95, 43)
        Me.chkLogInformation.Name = "chkLogInformation"
        Me.chkLogInformation.Size = New System.Drawing.Size(104, 24)
        Me.chkLogInformation.TabIndex = 2
        Me.chkLogInformation.Text = "Log Information"
        '
        'chkLogWarning
        '
        Me.chkLogWarning.Location = New System.Drawing.Point(211, 43)
        Me.chkLogWarning.Name = "chkLogWarning"
        Me.chkLogWarning.Size = New System.Drawing.Size(104, 24)
        Me.chkLogWarning.TabIndex = 3
        Me.chkLogWarning.Text = "Log Warning"
        '
        'chkLogError
        '
        Me.chkLogError.Location = New System.Drawing.Point(327, 43)
        Me.chkLogError.Name = "chkLogError"
        Me.chkLogError.Size = New System.Drawing.Size(104, 24)
        Me.chkLogError.TabIndex = 4
        Me.chkLogError.Text = "Log Error"
        '
        'txtLogSourceName
        '
        Me.txtLogSourceName.Location = New System.Drawing.Point(95, 17)
        Me.txtLogSourceName.Name = "txtLogSourceName"
        Me.txtLogSourceName.Size = New System.Drawing.Size(336, 20)
        Me.txtLogSourceName.TabIndex = 6
        '
        'cmdOK
        '
        Me.cmdOK.Location = New System.Drawing.Point(288, 465)
        Me.cmdOK.Name = "cmdOK"
        Me.cmdOK.Size = New System.Drawing.Size(76, 24)
        Me.cmdOK.TabIndex = 7
        Me.cmdOK.Text = "Conferma"
        '
        'cmdCancel
        '
        Me.cmdCancel.Location = New System.Drawing.Point(376, 465)
        Me.cmdCancel.Name = "cmdCancel"
        Me.cmdCancel.Size = New System.Drawing.Size(76, 24)
        Me.cmdCancel.TabIndex = 8
        Me.cmdCancel.Text = "Annulla"
        '
        'lblIsolationLevel
        '
        Me.lblIsolationLevel.Location = New System.Drawing.Point(12, 72)
        Me.lblIsolationLevel.Name = "lblIsolationLevel"
        Me.lblIsolationLevel.Size = New System.Drawing.Size(96, 16)
        Me.lblIsolationLevel.TabIndex = 9
        Me.lblIsolationLevel.Text = "Isolation Level"
        '
        'lblSyncLevel
        '
        Me.lblSyncLevel.Location = New System.Drawing.Point(12, 98)
        Me.lblSyncLevel.Name = "lblSyncLevel"
        Me.lblSyncLevel.Size = New System.Drawing.Size(96, 16)
        Me.lblSyncLevel.TabIndex = 11
        Me.lblSyncLevel.Text = "Sync Level"
        '
        'cmbIsolationLevel
        '
        Me.cmbIsolationLevel.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList
        Me.cmbIsolationLevel.Items.AddRange(New Object() {"Chaos", "ReadCommitted", "ReadUncommitted", "RepeatableRead", "Serializable"})
        Me.cmbIsolationLevel.Location = New System.Drawing.Point(116, 68)
        Me.cmbIsolationLevel.Name = "cmbIsolationLevel"
        Me.cmbIsolationLevel.Size = New System.Drawing.Size(204, 21)
        Me.cmbIsolationLevel.TabIndex = 12
        '
        'cmbSyncLevel
        '
        Me.cmbSyncLevel.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList
        Me.cmbSyncLevel.Items.AddRange(New Object() {"Tipo", "Sistema", "IdEsterno"})
        Me.cmbSyncLevel.Location = New System.Drawing.Point(116, 94)
        Me.cmbSyncLevel.Name = "cmbSyncLevel"
        Me.cmbSyncLevel.Size = New System.Drawing.Size(204, 21)
        Me.cmbSyncLevel.TabIndex = 13
        '
        'numSyncTimOut
        '
        Me.numSyncTimOut.Increment = New Decimal(New Integer() {10, 0, 0, 0})
        Me.numSyncTimOut.Location = New System.Drawing.Point(116, 122)
        Me.numSyncTimOut.Maximum = New Decimal(New Integer() {1000, 0, 0, 0})
        Me.numSyncTimOut.Minimum = New Decimal(New Integer() {10, 0, 0, 0})
        Me.numSyncTimOut.Name = "numSyncTimOut"
        Me.numSyncTimOut.Size = New System.Drawing.Size(92, 20)
        Me.numSyncTimOut.TabIndex = 14
        Me.numSyncTimOut.Value = New Decimal(New Integer() {10, 0, 0, 0})
        '
        'lblSyncTimeout
        '
        Me.lblSyncTimeout.Location = New System.Drawing.Point(12, 126)
        Me.lblSyncTimeout.Name = "lblSyncTimeout"
        Me.lblSyncTimeout.Size = New System.Drawing.Size(96, 16)
        Me.lblSyncTimeout.TabIndex = 15
        Me.lblSyncTimeout.Text = "Sync TimeOut"
        '
        'txtConnectionSac
        '
        Me.txtConnectionSac.Location = New System.Drawing.Point(116, 42)
        Me.txtConnectionSac.Name = "txtConnectionSac"
        Me.txtConnectionSac.Size = New System.Drawing.Size(336, 20)
        Me.txtConnectionSac.TabIndex = 17
        '
        'lblConnectionSAC
        '
        Me.lblConnectionSAC.Location = New System.Drawing.Point(12, 46)
        Me.lblConnectionSAC.Name = "lblConnectionSAC"
        Me.lblConnectionSAC.Size = New System.Drawing.Size(96, 16)
        Me.lblConnectionSAC.TabIndex = 16
        Me.lblConnectionSAC.Text = "Connection SAC"
        '
        'lblDllVersion
        '
        Me.lblDllVersion.AutoSize = True
        Me.lblDllVersion.Location = New System.Drawing.Point(15, 471)
        Me.lblDllVersion.Name = "lblDllVersion"
        Me.lblDllVersion.Size = New System.Drawing.Size(71, 13)
        Me.lblDllVersion.TabIndex = 20
        Me.lblDllVersion.Text = "Versione DLL"
        '
        'lblConnectionErrorNumRetry
        '
        Me.lblConnectionErrorNumRetry.AutoSize = True
        Me.lblConnectionErrorNumRetry.Location = New System.Drawing.Point(6, 23)
        Me.lblConnectionErrorNumRetry.Name = "lblConnectionErrorNumRetry"
        Me.lblConnectionErrorNumRetry.Size = New System.Drawing.Size(52, 13)
        Me.lblConnectionErrorNumRetry.TabIndex = 22
        Me.lblConnectionErrorNumRetry.Text = "Num retry"
        '
        'txtConnectionErrorNumRetry
        '
        Me.txtConnectionErrorNumRetry.Location = New System.Drawing.Point(95, 19)
        Me.txtConnectionErrorNumRetry.Name = "txtConnectionErrorNumRetry"
        Me.txtConnectionErrorNumRetry.Size = New System.Drawing.Size(73, 20)
        Me.txtConnectionErrorNumRetry.TabIndex = 23
        '
        'txtConnectionErrorDelayRetry
        '
        Me.txtConnectionErrorDelayRetry.Location = New System.Drawing.Point(258, 19)
        Me.txtConnectionErrorDelayRetry.Name = "txtConnectionErrorDelayRetry"
        Me.txtConnectionErrorDelayRetry.Size = New System.Drawing.Size(73, 20)
        Me.txtConnectionErrorDelayRetry.TabIndex = 25
        '
        'lblConnectionErrorDelayRetry
        '
        Me.lblConnectionErrorDelayRetry.AutoSize = True
        Me.lblConnectionErrorDelayRetry.Location = New System.Drawing.Point(169, 23)
        Me.lblConnectionErrorDelayRetry.Name = "lblConnectionErrorDelayRetry"
        Me.lblConnectionErrorDelayRetry.Size = New System.Drawing.Size(83, 13)
        Me.lblConnectionErrorDelayRetry.TabIndex = 24
        Me.lblConnectionErrorDelayRetry.Text = "Delay retry (sec)"
        '
        'txtCommandTimeoutDelayRetry
        '
        Me.txtCommandTimeoutDelayRetry.Location = New System.Drawing.Point(258, 21)
        Me.txtCommandTimeoutDelayRetry.Name = "txtCommandTimeoutDelayRetry"
        Me.txtCommandTimeoutDelayRetry.Size = New System.Drawing.Size(73, 20)
        Me.txtCommandTimeoutDelayRetry.TabIndex = 30
        '
        'lblCommandTimeoutDelayRetry
        '
        Me.lblCommandTimeoutDelayRetry.AutoSize = True
        Me.lblCommandTimeoutDelayRetry.Location = New System.Drawing.Point(169, 25)
        Me.lblCommandTimeoutDelayRetry.Name = "lblCommandTimeoutDelayRetry"
        Me.lblCommandTimeoutDelayRetry.Size = New System.Drawing.Size(83, 13)
        Me.lblCommandTimeoutDelayRetry.TabIndex = 29
        Me.lblCommandTimeoutDelayRetry.Text = "Delay retry (sec)"
        '
        'txtCommandTimeoutNumRetry
        '
        Me.txtCommandTimeoutNumRetry.Location = New System.Drawing.Point(95, 21)
        Me.txtCommandTimeoutNumRetry.Name = "txtCommandTimeoutNumRetry"
        Me.txtCommandTimeoutNumRetry.Size = New System.Drawing.Size(73, 20)
        Me.txtCommandTimeoutNumRetry.TabIndex = 28
        '
        'lblCommandTimeoutNumRetry
        '
        Me.lblCommandTimeoutNumRetry.AutoSize = True
        Me.lblCommandTimeoutNumRetry.Location = New System.Drawing.Point(6, 25)
        Me.lblCommandTimeoutNumRetry.Name = "lblCommandTimeoutNumRetry"
        Me.lblCommandTimeoutNumRetry.Size = New System.Drawing.Size(52, 13)
        Me.lblCommandTimeoutNumRetry.TabIndex = 27
        Me.lblCommandTimeoutNumRetry.Text = "Num retry"
        '
        'GroupBoxConnectionError
        '
        Me.GroupBoxConnectionError.Controls.Add(Me.txtConnectionErrorDelayRetry)
        Me.GroupBoxConnectionError.Controls.Add(Me.lblConnectionErrorNumRetry)
        Me.GroupBoxConnectionError.Controls.Add(Me.txtConnectionErrorNumRetry)
        Me.GroupBoxConnectionError.Controls.Add(Me.lblConnectionErrorDelayRetry)
        Me.GroupBoxConnectionError.Location = New System.Drawing.Point(15, 229)
        Me.GroupBoxConnectionError.Name = "GroupBoxConnectionError"
        Me.GroupBoxConnectionError.Size = New System.Drawing.Size(437, 50)
        Me.GroupBoxConnectionError.TabIndex = 31
        Me.GroupBoxConnectionError.TabStop = False
        Me.GroupBoxConnectionError.Text = "Connection error"
        '
        'GroupBoxCommandTimeout
        '
        Me.GroupBoxCommandTimeout.Controls.Add(Me.lblCommandTimeoutDelayRetry)
        Me.GroupBoxCommandTimeout.Controls.Add(Me.lblCommandTimeoutNumRetry)
        Me.GroupBoxCommandTimeout.Controls.Add(Me.txtCommandTimeoutDelayRetry)
        Me.GroupBoxCommandTimeout.Controls.Add(Me.txtCommandTimeoutNumRetry)
        Me.GroupBoxCommandTimeout.Location = New System.Drawing.Point(15, 285)
        Me.GroupBoxCommandTimeout.Name = "GroupBoxCommandTimeout"
        Me.GroupBoxCommandTimeout.Size = New System.Drawing.Size(437, 50)
        Me.GroupBoxCommandTimeout.TabIndex = 32
        Me.GroupBoxCommandTimeout.TabStop = False
        Me.GroupBoxCommandTimeout.Text = "Command Timeout"
        '
        'lblTranscodificaUoReferti
        '
        Me.lblTranscodificaUoReferti.Location = New System.Drawing.Point(8, 22)
        Me.lblTranscodificaUoReferti.Name = "lblTranscodificaUoReferti"
        Me.lblTranscodificaUoReferti.Size = New System.Drawing.Size(126, 16)
        Me.lblTranscodificaUoReferti.TabIndex = 33
        Me.lblTranscodificaUoReferti.Text = "Unita Operative Referti"
        '
        'chkTranscodificaUoReferti
        '
        Me.chkTranscodificaUoReferti.Checked = True
        Me.chkTranscodificaUoReferti.CheckState = System.Windows.Forms.CheckState.Checked
        Me.chkTranscodificaUoReferti.Location = New System.Drawing.Point(138, 17)
        Me.chkTranscodificaUoReferti.Name = "chkTranscodificaUoReferti"
        Me.chkTranscodificaUoReferti.Size = New System.Drawing.Size(32, 24)
        Me.chkTranscodificaUoReferti.TabIndex = 34
        '
        'GroupBoxLogSource
        '
        Me.GroupBoxLogSource.Controls.Add(Me.lblLogSourceName)
        Me.GroupBoxLogSource.Controls.Add(Me.txtLogSourceName)
        Me.GroupBoxLogSource.Controls.Add(Me.chkLogError)
        Me.GroupBoxLogSource.Controls.Add(Me.chkLogInformation)
        Me.GroupBoxLogSource.Controls.Add(Me.chkLogWarning)
        Me.GroupBoxLogSource.Location = New System.Drawing.Point(15, 150)
        Me.GroupBoxLogSource.Name = "GroupBoxLogSource"
        Me.GroupBoxLogSource.Size = New System.Drawing.Size(437, 72)
        Me.GroupBoxLogSource.TabIndex = 35
        Me.GroupBoxLogSource.TabStop = False
        Me.GroupBoxLogSource.Text = "Log Source"
        '
        'lblLogSourceName
        '
        Me.lblLogSourceName.AutoSize = True
        Me.lblLogSourceName.Location = New System.Drawing.Point(6, 20)
        Me.lblLogSourceName.Name = "lblLogSourceName"
        Me.lblLogSourceName.Size = New System.Drawing.Size(35, 13)
        Me.lblLogSourceName.TabIndex = 0
        Me.lblLogSourceName.Text = "Name"
        '
        'GroupBoxTranscodifiche
        '
        Me.GroupBoxTranscodifiche.Controls.Add(Me.lblTranscodificaUoReferti)
        Me.GroupBoxTranscodifiche.Controls.Add(Me.chkTranscodificaUoReferti)
        Me.GroupBoxTranscodifiche.Location = New System.Drawing.Point(13, 400)
        Me.GroupBoxTranscodifiche.Name = "GroupBoxTranscodifiche"
        Me.GroupBoxTranscodifiche.Size = New System.Drawing.Size(213, 50)
        Me.GroupBoxTranscodifiche.TabIndex = 36
        Me.GroupBoxTranscodifiche.TabStop = False
        Me.GroupBoxTranscodifiche.Text = "Transcodifiche"
        '
        'GroupBoxDeadLock
        '
        Me.GroupBoxDeadLock.Controls.Add(Me.lblDeadLockDelayRetry)
        Me.GroupBoxDeadLock.Controls.Add(Me.lblDeadLockNumRetry)
        Me.GroupBoxDeadLock.Controls.Add(Me.txtDeadLockDelayRetry)
        Me.GroupBoxDeadLock.Controls.Add(Me.txtDeadLockNumRetry)
        Me.GroupBoxDeadLock.Location = New System.Drawing.Point(15, 340)
        Me.GroupBoxDeadLock.Name = "GroupBoxDeadLock"
        Me.GroupBoxDeadLock.Size = New System.Drawing.Size(437, 50)
        Me.GroupBoxDeadLock.TabIndex = 37
        Me.GroupBoxDeadLock.TabStop = False
        Me.GroupBoxDeadLock.Text = "Dead Lock"
        '
        'lblDeadLockDelayRetry
        '
        Me.lblDeadLockDelayRetry.AutoSize = True
        Me.lblDeadLockDelayRetry.Location = New System.Drawing.Point(169, 25)
        Me.lblDeadLockDelayRetry.Name = "lblDeadLockDelayRetry"
        Me.lblDeadLockDelayRetry.Size = New System.Drawing.Size(83, 13)
        Me.lblDeadLockDelayRetry.TabIndex = 29
        Me.lblDeadLockDelayRetry.Text = "Delay retry (sec)"
        '
        'lblDeadLockNumRetry
        '
        Me.lblDeadLockNumRetry.AutoSize = True
        Me.lblDeadLockNumRetry.Location = New System.Drawing.Point(6, 25)
        Me.lblDeadLockNumRetry.Name = "lblDeadLockNumRetry"
        Me.lblDeadLockNumRetry.Size = New System.Drawing.Size(52, 13)
        Me.lblDeadLockNumRetry.TabIndex = 27
        Me.lblDeadLockNumRetry.Text = "Num retry"
        '
        'txtDeadLockDelayRetry
        '
        Me.txtDeadLockDelayRetry.Location = New System.Drawing.Point(258, 21)
        Me.txtDeadLockDelayRetry.Name = "txtDeadLockDelayRetry"
        Me.txtDeadLockDelayRetry.Size = New System.Drawing.Size(73, 20)
        Me.txtDeadLockDelayRetry.TabIndex = 30
        '
        'txtDeadLockNumRetry
        '
        Me.txtDeadLockNumRetry.Location = New System.Drawing.Point(95, 21)
        Me.txtDeadLockNumRetry.Name = "txtDeadLockNumRetry"
        Me.txtDeadLockNumRetry.Size = New System.Drawing.Size(73, 20)
        Me.txtDeadLockNumRetry.TabIndex = 28
        '
        'GroupBoxAllegati
        '
        Me.GroupBoxAllegati.Controls.Add(Me.txtMaxTotalSizeAllegati)
        Me.GroupBoxAllegati.Controls.Add(Me.lblMaxTotalSizeAllegati)
        Me.GroupBoxAllegati.Location = New System.Drawing.Point(232, 400)
        Me.GroupBoxAllegati.Name = "GroupBoxAllegati"
        Me.GroupBoxAllegati.Size = New System.Drawing.Size(220, 49)
        Me.GroupBoxAllegati.TabIndex = 38
        Me.GroupBoxAllegati.TabStop = False
        Me.GroupBoxAllegati.Text = "Allegati"
        '
        'txtMaxTotalSizeAllegati
        '
        Me.txtMaxTotalSizeAllegati.Location = New System.Drawing.Point(164, 19)
        Me.txtMaxTotalSizeAllegati.Name = "txtMaxTotalSizeAllegati"
        Me.txtMaxTotalSizeAllegati.Size = New System.Drawing.Size(47, 20)
        Me.txtMaxTotalSizeAllegati.TabIndex = 35
        '
        'lblMaxTotalSizeAllegati
        '
        Me.lblMaxTotalSizeAllegati.Location = New System.Drawing.Point(6, 22)
        Me.lblMaxTotalSizeAllegati.Name = "lblMaxTotalSizeAllegati"
        Me.lblMaxTotalSizeAllegati.Size = New System.Drawing.Size(152, 16)
        Me.lblMaxTotalSizeAllegati.TabIndex = 34
        Me.lblMaxTotalSizeAllegati.Text = "Max Total Size Allegati (Mb)"
        '
        'RegConfig
        '
        Me.AutoScaleBaseSize = New System.Drawing.Size(5, 13)
        Me.ClientSize = New System.Drawing.Size(472, 496)
        Me.Controls.Add(Me.GroupBoxAllegati)
        Me.Controls.Add(Me.GroupBoxDeadLock)
        Me.Controls.Add(Me.GroupBoxTranscodifiche)
        Me.Controls.Add(Me.GroupBoxLogSource)
        Me.Controls.Add(Me.GroupBoxCommandTimeout)
        Me.Controls.Add(Me.GroupBoxConnectionError)
        Me.Controls.Add(Me.lblDllVersion)
        Me.Controls.Add(Me.txtConnectionSac)
        Me.Controls.Add(Me.lblConnectionSAC)
        Me.Controls.Add(Me.lblSyncTimeout)
        Me.Controls.Add(Me.numSyncTimOut)
        Me.Controls.Add(Me.cmbSyncLevel)
        Me.Controls.Add(Me.cmbIsolationLevel)
        Me.Controls.Add(Me.lblSyncLevel)
        Me.Controls.Add(Me.lblIsolationLevel)
        Me.Controls.Add(Me.cmdCancel)
        Me.Controls.Add(Me.cmdOK)
        Me.Controls.Add(Me.txtConnectionString)
        Me.Controls.Add(Me.lblConnectionString)
        Me.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog
        Me.MaximizeBox = False
        Me.Name = "RegConfig"
        Me.Text = "Config DwhClinico DataAccess Esterno"
        CType(Me.numSyncTimOut, System.ComponentModel.ISupportInitialize).EndInit()
        Me.GroupBoxConnectionError.ResumeLayout(False)
        Me.GroupBoxConnectionError.PerformLayout()
        Me.GroupBoxCommandTimeout.ResumeLayout(False)
        Me.GroupBoxCommandTimeout.PerformLayout()
        Me.GroupBoxLogSource.ResumeLayout(False)
        Me.GroupBoxLogSource.PerformLayout()
        Me.GroupBoxTranscodifiche.ResumeLayout(False)
        Me.GroupBoxDeadLock.ResumeLayout(False)
        Me.GroupBoxDeadLock.PerformLayout()
        Me.GroupBoxAllegati.ResumeLayout(False)
        Me.GroupBoxAllegati.PerformLayout()
        Me.ResumeLayout(False)
        Me.PerformLayout()

    End Sub

#End Region

    Private Sub RegConfig_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load

        Try
            '
            ' Legge versione
            '
            Try
                Dim oTypeConnV2 As Type = GetType(Esterno.ConnectorV2)
                Dim oAssConnV2 As Assembly = oTypeConnV2.Assembly

                Dim oAssVers() As Object = oAssConnV2.GetCustomAttributes(GetType(AssemblyFileVersionAttribute), True)
                Dim oAssVerInfo As AssemblyFileVersionAttribute = CType(oAssVers(0), AssemblyFileVersionAttribute)

                lblDllVersion.Text = String.Format("Ver DLL:{0}, da GAC={1}", _
                                                   oAssVerInfo.Version, _
                                                   oAssConnV2.GlobalAssemblyCache)
            Catch ex As Exception
                lblDllVersion.Text = "Error"
            End Try
            '
            ' Legge configurazione
            '
            txtConnectionString.Text = moConfig.ConnectionString
            txtConnectionSac.Text = moConfig.ConnectionStringSac

            cmbIsolationLevel.Text = moConfig.DatabaseIsolationLevel
            cmbSyncLevel.Text = moConfig.ApplicationSyncLevel
            numSyncTimOut.Value = moConfig.ApplicationSyncTimeout \ 1000

            txtLogSourceName.Text = moConfig.LogSource
            chkLogInformation.Checked = moConfig.LogInformation
            chkLogWarning.Checked = moConfig.LogWarning
            chkLogError.Checked = moConfig.LogError
            '
            ' Modifica Ettore per gestione timeout 2012-07-30
            '
            txtConnectionErrorNumRetry.Text = moConfig.ConnectionErrorNumRetry.ToString()
            txtConnectionErrorDelayRetry.Text = moConfig.ConnectionErrorDelayRetry.ToString()
            txtCommandTimeoutNumRetry.Text = moConfig.CommandTimeoutNumRetry.ToString()
            txtCommandTimeoutDelayRetry.Text = moConfig.CommandTimeoutDelayRetry.ToString()
            '
            ' Modifica Ettore 2015-02-20: gestione retry per dead lock
            '
            txtDeadLockNumRetry.Text = moConfig.DeadLockNumRetry.ToString()
            txtDeadLockDelayRetry.Text = moConfig.DeadLockDelayRetry.ToString()
            '
            ' Modifica Ettore 2014-09-15: gestione transcodifica Unità Operative
            '
            chkTranscodificaUoReferti.Checked = moConfig.TranscodificaUoReferti
            '
            ' MODIFICA ETTORE 2018-02-20: Gestione massima dimensione di tutti gli allegati
            '
            txtMaxTotalSizeAllegati.Text = moConfig.MaxTotalSizeAllegatiRefertoMb.ToString


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
            moConfig.ConnectionStringSac = txtConnectionSac.Text

            moConfig.DatabaseIsolationLevel = cmbIsolationLevel.Text
            moConfig.ApplicationSyncLevel = cmbSyncLevel.Text
            moConfig.ApplicationSyncTimeout = CType(numSyncTimOut.Value, Integer) * 1000

            moConfig.LogSource = txtLogSourceName.Text

            moConfig.LogInformation = chkLogInformation.Checked
            moConfig.LogWarning = chkLogWarning.Checked
            moConfig.LogError = chkLogError.Checked
            '
            ' Modifica Ettore per gestione timeout 2012-07-30
            '
            Dim iTempValue As Integer
            iTempValue = CType(txtConnectionErrorNumRetry.Text, Integer)
            If iTempValue < 0 Then
                Throw New Exception(String.Format("{0}: '{1}' deve essere un valore intero maggiore o uguale a zero!", GroupBoxConnectionError.Text, lblConnectionErrorNumRetry.Text))
            Else
                moConfig.ConnectionErrorNumRetry = iTempValue
            End If

            iTempValue = CType(txtConnectionErrorDelayRetry.Text, Integer)
            If iTempValue <= 0 Then
                Throw New Exception(String.Format("{0}: '{1}' deve essere un valore intero maggiore di zero!", GroupBoxConnectionError.Text, lblConnectionErrorDelayRetry.Text))
            Else
                moConfig.ConnectionErrorDelayRetry = iTempValue
            End If

            iTempValue = CType(txtCommandTimeoutNumRetry.Text, Integer)
            If iTempValue < 0 Then
                Throw New Exception(String.Format("{0}: '{1}' deve essere un valore intero maggiore o uguale a zero!", GroupBoxCommandTimeout.Text, lblCommandTimeoutNumRetry.Text))
            Else
                moConfig.CommandTimeoutNumRetry = iTempValue
            End If

            iTempValue = CType(txtCommandTimeoutDelayRetry.Text, Integer)
            If iTempValue <= 0 Then
                Throw New Exception(String.Format("{0}: '{1}' deve essere un valore intero maggiore di zero!", GroupBoxCommandTimeout.Text, lblCommandTimeoutDelayRetry.Text))
            Else
                moConfig.CommandTimeoutDelayRetry = iTempValue
            End If

            '
            ' Modifica Ettore 2015-02-20: gestione retry per dead lock
            '
            iTempValue = CType(txtDeadLockNumRetry.Text, Integer)
            If iTempValue < 0 Then
                Throw New Exception(String.Format("{0}: '{1}' deve essere un valore intero maggiore o uguale a zero!", GroupBoxDeadLock.Text, lblDeadLockNumRetry.Text))
            Else
                moConfig.DeadLockNumRetry = iTempValue
            End If

            iTempValue = CType(txtDeadLockDelayRetry.Text, Integer)
            If iTempValue <= 0 Then
                Throw New Exception(String.Format("{0}: '{1}' deve essere un valore intero maggiore di zero!", GroupBoxDeadLock.Text, lblDeadLockDelayRetry.Text))
            Else
                moConfig.DeadLockDelayRetry = iTempValue
            End If

            '
            ' Modifica Ettore 2014-09-15: gestione transcodifiche Unità Operative
            '
            moConfig.TranscodificaUoReferti = chkTranscodificaUoReferti.Checked

            '
            ' MODIFICA ETTORE 2018-02-20: Gestione massima dimensione di tutti gli allegati
            '
            iTempValue = CType(txtMaxTotalSizeAllegati.Text, Integer)
            If iTempValue < 0 Then
                Throw New Exception(String.Format("{0}: '{1}' deve essere un valore intero maggiore o uguale a zero!", GroupBoxAllegati.Text, lblMaxTotalSizeAllegati.Text))
            Else
                moConfig.MaxTotalSizeAllegatiRefertoMb = iTempValue
            End If


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
