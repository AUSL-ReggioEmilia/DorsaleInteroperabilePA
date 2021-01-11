<%@ Page Language="VB" MasterPageFile="~/Site.master" AutoEventWireup="false" CodeBehind="GdALista.aspx.vb" Inherits="DI.DataWarehouse.Admin.GdALista"
	Title="" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="Server">
	<asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False" Visible="False"></asp:Label>
	<asp:Button ID="NewButton" CssClass="newbutton" runat="server" Text="Nuovo" TabIndex="10" Width="80px" />
	<fieldset class="filters">
		<legend>Ricerca</legend>
		<div>
			<span>Azienda</span><br />
			<asp:DropDownList ID="AziendaDropDownList" runat="server" DataSourceID="AziendeObjectDataSource" DataTextField="Descrizione"
				DataValueField="Codice" Width="120px" AppendDataBoundItems="true">
				<asp:ListItem Text="Tutti" Value="" Selected="True" />
			</asp:DropDownList>
		</div>
		<div>
			<span>Descrizione</span><br />
			<asp:TextBox ID="DescrizioneTextBox" runat="server" Width="200px"></asp:TextBox>
		</div>
		<div>
			<br />
			<asp:Button CssClass="Button" ID="CercaButton" runat="server" Text="Cerca" />
		</div>
	</fieldset>
	<asp:GridView ID="GridViewMain" runat="server" DataSourceID="DataSourceMain" AutoGenerateColumns="False" PageSize="100"
		DataKeyNames="Id" CssClass="Grid" EnableModelValidation="True" AllowPaging="True" AllowSorting="True" EmptyDataText="Nessun Risultato!"
		Width="700px">
		<Columns>
			<asp:TemplateField>
			  <HeaderStyle Width="60" />				
				<ItemTemplate>
					<asp:Button ToolTip="Modifica" Width="22" CommandName="Edit" CausesValidation="false" runat="server" ID="btEdit"
						CssClass="editButton" />&nbsp;
					<asp:Button ToolTip="Elimina" Width="22" CommandName="Delete" CausesValidation="false" runat="server" ID="btDelete"
						CssClass="deleteButton" OnClientClick="return msgboxYESNO('Si conferma l\'eliminazione dell\'elemento?');" />
				</ItemTemplate>
				<EditItemTemplate>
					<asp:Button ToolTip="Salva" Width="22" CommandName="Update" CausesValidation="true" runat="server" ID="btUpdate"
						CssClass="saveButton" />&nbsp;
					<asp:Button ToolTip="Annulla" Width="22" CommandName="Cancel" CausesValidation="false" runat="server" ID="btCancel"
						CssClass="cancelButton" />
				</EditItemTemplate>
				<FooterTemplate>
					<asp:Button ToolTip="Salva" Width="22" CommandName="Insert" CausesValidation="true" runat="server" ID="btInsert"
						CssClass="saveButton" />&nbsp;
					<asp:Button ToolTip="Annulla" Width="22" CommandName="Cancel" CausesValidation="false" runat="server" ID="btCancel"
						CssClass="cancelButton" />
				</FooterTemplate>
			</asp:TemplateField>
			<asp:TemplateField HeaderText="Azienda" SortExpression="AziendaCodice">
				<HeaderStyle Width="100px" />
				<EditItemTemplate>
					<asp:DropDownList ID="AziendaDropDownList" runat="server" DataSourceID="AziendeObjectDataSource" DataTextField="Descrizione"
						DataValueField="Codice" Width="100%" SelectedValue='<%# Bind("AziendaCodice") %>'>
					</asp:DropDownList>
				</EditItemTemplate>
				<ItemTemplate>
					<%# Eval("AziendaCodice") %>
				</ItemTemplate>
				<FooterTemplate>
					<asp:DropDownList ID="AziendaDropDownList" runat="server" DataSourceID="AziendeObjectDataSource" DataTextField="Descrizione"
						DataValueField="Codice" Width="100%" SelectedValue='<%# Bind("AziendaCodice") %>'>
					</asp:DropDownList>
				</FooterTemplate>
			</asp:TemplateField>
			<asp:TemplateField HeaderText="Descrizione" SortExpression="Descrizione">
				<EditItemTemplate>
					<asp:TextBox ID="TextBoxDescrizione" runat="server" Text='<%# Bind("Descrizione") %>' Width="100%" TextMode="MultiLine"
						Rows="2"></asp:TextBox>
					<asp:RequiredFieldValidator ID="req1" runat="server" ErrorMessage="Campo obbligatorio" ControlToValidate="TextBoxDescrizione"
						CssClass="Error" Display="Dynamic" />
				</EditItemTemplate>
				<ItemTemplate>
					<%# Eval("Descrizione")%>
				</ItemTemplate>
				<FooterTemplate>
					<asp:TextBox ID="TextBoxDescrizione" runat="server" Text='<%# Bind("Descrizione") %>' Width="100%" TextMode="MultiLine"
						Rows="1"></asp:TextBox>
					<asp:RequiredFieldValidator ID="req2" runat="server" ErrorMessage="Campo obbligatorio" ControlToValidate="TextBoxDescrizione"
						CssClass="Error" Display="Dynamic" />
				</FooterTemplate>
			</asp:TemplateField>
			<asp:TemplateField>
				<HeaderStyle Width="100px" />
				<EditItemTemplate>
				</EditItemTemplate>
				<ItemTemplate>
					<asp:HyperLink ID="LinkRuoli" runat="server" NavigateUrl='<%# String.Format("GdARuoli.aspx?Id={0}",Eval("Id")) %>'
						Text="Ruoli Utente"></asp:HyperLink>
				</ItemTemplate>
			</asp:TemplateField>
			<asp:TemplateField>
				<HeaderStyle Width="150px" />
				<EditItemTemplate>
				</EditItemTemplate>
				<ItemTemplate>
					<asp:HyperLink ID="LinkGruppi" runat="server" NavigateUrl='<%# String.Format("GdAGruppiAD.aspx?Id={0}",Eval("Id")) %>'
						Text="Gruppi Amministrativi"></asp:HyperLink>
				</ItemTemplate>
			</asp:TemplateField>
		</Columns>
		<RowStyle CssClass="GridItem" />
		<EditRowStyle CssClass="GridEditRow" />
		<PagerStyle CssClass="GridPager" />
		<HeaderStyle CssClass="GridHeader" />
		<AlternatingRowStyle CssClass="GridAlternatingItem" />
		<FooterStyle CssClass="GridEditRow" />
	</asp:GridView>
	<asp:ObjectDataSource ID="DataSourceMain" runat="server" SelectMethod="GetData" TypeName="AccessiDataSetTableAdapters.GdATableAdapter"
		OldValuesParameterFormatString="{0}" DeleteMethod="Delete" InsertMethod="Insert" UpdateMethod="Update">
		<InsertParameters>
			<asp:Parameter Name="UtenteInserimento" Type="String" />
			<asp:Parameter Name="AziendaCodice" Type="String" />
			<asp:Parameter Name="Descrizione" Type="String" />
		</InsertParameters>
		<SelectParameters>
			<asp:Parameter DbType="Guid" Name="Id" />
			<asp:ControlParameter ControlID="DescrizioneTextBox" Name="Descrizione" PropertyName="Text" Type="String" />
			<asp:ControlParameter ControlID="AziendaDropDownList" Name="AziendaCodice" PropertyName="SelectedValue" Type="String" />
		</SelectParameters>
		<UpdateParameters>
			<asp:Parameter DbType="Guid" Name="Id" />
			<asp:Parameter Name="UtenteModifica" Type="String" />
			<asp:Parameter Name="AziendaCodice" Type="String" />
			<asp:Parameter Name="Descrizione" Type="String" />
		</UpdateParameters>
	</asp:ObjectDataSource>
	<asp:ObjectDataSource ID="AziendeObjectDataSource" runat="server" SelectMethod="GetData" TypeName="DI.DataWarehouse.Admin.Data.BackEndDataSetTableAdapters.AziendeErogantiListaTableAdapter"
		OldValuesParameterFormatString="original_{0}" EnableCaching="true" CacheDuration="60" CacheKeyDependency="CacheAziendeLista">
	</asp:ObjectDataSource>
</asp:Content>
