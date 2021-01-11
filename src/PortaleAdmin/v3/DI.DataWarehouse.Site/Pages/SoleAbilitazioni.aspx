<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="SoleAbilitazioni.aspx.vb"
	Inherits="DI.DataWarehouse.Admin.SoleAbilitazioni" %>

<asp:Content ID="AbilitazioniContent" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
	<script src="../Scripts/sole-abilitazioni.js" type="text/javascript"></script>
	<div id="filterPanel" runat="server">
		<fieldset class="filters" style="height: 70px;">
			<legend>Ricerca</legend>
			<div>
				<span>Azienda</span><br />
				<asp:DropDownList ID="AziendaDropDownList" runat="server" DataSourceID="AziendeObjectDataSource" DataTextField="AziendaErogante"
					DataValueField="AziendaErogante" Width="150px">
				</asp:DropDownList>
			</div>
			<div>
				<span>Sistema Erogante</span><br />
				<asp:DropDownList ID="SistemaEroganteDropDownList" runat="server" DataSourceID="SistemaEroganteObjectDataSource"
					DataTextField="SistemaErogante" DataValueField="SistemaErogante" Width="150px">
				</asp:DropDownList>
			</div>
			<div style="width: 90px;">
				<br />
				<asp:Button ID="CercaButton" runat="server" CssClass="Button" Text="Cerca" />
			</div>
		</fieldset>
	</div>
	<asp:Label ID="LabelError" runat="server" Visible="False" CssClass="Error"></asp:Label>
	<asp:ValidationSummary ID="MainValidationSummary" runat="server" DisplayMode="List" CssClass="Error" />
	<br />
	<asp:ListView ID="AbilitazioniListView" runat="server" DataKeyNames="SistemaErogante,AziendaErogante" DataSourceID="AbilitazioniObjectDataSource"
		InsertItemPosition="FirstItem">
		<EditItemTemplate>
			<tr class="GridSelected">
				<td>
					<asp:ImageButton ID="UpdateButton" runat="server" CssClass="ImageButton" CommandName="Update" Text="" ImageUrl="~/Images/save.png"
						ToolTip="Salva" />
					<asp:ImageButton ID="CancelButton" runat="server" CssClass="ImageButton" CommandName="Cancel" Text="" ImageUrl="~/Images/undo.png"
						ToolTip="Annulla" />
				</td>
				<td>
					<%# Eval("AziendaErogante") %>
				</td>
				<td>
					<%# Eval("SistemaErogante") %>
				</td>
				<td>
					<asp:CheckBox ID="AbilitatoCheckBox" runat="server" Checked='<%# Bind("Abilitato") %>' />
				</td>
				<td>
					<asp:TextBox ID="DataInizioTextBox" CssClass="DateTimeInput" runat="server" Text='<%# Bind("DataInizio", "{0:d}") %>' />
					<asp:CompareValidator ID="DataInizioTextBoxCompareValidator" runat="server" ErrorMessage="La data d'inizio non può essere successiva alla data di fine"
						ControlToValidate="DataInizioTextBox" ControlToCompare="DataFineTextBox" Operator="LessThan" Type="Date" Display="None"></asp:CompareValidator>
				</td>
				<td>
					<asp:TextBox ID="DataFineTextBox" CssClass="DateTimeInput" runat="server" Text='<%# Bind("DataFine", "{0:d}") %>' />
				</td>
				<td>
					<%# Eval("DataModifica")%>
				</td>
				<td>
					<%# Eval("UtenteModifica")%>
				</td>
				<td>
					<asp:TextBox ID="LivelloMinimoConsensoTextBox" runat="server" Text='<%# Bind("LivelloMinimoConsenso") %>' />
					<asp:CustomValidator ID="LivelloMinimoConsensoTextBoxCustomValidator" runat="server" ErrorMessage="Il campo Livello Minimo Consenso deve contenere un valore numerico compreso fra 0 e 255"
						ControlToValidate="LivelloMinimoConsensoTextBox" Display="None" ValidateEmptyText="True" ClientValidationFunction="validateLivelloMinimoConsensoField"></asp:CustomValidator>
				</td>
				<td>
					<asp:CheckBox ID="BloccaInvioCheckBox" runat="server" Checked='<%# Bind("BloccaInvio") %>' />
				</td>
			</tr>
		</EditItemTemplate>
		<EmptyDataTemplate>
			Nessun risultato.
		</EmptyDataTemplate>
		<InsertItemTemplate>
			<tr id="insertRow" style="display: block; border: 1px solid black; padding: 4px;">
				<td style="width: 37px;">
					<asp:ImageButton ID="NewButton" runat="server" CssClass="ImageButton" ImageUrl="~/Images/new.gif" ToolTip="Nuovo"
						OnClientClick="$('#insertRow td').show(); $(this).hide(); $(this).next().show(); $(this).next().next().show(); return false; " />
					<asp:ImageButton ID="InsertButton" runat="server" CssClass="ImageButton" CommandName="Insert" ToolTip="Salva" ImageUrl="~/Images/save.png"
						Style="display: none;" />
					<asp:ImageButton ID="CancelButton" runat="server" CssClass="ImageButton" CommandName="Cancel" Style="display: none;"
						Text="" ImageUrl="~/Images/undo.png" ToolTip="Annulla" OnClientClick="$('#insertRow td:not(:first-child)').hide(); $(this).hide(); $(this).prev().hide(); $(this).prev().prev().show(); return false;" />
				</td>
				<td style="display: none;">
					<asp:DropDownList ID="AziendaDropDownList" runat="server" DataSourceID="AziendeObjectDataSource" Width="100" DataTextField="AziendaErogante"
						DataValueField="AziendaErogante">
					</asp:DropDownList>
				</td>
				<td style="display: none;">
					<asp:TextBox ID="SistemaEroganteTextBox" runat="server" Text='<%# Bind("SistemaErogante") %>' MaxLength="16" />
					<%--<asp:RequiredFieldValidator  ID="Validator1" runat="server" ErrorMessage="Specificare il Sistema Erogante."
						ControlToValidate="DataInizioTextBox"  Display="None"></asp:RequiredFieldValidator>--%>
				</td>
				<td style="display: none;">
					<asp:CheckBox ID="AbilitatoCheckBox" runat="server" Checked='<%# Bind("Abilitato") %>' />
				</td>
				<td style="display: none;">
					<asp:TextBox ID="DataInizioTextBox" CssClass="DateTimeInput" Width="50" runat="server" Text='<%# Bind("DataInizio", "{0:d}") %>' />
				</td>
				<td style="display: none;">
					<asp:TextBox ID="DataFineTextBox" CssClass="DateTimeInput" Width="50" runat="server" Text='<%# Bind("DataFine", "{0:d}") %>' />
					<asp:CompareValidator ID="DataInizioTextBoxCompareValidator" runat="server" ErrorMessage="La data d'inizio non può essere successiva alla data di fine"
						ControlToValidate="DataInizioTextBox" ControlToCompare="DataFineTextBox" Operator="LessThanEqual" Type="Date"
						Display="None"></asp:CompareValidator>
				</td>
				<td>
				</td>
				<td>
				</td>
				<td style="display: none;">
					<asp:TextBox ID="LivelloMinimoConsensoTextBox" runat="server" Text='<%# Bind("LivelloMinimoConsenso") %>' />
				</td>
				<td style="display: none;">
					<asp:CheckBox ID="BloccaInvioCheckBox" runat="server" Checked='<%# Bind("BloccaInvio") %>' />
				</td>
			</tr>
		</InsertItemTemplate>
		<ItemTemplate>
			<tr class="GridItem">
				<td>
					<asp:ImageButton ID="EditButton" CssClass="ImageButton" runat="server" CommandName="Edit" Text="" ImageUrl="~/Images/edititem.gif"
						ToolTip="Modifica" />
				</td>
				<td>
					<%# Eval("AziendaErogante") %>
				</td>
				<td>
					<%# Eval("SistemaErogante") %>
				</td>
				<td>
					<asp:CheckBox ID="AbilitatoCheckBox" runat="server" Checked='<%# Eval("Abilitato") %>' Enabled="false" />
				</td>
				<td>
					<%# Eval("DataInizio", "{0:d}") %>
				</td>
				<td>
					<%# Eval("DataFine", "{0:d}") %>
				</td>
				<td>
					<%# Eval("DataModifica") %>
				</td>
				<td>
					<%# Eval("UtenteModifica") %>
				</td>
				<td>
					<%# Eval("LivelloMinimoConsenso") %>
				</td>
				<td>
					<asp:CheckBox ID="BloccaInvioCheckBox" runat="server" Checked='<%# Eval("BloccaInvio") %>' Enabled="false" />
				</td>
			</tr>
		</ItemTemplate>
		<LayoutTemplate>
			<table id="itemPlaceholderContainer" runat="server" width="100%" class="Grid">
				<tr runat="server" class="GridHeader">
					<th>
					</th>
					<th>
						Azienda Erogante
					</th>
					<th>
						Sistema Erogante
					</th>
					<th>
						Abilitato
					</th>
					<th>
						Data Inizio
					</th>
					<th>
						Data Fine
					</th>
					<th>
						Data Ultima Modifica
					</th>
					<th>
						Utente Ultima Modifica
					</th>
					<th>
						Livello Minimo Consenso
					</th>
					<th>
						Blocca Invio
					</th>
				</tr>
				<tr id="itemPlaceholder" runat="server">
				</tr>
			</table>
		</LayoutTemplate>
	</asp:ListView>
	<asp:ObjectDataSource ID="AbilitazioniObjectDataSource" runat="server" SelectMethod="GetData" TypeName="DI.DataWarehouse.Admin.Data.SoleTableAdapters.AbilitazioniListaTableAdapter"
		InsertMethod="Insert" UpdateMethod="Update" OldValuesParameterFormatString="{0}">
		<InsertParameters>
			<asp:Parameter Name="SistemaErogante" Type="String" />
			<asp:Parameter Name="AziendaErogante" Type="String" />
			<asp:Parameter Name="Abilitato" Type="Boolean" />
			<asp:Parameter Name="DataInizio" Type="DateTime" />
			<asp:Parameter Name="DataFine" Type="DateTime" />
			<asp:Parameter Name="DataModifica" Type="DateTime" ConvertEmptyStringToNull="true" />
			<asp:Parameter Name="UtenteModifica" Type="String" />
			<asp:Parameter Name="LivelloMinimoConsenso" Type="Byte" />
			<asp:Parameter Name="BloccaInvio" Type="Boolean" />
		</InsertParameters>
		<SelectParameters>
			<asp:ControlParameter ControlID="SistemaEroganteDropDownList" Name="SistemaErogante" PropertyName="SelectedValue"
				Type="String" />
			<asp:ControlParameter ControlID="AziendaDropDownList" Name="AziendaErogante" PropertyName="SelectedValue" Type="String" />
		</SelectParameters>
		<UpdateParameters>
			<asp:Parameter Name="SistemaErogante" Type="String" />
			<asp:Parameter Name="AziendaErogante" Type="String" />
			<asp:Parameter Name="Abilitato" Type="Boolean" />
			<asp:Parameter Name="DataInizio" Type="DateTime" />
			<asp:Parameter Name="DataFine" Type="DateTime" />
			<asp:Parameter Name="DataModifica" Type="DateTime" />
			<asp:Parameter Name="UtenteModifica" Type="String" />
			<asp:Parameter Name="LivelloMinimoConsenso" Type="Byte" />
			<asp:Parameter Name="BloccaInvio" Type="Boolean" />
		</UpdateParameters>
	</asp:ObjectDataSource>
	<br />
	<asp:ObjectDataSource ID="AziendeObjectDataSource" runat="server" SelectMethod="GetAziendeLista" TypeName="DI.DataWarehouse.Admin.Data.DataAdapterManager"
		OldValuesParameterFormatString="{0}" EnableCaching="True" CacheDuration="60" CacheExpirationPolicy="Sliding">
		<SelectParameters>
			<asp:Parameter DefaultValue="true" Name="addEmpty" Type="Boolean" />
		</SelectParameters>
	</asp:ObjectDataSource>
	<br />
	<asp:ObjectDataSource ID="SistemaEroganteObjectDataSource" runat="server" SelectMethod="GetSistemiErogantiLista"
		TypeName="DI.DataWarehouse.Admin.Data.DataAdapterManager" OldValuesParameterFormatString="original_{0}" EnableCaching="True"
		CacheDuration="60" CacheExpirationPolicy="Sliding">
		<SelectParameters>
			<asp:Parameter DefaultValue="true" Name="addEmpty" Type="Boolean" />
		</SelectParameters>
	</asp:ObjectDataSource>
</asp:Content>
