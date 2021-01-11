Imports System.Configuration.ConfigurationSettings
Imports System.Net
Imports System.Reflection
Imports DwhConn.DataAccess.Esterno

Public Class frmMain
    Inherits System.Windows.Forms.Form

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
    Friend WithEvents lvTrace As System.Windows.Forms.ListView
    Friend WithEvents chTraceTimeInit As System.Windows.Forms.ColumnHeader
    Friend WithEvents chTraceTimeExec As System.Windows.Forms.ColumnHeader
    Friend WithEvents chTraceDescrizione As System.Windows.Forms.ColumnHeader
    Friend WithEvents OpenFileDialogJpg As System.Windows.Forms.OpenFileDialog
    Friend WithEvents tabPazienti As System.Windows.Forms.TabPage
    Friend WithEvents Label2 As System.Windows.Forms.Label
    Friend WithEvents txtPazientiIdEsterno As System.Windows.Forms.TextBox
    Friend WithEvents tabsTest As System.Windows.Forms.TabControl
    Friend WithEvents lblPazientiNomeAnagrafica As System.Windows.Forms.Label
    Friend WithEvents txtPazientiNomeAnagrafica As System.Windows.Forms.TextBox
    Friend WithEvents lblPazientiCodiceAnagrafica As System.Windows.Forms.Label
    Friend WithEvents txtPazientiCodiceAnagrafica As System.Windows.Forms.TextBox
    Friend WithEvents tabEpisodio As System.Windows.Forms.TabPage
    Friend WithEvents Label17 As System.Windows.Forms.Label
    Friend WithEvents Label18 As System.Windows.Forms.Label
    Friend WithEvents Label19 As System.Windows.Forms.Label
    Friend WithEvents Label20 As System.Windows.Forms.Label
    Friend WithEvents Label21 As System.Windows.Forms.Label
    Friend WithEvents cboTipoPostEpisodio As System.Windows.Forms.ComboBox
    Friend WithEvents txtEpisodioNomeAnagrafica As System.Windows.Forms.TextBox
    Friend WithEvents txtEpisodioCodiceAnagrafica As System.Windows.Forms.TextBox
    Friend WithEvents txtEpisodioIdEsternoReferto As System.Windows.Forms.TextBox
    Friend WithEvents txtEpisodioIdEsternoPaziente As System.Windows.Forms.TextBox
    Friend WithEvents cmdAddConsenso As System.Windows.Forms.Button
    Friend WithEvents cmdLibAddEpisodio As System.Windows.Forms.Button
    Friend WithEvents Label3 As System.Windows.Forms.Label
    Friend WithEvents txtEpisodioDataSeq As System.Windows.Forms.TextBox
    Friend WithEvents cmdAddAnagrafica As System.Windows.Forms.Button
    Friend WithEvents Label1 As System.Windows.Forms.Label
    Friend WithEvents txtPazientiDataSeqAnagrafica As System.Windows.Forms.TextBox
    Friend WithEvents Label4 As System.Windows.Forms.Label
    Friend WithEvents Label5 As System.Windows.Forms.Label
    Friend WithEvents txtAziendaErogante As System.Windows.Forms.TextBox
    Friend WithEvents lblDllVersion As System.Windows.Forms.Label
    Friend WithEvents tabRicovero As System.Windows.Forms.TabPage
    Friend WithEvents Label6 As System.Windows.Forms.Label
    Friend WithEvents txtEventoRicoveroDataSeq As System.Windows.Forms.TextBox
    Friend WithEvents Label7 As System.Windows.Forms.Label
    Friend WithEvents cboTipoPostEventoRicovero As System.Windows.Forms.ComboBox
    Friend WithEvents Label8 As System.Windows.Forms.Label
    Friend WithEvents txtEventoRicoveroNomeAnagrafica As System.Windows.Forms.TextBox
    Friend WithEvents Label9 As System.Windows.Forms.Label
    Friend WithEvents txtEventoRicoveroCodiceAnagrafica As System.Windows.Forms.TextBox
    Friend WithEvents txtEventoRicoveroIdEsternoEvento As System.Windows.Forms.TextBox
    Friend WithEvents Label10 As System.Windows.Forms.Label
    Friend WithEvents Label11 As System.Windows.Forms.Label
    Friend WithEvents txtEventoRicoveroIdEsternoPaziente As System.Windows.Forms.TextBox
    Friend WithEvents cmdLibAddEventoRicovero As System.Windows.Forms.Button
    Friend WithEvents cboEventoRicoveroTipoEvento As System.Windows.Forms.ComboBox
    Friend WithEvents txtEventoRicoveroNosologico As System.Windows.Forms.TextBox
    Friend WithEvents Label12 As System.Windows.Forms.Label
    Friend WithEvents cmdEpisodioSerializza As System.Windows.Forms.Button
    Friend WithEvents Label22 As System.Windows.Forms.Label
    Friend WithEvents txtEventoRicoveroDataEvento As System.Windows.Forms.TextBox
    Friend WithEvents cmdEventoSerializza As System.Windows.Forms.Button
    Friend WithEvents Label13 As System.Windows.Forms.Label
    Friend WithEvents txtIdEsternoEventoUtilizzato As System.Windows.Forms.TextBox
    Friend WithEvents gbEpisodio As System.Windows.Forms.GroupBox
    Friend WithEvents lblEpisodioDataSquenza As System.Windows.Forms.Label
    Friend WithEvents lblRicoveriDataSequenzaFormato As System.Windows.Forms.Label
    Friend WithEvents gbRicovero As System.Windows.Forms.GroupBox
    Friend WithEvents gbPazienti As System.Windows.Forms.GroupBox
    Friend WithEvents Label14 As System.Windows.Forms.Label
    Friend WithEvents lblRicoveriDataEventoFormato As System.Windows.Forms.Label
    Friend WithEvents Label23 As System.Windows.Forms.Label
    Friend WithEvents ToolTipManager As System.Windows.Forms.ToolTip
    Friend WithEvents txtPazientiCognome As System.Windows.Forms.TextBox
    Friend WithEvents lblPazientiCognome As System.Windows.Forms.Label
    Friend WithEvents txtPazientiNome As System.Windows.Forms.TextBox
    Friend WithEvents lblPazientiNome As System.Windows.Forms.Label
    Friend WithEvents txtPazientiDataNascita As System.Windows.Forms.TextBox
    Friend WithEvents lblPazientiDataNascita As System.Windows.Forms.Label
    Friend WithEvents cmbPazientiSesso As System.Windows.Forms.ComboBox
    Friend WithEvents Label25 As System.Windows.Forms.Label
    Friend WithEvents Label29 As System.Windows.Forms.Label
    Friend WithEvents txtPazientiCodiceFiscale As System.Windows.Forms.TextBox
    Friend WithEvents lblPazientiCodiceFiscale As System.Windows.Forms.Label
    Friend WithEvents txtPazientiLuogoNascita As System.Windows.Forms.TextBox
    Friend WithEvents lblPazientiLuogonascita As System.Windows.Forms.Label
    Friend WithEvents gpPazientiDatiFusione As System.Windows.Forms.GroupBox
    Friend WithEvents txtPazientiFusioneCodiceAnagrafica As System.Windows.Forms.TextBox
    Friend WithEvents Label24 As System.Windows.Forms.Label
    Friend WithEvents Label26 As System.Windows.Forms.Label
    Friend WithEvents txtPazientiFusioneNomeAnagrafica As System.Windows.Forms.TextBox
    Friend WithEvents StatusStripMain As System.Windows.Forms.StatusStrip
    Friend WithEvents ToolStripConnectionInfo As System.Windows.Forms.ToolStripStatusLabel
    Friend WithEvents Label16 As System.Windows.Forms.Label
    Friend WithEvents Label15 As System.Windows.Forms.Label
    Friend WithEvents txtEpisodioDataReferto As System.Windows.Forms.TextBox
    Friend WithEvents ToolStripIdentityInfo As System.Windows.Forms.ToolStripStatusLabel
    Friend WithEvents tabEpisodio_XML As System.Windows.Forms.TabPage
    Friend WithEvents cmdEpisodio_XML_Esegui As System.Windows.Forms.Button
    Friend WithEvents txtEpisodio_XML_Xml As System.Windows.Forms.TextBox
    Friend WithEvents Label27 As System.Windows.Forms.Label
    Friend WithEvents cboTipoPostEpisodio_XML As System.Windows.Forms.ComboBox
    Friend WithEvents Label28 As System.Windows.Forms.Label
    Friend WithEvents Label30 As System.Windows.Forms.Label
    Friend WithEvents txtEpisodio_XML_DataSequenza As System.Windows.Forms.TextBox
    Friend WithEvents Label31 As System.Windows.Forms.Label
    Friend WithEvents tabRicovero_XML As System.Windows.Forms.TabPage
    Friend WithEvents Label33 As System.Windows.Forms.Label
    Friend WithEvents cboTipoPostEventoRicovero2 As System.Windows.Forms.ComboBox
    Friend WithEvents Label35 As System.Windows.Forms.Label
    Friend WithEvents Label36 As System.Windows.Forms.Label
    Friend WithEvents txtEventoRicovero2DataSeq As System.Windows.Forms.TextBox
    Friend WithEvents Label34 As System.Windows.Forms.Label
    Friend WithEvents txtEventoRicovero2Xml As System.Windows.Forms.TextBox
    Friend WithEvents cmdRicovero2Esegui As System.Windows.Forms.Button
    Friend WithEvents tabPazienti_XML As System.Windows.Forms.TabPage
    Friend WithEvents Label32 As System.Windows.Forms.Label
    Friend WithEvents Label37 As System.Windows.Forms.Label
    Friend WithEvents Label38 As System.Windows.Forms.Label
    Friend WithEvents txtPazientiDataSeqAnagrafica2 As System.Windows.Forms.TextBox
    Friend WithEvents Label39 As System.Windows.Forms.Label
    Friend WithEvents cmdEseguiAnagrafica2 As System.Windows.Forms.Button
    Friend WithEvents txtAnagrafica2Xml As System.Windows.Forms.TextBox
    Friend WithEvents cboTipoPostAnagrafica2 As System.Windows.Forms.ComboBox
    Friend WithEvents tabProveDiCarico As System.Windows.Forms.TabPage
    Friend WithEvents txtProveCaricoNumMaxReferti As System.Windows.Forms.TextBox
    Friend WithEvents Label40 As System.Windows.Forms.Label
    Friend WithEvents cmdProveCaricoRefertiEsegui As System.Windows.Forms.Button
    Friend WithEvents txtProveCaricoTemplateReferto As System.Windows.Forms.TextBox
    Friend WithEvents Label41 As System.Windows.Forms.Label
    Friend WithEvents OpenFileDialog1 As System.Windows.Forms.OpenFileDialog
    Friend WithEvents cmdProveCaricoSelectRefertoTemplate As System.Windows.Forms.Button
    Friend WithEvents txtErroriProvaDiCaricoReferti As System.Windows.Forms.TextBox
    Friend WithEvents txtProveCaricorefertiThreadrandomDelayMax As System.Windows.Forms.TextBox
    Friend WithEvents Label42 As System.Windows.Forms.Label
    Friend WithEvents txtEpisodio_XML_IdEsternoPrecedente As System.Windows.Forms.TextBox
    Friend WithEvents Label43 As System.Windows.Forms.Label
    Friend WithEvents chkEpisodio_XML_UsaMetodoEpisodio2 As System.Windows.Forms.CheckBox
    Friend WithEvents cboTipoPostAnagrafica As System.Windows.Forms.ComboBox
    <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()
        Me.components = New System.ComponentModel.Container()
        Me.lvTrace = New System.Windows.Forms.ListView()
        Me.chTraceTimeInit = CType(New System.Windows.Forms.ColumnHeader(), System.Windows.Forms.ColumnHeader)
        Me.chTraceTimeExec = CType(New System.Windows.Forms.ColumnHeader(), System.Windows.Forms.ColumnHeader)
        Me.chTraceDescrizione = CType(New System.Windows.Forms.ColumnHeader(), System.Windows.Forms.ColumnHeader)
        Me.OpenFileDialogJpg = New System.Windows.Forms.OpenFileDialog()
        Me.tabsTest = New System.Windows.Forms.TabControl()
        Me.tabPazienti = New System.Windows.Forms.TabPage()
        Me.Label29 = New System.Windows.Forms.Label()
        Me.txtPazientiCodiceFiscale = New System.Windows.Forms.TextBox()
        Me.lblPazientiCodiceFiscale = New System.Windows.Forms.Label()
        Me.txtPazientiLuogoNascita = New System.Windows.Forms.TextBox()
        Me.lblPazientiLuogonascita = New System.Windows.Forms.Label()
        Me.txtPazientiDataNascita = New System.Windows.Forms.TextBox()
        Me.lblPazientiDataNascita = New System.Windows.Forms.Label()
        Me.cmbPazientiSesso = New System.Windows.Forms.ComboBox()
        Me.Label25 = New System.Windows.Forms.Label()
        Me.txtPazientiNome = New System.Windows.Forms.TextBox()
        Me.lblPazientiNome = New System.Windows.Forms.Label()
        Me.txtPazientiCognome = New System.Windows.Forms.TextBox()
        Me.lblPazientiCognome = New System.Windows.Forms.Label()
        Me.gbPazienti = New System.Windows.Forms.GroupBox()
        Me.cmdAddConsenso = New System.Windows.Forms.Button()
        Me.Label14 = New System.Windows.Forms.Label()
        Me.cmdAddAnagrafica = New System.Windows.Forms.Button()
        Me.Label1 = New System.Windows.Forms.Label()
        Me.txtPazientiDataSeqAnagrafica = New System.Windows.Forms.TextBox()
        Me.Label4 = New System.Windows.Forms.Label()
        Me.cboTipoPostAnagrafica = New System.Windows.Forms.ComboBox()
        Me.lblPazientiNomeAnagrafica = New System.Windows.Forms.Label()
        Me.txtPazientiNomeAnagrafica = New System.Windows.Forms.TextBox()
        Me.lblPazientiCodiceAnagrafica = New System.Windows.Forms.Label()
        Me.txtPazientiCodiceAnagrafica = New System.Windows.Forms.TextBox()
        Me.txtPazientiIdEsterno = New System.Windows.Forms.TextBox()
        Me.Label2 = New System.Windows.Forms.Label()
        Me.gpPazientiDatiFusione = New System.Windows.Forms.GroupBox()
        Me.txtPazientiFusioneCodiceAnagrafica = New System.Windows.Forms.TextBox()
        Me.Label24 = New System.Windows.Forms.Label()
        Me.Label26 = New System.Windows.Forms.Label()
        Me.txtPazientiFusioneNomeAnagrafica = New System.Windows.Forms.TextBox()
        Me.tabPazienti_XML = New System.Windows.Forms.TabPage()
        Me.Label32 = New System.Windows.Forms.Label()
        Me.Label37 = New System.Windows.Forms.Label()
        Me.Label38 = New System.Windows.Forms.Label()
        Me.txtPazientiDataSeqAnagrafica2 = New System.Windows.Forms.TextBox()
        Me.Label39 = New System.Windows.Forms.Label()
        Me.cboTipoPostAnagrafica2 = New System.Windows.Forms.ComboBox()
        Me.cmdEseguiAnagrafica2 = New System.Windows.Forms.Button()
        Me.txtAnagrafica2Xml = New System.Windows.Forms.TextBox()
        Me.tabEpisodio = New System.Windows.Forms.TabPage()
        Me.Label16 = New System.Windows.Forms.Label()
        Me.Label15 = New System.Windows.Forms.Label()
        Me.txtEpisodioDataReferto = New System.Windows.Forms.TextBox()
        Me.lblEpisodioDataSquenza = New System.Windows.Forms.Label()
        Me.gbEpisodio = New System.Windows.Forms.GroupBox()
        Me.cmdEpisodioSerializza = New System.Windows.Forms.Button()
        Me.Label3 = New System.Windows.Forms.Label()
        Me.txtEpisodioDataSeq = New System.Windows.Forms.TextBox()
        Me.cmdLibAddEpisodio = New System.Windows.Forms.Button()
        Me.Label21 = New System.Windows.Forms.Label()
        Me.cboTipoPostEpisodio = New System.Windows.Forms.ComboBox()
        Me.Label17 = New System.Windows.Forms.Label()
        Me.txtEpisodioNomeAnagrafica = New System.Windows.Forms.TextBox()
        Me.Label18 = New System.Windows.Forms.Label()
        Me.txtEpisodioCodiceAnagrafica = New System.Windows.Forms.TextBox()
        Me.txtEpisodioIdEsternoReferto = New System.Windows.Forms.TextBox()
        Me.Label19 = New System.Windows.Forms.Label()
        Me.Label20 = New System.Windows.Forms.Label()
        Me.txtEpisodioIdEsternoPaziente = New System.Windows.Forms.TextBox()
        Me.tabRicovero = New System.Windows.Forms.TabPage()
        Me.Label23 = New System.Windows.Forms.Label()
        Me.lblRicoveriDataEventoFormato = New System.Windows.Forms.Label()
        Me.lblRicoveriDataSequenzaFormato = New System.Windows.Forms.Label()
        Me.gbRicovero = New System.Windows.Forms.GroupBox()
        Me.cmdEventoSerializza = New System.Windows.Forms.Button()
        Me.txtIdEsternoEventoUtilizzato = New System.Windows.Forms.TextBox()
        Me.Label13 = New System.Windows.Forms.Label()
        Me.Label22 = New System.Windows.Forms.Label()
        Me.txtEventoRicoveroDataEvento = New System.Windows.Forms.TextBox()
        Me.txtEventoRicoveroNosologico = New System.Windows.Forms.TextBox()
        Me.Label12 = New System.Windows.Forms.Label()
        Me.cboEventoRicoveroTipoEvento = New System.Windows.Forms.ComboBox()
        Me.cmdLibAddEventoRicovero = New System.Windows.Forms.Button()
        Me.Label6 = New System.Windows.Forms.Label()
        Me.txtEventoRicoveroDataSeq = New System.Windows.Forms.TextBox()
        Me.Label7 = New System.Windows.Forms.Label()
        Me.cboTipoPostEventoRicovero = New System.Windows.Forms.ComboBox()
        Me.Label8 = New System.Windows.Forms.Label()
        Me.txtEventoRicoveroNomeAnagrafica = New System.Windows.Forms.TextBox()
        Me.Label9 = New System.Windows.Forms.Label()
        Me.txtEventoRicoveroCodiceAnagrafica = New System.Windows.Forms.TextBox()
        Me.txtEventoRicoveroIdEsternoEvento = New System.Windows.Forms.TextBox()
        Me.Label10 = New System.Windows.Forms.Label()
        Me.Label11 = New System.Windows.Forms.Label()
        Me.txtEventoRicoveroIdEsternoPaziente = New System.Windows.Forms.TextBox()
        Me.tabEpisodio_XML = New System.Windows.Forms.TabPage()
        Me.txtEpisodio_XML_IdEsternoPrecedente = New System.Windows.Forms.TextBox()
        Me.Label43 = New System.Windows.Forms.Label()
        Me.chkEpisodio_XML_UsaMetodoEpisodio2 = New System.Windows.Forms.CheckBox()
        Me.Label31 = New System.Windows.Forms.Label()
        Me.Label28 = New System.Windows.Forms.Label()
        Me.Label30 = New System.Windows.Forms.Label()
        Me.txtEpisodio_XML_DataSequenza = New System.Windows.Forms.TextBox()
        Me.Label27 = New System.Windows.Forms.Label()
        Me.cboTipoPostEpisodio_XML = New System.Windows.Forms.ComboBox()
        Me.cmdEpisodio_XML_Esegui = New System.Windows.Forms.Button()
        Me.txtEpisodio_XML_Xml = New System.Windows.Forms.TextBox()
        Me.tabRicovero_XML = New System.Windows.Forms.TabPage()
        Me.cmdRicovero2Esegui = New System.Windows.Forms.Button()
        Me.Label35 = New System.Windows.Forms.Label()
        Me.Label36 = New System.Windows.Forms.Label()
        Me.txtEventoRicovero2DataSeq = New System.Windows.Forms.TextBox()
        Me.Label34 = New System.Windows.Forms.Label()
        Me.txtEventoRicovero2Xml = New System.Windows.Forms.TextBox()
        Me.Label33 = New System.Windows.Forms.Label()
        Me.cboTipoPostEventoRicovero2 = New System.Windows.Forms.ComboBox()
        Me.tabProveDiCarico = New System.Windows.Forms.TabPage()
        Me.txtProveCaricorefertiThreadrandomDelayMax = New System.Windows.Forms.TextBox()
        Me.Label42 = New System.Windows.Forms.Label()
        Me.txtErroriProvaDiCaricoReferti = New System.Windows.Forms.TextBox()
        Me.cmdProveCaricoSelectRefertoTemplate = New System.Windows.Forms.Button()
        Me.txtProveCaricoTemplateReferto = New System.Windows.Forms.TextBox()
        Me.Label41 = New System.Windows.Forms.Label()
        Me.cmdProveCaricoRefertiEsegui = New System.Windows.Forms.Button()
        Me.txtProveCaricoNumMaxReferti = New System.Windows.Forms.TextBox()
        Me.Label40 = New System.Windows.Forms.Label()
        Me.Label5 = New System.Windows.Forms.Label()
        Me.txtAziendaErogante = New System.Windows.Forms.TextBox()
        Me.lblDllVersion = New System.Windows.Forms.Label()
        Me.ToolTipManager = New System.Windows.Forms.ToolTip(Me.components)
        Me.StatusStripMain = New System.Windows.Forms.StatusStrip()
        Me.ToolStripConnectionInfo = New System.Windows.Forms.ToolStripStatusLabel()
        Me.ToolStripIdentityInfo = New System.Windows.Forms.ToolStripStatusLabel()
        Me.OpenFileDialog1 = New System.Windows.Forms.OpenFileDialog()
        Me.tabsTest.SuspendLayout()
        Me.tabPazienti.SuspendLayout()
        Me.gbPazienti.SuspendLayout()
        Me.gpPazientiDatiFusione.SuspendLayout()
        Me.tabPazienti_XML.SuspendLayout()
        Me.tabEpisodio.SuspendLayout()
        Me.gbEpisodio.SuspendLayout()
        Me.tabRicovero.SuspendLayout()
        Me.gbRicovero.SuspendLayout()
        Me.tabEpisodio_XML.SuspendLayout()
        Me.tabRicovero_XML.SuspendLayout()
        Me.tabProveDiCarico.SuspendLayout()
        Me.StatusStripMain.SuspendLayout()
        Me.SuspendLayout()
        '
        'lvTrace
        '
        Me.lvTrace.Anchor = CType(((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Left) _
            Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.lvTrace.Columns.AddRange(New System.Windows.Forms.ColumnHeader() {Me.chTraceTimeInit, Me.chTraceTimeExec, Me.chTraceDescrizione})
        Me.lvTrace.FullRowSelect = True
        Me.lvTrace.Location = New System.Drawing.Point(12, 49)
        Me.lvTrace.Name = "lvTrace"
        Me.lvTrace.Size = New System.Drawing.Size(626, 157)
        Me.lvTrace.TabIndex = 5
        Me.lvTrace.UseCompatibleStateImageBehavior = False
        Me.lvTrace.View = System.Windows.Forms.View.Details
        '
        'chTraceTimeInit
        '
        Me.chTraceTimeInit.Text = "Time"
        Me.chTraceTimeInit.Width = 107
        '
        'chTraceTimeExec
        '
        Me.chTraceTimeExec.Text = "Time exec."
        Me.chTraceTimeExec.Width = 66
        '
        'chTraceDescrizione
        '
        Me.chTraceDescrizione.Text = "Descrizione"
        Me.chTraceDescrizione.Width = 400
        '
        'OpenFileDialogJpg
        '
        Me.OpenFileDialogJpg.DefaultExt = "*.jpg"
        '
        'tabsTest
        '
        Me.tabsTest.Anchor = CType((((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Bottom) _
            Or System.Windows.Forms.AnchorStyles.Left) _
            Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.tabsTest.Controls.Add(Me.tabPazienti)
        Me.tabsTest.Controls.Add(Me.tabPazienti_XML)
        Me.tabsTest.Controls.Add(Me.tabEpisodio)
        Me.tabsTest.Controls.Add(Me.tabRicovero)
        Me.tabsTest.Controls.Add(Me.tabEpisodio_XML)
        Me.tabsTest.Controls.Add(Me.tabRicovero_XML)
        Me.tabsTest.Controls.Add(Me.tabProveDiCarico)
        Me.tabsTest.Location = New System.Drawing.Point(12, 221)
        Me.tabsTest.Name = "tabsTest"
        Me.tabsTest.SelectedIndex = 0
        Me.tabsTest.Size = New System.Drawing.Size(630, 349)
        Me.tabsTest.TabIndex = 22
        '
        'tabPazienti
        '
        Me.tabPazienti.Controls.Add(Me.Label29)
        Me.tabPazienti.Controls.Add(Me.txtPazientiCodiceFiscale)
        Me.tabPazienti.Controls.Add(Me.lblPazientiCodiceFiscale)
        Me.tabPazienti.Controls.Add(Me.txtPazientiLuogoNascita)
        Me.tabPazienti.Controls.Add(Me.lblPazientiLuogonascita)
        Me.tabPazienti.Controls.Add(Me.txtPazientiDataNascita)
        Me.tabPazienti.Controls.Add(Me.lblPazientiDataNascita)
        Me.tabPazienti.Controls.Add(Me.cmbPazientiSesso)
        Me.tabPazienti.Controls.Add(Me.Label25)
        Me.tabPazienti.Controls.Add(Me.txtPazientiNome)
        Me.tabPazienti.Controls.Add(Me.lblPazientiNome)
        Me.tabPazienti.Controls.Add(Me.txtPazientiCognome)
        Me.tabPazienti.Controls.Add(Me.lblPazientiCognome)
        Me.tabPazienti.Controls.Add(Me.gbPazienti)
        Me.tabPazienti.Controls.Add(Me.Label14)
        Me.tabPazienti.Controls.Add(Me.cmdAddAnagrafica)
        Me.tabPazienti.Controls.Add(Me.Label1)
        Me.tabPazienti.Controls.Add(Me.txtPazientiDataSeqAnagrafica)
        Me.tabPazienti.Controls.Add(Me.Label4)
        Me.tabPazienti.Controls.Add(Me.cboTipoPostAnagrafica)
        Me.tabPazienti.Controls.Add(Me.lblPazientiNomeAnagrafica)
        Me.tabPazienti.Controls.Add(Me.txtPazientiNomeAnagrafica)
        Me.tabPazienti.Controls.Add(Me.lblPazientiCodiceAnagrafica)
        Me.tabPazienti.Controls.Add(Me.txtPazientiCodiceAnagrafica)
        Me.tabPazienti.Controls.Add(Me.txtPazientiIdEsterno)
        Me.tabPazienti.Controls.Add(Me.Label2)
        Me.tabPazienti.Controls.Add(Me.gpPazientiDatiFusione)
        Me.tabPazienti.Location = New System.Drawing.Point(4, 22)
        Me.tabPazienti.Name = "tabPazienti"
        Me.tabPazienti.Size = New System.Drawing.Size(622, 323)
        Me.tabPazienti.TabIndex = 1
        Me.tabPazienti.Text = "Pazienti"
        Me.tabPazienti.UseVisualStyleBackColor = True
        '
        'Label29
        '
        Me.Label29.Location = New System.Drawing.Point(460, 102)
        Me.Label29.Name = "Label29"
        Me.Label29.Size = New System.Drawing.Size(125, 16)
        Me.Label29.TabIndex = 79
        Me.Label29.Text = "(yyyy-MM-dd)"
        '
        'txtPazientiCodiceFiscale
        '
        Me.txtPazientiCodiceFiscale.Location = New System.Drawing.Point(105, 71)
        Me.txtPazientiCodiceFiscale.Name = "txtPazientiCodiceFiscale"
        Me.txtPazientiCodiceFiscale.Size = New System.Drawing.Size(140, 20)
        Me.txtPazientiCodiceFiscale.TabIndex = 78
        '
        'lblPazientiCodiceFiscale
        '
        Me.lblPazientiCodiceFiscale.Location = New System.Drawing.Point(8, 74)
        Me.lblPazientiCodiceFiscale.Name = "lblPazientiCodiceFiscale"
        Me.lblPazientiCodiceFiscale.Size = New System.Drawing.Size(79, 16)
        Me.lblPazientiCodiceFiscale.TabIndex = 77
        Me.lblPazientiCodiceFiscale.Text = "Codice fiscale"
        '
        'txtPazientiLuogoNascita
        '
        Me.txtPazientiLuogoNascita.Location = New System.Drawing.Point(314, 72)
        Me.txtPazientiLuogoNascita.Name = "txtPazientiLuogoNascita"
        Me.txtPazientiLuogoNascita.Size = New System.Drawing.Size(140, 20)
        Me.txtPazientiLuogoNascita.TabIndex = 76
        '
        'lblPazientiLuogonascita
        '
        Me.lblPazientiLuogonascita.Location = New System.Drawing.Point(252, 75)
        Me.lblPazientiLuogonascita.Name = "lblPazientiLuogonascita"
        Me.lblPazientiLuogonascita.Size = New System.Drawing.Size(60, 16)
        Me.lblPazientiLuogonascita.TabIndex = 75
        Me.lblPazientiLuogonascita.Text = "Luogo nas."
        '
        'txtPazientiDataNascita
        '
        Me.txtPazientiDataNascita.Location = New System.Drawing.Point(314, 98)
        Me.txtPazientiDataNascita.Name = "txtPazientiDataNascita"
        Me.txtPazientiDataNascita.Size = New System.Drawing.Size(140, 20)
        Me.txtPazientiDataNascita.TabIndex = 74
        '
        'lblPazientiDataNascita
        '
        Me.lblPazientiDataNascita.Location = New System.Drawing.Point(252, 99)
        Me.lblPazientiDataNascita.Name = "lblPazientiDataNascita"
        Me.lblPazientiDataNascita.Size = New System.Drawing.Size(60, 18)
        Me.lblPazientiDataNascita.TabIndex = 73
        Me.lblPazientiDataNascita.Text = "Data nas."
        '
        'cmbPazientiSesso
        '
        Me.cmbPazientiSesso.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList
        Me.cmbPazientiSesso.FormattingEnabled = True
        Me.cmbPazientiSesso.Items.AddRange(New Object() {"", "M", "F"})
        Me.cmbPazientiSesso.Location = New System.Drawing.Point(534, 47)
        Me.cmbPazientiSesso.Name = "cmbPazientiSesso"
        Me.cmbPazientiSesso.Size = New System.Drawing.Size(46, 21)
        Me.cmbPazientiSesso.TabIndex = 72
        '
        'Label25
        '
        Me.Label25.Location = New System.Drawing.Point(480, 50)
        Me.Label25.Name = "Label25"
        Me.Label25.Size = New System.Drawing.Size(48, 16)
        Me.Label25.TabIndex = 71
        Me.Label25.Text = "Sesso"
        '
        'txtPazientiNome
        '
        Me.txtPazientiNome.Location = New System.Drawing.Point(314, 46)
        Me.txtPazientiNome.Name = "txtPazientiNome"
        Me.txtPazientiNome.Size = New System.Drawing.Size(140, 20)
        Me.txtPazientiNome.TabIndex = 70
        '
        'lblPazientiNome
        '
        Me.lblPazientiNome.Location = New System.Drawing.Point(252, 49)
        Me.lblPazientiNome.Name = "lblPazientiNome"
        Me.lblPazientiNome.Size = New System.Drawing.Size(60, 16)
        Me.lblPazientiNome.TabIndex = 69
        Me.lblPazientiNome.Text = "Nome"
        '
        'txtPazientiCognome
        '
        Me.txtPazientiCognome.Location = New System.Drawing.Point(105, 45)
        Me.txtPazientiCognome.Name = "txtPazientiCognome"
        Me.txtPazientiCognome.Size = New System.Drawing.Size(140, 20)
        Me.txtPazientiCognome.TabIndex = 64
        '
        'lblPazientiCognome
        '
        Me.lblPazientiCognome.Location = New System.Drawing.Point(8, 48)
        Me.lblPazientiCognome.Name = "lblPazientiCognome"
        Me.lblPazientiCognome.Size = New System.Drawing.Size(60, 16)
        Me.lblPazientiCognome.TabIndex = 63
        Me.lblPazientiCognome.Text = "Cognome"
        '
        'gbPazienti
        '
        Me.gbPazienti.Anchor = CType(((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Left) _
            Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.gbPazienti.Controls.Add(Me.cmdAddConsenso)
        Me.gbPazienti.Location = New System.Drawing.Point(11, 223)
        Me.gbPazienti.Name = "gbPazienti"
        Me.gbPazienti.Size = New System.Drawing.Size(598, 89)
        Me.gbPazienti.TabIndex = 62
        Me.gbPazienti.TabStop = False
        Me.gbPazienti.Text = " Altre operazioni: "
        '
        'cmdAddConsenso
        '
        Me.cmdAddConsenso.Location = New System.Drawing.Point(15, 40)
        Me.cmdAddConsenso.Name = "cmdAddConsenso"
        Me.cmdAddConsenso.Size = New System.Drawing.Size(144, 23)
        Me.cmdAddConsenso.TabIndex = 46
        Me.cmdAddConsenso.Text = "Aggiunge consenso"
        '
        'Label14
        '
        Me.Label14.Location = New System.Drawing.Point(460, 18)
        Me.Label14.Name = "Label14"
        Me.Label14.Size = New System.Drawing.Size(125, 16)
        Me.Label14.TabIndex = 61
        Me.Label14.Text = "(yyyy-MM-dd hh:mm:ss)"
        '
        'cmdAddAnagrafica
        '
        Me.cmdAddAnagrafica.Location = New System.Drawing.Point(470, 153)
        Me.cmdAddAnagrafica.Name = "cmdAddAnagrafica"
        Me.cmdAddAnagrafica.Size = New System.Drawing.Size(110, 23)
        Me.cmdAddAnagrafica.TabIndex = 47
        Me.cmdAddAnagrafica.Text = "Esegui"
        '
        'Label1
        '
        Me.Label1.Location = New System.Drawing.Point(231, 18)
        Me.Label1.Name = "Label1"
        Me.Label1.Size = New System.Drawing.Size(81, 16)
        Me.Label1.TabIndex = 60
        Me.Label1.Text = "Data sequenza"
        Me.ToolTipManager.SetToolTip(Me.Label1, "Data sequenza: da compilare se si vuole simulare l'errore di data sequenza")
        '
        'txtPazientiDataSeqAnagrafica
        '
        Me.txtPazientiDataSeqAnagrafica.Location = New System.Drawing.Point(314, 15)
        Me.txtPazientiDataSeqAnagrafica.Name = "txtPazientiDataSeqAnagrafica"
        Me.txtPazientiDataSeqAnagrafica.Size = New System.Drawing.Size(140, 20)
        Me.txtPazientiDataSeqAnagrafica.TabIndex = 59
        Me.ToolTipManager.SetToolTip(Me.txtPazientiDataSeqAnagrafica, "Data sequenza: da compilare se si vuole simulare l'errore di data sequenza")
        '
        'Label4
        '
        Me.Label4.Location = New System.Drawing.Point(8, 18)
        Me.Label4.Name = "Label4"
        Me.Label4.Size = New System.Drawing.Size(96, 16)
        Me.Label4.TabIndex = 58
        Me.Label4.Text = "Tipo operazione"
        '
        'cboTipoPostAnagrafica
        '
        Me.cboTipoPostAnagrafica.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList
        Me.cboTipoPostAnagrafica.Items.AddRange(New Object() {"Aggiunge", "Modifica", "Rimuove", "Fusione"})
        Me.cboTipoPostAnagrafica.Location = New System.Drawing.Point(105, 14)
        Me.cboTipoPostAnagrafica.Name = "cboTipoPostAnagrafica"
        Me.cboTipoPostAnagrafica.Size = New System.Drawing.Size(111, 21)
        Me.cboTipoPostAnagrafica.TabIndex = 57
        '
        'lblPazientiNomeAnagrafica
        '
        Me.lblPazientiNomeAnagrafica.Location = New System.Drawing.Point(8, 130)
        Me.lblPazientiNomeAnagrafica.Name = "lblPazientiNomeAnagrafica"
        Me.lblPazientiNomeAnagrafica.Size = New System.Drawing.Size(96, 16)
        Me.lblPazientiNomeAnagrafica.TabIndex = 45
        Me.lblPazientiNomeAnagrafica.Text = "Nome anagrafica"
        Me.ToolTipManager.SetToolTip(Me.lblPazientiNomeAnagrafica, "La modifica di ""Codice anagrafica"" e ""Nome anagrafica""  ha" & Global.Microsoft.VisualBasic.ChrW(13) & Global.Microsoft.VisualBasic.ChrW(10) & "effetto solo in inser" & _
        "imento." & Global.Microsoft.VisualBasic.ChrW(13) & Global.Microsoft.VisualBasic.ChrW(10))
        '
        'txtPazientiNomeAnagrafica
        '
        Me.txtPazientiNomeAnagrafica.Location = New System.Drawing.Point(105, 127)
        Me.txtPazientiNomeAnagrafica.Name = "txtPazientiNomeAnagrafica"
        Me.txtPazientiNomeAnagrafica.Size = New System.Drawing.Size(140, 20)
        Me.txtPazientiNomeAnagrafica.TabIndex = 44
        Me.txtPazientiNomeAnagrafica.Text = "TEST"
        Me.ToolTipManager.SetToolTip(Me.txtPazientiNomeAnagrafica, "La modifica di ""Codice anagrafica"" e ""Nome anagrafica""  ha" & Global.Microsoft.VisualBasic.ChrW(13) & Global.Microsoft.VisualBasic.ChrW(10) & "effetto solo in inser" & _
        "imento." & Global.Microsoft.VisualBasic.ChrW(13) & Global.Microsoft.VisualBasic.ChrW(10))
        '
        'lblPazientiCodiceAnagrafica
        '
        Me.lblPazientiCodiceAnagrafica.Location = New System.Drawing.Point(8, 160)
        Me.lblPazientiCodiceAnagrafica.Name = "lblPazientiCodiceAnagrafica"
        Me.lblPazientiCodiceAnagrafica.Size = New System.Drawing.Size(96, 16)
        Me.lblPazientiCodiceAnagrafica.TabIndex = 43
        Me.lblPazientiCodiceAnagrafica.Text = "Codice anagrafica"
        Me.ToolTipManager.SetToolTip(Me.lblPazientiCodiceAnagrafica, "La modifica di ""Codice anagrafica"" e ""Nome anagrafica""  ha" & Global.Microsoft.VisualBasic.ChrW(13) & Global.Microsoft.VisualBasic.ChrW(10) & "effetto solo in inser" & _
        "imento." & Global.Microsoft.VisualBasic.ChrW(13) & Global.Microsoft.VisualBasic.ChrW(10))
        '
        'txtPazientiCodiceAnagrafica
        '
        Me.txtPazientiCodiceAnagrafica.Location = New System.Drawing.Point(105, 157)
        Me.txtPazientiCodiceAnagrafica.Name = "txtPazientiCodiceAnagrafica"
        Me.txtPazientiCodiceAnagrafica.Size = New System.Drawing.Size(140, 20)
        Me.txtPazientiCodiceAnagrafica.TabIndex = 42
        Me.txtPazientiCodiceAnagrafica.Text = "800000"
        Me.ToolTipManager.SetToolTip(Me.txtPazientiCodiceAnagrafica, "La modifica di ""Codice anagrafica"" e ""Nome anagrafica""  ha" & Global.Microsoft.VisualBasic.ChrW(13) & Global.Microsoft.VisualBasic.ChrW(10) & "effetto solo in inser" & _
        "imento.")
        '
        'txtPazientiIdEsterno
        '
        Me.txtPazientiIdEsterno.Location = New System.Drawing.Point(105, 97)
        Me.txtPazientiIdEsterno.Name = "txtPazientiIdEsterno"
        Me.txtPazientiIdEsterno.Size = New System.Drawing.Size(140, 20)
        Me.txtPazientiIdEsterno.TabIndex = 19
        Me.txtPazientiIdEsterno.Text = "TEST_800000"
        '
        'Label2
        '
        Me.Label2.Location = New System.Drawing.Point(8, 97)
        Me.Label2.Name = "Label2"
        Me.Label2.Size = New System.Drawing.Size(84, 16)
        Me.Label2.TabIndex = 18
        Me.Label2.Text = "IdEsterno paz."
        '
        'gpPazientiDatiFusione
        '
        Me.gpPazientiDatiFusione.Controls.Add(Me.txtPazientiFusioneCodiceAnagrafica)
        Me.gpPazientiDatiFusione.Controls.Add(Me.Label24)
        Me.gpPazientiDatiFusione.Controls.Add(Me.Label26)
        Me.gpPazientiDatiFusione.Controls.Add(Me.txtPazientiFusioneNomeAnagrafica)
        Me.gpPazientiDatiFusione.Location = New System.Drawing.Point(268, 127)
        Me.gpPazientiDatiFusione.Name = "gpPazientiDatiFusione"
        Me.gpPazientiDatiFusione.Size = New System.Drawing.Size(260, 72)
        Me.gpPazientiDatiFusione.TabIndex = 84
        Me.gpPazientiDatiFusione.TabStop = False
        Me.gpPazientiDatiFusione.Text = " Riferimento paziente da fondere: "
        Me.ToolTipManager.SetToolTip(Me.gpPazientiDatiFusione, "Compilare con il Nome e il Codice Anagrafica del paziente che si vuole fondere" & Global.Microsoft.VisualBasic.ChrW(13) & Global.Microsoft.VisualBasic.ChrW(10) & "n" & _
        "el paziente visualizzato nll'interfaccia.")
        '
        'txtPazientiFusioneCodiceAnagrafica
        '
        Me.txtPazientiFusioneCodiceAnagrafica.Location = New System.Drawing.Point(107, 42)
        Me.txtPazientiFusioneCodiceAnagrafica.Name = "txtPazientiFusioneCodiceAnagrafica"
        Me.txtPazientiFusioneCodiceAnagrafica.Size = New System.Drawing.Size(140, 20)
        Me.txtPazientiFusioneCodiceAnagrafica.TabIndex = 80
        Me.txtPazientiFusioneCodiceAnagrafica.Text = "800000"
        '
        'Label24
        '
        Me.Label24.Location = New System.Drawing.Point(10, 20)
        Me.Label24.Name = "Label24"
        Me.Label24.Size = New System.Drawing.Size(96, 16)
        Me.Label24.TabIndex = 83
        Me.Label24.Text = "Nome anagrafica "
        '
        'Label26
        '
        Me.Label26.Location = New System.Drawing.Point(10, 45)
        Me.Label26.Name = "Label26"
        Me.Label26.Size = New System.Drawing.Size(96, 16)
        Me.Label26.TabIndex = 81
        Me.Label26.Text = "Codice anagrafica"
        '
        'txtPazientiFusioneNomeAnagrafica
        '
        Me.txtPazientiFusioneNomeAnagrafica.Location = New System.Drawing.Point(107, 17)
        Me.txtPazientiFusioneNomeAnagrafica.Name = "txtPazientiFusioneNomeAnagrafica"
        Me.txtPazientiFusioneNomeAnagrafica.Size = New System.Drawing.Size(140, 20)
        Me.txtPazientiFusioneNomeAnagrafica.TabIndex = 82
        Me.txtPazientiFusioneNomeAnagrafica.Text = "TEST"
        '
        'tabPazienti_XML
        '
        Me.tabPazienti_XML.Controls.Add(Me.Label32)
        Me.tabPazienti_XML.Controls.Add(Me.Label37)
        Me.tabPazienti_XML.Controls.Add(Me.Label38)
        Me.tabPazienti_XML.Controls.Add(Me.txtPazientiDataSeqAnagrafica2)
        Me.tabPazienti_XML.Controls.Add(Me.Label39)
        Me.tabPazienti_XML.Controls.Add(Me.cboTipoPostAnagrafica2)
        Me.tabPazienti_XML.Controls.Add(Me.cmdEseguiAnagrafica2)
        Me.tabPazienti_XML.Controls.Add(Me.txtAnagrafica2Xml)
        Me.tabPazienti_XML.Location = New System.Drawing.Point(4, 22)
        Me.tabPazienti_XML.Name = "tabPazienti_XML"
        Me.tabPazienti_XML.Padding = New System.Windows.Forms.Padding(3)
        Me.tabPazienti_XML.Size = New System.Drawing.Size(622, 323)
        Me.tabPazienti_XML.TabIndex = 8
        Me.tabPazienti_XML.Text = "Pazienti-XML"
        Me.tabPazienti_XML.UseVisualStyleBackColor = True
        '
        'Label32
        '
        Me.Label32.Location = New System.Drawing.Point(11, 67)
        Me.Label32.Name = "Label32"
        Me.Label32.Size = New System.Drawing.Size(96, 16)
        Me.Label32.TabIndex = 70
        Me.Label32.Text = "Xml:"
        Me.ToolTipManager.SetToolTip(Me.Label32, "Data sequenza: da compilare se si vuole simulare l'errore di data sequenza")
        '
        'Label37
        '
        Me.Label37.Location = New System.Drawing.Point(262, 44)
        Me.Label37.Name = "Label37"
        Me.Label37.Size = New System.Drawing.Size(125, 16)
        Me.Label37.TabIndex = 69
        Me.Label37.Text = "(yyyy-MM-dd hh:mm:ss)"
        '
        'Label38
        '
        Me.Label38.Location = New System.Drawing.Point(11, 42)
        Me.Label38.Name = "Label38"
        Me.Label38.Size = New System.Drawing.Size(85, 16)
        Me.Label38.TabIndex = 68
        Me.Label38.Text = "Data sequenza"
        Me.ToolTipManager.SetToolTip(Me.Label38, "Data sequenza: da compilare se si vuole simulare l'errore di data sequenza")
        '
        'txtPazientiDataSeqAnagrafica2
        '
        Me.txtPazientiDataSeqAnagrafica2.Location = New System.Drawing.Point(108, 41)
        Me.txtPazientiDataSeqAnagrafica2.Name = "txtPazientiDataSeqAnagrafica2"
        Me.txtPazientiDataSeqAnagrafica2.Size = New System.Drawing.Size(148, 20)
        Me.txtPazientiDataSeqAnagrafica2.TabIndex = 67
        Me.ToolTipManager.SetToolTip(Me.txtPazientiDataSeqAnagrafica2, "Data sequenza: da compilare se si vuole simulare l'errore di data sequenza")
        '
        'Label39
        '
        Me.Label39.Location = New System.Drawing.Point(11, 12)
        Me.Label39.Name = "Label39"
        Me.Label39.Size = New System.Drawing.Size(96, 16)
        Me.Label39.TabIndex = 66
        Me.Label39.Text = "Tipo operazione"
        '
        'cboTipoPostAnagrafica2
        '
        Me.cboTipoPostAnagrafica2.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList
        Me.cboTipoPostAnagrafica2.Items.AddRange(New Object() {"Aggiunge", "Modifica", "Rimuove"})
        Me.cboTipoPostAnagrafica2.Location = New System.Drawing.Point(108, 9)
        Me.cboTipoPostAnagrafica2.Name = "cboTipoPostAnagrafica2"
        Me.cboTipoPostAnagrafica2.Size = New System.Drawing.Size(148, 21)
        Me.cboTipoPostAnagrafica2.TabIndex = 65
        '
        'cmdEseguiAnagrafica2
        '
        Me.cmdEseguiAnagrafica2.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.cmdEseguiAnagrafica2.Location = New System.Drawing.Point(517, 37)
        Me.cmdEseguiAnagrafica2.Name = "cmdEseguiAnagrafica2"
        Me.cmdEseguiAnagrafica2.Size = New System.Drawing.Size(89, 23)
        Me.cmdEseguiAnagrafica2.TabIndex = 64
        Me.cmdEseguiAnagrafica2.Text = "Esegui"
        Me.cmdEseguiAnagrafica2.UseVisualStyleBackColor = True
        '
        'txtAnagrafica2Xml
        '
        Me.txtAnagrafica2Xml.Anchor = CType((((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Bottom) _
            Or System.Windows.Forms.AnchorStyles.Left) _
            Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.txtAnagrafica2Xml.Location = New System.Drawing.Point(14, 86)
        Me.txtAnagrafica2Xml.MaxLength = 65536
        Me.txtAnagrafica2Xml.Multiline = True
        Me.txtAnagrafica2Xml.Name = "txtAnagrafica2Xml"
        Me.txtAnagrafica2Xml.ScrollBars = System.Windows.Forms.ScrollBars.Both
        Me.txtAnagrafica2Xml.Size = New System.Drawing.Size(598, 227)
        Me.txtAnagrafica2Xml.TabIndex = 63
        '
        'tabEpisodio
        '
        Me.tabEpisodio.Controls.Add(Me.Label16)
        Me.tabEpisodio.Controls.Add(Me.Label15)
        Me.tabEpisodio.Controls.Add(Me.txtEpisodioDataReferto)
        Me.tabEpisodio.Controls.Add(Me.lblEpisodioDataSquenza)
        Me.tabEpisodio.Controls.Add(Me.gbEpisodio)
        Me.tabEpisodio.Controls.Add(Me.Label3)
        Me.tabEpisodio.Controls.Add(Me.txtEpisodioDataSeq)
        Me.tabEpisodio.Controls.Add(Me.cmdLibAddEpisodio)
        Me.tabEpisodio.Controls.Add(Me.Label21)
        Me.tabEpisodio.Controls.Add(Me.cboTipoPostEpisodio)
        Me.tabEpisodio.Controls.Add(Me.Label17)
        Me.tabEpisodio.Controls.Add(Me.txtEpisodioNomeAnagrafica)
        Me.tabEpisodio.Controls.Add(Me.Label18)
        Me.tabEpisodio.Controls.Add(Me.txtEpisodioCodiceAnagrafica)
        Me.tabEpisodio.Controls.Add(Me.txtEpisodioIdEsternoReferto)
        Me.tabEpisodio.Controls.Add(Me.Label19)
        Me.tabEpisodio.Controls.Add(Me.Label20)
        Me.tabEpisodio.Controls.Add(Me.txtEpisodioIdEsternoPaziente)
        Me.tabEpisodio.Location = New System.Drawing.Point(4, 22)
        Me.tabEpisodio.Name = "tabEpisodio"
        Me.tabEpisodio.Size = New System.Drawing.Size(622, 323)
        Me.tabEpisodio.TabIndex = 4
        Me.tabEpisodio.Text = "Episodio"
        Me.tabEpisodio.UseVisualStyleBackColor = True
        '
        'Label16
        '
        Me.Label16.Location = New System.Drawing.Point(468, 77)
        Me.Label16.Name = "Label16"
        Me.Label16.Size = New System.Drawing.Size(125, 16)
        Me.Label16.TabIndex = 61
        Me.Label16.Text = "(yyyy-MM-dd hh:mm:ss)"
        '
        'Label15
        '
        Me.Label15.Location = New System.Drawing.Point(274, 79)
        Me.Label15.Name = "Label15"
        Me.Label15.Size = New System.Drawing.Size(78, 16)
        Me.Label15.TabIndex = 60
        Me.Label15.Text = "Data Referto"
        '
        'txtEpisodioDataReferto
        '
        Me.txtEpisodioDataReferto.Location = New System.Drawing.Point(358, 75)
        Me.txtEpisodioDataReferto.Name = "txtEpisodioDataReferto"
        Me.txtEpisodioDataReferto.Size = New System.Drawing.Size(103, 20)
        Me.txtEpisodioDataReferto.TabIndex = 59
        '
        'lblEpisodioDataSquenza
        '
        Me.lblEpisodioDataSquenza.Location = New System.Drawing.Point(274, 18)
        Me.lblEpisodioDataSquenza.Name = "lblEpisodioDataSquenza"
        Me.lblEpisodioDataSquenza.Size = New System.Drawing.Size(125, 16)
        Me.lblEpisodioDataSquenza.TabIndex = 58
        Me.lblEpisodioDataSquenza.Text = "(yyyy-MM-dd hh:mm:ss)"
        '
        'gbEpisodio
        '
        Me.gbEpisodio.Anchor = CType(((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Left) _
            Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.gbEpisodio.Controls.Add(Me.cmdEpisodioSerializza)
        Me.gbEpisodio.Location = New System.Drawing.Point(11, 223)
        Me.gbEpisodio.Name = "gbEpisodio"
        Me.gbEpisodio.Size = New System.Drawing.Size(598, 89)
        Me.gbEpisodio.TabIndex = 57
        Me.gbEpisodio.TabStop = False
        Me.gbEpisodio.Text = " Altre operazioni: "
        '
        'cmdEpisodioSerializza
        '
        Me.cmdEpisodioSerializza.Location = New System.Drawing.Point(15, 40)
        Me.cmdEpisodioSerializza.Name = "cmdEpisodioSerializza"
        Me.cmdEpisodioSerializza.Size = New System.Drawing.Size(140, 23)
        Me.cmdEpisodioSerializza.TabIndex = 54
        Me.cmdEpisodioSerializza.Text = "Serializza episodio di test"
        '
        'Label3
        '
        Me.Label3.Location = New System.Drawing.Point(8, 18)
        Me.Label3.Name = "Label3"
        Me.Label3.Size = New System.Drawing.Size(96, 16)
        Me.Label3.TabIndex = 56
        Me.Label3.Text = "Data sequenza"
        Me.ToolTipManager.SetToolTip(Me.Label3, "Data sequenza: da compilare se si vuole simulare l'errore di data sequenza")
        '
        'txtEpisodioDataSeq
        '
        Me.txtEpisodioDataSeq.Location = New System.Drawing.Point(116, 15)
        Me.txtEpisodioDataSeq.Name = "txtEpisodioDataSeq"
        Me.txtEpisodioDataSeq.Size = New System.Drawing.Size(148, 20)
        Me.txtEpisodioDataSeq.TabIndex = 55
        Me.ToolTipManager.SetToolTip(Me.txtEpisodioDataSeq, "Data sequenza: da compilare se si vuole simulare l'errore di data sequenza")
        '
        'cmdLibAddEpisodio
        '
        Me.cmdLibAddEpisodio.Location = New System.Drawing.Point(483, 133)
        Me.cmdLibAddEpisodio.Name = "cmdLibAddEpisodio"
        Me.cmdLibAddEpisodio.Size = New System.Drawing.Size(110, 23)
        Me.cmdLibAddEpisodio.TabIndex = 53
        Me.cmdLibAddEpisodio.Text = "Esegui"
        '
        'Label21
        '
        Me.Label21.Location = New System.Drawing.Point(8, 46)
        Me.Label21.Name = "Label21"
        Me.Label21.Size = New System.Drawing.Size(96, 16)
        Me.Label21.TabIndex = 52
        Me.Label21.Text = "Tipo operazione"
        '
        'cboTipoPostEpisodio
        '
        Me.cboTipoPostEpisodio.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList
        Me.cboTipoPostEpisodio.Items.AddRange(New Object() {"Aggiunge", "Modifica", "Rimuove"})
        Me.cboTipoPostEpisodio.Location = New System.Drawing.Point(116, 41)
        Me.cboTipoPostEpisodio.Name = "cboTipoPostEpisodio"
        Me.cboTipoPostEpisodio.Size = New System.Drawing.Size(148, 21)
        Me.cboTipoPostEpisodio.TabIndex = 50
        '
        'Label17
        '
        Me.Label17.Location = New System.Drawing.Point(8, 133)
        Me.Label17.Name = "Label17"
        Me.Label17.Size = New System.Drawing.Size(96, 16)
        Me.Label17.TabIndex = 49
        Me.Label17.Text = "Nome anagrafica"
        '
        'txtEpisodioNomeAnagrafica
        '
        Me.txtEpisodioNomeAnagrafica.Location = New System.Drawing.Point(116, 133)
        Me.txtEpisodioNomeAnagrafica.Name = "txtEpisodioNomeAnagrafica"
        Me.txtEpisodioNomeAnagrafica.Size = New System.Drawing.Size(103, 20)
        Me.txtEpisodioNomeAnagrafica.TabIndex = 48
        Me.txtEpisodioNomeAnagrafica.Text = "TEST"
        '
        'Label18
        '
        Me.Label18.Location = New System.Drawing.Point(225, 133)
        Me.Label18.Name = "Label18"
        Me.Label18.Size = New System.Drawing.Size(96, 16)
        Me.Label18.TabIndex = 47
        Me.Label18.Text = "Codice anagrafica"
        '
        'txtEpisodioCodiceAnagrafica
        '
        Me.txtEpisodioCodiceAnagrafica.Location = New System.Drawing.Point(327, 133)
        Me.txtEpisodioCodiceAnagrafica.Name = "txtEpisodioCodiceAnagrafica"
        Me.txtEpisodioCodiceAnagrafica.Size = New System.Drawing.Size(112, 20)
        Me.txtEpisodioCodiceAnagrafica.TabIndex = 46
        Me.txtEpisodioCodiceAnagrafica.Text = "800000"
        '
        'txtEpisodioIdEsternoReferto
        '
        Me.txtEpisodioIdEsternoReferto.Location = New System.Drawing.Point(116, 74)
        Me.txtEpisodioIdEsternoReferto.Name = "txtEpisodioIdEsternoReferto"
        Me.txtEpisodioIdEsternoReferto.Size = New System.Drawing.Size(152, 20)
        Me.txtEpisodioIdEsternoReferto.TabIndex = 45
        Me.txtEpisodioIdEsternoReferto.Text = "TEST_20060311_00000"
        '
        'Label19
        '
        Me.Label19.Location = New System.Drawing.Point(8, 78)
        Me.Label19.Name = "Label19"
        Me.Label19.Size = New System.Drawing.Size(96, 16)
        Me.Label19.TabIndex = 44
        Me.Label19.Text = "IdEsteno referto"
        '
        'Label20
        '
        Me.Label20.Location = New System.Drawing.Point(8, 106)
        Me.Label20.Name = "Label20"
        Me.Label20.Size = New System.Drawing.Size(100, 16)
        Me.Label20.TabIndex = 43
        Me.Label20.Text = "IdEsterno paziente"
        '
        'txtEpisodioIdEsternoPaziente
        '
        Me.txtEpisodioIdEsternoPaziente.Location = New System.Drawing.Point(116, 102)
        Me.txtEpisodioIdEsternoPaziente.Name = "txtEpisodioIdEsternoPaziente"
        Me.txtEpisodioIdEsternoPaziente.Size = New System.Drawing.Size(152, 20)
        Me.txtEpisodioIdEsternoPaziente.TabIndex = 42
        Me.txtEpisodioIdEsternoPaziente.Text = "TEST_800000"
        '
        'tabRicovero
        '
        Me.tabRicovero.Controls.Add(Me.Label23)
        Me.tabRicovero.Controls.Add(Me.lblRicoveriDataEventoFormato)
        Me.tabRicovero.Controls.Add(Me.lblRicoveriDataSequenzaFormato)
        Me.tabRicovero.Controls.Add(Me.gbRicovero)
        Me.tabRicovero.Controls.Add(Me.txtIdEsternoEventoUtilizzato)
        Me.tabRicovero.Controls.Add(Me.Label13)
        Me.tabRicovero.Controls.Add(Me.Label22)
        Me.tabRicovero.Controls.Add(Me.txtEventoRicoveroDataEvento)
        Me.tabRicovero.Controls.Add(Me.txtEventoRicoveroNosologico)
        Me.tabRicovero.Controls.Add(Me.Label12)
        Me.tabRicovero.Controls.Add(Me.cboEventoRicoveroTipoEvento)
        Me.tabRicovero.Controls.Add(Me.cmdLibAddEventoRicovero)
        Me.tabRicovero.Controls.Add(Me.Label6)
        Me.tabRicovero.Controls.Add(Me.txtEventoRicoveroDataSeq)
        Me.tabRicovero.Controls.Add(Me.Label7)
        Me.tabRicovero.Controls.Add(Me.cboTipoPostEventoRicovero)
        Me.tabRicovero.Controls.Add(Me.Label8)
        Me.tabRicovero.Controls.Add(Me.txtEventoRicoveroNomeAnagrafica)
        Me.tabRicovero.Controls.Add(Me.Label9)
        Me.tabRicovero.Controls.Add(Me.txtEventoRicoveroCodiceAnagrafica)
        Me.tabRicovero.Controls.Add(Me.txtEventoRicoveroIdEsternoEvento)
        Me.tabRicovero.Controls.Add(Me.Label10)
        Me.tabRicovero.Controls.Add(Me.Label11)
        Me.tabRicovero.Controls.Add(Me.txtEventoRicoveroIdEsternoPaziente)
        Me.tabRicovero.Location = New System.Drawing.Point(4, 22)
        Me.tabRicovero.Name = "tabRicovero"
        Me.tabRicovero.Size = New System.Drawing.Size(622, 323)
        Me.tabRicovero.TabIndex = 5
        Me.tabRicovero.Text = "Ricovero"
        Me.tabRicovero.UseVisualStyleBackColor = True
        '
        'Label23
        '
        Me.Label23.Location = New System.Drawing.Point(8, 171)
        Me.Label23.Name = "Label23"
        Me.Label23.Size = New System.Drawing.Size(85, 29)
        Me.Label23.TabIndex = 89
        Me.Label23.Text = "Output: IdEst. Ev. usato"
        '
        'lblRicoveriDataEventoFormato
        '
        Me.lblRicoveriDataEventoFormato.Location = New System.Drawing.Point(261, 125)
        Me.lblRicoveriDataEventoFormato.Name = "lblRicoveriDataEventoFormato"
        Me.lblRicoveriDataEventoFormato.Size = New System.Drawing.Size(125, 16)
        Me.lblRicoveriDataEventoFormato.TabIndex = 88
        Me.lblRicoveriDataEventoFormato.Text = "(yyyy-MM-dd hh:mm:ss)"
        '
        'lblRicoveriDataSequenzaFormato
        '
        Me.lblRicoveriDataSequenzaFormato.Location = New System.Drawing.Point(261, 150)
        Me.lblRicoveriDataSequenzaFormato.Name = "lblRicoveriDataSequenzaFormato"
        Me.lblRicoveriDataSequenzaFormato.Size = New System.Drawing.Size(125, 16)
        Me.lblRicoveriDataSequenzaFormato.TabIndex = 87
        Me.lblRicoveriDataSequenzaFormato.Text = "(yyyy-MM-dd hh:mm:ss)"
        '
        'gbRicovero
        '
        Me.gbRicovero.Anchor = CType(((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Left) _
            Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.gbRicovero.Controls.Add(Me.cmdEventoSerializza)
        Me.gbRicovero.Location = New System.Drawing.Point(11, 223)
        Me.gbRicovero.Name = "gbRicovero"
        Me.gbRicovero.Size = New System.Drawing.Size(598, 89)
        Me.gbRicovero.TabIndex = 86
        Me.gbRicovero.TabStop = False
        Me.gbRicovero.Text = " Altre operazioni: "
        '
        'cmdEventoSerializza
        '
        Me.cmdEventoSerializza.Location = New System.Drawing.Point(15, 40)
        Me.cmdEventoSerializza.Name = "cmdEventoSerializza"
        Me.cmdEventoSerializza.Size = New System.Drawing.Size(140, 23)
        Me.cmdEventoSerializza.TabIndex = 83
        Me.cmdEventoSerializza.Text = "Serializza evento di test"
        '
        'txtIdEsternoEventoUtilizzato
        '
        Me.txtIdEsternoEventoUtilizzato.Location = New System.Drawing.Point(109, 173)
        Me.txtIdEsternoEventoUtilizzato.Name = "txtIdEsternoEventoUtilizzato"
        Me.txtIdEsternoEventoUtilizzato.ReadOnly = True
        Me.txtIdEsternoEventoUtilizzato.Size = New System.Drawing.Size(220, 20)
        Me.txtIdEsternoEventoUtilizzato.TabIndex = 85
        '
        'Label13
        '
        Me.Label13.Location = New System.Drawing.Point(270, 14)
        Me.Label13.Name = "Label13"
        Me.Label13.Size = New System.Drawing.Size(96, 16)
        Me.Label13.TabIndex = 84
        Me.Label13.Text = "Tipo evento"
        '
        'Label22
        '
        Me.Label22.Location = New System.Drawing.Point(7, 126)
        Me.Label22.Name = "Label22"
        Me.Label22.Size = New System.Drawing.Size(76, 16)
        Me.Label22.TabIndex = 82
        Me.Label22.Text = "Data evento"
        '
        'txtEventoRicoveroDataEvento
        '
        Me.txtEventoRicoveroDataEvento.Location = New System.Drawing.Point(109, 122)
        Me.txtEventoRicoveroDataEvento.Name = "txtEventoRicoveroDataEvento"
        Me.txtEventoRicoveroDataEvento.Size = New System.Drawing.Size(148, 20)
        Me.txtEventoRicoveroDataEvento.TabIndex = 81
        '
        'txtEventoRicoveroNosologico
        '
        Me.txtEventoRicoveroNosologico.Location = New System.Drawing.Point(109, 39)
        Me.txtEventoRicoveroNosologico.Name = "txtEventoRicoveroNosologico"
        Me.txtEventoRicoveroNosologico.Size = New System.Drawing.Size(114, 20)
        Me.txtEventoRicoveroNosologico.TabIndex = 73
        Me.txtEventoRicoveroNosologico.Text = "D09012123_TEST"
        '
        'Label12
        '
        Me.Label12.Location = New System.Drawing.Point(7, 42)
        Me.Label12.Name = "Label12"
        Me.Label12.Size = New System.Drawing.Size(96, 16)
        Me.Label12.TabIndex = 72
        Me.Label12.Text = "Nosologico"
        '
        'cboEventoRicoveroTipoEvento
        '
        Me.cboEventoRicoveroTipoEvento.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList
        Me.cboEventoRicoveroTipoEvento.Location = New System.Drawing.Point(372, 11)
        Me.cboEventoRicoveroTipoEvento.Name = "cboEventoRicoveroTipoEvento"
        Me.cboEventoRicoveroTipoEvento.Size = New System.Drawing.Size(148, 21)
        Me.cboEventoRicoveroTipoEvento.TabIndex = 71
        '
        'cmdLibAddEventoRicovero
        '
        Me.cmdLibAddEventoRicovero.Location = New System.Drawing.Point(482, 166)
        Me.cmdLibAddEventoRicovero.Name = "cmdLibAddEventoRicovero"
        Me.cmdLibAddEventoRicovero.Size = New System.Drawing.Size(110, 23)
        Me.cmdLibAddEventoRicovero.TabIndex = 69
        Me.cmdLibAddEventoRicovero.Text = "Esegui"
        '
        'Label6
        '
        Me.Label6.Location = New System.Drawing.Point(7, 149)
        Me.Label6.Name = "Label6"
        Me.Label6.Size = New System.Drawing.Size(96, 16)
        Me.Label6.TabIndex = 68
        Me.Label6.Text = "Data sequenza"
        Me.ToolTipManager.SetToolTip(Me.Label6, "Da compilare se si vuole simulare l'errore di data sequenza")
        '
        'txtEventoRicoveroDataSeq
        '
        Me.txtEventoRicoveroDataSeq.Location = New System.Drawing.Point(109, 147)
        Me.txtEventoRicoveroDataSeq.Name = "txtEventoRicoveroDataSeq"
        Me.txtEventoRicoveroDataSeq.Size = New System.Drawing.Size(148, 20)
        Me.txtEventoRicoveroDataSeq.TabIndex = 67
        Me.ToolTipManager.SetToolTip(Me.txtEventoRicoveroDataSeq, "Data sequenza: da compilare se si vuole simulare l'errore di data sequenza")
        '
        'Label7
        '
        Me.Label7.Location = New System.Drawing.Point(7, 16)
        Me.Label7.Name = "Label7"
        Me.Label7.Size = New System.Drawing.Size(96, 16)
        Me.Label7.TabIndex = 66
        Me.Label7.Text = "Tipo operazione"
        '
        'cboTipoPostEventoRicovero
        '
        Me.cboTipoPostEventoRicovero.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList
        Me.cboTipoPostEventoRicovero.Location = New System.Drawing.Point(109, 11)
        Me.cboTipoPostEventoRicovero.Name = "cboTipoPostEventoRicovero"
        Me.cboTipoPostEventoRicovero.Size = New System.Drawing.Size(148, 21)
        Me.cboTipoPostEventoRicovero.TabIndex = 65
        '
        'Label8
        '
        Me.Label8.Location = New System.Drawing.Point(8, 94)
        Me.Label8.Name = "Label8"
        Me.Label8.Size = New System.Drawing.Size(90, 16)
        Me.Label8.TabIndex = 64
        Me.Label8.Text = "Nome anagrafica"
        '
        'txtEventoRicoveroNomeAnagrafica
        '
        Me.txtEventoRicoveroNomeAnagrafica.Location = New System.Drawing.Point(109, 94)
        Me.txtEventoRicoveroNomeAnagrafica.Name = "txtEventoRicoveroNomeAnagrafica"
        Me.txtEventoRicoveroNomeAnagrafica.Size = New System.Drawing.Size(112, 20)
        Me.txtEventoRicoveroNomeAnagrafica.TabIndex = 63
        Me.txtEventoRicoveroNomeAnagrafica.Text = "TEST"
        '
        'Label9
        '
        Me.Label9.Location = New System.Drawing.Point(228, 97)
        Me.Label9.Name = "Label9"
        Me.Label9.Size = New System.Drawing.Size(96, 16)
        Me.Label9.TabIndex = 62
        Me.Label9.Text = "Codice anagrafica"
        '
        'txtEventoRicoveroCodiceAnagrafica
        '
        Me.txtEventoRicoveroCodiceAnagrafica.Location = New System.Drawing.Point(330, 94)
        Me.txtEventoRicoveroCodiceAnagrafica.Name = "txtEventoRicoveroCodiceAnagrafica"
        Me.txtEventoRicoveroCodiceAnagrafica.Size = New System.Drawing.Size(112, 20)
        Me.txtEventoRicoveroCodiceAnagrafica.TabIndex = 61
        Me.txtEventoRicoveroCodiceAnagrafica.Text = "0000000007"
        '
        'txtEventoRicoveroIdEsternoEvento
        '
        Me.txtEventoRicoveroIdEsternoEvento.Location = New System.Drawing.Point(372, 39)
        Me.txtEventoRicoveroIdEsternoEvento.Name = "txtEventoRicoveroIdEsternoEvento"
        Me.txtEventoRicoveroIdEsternoEvento.Size = New System.Drawing.Size(220, 20)
        Me.txtEventoRicoveroIdEsternoEvento.TabIndex = 60
        Me.ToolTipManager.SetToolTip(Me.txtEventoRicoveroIdEsternoEvento, "L' IdEsternoEvento va impostato quando si desidera " & Global.Microsoft.VisualBasic.ChrW(13) & Global.Microsoft.VisualBasic.ChrW(10) & "aggiornare/rimuovere un even" & _
        "to esistente")
        '
        'Label10
        '
        Me.Label10.Location = New System.Drawing.Point(270, 41)
        Me.Label10.Name = "Label10"
        Me.Label10.Size = New System.Drawing.Size(96, 16)
        Me.Label10.TabIndex = 59
        Me.Label10.Text = "IdEsterno evento"
        Me.ToolTipManager.SetToolTip(Me.Label10, "L' IdEsternoEvento va impostato quando si desidera " & Global.Microsoft.VisualBasic.ChrW(13) & Global.Microsoft.VisualBasic.ChrW(10) & "aggiornare/rimuovere un even" & _
        "to esistente")
        '
        'Label11
        '
        Me.Label11.Location = New System.Drawing.Point(7, 68)
        Me.Label11.Name = "Label11"
        Me.Label11.Size = New System.Drawing.Size(100, 16)
        Me.Label11.TabIndex = 58
        Me.Label11.Text = "IdEsterno paziente"
        '
        'txtEventoRicoveroIdEsternoPaziente
        '
        Me.txtEventoRicoveroIdEsternoPaziente.Location = New System.Drawing.Point(109, 65)
        Me.txtEventoRicoveroIdEsternoPaziente.Name = "txtEventoRicoveroIdEsternoPaziente"
        Me.txtEventoRicoveroIdEsternoPaziente.Size = New System.Drawing.Size(114, 20)
        Me.txtEventoRicoveroIdEsternoPaziente.TabIndex = 57
        Me.txtEventoRicoveroIdEsternoPaziente.Text = "TEST_0000000007"
        '
        'tabEpisodio_XML
        '
        Me.tabEpisodio_XML.Controls.Add(Me.txtEpisodio_XML_IdEsternoPrecedente)
        Me.tabEpisodio_XML.Controls.Add(Me.Label43)
        Me.tabEpisodio_XML.Controls.Add(Me.chkEpisodio_XML_UsaMetodoEpisodio2)
        Me.tabEpisodio_XML.Controls.Add(Me.Label31)
        Me.tabEpisodio_XML.Controls.Add(Me.Label28)
        Me.tabEpisodio_XML.Controls.Add(Me.Label30)
        Me.tabEpisodio_XML.Controls.Add(Me.txtEpisodio_XML_DataSequenza)
        Me.tabEpisodio_XML.Controls.Add(Me.Label27)
        Me.tabEpisodio_XML.Controls.Add(Me.cboTipoPostEpisodio_XML)
        Me.tabEpisodio_XML.Controls.Add(Me.cmdEpisodio_XML_Esegui)
        Me.tabEpisodio_XML.Controls.Add(Me.txtEpisodio_XML_Xml)
        Me.tabEpisodio_XML.Location = New System.Drawing.Point(4, 22)
        Me.tabEpisodio_XML.Name = "tabEpisodio_XML"
        Me.tabEpisodio_XML.Padding = New System.Windows.Forms.Padding(3)
        Me.tabEpisodio_XML.Size = New System.Drawing.Size(622, 323)
        Me.tabEpisodio_XML.TabIndex = 6
        Me.tabEpisodio_XML.Text = "Episodio-XML"
        Me.tabEpisodio_XML.UseVisualStyleBackColor = True
        '
        'txtEpisodio_XML_IdEsternoPrecedente
        '
        Me.txtEpisodio_XML_IdEsternoPrecedente.Location = New System.Drawing.Point(140, 74)
        Me.txtEpisodio_XML_IdEsternoPrecedente.Name = "txtEpisodio_XML_IdEsternoPrecedente"
        Me.txtEpisodio_XML_IdEsternoPrecedente.Size = New System.Drawing.Size(148, 20)
        Me.txtEpisodio_XML_IdEsternoPrecedente.TabIndex = 65
        Me.ToolTipManager.SetToolTip(Me.txtEpisodio_XML_IdEsternoPrecedente, "Data sequenza: da compilare se si vuole simulare l'errore di data sequenza")
        '
        'Label43
        '
        Me.Label43.AutoSize = True
        Me.Label43.Location = New System.Drawing.Point(7, 76)
        Me.Label43.Name = "Label43"
        Me.Label43.Size = New System.Drawing.Size(107, 13)
        Me.Label43.TabIndex = 64
        Me.Label43.Text = "IdEsternoPrecedente"
        '
        'chkEpisodio_XML_UsaMetodoEpisodio2
        '
        Me.chkEpisodio_XML_UsaMetodoEpisodio2.AutoSize = True
        Me.chkEpisodio_XML_UsaMetodoEpisodio2.Location = New System.Drawing.Point(297, 76)
        Me.chkEpisodio_XML_UsaMetodoEpisodio2.Name = "chkEpisodio_XML_UsaMetodoEpisodio2"
        Me.chkEpisodio_XML_UsaMetodoEpisodio2.Size = New System.Drawing.Size(138, 17)
        Me.chkEpisodio_XML_UsaMetodoEpisodio2.TabIndex = 63
        Me.chkEpisodio_XML_UsaMetodoEpisodio2.Text = "Usa metodo Episodio2()"
        Me.chkEpisodio_XML_UsaMetodoEpisodio2.UseVisualStyleBackColor = True
        '
        'Label31
        '
        Me.Label31.Location = New System.Drawing.Point(7, 101)
        Me.Label31.Name = "Label31"
        Me.Label31.Size = New System.Drawing.Size(96, 16)
        Me.Label31.TabIndex = 62
        Me.Label31.Text = "Xml:"
        Me.ToolTipManager.SetToolTip(Me.Label31, "Data sequenza: da compilare se si vuole simulare l'errore di data sequenza")
        '
        'Label28
        '
        Me.Label28.Location = New System.Drawing.Point(294, 48)
        Me.Label28.Name = "Label28"
        Me.Label28.Size = New System.Drawing.Size(125, 16)
        Me.Label28.TabIndex = 61
        Me.Label28.Text = "(yyyy-MM-dd hh:mm:ss)"
        '
        'Label30
        '
        Me.Label30.Location = New System.Drawing.Point(7, 46)
        Me.Label30.Name = "Label30"
        Me.Label30.Size = New System.Drawing.Size(85, 16)
        Me.Label30.TabIndex = 60
        Me.Label30.Text = "Data sequenza"
        Me.ToolTipManager.SetToolTip(Me.Label30, "Data sequenza: da compilare se si vuole simulare l'errore di data sequenza")
        '
        'txtEpisodio_XML_DataSequenza
        '
        Me.txtEpisodio_XML_DataSequenza.Location = New System.Drawing.Point(140, 45)
        Me.txtEpisodio_XML_DataSequenza.Name = "txtEpisodio_XML_DataSequenza"
        Me.txtEpisodio_XML_DataSequenza.Size = New System.Drawing.Size(148, 20)
        Me.txtEpisodio_XML_DataSequenza.TabIndex = 59
        Me.ToolTipManager.SetToolTip(Me.txtEpisodio_XML_DataSequenza, "Data sequenza: da compilare se si vuole simulare l'errore di data sequenza")
        '
        'Label27
        '
        Me.Label27.Location = New System.Drawing.Point(7, 16)
        Me.Label27.Name = "Label27"
        Me.Label27.Size = New System.Drawing.Size(96, 16)
        Me.Label27.TabIndex = 54
        Me.Label27.Text = "Tipo operazione"
        '
        'cboTipoPostEpisodio_XML
        '
        Me.cboTipoPostEpisodio_XML.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList
        Me.cboTipoPostEpisodio_XML.Items.AddRange(New Object() {"Aggiunge", "Modifica", "Rimuove"})
        Me.cboTipoPostEpisodio_XML.Location = New System.Drawing.Point(140, 13)
        Me.cboTipoPostEpisodio_XML.Name = "cboTipoPostEpisodio_XML"
        Me.cboTipoPostEpisodio_XML.Size = New System.Drawing.Size(148, 21)
        Me.cboTipoPostEpisodio_XML.TabIndex = 53
        '
        'cmdEpisodio_XML_Esegui
        '
        Me.cmdEpisodio_XML_Esegui.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.cmdEpisodio_XML_Esegui.Location = New System.Drawing.Point(513, 41)
        Me.cmdEpisodio_XML_Esegui.Name = "cmdEpisodio_XML_Esegui"
        Me.cmdEpisodio_XML_Esegui.Size = New System.Drawing.Size(89, 23)
        Me.cmdEpisodio_XML_Esegui.TabIndex = 1
        Me.cmdEpisodio_XML_Esegui.Text = "Esegui"
        Me.cmdEpisodio_XML_Esegui.UseVisualStyleBackColor = True
        '
        'txtEpisodio_XML_Xml
        '
        Me.txtEpisodio_XML_Xml.Anchor = CType((((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Bottom) _
            Or System.Windows.Forms.AnchorStyles.Left) _
            Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.txtEpisodio_XML_Xml.Location = New System.Drawing.Point(10, 121)
        Me.txtEpisodio_XML_Xml.MaxLength = 2500000
        Me.txtEpisodio_XML_Xml.Multiline = True
        Me.txtEpisodio_XML_Xml.Name = "txtEpisodio_XML_Xml"
        Me.txtEpisodio_XML_Xml.ScrollBars = System.Windows.Forms.ScrollBars.Both
        Me.txtEpisodio_XML_Xml.Size = New System.Drawing.Size(598, 196)
        Me.txtEpisodio_XML_Xml.TabIndex = 0
        '
        'tabRicovero_XML
        '
        Me.tabRicovero_XML.Controls.Add(Me.cmdRicovero2Esegui)
        Me.tabRicovero_XML.Controls.Add(Me.Label35)
        Me.tabRicovero_XML.Controls.Add(Me.Label36)
        Me.tabRicovero_XML.Controls.Add(Me.txtEventoRicovero2DataSeq)
        Me.tabRicovero_XML.Controls.Add(Me.Label34)
        Me.tabRicovero_XML.Controls.Add(Me.txtEventoRicovero2Xml)
        Me.tabRicovero_XML.Controls.Add(Me.Label33)
        Me.tabRicovero_XML.Controls.Add(Me.cboTipoPostEventoRicovero2)
        Me.tabRicovero_XML.Location = New System.Drawing.Point(4, 22)
        Me.tabRicovero_XML.Name = "tabRicovero_XML"
        Me.tabRicovero_XML.Size = New System.Drawing.Size(622, 323)
        Me.tabRicovero_XML.TabIndex = 7
        Me.tabRicovero_XML.Text = "Ricovero-XML"
        Me.tabRicovero_XML.UseVisualStyleBackColor = True
        '
        'cmdRicovero2Esegui
        '
        Me.cmdRicovero2Esegui.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.cmdRicovero2Esegui.Location = New System.Drawing.Point(516, 41)
        Me.cmdRicovero2Esegui.Name = "cmdRicovero2Esegui"
        Me.cmdRicovero2Esegui.Size = New System.Drawing.Size(89, 23)
        Me.cmdRicovero2Esegui.TabIndex = 94
        Me.cmdRicovero2Esegui.Text = "Esegui"
        Me.cmdRicovero2Esegui.UseVisualStyleBackColor = True
        '
        'Label35
        '
        Me.Label35.Location = New System.Drawing.Point(258, 46)
        Me.Label35.Name = "Label35"
        Me.Label35.Size = New System.Drawing.Size(125, 16)
        Me.Label35.TabIndex = 93
        Me.Label35.Text = "(yyyy-MM-dd hh:mm:ss)"
        '
        'Label36
        '
        Me.Label36.Location = New System.Drawing.Point(7, 45)
        Me.Label36.Name = "Label36"
        Me.Label36.Size = New System.Drawing.Size(85, 16)
        Me.Label36.TabIndex = 92
        Me.Label36.Text = "Data sequenza"
        Me.ToolTipManager.SetToolTip(Me.Label36, "Da compilare se si vuole simulare l'errore di data sequenza")
        '
        'txtEventoRicovero2DataSeq
        '
        Me.txtEventoRicovero2DataSeq.Location = New System.Drawing.Point(104, 43)
        Me.txtEventoRicovero2DataSeq.Name = "txtEventoRicovero2DataSeq"
        Me.txtEventoRicovero2DataSeq.Size = New System.Drawing.Size(148, 20)
        Me.txtEventoRicovero2DataSeq.TabIndex = 91
        Me.ToolTipManager.SetToolTip(Me.txtEventoRicovero2DataSeq, "Data sequenza: da compilare se si vuole simulare l'errore di data sequenza")
        '
        'Label34
        '
        Me.Label34.Location = New System.Drawing.Point(7, 73)
        Me.Label34.Name = "Label34"
        Me.Label34.Size = New System.Drawing.Size(96, 16)
        Me.Label34.TabIndex = 90
        Me.Label34.Text = "Xml:"
        Me.ToolTipManager.SetToolTip(Me.Label34, "Data sequenza: da compilare se si vuole simulare l'errore di data sequenza")
        '
        'txtEventoRicovero2Xml
        '
        Me.txtEventoRicovero2Xml.Anchor = CType((((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Bottom) _
            Or System.Windows.Forms.AnchorStyles.Left) _
            Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.txtEventoRicovero2Xml.Location = New System.Drawing.Point(7, 95)
        Me.txtEventoRicovero2Xml.MaxLength = 65536
        Me.txtEventoRicovero2Xml.Multiline = True
        Me.txtEventoRicovero2Xml.Name = "txtEventoRicovero2Xml"
        Me.txtEventoRicovero2Xml.ScrollBars = System.Windows.Forms.ScrollBars.Both
        Me.txtEventoRicovero2Xml.Size = New System.Drawing.Size(598, 216)
        Me.txtEventoRicovero2Xml.TabIndex = 89
        '
        'Label33
        '
        Me.Label33.Location = New System.Drawing.Point(7, 16)
        Me.Label33.Name = "Label33"
        Me.Label33.Size = New System.Drawing.Size(96, 16)
        Me.Label33.TabIndex = 86
        Me.Label33.Text = "Tipo operazione"
        '
        'cboTipoPostEventoRicovero2
        '
        Me.cboTipoPostEventoRicovero2.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList
        Me.cboTipoPostEventoRicovero2.Location = New System.Drawing.Point(104, 13)
        Me.cboTipoPostEventoRicovero2.Name = "cboTipoPostEventoRicovero2"
        Me.cboTipoPostEventoRicovero2.Size = New System.Drawing.Size(148, 21)
        Me.cboTipoPostEventoRicovero2.TabIndex = 85
        '
        'tabProveDiCarico
        '
        Me.tabProveDiCarico.Controls.Add(Me.txtProveCaricorefertiThreadrandomDelayMax)
        Me.tabProveDiCarico.Controls.Add(Me.Label42)
        Me.tabProveDiCarico.Controls.Add(Me.txtErroriProvaDiCaricoReferti)
        Me.tabProveDiCarico.Controls.Add(Me.cmdProveCaricoSelectRefertoTemplate)
        Me.tabProveDiCarico.Controls.Add(Me.txtProveCaricoTemplateReferto)
        Me.tabProveDiCarico.Controls.Add(Me.Label41)
        Me.tabProveDiCarico.Controls.Add(Me.cmdProveCaricoRefertiEsegui)
        Me.tabProveDiCarico.Controls.Add(Me.txtProveCaricoNumMaxReferti)
        Me.tabProveDiCarico.Controls.Add(Me.Label40)
        Me.tabProveDiCarico.Location = New System.Drawing.Point(4, 22)
        Me.tabProveDiCarico.Name = "tabProveDiCarico"
        Me.tabProveDiCarico.Size = New System.Drawing.Size(622, 323)
        Me.tabProveDiCarico.TabIndex = 9
        Me.tabProveDiCarico.Text = "Prove di Carico Referti"
        Me.tabProveDiCarico.UseVisualStyleBackColor = True
        '
        'txtProveCaricorefertiThreadrandomDelayMax
        '
        Me.txtProveCaricorefertiThreadrandomDelayMax.Location = New System.Drawing.Point(391, 15)
        Me.txtProveCaricorefertiThreadrandomDelayMax.Name = "txtProveCaricorefertiThreadrandomDelayMax"
        Me.txtProveCaricorefertiThreadrandomDelayMax.Size = New System.Drawing.Size(49, 20)
        Me.txtProveCaricorefertiThreadrandomDelayMax.TabIndex = 8
        Me.txtProveCaricorefertiThreadrandomDelayMax.Text = "10"
        '
        'Label42
        '
        Me.Label42.AutoSize = True
        Me.Label42.Location = New System.Drawing.Point(228, 18)
        Me.Label42.Name = "Label42"
        Me.Label42.Size = New System.Drawing.Size(157, 13)
        Me.Label42.TabIndex = 7
        Me.Label42.Text = "Thread  random delay max (ms):"
        '
        'txtErroriProvaDiCaricoReferti
        '
        Me.txtErroriProvaDiCaricoReferti.Anchor = CType((((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Bottom) _
            Or System.Windows.Forms.AnchorStyles.Left) _
            Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.txtErroriProvaDiCaricoReferti.Location = New System.Drawing.Point(22, 79)
        Me.txtErroriProvaDiCaricoReferti.Multiline = True
        Me.txtErroriProvaDiCaricoReferti.Name = "txtErroriProvaDiCaricoReferti"
        Me.txtErroriProvaDiCaricoReferti.ReadOnly = True
        Me.txtErroriProvaDiCaricoReferti.ScrollBars = System.Windows.Forms.ScrollBars.Both
        Me.txtErroriProvaDiCaricoReferti.Size = New System.Drawing.Size(582, 226)
        Me.txtErroriProvaDiCaricoReferti.TabIndex = 6
        '
        'cmdProveCaricoSelectRefertoTemplate
        '
        Me.cmdProveCaricoSelectRefertoTemplate.Location = New System.Drawing.Point(495, 43)
        Me.cmdProveCaricoSelectRefertoTemplate.Name = "cmdProveCaricoSelectRefertoTemplate"
        Me.cmdProveCaricoSelectRefertoTemplate.Size = New System.Drawing.Size(28, 23)
        Me.cmdProveCaricoSelectRefertoTemplate.TabIndex = 5
        Me.cmdProveCaricoSelectRefertoTemplate.Text = "..."
        Me.cmdProveCaricoSelectRefertoTemplate.UseVisualStyleBackColor = True
        '
        'txtProveCaricoTemplateReferto
        '
        Me.txtProveCaricoTemplateReferto.Location = New System.Drawing.Point(140, 45)
        Me.txtProveCaricoTemplateReferto.Name = "txtProveCaricoTemplateReferto"
        Me.txtProveCaricoTemplateReferto.Size = New System.Drawing.Size(339, 20)
        Me.txtProveCaricoTemplateReferto.TabIndex = 4
        '
        'Label41
        '
        Me.Label41.AutoSize = True
        Me.Label41.Location = New System.Drawing.Point(19, 47)
        Me.Label41.Name = "Label41"
        Me.Label41.Size = New System.Drawing.Size(104, 13)
        Me.Label41.TabIndex = 3
        Me.Label41.Text = "Template del referto:"
        '
        'cmdProveCaricoRefertiEsegui
        '
        Me.cmdProveCaricoRefertiEsegui.Location = New System.Drawing.Point(529, 43)
        Me.cmdProveCaricoRefertiEsegui.Name = "cmdProveCaricoRefertiEsegui"
        Me.cmdProveCaricoRefertiEsegui.Size = New System.Drawing.Size(75, 23)
        Me.cmdProveCaricoRefertiEsegui.TabIndex = 2
        Me.cmdProveCaricoRefertiEsegui.Text = "Esegui"
        Me.cmdProveCaricoRefertiEsegui.UseVisualStyleBackColor = True
        '
        'txtProveCaricoNumMaxReferti
        '
        Me.txtProveCaricoNumMaxReferti.Location = New System.Drawing.Point(140, 15)
        Me.txtProveCaricoNumMaxReferti.Name = "txtProveCaricoNumMaxReferti"
        Me.txtProveCaricoNumMaxReferti.Size = New System.Drawing.Size(49, 20)
        Me.txtProveCaricoNumMaxReferti.TabIndex = 1
        Me.txtProveCaricoNumMaxReferti.Text = "5"
        '
        'Label40
        '
        Me.Label40.AutoSize = True
        Me.Label40.Location = New System.Drawing.Point(19, 18)
        Me.Label40.Name = "Label40"
        Me.Label40.Size = New System.Drawing.Size(110, 13)
        Me.Label40.TabIndex = 0
        Me.Label40.Text = "Numero max di thread"
        '
        'Label5
        '
        Me.Label5.Location = New System.Drawing.Point(12, 16)
        Me.Label5.Name = "Label5"
        Me.Label5.Size = New System.Drawing.Size(96, 16)
        Me.Label5.TabIndex = 45
        Me.Label5.Text = "Azienda erogante"
        '
        'txtAziendaErogante
        '
        Me.txtAziendaErogante.Location = New System.Drawing.Point(156, 12)
        Me.txtAziendaErogante.Name = "txtAziendaErogante"
        Me.txtAziendaErogante.Size = New System.Drawing.Size(112, 20)
        Me.txtAziendaErogante.TabIndex = 44
        Me.txtAziendaErogante.Text = "ASMN"
        '
        'lblDllVersion
        '
        Me.lblDllVersion.AutoSize = True
        Me.lblDllVersion.Location = New System.Drawing.Point(306, 16)
        Me.lblDllVersion.Name = "lblDllVersion"
        Me.lblDllVersion.Size = New System.Drawing.Size(26, 13)
        Me.lblDllVersion.TabIndex = 46
        Me.lblDllVersion.Text = "Ver:"
        '
        'StatusStripMain
        '
        Me.StatusStripMain.Items.AddRange(New System.Windows.Forms.ToolStripItem() {Me.ToolStripConnectionInfo, Me.ToolStripIdentityInfo})
        Me.StatusStripMain.Location = New System.Drawing.Point(0, 573)
        Me.StatusStripMain.Name = "StatusStripMain"
        Me.StatusStripMain.Size = New System.Drawing.Size(650, 22)
        Me.StatusStripMain.TabIndex = 47
        '
        'ToolStripConnectionInfo
        '
        Me.ToolStripConnectionInfo.Font = New System.Drawing.Font("Segoe UI", 8.0!)
        Me.ToolStripConnectionInfo.Name = "ToolStripConnectionInfo"
        Me.ToolStripConnectionInfo.Size = New System.Drawing.Size(91, 17)
        Me.ToolStripConnectionInfo.Text = "Connection Info"
        '
        'ToolStripIdentityInfo
        '
        Me.ToolStripIdentityInfo.Name = "ToolStripIdentityInfo"
        Me.ToolStripIdentityInfo.Size = New System.Drawing.Size(68, 17)
        Me.ToolStripIdentityInfo.Text = "IdentityInfo"
        '
        'OpenFileDialog1
        '
        Me.OpenFileDialog1.FileName = "OpenFileDialog1"
        '
        'frmMain
        '
        Me.AutoScaleBaseSize = New System.Drawing.Size(5, 13)
        Me.ClientSize = New System.Drawing.Size(650, 595)
        Me.Controls.Add(Me.StatusStripMain)
        Me.Controls.Add(Me.lblDllVersion)
        Me.Controls.Add(Me.Label5)
        Me.Controls.Add(Me.txtAziendaErogante)
        Me.Controls.Add(Me.tabsTest)
        Me.Controls.Add(Me.lvTrace)
        Me.Name = "frmMain"
        Me.Text = "Test DataAccess Esterno"
        Me.tabsTest.ResumeLayout(False)
        Me.tabPazienti.ResumeLayout(False)
        Me.tabPazienti.PerformLayout()
        Me.gbPazienti.ResumeLayout(False)
        Me.gpPazientiDatiFusione.ResumeLayout(False)
        Me.gpPazientiDatiFusione.PerformLayout()
        Me.tabPazienti_XML.ResumeLayout(False)
        Me.tabPazienti_XML.PerformLayout()
        Me.tabEpisodio.ResumeLayout(False)
        Me.tabEpisodio.PerformLayout()
        Me.gbEpisodio.ResumeLayout(False)
        Me.tabRicovero.ResumeLayout(False)
        Me.tabRicovero.PerformLayout()
        Me.gbRicovero.ResumeLayout(False)
        Me.tabEpisodio_XML.ResumeLayout(False)
        Me.tabEpisodio_XML.PerformLayout()
        Me.tabRicovero_XML.ResumeLayout(False)
        Me.tabRicovero_XML.PerformLayout()
        Me.tabProveDiCarico.ResumeLayout(False)
        Me.tabProveDiCarico.PerformLayout()
        Me.StatusStripMain.ResumeLayout(False)
        Me.StatusStripMain.PerformLayout()
        Me.ResumeLayout(False)
        Me.PerformLayout()

    End Sub

#End Region

    Private msAnagraficaXmlTemplate_Aggiungi_Modifica As String
    Private msAnagraficaXmlTemplate_Fusione As String
    Private msEpisodioXmlTemplate As String
    Private moConfig As New RegConfig

    Private Sub frmMain_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Try
            '
            ' Connessione: visualizzo dati di connessione al Db Principale
            '
            ToolStripConnectionInfo.Text = ConnectionInfo(moConfig.ConnectionString)
            ToolStripConnectionInfo.ToolTipText = moConfig.ConnectionString
            '
            ' Application user
            '
            Dim sAppUser As String = System.Security.Principal.WindowsIdentity.GetCurrent().Name.ToString()
            ToolStripIdentityInfo.Text = String.Format("App.User: '{0}'", sAppUser)
            '
            ' Versione DLL
            '
            lblDllVersion.Text = GetDllVersion()
            '
            '
            '
            Call ConfigTabPazienti()
            '
            ' 
            '
            Call ConfigTabEpisodio()
            Call ConfigTabEpisodio_XML()
            '
            '
            '
            Call ConfigTabEventi() 'per tab Ricovero
            Call ConfigTabEventi2() 'per tab Ricovero2
            Call ConfigTabPazienti2() 'per tab Anagrafica2

            Try
                'Elimino poichè non mi servono le tab "tabPazienti" e "tabPazienti_XML" (la data access non gestisce più i pazienti)
                tabsTest.TabPages.RemoveByKey("tabPazienti")
                tabsTest.TabPages.RemoveByKey("tabPazienti_XML")
                'Elimino poichè non mi servono le tab "tabEpisodio" e "tabRicovero" (sostiuite dalle tab dove in input si fornisce l'XML del messaggio)
                tabsTest.TabPages.RemoveByKey("tabEpisodio")
                tabsTest.TabPages.RemoveByKey("tabRicovero")
            Catch
            End Try

        Catch ex As Exception
            Call MsgBox("Exception:" & vbCrLf & ex.Message)
        End Try

    End Sub

    Private Sub AddTrace(ByVal StartTime As Date, ByVal EndTime As Date, ByVal Descrizione As String)
        '
        ' Aggiunge un evento al trace
        '
        Try
            Dim lviTrace As ListViewItem

            Dim sTime As String = StartTime.ToString("hh:mm:ss fff")

            Dim tsDiff As TimeSpan = EndTime.Subtract(StartTime)
            Dim sTimeDiff As String = String.Format("{0} ms.", CType(tsDiff.TotalMilliseconds, Integer))

            lviTrace = lvTrace.Items.Add(sTime)
            lviTrace.SubItems.AddRange(New String() {sTimeDiff, Descrizione})

        Catch ex As Exception

        End Try

    End Sub

    Private Function GetDllVersion() As String
        '
        ' Legge versione della DLL
        '
        Dim oTypeConnV2 As Type = GetType(ConnectorV2)
        Dim oAssConnV2 As Assembly = oTypeConnV2.Assembly

        Dim oAssVers() As Object = oAssConnV2.GetCustomAttributes(GetType(AssemblyFileVersionAttribute), True)
        Dim oAssVerInfo As AssemblyFileVersionAttribute = CType(oAssVers(0), AssemblyFileVersionAttribute)

        Return String.Format("Ver DLL:{0}, da GAC={1}", oAssVerInfo.Version, oAssConnV2.GlobalAssemblyCache)

    End Function

#Region " Anagrafica "

    Private Sub ConfigTabPazienti()
        '
        ' Configurazioni per tab Pazienti
        '
        cboTipoPostAnagrafica.Items.Clear()
        cboTipoPostAnagrafica.Items.Add("Aggiunge")
        cboTipoPostAnagrafica.Items.Add("Modifica")
        cboTipoPostAnagrafica.Items.Add("Rimuove")
        cboTipoPostAnagrafica.Items.Add("Fusione")
        cboTipoPostAnagrafica.SelectedIndex = 0

        Call TabPazienti_LoadDataFromXml_Aggiungi_Modifica()

        gpPazientiDatiFusione.Location = lblPazientiNomeAnagrafica.Location

        gpPazientiDatiFusione.Visible = False
    End Sub

    Private Sub TabPazienti_LoadDataFromXml_Aggiungi_Modifica()
        Dim oAnagrafica As ConnectorV2.MessaggioAnagrafica = Nothing
        Dim oXmlDoc As Xml.XmlDocument = New Xml.XmlDocument

        msAnagraficaXmlTemplate_Aggiungi_Modifica = "MsgAnagraficaTest2.xml"
        'msAnagraficaXmlTemplate_Aggiungi_Modifica = "MsgAnagraficaFusione1.xml"


        oXmlDoc.Load(Application.StartupPath & "\" & msAnagraficaXmlTemplate_Aggiungi_Modifica)
        oAnagrafica = ConnectorV2.MessaggioAnagrafica.Deserialize(oXmlDoc.OuterXml)

        '
        ' Imposto i dati nell'interfaccia
        '
        txtPazientiCognome.Text = oAnagrafica.Cognome
        txtPazientiNome.Text = oAnagrafica.Nome
        txtPazientiCodiceFiscale.Text = oAnagrafica.CodiceFiscale
        txtPazientiDataNascita.Text = Date.Parse(oAnagrafica.DataNascita).ToString("yyyy-MM-dd")
        txtPazientiLuogoNascita.Text = oAnagrafica.LuogoNascita
        Try
            cmbPazientiSesso.SelectedIndex = cmbPazientiSesso.FindStringExact(oAnagrafica.Sesso.ToUpper)
        Catch
        End Try


        txtPazientiIdEsterno.Text = oAnagrafica.IdEsternoPaziente
        '
        ' Imposto Anagrafica e Codice Anagrafica con il primo riferimento presente 
        ' fra i riferimenti dell'XML diverso da quello dell'IdEsterno
        ' Questo per dare la possibilità (SOLO IN INSERIMENTO, la DLL funziona così)
        ' di modificare un riferimento
        '
        For Each oRiferimento As ConnectorV2.Riferimento In oAnagrafica.Riferimenti
            If (oRiferimento.Nome & "_" & oRiferimento.Valore).ToUpper <> oAnagrafica.IdEsternoPaziente.ToUpper Then
                txtPazientiNomeAnagrafica.Text = oRiferimento.Nome
                txtPazientiCodiceAnagrafica.Text = oRiferimento.Valore
                Exit For
            End If
        Next

    End Sub


    Private Sub LoadDataFromXml_Fusione()
        Dim oAnagrafica As ConnectorV2.MessaggioAnagrafica = Nothing
        Dim oXmlDoc As Xml.XmlDocument = New Xml.XmlDocument

        msAnagraficaXmlTemplate_Fusione = "MsgAnagraficaFusione1.xml"

        oXmlDoc.Load(Application.StartupPath & "\" & msAnagraficaXmlTemplate_Fusione)
        oAnagrafica = ConnectorV2.MessaggioAnagrafica.Deserialize(oXmlDoc.OuterXml)

        '
        ' Imposto i dati nell'interfaccia
        '
        txtPazientiCognome.Text = oAnagrafica.Cognome
        txtPazientiNome.Text = oAnagrafica.Nome
        txtPazientiCodiceFiscale.Text = oAnagrafica.CodiceFiscale
        txtPazientiDataNascita.Text = Date.Parse(oAnagrafica.DataNascita).ToString("yyyy-MM-dd")
        txtPazientiLuogoNascita.Text = oAnagrafica.LuogoNascita
        Try
            cmbPazientiSesso.SelectedIndex = cmbPazientiSesso.FindStringExact(oAnagrafica.Sesso.ToUpper)
        Catch
        End Try

        txtPazientiIdEsterno.Text = oAnagrafica.IdEsternoPaziente
        '
        ' Imposto Anagrafica e Codice Anagrafica con il primo riferimento presente 
        ' fra i riferimenti dell'XML diverso da quello dell'IdEsterno
        ' Questo per dare la possibilità (SOLO IN INSERIMENTO, la DLL funziona così)
        ' di modificare un riferimento
        '
        For Each oRiferimento As ConnectorV2.Riferimento In oAnagrafica.Riferimenti
            If (oRiferimento.Nome & "_" & oRiferimento.Valore).ToUpper <> oAnagrafica.IdEsternoPaziente.ToUpper Then
                txtPazientiNomeAnagrafica.Text = oRiferimento.Nome
                txtPazientiCodiceAnagrafica.Text = oRiferimento.Valore
                Exit For
            End If
        Next

    End Sub



    Private Sub cmdAddConsenso_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdAddConsenso.Click

        Dim oLibV2 As ConnectorV2
        '
        ' Trace
        '
        Dim dtStart As Date
        dtStart = Date.Now
        AddTrace(dtStart, dtStart, "Start")

        Try
            '
            ' Login ai web service
            '
            oLibV2 = New ConnectorV2
            '
            ' Setta dati
            '
            Dim sIdEsternoPaziente As String = txtPazientiIdEsterno.Text

            Dim oPaziente As New ConnectorV2.Paziente(sIdEsternoPaziente, _
                                                        txtPazientiCodiceAnagrafica.Text, _
                                                        txtPazientiNomeAnagrafica.Text)

            Dim oMessaggio As New ConnectorV2.MessaggioConsenso("CON_" & sIdEsternoPaziente, _
                                                                        txtAziendaErogante.Text, _
                                                                        "TEST", _
                                                                        Date.Now.ToString("s"), _
                                                                        (Rnd() > 0.5), _
                                                                        "SANDRO", _
                                                                        "Alessandro Nostini", _
                                                                        oPaziente)

            oLibV2.Consenso(ConnectorV2.TipoMessaggio.Aggiunge, oMessaggio)
            '
            ' Trace
            '
            AddTrace(dtStart, Date.Now, "Esegue DLL oLibV2.Consenso()")
            dtStart = Date.Now

            MessageBox.Show("Aggiunto coonsenso completato!", Me.Text, MessageBoxButtons.OK, MessageBoxIcon.Information)

        Catch ex As Exception
            '
            ' Eccezzione generica
            '
            Call MsgBox("Exception:" & vbCrLf & ex.Message)

        End Try

    End Sub

    Private Sub cmdAddAnagrafica_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdAddAnagrafica.Click
        cmdAddAnagrafica.Enabled = False
        Dim oLibV2 As ConnectorV2
        '
        ' 
        '
        oLibV2 = New ConnectorV2
        '
        ' Tipo messaggio
        '
        Try
            Dim enTipoMessaggio As ConnectorV2.TipoMessaggio

            Try
                Dim sTipoPost As String = cboTipoPostAnagrafica.SelectedItem
                Select Case sTipoPost.ToLower
                    Case "aggiunge"
                        enTipoMessaggio = ConnectorV2.TipoMessaggio.Aggiunge

                    Case "modifica"
                        enTipoMessaggio = ConnectorV2.TipoMessaggio.Modifica

                    Case "rimuove"
                        enTipoMessaggio = ConnectorV2.TipoMessaggio.Rimuove

                    Case "fusione"
                        enTipoMessaggio = ConnectorV2.TipoMessaggio.Fusione

                    Case Else
                        enTipoMessaggio = ConnectorV2.TipoMessaggio.Aggiunge
                End Select
            Catch ex As Exception
                enTipoMessaggio = ConnectorV2.TipoMessaggio.Modifica
            End Try
            '
            ' Setta dati
            '
            Dim sIdEsternoPaziente As String = txtPazientiIdEsterno.Text
            '*******************************************************************************************************************
            '
            ' Riferimento
            '
            'Dim oRiferimenti() As ConnectorV2.Riferimento = Nothing

            'If txtPazienteNomeAnagrafica.Text.Length > 0 Then
            '    Dim oRifPaziente As New ConnectorV2.Riferimento(txtPazienteNomeAnagrafica.Text, _
            '                                                    txtPazienteCodiceAnagrafica.Text)
            '    oRiferimenti = New ConnectorV2.Riferimento() {oRifPaziente}
            'End If
            ''
            '' Setta alcuni dati
            ''
            'Dim oAnagrafica As New ConnectorV2.MessaggioAnagrafica(sIdEsternoPaziente, _
            '                                                             "ASMN", "LHA", "", _
            '                                                            "Rossi", "Mario", "M", _
            '                                                            #10/12/1957#, "Vicenza", "RSSMRA57F12G912R", _
            '                                                            "", "", oRiferimenti)
            '*******************************************************************************************************************

            Dim oAnagrafica As ConnectorV2.MessaggioAnagrafica = Nothing
            Dim oXmlDoc As Xml.XmlDocument = New Xml.XmlDocument
            If enTipoMessaggio = ConnectorV2.TipoMessaggio.Fusione Then
                '
                ' Se sto facendo fusione prendo i dati da XML
                '
                oXmlDoc.Load(Application.StartupPath & "\MsgAnagraficaFusione1.xml")
                oAnagrafica = ConnectorV2.MessaggioAnagrafica.Deserialize(oXmlDoc.OuterXml)
                '
                ' Riporto nell'oggetto oAnagrafica eventuali modifiche fatte da interfaccia
                ' 
                oAnagrafica.Cognome = txtPazientiCognome.Text
                oAnagrafica.Nome = txtPazientiNome.Text
                oAnagrafica.CodiceFiscale = txtPazientiCodiceFiscale.Text
                oAnagrafica.DataNascita = txtPazientiDataNascita.Text
                oAnagrafica.LuogoNascita = txtPazientiLuogoNascita.Text
                Try
                    oAnagrafica.Sesso = cmbPazientiSesso.SelectedItem.ToString
                Catch
                    oAnagrafica.Sesso = ""
                End Try
                oAnagrafica.IdEsternoPaziente = txtPazientiIdEsterno.Text
                '
                ' Leggo il riferimento anagrafico del paziente da fondere 
                ' e lo aggiungo ai riferimenti del paziente se già non esiste
                '
                Dim sNomeAnagrafica As String = txtPazientiFusioneNomeAnagrafica.Text.ToUpper
                Dim sCodiceAnagrafica As String = txtPazientiFusioneCodiceAnagrafica.Text.ToUpper
                Dim bExistRiferimento As Boolean = False
                For Each oRif As ConnectorV2.Riferimento In oAnagrafica.Riferimenti
                    If String.Compare(sNomeAnagrafica, oRif.Nome, True) = 0 AndAlso _
                        String.Compare(sCodiceAnagrafica, oRif.Valore, True) = 0 Then
                        bExistRiferimento = True
                        Exit For
                    End If
                Next
                If Not bExistRiferimento Then
                    '
                    ' Lo aggiungo a quelli esistenti...
                    '
                    Dim oRif(oAnagrafica.Riferimenti.GetUpperBound(0) + 1) As ConnectorV2.Riferimento
                    Array.Copy(oAnagrafica.Riferimenti, oRif, oAnagrafica.Riferimenti.GetLength(0))
                    oRif(oRif.GetUpperBound(0)) = New ConnectorV2.Riferimento(sNomeAnagrafica, sCodiceAnagrafica)
                    '
                    ' Sostituisco
                    '
                    oAnagrafica.Riferimenti = oRif
                End If

            ElseIf enTipoMessaggio = ConnectorV2.TipoMessaggio.Aggiunge OrElse _
                    enTipoMessaggio = ConnectorV2.TipoMessaggio.Modifica Then

                oXmlDoc.Load(Application.StartupPath & "\" & msAnagraficaXmlTemplate_Aggiungi_Modifica)
                oAnagrafica = ConnectorV2.MessaggioAnagrafica.Deserialize(oXmlDoc.OuterXml)

                oAnagrafica.Cognome = txtPazientiCognome.Text
                oAnagrafica.Nome = txtPazientiNome.Text
                oAnagrafica.CodiceFiscale = txtPazientiCodiceFiscale.Text
                oAnagrafica.DataNascita = txtPazientiDataNascita.Text
                oAnagrafica.LuogoNascita = txtPazientiLuogoNascita.Text
                Try
                    oAnagrafica.Sesso = cmbPazientiSesso.SelectedItem.ToString
                Catch
                    oAnagrafica.Sesso = ""
                End Try
                oAnagrafica.IdEsternoPaziente = txtPazientiIdEsterno.Text

                '
                ' Ricreo i riferimenti: uno per l'IdEsterno e l'altro quello scritto in interfaccia
                '
                Dim sNomeAnagrafica As String = txtPazientiIdEsterno.Text.Substring(0, txtPazientiIdEsterno.Text.LastIndexOf("_"c))
                Dim sCodiceAnagrafica As String = txtPazientiIdEsterno.Text.Substring(txtPazientiIdEsterno.Text.LastIndexOf("_"c) + 1)
                '
                ' se le anagrafiche sono differenti ...
                '
                If String.Compare(sNomeAnagrafica, txtPazientiNomeAnagrafica.Text, True) = 0 AndAlso _
                        String.Compare(sCodiceAnagrafica, txtPazientiCodiceAnagrafica.Text, True) = 0 Then
                    Dim oRif(0) As ConnectorV2.Riferimento
                    oRif(0) = New ConnectorV2.Riferimento(txtPazientiNomeAnagrafica.Text, txtPazientiCodiceAnagrafica.Text)
                    oAnagrafica.Riferimenti = oRif
                Else
                    Dim oRif(1) As ConnectorV2.Riferimento
                    oRif(0) = New ConnectorV2.Riferimento(sNomeAnagrafica, sCodiceAnagrafica)
                    oRif(1) = New ConnectorV2.Riferimento(txtPazientiNomeAnagrafica.Text, txtPazientiCodiceAnagrafica.Text)
                    oAnagrafica.Riferimenti = oRif
                End If

            ElseIf enTipoMessaggio = ConnectorV2.TipoMessaggio.Rimuove Then
                '
                ' Rimuovo usando l'idEsterno fornito da interfaccia
                ' Creo un messaggio, non hanno importanza i dati anagrafici 
                ' la DLL utilizza solo l'IdEsterno per eseguire lem operazioni su database...
                '
                oAnagrafica = New ConnectorV2.MessaggioAnagrafica(sIdEsternoPaziente, "", "", "", "", "", "", Nothing, "", "", "", "")

            End If

            Dim dtDataSeq As DateTime
            If txtPazientiDataSeqAnagrafica.Text.Length = 0 Then
                dtDataSeq = Date.Now
            Else
                dtDataSeq = Date.Parse(txtPazientiDataSeqAnagrafica.Text)
            End If

            '
            ' Trace
            '
            Dim dtStart As Date
            dtStart = Date.Now
            AddTrace(dtStart, dtStart, "Start")


            oLibV2.Anagrafica(enTipoMessaggio, dtDataSeq, oAnagrafica)
            ' ''
            ' '' Aggiunge una seconda con referimento alla prima
            ' ''
            ''Dim oRiferimenti2() As ConnectorV2.Riferimento
            ''oRiferimenti2 = New ConnectorV2.Riferimento() {oAnagrafica.Riferimenti(0), _
            ''                                               New ConnectorV2.Riferimento(txtPazienteNomeAnagrafica.Text, _
            ''                                                                            txtPazienteCodiceAnagrafica.Text & "_2")}
            ''oAnagrafica.IdEsternoPaziente &= "_2"
            ''oAnagrafica.Riferimenti = oRiferimenti2
            ''oLibV2.Anagrafica(enTipoMessaggio, dtDataSeq, oAnagrafica)

            '
            ' Test serializza
            '
            'Dim sAnag As String = ConnectorV2.MessaggioAnagrafica.Serialize(oAnagrafica)
            'Dim oAnag As ConnectorV2.MessaggioAnagrafica = ConnectorV2.MessaggioAnagrafica.Deserialize(sAnag)
            '
            ' Trace
            '
            AddTrace(dtStart, Date.Now, "Esegue DLL oLibV2.Consenso()")
            dtStart = Date.Now

            MessageBox.Show("Anagrafica - Operazione completata!", Me.Text, MessageBoxButtons.OK, MessageBoxIcon.Information)

        Catch ex As Exception
            '
            ' Eccezione generica
            '
            Call MsgBox("Exception:" & vbCrLf & ex.Message)
        Finally
            cmdAddAnagrafica.Enabled = True
        End Try

    End Sub

    Private Sub cboTipoPostAnagrafica_SelectedIndexChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cboTipoPostAnagrafica.SelectedIndexChanged
        '
        ' Default
        '
        txtPazientiDataSeqAnagrafica.Enabled = True
        txtPazientiCodiceAnagrafica.Enabled = True
        txtPazientiNomeAnagrafica.Enabled = True
        txtPazientiCognome.Enabled = True
        txtPazientiNome.Enabled = True
        txtPazientiCodiceFiscale.Enabled = True
        txtPazientiLuogoNascita.Enabled = True
        cmbPazientiSesso.Enabled = True
        txtPazientiDataNascita.Enabled = True

        gpPazientiDatiFusione.Visible = False

        lblPazientiCodiceAnagrafica.Visible = True
        txtPazientiCodiceAnagrafica.Visible = True
        lblPazientiNomeAnagrafica.Visible = True
        txtPazientiNomeAnagrafica.Visible = True

        '
        '
        '
        Dim sOperazione As String = cboTipoPostAnagrafica.SelectedItem.ToString.ToUpper
        If sOperazione = "RIMUOVE" Then

            txtPazientiDataSeqAnagrafica.Enabled = False
            txtPazientiCodiceAnagrafica.Enabled = False
            txtPazientiNomeAnagrafica.Enabled = False
            txtPazientiCognome.Enabled = False
            txtPazientiNome.Enabled = False
            txtPazientiCodiceFiscale.Enabled = False
            txtPazientiLuogoNascita.Enabled = False
            cmbPazientiSesso.Enabled = False
            txtPazientiDataNascita.Enabled = False

        ElseIf sOperazione = "FUSIONE" Then

            lblPazientiCodiceAnagrafica.Visible = False
            txtPazientiCodiceAnagrafica.Visible = False
            lblPazientiNomeAnagrafica.Visible = False
            txtPazientiNomeAnagrafica.Visible = False

            gpPazientiDatiFusione.Visible = True

            Call LoadDataFromXml_Fusione()

        ElseIf sOperazione = "AGGIUNGE" Then

            Call TabPazienti_LoadDataFromXml_Aggiungi_Modifica()

        ElseIf sOperazione = "MODIFICA" Then

            Call TabPazienti_LoadDataFromXml_Aggiungi_Modifica()

        End If


    End Sub


#End Region

#Region " Episodio/Referto "

    Private Sub ConfigTabEpisodio_XML()
        '
        ' Configurazioni per tab Episodio XML
        '
        cboTipoPostEpisodio_XML.Items.Clear()
        cboTipoPostEpisodio_XML.Items.Add("Aggiunge")
        cboTipoPostEpisodio_XML.Items.Add("Modifica")
        cboTipoPostEpisodio_XML.Items.Add("Rimuove")
        cboTipoPostEpisodio_XML.SelectedIndex = 0
    End Sub

    Private Sub ConfigTabEpisodio()
        '
        ' Configurazioni per tab Episodio
        '
        cboTipoPostEpisodio.Items.Clear()
        cboTipoPostEpisodio.Items.Add("Aggiunge")
        cboTipoPostEpisodio.Items.Add("Modifica")
        cboTipoPostEpisodio.Items.Add("Rimuove")
        cboTipoPostEpisodio.SelectedIndex = 0

        Call TabEpisodio_LoadDataFromXml()
    End Sub

    Private Sub TabEpisodio_LoadDataFromXml()
        Dim oEpisodio As ConnectorV2.MessaggioEpisodio = Nothing
        Dim oXmlDoc As Xml.XmlDocument = New Xml.XmlDocument

        msEpisodioXmlTemplate = "MsgEpisodio2.xml"

        oXmlDoc.Load(Application.StartupPath & "\" & msEpisodioXmlTemplate)
        oEpisodio = ConnectorV2.MessaggioEpisodio.Deserialize(oXmlDoc.OuterXml)
        '
        ' Imposto i dati nell'interfaccia
        '
        txtEpisodioIdEsternoReferto.Text = oEpisodio.Referto.IdEsternoReferto
        'txtEpisodioDataReferto.Text = Date.Parse(oEpisodio.Referto.DataReferto).ToString("yyyy-MM-dd hh:mm:ss")

        txtEpisodioIdEsternoPaziente.Text = oEpisodio.Paziente.IdEsternoPaziente
        txtEpisodioNomeAnagrafica.Text = oEpisodio.Paziente.NomeAnagraficaCentrale
        txtEpisodioCodiceAnagrafica.Text = oEpisodio.Paziente.CodiceAnagraficaCentrale

    End Sub

    Private Sub cmdLibAddEpisodio_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdLibAddEpisodio.Click
        cmdLibAddEpisodio.Enabled = False
        Dim oLibV2 As ConnectorV2
        '
        ' Trace
        '
        Dim dtStart As Date
        dtStart = Date.Now
        AddTrace(dtStart, dtStart, "Start")
        '
        ' Tipo messaggio
        '
        Try
            '
            ' Setta dati
            '
            Dim enTipoMessaggio As ConnectorV2.TipoMessaggio

            Try
                Dim sTipoPostEpisodio As String = cboTipoPostEpisodio.SelectedItem
                Select Case sTipoPostEpisodio.ToLower
                    Case "aggiunge"
                        enTipoMessaggio = ConnectorV2.TipoMessaggio.Aggiunge

                    Case "modifica"
                        enTipoMessaggio = ConnectorV2.TipoMessaggio.Modifica

                    Case "rimuove"
                        enTipoMessaggio = ConnectorV2.TipoMessaggio.Rimuove

                    Case Else
                        enTipoMessaggio = ConnectorV2.TipoMessaggio.Aggiunge
                End Select
            Catch ex As Exception
                enTipoMessaggio = ConnectorV2.TipoMessaggio.Aggiunge
            End Try

            Dim sIdEsternoReferto As String = txtEpisodioIdEsternoReferto.Text
            Dim sIdEsternoPaziente As String = txtEpisodioIdEsternoPaziente.Text
            Dim sCodiceAnagrafica As String = txtEpisodioCodiceAnagrafica.Text
            Dim sNomeAnagrafica As String = txtEpisodioNomeAnagrafica.Text
            Dim sAziendaErogante As String = txtAziendaErogante.Text
            '
            ' Leggo file
            '
            Dim sDir As String = Application.StartupPath

            Dim oXmlDoc As Xml.XmlDocument = New Xml.XmlDocument

            'oXmlDoc.Load(sDir & "\MsgEpisodio_Annullamento.xml") 'pone StatoRichiestaCodice=3=Annullato
            'oXmlDoc.Load(sDir & "\MsgEpisodio1.xml")
            oXmlDoc.Load(sDir & "\" & msEpisodioXmlTemplate)

            Dim oMessagioEpisodio As ConnectorV2.MessaggioEpisodio
            oMessagioEpisodio = ConnectorV2.MessaggioEpisodio.Deserialize(oXmlDoc.OuterXml)

            oMessagioEpisodio.Referto.AziendaErogante = sAziendaErogante
            oMessagioEpisodio.Referto.IdEsternoReferto = sIdEsternoReferto
            If enTipoMessaggio = ConnectorV2.TipoMessaggio.Aggiunge OrElse _
                enTipoMessaggio = ConnectorV2.TipoMessaggio.Modifica Then
                '
                ' Imposto eventualmente la data del referto
                '
                If txtEpisodioDataReferto.Text.Length > 0 Then
                    oMessagioEpisodio.Referto.DataReferto = Date.Parse(txtEpisodioDataReferto.Text)
                End If
            End If

            oMessagioEpisodio.Paziente.NomeAnagraficaCentrale = sNomeAnagrafica
            oMessagioEpisodio.Paziente.CodiceAnagraficaCentrale = sCodiceAnagrafica
            oMessagioEpisodio.Paziente.IdEsternoPaziente = sIdEsternoPaziente

            '
            ' Compongo messaggio
            '
            oLibV2 = New ConnectorV2

            Dim oRetEpisodio As ConnectorV2.Risultato

            Dim dtDataSeq As DateTime
            If txtEpisodioDataSeq.Text.Length = 0 Then
                dtDataSeq = Date.Now
            Else
                dtDataSeq = Date.Parse(txtEpisodioDataSeq.Text)
            End If

            oRetEpisodio = oLibV2.Episodio(enTipoMessaggio, dtDataSeq, oMessagioEpisodio)
            '
            ' Trace
            '
            AddTrace(dtStart, Date.Now, "Esegue ConnectorV2.Episodio()")
            dtStart = Date.Now

            If oRetEpisodio.ErrorNumber = 0 Then
                MessageBox.Show("Episodio - Operazione completata!", Me.Text, MessageBoxButtons.OK, MessageBoxIcon.Information)
            Else
                MessageBox.Show("Episodio - Errore: Err # " & oRetEpisodio.ErrorNumber & ", " & oRetEpisodio.ErrorDescription, Me.Text, MessageBoxButtons.OK, MessageBoxIcon.Error)
            End If

        Catch ex As Exception
            '
            ' Eccezzione generica
            '
            Call MsgBox("Exception:" & vbCrLf & ex.Message)
        Finally
            cmdLibAddEpisodio.Enabled = True
        End Try

    End Sub

    Private Sub cmdEpisodioSerializza_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdEpisodioSerializza.Click

        Dim sIdEsternoReferto As String = txtEpisodioIdEsternoReferto.Text
        Dim sIdEsternoPaziente As String = txtEpisodioIdEsternoPaziente.Text
        Dim sCodiceAnagrafica As String = txtEpisodioCodiceAnagrafica.Text
        Dim sNomeAnagrafica As String = txtEpisodioNomeAnagrafica.Text

        Dim oMessagioEpisodio As New ConnectorV2.MessaggioEpisodio
        Dim oPaziente As New ConnectorV2.Paziente
        Dim oReferto As New ConnectorV2.Referto
        Dim oPrestazione1 As New ConnectorV2.Prestazione
        Dim oPrestazione2 As New ConnectorV2.Prestazione
        '
        ' Dati episodio
        '
        oMessagioEpisodio.StileVisualizzazione = "Gen01.00"
        oMessagioEpisodio.DatiSoloPerCercare = False
        '
        ' Dati paziente
        '
        oPaziente.IdEsternoPaziente = sIdEsternoPaziente
        oPaziente.Cognome = "Topone"
        oPaziente.Nome = "Ciccio"
        oPaziente.Sesso = "M"
        oPaziente.DataNascita = "2001-10-24"
        oPaziente.LuogoNascita = "Bologna"
        oPaziente.CodiceFiscale = "CCCTPN45ngr356g"
        oPaziente.CodiceSanitario = "12345678"
        oPaziente.NomeAnagraficaCentrale = sNomeAnagrafica
        oPaziente.CodiceAnagraficaCentrale = sCodiceAnagrafica

        Dim oPazienteAttributi1 As New ConnectorV2.Attributo
        oPazienteAttributi1.Nome = "LuogoResidenza"
        oPazienteAttributi1.Valore = "San Giorgio di Piano"

        Dim oPazienteAttributi2 As New ConnectorV2.Attributo
        oPazienteAttributi2.Nome = "IndirizzoResidenza"
        oPazienteAttributi2.Valore = "Via XX Settembre, 14"

        oPaziente.Attributi = New ConnectorV2.Attributo() {oPazienteAttributi1, oPazienteAttributi2}
        '
        ' Dati referto
        '
        oReferto.IdEsternoReferto = sIdEsternoReferto
        oReferto.AziendaErogante = txtAziendaErogante.Text
        oReferto.SistemaErogante = "TEST"
        oReferto.RepartoErogante = "REP1"
        oReferto.SezioneErogante = "SEZ1"
        oReferto.SpecialitaErogante = "SPEC1"
        oReferto.DataReferto = DateTime.Now.ToString("s")
        oReferto.NumeroReferto = "10222"
        oReferto.NumeroPrenotazione = "20001"
        oReferto.NumeroNosologico = "32300"
        oReferto.PrioritaCodice = "1"
        oReferto.PrioritaDescrizione = "Normale"
        oReferto.StatoRichiestaCodice = "R"
        oReferto.StatoRichiestaDescrizione = "Routine"
        oReferto.TipoRichiestaCodice = "U"
        oReferto.TipoRichiestaDescrizione = "Urgente"
        oReferto.RepartoRichiedenteCodice = "CARD1"
        oReferto.RepartoRichiedenteDescrizione = "Cardiologia1"
        oReferto.MedicoRefertanteCodice = "PP"
        oReferto.MedicoRefertanteDescrizione = "Pinco Pallo"

        Dim oRefertoAttributi1 As New ConnectorV2.Attributo
        oRefertoAttributi1.Nome = "Referto"
        oRefertoAttributi1.Valore = "Niente di rotto"

        oReferto.Attributi = New ConnectorV2.Attributo() {oRefertoAttributi1}
        '
        ' Dati prestazione
        '
        oPrestazione1.IdEsternoPrestazione = "TEST_0001"
        oPrestazione1.DataErogazione = DateTime.Now.ToString("s")
        oPrestazione1.PrestazioneCodice = "PRES1"
        oPrestazione1.PrestazioneDescrizione = "Prestazione 1"
        oPrestazione1.PrestazionePosizione = 1
        oPrestazione1.SezioneCodice = "Sez1"
        oPrestazione1.SezioneDescrizione = "Sezione uno"
        oPrestazione1.SezionePosizione = 1
        oPrestazione1.GravitaCodice = "N"
        oPrestazione1.GravitaDescrizione = "Normale"
        oPrestazione1.Quantita = "10"
        oPrestazione1.Risultato = "50"
        oPrestazione1.ValoriRiferimento = "> 100"
        oPrestazione1.PrestazioneCommenti = ""

        Dim oPrestazione1Attributi1 As New ConnectorV2.Attributo
        oPrestazione1Attributi1.Nome = "CodiceIstat"
        oPrestazione1Attributi1.Valore = "3354"

        oPrestazione1.Attributi = New ConnectorV2.Attributo() {oPrestazione1Attributi1}

        oPrestazione2.IdEsternoPrestazione = "TEST_0002"
        oPrestazione2.DataErogazione = DateTime.Now.ToString("s")
        oPrestazione2.PrestazioneCodice = "PRES2"
        oPrestazione2.PrestazioneDescrizione = "Prestazione 2"
        oPrestazione2.PrestazionePosizione = 2
        oPrestazione2.SezioneCodice = "Sez2"
        oPrestazione2.SezioneDescrizione = "Sezione due"
        oPrestazione2.SezionePosizione = 2
        oPrestazione2.GravitaCodice = "N"
        oPrestazione2.GravitaDescrizione = "Normale"
        oPrestazione2.Quantita = "13"
        oPrestazione2.Risultato = "107"
        oPrestazione2.ValoriRiferimento = "< 200"
        oPrestazione2.PrestazioneCommenti = "Fuori scala"
        oPrestazione2.Attributi = Nothing
        '
        ' Compongo messaggio
        '
        oMessagioEpisodio.Referto = oReferto
        oMessagioEpisodio.Paziente = oPaziente
        oMessagioEpisodio.Prestazioni = New ConnectorV2.Prestazione() {oPrestazione1, oPrestazione2}
        oMessagioEpisodio.StileVisualizzazione = "Test.1.0.1"
        oMessagioEpisodio.DatiSoloPerCercare = False

        Dim sXmlMessagio As String
        Dim oMessagioEpisodio2 As ConnectorV2.MessaggioEpisodio
        '
        ' Serializzo e deserializzo
        '
        sXmlMessagio = ConnectorV2.MessaggioEpisodio.Serialize(oMessagioEpisodio)
        oMessagioEpisodio2 = ConnectorV2.MessaggioEpisodio.Deserialize(sXmlMessagio)

        MsgBox("Oprazione completata!")

    End Sub

    Private Sub cboTipoPostEpisodio_SelectedIndexChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cboTipoPostEpisodio.SelectedIndexChanged
        If cboTipoPostEpisodio.SelectedItem.ToString.ToUpper = "RIMUOVE" Then
            txtEpisodioDataSeq.Enabled = False
            txtEpisodioIdEsternoPaziente.Enabled = False
            txtEpisodioNomeAnagrafica.Enabled = False
            txtEpisodioCodiceAnagrafica.Enabled = False
            txtEpisodioDataReferto.Enabled = False
        Else
            txtEpisodioDataSeq.Enabled = True
            txtEpisodioIdEsternoPaziente.Enabled = True
            txtEpisodioNomeAnagrafica.Enabled = True
            txtEpisodioCodiceAnagrafica.Enabled = True
            txtEpisodioDataReferto.Enabled = True
        End If
    End Sub

#End Region

#Region " Eventi ricovero ADT "

    Private Sub ConfigTabEventi()
        '
        ' Configurazioni per tab Eventi
        '

        '
        ' Tipo di operazione
        '
        cboTipoPostEventoRicovero.Items.Clear()
        cboTipoPostEventoRicovero.Items.Add("Aggiornamento")
        cboTipoPostEventoRicovero.Items.Add("Rimozione")
        '
        ' Seleziono il primo tipo di operazione
        '
        cboTipoPostEventoRicovero.SelectedIndex = 0

        '
        ' I tipi di eventi
        '
        cboEventoRicoveroTipoEvento.Items.Clear()
        ' Eventi ricovero
        cboEventoRicoveroTipoEvento.Items.Add("A - (Accettazione)")
        cboEventoRicoveroTipoEvento.Items.Add("T - (Trasferimento)")
        cboEventoRicoveroTipoEvento.Items.Add("D - (Dimissione)")
        ' Eventi ricovero - Azioni
        cboEventoRicoveroTipoEvento.Items.Add("X - (Annullamento)")
        cboEventoRicoveroTipoEvento.Items.Add("E - (Erase)")
        cboEventoRicoveroTipoEvento.Items.Add("M - (Merge)")
        cboEventoRicoveroTipoEvento.Items.Add("R - (Riapertura)")
        '
        ' Seleziono il primo tipo di evento
        '
        cboEventoRicoveroTipoEvento.SelectedIndex = 0

    End Sub

    Private Sub cmdLibAddEventoRicovero_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdLibAddEventoRicovero.Click
        cmdLibAddEventoRicovero.Enabled = False
        Dim sIdEsternoEvento As String = ""
        Dim sIdPazienteEsternoFuso As String = ""
        Dim sCodiceAnagraficaPazienteFuso As String = ""
        Dim sNomeAnagraficaPazienteFuso As String = ""
        Dim sTipoCodiceEvento As String = ""

        Dim dtDataEvento As Date = Nothing

        Dim sSistemaErogante As String = "ADT"  'Fissato
        Dim oXmlDoc As Xml.XmlDocument = Nothing
        Dim oLibV2 As ConnectorV2
        '
        ' Trace
        '
        Dim dtStart As Date
        dtStart = Date.Now
        AddTrace(dtStart, dtStart, "Start")
        '
        ' Tipo messaggio
        '
        Try
            If txtEventoRicoveroNosologico.Text.Length = 0 Then
                Throw New Exception("Impostare il numero nosologico!")
            End If
            '
            ' Imposto la data dell'evento
            '
            If txtEventoRicoveroDataEvento.Text.Length > 0 Then
                dtDataEvento = Date.Parse(txtEventoRicoveroDataEvento.Text, New System.Globalization.CultureInfo("it-it"))
            Else
                dtDataEvento = dtStart
            End If
            '
            ' Folder in cui trovo il documento XML con i dati
            '
            Dim sDir As String = Application.StartupPath
            oXmlDoc = New Xml.XmlDocument
            '
            ' Definisco l'IdEsterno dell'evento
            '
            sIdEsternoEvento = sSistemaErogante & "_" & _
                              txtEventoRicoveroNosologico.Text & "_" & _
                              dtDataEvento.ToString("yyyyddMMhhmmss")
            '
            ' Setta dati
            '
            Dim enTipoMessaggio As ConnectorV2.TipoMessaggioEvento

            sTipoCodiceEvento = cboEventoRicoveroTipoEvento.SelectedItem.ToString.Substring(0, 1).ToUpper

            Dim sTipoPostEventoRicovero As String = cboTipoPostEventoRicovero.SelectedItem
            Select Case sTipoPostEventoRicovero.ToLower
                Case "aggiornamento"
                    enTipoMessaggio = ConnectorV2.TipoMessaggioEvento.Aggiornamento
                    '
                    ' Determino l'IdEsterno dell'evento
                    '
                    sIdEsternoEvento = sIdEsternoEvento & "_" & sTipoCodiceEvento
                    '
                    ' Carico dati xml
                    '
                    Select Case sTipoCodiceEvento
                        Case "A", "D"
                            oXmlDoc.Load(sDir & "\MsgRicoveroEvento.xml")
                        Case "T"
                            oXmlDoc.Load(sDir & "\MsgRicoveroEventoT.xml")
                        Case "X", "R", "E"
                            oXmlDoc.Load(sDir & "\MsgRicoveroEvento.xml")
                        Case "M"
                            oXmlDoc.Load(sDir & "\MsgRicoveroFusione.xml")
                        Case Else
                            Throw New Exception("Tipo di evento non valido!")
                    End Select
                    '
                    ' Lo fornisco io l'Id esterno dell'evento
                    '
                    If txtEventoRicoveroIdEsternoEvento.Text.Length > 0 Then
                        '
                        ' Update di un evento: deve essere un Id esterno esistente nel db
                        '
                        sIdEsternoEvento = txtEventoRicoveroIdEsternoEvento.Text
                    End If
                Case "rimozione"

                    enTipoMessaggio = ConnectorV2.TipoMessaggioEvento.Rimozione
                    oXmlDoc.Load(sDir & "\MsgRicoveroEvento.xml") 'serve solo per non dare errore
                    '
                    ' L'Idsterno lo prendo dall'intefaccia
                    '
                    sIdEsternoEvento = txtEventoRicoveroIdEsternoEvento.Text
                    If Trim(sIdEsternoEvento) = "" Then
                        MsgBox("L'IdEsterno dell'evento non è stato fornito!", MsgBoxStyle.Information)
                        Exit Sub
                    End If
            End Select
            '
            ' Visualizzo l'IdEsterno dell'evento utilizzato nell'esecuzione
            '
            txtIdEsternoEventoUtilizzato.Text = sIdEsternoEvento
            '
            '
            '
            Dim sIdEsternoPaziente As String = txtEventoRicoveroIdEsternoPaziente.Text
            Dim sCodiceAnagrafica As String = txtEventoRicoveroCodiceAnagrafica.Text
            Dim sNomeAnagrafica As String = txtEventoRicoveroNomeAnagrafica.Text
            Dim sAziendaErogante As String = txtAziendaErogante.Text

            Dim oMessaggioEvento As ConnectorV2.MessaggioEvento
            '
            ' Carico i dati XML del documento nella classe
            '
            oMessaggioEvento = ConnectorV2.MessaggioEvento.Deserialize(oXmlDoc.OuterXml)
            '
            ' Sovrascrivo campi del messaggio con i dati provenienti dall'interfaccia
            '
            oMessaggioEvento.Evento.AziendaErogante = sAziendaErogante
            oMessaggioEvento.Evento.IdEsternoEvento = sIdEsternoEvento
            '
            ' Solo nel caso di fuzione
            '
            If sTipoCodiceEvento <> "M" And enTipoMessaggio = ConnectorV2.TipoMessaggioEvento.Aggiornamento Then
                '
                ' Sovrascrivo i dati per impostare i valori del paziente fuso provenienti dall'interfaccia
                '
                oMessaggioEvento.Paziente.NomeAnagraficaCentrale = sNomeAnagrafica
                oMessaggioEvento.Paziente.CodiceAnagraficaCentrale = sCodiceAnagrafica
                oMessaggioEvento.Paziente.IdEsternoPaziente = sIdEsternoPaziente
            ElseIf enTipoMessaggio = ConnectorV2.TipoMessaggioEvento.Rimozione Then
                oMessaggioEvento.Paziente.IdEsternoPaziente = sIdEsternoPaziente
            Else
                'Uso quelli documento xml: uguali a quelli del paziente fuso
            End If

            '
            ' Data dell'evento 
            '
            oMessaggioEvento.Evento.DataEvento = dtDataEvento.ToString("yyyy-MM-dd HH:mm:ss", New System.Globalization.CultureInfo("en-US"))
            '
            ' Imposto TipoEvento (A,T,D) o (M,X,R,E)
            '
            oMessaggioEvento.Evento.TipoEventoCodice = sTipoCodiceEvento

            '
            ' Imposto il tipo di Episodio: I = Ricovero Ordinario solo per Evento di Accettazione
            '
            oMessaggioEvento.Evento.TipoEpisodio = Nothing
            If oMessaggioEvento.Evento.TipoEventoCodice.ToUpper = "A" Then
                oMessaggioEvento.Evento.TipoEpisodio = "O"
            End If
            '
            ' Cancello campi non sempre valorizzati
            '

            If oMessaggioEvento.Evento.TipoEventoCodice.ToUpper <> "A" Then
                oMessaggioEvento.Evento.Diagnosi = Nothing
            End If
            If oMessaggioEvento.Evento.TipoEventoCodice.ToUpper = "A" OrElse _
                oMessaggioEvento.Evento.TipoEventoCodice.ToUpper = "T" Then
                '
                ' Genero codici e descrizioni Random
                '
                Dim oRand As New Random(Now.Millisecond)
                Dim i As Integer = oRand.Next(0, 20)

                Dim sCodice As String = ""

                sCodice = "RRC-" & oRand.Next(1, 10).ToString
                oMessaggioEvento.Evento.RepartoCodice = sCodice
                oMessaggioEvento.Evento.RepartoDescrizione = sCodice & " Descrizione"

                If oMessaggioEvento.Evento.TipoEventoCodice.ToUpper = "T" Then
                    oRand = New Random(Now.Millisecond)
                    i = oRand.Next(0, 100)
                    For j As Integer = 0 To oMessaggioEvento.Evento.Attributi.GetUpperBound(0)
                        Select Case oMessaggioEvento.Evento.Attributi(j).Nome
                            Case "SettoreCodice"
                                oMessaggioEvento.Evento.Attributi(j).Valore = "Settore" & i.ToString
                            Case "SettoreDescr"
                                oMessaggioEvento.Evento.Attributi(j).Valore = "Settore" & i.ToString & "-desc"
                            Case "LettoCodice"
                                oMessaggioEvento.Evento.Attributi(j).Valore = "Letto" & oRand.Next(0, 100).ToString
                        End Select
                    Next
                End If

            Else
                oMessaggioEvento.Evento.RepartoCodice = Nothing
                oMessaggioEvento.Evento.RepartoDescrizione = Nothing
            End If


            oMessaggioEvento.Evento.NumeroNosologico = txtEventoRicoveroNosologico.Text
            '
            ' Compongo messaggio
            '
            oLibV2 = New ConnectorV2

            Dim oRetEvento As ConnectorV2.Risultato

            Dim dtDataSeq As DateTime
            '
            ' Assumo che la data sequenza sia la data dell'evento!!!!!
            '
            If txtEventoRicoveroDataSeq.Text.Length = 0 Then
                dtDataSeq = Date.Now
            Else
                dtDataSeq = Date.Parse(txtEventoRicoveroDataSeq.Text)
            End If

            oRetEvento = oLibV2.Ricovero(enTipoMessaggio, dtDataSeq, oMessaggioEvento)
            '
            ' Trace
            '
            AddTrace(dtStart, Date.Now, "Esegue ConnectorV2.Ricovero()")
            dtStart = Date.Now

            If oRetEvento.ErrorNumber = 0 Then
                MessageBox.Show("Ricoveri - Operazione completata!", Me.Text, MessageBoxButtons.OK, MessageBoxIcon.Information)
            Else
                MessageBox.Show("Ricoveri - Errore: Err # " & oRetEvento.ErrorNumber & ", " & oRetEvento.ErrorDescription, Me.Text, MessageBoxButtons.OK, MessageBoxIcon.Error)
            End If

        Catch ex As Exception
            '
            ' Eccezione generica
            '
            Call MsgBox("Exception:" & vbCrLf & ex.Message)
        Finally
            cmdLibAddEventoRicovero.Enabled = True
        End Try

    End Sub

    Private Sub cmdEventoSerializza_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdEventoSerializza.Click

        Dim sSistemaErogante As String = "TEST"
        Dim sNumeroNosologico As String = "32300"
        Dim sIdEsternoPaziente As String = txtEventoRicoveroIdEsternoPaziente.Text
        Dim sCodiceAnagrafica As String = txtEventoRicoveroCodiceAnagrafica.Text
        Dim sNomeAnagrafica As String = txtEventoRicoveroNomeAnagrafica.Text

        Dim oMessagioEpisodio As New ConnectorV2.MessaggioEvento
        Dim oPaziente As New ConnectorV2.Paziente
        Dim oEvento As New ConnectorV2.Evento
        '
        ' Dati paziente
        '
        oPaziente.IdEsternoPaziente = sIdEsternoPaziente
        oPaziente.Cognome = "Topone"
        oPaziente.Nome = "Ciccio"
        oPaziente.Sesso = "M"
        oPaziente.DataNascita = "2001-10-24T00:00:00"
        oPaziente.LuogoNascita = "Bologna"
        oPaziente.CodiceFiscale = "CCCTPN45ngr356g"
        oPaziente.CodiceSanitario = "12345678"
        oPaziente.NomeAnagraficaCentrale = sNomeAnagrafica
        oPaziente.CodiceAnagraficaCentrale = sCodiceAnagrafica

        '
        ' Attributi anagrafici obbligatori per evento di Accettazione (TipoEventoCodice=A)
        '
        Dim oPazienteAttributi1 As ConnectorV2.Attributo = New ConnectorV2.Attributo("CodiceAnagraficaCentrale", oPaziente.CodiceAnagraficaCentrale)
        Dim oPazienteAttributi2 As ConnectorV2.Attributo = New ConnectorV2.Attributo("NomeAnagraficaCentrale", oPaziente.NomeAnagraficaCentrale)
        Dim oPazienteAttributi3 As ConnectorV2.Attributo = New ConnectorV2.Attributo("Cognome", oPaziente.Cognome)
        Dim oPazienteAttributi4 As ConnectorV2.Attributo = New ConnectorV2.Attributo("Nome", oPaziente.Nome)
        Dim oPazienteAttributi5 As ConnectorV2.Attributo = New ConnectorV2.Attributo("Sesso", oPaziente.Sesso)
        Dim oPazienteAttributi6 As ConnectorV2.Attributo = New ConnectorV2.Attributo("DataNascita", oPaziente.DataNascita)
        Dim oPazienteAttributi7 As ConnectorV2.Attributo = New ConnectorV2.Attributo("ComuneNascita", oPaziente.LuogoNascita)
        Dim oPazienteAttributi8 As ConnectorV2.Attributo = New ConnectorV2.Attributo("CodiceFiscale", oPaziente.CodiceFiscale)
        Dim oPazienteAttributi9 As ConnectorV2.Attributo = New ConnectorV2.Attributo("CodiceSanitario", oPaziente.CodiceSanitario)
        '
        ' Attributi in più...
        '
        Dim oPazienteAttributi10 As ConnectorV2.Attributo = New ConnectorV2.Attributo("IndirizzoResidenza", "Via XX Settembre, 14")
        Dim oPazienteAttributi11 As ConnectorV2.Attributo = New ConnectorV2.Attributo("LuogoResidenza", "San Giorgio di Piano")

        oPaziente.Attributi = New ConnectorV2.Attributo() {oPazienteAttributi1, oPazienteAttributi2, oPazienteAttributi3, _
                                                           oPazienteAttributi4, oPazienteAttributi5, oPazienteAttributi6, _
                                                          oPazienteAttributi7, oPazienteAttributi8, oPazienteAttributi9, _
                                                          oPazienteAttributi10, oPazienteAttributi11}
        '
        ' Dati evento
        '
        oEvento.TipoEpisodio = "I"
        '
        '
        '
        Select Case cboTipoPostEventoRicovero.SelectedItem.ToString.ToLower
            Case "aggiornamento"
                oEvento.TipoEventoCodice = cboEventoRicoveroTipoEvento.SelectedItem.ToString.ToUpper
            Case "annullamento"
                oEvento.TipoEventoCodice = "X"
            Case "rimozione"
                oEvento.TipoEventoCodice = "E"
            Case "fusione"
                oEvento.TipoEventoCodice = "M"
            Case "riapertura"
                oEvento.TipoEventoCodice = "R"
            Case Else
                Throw New Exception("Tipo di evento non valido!")
        End Select


        oEvento.IdEsternoEvento = sSistemaErogante & "_" & sNumeroNosologico & "_" & Now.ToString("yyyyddMMhhmmss")

        oEvento.AziendaErogante = txtAziendaErogante.Text
        oEvento.SistemaErogante = sSistemaErogante
        oEvento.RepartoErogante = "REP1"
        oEvento.DataEvento = DateTime.Now.ToString("s")
        oEvento.NumeroNosologico = sNumeroNosologico

        oEvento.RepartoCodice = "CARD1"
        oEvento.RepartoDescrizione = "Cardiologia1"

        '
        ' Attributi dell'evento
        '
        Dim oEventoAttributi1 As New ConnectorV2.Attributo("Nome1", "Nome1_Valore")
        Dim oEventoAttributi2 As New ConnectorV2.Attributo("Nome2", "Nome2_Valore")
        Dim oEventoAttributi3 As New ConnectorV2.Attributo("Nome3", "Nome3_Valore")

        oEvento.Attributi = New ConnectorV2.Attributo() {oEventoAttributi1, oEventoAttributi2, oEventoAttributi3}

        '
        ' Compongo messaggio
        '
        oMessagioEpisodio.Evento = oEvento
        oMessagioEpisodio.Paziente = oPaziente

        Dim sXmlMessagio As String
        '
        ' Serializzo
        '
        sXmlMessagio = ConnectorV2.MessaggioEvento.Serialize(oMessagioEpisodio)
        '
        ' Deserializzo
        '
        Dim oMessagioEvento2 As ConnectorV2.MessaggioEvento
        oMessagioEvento2 = ConnectorV2.MessaggioEvento.Deserialize(sXmlMessagio)

        MsgBox("Operazione completata!")
    End Sub

    Private Sub cboTipoPostEventoRicovero_SelectedIndexChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cboTipoPostEventoRicovero.SelectedIndexChanged
        If cboTipoPostEventoRicovero.SelectedItem.ToString.ToUpper = "RIMOZIONE" Then
            txtEventoRicoveroDataEvento.Enabled = False
            cboEventoRicoveroTipoEvento.Enabled = False
            txtEventoRicoveroDataSeq.Enabled = False
        Else
            txtEventoRicoveroDataEvento.Enabled = True
            cboEventoRicoveroTipoEvento.Enabled = True
            txtEventoRicoveroDataSeq.Enabled = True
        End If
    End Sub

#End Region

    Private Function ConnectionInfo(ByVal sConnectionString As String) As String
        Dim sServerName As String = String.Empty
        Dim sCatalog As String = String.Empty
        Dim sUserid As String = String.Empty

        Dim oArray As String() = Split(sConnectionString, ";")
        For i As Integer = 0 To oArray.GetUpperBound(0)
            If oArray(i).ToUpper.StartsWith("DATA SOURCE=") Then
                sServerName = Trim(oArray(i).Substring(Len("DATA SOURCE=")))
            ElseIf oArray(i).ToUpper.StartsWith("INITIAL CATALOG=") Then
                sCatalog = Trim(oArray(i).Substring(Len("INITIAL CATALOG=")))
            ElseIf oArray(i).ToUpper.StartsWith("USER ID=") Then
                sUserid = Trim(oArray(i).Substring(Len("USER ID=")))
            End If
            'If Not String.IsNullOrEmpty(sServerName) AndAlso Not String.IsNullOrEmpty(sDbName) Then
            '    Exit For
            'End If
        Next
        If String.IsNullOrEmpty(sUserid) Then
            sUserid = "Integrata"
        End If
        '
        '
        '
        Return String.Format(" Server: '{0}', Database: '{1}' , UserId: '{2}'", sServerName, sCatalog, sUserid)
    End Function

    'Private Sub frmMain_Resize(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Resize
    '    Try
    '        Dim frm As Form = CType(sender, Form)
    '        Dim height As Integer = frm.Size.Height
    '        Dim width As Integer = frm.Size.Width
    '        If height < 600 Then height = 600
    '        If width < 600 Then width = 600
    '        frm.Size = New Size(width, height)
    '    Catch
    '    End Try
    'End Sub

#Region "Episodio2"

    Private Sub cmdEpisodio2Esegui_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdEpisodio_XML_Esegui.Click
        cmdEpisodio_XML_Esegui.Enabled = False
        Dim oLibV2 As ConnectorV2
        '
        ' Trace
        '
        Dim dtStart As Date
        dtStart = Date.Now
        AddTrace(dtStart, dtStart, "Start")
        Try
            '
            ' Tipo messaggio
            '
            Dim enTipoMessaggio As ConnectorV2.TipoMessaggio
            Try
                Dim sTipoPostEpisodio As String = cboTipoPostEpisodio_XML.SelectedItem
                Select Case sTipoPostEpisodio.ToLower
                    Case "aggiunge"
                        enTipoMessaggio = ConnectorV2.TipoMessaggio.Aggiunge
                    Case "modifica"
                        enTipoMessaggio = ConnectorV2.TipoMessaggio.Modifica
                    Case "rimuove"
                        enTipoMessaggio = ConnectorV2.TipoMessaggio.Rimuove
                    Case Else
                        enTipoMessaggio = ConnectorV2.TipoMessaggio.Aggiunge
                End Select
            Catch ex As Exception
                Throw New Exception("Selezionare il tipo di messaggio!")
            End Try
            '
            ' Il messaggio è contenuto nella textbox
            '
            If String.IsNullOrEmpty(txtEpisodio_XML_Xml.Text) Then
                Throw New Exception("Compilare il messaggio del referto!")
            End If
            '
            ' Creo la classe dall'XML del messaggio
            '
            Dim oMessagioEpisodio As ConnectorV2.MessaggioEpisodio
            oMessagioEpisodio = ConnectorV2.MessaggioEpisodio.Deserialize(txtEpisodio_XML_Xml.Text)
            '
            ' Compongo messaggio
            '
            oLibV2 = New ConnectorV2
            Dim oRetEpisodio As ConnectorV2.Risultato

            Dim dtDataSeq As DateTime
            If txtEpisodio_XML_DataSequenza.Text.Length = 0 Then
                dtDataSeq = Date.Now
            Else
                dtDataSeq = Date.Parse(txtEpisodio_XML_DataSequenza.Text)
            End If
            '
            ' Chiamo il metodo della DLL relativo al referto
            ' Scelgo se chiamare il metodo Episodio2 o Episodio
            '
            If chkEpisodio_XML_UsaMetodoEpisodio2.Checked = True Then
                oRetEpisodio = oLibV2.Episodio2(enTipoMessaggio, dtDataSeq, oMessagioEpisodio, txtEpisodio_XML_IdEsternoPrecedente.Text)
            Else
                oRetEpisodio = oLibV2.Episodio(enTipoMessaggio, dtDataSeq, oMessagioEpisodio)
            End If
            '
            ' Trace
            '
            AddTrace(dtStart, Date.Now, "Esegue ConnectorV2.Episodio()")
            dtStart = Date.Now

            If oRetEpisodio.ErrorNumber = 0 Then
                MessageBox.Show("Episodio - Operazione completata!", Me.Text, MessageBoxButtons.OK, MessageBoxIcon.Information)
            Else
                MessageBox.Show("Episodio - Errore: Err # " & oRetEpisodio.ErrorNumber & ", " & oRetEpisodio.ErrorDescription, Me.Text, MessageBoxButtons.OK, MessageBoxIcon.Error)
            End If

        Catch ex As Exception
            '
            ' Eccezione generica
            '
            Call MsgBox("Exception:" & vbCrLf & ex.Message)
        Finally
            cmdEpisodio_XML_Esegui.Enabled = True
        End Try

    End Sub

#End Region


#Region "Ricovero2"

    Private Sub ConfigTabEventi2()
        '
        ' Tipo di operazione
        '
        cboTipoPostEventoRicovero2.Items.Clear()
        cboTipoPostEventoRicovero2.Items.Add("Aggiornamento")
        cboTipoPostEventoRicovero2.Items.Add("Rimozione")
        '
        ' Seleziono il primo tipo di operazione
        '
        cboTipoPostEventoRicovero2.SelectedIndex = 0
    End Sub


    Private Sub cmdRicovero2Esegui_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdRicovero2Esegui.Click
        cmdRicovero2Esegui.Enabled = False
        Dim oLibV2 As ConnectorV2
        '
        ' Trace
        '
        Dim dtStart As Date
        dtStart = Date.Now
        AddTrace(dtStart, dtStart, "Start")
        Try
            '
            ' Tipo messaggio
            '
            Dim enTipoMessaggio As ConnectorV2.TipoMessaggioEvento
            Dim sTipoPostEventoRicovero As String = cboTipoPostEventoRicovero2.SelectedItem
            Select Case sTipoPostEventoRicovero.ToLower
                Case "aggiornamento"
                    enTipoMessaggio = ConnectorV2.TipoMessaggioEvento.Aggiornamento
                Case "rimozione"
                    enTipoMessaggio = ConnectorV2.TipoMessaggioEvento.Rimozione
            End Select
            '
            ' Verifico la presenza dell'XML
            '
            If String.IsNullOrEmpty(txtEventoRicovero2Xml.Text) Then
                Throw New Exception("Compilare il messaggio dell'evento!")
            End If
            '
            ' Creo la classe a partire dall'XML
            '
            Dim oMessaggioEvento As ConnectorV2.MessaggioEvento
            oMessaggioEvento = ConnectorV2.MessaggioEvento.Deserialize(txtEventoRicovero2Xml.Text)

            '
            ' Compongo messaggio
            '
            oLibV2 = New ConnectorV2
            Dim oRetEvento As ConnectorV2.Risultato
            Dim dtDataSeq As DateTime
            '
            ' Imposto la data sequenza
            '
            If txtEventoRicovero2DataSeq.Text.Length = 0 Then
                dtDataSeq = Date.Now
            Else
                dtDataSeq = Date.Parse(txtEventoRicovero2DataSeq.Text)
            End If

            'oMessaggioEvento.Evento.IdEsternoEvento = oMessaggioEvento.Evento.SistemaErogante & "_" & _
            '                                            oMessaggioEvento.Evento.NumeroNosologico & "_" & _
            '                                            dtDataSeq.ToString("yyyyddMMhhmmss") & "_" & oMessaggioEvento.Evento.TipoEventoCodice

            '
            ' Chiamo il metodo della DLL
            '
            oRetEvento = oLibV2.Ricovero(enTipoMessaggio, dtDataSeq, oMessaggioEvento)
            '
            ' Trace
            '
            AddTrace(dtStart, Date.Now, "Esegue ConnectorV2.Ricovero()")
            dtStart = Date.Now

            If oRetEvento.ErrorNumber = 0 Then
                MessageBox.Show("Ricoveri - Operazione completata!", Me.Text, MessageBoxButtons.OK, MessageBoxIcon.Information)
            Else
                MessageBox.Show("Ricoveri - Errore: Err # " & oRetEvento.ErrorNumber & ", " & oRetEvento.ErrorDescription, Me.Text, MessageBoxButtons.OK, MessageBoxIcon.Error)
            End If

        Catch ex As Exception
            '
            ' Eccezione generica
            '
            Call MsgBox("Exception:" & vbCrLf & ex.Message)
        Finally
            cmdRicovero2Esegui.Enabled = True
        End Try
    End Sub

#End Region


#Region "Anagrafica2"

    Private Sub ConfigTabPazienti2()
        '
        ' Configurazioni per tab Pazienti2
        '
        cboTipoPostAnagrafica2.Items.Clear()
        cboTipoPostAnagrafica2.Items.Add("Aggiunge")
        cboTipoPostAnagrafica2.Items.Add("Modifica")
        cboTipoPostAnagrafica2.Items.Add("Rimuove")
        cboTipoPostAnagrafica2.Items.Add("Fusione")
        cboTipoPostAnagrafica2.SelectedIndex = 0
    End Sub

    Private Sub cmdEseguiAnagrafica2_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdEseguiAnagrafica2.Click
        cmdEseguiAnagrafica2.Enabled = False
        Dim oLibV2 As ConnectorV2
        '
        ' Trace
        '
        Dim dtStart As Date
        dtStart = Date.Now
        AddTrace(dtStart, dtStart, "Start")
        Try
            '
            ' Tipo messaggio
            '
            Dim enTipoMessaggio As ConnectorV2.TipoMessaggio
            Try
                Dim sTipoPostEpisodio As String = cboTipoPostAnagrafica2.SelectedItem
                Select Case sTipoPostEpisodio.ToLower
                    Case "aggiunge"
                        enTipoMessaggio = ConnectorV2.TipoMessaggio.Aggiunge
                    Case "modifica"
                        enTipoMessaggio = ConnectorV2.TipoMessaggio.Modifica
                    Case "rimuove"
                        enTipoMessaggio = ConnectorV2.TipoMessaggio.Rimuove
                    Case "fusione"
                        enTipoMessaggio = ConnectorV2.TipoMessaggio.Fusione
                    Case Else
                        Throw New Exception("Il tipo di messaggio non esiste!")
                End Select
            Catch ex As Exception
                Throw New Exception("Selezionare il tipo di messaggio!")
            End Try
            '
            ' Il messaggio è contenuto nella textbox
            '
            If String.IsNullOrEmpty(txtAnagrafica2Xml.Text) Then
                Throw New Exception("Compilare il messaggio dell'anagrafica!")
            End If
            '
            ' Creo la classe dall'XML del messaggio
            '
            Dim oMessagio As ConnectorV2.MessaggioAnagrafica
            oMessagio = ConnectorV2.MessaggioAnagrafica.Deserialize(txtAnagrafica2Xml.Text)
            '
            ' Compongo messaggio
            '
            oLibV2 = New ConnectorV2
            Dim oRet As ConnectorV2.Risultato

            Dim dtDataSeq As DateTime
            If txtPazientiDataSeqAnagrafica2.Text.Length = 0 Then
                dtDataSeq = Date.Now
            Else
                dtDataSeq = Date.Parse(txtPazientiDataSeqAnagrafica2.Text)
            End If
            '
            ' Chiamo il metodo della DLL relativo all'anagrafica
            '
            oRet = oLibV2.Anagrafica(enTipoMessaggio, dtDataSeq, oMessagio)
            '
            ' Trace
            '
            AddTrace(dtStart, Date.Now, "Esegue ConnectorV2.Anagrafica()")
            dtStart = Date.Now

            If oRet.ErrorNumber = 0 Then
                MessageBox.Show("Anagrafica - Operazione completata!", Me.Text, MessageBoxButtons.OK, MessageBoxIcon.Information)
            Else
                MessageBox.Show("Anagrafica - Errore: Err # " & oRet.ErrorNumber & ", " & oRet.ErrorDescription, Me.Text, MessageBoxButtons.OK, MessageBoxIcon.Error)
            End If

        Catch ex As Exception
            '
            ' Eccezione generica
            '
            Call MsgBox("Exception:" & vbCrLf & ex.Message)
        Finally
            cmdEseguiAnagrafica2.Enabled = True
        End Try

    End Sub

#End Region

#Region "Prova di carico"

    Public Class ProveCaricoReferti
        Public IdEsterno As String
        Public XmlReferto As String
    End Class
    Private oListProveCaricoReferti As New Generic.List(Of ProveCaricoReferti)

    Public Class ProcessRefertiData
        Public ThreadRandomDelayMax As Integer
        Public ProveCaricoReferti As ProveCaricoReferti
    End Class

    Private oListThreadReferti As New Generic.List(Of System.Threading.Thread)
    Private _MessageErrors As String

    Private Sub cmdProveCaricoRefertiEsegui_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdProveCaricoRefertiEsegui.Click
        cmdProveCaricoRefertiEsegui.Enabled = False
        Dim iNumMaxReferti As Integer
        Dim sFileTemplateXmlReferto As String
        Try
            Me.Cursor = Cursors.WaitCursor
            If Trim(txtProveCaricoTemplateReferto.Text) = "" Then
                MsgBox("Selezionare il template XML per i referti.")
                Exit Sub
            End If
            If Trim(txtProveCaricoNumMaxReferti.Text) = "" Or _
                    Not IsNumeric(txtProveCaricoNumMaxReferti.Text) Then
                MsgBox("Impostare il numero max di referti.")
                Exit Sub
            End If
            If Trim(txtProveCaricorefertiThreadrandomDelayMax.Text) = "" Or _
                    Not IsNumeric(txtProveCaricorefertiThreadrandomDelayMax.Text) Then
                MsgBox("Impostare il thread  random delay max (ms).")
                Exit Sub
            End If

            _MessageErrors = ""
            txtErroriProvaDiCaricoReferti.Text = ""

            iNumMaxReferti = CType(txtProveCaricoNumMaxReferti.Text, Integer)
            sFileTemplateXmlReferto = txtProveCaricoTemplateReferto.Text
            '
            ' Leggo l'XML e ne modifico alcune parti; lo salvo nella lista
            '
            Dim oXmlDoc As New System.Xml.XmlDocument()
            For i As Integer = 1 To iNumMaxReferti
                Dim oProveCaricoRefertiItem As New ProveCaricoReferti
                '
                ' Modifico l'XML
                '
                oXmlDoc.Load(sFileTemplateXmlReferto)
                Dim oXmlNode As System.Xml.XmlNode = oXmlDoc.SelectSingleNode("//MessaggioEpisodio/Referto/IdEsternoReferto")
                oProveCaricoRefertiItem.IdEsterno = oXmlNode.InnerText & "_" & i.ToString
                oXmlNode.InnerText = oProveCaricoRefertiItem.IdEsterno
                oProveCaricoRefertiItem.XmlReferto = oXmlDoc.OuterXml
                oListProveCaricoReferti.Add(oProveCaricoRefertiItem)
            Next
            '
            ' Creo i thread : attenzione la data access esegue una sequenzializzazione utilizzando un mutex (synclevel)
            ' bisogna quindi verificare quale synclevel utilizza per capire se la prova di carico è corretta
            '
            For i As Integer = 0 To iNumMaxReferti - 1
                Dim oThread As New System.Threading.Thread(AddressOf ProcessInsertReferto)
                Dim oData As New ProcessRefertiData()
                oData.ProveCaricoReferti = oListProveCaricoReferti(i)
                oData.ThreadRandomDelayMax = CType(txtProveCaricorefertiThreadrandomDelayMax.Text, Integer)
                '
                ' Memorizzo il thread in una lista
                '
                oListThreadReferti.Add(oThread)
                '
                ' partenza
                '
                oThread.Name = oListProveCaricoReferti(i).IdEsterno
                oThread.Start(oData)
            Next
            '
            ' Aspetto terminazione dei thread
            '

            Do While oListThreadReferti.Count > 0
                For i As Integer = oListThreadReferti.Count - 1 To 0 Step -1
                    Dim oThread As System.Threading.Thread = oListThreadReferti(i)
                    If Not oThread.IsAlive Then
                        txtErroriProvaDiCaricoReferti.Text = txtErroriProvaDiCaricoReferti.Text & vbCrLf & _
                            String.Format("Terminato thread {0}.", oThread.Name)
                        oListThreadReferti.RemoveAt(i)
                        System.Threading.Thread.Sleep(50)
                    End If
                Next
                System.Threading.Thread.Sleep(50)
            Loop
            '
            ' Visualizzo eventuali errori
            '
            If String.IsNullOrEmpty(_MessageErrors) Then
                txtErroriProvaDiCaricoReferti.Text = txtErroriProvaDiCaricoReferti.Text & vbCrLf & vbCrLf & "Esecuzione terminata senza errori!"
            Else
                txtErroriProvaDiCaricoReferti.Text = txtErroriProvaDiCaricoReferti.Text & vbCrLf & vbCrLf & _MessageErrors
            End If

        Catch ex As Exception
            Me.Cursor = Cursors.Default
            MsgBox("Errore:" & vbCrLf & ex.Message)
        Finally
            cmdProveCaricoRefertiEsegui.Enabled = True
            Me.Cursor = Cursors.Default
        End Try
    End Sub

    ''' <summary>
    ''' La funzione eseguita nel thread 
    ''' </summary>
    ''' <param name="oData"></param>
    ''' <remarks></remarks>
    Private Sub ProcessInsertReferto(ByVal oData As Object)
        Try
            Dim oProcessRefertiData As ProcessRefertiData = CType(oData, ProcessRefertiData)

            Dim sXmlReferto As String = oProcessRefertiData.ProveCaricoReferti.XmlReferto
            '
            ' Per simulare esecuzioni a tempi differenti
            '
            Dim iMilliSecToWait As Integer = GetRandomNumber(0, oProcessRefertiData.ThreadRandomDelayMax)
            System.Threading.Thread.Sleep(iMilliSecToWait)
            '
            ' Eseguo la chiamata alla DLL
            '
            Dim oConnectorV2 As New ConnectorV2
            Dim oRetEpisodio As ConnectorV2.Risultato
            Dim oMessagioEpisodio As ConnectorV2.MessaggioEpisodio
            oMessagioEpisodio = ConnectorV2.MessaggioEpisodio.Deserialize(sXmlReferto)
            'Sempre Aggiunge
            oRetEpisodio = oConnectorV2.Episodio(ConnectorV2.TipoMessaggio.Aggiunge, Now(), oMessagioEpisodio)
            If oRetEpisodio.ErrorNumber <> 0 Then
                _MessageErrors = _MessageErrors & String.Format("Errore: numero: {0} - descrizione: {1}", oRetEpisodio.ErrorNumber, oRetEpisodio.ErrorDescription) & vbCrLf
            End If
            '
            ' Bisognerebbe scrivere da qualche parte i dati contenuti in oRetEpisodio
            '
        Catch ex As Exception
            _MessageErrors = _MessageErrors & "Eccezione: " & vbCrLf & ex.Message & vbCrLf
        End Try
    End Sub

    Private Function GetRandomNumber(Optional ByVal Low As Integer = 1, Optional ByVal High As Integer = 100) As Integer
        ' Returns a random number, 
        ' between the optional Low and High parameters 
        Dim objRandom As New System.Random(CType(System.DateTime.Now.Ticks Mod System.Int32.MaxValue, Integer))
        Return objRandom.Next(Low, High + 1)
    End Function




#Region "Prova carico metodo Episodio2() catena referti"


    'Public Class ProveCaricoCatenaReferti
    '    Public Index As Integer
    '    Public IdEsterno As String
    '    Public XmlReferto As String
    'End Class

    ''Private oListProveCaricoCatenaReferti As New Generic.List(Of ProveCaricoCatenaReferti)


    'Private Sub ProveCaricoCatenaDiReferti()
    '    Dim iNumMaxReferti As Integer
    '    Dim sFileTemplateXmlReferto As String
    '    Try
    '        Me.Cursor = Cursors.WaitCursor
    '        If Trim(txtProveCaricoTemplateReferto.Text) = "" Then
    '            MsgBox("Selezionare il template XML per i referti.")
    '            Exit Sub
    '        End If
    '        If Trim(txtProveCaricoNumMaxReferti.Text) = "" Or _
    '                Not IsNumeric(txtProveCaricoNumMaxReferti.Text) Then
    '            MsgBox("Impostare il numero max di referti.")
    '            Exit Sub
    '        End If
    '        If Trim(txtProveCaricorefertiThreadrandomDelayMax.Text) = "" Or _
    '                Not IsNumeric(txtProveCaricorefertiThreadrandomDelayMax.Text) Then
    '            MsgBox("Impostare il thread  random delay max (ms).")
    '            Exit Sub
    '        End If

    '        _MessageErrors = ""
    '        txtErroriProvaDiCaricoReferti.Text = ""

    '        iNumMaxReferti = CType(txtProveCaricoNumMaxReferti.Text, Integer)
    '        sFileTemplateXmlReferto = txtProveCaricoTemplateReferto.Text

    '        ' per ognuno degli item di qusto array c'è un thread che sequenzialmnete
    '        ' eseguo le chiamate alla DataAccess: una chiamata per ogni elemento della lista ProveCaricoCatenaReferti
    '        Dim oArrayProveCaricoCatenaReferti(1) As Generic.List(Of ProveCaricoCatenaReferti)


    '        Dim oXmlDoc As New System.Xml.XmlDocument()
    '        'Creo una lista per ogni thread da creare 
    '        For j As Integer = 0 To oArrayProveCaricoCatenaReferti.GetUpperBound(0)
    '            For i As Integer = 1 To iNumMaxReferti
    '                Dim oProveCaricoCatenaRefertiItem As New ProveCaricoCatenaReferti
    '                '
    '                ' Modifico l'XML
    '                '
    '                oXmlDoc.Load(sFileTemplateXmlReferto)
    '                Dim oXmlNode As System.Xml.XmlNode = oXmlDoc.SelectSingleNode("//MessaggioEpisodio/Referto/IdEsternoReferto")
    '                oProveCaricoCatenaRefertiItem.IdEsterno = oXmlNode.InnerText & "_" & i.ToString
    '                oXmlNode.InnerText = oProveCaricoCatenaRefertiItem.IdEsterno
    '                oProveCaricoCatenaRefertiItem.XmlReferto = oXmlDoc.OuterXml
    '                'Indice di sequenza
    '                oProveCaricoCatenaRefertiItem.Index = i
    '                oArrayProveCaricoCatenaReferti(j).Add(oProveCaricoCatenaRefertiItem)
    '            Next
    '        Next

    '        '
    '        ' creo i thread
    '        ' 
    '        For j As Integer = 0 To oArrayProveCaricoCatenaReferti.GetUpperBound(0)
    '            Dim oThread As New System.Threading.Thread(AddressOf ProcessCatenaReferti)
    '            '
    '            ' Memorizzo il thread in una lista
    '            '
    '            oListThreadReferti.Add(oThread)
    '            '
    '            '
    '            '
    '            oThread.Name = "ThreadProveCaricoCatenaReferti_" & j.ToString()
    '            '
    '            ' partenza
    '            '
    '            oThread.Start(oArrayProveCaricoCatenaReferti(j))
    '        Next


    '        '
    '        ' Aspetto terminazione dei thread
    '        '
    '        Do While oListThreadReferti.Count > 0
    '            For i As Integer = oListThreadReferti.Count - 1 To 0 Step -1
    '                Dim oThread As System.Threading.Thread = oListThreadReferti(i)
    '                If Not oThread.IsAlive Then
    '                    txtErroriProvaDiCaricoReferti.Text = txtErroriProvaDiCaricoReferti.Text & vbCrLf & _
    '                        String.Format("Terminato thread {0}.", oThread.Name)
    '                    oListThreadReferti.RemoveAt(i)
    '                    System.Threading.Thread.Sleep(50)
    '                End If
    '            Next
    '            System.Threading.Thread.Sleep(50)
    '        Loop
    '        '
    '        ' Visualizzo eventuali errori
    '        '
    '        If String.IsNullOrEmpty(_MessageErrors) Then
    '            txtErroriProvaDiCaricoReferti.Text = txtErroriProvaDiCaricoReferti.Text & vbCrLf & vbCrLf & "Esecuzione terminata senza errori!"
    '        Else
    '            txtErroriProvaDiCaricoReferti.Text = txtErroriProvaDiCaricoReferti.Text & vbCrLf & vbCrLf & _MessageErrors
    '        End If

    '    Catch ex As Exception
    '        Me.Cursor = Cursors.Default
    '        MsgBox("Errore:" & vbCrLf & ex.Message)
    '    Finally
    '        Me.Cursor = Cursors.Default
    '    End Try
    'End Sub


    'Private Sub ProcessCatenaReferti(ByVal oListProveCaricoCatenaReferti As Object)
    '    Try

    '        Dim oList As Generic.List(Of ProveCaricoCatenaReferti) = CType(oListProveCaricoCatenaReferti, Generic.List(Of ProveCaricoCatenaReferti))








    '    Catch ex As Exception
    '        _MessageErrors = _MessageErrors & "Eccezione: " & vbCrLf & ex.Message & vbCrLf
    '    End Try
    'End Sub


#End Region

#End Region


#Region "Selezione file"

    'Private Const OPEN_DIALOG_FILTER As String = "All|*.*|XPS|*.xps|Word|*.docx;*.doc|Html|*.htm;*.html;*.mht|PDF|*.pdf|Image|*.tif;*.tiff;*.jpeg;*.jpg"
    Private Const OPEN_DIALOG_FILTER As String = "XML|*.xml"
    Private Function SelectFiles() As String()
        Dim sFile() As String = Nothing
        OpenFileDialog1.Filter = OPEN_DIALOG_FILTER
        OpenFileDialog1.FilterIndex = 1
        OpenFileDialog1.Multiselect = True
        OpenFileDialog1.CheckFileExists = True
        OpenFileDialog1.CheckPathExists = True
        OpenFileDialog1.FileName = ""
        If OpenFileDialog1.ShowDialog() = Windows.Forms.DialogResult.OK Then
            sFile = OpenFileDialog1.FileNames
        End If
        Return sFile
    End Function
    Private Function SelectFile() As String
        Dim sFile As String = Nothing
        OpenFileDialog1.Filter = OPEN_DIALOG_FILTER
        OpenFileDialog1.FilterIndex = 1
        OpenFileDialog1.Multiselect = False
        OpenFileDialog1.CheckFileExists = True
        OpenFileDialog1.CheckPathExists = True
        OpenFileDialog1.FileName = ""
        If OpenFileDialog1.ShowDialog() = Windows.Forms.DialogResult.OK Then
            sFile = OpenFileDialog1.FileName
        End If
        Return sFile
    End Function

#End Region

    Private Sub cmdProveCaricoSelectRefertoTemplate_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles cmdProveCaricoSelectRefertoTemplate.Click
        Dim sSelectedFile As String = SelectFile()
        If sSelectedFile & "" <> "" Then
            txtProveCaricoTemplateReferto.Text = sSelectedFile
        End If
    End Sub

End Class
