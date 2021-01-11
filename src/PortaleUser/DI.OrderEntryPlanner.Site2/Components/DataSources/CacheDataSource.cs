using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Caching;

namespace OrderEntryPlanner.Components.DataSources
{
    public class CacheDataSource<T>
    {
        public CacheDataSource()
        {

            // Modifica Leo 2019/12/10: Controllo e correzione Cache su etichette
            // Durata della cache in secondi!
            CacheDuration = 300;
            CacheDataKey = OriginalCacheDatakey;
        }

        public string OriginalCacheDatakey
        {
            get
            {
                // 
                // Per costruire la key sfrutto anche l'HashCode dell'Url.
                // 
                string sPath = HttpContext.Current.Request.Url.GetHashCode().ToString();

                return string.Format("{0}_{1}_{2}", HttpContext.Current.User.Identity.Name, sPath.ToUpper(), typeof(T).Name);
            }
        }

        /// <summary>
        /// Durata della Cache in Secondi
        /// </summary>
        public virtual int CacheDuration { get; set; }

        public string CacheDataKey { get; set; }

        public void ClearCache()
        {
            // 
            // Vuota la cache
            // 
            this.CacheData = default(T);
        }

        public T CacheData
        {
            get
            {
                object oData = HttpContext.Current.Cache[CacheDataKey];
                if (oData != null)
                {
                    // 
                    // Cast as T
                    // 
                    if (oData is T)
                        return (T)oData;
                    else
                        return default(T);
                }
                else
                    return default(T);
            }
            set
            {
                // 
                // Vuota, salva in cache
                // 
                if (value == null)
                    HttpContext.Current.Cache.Remove(CacheDataKey);
                else
                    HttpContext.Current.Cache.Insert(CacheDataKey, value, null, DateTime.UtcNow.AddSeconds(CacheDuration), Cache.NoSlidingExpiration);
            }
        }
    }
}

