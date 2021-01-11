Imports System.ComponentModel.DataAnnotations
Imports System.ComponentModel

Partial Public Class OeConnCupDataContext
End Class


Partial Public Class Enum_CodiciAziendeEroganti
End Class

Partial Public Class Enum_CodiciSistemiEroganti
End Class

<ScaffoldTable(True)>
<MetadataType(GetType(ocup_StruttureErogantiMetaData))>
<DisplayName("OeConnCup/~Strutture Eroganti")>
<TableName("OeConnCup-StruttureEroganti")>
<ExcelImport>
Partial Public Class ocup_StruttureEroganti
End Class

Public Class ocup_StruttureErogantiMetaData

    '[Codice]

    <Display(Name:="Codice", Order:=1)>
    <FilterUIHint("Search")>
    Public Codice As Object

End Class


<ScaffoldTable(True)>
<MetadataType(GetType(ocup_SistemiErogantiMetaData))>
<DisplayName("OeConnCup/~Sistemi Eroganti")>
<TableName("OeConnCup-SistemiEroganti")>
<ExcelImport>
Partial Public Class ocup_SistemiEroganti
End Class

Public Class ocup_SistemiErogantiMetaData

    '[CodiceSistema]
    '[CodiceAzienda]
    <Display(Name:="Codice Sistema", Order:=1)>
    <FilterUIHint("Search")>
    Public CodiceSistema As Object

    <Display(Name:="Codice Azienda", Order:=2)>
    Public CodiceAzienda As Object

End Class


<ScaffoldTable(True)>
<MetadataType(GetType(RegimiOeMetaData))>
<DisplayName("OeConnCup/~Regimi OE")>
<TableName("OeConnCup-RegimiOe")>
<ExcelImport>
<DisplayColumn("Codice")>
Partial Public Class RegimiOe
End Class

Public Class RegimiOeMetaData

    'Codice
    'Descrizione

    <Display(Name:="Codice", Order:=1)>
    <FilterUIHint("Search")>
    Public Codice As Object

    <Display(Name:="Descrizione", Order:=2)>
    <FilterUIHint("Search")>
    Public Descrizione As Object

End Class

<ScaffoldTable(True)>
<MetadataType(GetType(AttributiNomiMetaData))>
<DisplayName("OeConnCup/~Nome Attributi")>
<TableName("OeConnCup-AttributiNomi")>
<ExcelImport>
Partial Public Class AttributiNomi
End Class

Public Class AttributiNomiMetaData

    '[Nome]

    <Display(Name:="Nome", Order:=1)>
    <FilterUIHint("Search")>
    Public Nome As Object

End Class


<ScaffoldTable(True)>
<MetadataType(GetType(TipiContrattoCupMetaData))>
<DisplayName("OeConnCup/~Tipi Contratti Cup")>
<TableName("OeConnCup-TipiContrattiCup")>
<ExcelImport>
Partial Public Class TipiContrattoCup
End Class

Public Class TipiContrattoCupMetaData

    '[Codice]

    <Display(Name:="Codice", Order:=1)>
    <FilterUIHint("Search")>
    Public Codice As Object

End Class


<ScaffoldTable(True)>
<MetadataType(GetType(TranscodificaAgendaCupStrutturaEroganteMetadata))>
<DisplayName("OeConnCup/Trans. Agende")>
<TableName("OeConnCup-Agende")>
<ExcelImport>
Partial Public Class TranscodificaAgendaCupStrutturaErogante
End Class

Public Class TranscodificaAgendaCupStrutturaEroganteMetadata

    '[CodiceAgendaCup]
    '[DescrizioneAgendaCup]
    '[TranscodificaCodiceAgendaCup]
    '[StrutturaErogante]
    '[DescrizioneStrutturaErogante]
    '[CodiceSistemaErogante]
    '[CodiceAziendaErogante]
    '[MultiErogante]

    <Display(Name:="Codice Agenda Cup", Order:=1)>
    <FilterUIHint("Search")>
    Public CodiceAgendaCup As Object

    <Display(Name:="Descrizione Agenda Cup", Order:=2)>
    <FilterUIHint("Search")>
    Public DescrizioneAgendaCup As Object

    <Display(Name:="Transcodifica Codice Agenda Cup", Order:=3)>
    <FilterUIHint("Search")>
    Public TranscodificaCodiceAgendaCup As Object

    '<Display(AutoGenerateFilter:=False, AutoGenerateField:=True, Name:="Struttura Erogante", Order:=3)>
    'Public StrutturaErogante As Object

    <Display(Name:="Struttura Erogante", AutoGenerateFilter:=True, AutoGenerateField:=True, Order:=4)>
    Public ocup_StruttureEroganti As Object

    <Display(Name:="Descrizione Struttura Erogante", Order:=5)>
    <FilterUIHint("Search")>
    Public DescrizioneStrutturaErogante As Object

    '<Display(Name:="Codice Sistema Erogante", AutoGenerateFilter:=False, AutoGenerateField:=True, Order:=6)>
    'Public CodiceSistemaErogante As Object

    <Display(Name:="Codice Sistema Erogante", AutoGenerateFilter:=True, AutoGenerateField:=True, Order:=6)>
    Public Enum_CodiciSistemiEroganti As Object

    '<Display(Name:="Codice Azienda Erogante", AutoGenerateFilter:=False, AutoGenerateField:=True, Order:=7)>
    'Public CodiceAziendaErogante As Object

    <Display(Name:="Codice Azienda Erogante", AutoGenerateFilter:=True, AutoGenerateField:=True, Order:=7)>
    Public Enum_CodiciAziendeEroganti As Object

    <Display(Name:="Multi Erogante", AutoGenerateFilter:=True, AutoGenerateField:=True, Order:=8)>
    <FilterUIHint("Boolean")>
    Public MultiErogante As Object

End Class



<ScaffoldTable(True)>
<MetadataType(GetType(TranscodificaAttributiPrestazioniCupEroganteMetadata))>
<DisplayName("OeConnCup/Trans. Prestazioni")>
<TableName("OeConnCup-Prestazioni")>
<ExcelImport>
Partial Public Class TranscodificaAttributiPrestazioniCupErogante
End Class

Public Class TranscodificaAttributiPrestazioniCupEroganteMetadata
    '[StrutturaErogante]
    '[IdPrestazioneCup]
    '[IdPrestazioneErogante]
    '[Nome]
    '[Codice]
    '[Posizione]
    '[Descrizione]
    '[TipoDato]
    '[TipoContenuto]
    '[SpecialitaEsameCup]


    '<Display(Name:="Struttura Erogante", Order:=1, AutoGenerateFilter:=False, AutoGenerateField:=True)>
    'Public StrutturaErogante As Object

    <Display(AutoGenerateFilter:=True, AutoGenerateField:=True, Name:="Struttura Erogante", Order:=1)>
    Public ocup_StruttureEroganti As Object

    <Display(Name:="Id Prestazione Cup", Order:=2)>
    <FilterUIHint("Search")>
    Public IdPrestazioneCup As Object

    <Display(Name:="Id Prestazione Erogante", Order:=3)>
    <FilterUIHint("Search")>
    Public IdPrestazioneErogante As Object

    <Display(Name:="Codice", Order:=4)>
    <FilterUIHint("Search")>
    <Required(AllowEmptyStrings:=True)> 'CAMPO CHE PERMETTE DI INSERIRE STRINGA VUOTA SENZA TRASFORMARLO IN NULL (ANCHE SE È CHIAVE)
    <DisplayFormat(ConvertEmptyStringToNull:=False)> 'CAMPO CHE PERMETTE DI INSERIRE STRINGA VUOTA SENZA TRASFORMARLO IN NULL (ANCHE SE È CHIAVE)
    Public Codice As Object

    '<Display(Name:="Nome", Order:=5, AutoGenerateFilter:=False, AutoGenerateField:=True)>
    '<Required(AllowEmptyStrings:=True)> 'CAMPO CHE PERMETTE DI INSERIRE STRINGA VUOTA SENZA TRASFORMARLO IN NULL (ANCHE SE È CHIAVE)
    '<DisplayFormat(ConvertEmptyStringToNull:=False)> 'CAMPO CHE PERMETTE DI INSERIRE STRINGA VUOTA SENZA TRASFORMARLO IN NULL (ANCHE SE È CHIAVE)
    'Public Nome As Object

    <DefaultEmptyString>
    <DisplayFormat(ConvertEmptyStringToNull:=False, NullDisplayText:="")> 'CAMPO CHE PERMETTE DI INSERIRE STRINGA VUOTA SENZA TRASFORMARLO IN NULL (ANCHE SE È CHIAVE)
    <Required(AllowEmptyStrings:=True)> 'CAMPO CHE PERMETTE DI INSERIRE STRINGA VUOTA SENZA TRASFORMARLO IN NULL (ANCHE SE È CHIAVE)
    <Display(Name:="Nome", Order:=5, AutoGenerateFilter:=True, AutoGenerateField:=True)>
    Public AttributiNomi As Object

    <Display(Name:="Descrizione", Order:=6)>
    <FilterUIHint("Search")>
    Public Descrizione As Object

    <Display(Name:="Specialità Esame Cup", Order:=7)>
    Public SpecialitaEsameCup As Object

    <Display(Name:="Tipo Dato", Order:=8)>
    Public TipoDato As Object

    <Display(Name:="Tipo Contenuto", Order:=9)>
    Public TipoContenuto As Object

    '<Display(Name:="Codice Sistema Erogante", Order:=10, AutoGenerateFilter:=False, AutoGenerateField:=True)>
    'Public CodiceSistemaErogante As Object

    <Display(Name:="Codice Sistema Erogante", Order:=10, AutoGenerateFilter:=True, AutoGenerateField:=True)>
    Public Enum_CodiciSistemiEroganti As Object

    '<Display(Name:="Codice Azienda Erogante", Order:=11, AutoGenerateFilter:=False, AutoGenerateField:=True)>
    'Public CodiceAziendaErogante As Object

    <Display(Name:="Codice Azienda Erogante", Order:=11, AutoGenerateFilter:=True, AutoGenerateField:=True)>
    Public Enum_CodiciAziendeEroganti As Object
End Class


<ScaffoldTable(True)>
<MetadataType(GetType(TranscodificaCodiceProvenienzaCupEroganteMetadata))>
<DisplayName("OeConnCup/Trans. Provenienze")>
<TableName("OeConnCup-Provenienze")>
<ExcelImport>
Partial Public Class TranscodificaCodiceProvenienzaCupErogante
End Class

Public Class TranscodificaCodiceProvenienzaCupEroganteMetadata
    '[CodiceProvenienzaCup]
    '[CodiceProvenienzaErogante]
    '[DescrizioneProvenienzaErogante]
    '[StrutturaErogante]



    '<Display(Name:="Struttura Erogante", Order:=1, AutoGenerateFilter:=False, AutoGenerateField:=True)>
    'Public StrutturaErogante As Object

    <Display(Name:="Struttura Erogante", Order:=1, AutoGenerateFilter:=True, AutoGenerateField:=True)>
    Public ocup_StruttureEroganti As Object

    <Display(Name:="Codice Provenienza Cup", Order:=2)>
    <FilterUIHint("Search")>
    Public CodiceProvenienzaCup As Object

    <Display(Name:="Codice Provenienza Erogante", Order:=3)>
    <FilterUIHint("Search")>
    Public CodiceProvenienzaErogante As Object

    <Display(Name:="Descrizione Provenienza Erogante", Order:=4)>
    <FilterUIHint("Search")>
    Public DescrizioneProvenienzaErogante As Object

End Class



<ScaffoldTable(True)>
<MetadataType(GetType(TranscodificaCodiceUrgenzaCupOrderEntryMetadata))>
<DisplayName("OeConnCup/Trans. Codici Urgenza OE")>
<TableName("OeConnCup-CodiciUrgenzaOE")>
<ExcelImport>
Partial Public Class TranscodificaCodiceUrgenzaCupOrderEntry
End Class

Public Class TranscodificaCodiceUrgenzaCupOrderEntryMetadata
    '[CodiceUrgenzaCup]
    '[CodiceUrgenzaOe]
    '[DescrizioneUrgenzaOe]

    <Display(Name:="Codice Urgenza Cup")>
    Public CodiceUrgenzaCup As Object

    <Display(Name:="Codice Urgenza O.E.")>
    Public CodiceUrgenzaOe As Object

    <Display(Name:="Descrizione Urgenza O.E.")>
    Public DescrizioneUrgenzaOe As Object

End Class


<ScaffoldTable(True)>
<MetadataType(GetType(TranscodificaTipoContrattoCupEroganteMetadata))>
<DisplayName("OeConnCup/Trans. Tipi Contratti Cup")>
<TableName("OeConnCup-ContrattiCup")>
<ExcelImport>
Partial Public Class TranscodificaTipoContrattoCupErogante
End Class

Public Class TranscodificaTipoContrattoCupEroganteMetadata
    '[CodiceTipoContrattoCup]
    '[CodiceTipoContrattoErogante]
    '[StrutturaErogante]

    '<Display(Name:="Struttura Erogante", Order:=1, AutoGenerateFilter:=False, AutoGenerateField:=True)>
    'Public StrutturaErogante As Object

    <Display(AutoGenerateFilter:=True, AutoGenerateField:=True, Name:="Struttura Erogante", Order:=1)>
    Public ocup_StruttureEroganti As Object

    '<Display(Name:="Codice Tipo Contratto Cup", Order:=2, AutoGenerateFilter:=False, AutoGenerateField:=True)>
    'Public CodiceTipoContrattoCup As Object

    <Display(Name:="Codice Tipo Contratto Cup", Order:=2, AutoGenerateFilter:=True, AutoGenerateField:=True)>
    <FilterUIHint("MultiForeignKey")>
    Public TipiContrattoCup As Object

    '<Display(Name:="Codice Tipo Contratto Erogante", Order:=3, AutoGenerateFilter:=False, AutoGenerateField:=True)>
    'Public CodiceTipoContrattoErogante As Object

    <Display(Name:="Codice Tipo Contratto Erogante", Order:=3, AutoGenerateFilter:=True, AutoGenerateField:=True)>
    <FilterUIHint("MultiForeignKey")>
    Public TipiContrattoErogante As Object

End Class


<ScaffoldTable(True)>
<MetadataType(GetType(TranscodificaTipoContrattoCupRegimeOrderEntryMetadata))>
<DisplayName("OeConnCup/Trans. Tipi Contratti Regimi OE")>
<TableName("OeConnCup-TipiContrattiRegimiOE")>
<ExcelImport>
Partial Public Class TranscodificaTipoContrattoCupRegimeOrderEntry
End Class

Public Class TranscodificaTipoContrattoCupRegimeOrderEntryMetadata
    '[CodiceTipoContrattoCup]
    '[CodiceRegimeOe]
    '[DescrizioneRegimeOe]

    '<Display(Name:="Codice Tipo Contratto Cup", Order:=1, AutoGenerateFilter:=False, AutoGenerateField:=True)>
    'Public CodiceTipoContrattoCup As Object

    <Display(Name:="Codice Tipo Contratto Cup", Order:=1, AutoGenerateFilter:=True, AutoGenerateField:=True)>
    Public TipiContrattoCup As Object

    '<Display(Name:="Codice Regime O.E.", Order:=2, AutoGenerateFilter:=False, AutoGenerateField:=True)>
    'Public CodiceRegimeOe As Object

    <Display(Name:="Codice Regime O.E.", Order:=2, AutoGenerateFilter:=True, AutoGenerateField:=True)>
    Public RegimiOe As Object

    <Display(Name:="Descrizione Regime O.E.", Order:=3)>
    Public DescrizioneRegimeOe As Object

End Class



<ScaffoldTable(True)>
<MetadataType(GetType(AgendeCupSistemiDiStampaMetadata))>
<DisplayName("OeConnCup/Trans. Sistemi di stampa")>
<TableName("OeConnCup-SistemiDiStampa")>
<ExcelImport>
Partial Public Class AgendeCupSistemiDiStampa
End Class

Public Class AgendeCupSistemiDiStampaMetadata
    'Id
    'CodiceAgendaCup
    'PcRichiedente
    'SistemaDiStampa

    <Display(Name:="Id", Order:=1)>
    Public Id As Object

    <Display(Name:="Codice Agenda Cup", Order:=2)>
    <FilterUIHint("Search")>
    Public CodiceAgendaCup As Object

    <Display(Name:="Pc Richiedente", Order:=3)>
    <FilterUIHint("Search")>
    <DisplayFormat(ConvertEmptyStringToNull:=True)> 'CAMPO CHE PERMETTE DI INSERIRE NULL SE LA STRINGA E' VUOTA SENZA.
    Public PcRichiedente As Object

    <Display(Name:="Sistema Di Stampa", Order:=4)>
    <FilterUIHint("Search")>
    Public SistemaDiStampa As Object
End Class

' ------------------------------------------------------------------------------------------------
' 
'   Diff AgendeLHA-AgendeCup -> Icona Wizard di configurazione Agenda
'   Diff PrestazioniLHA-PrestazioniCup
'   Diff ProvenienzeLHA-ProvenienzeCup
' ------------------------------------------------------------------------------------------------
'   Wizard:
'   Definizione di un attributo custom di nome <OeConnCupWizardAgende>; se definito nelle classi allora nella pagina di lista List.aspx si visualizza un pulsante che fa partire il wizard
'   START del wizard dalla pagina dalle AGENDE
' ------------------------------------------------------------------------------------------------
'
' L'attributo <OeConnCupWizardAgende> serve a fare si che se presente nella classe venga visualizzato un determinato pulsante nella pagina List.aspx
'
'<OeConnCupWizardAgende>  Aggiungere questo attributo se si vuole visualizzare il pulsante che fa partire il wizard di importazione a partire dalle agende nella lista delle agende
'<RuoloAccesso("OeConnCup_WizardAgendeCup")> è l'attributo che indica i gruppi che possono accedere|vedere le pagine associate al wizard
<RuoloAccesso("OeConnCup_WizardAgendeCup")>
<OeConnCupWizardAgende>
<ScaffoldTable(True)>
<MetadataType(GetType(DiffAgendeCupMetadata))>
<DisplayName("OeConnCup/Agende Cup da Configurare")>
<TableName("OeConnCup-AgendeCupDaConfigurare")>
<ExcelImport>
Partial Public Class DiffAgendeCup
End Class

Public Class DiffAgendeCupMetadata
    'CodiceAgendaCup
    'DescrizioneAgendaCup
    'TranscodificaCodiceAgendaCup

    <Display(Name:="Codice Agenda Cup", Order:=1)>
    <FilterUIHint("Search")>
    Public CodiceAgendaCup As Object

    <Display(Name:="Descrizione Agenda Cup", Order:=2)>
    <FilterUIHint("Search")>
    Public DescrizioneAgendaCup As Object

    <Display(Name:="Transcodifica Codice Agenda Cup", Order:=3, AutoGenerateField:=True, AutoGenerateFilter:=False)>
    Public TranscodificaCodiceAgendaCup As Object

End Class

<RuoloAccesso("OeConnCup_WizardAgendeCup")>
<OeConnCupWizardAgende>
<ScaffoldTable(True)>
<MetadataType(GetType(DiffAgendeEsistentiPrestazioniMancantiMetadata))>
<DisplayName("OeConnCup/Agende Esistenti con Prestazioni da Configurare")>
<TableName("OeConnCup-AgendeEsistentiPrestazioniMancanti")>
<ExcelImport>
Partial Public Class DiffAgendeEsistentiPrestazioniMancanti
End Class

Public Class DiffAgendeEsistentiPrestazioniMancantiMetadata
    'CodiceAgendaCup
    'DescrizioneAgendaCup
    'TranscodificaCodiceAgendaCup

    <Display(Name:="Codice Agenda Cup", Order:=1)>
    <FilterUIHint("Search")>
    Public CodiceAgendaCup As Object

    <Display(Name:="Descrizione Agenda Cup", Order:=2)>
    <FilterUIHint("Search")>
    Public DescrizioneAgendaCup As Object

    <Display(Name:="Transcodifica Codice Agenda Cup", Order:=3, AutoGenerateField:=True, AutoGenerateFilter:=False)>
    Public TranscodificaCodiceAgendaCup As Object

End Class


'<ScaffoldTable(False)> rende invisibile il link nel treeview. Impostare a True per vederlo.
<RuoloAccesso("OeConnCup_WizardAgendeCup")>
<ScaffoldTable(True)>
<MetadataType(GetType(DiffPrestazioniCupMetadata))>
<DisplayName("OeConnCup/Prestazioni Cup Da Verificare")>
<TableName("OeConnCup-PrestazioniCupDaVerificare")>
<ExcelImport>
<[ReadOnly](True)>
Partial Public Class DiffPrestazioniCup
End Class

Public Class DiffPrestazioniCupMetadata
    'StrutturaErogante
    'CodiceAgendaCup
    'IdPrestazioneErogante
    'IdPrestazioneCup
    'SpecialitaEsameCup
    'Descrizione

    <Display(Name:="Struttura Erogante", Order:=1, AutoGenerateField:=True, AutoGenerateFilter:=False)>
    Public StrutturaErogante As Object

    <Display(Name:="Struttura Erogante", Order:=1, AutoGenerateField:=False, AutoGenerateFilter:=True)>
    Public ocup_StruttureEroganti As Object

    <Display(Name:="Codice Agenda Cup", Order:=2)>
    <FilterUIHint("Search")>
    Public CodiceAgendaCup As Object

    '<Display(Name:="Codice Agenda Cup", Order:=2, AutoGenerateField:=False, AutoGenerateFilter:=True)>
    'Public TranscodificaAgendaCupStrutturaErogante As Object

    <Display(Name:="Id Prestazione Erogante", Order:=3, AutoGenerateField:=True, AutoGenerateFilter:=False)>
    Public IdPrestazioneErogante As Object

    <Display(Name:="Id Prestazione Cup", Order:=4)>
    <FilterUIHint("Search")>
    Public IdPrestazioneCup As Object

    <Display(Name:="Specialita Esame Cup", Order:=5, AutoGenerateField:=True, AutoGenerateFilter:=False)>
    Public SpecialitaEsameCup As Object

    <Display(Name:="Descrizione", Order:=6, AutoGenerateField:=True, AutoGenerateFilter:=False)>
    Public Descrizione As Object

End Class


'<ScaffoldTable(False)> rende invisibile il link nel treeview. Impostare a True per vederlo.
<RuoloAccesso("OeConnCup_WizardAgendeCup")>
<ScaffoldTable(True)>
<MetadataType(GetType(DiffProvenienzeCupMetadata))>
<DisplayName("OeConnCup/Provenienze Cup Da Verificare")>
<TableName("OeConnCup-ProvenienzeCupDaVerificare")>
<ExcelImport>
Partial Public Class DiffProvenienzeCup
End Class

Public Class DiffProvenienzeCupMetadata
    'CodiceProvenienzaCup
    'DescrizioneProvenienzaErogante

    <Display(Name:="CodiceProvenienzaCup", Order:=1)>
    <FilterUIHint("Search")>
    Public CodiceProvenienzaCup As Object

    <Display(Name:="DescrizioneProvenienzaErogante", Order:=3, AutoGenerateField:=True, AutoGenerateFilter:=False)>
    Public DescrizioneProvenienzaErogante As Object


End Class