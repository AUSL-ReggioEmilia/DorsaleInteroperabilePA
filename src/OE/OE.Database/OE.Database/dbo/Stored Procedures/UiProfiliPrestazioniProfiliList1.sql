

CREATE PROCEDURE [dbo].[UiProfiliPrestazioniProfiliList1]
					   

@IdProfilo as uniqueidentifier,
@CodiceDescrizione as varchar(max) = NULL,
@IDSistemaErogante as uniqueidentifier = NULL

AS
BEGIN
SET NOCOUNT ON

select Prestazioni.[ID]
      ,[DataInserimento]
      ,[DataModifica]         
      ,Prestazioni.UtenteModifica
      ,Prestazioni.[Codice]
      --,CASE Tipo
      -- WHEN 0 THEN ISNULL(Prestazioni.[Descrizione] + CASE WHEN Prestazioni.Attivo = 0 THEN ' (Disattivo)'  ELSE '' END ,Prestazioni.Codice + CASE WHEN Prestazioni.Attivo = 0 THEN ' (Cancellato)'  ELSE '' END)
      -- WHEN 1 THEN  ISNULL('(Profilo) ' + Prestazioni.[Descrizione] + CASE WHEN Prestazioni.Attivo = 0 THEN ' (Disattivo)'  ELSE '' END,Prestazioni.Codice + CASE WHEN Prestazioni.Attivo = 0 THEN ' (Cancellato)'  ELSE '' END)
      -- WHEN 2 THEN  ISNULL('(Profilo) ' + Prestazioni.[Descrizione] + CASE WHEN Prestazioni.Attivo = 0 THEN ' (Disattivo)'  ELSE '' END,Prestazioni.Codice + CASE WHEN Prestazioni.Attivo = 0 THEN ' (Cancellato)'  ELSE '' END)
      -- ELSE ISNULL(Prestazioni.[Descrizione],Prestazioni.Codice)      
      -- END
      -- AS Descrizione
      ,CASE Tipo
       WHEN 0 THEN ISNULL(Prestazioni.[Descrizione] + CASE WHEN Prestazioni.Attivo = 0 THEN ' (Disattivo)'  ELSE '' END ,Prestazioni.Codice + CASE WHEN Prestazioni.Attivo = 0 THEN ' (Disattivo)'  ELSE '' END)
       WHEN 1 THEN  ISNULL(Prestazioni.[Descrizione] + CASE WHEN Prestazioni.Attivo = 0 THEN ' (Disattivo)'  ELSE '' END,Prestazioni.Codice + CASE WHEN Prestazioni.Attivo = 0 THEN ' (Disattivo)'  ELSE '' END)
       WHEN 2 THEN  ISNULL(Prestazioni.[Descrizione] + CASE WHEN Prestazioni.Attivo = 0 THEN ' (Disattivo)'  ELSE '' END,Prestazioni.Codice + CASE WHEN Prestazioni.Attivo = 0 THEN ' (Disattivo)'  ELSE '' END)
       ELSE ISNULL(Prestazioni.[Descrizione],Prestazioni.Codice)      
       END
       AS Descrizione
      ,[Tipo]
      ,[Provenienza]
      ,[IDSistemaErogante]
      --,(Sistemi.CodiceAzienda + '-' + ISNULL(Sistemi.Descrizione + CASE WHEN Sistemi.Attivo = 0 THEN ' (Disattivo)'  ELSE '' END, Sistemi.Codice + CASE WHEN Sistemi.Attivo = 0 THEN ' (Disattivo)'  ELSE '' END)) as SistemaErogante      
     	  
      ,CASE Tipo
       WHEN 0 THEN (Sistemi.CodiceAzienda + '-' + ISNULL( Sistemi.Codice + CASE WHEN Sistemi.Attivo = 0 THEN ' (Disattivo)'  ELSE '' END,Sistemi.Descrizione + CASE WHEN Sistemi.Attivo = 0 THEN ' (Disattivo)'  ELSE '' END))
       WHEN 1 THEN  '(Profilo) ' 
       WHEN 2 THEN  '(Profilo) ' 
       ELSE (Sistemi.CodiceAzienda + '-' + ISNULL( Sistemi.Codice + CASE WHEN Sistemi.Attivo = 0 THEN ' (Disattivo)'  ELSE '' END,Sistemi.Descrizione + CASE WHEN Sistemi.Attivo = 0 THEN ' (Disattivo)'  ELSE '' END))      
       END
       AS SistemaErogante
     	  
     	   
from PrestazioniProfili left join Prestazioni on Prestazioni.ID = PrestazioniProfili.IDFiglio
						left join Sistemi on Sistemi.ID = Prestazioni.IDSistemaErogante
						
								  
where PrestazioniProfili.IDPadre = @IdProfilo
  AND (@CodiceDescrizione IS NULL OR Prestazioni.[Codice] LIKE '%' + @CodiceDescrizione + '%' OR Prestazioni.Descrizione LIKE '%' + @CodiceDescrizione + '%')
  AND (@IDSistemaErogante IS NULL OR IDSistemaErogante = @IDSistemaErogante)
  AND Prestazioni.Attivo = 1
  --and Tipo = 1
order by Codice

SET NOCOUNT OFF
END










GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiProfiliPrestazioniProfiliList1] TO [DataAccessUi]
    AS [dbo];

