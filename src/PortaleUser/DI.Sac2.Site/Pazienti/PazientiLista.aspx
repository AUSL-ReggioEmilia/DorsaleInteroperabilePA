<%@ Page Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="PazientiLista.aspx.vb"
    Inherits="DI.Sac.User.PazientiLista" Title="Untitled Page" %>


<%@ MasterType VirtualPath="~/Site.Master" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">

    <!-- 
        Filtri della pagina 
    -->
    <div class="row" runat="server" id="pannelloFiltri">
        <div class="col-sm-12">
            <div class="panel panel-default">
                <div class="panel-body">
                    <div class="form-horizontal">
                        <div class="row">
                            <div class="col-sm-4">
                                <div class="form-group form-group-sm">
                                    <asp:Label Text="Cognome:" runat="server" AssociatedControlID="txtCognome" CssClass="control-label col-sm-5" />
                                    <div class="col-sm-7">
                                        <asp:TextBox autocomplete="off" ID="txtCognome" runat="server" CssClass="form-control" placeholder="Cognome (Inizia con)"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                            <div class="col-sm-4">
                                <div class="form-group form-group-sm">
                                    <asp:Label Text="Nome:" runat="server" AssociatedControlID="txtNome" CssClass="control-label col-sm-5" />
                                    <div class="col-sm-7">
                                        <asp:TextBox autocomplete="off" ID="txtNome" runat="server" CssClass="form-control" placeholder="Nome (Inizia con)"></asp:TextBox>
                                    </div>
                                </div>
                            </div>

                            <div class="col-sm-4">
                                <div class="form-group form-group-sm">
                                    <asp:Label Text="Codice Fiscale:" runat="server" AssociatedControlID="txtCodiceFiscale" CssClass="control-label col-sm-5" />
                                    <div class="col-sm-7">
                                        <asp:TextBox autocomplete="off" ID="txtCodiceFiscale" runat="server" CssClass="form-control" placeholder="Codice Fiscale"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-sm-4">
                                <div class="form-group form-group-sm">
                                    <asp:Label Text="Anno di nascita:" runat="server" AssociatedControlID="txtAnnoNascita" CssClass="control-label col-sm-5" />
                                    <div class="col-sm-7">
                                        <asp:TextBox autocomplete="off" ID="txtAnnoNascita" runat="server" CssClass="form-control" MaxLength="4" placeholder="Anno di nascita"></asp:TextBox>
                                        <asp:CompareValidator ID="cvalDataNascita" runat="server" ControlToValidate="txtAnnoNascita" CssClass="text-danger small"
                                            ErrorMessage="Valore non valido" Display="Dynamic"
                                            Operator="DataTypeCheck" Type="Integer"></asp:CompareValidator>
                                    </div>
                                </div>
                            </div>
                            <div class="col-sm-4">
                                <div class="form-group form-group-sm">
                                    <asp:Label Text="Cognome Medico:" runat="server" AssociatedControlID="txtCognomeMedico" CssClass="control-label col-sm-5" />
                                    <div class="col-sm-7">
                                        <asp:TextBox autocomplete="off" ID="txtCognomeMedico" runat="server" CssClass="form-control" placeholder="Cognome Medico (inizia con)"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                            <div class="col-sm-4">
                                <div class="form-group form-group-sm">
                                    <asp:Label Text="Nome Medico:" runat="server" AssociatedControlID="txtNomeMedico" CssClass="control-label col-sm-5" />
                                    <div class="col-sm-7">
                                        <asp:TextBox autocomplete="off" ID="txtNomeMedico" runat="server" CssClass="form-control" placeholder="Nome Medico (inizia con)"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-sm-4">
                                <div class="form-group form-group-sm">
                                    <asp:Label Text="Comune residenza:" runat="server" AssociatedControlID="txtComuneResidenza" CssClass="control-label col-sm-5" />
                                    <div class="col-sm-7">
                                        <asp:TextBox autocomplete="off" ID="txtComuneResidenza" runat="server" CssClass="form-control" placeholder="Comune residenza (inizia con)"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
							 <div class="col-sm-4">
                                <div class="form-group form-group-sm">
                                    <asp:Label Text="Id SAC:" runat="server" AssociatedControlID="txtIdSac" CssClass="control-label col-sm-5" />
                                    <div class="col-sm-7">
                                        <asp:TextBox autocomplete="off" ID="txtIdSac" runat="server" CssClass="form-control" placeholder="Inserire l'id Sac"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                            <div class="col-sm-2">
                                <asp:Button ID="btnRicerca" runat="server" CssClass="btn btn-primary btn-sm" Text="Cerca" />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- 
       Tabella
    -->
    <div class="row">
        <div class="col-sm-12" id="divEmptyRow" runat="server" visible="false">
            <div class="well well-sm">
                Non è stato trovato nessun record. Modificare i valori di filtro!
            </div>
        </div>

        <div class="col-sm-12">
            <div class="table-responsive small">
                <asp:GridView ID="gvPazienti" CssClass="table table-bordered table-condensed table-striped" runat="server" AllowPaging="True" AllowSorting="True"
                    AutoGenerateColumns="False" DataSourceID="odsLista"
                    EmptyDataText="Nessun risultato!" GridLines="Horizontal" ClientIDMode="Static"
                    PageSize="100" DataKeyNames="Id">
                    <Columns>
                        <asp:HyperLinkField DataTextField="Cognome" DataNavigateUrlFormatString="PazienteDettaglio.aspx?id={0}"
                            DataNavigateUrlFields="Id" HeaderText="Cognome" SortExpression="Cognome" />
                        <asp:BoundField DataField="Nome" HeaderText="Nome" SortExpression="Nome" />
                        <asp:BoundField DataField="DataNascita" HeaderText="Data Nascita" SortExpression="DataNascita"
                            DataFormatString="{0:d}" HtmlEncode="False" />
                        <asp:BoundField DataField="Sesso" HeaderText="Sesso" SortExpression="Sesso" />
                        <asp:BoundField DataField="CodiceFiscale" HeaderText="Codice Fiscale" SortExpression="CodiceFiscale" />
                        <asp:BoundField DataField="DataDecesso" HeaderText="Data Decesso" SortExpression="DataDecesso"
                            DataFormatString="{0:d}" HtmlEncode="False" />
                        <%--                       <asp:TemplateField HeaderText="Provenienza" SortExpression="Provenienza">
                            <ItemTemplate>
                                <b>
                                    <%# String.Format("{0} ({1})", Eval("Provenienza"), Eval("IdProvenienza")) %></b><br />
                                <%# Eval("ProvenienzaFuse") %>
                            </ItemTemplate>
                        </asp:TemplateField>--%>
                    </Columns>
                    <%--                    <EmptyDataRowStyle CssClass="empty-row-style" />
                    <EmptyDataTemplate>
                        <div class="well well-sm">
                            Nessun risultato! Modificare i valori di filtro.
                        </div>
                    </EmptyDataTemplate>--%>
                </asp:GridView>
            </div>
        </div>
    </div>

    <asp:ObjectDataSource ID="odsLista" runat="server" SelectMethod="GetData" TypeName="CustomDataSource.PazientiCerca" OldValuesParameterFormatString="{0}">
        <SelectParameters>
            <asp:Parameter Name="Token" Type="Object"></asp:Parameter>
            <asp:Parameter Name="Ordinamento" Type="String"></asp:Parameter>
            <asp:Parameter Name="MedicoDiBaseCodiceFiscale" Type="String"></asp:Parameter>
            <asp:Parameter Name="Cognome" Type="String"></asp:Parameter>
            <asp:Parameter Name="Nome" Type="String"></asp:Parameter>
            <asp:Parameter Name="DataNascita" Type="DateTime"></asp:Parameter>
            <asp:Parameter Name="LuogoNascita" Type="String"></asp:Parameter>
            <asp:Parameter Name="CodiceFiscale" Type="String"></asp:Parameter>
            <asp:Parameter Name="TesseraSanitaria" Type="String"></asp:Parameter>
            <asp:Parameter Name="AnnoNascita" Type="Int32"></asp:Parameter>
            <asp:Parameter Name="ComuneResidenzaNome" Type="String"></asp:Parameter>
            <asp:Parameter Name="MedicoDiBaseCognome" Type="String"></asp:Parameter>
            <asp:Parameter Name="MedicoDiBaseNome" Type="String"></asp:Parameter>
        </SelectParameters>
    </asp:ObjectDataSource>

</asp:Content>
