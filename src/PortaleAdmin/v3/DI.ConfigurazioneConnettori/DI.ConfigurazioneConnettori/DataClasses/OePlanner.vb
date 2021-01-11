Imports System.ComponentModel

Namespace OePlanner

    Partial Public Class OePlannerDataContext
    End Class

    '
    'Lo spazio prima di Sistemi serve perchè esiste un'altra tabella chiamata "Sistemi". Senza lo spazio l'applicazione andrebbe in errore.
    'Ricordarsi che nel caso in cui ci siano due tabelle uguali per diversi database è necessario impostare il "ContextNamespace" e "EntityNamespace" dalle properties dei DBML.
    '
    <ScaffoldTable(True)>
    <MetadataType(GetType(SistemiMetadata))>
    <DisplayName("OePlanner/Sistemi")>
    <TableName("OePlanner-Sistemi")>
    <ExcelImport>
    Partial Public Class Sistemi
    End Class

    Public Class SistemiMetadata
        <Display(Name:="Id", Order:=1)>
        Public ID As Object

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

        <Display(Name:="Codice Sistema", Order:=2)>
        <FilterUIHint("Search")>
        Public Codice As Object

        <Display(Name:="Azienda", AutoGenerateFilter:=False, AutoGenerateField:=True, Order:=3)>
        Public CodiceAzienda As Object

        <Display(Name:="Attivo", Order:=4)>
        Public Attivo As Object

        <Display(Name:="Richiedente", Order:=4)>
        Public Richiedente As Object

        <Display(Name:="Erogante", Order:=4)>
        Public Erogante As Object

        <Display(Name:="RichiedenteProgrammabile", Order:=4)>
        Public RichiedenteProgrammabile As Object
    End Class


    <ScaffoldTable(True)>
    <MetadataType(GetType(PrioritaMetadata))>
    <DisplayName("OePlanner/Priorita")>
    <TableName("OePlanner-Priorita")>
    <ExcelImport>
    Partial Public Class Priorita
    End Class

    Public Class PrioritaMetadata

        <Display(Name:="Codice")>
        <Editable(False, AllowInitialValue:=True)>
        <UIHint("Codice")>
        Public Codice As Object

        <Display(Name:="Descrizione", Order:=2)>
        <FilterUIHint("Search")>
        Public Descrizione As Object

        <Display(Name:="Ordinamento", Order:=3)>
        <FilterUIHint("Search")>
        Public Ordinamento As Object

    End Class

    <ScaffoldTable(True)>
    <MetadataType(GetType(RegimiMetadata))>
    <DisplayName("OePlanner/Regimi")>
    <TableName("OePlanner-Regimi")>
    <ExcelImport>
    Partial Public Class Regimi
    End Class

    Public Class RegimiMetadata

        <Display(Name:="Codice")>
        <Editable(False, AllowInitialValue:=True)>
        <UIHint("Codice")>
        Public Codice As Object

        <Display(Name:="Descrizione", Order:=2)>
        <FilterUIHint("Search")>
        Public Descrizione As Object

        <Display(Name:="Ordinamento", Order:=3)>
        <FilterUIHint("Search")>
        Public Ordinamento As Object

    End Class

End Namespace
