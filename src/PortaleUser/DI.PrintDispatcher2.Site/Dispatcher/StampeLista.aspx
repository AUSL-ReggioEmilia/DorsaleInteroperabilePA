<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master"
	CodeBehind="StampeLista.aspx.vb" Inherits="DI.Dispatcher.User.StampeLista" Culture="it-IT" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
	<div id="divErrore" class="row" runat="server" visible="false">
		<div class="col-sm-12">
			<div class="alert alert-danger">
				<asp:Label ID="lblErrore" runat="server" Text=""></asp:Label>
			</div>
		</div>
	</div>
	<div id="filterPanel" class="row filters" runat="server">
		<div class="col-sm-12">
			<div class="panel panel-default">
				<div class="panel-body">
					<div class="form-horizontal">
						<div class="col-sm-2 form-group form-group-sm">
							<div class="col-sm-12">
								<asp:DropDownList ID="FilterDropDownList" runat="server" onchange="ClearFilters();" CssClass="form-control">
									<asp:ListItem Text="Numero Ordine O.E." Value="id" />
									<asp:ListItem Text="Cognome" Value="cognome" />
									<asp:ListItem Text="Cognome e nome" Value="cognomeNome" />
									<asp:ListItem Text="PC invio richiesta" Value="periferica" Selected="True" />
								</asp:DropDownList>
							</div>
						</div>
						<div class="col-sm-2 form-group form-group-sm">
							<div class="col-sm-12">
								<asp:TextBox ID="FilterTextBox" CssClass="form-control" runat="server" />
							</div>
						</div>
						<div class="col-sm-3 form-group form-group-sm">
							<label for="DataDaTextBox" id="lblDataDal" runat="server" class="col-sm-5 control-label">Data modifica da</label>
							<div class="col-sm-7">
								<asp:TextBox ID="DataDaTextBox" MaxLength="10" CssClass="form-control-dataPicker form-control" runat="server" aria-describedby="sizing-addon1"></asp:TextBox>
							</div>
						</div>
						<div class="col-sm-3 form-group form-group-sm">
							<label for="DataATextBox" id="lblDataA" runat="server" class="col-sm-1 control-label">a</label>
							<div class="col-sm-7">
								<asp:TextBox ID="DataATextBox" CssClass="form-control-dataPicker form-control" runat="server"></asp:TextBox>
							</div>
							<div class="col-sm-1">
								<asp:Button ID="SearchButton" Text="Cerca" runat="server" CssClass="btn btn-primary btn-sm" CausesValidation="true" />
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>

	<div id="gridPanel" class="row small">
		<div class="col-sm-12">
			<h4>Code di stampa</h4>
			<hr />
			<div class="table-responsive">
				<asp:GridView ID="RichiesteGridView" runat="server" AllowPaging="True" AllowSorting="false"
					CssClass="table table-bordered table-condensed table-striped" AutoGenerateColumns="False" DataSourceID="MainObjectDataSource"
					EnableModelValidation="True" PageSize="100">
					<EmptyDataTemplate>
						Nessun risultato.
					</EmptyDataTemplate>
					<Columns>
						<asp:TemplateField>
							<ItemTemplate>
								<div>
									<img id='<%# String.Format("refresh_{0}", Eval("IdPrinterManager")) %>' src="../Images/refresh.gif"
										style="width: 12px; height: 12px; display: none;" />
									<img id='<%# String.Format("error_{0}", Eval("IdPrinterManager")) %>' src="../Images/icon_err.gif"
										style="width: 12px; height: 12px; display: none;" title="Errore" />
									<img id='<%# String.Format("ok_{0}", Eval("IdPrinterManager")) %>' src="../Images/ok.png"
										style="width: 12px; height: 12px; display: none;" title="Ristampa effettuata con successo" />
								</div>
								<div>
									<a href="#" onclick="<%# String.Format("Reprint('{0}', {1})", Eval("IdPrinterManager"), Eval("PrintDispatcherJob").ToString().ToLower()) %>; return false;">Ristampa</a><br />
									<a href="#" onclick="<%# String.Format("ReprintLocal('{0}', {1})", Eval("IdPrinterManager"), Eval("PrintDispatcherJob").ToString().ToLower()) %>; return false;">Ristampa su questo pc</a>
								</div>
							</ItemTemplate>
						</asp:TemplateField>
						<asp:BoundField DataField="DataInserimento" HeaderText="Data di Stampa" SortExpression="DataInserimento" />
						<asp:BoundField DataField="IdOrderEntry" HeaderText="Id O.E." SortExpression="IdOrderEntry" />
						<asp:BoundField DataField="Periferica" HeaderText="PC invio richiesta" SortExpression="Periferica" />
						<asp:BoundField DataField="NumeroNosologico" HeaderText="Nosologico" SortExpression="NumeroNosologico" />
						<asp:TemplateField HeaderText="Paziente" SortExpression="PazienteCognome">
							<ItemTemplate>
								<span>
									<%#String.Format("<b>{0} {1}</b><br /> nato il {2} a {3}<br />CF: {4}", Eval("PazienteNome"), Eval("PazienteCognome"), Eval("PazienteDataNascita","{0:d}"), Eval("PazienteLuogoNascita"), Eval("PazienteCodiceFiscale")) %></span>
							</ItemTemplate>
						</asp:TemplateField>
						<asp:TemplateField HeaderText="Richiedente" SortExpression="SistemaRichiedente">
							<ItemTemplate>
								<span>
									<%#String.Format("{0}-{1}-{2}", Eval("AziendaRichiedente"), Eval("SistemaRichiedente"), Eval("UnitaOperativaDesc")) %></span>
							</ItemTemplate>
						</asp:TemplateField>
						<asp:BoundField DataField="Periferica" HeaderText="PC invio richiesta" SortExpression="Periferica" />
						<asp:TemplateField HeaderText="Destinazione stampa" SortExpression="ServerDiStampa">
							<ItemTemplate>
								<span>
									<%#String.Format("{0}\{1}", Eval("ServerDiStampa"), Eval("Stampante")) %></span>
							</ItemTemplate>
						</asp:TemplateField>
						<asp:TemplateField HeaderText="">
							<ItemTemplate>
								<a href="#" onclick="<%# String.Format("ShowFile('{0}')", Eval("IdPrinterManager")) %>; return false;"
									style="width: 16px;">
									<img id='<%# String.Format("file_{0}", Eval("IdPrinterManager")) %>' src="../Images/pdficon.gif"
										style="margin: 0px;" title="Visualizza il file" />
									<img id='<%# String.Format("fileRefresh_{0}", Eval("IdPrinterManager")) %>' src="../Images/refresh.gif"
										style="width: 16px; height: 16px; display: none; margin: 0px;" />
									<img id='<%# String.Format("fileError_{0}", Eval("IdPrinterManager")) %>' src="../Images/icon_err.gif"
										style="width: 16px; height: 16px; display: none; margin: 0px;" title="Errore" /></a>
							</ItemTemplate>
						</asp:TemplateField>
					</Columns>
				</asp:GridView>
			</div>
			<asp:ObjectDataSource ID="MainObjectDataSource" runat="server" OldValuesParameterFormatString="original_{0}"
				SelectMethod="GetPrintList" TypeName="DI.Dispatcher.User.StampeLista" SortParameterName="sortExpression">
				<SelectParameters>
					<asp:Parameter Name="tipoFiltro" Type="String" />
					<asp:Parameter Name="valoreFiltro" Type="String" />
					<asp:Parameter Name="dataDa" Type="DateTime" />
					<asp:Parameter Name="dataA" Type="DateTime" />
					<asp:Parameter DefaultValue="PrintJobDateCreated DESC" Name="sortExpression" Type="String" />
				</SelectParameters>
			</asp:ObjectDataSource>
		</div>
	</div>
	<script type="text/javascript" src="../Scripts/stampe-lista.js"></script>
	<script>
	    //CREO I BOOTSTRAP DATETIMEPICKER
	    $('.form-control-dataPicker').datepicker({
	        format: "dd/mm/yyyy",
	        weekStart: 1,
	        language: "it",
	        todayHighlight: true,
	        todayBtn: "linked",
	        orientation: "bottom left"
	    });
	</script>
</asp:Content>
