<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="ucMenuRuoliUtente.ascx.vb" Inherits="DwhClinico.Web.ucMenuRuoliUtente" %>
<ul id="MainMenuRight" class="nav navbar-nav navbar-right">
    <li class="dropdown">
        <a class="dropdown-toggle" data-toggle="dropdown" href="#">
            <span class="glyphicon glyphicon-user" aria-hidden="true"></span>
            <asp:Label ID="lblLegend" runat="server" Text="Info Utente"></asp:Label>
            -
                                     <asp:Label ID="lblRuoloUtente" runat="server"></asp:Label><span class="caret"></span>
        </a>
        <ul class="dropdown-menu" style="width: 300px;">
            <li>
                <div id="divUtente">
                    <fieldset>
                        <div class="form-group col-sm-12" id="trRuoli" runat="server">
                            <asp:Label Text="Ruolo:" runat="server" AssociatedControlID="cmbRuoliUtente"></asp:Label>
                            <asp:DropDownList ID="cmbRuoliUtente" runat="server" AutoPostBack="True" CssClass="form-control input-sm">
                            </asp:DropDownList>
                        </div>
                        <div class="form-group col-sm-12">
                            <asp:Label Text="Nome Utente:" runat="server" AssociatedControlID="cmbRuoliUtente"></asp:Label>
                            <asp:Label ID="lblUtente" runat="server" Text=""></asp:Label>
                        </div>
                        <div class="form-group col-sm-12">
                            <asp:Label Text="Postazione:" runat="server" AssociatedControlID="cmbRuoliUtente" />
                            <asp:Label ID="lblPostazione" runat="server" Text=""></asp:Label>
                        </div>
                    </fieldset>
                </div>
            </li>
            <li role="separator" class="divider"></li>
            <li>
                <fieldset>
                    <div class="form-group col-sm-12">
                        <asp:Label Text="Ultimo accesso:" runat="server" AssociatedControlID="cmbRuoliUtente" />
                        <asp:Label ID="lblUltimoAccesso" runat="server" Text=""></asp:Label>
                    </div>
                </fieldset>
            </li>
            <li role="separator" class="divider"></li>
            <li>
                <fieldset>
                    <div class="form-group col-sm-12">
                        <asp:Label Text="Versione:" runat="server" AssociatedControlID="versioneAssembly" />
                        <asp:Label ID="versioneAssembly" runat="server" />
                    </div>
                    <div class="form-group col-sm-12">
                        <asp:Label Text="Host:" runat="server" AssociatedControlID="nomeHost" />
                        <asp:Label ID="nomeHost" runat="server" />
                    </div>
                </fieldset>
            </li>
        </ul>
    </li>
</ul>
