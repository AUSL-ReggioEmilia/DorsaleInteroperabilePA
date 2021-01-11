<%@ Page Title="Order Entry - Configurazione Ennuple" Language="vb" AutoEventWireup="false"
	MasterPageFile="~/OrderEntry.Master" CodeBehind="EnnupleAccessi.aspx.vb" Inherits="DI.OrderEntry.Admin.EnnupleAccessi" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="OrderEntryContentPlaceHolder"
	runat="server">
	<style type="text/css">
		.GridItem1 /*ABILITATO*/ {
			cursor: default;
		}

		.GridItem2 /*DISABILITATO*/ {
			cursor: default;
			background-color: #E4E4E4;
			color: #6F6F6F;
			text-decoration: line-through;
		}

		.GridItem3 /*SIMULAZIONE*/ {
			cursor: default;
			background-color: #E4F4E4;
		}
	</style>
	<img id="loader" src="../Images/refresh.gif" style="display: none; float: left;" />
	<div id="filterPanel" runat="server" style="width: 100%;">
		<fieldset style="width: 100%;">
			<legend>Ricerca</legend>
			<table style="width: 100%; border-collapse: collapse;">
				<tr style="padding: 4px;">
					<td>Descrizione:
						<br />
						<asp:TextBox ID="DescrizioneFiltroTextBox" runat="server" Text="" />
					</td>
					<td>Gruppo di Order Entry:
						<br />
						<asp:TextBox ID="GruppoUtentiFiltroTextBox" runat="server" Text="" />
					</td>
					<td>Erogante:
						<br />
						<asp:DropDownList ID="SistemaEroganteFiltroDropDownList" runat="server" DataSourceID="SistemiErogantiObjectDataSource"
							DataTextField="Descrizione" DataValueField="Id" AppendDataBoundItems="true" CssClass="GridCombo"
							Width="250px">
							<asp:ListItem Value="" Text="(Tutti)"></asp:ListItem>
						</asp:DropDownList>
					</td>
					<td style="display: none;">NOT:
						<br />
						<asp:DropDownList ID="NotFiltroDropDownList" runat="server" CssClass="GridCombo">
							<asp:ListItem Value="" Text="(Tutti)" Selected="true"></asp:ListItem>
							<asp:ListItem Value="false" Text="Solo logica positiva"></asp:ListItem>
							<asp:ListItem Value="true" Text="Solo logica negativa"></asp:ListItem>
						</asp:DropDownList>
					</td>
					<td style="width: 100%">Stato:
						<br />
						<asp:DropDownList ID="StatoFiltroDropDownList" runat="server" DataSourceID="EnnupleStatiObjectDataSource"
							DataTextField="Descrizione" DataValueField="ID" CssClass="GridCombo" AppendDataBoundItems="true">
							<asp:ListItem Value="" Text="(Tutti)"></asp:ListItem>
						</asp:DropDownList>
					</td>
				</tr>
			</table>
			<div style="text-align: right;">
				<asp:Button ID="CercaButton" runat="server" CssClass="Button" Style="float: left; margin-top: 15px;"
					Text="Cerca" />
			</div>
		</fieldset>
	</div>
	<asp:Label ID="ErrorLabel" runat="server" Text="error" Visible="false" CssClass="Error"></asp:Label>
	<asp:ValidationSummary ID="InsertValidationSummary" runat="server" DisplayMode="List"
		CssClass="Error" ValidationGroup="InsertGroup" />
	<asp:ValidationSummary ID="EditValidationSummary" runat="server" DisplayMode="List"
		CssClass="Error" ValidationGroup="EditGroup" />
	<fieldset id='listFieldset' style="padding: 3px; margin: 3px;">
		<legend>Permessi</legend>
		<div id="toolbarAzioni" style="padding: 3px;">
			<input id="NewButton" type="button" class="addLongButton" onclick="NewEnnupla(); return false;"
				value="Nuovo" title="aggiunge una nuova ennupla" />
		</div>
		<div>
			<asp:ListView ID="EnnupleListView" runat="server" DataKeyNames="ID" DataSourceID="EnnupleObjectDataSource"
				InsertItemPosition="FirstItem">
				<EditItemTemplate>
				</EditItemTemplate>
				<EmptyDataTemplate>
					Nessuna ennupla inserita
				</EmptyDataTemplate>
				<InsertItemTemplate>
				</InsertItemTemplate>
				<ItemTemplate>
					<tr class='GridItem<%# eval("IDStato") %>'>
						<td>
							<%--                       <asp:ImageButton ID="EditButton" CssClass="ImageButton" runat="server" CommandName="Edit"
                            ImageUrl="~/Images/edititem.gif" ToolTip="Modifica" CausesValidation="false" />--%>
							<asp:ImageButton ID="EditButton" CssClass="ImageButton" runat="server" ImageUrl="~/Images/edititem.gif"
								ToolTip="Modifica" OnClientClick='<%# "EditEnnupla(""" & Eval("ID").ToString() & """, """ & Eval("Inverso").ToString().ToLower() & """,  """ & Eval("Descrizione").ToString() & """,""" & Eval("Note").ToString() & """, """ & Eval("IDStato").ToString().ToLower() & """, """ & Eval("IDGruppoUtenti").ToString().ToLower() &  """); return false;"%>' />
						</td>
						<td>
							<asp:Label ID="IDStatoLabel" runat="server" Text='<%# Bind("IDStato") %>' Style="display: none;" />
							<asp:Label ID="StatoLabel" runat="server" Text='<%# Eval("Stato") %>' />
						</td>
						<td>
							<%# IF(Eval("Inverso"), "<img src='../Images/alert.png'>", "") %>
						</td>
						<td>
							<asp:Label ID="IdLabel" runat="server" Text='<%# Bind("ID") %>' Style="display: none;" />
							<asp:Label ID="DescrizioneLabel" runat="server" Text='<%# Bind("Descrizione") %>' />
						</td>
						<td>
							<asp:Label ID="NoteLabel" runat="server" Text='<%# Bind("Note") %>' />
						</td>
						<td>
							<asp:Label ID="IdGruppoUtentiLabel" runat="server" Text='<%# Bind("IDGruppoUtenti") %>'
								Style="display: none;" />
							<asp:Label ID="GruppoUtentiLabel" runat="server" Text='<%# IF(Eval("GruppoUtenti") Is DbNull.Value, "(Tutti)", Eval("GruppoUtenti")) %>'
								CssClass='<%# IF(Eval("GruppoUtenti") Is DbNull.Value, "Bold", "") %>' />
						</td>
						<td>
							<asp:Label ID="IDSistemaEroganteLabel" runat="server" Text='<%# Bind("IDSistemaErogante") %>'
								Style="display: none;" />
							<asp:Label ID="SistemaEroganteLabel" runat="server" Text='<%# IF(Eval("SistemaErogante") Is DbNull.Value, "(Tutti)", Eval("SistemaErogante")) %>'
								CssClass='<%# IF(Eval("SistemaErogante") Is DbNull.Value, "Bold", "") %>' />
						</td>
						<td>
							<asp:Image ID="LetturaImage" runat="server" ImageUrl='<%# If(Eval("Lettura"), "../Images/ok.png", "../Images/alert.png") %>' />
						</td>
						<td>
							<asp:Image ID="ScritturaImage" runat="server" ImageUrl='<%# If(Eval("Scrittura"), "../Images/ok.png", "../Images/alert.png") %>' />
						</td>
						<td>
							<asp:Image ID="InoltroImage" runat="server" ImageUrl='<%# If(Eval("Inoltro"), "../Images/ok.png", "../Images/alert.png") %>' />
						</td>
						<td>
							<asp:ImageButton ID="DeleteButton" CssClass="ImageButton" runat="server" CommandName="Elimina"
								CommandArgument='<%# Eval("ID") %>' ToolTip="Elimina" ImageUrl="~/Images/delete.gif"
								OnClientClick="return confirm('Sei sicuro di voler eliminare la riga selezionata?');" />
							<%--<asp:ImageButton ID="CopyImageButton" CssClass="ImageButton" runat="server" CommandName="Copy"
                            CommandArgument='<%# Eval("ID") %>' ToolTip="Copia ennupla" ImageUrl="~/Images/copy.png"
                            OnClientClick="return confirm('Sei sicuro di voler copiare la riga selezionata?');" />--%>
						</td>
						<td>
							<asp:ImageButton ID="CopyImageButtonNew" CssClass="ImageButton" runat="server" CommandArgument='<%# Eval("ID") %>'
								ToolTip="Copia ennupla" ImageUrl="~/Images/copy.png" OnClientClick='<%# "EditEnnupla("""", """ & Eval("Inverso").ToString().ToLower() & """,  """ & Eval("Descrizione").ToString() & """,""" & Eval("Note").ToString() & """, """ & Eval("IDStato").ToString().ToLower() & """, """ & Eval("IDGruppoUtenti").ToString().ToLower() & """ , """ & Eval("IDSistemaErogante").ToString().ToLower() & """, """ & Eval("Lettura").ToString().ToLower() & """, """ & Eval("Scrittura").ToString().ToLower() & """, """ & Eval("Inoltro").ToString().ToLower() & """); return false;"%>' />
						</td>
					</tr>
				</ItemTemplate>
				<LayoutTemplate>
					<table id="itemPlaceholderContainer" runat="server" style="width: 100%; border: 1px silver solid; border-collapse: collapse;"
						class="tablesorter">
						<tr id="Tr1" runat="server" style="">
							<th id="Th1" runat="server">Modifica permesso
							</th>
							<th id="Th15" runat="server">
								<asp:LinkButton ID="StatoLinkButton" runat="server" CommandName="Sort" CommandArgument="Stato">Stato</asp:LinkButton>
							</th>
							<th id="Th14" runat="server">
								<asp:LinkButton ID="InversoLinkButton" runat="server" CommandName="Sort" CommandArgument="Inverso">NOT</asp:LinkButton>
							</th>
							<th id="Th6" runat="server">
								<asp:LinkButton ID="DescrizioneLinkButton" runat="server" CommandName="Sort" CommandArgument="Descrizione">Descrizione</asp:LinkButton>
							</th>
							<th id="Th7" runat="server">
								<asp:LinkButton ID="NoteLinkButton" runat="server" CommandName="Sort" CommandArgument="Note">Note</asp:LinkButton>
							</th>
							<th id="Th4" runat="server">
								<asp:LinkButton ID="IDGruppoUtentiLinkButton" runat="server" CommandName="Sort" CommandArgument="GruppoUtenti">Gruppo di Order Entry</asp:LinkButton>
							</th>
							<th id="Th11" runat="server">
								<asp:LinkButton ID="IDSistemaEroganteLinkButton" runat="server" CommandName="Sort"
									CommandArgument="SistemaErogante">Sistema erogante</asp:LinkButton>
							</th>
							<th id="Th12" runat="server">
								<asp:LinkButton ID="LetturaLinkButton" runat="server" CommandName="Sort" CommandArgument="Lettura">Lettura</asp:LinkButton>
							</th>
							<th id="Th13" runat="server">
								<asp:LinkButton ID="ScritturaLinkButton" runat="server" CommandName="Sort" CommandArgument="Scrittura">Inserimento</asp:LinkButton>
							</th>
							<th id="Th2" runat="server">
								<asp:LinkButton ID="InoltroLinkButton" runat="server" CommandName="Sort" CommandArgument="Inoltro">Inoltro</asp:LinkButton>
							</th>
							<th id="Th3" runat="server">Elimina
							</th>
							<th id="Th5" runat="server">Copia
							</th>
						</tr>
						<tr id="itemPlaceholder" runat="server">
						</tr>
					</table>
				</LayoutTemplate>
			</asp:ListView>
			<asp:ObjectDataSource ID="EnnupleObjectDataSource" runat="server" SelectMethod="GetData"
				TypeName="DI.OrderEntry.Admin.Data.EnnupleAccessiTableAdapters.UiEnnupleAccessiListTableAdapter"
				OldValuesParameterFormatString="{0}" InsertMethod="Insert" UpdateMethod="Update">
				<InsertParameters>
					<asp:Parameter Name="UtenteInserimento" Type="String" />
					<asp:Parameter DbType="Guid" Name="IDGruppoUtenti" />
					<asp:Parameter Name="Descrizione" Type="String" />
					<asp:Parameter Name="Note" Type="String" />
					<asp:Parameter DbType="Guid" Name="IDSistemaErogante" />
					<asp:Parameter Name="Lettura" Type="Boolean" />
					<asp:Parameter Name="Inoltro" Type="Boolean" />
					<asp:Parameter Name="Scrittura" Type="Boolean" />
					<asp:Parameter Name="Inverso" Type="Boolean" />
					<asp:Parameter Name="IDStato" Type="Byte" />
				</InsertParameters>
				<SelectParameters>
					<asp:ControlParameter ControlID="GruppoUtentiFiltroTextBox" Name="GruppoUtenti" PropertyName="Text"
						Type="String" />
					<asp:ControlParameter ControlID="DescrizioneFiltroTextBox" Name="Descrizione" PropertyName="Text"
						Type="String" />
					<asp:Parameter Name="Note" Type="String" />
					<asp:ControlParameter ControlID="SistemaEroganteFiltroDropDownList" DbType="Guid"
						Name="IDSistemaErogante" PropertyName="SelectedValue" />
					<asp:ControlParameter ControlID="NotFiltroDropDownList" Name="Inverso" PropertyName="SelectedValue"
						Type="Boolean" />
					<asp:ControlParameter ControlID="StatoFiltroDropDownList" Name="IDStato" PropertyName="SelectedValue"
						Type="Byte" />
				</SelectParameters>
				<UpdateParameters>
					<asp:Parameter DbType="Guid" Name="ID" />
					<asp:Parameter Name="UtenteModifica" Type="String" />
					<asp:Parameter DbType="Guid" Name="IDGruppoUtenti" />
					<asp:Parameter Name="Descrizione" Type="String" />
					<asp:Parameter Name="Note" Type="String" />
					<asp:Parameter DbType="Guid" Name="IDSistemaErogante" />
					<asp:Parameter Name="Lettura" Type="Boolean" />
					<asp:Parameter Name="Inoltro" Type="Boolean" />
					<asp:Parameter Name="Scrittura" Type="Boolean" />
					<asp:Parameter Name="Inverso" Type="Boolean" />
					<asp:Parameter Name="IDStato" Type="Byte" />
				</UpdateParameters>
			</asp:ObjectDataSource>
			<asp:ObjectDataSource ID="EnnupleStatiObjectDataSource" runat="server" OldValuesParameterFormatString="original_{0}"
				SelectMethod="GetData" TypeName="DI.OrderEntry.Admin.Data.EnnupleTableAdapters.UiLookupEnnupleStatiTableAdapter">
				<SelectParameters>
					<asp:Parameter Name="ID" Type="Byte" />
				</SelectParameters>
			</asp:ObjectDataSource>
			<asp:ObjectDataSource ID="SistemiErogantiObjectDataSource" runat="server" OldValuesParameterFormatString="original_{0}"
				SelectMethod="GetData" TypeName="DI.OrderEntry.Admin.Data.EnnupleAccessiTableAdapters.UiLookupSistemiErogantiTableAdapter">
				<SelectParameters>
					<asp:Parameter Name="Codice" Type="String" />
				</SelectParameters>
			</asp:ObjectDataSource>
			<asp:ObjectDataSource ID="GruppiUtentiObjectDataSource" runat="server"
				DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}"
				SelectMethod="GetData" TypeName="DI.OrderEntry.Admin.Data.EnnupleTableAdapters.UiGruppiUtentiListTableAdapter"
				UpdateMethod="Update" DataObjectTypeName="System.Nullable`1[[System.Guid, mscorlib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089]]">
				<InsertParameters>
					<asp:Parameter Name="Descrizione" Type="String" />
					<asp:Parameter Name="Note" Type="String"></asp:Parameter>
				</InsertParameters>
				<SelectParameters>
					<asp:Parameter Name="Descrizione" Type="String" />
					<asp:Parameter Name="Utente" Type="String" />
					<asp:Parameter Name="Note" Type="String"></asp:Parameter>
				</SelectParameters>
				<UpdateParameters>
					<asp:Parameter DbType="Guid" Name="ID" />
					<asp:Parameter Name="Descrizione" Type="String" />
					<asp:Parameter Name="Note" Type="String"></asp:Parameter>
				</UpdateParameters>
			</asp:ObjectDataSource>
		</div>
	</fieldset>
	<div id="anteprimaDiv">
	</div>
	<div id="EnnuplaAccessiDetail" style="display: none; padding: 5px;">
		<table style="width: 100%; border-collapse: collapse; padding: 10px; font-size: 12px;">
			<tr>
				<td style="width: 100%; padding: 5px;">
					<asp:HiddenField ID="EnnuplaAccessiDetail_IdHiddenField" runat="server" />
				</td>
			</tr>
			<tr>
				<td style="width: 100%; padding: 5px;">NOT
				</td>
				<td style="width: 100%; padding: 5px;">
					<asp:CheckBox ID="EnnuplaAccessiDetail_NotCheckBox" runat="server" />
				</td>
			</tr>
			<tr>
				<td style="width: 100%; padding: 5px;">Stato
				</td>
				<td style="width: 100%; padding: 5px;">
					<asp:DropDownList ID="EnnuplaAccessiDetail_StatoDropDownList" runat="server" DataSourceID="EnnupleStatiObjectDataSource"
						DataTextField="Descrizione" DataValueField="ID" CssClass="GridCombo" Width="180px">
						<asp:ListItem Value="" Text="(Tutti)"></asp:ListItem>
					</asp:DropDownList>
				</td>
			</tr>
			<tr>
				<td style="width: 100%; padding: 5px;">Descrizione
				</td>
				<td style="width: 100%; padding: 5px;">
					<asp:TextBox ID="EnnuplaAccessiDetail_DescrizioneTextBox" runat="server"></asp:TextBox>
				</td>
			</tr>
			<tr>
				<td style="width: 100%; padding: 5px;">Note
				</td>
				<td style="width: 100%; padding: 5px;">
					<asp:TextBox TextMode="MultiLine" Height="100" ID="EnnuplaAccessiDetail_NoteTextBox" runat="server"></asp:TextBox>
				</td>
			</tr>
			<tr>
				<td style="width: 100%; padding: 5px;">Gruppo di Order Entry
				</td>
				<td style="width: 100%; padding: 5px;">
					<asp:DropDownList ID="EnnuplaAccessiDetail_GruppoUtentiDropDownList" runat="server"
						DataSourceID="GruppiUtentiObjectDataSource" DataTextField="Descrizione" DataValueField="ID"
						AppendDataBoundItems="true" CssClass="GridCombo" Width="180px">
						<asp:ListItem Value="" Text="(Tutti)"></asp:ListItem>
					</asp:DropDownList>
				</td>
			</tr>
			<tr>
				<td style="width: 100%; padding: 5px;">Sistema erogante
				</td>
				<td style="width: 100%; padding: 5px;">
					<asp:DropDownList ID="EnnuplaAccessiDetail_SistemaEroganteDropDownList" runat="server"
						DataSourceID="SistemiErogantiObjectDataSource" DataTextField="Descrizione" DataValueField="Id"
						AppendDataBoundItems="true" CssClass="GridCombo" Width="180px">
						<asp:ListItem Value="" Text="(Tutti)"></asp:ListItem>
					</asp:DropDownList>
				</td>
			</tr>
			<tr>
				<td style="width: 100%; padding: 5px;">Lettura
				</td>
				<td style="width: 100%; padding: 5px;">
					<asp:CheckBox ID="EnnuplaAccessiDetail_LetturaCheckBox" runat="server" />
				</td>
			</tr>
			<tr>
				<td style="width: 100%; padding: 5px;">Inserimento
				</td>
				<td style="width: 100%; padding: 5px;">
					<asp:CheckBox ID="EnnuplaAccessiDetail_ScritturaCheckBox" runat="server" />
				</td>
			</tr>
			<tr>
				<td style="width: 100%; padding: 5px;">Inoltro
				</td>
				<td style="width: 100%; padding: 5px;">
					<asp:CheckBox ID="EnnuplaAccessiDetail_InoltroCheckBox" runat="server" />
				</td>
			</tr>
		</table>
		<br />
		<asp:Button ID="SaveButton" runat="server" CssClass="saveFake" Text="Salva" ToolTip="Salva il permesso"
			Style="display: none;" CausesValidation="false" OnClick="SaveButton_Click"></asp:Button>
	</div>
	<script type="text/javascript">

		var _EnnuplaAccessiDetail_IdHiddenField;

		var _EnnuplaAccessiDetail_NOT;

		var _EnnuplaAccessiDetail_StatoDropDownList;

		var _EnnuplaAccessiDetail_Descrizione;

		var _EnnuplaAccessiDetail_Note;

		var _EnnuplaAccessiDetail_SistemaEroganteDropDownList;

		var _EnnuplaAccessiDetail_GruppoUtentiDropDownList;

		var _EnnuplaAccessiDetail_Lettura;

		var _EnnuplaAccessiDetail_Scrittura;

		var _EnnuplaAccessiDetail_Inoltro;

		$(document).ready(function () {

			_EnnuplaAccessiDetail_IdHiddenField = '<%= EnnuplaAccessiDetail_IdHiddenField.ClientID %>';
			_EnnuplaAccessiDetail_NotCheckBox = '<%= EnnuplaAccessiDetail_NotCheckBox.ClientID %>';
			_EnnuplaAccessiDetail_StatoDropDownList = '<%= EnnuplaAccessiDetail_StatoDropDownList.ClientID %>';
			_EnnuplaAccessiDetail_DescrizioneTextBox = '<%= EnnuplaAccessiDetail_DescrizioneTextBox.ClientID %>';
			_EnnuplaAccessiDetail_NoteTextBox = '<%= EnnuplaAccessiDetail_NoteTextBox.ClientID %>';
			_EnnuplaAccessiDetail_SistemaEroganteDropDownList = '<%= EnnuplaAccessiDetail_SistemaEroganteDropDownList.ClientID %>';
			_EnnuplaAccessiDetail_GruppoUtentiDropDownList = '<%= EnnuplaAccessiDetail_GruppoUtentiDropDownList.ClientID %>';
			_EnnuplaAccessiDetail_LetturaCheckBox = '<%= EnnuplaAccessiDetail_LetturaCheckBox.ClientID %>';
			_EnnuplaAccessiDetail_ScritturaCheckBox = '<%= EnnuplaAccessiDetail_ScritturaCheckBox.ClientID %>';
			_EnnuplaAccessiDetail_InoltroCheckBox = '<%=EnnuplaAccessiDetail_InoltroCheckBox.ClientID %>';

		});

	</script>
	<script src="../Scripts/ennuple-accessi.js?<%# Reflection.Assembly.GetExecutingAssembly.GetName.Version.ToString %>" type="text/javascript"></script>
</asp:Content>
