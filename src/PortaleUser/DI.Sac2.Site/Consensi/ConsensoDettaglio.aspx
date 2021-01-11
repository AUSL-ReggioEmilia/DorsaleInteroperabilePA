<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master"
    CodeBehind="ConsensoDettaglio.aspx.vb" Inherits="DI.Sac.User.ConsensoDettaglio" %>

<%@ MasterType VirtualPath="~/Site.Master" %>


<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">
    <div class="row" id="ToolbarTable" runat="server">
        <div class="col-sm-12">
            <div class="well well-sm">
                <asp:HyperLink ID="lnkIndietro" CssClass="btn btn-primary btn-sm" runat="server" NavigateUrl="~/Pazienti/PazienteDettaglio.aspx?id={0}">
                    <span class="glyphicon glyphicon-chevron-left" aria-hidden="true"></span>&nbsp;Indietro
                </asp:HyperLink>
            </div>
        </div>
    </div>



    <label class="label label-default">Dettaglio Consenso</label>
    <div class="well well-sm">
        <div class="row">
            <div class="col-sm-12 col-md-8">
                <asp:FormView ID="fvConsenso" runat="server" DataSourceID="odsConsenso" RenderOuterTable="false" DataKeyNames="Id" DefaultMode="ReadOnly">
                    <ItemTemplate>
                        <div class="form-horizontal">
                            <div class="col-sm-6">
                            <div class="form-group  form-group-sm">
                                <label for="ProvenienzaLable" class="col-sm-6 control-label">Provenienza</label>
                                <div class="col-sm-6">
                                    <p class="form-control-static"><%# Eval("Provenienza") %></p>
                                </div>
                            </div>
<%--                            <div class="form-group  form-group-sm">
                                <label for="IdProvenienzaLabel" class="col-sm-6 control-label">IdProvenienza</label>
                                <div class="col-sm-6">
                                    <p class="form-control-static"><%# Eval("IdProvenienza") %></p>
                                </div>
                            </div>--%>
                            <div class="form-group form-group-sm">
                                <label for="TipoNomeLabel" class="col-sm-6 control-label">Tipo</label>
                                <div class="col-sm-6">
                                    <p class="form-control-static"><%# Eval("Tipo") %></p>
                                </div>
                            </div>
                            <div class="form-group form-group-sm ">
                                <label for="DataStatoLabel" class="col-sm-6 control-label">Data</label>
                                <div class="col-sm-6">
                                    <p class="form-control-static"><%# String.Format("{0:d}", Eval("DataStato")) %></p>
                                </div>
                            </div>
                            <div class="form-group form-group-sm">
                                <label for="StatoCheckBox" class="col-sm-6 control-label">Stato</label>
                                <div class="col-sm-6">
                                    <asp:CheckBox ID="CheckBox1" disabled="disabled" runat="server" Checked='<%# Eval("Stato") %>' Enabled="false" />
                                </div>
                            </div>
                            <div class="form-group form-group-sm">
                                <label for="OperatoreNomeLabel" class="col-sm-6 control-label">Cognome Operatore</label>
                                <div class="col-sm-6">
                                    <p class="form-control-static"><%# GetOperatoreCognome(Container.DataItem) %></p>
                                </div>
                            </div>
                            <div class="form-group form-group-sm">
                                <label for="OperatoreComputerLabel" class="col-sm-6 control-label">Nome Operatore</label>
                                <div class="col-sm-6">
                                    <p class="form-control-static"><%# GetOperatoreNome(Container.DataItem) %></p>
                                </div>
                            </div>
                            <div class="form-group form-group-sm">
                                <label for="OperatoreComputerLabel" class="col-sm-6 control-label">Computer Operatore</label>
                                <div class="col-sm-6">
                                    <p class="form-control-static"><%# GetOperatoreComputer(Container.DataItem) %></p>
                                </div>
                            </div>
                            <div class="form-group form-group-sm">
                                <label for="AttributiLabel" class="col-sm-6 control-label">Attributi</label>
                                <div class="col-sm-6">
                                    <p class="form-control-static"><%# ShowAttributi(Eval("Attributi")) %></p>
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:FormView>
            </div>
        </div>
    </div>




    <asp:ObjectDataSource ID="odsConsenso" runat="server" OldValuesParameterFormatString="{0}" SelectMethod="GetData" TypeName="CustomDataSource.ConsensoPaziente">
        <SelectParameters>
            <asp:Parameter Name="Token" Type="Object"></asp:Parameter>
            <asp:QueryStringParameter QueryStringField="IdPaziente" DbType="Guid" DefaultValue="" Name="IdPaziente"></asp:QueryStringParameter>
            <asp:QueryStringParameter QueryStringField="IdConsenso" DbType="Guid" Name="IdConsenso"></asp:QueryStringParameter>
        </SelectParameters>
    </asp:ObjectDataSource>
</asp:Content>
