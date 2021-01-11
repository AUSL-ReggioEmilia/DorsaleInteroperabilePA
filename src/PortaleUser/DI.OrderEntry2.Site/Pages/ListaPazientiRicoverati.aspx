<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Site.Master" CodeBehind="ListaPazientiRicoverati.aspx.vb" EnableEventValidation="true"
    Inherits="DI.OrderEntry.User.ListaPazientiRicoverati" %>

<%@ MasterType VirtualPath="~/Site.Master" %>
<%@ Register Src="~/UserControl/UcToolbar.ascx" TagPrefix="uc1" TagName="UcToolbar" %>
<%@ Register Src="~/UserControl/UcWizard.ascx" TagPrefix="uc1" TagName="UcWizard" %>


<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolderMain" runat="server">

    <div class="row" id="divErrorMessage" runat="server" visible="false" enableviewstate="false">
        <div class="col-sm-12">
            <div class="alert alert-danger">
                <asp:Label ID="lblError" runat="server" CssClass="Error text-danger" EnableViewState="false" />
            </div>
        </div>
    </div>
	<uc1:UcWizard runat="server" ID="UcWizard"  CurrentStep="1"/>
    <div class="row" id="divSuperati100Risultati" runat="server" visible="false" enableviewstate="false">
		<div class="col-sm-12">
			<div class="alert alert-danger">
				<asp:Label ID="Label1" runat="server" CssClass="Error text-danger" EnableViewState="false" Text="La ricerca ha prodotto più di 100 risultati, ne sono stati mostrati solo i primi 100. Si prega di inserire ulteriori parametri di ricerca." />
			</div>
		</div>
	</div>

    <!--filtri-->
    <div class="row">
        <div class="col-sm-12">
            <div id="pannelloFiltriRicoverati" runat="server">
                <label class="label label-default">Ricerca</label>
                <div class="panel panel-default">
                    <div class="panel-body">
                        <div class="form-horizontal">
                            <div class="row">
                                <div class="col-sm-6">
                                    <div class="form-group form-group-sm">
                                        <asp:Label runat="server" ID="lblCognomeRicoverati" AssociatedControlID="txtCognomeRicoverati" CssClass=" col-sm-3 control-label">Cognome</asp:Label>
                                        <div class="col-sm-6">
                                            <asp:TextBox runat="Server" AutoComplete="off" ID="txtCognomeRicoverati" CssClass="form-control" placeholder="Cognome (Inizia con)" />
                                        </div>
                                    </div>
                                </div>
                                <div class="col-sm-6">
                                    <div class="form-group form-group-sm">
                                        <asp:Label runat="server" ID="lblNomeRicoverati" AssociatedControlID="txtNomeRicoverati" CssClass="control-label  col-sm-3">Nome</asp:Label>
                                        <div class="col-sm-6">
                                            <asp:TextBox runat="Server" AutoComplete="off" ID="txtNomeRicoverati" CssClass="form-control" placeholder="Nome (Inizia con)" />
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <asp:UpdatePanel ID="updDdl" runat="server">
								<ContentTemplate>
							<div class="row">
                                <div class="col-sm-6">
                                    <div class="form-group form-group-sm">
                                        <asp:Label runat="server" ID="UOLabel" AssociatedControlID="ddlUO" CssClass="control-label  col-sm-3">Unità operativa</asp:Label>
                                        <div class="col-sm-6">
                                            <asp:DropDownList ID="ddlUO" runat="server" DataSourceID="odsUo" DataTextField="DescrizioneUO"
                                                DataValueField="CodiceUO" AppendDataBoundItems="true" CssClass="form-control" AutoPostBack="true">
                                                <asp:ListItem Text="Tutte le Unità Operative" Value="*-*"></asp:ListItem>
                                            </asp:DropDownList>
                                            <asp:ObjectDataSource ID="odsUo" runat="server" OldValuesParameterFormatString="{0}" SelectMethod="GetData"
                                                TypeName="CustomDataSource+UnitaOperative"></asp:ObjectDataSource>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-sm-6">
                                    <div class="form-group form-group-sm">
                                        <asp:Label runat="server" ID="lblTipoRicovero" AssociatedControlID="ddlTipoRicovero" CssClass="control-label  col-sm-3">Tipo ricovero</asp:Label>
                                        <div class="col-sm-6">
                                            <asp:DropDownList ID="ddlTipoRicovero" runat="server" DataSourceID="odsTipoRicovero" DataTextField="Descrizione"
                                                DataValueField="Codice" AppendDataBoundItems="false" CssClass="form-control">
                                                <asp:ListItem Text="Tutte le Unità Operative" Value="*-*"></asp:ListItem>
                                            </asp:DropDownList>
                                            <asp:ObjectDataSource ID="odsTipoRicovero" runat="server" OldValuesParameterFormatString="{0}" SelectMethod="GetData" TypeName="CustomDataSource+Ricoveri">
                                                <SelectParameters>
                                                    <asp:Parameter Name="AziendaUnitaOperativa" Type="String"></asp:Parameter>
                                                </SelectParameters>
                                            </asp:ObjectDataSource>
                                        </div>

                                    </div>
                                </div>
                            </div>
									</ContentTemplate>
							</asp:UpdatePanel>
                            <div class="row">
                                <div class="col-sm-6">
                                    <div class="form-group form-group-sm">
                                        <asp:Label runat="server" ID="lblStatoEpisodio" AssociatedControlID="ddlStatoEpisodio" CssClass="control-label  col-sm-3">Stato episodio</asp:Label>
                                        <div class="col-sm-6">
                                            <asp:DropDownList runat="server" ID="ddlStatoEpisodio" CssClass="form-control">
                                                <asp:ListItem Text="Ricoverato" Selected="True" Value="1"></asp:ListItem>
                                                <asp:ListItem Text="Dimesso" Value="0"></asp:ListItem>
                                                <asp:ListItem Text="In Prenotazione" Value="3"></asp:ListItem>
                                            </asp:DropDownList>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-sm-6">
                                    <div class="form-group form-group-sm">
                                        <div class="col-sm-offset-3 col-sm-6">
                                            <asp:Button runat="server" ID="btnCercaRicoverati" ClientIDMode="Static" CssClass="btn btn-primary btn-sm" OnClientClick="ShowModalCaricamento();" Text="Cerca" />
                                            <img id="loader" class="loader" src="../Images/refresh.gif" style="display: none;" />
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>


    <%-- ROW GVPAZIENTIRICOVERATI --%>
    <div class="row">
        <div class="col-sm-12">
            <asp:GridView EmptyDataText="Nessun risultato" runat="server" ID="gvPazientiRicoverati" ClientIDMode="Static"
                DataKeyNames="Id,EpisodioNumeroNosologico,EpisodioAziendaErogante,EpisodioStrutturaUltimoEventoCodice,EpisodioStrutturaConclusioneCodice"
                DataSourceID="odsPazientiRicoverati" AutoGenerateColumns="False" CssClass="tablesorter table table-bordered table-bordered table-hover small">
                <Columns>
                    <asp:TemplateField HeaderStyle-CssClass="hiddenCol" ItemStyle-CssClass="hiddenCol">
                        <ItemTemplate>
                            <%-- ATTENZIONE: non cancellare questa colonna. Serve per gestire l'onClick event sull'intera riga. --%>
                            <asp:Button ID="Row" OnClientClick="ShowModalCaricamento();" ClientIDMode="Static" Text="do something" runat="server" CommandArgument='<%#Eval("Id")%>' />
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Paziente">
                        <ItemTemplate>
                            <%# String.Format("{0} {1} ({2})", Eval("Cognome"), Eval("Nome"), Eval("Sesso")) %>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Informazioni anagrafiche">
                        <ItemTemplate>
                            <%# String.Format("Nat{0} il {1:d} a {2}<br/>CF: {3}", If(Eval("Sesso") = "F", "a", "o"), CType(Eval("DataNascita"), DateTime).ToString("d"), Eval("ComuneNascitaDescrizione"), Eval("CodiceFiscale")) %>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Ricovero">
                        <ItemTemplate>
                            <%# String.Format("Nosologico: {0}<br />{1} {2} dal {3:d}", Eval("EpisodioNumeroNosologico"), If(ddlStatoEpisodio.SelectedValue = 3, "Prenotato nel reparto", "Ricoverato nel reparto"), Eval("EpisodioStrutturaUltimoEventoDescrizione"), Eval("EpisodioDataApertura")) %>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Consenso">
                        <ItemTemplate>
                            <img src='<%# getConsensoImg(Eval("ConsensoAziendaleCodice")) %>' />
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>
    </div>

    <%-- ODS PAZIENTIRICOVERATI--%>
    <asp:ObjectDataSource ID="odsPazientiRicoverati" runat="server" OldValuesParameterFormatString="{0}" SelectMethod="GetDataDwh" TypeName="CustomDataSource+Pazienti">
        <SelectParameters>
            <asp:ControlParameter ControlID="txtCognomeRicoverati" PropertyName="Text" Name="cognome" Type="String"></asp:ControlParameter>
            <asp:ControlParameter ControlID="txtNomeRicoverati" PropertyName="Text" Name="nome" Type="String"></asp:ControlParameter>
            <asp:ControlParameter ControlID="ddlUO" PropertyName="SelectedValue" Name="uo" Type="String"></asp:ControlParameter>
            <asp:ControlParameter ControlID="ddlTipoRicovero" PropertyName="SelectedValue" Name="tipoRicovero" Type="String"></asp:ControlParameter>
            <asp:ControlParameter ControlID="ddlStatoEpisodio" PropertyName="SelectedValue" Name="idStatoEpisodio" Type="Int32"></asp:ControlParameter>
        </SelectParameters>
    </asp:ObjectDataSource>

    <style>
        .hiddenCol {
            display: none;
        }
    </style>
    <script type="text/javascript">
        var _idComboUO = '<%=ddlUO.ClientId %>';

        //ATTENZIONE:
        //Codice utilizzato per la gestione dell'onclick sull'intera riga.
        //Al click sulla riga esegue il click sul bottone contenuto nella prima colonna, in questo modo facciamo scattare il RowCommand della GridView.
        $("#gvPazientiRicoverati tr td:not(:first-child)").click(function () {
            var btn = $(this).parent().find("input")[0];
            $(btn).trigger('click');
        });
        $("#gvPazientiRicoverati tr").css("cursor", "pointer");
        $(document).keydown(function (e) {
            var keycode = (e.keyCode ? e.keyCode : e.which);

            if (keycode === 13) {
                $('#btnCercaRicoverati').trigger('click');
            }
        });
    </script>
</asp:Content>
