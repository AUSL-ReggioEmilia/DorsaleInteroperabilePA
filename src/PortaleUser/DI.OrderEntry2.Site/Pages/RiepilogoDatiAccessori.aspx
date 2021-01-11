<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="RiepilogoDatiAccessori.aspx.vb" Inherits=".RiepilogoDatiAccessori" %>

<%@ Register Src="~/UserControl/UcDettaglioPaziente2.ascx" TagPrefix="uc1" TagName="DettaglioPaziente" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
	<%-- Error Message --%>
	<div class="row" id="divErrorMessage" runat="server" visible="false" enableviewstate="false">
		<div class="col-sm-12">
			<div class="alert alert-danger">
				<asp:Label ID="lblError" runat="server" CssClass="Error text-danger" EnableViewState="false" />
			</div>
		</div>
	</div>

	<h2>Riepilogo dati accessori</h2>

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
							<button id="DatiAccessoriIcon" clientidmode="Static" visible="False" runat="server" type="button" data-toggle="modal" data-target="#modalDatiAccessoriTestata" class="btn btn-link">
								<span class="glyphicon glyphicon-info-sign" style="font-size: 15px" aria-hidden="true"></span>
							</button>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>

	<div class="row">
		<div class="col-sm-12">

			<div class="panel panel-default">
				<div class="panel-heading">
					Dati della richiesta					
				</div>
				<div class="panel-body">
					<div class="col-sm-6">
						<asp:GridView EmptyDataText="Nessun dato da visualizzare." ID="gvDatiAccessoriTestata" runat="server" DataSourceID="odsDatiAccessoriTestata"
							AutoGenerateColumns="False" CssClass="table table-striped small" GridLines="None">
							<Columns>
								<asp:TemplateField HeaderText="Etichetta">
									<ItemTemplate>
										<%# GetEtichetta(Eval("DatoAccessorio")) %>
									</ItemTemplate>
								</asp:TemplateField>
								<asp:TemplateField HeaderText="Valore">
									<ItemTemplate>
										<%# Eval("ValoreDato") %>
									</ItemTemplate>
								</asp:TemplateField>
							</Columns>
						</asp:GridView>
					</div>
				</div>
			</div>

			<asp:ObjectDataSource ID="odsDatiAccessoriTestata" runat="server" SelectMethod="DatiAggiuntiviOrdineErogato" TypeName="DI.OrderEntry.User.RiassuntoOrdineMethods">
				<SelectParameters>
					<asp:QueryStringParameter QueryStringField="IdRichiesta" Name="IdRichiesta" Type="String"></asp:QueryStringParameter>
				</SelectParameters>
			</asp:ObjectDataSource>
		</div>
	</div>

	<div class="row">
		<div class="col-sm-12">

			<asp:Repeater ID="rptDatiAccessoriErogante" OnItemDataBound="rptDatiAccessoriErogante_ItemDataBound" runat="server" DataSourceID="odsDatiAccessoriErogante">
				<ItemTemplate>
					<div style="display: none">
						<div class="panel panel-default">
							<div class="panel-heading">
								<label>
									Dati erogante <%# Container.DataItem.ToString()%>
							</div>
							<div class="panel-body">
								<div class="col-sm-6">
									<table class="table table-striped small tabella-erogante" data-id='<%# Container.DataItem.ToString() %>' id='<%# Container.DataItem.ToString()%>'>
										<thead style="display: none;">
											<tr>
												<th>Etichetta
												</th>
												<th>Valore
												</th>
											</tr>
										</thead>
										<tbody>
										</tbody>
									</table>
								</div>
							</div>

							<asp:Repeater ID="rptDatiAccessoriPrestazioni" runat="server">
								<ItemTemplate>
									<div style="display: none">
										<div class="panel-heading">
											Dati prestazione: <u><%# Eval("value")%></u>
										</div>
										<div class="panel-body">
											<div class="col-sm-6">
												<table class="table table-striped small tabella-prestazione" data-id='<%# Eval("key")%>' id='<%# Eval("key")%>'>
													<thead>
														<tr>
															<th>Etichetta
															</th>
															<th>Valore
															</th>
														</tr>
													</thead>
													<tbody>
													</tbody>
												</table>
											</div>
										</div>
									</div>
								</ItemTemplate>
							</asp:Repeater>
						</div>
					</div>
				</ItemTemplate>
			</asp:Repeater>
		</div>

	</div>

	<asp:ObjectDataSource ID="odsDatiAccessoriErogante" runat="server" SelectMethod="GetDistinctSistemiFromPrestazioni" TypeName="RiepilogoDatiAccessori">
		<SelectParameters>
			<asp:QueryStringParameter QueryStringField="IdRichiesta" Name="IdRichiesta" Type="String"></asp:QueryStringParameter>
		</SelectParameters>
	</asp:ObjectDataSource>

	<script src="<%= Page.ResolveUrl("~/Scripts/RiepilogoDatiAccessori.js")%>"></script>
</asp:Content>
