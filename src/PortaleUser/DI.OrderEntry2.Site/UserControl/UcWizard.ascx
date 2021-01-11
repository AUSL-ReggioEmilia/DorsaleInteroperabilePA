<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="UcWizard.ascx.vb" Inherits=".UcWizard" %>

<style type="text/css">
	.wizardList a { cursor: default; }
</style>

<%-- Messaggio di "Ordine in bozza" --%>
<div class="row" >
	<div id="divTitle" runat="server" class="col-sm-12">
		<h4 class="text-danger text-uppercase">Ordine in bozza - non inoltrato</h4>
	</div>
</div>


<%-- Wizard --%>
<div class="row widget">
	<div class="col-sm-12">
		<div id="wizard" class="jumbotron jumbotron-wizard-custom-margin">
			<ul runat="server" id="wizardList" class="nav nav-pills">
				<li id="li1" runat="server">
					<asp:LinkButton ID="lnk1" runat="server">
						<span class="h4">1</span>
						<span>Selezione Paziente</span>
					</asp:LinkButton>
				</li>
				<li id="li2" runat="server">
					<asp:LinkButton ID="lnk2" runat="server">
						<span class="h4">2</span>
						<span>Composizione Ordine</span>
					</asp:LinkButton>
				</li>
				<li id="li3" runat="server">
					<asp:LinkButton ID="lnk3" runat="server">
						<span class="h4">3</span>
						<span>Dati Accessori</span>
					</asp:LinkButton>
				</li>
				<li id="li4" runat="server">
					<asp:LinkButton ID="lnk4" runat="server">
						<span class="h4">4</span>
						<span>Inoltro</span>
					</asp:LinkButton>
				</li>
			</ul>
		</div>
	</div>
</div>
