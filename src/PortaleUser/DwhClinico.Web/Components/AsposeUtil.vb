Public Class AsposeUtil
    ''' <summary>
    ''' Il path fisico della foder che contiene le immagini 
    ''' </summary>
    ''' <remarks></remarks>
    Public ImagesFolder As String = String.Empty
    ''' <summary>
    ''' L'URI associato alla folder che contiene le immagini
    ''' </summary>
    ''' <remarks></remarks>
    Public ImagesFolderAlias As String = String.Empty
    ''' <summary>
    ''' Indica ad ASPOSE di inserire le immagini come base64 per i formati di export HTML (e anche altri)
    ''' </summary>
    ''' <remarks></remarks>
    Public ExportImageAsBase64 As Boolean = False


    ''' <summary>
    ''' Crea un documento a partire a un array di byte
    ''' </summary>
    ''' <param name="baArrayIn"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Function DocumentCreate(ByVal baArrayIn As Byte()) As Aspose.Words.Document
        Dim doc As Aspose.Words.Document = Nothing
        Using msFileOut As New IO.MemoryStream
            Using msFileIn As New IO.MemoryStream(baArrayIn)
                Dim license As New Aspose.Words.License()
                license.SetLicense("Aspose.Words.lic")
                doc = New Aspose.Words.Document(msFileIn)
            End Using
            '
            ' Restituisco
            '
            Return doc
        End Using
    End Function


    ''' <summary>
    ''' Attacca il documento srcDoc al documento di dstDoc
    ''' </summary>
    ''' <param name="dstDoc">Documento destinazione</param>
    ''' <param name="srcDoc">Documento da appendere</param>
    ''' <remarks></remarks>
    Public Sub AppendDocument(dstDoc As Aspose.Words.Document, srcDoc As Aspose.Words.Document)
        If Not srcDoc Is Nothing Then
            srcDoc.FirstSection.PageSetup.SectionStart = Aspose.Words.SectionStart.Continuous
            dstDoc.AppendDocument(srcDoc, Aspose.Words.ImportFormatMode.KeepSourceFormatting)
        End If
    End Sub

    ''' <summary>
    ''' Converte un documento nel formato richiesto e lo restituisce come array di byte
    ''' </summary>
    ''' <param name="oDoc"></param>
    ''' <param name="format"></param>
    ''' <returns></returns>
    ''' <remarks>Per formati di salvataggio come HTML bisogna specificare la folder di destinazione delle immagini e il suo alias oppure di inserire le immagini nel documento come base64</remarks>
    Public Function DocumentConvertToByteArray(ByVal oDoc As Aspose.Words.Document, format As Aspose.Words.SaveFormat) As Byte()
        Using msFileOut As New IO.MemoryStream
            '
            ' Ci sono formati per i quali bisogna specificare una folder per le immagini o di inserirle come base64 nella pagina
            '
            If format = Aspose.Words.SaveFormat.Html Then
                Dim options As New Aspose.Words.Saving.HtmlSaveOptions(Aspose.Words.SaveFormat.Html)
                If (Not String.IsNullOrEmpty(ImagesFolder)) AndAlso (Not String.IsNullOrEmpty(ImagesFolderAlias)) Then
                    options.ImagesFolder = ImagesFolder
                    options.ImagesFolderAlias = ImagesFolderAlias
                ElseIf ExportImageAsBase64 Then
                    options.ExportImagesAsBase64 = True
                Else
                    Throw New ApplicationException("Il formato di export HTML richiede di specificare ExportImageAsBase64=True oppure la folder di esportazione delle immagini e il suo alias rispettivamente in ImagesFolder e ImagesFolderAlias.")
                End If
                oDoc.Save(msFileOut, options)
            Else
                ' Converte
                oDoc.Save(msFileOut, format)
            End If
            ' Restituisco
            Return msFileOut.ToArray
        End Using
    End Function


End Class
