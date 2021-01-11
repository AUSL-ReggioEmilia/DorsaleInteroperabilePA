<%@ Page Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="RefertiRiassociazioneSACPazientiLista.aspx.vb"
	Inherits="DI.Sac.Admin.RefertiRiassociazioneSACPazientiLista" Title="Untitled Page" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
	<asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False"
		Visible="False"></asp:Label>
	<table id="pannelloFiltri" class="toolbar" runat="server" width="100%">
		<tr>
			<td nowrap="nowrap">
				Cognome (inizia con)
			</td>
			<td>
				<asp:TextBox ID="CognomeTextBox" runat="server" Width="180px"></asp:TextBox>
			</td>
			<td nowrap="nowrap">
				Nome (inizia con)
			</td>
			<td>
				<asp:TextBox ID="NomeTextBox" runat="server" Width="180px"></asp:TextBox>
			</td>
			<td>
				<asp:RadioButtonList ID="OccultatoRadioButtonList" runat="server" RepeatDirection="Horizontal"
					Visible="false">
					<asp:ListItem Value="true">si</asp:ListItem>
					<asp:ListItem Value="false">no</asp:ListItem>
					<asp:ListItem Value="" Selected="True">tutti</asp:ListItem>
				</asp:RadioButtonList>
			</td>
		</tr>
		<tr>
			<td nowrap="nowrap">
				Codice Fiscale
			</td>
			<td>
				<asp:TextBox ID="CodiceFiscaleTextBox" runat="server" Width="180px"></asp:TextBox>
			</td>
			<td nowrap="nowrap">
				ID Paziente SAC
			</td>
			<td>
				<asp:TextBox ID="IdSacTextBox" runat="server" Width="180px"></asp:TextBox>
			</td>
			<td>
			</td>
		</tr>
		<tr>
			<td nowrap="nowrap">
				Anno di nascita<br />
				<asp:RegularExpressionValidator ID="AnnoNascitaTextBoxRegularExpressionValidator"
					runat="server" ErrorMessage="Formato non valido" Display="Dynamic" ControlToValidate="AnnoNascitaTextBox"
					ValidationExpression="^(18|19|20)\d{2}$"></asp:RegularExpressionValidator>
			</td>
			<td>
				<asp:TextBox ID="AnnoNascitaTextBox" runat="server" Width="180px" MaxLength="4"></asp:TextBox>
			</td>
			<td>
				Provenienza
			</td>
			<td>
				<asp:TextBox ID="ProvenienzaTexttBox" runat="server" Width="180px"></asp:TextBox>
			</td>
			<td>
				<asp:Button ID="RicercaButton" runat="server" CssClass="Button" Text="Cerca" />
			</td>
		</tr>
		<tr>
			<td>
				Stato
			</td>
			<td>
				<asp:DropDownList ID="StatoDropDownList" runat="server" Width="180px">
					<asp:ListItem Value="0" Selected="True">Attivo</asp:ListItem>
					<asp:ListItem Value="1">Cancellato</asp:ListItem>
					<asp:ListItem Value="2">Fuso</asp:ListItem>
					<asp:ListItem Value="255">Tutti</asp:ListItem>
				</asp:DropDownList>
			</td>
			<td nowrap="nowrap">
				Id Provenienza
			</td>
			<td>
				<asp:TextBox ID="IdProvenienzaTextBox" runat="server" Width="180px"></asp:TextBox>
			</td>
			<td style="width: 100%;">
					<asp:Button ID="butAnnulla" runat="server" CausesValidation="False" Text="Annulla"
						class="Button" Style="padding-left: 10px;" />
			</td>
		</tr>
	</table>
	<br />
	<asp:GridView ID="PazientiGridView" runat="server" AllowPaging="True" AllowSorting="True"
		AutoGenerateColumns="False" BackColor="White" BorderColor="White" BorderStyle="Solid"
		BorderWidth="1px" CellPadding="4" DataSourceID="PazientiListaObjectDataSource"
		PagerSettings-Position="TopAndBottom" GridLines="Horizontal" PageSize="100" DataKeyNames="Id"
		Width="100%" EnableModelValidation="True">
		<RowStyle BackColor="White" ForeColor="#333333" />
		<PagerStyle CssClass="GridPager" />
		<HeaderStyle Font-Bold="True" ForeColor="Black" HorizontalAlign="Left" CssClass="GridHeader" />
		<Columns>
			<asp:TemplateField ShowHeader="False">
				<ItemTemplate>
					<asp:LinkButton ID="linkSeleziona" runat="server" CommandArgument='<%# Eval("Id")%>'
						OnClick="linkSeleziona_Click">Seleziona</asp:LinkButton>
				</ItemTemplate>
			</asp:TemplateField>
			<asp:TemplateField HeaderText="Cognome e Nome" SortExpression="Cognome,Nome">
				<ItemTemplate>
					<%# Eval("Cognome")%>
					<%# Eval("Nome")%>
				</ItemTemplate>
			</asp:TemplateField>
			<asp:BoundField DataField="DataNascita" HeaderText="Data di nascita" SortExpression="DataNascita"
				DataFormatString="{0:d}" HtmlEncode="False" />
			<asp:TemplateField HeaderText="Luogo di nascita" SortExpression="ComuneNascitaNome">
				<ItemTemplate>
					<%# Eval("ComuneNascitaNome")%>
					<%# If(Eval("ProvincianascitaNome") Is DBNull.Value, "", "(" & Eval("ProvincianascitaNome") & ")")%>
				</ItemTemplate>
			</asp:TemplateField>
			<asp:BoundField DataField="CodiceFiscale" HeaderText="Codice Fiscale" SortExpression="CodiceFiscale" />
			<asp:BoundField DataField="Provenienza" HeaderText="Provenienza" SortExpression="Provenienza" />
			<asp:BoundField DataField="IdProvenienza" HeaderText="Id Provenienza" SortExpression="IdProvenienza" />
			<asp:BoundField DataField="DisattivatoDescrizione" HeaderText="Stato" SortExpression="DisattivatoDescrizione" />
		</Columns>
	</asp:GridView>
	<asp:ObjectDataSource ID="PazientiListaObjectDataSource" runat="server" OldValuesParameterFormatString="original_{0}"
		SelectMethod="GetData" TypeName="RefertiDataSetTableAdapters.RiassociazioneSACPazienteTableAdapter"
		CacheKeyDependency="RefertiRiassociazioneSACPazientiLista" EnableCaching="True" CacheDuration="60">
		<SelectParameters>
			<asp:Parameter Name="IdPaziente" DbType="Guid"  />
			<asp:ControlParameter ControlID="IdProvenienzaTextBox" Name="IdProvenienza" PropertyName="Text"
				Type="String" />
			<asp:ControlParameter ControlID="ProvenienzaTexttBox" Name="Provenienza" PropertyName="Text"
				Type="String" />
			<asp:ControlParameter ControlID="StatoDropDownList" Name="Disattivato" PropertyName="SelectedValue"
				Type="Byte" />
			<asp:ControlParameter ControlID="CognomeTextBox" Name="Cognome" PropertyName="Text"
				Type="String" />
			<asp:ControlParameter ControlID="NomeTextBox" Name="Nome" PropertyName="Text" Type="String" />
			<asp:ControlParameter ControlID="AnnoNascitaTextBox" Name="AnnoNascita" PropertyName="Text"
				Type="Int32" />
			<asp:ControlParameter ControlID="CodiceFiscaleTextBox" Name="CodiceFiscale" PropertyName="Text"
				Type="String" />
			<asp:Parameter Name="Top" Type="Int32" DefaultValue="200" />
		</SelectParameters>
	</asp:ObjectDataSource>
</asp:Content>
