<%@ Page Title="Raccolta dei Consensi Privacy" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="DatiTutore.aspx.vb"
	Inherits=".DatiTutore" %>

<%@ MasterType VirtualPath="~/Site.Master" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
	<h3>Rilevazione consenso privacy su minore
        <br />
		<small>Inserire le generalità del Genitore / Tutore Legale</small></h3>

	<div class="row">
		<div class="col-sm-6 col-lg-4">
			<div class="panel panel-default small ">
				<div class="panel-body">
					<div class="form">
						<div class="form-group form-group-sm">
							<label for="ddlRelazione">Relazione col minore</label>
							<asp:DropDownList ID="ddlRelazione" runat="server" Width="100%" AppendDataBoundItems="True" CssClass="form-control" DataSourceID="odsRelazione"
								DataTextField="Descrizione" DataValueField="Descrizione">
							</asp:DropDownList>
						</div>

						<div class="form-group form-group-sm">
							<label for="txtCognome">Cognome</label>
							<asp:TextBox runat="server" ID="txtCognome" CssClass="form-control" MaxLength="64" placeholder="Cognome"></asp:TextBox>
							<asp:RequiredFieldValidator ID="Req2" class="label label-danger" runat="server" ErrorMessage="Campo Obbligatorio" Display="Dynamic"
								ControlToValidate="txtCognome" />
						</div>

						<div class="form-group form-group-sm">
							<label for="txtNome">Nome</label>
							<asp:TextBox runat="server" ID="txtNome" CssClass="form-control" MaxLength="64" placeholder="Nome"></asp:TextBox>
							<asp:RequiredFieldValidator ID="req1" class="label label-danger" runat="server" ErrorMessage="Campo Obbligatorio" Display="Dynamic"
								ControlToValidate="txtNome" />
						</div>

						<div class="form-group form-group-sm">
							<label for="txtDataNascita">Data di Nascita</label>
							<asp:TextBox runat="server" ID="txtDataNascita" placeholder="gg/mm/aaaa" CssClass="form-control" MaxLength="10"></asp:TextBox>
							<asp:RequiredFieldValidator ID="ReqDataNascita" class="label label-danger" runat="server" ErrorMessage="Campo Obbligatorio"
								Display="Dynamic" ControlToValidate="txtDataNascita" />
							<asp:RangeValidator Type="Date" MinimumValue="1900-01-01" MaximumValue="3000-01-01" ControlToValidate="txtDataNascita"
								runat="server" class="label label-danger" ErrorMessage="Inserire una data valida" Display="Dynamic"></asp:RangeValidator>
						</div>

						<div class="form-group form-group-sm">
							<label for="txtLuogoNascita">Luogo di Nascita</label>
							<asp:TextBox runat="server" ID="txtLuogoNascita" CssClass="form-control" MaxLength="128" placeholder="Luogo di nascita"></asp:TextBox>
							<asp:RequiredFieldValidator ID="Req4" class="label label-danger" runat="server" ErrorMessage="Campo Obbligatorio" Display="Dynamic"
								ControlToValidate="txtLuogoNascita" />
						</div>
						<div class="form-group">
							<label class="text-danger">Tutti i dati sono obbligatori </label>
						</div>
					</div>
				</div>
				<div class="panel-footer">
					<div class="text-right">
						<asp:Button ID="butAnnulla" CssClass="btn btn-default" runat="server" Text="Annulla" CausesValidation="false" />
						<asp:Button ID="butSalva" runat="server" Text="Acquisici Consenso" CssClass="btn btn-primary" />
					</div>
				</div>
			</div>
		</div>
	</div>

	<asp:ObjectDataSource ID="odsRelazione" runat="server" SelectMethod="GetRelazioneMinore" TypeName="WcfSacConsensiHelper"
		OldValuesParameterFormatString="original_{0}"></asp:ObjectDataSource>
</asp:Content>
