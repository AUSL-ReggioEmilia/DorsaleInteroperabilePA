<%@ Page Title="Home Page" Language="VB" MasterPageFile="~/Site.Master" AutoEventWireup="false" CodeBehind="Default.aspx.vb" Inherits="SAC.RaccoltaEsenzioni._Default" %>

<%@ MasterType VirtualPath="~/Site.Master" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">


    <div id="divRicerca" class="visible" runat="server">
        <label class="h3">Raccolta delle esenzioni</label>

        <!-- Filtri -->
        <div class="row" id="pannelloFiltri" runat="server">
            <div class="col-sm-12">
                <div class="panel panel-default small">
                    <div class="panel-body">
                        <div class="form-horizontal">
                            <div class="row">
                                <div class="col-sm-5">
                                    <div class="form-group form-group-sm">
                                        <asp:Label Text="Cognome:" runat="server" AssociatedControlID="txtCognome" CssClass="control-label col-sm-5" />
                                        <div class="col-sm-7">
                                            <asp:TextBox ID="txtCognome" runat="server" CssClass="form-control" MaxLength="64" placeholder="Cognome"></asp:TextBox>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-sm-5">
                                    <div class="form-group form-group-sm">
                                        <asp:Label Text="Nome:" runat="server" AssociatedControlID="txtNome" CssClass="control-label col-sm-5" />
                                        <div class="col-sm-7">
                                            <asp:TextBox ID="txtNome" runat="server" CssClass="form-control" MaxLength="64" placeholder="Nome"></asp:TextBox>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-sm-5">
                                    <div class="form-group form-group-sm">
                                        <asp:Label Text="Anno di nascita:" runat="server" AssociatedControlID="txtAnnoNascita" CssClass="control-label col-sm-5" />
                                        <div class="col-sm-7">
                                            <asp:TextBox ID="txtAnnoNascita" runat="server" CssClass="form-control" MaxLength="4" placeholder="es: 1999"></asp:TextBox>
                                            <asp:RangeValidator ID="RangeValidator1" runat="server" ErrorMessage="Anno non valido." ControlToValidate="txtAnnoNascita"
                                                Display="Dynamic" CssClass="text-danger" EnableClientScript="true" Type="Integer" MinimumValue="1900" MaximumValue="2100" />
                                        </div>
                                    </div>
                                </div>
                                <div class="col-sm-5">
                                    <div class="form-group form-group-sm">
                                        <asp:Label Text="Codice Fiscale:" runat="server" AssociatedControlID="txtCodfisc" CssClass="control-label col-sm-5" />
                                        <div class="col-sm-7">
                                            <asp:TextBox ID="txtCodfisc" runat="server" CssClass="form-control" MaxLength="16" placeholder="Codice Fiscale"></asp:TextBox>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-sm-2">
                                    <asp:Button ID="butFiltriRicerca" runat="server" CausesValidation="true" CssClass="btn btn-primary btn-sm" Text="Cerca" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Tabella -->
        <div class="row">
            <div class="col-sm-12" id="divEmptyRow" runat="server" visible="false" enableviewstate="false">
                <div class="well well-sm">
                    Non è stato trovato nessun record. Modificare i valori di filtro!
                </div>
            </div>

            <div class="col-sm-12">
                <asp:GridView ID="gvMain" EnableViewState="false" runat="server" AllowPaging="True"
                    CssClass="table table-bordered table-striped table-condensed small" AutoGenerateColumns="False" PageSize="100" DataSourceID="odsPazienti">
                    <Columns>
                        <asp:HyperLinkField ItemStyle-CssClass="text-center" DataNavigateUrlFormatString="Esenzioni.aspx?Id={0}" DataNavigateUrlFields="Id" Text="&lt;span class='glyphicon glyphicon-folder-open' aria-hidden='true'/&gt" />
                        <asp:BoundField DataField="Cognome" HeaderText="Cognome" SortExpression="Cognome"></asp:BoundField>
                        <asp:BoundField DataField="Nome" HeaderText="Nome" SortExpression="Nome"></asp:BoundField>
                        <asp:BoundField DataField="CodiceFiscale" HeaderText="CodiceFiscale" SortExpression="CodiceFiscale"></asp:BoundField>
                        <asp:BoundField DataField="Sesso" HeaderText="Sesso" SortExpression="Sesso"></asp:BoundField>
                        <asp:BoundField DataField="DataNascita" HeaderText="DataNascita" SortExpression="DataNascita" DataFormatString="{0:d}"></asp:BoundField>
                        <asp:BoundField DataField="ComuneNascitaDescrizione" HeaderText="ComuneNascitaDescrizione" SortExpression="ComuneNascitaDescrizione"></asp:BoundField>
                    </Columns>
                </asp:GridView>
                <asp:ObjectDataSource ID="odsPazienti" runat="server" SelectMethod="PazientiCerca"
                    TypeName="SAC.RaccoltaEsenzioni.CustomDataSource" OldValuesParameterFormatString="original_{0}">
                    <SelectParameters>
                        <asp:Parameter Name="Token" Type="Object" />
                        <asp:Parameter Name="Cognome" Type="String"></asp:Parameter>
                        <asp:Parameter Name="Nome" Type="String"></asp:Parameter>
                        <asp:Parameter Name="AnnoNascita" Type="Int32"></asp:Parameter>
                        <asp:Parameter Name="CodiceFiscale" Type="String"></asp:Parameter>
                    </SelectParameters>
                </asp:ObjectDataSource>
            </div>
        </div>

    </div>

</asp:Content>
