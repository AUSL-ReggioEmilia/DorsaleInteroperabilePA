

-- =============================================
-- Author:      Ettore
-- Create date: 2015-05-21
-- Modify date: 
-- Description: Ottiene la lista XML dei codici di oscuramento di tutti gli oscuramenti a cui il referto è soggetto, 
--	se presenti restituisce gli Id dei ruoli che possono bypassare l'oscuramento
-- =============================================

CREATE FUNCTION [dbo].[GetRefertoOscuramentiXml]
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
RETURNS XML
AS
BEGIN

	RETURN (
			SELECT CAST( 
				(	SELECT CodiceOscuramento, IdRuolo 
					FROM dbo.GetRefertoOscuramenti(@IdReferto, @DataPartizione, @AziendaErogante
									, @SistemaErogante, @StrutturaEroganteCodice, @NumeroNosologico
									, @RepartoRichiedenteCodice, @RepartoErogante, @Confidenziale) AS Oscuramento 
					FOR XML AUTO , ROOT('Oscuramenti') )  AS XML
			)
		) 
END
