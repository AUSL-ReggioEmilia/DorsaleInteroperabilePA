<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/SiteAccessoDiretto.Master" CodeBehind="AccessoDirettoMessage.aspx.vb" Inherits=".AccessoDirettoMessage" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
		<style>
		.center-div {
			position: absolute;
			margin: auto;
			top: 0;
			right: 0;
			bottom: 0;
			left: 0;
			width: 500px;
			height: 500px;
		}

		.custom-row {
			margin-top: 20px;
		}

		span.glyphicon-alert {
			font-size: 10em;
			color: red;
		}
	</style>
		<div class="container-fluid" id="divCriticalErrorMessage" runat="server" visible="false">
			<div class="center-div">
				<div class="row">
					<div class="col-sm-12 text-center custom-row">
						<span class="glyphicon glyphicon-alert" aria-hidden="true"></span>
					</div>
				</div>
				<div class="row">
					<div class="col-sm-12 text-center custom-row">
						<strong> <p class="h3" style="color:red">SI E' VERIFICATO UN ERRORE</p></strong>
						<p runat="server" id="pErrorMessage">
							Contattare l'amministratore del sito
						</p>
					</div>
				</div>
			</div>
		</div>

		<div class="container-fluid" id="divOrderSuccesfullySaved" runat="server" visible="false">
			<div class="center-div">
				<div class="row">
					<div class="col-sm-12 text-center custom-row">
						<span style="font-size: 90px;" class="glyphicon glyphicon-floppy-saved" aria-hidden="true"></span>
					</div>
				</div>
				<div class="row">
					<div class="col-sm-12 text-center custom-row">
						<h1 class="" style="color: red">ORDINE SALVATO IN BOZZA!</h1>
						<h3>Ordine correttamente salvato in bozza. Per recuperarlo, tornare alla pagina di lista degli ordini.</h3>
					</div>
				</div>
			</div>
		</div>
		<div class="container-fluid" id="divOrderSuccesfullyDeleted" runat="server" visible="false">
			<div class="center-div">
				<div class="row">
					<div class="col-sm-12 text-center custom-row">
						<span style="font-size:90px;" class="glyphicon glyphicon-remove" aria-hidden="true"></span>
					</div>
				</div>
				<div class="row">
					<div class="col-sm-12 text-center custom-row">
						<h1 class="" style="color:red">ORDINE ELIMINATO!</h1>
						<h3>Ordine definitivamente eliminato.</h3>
					</div>
				</div>
			</div>
		</div>
</asp:Content>
