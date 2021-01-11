<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="NoteAnamnesticheSinottico.aspx.vb" Inherits=".NoteAnamnesticheSinottico" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
    <style type="text/css">
        .Indent {
            padding-left: 20px !important;
        }
    </style>

    <asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False" Visible="False" />

    <fieldset class="filters">
        <table id="pannelloFiltri" runat="server">
            <tr>
                <td>Periodo
                </td>
                <td>
                    <asp:DropDownList ID="ddlFiltriPeriodo" runat="server" Width="120px" AutoPostBack="True">
                        <asp:ListItem Text="Ultima ora" Value="1" Selected="True" />
                        <asp:ListItem Text="Oggi" Value="2" />
                        <asp:ListItem Text="Ultimi 7 Giorni" Value="3" />
                        <asp:ListItem Text="Ultimi 30 Giorni" Value="4" />
                    </asp:DropDownList>
                </td>
                <td style="padding-left: 30px;">Visualizzazione
                </td>
                <td>
                    <asp:RadioButtonList runat="server" ID="rbtVisual" AutoPostBack="True">
                        <asp:ListItem Text="Compatta" Value="Compatta" Selected="True" />
                        <asp:ListItem Text="Dettagliata" Value="Dettagliata" />
                    </asp:RadioButtonList>
                </td>
            </tr>
        </table>
    </fieldset>

    <asp:GridView ID="gvLista" runat="server" DataSourceID="odsListaSinottico" AutoGenerateColumns="False"
        CssClass="Grid" Width="800px" EmptyDataText="Nessun risultato!">
        <Columns>
            <asp:BoundField DataField="AziendaSistemaErogante" HeaderText="Azienda-SistemaErogante" ReadOnly="True" SortExpression="AziendaSistemaErogante"></asp:BoundField>
            <asp:BoundField DataField="SubProcessoTipo" HeaderText="Tipo" ReadOnly="True" SortExpression="SubProcessoTipo"></asp:BoundField>
            <asp:BoundField DataField="InCorso" HeaderText="In Corso" ReadOnly="True" SortExpression="InCorso"></asp:BoundField>
            <asp:BoundField DataField="Completata" HeaderText="Completata" ReadOnly="True" SortExpression="Completata"></asp:BoundField>
            <asp:BoundField DataField="Variata" HeaderText="Variata" ReadOnly="True" SortExpression="Variata"></asp:BoundField>
            <asp:BoundField DataField="Cancellata" HeaderText="Cancellata" ReadOnly="True" SortExpression="Cancellata"></asp:BoundField>
        </Columns>
		<RowStyle CssClass="GridItem" />
		<SelectedRowStyle CssClass="GridSelected" />
		<PagerStyle CssClass="GridPager" />
		<HeaderStyle CssClass="GridHeader" />
		<FooterStyle CssClass="GridFooter" />
    </asp:GridView>

    <asp:ObjectDataSource ID="odsListaSinottico" runat="server" OldValuesParameterFormatString="{0}" SelectMethod="GetData"
        TypeName="NoteAnamnesticheDataSetTableAdapters.NoteAnamnesticheSinotticoTableAdapter">
        <SelectParameters>
            <asp:Parameter Name="DataDal" Type="DateTime"></asp:Parameter>
            <asp:Parameter Name="DataAl" Type="DateTime"></asp:Parameter>
        </SelectParameters>
    </asp:ObjectDataSource>
</asp:Content>
