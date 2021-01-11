<%@ Page Title="Sistemi" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master"
    CodeBehind="SistemiLista.aspx.vb" Inherits=".SistemiLista" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
    <asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False"
        Visible="False" />
    <table id="pannelloFiltri" runat="server" class="toolbar">
        <tr>
            <td colspan="7">
                <asp:HyperLink ID="lnkNuovo" runat="server" NavigateUrl="SistemiDettaglio.aspx" ToolTip="Nuovo Sistema"><img src="../Images/newitem.gif" alt="Nuovo Sistema" class="toolbar-img"/>Nuovo Sistema</asp:HyperLink>
            </td>
        </tr>
        <tr>
            <td>Azienda
            </td>
            <td>
                <asp:DropDownList ID="ddlFiltriAzienda" runat="server" Width="120px" AppendDataBoundItems="True"
                    DataSourceID="odsAziende" DataTextField="Descrizione" DataValueField="Codice">
                    <asp:ListItem Text="" Value="" />
                </asp:DropDownList>
            </td>
            <td>Codice
            </td>
            <td>
                <asp:TextBox ID="txtFiltriCodice" runat="server" Width="120px" MaxLength="16" />
            </td>
            <td>Descrizione
            </td>
            <td>
                <asp:TextBox ID="txtFiltriDescrizione" runat="server" Width="120px" MaxLength="128" />
            </td>
            <td>Attivo
            </td>
            <td>
                <asp:DropDownList ID="ddlAttivo" runat="server" Width="120px">
                    <asp:ListItem Text="" Value="" />
                    <asp:ListItem Text="Si" Value="1" Selected />
                    <asp:ListItem Text="No" Value="0" />
                </asp:DropDownList>
            </td>
            <td width="100%">
                <asp:Button ID="butFiltriRicerca" runat="server" CssClass="TabButton" Text="Cerca" />
            </td>
        </tr>
        <tr>
            <td colspan="7">
                <br />
            </td>
        </tr>
    </table>
    <br />
    <asp:GridView ID="gvLista" runat="server" AllowPaging="True" AllowSorting="True"
        DataSourceID="odsLista" GridLines="Horizontal" AutoGenerateColumns="false" PageSize="100"
        Width="100%" EnableModelValidation="True" EmptyDataText="Nessun risultato!" PagerSettings-Position="TopAndBottom"
        DataKeyNames="Id" CssClass="GridYellow" HeaderStyle-CssClass="Header" AlternatingRowStyle-CssClass="AlternatingRow"
        PagerStyle-CssClass="Pager">
        <Columns>
            <asp:HyperLinkField DataTextField="Codice" DataNavigateUrlFormatString="SistemiDettaglio.aspx?id={0}"
                DataNavigateUrlFields="Id" HeaderText="Codice" SortExpression="Codice" ItemStyle-Width="150px" />
            <asp:BoundField DataField="CodiceAzienda" HeaderText="Codice Azienda" SortExpression="CodiceAzienda"
                ItemStyle-Width="70px" />
            <asp:CheckBoxField DataField="Attivo" HeaderText="Attivo" ReadOnly="True" SortExpression="Attivo"
                ItemStyle-Width="60px" />
            <asp:CheckBoxField DataField="Erogante" HeaderText="Erogante" ReadOnly="True" SortExpression="Erogante"
                ItemStyle-Width="60px" />
            <asp:CheckBoxField DataField="Richiedente" HeaderText="Richiedente" ReadOnly="True"
                SortExpression="Richiedente" ItemStyle-Width="60px" />
            <asp:BoundField DataField="Descrizione" HeaderText="Descrizione" SortExpression="Descrizione" />
        </Columns>
    </asp:GridView>
    <asp:ObjectDataSource ID="odsLista" runat="server" SelectMethod="GetData" TypeName="OrganigrammaDataSetTableAdapters.SistemiTableAdapter">
        <SelectParameters>
            <asp:ControlParameter ControlID="txtFiltriCodice" Name="Codice" PropertyName="Text"
                Type="String" />
            <asp:ControlParameter ControlID="txtFiltriDescrizione" Name="Descrizione" PropertyName="Text"
                Type="String" />
            <asp:Parameter Name="Erogante" Type="Boolean" />
            <asp:Parameter Name="Richiedente" Type="Boolean" />
            <asp:ControlParameter ControlID="ddlFiltriAzienda" Name="CodiceAzienda" PropertyName="SelectedValue"
                Type="String" />
            <asp:Parameter Name="Top" Type="Int32" DefaultValue="1000" />
            <asp:ControlParameter ControlID="ddlAttivo" Name="Attivo" PropertyName="SelectedValue" Type="String" />
        </SelectParameters>
    </asp:ObjectDataSource>
    <asp:ObjectDataSource ID="odsAziende" runat="server" OldValuesParameterFormatString="{0}"
        SelectMethod="AziendeLista" TypeName="OrganigrammaDataSetTableAdapters.AziendeListaTableAdapter"
        CacheDuration="120" CacheKeyDependency="CacheAziende" EnableCaching="True"></asp:ObjectDataSource>
</asp:Content>
