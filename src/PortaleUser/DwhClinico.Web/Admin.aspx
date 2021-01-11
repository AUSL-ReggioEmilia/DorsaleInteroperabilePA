<%@ Page Language="VB" MasterPageFile="~/Portale/Default.master" AutoEventWireup="false" Inherits="DwhClinico.Web.Admin" title="" Codebehind="Admin.aspx.vb" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder" Runat="Server">

    <table cellpadding="0" cellspacing="0" border="0" class="ExpandWidthHeight" id="tblContainer">
    
        <tr id="trMenuTop" height="1">
            <td id="tdMenuTopContainer">
            </td>
        </tr>
        
        <tr>
            <td valign="top">
            
                <table id="ucPageTitle_tblMain" class="PageTitleContent" cellspacing="0" cellpadding="0"
                    border="0">
                    <tr>
                        <td class="PageTitle">
                            <span id="ucPageTitle_lblTitle">Admin page</span>
                        </td>
                    </tr>
                </table>
                
                <table id="tblMain" class="ExpandWidth" cellspacing="0" cellpadding="0" border="0"
                    style="border-width: 0px; height: 100%; border-collapse: collapse;">
                    <tr>
                        <td valign="Top">
                            <div id="ModuleContent" class="ModuleContent">
                                <p align="center">
                                    <br />
                                    <img alt="" hspace="0" src="images/HomeAdmin.jpg" align="baseline" border="0"><br />
                                </p>
                                <p>
                                    La sezione admin consente di configurare le visualizzazioni dei referti.
                                </p>
                            </div>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>

</asp:Content>

