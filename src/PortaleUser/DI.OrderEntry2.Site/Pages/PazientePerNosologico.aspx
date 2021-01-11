<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="PazientePerNosologico.aspx.vb"
    Inherits="DI.OrderEntry.User.PazientePerNosologico" %>

<%@ Register Src="~/UserControl/UcWizard.ascx" TagPrefix="uc1" TagName="UcWizard" %>


<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
    <uc1:UcWizard runat="server" ID="UcWizard" CurrentStep="1" />

    <%-- Div Errore --%>
    <div class="row" id="divErrorMessage" runat="server" visible="false" enableviewstate="true">
        <div class="col-sm-12">
            <div class="alert alert-danger">
                <asp:Label ID="lblError" runat="server" CssClass="Error text-danger"></asp:Label>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="col-sm-12">
            <label class="label label-default">Cerca paziente per nosologico</label>
            <div class="panel panel-default small">
                <div class="panel-body">
                    <div class="form-horizontal">
                        <div class="form-group form-group-sm col-sm-5">
                            <label class="control-label col-sm-6">Numero Nosologico:</label>
                            <div class="col-sm-6">
                                <asp:TextBox runat="server" ID="txtNosologico" CssClass="form-control" placeholder="Numero Nosologico" />
                            </div>
                        </div>
                        <div class="form-group form-group-sm col-sm-5">
                            <label class="control-label col-sm-6">Azienda:</label>
                            <div class="col-sm-6">
                                <asp:DropDownList ID="ddlAzienda" CssClass="form-control" runat="server" DataSourceID="odsAziende" DataTextField="Value" DataValueField="Key" AutoPostBack="true" ClientIDMode="Static">
                                </asp:DropDownList>
                                <asp:ObjectDataSource ID="odsAziende" runat="server" SelectMethod="GetAziende" TypeName="DI.OrderEntry.User.LookupManager" />
                            </div>
                        </div>
                    </div>
                    <asp:Button ID="btnCerca" Text="Cerca" runat="server" CssClass="btn btn-sm btn-primary" OnClientClick="ShowModalCaricamento();" />
                </div>
            </div>
        </div>
    </div>

    <div class="row" id="divNoRecord" runat="server" visible="false" enableviewstate="false">
        <div class="col-sm-12">
            <div class="well well-sm">Nosologico non trovato</div>
        </div>
    </div>
</asp:Content>
