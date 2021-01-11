<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="PazientiSinottico.aspx.vb" Inherits=".PazientiSinottico" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
    <asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False"
        Visible="False"></asp:Label>
    <div class="toolbar">
        <table id="pannelloFiltri" runat="server" style="padding: 13px; margin-top: 5px; margin-bottom: 5px;">
            <tr>
                <td>
                    Periodo
                </td>
                <td>
                    <asp:DropDownList ID="ddlFiltriPeriodo" runat="server" Width="120px" AutoPostBack="True">
                        <asp:ListItem Text="Ultima ora" Value="1" Selected="True" />
                        <asp:ListItem Text="Oggi" Value="2" />
                        <asp:ListItem Text="Ultimi 7 Giorni" Value="3" />
                        <asp:ListItem Text="Ultimi 30 Giorni" Value="4" />
                    </asp:DropDownList>
                </td>
            </tr>
        </table>
    </div>

    <asp:GridView runat="server" ID="gvLista" AllowPaging="true" AllowSorting="false" GridLines="Horizontal" PageSize="20" Width="600px" PagerSettings-Position="TopAndBottom" EmptyDataText="Nessun Risultato!"
        CssClass="GridYellow" HeaderStyle-CssClass="Header" AlternatingRowStyle-CssClass="AlternatingRow"
        PagerStyle-CssClass="Pager" DataSourceID="odsLista" AutoGenerateColumns="False" style="margin-top:10px;">
        <Columns>
            <asp:BoundField DataField="Provenienza" HeaderText="Provenienza" SortExpression="Provenienza"></asp:BoundField>
            <asp:BoundField DataField="Attivi" HeaderText="Attivi" ReadOnly="True" SortExpression="Attivi"></asp:BoundField>
            <asp:BoundField DataField="Cancellati" HeaderText="Cancellati" ReadOnly="True" SortExpression="Cancellati"></asp:BoundField>
            <asp:BoundField DataField="Fusi" HeaderText="Fusi" ReadOnly="True" SortExpression="Fusi"></asp:BoundField>
        </Columns>
    </asp:GridView>

    <asp:ObjectDataSource ID="odsLista" runat="server" OldValuesParameterFormatString="{0}" SelectMethod="GetData" TypeName="MonitoraggioTableAdapters.PazientiUISinotticoTableAdapter">
        <SelectParameters>
            <asp:Parameter Name="DataDal" Type="DateTime"></asp:Parameter>
            <asp:Parameter Name="DataAl" Type="DateTime"></asp:Parameter>
        </SelectParameters>
    </asp:ObjectDataSource>
</asp:Content>
