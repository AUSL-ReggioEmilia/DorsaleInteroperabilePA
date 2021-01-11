<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Portale/Default.master" CodeBehind="GestioneConsensi.aspx.vb" Inherits="DwhClinico.Web.GestioneConsensi" %>

<%@ Register Src="~/UserControl/ucTestataPaziente.ascx" TagPrefix="uc1" TagName="ucTestataPaziente" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder" runat="server">
    <div class="row">
        <div class="col-sm-12">
            <div class="alert alert-danger dfsdf" id="alertErrorMessage" visible="false" runat="server" enableviewstate="false">
                <asp:Label ID="lblErrorMessage" runat="server" CssClass="text-danger" EnableViewState="False"></asp:Label>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="col-sm-12">
            <asp:LinkButton CssClass="btn btn-primary btn-sm pull-right" ID="cmdEsci" runat="server">
                 Torna indietro
            </asp:LinkButton>
        </div>
    </div>

    <uc1:ucTestataPaziente runat="server" ID="ucTestataPaziente" />

    <div class="row">
        <div class="col-sm-12">
            <div class="well well-sm" id="divNoRecordFound" runat="server"></div>
        </div>
    </div>

    <div class="row small">
        <div class="col-sm-12">
            <div class="table-responsive">
                <asp:GridView ID="GridViewConsensiSAC" runat="server" AutoGenerateColumns="False"
                    DataSourceID="ConsensiSACDataSource" CssClass="table table-bordered table-striped table-condensed"
                    AllowPaging="True">
                    <Columns>
                        <asp:TemplateField HeaderStyle-Width="3%">
                            <ItemTemplate>
                                <asp:Button CssClass="btn btn-danger btn-xs btn-block" Text="Nega" CommandArgument='<%# String.Format("{0},{1}", Eval("Tipo"), Eval("Stato")) %>' CommandName="Nega" runat="server" Visible='<%# VisibilitaNegazioneConsenso(Container.DataItem) %>' />
                                <asp:Button CssClass="btn btn-success btn-xs btn-block" Text="Concedi" CommandArgument='<%# String.Format("{0},{1}", Eval("Tipo"), Eval("Stato")) %>' CommandName="Concedi" runat="server" Visible='<%# VisibilitaConcessioneConsenso(Container.DataItem) %>' />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Tipo consenso">
                            <ItemTemplate>
                                <%# GetColTipoConsenso(Eval("Tipo")) %>
                            </ItemTemplate>
                        </asp:TemplateField>
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
            <%-- BUTTON PER RESETTARE I CONSENSI--%>
            <asp:LinkButton ID="cmdCancellaConsensi" CssClass="btn btn-primary btn-sm" OnClientClick="return confirm('Si conferma di voler resettare i consensi per il paziente corrente?');" runat="server">
                      Cancella Consensi
            </asp:LinkButton>
            
        </div>
    </div>

    <%-- MODALE MODIFICA CONSENSO --%>
    <div class="modal fade" id="ModaleModificaConsenso" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <asp:UpdatePanel UpdateMode="Always" runat="server">
                    <ContentTemplate>
                        <div class="modal-header">
                            <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                            <div class="h4 modal-title" id="PageTitle" runat="server">
                            </div>
                        </div>
                        <div class="modal-body">
                            <asp:Label ID="lblErrore" runat="server" CssClass="errore" EnableViewState="False"></asp:Label>
                            <div class="form-horizontal">
                                <div class="form-group form-group-sm">
                                    <label for="lblUtenteNome" class="col-sm-4 control-label">Nome Utente:</label>
                                    <div class="col-sm-8">
                                        <asp:Label CssClass="col-sm-12" ID="lblUtenteNome" runat="server" />
                                    </div>
                                </div>
                                <div class="form-group form-group-sm">
                                    <label for="cboConsenso" class="col-sm-4 control-label">Consenso:</label>
                                    <div class="col-sm-8">
                                        <asp:DropDownList EnableViewState="false" ID="cboStatoConsenso" CssClass="form-control" runat="server" AutoPostBack="true">
                                            <asp:ListItem Value="1">Positivo</asp:ListItem>
                                            <asp:ListItem Value="0">Negativo</asp:ListItem>
                                        </asp:DropDownList>
                                    </div>
                                </div>
                                <div id="trUtenteAutorizzatoreTitle" runat="server">
                                    <hr />
                                    <h4>RILEVAZIONE CONSENSO MINORE </h4>
                                    <p class="help-block">Inserire le generalità del Genitore/Tutore Legale</p>
                                </div>
                                <div class="form-group form-group-sm" id="trUtenteAutorizzatoreRelazioneColMinore" runat="server">
                                    <label for="cmbAutorizzatoreMinoreRelazioneColMinore" class="col-sm-4 control-label">Relazione col minore:</label>
                                    <div class="col-sm-8">
                                        <asp:DropDownList placeholder="Relazione col minore" ID="cmbAutorizzatoreMinoreRelazioneColMinore" runat="server" class="form-control">
                                        </asp:DropDownList>
                                    </div>
                                </div>
                                <div class="form-group form-group-sm" id="trUtenteAutorizzatoreCognome" runat="server">
                                    <label for="txtAutorizzatoreMinoreCognome" class="col-sm-4 control-label">Cognome:</label>
                                    <div class="col-sm-8">
                                        <asp:TextBox placeholder="Cognome" ID="txtAutorizzatoreMinoreCognome" runat="server" class="form-control" ValidationGroup="modaleValidator"></asp:TextBox>
                                        <asp:RequiredFieldValidator ID="ReqAutorizzatoreMinoreCognome" CssClass="label label-danger" runat="server"
                                            ErrorMessage="Campo Obbligatorio" Display="Dynamic" ControlToValidate="txtAutorizzatoreMinoreCognome" ValidationGroup="modaleValidator" />
                                    </div>
                                </div>
                                <div class="form-group form-group-sm" id="trUtenteAutorizzatoreNome" runat="server">
                                    <label for="txtAutorizzatoreMinoreNome" class="col-sm-4 control-label">Nome:</label>
                                    <div class="col-sm-8">
                                        <asp:TextBox placeholder="Nome" ID="txtAutorizzatoreMinoreNome" runat="server" class="form-control"></asp:TextBox>
                                        <asp:RequiredFieldValidator ID="ReqAutorizzatoreMinoreNome" CssClass="label label-danger" runat="server"
                                            ErrorMessage="Campo Obbligatorio" Display="Dynamic" ControlToValidate="txtAutorizzatoreMinoreNome" ValidationGroup="modaleValidator" />
                                    </div>
                                </div>
                                <div class="form-group form-group-sm" id="trUtenteAutorizzatoreDataNascita" runat="server">
                                    <label for="txtAutorizzatoreDataNascita" class="col-sm-4 control-label">Data nascita:</label>
                                    <div class="col-sm-8">
                                        <asp:TextBox placeholder="es: 22/11/1996" ID="txtAutorizzatoreDataNascita" runat="server" MaxLength="10" class="form-control"></asp:TextBox>

                                        <asp:RequiredFieldValidator ID="ReqAutorizzatoreDataNascita" CssClass="label label-danger" runat="server"
                                            ErrorMessage="Campo Obbligatorio" Display="Dynamic" ControlToValidate="txtAutorizzatoreDataNascita" ValidationGroup="modaleValidator" />
                                        <asp:RangeValidator ID="RangeValAutorizzatoreDataNascita" Type="Date" MinimumValue="1900-01-01"
                                            MaximumValue="3000-01-01" ControlToValidate="txtAutorizzatoreDataNascita" CssClass="label label-danger"
                                            runat="server" ErrorMessage="Inserire una data valida" Display="Dynamic" ValidationGroup="modaleValidator"></asp:RangeValidator>
                                    </div>
                                </div>
                                <div class="form-group form-group-sm" id="trUtenteAutorizzatoreLuogoNascita" runat="server">
                                    <label for="txtAutorizzatoreLuogoNascita" class="col-sm-4 control-label">Luogo di nascita:</label>
                                    <div class="col-sm-8">
                                        <asp:TextBox placeholder="Luogo di nascita" ID="txtAutorizzatoreLuogoNascita" runat="server" class="form-control"></asp:TextBox>
                                        <asp:RequiredFieldValidator ID="ReqAutorizzatoreLuogoNascita" CssClass="label label-danger" runat="server"
                                            ErrorMessage="Campo Obbligatorio" Display="Dynamic" ControlToValidate="txtAutorizzatoreLuogoNascita" ValidationGroup="modaleValidator" />
                                    </div>
                                </div>
                            </div>
                        </div>
                    </ContentTemplate>
                </asp:UpdatePanel>
                <div class="modal-footer">
                    <asp:Button ID="cmdSalvaConsenso" runat="server" CausesValidation="true" Text="Conferma" ValidationGroup="modaleValidator" CssClass="btn btn-primary btn-sm"></asp:Button>
                    <button type="button" name="cmdInformativa" id="cmdInformativa"
                        runat="server" class="btn btn-default btn-sm">
                        <span class="glyphicon glyphicon-info-sign text-info" aria-hidden="true"></span>
                        Apri Informativa
                    </button>
                    <asp:Button ID="cmdAcquisizioneConsensoAnnulla" class="btn btn-default btn-sm" Text="Annulla" runat="server" />
                </div>
            </div>
        </div>
    </div>

    <asp:ObjectDataSource ID="ConsensiSACDataSource" runat="server" SelectMethod="GetData"
        TypeName="DwhClinico.Web.CustomDataSource.ListaConsensi" OldValuesParameterFormatString="original_{0}" CacheKeyDependency="CKD_ConsensiSACDataSource">
        <SelectParameters>
            <asp:Parameter Name="sIdPazienteSAC" Type="String" />
        </SelectParameters>
    </asp:ObjectDataSource>
</asp:Content>
