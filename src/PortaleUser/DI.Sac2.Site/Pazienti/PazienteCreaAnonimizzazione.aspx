<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="PazienteCreaAnonimizzazione.aspx.vb" Inherits=".PazienteCreaAnonimizzazione" %>

<%@ Register Src="~/UserControl/DettaglioPaziente.ascx" TagPrefix="uc1" TagName="DettaglioPaziente" %>


<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
    <div class="row" id="divErrorMessage" runat="server" visible="false">
        <div class="col-sm-12">
            <div class="alert alert-danger">
                <asp:Label ID="LabelError" runat="server" CssClass="text-danger" EnableViewState="False"></asp:Label>
            </div>
        </div>
    </div>

    <div id="MainTable" runat="server">
        <%--<div class="row">
            <div class="col-sm-12 col-md-6">
                <label class="label label-default">Anonimizzazione paziente</label>
                <div class="panel panel-default">
                    <div class="panel-body">--%>
        <uc1:DettaglioPaziente runat="server" ID="DettaglioPaziente" />
        <%--   </div>
                </div>
            </div>
        </div>--%>
        <div class="row">
            <div class="col-sm-12 col-md-6 col-md-offset-3">
                <div class="form">
                    <div class="form-group small">
                        <asp:Label Text="Motivo anonimizzazione" AssociatedControlID="txtNote" runat="server" />
                        <asp:RequiredFieldValidator ID="txtNoteRequiredFieldValidator" runat="server" ControlToValidate="txtNote"
                            ErrorMessage='Richiesto!' CssClass="label label-danger"></asp:RequiredFieldValidator>
                        <asp:TextBox ID="txtNote" Style="width: 100% !important; max-width: none;" CssClass="form-control" runat="server" MaxLength="2048" Rows="7" TextMode="MultiLine" placeholder="Inserire il motivo dell' anonimizzazione"></asp:TextBox>
                    </div>
                    <div class="form-group small">
                        <div class="btn-group pull-right">
                            <asp:Button ID="btnConferma" runat="server" CssClass="btn btn-primary" Text="Conferma"
                                Causevalidation="True" />
                            <asp:Button ID="btnAnnulla" runat="server" CssClass="btn btn-default" Text="Annulla" CausesValidation="False" />
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <asp:ObjectDataSource ID="PazienteDettaglioObjectDataSource" runat="server" SelectMethod="GetData"
        TypeName="PazientiAnonimizzazioniDataSetTableAdapters.PazientiAnonimizzazioniPazienteSelectTableAdapter">
        <SelectParameters>
            <asp:QueryStringParameter Name="Id" QueryStringField="id" DbType="Guid" />
        </SelectParameters>
    </asp:ObjectDataSource>

</asp:Content>
