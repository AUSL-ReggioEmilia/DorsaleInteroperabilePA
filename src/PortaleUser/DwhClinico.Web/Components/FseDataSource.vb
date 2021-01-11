Imports System.ComponentModel
Imports DwhClinico.Web.CustomDataSource


Namespace FseDataSource

    <DataObject()>
    Public Class FseDocumentiCerca
        Inherits CacheDataSource(Of WcfDwhClinico.DocumentiListaType)

        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetData(Token As WcfDwhClinico.TokenType, NumMaxRecord As Integer, TipoAccesso As String, DataDal As Date, DataAl As Date?, CodiceFiscalePaziente As String, CodiceFiscaleMedico As String, Optional TipiDocumento As String = Nothing) As WcfDwhClinico.DocumentiListaType

            Dim oDocumenti As WcfDwhClinico.DocumentiListaType
            '
            ' Cerco prima nella cache
            '
            oDocumenti = Me.CacheData
            If oDocumenti Is Nothing Then
                '
                ' Recupero dati dal WS
                '
                Using oWcf As New WcfDwhClinico.ServiceClient
                    Utility.SetWcfDwhClinicoCredential(oWcf)
                    '
                    ' Chiamata al metodo che restituisce i dati
                    '
                    Dim oDocumentiReturn As WcfDwhClinico.DocumentiReturn = oWcf.FseDocumentiCerca(Token, NumMaxRecord, TipoAccesso, TipiDocumento, DataDal, DataAl, CodiceFiscalePaziente, CodiceFiscaleMedico)
                    If oDocumentiReturn IsNot Nothing Then
                        If oDocumentiReturn.Errore IsNot Nothing Then
                            Throw New WsDwhException("Si è verificato un errore durante la lettura della lista dei documenti.", oDocumentiReturn.Errore)
                        Else
                            oDocumenti = oDocumentiReturn.Documenti
                        End If
                    End If
                End Using

                '
                ' Salvo nella cache
                '
                Me.CacheData = oDocumenti
            End If

            Return oDocumenti

        End Function

    End Class

    <DataObject()>
    Public Class FseDocumentoOttieni

        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetData(Token As WcfDwhClinico.TokenType, CodiceDocumento As String, TipoAccesso As String, TipiDocumento As String, DocumentoNatura As String, CodiceFiscalePaziente As String, CodiceFiscaleMedico As String) As WcfDwhClinico.DocumentoType
            Dim oDocumento As WcfDwhClinico.DocumentoType = Nothing
            '
            ' Recupero dati dal WS
            '
            Using oWcf As New WcfDwhClinico.ServiceClient
                Utility.SetWcfDwhClinicoCredential(oWcf)
                '
                ' Chiamata al metodo che restituisce i dati
                '
                Dim oDocumentoReturn As WcfDwhClinico.DocumentoReturn = oWcf.FseDocumentoOttieniPerCodice(Token, CodiceDocumento, TipoAccesso, TipiDocumento, DocumentoNatura, CodiceFiscalePaziente, CodiceFiscaleMedico)
                If oDocumentoReturn IsNot Nothing Then
                    If oDocumentoReturn.Errore IsNot Nothing Then
                        Throw New WsDwhException("Si è verificato un errore durante la lettura dei pdf del documento.", oDocumentoReturn.Errore)
                    Else
                        If Not oDocumentoReturn.Documento Is Nothing Then
                            oDocumento = oDocumentoReturn.Documento
                        End If
                    End If
                End If
            End Using
            Return oDocumento
        End Function

    End Class

    <DataObject()>
    Public Class FseDizionariOttieni

        <DataObjectMethod(DataObjectMethodType.Select, True)>
        Public Function GetData(Token As WcfDwhClinico.TokenType) As WcfDwhClinico.TipiAccessoListaType
            Dim oTipiAccesso As WcfDwhClinico.TipiAccessoListaType = Nothing
            '
            ' Recupero dati dal WS
            '
            Using oWcf As New WcfDwhClinico.ServiceClient
                Utility.SetWcfDwhClinicoCredential(oWcf)
                '
                ' Chiamata al metodo che restituisce i dati
                '
                Dim oDizionariReturn As WcfDwhClinico.DizionariReturn = oWcf.FseDizionariOttieni(Token)
                If oDizionariReturn IsNot Nothing Then
                    If oDizionariReturn.Errore IsNot Nothing Then
                        Throw New WsDwhException("Si è verificato un errore durante il caricamento dei tipi accesso", oDizionariReturn.Errore)
                    Else
                        If Not oDizionariReturn.TipiAccesso Is Nothing Then
                            oTipiAccesso = oDizionariReturn.TipiAccesso
                        End If
                    End If
                End If
            End Using
            Return oTipiAccesso
        End Function

    End Class


End Namespace
