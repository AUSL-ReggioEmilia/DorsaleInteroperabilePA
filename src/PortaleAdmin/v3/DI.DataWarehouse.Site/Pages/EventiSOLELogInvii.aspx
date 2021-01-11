<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="EventiSOLELogInvii.aspx.vb" Inherits=".RicoveriSOLElogInvii" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
    <asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False" Visible="False"></asp:Label>
 
    <div style="padding: 3px">
        <asp:Button ID="DeleteButton" CssClass="deleteButton" runat="server" Text="Cancella Ricovero su SOLE" TabIndex="10"
            OnClientClick="return msgboxYESNO('Si conferma l\'invio della notifica di cancellazione a SOLE?');" />
    </div>
    <div>
        <table>
            <tr>
                <td style="vertical-align: middle">
                    <asp:Label ID="lblDallaDataQueue" runat="server" Text="Data Queue (dd/MM/yyyy hh:mm)"></asp:Label></td>
                <td style="vertical-align: middle">
                    <asp:TextBox ID="txtDallaDataQueue" runat="server"></asp:TextBox></td>
                <td style="vertical-align: middle">
                    <asp:Button ID="RiprocessaButton" CssClass="rinotificaButton" runat="server" Text="Riprocessa eventi su SOLE" TabIndex="10" ToolTip="Per riprocessare una serie di eventi selezionare la 'Data Queue' del primo evento da riprocessare."
                        OnClientClick="return msgboxYESNO('Si conferma il riprocessamento degli eventi SOLE?');" /></td>
            </tr>
        </table>
    </div>


    <asp:Label ID="lblTitolo" runat="server" class="Title" Text="" Style="margin-top: 10px;" />

    <asp:GridView ID="gvMain" runat="server" DataSourceID="odsRicoveri" AutoGenerateColumns="False" CssClass="Grid"
        Width="100%" EmptyDataText="Nessun Risultato.">
        <RowStyle CssClass="GridItem" />
        <SelectedRowStyle CssClass="GridSelected" />
        <PagerStyle CssClass="GridPager" />
        <HeaderStyle CssClass="GridHeader" />
        <AlternatingRowStyle CssClass="GridAlternatingItem" />
        <FooterStyle CssClass="GridFooter" />
        <Columns>
            <asp:BoundField DataField="DataQueue" HeaderText="Data Queue" ReadOnly="True" SortExpression="DataQueue"></asp:BoundField>
            <asp:BoundField DataField="IdEvento" HeaderText="I dEvento" ReadOnly="True" SortExpression="IdEvento"></asp:BoundField>
            <asp:BoundField DataField="TipoEvento" HeaderText="Tipo Evento" ReadOnly="True" SortExpression="TipoEvento"></asp:BoundField>
            <asp:CheckBoxField DataField="InviatoSole" HeaderText="Inviato Sole" ReadOnly="True" SortExpression="InviatoSole"></asp:CheckBoxField>
            <asp:BoundField DataField="DataInvioSole" HeaderText="Data Invio Sole" ReadOnly="True" SortExpression="DataInvioSole"></asp:BoundField>
            <asp:CheckBoxField DataField="Oscurato" HeaderText="Oscurato" ReadOnly="True" SortExpression="Oscurato"></asp:CheckBoxField>
            <asp:BoundField DataField="CodiceOscuramento" HeaderText="Codice Oscuramento" ReadOnly="True" SortExpression="CodiceOscuramento"></asp:BoundField>
            <asp:CheckBoxField DataField="Processato" HeaderText="Processato" ReadOnly="True" SortExpression="Processato"></asp:CheckBoxField>
            <asp:BoundField DataField="DataProcesso" HeaderText="Data Processo" ReadOnly="True" SortExpression="DataProcesso"></asp:BoundField>
            <asp:BoundField DataField="EsitoProcesso" HeaderText="Esito Processo" ReadOnly="True" SortExpression="EsitoProcesso"></asp:BoundField>
            <asp:CheckBoxField DataField="Verificato" HeaderText="Verificato" ReadOnly="True" SortExpression="Verificato"></asp:CheckBoxField>
            <asp:BoundField DataField="Versione" HeaderText="Versione" ReadOnly="True" SortExpression="Versione"></asp:BoundField>
            <asp:BoundField DataField="EsitoSoleStato" HeaderText="Esito Sole Stato" ReadOnly="True" SortExpression="EsitoSoleStato"></asp:BoundField>
            <asp:TemplateField HeaderText="Anno / Numero">
                <ItemTemplate>
                    <%# Eval("IdAnno")%>
					/
					<%# Eval("IdNumero")%>
                </ItemTemplate>
            </asp:TemplateField>
        </Columns>
    </asp:GridView>

    <asp:ObjectDataSource ID="odsRicoveri" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="DI.DataWarehouse.Admin.Data.SoleTableAdapters.LogInviiSoleListaPerAziendaNosologicoTableAdapter">
        <SelectParameters>
            <asp:QueryStringParameter QueryStringField="NumeroNosologico" DefaultValue="" Name="NumeroNosologico" Type="String"></asp:QueryStringParameter>
            <asp:QueryStringParameter QueryStringField="AziendaErogante" Name="AziendaErogante" Type="String"></asp:QueryStringParameter>
        </SelectParameters>
    </asp:ObjectDataSource>


</asp:Content>
