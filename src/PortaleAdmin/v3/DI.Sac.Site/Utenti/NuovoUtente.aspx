<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master"
	CodeBehind="NuovoUtente.aspx.vb" Inherits="DI.Sac.Admin.NuovoUtente" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
	<asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False"
		Visible="False"></asp:Label>
	<table cellpadding="1" cellspacing="0" border="0" style="width: 100%;">
		<tr id="trToolbar" runat="server">
			<td class="toolbar">
				<table>
					<tr>
						<td colspan="7">
							<br />
						</td>
					</tr>
					<tr>
						<td>
							Nome
						</td>
						<td>
							<asp:TextBox ID="txtNomeCerca" runat="server" Width="120px" />
							<asp:RequiredFieldValidator ID="RequiredNome" runat="server" ControlToValidate="txtNomeCerca"
								ErrorMessage='<img src="../Images/icon_small_caution.gif" alt="Valore richiesto!" />'>
							</asp:RequiredFieldValidator>
						</td>
						<td>
							Descrizione
						</td>
						<td>
							<asp:TextBox ID="txtDescrizioneCerca" runat="server" Width="120px" />
						</td>
						<td>
							<asp:Button ID="btnRicerca" runat="server" CssClass="TabButton" Text="Cerca" />
						</td>
						<td>
							<asp:Button ID="btnNuovo" runat="server" CssClass="TabButton" Text="Nuovo" CausesValidation="false"
								Visible="false" />
						</td>
					</tr>
					<tr>
						<td>
						</td>
						<td colspan="4">
							<asp:CheckBoxList ID="chkUserGroup" runat="server" RepeatDirection="Horizontal">
								<asp:ListItem Value="Utenti" Selected="True">Utenti</asp:ListItem>
								<asp:ListItem Value="Gruppi" Selected="True">Gruppi</asp:ListItem>
							</asp:CheckBoxList>
						</td>
					</tr>
				</table>
			</td>
		</tr>
		<tr id="trNuovoUtente" runat="server" visible="false">
			<td>
				<table cellpadding="3" cellspacing="0" border="0">
					<tr>
						<td style="width: 200px;">
						</td>
						<td style="width: 300px;">
						</td>
					</tr>
					<tr>
						<td class="toolbar" colspan="2">
							<p>
								Nuovo Utente</p>
						</td>
					</tr>
					<tr style="height: 30px;">
						<td colspan="2">
						</td>
					</tr>
					<tr style="height: 30px;">
						<td class="Td-Text">
							Utente
							<asp:RequiredFieldValidator ID="RequiredUtente" runat="server" ControlToValidate="txtUtente"
								ErrorMessage='<img src="../Images/icon_small_caution.gif" alt="Valore richiesto!" />'></asp:RequiredFieldValidator>
						</td>
						<td class="Td-Value">
							<asp:TextBox ID="txtUtente" runat="server" CssClass="Input64" MaxLength="64" />
						</td>
					</tr>
					<tr style="height: 30px;">
						<td class="Td-Text" style="vertical-align: top;">
							Descrizione
						</td>
						<td class="Td-Value">
							<asp:TextBox ID="txtDescrizione" runat="server" CssClass="Input64" TextMode="MultiLine"
								Rows="2" MaxLength="128" />
						</td>
					</tr>
					<tr style="height: 30px;">
						<td class="Td-Text" style="vertical-align: top;">
							Dipartimentale
						</td>
						<td class="Td-Value">
							<asp:TextBox ID="txtDipartimentale" runat="server" CssClass="Input64" TextMode="MultiLine"
								Rows="2" MaxLength="128" />
						</td>
					</tr>
					<tr style="height: 30px;">
						<td class="Td-Text">
							Email Responsabile
						</td>
						<td class="Td-Value">
							<asp:TextBox ID="txtEmailResponsabile" runat="server" CssClass="Input64" MaxLength="128" />
						</td>
					</tr>
					<tr style="height: 30px;">
						<td class="Td-Text2">
							Disattivato
						</td>
						<td class="Td-Value2">
							<asp:CheckBox ID="chkDisattivato" runat="server" />
						</td>
					</tr>
					<tr>
						<td colspan="2" style="text-align: right">
							<br />
							<asp:Button ID="InsertButton" runat="server" CssClass="TabButton" CausesValidation="True"
								Text="Conferma" />
							<asp:Button ID="InsertCancelButton" runat="server" CssClass="TabButton" CausesValidation="False"
								Text="Annulla" />
						</td>
					</tr>
				</table>
			</td>
		</tr>
		<tr id="trGridView" runat="server">
			<td>
				<table class="table_dettagli" width="100%">
					<tr>
						<td style="padding: 10px 0px 10px 5px;" width="50%">
							<asp:Button ID="butConfermaTop" runat="server" Text="Aggiungi Selezionati" CssClass="TabButton"
								Style="width: 140px;" CommandName="Insert" />
						</td>
						<td style="padding: 10px 5px 10px 5px; text-align: right;" width="50%">
							<asp:Button ID="butAnnullaTop" runat="server" CommandName="Cancel" Text="Chiudi"
								CssClass="TabButton" ValidationGroup="none" />
						</td>
					</tr>
				</table>
				<asp:GridView ID="gvActiveDirectory" runat="server" EmptyDataText="Nessun risultato!"
					AutoGenerateColumns="False" GridLines="Horizontal" PageSize="100" AllowPaging="true"
					DataKeyNames="objectGUID" Width="100%" PagerSettings-Position="TopAndBottom" CssClass="GridYellow"
					HeaderStyle-CssClass="Header" AlternatingRowStyle-CssClass="AlternatingRow" PagerStyle-CssClass="Pager"
					OnPageIndexChanging="gvActiveDirectory_PageIndexChanging" OnSorting="gvActiveDirectory_Sorting">
					<Columns>
						<asp:TemplateField>
							<ItemTemplate>
								<asp:CheckBox ID="chkSelect" runat="server"></asp:CheckBox>
							</ItemTemplate>
						</asp:TemplateField>
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
					</Columns>
				</asp:GridView>
				<table class="table_dettagli" width="100%">
					<tr>
						<td class="LeftFooter" width="50%">
							<asp:Button ID="butConferma" runat="server" Text="Aggiungi Selezionati" CssClass="TabButton"
								Style="width: 140px;" CommandName="Insert" />
						</td>
						<td class="RightFooter" width="50%">
							<asp:Button ID="butAnnulla" runat="server" CommandName="Cancel" Text="Chiudi" CssClass="TabButton"
								ValidationGroup="none" />
						</td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
</asp:Content>
