﻿'------------------------------------------------------------------------------
' <auto-generated>
'     This code was generated by a tool.
'     Runtime Version:4.0.30319.42000
'
'     Changes to this file may cause incorrect behavior and will be lost if
'     the code is regenerated.
' </auto-generated>
'------------------------------------------------------------------------------

Option Strict On
Option Explicit On


Namespace My
    
    <Global.System.Runtime.CompilerServices.CompilerGeneratedAttribute(),  _
     Global.System.CodeDom.Compiler.GeneratedCodeAttribute("Microsoft.VisualStudio.Editors.SettingsDesigner.SettingsSingleFileGenerator", "16.8.1.0"),  _
     Global.System.ComponentModel.EditorBrowsableAttribute(Global.System.ComponentModel.EditorBrowsableState.Advanced)>  _
    Partial Friend NotInheritable Class MySettings
        Inherits Global.System.Configuration.ApplicationSettingsBase
        
        Private Shared defaultInstance As MySettings = CType(Global.System.Configuration.ApplicationSettingsBase.Synchronized(New MySettings()),MySettings)
        
#Region "My.Settings Auto-Save Functionality"
#If _MyType = "WindowsForms" Then
    Private Shared addedHandler As Boolean

    Private Shared addedHandlerLockObject As New Object

    <Global.System.Diagnostics.DebuggerNonUserCodeAttribute(), Global.System.ComponentModel.EditorBrowsableAttribute(Global.System.ComponentModel.EditorBrowsableState.Advanced)> _
    Private Shared Sub AutoSaveSettings(sender As Global.System.Object, e As Global.System.EventArgs)
        If My.Application.SaveMySettingsOnExit Then
            My.Settings.Save()
        End If
    End Sub
#End If
#End Region
        
        Public Shared ReadOnly Property [Default]() As MySettings
            Get
                
#If _MyType = "WindowsForms" Then
               If Not addedHandler Then
                    SyncLock addedHandlerLockObject
                        If Not addedHandler Then
                            AddHandler My.Application.Shutdown, AddressOf AutoSaveSettings
                            addedHandler = True
                        End If
                    End SyncLock
                End If
#End If
                Return defaultInstance
            End Get
        End Property
        
        <Global.System.Configuration.ApplicationScopedSettingAttribute(),  _
         Global.System.Diagnostics.DebuggerNonUserCodeAttribute(),  _
         Global.System.Configuration.DefaultSettingValueAttribute("https://portaleclinico.asmn.re.it")>  _
        Public ReadOnly Property UrlPortaleCLinico() As String
            Get
                Return CType(Me("UrlPortaleCLinico"),String)
            End Get
        End Property
        
        <Global.System.Configuration.ApplicationScopedSettingAttribute(),  _
         Global.System.Diagnostics.DebuggerNonUserCodeAttribute(),  _
         Global.System.Configuration.DefaultSettingValueAttribute("progel.it\dev_vs")>  _
        Public ReadOnly Property WsPatientSummaryUser() As String
            Get
                Return CType(Me("WsPatientSummaryUser"),String)
            End Get
        End Property
        
        <Global.System.Configuration.ApplicationScopedSettingAttribute(),  _
         Global.System.Diagnostics.DebuggerNonUserCodeAttribute(),  _
         Global.System.Configuration.DefaultSettingValueAttribute("aa1234BB")>  _
        Public ReadOnly Property WsPatientSummaryPassword() As String
            Get
                Return CType(Me("WsPatientSummaryPassword"),String)
            End Get
        End Property
        
        <Global.System.Configuration.ApplicationScopedSettingAttribute(),  _
         Global.System.Diagnostics.DebuggerNonUserCodeAttribute(),  _
         Global.System.Configuration.DefaultSettingValueAttribute("False")>  _
        Public ReadOnly Property PatientSummaryEnabled() As Boolean
            Get
                Return CType(Me("PatientSummaryEnabled"),Boolean)
            End Get
        End Property
        
        <Global.System.Configuration.ApplicationScopedSettingAttribute(),  _
         Global.System.Diagnostics.DebuggerNonUserCodeAttribute(),  _
         Global.System.Configuration.DefaultSettingValueAttribute("progel.it\dev_vs")>  _
        Public ReadOnly Property WcfDwhClinico_User() As String
            Get
                Return CType(Me("WcfDwhClinico_User"),String)
            End Get
        End Property
        
        <Global.System.Configuration.ApplicationScopedSettingAttribute(),  _
         Global.System.Diagnostics.DebuggerNonUserCodeAttribute(),  _
         Global.System.Configuration.DefaultSettingValueAttribute("aa1234BB")>  _
        Public ReadOnly Property WcfDwhClinico_Password() As String
            Get
                Return CType(Me("WcfDwhClinico_Password"),String)
            End Get
        End Property
        
        <Global.System.Configuration.ApplicationScopedSettingAttribute(),  _
         Global.System.Diagnostics.DebuggerNonUserCodeAttribute(),  _
         Global.System.Configuration.DefaultSettingValueAttribute("RILEVAZIONE CONSENSO MINORE<br/>Inserire le generalità del Genitore/Tutore Legale"& _ 
            "")>  _
        Public ReadOnly Property DatiAutenteAutorizzatore_Titolo() As String
            Get
                Return CType(Me("DatiAutenteAutorizzatore_Titolo"),String)
            End Get
        End Property
        
        <Global.System.Configuration.ApplicationScopedSettingAttribute(),  _
         Global.System.Diagnostics.DebuggerNonUserCodeAttribute(),  _
         Global.System.Configuration.DefaultSettingValueAttribute("~/Reporting/Reports/RefertoDettaglio.aspx?@@FLD@@@IdRefertiBase=@Id_Referto")>  _
        Public ReadOnly Property ApreReferto_DefaultView() As String
            Get
                Return CType(Me("ApreReferto_DefaultView"),String)
            End Get
        End Property
        
        <Global.System.Configuration.ApplicationScopedSettingAttribute(),  _
         Global.System.Diagnostics.DebuggerNonUserCodeAttribute(),  _
         Global.System.Configuration.DefaultSettingValueAttribute("~/Reporting/Reports/GroupListaReferti.aspx?@@FLD@@@IdPaziente=@Id_Paziente")>  _
        Public ReadOnly Property Referti_Link() As String
            Get
                Return CType(Me("Referti_Link"),String)
            End Get
        End Property
        
        <Global.System.Configuration.ApplicationScopedSettingAttribute(),  _
         Global.System.Diagnostics.DebuggerNonUserCodeAttribute(),  _
         Global.System.Configuration.DefaultSettingValueAttribute("Progel.it\sviluppo")>  _
        Public ReadOnly Property Role_Delete() As String
            Get
                Return CType(Me("Role_Delete"),String)
            End Get
        End Property
        
        <Global.System.Configuration.ApplicationScopedSettingAttribute(),  _
         Global.System.Diagnostics.DebuggerNonUserCodeAttribute(),  _
         Global.System.Configuration.DefaultSettingValueAttribute("True")>  _
        Public ReadOnly Property ButtonAggiungiNota_Visible() As Boolean
            Get
                Return CType(Me("ButtonAggiungiNota_Visible"),Boolean)
            End Get
        End Property
        
        <Global.System.Configuration.ApplicationScopedSettingAttribute(),  _
         Global.System.Diagnostics.DebuggerNonUserCodeAttribute(),  _
         Global.System.Configuration.DefaultSettingValueAttribute("PROGEL.IT\DEV_VS")>  _
        Public ReadOnly Property SacDataAccess_User() As String
            Get
                Return CType(Me("SacDataAccess_User"),String)
            End Get
        End Property
        
        <Global.System.Configuration.ApplicationScopedSettingAttribute(),  _
         Global.System.Diagnostics.DebuggerNonUserCodeAttribute(),  _
         Global.System.Configuration.DefaultSettingValueAttribute("aa1234BB")>  _
        Public ReadOnly Property SacDataAccess_Password() As String
            Get
                Return CType(Me("SacDataAccess_Password"),String)
            End Get
        End Property
        
        <Global.System.Configuration.ApplicationScopedSettingAttribute(),  _
         Global.System.Diagnostics.DebuggerNonUserCodeAttribute(),  _
         Global.System.Configuration.DefaultSettingValueAttribute("http://DAGOBAH2:8044/WS-DI-DWH-PDF/StampaReferto.aspx")>  _
        Public ReadOnly Property Printing_PageUrl() As String
            Get
                Return CType(Me("Printing_PageUrl"),String)
            End Get
        End Property
        
        <Global.System.Configuration.ApplicationScopedSettingAttribute(),  _
         Global.System.Diagnostics.DebuggerNonUserCodeAttribute(),  _
         Global.System.Configuration.DefaultSettingValueAttribute("1")>  _
        Public ReadOnly Property Printing_ShowGeneraPDF() As Integer
            Get
                Return CType(Me("Printing_ShowGeneraPDF"),Integer)
            End Get
        End Property
        
        <Global.System.Configuration.ApplicationScopedSettingAttribute(),  _
         Global.System.Diagnostics.DebuggerNonUserCodeAttribute(),  _
         Global.System.Configuration.DefaultSettingValueAttribute("")>  _
        Public ReadOnly Property WsPrintManager_User() As String
            Get
                Return CType(Me("WsPrintManager_User"),String)
            End Get
        End Property
        
        <Global.System.Configuration.ApplicationScopedSettingAttribute(),  _
         Global.System.Diagnostics.DebuggerNonUserCodeAttribute(),  _
         Global.System.Configuration.DefaultSettingValueAttribute("")>  _
        Public ReadOnly Property WsPrintManager_Password() As String
            Get
                Return CType(Me("WsPrintManager_Password"),String)
            End Get
        End Property
        
        <Global.System.Configuration.ApplicationScopedSettingAttribute(),  _
         Global.System.Diagnostics.DebuggerNonUserCodeAttribute(),  _
         Global.System.Configuration.DefaultSettingValueAttribute("PROGEL.IT\DevApp_DWH_RenderPdf")>  _
        Public ReadOnly Property WsRenderingPdf_User() As String
            Get
                Return CType(Me("WsRenderingPdf_User"),String)
            End Get
        End Property
        
        <Global.System.Configuration.ApplicationScopedSettingAttribute(),  _
         Global.System.Diagnostics.DebuggerNonUserCodeAttribute(),  _
         Global.System.Configuration.DefaultSettingValueAttribute("aa1234BB")>  _
        Public ReadOnly Property WsRenderingPdf_Password() As String
            Get
                Return CType(Me("WsRenderingPdf_Password"),String)
            End Get
        End Property
        
        <Global.System.Configuration.ApplicationScopedSettingAttribute(),  _
         Global.System.Diagnostics.DebuggerNonUserCodeAttribute(),  _
         Global.System.Configuration.DefaultSettingValueAttribute("365")>  _
        Public ReadOnly Property Referti_FiltroDataDal_DefaultDaysBeforeNow() As Integer
            Get
                Return CType(Me("Referti_FiltroDataDal_DefaultDaysBeforeNow"),Integer)
            End Get
        End Property
        
        <Global.System.Configuration.ApplicationScopedSettingAttribute(),  _
         Global.System.Diagnostics.DebuggerNonUserCodeAttribute(),  _
         Global.System.Configuration.DefaultSettingValueAttribute("http://DAGOBAH2:8087/DWHCLINICO/Referti/ApreReferto.aspx?IdReferto={0}")>  _
        Public ReadOnly Property WsRenderingPdf_UrlDettaglioReferto() As String
            Get
                Return CType(Me("WsRenderingPdf_UrlDettaglioReferto"),String)
            End Get
        End Property
        
        <Global.System.Configuration.ApplicationScopedSettingAttribute(),  _
         Global.System.Diagnostics.DebuggerNonUserCodeAttribute(),  _
         Global.System.Configuration.DefaultSettingValueAttribute("10000")>  _
        Public ReadOnly Property StampaReferti_UiStampeRefreshInterval_Ms() As Integer
            Get
                Return CType(Me("StampaReferti_UiStampeRefreshInterval_Ms"),Integer)
            End Get
        End Property
        
        <Global.System.Configuration.ApplicationScopedSettingAttribute(),  _
         Global.System.Diagnostics.DebuggerNonUserCodeAttribute(),  _
         Global.System.Configuration.DefaultSettingValueAttribute("Progel.it\sviluppo")>  _
        Public ReadOnly Property RefertiOpenDocument_Role() As String
            Get
                Return CType(Me("RefertiOpenDocument_Role"),String)
            End Get
        End Property
        
        <Global.System.Configuration.ApplicationScopedSettingAttribute(),  _
         Global.System.Diagnostics.DebuggerNonUserCodeAttribute(),  _
         Global.System.Configuration.DefaultSettingValueAttribute("Apri Documento")>  _
        Public ReadOnly Property RefertiOpenDocument_Text() As String
            Get
                Return CType(Me("RefertiOpenDocument_Text"),String)
            End Get
        End Property
        
        <Global.System.Configuration.ApplicationScopedSettingAttribute(),  _
         Global.System.Diagnostics.DebuggerNonUserCodeAttribute(),  _
         Global.System.Configuration.DefaultSettingValueAttribute("1")>  _
        Public ReadOnly Property ListaAccessiPaziente_Visible() As Integer
            Get
                Return CType(Me("ListaAccessiPaziente_Visible"),Integer)
            End Get
        End Property
        
        <Global.System.Configuration.ApplicationScopedSettingAttribute(),  _
         Global.System.Diagnostics.DebuggerNonUserCodeAttribute(),  _
         Global.System.Configuration.DefaultSettingValueAttribute("http://DAGOBAH2:8087/SAC/Pazienti/PazienteDettaglio.aspx?id={0}")>  _
        Public ReadOnly Property UrlSacPaziente() As String
            Get
                Return CType(Me("UrlSacPaziente"),String)
            End Get
        End Property
        
        <Global.System.Configuration.ApplicationScopedSettingAttribute(),  _
         Global.System.Diagnostics.DebuggerNonUserCodeAttribute(),  _
         Global.System.Configuration.SpecialSettingAttribute(Global.System.Configuration.SpecialSetting.ConnectionString),  _
         Global.System.Configuration.DefaultSettingValueAttribute("Data Source=ALDERAAN;Initial Catalog=AuslAsmnre_SAC;Integrated Security=True")>  _
        Public ReadOnly Property SAC_ConnectionString() As String
            Get
                Return CType(Me("SAC_ConnectionString"),String)
            End Get
        End Property
        
        <Global.System.Configuration.ApplicationScopedSettingAttribute(),  _
         Global.System.Diagnostics.DebuggerNonUserCodeAttribute(),  _
         Global.System.Configuration.DefaultSettingValueAttribute(""&Global.Microsoft.VisualBasic.ChrW(13)&Global.Microsoft.VisualBasic.ChrW(10)&"          Siete entrati in un archivio di dati sensibili, tutelati e protetti d"& _ 
            "alla Legge sulla privacy. Qualsiasi violazione e uso ingiustificato o improprio "& _ 
            "può configurare un illecito disciplinare, civile o penale. Gli accessi vengono p"& _ 
            "eriodicamente monitorati.&#xA;"&Global.Microsoft.VisualBasic.ChrW(13)&Global.Microsoft.VisualBasic.ChrW(10)&"          Il DataWareHouse Clinico costituisce u"& _ 
            "n archivio potenzialmente INCOMPLETO dei dati sanitari del paziente. Alcune info"& _ 
            "rmazioni cliniche potrebbero non essere disponibili per motivi tecnici o per ESP"& _ 
            "LICITA RICHIESTA DI OSCURAMENTO da parte dell'assistito."&Global.Microsoft.VisualBasic.ChrW(13)&Global.Microsoft.VisualBasic.ChrW(10)&"        ")>  _
        Public ReadOnly Property Messaggio_WarningPrivacy() As String
            Get
                Return CType(Me("Messaggio_WarningPrivacy"),String)
            End Get
        End Property
        
        <Global.System.Configuration.ApplicationScopedSettingAttribute(),  _
         Global.System.Diagnostics.DebuggerNonUserCodeAttribute(),  _
         Global.System.Configuration.DefaultSettingValueAttribute("True")>  _
        Public ReadOnly Property FsePulsanteAbilitato() As Boolean
            Get
                Return CType(Me("FsePulsanteAbilitato"),Boolean)
            End Get
        End Property
        
        <Global.System.Configuration.ApplicationScopedSettingAttribute(),  _
         Global.System.Diagnostics.DebuggerNonUserCodeAttribute(),  _
         Global.System.Configuration.DefaultSettingValueAttribute("200")>  _
        Public ReadOnly Property FseDocumentiListaTop() As Integer
            Get
                Return CType(Me("FseDocumentiListaTop"),Integer)
            End Get
        End Property
        
        <Global.System.Configuration.ApplicationScopedSettingAttribute(),  _
         Global.System.Diagnostics.DebuggerNonUserCodeAttribute(),  _
         Global.System.Configuration.DefaultSettingValueAttribute("progel.it\dev_vs")>  _
        Public ReadOnly Property WsSac_User() As String
            Get
                Return CType(Me("WsSac_User"),String)
            End Get
        End Property
        
        <Global.System.Configuration.ApplicationScopedSettingAttribute(),  _
         Global.System.Diagnostics.DebuggerNonUserCodeAttribute(),  _
         Global.System.Configuration.DefaultSettingValueAttribute("aa1234BB")>  _
        Public ReadOnly Property WsSac_Password() As String
            Get
                Return CType(Me("WsSac_Password"),String)
            End Get
        End Property
        
        <Global.System.Configuration.ApplicationScopedSettingAttribute(),  _
         Global.System.Diagnostics.DebuggerNonUserCodeAttribute(),  _
         Global.System.Configuration.DefaultSettingValueAttribute("True")>  _
        Public ReadOnly Property ShowNoteAnamnesticheTab() As Boolean
            Get
                Return CType(Me("ShowNoteAnamnesticheTab"),Boolean)
            End Get
        End Property
        
        <Global.System.Configuration.ApplicationScopedSettingAttribute(),  _
         Global.System.Diagnostics.DebuggerNonUserCodeAttribute(),  _
         Global.System.Configuration.DefaultSettingValueAttribute("DwhClinico@progel.it")>  _
        Public ReadOnly Property MittenteMail() As String
            Get
                Return CType(Me("MittenteMail"),String)
            End Get
        End Property
        
        <Global.System.Configuration.ApplicationScopedSettingAttribute(),  _
         Global.System.Diagnostics.DebuggerNonUserCodeAttribute(),  _
         Global.System.Configuration.DefaultSettingValueAttribute("https://di-go.asmn.net/DwhClinico/{0}")>  _
        Public ReadOnly Property UrlMailLinkAccessoDiretto() As String
            Get
                Return CType(Me("UrlMailLinkAccessoDiretto"),String)
            End Get
        End Property
        
        <Global.System.Configuration.ApplicationScopedSettingAttribute(),  _
         Global.System.Diagnostics.DebuggerNonUserCodeAttribute(),  _
         Global.System.Configuration.DefaultSettingValueAttribute("True")>  _
        Public ReadOnly Property AziendaErogante_Visible() As Boolean
            Get
                Return CType(Me("AziendaErogante_Visible"),Boolean)
            End Get
        End Property
        
        <Global.System.Configuration.ApplicationScopedSettingAttribute(),  _
         Global.System.Diagnostics.DebuggerNonUserCodeAttribute(),  _
         Global.System.Configuration.DefaultSettingValueAttribute("True")>  _
        Public ReadOnly Property Print_Enabled() As Boolean
            Get
                Return CType(Me("Print_Enabled"),Boolean)
            End Get
        End Property
        
        <Global.System.Configuration.ApplicationScopedSettingAttribute(),  _
         Global.System.Diagnostics.DebuggerNonUserCodeAttribute(),  _
         Global.System.Configuration.DefaultSettingValueAttribute("False")>  _
        Public ReadOnly Property NuovaGestioneConsensi() As Boolean
            Get
                Return CType(Me("NuovaGestioneConsensi"),Boolean)
            End Get
        End Property
        
        <Global.System.Configuration.ApplicationScopedSettingAttribute(),  _
         Global.System.Diagnostics.DebuggerNonUserCodeAttribute(),  _
         Global.System.Configuration.DefaultSettingValueAttribute("47f2a002-85e4-4b5b-af93-bb848e0c7a4a")>  _
        Public ReadOnly Property InstrumentationKey() As String
            Get
                Return CType(Me("InstrumentationKey"),String)
            End Get
        End Property
        
        <Global.System.Configuration.ApplicationScopedSettingAttribute(),  _
         Global.System.Diagnostics.DebuggerNonUserCodeAttribute(),  _
         Global.System.Configuration.DefaultSettingValueAttribute("True")>  _
        Public ReadOnly Property ShowCalendarioTab() As Boolean
            Get
                Return CType(Me("ShowCalendarioTab"),Boolean)
            End Get
        End Property
    End Class
End Namespace

Namespace My
    
    <Global.Microsoft.VisualBasic.HideModuleNameAttribute(),  _
     Global.System.Diagnostics.DebuggerNonUserCodeAttribute(),  _
     Global.System.Runtime.CompilerServices.CompilerGeneratedAttribute()>  _
    Friend Module MySettingsProperty
        
        <Global.System.ComponentModel.Design.HelpKeywordAttribute("My.Settings")>  _
        Friend ReadOnly Property Settings() As Global.DwhClinico.Web.My.MySettings
            Get
                Return Global.DwhClinico.Web.My.MySettings.Default
            End Get
        End Property
    End Module
End Namespace
