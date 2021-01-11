<%@ Page Language="VB" MasterPageFile="~/Portale/Default.master" AutoEventWireup="false" Inherits="DwhClinico.Web.Pazienti_PazientiConsensoSac"
    Title="" CodeBehind="PazientiConsensoSac.aspx.vb" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder" runat="Server">
    <div class="row">
        <div class="col-sm-12">
            <div class="alert alert-danger" id="alertErrorMessage" runat="server" visible="false" enableviewstate="false">
                <asp:Label ID="lblErrorMessage" runat="server" CssClass="text-danger" EnableViewState="False"></asp:Label>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="col-sm-12">
            <div id="divPaziente" runat="server" class="panel panel-default">
                <div class="panel-heading">
                    Paziente
                </div>
                <div class="panel-body">
                    <div class="form">
                        <div class="row">
                            <div class="col-sm-6">
                                <div class="form-group">
                                    <asp:Label Text="Cognome:" runat="server" AssociatedControlID="lblCognome" CssClass="col-sm-6" />
                                    <asp:Label ID="lblCognome" runat="server" Text='<%# DataBinder.Eval(moSacDettaglioPaziente, "Cognome") %>'>
                                    </asp:Label>
                                </div>
                            </div>
                            <div class="col-sm-6">
                                <div class="form-group">
                                    <asp:Label Text="Nome:" runat="server" AssociatedControlID="lblNome" CssClass="col-sm-6" />
                                    <asp:Label ID="lblNome" runat="server" Text='<%# DataBinder.Eval(moSacDettaglioPaziente, "Nome") %>'>
                                    </asp:Label>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-sm-6">
                                <div class="form-group">
                                    <asp:Label Text="Data di nascita:" runat="server" AssociatedControlID="lblDataNascita" CssClass="col-sm-6" />
                                    <asp:Label ID="lblDataNascita" runat="server" Text='<%# DataBinder.Eval(moSacDettaglioPaziente, "DataNascita", "{0:d}") %>'>
                                    </asp:Label>
                                </div>
                            </div>
                            <div class="col-sm-6">
                                <div class="form-group">
                                    <asp:Label Text="Luogo di nascita:" runat="server" AssociatedControlID="lblLuogoNascita" CssClass="col-sm-6" />
                                    <asp:Label ID="lblLuogoNascita" runat="server" Text='<%# DataBinder.Eval(moSacDettaglioPaziente, "LuogoNascita") %>'>
                                    </asp:Label>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-sm-6">
                                <div class="form-group">
                                    <asp:Label Text="Codice fiscale:" runat="server" AssociatedControlID="lblCodiceFiscale" CssClass="col-sm-6" />
                                    <asp:Label ID="lblCodiceFiscale" runat="server" Text='<%# DataBinder.Eval(moSacDettaglioPaziente, "CodiceFiscale") %>'>
                                    </asp:Label>
                                </div>
                            </div>
                            <div class="col-sm-6">
                                <div class="form-group">
                                    <asp:Label Text="Codice sanitario:" runat="server" AssociatedControlID="lblCodiceSanitario" CssClass="col-sm-6" />
                                    <asp:Label ID="lblCodiceSanitario" runat="server" Text='<%# DataBinder.Eval(moSacDettaglioPaziente, "CodiceSanitario") %>'>
                                    </asp:Label>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-sm-6">
                                <div class="form-group">
                                    <asp:Label ID="lblDataDecessoDesc" runat="server" AssociatedControlID="lblDataDecesso" CssClass="col-sm-6" Text="Data decesso:" Visible='<%# LabelDataDecessoVisible(DataBinder.Eval(moSacDettaglioPaziente, "DataDecesso")) %>'></asp:Label>
                                    <asp:Label ID="lblDataDecesso" runat="server" Text='<%# DataBinder.Eval(moSacDettaglioPaziente, "DataDecesso", "{0:d}") %>'></asp:Label>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="col-sm-12">
            <asp:Label ID="lblNoRecordFound" runat="server" EnableViewState="False"></asp:Label>
        </div>
    </div>

    <div class="row">
        <div class="col-sm-12">
            <div class="table-responsive">
                <asp:GridView ID="GridViewConsensiSAC" runat="server" AutoGenerateColumns="False"
                    DataSourceID="ConsensiSACDataSource" CssClass="table table-bordered table-striped table-condensed"
                    AllowPaging="True">
                    <Columns>
                        <asp:BoundField DataField="Tipo" HeaderText="Tipo consenso" SortExpression="Tipo" />
                        <asp:TemplateField HeaderText="Stato consenso">
                            <ItemTemplate>
                                <%# GetColConsenso(Eval("Stato")) %>
                            </ItemTemplate>
                            <ItemStyle HorizontalAlign="Center" />
                        </asp:TemplateField>
                        <asp:BoundField DataField="DataStato" HeaderText="Data" SortExpression="DataStato"
                            DataFormatString="{0:g}" />
                        <asp:BoundField DataField="OperatoreId" HeaderText="Operatore: Account" SortExpression="OperatoreId" />
                        <asp:BoundField DataField="OperatoreCognome" HeaderText="Operatore: Cognome" SortExpression="OperatoreCognome" />
                        <asp:BoundField DataField="OperatoreNome" HeaderText="Operatore: Nome" SortExpression="OperatoreNome" />
                        <asp:BoundField DataField="OperatoreComputer" HeaderText="Operatore: Computer" SortExpression="OperatoreComputer" />
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="col-sm-12">
            <div class="text-right">
                <asp:Button ID="cmdAnnulla" runat="server" Text="Esci" CssClass="btn btn-primary btn-sm" />
            </div>
        </div>
    </div>

    <asp:ObjectDataSource ID="ConsensiSACDataSource" runat="server" SelectMethod="GetListaConsensi"
        TypeName="DwhClinico.Web.ConsensiSac" OldValuesParameterFormatString="original_{0}" CacheKeyDependency="CKD_ConsensiSACDataSource">
        <SelectParameters>
            <asp:Parameter Name="sIdPazienteSAC" Type="String" />
        </SelectParameters>
    </asp:ObjectDataSource>


</asp:Content>
