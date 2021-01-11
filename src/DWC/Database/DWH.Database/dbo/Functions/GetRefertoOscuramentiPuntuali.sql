



-- =============================================
-- Author:      Stefano P.
-- Create date: 2015-05-20
-- Modify date: 2016-10-14 Stefano P.: Aggiunto filtro ApplicaDWH
-- Modify date: 2017-10-16 Ettore: Utilizzata la nuova Table Function generale degli oscuramenti
-- Description: Ritorna 1 se il referto passato è oscurato da un oscuramento di tipo PUNTUALE
-- =============================================
CREATE FUNCTION [dbo].[GetRefertoOscuramentiPuntuali]
(
 @IdEsternoReferto varchar(64),
 @AziendaErogante varchar(16),
 @SistemaErogante varchar(16),
 @NumeroNosologico varchar(64),
 @NumeroPrenotazione varchar(32),
 @NumeroReferto varchar(16),
 @IdOrderEntry varchar(64)
)  
RETURNS BIT 
AS  
BEGIN
	
	IF EXISTS (SELECT * FROM [dbo].[OttieniRefertoOscuramenti] (
								   NULL
								  ,'Puntuali'
								  ,'DWH'
								  ,@IdEsternoReferto 
								  ,NULL
								  ,NULL
								  ,@AziendaErogante
								  ,@SistemaErogante
								  ,@NumeroNosologico
								  ,@NumeroPrenotazione
								  ,@NumeroReferto
								  ,@IdOrderEntry
								  ,NULL
								  ,NULL
								  ,NULL
								  ,NULL)
					)
	BEGIN 
		RETURN 1 
	END
	RETURN 0

END


