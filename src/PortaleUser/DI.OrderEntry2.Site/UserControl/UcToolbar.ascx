<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="UcToolbar.ascx.vb" Inherits=".ucToolbar" %>
<%-- Toolbar fixed bottom --%>
<nav id="toolbar" class="navbar navbar-default navbar-fixed-bottom">
	<div class="container-fluid text-center">
		<div class="btn-group" role="group" aria-label="...">
			<asp:LinkButton OnClientClick="ShowModalCaricamento();" ID="realIndietroButton" runat="server" CssClass="Button backButton btn btn-default navbar-btn" Text="Indietro"
				ToolTip="Torna a selezione paziente"><span class="glyphicon glyphicon-chevron-left" aria-hidden="true"></span>&nbsp;Indietro</asp:LinkButton>
			<asp:LinkButton OnClientClick="ShowModalCaricamento();" ID="btnSalvaOrdineInBozza" Visible="false" runat="server" CssClass="Button backButton btn btn-default navbar-btn" Text="Salva ordine in bozza"
				ToolTip="Salva ordine"><span class="glyphicon glyphicon-floppy-disk" aria-hidden="true"></span>&nbsp;Salva ordine in bozza</asp:LinkButton>
			<asp:LinkButton ID="btnEliminaRichiesta" runat="server" CssClass="btn btn-danger navbar-btn" OnClientClick="if(!UserDeleteConfirmation())return false;">
                <span class="glyphicon glyphicon-trash" aria-hidden="true"></span>&nbsp;Elimina</asp:LinkButton>
			<asp:LinkButton OnClientClick="ShowModalCaricamento();" ID="btnInoltraEStampaOrdine" Visible="false" runat="server" CssClass="Button backButton btn btn-default navbar-btn" Text="Inoltra e stampa ordine"
				ToolTip="Inoltra e stampa ordine"><span class="glyphicon glyphicon-file" aria-hidden="true"></span>&nbsp;Inoltra e stampa</asp:LinkButton>
			<asp:LinkButton OnClientClick="ShowModalCaricamento();" ID="btnInoltra" Visible="false" runat="server" CssClass="Button backButton btn btn-default navbar-btn" Text="Inoltra"
				ToolTip="Inoltra ordine">Inoltra&nbsp;<span class="glyphicon glyphicon-chevron-right" aria-hidden="true"></span></asp:LinkButton>
			<asp:LinkButton ID="btnAvanti" OnClientClick="ShowModalCaricamentoConValidatori();" clientidmode="Static" runat="server" CssClass="btn btn-default navbar-btn" CausesValidation="false">
                Avanti&nbsp;<span class="glyphicon glyphicon-chevron-right" aria-hidden="true"></span></asp:LinkButton>
			<asp:LinkButton OnClientClick="ShowModalCaricamento();" ID="btnStampaOrdine" Visible="false" runat="server" CssClass="Button backButton btn btn-default navbar-btn" Text="Stampa ordine"
				ToolTip="Stampa ordine"><span class="glyphicon glyphicon-print" aria-hidden="true"></span>&nbsp;Stampa</asp:LinkButton>
			<asp:LinkButton OnClientClick="ShowModalCaricamento();" ID="btnScaricaOrdine" Visible="false" runat="server" CssClass="Button backButton btn btn-default navbar-btn" Text="Scarica ordine"
				ToolTip="Scarica ordine"><span class="glyphicon glyphicon-download" aria-hidden="true"></span>&nbsp;Scarica Ordine</asp:LinkButton>
		</div>
	</div>
</nav>

<script type="text/javascript">
    function UserDeleteConfirmation() {
        return confirm("L'ordine verrà cancellato. Procedere comunque?");
    }
</script>
