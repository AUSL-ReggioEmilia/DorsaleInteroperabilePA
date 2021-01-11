<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="DettaglioPaziente.ascx.vb" Inherits=".DettaglioPaziente" %>

<div class="row" id="divErrore" runat="server" visible="false" enableviewstate="false">
    <div class="col-sm-12">
        <div class="alert alert-danger">
            <asp:Label ID="lblErrore" runat="server" />
        </div>
    </div>
</div>
<label class="label label-default">Dettaglio paziente</label>
<div class="well well-sm">
    <asp:FormView runat="server" DataSourceID="odsPaziente" RenderOuterTable="false">
        <ItemTemplate>
            <div class="row">
                <div class="col-sm-12">
                    <div class="form-horizontal">
                        <div class="col-sm-6">
                            <div class="form-group form-group-sm">
                                <label for="lblCognome" class="col-sm-6 control-label">Cognome</label>
                                <div class="col-sm-6">
                                    <p id="lblCognome" class="form-control-static"><%# GetCognomePaziente(Container.DataItem) %></p>
                                </div>
                            </div>
                            <div class="form-group form-group-sm">
                                <label for="lblNome" class="col-sm-6 control-label">Nome</label>
                                <div class="col-sm-6">
                                    <p id="lblNome" class="form-control-static"><%# GetNomePaziente(Container.DataItem) %></p>
                                </div>
                            </div>
                            <div class="form-group form-group-sm">
                                <label for="lblCodiceFiscale" class="col-sm-6 control-label">Codice fiscale</label>
                                <div class="col-sm-6">
                                    <p id="lblCodiceFiscale" class="form-control-static"><%# GetCodiceFiscalePaziente(Container.DataItem) %></p>
                                </div>
                            </div>
                            <div class="form-group form-group-sm">
                                <label for="lblSesso" class="col-sm-6 control-label">Sesso</label>
                                <div class="col-sm-6">
                                    <p id="lblSesso" class="form-control-static"><%# GetSessoPaziente(Container.DataItem) %></p>
                                </div>
                            </div>
                            <div class="form-group form-group-sm">
                                <label for="lblDataNascita" class="col-sm-6 control-label">Data nascita</label>
                                <div class="col-sm-6">
                                    <p id="lblDataNascita" class="form-control-static"><%# GetDataNascitaPaziente(Container.DataItem) %></p>
                                </div>
                            </div>
                            <div class="form-group form-group-sm">
                                <label for="lblComuneNascitaDesc" class="col-sm-6 control-label">Comune nascita</label>
                                <div class="col-sm-6">
                                    <p id="lblComuneNascitaDesc" class="form-control-static"><%# GeComuneNascitaPaziente(Container.DataItem) %></p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </ItemTemplate>
    </asp:FormView>
</div>

<asp:ObjectDataSource ID="odsPaziente" runat="server" OldValuesParameterFormatString="{0}" SelectMethod="GetData" TypeName="CustomDataSource.PazientiOttieniPerId">
    <SelectParameters>
        <asp:Parameter Name="Token" Type="Object"></asp:Parameter>
        <asp:Parameter DbType="Guid" Name="Id"></asp:Parameter>
    </SelectParameters>
</asp:ObjectDataSource>
