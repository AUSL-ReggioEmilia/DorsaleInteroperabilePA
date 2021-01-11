<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="LogAggancioPaziente.aspx.vb" Inherits=".LogAggancioPaziente" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
    <asp:Label ID="lblError" runat="server" CssClass="Error" EnableViewState="False" Visible="False"></asp:Label>

    <%-- PANNELLO FILTRI --%>
    <div id="filterPanel" runat="server">
        <fieldset class="filters">
            <legend>Ricerca</legend>
            <table>
                <tr>
                    <td>Tipo Oggetto</td>
                    <td>Data Dal (dd/MM/yyyy)</td>
                    <td>Data Al (dd/MM/yyyy)</td>
                    <td>Max Records</td>
                    <td></td>
                    <td></td>
                </tr>
                <tr>
                    <td>
                        <asp:DropDownList ID="ddlOggetti" runat="server" Width="120px">
                            <asp:ListItem Selected="True">Tutti</asp:ListItem>
                            <asp:ListItem >Referto</asp:ListItem>
                            <asp:ListItem>Ricovero</asp:ListItem>
                            <asp:ListItem>Prenotazione</asp:ListItem>
                            <asp:ListItem>Prescrizione</asp:ListItem>
                            <asp:ListItem>NotaAnamnestica</asp:ListItem>
                        </asp:DropDownList>
                    </td>
                    <td>
                        <asp:TextBox ID="txtDataDal" runat="server" MaxLength="16" Width="120px"></asp:TextBox>
                    </td>
                    <td>
                        <asp:TextBox ID="txtDataAl" runat="server" MaxLength="16" Width="120px" ></asp:TextBox>
                    </td>
                    <td>
                        <asp:DropDownList ID="ddlMaxRow" runat="server" Width="95px">
                            <asp:ListItem Selected="True">50</asp:ListItem>
                            <asp:ListItem>100</asp:ListItem>
                            <asp:ListItem>500</asp:ListItem>
                            <asp:ListItem>1000</asp:ListItem>
                        </asp:DropDownList>
                    </td>
                    <td style="padding-left: 10px;">
                        <asp:Button ID="SearchButton" Text="Cerca" runat="server" CssClass="Button" CausesValidation="true" />
                    </td>
                    <td style="padding-left: 10px;">
                        <asp:Button ID="ClearFiltersButton" Text="Annulla" runat="server" CssClass="Button" ValidationGroup="null" />
                    </td>
                </tr>
            </table>
        </fieldset>
    </div>

    <asp:GridView ID="gvMain" runat="server" DataSourceID="odsMain" AllowPaging="True" AllowSorting="True" CssClass="Grid" AutoGenerateColumns="False" DataKeyNames="Id" PageSize="100" PagerSettings-Position="TopAndBottom">
        <HeaderStyle CssClass="GridHeader" />
        <PagerStyle CssClass="GridPager" />
        <SelectedRowStyle CssClass="GridSelected" />
        <RowStyle CssClass="GridItem" Wrap="true" />
        <AlternatingRowStyle CssClass="GridAlternatingItem" Wrap="true" />
        <Columns>
            <asp:BoundField DataField="Oggetto" HeaderText="Oggetto" SortExpression="Oggetto"></asp:BoundField>
            <asp:BoundField DataField="DataInserimento" HeaderText="Data Inserimento" SortExpression="DataInserimento"></asp:BoundField>
            <asp:BoundField DataField="IdPaziente" HeaderText="IdPaziente" SortExpression="IdPaziente"></asp:BoundField>
            <asp:BoundField DataField="AziendaErogante" HeaderText="Azienda Erogante" SortExpression="AziendaErogante"></asp:BoundField>
            <asp:BoundField DataField="SistemaErogante" HeaderText="Sistema Erogante" SortExpression="SistemaErogante"></asp:BoundField>
            <asp:BoundField DataField="IdOggetto" HeaderText="IdOggetto" SortExpression="IdOggetto"></asp:BoundField>
            <asp:BoundField DataField="IdEsternoOggetto" HeaderText="IdEsternoOggetto" SortExpression="IdEsternoOggetto"></asp:BoundField>
        </Columns>
        <EmptyDataTemplate>
            Nessun risultato!
        </EmptyDataTemplate>
    </asp:GridView>

    <asp:ObjectDataSource ID="odsMain" runat="server" OldValuesParameterFormatString="original_{0}"
        SelectMethod="GetData" TypeName="MonitorTableAdapters.LogMntAggancioPazienteCercaTableAdapter">
        <SelectParameters>
            <asp:Parameter Name="MaxRow" Type="Int32"></asp:Parameter>
            <asp:Parameter Name="Oggetto" Type="String"></asp:Parameter>
            <asp:Parameter Name="DataDal" Type="DateTime"></asp:Parameter>
            <asp:Parameter Name="DataAl" Type="DateTime"></asp:Parameter>
        </SelectParameters>
    </asp:ObjectDataSource>
        
</asp:Content>
