<%@ Control Language="VB" CodeBehind="MultiForeignKey.ascx.vb" Inherits="MultiForeignKey" %>

<div class="dropdown">

    <button type="button" class="btn btn-default btn-sm dropdown-toggle form-control"
        data-toggle="dropdown" aria-haspopup="true" aria-expanded="true">
        Seleziona<span class="glyphicon glyphicon-menu-down pull-right"></span>
    </button>

    <ul class="dropdown-menu">
        <li>
            <fieldset>
                <div class="checkboxlist">
                    <asp:Button ID="BtnSelezionaTutti" runat="server" Text="Deseleziona tutti" class="btn btn-default btn-center" />
                    <asp:CheckBoxList runat="server" ID="CheckBoxList1"
                        AutoPostBack="True"
                        RepeatLayout="Flow"
                        RepeatDirection="Vertical"
                        CssClass="checkbox checkboxlist-custom-left-margin">
                    </asp:CheckBoxList>
                </div>
            </fieldset>
        </li>
    </ul>
</div>

<style>
    .checkboxlist-custom-left-margin {
        line-height: 150%;
        padding-top: 0px !important;
    }

        .checkboxlist-custom-left-margin > label, .checkboxlist-custom-left-margin > input {
            margin-left: 10px !important;
        }

    .dropdown-toggle {
        text-align: left;
        padding-left: 10px !important;
    }

    .dropdown-menu {
        width: 100%;
    }

    .checkboxlist {
        max-height: 300px;
        overflow-y: auto;
    }

    .btn-center
    {
        margin:auto;
        display:block;
    }

</style>
