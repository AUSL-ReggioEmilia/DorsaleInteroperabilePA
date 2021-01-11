Imports System.ComponentModel

Namespace OeGestioneOrdiniErogante
    <ScaffoldTable(True)>
    <MetadataType(GetType(DatiAccessoriMetaData))>
    <DisplayName("OeGestioneOrdiniErogante/Dati Accessori")>
    <TableName("OeGestioneOrdiniErogante-DatiAccessori")>
    <ExcelImport>
    Partial Public Class DatiAccessori
    End Class

    <ScaffoldTable(True)>
    <MetadataType(GetType(DatiAccessoriPrestazioniMetaData))>
    <DisplayName("OeGestioneOrdiniErogante/Dati Accessori Prestazioni")>
    <TableName("OeGestioneOrdiniErogante-DatiAccessoriPrestazioni")>
    <ExcelImport>
    Partial Public Class DatiAccessoriPrestazioni
    End Class

    <ScaffoldTable(True)>
    <MetadataType(GetType(PrestazioniMetaData))>
    <DisplayName("OeGestioneOrdiniErogante/Prestazioni")>
    <TableName("OeGestioneOrdiniErogante-Prestazioni")>
    <ExcelImport>
    Partial Public Class Prestazioni
    End Class

    <ScaffoldTable(True)>
    <MetadataType(GetType(DatiAccessoriSistemiMetaData))>
    <DisplayName("OeGestioneOrdiniErogante/Dati Accessori Sistemi")>
    <TableName("OeGestioneOrdiniErogante-DatiAccessoriSistemi")>
    <ExcelImport>
    Partial Public Class DatiAccessoriSistemi
    End Class
    <ScaffoldTable(True)>
    <MetadataType(GetType(SistemiMetadata))>
    <DisplayName("OeGestioneOrdiniErogante/Sistemi")>
    <TableName("OeGestioneOrdiniErogante-Sistemi")>
    <ExcelImport>
    Partial Public Class Sistemi
        '
        'Override della function ToString per mostrare il CodiceSistema nel seguente formato: CodiceSistema + Azienda
        '
        Public Overrides Function ToString() As String
            Return $"{Codice} - {CodiceAzienda}"
        End Function
    End Class


    '<ScaffoldTable(True)>
    '<MetadataType(GetType(DatiAggiuntiviMetaData))>
    '<DisplayName("OeGestioneOrdiniErogante")>
    '<TableName("Dati Aggiuntivi")>
    '<ExcelImport>
    'Partial Public Class DatiAggiuntivi
    'End Class

    <ScaffoldTable(True)>
    <MetadataType(GetType(DatiAccessoriMetaData))>
    <DisplayName("OeGestioneOrdiniErogante/Dati Accessori")>
    <TableName("OeGestioneOrdiniErogante-DatiAccessori")>
    <ExcelImport>
    Partial Public Class DatiAccessoriDataSet
    End Class


    Public Class SistemiMetadata
        '[ID]
        '[Codice]
        '[CodiceAzienda]
        '[Attivo]
        '[CancellazionePostInoltro]
        '[CancellazionePostInCarico]

        <Display(Name:="Id", Order:=1)>
        Public ID As Object

        <Display(Name:="Codice Sistema", Order:=2)>
        <FilterUIHint("Search")>
        Public Codice As Object

        <Display(Name:="Azienda", AutoGenerateFilter:=False, AutoGenerateField:=True, Order:=3)>
        Public CodiceAzienda As Object

        <Display(Name:="Azienda", AutoGenerateFilter:=True, AutoGenerateField:=False, Order:=3)>
        Public SistemiCodiciAziende As Object

        <Display(Name:="Attivo", Order:=4)>
        Public Attivo As Object

        <Display(Name:="Cancellazione Post-Inoltro", Order:=5)>
        Public CancellazionePostInoltro As Object

        <Display(Name:="Cancellazione Post-InCarico", Order:=6)>
        Public CancellazionePostInCarico As Object

        <Display(Name:="Dati Accessori Sistemi", Order:=7, AutoGenerateField:=False, AutoGenerateFilter:=False)>
        Public DatiAccessoriSistemi As Object

        <Display(Name:="Prestazioni", Order:=8, AutoGenerateField:=False, AutoGenerateFilter:=False)>
        Public Prestazioni As Object
    End Class

    Public Class DatiAccessoriMetaData
        '  [Id]
        ',[Codice]
        ',[DataInserimento]
        ',[DataModifica]
        ',[Descrizione]
        ',[Etichetta]
        ',[IdTipoDatoAccessorio]
        ',[Valori]
        ',[Ordinamento]
        ',[Gruppo]
        ',[ValidazioneRegex]
        ',[ValidazioneMessaggio]
        ',[ValoreDefault]
        ',[UtenteInserimento]
        ',[UtenteModifica]

        <Display(Name:="Id", Order:=1)>
        Public Id As Object

        <Display(Name:="Codice", Order:=1)>
        <FilterUIHint("Search")>
        Public Codice As Object

        <Display(Name:="Descrizione", Order:=2)>
        <FilterUIHint("Search")>
        Public Descrizione As Object

        <Display(Name:="Etichetta", Order:=3)>
        <FilterUIHint("Search")>
        Public Etichetta As Object

        <Display(Name:="Tipo", Order:=4, AutoGenerateField:=False, AutoGenerateFilter:=False)>
        Public IdTipoDatoAccessorio As Object


        <Display(Name:="Tipo", Order:=4, AutoGenerateField:=True, AutoGenerateFilter:=True)>
        <UIHint("ReadOnly_ForeignKey")>
        Public TipiDatiAccessori As Object

        <Display(Name:="Valori", Order:=5)>
        Public Valori As Object

        <Display(Name:="Ordinamento", Order:=6)>
        Public Ordinamento As Object

        <Display(Name:="Gruppo", Order:=7)>
        <FilterUIHint("Search")>
        Public Gruppo As Object

        <Display(Name:="Validazione Regex", Order:=8)>
        Public ValidazioneRegex As Object

        <Display(Name:="Validazione Messaggio", Order:=9)>
        Public ValidazioneMessaggio As Object

        <Display(Name:="Valore Default", Order:=10)>
        <UIHint("DatiAccessori_Autocomplete", Nothing, "ValueList", "Referto,Evento")>
        Public ValoreDefault As Object

        ' Campo nascosto
        <ScaffoldColumn(False)>
        <Display(Name:="Utente Inserimento")>
        <Editable(False, AllowInitialValue:=True)>
        <UIHint("LoggedUsername")>
        Public UtenteInserimento As Object

        ' Campo nascosto
        <ScaffoldColumn(False)>
        <Display(Name:="Utente Modifica")>
        <UIHint("LoggedUsername")>
        Public UtenteModifica As Object

        ' Campo nascosto
        <ScaffoldColumn(False)>
        <Display(Name:="Data Inserimento")>
        <Editable(False, AllowInitialValue:=True)>
        <UIHint("DateTimeNow")>
        Public DataInserimento As Object

        <Display(Name:="Data Modifica")>
        <UIHint("DateTimeNow")>
        <[ReadOnly](True)>
        Public DataModifica As Object

        <Display(Name:="DatiAccessoriSistemi", Order:=7, AutoGenerateField:=False, AutoGenerateFilter:=False)>
        Public DatiAccessoriSistemi As Object

        <Display(Name:="DatiAccessoriPrestazioni", Order:=7, AutoGenerateField:=False, AutoGenerateFilter:=False)>
        Public DatiAccessoriPrestazioni As Object
    End Class

    Public Class DatiAccessoriSistemiMetaData
        ' [ID]
        ',[IdDatoAccessorio]
        ',[IDSistema]
        ',[Attivo]

        <Display(Name:="Id", Order:=1)>
        Public Id As Object

        <Display(Name:="Dato Accessorio", Order:=2, AutoGenerateField:=False, AutoGenerateFilter:=False)>
        Public IdDatoAccessorio As Object

        <Display(Name:="Dato Accessorio", Order:=2, AutoGenerateField:=True, AutoGenerateFilter:=True)>
        Public DatiAccessori As Object

        <Display(Name:="Sistema", Order:=3, AutoGenerateField:=False, AutoGenerateFilter:=False)>
        Public IdSistema As Object

        <Display(Name:="Sistema", Order:=3, AutoGenerateField:=True, AutoGenerateFilter:=True)>
        Public Sistemi As Object

        <Display(Name:="Attivo", Order:=4)>
        Public Attivo As Object
    End Class

    Public Class DatiAccessoriPrestazioniMetaData
        ' [ID]
        ',[IdDatoAccessorio]
        ',[IDPrestazione]
        ',[Attivo]

        <Display(Name:="Id", Order:=1)>
        Public ID As Object

        <Display(Name:="Dato Accessorio", Order:=2, AutoGenerateField:=False, AutoGenerateFilter:=False)>
        Public IDDatoAccessorio As Object

        <Display(Name:="Dato Accessorio", Order:=2, AutoGenerateField:=True, AutoGenerateFilter:=True)>
        Public DatiAccessori As Object

        <Display(Name:="Sistema", Order:=3, AutoGenerateField:=False, AutoGenerateFilter:=False)>
        Public IDPrestazione As Object

        <Display(Name:="Prestazione", Order:=3, AutoGenerateField:=True, AutoGenerateFilter:=True)>
        Public Prestazioni As Object

        <Display(Name:="Attivo", Order:=4)>
        Public Attivo As Object
    End Class

    Public Class PrestazioniMetaData
        '[ID]
        ',[DataInserimento]
        ',[DataModifica]
        ',[Codice]
        ',[Descrizione]
        ',[IDSistemaErogante]
        ',[Attivo]
        ',[UtenteInserimento]
        ',[UtenteModifica]

        <Display(Name:="Id", Order:=1)>
        Public ID As Object

        <Display(Name:="Codice", Order:=2)>
        <FilterUIHint("Search")>
        Public Codice As Object

        <Display(Name:="Descrizione", Order:=3)>
        <FilterUIHint("Search")>
        Public Descrizione As Object

        <Display(Name:="Sistema Erogante", Order:=4, AutoGenerateField:=False, AutoGenerateFilter:=False)>
        Public IDSistemaErogante As Object

        <Display(Name:="Sistema Erogante", Order:=4, AutoGenerateField:=True, AutoGenerateFilter:=True)>
        Public Sistemi As Object

        <Display(Name:="Attivo", Order:=4)>
        Public Attivo As Object

        ' Campo nascoto nelle liste --> Viene rimosso nella lista (tramite l'utilizzo del campo ShortName:="[HIDE]")
        <Display(Name:="Utente Inseriemtno", ShortName:="[HIDE]")>
        <Editable(False, AllowInitialValue:=True)>
        <UIHint("LoggedUsername")>
        Public UtenteInserimento As Object

        ' Campo nascoto nelle liste --> Viene rimosso nella lista (tramite l'utilizzo del campo ShortName:="[HIDE]")
        <Display(Name:="Data inserimento", ShortName:="[HIDE]")>
        <Editable(False, AllowInitialValue:=True)>
        <UIHint("DateTimeNow")>
        Public DataInserimento As Object

        ' Campo nascoto nelle liste --> Viene rimosso nella lista (tramite l'utilizzo del campo ShortName:="[HIDE]")
        <Display(Name:="Utente Modifica", ShortName:="[HIDE]")>
        <UIHint("LoggedUsername")>
        Public UtenteModifica As Object

        <Display(Name:="Data Modifica")>
        <UIHint("DateTimeNow")>
        Public DataModifica As Object

        <Display(Name:="DatiAccessoriPrestazioni", AutoGenerateField:=False, AutoGenerateFilter:=False)>
        Public DatiAccessoriPrestazioni As Object
    End Class
End Namespace
