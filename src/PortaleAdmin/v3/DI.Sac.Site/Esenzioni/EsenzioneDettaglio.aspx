<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master"
    CodeBehind="EsenzioneDettaglio.aspx.vb" Inherits="DI.Sac.Admin.EsenzioneDettaglio" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
    <asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False"
        Visible="False"></asp:Label>
    <table cellpadding="1" cellspacing="0" border="0" style="width: 100%;">
        <tr>
            <td class="toolbar">
                <asp:HyperLink ID="lnkIndietro" runat="server" NavigateUrl="~/Pazienti/PazienteDettaglio.aspx?id={0}"><img src="../Images/back.gif" alt="Indietro" class="toolbar-img"/>Indietro</asp:HyperLink>
            </td>
        </tr>
    </table>
    <br />
    <table cellpadding="1" cellspacing="0" border="0">
        <asp:FormView ID="MainFormView" runat="server" DataKeyNames="Id" DataSourceID="EsenzioneDettaglioObjectDataSource">
            <ItemTemplate>
                <table cellpadding="3" cellspacing="0" border="0" width="350">
                    <tr>
                        <td class="toolbar" colspan="2">
                            <p>
                                Dettaglio Esenzione</p>
                        </td>
                    </tr>
                    <tr style="height: 30px;">
                        <td colspan="2">
                        </td>
                    </tr>
                    <tr style="height: 30px;">
                        <td class="Td-Text">
                            Data Inserimento
                        </td>
                        <td class="Td-Value">
                            <asp:Label ID="lblDataInserimento" runat="server" Text='<%# Eval("DataInserimento", "{0:d}") %>'
                                CssClass="LabelReadOnly"></asp:Label>&nbsp;
                        </td>
                    </tr>
                    <tr style="height: 30px;">
                        <td class="Td-Text">
                            Data Modifica
                        </td>
                        <td class="Td-Value">
                            <asp:Label ID="lblDataModifica" runat="server" Text='<%# Eval("DataModifica", "{0:d}") %>'
                                CssClass="LabelReadOnly"></asp:Label>&nbsp;
                        </td>
                    </tr>
                    <tr style="height: 30px;">
                        <td class="Td-Text">
                            Codice Esenzione
                        </td>
                        <td class="Td-Value">
                            <asp:Label ID="lblCodiceEsenzione" runat="server" Text='<%# Eval("CodiceEsenzione") %>'
                                CssClass="LabelReadOnly"></asp:Label>&nbsp;
                        </td>
                    </tr>
                    <tr style="height: 30px;">
                        <td class="Td-Text">
                            Codice Diagnosi
                        </td>
                        <td class="Td-Value">
                            <asp:Label ID="lblCodiceDiagnosi" runat="server" Text='<%# Eval("CodiceDiagnosi") %>'
                                CssClass="LabelReadOnly"></asp:Label>&nbsp;
                        </td>
                    </tr>
                    <tr style="height: 30px;">
                        <td class="Td-Text">
                            Patologica
                        </td>
                        <td class="Td-Value">
                            <asp:CheckBox ID="chkPatologica" runat="server" Checked='<%# Eval("Patologica") %>'
                                Enabled="false" />
                        </td>
                    </tr>
                    <tr style="height: 30px;">
                        <td class="Td-Text">
                            Data Inizio Validita'
                        </td>
                        <td class="Td-Value">
                            <asp:Label ID="lblDataInizioValidita" runat="server" Text='<%# Eval("DataInizioValidita", "{0:d}") %>'
                                CssClass="LabelReadOnly"></asp:Label>&nbsp;
                        </td>
                    </tr>
                    <tr style="height: 30px;">
                        <td class="Td-Text">
                            Data Fine Validita'
                        </td>
                        <td class="Td-Value">
                            <asp:Label ID="lblDataFineValidita" runat="server" Text='<%# Eval("DataFineValidita", "{0:d}") %>'
                                CssClass="LabelReadOnly"></asp:Label>&nbsp;
                        </td>
                    </tr>
                    <tr style="height: 30px;">
                        <td class="Td-Text">
                            Nr Autorizzazione Esenzione
                        </td>
                        <td class="Td-Value">
                            <asp:Label ID="lblNumeroAutorizzazioneEsenzione" runat="server" Text='<%# Eval("NumeroAutorizzazioneEsenzione") %>'
                                CssClass="LabelReadOnly"></asp:Label>&nbsp;
                        </td>
                    </tr>
                    <tr style="height: 30px;">
                        <td class="Td-Text">
                            Note Aggiuntive
                        </td>
                        <td class="Td-Value">
                            <asp:Label ID="lblNoteAggiuntive" runat="server" Text='<%# Eval("NoteAggiuntive") %>'
                                CssClass="LabelReadOnly"></asp:Label>&nbsp;
                        </td>
                    </tr>
                    <tr style="height: 30px;">
                        <td class="Td-Text">
                            Codice Testo Esenzione
                        </td>
                        <td class="Td-Value">
                            <asp:Label ID="lblCodiceTestoEsenzione" runat="server" Text='<%# Eval("CodiceTestoEsenzione") %>'
                                CssClass="LabelReadOnly"></asp:Label>&nbsp;
                        </td>
                    </tr>
                    <tr style="height: 30px;">
                        <td class="Td-Text">
                            Testo Esenzione
                        </td>
                        <td class="Td-Value">
                            <asp:Label ID="lblTestoEsenzione" runat="server" Text='<%# Eval("TestoEsenzione") %>'
                                CssClass="LabelReadOnly"></asp:Label>&nbsp;
                        </td>
                    </tr>
                    <tr style="height: 30px;">
                        <td class="Td-Text">
                            Decodifica Esenzione Diagnosi
                        </td>
                        <td class="Td-Value">
                            <asp:Label ID="lblDecodificaEsenzioneDiagnosi" runat="server" Text='<%# Eval("DecodificaEsenzioneDiagnosi") %>'
                                CssClass="LabelReadOnly"></asp:Label>&nbsp;
                        </td>
                    </tr>
                    <tr style="height: 30px;">
                        <td class="Td-Text">
                            Attributo Esenzione Diagnosi
                        </td>
                        <td class="Td-Value">
                            <asp:Label ID="lblAttributoEsenzioneDiagnosi" runat="server" Text='<%# Eval("AttributoEsenzioneDiagnosi") %>'
                                CssClass="LabelReadOnly"></asp:Label>&nbsp;
                        </td>
                    </tr>
                </table>
            </ItemTemplate>
            <EmptyDataTemplate>
                Dettaglio non disponibile!
            </EmptyDataTemplate>
        </asp:FormView>
    </table>
    <asp:ObjectDataSource ID="EsenzioneDettaglioObjectDataSource" runat="server" SelectMethod="GetData"
        TypeName="DI.Sac.Admin.Data.PazientiDataSetTableAdapters.PazientiEsenzioniTableAdapter"
        DeleteMethod="Delete" InsertMethod="Insert" UpdateMethod="Update">
        <DeleteParameters>
            <asp:Parameter DbType="Guid" Name="Id" />
            <asp:Parameter Name="Ts" Type="Object" />
            <asp:Parameter Name="Utente" Type="String" />
        </DeleteParameters>
        <UpdateParameters>
            <asp:Parameter DbType="Guid" Name="Id" />
            <asp:Parameter Name="Ts" Type="Object" />
            <asp:Parameter DbType="Guid" Name="IdPaziente" />
            <asp:Parameter Name="CodiceEsenzione" Type="String" />
            <asp:Parameter Name="CodiceDiagnosi" Type="String" />
            <asp:Parameter Name="Patologica" Type="Boolean" />
            <asp:Parameter Name="DataInizioValidita" Type="DateTime" />
            <asp:Parameter Name="DataFineValidita" Type="DateTime" />
            <asp:Parameter Name="NumeroAutorizzazioneEsenzione" Type="String" />
            <asp:Parameter Name="NoteAggiuntive" Type="String" />
            <asp:Parameter Name="CodiceTestoEsenzione" Type="String" />
            <asp:Parameter Name="TestoEsenzione" Type="String" />
            <asp:Parameter Name="DecodificaEsenzioneDiagnosi" Type="String" />
            <asp:Parameter Name="AttributoEsenzioneDiagnosi" Type="String" />
            <asp:Parameter Name="Utente" Type="String" />
        </UpdateParameters>
        <SelectParameters>
            <asp:QueryStringParameter DbType="Guid" Name="Id" QueryStringField="idEsenzione" />
        </SelectParameters>
        <InsertParameters>
            <asp:Parameter DbType="Guid" Name="IdPaziente" />
            <asp:Parameter Name="CodiceEsenzione" Type="String" />
            <asp:Parameter Name="CodiceDiagnosi" Type="String" />
            <asp:Parameter Name="Patologica" Type="Boolean" />
            <asp:Parameter Name="DataInizioValidita" Type="DateTime" />
            <asp:Parameter Name="DataFineValidita" Type="DateTime" />
            <asp:Parameter Name="NumeroAutorizzazioneEsenzione" Type="String" />
            <asp:Parameter Name="NoteAggiuntive" Type="String" />
            <asp:Parameter Name="CodiceTestoEsenzione" Type="String" />
            <asp:Parameter Name="TestoEsenzione" Type="String" />
            <asp:Parameter Name="DecodificaEsenzioneDiagnosi" Type="String" />
            <asp:Parameter Name="AttributoEsenzioneDiagnosi" Type="String" />
            <asp:Parameter Name="Utente" Type="String" />
        </InsertParameters>
    </asp:ObjectDataSource>
</asp:Content>
 