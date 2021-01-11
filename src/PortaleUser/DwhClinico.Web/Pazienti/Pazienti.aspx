<%@ Page Language="VB" MasterPageFile="~/Portale/Default.master" AutoEventWireup="false" Inherits="DwhClinico.Web.Pazienti_Pazienti" Title="" CodeBehind="Pazienti.aspx.vb" %>

<%@ Register Src="~/UserControl/ucLegenda.ascx" TagPrefix="uc1" TagName="ucLegenda" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder" runat="Server">
    <asp:ScriptManagerProxy ID="ScriptManagerProxy" runat="server"></asp:ScriptManagerProxy>

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

    <asp:UpdateProgress ID="UpdateProgress1" AssociatedUpdatePanelID="UpdatePanelPazientiReparto" runat="server" DisplayAfter="25">
        <ProgressTemplate>
            <div class="alert alert-success" style="position: absolute; z-index: 1200; right: 10px">
                <h5><strong>Caricamento in corso...</strong></h5>
            </div>
        </ProgressTemplate>
    </asp:UpdateProgress>

    <asp:UpdatePanel ID="UpdatePanelPazientiReparto" runat="server" UpdateMode="Always">
        <ContentTemplate>

            <%-- PANNELLO RICERCA PAZIENTE --%>
            <div class="row">
                <div class="col-sm-12">
                    <label class="label label-default">Cerca paziente</label>
                    <div class="panel panel-default">
                        <div class="panel-body">
                            <div class="form-horizontal">
                                <div class="row">
                                    <div class="col-sm-4">
                                        <div class="form-group form-group-sm">
                                            <asp:Label Text="Cognome:" runat="server" AssociatedControlID="txtCognome" CssClass="control-label col-sm-5" />
                                            <div class="col-sm-7">
                                                <asp:TextBox ID="txtCognome" runat="server" CssClass="form-control" placeholder="Cognome"></asp:TextBox>
                                                <asp:RequiredFieldValidator CssClass="label label-danger" Display="Dynamic" ErrorMessage="Campo Obbligatorio" ControlToValidate="txtCognome" runat="server" />
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-sm-4">
                                        <div class="form-group form-group-sm">
                                            <asp:Label Text="Nome:" runat="server" AssociatedControlID="txtNome" CssClass="control-label col-sm-5" />
                                            <div class="col-sm-7">
                                                <asp:TextBox ID="txtNome" runat="server" CssClass="form-control" placeholder="Nome"></asp:TextBox>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-sm-4">
                                        <div class="form-group form-group-sm">
                                            <asp:Label Text="Anno di nascita:" runat="server" AssociatedControlID="txtAnnoNascita" CssClass="control-label col-sm-5" />
                                            <div class="col-sm-4">
                                                <asp:TextBox ID="txtAnnoNascita" runat="server" CssClass="form-control input-sm" MaxLength="4" placeholder="es: 1961">
                                                </asp:TextBox>
                                                <asp:RangeValidator ID="RvAnno" runat="server" ControlToValidate="txtAnnoNascita" CssClass="label label-danger"
                                                    ErrorMessage="Anno non valido" MinimumValue="1900" MaximumValue="9999"
                                                    Type="Integer" Display="Dynamic" />
                                            </div>
                                            <div class="col-sm-3">
                                                <asp:Button ID="cmdCerca" runat="server" Text="Cerca" CssClass="btn btn-primary btn-sm" />
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <%-- PANNELLO MOTIVAZIONI ACCESSO --%>
            <div class="row">
                <div class="col-sm-12">
                    <label class="label label-default">Motivo d'accesso</label>
                    <div class="panel panel-default">
                        <div class="panel-body">
                            <div class="form-horizontal">
                                <div class="row">
                                    <div class="col-sm-4">
                                        <div class="form-group form-group-sm">
                                            <asp:Label Text="Motivo dell&#39;accesso:" runat="server" AssociatedControlID="cmbMotiviAccesso" CssClass=" col-sm-5 small" />
                                            <div class="col-sm-7">
                                                <asp:DropDownList ID="cmbMotiviAccesso" runat="server" CssClass="form-control" />
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-sm-4">
                                        <div class="form-group form-group-sm">
                                            <asp:Label Text="Note sul motivo d'accesso:" runat="server" AssociatedControlID="txtMotivoAccessoNote" CssClass="col-sm-5 small" />
                                            <div class="col-sm-7">
                                                <asp:TextBox ID="txtMotivoAccessoNote" runat="server" Rows="2" onkeyup="return LimitTextareaMaxlength(this, 254);" TextMode="MultiLine" CssClass="form-control" placeholder="Note" />
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <%-- TABELLA PAZIENTI --%>
            <div class="row">
                <div class="col-sm-12">
                    <div id="divMessage" class="jumbotron message-custom-padding" runat="server" visible="false" enableviewstate="false"></div>
                    <div id="divGridView" runat="server" visible="false">
                        <%--<uc1:ucLegenda runat='server' ID='ucLegenda' />--%>
                        <div class="table-responsive">
                            <asp:GridView ID="GridViewMain" EnableViewState="false" runat="server" AllowPaging="True" AllowSorting="false" DataSourceID="DataSourcePazienti"
                                CssClass="table table-bordered table-striped table-condensed small" DataKeyNames="Id" AutoGenerateColumns="False" PageSize="100">
                                <Columns>
                                    <asp:TemplateField>
                                        <ItemTemplate>
                                            <%# GetImgPresenzaReferti(Container.DataItem) %>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField>
                                        <ItemTemplate>
                                            <%# GetImgTipoEpisodioRicovero(Container.DataItem)%>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField>
                                        <ItemTemplate>
                                            <%-- ICONA PRESENZA NOTA ANAMNESTICA --%>
                                            <%# GetImgPresenzaNoteAnamnestiche(Container.DataItem) %>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField>
                                        <ItemTemplate>
                                            <%# GetImgConsenso(Container.DataItem)%>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Paziente">
                                        <ItemTemplate>
                                            <asp:Button CommandName="1" CssClass="btn btn-link btn-xs" CommandArgument='<%# Eval("Id") %>' Text='<%# GetColumnPaziente(Container.DataItem)%>' runat="server" />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Informazioni anagrafiche">
                                        <ItemTemplate>
                                            <%# GetInformazioniAnagrafiche(Container.DataItem)%>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Episodio Attuale">
                                        <ItemTemplate>
                                            <%# GetRicovero(Container.DataItem)%>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Anteprima">
                                        <ItemTemplate>
                                            <asp:Label ID="lblAnteprima" runat="server" Text='<%# GetAnteprima(Container.DataItem)%>'></asp:Label>
                                        </ItemTemplate>
                                        <ItemStyle HorizontalAlign="Left" />
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Residenza">
                                        <ItemTemplate>
                                            <%# GetDomicilio(Container.DataItem)%>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField HeaderText="Data Decesso" DataField="DataDecesso" DataFormatString="{0:d}" />
                                    <asp:TemplateField>
                                        <ItemTemplate>
                                            <asp:LinkButton CommandName="OscuramentoPaziente" CommandArgument='<%# Eval("Id") %>' runat="server" Visible='<%# CheckDeletePermission() %>' ToolTip="Oscura paziente">
                                                 <span class="glyphicon glyphicon-remove" aria-hidden="true"></span>
                                            </asp:LinkButton>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                        </div>
                    </div>
                </div>
            </div>

            <asp:ObjectDataSource ID="DataSourcePazienti" runat="server" SelectMethod="GetData"
                TypeName="DwhClinico.Web.CustomDataSource.PazientiCercaPerGeneralita" OldValuesParameterFormatString="original_{0}">
                <SelectParameters>
                    <asp:Parameter Name="Token" Type="Object" />
                    <asp:Parameter Name="Ordinamento" Type="String"></asp:Parameter>
                    <asp:ControlParameter ControlID="txtCognome" PropertyName="Text" Name="Cognome" Type="String" />
                    <asp:ControlParameter ControlID="txtNome" Name="Nome" PropertyName="Text" Type="String" />
                    <asp:ControlParameter ControlID="txtAnnoNascita" PropertyName="Text" Name="AnnoNascita" Type="Int32"></asp:ControlParameter>
                </SelectParameters>
            </asp:ObjectDataSource>
        </ContentTemplate>
    </asp:UpdatePanel>

    <script type="text/javascript">
        //limita la lunghezza massima del testo nella textbox multiline a 254 caratteri
        function LimitTextareaMaxlength(txtBox, maxLength) {
            if (txtBox.getAttribute && txtBox.value.length > maxLength)
                txtBox.value = txtBox.value.substring(0, maxLength)
        }
    </script>
</asp:Content>

