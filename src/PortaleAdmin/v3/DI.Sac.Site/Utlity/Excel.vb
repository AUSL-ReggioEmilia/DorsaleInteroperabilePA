Imports System
Imports System.Data
Imports System.IO
Imports System.Reflection
Imports Aspose.Cells

Public Class Excel

    Shared Sub New()
        '
        ' Liceza ASPOSE
        '
        Dim lic As New Aspose.Cells.License
        lic.SetLicense("..\Licenses\2016 Oem Aspose.Cells.lic")

    End Sub


    Public Shared Function AnyListToExcel(Input As System.Collections.IList, WorksheetName As String) As MemoryStream
        If Input Is Nothing OrElse Input.Count = 0 Then Return Nothing

        'DOCUMENTO E FOGLIO DI LAVORO
        Dim workbook As New Workbook(FileFormatType.Xlsx)
        Dim worksheet As Worksheet = workbook.Worksheets(0)
        worksheet.Name = WorksheetName.SafeSubstring(0, 31)

        'HEADER STYLE
        Dim headerstyle As Style = workbook.CreateStyle()
        headerstyle.Font.IsBold = True
        headerstyle.ForegroundColor = System.Drawing.Color.Beige
        headerstyle.Pattern = BackgroundType.Solid
        headerstyle.Borders(BorderType.BottomBorder).Color = System.Drawing.Color.Khaki
        headerstyle.Borders(BorderType.BottomBorder).LineStyle = CellBorderType.Medium
        headerstyle.VerticalAlignment = TextAlignmentType.Center

        'TEXT STYLE (ANCHE PER I NUMERI)
        Dim textstyle As Style = workbook.CreateStyle()
        textstyle.Number = 49

        'DATE STYLE
        Dim datestyle As Style = workbook.CreateStyle()
        datestyle.Custom = "dd/mm/yyyy"

        Dim iRow As Integer = 0
        Dim iCol As Integer = 0

        'INTESTAZIONI
        Dim _type As Type = Input(0).GetType()
        'Dim _type As Type = CType(Input(0), DataRow).ItemArray.GetType()
        'BindingFlags.DeclaredOnly
        Dim properties() As PropertyInfo = _type.GetProperties()

        For Each colonna As PropertyInfo In properties
            '
            ' SCARTO LE COLONNE NON SERIALIZZABILI (RELAZIONI CON FOREIGNKEY)
            '
            If Not colonna.PropertyType.IsSerializable Then Continue For

            worksheet.Cells(iRow, iCol).PutValue(colonna.Name)
            worksheet.Cells(iRow, iCol).SetStyle(headerstyle)
            worksheet.AutoFitColumn(iCol)
            iCol += 1
        Next
        worksheet.AutoFitRows(0, 0)
        worksheet.Cells.Rows(0).Height = 18

        'DATI
        iRow += 1
        For Each riga In Input
            iCol = 0
            For Each colonna As PropertyInfo In properties
                '
                ' SCARTO LE COLONNE NON SERIALIZZABILI (RELAZIONI CON FOREIGNKEY)
                '
                If Not colonna.PropertyType.IsSerializable Then Continue For

                Dim value
                Try
                    value = colonna.GetValue(riga, Nothing)
                Catch ex As Exception
                    value = Nothing
                End Try

                If TypeOf value Is Date Then
                    worksheet.Cells(iRow, iCol).SetStyle(datestyle)
                    'ElseIf TypeOf value Is boolean Then
                    '	worksheet.Cells(iRow, iCol).SetStyle(datestyle)
                Else
                    worksheet.Cells(iRow, iCol).SetStyle(textstyle)
                End If

                worksheet.Cells(iRow, iCol).PutValue(value)
                iCol += 1
            Next
            iRow += 1
        Next

        'SAVE THE WORKBOOK TO STREAM
        Dim ms As New MemoryStream
        workbook.Save(ms, SaveFormat.Xlsx)
        ms.Seek(0, SeekOrigin.Begin)

        Return ms

    End Function



    Public Shared Function ExcelToDataTable(ExcelFileStream As Stream, WorksheetName As String) As System.Data.DataTable

        Dim shortWorksheetName = WorksheetName.SafeSubstring(0, 31)
        'DOCUMENTO E FOGLIO DI LAVORO
        ExcelFileStream.Seek(0, SeekOrigin.Begin)
        Dim workbook As New Workbook(ExcelFileStream)
        If workbook.Worksheets.Item(shortWorksheetName) Is Nothing Then Throw New ApplicationException(String.Format("Nel file non è presente un foglio di lavoro con nome '{0}'.", WorksheetName))
        Dim worksheet As Worksheet = workbook.Worksheets.Item(shortWorksheetName)

        'CONVERSIONE DA EXCEL A DATATABLE
        Dim opt As New ExportTableOptions()
        opt.ExportColumnName = True

        worksheet.Cells.DeleteBlankRows()
        Dim dt = worksheet.Cells.ExportDataTable(0, 0, worksheet.Cells.Rows.Count, worksheet.Cells.Columns.Count, opt)
        Return dt

    End Function


#Region "Utilità Linq"

    ''' <summary>
    ''' Copia i valori dei campi da una ratarow ad una generica entity (nomi proprietà = nomi campi)
    ''' </summary>
    Public Shared Sub DataRowToEntity(drOrigin As DataRow, oDestination As Object)

        Dim entityType As Type = oDestination.GetType()
        Dim destColumns() As PropertyInfo = entityType.GetProperties()

        For Each column In destColumns
            ' SALTO LE COLONNE NON SERIALIZZABILI (RELAZIONI CON FOREIGNKEY)
            If Not column.PropertyType.IsSerializable Then Continue For
            ' SALTO LE COLONNE ASSENTI NELLA DATAROW
            If drOrigin.Item(column.Name) Is Nothing Then Continue For

            Dim origValue As Object = drOrigin(column.Name)
            Dim destValue As Object = origValue

            'CONVERTO DBNULL IN NOTHING
            If origValue Is DBNull.Value Then
                destValue = Nothing
            Else
                'SE I TIPI DIFFERISCONO DEVO CASTARE
                If Not drOrigin(column.Name).GetType.Equals(column.PropertyType) Then

                    'GESTIONE DEI TIPI 'NULLABLE' DI DESTINAZIONE
                    Dim destType As Type
                    If Nullable.GetUnderlyingType(column.PropertyType) IsNot Nothing Then
                        destType = Nullable.GetUnderlyingType(column.PropertyType)
                    Else
                        destType = column.PropertyType
                    End If
                    'CONVERSIONE DEL VALORE AL TIPO DI DESTINAZIONE
                    destValue = Convert.ChangeType(origValue, destType)
                End If
            End If

            column.SetValue(oDestination, destValue, Nothing)
        Next

    End Sub

#End Region
End Class
