<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="ConfermaInoltro.aspx.vb" EnableEventValidation="false"
	Inherits="DI.OrderEntry.User.ConfermaInoltro" %>

<%@ Import Namespace="DI.OrderEntry.Services" %>
<%@ MasterType VirtualPath="~/Site.Master" %>
<%@ Register Src="~/UserControl/UcDettaglioPaziente2.ascx" TagPrefix="uc1" TagName="DettaglioPaziente" %>
<%@ Register Src="~/UserControl/UcWizard.ascx" TagPrefix="uc1" TagName="UcWizard" %>
<%@ Register Src="~/UserControl/UcToolbar.ascx" TagPrefix="uc1" TagName="UcToolbar" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">

	<%-- CSS --%>
	<style>
		#gvEroganti > tbody > tr:nth-child(2n) > td:nth-child(2n) {
			padding: 0px;
		}

		.glyphicon {
			font-size: 10px;
		}

		.table > thead > tr > th, .table > tbody > tr > th, .table > tfoot > tr > th, .table > thead > tr > td, .table > tbody > tr > td, .table > tfoot > tr > td {
			vertical-align: inherit;
		}

		#gvPrestazioni tbody tr:last-child td {
			/*border-left: 1px solid transparent !important;*/
			border-top: 1px solid transparent;
			border-bottom: 1px solid transparent;
		}

		#gvPrestazioni tbody tr:first-child th {
			/*border-left: 1px solid transparent !important;*/
			border-top: 1px solid transparent;
		}

		.td-padding {
			padding: 0px !important;
		}

		.table-margin {
			margin-bottom: 0px !important;
		}

		#gvEroganti tbody tr th:first-child, #gvPrestazioni tbody tr td:first-child {
			border-left: 1px solid transparent !important;
		}

		#gvEroganti tbody tr th:last-child, #gvPrestazioni tbody tr td:last-child {
			border-right: 1px solid transparent !important;
		}

		#gvPrestazioni > tbody > tr td:first-child {
			border-left: 1px solid transparent !important;
		}

		#gvPrestazioni > tbody > tr:nth-child(2n) > td:last-child {
			border-right: 1px solid transparent !important;
		}
	</style>

	<%-- Wizard --%>
	<uc1:UcWizard runat="server" ID="UcWizard" CurrentStep="4" />

	<%-- Dettaglio paziente. --%>
	<uc1:DettaglioPaziente runat="server" ID="DettaglioPaziente" />

	<%-- Error Message --%>
	<div class="row" id="divErrorMessage" runat="server" visible="false" enableviewstate="false">
		<div class="col-sm-12">
			<div class="alert alert-danger">
				<asp:Label ID="lblError" runat="server" CssClass="Error text-danger" EnableViewState="false" />
			</div>
		</div>
	</div>

	<%-- Testata --%>
	<div class="row">
		<div class="col-sm-12">
			<label class="label label-default">Testata Ordine</label>
			<div class="panel panel-default small">
				<div class="panel-body">

					<%-- TESTATA ORDINE NUOVA--%>
					<div class="row">
						<div class="col-sm-2">
							<span>Numero richiesta:</span>
							<label id="lblIdRichiesta" runat="server"></label>
						</div>
						<div class="col-sm-3">
							<span>Unità Operativa:</span>
							<label runat="server" id="lblUo"></label>
						</div>
						<div class="col-sm-2">
							<span>Regime:</span>
							<label runat="server" id="lblRegime"></label>
						</div>
						<div class="col-sm-2">
							<span>Priorità:</span>
							<label runat="server" id="lblPriorita"></label>
						</div>
						<div class="col-sm-2">
							<span>Data Prenotazione:</span>
							<label runat="server" id="lblDataPrenotazione"></label>
						</div>
						<div class="col-sm-1">
							<span id="ValidoError" class="glyphicon glyphicon-exclamation-sign text-danger" runat="server" visible="false" style="cursor: help; font-size: 15px"></span>
							<button id="DatiAccessoriIcon" clientidmode="Static" visible="False" runat="server" type="button" data-toggle="modal" data-target="#modalDatiAccessoriTestata" class="btn btn-link">
								<span class="glyphicon glyphicon-info-sign" style="font-size: 15px" aria-hidden="true"></span>
							</button>
						</div>
					</div>
				</div>

			</div>
		</div>
	</div>

	<%-- Prestazioni --%>
	<div class="row">
		<div class="col-sm-12">
			<label class="label label-default">Prestazioni</label>
			<div class="row">
				<div class="col-sm-12">
					<asp:GridView ID="gvEroganti" EnableViewState="false" runat="server" ClientIDMode="Static" AutoGenerateColumns="False" CssClass="table-margin table table-bordered table-condensed table-striped" ShowHeader="False" EmptyDataText="Nessun record da visualizzare." DataSourceID="odsEroganti">
						<Columns>
							<asp:TemplateField ItemStyle-Width="30px">
								<ItemTemplate>
									<%-- CONTIENE IL BOTTONE, GENERATO LATO SERVER, PER IL COLLASSAMENTO DELLA RIGA. NON CANCELLARE. --%>
								</ItemTemplate>
							</asp:TemplateField>
							<asp:TemplateField>
								<ItemTemplate>
									<%-- CONTIENE IL BOTTONE, GENERATO LATO SERVER, PER IL COLLASSAMENTO DELLA RIGA. NON CANCELLARE. --%>
								</ItemTemplate>
							</asp:TemplateField>
							<asp:TemplateField>
								<ItemTemplate>
									<asp:GridView EnableViewState="false" DataKeyNames="Id, Descrizione" OnRowCommand="gvPrestazioni_RowCommand" CssClass="small table-responsive table-margin table table-bordered table-condensed table-striped" ID="gvPrestazioni" runat="server" AutoGenerateColumns="False" HeaderStyle-CssClass="active" DataSourceID="odsPrestazioni">
										<Columns>
											<asp:TemplateField HeaderText="Codice" ItemStyle-Width="20%">
												<ItemTemplate>
													<%# Eval("Codice")%>
												</ItemTemplate>
											</asp:TemplateField>
											<asp:TemplateField HeaderText="Descrizione" ItemStyle-Width="40%">
												<ItemTemplate>
													<%# Eval("Descrizione")%>
												</ItemTemplate>
											</asp:TemplateField>
											<asp:TemplateField HeaderText="Dati accessori" ItemStyle-Width="20%">
												<ItemTemplate>
													<asp:LinkButton Visible='<%# HasPrestazioneDatiAccessori(Container.DataItem.Id) %>' runat="server" ID="btnOpenModalDatiAccessoriPrestazione" CommandName="ApriDatiAccessori" CommandArgument='<%# Eval("Id") %>'><span class="glyphicon glyphicon-info-sign" aria-hidden="true" runat="server" ></span></asp:LinkButton>
												</ItemTemplate>
											</asp:TemplateField>
											<asp:TemplateField HeaderText="Validità" ItemStyle-Width="20%">
												<ItemTemplate>
													<span class="glyphicon glyphicon-ok text-success" aria-hidden="true" runat="server" visible='<%# If(CType(Eval("Valido"), Boolean), True, False) %>'></span>
													<span class="glyphicon glyphicon-exclamation-sign text-danger" style="cursor: help;" title='<%# CType(Eval("DescrizioneStatoValidazione"), String) %>' aria-hidden="true" runat="server" visible='<%# Not If(CType(Eval("Valido"), Boolean), True, False) %>'></span>
												</ItemTemplate>
											</asp:TemplateField>
										</Columns>
									</asp:GridView>
									<asp:ObjectDataSource ID="odsPrestazioni" runat="server" SelectMethod="GetPrestazioniBySistema" TypeName="DI.OrderEntry.User.ConfermaInoltro">
										<SelectParameters>
											<asp:QueryStringParameter QueryStringField="IdRichiesta" Name="Id" Type="String"></asp:QueryStringParameter>
											<asp:Parameter Name="Sistema" Type="String"></asp:Parameter>
										</SelectParameters>
									</asp:ObjectDataSource>
								</ItemTemplate>
							</asp:TemplateField>
						</Columns>
					</asp:GridView>
					<asp:ObjectDataSource ID="odsEroganti" runat="server" SelectMethod="GetDistinctSistemiFromPrestazioni" TypeName="DI.OrderEntry.User.ConfermaInoltro">
						<SelectParameters>
							<asp:QueryStringParameter QueryStringField="IdRichiesta" Name="Id" Type="String"></asp:QueryStringParameter>
						</SelectParameters>
					</asp:ObjectDataSource>

				</div>
			</div>
		</div>
	</div>

	<%-- TOOLBAR --%>
	<uc1:UcToolbar runat="server" ID="UcToolbar" CurrentStep="4" />

	<%-- MODALI --%>
	<div class="modal fade" id="modalDatiAccessori" role="dialog" aria-labelledby="myModalLabel">
		<div class="modal-dialog" role="document">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
				<h4 class="modal-title" runat="server" id="lblDatiAccessoriRichiestaTitle"></h4>
				</div>
				<div class="modal-body">
					<div class="row">
						<div class="form-horizontal">
							<asp:ListView ID="lwDatiAccessori" runat="server" DataSourceID="odsModalDatiAccessori">
								<ItemTemplate>
									<div class="form-group form-group-sm">
										<label class="col-sm-6 control-label"><%# GetEtichetta(Eval("DatoAccessorio"))   %></label>

										<div class="col-sm-6">
											<p class="form-control-static"><%# Eval("ValoreDato")  %></p>
										</div>
									</div>
								</ItemTemplate>
							</asp:ListView>
							<asp:ObjectDataSource ID="odsModalDatiAccessori" runat="server" SelectMethod="GetDataByPrestazione" TypeName="CustomDataSource+DatiAggiuntivi">
								<SelectParameters>
									<asp:QueryStringParameter QueryStringField="IdRichiesta" Name="IdRichiesta" Type="String"></asp:QueryStringParameter>
									<asp:Parameter Name="IdPrestazione" Type="String"></asp:Parameter>
								</SelectParameters>
							</asp:ObjectDataSource>
						</div>
					</div>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">Chiudi</button>
				</div>
			</div>
		</div>
	</div>

	<div class="modal fade" id="modalDatiAccessoriTestata" role="dialog" aria-labelledby="myModalLabel">
		<div class="modal-dialog" role="document">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
					<h4 class="modal-title" runat="server">Dati accessori richiesta</h4>
				</div>
				<div class="modal-body">
					<div class="row">
						<div class="form-horizontal">
							<asp:ListView ID="lwDatiAccessoriTestata" runat="server" DataSourceID="odsDatiAccessoriTestata">
								<ItemTemplate>
									<div class="form-group form-group-sm">
										<label class="col-sm-6 control-label"><%# GetEtichetta(Eval("DatoAccessorio"))%></label>
									<div class="col-sm-6">
										<p class="form-control-static"><%# Eval("ValoreDato")%></p>
									</div>
									</div>
								</ItemTemplate>
							</asp:ListView>
							<asp:ObjectDataSource ID="odsDatiAccessoriTestata" runat="server" SelectMethod="GetDataByIdRichiesta" TypeName="CustomDataSource+DatiAggiuntivi" OldValuesParameterFormatString="{0}">
								<SelectParameters>
									<asp:QueryStringParameter QueryStringField="IdRichiesta" Name="IdRichiesta" Type="String"></asp:QueryStringParameter>
								</SelectParameters>
							</asp:ObjectDataSource>
						</div>
					</div>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">Chiudi</button>
				</div>
			</div>
		</div>
	</div>

	<%-- JAVASCRIPT --%>
	<script>

		$(document).ready(function () {
			$("tr").addClass("in");
			$("tr").removeAttr("style");
		});

		$(".navbar li:not('.has-popup,.dropdown') a").click(function () {
			var message = 'Attenzione: Ordine non inserito. Continuare comunque?'
			var url = $(this).attr('href');
			var result = ConfirmMessage(message, url);
			if (result == false) {
				return false;
			};
		});

	</script>

</asp:Content>
