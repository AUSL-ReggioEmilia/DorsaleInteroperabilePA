<%@ Page Language="VB" MasterPageFile="~/Portale/Default.master" AutoEventWireup="false" Inherits="DwhClinico.Web.Reports" title="" Codebehind="Reports.aspx.vb" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder" Runat="Server">
    
    <table cellpadding="0" cellspacing="0" border="0" class="ExpandWidthHeight" id="tblContainer">
    
        <tr id="trMenuTop" >
            <td height="1" id="tdMenuTopContainer">
            </td>
        </tr>
        
        <tr>
            <td valign="top">
            
                <table id="ucPageTitle_tblMain" class="PageTitleContent" cellspacing="0" cellpadding="0"
                    border="0">
                    <tr>
                        <td class="PageTitle">
                            <span id="ucPageTitle_lblTitle">Reports page</span>
                        </td>
                    </tr>
                </table>
                
                <table id="tblMain" class="ExpandWidth" cellspacing="0" cellpadding="0" border="0"
                    style="border-width: 0px; height: 100%; border-collapse: collapse;">
                    <tr>
                        <td valign="top">
                            <div id="ModuleContent" class="ModuleContent">
                                <p align="center">
                                    <br />
                                    <img alt="" hspace="0" src="images/HomeReports.jpg" align="baseline" border="0"/><br />
                                </p>
                                <p>
                                    La sezione report consente di consultare le statistiche di accesso e delle orchestrazioni in corso.
                                </p>
                            </div>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>

</asp:Content>

