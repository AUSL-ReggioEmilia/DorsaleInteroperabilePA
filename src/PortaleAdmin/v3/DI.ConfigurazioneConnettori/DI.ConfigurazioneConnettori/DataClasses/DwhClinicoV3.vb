Imports System.ComponentModel.DataAnnotations
Imports System.ComponentModel
Partial Public Class DwhClinicoV3DataContext
End Class

<ScaffoldTable(True)>
<MetadataType(GetType(AbilitazioniPrestazioniMetadata))>
<DisplayName("DwhConnSole3/Sole Abilitazioni Prestazioni")>
<TableName("DwhConnSole3-SoleAbilitazioniPrestazioni")>
Partial Public Class Sole_AbilitazioniPrestazioni
End Class

Public Class AbilitazioniPrestazioniMetadata

    '[SistemaErogante]
    '[AziendaErogante]
    '[PrestazioneCodice]
    '[DataModifica]
    '[UtenteModifica]
    '[Abilitato]
    '[DisabilitaControlliBloccoInvio]
    '[OreRitardoInvio]

    <Display(Name:="Sistema Erogante", AutoGenerateFilter:=False, AutoGenerateField:=True, Order:=1)>
    Public SistemaErogante As Object

    <Display(Name:="Sistema Erogante", AutoGenerateFilter:=True, AutoGenerateField:=False, Order:=1)>
    Public AbilitazioniSistemiEroganti As Object

    <Display(Name:="Azienda Erogante", AutoGenerateFilter:=False, AutoGenerateField:=True, Order:=2)>
    Public AziendaErogante As Object

    <Display(Name:="Azienda Erogante", AutoGenerateFilter:=True, AutoGenerateField:=False, Order:=2)>
    Public AbilitazioniAziendeEroganti As Object

    <Display(Name:="Prestazione Codice")>
    Public PrestazioneCodice As Object

    ' Campo nascoto nelle liste --> Viene rimosso nella lista (tramite l'utilizzo del campo ShortName:="[HIDE]")
    <Display(Name:="Data Modifica", ShortName:="[HIDE]")>
    <UIHint("DateTimeNow")>
    Public DataModifica As Object

    ' Campo nascoto nelle liste --> Viene rimosso nella lista (tramite l'utilizzo del campo ShortName:="[HIDE]")
    <Display(Name:="Utente Modifica", ShortName:="[HIDE]")>
    <UIHint("LoggedUsername")>
    Public UtenteModifica As Object

    <Display(Name:="Abilitato")>
    Public Abilitato As Object

    <Display(Name:="Disabilita Controlli Blocco Invio")>
    Public DisabilitaControlliBloccoInvio As Object

    <Display(Name:="Ore Ritardo Invio")>
    Public OreRitardoInvio As Object


End Class


<ScaffoldTable(True)>
<MetadataType(GetType(AbilitazioniSistemiMetadata))>
<DisplayName("DwhConnSole3/Sole Abilitazioni Sistemi")>
<TableName("DwhConnSole3-SoleAbilitazioniSistemi")>
Partial Public Class Sole_AbilitazioniSistemi
End Class

Public Class AbilitazioniSistemiMetadata

    '[Id] -non visualizzato
    '[SistemaErogante] 
    '[AziendaErogante] 
    '[TipoErogante] 
    '[Abilitato] 
    '[DataInizio] 
    '[DataFine] 
    '[DataModifica]
    '[UtenteModifica]
    '[TipologiaSole]
    '[Mittente]
    '[OreRitardoInvio]
    '[DisabilitaControlloRegime]
    '[DisabilitaControlloInviabile]
    '[DisabilitaControlloConsensi]
    '[Priorita]
    '[CorrelazioneInvio]
    '[InviaOscurati]
    '[InviaConfidenziali]
    '[InviaLiberaProfessione]

    <Display(Name:="Sistema Erogante", AutoGenerateFilter:=False, AutoGenerateField:=True, Order:=1)>
    Public SistemaErogante As Object

    <Display(Name:="Sistema Erogante", AutoGenerateFilter:=True, AutoGenerateField:=False, Order:=1)>
    Public AbilitazioniSistemiEroganti As Object

    <Display(Name:="Azienda Erogante", AutoGenerateFilter:=False, AutoGenerateField:=True, Order:=2)>
    Public AziendaErogante As Object

    <Display(Name:="Azienda Erogante", AutoGenerateFilter:=True, AutoGenerateField:=False, Order:=2)>
    Public AbilitazioniAziendeEroganti As Object

    <Display(Name:="Tipo Erogante", AutoGenerateFilter:=False, AutoGenerateField:=True, Order:=3)>
    Public TipoErogante As Object

    <Display(Name:="Tipo Erogante", AutoGenerateFilter:=True, AutoGenerateField:=False, Order:=3)>
    Public AbilitazioniTipiEroganti As Object

    <Display(Name:="Abilitato", AutoGenerateFilter:=True, AutoGenerateField:=True, Order:=4)>
    Public Abilitato As Object

    <Display(Name:="Data Inizio", AutoGenerateFilter:=False, AutoGenerateField:=True, Order:=4)>
    Public DataInizio As Object

    <Display(Name:="Data Fine", AutoGenerateFilter:=False, AutoGenerateField:=True, Order:=4)>
    Public DataFine As Object

    ' Campo nascoto nelle liste --> Viene rimosso nella lista (tramite l'utilizzo del campo ShortName:="[HIDE]")
    <Display(Name:="Data Modifica", ShortName:="[HIDE]")>
    <UIHint("DateTimeNow")>
    Public DataModifica As Object

    ' Campo nascoto nelle liste --> Viene rimosso nella lista (tramite l'utilizzo del campo ShortName:="[HIDE]")
    <Display(Name:="Utente Modifica", ShortName:="[HIDE]")>
    <UIHint("LoggedUsername")>
    Public UtenteModifica As Object

    'TipologiaSole
    <Display(Name:="Tipologia Sole", AutoGenerateFilter:=False, AutoGenerateField:=True, Order:=5)>
    Public TipologiaSole As Object

    <Display(Name:="Tipologia Sole", AutoGenerateFilter:=True, AutoGenerateField:=False, Order:=5)>
    Public AbilitazioniTipologieSole As Object

    <Display(Name:="Mittente")>
    Public Mittente As Object

    <Display(Name:="Ore Ritardo Invio")>
    Public OreRitardoInvio As Object

    <Display(Name:="Disabilita Controllo Regime")>
    Public DisabilitaControlloRegime As Object

    <Display(Name:="Disabilita Controllo Inviabile")>
    Public DisabilitaControlloInviabile As Object

    <Display(Name:="Disabilita Controllo Consensi")>
    Public DisabilitaControlloConsensi As Object

    <Display(Name:="Priorità")>
    Public Priorita As Object

    <Display(Name:="Correlazione Invio")>
    Public CorrelazioneInvio As Object

    <Display(Name:="Invia Oscurati")>
    Public InviaOscurati As Object

    <Display(Name:="Invia Confidenziali")>
    Public InviaConfidenziali As Object

    <Display(Name:="Invia Libera Professione")>
    Public InviaLiberaProfessione As Object

End Class

