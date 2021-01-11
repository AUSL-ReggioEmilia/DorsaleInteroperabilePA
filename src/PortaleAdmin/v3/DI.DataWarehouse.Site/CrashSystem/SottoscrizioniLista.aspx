<%@ Page Language="VB" MasterPageFile="~/Site.master" AutoEventWireup="false" CodeBehind="SottoscrizioniLista.aspx.vb"
	Inherits="DI.DataWarehouse.Admin.SottoscrizioniLista" Title="Lista Sottoscrizioni" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="Server">
	<asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False"
		Visible="False"></asp:Label>
	<div>
		<div style="padding: 3px">
			<input type="button" id="NuovoButton" class="newButton" value="Nuovo" style="width: 80px"
				onclick="location.href = 'SottoscrizioniDettaglio.aspx'; return false;" />
		</div>

		<fieldset class="filters">
			<legend>Ricerca</legend>
			<div>
				<span>Nome</span><br />
				<asp:TextBox ID="NomeTextBox" runat="server" Width="200px"></asp:TextBox>
			</div>
			<div>
				<span>Descrizione</span><br />
				<asp:TextBox ID="DescrizioneTextBox" runat="server" Width="200px"></asp:TextBox>
			</div>
			<div>
				<span>Attivo</span><br />
				<asp:DropDownList ID="ddlFiltriStatoAttivo" runat="server" Width="110">
					<asp:ListItem Text="Tutti" Value="" Selected="True" />
					<asp:ListItem Text="Sì" Value="True" />
					<asp:ListItem Text="No" Value="False" />
				</asp:DropDownList>
			</div>

			<div>
				<br />
				<asp:Button CssClass="Button" ID="CercaButton" runat="server" Text="Cerca" />
			</div>
		</fieldset>
	</div>

	<asp:GridView ID="GridViewMain" runat="server" AllowPaging="false" AllowSorting="True"
		DataSourceID="DataSourceMain" AutoGenerateColumns="False" EnableViewState="false" DataKeyNames="Id"
		CssClass="Grid" Width="100%" EmptyDataText="Nessun risultato!">
		<Columns>
			<asp:TemplateField HeaderText="">
				<ItemStyle Width="30px" />
				<ItemTemplate>
					<a href='<%# String.Format("SottoscrizioniDettaglio.aspx?Id={0}", Eval("Id")) %>'>
						<img src='../Images/detail.png' alt="Vai al dettaglio…" title="Vai al dettaglio…" /></a>
				</ItemTemplate>
			</asp:TemplateField>
			<asp:BoundField DataField="Nome" HeaderText="Nome" SortExpression="Nome" />
			<asp:BoundField DataField="Descrizione" HeaderText="Descrizione" SortExpression="Descrizione" />
			<asp:CheckBoxField DataField="Attivo" HeaderText="Attivo" SortExpression="Attivo" />
			<asp:BoundField DataField="UltimoSuccesso" HeaderText="Ultimo Successo" SortExpression="UltimoSuccesso" />
			<asp:BoundField DataField="UltimoFallimento" HeaderText="Ultimo Fallimento" SortExpression="UltimoFallimento" />
		</Columns>
		<RowStyle CssClass="GridItem" />
		<SelectedRowStyle CssClass="GridSelected" />
		<PagerStyle CssClass="GridPager" />
		<HeaderStyle CssClass="GridHeader" />
		<AlternatingRowStyle CssClass="GridAlternatingItem" />
		<FooterStyle CssClass="GridFooter" />
	</asp:GridView>

	<asp:ObjectDataSource ID="DataSourceMain" runat="server" SelectMethod="GetData" EnableCaching="false"
		TypeName="CrashSystemTableAdapters.SottoscrizioniCercaTableAdapter" OldValuesParameterFormatString="original_{0}">
		<SelectParameters>
			<asp:Parameter DefaultValue="1000" Name="Top" Type="Int32"></asp:Parameter>
			<asp:ControlParameter ControlID="NomeTextBox" PropertyName="Text" Name="Nome" Type="String"></asp:ControlParameter>
			<asp:ControlParameter ControlID="ddlFiltriStatoAttivo" Name="Attivo" PropertyName="SelectedValue" Type="Boolean" DefaultValue="" />
			<asp:ControlParameter ControlID="DescrizioneTextBox" PropertyName="Text" Name="Descrizione" Type="String"></asp:ControlParameter>
		</SelectParameters>
	</asp:ObjectDataSource>
</asp:Content>
