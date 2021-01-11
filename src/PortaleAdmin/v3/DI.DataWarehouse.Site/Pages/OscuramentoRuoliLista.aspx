<%@ Page Title="Sistemi" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="OscuramentoRuoliLista.aspx.vb"
	Inherits=".OscuramentoRuoliLista" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
	<style type="text/css">
		body
		{
			/*  necessario quando si usa screenMask  */
			overflow: hidden;
		}
	</style>
	<div class="screenMask">
	</div>
	<div class="pseudo-popup" style="width: 700px; height: 90%;">
		<asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False" Visible="False"></asp:Label>
		<asp:Label ID="lblTitolo" runat="server" CssClass="Title" Text=""></asp:Label>
		<asp:Label ID="lblSottoTitolo" runat="server" CssClass="SubTitle" Text=""></asp:Label>
		<table id="pannelloFiltri" runat="server" class="toolbar" width="100%">
			<tr>
				<td colspan="7">
					<br />
				</td>
			</tr>
			<tr>
				<td>
					Codice
				</td>
				<td>
					<asp:TextBox ID="txtFiltriCodice" runat="server" Width="120px" MaxLength="16"></asp:TextBox>
				</td>
				<td>
					Descrizione
				</td>
				<td>
					<asp:TextBox ID="txtFiltriDescrizione" runat="server" Width="120px" MaxLength="128"></asp:TextBox>
				</td>
				<td width="100%">
					<asp:Button ID="butFiltriRicerca" runat="server" CssClass="Button" Text="Cerca" />
				</td>
			</tr>
			<tr>
				<td colspan="7">
					<br />
				</td>
			</tr>
		</table>
		<table class="table_pulsanti" width="100%">
			<tr>
				<td class="Left">
					<asp:Button ID="butEliminaTop" runat="server" Text="Elimina Selezionati" CssClass="Button" CommandName="Delete"
						OnClientClick="return msgboxYESNO('Si conferma l\'eliminazione degli elementi selezionati?');" ValidationGroup="none"
						Width="10em" />
					<asp:Button ID="butAggiungiTop" runat="server" Text="Aggiungi..." CssClass="Button" CommandName="Insert" />
					<asp:Button ID="butConfermaTop" runat="server" Text="Aggiungi Selezionati" CssClass="Button" Style="width: 140px;"
						CommandName="Insert" />
				</td>
				<td class="Right">
					<asp:Button ID="butAnnullaTop" runat="server" CommandName="Cancel" Text="Chiudi" CssClass="Button" ValidationGroup="none" />
				</td>
			</tr>
		</table>
		<asp:GridView ID="gvLista" runat="server" AllowPaging="True" AllowSorting="True" CssClass="Grid" AutoGenerateColumns="False"
			DataSourceID="odsLista" EnableModelValidation="True" PageSize="100" EmptyDataText="Nessun risultato!" DataKeyNames="IdRuolo"
			Width="100%">
			<HeaderStyle CssClass="GridHeader" />
			<PagerStyle CssClass="GridPager" />
			<PagerSettings Position="TopAndBottom"></PagerSettings>
			<SelectedRowStyle CssClass="GridSelected" />
			<RowStyle CssClass="GridItem" Wrap="true" />
			<AlternatingRowStyle CssClass="GridAlternatingItem" Wrap="true" />
			<Columns>
				<asp:TemplateField>
					<HeaderTemplate>
						<asp:CheckBox ID="chkboxSelectAll" runat="server" AutoPostBack="true" OnCheckedChanged="chkboxSelectAll_CheckedChanged" />
					</HeaderTemplate>
					<ItemStyle HorizontalAlign="Left" VerticalAlign="Middle" Width="20px" />
					<ItemTemplate>
						<asp:CheckBox ID="CheckBox" runat="server"></asp:CheckBox>
					</ItemTemplate>
				</asp:TemplateField>
				<asp:BoundField DataField="Codice" HeaderText="Codice" SortExpression="Codice" ItemStyle-Width="150px" />
				<asp:BoundField DataField="Descrizione" HeaderText="Descrizione" SortExpression="Descrizione" />
				<asp:CheckBoxField DataField="Attivo" HeaderText="Attivo" SortExpression="Attivo" ItemStyle-Width="50px" />
			</Columns>
		</asp:GridView>
		<table class="table_pulsanti" width="100%">
			<tr>
				<td class="Left">
					<asp:Button ID="butElimina" runat="server" Text="Elimina Selezionati" CssClass="Button" CommandName="Delete" OnClientClick="return msgboxYESNO('Si conferma l\'eliminazione degli elementi selezionati?');"
						ValidationGroup="none" Width="10em" />
					<asp:Button ID="butAggiungi" runat="server" Text="Aggiungi..." CssClass="Button" CommandName="Insert" />
					<asp:Button ID="butConferma" runat="server" Text="Aggiungi Selezionati" CssClass="Button" Style="width: 140px;"
						CommandName="Insert" />
				</td>
				<td class="Right">
					<asp:Button ID="butAnnulla" runat="server" CommandName="Cancel" Text="Chiudi" CssClass="Button" ValidationGroup="none" />
				</td>
			</tr>
		</table>
	</div>
	<asp:ObjectDataSource ID="odsLista" runat="server" SelectMethod="GetData" TypeName="RefertiDataSetTableAdapters.OscuramentoRuoliTableAdapter"
		CacheDuration="120" CacheKeyDependency="CacheOscuramentoRuoli" EnableCaching="True" OldValuesParameterFormatString="{0}"
		DeleteMethod="Delete" InsertMethod="Insert">
		<DeleteParameters>
			<asp:Parameter DbType="Guid" Name="IdOscuramento" />
			<asp:Parameter DbType="Guid" Name="IdRuolo" />
		</DeleteParameters>
		<InsertParameters>
			<asp:Parameter DbType="Guid" Name="IdOscuramento" />
			<asp:Parameter DbType="Guid" Name="IdRuolo" />
			<asp:Parameter Name="UtenteInserimento" Type="String" />
		</InsertParameters>
		<SelectParameters>
			<asp:QueryStringParameter DbType="Guid" Name="IdOscuramento" QueryStringField="Id" />
			<asp:ControlParameter ControlID="txtFiltriCodice" Name="Codice" PropertyName="Text" Type="String" />
			<asp:ControlParameter ControlID="txtFiltriDescrizione" Name="Descrizione" PropertyName="Text" Type="String" />
			<asp:Parameter Name="Top" Type="Int32" DefaultValue="500" />
		</SelectParameters>
	</asp:ObjectDataSource>
</asp:Content>
