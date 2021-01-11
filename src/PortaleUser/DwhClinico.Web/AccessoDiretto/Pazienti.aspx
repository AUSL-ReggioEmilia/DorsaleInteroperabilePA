<%@ Page Language="VB" MasterPageFile="~/AccessoDiretto/AccessoDiretto.master" AutoEventWireup="false" Inherits="DwhClinico.Web.AccessoDiretto_Pazienti" Title="" CodeBehind="Pazienti.aspx.vb" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder" runat="Server">
    
      <%-- Div Errore --%>
    <asp:UpdatePanel runat="server">
        <ContentTemplate>
            <div class="row">
                <div class="col-sm-12">
                    <div runat="server" id="DivAlertMessage" class="alert alert-danger" visible="false" enableviewstate="false">
                    </div>
                </div>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>

    <div class="divPage" id="divPage" runat="server">
        <div class="row">
            <div class="col-sm-12">
                <label class="label label-default">Motivo d'accesso</label>
                <div class="panel panel-default">
                    <div class="panel-body">
                        <div class="form-horizontal">
                            <div class="row">
                                <div class="col-sm-5">
                                    <div class="form-group form-group-sm">
                                        <asp:Label Text="Motivo dell&#39;accesso:" runat="server" AssociatedControlID="cmbMotiviAccesso" CssClass=" col-sm-5 small" />
                                        <div class="col-sm-7">
                                            <asp:DropDownList ID="cmbMotiviAccesso" runat="server" CssClass="form-control" />
                                        </div>
                                    </div>
                                </div>
                                <div class="col-sm-5">
                                    <div class="form-group form-group-sm">
                                        <asp:Label Text="Note sul motivo d'accesso:" runat="server" AssociatedControlID="txtMotivoAccessoNote" CssClass="col-sm-5 small" />
                                        <div class="col-sm-7">
                                            <asp:TextBox ID="txtMotivoAccessoNote" runat="server" Rows="2" TextMode="MultiLine" onkeyup="return LimitTextareaMaxlength(this, 254);" CssClass="form-control" placeholder="Note" />
                                        </div>
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
                <div id="divMessage" class="jumbotron message-custom-padding" runat="server" visible="false" enableviewstate="false"></div>
                <asp:GridView ID="WebGridPazienti" runat="server" AllowPaging="True" AllowSorting="false" DataSourceID="PazientiDataSource"
                    CssClass="table table-bordered table-striped table-condensed small" DataKeyNames="Id" AutoGenerateColumns="False" PageSize="100">
                    <Columns>
                        <asp:TemplateField>
                            <ItemTemplate>
                                <%# GetImgPresenzaReferti(Container.DataItem) %>
                            </ItemTemplate>
                            <ItemStyle HorizontalAlign="Center" />
                        </asp:TemplateField>
                        <asp:TemplateField>
                            <ItemTemplate>
                                <%# GetImgTipoEpisodioRicovero(Container.DataItem)%>
                            </ItemTemplate>
                            <ItemStyle HorizontalAlign="Center" />
                        </asp:TemplateField>
                        <asp:TemplateField>
                            <ItemTemplate>
                                <%-- ICONA PRESENZA NOTA ANAMNESTICA --%>
                                <%# GetImgPresenzaNoteAnamnestiche(Container.DataItem) %>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderStyle-Width="2%" ItemStyle-Width="2%">
                            <ItemTemplate>
                                <%# GetImgConsenso(Container.DataItem)%>
                            </ItemTemplate>
                            <ItemStyle HorizontalAlign="Center" />
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Paziente" SortExpression="Cognome">
                            <ItemTemplate>
                                <asp:Button CommandName="1" CssClass="btn btn-link btn-xs" CommandArgument='<%# Eval("Id") %>' Text='<%# GetColumnPaziente(Container.DataItem)%>' runat="server" />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Informazioni anagrafiche" SortExpression="DataNascita">
                            <ItemTemplate>
                                <%# GetInformazioniAnagrafiche(Container.DataItem)%>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Episodio Attuale" SortExpression="DataAperturaEpisodio">
                            <ItemTemplate>
                                <%# GetRicovero(Container.DataItem)%>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Anteprima">
                            <ItemTemplate>
                                <asp:Label ID="Label1" runat="server" Text='<%# GetAnteprima(Container.DataItem)%>'></asp:Label>
                            </ItemTemplate>
                            <ItemStyle HorizontalAlign="Left" />
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Domicilio">
                            <ItemTemplate>
                                <%# GetDomicilio(Container.DataItem)%>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField HeaderText="Data Decesso" DataField="DataDecesso" DataFormatString="{0:d}" SortExpression="DataDecesso" />
                    </Columns>
                </asp:GridView>

            </div>
        </div>
    </div>

    <asp:ObjectDataSource ID="PazientiDataSource" EnableCaching="false" runat="server" OldValuesParameterFormatString="original_{0}" SelectMethod="GetData" TypeName="DwhClinico.Web.CustomDataSource.AccessoDirettoPazientiCerca">
        <SelectParameters>
            <asp:Parameter Name="Token" Type="Object"></asp:Parameter>
            <asp:Parameter Name="Ordinamento" Type="String"></asp:Parameter>
            <asp:Parameter Name="Cognome" Type="String"></asp:Parameter>
            <asp:Parameter Name="Nome" Type="String"></asp:Parameter>
            <asp:Parameter Name="DataNascita" Type="DateTime"></asp:Parameter>
            <asp:Parameter Name="CodiceFiscale" Type="String"></asp:Parameter>
            <asp:Parameter Name="CodiceSanitario" Type="String"></asp:Parameter>
        </SelectParameters>
    </asp:ObjectDataSource>
</asp:Content>
