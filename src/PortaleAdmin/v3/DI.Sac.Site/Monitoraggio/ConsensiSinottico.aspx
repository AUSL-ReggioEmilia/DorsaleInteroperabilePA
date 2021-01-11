<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="ConsensiSinottico.aspx.vb" Inherits=".ConsensiSinottico" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
    <style type="text/css">
        .Indent {
            padding-left: 20px !important;
        }
    </style>

    <asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False"
        Visible="False"></asp:Label>
    <div class="toolbar">
        <table id="pannelloFiltri" runat="server" style="padding: 13px; margin-top: 5px; margin-bottom: 5px;">
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
                <td>Visualizzazione
                </td>
                <td>
                    <asp:RadioButtonList runat="server" ID="rbtVisual" AutoPostBack="True">
                        <asp:ListItem Text="Compatta" Value="Compatta" Selected="True" />
                        <asp:ListItem Text="Dettagliata" Value="Dettagliata" />
                    </asp:RadioButtonList>
                </td>
            </tr>
        </table>
    </div>
    <asp:GridView runat="server" ID="gvLista" AllowPaging="true" AllowSorting="false" GridLines="Horizontal" PageSize="20" PagerSettings-Position="TopAndBottom"
        CssClass="GridYellow" HeaderStyle-CssClass="Header" AlternatingRowStyle-CssClass="AlternatingRow"
        PagerStyle-CssClass="Pager" AutoGenerateColumns="False" Style="margin-top: 10px;" DataSourceID="odsLista" EnableModelValidation="true" EmptyDataText="Nessun Risultato!">
        <Columns>
            <asp:BoundField DataField="Provenienza" HeaderText="Provenienza" SortExpression="Provenienza" HeaderStyle-HorizontalAlign="Left"></asp:BoundField>
            <asp:TemplateField HeaderText="Stato">
                <ItemTemplate>
                    <%# getStatoField(Eval("Stato")) %>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:BoundField DataField="NumGenerico" HeaderText="Generico" ReadOnly="True" SortExpression="NumGenerico"></asp:BoundField>
            <asp:BoundField DataField="NumDossier" HeaderText="Dossier" ReadOnly="True" SortExpression="NumDossier"></asp:BoundField>
            <asp:BoundField DataField="NumStorico" HeaderText="Storico" ReadOnly="True" SortExpression="NumStorico"></asp:BoundField>
            <asp:BoundField DataField="SOLE_LIVELLO_0" HeaderText="SOLE LIVELLO 0" HeaderStyle-CssClass="text-nowrap" ReadOnly="True" SortExpression="SOLE_LIVELLO_0"></asp:BoundField>
            <asp:BoundField DataField="SOLE_LIVELLO_1" HeaderText="SOLE LIVELLO 1" HeaderStyle-CssClass="text-nowrap" ReadOnly="True" SortExpression="SOLE_LIVELLO_1"></asp:BoundField>
            <asp:BoundField DataField="SOLE_LIVELLO_2" HeaderText="SOLE LIVELLO 2" HeaderStyle-CssClass="text-nowrap" ReadOnly="True" SortExpression="SOLE_LIVELLO_2"></asp:BoundField>
            <asp:BoundField DataField="SOLE_STATO_A" HeaderText="SOLE STATO A" HeaderStyle-CssClass="text-nowrap" ReadOnly="True" SortExpression="SOLE_STATO_A"></asp:BoundField>
            <asp:BoundField DataField="SOLE_STATO_N" HeaderText="SOLE STATO N" HeaderStyle-CssClass="text-nowrap" ReadOnly="True" SortExpression="SOLE_STATO_N"></asp:BoundField>
            <asp:BoundField DataField="SOLE_STATO_R" HeaderText="SOLE STATO R" HeaderStyle-CssClass="text-nowrap" ReadOnly="True" SortExpression="SOLE_STATO_R"></asp:BoundField>
            <asp:BoundField DataField="SOLE_STATO_S" HeaderText="SOLE STATO S" HeaderStyle-CssClass="text-nowrap" ReadOnly="True" SortExpression="SOLE_STATO_S"></asp:BoundField>
            <asp:BoundField DataField="SOLE_STATO_C" HeaderText="SOLE STATO C" HeaderStyle-CssClass="text-nowrap" ReadOnly="True" SortExpression="SOLE_STATO_C"></asp:BoundField>
        </Columns>
    </asp:GridView>

    <asp:ObjectDataSource ID="odsLista" runat="server" OldValuesParameterFormatString="{0}" SelectMethod="GetData" TypeName="MonitoraggioTableAdapters.ConsensiUISinotticoTableAdapter">
        <SelectParameters>
            <asp:Parameter Name="DataDal" Type="DateTime"></asp:Parameter>
            <asp:Parameter Name="DataAl" Type="DateTime"></asp:Parameter>
        </SelectParameters>
    </asp:ObjectDataSource>
</asp:Content>
