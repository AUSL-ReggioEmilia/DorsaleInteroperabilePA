using OrderEntryPlanner.Properties;
using OrderEntryPlanner.WcfOrderEntry;
using System;
using System.Web;
using static Microsoft.ApplicationInsights.MetricDimensionNames.TelemetryContext;

namespace OrderEntryPlanner.Components
{
    public class WcfOeToken
    {

        public static OeUserToken GetOeToken()
        {
            OeUserToken userToken = null;

            if (HttpContext.Current.Session["OeToken"] != null)
            {
                userToken = (OeUserToken)HttpContext.Current.Session["OeToken"];
            }

            if (userToken == null || userToken.Token == null || userToken.Token.DataScadenza.AddMinutes(-10) <= DateTime.Now)
            {
                userToken = CreateUserData(GetToken());
            }

            return userToken;
        }


        private static TokenAccessoType GetToken()
        {
            OrderEntryV1Client wcfOeUser = new OrderEntryV1Client("BasicHttpBinding_IOrderEntryV1");
            using (wcfOeUser)
            {
                return wcfOeUser.CreaTokenAccessoDelega2(HttpContext.Current.User.Identity.Name, DI.Common.Utility.GetAziendaRichiedente(), Settings.Default.SistemaRichiedente, Utility.GetUserHostName());
            }
        }

        private static OeUserToken CreateUserData(TokenAccessoType token)
        {
            OeUserToken oeUserToken = new OeUserToken(token);

            HttpContext.Current.Session.Add("OeToken",oeUserToken);

            return oeUserToken;
        }
    }


    public class OeUserToken
    {
        private TokenAccessoType token;

        public TokenAccessoType Token
        {
            get
            {
                return token;
            }
        }

        public OeUserToken(TokenAccessoType tokenPar)
        {
            token = tokenPar;
        }
    }
}