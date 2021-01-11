


-- =============================================
-- Author:      Stefano P.
-- Create date: 2015-05-20
-- Modify date: 2016-10-14 Stefano P.: Aggiunto filtro ApplicaDWH
-- Modify date: 2017-04-07 Ettore: Adeguamento per gestire sistemi eroganti di ricoveri diversi da ADT
-- Modify date: 2017-10-16 Ettore: Utilizzo della n uova TABLE FUNCTION generale per gli oscuramenti
-- Description: Ottiene la lista dei codici di oscuramento di tipo MASSIVO per il referto passato, 
--	se presenti restituisce gli Id dei ruoli che possono bypassare l'oscuramento
-- =============================================
CREATE FUNCTION [dbo].[GetRefertoOscuramenti]
(
 @IdReferto uniqueidentifier,
 @DataPartizione smalldatetime,
 @AziendaErogante varchar(16),
 @SistemaErogante varchar(16),
 @StrutturaEroganteCodice varchar(16),
 @NumeroNosologico varchar(64),
 @RepartoRichiedenteCodice varchar(16),
 @RepartoErogante varchar(64),
 @Confidenziale AS BIT
)  
RETURNS TABLE
AS
	RETURN

	SELECT CodiceOscuramento, IdRuolo 
	FROM [dbo].[OttieniRefertoOscuramenti] (
								   NULL
								  ,'Massivi'
								  ,'DWH'
								  ,NULL
								  ,@IdReferto
								  ,@DataPartizione
								  ,@AziendaErogante
								  ,@SistemaErogante
								  ,@NumeroNosologico
								  ,NULL
								  ,NULL
								  ,NULL
								  ,@StrutturaEroganteCodice
								  ,@RepartoRichiedenteCodice
								  ,@RepartoErogante 
								  ,@Confidenziale)
	

