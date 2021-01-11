<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="MMGSistemiAbilitatiLista.aspx.vb" Inherits=".SistemiAbilitati" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
	<asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False" Visible="False" />
    <div style="padding: 3px">
		<asp:Button ID="NewButton" CssClass="newbutton" runat="server" Text="Nuovo" TabIndex="10" Width="80px" />
	</div>
    <fieldset runat="server" id="pannelloFiltri" class="filters">
		<legend>Ricerca</legend>
		<div>
			<span>Codice Sistema Erogante</span><br />
			<asp:TextBox ID="txtFiltriSistemaErogante" runat="server" Width="150px"></asp:TextBox>
		</div>
        <div>
			<span>Codice Specialità Erogante</span><br />
			<asp:TextBox ID="txtFiltriSpecialitaErogante" runat="server" Width="150px"></asp:TextBox>
		</div>
		<div>
			<br />
			<asp:Button CssClass="Button" ID="butFiltriRicerca" runat="server" Text="Cerca" />
		</div>
	</fieldset>

    <asp:GridView ID="gvLista" runat="server" AllowPaging="True" AllowSorting="true" AutoGenerateColumns="False"
		PageSize="100" CssClass="Grid" Width="700px" EmptyDataText="Nessun risultato!"
		PagerSettings-Position="TopAndBottom" DataKeyNames="Id" DataSourceID="odsLista">
		<Columns>
            <asp:TemplateField HeaderText="">
				<ItemStyle Width="30px" />
				<ItemTemplate>
					<a href='<%# String.Format("MMGSistemiAbilitatiDettaglio.aspx?Id={0}", Eval("Id")) %>'>
						<img src='../Images/detail.png' alt="Vai al dettaglio…" title="Vai al dettaglio…" /></a>
				</ItemTemplate>
			</asp:TemplateField>
            <%--<asp:BoundField DataField="Id" HeaderText="Id" SortExpression="Id" ReadOnly="True"></asp:BoundField>--%>
            <asp:BoundField DataField="SistemaErogante" HeaderText="SistemaErogante" SortExpression="SistemaErogante"></asp:BoundField>
            <asp:BoundField DataField="SpecialitaErogante" HeaderText="SpecialitaErogante" SortExpression="SpecialitaErogante"></asp:BoundField>
		</Columns>

		<RowStyle CssClass="GridItem" />
		<SelectedRowStyle CssClass="GridSelected" />
		<PagerSettings Position="TopAndBottom"></PagerSettings>
		<PagerStyle CssClass="GridPager" />
		<HeaderStyle CssClass="GridHeader" />
		<AlternatingRowStyle CssClass="GridAlternatingItem" />
		<FooterStyle CssClass="GridFooter" />
	</asp:GridView>

    <asp:ObjectDataSource ID="odsLista" runat="server" InsertMethod="Insert" OldValuesParameterFormatString="{0}" SelectMethod="GetData" TypeName="DI.DataWarehouse.Admin.Data.BackEndDataSetTableAdapters.MMGSistemiAbilitatiCercaTableAdapter" UpdateMethod="Update">
        <InsertParameters>
            <asp:Parameter Name="SistemaErogante" Type="String"></asp:Parameter>
            <asp:Parameter Name="SpecialitaErogante" Type="String"></asp:Parameter>
        </InsertParameters>
        <SelectParameters>
            <asp:ControlParameter ControlID="txtFiltriSistemaErogante" PropertyName="Text" Name="SistemaErogante" Type="String"></asp:ControlParameter>
            <asp:ControlParameter ControlID="txtFiltriSpecialitaErogante" PropertyName="Text" Name="SpecialitaErogante" Type="String"></asp:ControlParameter>
        </SelectParameters>
        <UpdateParameters>
            <asp:Parameter DbType="Guid" Name="Id"></asp:Parameter>
            <asp:Parameter Name="SistemaErogante" Type="String"></asp:Parameter>
            <asp:Parameter Name="SpecialitaErogante" Type="String"></asp:Parameter>
        </UpdateParameters>
    </asp:ObjectDataSource>

</asp:Content>
