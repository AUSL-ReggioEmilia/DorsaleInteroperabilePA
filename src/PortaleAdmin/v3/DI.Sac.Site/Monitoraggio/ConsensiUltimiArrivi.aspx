<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="ConsensiUltimiArrivi.aspx.vb" Inherits=".ConsensiUltimiArrivi" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">

    <asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False" Visible="False" />

    <div class="Title" style="width: 600px;">
        In questo quadro riassuntivo vengono mostrati per ciascuna Provenienza la data di inserimento dell'ultimo consenso e il numero di consensi inseriti nell'ultima ora.
    </div>

    <asp:GridView runat="server" ID="gvLista" AllowPaging="true" AllowSorting="false" GridLines="Horizontal" PageSize="20" Width="600px" PagerSettings-Position="TopAndBottom"
        CssClass="GridYellow" HeaderStyle-CssClass="Header" AlternatingRowStyle-CssClass="AlternatingRow"
        PagerStyle-CssClass="Pager" DataSourceID="odsLista" AutoGenerateColumns="False" EmptyDataText="Nessun Risultato!">
        <Columns>
            <asp:BoundField DataField="Provenienza" HeaderText="Provenienza" SortExpression="Provenienza"></asp:BoundField>
            <asp:BoundField DataField="DataModifica" HeaderText="Data Modifica" ReadOnly="True" SortExpression="DataModifica"></asp:BoundField>
            <asp:BoundField DataField="Count" HeaderText="Totale" ReadOnly="True" SortExpression="Count"></asp:BoundField>
        </Columns>
    </asp:GridView>

    <asp:ObjectDataSource ID="odsLista" runat="server" OldValuesParameterFormatString="{0}" SelectMethod="GetData" TypeName="MonitoraggioTableAdapters.ConsensiUltimiArriviTableAdapter">
        <SelectParameters>
            <asp:Parameter Name="NumeroOre" Type="Int32" DefaultValue="1"></asp:Parameter>
        </SelectParameters>
    </asp:ObjectDataSource>
</asp:Content>
