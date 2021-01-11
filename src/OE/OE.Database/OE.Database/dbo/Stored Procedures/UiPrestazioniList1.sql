
-- =============================================
-- Author:		Francesco Pichierri
-- Modify date: 2012-02-23
-- Description:	Seleziona le prestazioni per gruppo, descrizione e sistyema erogante
-- Modified: il 05/08/2014 da Valerio Cremonini - modificato il filtro, sono esclusi solo i profili personali
-- Modified: il 14/10/2014 da Stefano P.- aggiunta stringa disattivo su descrizione prestazione
-- =============================================

CREATE PROCEDURE [dbo].[UiPrestazioniList1]

@IDGruppo as uniqueidentifier,
@CodiceDescrizione as varchar(max) = NULL,
@IDSistemaErogante as uniqueidentifier = NULL

AS
BEGIN
SET NOCOUNT ON

SELECT Prestazioni.[ID]
      ,[DataInserimento]
      ,[DataModifica]
      --,[IDTicketInserimento]
      --,[IDTicketModifica]      
      ,NULL as IDUtente
      ,Prestazioni.UtenteModifica
      ,Prestazioni.[Codice]
      --,ISNULL(Prestazioni.[Descrizione],Prestazioni.Codice) as Descrizione      
      /*CASE Tipo
        WHEN 0 THEN ISNULL(Prestazioni.[Descrizione] + 
							CASE 
							 WHEN Prestazioni.Attivo = 0 THEN ' (Disattivo)'  
							 ELSE '' 
							END, Prestazioni.Codice + 
							CASE 
							 WHEN Prestazioni.Attivo = 0 THEN ' (Disattivo)'  
							 ELSE '' 
							END)
       
        WHEN 1 THEN  ISNULL(Prestazioni.[Descrizione] + 
							CASE 
							 WHEN Prestazioni.Attivo = 0 THEN ' (Disattivo)'  
							 ELSE '' 
							END, Prestazioni.Codice + 
							CASE 
							 WHEN Prestazioni.Attivo = 0 THEN ' (Disattivo)'  
							 ELSE '' 
							END)
       
        WHEN 2 THEN  ISNULL(Prestazioni.[Descrizione] + 
							CASE 
							 WHEN Prestazioni.Attivo = 0 THEN ' (Disattivo)'  
							 ELSE '' 
							END, Prestazioni.Codice + 
							CASE 
							 WHEN Prestazioni.Attivo = 0 THEN ' (Disattivo)'  
							 ELSE '' 
							END)
        ELSE ISNULL(Prestazioni.[Descrizione],Prestazioni.Codice)     + ' aaa' 
       
       END*/
       
       ,ISNULL(Prestazioni.[Descrizione],Prestazioni.Codice) + 
			CASE 
			 WHEN Prestazioni.Attivo = 0 THEN ' (Disattivo)'  
			 ELSE '' 
			END AS Descrizione       
      ,[Tipo]
      ,[Provenienza]
      ,[IDSistemaErogante]
  ,CASE Tipo
       WHEN 0 THEN (Sistemi.CodiceAzienda + '-' + ISNULL(Sistemi.Codice + CASE WHEN Sistemi.Attivo = 0 THEN ' (Disattivo)'  ELSE '' END,Sistemi.Descrizione + CASE WHEN Sistemi.Attivo = 0 THEN ' (Disattivo)'  ELSE '' END))
       WHEN 1 THEN  '(Profilo) ' 
       WHEN 2 THEN  '(Profilo) ' 
       ELSE (Sistemi.CodiceAzienda + '-' + ISNULL(Sistemi.Codice + CASE WHEN Sistemi.Attivo = 0 THEN ' (Disattivo)'  ELSE '' END,Sistemi.Descrizione + CASE WHEN Sistemi.Attivo = 0 THEN ' (Disattivo)'  ELSE '' END))      
       END
       AS SistemaErogante

	   
from PrestazioniGruppiPrestazioni 
LEFT JOIN Prestazioni on Prestazioni.ID = PrestazioniGruppiPrestazioni.IDPrestazione
LEFT JOIN Sistemi on Sistemi.ID = Prestazioni.IDSistemaErogante
				  
where PrestazioniGruppiPrestazioni.IDGruppoPrestazioni = @IDGruppo
  AND (@CodiceDescrizione IS NULL OR Prestazioni.[Codice] LIKE '%' + @CodiceDescrizione + '%' OR Prestazioni.Descrizione LIKE '%' + @CodiceDescrizione + '%')
  AND (@IDSistemaErogante IS NULL OR IDSistemaErogante = @IDSistemaErogante)
  --AND Prestazioni.Attivo = 1
 AND Tipo <> 3
order by Codice

SET NOCOUNT OFF
END









GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiPrestazioniList1] TO [DataAccessUi]
    AS [dbo];

