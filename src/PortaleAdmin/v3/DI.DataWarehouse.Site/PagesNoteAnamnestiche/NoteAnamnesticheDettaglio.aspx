<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="NoteAnamnesticheDettaglio.aspx.vb" Inherits=".NoteAnamnesticheDettaglio" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
    <asp:Label ID="lblError" runat="server" CssClass="Error" EnableViewState="False"></asp:Label>

    <label class="Title">Dettaglio della Nota Anamnestica</label>

    <asp:FormView ID="fvNotaAnamnestica" runat="server" DataSourceID="odsNotaAnamnestica" DataKeyNames="Contenuto,TipoContenuto" DefaultMode="ReadOnly" Style="width: 900px">
        <ItemTemplate>
            <fieldset class="filters">
                <legend>Paziente</legend>
                <table class="table_dettagli" style="width: 900px">
                    <tr class="fv-table-row-height">
                        <td class="Td-Text">Cognome:
                        </td>
                        <td class="Td-Value">
                            <asp:Label CssClass="fv-text-bold" Text='<%# Eval("Cognome") %>' runat="server" ID="CognomeLabel" />
                        </td>
                        <td class="Td-Text">Nome:
                        </td>
                        <td class="Td-Value">
                            <asp:Label CssClass="fv-text-bold" Text='<%# Eval("Nome") %>' runat="server" ID="NomeLabel" />
                        </td>
                        <td class="Td-Text">Sesso:
                        </td>
                        <td class="Td-Value">
                            <asp:Label CssClass="fv-text-bold" Text='<%# Bind("Sesso") %>' runat="server" ID="SessoLabel" />
                        </td>
                    </tr>
                    <tr class="fv-table-row-height">
                        <td class="Td-Text">Codice Fiscale:</td>
                        <td class="Td-Value">
                            <asp:Label CssClass="fv-text-bold" Text='<%# Eval("CodiceFiscale") %>' runat="server" ID="CodiceFiscaleLabel" />
                        </td>
                        <td class="Td-Text">Data Nascita:</td>
                        <td class="Td-Value">
                            <asp:Label CssClass="fv-text-bold" Text='<%# Eval("DataNascita", "{0:d}") %>' runat="server" ID="DataNascitaLabel" />
                        </td>
                        <td class="Td-Text">Comune Nascita:</td>
                        <td class="Td-Value">
                            <asp:Label CssClass="fv-text-bold" Text='<%# Bind("ComuneNascita") %>' runat="server" ID="ComuneNascitaLabel" />
                        </td>
                    </tr>
                    <tr class="fv-table-row-height">
                        <td class="Td-Text">Codice Sanitario
                        </td>
                        <td class="Td-Value">
                            <asp:Label CssClass="fv-text-bold" Text='<%# Bind("CodiceSanitario") %>' runat="server" ID="CodiceSanitarioLabel" />
                        </td>
                    </tr>
                </table>
            </fieldset>

            <fieldset class="filters">
                <legend>Nota Anamnestica</legend>
                <table class="table_dettagli" style="width: 900px">
                    <tr class="fv-table-row-height">
                        <td class="Td-Text">Data Inserimento:
                        </td>
                        <td class="Td-Value" style="width: 20% !important;">
                            <asp:Label CssClass="fv-text-bold" Text='<%# Eval("DataInserimento") %>' runat="server" ID="DataInserimentoLabel" />
                        </td>
                        <td class="Td-Text">Data Modifica:
                        </td>
                        <td class="Td-Value" style="width: 20% !important;">
                            <asp:Label CssClass="fv-text-bold" Text='<%# Eval("DataModifica") %>' runat="server" ID="DataModificaLabel" />
                        </td>
                        <td class="Td-Text">Data Nota:
                        </td>
                        <td class="Td-Value">
                            <asp:Label CssClass="fv-text-bold" Text='<%# Eval("DataNota") %>' runat="server" ID="Label1" />
                        </td>
                    </tr>
                    <tr class="fv-table-row-height">
                        <td class="Td-Text">Azienda Erogante:
                        </td>
                        <td class="Td-Value">
                            <asp:Label CssClass="fv-text-bold" Text='<%# Eval("AziendaErogante") %>' runat="server" ID="AziendaEroganteLabel" />
                        </td>
                        <td class="Td-Text">Sistema Erogante:
                        </td>
                        <td class="Td-Value">
                            <asp:Label CssClass="fv-text-bold" Text='<%# Eval("SistemaErogante") %>' runat="server" ID="SistemaEroganteLabel" />
                        </td>
                        <td class="Td-Text">Stato:
                        </td>
                        <td class="Td-Value">
                            <asp:Label CssClass="fv-text-bold" Text='<%# FormatCodiceDescrizione(Eval("StatoDescrizione"), Eval("StatoCodice")) %>' runat="server" ID="StatoCodiceLabel" />
                        </td>
                    </tr>
                    <tr class="fv-table-row-height">
                        <td class="Td-Text">Tipo:
                        </td>
                        <td class="Td-Value">
                            <asp:Label CssClass="fv-text-bold" Text='<%# FormatCodiceDescrizione(Eval("TipoDescrizione"), Eval("TipoCodice")) %>' runat="server" ID="Label2" />
                        </td>
                        <td class="Td-Text">Data fine validità:
                        </td>
                        <td class="Td-Value">
                            <asp:Label CssClass="fv-text-bold" Text='<%# Eval("DataFineValidita") %>' runat="server" ID="Label5" />
                        </td>

                    </tr>
                    <tr class="fv-table-row-height">
                        <td class="Td-Text">Tipo Contenuto:
                        </td>
                        <td class="Td-Value">
                            <asp:Label CssClass="fv-text-bold" Text='<%# Eval("TipoContenuto") %>' runat="server" ID="Label4" />
                        </td>
                        <td class="Td-Text">Download Contenuto:
                        </td>
                        <td class="Td-Value">
                            <asp:ImageButton ID="ApriContenutoBtn" CommandName="ApriContenuto" ImageUrl="../Images/ViewDoc.gif" ToolTip="Scarica il contenuto della nota anamnestica.." runat="server" />
                        </td>
                        <td class="Td-Text">Mostra Contenuto HTML:
                        </td>
                        <td class="Td-Value">
                            <asp:ImageButton ID="ApriContenutoHtmlBtn" CommandName="ApriContenutoHtml" CommandArgument=' <%# Eval("ContenutoHtml") %>' ImageUrl="../Images/ViewDoc.gif" ToolTip="Visualizza il contenuto della nota anamnestica.." runat="server" />
                        </td>
                    </tr>
                </table>
            </fieldset>

            <%-- MODALE DI VISUALIZZAZIONE DEL CONTENUTO IN FORMATO HTML --%>
            <div id="ContenutoHtmlModal" style="display: none;">
                <div style="overflow: auto; height: 500px;">
                    <%# Eval("ContenutoHtml") %>
                </div>
            </div>
        </ItemTemplate>
    </asp:FormView>

    <label class="Title">Attributi della Nota Anamnestica</label>
    <div id="divAttributi" style="width: 500px">
        <asp:GridView ID="gvAttributiNotaAnamnestica" runat="server" AutoGenerateColumns="False" DataSourceID="OdsAttributiNotaAnamnestica"
            AllowPaging="True" Width="100%" Style="margin-top: 0px !important" CssClass="Grid" AllowSorting="false"
            PageSize="100" PagerSettings-Position="TopAndBottom">
            <HeaderStyle CssClass="GridHeader" />
            <PagerStyle CssClass="GridPager" />
            <SelectedRowStyle CssClass="GridSelected" />
            <RowStyle CssClass="GridItem" Wrap="true" />
            <AlternatingRowStyle CssClass="GridAlternatingItem" Wrap="true" />
            <Columns>
                <asp:BoundField DataField="Nome" HeaderText="Nome" SortExpression="Nome"></asp:BoundField>
                <asp:BoundField DataField="Valore" HeaderText="Valore" SortExpression="Valore"></asp:BoundField>
            </Columns>
            <EmptyDataTemplate>
                "Non sono presenti attributi per il ricovero selezionato."
            </EmptyDataTemplate>
        </asp:GridView>
    </div>

    <asp:ObjectDataSource ID="OdsAttributiNotaAnamnestica" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="NoteAnamnesticheDataSetTableAdapters.AttributiNotaAnamnesticaOttieniTableAdapter">
        <SelectParameters>
            <asp:Parameter DbType="Guid" Name="IdNotaAnamnestica"></asp:Parameter>
        </SelectParameters>
    </asp:ObjectDataSource>

    <asp:ObjectDataSource ID="odsNotaAnamnestica" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="NoteAnamnesticheDataSetTableAdapters.NotaAnamnesticaOttieniTableAdapter">
        <SelectParameters>
            <asp:Parameter DbType="Guid" Name="IdNotaAnamnestica"></asp:Parameter>
        </SelectParameters>
    </asp:ObjectDataSource>


    <%-- IFRAME USATO SOLO PER ESEGUIRE IL DOWNLOAD DEL CONTENUTO --%>
    <iframe id="myIframe" runat="server" style="display: none;"></iframe>

    <script src="../Scripts/PopUp-2.0.0.js"></script>
</asp:Content>
