<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="ListaPazienti.aspx.vb" EnableEventValidation="true"
	Inherits="DI.OrderEntry.User.ListaPazienti" %>

<%@ MasterType VirtualPath="~/Site.Master" %>
<%@ Register Src="~/UserControl/UcWizard.ascx" TagPrefix="uc1" TagName="UcWizard" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
	<div class="row" id="divErrorMessage" runat="server" visible="false" enableviewstate="false">
		<div class="col-sm-12">
			<div class="alert alert-danger">
				<asp:Label ID="lblError" runat="server" CssClass="Error text-danger" EnableViewState="false" />
			</div>
		</div>
	</div>

	<uc1:UcWizard runat="server" ID="UcWizard" CurrentStep="1" />
	<div class="row" id="divSuperati100Risultati" runat="server" visible="false" enableviewstate="false">
		<div class="col-sm-12">
			<div class="alert alert-danger">
				<asp:Label ID="Label1" runat="server" CssClass="Error text-danger" EnableViewState="false" Text="La ricerca ha prodotto più di 100 risultati, ne sono stati mostrati solo i primi 100. Si prega di inserire ulteriori parametri di ricerca." />
			</div>
		</div>
	</div>
	<!--filtri-->
	<div class="row">
		<div class="col-sm-12">
			<div id="pannelloFiltriRicerca" runat="server">
				<label class="label label-default">Ricerca</label>
				<div class="panel panel-default small">
					<div class="panel-body">
						<div class="form-horizontal">
							<div class="row">
								<div class="col-sm-6">
									<div class="form-group form-group-sm">
										<asp:Label runat="server" ID="lblCognome" AssociatedControlID="txtCognome" CssClass="control-label col-sm-3">Cognome</asp:Label>
										<div class="col-sm-6">
											<asp:TextBox runat="server" AutoComplete="off" ID="txtCognome" CssClass="form-control" placeholder="Cognome" />
										</div>
									</div>
								</div>
								<div class="col-sm-6">
									<div class="form-group form-group-sm">
										<asp:Label runat="server" ID="lblNome" AssociatedControlID="txtNome" CssClass="control-label DateInput col-sm-3">Nome</asp:Label>
										<div class="col-sm-6">
											<asp:TextBox runat="server" AutoComplete="off" ID="txtNome" CssClass="form-control" placeholder="Nome" />
										</div>
									</div>
								</div>
							</div>
							<div class="row">
								<div class="col-sm-6">
									<div class="form-group form-group-sm">
										<asp:Label runat="server" ID="lblDataNascita" AssociatedControlID="txtDataNascita" CssClass="control-label col-sm-3">Data di nascita</asp:Label>
										<div class="col-sm-6">
											<asp:TextBox runat="server" AutoComplete="off" ID="txtDataNascita" CssClass="form-control form-control-datatimepicker" placeholder="Data di nascita" />
											<asp:RegularExpressionValidator ValidationExpression="(0?[1-9]|[12][0-9]|3[01])[/-](0?[1-9]|1[0-2])[/-](1[89][0-9]{2}|[23][0-9]{3})" CssClass="text-danger" Display="Dynamic" ErrorMessage="Formato non valido" ControlToValidate="txtDataNascita" runat="server" ValidationGroup="PazientiSac" />
										</div>
									</div>
								</div>
								<div class="col-sm-6">
									<div class="form-group form-group-sm">
										<asp:Label runat="server" ID="lblLuogoNascita" AssociatedControlID="txtLuogoNascita" CssClass="control-label col-sm-3">Luogo di nascita</asp:Label>
										<div class="col-sm-6">
											<asp:TextBox runat="server" AutoComplete="off" ID="txtLuogoNascita" CssClass="form-control" placeholder="Luogo di nascita" />
										</div>
									</div>
								</div>
							</div>
							<div class="row">
								<div class="col-sm-6">
									<div class="form-group form-group-sm">
										<asp:Label runat="server" ID="lblCodiceFiscale" AssociatedControlID="txtCodiceFiscale" CssClass="control-label col-sm-3">Codice Fiscale</asp:Label>
										<div class="col-sm-6">
											<asp:TextBox runat="server" AutoComplete="off" ID="txtCodiceFiscale" CssClass="form-control" placeholder="Codice fiscale" />
										</div>
									</div>
								</div>
								<div class="col-sm-6">
									<div class="form-group form-group-sm">
										<div class="col-sm-6 col-sm-offset-3">
											<asp:Button CssClass="btn btn-primary" OnClientClick="ShowModalCaricamento();" runat="server" ID="btnCercaPazientiSac" Text="Cerca" CausesValidation="true" ValidationGroup="PazientiSac" />
										</div>
									</div>
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>

	<style>
		.hiddenCol {
			display: none;
		}

		.collapsing {
			transition: height 0.6s;
		}
	</style>

	<%--  ROW GVPAZIENTISAC --%>
	<div class="row">
		<div class="col-sm-12">
			<asp:GridView ID="gvPazientiSac" EmptyDataText="Nessun risultato" ClientIDMode="Static" runat="server" DataKeyNames="Id" DataSourceID="odsPazienti" AutoGenerateColumns="False" CssClass="tablesorter table table-bordered table-bordered table-hover small" Visible="true">
				<Columns>
					<asp:TemplateField HeaderStyle-CssClass="hiddenCol" ItemStyle-CssClass="hiddenCol">
						<ItemTemplate>
							<%-- ATTENZIONE: non cancellare questa colonna. Serve per gestire l'onClick event sull'intera riga. --%>
							<asp:Button ID="Row" ClientIDMode="Static" Text="do something" runat="server" CommandArgument='<%#Eval("Id") %>' />
						</ItemTemplate>
					</asp:TemplateField>
					<asp:BoundField DataField="Cognome" HeaderText="Cognome" SortExpression="Cognome"></asp:BoundField>
					<asp:BoundField DataField="Nome" HeaderText="Nome" SortExpression="Nome"></asp:BoundField>
					<asp:BoundField DataField="DataNascita" DataFormatString="{0:dd/MM/yyyy}" HeaderText="Data di Nascita" SortExpression="DataNascita" HtmlEncode="false"></asp:BoundField>
					<asp:BoundField DataField="ComuneNascitaNome" HeaderText="ComuneNascitaNome" SortExpression="ComuneNascitaNome"></asp:BoundField>
					<asp:BoundField DataField="Sesso" HeaderText="Sesso" SortExpression="Sesso"></asp:BoundField>
					<asp:BoundField DataField="CodiceFiscale" HeaderText="CodiceFiscale" SortExpression="CodiceFiscale"></asp:BoundField>
				</Columns>
			</asp:GridView>
		</div>
	</div>

	<%--  ODS PAZIENTISAC --%>
	<asp:ObjectDataSource runat="server" ID="odsPazienti" OldValuesParameterFormatString="{0}" SelectMethod="GetDataSac" TypeName="CustomDataSource+Pazienti">
		<SelectParameters>
			<asp:ControlParameter ControlID="txtCognome" PropertyName="Text" Name="cognome" Type="String"></asp:ControlParameter>
			<asp:ControlParameter ControlID="txtNome" PropertyName="Text" Name="nome" Type="String"></asp:ControlParameter>
			<asp:ControlParameter ControlID="txtDataNascita" PropertyName="Text" Name="dataNascita" Type="String"></asp:ControlParameter>
			<asp:ControlParameter ControlID="txtLuogoNascita" PropertyName="Text" Name="luogoNascita" Type="String"></asp:ControlParameter>
			<asp:ControlParameter ControlID="txtCodiceFiscale" PropertyName="Text" Name="codiceFiscale" Type="String"></asp:ControlParameter>
		</SelectParameters>
	</asp:ObjectDataSource>
	<script src="../Scripts/moment.min.js"></script>
	<script src="../Scripts/moment-with-locales.js"></script>
	<script src="../Scripts/bootstrap-datetimepicker.min.js"></script>
	<link href="../Content/bootstrap-datetimepicker.min.css" rel="stylesheet" />
	<script type="text/javascript">

		function pageLoad() {
			moment.locale('it');
			//Nascondo la modale di caricamento.
			$("#modalCaricamento").modal("hide");

			$('.form-control-datatimepicker').datetimepicker({
				locale: 'it',
				format: "DD/MM/YYYY"
			});
		}

		//ATTENZIONE:
		//Codice utilizzato per la gestione dell'onclick sull'intera riga.
		//Al click sulla riga esegue il click sul bottone contenuto nella prima colonna, in questo modo facciamo scattare il RowCommand della GridView.
		$("#gvPazientiSac tr td:not(:first-child)").click(function () {
			var btn = $(this).parent().find("input")[0];
			$(btn).trigger('click');
		});

		$("#gvPazientiSac tr").css("cursor", "pointer");
		$(document).keydown(function (e) {
			var keycode = (e.keyCode ? e.keyCode : e.which);
			if (keycode === 13) {
				$('#btnCercaPazientiSac').trigger('click');
			}
		});

	</script>
</asp:Content>
