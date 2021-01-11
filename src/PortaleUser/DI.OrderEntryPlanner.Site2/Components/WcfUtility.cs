using OrderEntryPlanner.Properties;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.ServiceModel;
using System.Web;

namespace OrderEntryPlanner.Components
{
    public class WcfUtility
    {
        public static void SetCredentials(WcfPazienti.PazientiClient wcf)
        {

            string sacWsUser = Settings.Default.SacWs_User;
            string sacWsPsw = Settings.Default.SacWs_Password;

            //Se non è specificato l'utente esco
            if (String.IsNullOrEmpty(sacWsUser)) return;

            string errorMessage = string.Empty;

            BasicHttpBinding basicHttpBinding = (BasicHttpBinding)wcf.ChannelFactory.Endpoint.Binding;
            if (basicHttpBinding != null)
            {
                HttpClientCredentialType credType = basicHttpBinding.Security.Transport.ClientCredentialType;
                if (credType == HttpClientCredentialType.Basic)
                {
                    wcf.ClientCredentials.UserName.UserName = sacWsUser;
                    wcf.ClientCredentials.UserName.Password = sacWsPsw;

                    basicHttpBinding.UseDefaultWebProxy = false;
                    return;
                }
                else if (credType == HttpClientCredentialType.Windows)
                {
                    if (!String.IsNullOrEmpty(sacWsUser) && !String.IsNullOrEmpty(sacWsPsw))
                    {

                        wcf.ClientCredentials.Windows.ClientCredential = GetNetworkCredential(sacWsUser, sacWsPsw);
                    }
                    return;
                }
                else
                {
                    errorMessage = $"Il tipo di credenziali 'HttpClientCredentialType.{credType.ToString()}' non è gestito!";
                    errorMessage = $"{errorMessage} \r\n I tipi di credenziali gestiti sono: 'HttpClientCredentialType.Basic', 'HttpClientCredentialType.Windows'.";
                    throw new ApplicationException(errorMessage);
                }
            }


            WSHttpBinding wsHttpBinding = (WSHttpBinding)(wcf.ChannelFactory.Endpoint.Binding);
            if (wsHttpBinding != null)
            {
                HttpClientCredentialType credType = wsHttpBinding.Security.Transport.ClientCredentialType;
                if (credType == HttpClientCredentialType.Basic)
                {
                    wcf.ClientCredentials.UserName.UserName = sacWsUser;
                    wcf.ClientCredentials.UserName.Password = sacWsPsw;
                    wsHttpBinding.UseDefaultWebProxy = false;
                    return;
                }
                else if (credType == HttpClientCredentialType.Windows)
                {
                    if (!String.IsNullOrEmpty(sacWsUser) && !String.IsNullOrEmpty(sacWsPsw))
                    {

                        wcf.ClientCredentials.Windows.ClientCredential = GetNetworkCredential(sacWsUser, sacWsPsw);
                    }
                    return;
                }
                else
                {
                    errorMessage = $"Il tipo di credenziali 'HttpClientCredentialType.{credType.ToString()}' non è gestito!";
                    errorMessage = $"{errorMessage} \r\n I tipi di credenziali gestiti sono: 'HttpClientCredentialType.Basic', 'HttpClientCredentialType.Windows'.";
                    throw new ApplicationException(errorMessage);
                }
            }

            // Se sono qui il tipo di binding non è gestito
            errorMessage = $"Il tipo di binding {wcf.ChannelFactory.Endpoint.Binding.ToString()}' non è gestito!";
            errorMessage = $"{errorMessage} \r\n Utilizzare il tipo di binding 'BasicHttpBinding'/'WsHttpBinding'.";
            throw new ApplicationException(errorMessage);

        }

        private static NetworkCredential GetNetworkCredential(string User, string Password)
        {
            NetworkCredential networkCredential;


            if (!(string.IsNullOrEmpty(User)))
            {
                string domain = string.Empty;
                string[] account = User.Replace("\\", "/").Split('/');

                if (account.Length > 1)
                {
                    domain = account[0];
                    User = account[1];
                }

                networkCredential = new NetworkCredential(User, Password, domain);
            }
            else
            {
                networkCredential = (NetworkCredential)CredentialCache.DefaultCredentials;
            }

            return networkCredential;
        }

    }
}