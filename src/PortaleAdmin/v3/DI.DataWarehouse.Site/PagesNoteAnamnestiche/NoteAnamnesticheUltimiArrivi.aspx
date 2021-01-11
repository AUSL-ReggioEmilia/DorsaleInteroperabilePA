<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="NoteAnamnesticheUltimiArrivi.aspx.vb" Inherits=".NoteAnamnesticheUltimiArrivi" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
    <asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False"
        Visible="False" />

    <div class="Title" style="width: 600px;">
        In questo quadro riassuntivo vengono mostrati per ciascuna accoppiata Azienda +
		Sistema erogante la data di modifica dell'ultima nota anamnestica e il numero di note anamnestiche
		ricevute nell'ultima ora.
    </div>

    <asp:GridView runat="server" DataSourceID="odsListaNoteAnamnestiche" AutoGenerateColumns="False" EmptyDataText="Nessun risultato!"
        CssClass="Grid" Width="600px" EnableModelValidation="True" AllowSorting="True">
        <Columns>
            <asp:BoundField DataField="AziendaErogante" HeaderText="AziendaErogante" SortExpression="AziendaErogante"></asp:BoundField>
            <asp:BoundField DataField="SistemaErogante" HeaderText="SistemaErogante" SortExpression="SistemaErogante"></asp:BoundField>
            <asp:BoundField DataField="DataModifica" HeaderText="DataModifica" ReadOnly="True" SortExpression="DataModifica"></asp:BoundField>
            <asp:BoundField DataField="Count" HeaderText="Count" ReadOnly="True" SortExpression="Count"></asp:BoundField>
        </Columns>
        <RowStyle CssClass="GridItem" />
		<SelectedRowStyle CssClass="GridSelected" />
		<PagerStyle CssClass="GridPager" />
		<HeaderStyle CssClass="GridHeader" />
		<AlternatingRowStyle CssClass="GridAlternatingItem" />
		<FooterStyle CssClass="GridFooter" />
    </asp:GridView>

    <asp:ObjectDataSource ID="odsListaNoteAnamnestiche" runat="server" OldValuesParameterFormatString="{0}" SelectMethod="GetData"
        TypeName="NoteAnamnesticheDataSetTableAdapters.NoteAnamnesticheUltimiArriviTableAdapter">
        <SelectParameters>
            <asp:Parameter Name="NumeroOre" Type="Int32" DefaultValue="1"></asp:Parameter>
        </SelectParameters>
    </asp:ObjectDataSource>
</asp:Content>
