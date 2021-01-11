<%@ Page Title="Dettaglio Unità Operative" Language="vb" AutoEventWireup="false"
	MasterPageFile="~/Site.Master" CodeBehind="UnitaOperativeDettaglio.aspx.vb" Inherits=".UnitaOperativeDettaglio" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
	<asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False"
		Visible="False" />
	<asp:Label ID="lblTitolo" runat="server" CssClass="Title" Text="Label" />
	<table id="toolbar" runat="server" class="toolbar" style="width: 100%;">
		<tr>
			<td>
                <asp:LinkButton ID="lnkImpostaRuoli" Text="Imposta Ruoli" runat="server" ToolTip="Imposta Ruoli" />
				<asp:LinkButton ID="lnkElimina" runat="server" ToolTip="Elimina Unità Operativa"
					OnClick="lnkElimina_Click" OnClientClick="return msgboxYESNO('Si conferma l\'eliminazione dell\'elemento?');">
				 <img src="../Images/delete.gif" class="toolbar-img" alt=""/>
				 Elimina Unità Operativa
				</asp:LinkButton>
				<asp:LinkButton ID="lnkRegimi" runat="server" ToolTip="Imposta i Regimi di ricovero"
					OnClick="lnkRegimi_Click" >
				 <img src="../Images/edititem.gif" class="toolbar-img" alt=""/>
				 Regimi di ricovero
				</asp:LinkButton>				
			</td>
		</tr>
	</table>
	<br />
	<asp:FormView ID="FormViewDettaglio" runat="server" DataKeyNames="Id" DataSourceID="odsDettaglio"
		EmptyDataText="Dettaglio non disponibile." EnableModelValidation="True" DefaultMode="Edit">
		<EditItemTemplate>
			<table class="table_dettagli" width="500px">
				<tr>
					<td class="Td-Text" width="200px">
						Id
					</td>
					<td class="Td-Value">
						<%# Eval("Id")%>
					</td>
				</tr>
				<tr>
					<td class="Td-Text">
						Azienda
					</td>
					<td class="Td-Value">
						<asp:DropDownList ID="ddlAzienda" runat="server" Width="300px" AppendDataBoundItems="True"
							DataSourceID="odsAziende" DataTextField="Descrizione" DataValueField="Codice" SelectedValue='<%# Bind("CodiceAzienda") %>'>
						</asp:DropDownList>
						<asp:RequiredFieldValidator ID="RequiredFieldValidator3" class="Error" runat="server"
							ErrorMessage="Campo Obbligatorio" Display="Dynamic" ControlToValidate="ddlAzienda" />
					</td>
				</tr>
				<tr>
					<td class="Td-Text">
						Codice
					</td>
					<td class="Td-Value">
						<asp:TextBox ID="txtCodice" runat="server" Width="300px" MaxLength="16" Text='<%# Bind("Codice") %>' />
						<asp:RequiredFieldValidator ID="RequiredFieldValidator2" class="Error" runat="server"
							ErrorMessage="Campo Obbligatorio" Display="Dynamic" ControlToValidate="txtCodice" />
					</td>
				</tr>
				<tr>
					<td class="Td-Text">
						Descrizione
					</td>
					<td class="Td-Value">
						<asp:TextBox ID="txtDescrizione" runat="server" Width="300px" MaxLength="128" Text='<%# Bind("Descrizione") %>' />
						<asp:RequiredFieldValidator ID="req1" class="Error" runat="server" ErrorMessage="Campo Obbligatorio"
							Display="Dynamic" ControlToValidate="txtDescrizione" />
					</td>
				</tr>
				<tr>
					<td class="Td-Text">
						Attiva
					</td>
					<td class="Td-Value">
						<asp:CheckBox ID="chkAttivo" runat="server" Checked='<%# Bind("Attivo") %>' />
					</td>
				</tr>			
				<tr>
					<td class="LeftFooter">
						<asp:Button ID="butSalva" runat="server" Text="Conferma" CssClass="TabButton" CommandName="Update" />
					</td>
					<td class="RightFooter">
						<asp:Button ID="butAnnulla" runat="server" CommandName="Cancel" Text="Annulla" CssClass="TabButton"
							ValidationGroup="none" />
					</td>
				</tr>
			</table>
			<!-- ############################################################################################################# -->
	        <asp:Label ID="lblTitolo2" runat="server" CssClass="Title" Text="Ruoli in cui è presente l'Unità Operativa" />
            
            <asp:GridView runat="server" DataSourceID="odsRuoli" AutoGenerateColumns="False" DataKeyNames="ID,IDRuolo,IdUnitaOperativa"
                AllowPaging="True" AllowSorting="True" GridLines="Horizontal"
                PageSize="100" Width="500px" EmptyDataText="Nessun risultato!"
                PagerSettings-Position="TopAndBottom"
                CssClass="GridYellow" HeaderStyle-CssClass="Header" AlternatingRowStyle-CssClass="AlternatingRow" PagerStyle-CssClass="Pager">
                <Columns>
                    <%--<asp:BoundField DataField="ID" HeaderText="ID" ReadOnly="True" SortExpression="ID"></asp:BoundField>--%>
                    <%--<asp:BoundField DataField="IDRuolo" HeaderText="IDRuolo" SortExpression="IDRuolo" ReadOnly="True"></asp:BoundField>--%>
                    <%--<asp:BoundField DataField="IdUnitaOperativa" HeaderText="IdUnitaOperativa" SortExpression="IdUnitaOperativa" ReadOnly="True"></asp:BoundField>--%>
                    <asp:BoundField DataField="Codice" HeaderText="Codice" SortExpression="Codice"></asp:BoundField>
                    <asp:BoundField DataField="Descrizione" HeaderText="Descrizione" SortExpression="Descrizione"></asp:BoundField>
                </Columns>
            </asp:GridView>
		</EditItemTemplate>
		<InsertItemTemplate>
			<table class="table_dettagli" width="500px">
				<tr>
					<td class="Td-Text" width="200px">
						Azienda
					</td>
					<td class="Td-Value">
						<asp:DropDownList ID="ddlAzienda" runat="server" Width="300px" AppendDataBoundItems="True"
							DataSourceID="odsAziende" DataTextField="Descrizione" DataValueField="Codice" SelectedValue='<%# Bind("CodiceAzienda") %>'>
							<asp:ListItem Text="" Value="" />
						</asp:DropDownList>
						<asp:RequiredFieldValidator ID="RequiredFieldValidator3" class="Error" runat="server"
							ErrorMessage="Campo Obbligatorio" Display="Dynamic" ControlToValidate="ddlAzienda" />
					</td>
				</tr>
				<tr>
					<td class="Td-Text">
						Codice
					</td>
					<td class="Td-Value" width="300px">
						<asp:TextBox ID="txtCodice" runat="server" Width="300px" MaxLength="16" Text='<%# Bind("Codice") %>' />
						<asp:RequiredFieldValidator ID="RequiredFieldValidator1" class="Error" runat="server"
							ErrorMessage="Campo Obbligatorio" Display="Dynamic" ControlToValidate="txtCodice" />
					</td>
				</tr>
				<tr>
					<td class="Td-Text">
						Descrizione
					</td>
					<td class="Td-Value">
						<asp:TextBox ID="txtDescrizione" runat="server" Width="300px" MaxLength="128" Text='<%# Bind("Descrizione") %>' />
						<asp:RequiredFieldValidator ID="req1" class="Error" runat="server" ErrorMessage="Campo Obbligatorio"
							Display="Dynamic" ControlToValidate="txtDescrizione" />
					</td>
				</tr>
				<tr>
					<td class="Td-Text2">
						Attiva
					</td>
					<td class="Td-Value2">
						<asp:CheckBox ID="chkAttivo" runat="server" Checked='<%# Bind("Attivo") %>' />
					</td>
				</tr>
				<tr>
					<td class="LeftFooter">
						<asp:Button ID="butSalva" runat="server" Text="Conferma" CssClass="TabButton" CommandName="Insert"
							OnClick="butSalva_Click" />
					</td>
					<td class="RightFooter">
						<asp:Button ID="butAnnulla" runat="server" CommandName="Cancel" Text="Chiudi" CssClass="TabButton"
							ValidationGroup="null" />
					</td>
				</tr>
			</table>
		</InsertItemTemplate>
	</asp:FormView>
    <asp:ObjectDataSource ID="odsRuoli" runat="server" DataObjectTypeName="System.Nullable`1[[System.Guid, mscorlib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089]]" DeleteMethod="Delete" InsertMethod="Insert" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="OrganigrammaDataSetTableAdapters.RuoliCercaPerUnitaOperativaTableAdapter">
        <InsertParameters>
            <asp:Parameter Name="UtenteInserimento" Type="String"></asp:Parameter>
            <asp:Parameter DbType="Guid" Name="IdRuolo"></asp:Parameter>
            <asp:Parameter DbType="Guid" Name="IdUnitaOperativa"></asp:Parameter>
        </InsertParameters>
        <SelectParameters>
            <asp:Parameter DbType="Guid" Name="IdUnitaOperativa"></asp:Parameter>
            <asp:Parameter Name="CodiceRuolo" Type="String"></asp:Parameter>
            <asp:Parameter Name="DescrizioneRuolo" Type="String"></asp:Parameter>
            <asp:Parameter Name="Top" Type="Int32"></asp:Parameter>
        </SelectParameters>
    </asp:ObjectDataSource> 
	<asp:ObjectDataSource ID="odsDettaglio" runat="server" TypeName="OrganigrammaDataSetTableAdapters.UnitaOperativeTableAdapter"
		SelectMethod="GetDataById" DeleteMethod="Delete" InsertMethod="Insert" UpdateMethod="Update"
		OldValuesParameterFormatString="{0}">
		<InsertParameters>
			<asp:Parameter Name="UtenteInserimento" Type="String" />
			<asp:Parameter Name="Codice" Type="String" />
			<asp:Parameter Name="Descrizione" Type="String" />
			<asp:Parameter Name="CodiceAzienda" Type="String" />
			<asp:Parameter Name="Attivo" Type="Boolean" DefaultValue="true" />
		</InsertParameters>
		<SelectParameters>
			<asp:QueryStringParameter Name="ID" QueryStringField="Id" DbType="Guid" />
		</SelectParameters>
		<UpdateParameters>
			<asp:Parameter Name="ID" DbType="Guid" />
			<asp:Parameter Name="UtenteModifica" Type="String" />
			<asp:Parameter Name="Codice" Type="String" />
			<asp:Parameter Name="Descrizione" Type="String" />
			<asp:Parameter Name="CodiceAzienda" Type="String" />
			<asp:Parameter Name="Attivo" Type="Boolean" />
		</UpdateParameters>
	</asp:ObjectDataSource>
	<asp:ObjectDataSource ID="odsAziende" runat="server" OldValuesParameterFormatString="{0}"
		SelectMethod="AziendeLista" TypeName="OrganigrammaDataSetTableAdapters.AziendeListaTableAdapter"
		CacheDuration="120" CacheKeyDependency="CacheAziende" EnableCaching="True"></asp:ObjectDataSource>
</asp:Content>
