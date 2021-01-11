<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="DatiAccessori.aspx.vb" EnableEventValidation="false"
	Inherits="DI.OrderEntry.User.DatiAccessori" %>

<%@ Import Namespace="DI.OrderEntry.Services" %>
<%@ MasterType VirtualPath="~/Site.Master" %>
<%@ Register Src="~/UserControl/UcWizard.ascx" TagPrefix="uc1" TagName="UcWizard" %>
<%@ Register Src="~/UserControl/UcToolbar.ascx" TagPrefix="uc1" TagName="UcToolbar" %>
<%@ Register Src="~/UserControl/ucDettaglioPaziente2.ascx" TagPrefix="uc1" TagName="ucDettaglioPaziente2" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
	<style>
		.table-condensed > thead > tr > th, .table-condensed > tbody > tr > th, .table-condensed > tfoot > tr > th, .table-condensed > thead > tr > td, .table-condensed > tbody > tr > td, .table-condensed > tfoot > tr > td {
			padding: 0px !important;
		}

		/* NON PERMETTE ALLA LABEL DELLE CHECKBOX DI ANDARE A CAPO. NECESSARIO SU IE 8.*/
		.checkboxlist-custom-whitespace {
			white-space: nowrap;
		}

		.input-group-btn .btn {
			padding: 4px 5px !important;
		}

		.input-group-custom-margin {
			margin-top: 5px;
		}

		.input-group-btn:last-child > .btn, .input-group-btn:last-child > .btn-group {
			z-index: 0 !important;
		}

		.input-group .form-control {
			z-index: 0 !important;
		}

		input[type="radio"], input[type="checkbox"] {
		margin: 0 !important;
		}
	</style>

	<!-- Messaggio errore -->
	<div class="row" id="divErrorMessage" runat="server" enableviewstate="false" visible="false">
		<div class="col-sm-12">
			<div class="alert alert-danger">
				<asp:Label ID="lblError" runat="server" CssClass="text-danger" EnableViewState="false" Text=""></asp:Label>
			</div>
		</div>
	</div>
	<asp:UpdateProgress ID="UpdateProgress" AssociatedUpdatePanelID="updDatiAccessori" runat="server">
		<ProgressTemplate>
			<div class="alert alert-success" style="position: absolute; z-index: 1200; right: 10px">
				<h5><strong>Caricamento in corso...</strong></h5>
			</div>
		</ProgressTemplate>
	</asp:UpdateProgress>
	<uc1:UcWizard runat="server" ID="UcWizard" CurrentStep="3" />

	<uc1:ucDettaglioPaziente2 runat="server" ID="ucDettaglioPaziente2" />

	<asp:UpdatePanel ID="updDatiAccessori" runat="server" ChildrenAsTriggers="False" UpdateMode="Conditional">
		<Triggers>
			<asp:AsyncPostBackTrigger ControlID="timer" />
			<asp:PostBackTrigger ControlID="dtGruppi" />
			<%--<asp:PostBackTrigger ControlID="btnModalAvanti" />--%>
			<%--			<asp:AsyncPostBackTrigger ControlID="dtGruppi" />--%>
		</Triggers>
		<ContentTemplate>
			<div class="row">
				<div class="col-sm-12">
					<asp:DataList ID="dtGruppi" runat="server" DataSourceID="odsGruppi" EnableViewState="false" RepeatLayout="Flow">
						<ItemTemplate>
							<div class="panel panel-default">
								<div class="panel-heading" runat="server" visible='<%# If(Container.DataItem Is Nothing OrElse String.IsNullOrEmpty(Container.DataItem), False, True) %>'>
									Dati accessori del gruppo "<strong><%# Container.DataItem %></strong>"
								</div>
								<div class="panel-body">
									<div class="form-horizontal">
										<asp:DataList ID="dtDatiAccessori" runat="server" DataSourceID="odsDatiAccessori2" OnItemDataBound="dtDatiAccessori_ItemDataBound" RepeatLayout="Flow">
											<ItemTemplate>
												<div class="form-group form-group-sm">
													<label class="col-sm-5 control-label" title='<%# GetTooltipPrestazioni(DirectCast(Container.DataItem, DatoAccessorioListaType)) %>' style="cursor: help">
														<%# DirectCast(Container.DataItem, DatoAccessorioListaType).DatoAccessorio.Etichetta %>
													</label>
													<div class="col-sm-3">
														<div id='<%# DirectCast(Container.DataItem, DatoAccessorioListaType).DatoAccessorio.Codice %>' class="colonnaRisposta">
															<asp:Panel ID="RispostaPanel" CssClass='<%# String.Format("panel{0}", DirectCast(Container.DataItem, DatoAccessorioListaType).DatoAccessorio.Codice) %>' ClientIDMode="Static" runat="server" data-codice="<%# DirectCast(Container.DataItem, DatoAccessorioListaType).DatoAccessorio.Codice %>">
															</asp:Panel>
														</div>

														<span runat="server" visible='<%# DirectCast(Container.DataItem, DatoAccessorioListaType).DatoAccessorio.Obbligatorio %>' class="label label-danger small" aria-hidden="true">Obbligatorio.</span>
													</div>
												</div>
											</ItemTemplate>
										</asp:DataList>
									</div>
									<asp:ObjectDataSource ID="odsDatiAccessori2" runat="server" SelectMethod="GetDatiAccessoriByNomeGruppo"
										TypeName="DI.OrderEntry.User.DatiAccessori">
										<SelectParameters>
											<asp:QueryStringParameter Name="idRichiesta" QueryStringField="IdRichiesta" Type="String" />
											<asp:Parameter Name="NomeGruppo" Type="String" DefaultValue="" />
										</SelectParameters>
									</asp:ObjectDataSource>
								</div>
							</div>
						</ItemTemplate>
						<FooterTemplate>
							<nav id="toolbar" class="navbar navbar-default navbar-fixed-bottom">
								<div class="container-fluid text-center">
									<div class="btn-group" role="group" aria-label="...">
										<asp:LinkButton ID="btnIndietro" OnClientClick='window.location.href = window.location.href.replace("DatiAccessori","ComposizioneOrdine"); return false;' runat="server" CssClass="btn btn-default navbar-btn" Text="Indietro"
											ToolTip="Torna a selezione paziente" CommandName="indietro">
                <span class="glyphicon glyphicon-chevron-left" aria-hidden="true"></span>&nbsp;Indietro</asp:LinkButton>

										<asp:LinkButton ClientIDMode="Static" ID="btnAvanti" runat="server" CommandName="avanti" CssClass="btn btn-default navbar-btn" CausesValidation="false">
                Avanti&nbsp;<span class="glyphicon glyphicon-chevron-right" aria-hidden="true"></span> 
										</asp:LinkButton>
									</div>
								</div>
							</nav>
						</FooterTemplate>
					</asp:DataList>
				</div>
			</div>



			<asp:ObjectDataSource ID="odsGruppi" runat="server" SelectMethod="GetNomiGruppi"
				TypeName="DI.OrderEntry.User.DatiAccessori">
				<SelectParameters>
					<asp:QueryStringParameter Name="idRichiesta" QueryStringField="IdRichiesta" Type="String" />
				</SelectParameters>
			</asp:ObjectDataSource>

			<div id="modalErroriCompilazione" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="gridSystemModalLabel">
				<div class="modal-dialog" role="document">
					<div class="modal-content">
						<div class="modal-header">
							<h4 class="modal-title" id="gridSystemModalLabel">Errori di compilazione</h4>
						</div>
						<div class="modal-body">
							<asp:Label ClientIDMode="Static" ID="lblErroriCompilazione" runat="server" CssClass="text-danger" />
						</div>
						<div class="modal-footer">
							<button type="button" class="btn btn-default" data-dismiss="modal">Annulla</button>

							<asp:LinkButton ClientIDMode="Static" OnClientClick='window.location.href = window.location.href.replace("DatiAccessori","ConfermaInoltro");' ID="btnModalAvanti" runat="server" CssClass="btn btn-primary" Text="Ok" CausesValidation="true" />
						</div>
					</div>
				</div>
			</div>
			<%-- Primo timer a scattare nella pagina --%>
			<asp:Timer runat="server" ID="timer" Enabled="true" Interval="1"></asp:Timer>
		</ContentTemplate>
	</asp:UpdatePanel>

	<script src="<%= Page.ResolveUrl("~/Scripts/moment.min.js")%>"></script>
	<script src="<%= Page.ResolveUrl("~/Scripts/moment-with-locales.js")%>"></script>
	<script src="<%= Page.ResolveUrl("~/Scripts/bootstrap-datetimepicker.min.js")%>"></script>
	<link href="<%= Page.ResolveUrl("~/Content/bootstrap-datetimepicker.min.css")%>" rel="stylesheet" />
	<script src="<%= Page.ResolveUrl(String.Format("~/Scripts/dati-accessori.js?{0}", DI.OrderEntry.User.Markup.MarkupUtility.GetAssemblyVersion()))%>"></script>
</asp:Content>
