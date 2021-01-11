<%@ Page Language="VB" MasterPageFile="~/Site.master" CodeBehind="Import.aspx.vb" Inherits="Import" %>

<%@ MasterType VirtualPath="~/Site.Master" %>

<asp:Content ID="headContent" ContentPlaceHolderID="head" runat="Server">
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
	<asp:ScriptManagerProxy ID="ScriptManagerProxy1" runat="server" />

	<%--


				BOX CARICAMENTO FILE


	--%>
	<div class="modal fade" id="ModalFileUpload" role="dialog" aria-hidden="true"
		data-backdrop="static" style="top: 30%;">
		<div class="modal-dialog modal-md">
			<div class="modal-content">
				<div class="modal-header">
					<h4 class="modal-title">Caricamento file Excel in <mark><%= metaTable.Name %></mark></h4>
				</div>
				<div class="modal-body">
					<span class="help-block">Selezionare il file da caricare</span>
					<div class="input-group">
						<span class="input-group-btn">
							<span class="btn btn-primary btn-file">Seleziona file&hellip;<input id="InputFile" 
								type="file" runat="server" class="InputFile" onchange="SubmitFile(); return true;" />
							</span>
						</span>
						<input id="lblFileSelezionato" type="text" class="form-control" disabled style="max-width: 980px !important;">
					</div>
					<%--PROGRESS-BAR--%>
					<div id="divProgress" class="hidden">
						<h4><span class="glyphicon glyphicon-hourglass"></span>&nbsp;&nbsp;Attendere prego&hellip;</h4>
						<div class="progress">
							<div class="progress-bar progress-bar-striped active" role="progressbar"
								aria-valuenow="100" aria-valuemin="0" aria-valuemax="100" style="width: 100%">
							</div>
						</div>
					</div>
				</div>
				<div class="modal-footer text-right">
					<%--<button class="btn btn-default" type="submit">Submit</button>--%>
					<button id="butAnnulla" class="btn btn-default" data-dismiss="modal">Annulla</button>
				</div>
			</div>
		</div>
	</div>


	<%--


				GRID DI ANTEPRIMA


	--%>
	<div id="divAnteprima" runat="server" class="row">
		<div class="col-sm-12">
			<div class="panel panel-primary">
				<div class="panel-heading">
					<h3 class="panel-title">Importazione in <%= metaTable.Name %>, Anteprima operazioni</h3>
				</div>

				<div class="panel-footer">
					<button type="button" class="btn btn-default" data-toggle="modal" data-target="#ModalFileUpload">Seleziona file&hellip;</button>
				</div>

				<div class="table-responsive">
					<asp:GridView ID="GridView1" runat="server"
						AutoGenerateColumns="true" AllowSorting="False" AllowPaging="False"
						CssClass="table table-bordered table-condensed table-custom-padding"
						EnableViewState="false">
						<PagerStyle CssClass="pagination-gridview" />
						<EmptyDataTemplate>
							Nessun elemento da visualizzare.
						</EmptyDataTemplate>
					</asp:GridView>
				</div>

				<div id="panFooter" runat="server" class="panel-footer">
					<ul class="nav navbar-nav pull-left">
						<li class="list-group-item list-group-item-success btn-group btn-group-sm">Record da aggiungere</li>
					</ul>
					<ul class="nav navbar-nav pull-left">
						<li class="list-group-item list-group-item-warning">Record da aggiornare</li>
					</ul>
					<div class="pull-right text-right">
						<asp:Button ID="butConferma" runat="server" CssClass="btn btn-primary" Text="Conferma" />
						<a class="btn btn-default" href='<%= metaTable.ListActionPath %>'>Annulla</a>
					</div>
					<div class="clearfix"></div>
				</div>

			</div>
		</div>
	</div>

	<%--   


				MODAL CON MESSAGGIO DI ATTESA DURANTE IL CARICAMENTO


	--%>
	<div class="modal fade" id="ModalMessaggioAttesa" role="dialog" aria-labelledby="ModalMessaggioAttesa" aria-hidden="true"
		data-backdrop="static" style="top: 35%;">
		<div class="modal-dialog modal-sm">
			<div class="modal-content">
				<div class="modal-body">
					<h4><span class="glyphicon glyphicon-hourglass"></span>&nbsp;&nbsp;Attendere prego...</h4>
					<div class="progress">
						<div class="progress-bar progress-bar-striped active" role="progressbar"
							aria-valuenow="100" aria-valuemin="0" aria-valuemax="100" style="width: 100%">
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>


	<script type="text/javascript">

		$(document).ready(function () {

			// AGGIUNGE IL ROLE PER IL FORM DI BOOTSTRAP
			$("#formMaster").attr("role", "form");

			// SCELTA FILE on change : SCRIVE NELLA LABEL IL NOME DEL FILE SELEZIONATO
			$("input[type=file]").on('change', function () {
				try {
					var path = this.value.replace(/\\/g, "/");
					var filename = path.substring(path.lastIndexOf("/") + 1);
					$("#lblFileSelezionato").val(filename);
				} catch (e) {
					$("#lblFileSelezionato").val(this.value);
				}
			});

		});

		//SUBMIT DEL FILE SCELTO, MOSTRA LA BARRA DI ATTESA
		function SubmitFile() {

			$("#butAnnulla").addClass('disabled');
			$("#divProgress").removeClass('hidden');
			$("#formMaster").submit();

		}

	</script>

</asp:Content>


