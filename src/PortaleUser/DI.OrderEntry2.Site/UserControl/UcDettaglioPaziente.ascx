<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="UcDettaglioPaziente.ascx.vb" Inherits=".UcDettaglioPaziente" %>

<div id="dettaglio">
	<div class="row">
		<div class="col-sm-12">
			<label class="label label-default">Paziente</label>
			<div class="panel panel-default small">
				<div class="panel-body">
					<asp:FormView ID="fvPaziente" runat="server" DataSourceID="odsPazienteDettaglio" Width="98%" EnableViewState="false" ClientIDMode="Static">
						<ItemTemplate>
							<div class="col-sm-6">
								<span style="font-weight: bold; font-size: 16px;">
									<a id="SacHyperLink" href='<%# DI.OrderEntry.User.CustomDataSourceDettaglioPaziente.GetSacPazienteUrl(Eval("Id")) %>' target="_blank" title="visualizza il dettaglio del paziente">
										<img src="<%= Page.ResolveUrl("~/Images/person.gif")%>" alt="visualizza il dettaglio del paziente" />
										<%# String.Format("{0} {1} ({2})", Eval("Cognome"), Eval("Nome"), Eval("Sesso")) %>
									</a>
								</span>
							<%--	<br />
								<asp:Label ID="CodiceFiscaleLabel" runat="server" Font-Bold="true" Text='<%# Eval("CodiceFiscale") %>' Style="padding-left: 22px;" />,
							<%# If(Eval("Sesso") = "M", "nato il ", "nata il ") %>
								<asp:Label ID="DataNascitaLabel" Font-Bold="true" runat="server" Text='<%# String.Format("{0:d} {1}", Eval("DataNascita"), GetAge2(Eval("DataNascita"))) %>' />
								<asp:Label ID="LuogoNascitaLabel" Font-Bold="true" runat="server" Text='<%# Eval("ComuneNascitaNome") %>' />--%>
							</div>
							<%--<div id="divIcons" class="col-sm-6 text-right">
								<asp:Label ID="NumeroEpisodioLabel" runat="server" ClientIDMode="Static"></asp:Label>
								<asp:LinkButton runat="server" ID="lnkReferti" Visible="false" alt='visualizza i referti' OnClick="ShowReferti" title='visualizza i referti'>
									<img id="imgReferti" runat="server" src=".." /></asp:LinkButton>
								<asp:LinkButton runat="server" ID="lnkEsenzioni" Visible="false" OnClick="ShowEsenzioni">
									<img src="<%= Page.ResolveUrl("~/Images/icon_small_caution.gif")%>" alt='Sono presenti esenzioni' title='Sono presenti esenzioni'/></asp:LinkButton>
								<asp:LinkButton runat="server" ID="lnkRicoveri" Visible="false" OnClick="ShowRicovero" ClientIDMode="Static"><%# GetElement() %></asp:LinkButton>
							</div>--%>
						</ItemTemplate>
					</asp:FormView>
				</div>
			</div>
		</div>
	</div>

	<asp:ObjectDataSource ID="odsPazienteDettaglio" runat="server" SelectMethod="GetDataById" EnableCaching="false"
		TypeName="DI.OrderEntry.User.CustomDataSourceDettaglioPaziente+Paziente" OldValuesParameterFormatString="original_{0}">
		<SelectParameters>
			<asp:Parameter Name="IdPaziente" Type="String" />
		</SelectParameters>
	</asp:ObjectDataSource>

	<div class="modal fade" id="modalEsenzioni" role="dialog" aria-labelledby="myModalLabel">
		<div class="modal-dialog" role="document">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
					<h4 class="modal-title" runat="server" id="H1">Esenzioni</h4>
				</div>
				<div class="modal-body">
					<div class="row">
						<div class="form-horizontal">
							<asp:GridView ID="gvEsenzioni" AutoGenerateColumns="False" CssClass="small table table-bordered table-striped table-condensed" runat="server" DataSourceID="odsEsenzioni">
								<Columns>
									<asp:BoundField DataField="CodiceEsenzione" HeaderText="CodiceEsenzione" SortExpression="CodiceEsenzione"></asp:BoundField>
									<asp:BoundField DataField="CodiceDiagnosi" HeaderText="CodiceDiagnosi" SortExpression="CodiceDiagnosi"></asp:BoundField>
									<asp:BoundField DataField="DataInizioValidita" HeaderText="DataInizioValidita" SortExpression="DataInizioValidita"></asp:BoundField>
									<asp:BoundField DataField="DataFineValidita" HeaderText="DataFineValidita" SortExpression="DataFineValidita"></asp:BoundField>
									<asp:BoundField DataField="TestoEsenzione" HeaderText="TestoEsenzione" SortExpression="TestoEsenzione"></asp:BoundField>
									<asp:BoundField DataField="DecodificaEsenzioneDiagnosi" HeaderText="DecodificaEsenzioneDiagnosi" SortExpression="DecodificaEsenzioneDiagnosi"></asp:BoundField>
								</Columns>
							</asp:GridView>
							<asp:ObjectDataSource runat="server" ID="odsEsenzioni" OldValuesParameterFormatString="original_{0}" SelectMethod="GetDataByIdPaziente" TypeName="DI.OrderEntry.User.CustomDataSourceDettaglioPaziente+Esenzioni">
								<SelectParameters>
									<asp:Parameter Name="idPaziente" Type="String"></asp:Parameter>
								</SelectParameters>
							</asp:ObjectDataSource>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>

	<div class="modal fade" id="modalReferti" role="dialog" aria-labelledby="myModalLabel">
		<div class="modal-dialog modal-lg" role="document">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
					<h4 class="modal-title" runat="server">Referti</h4>
				</div>
				<div class="modal-body">
					<div class="row">
						<div class="form-horizontal">
							<div style="width: 100%; max-height: 500px; overflow-y: scroll">
								<asp:GridView ID="gvReferti" AutoGenerateColumns="False" CssClass="small table table-bordered table-striped table-condensed" runat="server" DataSourceID="odsReferti">
									<Columns>
										<asp:TemplateField>
											<ItemTemplate>
												<a target="_blank" href="<%# GetLinkReferto(Eval("Id")) %>"><span class="glyphicon glyphicon-link"></span></a>
											</ItemTemplate>
										</asp:TemplateField>
										<asp:TemplateField>
											<Itemtemplate>
												<%# String.Format("{0}-{1}", Eval("AziendaErogante"), Eval("SistemaErogante")) %>
											</Itemtemplate>
											<HeaderTemplate>
												Sistema Erogante
											</HeaderTemplate>
										</asp:TemplateField>
										<asp:BoundField DataField="DataReferto" HeaderText="DataReferto" SortExpression="DataReferto"></asp:BoundField>
										<asp:TemplateField>
											<ItemTemplate>
												<img src='<%# Page.ResolveUrl(GetIconStatoRichiesta(Eval("StatoRichiestaCodice"))) %>' alt='<%# IIf(Eval("StatoRichiestaCodice") = 1, "Inserita", "") %>' title='<%# IIf(Eval("StatoRichiestaCodice") = 1, "Inserita", "") %>' runat="server" />
											</ItemTemplate>
											<HeaderTemplate>
												Stato Richiesta
											</HeaderTemplate>
										</asp:TemplateField>
										<asp:BoundField DataField="Anteprima" HeaderText="Anteprima" SortExpression="Anteprima"></asp:BoundField>
										<asp:BoundField DataField="RepartoErogante" HeaderText="RepartoErogante" SortExpression="RepartoErogante"></asp:BoundField>
										<asp:BoundField DataField="RepartoRichiedenteDescrizione" HeaderText="RepartoRichiedenteDescrizione" SortExpression="RepartoRichiedenteDescrizione"></asp:BoundField>
										<asp:BoundField DataField="NumeroNosologico" HeaderText="NumeroNosologico" SortExpression="NumeroNosologico"></asp:BoundField>
										
									</Columns>
								</asp:GridView>
							</div>
							<asp:ObjectDataSource runat="server" ID="odsReferti" OldValuesParameterFormatString="{0}" SelectMethod="GetDataByIdPaziente" TypeName="DI.OrderEntry.User.CustomDataSourceDettaglioPaziente+Referti">
								<SelectParameters>
									<asp:Parameter Name="idPaziente" Type="String"></asp:Parameter>
								</SelectParameters>
							</asp:ObjectDataSource>

						</div>
					</div>
					
					<div class="modal-footer">
						<a id="lnkTuttiReferti" class="btn btn-primary" href='<%#GetUrlTuttiReferti %>' target="_blank">Visualizza referti su DWH</a>
						<button type="button" class="btn btn-default" data-dismiss="modal">Chiudi</button>
					</div>
				</div>
			</div>
		</div>
	</div>

	<div class="modal fade" id="modalRicoveri" role="dialog" aria-labelledby="myModalLabel">
		<div class="modal-dialog" role="document">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
					<h4 class="modal-title" runat="server">Ricoveri</h4>
				</div>
				<div class="modal-body">
					<div class="row">
						<div class="form-horizontal">
							<asp:GridView ID="gvRicoveri" CssClass="small table-margin table table-bordered table-condensed table-striped" runat="server" AutoGenerateColumns="False" DataSourceID="odsRicoveri">
								<Columns>
									<asp:BoundField DataField="Descrizione" HeaderText="Descrizione" SortExpression="Descrizione"></asp:BoundField>
									<asp:BoundField DataField="Data_Evento" HeaderText="Data_Evento" SortExpression="Data_Evento"></asp:BoundField>
									<asp:BoundField DataField="Reparto" HeaderText="Reparto" SortExpression="Reparto"></asp:BoundField>
								</Columns>
							</asp:GridView>
							<asp:ObjectDataSource runat="server" ID="odsRicoveri" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="DI.OrderEntry.User.CustomDataSourceDettaglioPaziente+Ricoveri">
								<SelectParameters>
									<asp:Parameter Name="nosologico" Type="String"></asp:Parameter>
									<asp:Parameter Name="idPaziente" Type="String"></asp:Parameter>
									<asp:Parameter Name="aziendaErogante" Type="String"></asp:Parameter>
								</SelectParameters>
							</asp:ObjectDataSource>
						</div>
					</div>
					<div class="modal-footer">
						<a id="lnkTuttiRicoveri" class="btn btn-primary" href='<%#GetUrlTuttiRicoveri %>' target="_blank">Visualizza ricoveri&nbsp;<span class="glyphicon glyphicon-new-window"></span></a>
						<button type="button" class="btn btn-default" data-dismiss="modal">Chiudi</button>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>
