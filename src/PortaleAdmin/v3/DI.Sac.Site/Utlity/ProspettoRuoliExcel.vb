Imports System
Imports System.Data
Imports System.Data.SqlClient
Imports System.IO
Imports Aspose.Cells

Public Class ProspettoRuoliExcel

    Private _connectionString As String = String.Empty

    Public Sub New()
        '
        ' Liceza ASPOSE
        '
        Dim lic As New Aspose.Cells.License
        lic.SetLicense("..\Licenses\2016 Oem Aspose.Cells.lic")

        '
        ' Connection string
        '
        _connectionString = System.Configuration.ConfigurationManager.ConnectionStrings("AuslAsmnRe_SacConnectionString").ConnectionString

    End Sub

    Public Function ExportExcelProspettoRuoli(ByVal Optional idRuolo As Guid? = Nothing)

        'Definisco le DataTable che conterranno il ritorno dalla SP
        Dim dtRuoli As DataTable = New DataTable("Ruoli")
        Dim dtRuoliUtenti As DataTable = New DataTable("Ruoli-Utenti")
        Dim dtRuoliAccessi As DataTable = New DataTable("Ruoli-Accessi")
        Dim dtRuoliUO As DataTable = New DataTable("Ruoli-UO")
        Dim dtRuoliSistemi As DataTable = New DataTable("Ruoli-Sistemi")

        'Chiamo la SP che torna un DataSet di più tabelle (5)
        Using adapter As New SqlDataAdapter("[organigramma_admin].[ProspettoRuoliExcel]", _connectionString)

            adapter.SelectCommand.CommandType = CommandType.StoredProcedure
            adapter.SelectCommand.Parameters.Add("@IdRuolo", SqlDbType.UniqueIdentifier).Value = idRuolo

            Using ds As New DataSet()
                'Ottengo tutte le tabelle
                adapter.Fill(ds)

                'Valorizzo le singole DataTable
                dtRuoli = ds.Tables(0)
                dtRuoliUtenti = ds.Tables(1)
                dtRuoliAccessi = ds.Tables(2)
                dtRuoliUO = ds.Tables(3)
                dtRuoliSistemi = ds.Tables(4)
            End Using
        End Using

        'Crero il Workbook e rimuovo la worksheet di default
        Dim workbook As Workbook = New Workbook()
        workbook.Worksheets.RemoveAt(0)

        'Creo le 5 worksheet con il nome custom
        Dim worksheetRuoli As Worksheet = workbook.Worksheets.Add("Ruoli")
        Dim worksheetRuoliUtenti As Worksheet = workbook.Worksheets.Add("Associazione Ruoli-Utenti")
        Dim worksheetRuoliAccessi As Worksheet = workbook.Worksheets.Add("Associazione Ruoli-Accessi")
        Dim worksheetRuoliUO As Worksheet = workbook.Worksheets.Add("Associazione Ruoli-UO")
        Dim worksheetRuoliSistemi As Worksheet = workbook.Worksheets.Add("Associazione Ruoli-Sistemi")

        'Popolo le worksheet create con i dati dalle DataTable, compreso le intestazioni.
        worksheetRuoli.Cells.ImportDataTable(dtRuoli, True, "A1")
        worksheetRuoliUtenti.Cells.ImportDataTable(dtRuoliUtenti, True, "A1")
        worksheetRuoliAccessi.Cells.ImportDataTable(dtRuoliAccessi, True, "A1")
        worksheetRuoliUO.Cells.ImportDataTable(dtRuoliUO, True, "A1")
        worksheetRuoliSistemi.Cells.ImportDataTable(dtRuoliSistemi, True, "A1")

        'Definisco lo stile che verà applicato alle intestazioni delle tabelle 
        Dim headerstyle As Style = workbook.CreateStyle()
        headerstyle.Font.IsBold = True
        headerstyle.Font.Color = System.Drawing.Color.White
        headerstyle.ForegroundColor = System.Drawing.Color.ForestGreen
        headerstyle.Pattern = BackgroundType.Solid
        headerstyle.Borders(BorderType.BottomBorder).Color = System.Drawing.Color.Black
        headerstyle.Borders(BorderType.BottomBorder).LineStyle = CellBorderType.Thin
        headerstyle.VerticalAlignment = TextAlignmentType.Center
        headerstyle.HorizontalAlignment = TextAlignmentType.Center

        'Applico lo stile alle intestazioni di tutte le tabelle
        SetCellsHeaderStyle(worksheetRuoli, headerstyle)
        SetCellsHeaderStyle(worksheetRuoliUtenti, headerstyle)
        SetCellsHeaderStyle(worksheetRuoliAccessi, headerstyle)
        SetCellsHeaderStyle(worksheetRuoliUO, headerstyle)
        SetCellsHeaderStyle(worksheetRuoliSistemi, headerstyle)

        'Salvo la workbook con estensione .Xlsx (Excel-2007) in un MemoryStream
        Dim ms As New MemoryStream
        workbook.Save(ms, SaveFormat.Xlsx)

        'Torno lo stream
        Return ms

    End Function

    Private Sub SetCellsHeaderStyle(sheet As Worksheet, style As Style)

        Dim totalColumnsNumber As Integer = sheet.Cells.MaxColumn + 1

        'Applico lo stile solo alla prima riga delle colonne presenti -> da A + numero colonne presenti -1
        'Utilizzando la conversione dell'intero in Char riesco a scorrere le colonne excel
        For i As Int16 = Convert.ToInt16("A"c) To Convert.ToInt16("A"c) + totalColumnsNumber - 1
            Dim letter As Char = Convert.ToChar(i)
            sheet.Cells($"{letter}1").SetStyle(style)
        Next

        'Dimensiono le celle di tutta la worksheet per contenere il testo
        sheet.AutoFitColumns()
        sheet.AutoFitRows()

    End Sub

End Class
