
-- =============================================
-- Author:		Francesco Pichierri
-- Modify date: 2012-02-23
-- Description:	Seleziona la prestazione per descrizione e unità operativa
-- Modified: il 05/08/2014 da Valerio Cremonini - modificato il filtro, sono esclusi solo i profili personali
-- Modified: il 14/10/2014 da Stefano P. - aggiunta stringa disattivo su descrizione 
-- =============================================

CREATE PROCEDURE [dbo].[UiPrestazioniSelect]

@ID as uniqueidentifier = NULL,
@CodiceDescrizione as varchar(max) = NULL,
@IDSistemaErogante as uniqueidentifier = NULL,
@Attivo as bit= NULL

AS
BEGIN
SET NOCOUNT ON

SELECT TOP 5000 
	   Prestazioni.[ID]
      ,[DataInserimento]
      ,[DataModifica]
      ,NULL AS IDUtente
      ,UtenteModifica as UserName
      ,Prestazioni.[Codice]

      ,CASE 
         WHEN Tipo BETWEEN 1 AND 2 THEN ISNULL('(Profilo) ' + Prestazioni.[Descrizione],Prestazioni.Codice)      
         ELSE ISNULL(Prestazioni.[Descrizione],Prestazioni.Codice)
       END +
       CASE 
		 WHEN Prestazioni.Attivo = 0 THEN ' (Disattivo)' 
		  ELSE '' 
	   END AS Descrizione
	   
      ,[Tipo]
      ,[Provenienza]
      ,[IDSistemaErogante]
      
      ,CASE        
         WHEN Tipo BETWEEN 1 AND 2 THEN  '(Profilo)' 
         ELSE Sistemi.CodiceAzienda + '-' + Sistemi.Codice + 
				CASE 
					WHEN Sistemi.Attivo = 0 THEN ' (Disattivo)'  
					ELSE '' 	
				END		
       END AS SistemaErogante       
	  
	  ,Prestazioni.Attivo
	   
FROM Prestazioni 

LEFT JOIN Sistemi ON Sistemi.ID = Prestazioni.IDSistemaErogante			

WHERE 
	(@ID IS NULL OR Prestazioni.ID = @ID)
	AND (@CodiceDescrizione IS NULL OR Prestazioni.[Codice] LIKE '%'+@CodiceDescrizione+'%' 
		OR Prestazioni.Descrizione LIKE '%'+@CodiceDescrizione+'%')
	AND (@IDSistemaErogante IS NULL OR IDSistemaErogante = @IDSistemaErogante)
	AND (@Attivo IS NULL OR Prestazioni.Attivo = @Attivo)
	AND Prestazioni.Tipo <> 3

ORDER BY Codice


END



























GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiPrestazioniSelect] TO [DataAccessUi]
    AS [dbo];

