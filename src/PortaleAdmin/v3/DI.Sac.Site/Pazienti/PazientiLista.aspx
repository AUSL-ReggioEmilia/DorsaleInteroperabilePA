<%@ Page Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="PazientiLista.aspx.vb"
	Inherits="DI.Sac.Admin.PazientiLista" Title="Untitled Page" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
	<asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False"
		Visible="False"></asp:Label>
	<table id="MainTable" runat="server" cellpadding="1" cellspacing="0" border="0" style="width: 100%;">
		<tr>
			<td class="toolbar">
				<table id="pannelloFiltri" runat="server" style="padding: 13px;">
					<tr>
						<td colspan="9">
							<asp:HyperLink ID="NuovoPazienteLink" runat="server" NavigateUrl="PazienteDettaglio.aspx?mode=insert"
								Enabled="true"><img src="../Images/newitem.gif" alt="Nuovo paziente" class="toolbar-img"/>Nuovo paziente</asp:HyperLink>
						</td>
					</tr>
					<tr>
						<td>
							<asp:Label ID="CognomeLabel" runat="server" Text="Cognome (inizia con)"></asp:Label>
						</td>
						<td>
							<asp:TextBox ID="CognomeTextBox" runat="server" Width="120px"></asp:TextBox>
						</td>
						<td>
							<asp:Label ID="NomeLabel" runat="server" Text="Nome (inizia con)"></asp:Label>
						</td>
						<td>
							<asp:TextBox ID="NomeTextBox" runat="server" Width="120px"></asp:TextBox>
						</td>
						<td>
							Occultato
						</td>
						<td>
							<asp:RadioButtonList ID="OccultatoRadioButtonList" runat="server" RepeatDirection="Horizontal">
								<asp:ListItem Value="1">si</asp:ListItem>
								<asp:ListItem Value="0">no</asp:ListItem>
								<asp:ListItem Value="" Selected="True">tutti</asp:ListItem>
							</asp:RadioButtonList>
						</td>
					</tr>
					<tr>
						<td>
							<asp:Label ID="CodiceFiscaleLabel" runat="server" Text="Codice Fiscale"></asp:Label>
						</td>
						<td>
							<asp:TextBox ID="CodiceFiscaleTextBox" runat="server" Width="120px"></asp:TextBox>
						</td>
						<td>
							<asp:Label ID="IdSacLabel" runat="server" Text="ID SAC"></asp:Label>
						</td>
						<td>
							<asp:TextBox ID="IdSacTextBox" runat="server" Width="120px"></asp:TextBox>
						</td>
						<td>
						</td>
						<td>
						</td>
					</tr>
					<tr>
						<td>
							<asp:Label ID="AnnoNascitaLabel" runat="server" Text="Anno di nascita"></asp:Label><br />
							<asp:RegularExpressionValidator ID="AnnoNascitaTextBoxRegularExpressionValidator"
								runat="server" ErrorMessage="Formato non valido" Display="Dynamic" ControlToValidate="AnnoNascitaTextBox"
								ValidationExpression="^(18|19|20)\d{2}$"></asp:RegularExpressionValidator>
						</td>
						<td>
							<asp:TextBox ID="AnnoNascitaTextBox" runat="server" Width="120px" MaxLength="4"></asp:TextBox>
						</td>
						<td>
							Provenienza
						</td>
						<td>
							<asp:DropDownList ID="ProvenienzaDropDownList" runat="server" Width="120px" DataSourceID="ProvenienzaObjectDataSource"
								DataTextField="Provenienza" DataValueField="Provenienza" AppendDataBoundItems="True">
								<asp:ListItem Value=""></asp:ListItem>
							</asp:DropDownList>
							<asp:ObjectDataSource ID="ProvenienzaObjectDataSource" runat="server" OldValuesParameterFormatString="original_{0}"
								SelectMethod="GetData" TypeName="DI.Sac.Admin.Data.ProvenienzeDataSetTableAdapters.ProvenienzeListaTableAdapter">
							</asp:ObjectDataSource>
						</td>
					</tr>
					<tr>
						<td>
							Stato
						</td>
						<td>
							<asp:DropDownList ID="StatoDropDownList" runat="server" Width="120px">
								<asp:ListItem Value="0" Selected="True">Attivo</asp:ListItem>
								<asp:ListItem Value="1">Cancellato</asp:ListItem>
								<asp:ListItem Value="2">Fuso</asp:ListItem>
								<asp:ListItem Value="255">Tutti</asp:ListItem>
							</asp:DropDownList>
						</td>
						<td>
							Id Provenienza
						</td>
						<td>
							<asp:TextBox ID="IdEsternoTextBox" runat="server" Width="120px"></asp:TextBox>
						</td>
						<td>
						</td>
						<td>
							<asp:Button ID="RicercaButton" runat="server" CssClass="TabButton" Text="Cerca" />
						</td>
					</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td>
				<br />
				Risultato della ricerca:<br />
				<asp:GridView ID="PazientiGridView" runat="server" AllowPaging="True" AllowSorting="True"
					AutoGenerateColumns="False" BackColor="White" BorderColor="White" BorderStyle="Solid"
					BorderWidth="1px" CellPadding="4" DataSourceID="PazientiListaObjectDataSource"
					PagerSettings-Position="TopAndBottom" GridLines="Horizontal" PageSize="100" DataKeyNames="Id"
					Width="100%" EnableModelValidation="True">
					<Columns>
						<asp:TemplateField HeaderText="" ItemStyle-Width="20px">
							<ItemTemplate>
								<asp:HyperLink Visible='<%# Eval("NumeroFuse") <> 0 %>' ID="CaricaFuseLink" runat="server"
									NavigateUrl="#" onclick='<%# GetCaricaFuseFunction(Eval("Id")) %>'>
                                    <img src='../Images/plus_icon.gif' alt="visualizza <%# Eval("NumeroFuse") %> posizione/i fusa/e"
                                        title="visualizza <%# Eval("NumeroFuse") %> posizione/i fusa/e" /></asp:HyperLink>
								<asp:HyperLink Visible='<%# Eval("NumeroFuse") <> 0 %>' ID="ChiudiFuseHyperLink"
									runat="server" NavigateUrl="#" onclick='<%# GetChiudiFuseFunction(Eval("Id")) %>'
									Style="display: none;">
                                    <img src='../Images/minus_icon.gif' alt="nascondi fuse"
                                        title="nascondi fuse" /></asp:HyperLink>
							</ItemTemplate>
						</asp:TemplateField>
						<asp:TemplateField HeaderText="">
							<ItemTemplate>
								<a href='<%# String.Format("PazienteDettaglio.aspx?id={0}", Eval("Id")) %>'>
									<img src='../Images/view.png' alt="vai al dettaglio" title="vai al dettaglio" /></a>
							</ItemTemplate>
						</asp:TemplateField>
						<asp:TemplateField HeaderText="Nome" SortExpression="Cognome">
							<ItemTemplate>
								<%# String.Format("{0} {1}", Eval("Cognome"), Eval("Nome")) %>
							</ItemTemplate>
						</asp:TemplateField>
						<asp:BoundField DataField="DataNascita" HeaderText="Data di nascita" SortExpression="DataNascita"
							DataFormatString="{0:d}" HtmlEncode="False" />
						<asp:BoundField DataField="ComuneNascita" HeaderText="Comune di nascita" SortExpression="ComuneNascita" />
						<asp:BoundField DataField="CodiceFiscale" HeaderText="Codice Fiscale" SortExpression="CodiceFiscale" />
						<asp:BoundField DataField="DataDecesso" HeaderText="Data di decesso" SortExpression="DataDecesso"
							DataFormatString="{0:d}" HtmlEncode="False" />
						<asp:BoundField DataField="Provenienza" HeaderText="Provenienza" SortExpression="Provenienza" />
						<asp:BoundField DataField="DisattivatoDescrizione" HeaderText="Stato" SortExpression="DisattivatoDescrizione" />
						<asp:CheckBoxField DataField="Occultato" HeaderText="Occultato" SortExpression="Occultato"
							ControlStyle-BorderStyle="None" ItemStyle-HorizontalAlign="Center" />
					</Columns>
					<EmptyDataTemplate>
						<b>Nessun risultato!</b>
					</EmptyDataTemplate>
					<RowStyle BackColor="White" ForeColor="#333333" />
					<PagerStyle CssClass="GridPager" />
					<HeaderStyle Font-Bold="True" ForeColor="Black" HorizontalAlign="Left" CssClass="GridHeader" />
				</asp:GridView>
				<asp:ObjectDataSource ID="PazientiListaObjectDataSource" runat="server" OldValuesParameterFormatString="original_{0}"
					SelectMethod="GetData" TypeName="DI.Sac.Admin.Data.PazientiDataSetTableAdapters.PazientiGestioneListaTableAdapter"
					CacheKeyDependency="PazientiGestioneLista" EnableCaching="True" CacheDuration="60">
					<SelectParameters>
						<asp:ControlParameter ControlID="CognomeTextBox" Name="Cognome" PropertyName="Text"
							Type="String" />
						<asp:ControlParameter ControlID="NomeTextBox" Name="Nome" PropertyName="Text" Type="String" />
						<asp:ControlParameter ControlID="AnnoNascitaTextBox" Name="AnnoNascita" PropertyName="Text"
							Type="Int32" />
						<asp:ControlParameter ControlID="CodiceFiscaleTextBox" Name="CodiceFiscale" PropertyName="Text"
							Type="String" />
						<asp:ControlParameter ControlID="IdSacTextBox" DbType="Guid" Name="IdSac" PropertyName="Text" />
						<asp:ControlParameter ControlID="StatoDropDownList" Name="Disattivato" PropertyName="SelectedValue"
							Type="Byte" />
						<asp:Parameter Name="Occultato" Type="Boolean" />
						<asp:ControlParameter ControlID="ProvenienzaDropDownList" Name="Provenienza" PropertyName="SelectedValue"
							Type="String" />
						<asp:ControlParameter ControlID="IdEsternoTextBox" Name="IdEsterno" PropertyName="Text"
							Type="String" />
					</SelectParameters>
				</asp:ObjectDataSource>
				<asp:Label ID="UltimiPazientiVisitatiLabel" runat="server" Text="Ultimi pazienti visitati:"
					Visible="false" Style="margin-top: 30px; margin-bottom: 8px; display: block;" />
				<asp:GridView ID="UltimiPazientiVisitatiGridView" runat="server" AllowPaging="True"
					AllowSorting="True" AutoGenerateColumns="False" GridLines="Horizontal" PageSize="100"
					DataKeyNames="Id" Width="100%" EnableModelValidation="True" PagerSettings-Position="TopAndBottom"
					CssClass="GridYellow" HeaderStyle-CssClass="Header" PagerStyle-CssClass="Pager">
					<Columns>
						<asp:TemplateField HeaderText="">
							<ItemTemplate>
								<a href='<%# String.Format("PazienteDettaglio.aspx?id={0}", Eval("Id")) %>'>
									<img src='../Images/view.png' alt="vai al dettaglio" title="vai al dettaglio" /></a>
							</ItemTemplate>
						</asp:TemplateField>
						<asp:TemplateField HeaderText="Nome" SortExpression="Cognome">
							<ItemTemplate>
								<%# String.Format("{0} {1}", Eval("Cognome"), Eval("Nome")) %>
							</ItemTemplate>
						</asp:TemplateField>
						<asp:BoundField DataField="DataNascita" HeaderText="Data di nascita" SortExpression="DataNascita"
							DataFormatString="{0:d}" HtmlEncode="False" />
						<asp:BoundField DataField="ComuneNascita" HeaderText="Comune di nascita" SortExpression="ComuneNascita" />
						<asp:BoundField DataField="CodiceFiscale" HeaderText="Codice Fiscale" SortExpression="CodiceFiscale" />
						<asp:BoundField DataField="Provenienza" HeaderText="Provenienza" SortExpression="Provenienza" />
						<asp:BoundField DataField="DisattivatoDescrizione" HeaderText="Stato" SortExpression="DisattivatoDescrizione" />
						<asp:CheckBoxField DataField="Occultato" HeaderText="Occultato" SortExpression="Occultato"
							ControlStyle-BorderStyle="None" ItemStyle-HorizontalAlign="Center" />
					</Columns>
				</asp:GridView>
			</td>
		</tr>
	</table>
	<script src="../Scripts/pazienti-lista.js" type="text/javascript"></script>
</asp:Content>
