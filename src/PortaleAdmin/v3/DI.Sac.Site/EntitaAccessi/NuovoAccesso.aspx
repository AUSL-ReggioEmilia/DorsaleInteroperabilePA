<%@ Page Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="NuovoAccesso.aspx.vb"
	Inherits="DI.Sac.Admin.NuovoAccesso" Title="Untitled Page" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
	<asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False"
		Visible="False"></asp:Label>
	<table cellpadding="1" cellspacing="0" border="0" style="width: 100%;">
		<tr>
			<td class="toolbar">
				<table>
					<tr>
						<td colspan="3">
							<asp:CheckBoxList ID="chkUserGroup" runat="server" RepeatDirection="Horizontal">
								<asp:ListItem Value="Utenti" Selected="True">Utenti</asp:ListItem>
								<asp:ListItem Value="Gruppi" Selected="True">Gruppi</asp:ListItem>
							</asp:CheckBoxList>
						</td>
					</tr>
					<tr>
						<td>
							<asp:Label ID="lblNome" runat="server" Text="Nome"></asp:Label>
						</td>
						<td colspan="2">
							<asp:TextBox ID="txtNome" runat="server" Width="250px"></asp:TextBox>
							<asp:RequiredFieldValidator ID="RequiredNome" runat="server" ControlToValidate="txtNome"
								ErrorMessage='<img src="../Images/icon_small_caution.gif" alt="Valore richiesto!" />'>
							</asp:RequiredFieldValidator>
						</td>
					</tr>
					<tr>
						<td>
							<asp:Label ID="lblDescrizione" runat="server" Text="Descrizione"></asp:Label>
						</td>
						<td>
							<asp:TextBox ID="txtDescrizione" runat="server" Width="250px"></asp:TextBox>
						</td>
						<td>
							<asp:Button ID="btnRicerca" runat="server" CssClass="TabButton" Text="Cerca" />
						</td>
					</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td>
				<br />
				<asp:GridView ID="gvActiveDirectory" runat="server" EmptyDataText="Nessun risultato!"
					AutoGenerateColumns="False" BackColor="White" GridLines="Horizontal" PageSize="20"
					DataKeyNames="objectGUID" Width="100%" PagerSettings-Position="TopAndBottom" CssClass="GridYellow"
					HeaderStyle-CssClass="Header" AlternatingRowStyle-CssClass="AlternatingRow" PagerStyle-CssClass="Pager">
					<Columns>
						<asp:TemplateField Visible="false">
							<ItemTemplate>
								<asp:Label ID="lblObjectGUID" runat="server" Text='<%# Eval("objectGUID") %>'></asp:Label>
								<asp:Label ID="lblObjectCategory" runat="server" Text='<%# Eval("objectCategory") %>'></asp:Label>
								<asp:Label ID="lblObjectClass" runat="server" Text='<%# Eval("objectClass") %>'></asp:Label>
							</ItemTemplate>
						</asp:TemplateField>
						<asp:CommandField ButtonType="Link" ShowSelectButton="True" SelectImageUrl="~/Images/sel.gif"
							SelectText="Seleziona">
							<ItemStyle ForeColor="#4682B4" />
						</asp:CommandField>
						<asp:BoundField DataField="sAMAccountName" HeaderText="Nome" />
						<asp:BoundField DataField="displayName" HeaderText="Descrizione 1" />
						<asp:BoundField DataField="name" HeaderText="Descrizione 2" />
						<asp:BoundField DataField="description" HeaderText="Descrizione 3" />
						<asp:TemplateField>
							<ItemTemplate>
								<asp:CheckBox ID="chkSelect" runat="server"></asp:CheckBox>
							</ItemTemplate>
						</asp:TemplateField>
					</Columns>
				</asp:GridView>
			</td>
		</tr>
		<tr>
			<td style="text-align: right;">
				<br />
				<asp:Button ID="btnConferma" runat="server" CssClass="TabButton" Text="Conferma"
					Visible="False" />
				&nbsp;<asp:Button ID="btnAnnulla" runat="server" CssClass="TabButton" Text="Annulla"
					CausesValidation="False" Visible="False" />
			</td>
		</tr>
	</table>
</asp:Content>
