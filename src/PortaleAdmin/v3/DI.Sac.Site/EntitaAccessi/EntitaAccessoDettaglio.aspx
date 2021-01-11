<%@ Page Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="EntitaAccessoDettaglio.aspx.vb"
	Inherits="DI.Sac.Admin.EntitaAccessoDettaglio" Title="Untitled Page" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
	<asp:Label ID="LabelError" runat="server" CssClass="Error" EnableViewState="False"
		Visible="False"></asp:Label>
	<asp:Label ID="lblDettaglioUtente" runat="server" Text="" class="Title"></asp:Label>
	<asp:GridView ID="gvEntitaAccessiServizi" runat="server" AutoGenerateColumns="False"
		EmptyDataText="Nessun risultato!" GridLines="Horizontal" DataKeyNames="Id" Width="900px"
		PagerSettings-Position="TopAndBottom" CssClass="GridYellow" HeaderStyle-CssClass="Header"
		AlternatingRowStyle-CssClass="AlternatingRow" PagerStyle-CssClass="Pager">
		<Columns>
			<asp:TemplateField Visible="false">
				<ItemTemplate>
					<asp:Label ID="lblId" runat="server" Text='<%# Eval("Id") %>'></asp:Label>
				</ItemTemplate>
			</asp:TemplateField>
			<asp:BoundField DataField="DescrizioneServizio" HeaderText="Servizio" ItemStyle-Width="250px" />
			<asp:TemplateField HeaderText="Creazione">
				<ItemTemplate>
					<asp:CheckBox ID="chkCreazione" runat="server" Checked='<%# Bind("Creazione") %>' />
				</ItemTemplate>
				<ItemStyle Width="70px"></ItemStyle>
			</asp:TemplateField>
			<asp:TemplateField HeaderText="Lettura">
				<ItemTemplate>
					<asp:CheckBox ID="chkLettura" runat="server" Checked='<%# Bind("Lettura") %>' />
				</ItemTemplate>
				<ItemStyle Width="70px"></ItemStyle>
			</asp:TemplateField>
			<asp:TemplateField HeaderText="Scrittura">
				<ItemTemplate>
					<asp:CheckBox ID="chkScrittura" runat="server" Checked='<%# Bind("Scrittura") %>' />
				</ItemTemplate>
				<ItemStyle Width="70px"></ItemStyle>
			</asp:TemplateField>
			<asp:TemplateField HeaderText="Eliminazione">
				<ItemTemplate>
					<asp:CheckBox ID="chkEliminazione" runat="server" Checked='<%# Bind("Eliminazione") %>' />
				</ItemTemplate>
				<ItemStyle Width="70px"></ItemStyle>
			</asp:TemplateField>
			<asp:TemplateField HeaderText="Creazione Anonimizzazione">
				<ItemTemplate>
					<asp:CheckBox ID="chkCreazioneAnonimizzazione" runat="server" Checked='<%# Bind("CreazioneAnonimizzazione") %>'
						Visible='<%# AbilitaCheckAnonimizzazione(Eval("IdServizio")) %>' />
				</ItemTemplate>
				<ItemStyle Width="70px"></ItemStyle>
			</asp:TemplateField>
			<asp:TemplateField HeaderText="Lettura Anonimizzazione">
				<ItemTemplate>
					<asp:CheckBox ID="chkLetturaAnonimizzazione" runat="server" Checked='<%# Bind("LetturaAnonimizzazione") %>'
						Visible='<%# AbilitaCheckAnonimizzazione(Eval("IdServizio")) %>' />
				</ItemTemplate>
				<ItemStyle Width="70px"></ItemStyle>
			</asp:TemplateField>
			<asp:TemplateField HeaderText="Creazione Pos. Collegata">
				<ItemTemplate>
					<asp:CheckBox ID="chkCreazionePosCollegata" runat="server" Checked='<%# Bind("CreazionePosizioneCollegata") %>'
						Visible='<%# AbilitaCheckPosCollegata(Eval("IdServizio")) %>' />
				</ItemTemplate>
				<ItemStyle Width="70px"></ItemStyle>
			</asp:TemplateField>
			<asp:TemplateField HeaderText="Lettura Pos Collegata">
				<ItemTemplate>
					<asp:CheckBox ID="chkLetturaPosCollegata" runat="server" Checked='<%# Bind("LetturaPosizioneCollegata") %>'
						Visible='<%# AbilitaCheckPosCollegata(Eval("IdServizio")) %>' />
				</ItemTemplate>
				<ItemStyle Width="70px"></ItemStyle>
			</asp:TemplateField>

			<asp:TemplateField HeaderText="Controllo Completo">
				<ItemTemplate>
					<asp:CheckBox ID="chkControlloCompleto" runat="server" Checked='<%# Bind("ControlloCompleto") %>' />
				</ItemTemplate>
				<ItemStyle Width="70px"></ItemStyle>
			</asp:TemplateField>
		</Columns>
	</asp:GridView>
	<div style="text-align: right; width:900px;	padding: 30px 5px 30px 0px;	text-align: right;">	
		<asp:Button ID="btnConferma" runat="server" CssClass="TabButton" Text="Conferma" />
		<asp:Button ID="btnAnnulla" runat="server" CssClass="TabButton" Text="Annulla"	CausesValidation="False" />
	</div>
</asp:Content>
